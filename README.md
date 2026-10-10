<div align="center">

<img src="assets/AppIcon.svg" width="128" alt="OneShutdown icon">

# OneShutdown

**Shut down your Mac in one click, even when apps keep asking "Are you sure?"**

[![Release](https://img.shields.io/github/v/release/ZephyrDeng/one-shutdown?style=flat-square&color=e8264d)](https://github.com/ZephyrDeng/one-shutdown/releases/latest)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-black?style=flat-square&logo=apple)](#install)
[![Universal](https://img.shields.io/badge/Apple%20Silicon%20%2B%20Intel-universal-555?style=flat-square)](#install)
[![Swift](https://img.shields.io/badge/Swift-38%20lines-F05138?style=flat-square&logo=swift&logoColor=white)](Sources/main.swift)
[![License: MIT](https://img.shields.io/github/license/ZephyrDeng/one-shutdown?style=flat-square)](LICENSE)

English · [简体中文](README.zh-CN.md)

<img src="assets/hero.svg" alt="Before: Terminal, TextEdit and Chrome dialogs block shutdown. After: one click on the menu bar and the Mac is off." width="100%">

</div>

## The problem

It's 6:30 pm. You hit **Apple menu → Shut Down**, close the lid on the day, and walk out.

The next morning the Mac is still on, because macOS lets any app cancel a shutdown:

- **Terminal / iTerm / Warp:** *"Do you want to terminate running processes?"*
- **Editors:** *"Do you want to save the changes you made to 'Untitled'?"*
- **Browsers:** *"Quit Chrome? You have 47 tabs open."*
- **Docker, OrbStack, IDEs, chat apps:** something always has an opinion.

One dialog is enough to cancel the whole shutdown, and you won't see it until you come back.

## Who it's for

OneShutdown is for you if you **turn your Mac off every day** and already know you've saved what matters:

- 🎒 **You carry a Mac mini or MacBook** between office and home every day (that's why this exists)
- 👩‍💻 **You're a developer**: dev servers in terminals, containers and 40-tab browsers, all of which can block shutdown
- 🏢 **You power off a shared or office Mac** at the end of the day, for security or energy rules

If you mostly put your Mac to sleep, or you rely on those *"Save changes?"* prompts as a safety net, this isn't for you.

## How it works

Click the <kbd>⏻</kbd> icon in the menu bar → **Shut Down Now**. That's it.

1. Every regular app (anything with a Dock icon) is **force-quit**, so no app gets a chance to ask a question.
2. One second later, macOS shuts down normally.

Finder, background services and menu-bar utilities are left alone and quit as part of the regular shutdown.

|  | Apple menu → Shut Down | `sudo shutdown -h now` | **OneShutdown** |
|---|:---:|:---:|:---:|
| Apps can cancel it with dialogs | ❌ yes | ✅ no | ✅ no |
| Needs Terminal + admin password | ✅ no | ❌ yes | ✅ no |
| Steps | 2 clicks + 1 per dialog | open Terminal, type, password | **1 click** |

> [!WARNING]
> **Unsaved work is discarded. That's the whole point.** Save what matters first. Browsers and editors with session restore (Chrome, VS Code, …) usually reopen where you left off.

## Install

1. Download **`OneShutdown.zip`** from the [latest release](https://github.com/ZephyrDeng/one-shutdown/releases/latest), unzip it, and drag `OneShutdown.app` into `/Applications`.
2. Open it. A power icon appears in the menu bar. No Dock icon, no window.
3. *(Optional)* Start it at login: **System Settings → General → Login Items → +** → pick OneShutdown.

<details>
<summary><b>"OneShutdown can't be opened" / "Apple could not verify…"</b></summary>

The app is signed with a Developer ID but not notarized yet. Allow it once:

- **System Settings → Privacy & Security** → scroll down → **Open Anyway**, or
- run in Terminal:

  ```bash
  xattr -dr com.apple.quarantine /Applications/OneShutdown.app
  ```

</details>

<details>
<summary><b>macOS asks to let OneShutdown control "System Events"</b></summary>

Click **Allow**. OneShutdown asks System Events to shut down the Mac, the same way the Apple menu does. No sudo, no password. If you clicked *Don't Allow*, turn it back on in **System Settings → Privacy & Security → Automation**.

</details>

## Build from source

No Xcode project and no dependencies, just the `swiftc` that ships with the Command Line Tools:

```bash
git clone https://github.com/ZephyrDeng/one-shutdown.git
cd one-shutdown
./build.sh                 # → build/OneShutdown.app (universal, macOS 13+)
open build/OneShutdown.app
```

The whole app is [38 lines of Swift](Sources/main.swift). Read it before you run it.

## Ideas & contributing

Issues and PRs are welcome. Some directions people may want:

- [ ] Global hotkey
- [ ] Restart / Log Out variants
- [ ] An "always spare these apps" list

## License

[MIT](LICENSE) © Zephyr Deng

<div align="center">

**If OneShutdown got you out the door faster today, a ⭐ helps other people find it.**

</div>
