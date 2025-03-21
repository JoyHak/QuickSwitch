;@Ahk2Exe-SetVersion %A_ScriptName~[^\d\.]+%
;@Ahk2Exe-SetMainIcon QuickSwitch.ico
;@Ahk2Exe-SetDescription Quickly Switch to the path from any file manager.
;@Ahk2Exe-SetCopyright Rafaello
;@Ahk2Exe-SetLegalTrademarks GPL-3.0 license
;@Ahk2Exe-SetCompanyName ToYu studio

;@Ahk2Exe-Let U_name = %A_ScriptName~\.ahk%
;@Ahk2Exe-PostExec "C:\Program Files\7-Zip\7zG.exe" a "%A_ScriptDir%\Releases\%U_name%".zip -tzip -sae -- "%A_ScriptDir%\%U_name%.ahk" "%A_ScriptDir%\Libs" "%A_ScriptDir%\QuickSwitch.ico",, A_ScriptDir

/*
    Modification by Rafaello: 
    https://github.com/JoyHak/QuickSwitch
    
    Based on v0.5dw9a by NotNull, DaWolfi and Tuska: 
    https://www.voidtools.com/forum/viewtopic.php?f=2&t=9881
    
    
    This is the main file that is waiting for the dialog window to appear. 
    Then initializes the menu display. 
    The hotkey is declared once and linked to the ShowPathsMenu().
*/

#Requires AutoHotkey v1.1+
#SingleInstance force
#NoEnv
#Warn
FileEncoding, UTF-8
SetWorkingDir %A_ScriptDir%

global ScriptName := "QuickSwitch" 
global INI := ScriptName ".ini"
global ERRORS := "Errors.log"

#Include %A_ScriptDir%
#Include Libs\Log.ahk
#Include Libs\Values.ahk
#Include Libs\FileDialogs.ahk
#Include Libs\GetPaths.ahk
#Include Libs\AutoSwitch.ahk
#Include Libs\Debug.ahk

#Include Libs\AppSettings.ahk
#Include Libs\MenuSettings.ahk
#Include Libs\PathsMenu.ahk

SetDefaultValues()
ReadValues()
ValidateLog()
ValidateAutoStartup()

ValidateWriteKey(MainKey, 		"MainKey",      "ShowPathsMenu",    "Off")
ValidateWriteKey(RestartKey, 	"RestartKey",   "RestartApp",       "On") 
Menu, Tray, UseErrorLevel 
Menu, Tray, Icon, %MainIcon% 

; Wait for dialog
Loop {
    WinWaitActive, ahk_class #32770
    DialogID     := WinExist("A")
    FileDialog   := GetFileDialog(DialogID)

    ; if there is any GUI left from previous calls....
    Gui, Destroy
    
    IniRead, MainKey, %INI%, App, MainKey
    if FileDialog 
    {                                                       ; This is a supported dialog    
        GetPaths()
        WinGet, ahk_exe, ProcessName, ahk_id %DialogID%
        WinGetTitle, window_title, ahk_id %DialogID%
        FingerPrint := ahk_exe . "___" . window_title

        ; Check if FingerPrint entry is already in INI, so we know what to do.
        IniRead, DialogAction, %INI%, Dialogs, %FingerPrint%, 0
        if (DialogAction == 1) {                                           ; ======= AutoSwitch ==        
            AutoSwitch()
        } else if (DialogAction == 0) {                                    ; ======= Never here ==        
            if ShouldOpen() {
                ShowPathsMenu()         ; AutoOpenMenu only
            }
        }
        else if ShouldOpen() {                                             ; ======= Show Menu ==        
            ShowPathsMenu()             ; hotkey or AutoOpenMenu
        }

        ; if we end up here, we checked the INI for what to do in this supported dialog and did it
        ; We are still in this dialog and can now enable the hotkey for manual menu-activation

        Hotkey, %MainKey%, On

    }   ; End of File Dialog routine

    Sleep, 100
    WinWaitNotActive

    ; Clean up        
    Hotkey, %MainKey%, Off    
    ahk_exe         := ""
    window_title    := ""
    DialogAction    := ""
    DialogID        := ""
    DialogType      := ""
    
}   ; End of continuous WinWaitActive loop

LogError(Exception("Main menu error", "An error occurred while waiting for the file dialog to appear. Restart the app manually", "End of continuous WinWaitActive loop in main file"))
ExitApp
