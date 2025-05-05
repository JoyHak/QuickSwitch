;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU32.exe, %A_ScriptDir%\Releases\%A_ScriptName~\.ahk%-x32.exe
;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe, %A_ScriptDir%\Releases\%A_ScriptName~\.ahk%-x64.exe

;@Ahk2Exe-SetVersion %A_ScriptName~[^\d\.]+%
;@Ahk2Exe-SetMainIcon QuickSwitch.ico
;@Ahk2Exe-SetDescription https://github.com/JoyHak/QuickSwitch
;@Ahk2Exe-SetCopyright Rafaello
;@Ahk2Exe-SetLegalTrademarks GPL-3.0 license
;@Ahk2Exe-SetCompanyName ToYu studio

;@Ahk2Exe-Let U_name = %A_ScriptName~\.ahk%
;@Ahk2Exe-PostExec "C:\Program Files\7-Zip\7zG.exe" a "%A_ScriptDir%\Releases\%U_name%".zip -tzip -sae -- "%A_ScriptDir%\%U_name%.ahk" "%A_ScriptDir%\Lib" "%A_ScriptDir%\QuickSwitch.ico",, A_ScriptDir

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

FileEncoding, UTF-8
SetWorkingDir %A_ScriptDir%

ScriptName := "QuickSwitch"
INI        := ScriptName ".ini"
ErrorsLog  := "Errors.log"
MainIcon   := ""

;@Ahk2Exe-IgnoreBegin
MainIcon   := "QuickSwitch.ico"
;@Ahk2Exe-IgnoreEnd

#Include <Log>
#Include <Debug>
#Include <Values>
#Include <FileDialogs>

#Include <Processes>
#Include <ManagerMessages>
#Include <ManagerClasses>
#Include <TotalCommander>
#Include <GetPaths>

#Include <SettingsBackend>
#Include <MenuBackend>

#Include <SettingsFrontend>
#Include <MenuFrontend>

InitLog()

SetDefaultValues()
ReadValues()
InitAutoStartup()

ValidateTrayIcon("MainIcon",    MainIcon)
ValidateKey(     "MainKey",     MainKey,     MainKeyHook,     "Off",  "ShowMenu")
ValidateKey(     "RestartKey",  RestartKey,  RestartKeyHook,  "On",   "RestartApp")

Loop {
    ; Wait for any "Open/Save as" file dialog
    WinWaitActive, ahk_class #32770

    try {
        DialogID   := WinActive("A")
        FileDialog := GetFileDialog(DialogID)

        if FileDialog {
            ; This is a supported dialog
            ; If there is any GUI left from previous calls...
            Gui, Destroy

            WinGet,          Exe,        ProcessName,    ahk_id %DialogID%
            WinGetTitle,     WinTitle,                   ahk_id %DialogID%
            try ControlGet,  EditId,     hwnd,, Edit1,   ahk_id %DialogID%

            FingerPrint   := Exe "___" WinTitle
            FileDialog    := FileDialog.bind(SendEnter, EditId)

            SelectMenuPath := Func("SelectPath").bind(ShowAfterSelect || ShowAlways)

            ; Get current dialog settings or use default mode (AutoSwitch flag)
            ; Current settings override "Always AutoSwitch" mode (if they exist)
            IniRead, DialogAction, % INI, Dialogs, % FingerPrint, % AutoSwitch
            GetPaths(Paths := [], DialogAction = 1)

            ; Turn on registered hotkey to show menu later
            ValidateKey("MainKey", MainKey, MainKeyHook, "On")

            if IsMenuReady()
                ShowMenu()

            FromSettings := false
        }

    } catch GlobalError {
        LogError(GlobalError)
    }

    Sleep, 100
    WinWaitNotActive
    ValidateKey("MainKey", MainKey, MainKeyHook, "Off")

    ; Save the selected option in the Menu if it has been changed
    if (SaveDialogAction && FingerPrint && DialogAction != "") {
        SaveDialogAction := false
        IniWrite, % DialogAction, % INI, Dialogs, % FingerPrint
    }
}   ; End of continuous WinWaitActive loop

LogError(Exception("An error occurred while waiting for the file dialog to appear. Restart " ScriptName " app manually"
                   , "main menu"
                   , "End of continuous WinWaitActive loop in main file"))
ExitApp
