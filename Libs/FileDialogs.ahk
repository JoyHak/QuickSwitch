/* 
 There are a few different types of possible dialogues, and each one has its own function. 
 There's also a function called FeedDialogFunc() 
 Depending on the current dialogue, it finds the right function from this file (FuncObj). 
 You can FuncObj.call(id, folder) anywhere.
*/

FeedDialogGENERAL(ByRef _thisID, _path) {
    global DialogType

    WinActivate, ahk_id %_thisID%
    Sleep, 50

    ; Focus Edit1
    ControlFocus Edit1, ahk_id %_thisID%
    WinGet, ActivecontrolList, ControlList, ahk_id %_thisID%

    Loop, Parse, ActivecontrolList, `n  
    {       ; which addressbar and "Enter" controls to use   
        if InStr(A_LoopField, "ToolbarWindow32") {
            ControlGet, _ctrlHandle, Hwnd, , %A_LoopField%, ahk_id %_thisID%
            _parentHandle := DllCall("GetParent", "Ptr", _ctrlHandle)
            WinGetClass, _parentClass, ahk_id %_parentHandle%

            if InStr(_parentClass, "Breadcrumb Parent")
                _UseToolbar := A_LoopField

            if Instr(_parentClass, "msctls_progress32")
                _EnterToolbar := A_LoopField
        }

        ; Start next round clean
        _ctrlHandle     := ""
        _parentHandle   := ""
        _parentClass    := ""

    }
    
    _FolderSet := false
    if (_UseToolbar and _EnterToolbar) {
        Loop, 5 {
            SendInput ^l
            Sleep, 100

            ; Check and insert folder
            ControlGetFocus, _ctrlFocus, A

            if ((_ctrlFocus != "Edit1") and InStr(_ctrlFocus, "Edit")) {
                Control, EditPaste, %_path%, %_ctrlFocus%, A
                ControlGetText, _editAddress, %_ctrlFocus%, ahk_id %_thisID%
                
                if (_editAddress == _path) {
                    _FolderSet := true
                    Sleep, 15
                }
            }

            ; Start next round clean
            _ctrlFocus    := ""
            _editAddress  := ""

        } Until _FolderSet

        if (_FolderSet) {
            ; Click control to "execute" new folder
            ControlClick, %_EnterToolbar%, ahk_id %_thisID%
            ; Focus file name
            Sleep, 25
            ControlFocus Edit1, ahk_id %_thisID%
        }
    } else {
        MsgBox This type of dialog can not be handled (yet).`nPlease report it!
    }    

    Return
}

