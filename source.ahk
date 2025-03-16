$ThisVersion := "0.5dw9a"

;@Ahk2Exe-SetVersion 0.5dw9a
;@Ahk2Exe-SetName QuickSwitch
;@Ahk2Exe-SetDescription Use opened file manager folders in File dialogs.
;@Ahk2Exe-SetCopyright NotNull

/*
By		: NotNull (adaptions: DaWolfi)
Info	: https://www.voidtools.com/forum/viewtopic.php?f=2&t=9881
*/

;_____________________________________________________________________________
;
;					SETTINGS
;_____________________________________________________________________________
;

#SingleInstance force
#NoEnv
; #Warn, All, StdOut							; Enable warnings to assist with detecting common errors.
SendMode Input
SetWorkingDir %A_ScriptDir%

;	Total Commander internal codes
global cm_CopySrcPathToClip := 2029
global cm_CopyTrgPathToClip := 2030

global $DEBUG := 0
EnvGet, $LocalAppData, LocalAppData

FunctionShowMenu := Func("ShowMenu")
Hotkey, ^Q, %FunctionShowMenu%, Off
global FunctionJumpToFolder := Func("StartJumpToFolder")

; Looking for JumpToFolder
global $JumpScriptName := SearchJumpToFolder()
If ($JumpScriptName != "")
{
  Hotkey, ^J, %FunctionJumpToFolder%, Off
}

;	INI file ( <program name without extension>.INI)
SplitPath, A_ScriptFullPath, , , , name_no_ext
global $INI := name_no_ext . ".ini"
name_no_ext := ""

; set defaults without overwriting existing INI
; (these values are used if the INI settings are invalid)
SetDefaultValues(FALSE)

; read values from INI
IniRead, OpenMenu, %$INI%, Menu, AlwaysOpenMenu, 0
$OpenMenu := CheckMenuInput(OpenMenu, $OpenMenu, "AlwaysOpenMenu", 1)

global $LastMenuItem := ""
global $FromSettings := FALSE
global $ReDisplayMenu := 1

;	Path to tempfilefor Directory Opus
EnvGet, _tempfolder, TEMP
_tempfile := _tempfolder . "\dopusinfo.xml"
FileDelete, %_tempfile%

Menu, Tray, Icon, %A_ScriptDir%\QuickSwitch.ico
;#NoTrayIcon

;_____________________________________________________________________________
;
;					ACTION!
;_____________________________________________________________________________
;

;	Check if Win7 or higher; if not: exit
If A_OSVersion in WIN_VISTA, WIN_2003, WIN_XP, WIN_2000
{
  MsgBox %A_OSVersion% is not supported.
  ExitApp
}

Loop
{
  WinWaitActive, ahk_class #32770

  ;_____________________________________________________________________________
  ;
  ;					DIALOG ACTIVE
  ;_____________________________________________________________________________
  ;

  ;	Get ID of dialog box
  $WinID := WinExist("A")

  $DialogType := SmellsLikeAFileDialog($WinID)

  ; if there is any GUI left from previous calls....
  Gui, Destroy

  If $DialogType											;	This is a supported dialog
  {

    ;	Get Windows title and process.exe of this dialog
    WinGet, $ahk_exe, ProcessName, ahk_id %$WinID%
    WinGetTitle, $window_title, ahk_id %$WinID%

    $FingerPrint := $ahk_exe . "___" . $window_title

    ;	Check if FingerPrint entry is already in INI, so we know what to do.
    IniRead, $DialogAction, %$INI%, Dialogs, %$FingerPrint%

    If ($DialogAction = 1) 								;	======= AutoSwitch ==
    {
      $FolderPath := Get_Zfolder($WinID)

      If ValidFolder($FolderPath)
      {
        ;	FeedDialog($WinID, $FolderPath)
        FeedDialog%$DialogType%($WinID, $FolderPath)
      }
      Else If CheckShowMenu()
      {
        ShowMenu() ; only show with AutoOpenMenu = 1
      }
    }
    Else If ($DialogAction = 0 )							;	======= Never here ==
    {
      If CheckShowMenu()													;	======= Show Menu ==
      {
        ShowMenu() ; only show with AutoOpenMenu = 1
      }
    }
    Else If CheckShowMenu()											;	======= Show Menu ==
    {
        ShowMenu() ; only show with hotkey ctrl-q, or AutoOpenMenu = 1
    }

    ;	If we end up here, we checked the INI for what to do in this supported dialog and did it
    ;	We are still in this dialog and can now enable the hotkey for manual menu-activation
    ;	Activate the CTR-Q hotkey. When pressed, start the  ShowMenu routine

    Hotkey, ^Q, On

    ; Activate the script 'JumpToFolder.ahk' if available
    If ($JumpScriptName != "")
    {
      Hotkey, ^J, On
    }

  }																	;	End of File Dialog routine
  Else																;	This is a NOT supported dialog
  {
    ;	Do nothing; Not a supported dialogtype
  }

  Sleep, 100

  WinWaitNotActive

  ;_____________________________________________________________________________
  ;
  ;					DIALOG NOT ACTIVE
  ;_____________________________________________________________________________
  ;

  If ($LastMenuItem != "")
  {
    Menu ContextMenu, UseErrorLevel
    Menu ContextMenu, Delete
  }

  Hotkey, ^Q, Off

  If ($JumpScriptName != "")
  {
    Hotkey, ^J, Off
  }

  ;	Clean up
  $WinID := ""
  $ahk_exe := ""
  $window_title := ""
  $ahk_exe := ""
  $DialogAction := ""
  $DialogType := ""
  $FolderPath := ""

}	; End of continuous	WinWaitActive /	WinWaitNotActive loop
;_____________________________________________________________________________

