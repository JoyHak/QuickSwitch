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
    ; Analyzes the attributes of the Explorer COM object. 
    ; Searches for active tab using Explorer window title. 
    ; Returns number of added paths
    WinGetTitle, _title, % "ahk_id " winId
    
    _activeIdx := 0
    _length := paths.length() + 1

    try {
        _shellApp := 0
        _shellApp := ComObjCreate("Shell.Application")
        
        for _win in _shellApp.windows {
            if (winId != _win.hwnd)
                continue
            
            ; Get current path. 
            ; System path (e.g. This PC) have an empty `locationURL` property and we must skip it.   
            _path := _win.locationURL ? [_win.document.folder.self.path, "Explorer.ico"] : false
            
            ; Get active tab           
            if (!_activeIdx && (_title == _win.locationName)) {
                if _activeTabOnly {
                    if _path {
                        paths.push(_path)
                        return 1
                    }
                    return 0
                }
                
                ; If the path is empty, the index of the previous added path will be considered as active
                _activeIdx := paths.length() + !!_path                
            }
            
            if (!_activeTabOnly && _path)
                paths.push(_path)
        }
    } finally {
        if _shellApp
            ObjRelease(_shellApp)
    }
    
    ; Move active path to the top
    if paths.hasKey(_activeIdx) {
        _active := paths[_activeIdx]
        paths[_activeIdx] := paths[_length]
        paths[_length] := _active
    }

    return paths.length() - _length + 1
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
        $allPaths = <get tabs | a>, 'r'`;           ; Get tabs from the active panel, resolve native variables
        if (Get('#800')) {                          ; Second pane is enabled
            $allPaths .= '|' . <get tabs | i>`;     ; Get tabs from second pane
        }

        $realPaths = ''`;
        $activePath = ''`;
        $activeIndex = Tab('get')`;
        $index = 0`;

        ForEach($path, $allPaths, '|') {            ; Path separator is |
            $index++`;

            if (!Exists($path)
             || IsSet($hideLockedTabs)
             && (Tab('get', 'flags', $index) % 4 > 0)) {
                continue`;                          ; Exclude this tab
            }
            if ($index == $activeIndex) {
                $activePath = '|' . PathReal($path)`;  ; Save the active tab to insert it as first later
            } else {
                $realPaths .= '|' . PathReal($path)`;  ; Get the real path (XY has special and virtual paths)                
            }
        }

        $realPaths = Trim($activePath . $realPaths, '| ')`;
        if ($realPaths) {
            CopyText $realPaths`;                   ; Place to the clipboard. It's faster then CopyData
        } else {
            CopyText 'unset'`;                      ; No available tabs
        }
    )"

    static getCurPath := "
    ( LTrim Join
        if (!Exists(<curpath>)
         || IsSet($hideLockedTabs)
         && (Tab('get', 'flags') % 4 > 0)) {
            CopyText 'unset'`;
        } else {
            CopyText <curpath>`;
        }
    )"

    _script := _activeTabOnly ? getCurPath : getAllPaths
    _prefix := _showLockedTabs ? "::" : "::$hideLockedTabs = true`;"
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
    /*
    Analyzes the address bars of each tab using WinApi functions:
    - if the text matches the window title => this is the active tab;
    - if the position of others match the pos. of the active one => this is the active pane.
    Returns number of added paths.
    
    Each tab has its own address bar, so we can use it to determine the path of each tab
    */    
    static ADDRESS_BAR_CLASS := "dopus.filedisplaycontainer"
    ; Find the first address bar ID
    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowexw
    if !(_startId := DllCall("FindWindowExW", "ptr", winId, "ptr", 0, "str", ADDRESS_BAR_CLASS, "ptr", 0))
        return 0
        
    ; Defined in AutoHotkey source
    static WINDOW_TEXT_SIZE := 32767
    VarSetCapacity(_text,  WINDOW_TEXT_SIZE << 1)
    VarSetCapacity(_title, WINDOW_TEXT_SIZE << 1)

    ; Get window title (fast)
    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowtextw
    DllCall("GetWindowTextW", "ptr", winId, "str", _title, "int", WINDOW_TEXT_SIZE)

    _length := paths.length()
    _activePath := false
    _activePosX := _activePosY := 0    
    _currentId  := _startId
    
    loop {   
        ; Pass every address bar ID to GetWindowTextW() and get it's text
        if !(DllCall("GetWindowTextW", "ptr", _currentId, "str", _text, "int", WINDOW_TEXT_SIZE))
            continue
        
        _path := [_text, "Dopus.ico"]
        if (!_activePath
          && _title == SubStr(_text, 1 + InStr(_text, "\",, -1))) {                 
            if _activeTabOnly {
                paths.push(_path)
                return 1
            }
            
            _activePath := _path            
            continue          
        }
        
        if !activeTabOnly
            paths.push(_path)
        
        ; The loop iterates through all the tabs over and over again, so we must stop when it repeats
    } until (_startId = (_currentId := DllCall("FindWindowExW", "ptr", winId, "ptr", _currentId, "str", ADDRESS_BAR_CLASS, "ptr", 0)))

    if _activePath
        paths.insertAt(_length + 1, _activePath)

    return paths.length() - _length
}