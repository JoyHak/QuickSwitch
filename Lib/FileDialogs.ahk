FillDialog(ByRef editId, ByRef path) {
    ; Fills Edit field by specified handle with "path".
    ; Read the current text in the "File Name"
    ControlGetText, _fileName,, % "ahk_id " editId

    ; Change current path
    ControlFocus,,            % "ahk_id " editId
    ControlSetText,, % path,  % "ahk_id " editId
    ControlGetText, _path,,   % "ahk_id " editId

    if (_path = path) {
        ; Successfully changed
        ControlSend,, % "{Enter}", % "ahk_id " editId

        ; Restore filename
        ControlFocus,, % "ahk_id " editId
        ControlSetText,, % _fileName, % "ahk_id " editId
        return true
    }
    return false
}

;─────────────────────────────────────────────────────────────────────────────
;
IsFileDialog(ByRef dialogId, ByRef editId := 0, ByRef buttonId := 0) {
;─────────────────────────────────────────────────────────────────────────────
    ; Checks all dialog controls and returns true
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
    static classes := {SysTreeView321: 1, SysListView321: 2, SysHeader321: 3, DirectUIHWND1: 5, ToolbarWindow321: 8}

    ; Find controls and set bitwise flag
    _f := 0
    Loop, Parse, _controlList, `n
    {
        if (_class := classes[A_LoopField])
            _f += _class
    }

    ; Check if enough controls found
    return _f >= 13 || _f = 1
}