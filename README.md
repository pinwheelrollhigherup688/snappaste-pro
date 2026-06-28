<div align="center">

# 📋 SnapPaste Pro

### Mac-style screenshot paste for Windows terminals

Paste screenshots **directly** with `Ctrl + V` in Windows **CMD**, **PowerShell**,
**Windows Terminal**, and **Claude Code** — exactly like macOS.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-blue)
![No Admin](https://img.shields.io/badge/install-no%20admin%20needed-success)

</div>

---

## 🎬 Demo

<!-- TODO: add a GIF here -->
<!-- Record: take a screenshot (Win+Shift+S) -> focus terminal -> press Ctrl+V -> path is pasted -->
<!-- Save as docs/demo.gif and uncomment: -->
<!-- ![SnapPaste Pro demo](docs/demo.gif) -->

> _Take a screenshot → press `Ctrl + V` in your terminal → the image is saved and its path is pasted automatically._

---

## ❓ Why

On macOS you can paste a screenshot straight into a terminal. On Windows you can't —
the clipboard holds an **image**, but terminals only paste **text**. So `Ctrl + V`
does nothing, and you're stuck saving the file by hand and typing its path.

**SnapPaste Pro fixes that.** When you press `Ctrl + V` in a terminal:

- 🖼️ **Image on clipboard** → it's saved as a PNG and its **file path** is pasted automatically.
- 📝 **Text on clipboard** → normal paste, no change.

Perfect for **Claude Code**, AI coding assistants, and any tool where you need to hand a screenshot to the terminal.

---

## ✨ Features

- ⚡ **Instant** — image is saved natively (no slow background processes).
- 🛡️ **Lightweight & clean** — no Python, no extra runtimes; AutoHotkey is bundled.
- 🔒 **No admin required** — installs per-user.
- 🚀 **Auto-start** — runs quietly in the background on login.
- 🎯 **Smart** — only triggers on images; text paste stays exactly as fast as before.
- 🧰 Extra commands: `pi` (PowerShell) and `pasteimg` (CMD).

---

## 📦 Install

### Option 1 — Installer (recommended)
1. Download **`SnapPaste-Pro-Setup.exe`** from the [Releases](../../releases) page.
2. Run it (Next → Next → Finish). No admin needed.
3. Done — take a screenshot and press `Ctrl + V` in your terminal.

> ### ⚠️ "Windows protected your PC" — this is normal, please read
>
> The first time you run the installer, Windows SmartScreen may show a blue
> **"Windows protected your PC"** screen with **"Unknown publisher"**.
>
> **This does _not_ mean the app is unsafe.** It only appears because the app is
> not yet code-signed (a paid certificate / Azure verification we haven't purchased
> yet). To continue:
>
> 1. Click **More info**
> 2. Click **Run anyway**
>
> That's it — it won't ask again. ✅
>
> **Why you can trust it:** the entire source code is public in this repo, so anyone
> can read exactly what it does. It works fully offline — it never sends any data
> anywhere, doesn't touch your files, and only reacts to `Ctrl + V` inside terminals.

### Option 2 — npm (for developers) _(coming soon)_
```bash
npx snappaste-pro install
```

---

## 🚀 Usage

1. Take a screenshot: **`Win + Shift + S`** (select a region).
2. In your terminal, press **`Ctrl + V`**.
3. The image is saved to `Pictures\SnapPaste Pro\` and its path is pasted.

**Extra commands**

| Shell | Command |
|---|---|
| PowerShell | `pi` then `Ctrl + V` |
| Command Prompt | `pasteimg` then `Ctrl + V` |

**Supported terminals:** Windows Terminal, CMD, PowerShell, PowerShell 7 (pwsh), Claude Code, conhost.

---

## 🛠️ How it works

A small AutoHotkey script watches for `Ctrl + V` in terminal windows. If the clipboard
contains an image, it saves it as a PNG using the Windows GDI+ API, replaces the
clipboard with the file path, and pastes that — all in a few milliseconds.

---

## 🗑️ Uninstall

**Settings → Apps → SnapPaste Pro → Uninstall.** It cleanly removes the app, the
startup entry, the PATH entry, and the PowerShell profile addition.

---

## 🧱 Build from source

Requirements: [Inno Setup 6](https://jrsoftware.org/isdl.php) and the
[AutoHotkey v2](https://www.autohotkey.com/) runtime (`AutoHotkey64.exe`) placed in `src/`.

```powershell
ISCC.exe SnapPastePro.iss
# Output: Output\SnapPaste-Pro-Setup.exe
```

---

## 📄 License

[MIT](LICENSE) © Saqib Bin Shabbir

> Bundles the [AutoHotkey](https://www.autohotkey.com/) runtime, which is licensed under the GNU GPLv2.

---

<div align="center">

**Built by Saqib Bin Shabbir** — Full Stack Developer & Agentic AI Specialist

If this saved you time, consider giving it a ⭐ — it really helps!

</div>
