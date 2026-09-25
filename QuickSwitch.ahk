ScriptName    := "QuickSwitch"
;@Ahk2Exe-SetProductName %A_PriorLine~.*"(.*)"~$1%
ScriptVersion := "1.9.19"
;@Ahk2Exe-SetVersion %A_PriorLine~.*"(.*)"~$1%
ScriptRepo    := "https://github.com/JoyHak/QuickSwitch"
IssueTracker  := "https://github.com/JoyHak/QuickSwitch/issues/new?template=bug-report.yaml"
;@Ahk2Exe-SetDescription %A_PriorLine~.*"(.*)"~$1%
;@Ahk2Exe-SetMainIcon Icons\QuickSwitch.ico
;@Ahk2Exe-SetCopyright Rafaello
;@Ahk2Exe-SetCompanyName ToYu studio
;@Ahk2Exe-SetLegalTrademarks GPL-3.0 license

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

INI         := ScriptName ".ini"     ; see Lib\Values.ahk for details about .ini
ErrorsLog   := "Errors.log"          ; file for error dumps and tracing
ErrorsCount := 0                     ; track how many errors occurred in a short period of time

PinnedPaths    := []
FavoritePaths  := []
ManagersPaths  := []
ClipboardPaths := []

#Include <Log>
#Include <Tray>
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

if IsFile(INI) {
    ReadValues()
    ReadDialogs()
    ReadPinnedPaths(PinnedPaths)
} else {
    IsNewUser := true
    WriteValues()
}

InitTrayMenu()
ValidateKey("PinKey",      PinKey,      "",   "Off",  "Dummy")
ValidateKey("MainKey",     MainKey,     "",   "Off",  "ShowMenu")
ValidateKey("EnforceKey",  EnforceKey,  "$",  "On",   "EnforceShowMenu")

InitAutoStartup()
InitDarkTheme()
InitWelcomeMessage()

OnExit("OnExitCleanup")

;@Ahk2Exe-IgnoreBegin
ValidateKey("RestartKey",  RestartKey,  "~",  "On",   "RestartApp")
if ShowUiAfterRestart
    ShowSettings()
if ShowAfterRestart
    EnforceShowMenu()
;@Ahk2Exe-IgnoreEnd

Loop {
    ; Wait for any "Open/Save as" file dialog
    WinWaitActive, % "ahk_class #32770"

    try {
        DialogId := DllCall("GetForegroundWindow", "Ptr")
        
        if FromSettings {
            Gui, Destroy
        }
        
        if (IsDialogClosed || DialogId != Last.DialogId) {
            SendEnter := Last.SendEnter
            if !IsFileDialog(DialogId, EditId, , SendEnter) {
                WinWaitNotActive, % "ahk_id " DialogId
                Continue
            }

            WinGet,        DialogProcess, % "ProcessName", % "ahk_id " DialogId
            WinGetTitle,   DialogTitle,                    % "ahk_id " DialogId
            FingerPrint := DialogProcess "___" DialogTitle
            
            /*
            `DialogAction` represents user choice for current dialog: 
            autoswitch = 1, black list = -1 or nothing = 0.
            `DialogProcess` key affects all dialogs of this process 
            (currently used by Black List).
            */
            if FileDialogs.HasKey(DialogProcess) {
                DialogAction := FileDialogs[DialogProcess]
            } else if FileDialogs.HasKey(FingerPrint) {
                DialogAction := FileDialogs[FingerPrint]
            } else {
                ; Fallback to "Always AutoSwitch" value
                DialogAction := AutoSwitch
            }

            ; Get paths for Menu sections
            if ShowFavorites
                GetFavoritePaths(FavoritePaths)
        }
        
        if ShowManagers {
            ; Disable clipboard analysis while file managers transfer data through it
            OnClipboardChange("GetClipboardPath", false)
            GetPaths(ManagersPaths := []
                   , ListerIndex,    ShowAllDesktops
                   , ActivePaneOnly, ActiveTabOnly, ShowLockedTabs)
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
                ; Remove delay
                SetWinDelay, -1
                SetKeyDelay, -1
            }
        }
        IsDialogClosed := false

        ; Turn on registered hotkey
        ValidateKey("MainKey", MainKey,, "On")

        if IsMenuReady() {
            FromSettings := false
            ShowMenu()  ; halt main thread
        }
        
        LogElevatedNames()
        ErrorsCount := 0
        
    } catch GlobalEx {
        LogException(GlobalEx)
        
        if (ErrorsCount > 10) {
            if MsgError("Too many errors occurred in a short period of time.`nDo you want to report about it?")
                TrayIssueTracker()
            
            ExitApp
        }
    }
    
    Sleep 200
    WinWaitNotActive, % "ahk_id " DialogId
    ValidateKey("MainKey", MainKey,, "Off")

    ; Clean-up paths from clipboard in the new process
    if (Last.DialogProcess != DialogProcess && Last.DialogProcess)
        ClipboardPaths := []
    
    Last.DialogProcess := DialogProcess
    Last.DialogId  := DialogId
    IsDialogClosed := !WinExist("ahk_id " DialogId)

}   ; End of main loop


if MsgError("An error occurred while waiting for the file dialog to appear.`nDo you want to report about error?")
    TrayIssueTracker()

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
    EnforceShowMenu()
return
;@Ahk2Exe-IgnoreEnd
