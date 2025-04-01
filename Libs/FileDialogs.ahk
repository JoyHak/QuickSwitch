/*
    There are a few different types of possible dialogues, and each one has its own function.
    There's also a function called GetFileDialog()
    It returns the FuncObj to call it later and feed the current dialogue.
*/

FeedDialogGENERAL(ByRef _WinID, _path) {
    WinActivate, ahk_id %_WinID%
    Sleep, 50

    ControlFocus Edit1, ahk_id %_WinID%
    WinGet, ActivecontrolList, ControlList, ahk_id %_WinID%

    Loop, Parse, ActivecontrolList, `n
    {
        if InStr(A_LoopField, "ToolbarWindow32") {
            ControlGet, _ctrlHandle, Hwnd, , %A_LoopField%, ahk_id %_WinID%
            _parentHandle := DllCall("GetParent", "Ptr", _ctrlHandle)
            WinGetClass, _parentClass, ahk_id %_parentHandle%

            if InStr(_parentClass, "Breadcrumb Parent")
                _useToolbar := A_LoopField

            if Instr(_parentClass, "msctls_progress32")
                _enterToolbar := A_LoopField
        }
        ; Start next round clean
        _ctrlHandle     := ""
        _parentHandle   := ""
        _parentClass    := ""
    }

    _pathSet := false
    if (_useToolbar and _enterToolbar) {
        Loop, 5 {
            SendEvent ^l
            Sleep, 100

            ; Check and insert path
            ControlGetFocus, _ctrlFocus, A

            if ((_ctrlFocus != "Edit1") and InStr(_ctrlFocus, "Edit")) {
                Control, EditPaste, %_path%, %_ctrlFocus%, A
                ControlGetText, _editAddress, %_ctrlFocus%, ahk_id %_WinID%

                if (_editAddress == _path) {
                    _pathSet := true
                    Sleep, 15
                }
            }

            ; Start next round clean
            _ctrlFocus    := ""
            _editAddress  := ""

        } Until _pathSet

        if (_pathSet) {
            ; Click control to "execute" new path
            ControlClick, %_enterToolbar%, ahk_id %_WinID%
            ; Focus file name
            Sleep, 25
            ControlFocus Edit1, ahk_id %_WinID%
        }
    } else {
        MsgBox This type of dialog can not be handled (yet).`nPlease report it!
        LogError(Exception("File dialog", "This type of dialog can not be handled!", "`'Breadcrumb Parent`' and `'msctls_progress32`' controls not found"))
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogSYSLISTVIEW(ByRef _WinID, _path) {
;─────────────────────────────────────────────────────────────────────────────
    WinActivate, ahk_id %_WinID%
    ControlGetText _editOld, Edit1, ahk_id %_WinID%
    Sleep, 20

    ; Make sure there exactly one slash at the end.
    _path := RTrim(_path , "\")
    _path := _path . "\"

    ; Make sure no element is preselected in listview,
    ; it would always be used later on if you continue with {Enter}!
    Sleep, 10
    Loop, 100 {
        Sleep, 10
        ControlFocus SysListView321, ahk_id %_WinID%
        ControlGetFocus, _Focus, ahk_id %_WinID%

    } Until _Focus == "SysListView321"
    ControlSend SysListView321, {Home}, ahk_id %_WinID%

    Loop, 100 {
        Sleep, 10
        ControlSend SysListView321, ^{Space}, ahk_id %_WinID%
        ControlGet, _Focus, List, Selected, SysListView321, ahk_id %_WinID%

    } Until !_Focus

    _pathSet := false
    Loop, 20 {
        Sleep, 10
        ControlSetText, Edit1, %_path%, ahk_id %_WinID%
        ControlGetText, _Edit1, Edit1, ahk_id %_WinID%

        if (_Edit1 == _path)
            _pathSet := true

    } Until _pathSet

    if _pathSet {
        Sleep, 20
        ControlFocus Edit1, ahk_id %_WinID%
        ControlSend Edit1, {Enter}, ahk_id %_WinID%

        ; Restore original filename / make empty in case of previous path
        Sleep, 15
        ControlFocus Edit1, ahk_id %_WinID%
        Sleep, 20

        Loop, 5 {
            ControlSetText, Edit1, %_editOld%, ahk_id %_WinID%        ; set
            Sleep, 15
            ControlGetText, _editContent, Edit1, ahk_id %_WinID%      ; check

            if (_editContent == _editOld)
                Break
        }
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogSYSTREEVIEW(ByRef _WinID, _path) {
;─────────────────────────────────────────────────────────────────────────────
    WinActivate, ahk_id %_WinID%

    ; Read the current text in the "File Name:" box (= OldText)
    ControlGetText _editOld, Edit1, ahk_id %_WinID%
    Sleep, 20

    ; Make sure there exactly one slash at the end.
    _path := RTrim(_path , "\")
    _path := _path . "\"
    _pathSet := false

    Loop, 20 {
        Sleep, 10
        ControlSetText, Edit1, %_path%, ahk_id %_WinID%
        ControlGetText, _Edit1, Edit1, ahk_id %_WinID%

        if (_Edit1 == _path)
            _pathSet := true

    } Until _pathSet

    if _pathSet {
        Sleep, 20
        ControlFocus Edit1, ahk_id %_WinID%
        ControlSend Edit1, {Enter}, ahk_id %_WinID%

        ; Restore original filename / make empty in case of previous path
        Sleep, 15
        ControlFocus Edit1, ahk_id %_WinID%
        Sleep, 20

        Loop, 5 {
            ControlSetText, Edit1, %_editOld%, ahk_id %_WinID%        ; set
            Sleep, 15
            ControlGetText, _editContent, Edit1, ahk_id %_WinID%      ; check

            if (_editContent == _editOld)
                Break
        }
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetFileDialog(ByRef _DialogID) {
;─────────────────────────────────────────────────────────────────────────────
    ; Detection of a File dialog. 
    ; Returns FuncObj if required controls found,
    ; otherwise returns false
    
    try {
        WinGet, _controlList, ControlList, ahk_id %_DialogID%
        _flag := 0

        Loop, Parse, _controlList, `n
        {
            switch A_LoopField {
                case "Edit1": 
                    _flag |= 1
                case "SysListView321": 
                    _flag |= 2
                case "SysTreeView321": 
                    _flag |= 4
                case "SysHeader321": 
                    _flag |= 8
                case "ToolbarWindow321": 
                    _flag |= 16
                case "DirectUIHWND1": 
                    _flag |= 32
            }
        }
        
        if (_flag & 1 && _flag & 16 && _flag & 32)
            Return Func("FeedDialogGENERAL")
        else if (_flag & 1 && _flag & 2 && _flag & 8 && _flag & 16)
            Return Func("FeedDialogSYSTREEVIEW")
        else if (_flag & 1 && _flag & 2 && _flag & 16)
            Return Func("FeedDialogSYSLISTVIEW")
        else if (_flag & 1 && _flag & 2 && _flag & 8)
            Return Func("FeedDialogSYSLISTVIEW")

    } catch _error {
        LogError(_error)
    }
    Return false
}