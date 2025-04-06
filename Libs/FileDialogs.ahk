/*
    There are a few different types of possible dialogues, and each one has its own function.
    There's also a function called GetFileDialog()
    It returns the FuncObj to call it later and feed the current dialogue.
*/

FeedDialogGENERAL(ByRef winId, ByRef path) {
    WinActivate, ahk_id %winId%
    Sleep, 50
    
    ControlFocus Edit1, ahk_id %winId%
    
    static ActiveControlList
    WinGet, ActiveControlList, ControlList, ahk_id %winId%
    
    Loop, Parse, ActivecontrolList, `n
    {
        if InStr(A_LoopField, "ToolbarWindow32") {
            ControlGet, _ctrlHandle, Hwnd, , %A_LoopField%, ahk_id %winId%
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
                Control, EditPaste, %path%, %_ctrlFocus%, A
                ControlGetText, _editAddress, %_ctrlFocus%, ahk_id %winId%

                if (_editAddress == path) {
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
            ControlClick, %_enterToolbar%, ahk_id %winId%
            ; Focus file name
            Sleep, 25
            ControlFocus Edit1, ahk_id %winId%
        }
    } else {
        MsgBox This type of dialog can not be handled (yet).`nPlease report it!
        LogError(Exception("This type of dialog can not be handled!", "file dialog", "`'Breadcrumb Parent`' and `'msctls_progress32`' controls not found"))
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogSYSLISTVIEW(ByRef winId, ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    WinActivate, ahk_id %winId%
    ControlGetText _editOld, Edit1, ahk_id %winId%

    ; Make sure there exactly one slash at the end.
    path := RTrim(path , "\") . "\"

    ; Make sure no element is preselected in listview,
    ; it would always be used later on if you continue with {Enter}!
    Loop, 100 {
        Sleep, 10
        ControlFocus SysListView321, ahk_id %winId%
        ControlGetFocus, _Focus, ahk_id %winId%

    } Until _Focus == "SysListView321"
    ControlSend SysListView321, {Home}, ahk_id %winId%

    Loop, 100 {
        Sleep, 10
        ControlSend SysListView321, ^{Space}, ahk_id %winId%
        ControlGet, _Focus, List, Selected, SysListView321, ahk_id %winId%

    } Until !_Focus

    _pathSet := false
    Loop, 20 {
        Sleep, 10
        ControlSetText, Edit1, %path%, ahk_id %winId%
        ControlGetText, _Edit1, Edit1, ahk_id %winId%

        if (_Edit1 == path)
            _pathSet := true

    } Until _pathSet

    if _pathSet {
        Sleep, 20
        ControlFocus Edit1, ahk_id %winId%
        ControlSend Edit1, {Enter}, ahk_id %winId%

        ; Restore original filename / make empty in case of previous path
        Sleep, 15
        ControlFocus Edit1, ahk_id %winId%
        Sleep, 20

        Loop, 5 {
            ControlSetText, Edit1, %_editOld%, ahk_id %winId%        ; set
            Sleep, 15
            ControlGetText, _editContent, Edit1, ahk_id %winId%      ; check

            if (_editContent == _editOld)
                Break
        }
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogSYSTREEVIEW(ByRef winId, ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    WinActivate, ahk_id %winId%

    ; Read the current text in the "File Name:" box (= OldText)
    ControlGetText _editOld, Edit1, ahk_id %winId%
    Sleep, 20

    ; Make sure there exactly one slash at the end.
    path := RTrim(path , "\") . "\"
    _pathSet := false

    Loop, 20 {
        Sleep, 10
        ControlSetText, Edit1, %path%, ahk_id %winId%
        ControlGetText, _Edit1, Edit1, ahk_id %winId%

        if (_Edit1 == path)
            _pathSet := true

    } Until _pathSet

    if _pathSet {
        Sleep, 20
        ControlFocus Edit1, ahk_id %winId%
        ControlSend Edit1, {Enter}, ahk_id %winId%

        ; Restore original filename / make empty in case of previous path
        Sleep, 15
        ControlFocus Edit1, ahk_id %winId%
        Sleep, 20

        Loop, 5 {
            ControlSetText, Edit1, %_editOld%, ahk_id %winId%        ; set
            Sleep, 15
            ControlGetText, _editContent, Edit1, ahk_id %winId%      ; check

            if (_editContent == _editOld)
                Break
        }
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetFileDialog(ByRef dialogId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Detection of a File dialog. 
    ; Returns FuncObj if required controls found,
    ; otherwise returns false
    
    try {
        WinGet, _controlList, ControlList, ahk_id %dialogId%
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
            return Func("FeedDialogGENERAL")
        else if (_flag & 1 && _flag & 2 && _flag & 8 && _flag & 16)
            return Func("FeedDialogSYSTREEVIEW")
        else if (_flag & 1 && _flag & 2 && _flag & 16)
            return Func("FeedDialogSYSLISTVIEW")
        else if (_flag & 1 && _flag & 2 && _flag & 8)
            return Func("FeedDialogSYSLISTVIEW")

    } catch _error {
        LogError(_error)
    }
    return false
}