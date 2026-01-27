;@Ahk2Exe-SetDescription https://github.com/JoyHak/QuickSwitch
;@Ahk2Exe-SetProductName QuickSwitch
;@Ahk2Exe-SetMainIcon Icons\QuickSwitch.ico
;@Ahk2Exe-SetCopyright Rafaello
;@Ahk2Exe-SetCompanyName ToYu studio
;@Ahk2Exe-SetLegalTrademarks GPL-3.0 license
;@Ahk2Exe-SetVersion %A_ScriptName~[^\d\.]+%

#Requires AutoHotkey v1.1.37.02 Unicode
#Warn
#NoEnv
#Persistent
#SingleInstance force
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetWinDelay, -1
SetKeyDelay, -1

Process, % "Priority", , % "A"
FileEncoding, % "UTF-8"
SetWorkingDir, % A_ScriptDir
CoordMode, % "Menu", % "Screen"
CoordMode, % "Mouse", % "Screen"

ScriptName := "QuickSwitch"
INI        := ScriptName ".ini"
ErrorsLog  := "Errors.log"

#Include <Log>
#Include <Debug>
#Include <Values>
#Include <FileDialogs>

#Include <Elevated>
#Include <Windows>
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
ValidateKey(     "MainKey",     MainKey,     "",   "Off",  "ShowMenu")

InitAutoStartup()
InitDarkTheme()
InitSections("All")

;@Ahk2Exe-IgnoreBegin
ValidateKey(     "RestartKey",  RestartKey,  "~",  "On",   "RestartApp")
if ShowUiAfterRestart
    ShowSettings()
if ShowAfterRestart 
    GoSub ^#+0
;@Ahk2Exe-IgnoreEnd

Loop {
    ; Wait for any "Open/Save as" file dialog
    WinWaitActive, % "ahk_class #32770"

    try {
        DialogId := WinActive("A")
        
        IniRead, SendEnter, % INI, % "Global", % "SendEnter", 0
        if !IsFileDialog(DialogId, EditId, , SendEnter) {
            WinWaitNotActive, % "ahk_id " DialogId
            Continue
        }

        ; If there is any GUI left from previous calls...
        Gui, Destroy

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
        if ShowFavorites
            GetFavoritePaths(FavoritePaths := [])

        if ShowManagers {
            ; Disable clipboard analysis while file managers transfer data through it
            OnClipboardChange("GetClipboardPath", false)
            GetPaths(ManagersPaths := [], ActiveTabOnly, ShowLockedTabs)
        }
        OnClipboardChange("GetClipboardPath", ShowClipboard)

        ; Force menu re-creation on first hotkey press
        try Menu, % "ContextMenu", % "Delete"

        if (DialogAction = 1) {
            ; Perform AutoSwitch after preparation
            if (AutoSwitchTarget = "MenuStack")
                CreateMenu()  ; create MenuStack

            if IsDialogClosed {
                ; Add delay between actions to prevent accidental dialog closing (issue #77)
                SetWinDelay, 120
                SetKeyDelay, 120
                try ControlFocus, % "SysTreeView321", % "ahk_id " DialogId
                try ControlSend,, % "{end}{space}",   % "ahk_id " EditId
            }

            ; AutoSwitch if all paths are recieved.
            if (%AutoSwitchTarget%.Length())
                SwitchPath(%AutoSwitchTarget%[AutoSwitchIndex][1])

            if IsDialogClosed {
                SetWinDelay, -1
                SetKeyDelay, -1
            }
        }
        IsDialogClosed := false
        
        /*
        To prevent the Menu from stuck on the screen, we must first activate the hidden (main) script window by its handle (A_ScriptHwnd):
        https://github.com/AutoHotkey/AutoHotkey/blob/16ea5db9247812593c53bbb0444422524cf1a1df/source/script_menu.cpp#L1429
        
        In rare cases, script window will suddenly appear in the middle of the screen, closing the file dialog.
        This occurs inside WinActivate() after WinShow() call if IsIconic() is `true`:
        https://github.com/AutoHotkey/AutoHotkey/blob/16ea5db9247812593c53bbb0444422524cf1a1df/source/window.cpp#L182
        To prevent this we must use different approach, see SetForegroundWindow() in Lib\Windows.ahk
        */
        ; IsScriptActive := SetForegroundWindow(A_ScriptHwnd)
        IsScriptActive := true
        ; Turn on registered hotkey
        ValidateKey("MainKey", MainKey,, "On")
    
        if (IsMenuReady() && IsScriptActive)
            ShowMenu()  ; halt main thread

        ; WinActivate % "ahk_id " DialogId
        ; WinMoveBottom(A_ScriptHwnd)
        
        LogElevatedNames()

    } catch GlobalEx {
        LogException(GlobalEx)
    }

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
    IsDialogClosed := !WinExist("ahk_id " DialogId)

}   ; End of continuous WinWaitActive loop


LogError("An error occurred while waiting for the file dialog to appear. Restart " ScriptName " app manually"
       , "main menu"
       , "End of continuous WinWaitActive loop in main file")

ExitApp

;@Ahk2Exe-IgnoreBegin Alt + Tilde ~ (or backtick `)
!sc029::     
   if ShowOpenDialog {
       SendEvent ^!o
       return 
   } else if ShowSaveAsDialog {
       SendEvent ^!s  
       return     
   }
;@Ahk2Exe-IgnoreEnd
^#+0::
    DialogId := WinActive("A")
    CreateMenu()
    ShowMenu()
return

; Disable special keys
DisableKey() {
    global

    if (RegisteredKeys.HasKey(A_ThisHotkey) && !IsDialogClosed) {
        ; This key is chosen by the user in the settings and the file dialog is open.
        ; Its standard functionality must be disabled.
        SendInput, % "{Blind}{vkFF}"
    }
}


~Tab::DisableKey()
~LWin::DisableKey()
~Space::DisableKey()
~RButton::DisableKey()
~Capslock::
    if (RegisteredKeys.HasKey(A_ThisHotkey) && !IsDialogClosed)
        SetCapsLockState, % "Off"
return