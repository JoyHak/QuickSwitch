#Include %A_LineFile%\..\TotalCommander
#Include Ini.ahk
#Include Search.ahk
#Include Create.ahk
#Include Tabs.ahk

TTOTAL_CMD(ByRef winId, ByRef paths, _activeTabOnly := false, _showLockedTabs := false) {
    /*
        Gets current browsing paths from both panels.
        Active panel path is added first for AutoSwitch.
    */
    return GetTotalPanelPaths(winId, paths)
}

GetTotalPanelPaths(ByRef winId, ByRef paths) {
    /*
        Gets current browsing paths from both panels.
        - Window9: Active panel path (ends with ">")
        - Window13: Left panel path (ends with "*.*")
        - Window18: Right panel path (ends with "*.*")
        Active panel path is added first for AutoSwitch.
    */

    _leftPath := ""
    _rightPath := ""
    _activePath := ""

    ; Get active panel path from Window9 (ends with ">")
    ControlGetText, _text, % "Window9", % "ahk_id " winId
    if InStr(_text, ":\") && InStr(_text, ">") {
        _activePath := RTrim(_text, ">")
    }

    ; Get left panel path from Window13
    ControlGetText, _text, % "Window13", % "ahk_id " winId
    if InStr(_text, ":\") && RegExMatch(_text, "\*\.\*$") {
        _leftPath := RegExReplace(_text, "\*\.\*$", "")
        _leftPath := RTrim(_leftPath, "\")
    }

    ; Get right panel path from Window18
    ControlGetText, _text, % "Window18", % "ahk_id " winId
    if InStr(_text, ":\") && RegExMatch(_text, "\*\.\*$") {
        _rightPath := RegExReplace(_text, "\*\.\*$", "")
        _rightPath := RTrim(_rightPath, "\")
    }

    LogInfo("TC active: [" _activePath "] left: [" _leftPath "] right: [" _rightPath "]", "NoTraytip")

    _count := 0

    ; Add active panel path first (for AutoSwitch)
    if (_activePath != "") {
        paths.push([_activePath, "TotalCmd.ico", 1, ""])
        _count++
    }

    ; Add left panel path if not active
    if (_leftPath != "" && _leftPath != _activePath) {
        paths.push([_leftPath, "TotalCmd.ico", 1, ""])
        _count++
    }

    ; Add right panel path if not active
    if (_rightPath != "" && _rightPath != _activePath) {
        paths.push([_rightPath, "TotalCmd.ico", 1, ""])
        _count++
    }

    return _count
}