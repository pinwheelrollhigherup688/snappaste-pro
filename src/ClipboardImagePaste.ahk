#Requires AutoHotkey v2.0
; ============================================================
;  SnapPaste Pro  --  ClipboardImagePaste.ahk  (native, AV-friendly)
;  by Saqib Bin Shabbir | Full Stack Developer & Agentic AI Specialist
;
;  Mac-jaisa Ctrl+V: terminal mein agar clipboard pe IMAGE ho to use
;  PNG file mein save karke uska PATH paste karta hai. Warna normal text paste.
;
;  NOTE: Ye image ko AHK ke andar GDI+ se khud save karta hai -- koi
;  hidden PowerShell/extra process spawn NAHI hota (antivirus-friendly,
;  aur fast). Sirf terminal windows mein active hota hai.
; ============================================================

SaveDir := EnvGet("USERPROFILE") . "\Pictures\SnapPaste Pro"

; --- Sirf in terminal windows mein Ctrl+V remap ho ---
#HotIf WinActive("ahk_exe WindowsTerminal.exe")
    or WinActive("ahk_exe cmd.exe")
    or WinActive("ahk_exe powershell.exe")
    or WinActive("ahk_exe pwsh.exe")
    or WinActive("ahk_exe conhost.exe")
    or WinActive("ahk_exe OpenConsole.exe")

^v::
{
    ; CF_DIB = 8 : clipboard mein image (bitmap) hai ya nahi
    if DllCall("IsClipboardFormatAvailable", "UInt", 8)
    {
        path := SaveClipboardImageToPng(SaveDir)
        if (path != "")
        {
            A_Clipboard := path          ; ab clipboard pe text path hai
            Sleep 30
        }
    }
    Send("^v")                            ; image -> path paste; warna normal text paste
}

#HotIf

; ------------------------------------------------------------
;  Clipboard ki image ko PNG file mein save karta hai (GDI+).
;  Return: saved file ka full path, warna "" (khali) agar na ho saka.
; ------------------------------------------------------------
SaveClipboardImageToPng(saveDir)
{
    if !DirExist(saveDir)
        DirCreate(saveDir)

    ; --- GDI+ start ---
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)              ; GdiplusVersion = 1
    token := 0
    if (DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", si, "Ptr", 0) != 0)
        return ""

    pBitmap := 0
    result  := ""
    try
    {
        if DllCall("OpenClipboard", "Ptr", 0)
        {
            ; CF_BITMAP = 2 (system DIB se synthesize kar deta hai)
            hbm := DllCall("GetClipboardData", "UInt", 2, "Ptr")
            if hbm
                DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hbm, "Ptr", 0, "Ptr*", &pBitmap)
            DllCall("CloseClipboard")
        }

        if pBitmap
        {
            ; PNG encoder CLSID
            clsid := Buffer(16, 0)
            DllCall("ole32\CLSIDFromString", "WStr", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "Ptr", clsid)

            pngPath := saveDir . "\screenshot_" . FormatTime(, "yyyyMMdd_HHmmss") . "_" . A_MSec . ".png"
            if (DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "WStr", pngPath, "Ptr", clsid, "Ptr", 0) = 0)
                result := pngPath
        }
    }
    catch
    {
        result := ""
    }
    finally
    {
        if pBitmap
            DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
        DllCall("gdiplus\GdiplusShutdown", "Ptr", token)
    }

    return result
}
