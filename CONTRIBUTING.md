Thank you for your interest in **QuickSwitch** project! This document will help you get started, understand the project's priorities, and find where your contribution will have the most impact.

<details>
<summary>Table of Contents</summary>

- [About the Project](#about-the-project)
- [Project Priorities](#project-priorities)
- [Where to Start](#where-to-start)
- [Understanding the Codebase](#understanding-the-codebase)
- [How to Contribute](#how-to-contribute)
- [Code Style & Conventions](#code-style--conventions)

</details>

## About the Project

QuickSwitch is written on [AutoHotkey](https://www.autohotkey.com/) high-level language, that has interface for Windows API functions and the best syntax for creating GUIs and Menus. 

> QuickSwitch is currently written on AutoHotkey v1. One of the long-term goals is to **migrate the codebase to AutoHotkey v2**. If you are learning AHK, start with **v2**, as v1 is a legacy version.

<details>
<summary>If you are new to AutoHotkey, follow these steps</summary>

1. Download and install the **latest AutoHotkey v2** from the [official site](https://www.autohotkey.com/download)
2. Read the [Official Documentation](https://www.autohotkey.com/docs/v2/). Even if you ignore it and start asking experienced users, the first thing they will do is point you to documentation, as it covers a huge amount of details.

Key concepts you will use in QuickSwitch:
- **Arrays and Objects** — storing paths and manager data.
- **Classes** — QuickSwitch v2 will rely on organized data.
- **WinTitle / Control** — identify each window and it's UI elements (controls).
- **WinGet.. / ControlGet..** — interacting with windows.
- **IniRead / IniWrite** — reading and writing configuration.
- **DllCall** — calling Windows API functions directly.
3. Explore the AutoHotkey Community
- [Forum](https://www.autohotkey.com/boards/)
- [Discord](https://discord.gg/autohotkey)
- [Reddit](https://www.reddit.com/r/AutoHotkey/)

> Read the documentation and use forum searching before asking any question! To quickly find any detail use "advanced forum searching" and search by topic title or use google/SearX/PreSearch with search operators, e.g.
`site:autohotkey.com bound function`

</details>

## Project Priorities

QuickSwitch has **core goals** that must guide all development decisions:
#### 1. Improve Stability and Reliability
Stability over features. QuickSwitch interacts with external processes via WinAPI, COM, and clipboard. This makes it inherently fragile. Fixing edge cases, improving error handling (see [logging](Lib/Log.ahk) and [validation](Lib/Values.ahk)), and ensuring correct behavior across Windows versions are the most impactful contributions you can make.
#### 2. Extend File Managers Support
QuickSwitch retrieves paths from several file managers, each implemented as a dedicated getter function in [ManagerClasseses](Lib/ManagerClasses.ahk). Adding support for new file managers, or improving the robustness of existing ones, is a high-value contribution. If you use some file manager and you know it's API, this is the area to contribute to.
#### 3. Extend File Dialogs Support
QuickSwitch detects and interacts with Windows file dialogs. The current detection logic lives in [FileDialogs](Lib/FileDialogs.ahk). Many applications use non-standard or atypical dialogs (like MS Office 2003 or ABBYY FineReader) that QuickSwitch may fail to detect. If you have encountered unusual file dialogs and you know can integrate them effectively and you are familiar with the concept of "window control", this area is great for you. 

> A fast and reliable QuickSwitch that works perfectly with the software it currently supports is worth far more than a feature-rich one that is unpredictable.

## Where to Start

If you already have ideas on how to improve QuickSwitch – [jump to the documentation](#understanding-the-codebase).

The following smaller contributions are always appreciated:

- Fixing typos or improving comments in the source code.
- Refactoring or simplifying existing code without changing behavior.
- Improving path parsing edge cases in [GetPaths](Lib/GetPaths.ahk).
- Improving INI validation logic in [Values](Lib/Values.ahk).
- Adding or improving error messages in [Log](Lib/Log.ahk).

Also you can open Issues tracker and focus on the following labels:

- **[Open Bugs](https://github.com/JoyHak/QuickSwitch/issues?q=state%3Aopen%20label%3Abug)** — Real problems reported by users. Fixing these directly improves reliability and is the highest-impact contribution.
- **[Requested Features](https://github.com/JoyHak/QuickSwitch/issues?q=state%3Aopen%20label%3Afeature)** — Ideas and suggestions. Adding these improves existing functionality and user experience.

When picking an issue:
1. Read the full issue description and any linked discussions.
2. Comment on the issue to let others know you are working on it.
3. Ask questions if anything is unclear — it won't be very good if you don't catch the idea of the user.

## Understanding the Codebase

QuickSwitch is organized as a main script that `#Include`s files from `Lib` directory. The purpose of each file is described in the [table](Lib/README.md). The project's architecture described in detail and visualized on [DeepWiki](https://deepwiki.com/JoyHak/QuickSwitch), there is also an AI assistant that will instantly answer any question.

You can <a name="contacts">send me a message</a> and I will try to explain everything in detail:
- <img src="https://raw.githubusercontent.com/JoyHak/QuickSwitch/main/Images/forums/AutoHotkey.svg" width="24" height="24"/> [AutoHotkey](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=102377&sd=d)
- <img src="https://raw.githubusercontent.com/JoyHak/QuickSwitch/main/Images/forums/Discord.svg" width="24" height="24"/> [Discord](https://discord.com/users/450899199010144267)   
- <img src="https://raw.githubusercontent.com/JoyHak/QuickSwitch/main/Images/forums/Mail.svg" width="24" height="24"/> [E-mail](mailto:rafaello@disroot.org)   

## How to Contribute

You can send your ideas and changes [directly to me](#contacts).

But if you want to learn about GitHub, you can [start here](https://docs.github.com/ru/get-started/start-your-journey/hello-world).<br><br>

<a href="https://community.chocolatey.org/packages/gitbutler">
<img src="https://img.shields.io/chocolatey/v/gitbutler?style=flat&label=gitbutler&labelColor=cyan&color=white&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMzkiIGhlaWdodD0iMjgiIHZpZXdCb3g9IjAgMCAzOSAyOCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTI1LjIxNDUgMTIuMTk5N0wyLjg3MTA3IDEuMzg5MTJDMS41NDI5NSAwLjc0NjUzMiAwIDEuNzE0MDYgMCAzLjE4OTQ3VjI0LjgxMDVDMCAyNi4yODU5IDEuNTQyOTUgMjcuMjUzNSAyLjg3MTA3IDI2LjYxMDlMMjUuMjE0NSAxNS44MDAzQzI2LjcxOTcgMTUuMDcyMSAyNi43MTk3IDEyLjkyNzkgMjUuMjE0NSAxMi4xOTk3WiIgZmlsbD0iYmxhY2siLz4KPHBhdGggZD0iTTEzLjc4NTUgMTIuMTk5N0wzNi4xMjg5IDEuMzg5MTJDMzcuNDU3MSAwLjc0NjUzMiAzOSAxLjcxNDA2IDM5IDMuMTg5NDdWMjQuODEwNUMzOSAyNi4yODU5IDM3LjQ1NzEgMjcuMjUzNSAzNi4xMjg5IDI2LjYxMDlMMTMuNzg1NSAxNS44MDAzQzEyLjI4MDMgMTUuMDcyMSAxMi4yODAzIDEyLjkyNzkgMTMuNzg1NSAxMi4xOTk3WiIgZmlsbD0idXJsKCNwYWludDBfcmFkaWFsXzMxMF8xMjkpIi8%2BCjxkZWZzPgo8cmFkaWFsR3JhZGllbnQgaWQ9InBhaW50MF9yYWRpYWxfMzEwXzEyOSIgY3g9IjAiIGN5PSIwIiByPSIxIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgZ3JhZGllbnRUcmFuc2Zvcm09InRyYW5zbGF0ZSgxNi41NzAxIDE0KSBzY2FsZSgxOS44NjQxIDE5LjgzODMpIj4KPHN0b3Agb2Zmc2V0PSIwLjMwMTA1NiIgc3RvcC1vcGFjaXR5PSIwIi8%2BCjxzdG9wIG9mZnNldD0iMSIvPgo8L3JhZGlhbEdyYWRpZW50Pgo8L2RlZnM%2BCjwvc3ZnPgo%3D"></a>
<a href="https://community.chocolatey.org/packages/git">
<img src="https://img.shields.io/chocolatey/v/git?style=flat&logo=git&logoColor=red&label=git&color=red"></a>
<br>

The best way to start working with the GitHub is to [install GitButler](https://github.com/gitbutlerapp/gitbutler/). Read it's [short documentation](https://docs.gitbutler.com), [clone the project](https://docs.gitbutler.com/guide#importing-a-local-repository) and start making changes to the files. If you're a big fan of Git, I highly recommend giving this client a try – it solves many problems and simplifies your work by creating more functional branches.

<details><summary>If you have GitHub CLI</summary>
   
Execute this script in your terminal:

```powershell
# under construction
```

</details>

Once you've cloned your repository, follow these steps for each development session (fixing a bug, introducing a new feature, etc.):
1. **Create a branch** for your work: `fix/dialog-detection-edge-case` or `feat/add-freecommander-support`.
2. **Make your changes** and test them manually by running the main [QuickSwitch-1.9.ahk](QuickSwitch-1.9.ahk) script.
3. **Check `Errors.log`** in the root directory after testing — it records all exceptions caught by `LogException()` in [Log](Lib/Log.ahk).
4. **Check Menu**, all paths must work correctly. Press `Ctrl+Shift+Win+0` or **Alt + \`** (backtick or `~` tilde) to display the Menu everywhere.
> You can tweak pre-display actions and `Restart` hotkey on `Settings > App` tab. If you're working on the [Settings UI](Lib/SettingsFrontend.ahk), check `Show settings after restart`.
5. **Commit changes**, group a set of logically related changes into a single commit with the short name in the present tense: `Add new option`, `Fix Menu flick`.
> Never make one big commit from all the changes, but don't make micro commits either (see [project commit history](https://github.com/JoyHak/QuickSwitch/commits/main/) for examples).
6. **Open a Pull Request** against the `main` branch with a clear description of what you changed and wwhy
> If there's **a lot of commits**, open up multiple requests and logically group commits for each request: `Added new option` or `Fixed critical bug`. GitButler provides powerful cherry-picking for this purpose.

</details>

## Code Style & Conventions

- **Indentation:** 4 spaces (no tabs in `.ahk` files).
- **Local variables:** prefixed with `_` (e.g., `_path`, `_winId`).
- **Global variables:** PascalCase (e.g., `ShowManagers`, `AutoSwitch`).
- **Static variables, VarRefs:** camelCase (e.g., `winId`, `sendEnter`).
- **Strings and constants:** should be passed as `VarRef`s to the functions (functions must accept parameter by reference: `&variable`). E.g. path or window handle.
- **Error handling:** wrap risky WinAPI/COM calls in `try/catch` and call `LogException()` from [Log](Lib/Log.ahk) in the `catch` block. Pass non-terminating errors to the `LogError()`.
- **Comments:** should explain why such code is needed/complicated ideas of the code. Comments must not duplicate code, **code must be self-documented**, i.e. consise and readable!


*Thank you for helping make QuickSwitch the most reliable path-switching tool for Windows!*
