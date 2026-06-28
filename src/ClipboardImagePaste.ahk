#Requires AutoHotkey v2.0
; ============================================================
;  SnapPaste Pro  --  ClipboardImagePaste.ahk
;  by Saqib Bin Shabbir | Full Stack Developer & Agentic AI Specialist
;
;  Mac-jaisa Ctrl+V: terminal mein agar clipboard pe IMAGE ho to use
;  PNG file mein save karke uska PATH paste karta hai. Warna normal text paste.
;  Sirf terminal windows mein active hota hai (baqi apps pe asar nahi).
; ============================================================

; Core PowerShell script ka path (isi install folder mein)
psScript := A_ScriptDir . "\Save-ClipboardImage.ps1"

; --- Sirf in terminal windows mein Ctrl+V remap ho ---
#HotIf WinActive("ahk_exe WindowsTerminal.exe")
    or WinActive("ahk_exe cmd.exe")
    or WinActive("ahk_exe powershell.exe")
    or WinActive("ahk_exe pwsh.exe")
    or WinActive("ahk_exe conhost.exe")
    or WinActive("ahk_exe OpenConsole.exe")

^v::
{
    global psScript
    ; CF_DIB = 8 : clipboard mein image (bitmap) hai ya nahi
    if DllCall("IsClipboardFormatAvailable", "UInt", 8)
    {
        ; Image hai -> PowerShell se save karo + path clipboard pe daalo (hidden, wait)
        RunWait('powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "' . psScript . '" -Quiet', , "Hide")
        ; Thoda ruko taake clipboard set ho jaye, phir path paste karo
        Sleep 80
        Send("^v")
    }
    else
    {
        ; Image nahi -> normal text paste, koi latency nahi
        Send("^v")
    }
}

#HotIf
