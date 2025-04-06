/*
    There are a few different types of possible dialogues, and each one has its own function.
    There's also a function called GetFileDialog()
    It returns the FuncObj to call it later and feed the current dialogue.
*/

FeedDialogSYSLISTVIEW(ByRef winId, ByRef path) {
    WinActivate, ahk_id %winId%
    ControlGetText _editOld, Edit1, ahk_id %winId%

    ; Make sure there exactly one slash at the end.
    path := RTrim(path , "\") . "\"

    ; Make sure no element is preselected in listview,
    ; it would always be used later on if you continue with {Enter}!
    Loop, 100 {
        Sleep, 10
        ControlFocus SysListView321, ahk_id %winId%
        ControlGetFocus, _focus, ahk_id %winId%

    } Until (_focus == "SysListView321")
    ControlSend SysListView321, {Home}, ahk_id %winId%

    Loop, 100 {
        Sleep, 10
        ControlSend SysListView321, ^{Space}, ahk_id %winId%
        ControlGet, _focus, List, Selected, SysListView321, ahk_id %winId%

    } Until !_focus

    _pathSet := false
    Loop, 20 {
        Sleep, 10
        ControlSetText, Edit1, %path%, ahk_id %winId%
        ControlGetText, _Edit1, Edit1, ahk_id %winId%

        if (_Edit1 == path) {
            _pathSet := true
            break
        }
    }

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

    ; Read the current text in the "File Name"
    ControlGetText _editOld, Edit1, ahk_id %winId%

    ; Make sure there exactly one slash at the end.
    path := RTrim(path , "\") . "\"

    _pathSet := false
    Loop, 20 {
        Sleep, 10
        ControlSetText, Edit1, %path%, ahk_id %winId%
        ControlGetText, _Edit1, Edit1, ahk_id %winId%

        if (_Edit1 == path) {
            _pathSet := true
            break
        }
    }

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
                break
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
            return Func("FeedDialogSYSTREEVIEW")
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