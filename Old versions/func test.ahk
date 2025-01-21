/*
	By		: rafaell0 (based on v0.5dw9a by NotNull, DaWolfi and others)
	Topic	: https://www.voidtools.com/forum/viewtopic.php?f=2&t=9881
		
	WORK IN PROGRESS
	TODO
	- fix ShortPathGUI var
	- fix ini read
	- add XY code align, indentation
	- return normal height
	- return folders index
	- on clipboard change
	- align declarations and menus
	- delete legacy code (again)
	- Delete z-folder func and use ExecuteXYscript()
	- add & to menu items
	
	Global Settings in the Settings menu (label Setting_Controls: ) go through the following path:
	- initialization in SetDefaultValues()
	- Reading from INI in ReadValues()
	- Display in settings in Setting_Controls: 
	- Read from GUI and write to INI in OK:
	- Optional-overwrite ResetToDefaults:
	Therefore, when adding new variables, it is necessary to check this path for errors!

*/

;_____________________________________________________________________________
;
;					SCRIPT SETTINGS
;_____________________________________________________________________________
;
#Requires AutoHotkey v1
#SingleInstance force
#NoEnv
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, %A_ScriptDir%\QuickSwitch.ico

; Hotkeys to show & reload menu
FunctionShowMenu := Func("ShowMenu")
Hotkey, ^Q, %FunctionShowMenu%, Off

ReloadIfNotepad() 
{
    IfWinActive, ahk_exe notepad++.exe 
	{
		Reload
	}
}
Hotkey, ~^s, ReloadIfNotepad
 
; INI file ( <program name without extension>.INI)
SplitPath, A_ScriptFullPath, , , , name_no_ext
global $INI := name_no_ext . ".ini"
name_no_ext := ""

; set defaults without overwriting existing INI
; (these values are used if the INI settings are invalid)
SetDefaultValues()  
; Path to tempfilefor Directory Opus
EnvGet, $LocalAppData, LocalAppData
EnvGet, _tempfolder, TEMP
_tempfile := _tempfolder . "\dopusinfo.xml"
FileDelete, %_tempfile%



;_____________________________________________________________________________
;
;					ACTION!
;_____________________________________________________________________________
;

Loop
{
  WinWaitActive, ahk_class #32770

  ;_____________________________________________________________________________
  ;
  ;					DIALOG ACTIVE
  ;_____________________________________________________________________________
  ;

  ;	Get ID of dialog box
  $WinID 		:= WinExist("A")
  $DialogType 	:= IsDialog($WinID)

  ; if there is any GUI left from previous calls....
  Gui, Destroy

  If $DialogType										;	This is a supported dialog
  {

    ; Get Windows title and process.exe of this dialog
    WinGet, $ahk_exe, ProcessName, ahk_id %$WinID%
    WinGetTitle, $window_title, ahk_id %$WinID%

    $FingerPrint := $ahk_exe . "___" . $window_title

    ; Check if FingerPrint entry is already in INI, so we know what to do.
    IniRead, $DialogAction, %$INI%, Dialogs, %$FingerPrint%

    If ($DialogAction = 1) 								;	======= AutoSwitch ==
    {
      $FolderPath := Get_Zfolder($WinID)
      FeedDialog%$DialogType%($WinID, $FolderPath)

    }
    Else If ($DialogAction = 0 )						;	======= Never here ==
    {
      If CheckShowMenu()								;	======= Show Menu ==
      {
        ShowMenu() 	; only show with AutoOpenMenu = 1
      }
    }
    Else If CheckShowMenu()								;	======= Show Menu ==
    {
	  ShowMenu() 	; only show with hotkey ctrl-q, or AutoOpenMenu = 1
    }

    ; If we end up here, we checked the INI for what to do in this supported dialog and did it
    ; We are still in this dialog and can now enable the hotkey for manual menu-activation
    ; Activate the CTR-Q hotkey. When pressed, start the ShowMenu routine

	Hotkey, ^Q, On

  }														;	End of File Dialog routine

  Sleep, 100
  WinWaitNotActive

  ;_____________________________________________________________________________
  ;
  ;					DIALOG not ACTIVE
  ;_____________________________________________________________________________
  ;

  If ($LastMenuItem != "")
  {
    Menu ContextMenu, UseErrorLevel
    Menu ContextMenu, Delete
  }
  Hotkey, ^Q, Off

}	; End of continuous	WinWaitActive /	WinWaitNotActive loop
;_____________________________________________________________________________

MsgBox We never get here (and thats how it should be)
ExitApp

;=============================================================================
;
;			SUBROUTINES and FUNCTIONS
;
;=============================================================================

CheckShowMenu()
{
  global

  If (($OpenMenu = 1) and (InStr($LastMenuItem, "&Jump") = 0)) 
   or ($FromSettings  and ($ReDisplayMenu = 1))
    Return true
  Else
    Return false
}

