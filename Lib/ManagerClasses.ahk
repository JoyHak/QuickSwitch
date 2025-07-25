/*
    Contains getters whose names correspond to classes of known file managers.
    All functions add options to the array: [path, iconName]
    "winId" param must be existing window uniq ID (window handle / HWND)
*/

GroupAdd, ManagerClasses, ahk_class TTOTAL_CMD
GroupAdd, ManagerClasses, ahk_class CabinetWClass
GroupAdd, ManagerClasses, ahk_class ThunderRT6FormDC
GroupAdd, ManagerClasses, ahk_class dopus.lister


TTOTAL_CMD(ByRef winId, ByRef paths) {
    return GetTotalPaths(winId, paths)
}

CabinetWClass(ByRef winId, ByRef paths) {
    ; Analyzes open Explorer windows (tabs) and looks for non-virtual paths
    ; Returns number of added paths

    try {
        _count := 0
        for _win in ComObjCreate("Shell.Application").windows {
            if (winId = _win.hwnd) {
                _path := _win.document.folder.self.path
                if !InStr(_path, "::{") {
                    _count++
                    paths.push([_path, "Explorer.ico"])
                }
            }
        }
        _win := ""
        return _count
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ThunderRT6FormDC(ByRef winId, ByRef paths) {
;─────────────────────────────────────────────────────────────────────────────
    ; Sends script to XYplorer and parses the clipboard.
    ; Returns number of added paths.
    
    ; Save clipboard to restore later
    _clipSaved := ClipboardAll
    Clipboard  := ""

    static script := "
    ( LTrim Join Comments
        ::$paths = <get tabs_sf | a>, 'r'`;         ; Get tabs from the active panel, resolve native variables
        if (get('#800')) {                          ; Second panel is enabled
            $paths .= '|' . <get tabs_sf | i>`;     ; Get tabs from second panels
        }
        $reals = ''`;
        foreach($path, $paths, '|') {               ; Path separator is |
            $reals .= '|' . pathreal($path)`;       ; Get the real path (XY has special and virtual paths)
        }
        $reals = trim($reals, '|', 'L')`;           ; Remove the extra  | from the beginning of $reals
        copytext $reals`;                           ; Place $reals to the clipboard, faster then copydata
    )"

    SendXyplorerScript(winId, script)

    ; Try to fetch clipboard data
    ClipWait 1
    _clip     := Clipboard
    Clipboard := _clipSaved

    ; Retry if empty
    static attempts := 0
    if !(_clip || (attempts = 3)) {
        attempts++
        return ThunderRT6FormDC(winId, paths)
    }

    _count := attempts := 0
    Loop, parse, _clip, `|
    {
        _count++
        paths.push([A_LoopField, "Xyplorer.ico"])
    }
    
    return _count
}

;─────────────────────────────────────────────────────────────────────────────
;
Dopus(ByRef winId, ByRef paths) {
;─────────────────────────────────────────────────────────────────────────────
    ; Analyzes the text of address bars of each tab using windows functions.
    ; Searches for active tab using DOpus window title.
    ; Returns number of added paths.
    WinGetTitle, _title, % "ahk_id " winId

    ; Each tab has its own address bar, so we can use it to determine the path of each tab
    static ADDRESS_BAR_CLASS := "dopus.filedisplaycontainer"
    ; Defined in AutoHotkey source
    static WINDOW_TEXT_SIZE := 32767
    VarSetCapacity(_text, WINDOW_TEXT_SIZE * 2)

    ; Find the first address bar HWND
    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowexw
    _previousId := DllCall("FindWindowExW", "ptr", winId, "ptr", 0, "str", ADDRESS_BAR_CLASS, "ptr", 0)
    _startId    := _previousId
    _paths      := []
    _active     := 1

    loop, 100 {
        ; Pass every HWND to GetWindowText() and get the content
        ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowtextw
        if DllCall("GetWindowTextW", "ptr", _previousId, "str", _text, "int", WINDOW_TEXT_SIZE) {
            _paths.push([_text, "Dopus.ico"])

            if InStr(_text, _title)
                _active := A_Index
        }
        _nextId := DllCall("FindWindowExW", "ptr", winId, "ptr", _previousId, "str", ADDRESS_BAR_CLASS, "ptr", 0)

        ; The loop iterates through all the tabs over and over again,
        ; so we must stop when it repeats
        if (_nextId = _startId)
            break

        _previousId := _nextId
    }

    ; Push the active tab to the global array first
    ; Remove duplicate and add the remaining tabs
    paths.push(_paths.removeAt(_active))
    paths.push(_paths*)
    
    return _paths.length() + 1
}