/*
    Contains getters whose names correspond to classes of known file managers.
    All functions add values to the global "Paths" array.
    "winId" param must be existing window uniq ID (window handle / HWND)
*/

GroupAdd, ManagerClasses, ahk_class CabinetWClass
GroupAdd, ManagerClasses, ahk_class ThunderRT6FormDC
GroupAdd, ManagerClasses, ahk_class dopus.lister
GroupAdd, ManagerClasses, ahk_class TTOTAL_CMD


CabinetWClass(ByRef winId) {
    ; Analyzes open Explorer windows (tabs) and looks for non-virtual paths
    global Paths

    try {
        for _instance in ComObjCreate("Shell.Application").Windows {
            if (winId == _instance.hwnd) {
                _path := _instance.Document.Folder.Self.Path
                if !InStr(_path, "::{") {
                    Paths.push(_path)
                }
            }
        }

    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ThunderRT6FormDC(ByRef winId) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Sends script to XYplorer and parses the clipboard.

        If the second panel is enabled, gets tabs from all panels,
        otherwise gets tabs from the active panel.
        All native variables are resolved.

        The path separator is |
        For each path, gets the real path (XY has special and virtual paths).
        Removes the extra | from the beginning of $reals

        Places $reals on the clipboard.
        Parses it and puts all paths into the global array
    */
    global Paths

    try {
        ; Save clipboard to restore later
        _clipSaved := ClipboardAll
        Clipboard  := ""

        static script := "
        ( LTrim Join
            ::$paths = <get tabs_sf | a>, 'r'`;
            if (get('#800')) {
                $paths .= '|' . <get tabs_sf | i>`;
            }
            $reals = ''`;
            foreach($path, $paths, '|') {
                $reals .= '|' . pathreal($path)`;
            }
            $reals = trim($reals, '|', 'L')`;
            copytext $reals`;
        )"

        SendXyplorerScript(winId, script)

        ClipWait, 5
        if ErrorLevel
            return

        Loop, parse, Clipboard, `|
            Paths.push(A_LoopField)

        ; Restore
        Clipboard := _clipSaved

    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
Dopus(ByRef winId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Analyzes the text of address bars of each tab using MS C++ functions.
    ; Searches for active tab using DOpus window title
    global Paths

    try {
        WinGetTitle, _title, ahk_id %winId%

        ; Each tab has its own address bar, so we can use it to determine the path of each tab
        static ADDRESS_BAR_CLASS := "dopus.filedisplaycontainer"
        ; Defined in AutoHotkey source
        static WINDOW_TEXT_SIZE := 32767
        VarSetCapacity(_text, WINDOW_TEXT_SIZE * 2)

        ; Find the first address bar HWND
        ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowexw
        _previousHwnd := DllCall("FindWindowExW", "ptr", winId, "ptr", 0, "str", ADDRESS_BAR_CLASS, "ptr", 0)
        _startHwnd    := _previousHwnd
        _paths        := []
        _active       := 1

        loop {
            ; Pass every HWND to GetWindowText() and get the content
            ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowtextw
            if DllCall("GetWindowTextW", "ptr", _previousHwnd, "str", _text, "int", WINDOW_TEXT_SIZE) {
                _paths.push(_text)

                if InStr(_text, _title)
                    _active := A_Index
            }
            _nextHwnd := DllCall("FindWindowExW", "ptr", winId, "ptr", _previousHwnd, "str", ADDRESS_BAR_CLASS, "ptr", 0)

            ; The loop iterates through all the tabs over and over again,
            ; so we must stop when it repeats
            if (_nextHwnd = _startHwnd)
                break

            _previousHwnd := _nextHwnd
        }

        ; Push the active tab to the global array first
        ; Remove duplicate and add the remaining tabs
        Paths.push(_paths.removeAt(_active))
        Paths.push(_paths*)

    } catch _error {
        LogError(_error)
    }
}