;_____________________________________________________________________________
;
SetDefaultValues()
;_____________________________________________________________________________
{
  ; Here global variables are initialized 
  ; and their initial values are declared.
  global
  $OpenMenu                := 0
  $ReDisplayMenu           := 1
  $FolderNum               := 1
  
  $ShortPath               := 0
  $VirtualPath 		       := 0  
  $CutFromEnd 		       := 1  
  $FoldersCount            := 3   
  $FolderNameLength        := 20  
  $ShowDriveLetter 	       := 0 
  
  $PathSeparator           := "/"
  $ShortNameIndicator      := ".."
  
  $GuiColor                := "202020"
  $MenuColor               := "202020"
  
  ; TODO: write some globals to INI  
  $LastMenuItem     := ""
  $FromSettings     := false
  $ReDisplayMenu    := 1
  $DEBUG            := 0
}

;_____________________________________________________________________________
;
ReadValues:
;_____________________________________________________________________________
  ; read values from INI
  ; the current value of global variables is set in the SetDefaultValues() function, 
  ; so it is passed to IniRead as "default value"
  ;			  	global						INI name	section		param name					default value
  IniRead, 		$OpenMenu, 					%$INI%,		Menu, 		AlwaysOpenMenu, 	        %$OpenMenu%
  IniRead, 	  	$ShortPath, 				%$INI%,		Menu, 		ShortPath,      	        %$ShortPath%
  IniRead, 	  	$ReDisplayMenu, 			%$INI%,		Menu, 		ReDisplayMenu,  	        %$ReDisplayMenu%
  IniRead, 	  	$FolderNum, 				%$INI%,		Menu, 		ShowFolderNumbers, 			%$FolderNum%
				
  IniRead, 	  	$PathSeparator, 			%$INI%,		Menu, 		PathSeparator,      	    %$PathSeparator%
  IniRead, 	  	$ShortNameIndicator, 	 	%$INI%,		Menu, 		ShortNameIndicator,      	%$ShortNameIndicator%
				
  IniRead, 	  	$GuiColor, 					%$INI%,		Colors, 	GuiBGColor, 				%$GuiColor%
  IniRead, 	  	$MenuColor, 				%$INI%,		Colors, 	MenuBGColor, 				%$MenuColor%
Return


WriteValues: 
  ; 			value						INI name	section		param name
  IniWrite, 	%$OpenMenu%, 				%$INI%, 	Menu, 		AlwaysOpenMenu
  IniWrite, 	%$ShortPath%, 				%$INI%, 	Menu, 		ShortPath
  IniWrite, 	%$ReDisplayMenu%, 			%$INI%, 	Menu, 		ReDisplayMenu
  IniWrite, 	%$FolderNum%, 				%$INI%, 	Menu, 		ShowFolderNumbers
     
  ValidateWriteString($PathSeparator, 		"PathSeparator")
  ValidateWriteString($ShortNameIndicator, 	"ShortNameIndicator")
  
  ValidateWriteColor($GuiColor, 	"GuiBGColor")
  ValidateWriteColor($MenuColor, 	"MenuBGColor")

Return

OK:
  Gui, Submit
  Gosub, WriteValues
  Gosub, ReadValues
