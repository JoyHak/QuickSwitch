;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU32.exe, %A_ScriptDir%\Releases\%A_ScriptName~\.ahk%-x32.exe
;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe, %A_ScriptDir%\Releases\%A_ScriptName~\.ahk%-x64.exe

;@Ahk2Exe-SetVersion %A_ScriptName~[^\d\.]+%
;@Ahk2Exe-SetMainIcon QuickSwitch.ico
;@Ahk2Exe-SetDescription https://github.com/JoyHak/QuickSwitch
;@Ahk2Exe-SetCopyright Rafaello
;@Ahk2Exe-SetLegalTrademarks GPL-3.0 license
;@Ahk2Exe-SetCompanyName ToYu studio

;@Ahk2Exe-Let U_name = %A_ScriptName~\.ahk%
;@Ahk2Exe-PostExec "C:\Program Files\7-Zip\7zG.exe" a "%A_ScriptDir%\Releases\%U_name%".zip -tzip -sae -- "%A_ScriptDir%\%U_name%.ahk" "%A_ScriptDir%\Libs" "%A_ScriptDir%\QuickSwitch.ico",, A_ScriptDir

#Requires AutoHotkey v1.1+
#Warn
#NoEnv
#Persistent
#SingleInstance force
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetWinDelay, -1
SetControlDelay, -1
FileEncoding, UTF-8
SetWorkingDir %A_ScriptDir%

ScriptName    := "QuickSwitch"
MainIcon      := ""
INI           := ScriptName ".ini"
ErrorsLog     := "Errors.log"
BugReportLink := "https://github.com/JoyHak/QuickSwitch/issues/new?template=bug-report.yaml"

#Include %A_ScriptDir%
#Include Libs\Log.ahk
#Include Libs\Values.ahk
#Include Libs\FileDialogs.ahk
#Include Libs\GetPaths.ahk
#Include Libs\AutoSwitch.ahk
#Include Libs\Debug.ahk

#Include Libs\SettingsBackend.ahk
#Include Libs\SettingsFrontend.ahk
#Include Libs\PathsMenu.ahk

ValidateLog()
;@Ahk2Exe-IgnoreBegin
MainIcon := "QuickSwitch.ico"
ValidateWriteTrayIcon(MainIcon, "MainIcon")
;@Ahk2Exe-IgnoreEnd

SetDefaultValues()
ReadValues()
ValidateAutoStartup()

ValidateWriteKey(MainKey, 		"MainKey",      "ShowPathsMenu",    "Off",      MainKeyHook)
ValidateWriteKey(RestartKey, 	"RestartKey",   "RestartApp",       "On",       RestartKeyHook)

; Wait for dialog
Loop {
    WinWaitActive, ahk_class #32770

    try {
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
    } catch _globalError {
        LogError(_globalError)
    }

    ; Clean up
    Hotkey, %MainKey%, Off
    ahk_exe         := ""
    window_title    := ""
    DialogAction    := ""
    DialogID        := ""

}   ; End of continuous WinWaitActive loop

LogError(Exception("An error occurred while waiting for the file dialog to appear. Restart the app manually", "Main menu", "End of continuous WinWaitActive loop in main file"))
ExitApp
