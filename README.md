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

## Appearance
#### Menu sections
In addition to the paths from the file managers, you can add additional paths to the Menu on `Settings > Theme` tab.

<details><summary>Pinned paths (that are always visible)</summary> 

If you want some paths to appear permanently in the Menu, you can pin them. To do this, enable the `Settings > Theme > Show pinned paths`  option and select a key or mouse button at  `Settings > App > Pin path...`. Close the settings and open the Menu. Hold down the selected key and left click on any path. Now it is pinned and it will be stored in the configuration. You will see this path on every restart. 

If you turn this option off, the paths will no longer be displayed. If you turn it on, all pinned paths will be displayed again. If you want to delete all pinned paths, check `Settings > Reset > Delete favorite paths` and press `Enter`.

If you want to see the same paths in the list of fixed paths and from file managers *(for example, it is easier for you to find a path by knowing the icon of a file manager)*, disable the `Settings > Menu > Delete duplicate paths` option.

</details>

<details><summary>Paths from clipboard (temporary, for a single file dialog)</summary> 

You can copy any file or directory path (or any [variable](https://github.com/JoyHak/QuickSwitch#variables)) and it will appear in the Menu. All copied paths will remain in the Menu until you open the file dialog in another application. If you switch between file dialogs of different applications, the copied paths will disappear after switching. If you do not want a path to disappear, pin it. 

<img width="616" height="683" alt="Clipboard" src="https://github.com/user-attachments/assets/0014e6fc-74df-4936-b683-9c35a2d95068" />

Copied paths will not disappear if you force the Menu to appear using `Ctrl+Shift+Win+0` combination. It can help you open the copied paths in multiple applications. If you copy the path to a file, QuickSwitch will use the directory with that file by removing everything after the last slash `\`.

<img width="614" height="593" alt="clipboard2" src="https://github.com/user-attachments/assets/09237a63-2264-4050-9a8c-b0501536fd27" />

The option works in the background and analyzes the clipboard for the presence of a path when changing it. If several paths separated by line breaks (multi-line text) have been copied, they will be added to the Menu individually. 

Background analysis is temporarily disabled when requesting paths from other file managers *(if the `Settings > Theme > Show file managers paths` option is enabled)*, as their data is exchanged via the clipboard. If the request takes a very long time *(e.g., QuickSwitch creates the configuration for Total Commander)*, clipboard analysis will be turned off until all paths are fully received.

</details>

<details><summary>Favorite paths (with customizable icons and names)</summary>  
 
If you have many paths and want to customize how they are displayed in the Menu, enable the `Settings > Theme > Show favorite paths` option. The option works with `.lnk` shortcuts (links) from the directory you specified in the input field next to it. [Create a shortcut](https://www.thewindowsclub.com/create-desktop-shortcut-windows-10) to any directory or file in it (in this case the directory it is in will be used). From the context Menu, open the shortcut's "properties" and click on the "shortcut" tab. 

<img width="1920" height="1920" alt="properties" src="https://github.com/user-attachments/assets/ec65e78b-26cb-4989-a71b-a14c6ea964bf" />

You will see editable fields that will directly affect the display of the shortcut in QuickSwitch:
- Target
- Start in (working dir.)
- Comment
- Change icon (button)

The "target" field is the main path you will see. The "start in" field will only be used if the "target" field is empty. Even if the "target" points to a file, QuickSwitch will use the file directory by removing everything after the last slash `\`. You can change the displayed path and give it any name you want in the "comment" field. This field takes precedence over displaying the full or short path (`Settings > Short path`). All fields support [variables](https://github.com/JoyHak/QuickSwitch#variables).

Let's put the `ScriptName` variable in the "comment" field. The Menu will show the internal QuickSwitch name for the shortcut named "MyFavoritePath". 

<img width="1101" height="946" alt="shell32 example" src="https://github.com/user-attachments/assets/bcb9e450-efa5-40fd-899f-3f2c37842704" />

If you leave the "comment" field empty, the Menu will show the `Temp` variable value from "target" field (e.g. path to `C:\Temp`).

You can put the path to ICO, CUR, ANI, EXE, DLL, CPL, SCR and other resource that contains icons. For example I chose the system icon "shutdown" from `shell32.dll`, however I could choose ICO from the "Icons" folder. You can create as many shortcuts as you like and customize each one.

<img width="745" height="802" alt="recusrsive favorites" src="https://github.com/user-attachments/assets/3a969435-cfe1-48e1-b603-edf64dde2ffe" />

If you have many shortcuts, you can give them names (e.g. "MyFavoritePath") that will not be visible in the Menu and arrange them in directories. Regardless of the directory structure of your favorite paths, QuickSwitch will display all `.lnk` files from all directories. 

<img width="1369" height="778" alt="structure" src="https://github.com/user-attachments/assets/f9e2dd3c-3930-4f27-a826-e3fc86799cdc" />

You can hide some shortcuts by changing or removing their extension. If there are a lot of shortcuts and you don't need them anymore, check `Settings > Reset > Delete favorite paths`. After pressing the `Enter` button, your shortcuts will be placed in the trash. You will be able to restore them before emptying the trash can.

</details>

#### Variables
In the settings you can select the paths to the desired directories *(e.g. icons)*. You can use an absolute path *(C:\QuickSwitch/Icons)* or a path relative to the current QuickSwitch location *(Icons)* as the path. You can use variables in paths: [environment variables](https://learn.microsoft.com/en-us/windows/deployment/usmt/usmt-recognized-environment-variables); built-in [AutoHotkey variables](https://www.autohotkey.com/docs/v1/Variables.htm#BuiltIn); declared [QuickSwitch variables](https://github.com/JoyHak/QuickSwitch/blob/main/Lib/Values.ahk). Enclose the variables in percent signs `%`.
<details><summary>Examples</summary>
 
  %AppData%\Icons <br>
  %A_ScriptDir%\Icons <br>
  %Temp%\Icons\%SOME_SYSTEM_PATH% <br>
  C:\%IconsDir% <br>
  Icons <br>
  <br>
 If you have enabled the `Settings > Theme > Show paths from clipboard`, all copied variables will also be expanded. For example, if you have [Cmder](https://github.com/cmderdev/cmder) or [ConEmu](https://github.com/Maximus5/ConEmu) installed you can copy the `%ConEmuDir%` text to always see the path `C:\Users\...\cmder\vendor\conemu-maximus5` in the Menu. For permanent use you can pin this path and it will be visible in the menu always (enable `Settings > Theme > Show pinned paths`).
 
 <img width="616" height="683" alt="Clipboard" src="https://github.com/user-attachments/assets/80ea3b3d-9eec-4629-aa64-38b35a28ab92" />


</details>

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