return
;_____________________________________________________________________________
;
IsDialog(_thisID)
;_____________________________________________________________________________
;
{
  ;	Only consider this dialog a possible file-dialog when:
  ;	(SysListView321 and ToolbarWindow321) or (DirectUIHWND1 and ToolbarWindow321) controls detected
  ;	First is for Notepad++; second for all other filedialogs
  ; dw: (SysListView321 and SysHeader321 and Edit1) is for some AutoDesk products (e.g. AutoCAD, Revit, Navisworks)
  ; which need a delay loop to switch correctly between the dialog components!
  ;	That is our rough detection of a File dialog. Returns 1 or 0 (true/false)

  WinGet, _controlList, ControlList, ahk_id %_thisID%

  Loop, Parse, _controlList, `n
  {
    If (A_LoopField = "SysListView321")
      _SysListView321 := 1

    Else If (A_LoopField = "SysHeader321")
      _SysHeader321 := 1

    Else If (A_LoopField = "ToolbarWindow321")
      _ToolbarWindow321 := 1

    Else If (A_LoopField = "DirectUIHWND1")
      _DirectUIHWND1 := 1

    Else If (A_LoopField = "Edit1")
      _Edit1 := 1

    Else If (A_LoopField = "SysTreeView321")
      _SysTreeView321 := 1

    ; Else If (A_LoopField = "SHBrowseForFolder ShellNameSpace Control1")
    ;   _SHBrowseForFolderSC1 := 1
  }

  If (_DirectUIHWND1 and _ToolbarWindow321 and _Edit1)
    Return "GENERAL"

  Else If (_SysListView321 and _SysHeader321 and _ToolbarWindow321 and _Edit1)
    Return "SYSTREEVIEW"

  Else If (_SysListView321 and _ToolbarWindow321 and _Edit1)
    Return "SYSLISTVIEW"

  Else If (_SysListView321 and _SysHeader321 and _Edit1)
    Return "SYSLISTVIEW"

  ; Else If (_SysTreeView321 and _SHBrowseForFolderSC1 and _Edit1)
  ;   Return "SYSLISTVIEW"

  Else If (_SysTreeView321 and _Edit1)
    Return "SYSTREEVIEW"

  Else
    Return false
}

;_____________________________________________________________________________
;
FeedDialogGENERAL(_thisID, _thisFOLDER)
;_____________________________________________________________________________
;
{
  global $DialogType

  WinActivate, ahk_id %_thisID%
  Sleep, 50

  ;	Focus Edit1
  ControlFocus Edit1, ahk_id %_thisID%
  WinGet, ActivecontrolList, ControlList, ahk_id %_thisID%

  Loop, Parse, ActivecontrolList, `n	; which addressbar and "Enter" controls to use
  {
    If InStr(A_LoopField, "ToolbarWindow32")
    {
      ;	ControlGetText _thisToolbarText , %A_LoopField%, ahk_id %_thisID%
      ControlGet, _ctrlHandle, Hwnd, , %A_LoopField%, ahk_id %_thisID%
      ;	Get handle of parent control
      _parentHandle := DllCall("GetParent", "Ptr", _ctrlHandle)
      ;	Get class of parent control
      WinGetClass, _parentClass, ahk_id %_parentHandle%

      If InStr(_parentClass, "Breadcrumb Parent")
      {
        _UseToolbar := A_LoopField
      }

      If Instr(_parentClass, "msctls_progress32")
      {
        _EnterToolbar := A_LoopField
      }
    }

    ;	Start next round clean
    _ctrlHandle			:= ""
    _parentHandle		:= ""
    _parentClass		:= ""

  }

  If (_UseToolbar and _EnterToolbar)
  {
    Loop, 5
    {
      SendInput ^l
      Sleep, 100

      ;	Check and insert folder
      ControlGetFocus, _ctrlFocus, A

      If (InStr(_ctrlFocus, "Edit") and (_ctrlFocus != "Edit1"))
      {
        Control, EditPaste, %_thisFOLDER%, %_ctrlFocus%, A
        ControlGetText, _editAddress, %_ctrlFocus%, ahk_id %_thisID%

        If (_editAddress = _thisFOLDER)
        {
          _FolderSet := true
        }
      }
      ;	else: 	Try it in the next round

      ;	Start next round clean
      _ctrlFocus := ""
      _editAddress := ""

    }	Until _FolderSet

    If (_FolderSet)
    {
      ;	Click control to "execute" new folder
      ControlClick, %_EnterToolbar%, ahk_id %_thisID%
      ;	Focus file name
      Sleep, 15
      ControlFocus Edit1, ahk_id %_thisID%
    }
    Else
    {
      ;	What to do if folder is not set?
    }
  }
  Else ; unsupported dialog. At least one of the needed controls is missing
  {
    MsgBox This type of dialog can not be handled (yet).`nPlease report it!
  }

  Return
}

;_____________________________________________________________________________
;
FeedDialogSYSLISTVIEW(_thisID, _thisFOLDER)
;_____________________________________________________________________________
;
{
  global $DialogType

  WinActivate, ahk_id %_thisID%
  ;	Sleep, 50

  ControlGetText _oldText, Edit1, ahk_id %_thisID%
  Sleep, 20

  ;	Make sure there exactly 1 \ at the end.
  _thisFOLDER := RTrim( _thisFOLDER , "\")
  _thisFOLDER := _thisFOLDER . "\"

  ; Make sure no element is preselected in listview, it would always be used later on if you continue with {Enter}!!
  Sleep, 10
  Loop, 100
  {
    Sleep, 10
    ControlFocus SysListView321, ahk_id %_thisID%
    ControlGetFocus, _Focus, ahk_id %_thisID%

  } Until _Focus = "SysListView321"

  ControlSend SysListView321, {Home}, ahk_id %_thisID%

  Loop, 100
  {
    Sleep, 10
    ControlSend SysListView321, ^{Space}, ahk_id %_thisID%
    ControlGet, _Focus, List, Selected, SysListView321, ahk_id %_thisID%

  } Until _Focus = ""

  Loop, 20
  {
    Sleep, 10
    ControlSetText, Edit1, %_thisFOLDER%, ahk_id %_thisID%
    ControlGetText, _Edit1, Edit1, ahk_id %_thisID%

    If (_Edit1 = _thisFOLDER)
    {
      _FolderSet := true
    }

  } Until _FolderSet

  ; ControlFocus Edit1, ahk_id %_thisID%
  ; ControlSend Edit1, {Enter}, ahk_id %_thisID%

  ; Sleep, 10
  ; ControlSetText, Edit1, , ahk_id %_thisID%
  If _FolderSet
  {
    Sleep, 20
    ControlFocus Edit1, ahk_id %_thisID%
    ControlSend Edit1, {Enter}, ahk_id %_thisID%

    ;	Restore  original filename / make empty in case of previous folder
    Sleep, 15
    ControlFocus Edit1, ahk_id %_thisID%
    Sleep, 20

    Loop, 5
    {
      ControlSetText, Edit1, %_oldText%, ahk_id %_thisID%		; set
      Sleep, 15
      ControlGetText, _2thisCONTROLTEXT, Edit1, ahk_id %_thisID%		; check

      If (_2thisCONTROLTEXT = _oldText)
        Break
    }
  }

  Return
}

;_____________________________________________________________________________
;
FeedDialogSYSTREEVIEW(_thisID, _thisFOLDER)
;_____________________________________________________________________________
;
{
  global $DialogType

  WinActivate, ahk_id %_thisID%
  ;	Sleep, 50

  ;	Read the current text in the "File Name:" box (= $OldText)
  ControlGetText _oldText, Edit1, ahk_id %_thisID%
  Sleep, 20

  ;	Make sure there exactly 1 \ at the end.
  _thisFOLDER := RTrim(_thisFOLDER , "\")
  _thisFOLDER := _thisFOLDER . "\"

  Loop, 20
  {
    Sleep, 10
    ControlSetText, Edit1, %_thisFOLDER%, ahk_id %_thisID%
    ControlGetText, _Edit1, Edit1, ahk_id %_thisID%

    If (_Edit1 = _thisFOLDER)
      _FolderSet := true

  } Until _FolderSet

  If _FolderSet
  {
    Sleep, 20
    ControlFocus Edit1, ahk_id %_thisID%
    ControlSend Edit1, {Enter}, ahk_id %_thisID%

    ;	Restore  original filename / make empty in case of previous folder
    Sleep, 15
    ControlFocus Edit1, ahk_id %_thisID%
    Sleep, 20

    Loop, 5
    {
      ControlSetText, Edit1, %_oldText%, ahk_id %_thisID%		; set
      Sleep, 15
      ControlGetText, _2thisCONTROLTEXT, Edit1, ahk_id %_thisID%		; check

      If (_2thisCONTROLTEXT = _oldText)
        Break
    }
  }

  Return
}

;_____________________________________________________________________________
ShowShortPath(_fullPath) 
;_____________________________________________________________________________
{
    ; _fullPath is shortened to the last N folders ($foldersCount) starting from the end of the path.
    ; Folders are selected as intervals between slashes, excluding them.
    ; boundaries = indexes of any slashes \ / in the path: /folder/folder/
       
    global $FoldersCount, $FolderNameLength, $PathSeparator, $ShortNameIndicator    
 	
    ; The number of slashes (indexes) is 1 more than the number of folders: /f1/f2/ - 2 folders, 3 slashes
    _maxSlashes   := $FoldersCount + 1 
    ; If the number of slashes is less than $FoldersCount, the array will contain -1
    ; This is necessary for handling paths where the number of folders is less than $FoldersCount: C:/folder
    _slashIndexes := []
	Loop, % _maxSlashes 
    {
        _slashIndexes.Push(-1)
    }
        
    ; Parsing the path from the end, looking for the indexes of slashes
	_fullPath 		.= "/" 	; Last folder bound
	_pathIndex 		:= StrLen(_fullPath)
	_slashesCount 	:= _maxSlashes 
	while (_pathIndex >= 0 && _slashesCount >= 0)
    {
        char := SubStr(_fullPath, _pathIndex, 1)
        If (char == "/" || char == "\") 
        {
            _slashIndexes[_slashesCount] := _pathIndex
            _slashesCount--
        }
        _pathIndex--
    }

    ; Extracting folder names
    _shortPath := $ShortNameIndicator
    Loop, % $FoldersCount
    {
        _left  := _slashIndexes[A_Index]
        _right := _slashIndexes[A_Index + 1]  
        If (_left != -1 && _right != -1) 
        {  
			_left++ 	 ; exclude slash from name
			
			_length 	:= _right - _left
			_nameLength := Min(_length, $FolderNameLength)
            _folderName := SubStr(_fullPath, _left, _nameLength)
            _shortPath .= $PathSeparator . _folderName
			
			If ($folderNameLength - _length < 0)
				_shortPath .= $ShortNameIndicator
        }
    }
	return _shortPath
}

;_____________________________________________________________________________
;
ShowMenu()
;_____________________________________________________________________________
{
  global $DialogType, $DialogAction, _tempfile, $INI, $WinID
  global $WinX, $WinY, $WinWidth, $WinHeight, $NrOfEntries := 0
  global $LastMenuItem  := ""
	
	
  global $OpenMenu             
  global $ReDisplayMenu        
  global $FolderNum            

  global $ShortPath            
  global $VirtualPath 		    
  global $CutFromEnd 		    
  global $FoldersCount         
  global $FolderNameLength     
  global $ShowDriveLetter 	    

  global $PathSeparator        
 
  global $GuiColor             
  global $MenuColor    
	
	
	
	
	
	
	
  
  Gosub, ReadValues

  _showMenu   := 0
  _folderList := {}
  _entry      := ""
  _ampersand  := "&"

  ; Get dialog position (used for settings menu positon)
  WinGetPos, $WinX, $WinY, $WinWidth, $WinHeight, ahk_id %$WinID%
  WinGet, _allWindows, list
  Loop, %_allWindows%
  {
    _thisID := _allWindows%A_Index%
    WinGetClass, _thisClass, ahk_id %_thisID%

    If (_thisClass = "ThunderRT6FormDC") ; XYPlorer
    {
      ClipSaved := ClipboardAll
      Clipboard := ""
      
	  ;script = `::load('$paths = get("tabs_sf", "|"); $reals = ""; foreach($path, $paths, "|") { $reals = $reals . pathreal($path) . "|" }; copytext $reals;',,s);`
	  script = ::copytext get('tabs_sf', '|')
	  
      ExecuteXYscript(_thisID, script)
	  
	  Loop, parse, clipboard, `|
	  {  
		  _shortPath := ShowShortPath(A_LoopField)
		  Menu ContextMenu, Add, %_shortPath%, FolderChoice
	  }

	  _showMenu := 1
      Clipboard := ClipSaved
      ClipSaved := ""
    }
  }	; end loop parsing all windows to find file manager folders


  $LastMenuItem := A_ThisMenuItem
  $FromSettings := true
  ;https://www.autohotkey.com/board/topic/6768-how-to-preselect-a-group-of-radiobuttons-solved-for-now/
  C0 := 0
  C1 := 0
  C%$FolderNum% := 1
  Gui, Font,,Tahoma
  
  ; TOP BUTTONS
  ;				type		coordinates		vVARIABLE  gGOTO			title
  Gui, 	Add, 	Button, 	x30  y10 w120 	gStartDebug, 				Debug &this dialog
  Gui, 	Add, 	Button, 	x+20 w120 		gResetToDefaults, 			&Reset to defaults
			
	Gui, Add, CheckBox, y10 vCheckBox1 gCB checked, Portable Mode ; https://autohotkey.com/docs/commands/Gui.htm#Events

	
  
  Gui, 	Add, 	Checkbox, 	x30  w200		v$ShortPath gShortPath, 	Show short path											
  Gui, 	Add, 	Edit, 		x230 yp-4 w60 	v$ShortNameIndicator, 		%$ShortNameIndicator%


  ; MENU SETTINS
  Gui, 	Add, 	CheckBox, 	x30 y+20 		v$OpenMenu, 				&Always open Menu
  Gui, 	Add, 	CheckBox, 					v$ReDisplayMenu, 			&Show Menu after leaving settings
		
  Gui, 	Add, 	Text, 		x30, 										&Menu backgroud color (HEX)
  Gui, 	Add, 	Edit, 		x230 yp-4 w60 	v$MenuColor, 				%$MenuColor%
		
  Gui, 	Add, 	Text, 		x30, 										&Dialogs background color (HEX)
  Gui, 	Add, 	Edit, 		x230 yp-4 w60 	v$GuiColor, 				%$GuiColor%
		
  Gui, 	Add, 	Radio, 		x30 y+15 		v$FolderNum   Checked%C0%, 	&No folder numbering
  Gui, 	Add, 	Radio, 									  Checked%C1%,	Folder n&umbers with shortcuts 1-0 (10)


  ; hidden default button used for accepting {Enter} to leave GUI
  Gui, 	Add, 	Button, 	x60 y+30 w90 	Default  gOK, 		&OK
  Gui, 	Add, 	Button, 	x+20 w90 		Cancel   gCancel, 			&Cancel  
  
  Gui, Color, %$GuiColor%

  If (_showMenu = 1 || $OpenMenu = 1)
  {
    ;---------------[ Settings ]----------------------------------------

    Menu ContextMenu, Add,
    Menu ContextMenu, Add, Settings, Dummy
	Menu ContextMenu, disable, Settings

    Menu ContextMenu, Add, &Allow AutoSwitch, AutoSwitch, Radio
    Menu ContextMenu, Add, Never &here, Never, Radio
    Menu ContextMenu, Add, &not now, ThisMenu, Radio

    ;	Activate radiobutton for current setting (depends on INI setting)
    ;	Only show AutoSwitchException if AutoSwitch is activated.

    If ($DialogAction = 1)
    {
      Menu ContextMenu, Check, &Allow AutoSwitch
      Menu ContextMenu, Add, AutoSwitch &exception, AutoSwitchException
    }
    Else If ($DialogAction = 0)
    {
      Menu ContextMenu, Check, Never &here
    }
    Else
    {
      Menu ContextMenu, Check, &not now
    }

    ; new GUI added for other settings
    Menu ContextMenu, Add,
    Menu ContextMenu, Add, More &Settings..., Setting_Controls

    ;	Menu ContextMenu, Standard
    ;	BAckup to prevent errors
    Menu ContextMenu, UseErrorLevel
    Menu ContextMenu, Color, %$MenuColor%

    Menu ContextMenu, Show, 0, 100
    Menu ContextMenu, Delete
    If ($LastMenuItem != "")
        and (RegExMatch($LastMenuItem, "\\|&Jump|Settings") = 0)
        and ($ReDisplayMenu = 1)
    {
      ShowMenu()
    }
    Else
    {
    }

    _showMenu := 0
  }
  Else
  {
    Menu ContextMenu, UseErrorLevel
    Menu ContextMenu, Delete
  }

  Return
}

