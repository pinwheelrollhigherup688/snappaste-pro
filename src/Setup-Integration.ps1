<#
.SYNOPSIS
    SnapPaste Pro -- install/uninstall integration: User PATH + PowerShell profile.
    by Saqib Bin Shabbir | Full Stack Developer & Agentic AI Specialist

.DESCRIPTION
    Inno Setup is script ko install ke baad (-Action Install) aur uninstall ke waqt
    (-Action Uninstall) chalata hai. Dono kaam idempotent hain (dobara chale to gadbad na ho).

    -Action Install:
        * AppDir ko User PATH mein add karta hai (taake CMD mein `pasteimg` chale).
        * PowerShell profile ($PROFILE) mein ek marked block daalta hai jisme `pi` /
          `Paste-Image` function hota hai jo AppDir\Save-ClipboardImage.ps1 ko call kare.

    -Action Uninstall:
        * User PATH se AppDir hatata hai.
        * Profile se marked block hatata hai.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('Install','Uninstall')]
    [string]$Action,
    [Parameter(Mandatory)]
    [string]$AppDir
)

$ErrorActionPreference = 'Stop'
$AppDir = $AppDir.TrimEnd('\')

$startMarker = '# >>> SnapPaste Pro >>>'
$endMarker   = '# <<< SnapPaste Pro <<<'

# NOTE: User PATH ko registry se RAW parho (DoNotExpand) aur usi type
# (REG_EXPAND_SZ / REG_SZ) mein wapas likho. Warna [Environment]::SetEnvironmentVariable
# har baar REG_SZ likhta hai aur mojood %USERPROFILE% jaise tokens ko expand+freeze
# kar deta hai -- jo client ka PATH kharab kar sakta hai.
function Get-RawUserPath {
    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $false)
    if ($null -eq $key) {
        return [pscustomobject]@{ Value = ''; Kind = [Microsoft.Win32.RegistryValueKind]::ExpandString }
    }
    try {
        $raw = $key.GetValue('Path', $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
        if ($null -eq $raw) {
            return [pscustomobject]@{ Value = ''; Kind = [Microsoft.Win32.RegistryValueKind]::ExpandString }
        }
        return [pscustomobject]@{ Value = [string]$raw; Kind = $key.GetValueKind('Path') }
    } finally { $key.Close() }
}

function Set-RawUserPath([string]$value, $kind) {
    $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey('Environment')
    try { $key.SetValue('Path', $value, $kind) } finally { $key.Close() }
}

function Get-PathParts([string]$value) {
    return @($value -split ';' | Where-Object { $_ -ne '' })
}

function Add-ToUserPath([string]$dir) {
    $info = Get-RawUserPath
    $parts = Get-PathParts $info.Value
    if ($parts -notcontains $dir) {                 # -contains = case-insensitive
        Set-RawUserPath ((@($parts) + $dir) -join ';') $info.Kind
    }
}

function Remove-FromUserPath([string]$dir) {
    $info = Get-RawUserPath
    $parts = Get-PathParts $info.Value
    if ($parts -contains $dir) {
        Set-RawUserPath ((@($parts | Where-Object { $_ -ne $dir })) -join ';') $info.Kind
    }
}

function Get-ProfilePath {
    # $PROFILE (CurrentUserCurrentHost) -- Windows PowerShell 5.1 ke liye standard
    $p = $PROFILE
    if ([string]::IsNullOrWhiteSpace($p)) {
        $docs = [Environment]::GetFolderPath('MyDocuments')
        $p = Join-Path $docs 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
    }
    return $p
}

function Get-ProfileBlock([string]$dir) {
    $script = Join-Path $dir 'Save-ClipboardImage.ps1'
@"
$startMarker
# SnapPaste Pro -- by Saqib Bin Shabbir (Full Stack Developer & Agentic AI Specialist)
function Paste-Image {
    [CmdletBinding()]
    param([switch]`$Quiet, [switch]`$NoClipboard)
    `$script = '$script'
    if (-not (Test-Path -LiteralPath `$script)) {
        Write-Host "SnapPaste Pro script nahi mila: `$script" -ForegroundColor Red
        return
    }
    & `$script @PSBoundParameters
}
Set-Alias -Name pi -Value Paste-Image -Scope Global -Force
$endMarker
"@
}

function Remove-ProfileBlock([string]$profilePath) {
    if (-not (Test-Path -LiteralPath $profilePath)) { return }
    $content = Get-Content -LiteralPath $profilePath -Raw
    if ([string]::IsNullOrEmpty($content)) { return }
    # Marked block (start..end, beech ka sab) hatao
    $pattern = [regex]::Escape($startMarker) + '.*?' + [regex]::Escape($endMarker)
    $new = [regex]::Replace($content, $pattern, '', 'Singleline')
    # Extra blank lines tidy
    $new = $new -replace '(\r?\n){3,}', "`r`n`r`n"
    Set-Content -LiteralPath $profilePath -Value $new.TrimEnd() -Encoding UTF8
}

function Add-ProfileBlock([string]$profilePath, [string]$dir) {
    $profileDir = Split-Path -Parent $profilePath
    if (-not (Test-Path -LiteralPath $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    # Pehle purana block hatao (idempotent), phir naya add karo
    Remove-ProfileBlock $profilePath
    $block = Get-ProfileBlock $dir
    if (Test-Path -LiteralPath $profilePath) {
        Add-Content -LiteralPath $profilePath -Value "`r`n$block" -Encoding UTF8
    } else {
        Set-Content -LiteralPath $profilePath -Value $block -Encoding UTF8
    }
}

$profilePath = Get-ProfilePath

switch ($Action) {
    'Install' {
        Add-ToUserPath $AppDir
        Add-ProfileBlock $profilePath $AppDir
        Write-Host "SnapPaste Pro integration installed (PATH + profile)." -ForegroundColor Green
    }
    'Uninstall' {
        Remove-FromUserPath $AppDir
        Remove-ProfileBlock $profilePath
        Write-Host "SnapPaste Pro integration removed." -ForegroundColor Green
    }
}
