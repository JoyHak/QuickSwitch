This is an improved version of the [QuickSwitch script v0.5](https://github.com/gepruts/QuickSwitch) from Gepruts. [DaWolfi, NotNull and Tuska](https://www.voidtools.com/forum/viewtopic.php?t=9881) first improved it to [v0.5dw9a](https://www.voidtools.com/forum/download/file.php?id=2235).

[New versions](https://github.com/JoyHak/QuickSwitch/releases) displays all open tabs and contains new powerful options. 

## About

Imagine you want to open/save a file. A dialog box appears, allowing you to manually select the directory on your system. QuickSwitch lets you automatically switch to the path you need if it's open in any of the supported file managers (File Explorer, Directory Opus, Total Commander, XYPlorer). 
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/white.png)

**Menu** displays a list of opened paths (tabs from file managers). Select any path to change path in file dialog:
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/menu.gif)

Enable **Auto Switch** option to automatically change path in file dialog. If the file manager was active before opening the dialog, QuickSwitch opens it's directory immediately:

![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/autoswitch.gif)

You can add specific file dialog to the **Black List** to disable QuickSwitch in web browser or another app. Use `Ctr+Q` to access the Menu if needed.

These options work separately for each window, which makes it possible to customize the application for each dialog.

And of course you can customize the display of paths in the Menu:
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/settings.png)
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/settings.gif)

