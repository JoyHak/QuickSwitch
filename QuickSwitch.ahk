/*
	QuickSwitch modification by Rafaello. 
	Based on v0.5dw9a by NotNull, DaWolfi and others: 
	https://www.voidtools.com/forum/viewtopic.php?f=2&t=9881
	
	
	This is the main file that is waiting for the dialog window to appear. 
	Then initializes the menu display. 
	The hotkey is declared once and linked to the ShowPathsMenu().
*/

#Requires AutoHotkey v1.1
#SingleInstance force
#NoEnv

SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, %A_ScriptDir%\QuickSwitch.ico

#Include %A_ScriptDir%
#Include Libs\Values.ahk
#Include Libs\FileDialogs.ahk
#Include Libs\GetPaths.ahk
#Include Libs\AutoSwitch.ahk
#Include Libs\Debug.ahk

#Include Libs\SettingsMenu.ahk
#Include Libs\PathsMenu.ahk
  
ReloadKey := "~^s"
MainKey   := "^q"
;MainKey  := "+space"

ReloadIfNotepad() 
{
    IfWinActive, ahk_exe notepad++.exe 
	{
		Reload
	}
}
Hotkey, %ReloadKey%, ReloadIfNotepad, On
Hotkey, %MainKey%,   ShowPathsMenu,   Off

; INI file
SplitPath, A_ScriptFullPath, , , , ScriptName
global INI := ScriptName . ".ini"
ScriptName := ""

; Wait for dialog
Loop
{
  WinWaitActive, ahk_class #32770
  DialogID 		:= WinExist("A")
  FeedDialog 	:= FeedDialogFunc(DialogID)

  ; if there is any GUI left from previous calls....
  Gui, Destroy
  
  If FeedDialog										;	This is a supported dialog
  {
    GetPaths()
    WinGetTitle, window_title, ahk_id %DialogID%
    FingerPrint := ahk_exe . "___" . window_title

    ; Check if FingerPrint entry is already in INI, so we know what to do.
    IniRead, DialogAction, %INI%, Dialogs, %FingerPrint%

    If (DialogAction == 1)							;	======= AutoSwitch ==
    {
	  AutoSwitch()
    }
    Else If (DialogAction == 0) 					;	======= Never here ==
    {
      If ShouldOpen()								
      {
        ShowPathsMenu() 	; AutoOpenMenu only
      }
    }
    Else If ShouldOpen()							;	======= Show Menu ==
    {
	  ShowPathsMenu() 		; hotkey or AutoOpenMenu
    }

    ; If we end up here, we checked the INI for what to do in this supported dialog and did it
    ; We are still in this dialog and can now enable the hotkey for manual menu-activation
    ; Activate the CTR-Q hotkey. When pressed, start the ShowPathsMenu routine

	Hotkey, %MainKey%, On

  }														;	End of File Dialog routine

  Sleep, 100
  WinWaitNotActive

  If (LastMenuItem != "")
  {
    Menu ContextMenu, UseErrorLevel
    Menu ContextMenu, Delete
  }
  Hotkey, %MainKey%, Off  
  ; Clean up
  ahk_exe      := ""
  window_title := ""
  DialogAction := ""
  DialogID	   := ""
  DialogType   := ""
  
}	; End of continuous	WinWaitActive /	WinWaitNotActive loop


MsgBox We never get out of dialog waiting... restarting.
ExitApp