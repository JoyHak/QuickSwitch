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
#Include Libs\Debug.ahk
#Include Libs\Values.ahk
#Include Libs\FileDialogs.ahk

#Include Libs\Processes.ahk
#Include Libs\ManagerMessages.ahk
#Include Libs\GetTotalcmdIni.ahk
#Include Libs\GetTotalcmdTabs.ahk

#Include Libs\ManagerClasses.ahk
#Include Libs\GetPaths.ahk

#Include Libs\SettingsBackend.ahk
#Include Libs\MenuBackend.ahk

#Include Libs\SettingsFrontend.ahk
#Include Libs\MenuFrontend.ahk

ValidateLog()

;@Ahk2Exe-IgnoreBegin
MainIcon := "QuickSwitch.ico"
ValidateWriteTrayIcon(MainIcon, "MainIcon")
;@Ahk2Exe-IgnoreEnd

SetDefaultValues()
ReadValues()
ValidateAutoStartup()

ValidateWriteKey(MainKey, 	 "MainKey",    "ShowMenu",   "Off", MainKeyHook)
ValidateWriteKey(RestartKey, "RestartKey", "RestartApp", "On",  RestartKeyHook)

Loop {
    ; Wait for any "Open/Save as" file dialog
    WinWaitActive, ahk_class #32770

    try {
        DialogID   := WinActive("A")
        FileDialog := GetFileDialog(DialogID)

        if FileDialog {
            ; This is a supported dialog
            ; If there is any GUI left from previous calls....
            Gui, Destroy

            WinGet, Exe, ProcessName, ahk_id %DialogID%
            WinGetTitle, WinTitle, ahk_id %DialogID%
            FingerPrint := Exe . "___" . WinTitle

            ; Check if FingerPrint entry is already in INI, so we know what to do.
            IniRead, DialogAction, % INI, Dialogs, % FingerPrint, 0
            GetPaths()

            ; Turn on hotkey to hide / show menu later
            ValidateWriteKey(MainKey, "MainKey",, "On", MainKeyHook)

            if isMenuReady()
                ShowMenu()
        }

    } catch GlobalError {
        LogError(GlobalError)
    }

    Sleep, 100
    WinWaitNotActive

    ; Clean up
    ValidateWriteKey(MainKey, "MainKey",, "Off", MainKeyHook)
    Exe          := ""
    WinTitle     := ""
    DialogAction := ""
    DialogID     := ""

}   ; End of continuous WinWaitActive loop

LogError(Exception("An error occurred while waiting for the file dialog to appear. Restart the app manually", "main menu", "End of continuous WinWaitActive loop in main file"))
ExitApp
