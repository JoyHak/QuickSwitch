;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe, %A_ScriptDir%\Releases\QuickSwitch x64 1.0.0 
;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU32.exe, %A_ScriptDir%\Releases\QuickSwitch x32 1.0.0   

;@Ahk2Exe-SetVersion 1.0
;@Ahk2Exe-SetMainIcon QuickSwitch.ico
;@Ahk2Exe-SetDescription Quickly Switch to the folder from any file manager.
;@Ahk2Exe-SetCopyright Rafaello
;@Ahk2Exe-SetLegalTrademarks GPL-3.0 license
;@Ahk2Exe-SetCompanyName ToYu studio

;@Ahk2Exe-PostExec "C:\Program Files\7-Zip\7zG.exe" a "%A_ScriptDir%\Releases\QuickSwitch 1.0".zip -tzip -sae -- "%A_ScriptDir%\QuickSwitch.ahk" "%A_ScriptDir%\Libs" "%A_ScriptDir%\QuickSwitch.ico",, A_ScriptDir

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

SetWorkingDir %A_ScriptDir%
#Include %A_ScriptDir%
#Include Libs\Values.ahk
#Include Libs\FileDialogs.ahk
#Include Libs\GetPaths.ahk
#Include Libs\AutoSwitch.ahk
#Include Libs\Debug.ahk

#Include Libs\SettingsMenu.ahk
#Include Libs\PathsMenu.ahk

try
    Menu, Tray, Icon, QuickSwitch.ico

ReloadIfNotepad() {
    IfWinActive, ahk_exe notepad++.exe
        Reload
}

ReloadKey := "~^s"
MainKey   := "^q"

Hotkey, %ReloadKey%, ReloadIfNotepad, On
Hotkey, %MainKey%,     ShowPathsMenu, Off


ValidateAutoStartup() {
	global AutoStartup, ScriptName
    
	link := A_Startup . "\" . ScriptName . ".lnk"	
    
    IniRead,  AutoStartup,   %INI%, App, AutoStartup, %AutoStartup%
	if AutoStartup {
		if !FileExist(link) {
			FileCreateShortcut, A_ScriptFullPath, %link%, %A_ScriptDir%)
            Menu, Tray, Check, Enable autostartup
			TrayTip, %ScriptName%, AutoStartup enabled 
		}
	} else {
		if FileExist(link) {
			FileDelete, %link%
            Menu, Tray, Uncheck, Enable autostartup
            TrayTip, %ScriptName%, AutoStartup disabled,, 0x2 
		}
	}
}

AutoStartupToggle() {
	global AutoStartup
    IniRead,  AutoStartup,   %INI%, App, AutoStartup, %AutoStartup%
    
	AutoStartup := !AutoStartup	
    IniWrite, %AutoStartup%, %INI%, App, AutoStartup
	ValidateAutoStartup()
}

Menu, Tray, Insert, 1&, Enable autostartup, AutoStartupToggle, +Radio
ValidateAutoStartup()


; Wait for dialog
Loop {
    WinWaitActive, ahk_class #32770
    DialogID     := WinExist("A")
    FeedDialog   := FeedDialogFunc(DialogID)

    ; if there is any GUI left from previous calls....
    Gui, Destroy
    
    if FeedDialog 
    {                                                       ; This is a supported dialog    
        GetPaths()
        WinGet, ahk_exe, ProcessName, ahk_id %DialogID%
        WinGetTitle, window_title, ahk_id %DialogID%
        FingerPrint := ahk_exe . "___" . window_title

        ; Check if FingerPrint entry is already in INI, so we know what to do.
        IniRead, DialogAction, %INI%, Dialogs, %FingerPrint%

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
        ; Activate the CTR-Q hotkey. When pressed, start the ShowPathsMenu routine

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
    
}   ; End of continuous WinWaitActive / WinWaitNotActive loop


MsgBox Dialog waiting error... restarting.
ExitApp