;_____________________________________________________________________________
;
SetEntryIndex(_folder)
;_____________________________________________________________________________
;
{
  global $FolderNum
  global $NrOfEntries += 1

  If ($FolderNum = 0)
  {
    _entry = %_folder%
  }
  Else
  {
    If ($NrOfEntries < 10)
    {
      _entry = &%$NrOfEntries% %_folder%
    }
    Else If ($NrOfEntries = 10)
    {
      _entry = 1&0 %_folder%
    }
    Else
    {
      _entry = %$NrOfEntries% %_folder%
    }
  }

  Return _entry
}

;_____________________________________________________________________________
;
FolderChoice:
;_____________________________________________________________________________
;
  RegExMatch(A_ThisMenuItem, "i)([a-zA-Z]:\\|\\\\).*", _menuItem)
  FeedDialog%$DialogType%($WinID, _menuItem)
Return

;_____________________________________________________________________________
;
AutoSwitch:
;_____________________________________________________________________________
;
  IniWrite, 1, %$INI%, Dialogs, %$FingerPrint%
  $DialogAction := 1
  $FolderPath := Get_Zfolder($WinID)

  FeedDialog%$DialogType%($WinID, $FolderPath)

  $FolderPath := ""
  $LastMenuItem := A_ThisMenuItem