MsgBox We never get here (and that's how it should be)
ExitApp

;=============================================================================
;=============================================================================
;=============================================================================
;
;			SUBROUTINES AND FUNCTIONS
;
;=============================================================================
;=============================================================================
;=============================================================================

;_____________________________________________________________________________
;
CheckShowMenu()
;_____________________________________________________________________________
;
{
  global $OpenMenu, $LastMenuItem, $FromSettings, $ReDisplayMenu

  If (($OpenMenu = 1) AND (InStr($LastMenuItem, "&Jump") = 0)) OR ($FromSettings AND ($ReDisplayMenu	= 1))
    Return TRUE
  Else
    Return FALSE
}

;_____________________________________________________________________________
;
SetDefaultValues(_overwrite)
;_____________________________________________________________________________
;
{
  global $GuiColor := "F5F5F5"
  global $MenuColor := "C0C59C"
  global $NrOfMRU := 5
  global $OpenMenu := 0
  global $ReDisplayMenu := 1
  global $FolderNum := 1

  ; overwrite only if "Reset" botton is clicked
  if _overwrite
  {
    IniWrite, %$OpenMenu%, %$INI%, Menu, AlwaysOpenMenu
    IniWrite, %$ReDisplayMenu%, %$INI%, Menu, ReDisplayMenu
    IniWrite, %$NrOfMRU%, %$INI%, Menu, NrOfMRUFolders
    IniWrite, %$FolderNum%, %$INI%, Menu, ShowFolderNumbers
    IniWrite, %$GuiColor%, %$INI%, Colors, GuiBGColor
    IniWrite, %$MenuColor%, %$INI%, Colors, MenuBGColor
  }

  Return
}
;_____________________________________________________________________________

;_____________________________________________________________________________
;
SmellsLikeAFileDialog(_thisID)
;_____________________________________________________________________________
;
{

  ;	Only consider this dialog a possible file-dialog when:
  ;	(SysListView321 AND ToolbarWindow321) OR (DirectUIHWND1 AND ToolbarWindow321) controls detected
  ;	First is for Notepad++; second for all other filedialogs
  ; dw: (SysListView321 AND SysHeader321 AND Edit1) is for some AutoDesk products (e.g. AutoCAD, Revit, Navisworks)
  ;     which need a delay loop to switch correctly between the dialog components!
  ;	That is our rough detection of a File dialog. Returns 1 or 0 (TRUE/FALSE)

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

  If (_DirectUIHWND1 AND _ToolbarWindow321 AND _Edit1)
    Return "GENERAL"

  Else If (_SysListView321 AND _SysHeader321 AND _ToolbarWindow321 AND _Edit1)
    Return "SYSTREEVIEW"

  Else If (_SysListView321 AND _ToolbarWindow321 AND _Edit1)
    Return "SYSLISTVIEW"

  Else If (_SysListView321 AND _SysHeader321 AND _Edit1)
    Return "SYSLISTVIEW"

  ; Else If (_SysTreeView321 AND _SHBrowseForFolderSC1 AND _Edit1)
  ;   Return "SYSLISTVIEW"

  Else If (_SysTreeView321 AND _Edit1)
    Return "SYSTREEVIEW"

  Else
    Return FALSE

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

  If (_UseToolbar AND _EnterToolbar)
  {
    Loop, 5
    {
      SendInput ^l
      Sleep, 100

      ;	Check and insert folder
      ControlGetFocus, _ctrlFocus, A

      If (InStr(_ctrlFocus, "Edit") AND (_ctrlFocus != "Edit1"))
      {
        Control, EditPaste, %_thisFOLDER%, %_ctrlFocus%, A
        ControlGetText, _editAddress, %_ctrlFocus%, ahk_id %_thisID%

        If (_editAddress = _thisFOLDER)
        {
          _FolderSet := TRUE
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

  ;	Clean up; probably not needed
  _UseToolbar := ""
  _EnterToolbar := ""
  _editAddress := ""
  _FolderSet := ""
  _ctrlFocus := ""

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
      _FolderSet := TRUE
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
      _FolderSet := TRUE

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
;
StartJumpToFolder()
;_____________________________________________________________________________
;Computer\HKEY_CLASSES_ROOT\Directory\Background\shell\JumpToFolder\Command
;Computer\HKEY_CLASSES_ROOT\Folder\Background\Shell\JumpToFolder\Command
;
{
  global $JumpScriptName, $LastMenuItem

  $LastMenuItem := A_ThisMenuItem

  If ($JumpScriptName != "")
  {
    If InStr($JumpScriptName, "ahk")
    {
      Run, %A_ProgramFiles%\AutoHotkey\AutoHotkeyU64.exe %$JumpScriptName% -jump
    }
    Else
    {
      Run, %$JumpScriptName% -jump
    }
  }
  Else
  {
    MsgBox, "Script ""JumpToFolder.akh"" not found!"
  }

  Return
}

;_____________________________________________________________________________
;
SearchJumpToFolder()
;_____________________________________________________________________________
{
  RegRead, _cmdString, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\JumpToFolder\Command
  _cmd := ""

  If (_cmdString != "")
  {
    Loop, parse, _cmdString, """", " "
    {
      If (A_LoopField != "" AND InStr(A_LoopField, "JumpToFolder") > 0 AND FileExist(A_LoopField))
      {
        _cmd := A_LoopField
        Break
      }
    }
  }

  Return _cmd
}

;_____________________________________________________________________________
;
ShowMenu()
;_____________________________________________________________________________
;
{
  global $DialogType, $DialogAction, _tempfile, $JumpScriptName, $INI, $WinID
  global $OpenMenu, $NrOfMRU, $GuiColor, $MenuColor, $ReDisplayMenu, $FolderNum
  global $ExplorerFolder := {}
  global $LastMenuItem := ""
  global $FromSettings := FALSE
  global $NrOfEntries := 0

  _showMenu := 0
  _folderList := {}
  _entry := ""
  _ampersand := "&"

  ; read values from INI
  IniRead, OpenMenu, %$INI%, Menu, AlwaysOpenMenu, 0
  IniRead, ReDisplayMenu, %$INI%, Menu, ReDisplayMenu, 1
  IniRead, NumberOfMRU, %$INI%, Menu, NrOfMRUFolders, %$NrOfMRU%
  IniRead, FolderNum, %$INI%, Menu, ShowFolderNumbers, %$FolderNum%
  IniRead, GuiBGColor, %$INI%, Colors, GuiBGColor, %$GuiColor%
  IniRead, MenuBGColor, %$INI%, Colors, MenuBGColor, %$MenuColor%

  ; check INI values, only use them if valid, otherwise use defaults
  $OpenMenu := CheckMenuInput(OpenMenu, $OpenMenu, "AlwaysOpenMenu", 1)
  $ReDisplayMenu := CheckMenuInput(ReDisplayMenu, $ReDisplayMenu, "ReDisplayMenu", 1)
  $FolderNum := CheckMenuInput(FolderNum, $FolderNum, "ShowFolderNumbers", 1)
  CheckMRUInput(NumberOfMRU)
  $GuiColor := CheckColor(GuiBGColor, $GuiColor, "GuiBGColor")
  $MenuColor := CheckColor(MenuBGColor, $MenuColor, "MenuBGColor")

  ; Get windows position (maybe used for GUI positon?)
  WinGetPos, $WinX, $WinY, $WinWidth, $WinHeight, ahk_id %$WinID%

  ;	---------------[ Title BAr ]--------------------------------------
  Menu ContextMenu, Add, QuickSwitch Menu, Dummy
  Menu ContextMenu, Default, QuickSwitch Menu
  Menu ContextMenu, disable, QuickSwitch Menu

  WinGet, _allWindows, list
  Loop, %_allWindows%
  {
    _thisID := _allWindows%A_Index%
    WinGetClass, _thisClass, ahk_id %_thisID%

    ;---------------[ Total Commander Folders]--------------------------------------

    If (_thisClass = "TTOTAL_CMD")
    {
      ;	Get Process information for TC icon
      WinGet, _thisPID, PID, ahk_id %_thisID%
      _TC_exe := GetModuleFileNameEx(_thisPID)

      ClipSaved := ClipboardAll
      Clipboard := ""

      ; wait a little, or source path may not be captured!
      Sleep, 50
      SendMessage 1075, %cm_CopySrcPathToClip%, 0, , ahk_id %_thisID%
      ; Sleep, 50

      ;	Check if valid folder first. Only add it if it is.
      If (ErrorLevel = 0) AND ValidFolder(clipboard) AND AddExplorerEntry(clipboard)
      {
        _entry := SetEntryIndex(clipboard)
        Menu ContextMenu, Add, %_entry%, FolderChoice
        Menu ContextMenu, Icon, %_entry%, %_TC_exe%, 0, 16
        _showMenu := 1
      }

      SendMessage 1075, %cm_CopyTrgPathToClip%, 0, , ahk_id %_thisID%

      If (ErrorLevel = 0) AND ValidFolder(clipboard) AND AddExplorerEntry(clipboard)
      {
        _entry := SetEntryIndex(clipboard)
        Menu ContextMenu, Add, %_entry%, FolderChoice
        Menu ContextMenu, Icon, %_entry%, %_TC_exe%, 0, 16
        _showMenu := 1
      }

      Clipboard := ClipSaved
      ClipSaved := ""
    }

    ;---------------[ XYPlorer               ]--------------------------------------

    If (_thisClass = "ThunderRT6FormDC")
    {
      ;	Get Process information for TC icon
      WinGet, _thisPID, PID, ahk_id %_thisID%
      _XYPlorer_exe := GetModuleFileNameEx(_thisPID)

      ClipSaved := ClipboardAll
      Clipboard := ""

      Send_XYPlorer_Message(_thisID, "::copytext get('path', a);")

      ;	Check if valid folder first. Only add it if it is.
      If (ErrorLevel = 0) AND ValidFolder(clipboard) AND AddExplorerEntry(clipboard)
      {
        _entry := SetEntryIndex(clipboard)
        Menu ContextMenu, Add, %_entry%, FolderChoice
        Menu ContextMenu, Icon, %_entry%, %_XYPlorer_exe%, 0, 16
        _showMenu := 1
      }

      Send_XYPlorer_Message(_thisID, "::copytext get('path', i);")

      If (ErrorLevel = 0) AND ValidFolder(clipboard) AND AddExplorerEntry(clipboard)
      {
        _entry := SetEntryIndex(clipboard)
        Menu ContextMenu, Add, %_entry%, FolderChoice
        Menu ContextMenu, Icon, %_entry%, %_XYPlorer_exe%, 0, 16
        _showMenu := 1
      }

      Clipboard := ClipSaved
      ClipSaved := ""
    }

    ;---------------[ Directory Opus         ]--------------------------------------

    If ( _thisClass = "dopus.lister")
    {
      ;	Get Process information for Opus icon
      WinGet, _thisPID, PID, ahk_id %_thisID%
      _dopus_exe := GetModuleFileNameEx(_thisPID)

      If !(OpusInfo)
      {
        ;	Comma needs escaping: `,
        Run, "%_dopus_exe%\..\dopusrt.exe" /info "%_tempfile%"`, paths, , , $DUMMY

        Sleep, 100
        FileRead, OpusInfo, %_tempfile%

        Sleep, 20
        FileDelete, %_tempfile%
      }

      ;	Get active path of this lister (regex instead of XML library)
      RegExMatch(OpusInfo, "mO)^.*lister=\""" . _thisID . "\"".*tab_state=\""1\"".*\>(.*)\<\/path\>$", out)
      _thisFolder := out.Value(1)

      ;	Check if valid folder first. Only add it if it is.
      If ValidFolder(_thisFolder) AND AddExplorerEntry(_thisFolder)
      {
        _entry := SetEntryIndex(_thisFolder)
        Menu ContextMenu, Add, %_entry%, FolderChoice
        Menu ContextMenu, Icon, %_entry%, %_dopus_exe%, 0, 16
        _showMenu := 1
      }
      _thisFolder := ""

      ;	Get passive path of this lister
      RegExMatch(OpusInfo, "mO)^.*lister=\""" . _thisID . "\"".*tab_state=\""2\"".*\>(.*)\<\/path\>$", out)
      _thisFolder := out.Value(1)

      ;	Check if valid folder first. Only add it if it is.
      If ValidFolder(_thisFolder) AND AddExplorerEntry(_thisFolder)
      {
        _entry := SetEntryIndex(_thisFolder)
        Menu ContextMenu, Add, %_entry%, FolderChoice
        Menu ContextMenu, Icon, %_entry%, %_dopus_exe%, 0, 16
        _showMenu := 1
      }
      _thisFolder := ""
    }

    ;---------------[ File Explorer Folders ]----------------------------------------

    If (_thisClass = "CabinetWClass")
    {
      For _Exp in ComObjCreate("Shell.Application").Windows
      {
        try ; Attempts to execute code.
        {
          _checkID := _Exp.hwnd
        }
        catch e ; Handles the errors that Opus will generate.
        {
          ; Do nothing. Just ignore error.
          ; Proceed to the next Explorer instance
        }

        If (_Exp.Name = "Explorer") AND (_thisID = _Exp.Hwnd)
        {
          _thisExplorerPath := _Exp.Document.Folder.Self.Path
          ;	Check if valid folder first. Don't add it if not.
          If ValidFolder(_thisExplorerPath) AND AddExplorerEntry(_thisExplorerPath)
          {
            _entry := SetEntryIndex(_thisExplorerPath)
            Menu ContextMenu, Add, %_entry%, FolderChoice
            Menu ContextMenu, Icon, %_entry%, shell32.dll, 5, 16
            _showMenu := 1
          }
        }
      }
    }

  }	; end loop parsing all windows to find file manager folders

  ; check MRU folders, if INI setting is > 0
  if ($NrOfMRU > 0)
  {
    VarSetCapacity(_recent, 260*2, 0)
    DllCall("shell32\SHGetFolderPath", Ptr, 0, Int, 8, Ptr, 0, UInt, 0, Str, _recent)
    RegRead, _regDataList, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs\Folder, MRUListEx

    VarSetCapacity(_linkList, 100000*2)
    _linkList := ""

    Loop, % (StrLen(_regDataList)/8) - 1
    {
      _index := Format("{:i}", "0x" SubStr(_regDataList, (A_Index*8)-7, 2))
      RegRead, _regData, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs\Folder, % _index

      _temp := ""
      Loop, % Round(StrLen(_regData)/4)
      {
        _offset := (A_Index*4)-3
        _num := Format("{:i}", "0x" SubStr(_regData, _offset+2, 2) SubStr(_regData, _offset, 2))
        _temp .= (_num = 0) ? "|" : Chr(_num)
      }

      RegExMatch(_temp, "O)([^|]+\.lnk)(?=\|)", _match)
      _linkPath := _recent "\" _match.0
      FileGetShortcut, % _linkPath, _realPath
      FileGetTime, _temp, %_realPath%

      If FileExist(_realPath)
        _linkList .= _temp "`t" _realPath "`n"
    }

    Sort, _linkList, R
    _linkList := RegExReplace(_linkList, "(?<=^|`n)\d{14}`t")

    If ($NrOfEntries > 9)
      _ampersand := ""

    Loop, Parse, _linkList, `n
    {
      _hasFolder = FALSE
      Loop % $ExplorerFolder.Count()
      {
        If ($ExplorerFolder[A_Index-1] = A_LoopField)
        {
          _hasFolder = TRUE
          Break
        }
      }

      ; add MRU folder only if not already present as file explorer folder!
      If (!_folderList.HasKey(A_LoopField) AND !%_hasFolder% AND ValidFolder(A_LoopField))
      {
        _entry := SetEntryIndex(A_LoopField)
        Menu ContextMenu, Add, %_entry%, FolderChoice
        Menu ContextMenu, Icon, %_entry%, shell32.dll, -37219, 16
        _showMenu := 1
        _folderList.InsertAt(0, A_LoopField)
      }

    } Until _folderList.Count() = $NrOfMRU
  }

  ; Add link to JumpToFolder
  If ($JumpScriptName != "")
  {
    SplitPath, $JumpScriptName, , _dirName, , _fileName
    _fileName := _dirName . "\" . _fileName . ".ico"

    Menu ContextMenu, Add, &Jump to a different folder, % FunctionJumpToFolder
    Menu ContextMenu, Icon, &Jump to a different folder, %_fileName%
    _showMenu := 1
  }

  ;	All windows have been checked for valid File Manager folders
  ;	Most recent used filemanager will be shown on top.
  ;	If no folders found to be shown: no need to show menu ...

  If (_showMenu = 1 || $OpenMenu = 1)
  {
    ;---------------[ Settings ]----------------------------------------

    Menu ContextMenu, Add,
    Menu ContextMenu, Add, Settings for this dialog, Dummy
      Menu ContextMenu, disable, Settings for this dialog

    Menu ContextMenu, Add, &Allow AutoSwitch, AutoSwitch, Radio
    Menu ContextMenu, Add, Never &here, Never, Radio
    Menu ContextMenu, Add, &Not now, ThisMenu, Radio

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
      Menu ContextMenu, Check, &Not now
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
        AND (RegExMatch($LastMenuItem, "\\|&Jump|Settings") = 0)
        AND (ReDisplayMenu = 1)
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

  _folderList := {}
  ; $ExplorerFolder := {}
  $NrOfEntries := 0
  _entry := ""

  Return
}

;_____________________________________________________________________________
;
GetExeIcon(_WinID) ; reserved
;_____________________________________________________________________________
{
  _pid 		:= WinGet, _thisPID, PID, ahk_id %_thisID%
  _process 	:= DllCall("OpenProcess", "uint", 0x10|0x400, "int", false, "uint", _pid)

  If (ErrorLevel or _process = 0)
    Return

  _size = 255
  VarSetCapacity(_exe, _size)

  result := DllCall("psapi.dll\GetModuleFileNameExW", "uint", _process, "uint", 0, "str", _exe, "uint", _size)
  DllCall("CloseHandle", _process)

  Return, _exe
}

;_____________________________________________________________________________
;
SetEntryIndex(_folder) ; reserved
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
AddExplorerEntry(_entry) ; reserved
;_____________________________________________________________________________
;
{
  global $ExplorerFolder
  _hasFolder = FALSE

  Loop % $ExplorerFolder.Count()
  {
    If ($ExplorerFolder[A_Index-1] = _entry)
    {
      _hasFolder = TRUE
      Break
    }
  }
  If !%_hasFolder%
    $ExplorerFolder.InsertAt(0, _entry)

  Return !%_hasFolder%
}

;_____________________________________________________________________________
;
FolderChoice:
;_____________________________________________________________________________
;
  global $DialogType, $WinID

  RegExMatch(A_ThisMenuItem, "i)([a-zA-Z]:\\|\\\\).*", _menuItem)

  If ValidFolder(_menuItem)
  {
    ;	FeedDialog($WinID, $FolderPath)
    FeedDialog%$DialogType%($WinID, _menuItem)
  }

Return

;_____________________________________________________________________________
;
AutoSwitch:
;_____________________________________________________________________________
;
  global $DialogAction, $DialogType, $INI, $FingerPrint, $WinID, $LastMenuItem

  IniWrite, 1, %$INI%, Dialogs, %$FingerPrint%
  $DialogAction := 1
  $FolderPath := Get_Zfolder($WinID)

  If ValidFolder($FolderPath)
  {
    ;	FeedDialog($WinID, $FolderPath)
    FeedDialog%$DialogType%($WinID, $FolderPath)
  }

  $FolderPath := ""
  $LastMenuItem := A_ThisMenuItem

Return

;_____________________________________________________________________________
;
Never:
;_____________________________________________________________________________
;
  global $DialogAction, $INI, $FingerPrint, $LastMenuItem

  IniWrite, 0, %$INI%, Dialogs, %$FingerPrint%
  $DialogAction := 0
  $LastMenuItem := A_ThisMenuItem

Return

;_____________________________________________________________________________
;
ThisMenu:
;_____________________________________________________________________________
;
  global $DialogAction, $INI, $FingerPrint, $LastMenuItem

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

    If AutoSwitch doesn't work as expected, the application might have
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

      If (NOT level_2) AND ((this_class = "TTOTAL_CMD") OR (this_class = "CabinetWClass") OR (this_class = "ThunderRT6FormDC"))
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

      If ValidFolder($FolderPath)
      {
        ;	FeedDialog($WinID, $FolderPath)
        FeedDialog%$DialogType%($WinID, $FolderPath)
      }
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
ValidFolder(_thisPath_)
;_____________________________________________________________________________
;
{
  ;	Prepared for extra checks
  ;	If ( _thisPath_ != "") {
  If (_thisPath_ != "" AND (StrLen(_thisPath_) < 259))
  {
    If InStr(FileExist(_thisPath_), "D")
      Return TRUE
    Else
      Return FALSE
  }
  Else
  {
    Return FALSE
  }
}

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

	If (next_class = "TTOTAL_CMD") 							;	Total Commander
	{
	  ClipSaved := ClipboardAll
	  Clipboard := ""

	  SendMessage 1075, %cm_CopySrcPathToClip%, 0, , ahk_id %next_id%

	  If (ErrorLevel = 0)
	  {
	    $ZFolder := clipboard
	    Clipboard	:= ClipSaved
	  }
	}

	If (next_class = "ThunderRT6FormDC") 							;	XYPlorer
	{
	  ClipSaved := ClipboardAll
	  Clipboard := ""

	  Send_XYPlorer_Message(next_id, "::copytext get('path', a);")
	  ClipWait, 0

	  $ZFolder := clipboard
	  Clipboard	:= ClipSaved
	}

	If (next_class = "CabinetWClass") 						;	File Explorer
	{
	  For $Exp in ComObjCreate("Shell.Application").Windows
	  {
	    Try ; Attempts to execute code.
	    {
	      _checkID := $Exp.hwnd
	    }
	    Catch e ; Handles the errors that Opus will generate.
	    {
	      ; Do nothing. Just ignore error.
	      ; Proceed to the next Explorer instance
	    }

	    ;		If ($Exp.hwnd = next_id)
	    If (next_id = _checkID)
	    {
	      $ZFolder := $Exp.Document.Folder.Self.Path
	      Break
	    }
	  }
	}

  If (next_class = "dopus.lister")							;	Directory Opus
  {
    ;	Get dopus.exe loction
    WinGet, _thisPID, PID, ahk_id %next_id%
    _dopus_exe := GetModuleFileNameEx(_thisPID)

    ;	Get lister info
    Run, "%_dopus_exe%\..\dopusrt.exe" /info "%_tempfile%"`, paths, , , $DUMMY

    Sleep, 100
    FileRead, OpusInfo, %_tempfile%

    Sleep, 20
    FileDelete, %_tempfile%

    ;	Get active path of the most recent lister
    RegExMatch(OpusInfo, "mO)^.*lister=\""" . next_id . "\"".*tab_state=\""1\"".*\>(.*)\<\/path\>$", out)
    $ZFolder := out.Value(1)
    ;		MsgBox Active Z-folder = [%$ZFolder%]

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
Send_XYPlorer_Message(xyHwnd, message)
;_____________________________________________________________________________
;

{
  size := StrLen(message)

  If !(A_IsUnicode)
  {
    VarSetCapacity(data, size * 2, 0)
    StrPut(message, &data, "UTF-16")
  }
  Else
  {
    data := message
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
  global $OpenMenu, $NrOfMRU, $GuiColor, $MenuColor, $WinX, $WinY, $WinWidth, $WinHeight, $LastMenuItem, $FromSettings, $FolderNum

  $LastMenuItem := A_ThisMenuItem
  $FromSettings := TRUE
  ;https://www.autohotkey.com/board/topic/6768-how-to-preselect-a-group-of-radiobuttons-solved-for-now/
  C0 := 0
  C1 := 0
  C%$FolderNum% := 1

  ; show at menu position
  Xpos := $WinX
  Ypos := $WinY + 100

  Gui, Add, Button, x30 y10 w120 gStartDebug, Debug &this dialog
  Gui, Add, Button, x+20 w120 gResetToDefaults, &Reset to defaults

  Gui, Add, CheckBox, x30 y+20 vOpenMenuGUI, &Always open Menu
  Gui, Add, CheckBox, vReDisplayMenuGUI, &Show Menu after leaving settings

  Gui, Add, Text, y+20, MRU &folder entries (0-10)
  Gui, Add, Edit, x230 yp w20 vNrOfMruGUI, %$NrOfMRU%

  Gui, Add, Text, x30, &Menu backgroud color (HEX)
  Gui, Add, Edit, x230 yp w60 vMenuColorGUI, %$MenuColor%

  Gui, Add, Text, x30, &Dialogs background color (HEX)
  Gui, Add, Edit, x230 yp w60 vGuiColorGUI, %$GuiColor%

  Gui, Add, Radio, x30 y+15 vFolderNumGUI Checked%C0%, &No folder numbering
  Gui, Add, Radio, Checked%C1%, Folder n&umbers with shortcuts 1-0 (10)

  ; hidden default button used for accepting {Enter} to leave GUI
  Gui, Add, Button, x60 y255 w90 Default gOK, &OK
  Gui, Add, Button, x+20 w90 Cancel gCancel, &Cancel

  GuiControl, , OpenMenuGUI, %$OpenMenu%
  GuiControl, , ReDisplayMenuGUI, %$ReDisplayMenu%

  Gui, Color, %$GuiColor%
  Gui, Show, x%Xpos% y%Ypos% w320 h300, QuickSwitch Settings

Return

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
  ; reset AND rewrite INI to default values
  SetDefaultValues(FALSE)
  DisplayDefaultValues()
  ; Gui, Destroy

Return

;_____________________________________________________________________________
;
DisplayDefaultValues()
;_____________________________________________________________________________
;
{
  global $GuiColor, $MenuColor, $NrOfMRU, $OpenMenu, $ReDisplayMenu, $FolderNum

  GuiControl, , OpenMenuGUI, %$OpenMenu%
  GuiControl, , ReDisplayMenuGUI, %$ReDisplayMenu%
  GuiControl, , FolderNumGUI, %$FolderNum%
  GuiControl, , NrOfMruGUI, %$NrOfMRU%
  GuiControl, , GuiColorGUI, %$GuiColor%
  GuiControl, , MenuColorGUI, %$MenuColor%

  Return
}
;_____________________________________________________________________________

;_____________________________________________________________________________
;
OK:
;_____________________________________________________________________________
;
  global $GuiColor, $MenuColor, $OpenMenu, $ReDisplayMenu, $FolderNum

  ; read GUI values
  Gui, Submit
  GuiControlGet, _OpenMenu, , OpenMenuGUI
  GuiControlGet, _ReDisplayMenu, , ReDisplayMenuGUI
  GuiControlGet, _NrOfMRU, , NrOfMruGUI
  GuiControlGet, _GuiColor, , GuiColorGUI
  GuiControlGet, _MenuColor, , MenuColorGUI
  _FolderNum := FolderNumGUI - 1

  ; check and set them / write them to INI if valid
  $OpenMenu := CheckMenuInput(_OpenMenu, $OpenMenu, "AlwaysOpenMenu", 1)
  $ReDisplayMenu := CheckMenuInput(_ReDisplayMenu, $ReDisplayMenu, "ReDisplayMenu", 1)
  $FolderNum := CheckMenuInput(_FolderNum, $FolderNum, "ShowFolderNumbers", 1)
  CheckMRUInput(_NrOfMRU)
  $GuiColor := CheckColor(_GuiColor, $GuiColor, "GuiBGColor")
  $MenuColor := CheckColor(_MenuColor, $MenuColor, "MenuBGColor")

  Gui, Destroy

Return

;_____________________________________________________________________________
;
CheckColor(_iniColor, _defColor, _iniName)
;_____________________________________________________________________________
;
{
  global $INI

  _matchPos := RegExMatch(_iniColor, "i)[a-f0-9]{6}$")

  If (_matchPos > 0)
  {
    _defColor := SubStr(_iniColor, _matchPos)
    IniWrite, %_defColor%, %$INI%, Colors, %_iniName%
  }

  Return _defColor
}

;_____________________________________________________________________________
;
CheckMRUInput(_inputNr)
;_____________________________________________________________________________
;
{
  global $NrOfMRU, $INI

  If _inputNr Is Integer
  {
    If _inputNr Between 0 And 10
      $NrOfMRU := _inputNr
    Else If (_inputNr < 0)
      $NrOfMRU = 0
    Else If ($NrOfMRU > 10)
      $NrOfMRU = 10

    IniWrite, %$NrOfMRU%, %$INI%, Menu, NrOfMRUFolders
  }
  Else
  {
    $NrOfMRU = 5
    IniWrite, 5, %$INI%, Menu, NrOfMRUFolders
  }

  Return
}

;_____________________________________________________________________________
;
CheckMenuInput(_inputNr, _defVal, _iniName, _max)
;_____________________________________________________________________________
;
{
  global $INI

  _retVal := _inputNr

  If _inputNr Is Integer
  {
    If _inputNr Not Between 0 And _max
      _retVal := _defVal

    IniWrite, %_retVal%, %$INI%, Menu, %_iniName%
  }
  Else
  {
    _retVal := 0
    IniWrite, 0, %$INI%, Menu, %_iniName%
  }

  Return _retVal
}

;_____________________________________________________________________________
;
; AlwaysOpenMenu:
; ;_____________________________________________________________________________
; ;
;   global $OpenMenu, $INI

;   GuiControlGet, $OpenMenu, , OpenMenuGUI
;   Gui, Destroy

;   IniWrite, %$OpenMenu%, %$INI%, Menu, AlwaysOpenMenu

; Return

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

    _ctrlHandle := ""
    _ctrlText := ""
    _parentHandle := ""
    _X := ""
    _Y := ""
    _Width := ""
    _Height := ""
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
    Msgbox Can't create %_fileName%
  }

  ;	Clean up
  _fileName := ""
  _line := ""
  _col1 := ""
  _col2 := ""
  _col3 := ""
  _col4 := ""
  _col5 := ""
  _col6 := ""
  _col7 := ""
  _col8 := ""

;_____________________________________________________________________________
CancelLV:
;_____________________________________________________________________________
  LV_Delete()
  GUI, Destroy

Return

/*
============================================================================
*/