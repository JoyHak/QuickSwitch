/*
    Contains getters whose names correspond to classes of known file managers.
    All functions add options to the array. See implementation and documentation in Lib\MenuFrontend
    "winId" param must be existing window uniq ID (window handle / HWND)
*/

GroupAdd, ManagerClasses, ahk_class TTOTAL_CMD
GroupAdd, ManagerClasses, ahk_class CabinetWClass
GroupAdd, ManagerClasses, ahk_class ThunderRT6FormDC
GroupAdd, ManagerClasses, ahk_class dopus.lister

CabinetWClass(ByRef winId, ByRef paths, _activeTabOnly := false, _showLockedTabs := false) {
    ; Analyzes open Explorer windows (tabs) and looks for non-virtual paths
    ; Returns number of added paths

    try {
        _count := 0
        for _win in ComObjCreate("Shell.Application").windows {
            if (winId = _win.hwnd) {
                _path := _win.document.folder.self.path
                if !InStr(_path, "::{") {
                    paths.push([_path, "Explorer.ico", 1, ""])
                    if _activeTabOnly
                        return 1
                    
                    _count++
                }
            }
        }
        _win := ""
        return _count
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ThunderRT6FormDC(ByRef winId, ByRef paths, _activeTabOnly := false, _showLockedTabs := false) {
;─────────────────────────────────────────────────────────────────────────────
    ; Sends script to XYplorer and parses the clipboard.
    ; Returns number of added paths.
    
    ; Save clipboard to restore later
    _clipSaved := ClipboardAll
    A_Clipboard  := ""
    
    ; $hideLockedTabs is unset by default
    static getAllPaths := "
    ( LTrim Join Comments
        $paths = <get tabs_sf | a>, 'r'`;           ; Get tabs from the active panel, resolve native variables
        if (get('#800')) {                          ; Second panel is enabled
            $paths .= '|' . <get tabs_sf | i>`;     ; Get tabs from second panels
        }
        $reals = ''`;
        $count = 0`;
        foreach($path, $paths, '|') {               ; Path separator is |
            $count++;
            if (($hideLockedTabs == true) && (tab('get', 'flags', $count) % 4 > 0)) {
                continue`;                          ; Exclude locked tabs
            }
            $reals .= '|' . pathreal($path)`;       ; Get the real path (XY has special and virtual paths)
        }
        $reals = trim($reals, '|', 'L')`;           ; Remove the extra  | from the beginning of $reals
        copytext $reals`;                           ; Place $reals to the clipboard, faster then copydata
    )"
    
    static getCurPath := "
    ( LTrim Join
        if (($hideLockedTabs == true) && (tab('get', 'flags') % 4 > 0)) { 
            copytext 'unset'`;
        } else { 
            copytext <curpath>`; 
        }
    )"
    
    _script := _activeTabOnly ? getCurPath : getAllPaths
    _prefix := _showLockedTabs ? "::$hideLockedTabs = true`;" : "::"
    SendXyplorerScript(winId, _prefix . _script)

    ; Try to fetch clipboard data
    ClipWait 1
    _clip       := A_Clipboard
    A_Clipboard := _clipSaved

    ; Retry if empty
    static attempts := 0
    if !(_clip || (attempts = 3)) {
        attempts++
        return ThunderRT6FormDC(winId, paths, _activeTabOnly, _showLockedTabs)
    }
    
    if (!_clip || (_clip = "unset"))
        return 0
    
    _count := attempts := 0
    Loop, parse, _clip, `|
    {
        paths.push([A_LoopField, "Xyplorer.ico", 1, ""])
        if _activeTabOnly
            return 1
            
        _count++
    }
    
    return _count
}

;─────────────────────────────────────────────────────────────────────────────
;
Dopus(ByRef winId, ByRef paths, _activeTabOnly := false, _showLockedTabs := false) {
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
            if InStr(_text, _title) {
                if _activeTabOnly {
                    paths.push([_text, "Dopus.ico", 1, ""])
                    return 1
                }
                _active := A_Index
            }
            _paths.push([_text, "Dopus.ico", 1, ""])
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