/*
    Contains functions that feeds specific dialog.
    GetFileDialog() returns the FuncObj to call it later
    and feed the current dialog.

    "winId" param must be existing window uniq ID (window handle / HWND)
    "path"  param must be a string valid for any dialog
*/

FeedEditField(ByRef winId, ByRef path, ByRef attempts := 10) {
    Loop, % attempts {
        ControlSetText, Edit1, % path, ahk_id %winId%          ; set
        ControlGetText, _editContent, Edit1, ahk_id %winId%    ; check

        if (_editContent == path)
            return true
    }
    return false
}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogSYSTREEVIEW(ByRef winId, ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    global CloseDialog
    WinActivate, ahk_id %winId%

    ; Read the current text in the "File Name"
    ControlGetText _editOld, Edit1, ahk_id %winId%

    if FeedEditField(winId, path) {
        if CloseDialog {
            ; Restore original filename
            ; or make empty in case of previous path
            ControlFocus, Edit1, ahk_id %winId%
            ControlSend Edit1, {Enter}, ahk_id %winId%
            ControlFocus, Edit1, ahk_id %winId%

            return FeedEditField(winId, _editOld)

        } else {
            return true
        }
    }
    return false
}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogSYSLISTVIEW(ByRef winId, ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    WinActivate, ahk_id %winId%

    ; Make sure no element is preselected in listview,
    ; it would always be used later on if you continue with {Enter}!
    ControlFocus, SysListView321, ahk_id %winId%
    ControlSend SysListView321, {Home}, ahk_id %winId%

    Loop, 10 {
        Sleep, 15
        ControlSend SysListView321, ^{Space}, ahk_id %winId%
        ControlGet, _focus, List, Selected, SysListView321, ahk_id %winId%

    } Until !_focus

    return FeedDialogSYSTREEVIEW(winId, path)

}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogGENERAL(ByRef winId, ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    global CloseDialog

    ; Always send {Enter}
    CloseDialog  :=  true
    _result      :=  FeedDialogSYSTREEVIEW(winId, path)
    CloseDialog  :=  false

    return _result
}


;─────────────────────────────────────────────────────────────────────────────
;
GetFileDialog(ByRef dialogId) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Detection of a File dialog by checking specific controls existence.
        Returns FuncObj if required controls found,
        otherwise returns "false"
    */
    try {
        try ControlGet, _buttonId, hwnd,, Button1, ahk_id %dialogId%
        if _buttonId {
            ; Dialog with buttons
            ; Get specific controls
            WinGet, _controlList, ControlList, ahk_id %dialogId%

            ; Search for...
            static classes := {Edit1: 0x1, SysListView321: 0x2, SysTreeView321: 0x4, SysHeader321: 0x8, ToolbarWindow321: 0x10, DirectUIHWND1: 0x20}

            ; Find controls and set bitwise flag
            _f := 0
            Loop, Parse, _controlList, `n
            {
                if (_class := classes[A_LoopField])
                    _f |= _class
            }

            ; Check specific controls
            if (_f & 0x1) {
                if (_f & 0x10 && _f & 0x20) {
                    return Func("FeedDialogGENERAL")
                }

                if (_f & 0x2) {
                    if (_f & 0x8) {
                        if (_f & 0x10) {
                            return Func("FeedDialogSYSTREEVIEW")
                        }
                        return Func("FeedDialogSYSLISTVIEW")
                    }
                    if (_f & 0x10) {
                        return Func("FeedDialogSYSLISTVIEW")
                    }
                }

                if (_f & 0x4)
                    return Func("FeedDialogSYSTREEVIEW")
            }
        }

    } catch _error {
        LogError(_error)
    }
    return false
}