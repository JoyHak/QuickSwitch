/*
    Contains functions that feeds specific dialog.
    GetFileDialog() returns the FuncObj to call it later
    and feed the current dialog.

    "winId" param must be existing window uniq ID (window handle / HWND)
    "path"  param must be a string valid for any dialog
*/

FeedEditField(ByRef id, ByRef path, ByRef attempts := 10) {
    Loop, % attempts {
        ControlFocus, , ahk_id %id%
        Control, EditPaste, % path, , ahk_id %id%    ; set
        ControlGet, _path, Line, 1, , ahk_id %id%    ; check

        if (_path = path)
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

    ControlGet, _id, hwnd,, Edit1,    ahk_id %winId%    ; Get control handle
    ControlGet, _fileName, Line, 1, , ahk_id %_id%      ; Read the current text in the "File Name"

    if FeedEditField(_id, path) {
        if !CloseDialog
            return true

        ControlSend, , {Enter}, ahk_id %_id%            ; Change path
        ControlFocus, , ahk_id %_id%

        return FeedEditField(_id, _fileName)            ; Restore original filename
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
    ControlGet, _id, hwnd,, SysListView321, ahk_id %winId%
    ControlFocus,, ahk_id %_id%
    ControlSend,, {Home}, ahk_id %_id%

    Loop, 10 {
        Sleep, 15
        ControlSend,, ^{Space}, ahk_id %_id%
        ControlGet, _focus, List, Selected,, ahk_id %_id%

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
        Gets all dialog controls and returns FuncObj for this dialog
        if required controls found, otherwise returns "false"
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

                if (_f & 0x4) {
                    return Func("FeedDialogSYSTREEVIEW")
                }
            }
        }

    } catch _error {
        LogError(_error)
    }
    return false
}