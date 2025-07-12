;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU32.exe, %A_ScriptDir%\Releases\%A_ScriptName~\.ahk%-x32.exe
;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe, %A_ScriptDir%\Releases\%A_ScriptName~\.ahk%-x64.exe

;@Ahk2Exe-SetVersion %A_ScriptName~[^\d\.]+%
;@Ahk2Exe-SetMainIcon Icons\QuickSwitch.ico
;@Ahk2Exe-SetDescription https://github.com/JoyHak/QuickSwitch
;@Ahk2Exe-SetCopyright Rafaello
;@Ahk2Exe-SetLegalTrademarks GPL-3.0 license
;@Ahk2Exe-SetCompanyName ToYu studio

;@Ahk2Exe-Let U_name = %A_ScriptName~\.ahk%
;@Ahk2Exe-PostExec "C:\Program Files\7-Zip\7zG.exe" a "%A_ScriptDir%\Releases\%U_name%".zip -tzip -sae -- "%A_ScriptDir%\%U_name%.ahk" "%A_ScriptDir%\Lib" "%A_ScriptDir%\QuickSwitch.ico",, A_ScriptDir

#Requires AutoHotkey v1.1.37.02 Unicode
#Warn
#NoEnv
#Persistent
#SingleInstance force
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SendLevel 2
SetWinDelay, -1
SetKeyDelay, -1

FileEncoding, UTF-8
SetWorkingDir %A_ScriptDir%

ScriptName := "QuickSwitch"
INI        := ScriptName ".ini"
ErrorsLog  := "Errors.log"

#Include <Log>
#Include <Debug>
#Include <Values>
#Include <FileDialogs>

#Include <Elevated>
#Include <Processes>
#Include <ManagerMessages>
#Include <ManagerClasses>
#Include <TotalCommander>
#Include <GetPaths>

#Include <SettingsBackend>
#Include <SettingsMouse>
#Include <MenuBackend>
#Include <DarkTheme>

#Include <SettingsFrontend>
#Include <MenuFrontend>

InitLog()
SetDefaultValues()
ReadValues()

ValidateTrayIcon("MainIcon",    MainIcon)
ValidateKey(     "MainKey",     MainKey,     "",   "Off",  "^#+0")
ValidateKey(     "RestartKey",  RestartKey,  "~",  "On",   "RestartApp")

InitAutoStartup()
InitDarkTheme()

Loop {
    ; Wait for any "Open/Save as" file dialog
    WinWaitActive, ahk_class #32770
    ToolTip % ClipboardAll

    try {
        DialogId   := WinActive("A")
        FileDialog := GetFileDialog(DialogId, EditId)

        if FileDialog {
            ; This is a supported dialog
            ; Switch focus to non-buttons to prevent accidental closing
            try {
                ControlFocus ToolbarWindow321, ahk_id %DialogId%
                ControlSend,, {end}{space}, ahk_id %EditId%
                Sleep 100
            }

            ; If there is any GUI left from previous calls...
            Gui, Destroy

            WinGet,          Exe,        ProcessName,    ahk_id %DialogId%
            WinGetTitle,     WinTitle,                   ahk_id %DialogId%

            FingerPrint   := Exe "___" WinTitle
            FileDialog    := FileDialog.bind(SendEnter, EditId)

            /* 
                Get current dialog settings or use default mode (AutoSwitch flag).
                Current "AutoSwitch" choice will override "Always AutoSwitch" mode.
                If .exe or FingerPrint == -1 then DialogAction will be -1 (window in BlackList)
            */
            IniRead, BlackList, % INI, Dialogs, % Exe, 0
            IniRead, Switch, % INI, Dialogs, % FingerPrint, % AutoSwitch
            DialogAction := Switch | BlackList
            
            if MainPaths {
                ; Disable clipboard analysis while file managers transfer data through it
                OnClipboardChange("GetClipboardPath", false)
                GetPaths(Paths := [], ElevatedApps, DialogAction == 1)
            }
            OnClipboardChange("GetClipboardPath", ClipPaths)
            
            ; Turn on registered hotkey to show menu later
            ValidateKey("MainKey", MainKey,, "On")

            if IsMenuReady()
                SendEvent ^#+0

            if ElevatedApps["updated"] {
                if (Names := GetElevatedNames(ElevatedApps)) {
                    LogError("Unable to obtain paths: " Names, "admin permission", "
                        (LTrim

                            Cant send messages to these processes: " Names "
                            Run these processes as non-admin or run " ScriptName " as admin | with UI access

                        )")
                }
                ElevatedApps["updated"] := false
            }
        }

    } catch GlobalEx {
        LogException(GlobalEx)
    }

    Sleep, 100
    WinWaitNotActive, ahk_class #32770
    ValidateKey("MainKey", MainKey,, "Off")

    ; Save the selected option in the Menu if it has been changed
    if (SaveDialogAction && FingerPrint && DialogAction != "") {
        SaveDialogAction := false
        try IniWrite, % DialogAction, % INI, Dialogs, % FingerPrint
    }
    
    ; Clean-up paths from clipboard in new process
    if (LastExe && (LastExe != Exe)) {
        Clips := []
    }
    LastExe := Exe 
    
}   ; End of continuous WinWaitActive loop

LogError("An error occurred while waiting for the file dialog to appear. Restart " ScriptName " app manually"
       , "main menu"
       , "End of continuous WinWaitActive loop in main file")

ExitApp

^#+0::
    ; Popup main Menu
    ShowMenu()
    
    ; Release all keys to prevent holding
    SendEvent {Ctrl up}{Win up}{Shift up}
Return
