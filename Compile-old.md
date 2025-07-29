## Compiling	

`QuickSwitch-v1.0-v1.7.ahk` can be automatically compiled using `ahk2exe` and `7-zip` (CLI). Starting with version 1.8, a [new application build system](https://github.com/JoyHak/QuickSwitch#compiling) is used.

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
