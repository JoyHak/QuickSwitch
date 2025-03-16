/* 
  This is the context menu from which you can select the desired path. 
  Please note that the displayed and actual paths are independent of each other, 
  which allows you to display anything. 
  For further information on working with paths, please refer to GetPaths.ahk. 
  AutoSwitch settings code in AutoSwitch.ahk. 
*/

ShouldOpen()
{
  global
  If ((OpenMenu and !InStr(LastMenuItem, "&Jump")) 
   or (FromSettings and ReDisplayMenu))
   {
     Return true
   }
    
  Return false
}

;_____________________________________________________________________________
;
AddPathsMenuItems()
;_____________________________________________________________________________ 
{
  ; should be optimized
  global 	VirtualPath, FolderNum, ShortPath, paths, virtuals
  _paths := VirtualPath ? virtuals : paths

  for _index, _path in _paths
  {
  	If FolderNum
	  _display .= "&" . _index . " " 
	If ShortPath
	  _display .= ShowShortPath(_path)
	Else
	  _display .= _path

  	Menu, ContextMenu, Insert,, %_display%, PathChoice
	_display := ""
  }

}
;_____________________________________________________________________________
;
AddPathsMenuSettings()
;_____________________________________________________________________________ 
{
  global DialogAction
  Menu ContextMenu, Add,
  Menu ContextMenu, Add, Settings, Dummy
  Menu ContextMenu, disable, Settings
  
  Menu ContextMenu, Add, &Allow AutoSwitch, AutoSwitch, Radio
  Menu ContextMenu, Add, Never &here, Never, Radio
  Menu ContextMenu, Add, &not now, ThisMenu, Radio
  
  ; Activate radiobutton for current setting (depends on INI setting)
  ; Only show AutoSwitchException if AutoSwitch is activated.
  
  If DialogAction
    Menu ContextMenu, Check, &Allow AutoSwitch
  Else If !DialogAction
    Menu ContextMenu, Check, Never &here
  Else
    Menu ContextMenu, Check, &not now
  
  ; new GUI added for other settings
  Menu ContextMenu, Add,
  Menu ContextMenu, Add, More &Settings..., ShowSettingsMenu
}

;_____________________________________________________________________________
;
HidePathsMenu()
;_____________________________________________________________________________ 
{
  ; Ignore errors
  Menu ContextMenu, UseErrorLevel
  Menu ContextMenu, Delete
}

;_____________________________________________________________________________
;
ShowPathsMenu()
;_____________________________________________________________________________ 
{
  global DialogID, DialogType, DialogAction, FileManagerID, INI, paths, MenuColor
  global WinX, WinY, WinWidth, WinHeight, MenuColor, ReDisplayMenu
  global FromSettings  := false
  ReadValues()

  ; Get dialog position (also used for settings menu positon)
  WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %DialogID%
  If paths
  {   
    AddPathsMenuItems()
    AddPathsMenuSettings()
    Menu ContextMenu, Color, %MenuColor%
    Menu ContextMenu, Show, 0, 100    
	HidePathsMenu()

    If ((LastMenuItem != "")
        and !RegExMatch(LastMenuItem, "\\|&Jump|Settings")
        and ReDisplayMenu)
    {
      ShowPathsMenu()
    }
  }
  Else
  {
	HidePathsMenu()
  }
  Return
}