[The latest versions](https://github.com/JoyHak/QuickSwitch/releases) include the following features:

- Significantly improved performance.
- Added the ability to always show the Menu or enable always Auto Switch.
- Added application auto-startup at Windows log-on.
- The menu will display the paths from all open tabs starting from the current one. 
- The path can be displayed in a shortened form.
- Improved settings interface and additional customization options and features.
- Added minimalistic display of errors about incorrectly entered settings.

As an addition I recommend the [BigSur](https://www.deviantart.com/niivu/art/Big-Sur-2-Windows-10-Themes-861727886) or [CakeOS](https://www.deviantart.com/niivu/art/cakeOS-2-0-for-Windows-11-953541433) themes from Niivu and [XYplorer](https://www.xyplorer.com/index.php) file manager.

## Keyboard

Each option and button in the settings has a corresponding key.
Take a closer look: each name has an u̲n̲d̲e̲r̲l̲i̲n̲e̲d̲ l̲e̲t̲t̲e̲r̲. Press this letter on the keyboard to jump to the option. For example:
 _C̲ancel_ – `C`; _Path s̲eparator_  – `S`.

Here is a short list of the main keys:
- Path: `0-9`.
- Auto switch: `A`
- Black list: `B`
- Settings: `S`
- Hide menu: `Esc` / `click` anywhere

## Feedback

**I really need your feedback!** If something is not working for you, please [let me know](https://github.com/JoyHak/QuickSwitch/issues/new?template=bug-report.yaml). If you think that app can be improved, [write to me](https://github.com/JoyHak/QuickSwitch/issues/new?template=feature-request.yaml).

You can enforce the Menu in any application using the keyboard shortcut: `Ctrl+Shift+Win+0`. The menu will display the **paths obtained after the last opening of the file dialog** and will not change them until the next opening. The menu will be empty the first time it is opened.

You can use this feature to test whether QuickSwitch is working correctly in the (target) app in which Menu appears. **If it really works**, click _"Settings > Debug > Export"_ to export the app info file. [Open a suggestion](https://github.com/JoyHak/QuickSwitch/issues/new?template=feature-request.yaml) to add this app to QuickSwitch, attach exported file. 

## Limitations

To ensure that the correct current paths always appear in the menu:
- Disable localized folder names *(e.g. C:\Users, C:\Användare, ...).*                       
- Periodically open the file manager you need *(a big number of windows makes it difficult to find the last open manager).*
- Do not keep virtual folders open *(e.g. coll://, Desktop, Rapid Access, ...).*

QuickSwitch interacts with other applications, but the system may [restrict its access](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/user-account-control-allow-uiaccess-applications-to-prompt-for-elevation-without-using-the-secure-desktop). To avoid this, run QuickSwitch as an administrator, copy it to the `C:\Program Files` _(just paste `%ProgramFiles%` to the addressbar)_. You can also [disable UAC](https://superuser.com/a/1773044) to avoid similar problems with all applications.

<details><summary>Details</summary>

QuickSwitch is written in AutoHotkey, which uses WinAPI. It sends messages to other file managers and receives information about the current file dialog and its contents. For these actions to work correctly, it is required that **the target process is not running as an administrator** or QuickSwitch is running with UI access (if it is not a compiled `.ahk` file) or as an administrator. The reason for this is [UIPI](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/user-account-control-allow-uiaccess-applications-to-prompt-for-elevation-without-using-the-secure-desktop):

> User Interface Privilege Isolation (UIPI) implements restrictions in the Windows subsystem that prevent lower-privilege applications from sending messages or installing hooks in higher-privilege processes. Higher-privilege applications are permitted to send messages to lower-privilege processes. UIPI doesn't interfere with or change the behavior of messages between applications at the same privilege (or integrity) level.

You can also [disable UAC](https://superuser.com/a/1773044) and use low-level or powerful antivirus _(Crowdstrike, Eset Endpoint Security)_ for full control over running applications. Modern viruses [does not require admin privileges](https://security.stackexchange.com/a/183149) to interact with the system. However, they can obtain admin rights by [exploiting Windows vulnerability](https://community.spiceworks.com/t/how-does-malware-actually-gain-admin-access-to-a-pc-without-av/329471).
</details>

## Installation
Subscribe to releases so you don't miss critical updates!
![Subscribe](https://github.com/user-attachments/assets/57eb9a93-fc9d-4dfd-bfb0-00720c2911f1)

1. [Download](https://github.com/JoyHak/QuickSwitch/releases) the latest version.

2. Run `.exe` for your CPU architecture and check it's existence in the tray.

3. Open different directories in a supported file manager. E.g., open `C:\` in `Explorer`.

4. Open any application and try to open\save a file using it. E.g., open `Notepad` then `File - Open...`. Or try to [download](https://github.com/JoyHak/QuickSwitch/releases) any file.

5. Press `Ctrl+Q` and look at the paths in the Menu that opens. All directories opened in supported file managers will be displayed here.

6. Explore the available options in the _"Menu settings"_ and experiment with them. Choose a convenient style and logic of the menu!

## Compiling	

`QuickSwitch.ahk` can be automatically compiled using `ahk2exe` and `7-zip` (CLI).

<details><summary>Details</summary>

`ahk2exe` is here by default: `C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe`. </br>
It can be downloaded from here: https://github.com/AutoHotkey/Ahk2Exe </br>
It can be installed using the script: `C:\Program Files\AutoHotkey\UX\install-ahk2exe.ahk` </br>
</br>
`7zG.exe` is also needed to automatically create an archive with the required files from `CMD / PWSH`: https://7-zip.org
</details>

To compile, open `ahk2exe` and select the main file (e.g. `QuickSwitch-1.7.ahk`). Be sure to create the `Releases` directory next to this file! The necessary directives are already configured in main file, so you can immediately press `Convert`. 

![compile](https://github.com/user-attachments/assets/99a689e0-5b54-4994-9bd8-f242ac51c76b)

However, you can customize all the settings and click `Save` to automatically apply them to future releases of `QuickSwitch`. For manual compilation, you need to select the AHK `.exe` v1.1.+ with Unicode support *(e.g. Autohotkey U64.exe)*. It can be found here:
```powershell
C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe
C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU32.exe
# version may vary
```
> [!WARNING]
> Autohotkey v1 is an **outdated version.** I'm using it temporarily. It is not recommended to save such settings if you are already using AHK v2 scripts!

But I use [compiler directives](https://www.autohotkey.com/docs/v1/misc/Ahk2ExeDirectives.htm#Bin) for automation. [The benefits of directives](https://www.autohotkey.com/docs/v1/misc/Ahk2ExeDirectives.htm#SetProp):

> Script compiler directives allow the user to specify details of how a script is to be compiled via [Ahk2Exe](https://www.autohotkey.com/docs/v1/Scripts.htm#ahk2exe). Some of the features are:
>
> - Ability to change the version information (such as the name, description, version...).
> - Ability to add resources to the compiled script.
> - Ability to tweak several miscellaneous aspects of compilation.
> - Ability to remove code sections from the compiled script and vice versa.

## Need help with
- Auto-check for update (lib and setting)
- AutoSwitch on clipboard change
- Drag and drop any file field
- Pin favourite paths
- `QTTabBar` (get all tabs)
- `Autohotkey v2` port
- New file managers support
