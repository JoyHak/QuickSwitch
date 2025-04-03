This is an improved version of the [QuickSwitch script v0.5](https://github.com/gepruts/QuickSwitch) from Gepruts. [DaWolfi, NotNull and Tuska](https://www.voidtools.com/forum/viewtopic.php?t=9881) first improved it to [v0.5dw9a](https://www.voidtools.com/forum/download/file.php?id=2235), and I've now [released v1.0](https://github.com/JoyHak/QuickSwitch/releases), where I've made some really significant improvements!

## About

Imagine you want to open/save a file. A dialog box appears, allowing you to manually select the directory on your system. QuickSwitch lets you automatically switch to the path you need if it's open in any of the supported file managers (File Explorer, Directory Opus, Total Commander, XYPlorer). 
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/menu.gif)

In short, this compact menu will display all suitable paths:
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/menu.png)

It has two modes:

1. **Menu mode**: displays a list of opened directories. Selecting one switches the file dialog to that path. The menu won't appear if no directories are open.

2. **AutoSwitch mode**: the file dialog automatically opens the last active directory in the file manager when you `Alt-Tab` between them. If the file manager was active before opening the dialog, it opens that directory immediately. You can still use `Ctr+Q` to access the menu if needed.

**AutoSwitch** can be disabled using the `Never` option. There's also `Never here` option to disable QuickSwitch for specific dialogs, like web browsers or backup applications.

![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/autoswitch.gif)

And of course you can customize the display of paths in the menu to your liking:
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/settings.png)

[The latest versions](https://github.com/JoyHak/QuickSwitch/releases) include the following features:

- Added application auto-startup at Windows log-on.
- The menu will display the paths from all open folders starting from the current one. 
- The path can be displayed in a shortened form.
- Improved settings interface and additional customization options and features.
- Added minimalistic display of errors about incorrectly entered settings.

## Performance

This version is aimed at high performance and is devoid of various checks. To ensure that the correct current paths always appear in the menu:
- Disable localized folder names *(e.g. C:\Users, C:\Användare, ...).*                       
- Periodically open the file manager you need *(a big number of windows makes it difficult to find the last open manager).*
- Do not keep virtual folders open *(e.g. coll://, Desktop, Rapid Access, ...).*
- Do not disable window title bars *(otherwise the program will request paths through files)*.
- Do not change attributes of directories with file managers *(e.g. "read only")*.
- Don't use AHK's `OnClipBoardChange` function or CopyQ's `setData` function to change the contents of the last clipboard item *( the program uses the clipboard and may receive incorrect contents)*.

## Installation

1. [Download](https://github.com/JoyHak/QuickSwitch/releases) the latest version.

> [Subscribe to releases](https://docs.github.com/en/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/about-notifications#notifications-and-subscriptions) so you don't miss critical updates!

2. Run `.exe` for your CPU architecture and check it's existence in the tray.

3. Open different directories in a supported file manager.

> E.g., open `C:\` in `Explorer`.

4. Open any application and try to open\save a file using it.

> E.g., open `Notepad` then `File - Open...`. Or try downloading any file.

5. Press `Ctrl+Q` and look at the paths in the **menu** that opens. All directories opened in supported file managers will be displayed here.

6. Explore the available options in the menu, open the settings and experiment with them. Choose a convenient style and logic of the menu!

##  Scripting

This script is written in the [Autohotkey language](https://en.m.wikipedia.org/wiki/AutoHotkey).

1. [Download](https://www.autohotkey.com/download/) Autohotkey v1.1 and install it. 

> PLEASE KEEP IN MIND: Autohotkey v1 is an **outdated version.** If you want to start learning the language, install `v2`. **Do not learn autohotkey v1 yourself** and use it exclusively to run old scripts. This script needs to be updated from `v1` to `v2` !

2. When the installation is complete, you are presented with another menu. Choose `Run AutoHotkey`.
Once the AutoHotkey help file opens, you can read or close it now. 

3. [Download](https://github.com/JoyHak/QuickSwitch/releases) the latest version of QuickSwitch.
5.  Unpack `.zip` and run `QuickSwitch.ahk`. Check it's existence in the tray.

## Compiling	

`QuickSwitch.ahk` can be automatically compiled using `ahk2exe` which is here by default: `C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe` 
It can be downloaded from here: https://github.com/AutoHotkey/Ahk2Exe
Or installed from here: `C:\Program Files\AutoHotkey\UX\install-ahk2exe.ahk`

`7-zip` is also needed to automatically create an archive with the required files: 

```powershell
"C:\Program Files\7-Zip\7zG.exe" a "%A_ScriptDir%\Releases\QuickSwitch 1.0".zip -tzip -sae -- "%A_ScriptDir%\QuickSwitch.ahk" "%A_ScriptDir%\Libs" "%A_ScriptDir%\QuickSwitch.ico"
```

For compilation, you need to select the .exe AHK v1.1.+ with Unicode support. They can be found here:
```powershell
C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe
C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU32.exe
# version may vary
```

[Directives](https://www.autohotkey.com/docs/v1/misc/Ahk2ExeDirectives.htm#Bin) are used for compilation, but it can be set manually at each compilation using the `ahk2exe GUI`. But this is inconvenient because you will need to manually perform different actions each time you run it and you lose [the benefits of directives](https://www.autohotkey.com/docs/v1/misc/Ahk2ExeDirectives.htm#SetProp):

> Script compiler directives allow the user to specify details of how a script is to be compiled via [Ahk2Exe](https://www.autohotkey.com/docs/v1/Scripts.htm#ahk2exe). Some of the features are:
>
> - Ability to change the version information (such as the name, description, version...).
> - Ability to add resources to the compiled script.
> - Ability to tweak several miscellaneous aspects of compilation.
> - Ability to remove code sections from the compiled script and vice versa.

## To-Do
- auto-check for update (lib and setting)
- AutoSwitch on clipboard change
- drag and drop any file field
- Pin favourite paths
- `Explorer`: 
  - QTTabBar tabs
  - Win11 support
  - MRU

### Need help with:
- `Autohotkey v2` port
- `File managers`:
  - tabs from all panes
  - new file managers support
