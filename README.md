This is an improved version of the [QuickSwitch script v0.5](https://github.com/gepruts/QuickSwitch) from Gepruts. [DaWolfi, NotNull and Tuska](https://www.voidtools.com/forum/viewtopic.php?t=9881) first improved it to [v0.5dw9a](https://www.voidtools.com/forum/download/file.php?id=2235), and I've now [released v1.0](https://github.com/JoyHak/QuickSwitch/releases), where I've made some really significant improvements!

## About

Imagine you want to open/save a file. A dialog box appears, allowing you to manually select the folder on your system. QuickSwitch lets you automatically switch to the folder you need if it's open in any of the supported file managers (File Explorer, Directory Opus, Total Commander, XYPlorer). 

![](https://github.com/JoyHak/QuickSwitch-/blob/main/Images/(3).png)	
![](https://github.com/JoyHak/QuickSwitch-/blob/main/Images/(4).png)
![](https://github.com/JoyHak/QuickSwitch-/blob/main/Images/(5).png)

It has two modes:

1. **Menu mode**: displays a list of opened folders. Selecting one switches the file dialog to that folder. The menu won't appear if no folders are open.

2. **AutoSwitch mode**: the file dialog automatically opens the last active folder in the file manager when you `Alt-Tab` between them. If the file manager was active before opening the dialog, it opens that folder immediately. You can still use `Ctr+Q` to access the menu if needed.

**AutoSwitch** can be disabled using the `Never` option. There's also `Never here` option to disable QuickSwitch for specific dialogs, like web browsers, which manage their own folders.

## Installation
This script is written in the [Autohotkey language](https://en.m.wikipedia.org/wiki/AutoHotkey). It will be compiled later.

1. [Download](https://www.autohotkey.com/download/) Autohotkey v1.1 and install it. 

> PLEASE KEEP IN MIND: Autohotkey v1 is an **outdated version.** If you want to start learning the language, install `v2`. **Do not learn autohotkey v1 yourself** and use it exclusively to run old scripts. This script needs to be updated from `v1` to `v2` !

2. When the installation is complete, you are presented with another menu. Choose `Run AutoHotkey`.
Once the AutoHotkey help file opens, you can read or close it now. 

3. [Download](https://github.com/JoyHak/QuickSwitch/releases) the latest version of this repository *(and explore it if you want)*.
> [Subscribe to notifications](https://docs.github.com/en/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/about-notifications#notifications-and-subscriptions) so you don't miss out on improvements.

5. Run `QuickSwitch.ahk` and check its existence in the tray.

6. Open different folders in a supported file manager,
> E.g., open `C:\` in `Explorer`.

7. Open any application and try to open/save a file using it.
> E.g., open `Notepad` then `File - Open...`. Or try downloading any file.

9. Press `Ctrl+Q` *(the combination can be changed in the main script)* and look at the paths in the **menu** that opens. All folders opened in supported file managers will be displayed here.
> From any similar dialog box, from any application, you can quickly navigate to these folders using this menu and `save/open` a file from them.

11. Explore the available options in the menu, open the settings and experiment with them. Choose a convenient style and logic of the menu!

## To-do
- ByRef params in most functions
- Check for update (lib and setting)
- AutoSwitch on clipboard change
- drag and drop any file field

### Need help with:
- `Autohotkey v2` port
- `Explorer`: QTTabBar tabs
- `File managers`:
  - tabs from all panes
  - new commands to avoid using clipboard
  > XYplorer receives a command using `DllCall` and sends the XYdata directly to RAM, from where Autohotkey reads it