Return

;_____________________________________________________________________________
;
Never:
;_____________________________________________________________________________
;
  IniWrite, 0, %$INI%, Dialogs, %$FingerPrint%
  $DialogAction := 0
  $LastMenuItem := A_ThisMenuItem

Return

;_____________________________________________________________________________
;
ThisMenu:
;_____________________________________________________________________________
;
  IniDelete, %$INI%, Dialogs, %$FingerPrint%
  $DialogAction := ""
  $LastMenuItem := A_ThisMenuItem

Return

;_____________________________________________________________________________
;
AutoSwitchException:
;_____________________________________________________________________________
;
  global $DialogType, $INI, $FingerPrint, $WinID, $LastMenuItem

  MsgBox, 1, AutoSwitch Exceptions,
  (
    For AutoSwitch to work, typically a file manager is "2 windows away" :
      File manager ==> Aapplication ==> Dialog.
    AutoSwitch uses that fore deteceting when to switch folders.

    If AutoSwitch doesnt work as expected, the application might have
    created extra (possibly even hidden) windows
    Example: File manager==> Task Manager ==> Run new task ==> Browse
    ==> Dialog .

    To support these dialogs too:
      - Click Cancel in this Dialog
      - Alt-Tab to the file manager
      - Alt-Tab back to the file dialog
      - Press Control-Q
      - Select AutoSwitch Exception
      - Press OK

    The correct number of "windows away" will be detected and shown
    If these values are accepted, an exception will be added for this dialog.

    - Press OK if all looks OK
      (most common exception is 3; default is 2)
  )
           
  IfMsgBox OK
  {
    ;		Header for list
    Gui, Add, ListView, r30 w1024, Nr|ID|Window Title|program|Class

    WinGet, id, list

    Loop, %id%
    {
      this_id := id%A_Index%

      WinGetClass, this_class, ahk_id %this_id%
      WinGet, this_exe, ProcessName, ahk_id %this_id%
      WinGetTitle, this_title , ahk_id %this_id%

      If (this_id = $WinID)
      {
        $select := "select"
        level_1 := A_Index
        Z_exe		:= this_exe
        Z_title	:= this_title
      }

      If (not level_2) and ((this_class = "TTOTAL_CMD") or (this_class = "CabinetWClass") or (this_class = "ThunderRT6FormDC"))
      {
        $select	:= "select"
        level_2	:= A_Index
      }

      LV_Add($select, A_Index, This_id, this_title, this_exe, this_class)
      $select := ""
    }

    Delta := level_2 - level_1
    LV_ModifyCol() ; Auto-size each column to fit its contents.
    LV_ModifyCol(1, "Integer") ; For sorting purposes, indicate that column 1 is an integer.

    Gui, Show

    ;	Handle case when no file manager found (no Level2)
    MsgBox, 1, "File manager found ..", It looks like the filemanager is %Delta% levels away `n(default = 2)`n`nMAke this the new default for this specific dialog window?

    IfMsgBox OK
    {
      If (Delta = 2)
      {
        IniDelete, 	%$INI%, AutoSwitchException, %$FingerPrint%
      }
      Else
      {
        IniWrite, %Delta%, %$INI%, AutoSwitchException, %$FingerPrint%
      }

      ;	After INI was updated: try to AutoSwich straight away ..
      $FolderPath := Get_Zfolder($WinID)
	  FeedDialog%$DialogType%($WinID, $FolderPath)
    }

    GUI, Destroy
    id := ""
    this_class := ""
    this_exe := ""
    this_id := ""
    this_title := ""
    $select := ""
    level_1 := ""
    Z_exe		:= ""
    Z_title	:= ""
    level_2 := ""
    Delta := ""
    $select := ""
    $LastMenuItem := A_ThisMenuItem

  }

Return

;_____________________________________________________________________________
;
Dummy:
;_____________________________________________________________________________
;

Return

;_____________________________________________________________________________
;
Get_Zfolder(_thisID_)
;_____________________________________________________________________________
;
{
	;	Get z-order of all applicatiions.
	;	When "our" ID is found: save z-order of "the next one"
	;	Actualy: The next-next one as the next one is the parent-program that opens the dialog (e.g. notepad )
	;	If the next-next one is a file mananger (Explorer class = CabinetWClass ; TC = TTOTAL_CMD),
	;	read the active folder and browse to it in the dialog.
	;	Exceptions are in INI section [AutoSwitchException]

	global $FingerPrint, $INI, _tempfile

	;	Read Z-Order for this application (based on $Fingerprint)
	;	from INI section [AutoSwitchException]
	;	If not found, use default ( = 2)

	IniRead, _zDelta, %$INI%, AutoSwitchException, %$FingerPrint%, 2

	WinGet, id, list

	Loop, %id%
	{
	  this_id := id%A_Index%
	  If (_thisID_ = this_id)
	  {
	    this_z := A_Index
	    Break
	  }
	}

	$next := this_z + _zDelta
	next_id := id%$next%
	WinGetClass, next_class, ahk_id %next_id%


	If (next_class = "ThunderRT6FormDC") 							;	XYPlorer
	{
	  ClipSaved := ClipboardAll
	  Clipboard := ""

	  ExecuteXYscript(next_id, "::copytext get('path', a);")
	  ClipWait, 0

	  $ZFolder := clipboard
	  Clipboard	:= ClipSaved
	}

  Return $ZFolder
}

;_____________________________________________________________________________
;
GetModuleFileNameEx(p_pid)
;_____________________________________________________________________________
;
;	From: https://autohotkey.com/board/topic/32965-getting-file-path-of-a-running-process/
;	NotNull: changed "GetModuleFileNameExA" to "GetModuleFileNameExW""

{
  h_process := DllCall("OpenProcess", "uint", 0x10|0x400, "int", false, "uint", p_pid)

  If (ErrorLevel or h_process = 0)
    Return

  name_size = 255
  VarSetCapacity(name, name_size)

  result := DllCall("psapi.dll\GetModuleFileNameExW", "uint", h_process, "uint", 0, "str", name, "uint", name_size)
  DllCall("CloseHandle", h_process)

  Return, name
}

;_____________________________________________________________________________
;
ExecuteXYscript(xyHwnd, script)
;_____________________________________________________________________________
;

{
  size := StrLen(script)

  If !(A_IsUnicode)
  {
    VarSetCapacity(data, size * 2, 0)
    StrPut(script, &data, "UTF-16")
  }
  Else
  {
    data := script
  }

  VarSetCapacity(COPYDATA, A_PtrSize * 3, 0)
  NumPut(4194305, COPYDATA, 0, "Ptr")
  NumPut(size * 2, COPYDATA, A_PtrSize, "UInt")
  NumPut(&data, COPYDATA, A_PtrSize * 2, "Ptr")

  result := DllCall("User32.dll\SendMessageW", "Ptr", xyHwnd, "UInt", 74, "Ptr", 0, "Ptr", &COPYDATA, "Ptr")

  Return
}

;_____________________________________________________________________________
;
Setting_Controls:
;_____________________________________________________________________________
  
  ; show at menu position
  Xpos := $WinX
  Ypos := $WinY + 100
  Gui, Show, x%Xpos% y%Ypos% w320 h600, QuickSwitch Settings
Return

;_____________________________________________________________________________
;
ShortPath:
;_____________________________________________________________________________
  Gui, Submit, NoHide
  If (ShortPathGUI) 
  {
	GuiControl, , $ShortPath, Show short path, indicate as:
	GuiControl, Show, $ShortNameIndicator
  } 
  Else 
  {
	GuiControl, , $ShortPath, Show short path
	GuiControl, Hide, $ShortNameIndicator
  }
return

;_____________________________________________________________________________
;
GuiEscape:
GuiClose:
Cancel:
;_____________________________________________________________________________
;
  Gui, Destroy

Return

;_____________________________________________________________________________
;
ResetToDefaults:
;_____________________________________________________________________________
;
  ; reset and rewrite INI to default values
  SetDefaultValues()
  Gui, Destroy
  Gosub, Setting_Controls

Return

;_____________________________________________________________________________
;
ValidateWriteColor(_color, _iniParamName)
;_____________________________________________________________________________
;
{
  global $INI
  
  _matchPos := RegExMatch(_color, "i)[a-f0-9]{6}$")
  If (_matchPos > 0)
  {
    _result := SubStr(_color, _matchPos)
    IniWrite, %_result%, %$INI%, Colors, %_iniParamName%
  }
}

;_____________________________________________________________________________
;
ValidateWriteInteger(_new, _iniParamName)
;_____________________________________________________________________________
;
{  
  global $INI

  If _new is Integer
  {
	_result := _new
	IniWrite, %_result%, %$INI%, Menu, %_iniParamName%
  }
}

;_____________________________________________________________________________
;
ValidateWriteString(_new, _iniParamName)
;_____________________________________________________________________________
;
{  
  global $INI
  
  _result := Format("{}", _new)  
  IniWrite, %_result%, %$INI%, Menu, %_iniParamName%
}

;_____________________________________________________________________________
;
StartDebug:
;_____________________________________________________________________________
;
  Gui, Destroy
  Gosub, Debug_Controls

Return

;_____________________________________________________________________________
;
Debug_Controls:
;_____________________________________________________________________________
;
  ; Add ControlGetPos [, X, Y, Width, Height, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
  ; change folder to ahk folder. change name to fingerpringt.csv
  global $GuiColor
  SetFormat, Integer, D
  ;	Header for list
  Gui, Add, ListView, r30 w1024, Control|ID|PID||Text|X|Y|Width|Height
  ;	Loop through controls
  WinGet, ActivecontrolList, ControlList, A

  Loop, Parse, ActivecontrolList, `n
  {
    ;	Get ID
    ControlGet, _ctrlHandle, Hwnd, , %A_LoopField%, A
    ;	Get Text
    ControlGetText _ctrlText, , ahk_id %_ctrlHandle%
    ;	Get control coordinates
    ControlGetPos _X, _Y, _Width, _Height, , ahk_id %_ctrlHandle%
    ;	Get PID
    _parentHandle := DllCall("GetParent", "Ptr", _ctrlHandle)
    ;	Add to listview ; abs for hex to dec
    LV_Add(, A_LoopField, abs(_ctrlHandle), _parentHandle, _ctrlText, _X, _Y, _Width, _Height)
  }

  LV_ModifyCol() ; Auto-size each column to fit its contents.
  LV_ModifyCol(2, "Integer")
  LV_ModifyCol(3, "Integer")

  Gui, Add, Button, y+10 w100 h30 gDebugExport, Export
  Gui, Add, Button, x+10 w100 h30 gCancelLV, Cancel

  Gui, Color, %$GuiColor%
  Gui, Show

Return

;_____________________________________________________________________________
;
DebugExport:
;_____________________________________________________________________________
;
  global $FingerPrint
  _fileName := A_ScriptDir . "\" . $FingerPrint . ".csv"
  oFile := FileOpen(_fileName, "w") ; Creates a new file, overwriting any existing file.

  If IsObject(oFile)
  {
    ;	Header
    _line := "ControlName;ID;PID;Text;X;Y;Width;Height"
    oFile.WriteLine(_line)
    Gui, ListView

    Loop % LV_GetCount()
    {
      LV_GetText(_col1, A_index, 1)
      LV_GetText(_col2, A_index, 2)
      LV_GetText(_col3, A_index, 3)
      LV_GetText(_col4, A_index, 4)
      LV_GetText(_col5, A_index, 5)
      LV_GetText(_col6, A_index, 6)
      LV_GetText(_col7, A_index, 7)
      LV_GetText(_col8, A_index, 8)

      _line := _col1 ";" _col2 "," _col3 ";" _col4 ";" _col5 ";" _col6 ";" _col7 ";" _col8 ";"
      oFile.WriteLine(_line)
    }

    oFile.Close()
    oFile:=""

    Msgbox Results exported to:`n`n"%_filename%"
  }
  Else						; File could not be initialized
  {
    Msgbox Cant create %_fileName%
  }

;_____________________________________________________________________________
CancelLV:
;_____________________________________________________________________________
  LV_Delete()
  GUI, Destroy

Return


