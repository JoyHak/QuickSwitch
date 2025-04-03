; Here are the main functions for obtaining paths and interacting with them.
; All functions add values to the global paths array.

SelectPath() {
    /*
        The path is bound to the position of the menu item
        and MUST BE ADDED to the array in the same order as the menu item
    */
    global
    FileDialog.call(DialogID, Paths[A_ThisMenuItemPos])
}

GetShortPath(ByRef path) {
    /*
        _fullPath is shortened to the last N dirs (DirsCount) starting from the end of the path.
        Dirs are selected as intervals between slashes, excluding them.
        boundaries = indexes of any slashes \ / in the path: /dir/dir/
    */
    global ShortenEnd, DirsCount, DirNameLength, ShowDriveLetter, PathSeparator, ShortNameIndicator, ShowFirstSeparator
    
    try {
        ; Return input path if it's really short
        if (StrLen(path) < 4)
            return path    ; Just drive and slash
        
        path  := RTrim(path, "\")
        _dirs := StrSplit(path, "\")
        _size := _dirs.count()
        
        ; Variable to return
        _shortPath := ShowDriveLetter ? _dirs[1] : ""
        
        ; Parse the _dirs array, omit drive letter
        if ShortenEnd {
            ; Forward direction
            _index := 2
            _inc   := 1
            _last  := _size
            _stop  := Min(DirsCount, _last)
        } else {
            ; Backward direction
            _index := _size
            _inc   := -1
            _last  := 2
            _stop  := Max(_last, _index - DirsCount)
            _shortPath .= ShortNameIndicator     ; An indication that there are more paths after the drive letter
        }
        
        ; Add first separator if needed
        if (ShowFirstSeparator || ShowDriveLetter)
            _shortPath .= PathSeparator

        loop {
            _dir := _dirs[_index]
            _length  := StrLen(_dir)
            _dirName := SubStr(_dir, 1, Min(_length, DirNameLength))
            
            _shortPath .= _dirName
            if (_length > DirNameLength)
                _shortPath .= ShortNameIndicator
            
            if (_index == _stop)
                break
                
            _shortPath .= PathSeparator
            _index += _inc
        }
        
        ; The shortened path fits into DirsCount 
        ; but there are still directories remaining
        if ((_index != _last) && (_length <= DirNameLength))
            _shortPath .= ShortNameIndicator

    } catch _error {
        LogError(_error)
        return path
    }
    return _shortPath
}

;─────────────────────────────────────────────────────────────────────────────
;
GetWindowsPaths(ByRef winID) {
;─────────────────────────────────────────────────────────────────────────────
    ; Analyzes open Explorer windows (tabs) and looks for non-virtual paths
    global Paths
    
    try {
        for _instance in ComObjCreate("Shell.Application").Windows {
            if (winID == _instance.hwnd) {
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
XyplorerScript(ByRef winId, ByRef script) {
;─────────────────────────────────────────────────────────────────────────────
    ; https://www.xyplorer.com/xyfc/viewtopic.php?p=179654#p179654
    _size := StrLen(script)

    VarSetCapacity(_copyData, A_PtrSize * 3, 0)
    NumPut(4194305, _copyData, 0, "Ptr")
    NumPut(_size * 2, _copyData, A_PtrSize, "UInt")
    NumPut(&script, _copyData, A_PtrSize * 2, "Ptr")
    
    try {
        ; WM_COPYDATA without recieve
        SendMessage, 74, 0, &_copyData,, ahk_id %winId%
    } catch _error {
        throw Exception("Unable to send a message to XYplorer", "Xyplorer script",  _error.What " " _error.Message " " _error.Extra)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
TotalCommanderUserCommand(ByRef winId, ByRef command) {
;─────────────────────────────────────────────────────────────────────────────
    VarSetCapacity(_copyData, A_PtrSize * 3)
    VarSetCapacity(_result, StrPut(command, "UTF-8"))	
    _size := StrPut(command, &_result, "UTF-8")
    
    NumPut(19781, _copyData, 0)
    NumPut(_size, _copyData, A_PtrSize)
    NumPut(&_result , _copyData, A_PtrSize * 2)
     
    try {
        ; WM_COPYDATA without recieve
        SendMessage, 74, 0, &_copyData,, ahk_id %winId%
    } catch _error {
        throw Exception("Unable to execute TotalCommander user command", "TotalCommander command",  _error.What " " _error.Message " " _error.Extra)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetXyplorerPaths(ByRef winId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Sends a message as an internal script.
    ; If the second panel is enabled, gets tabs from all panels, 
    ; otherwise gets tabs from the active panel.
    ; The path separator is |
    ; For each path, gets the real path (XY has special and virtual paths)
    ; Removes the extra | from the beginning of $reals
    ; Places $reals on the clipboard, parses it and puts all paths into the global array    
    global Paths
    
    try {
        ; Save clipboard to restore later
        _clipSaved := ClipboardAll
        Clipboard  := ""

        static script := "
        ( LTrim Join
            ::$paths = <get tabs_sf | a>`;
            if (get('#800')) { 
                $paths .= '|' . <get tabs_sf | i>`;
            }
            $reals = ''`;
            foreach($path, $paths, '|') {
                $reals .= '|' . pathreal($path)`;
            }
            $reals = replace($reals, '|',,,1,1)`;
            copytext $reals`;
        )"
        XyplorerScript(winId, script)
        
        ClipWait, 3
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
GetTotalCommanderTabs(ByRef winId) {
;───────────────────────────────────────────────────────────────────────────── 
    ; Creates user command (if necessary) in usercmd.ini 
    ; and uses it to request the current tabs file. 
    ; If the second panel is enabled, file contains tabs from all panels, 
    ; otherwise file contains tabs from the active panel
    
    static TABS_RESULT, CONFIG, COMMAND
    static created := false
    if created
        return TABS_RESULT
    
    ; Search for TC main directory
    static APPDATA_PATH := A_AppData "\GHISLER\"     
    if !FileExist(APPDATA_PATH) {    
        static PATH
        WinGet, PATH, ProcessPath, ahk_id %winId%
        
        ; Remove exe name
        PATH := SubStr(PATH, 1, InStr(PATH, "\",, -12)) 
        APPDATA_PATH := PATH       
    }
        
    TABS_RESULT := APPDATA_PATH "Tabs.tab"
    CONFIG      := APPDATA_PATH "usercmd.ini"
    COMMAND     := "EM_SaveAllTabs"
       
    ; Check and create user command
    loop, 4 {
        ; Read the contents of the config until it appears or the loop ends with an error
        IniRead, _section, % CONFIG, % COMMAND
        if (_section && _section != "ERROR") {
            created := true
            return TABS_RESULT
        }            
        
        ; Set normal attributes (write access)
        FileSetAttrib, n, % APPDATA_PATH
        FileSetAttrib, n, % CONFIG
        sleep, 20 * A_Index
        
        ; Create new section
        FileAppend,
        (LTrim
            # Please dont add commands with the same name
            [%COMMAND%]
            cmd=SaveTabs2 
            param=`"%TABS_RESULT%`"
            
        ), % CONFIG
        sleep, 50 * A_Index
    }
    return LogError(Exception("Unable to create configuration", "Total Commander config", CONFIG " doesnt exist and cannot be created. Create it manually in the " APPDATA_PATH))
}

;─────────────────────────────────────────────────────────────────────────────
;
ParseTotalCommanderTabs(ByRef tabs) {
;─────────────────────────────────────────────────────────────────────────────
    global Paths
    
    try { 
        if FileExist(tabs) {
            SetTimer,, off
            _paths  := []
            
            ; Tabs index starts with 0, array index starts with 1
            _active := _last := 0
            
            Loop, read, % tabs
            {
                ; Omit the InStr key and SubStr from value position
                if (_pos := InStr(A_LoopReadLine, "path=")) {                
                    _paths.push(SubStr(A_LoopReadLine, _pos + 5))
                }
                if (_num := InStr(A_LoopReadLine, "activetab=")) {
                    ; Skip next active tab by saving last
                    _active := _last
                    _last   := SubStr(A_LoopReadLine, _num + 10)                
                }
            }
            ; Push the active tab to the global array first
            Paths.push(_paths[_active + 1])
            ; Remove duplicate and add the remaining tabs
            _paths.removeAt(_active + 1)
            Paths.push(_paths*)
            
            try FileDelete, % tabs
        }
        
        ; Check calls count
        static counter := 0
        counter++
        if (counter == 100) {
            SetTimer,, off
            return LogError(Exception("Unable to access tabs", "Total Commander tabs", "Close Total Commander. The architecture of the script and Total Commander must be the same: " . (A_PtrSize * 8)))
        }
        
    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalCommanderPaths(ByRef winId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Requests a file with current tabs and analyzes it. 
    ; Searches for the active tab using the "activetab" parameter
    global Paths
       
    try { 
        _tabs := GetTotalCommanderTabs(winId)
        TotalCommanderUserCommand(winId, "EM_SaveAllTabs")
        
        _parser := Func("ParseTotalCommanderTabs").Bind(_tabs)
        SetTimer, % _parser, 20
    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetDopusPaths(ByRef winId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Analyzes the text of address bars of each tab using MS C++ functions. 
    ; Searches for active tab using DOpus window title    
    global Paths
    
    try {
        ; Each tab has its own address bar, so we can use it to determine the path of each tab
        static ADDRESS_BAR_CLASS := "dopus.filedisplaycontainer" 
        ; Defined in AutoHotkey source
        static WINDOW_TEXT_SIZE := 32767 
        VarSetCapacity(_text, WINDOW_TEXT_SIZE * 2)
        
        ; Find the first address bar HWND
        ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowexa
        _previousHwnd := DllCall("FindWindowEx", "ptr", winId, "ptr", 0, "str", ADDRESS_BAR_CLASS, "ptr", 0)
        _startHwnd    := _previousHwnd
        _paths        := []
                
        loop {
            ; Pass every HWND to GetWindowText() and get the content
            ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowtexta
            if DllCall("GetWindowText", "ptr", _previousHwnd, "str", _text, "int", WINDOW_TEXT_SIZE) {
                _paths.push(_text)
            }
            _nextHwnd := DllCall("FindWindowEx", "ptr", winId, "ptr", _previousHwnd, "str", ADDRESS_BAR_CLASS, "ptr", 0)          
            
            ; The loop iterates through all the tabs over and over again, 
            ; so we must stop when it repeats
            if (_nextHwnd = _startHwnd)
                break
            
            _previousHwnd := _nextHwnd
        }
        
        ; Push the active tab to the global array first
        WinGetTitle, _title, ahk_id %winId%
        for _index, _path in _paths {
            if InStr(_path, _title) {
                _active := _index
                Paths.push(_path)
            }
        }
        ; Remove duplicate and add the remaining tabs
        _paths.removeAt(_active)
        Paths.push(_paths*)
  
    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetPaths() {
;─────────────────────────────────────────────────────────────────────────────
    ; Requests paths from all applications whose window class 
    ; is recognized as a known file manager class.
    ; Updates the global array after each call
    global Paths := []

    WinGet, _allWindows, list
    Loop, %_allWindows% {
        winId := _allWindows%A_Index%
        WinGetClass, _WinClass, ahk_id %winId%

        switch _WinClass {
            case "TTOTAL_CMD":          
                GetTotalCommanderPaths(winId)
            case "ThunderRT6FormDC":    
                GetXyplorerPaths(winId)
            case "dopus.lister":        
                GetDopusPaths(winId)
            case "CabinetWClass":       
                GetWindowsPaths(winId)
        }
    }
}


