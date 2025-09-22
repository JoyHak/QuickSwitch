/*
    Contains functions that feeds specific dialog.
    GetFileDialog() returns the FuncObj to call it later
    and feed the current dialog.

    "editId" param must be existing Edit control uniq ID (handle)
    "path"   param must be a string valid for any dialog
*/

FeedDialogGENERAL(ByRef sendEnter, ByRef editId, ByRef path, ByRef attempts := 3) {
    ; Always send "Enter" key to the General dialog
    return FeedDialogSYSTREEVIEW(true, editId, path, attempts)
}

FeedDialogSYSTREEVIEW(ByRef sendEnter, ByRef editId, ByRef path, ByRef attempts := 3) {
    ; Read the current text in the "File Name"
    ControlGetText, _fileName,, % "ahk_id " editId

    Loop, % attempts {
        ; Change current path
        ControlFocus,,            % "ahk_id " editId
        ControlSetText,, % path,  % "ahk_id " editId
        ControlGetText, _path,,   % "ahk_id " editId

        if (_path = path) {
            ; Successfully changed
            if !sendEnter
                return true

            ControlSend,, % "{Enter}", % "ahk_id " editId

            ; Restore filename
            ControlFocus,, % "ahk_id " editId
            ControlSetText,, % _fileName, % "ahk_id " editId
            return true
        }
    }
    return false
}

;─────────────────────────────────────────────────────────────────────────────
;
GetFileDialog(ByRef dialogId, ByRef editId := 0, ByRef buttonId := 0) {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets all dialog controls and returns FuncObj for this dialog
    ; if required controls found, otherwise returns "false"

    try {
        ControlGet, buttonId, % "hwnd",, % "Button1", % "ahk_id " DialogId
        ControlGet, editId,   % "hwnd",, % "Edit1",   % "ahk_id " DialogId
    } catch {
        return false
    }

    if !(buttonId || editId)
        return false

    ; Dialog with buttons
    ; Get specific controls
    WinGet, _controlList, % "ControlList", % "ahk_id " DialogId

    ; Search for...
    static classes := {SysListView321: 1, SysTreeView321: 2, SysHeader321: 4, ToolbarWindow321: 8, DirectUIHWND1: 16, SysTabControl321: 32}

    ; Find controls and set bitwise flag
    _f := 0
    Loop, Parse, _controlList, `n
    {
        if (_class := classes[A_LoopField])
            _f |= _class
    }

    ; Check for specific controls
    if (_f & 8 && _f & 16)
        return Func("FeedDialogGENERAL")      ; Main

    if (_f & 1 && _f & 4 && _f & 8)
        return Func("FeedDialogSYSTREEVIEW")  ; Rare

    if (_f = 2)
        return Func("FeedDialogSYSTREEVIEW")  ; Very old

    return false
}