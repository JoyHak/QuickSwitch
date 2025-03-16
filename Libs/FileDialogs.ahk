/* 
 There are a few different types of possible dialogues, and each one has its own function. 
 There's also a function called FeedDialogFunc() 
 Depending on the current dialogue, it finds the right function from this file (FuncObj). 
 You can FuncObj.call(id, folder) anywhere.
*/

FeedDialogGENERAL(_thisID, _thisFOLDER)
{
  global DialogType

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

        If (_editAddress == _thisFOLDER)
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
  global DialogType

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

  } Until _Focus == "SysListView321"

  ControlSend SysListView321, {Home}, ahk_id %_thisID%

  Loop, 100
  {
    Sleep, 10
    ControlSend SysListView321, ^{Space}, ahk_id %_thisID%
    ControlGet, _Focus, List, Selected, SysListView321, ahk_id %_thisID%

  } Until !_Focus

  Loop, 20
  {
    Sleep, 10
    ControlSetText, Edit1, %_thisFOLDER%, ahk_id %_thisID%
    ControlGetText, _Edit1, Edit1, ahk_id %_thisID%

    If (_Edit1 == _thisFOLDER)
    {
      _FolderSet := true
    }

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

      If (_2thisCONTROLTEXT == _oldText)
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
  global DialogType

  WinActivate, ahk_id %_thisID%
  ;	Sleep, 50

  ;	Read the current text in the "File Name:" box (= OldText)
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

    If (_Edit1 == _thisFOLDER)
      _FolderSet := true

  } Until _FolderSet

  If _FolderSet
  {
    Sleep, 20
    ControlFocus Edit1, ahk_id %_thisID%
    ControlSend Edit1, {Enter}, ahk_id %_thisID%

    ; Restore  original filename / make empty in case of previous folder
    Sleep, 15
    ControlFocus Edit1, ahk_id %_thisID%
    Sleep, 20

    Loop, 5
    {
      ControlSetText, Edit1, %_oldText%, ahk_id %_thisID%		; set
      Sleep, 15
      ControlGetText, _2thisCONTROLTEXT, Edit1, ahk_id %_thisID%		; check

      If (_2thisCONTROLTEXT == _oldText)
        Break
    }
  }

  Return
}

;_____________________________________________________________________________
;
FeedDialogFunc(_DialogID)
;_____________________________________________________________________________
;
{
  ;	Detection of a File dialog. Returns FuncObj / false

  ;	Only consider this dialog a possible file-dialog when:
  ;	(SysListView321 and ToolbarWindow321) or (DirectUIHWND1 and ToolbarWindow321) controls detected
  ;	First is for Notepad++; second for all other filedialogs
  ; dw: (SysListView321 and SysHeader321 and Edit1) is for some AutoDesk products (e.g. AutoCAD, Revit, Navisworks)
  ; which need a delay loop to switch correctly between the dialog components!
  
  WinGet, _controlList, ControlList, ahk_id %_DialogID%

  Loop, Parse, _controlList, `n
  {
    If (A_LoopField == "SysListView321")
      _SysListView321 := 1
    Else If (A_LoopField == "SysHeader321")
      _SysHeader321 := 1
    Else If (A_LoopField == "ToolbarWindow321")
      _ToolbarWindow321 := 1
    Else If (A_LoopField == "DirectUIHWND1")
      _DirectUIHWND1 := 1
    Else If (A_LoopField == "Edit1")
      _Edit1 := 1
    Else If (A_LoopField == "SysTreeView321")
      _SysTreeView321 := 1
  }

  If (_DirectUIHWND1 and _ToolbarWindow321 and _Edit1)
    Return Func("FeedDialogGENERAL")

  Else If (_SysListView321 and _ToolbarWindow321 and _Edit1 and _SysHeader321)
    Return Func("FeedDialogSYSTREEVIEW")

  Else If (_SysListView321 and _ToolbarWindow321 and _Edit1)
    Return Func("FeedDialogSYSLISTVIEW")

  Else If (_SysListView321 and _SysHeader321 and _Edit1)
    Return Func("FeedDialogSYSLISTVIEW")

  Else If (_SysTreeView321 and _Edit1)
    Return Func("FeedDialogSYSTREEVIEW")

  Else
    Return false
}