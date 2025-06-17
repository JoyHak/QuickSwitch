/*
    Contains functions that feeds specific dialog.
    GetFileDialog() returns the FuncObj to call it later
    and feed the current dialog.

    "editId" param must be existing Edit control uniq ID (handle)
    "path"   param must be a string valid for any dialog
*/

FeedControl(ByRef id, ByRef path, _attempts := 10) {
    Loop, % _attempts {
        ControlFocus,, ahk_id %id%
        ControlSetText,, % path, ahk_id %id%   ; set
        ControlGetText, _path,,  ahk_id %id%   ; check

        if (_path = path)
            return true
    }
    return false
}

FeedDialogGENERAL(ByRef sendEnter, ByRef editId, ByRef path) {
    ; Always send "Enter" key to the General dialog
    static SEND_ENTER := true
    return FeedDialogSYSTREEVIEW(SEND_ENTER, editId, path)
}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogSYSTREEVIEW(ByRef sendEnter, ByRef editId, ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    ; Read the current text in the "File Name"
    ControlGetText, _fileName,, ahk_id %editId%

    if FeedControl(editId, path) {
        if !sendEnter
            return true

        ControlSend,, {Enter}, ahk_id %editId%

        ; Restore filename
        ControlFocus,, ahk_id %editId%
        return FeedControl(editId, _fileName)
    }
    return false
}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogSYSLISTVIEW(ByRef sendEnter, ByRef editId, ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    global DialogId
        
    ; Make sure no element is preselected in listview,
    ; it would always be used later on if you continue with {Enter}!
    Loop, 10 {
        Sleep, 15
        ControlFocus     SysListView321, ahk_id %DialogId%
        ControlGetFocus, _focus,         ahk_id %DialogId%

    } Until (_focus = "SysListView321")

    ControlSend SysListView321, {Home},  ahk_id %DialogId%

    Loop, 10 {
        Sleep, 15
        ControlSend SysListView321, ^{Space}, ahk_id %DialogId%
        ControlGet, _focus, List, Selected, SysListView321, ahk_id %DialogId%

    } Until !_focus

    return FeedDialogSYSTREEVIEW(sendEnter, editId, path)
}

;─────────────────────────────────────────────────────────────────────────────
;
GetFileDialog(ByRef dialogId, ByRef editId := 0, ByRef buttonId := 0) {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets all dialog controls and returns FuncObj for this dialog
    ; if required controls found, otherwise returns "false"

    try {
        ControlGet, buttonId, hwnd,, Button1, ahk_id %dialogId%
        ControlGet, editId,   hwnd,, Edit1,   ahk_id %dialogId%
    }

    if buttonId && editId {
        ; Dialog with buttons
        ; Get specific controls
        WinGet, _controlList, ControlList, ahk_id %dialogId%

        ; Search for...
        static classes := {SysListView321: 1, SysTreeView321: 2, SysHeader321: 4, ToolbarWindow321: 8, DirectUIHWND1: 16}

        ; Find controls and set bitwise flag
        _f := 0
        Loop, Parse, _controlList, `n
        {
            if (_class := classes[A_LoopField])
                _f |= _class
        }

        ; Check specific controls
        if (_f & 8 && _f & 16) {
            return Func("FeedDialogGENERAL")
        }

        if (_f & 1) {
            if (_f & 4) {
                if (_f & 8) {
                    return Func("FeedDialogSYSTREEVIEW")
                }
                return Func("FeedDialogSYSLISTVIEW")
            }
            if (_f & 8) {
                return Func("FeedDialogSYSLISTVIEW")
            }
        }

        if (_f & 2) {
            return Func("FeedDialogSYSTREEVIEW")
        }
    }
    return false
}