FillDialog(ByRef editId, ByRef path, ByRef attempts := 3) {
    ; Fills Edit field by specified handle with "path".
    ; Read the current text in the "File Name"
    ControlGetText, _fileName,, % "ahk_id " editId

    Loop, % attempts {
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
    static classes := {SysListView321: 1, SysTreeView321: 2, SysHeader321: 4, ToolbarWindow321: 8, DirectUIHWND1: 16, SysTabControl321: 32}

    ; Find controls and set bitwise flag
    _f := 0
    Loop, Parse, _controlList, `n
    {
        if (_class := classes[A_LoopField])
            _f |= _class
    }

    ; Check for specific controls
    return (_f & 8 && _f & 16)
        || (_f & 1 && _f & 4 && _f & 8)
        || (_f = 2)
}