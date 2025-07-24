;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU32.exe, %A_ScriptDir%\Releases\%A_ScriptName~\.ahk%-x32.exe
;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe, %A_ScriptDir%\Releases\%A_ScriptName~\.ahk%-x64.exe

;@Ahk2Exe-SetVersion %A_ScriptName~[^\d\.]+%
;@Ahk2Exe-SetMainIcon Icons\QuickSwitch.ico
;@Ahk2Exe-SetDescription https://github.com/JoyHak/QuickSwitch
;@Ahk2Exe-SetCopyright Rafaello
;@Ahk2Exe-SetLegalTrademarks GPL-3.0 license
;@Ahk2Exe-SetCompanyName ToYu studio

;@Ahk2Exe-Let U_name = %A_ScriptName~\.ahk%
;@Ahk2Exe-PostExec "C:\Program Files\7-Zip\7zG.exe" a "%A_ScriptDir%\Releases\%U_name%".zip -tzip -sae -- "%A_ScriptDir%\%U_name%.ahk" "%A_ScriptDir%\Icons" "%A_ScriptDir%\Favorites" "%A_ScriptDir%\Lib",, A_ScriptDir

#Requires AutoHotkey v1.1.37.02 Unicode
#Warn
#NoEnv
#Persistent
#SingleInstance force
#KeyHistory 0
ListLines Off
SendLevel 2
SetBatchLines, -1
SetWinDelay, -1
SetKeyDelay, -1

Process, % "Priority", , % "A"
FileEncoding, % "UTF-8"
SetWorkingDir, % A_ScriptDir

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

if IsFile(INI)
    ReadValues()
else
    WriteValues()

ValidateTrayIcon("MainIcon",    MainIcon)
ValidateKey(     "PinKey",      PinKey,      "",   "Off",  "Dummy")  ; Init and dont use this key
ValidateKey(     "MainKey",     MainKey,     "",   "Off",  "^#+0")
ValidateKey(     "RestartKey",  RestartKey,  "~",  "On",   "RestartApp")
IniRead, PinKey, % INI, % "Global", % "PinKey"

InitAutoStartup()
InitDarkTheme()
InitSections("All")

Loop {
    ; Wait for any "Open/Save as" file dialog
    WinWaitActive, % "ahk_class #32770"

    try {
        DialogId   := WinActive("A")
        FileDialog := GetFileDialog(DialogId, EditId)
        
        if !FileDialog {
            WinWaitNotActive, % "ahk_id " DialogId
            Continue
        }
        
        ; This is a supported dialog
        ; Switch focus to non-buttons to prevent accidental closing
        try {
            ControlFocus  % "ToolbarWindow321", % "ahk_id " DialogId
            ControlSend,, % "{end}{space}",     % "ahk_id " EditId
            Sleep 100
        }
        
        WinGet,        DialogProcess, % "ProcessName", % "ahk_id " DialogId
        WinGetTitle,   DialogTitle,                    % "ahk_id " DialogId
        FingerPrint := DialogProcess "___" DialogTitle

        ; Get current dialog settings or use default mode (AutoSwitch flag).
        ; The default DialogAction value is depends on "Always AutoSwitch" option.
        ; Current choice will override "Always AutoSwitch" value.
        IniRead, BlackList,    % INI, % "Dialogs", % DialogProcess, 0               ; -1 or 0
        IniRead, DialogAction, % INI, % "Dialogs", % FingerPrint,   % AutoSwitch    ; -1, 0 or 1 
        DialogAction |= BlackList   
        
        ; Get paths for Menu sections
        if ShowManagers {
            ; Disable clipboard analysis while file managers transfer data through it
            OnClipboardChange("GetClipboardPath", false)
            GetPaths(ManagersPaths := [], DialogAction == 1, ActiveTabOnly == true)
        }
        OnClipboardChange("GetClipboardPath", ShowClipboard)
        
        if ShowFavorites
            GetFavoritePaths(FavoritePaths := [])

        ; Turn on registered hotkey to show menu later
        ValidateKey("MainKey", MainKey,, "On")
        ; If there is any GUI left from previous calls...
        Gui, Destroy
        
        if IsMenuReady()
            SendEvent, % "^#+0"

        LogElevatedNames()
    } catch GlobalEx {
        LogException(GlobalEx)
    }

    Sleep, 100
    WinWaitNotActive, % "ahk_id " DialogId
    ValidateKey("MainKey", MainKey,, "Off")
    ValidatePinnedPaths("PinnedPaths", PinnedPaths, ShowPinned)

    ; Pending actions that are performed after closing a dialog
    ; Save the selected option in the Menu if it has been changed
    if WriteDialogAction {
        WriteDialogAction := false
        try IniWrite, % DialogAction, % INI, % "Dialogs", % FingerPrint
    }

    ; Clean-up paths from clipboard in new process
    if (LastDialogProcess && (LastDialogProcess != DialogProcess))
        Clips := []

    LastDialogProcess := DialogProcess

}   ; End of continuous WinWaitActive loop


LogError("An error occurred while waiting for the file dialog to appear. Restart " ScriptName " app manually"
       , "main menu"
       , "End of continuous WinWaitActive loop in main file")

ExitApp


; Disable special keys
DisableKey() {
    global
    
    if (RegisteredSpecialKeys[A_ThisHotkey] && FileDialog) {
        ; This key is chosen by the user in the settings and the file dialog is open.
        ; Its standard functionality must be disabled.        
        SendEvent, % "{Blind}{vkFF}"
    }
}

#IfWinActive ahk_class #32770
~Tab::DisableKey()
~LWin::DisableKey()
~Space::DisableKey()
~RButton::DisableKey()
~Capslock::
    if (RegisteredSpecialKeys[A_ThisHotkey] && FileDialog)
        SetCapsLockState, % "Off"
return

^#+0::
    ; Popup main Menu
    ShowMenu()

    ; Release all keys to prevent holding
    SendEvent, % "{Ctrl up}{Win up}{Shift up}"
Return