;_____________________________________________________________________________
;
FeedDialogSYSLISTVIEW(ByRef _WinID, _path) {
;_____________________________________________________________________________

    global DialogType

    WinActivate, ahk_id %_thisID%
    ControlGetText _oldText, Edit1, ahk_id %_thisID%
    Sleep, 20

    ; Make sure there exactly one slash at the end.
    _path := RTrim( _path , "\")
    _path := _path . "\"
    
    ; Make sure no element is preselected in listview, 
    ; it would always be used later on if you continue with {Enter}!
    Sleep, 10
    Loop, 100 {
        Sleep, 10
        ControlFocus SysListView321, ahk_id %_thisID%
        ControlGetFocus, _Focus, ahk_id %_thisID%

    } Until _Focus == "SysListView321"
    ControlSend SysListView321, {Home}, ahk_id %_thisID%

    Loop, 100 {
        Sleep, 10 
        ControlSend SysListView321, ^{Space}, ahk_id %_thisID%
        ControlGet, _Focus, List, Selected, SysListView321, ahk_id %_thisID%

    } Until !_Focus

    Loop, 20 {
        Sleep, 10
        ControlSetText, Edit1, %_path%, ahk_id %_thisID%
        ControlGetText, _Edit1, Edit1, ahk_id %_thisID%

        if (_Edit1 == _path)        
            _FolderSet := true

    } Until _FolderSet

    if _FolderSet {
        Sleep, 20
        ControlFocus Edit1, ahk_id %_thisID% ControlSend Edit1, {Enter}, ahk_id %_thisID%

        ; Restore original filename / make empty in case of previous folder
        Sleep, 15
        ControlFocus Edit1, ahk_id %_thisID%
        Sleep, 20

        Loop, 5 {
            ControlSetText, Edit1, %_oldText%, ahk_id %_thisID%             ; set
            Sleep, 15
            ControlGetText, _2thisCONTROLTEXT, Edit1, ahk_id %_thisID%      ; check

            if (_2thisCONTROLTEXT == _oldText)
                Break
        }
    }

    Return
}

;_____________________________________________________________________________
;
FeedDialogSYSTREEVIEW(ByRef _WinID, _path) {
;_____________________________________________________________________________

    global DialogType

    WinActivate, ahk_id %_thisID%

    ; Read the current text in the "File Name:" box (= OldText)
    ControlGetText _oldText, Edit1, ahk_id %_thisID%
    Sleep, 20

    ; Make sure there exactly one slash at the end.
    _path := RTrim(_path , "\")
    _path := _path . "\"

    Loop, 20 {
        Sleep, 10
        ControlSetText, Edit1, %_path%, ahk_id %_thisID%
        ControlGetText, _Edit1, Edit1, ahk_id %_thisID%

        if (_Edit1 == _path)
            _FolderSet := true

    } Until _FolderSet

    if _FolderSet {
        Sleep, 20
        ControlFocus Edit1, ahk_id %_thisID% ControlSend Edit1, {Enter}, ahk_id %_thisID%

        ; Restore original filename / make empty in case of previous folder
        Sleep, 15
        ControlFocus Edit1, ahk_id %_thisID%
        Sleep, 20

        Loop, 5 {
            ControlSetText, Edit1, %_oldText%, ahk_id %_thisID%             ; set
            Sleep, 15
            ControlGetText, _2thisCONTROLTEXT, Edit1, ahk_id %_thisID%      ; check

            if (_2thisCONTROLTEXT == _oldText)
                Break
        
        }
    }

    Return
}

;_____________________________________________________________________________
;
FeedDialogFunc(ByRef _DialogID) {
;_____________________________________________________________________________

    ; Detection of a File dialog. Returns FuncObj / false

    ; Only consider this dialog a possible file-dialog when:
    ; (SysListView321 and ToolbarWindow321) or (DirectUIHWND1 and ToolbarWindow321) controls detected
    ; First is for Notepad++; second for all other filedialogs
    ; dw: (SysListView321 and SysHeader321 and Edit1) is for some AutoDesk products (e.g. AutoCAD, Revit, Navisworks)
    ; which need a delay loop to switch correctly between the dialog components!
    
    WinGet, _controlList, ControlList, ahk_id %_DialogID%

    _SysListView321 := _SysHeader321 := _ToolbarWindow321 := _DirectUIHWND1 := _Edit1 := _SysTreeView321 := 0
    
    Loop, Parse, _controlList, `n 
    {
    if (A_LoopField == "SysListView321")
        _SysListView321 := 1
    else if (A_LoopField == "SysHeader321")
        _SysHeader321 := 1
    else if (A_LoopField == "ToolbarWindow321")
        _ToolbarWindow321 := 1
    else if (A_LoopField == "DirectUIHWND1")
        _DirectUIHWND1 := 1
    else if (A_LoopField == "Edit1")
        _Edit1 := 1
    else if (A_LoopField == "SysTreeView321")
        _SysTreeView321 := 1
    }
    
    if (_DirectUIHWND1 and _ToolbarWindow321 and _Edit1)
    Return Func("FeedDialogGENERAL")
    
    else if (_SysListView321 and _ToolbarWindow321 and _Edit1 and _SysHeader321)
    Return Func("FeedDialogSYSTREEVIEW")
    
    else if (_SysListView321 and _ToolbarWindow321 and _Edit1)
    Return Func("FeedDialogSYSLISTVIEW")
    
    else if (_SysListView321 and _SysHeader321 and _Edit1)
    Return Func("FeedDialogSYSLISTVIEW")
    
    else if (_SysTreeView321 and _Edit1)
    Return Func("FeedDialogSYSTREEVIEW")
    
    else
    Return false
}