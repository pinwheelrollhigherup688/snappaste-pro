@echo off
REM ============================================================
REM  SnapPaste Pro  --  pasteimg  (CMD wrapper)
REM  by Saqib Bin Shabbir | Full Stack Developer & Agentic AI Specialist
REM ------------------------------------------------------------
REM  Screenshot lo (Win+Shift+S), phir CMD mein `pasteimg` chalao.
REM  Image Pictures\SnapPaste Pro mein save hoti hai aur uska path
REM  clipboard pe aa jata hai -- phir Ctrl+V se paste karo.
REM ============================================================
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0Save-ClipboardImage.ps1" %*
