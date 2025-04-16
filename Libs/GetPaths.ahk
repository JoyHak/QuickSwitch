; Here are the the top-level functions for getting paths
; All functions add values to the global paths array.

GetShortPath(ByRef path) {
    /*
        Full path is shortened according to user-specified global parameters 
        by shortening directory names to the specified length starting at the beginning 
        and separating them with the specified delimiter. 
        Additional options may change the final view.
    */
    global ShortenEnd, DirsCount, DirNameLength, ShowDriveLetter, PathSeparator, ShortNameIndicator, ShowFirstSeparator
    
    try {
        ; Return input path if it's really short
        if (StrLen(path) < 4)
            return path    ; Just drive and slash
        
        path  := RTrim(path, "\")
        _dirs := StrSplit(path, "\")
        _size := _dirs.count()
        
        if (_size = 1)
            return path
            
        ; Variable to return
        _shortPath := ShowDriveLetter ? _dirs[1] : ""
        
        ; Parse the _dirs array, omit drive letter
        if ShortenEnd {
            _index := 2
            _stop  := Min(DirsCount + 1, _size)
        } else {
            _index := Max(2, _size - DirsCount + 1)
            _stop  := _size
            
            ; An indication that there are more paths after the drive letter
            _shortPath .= ShortNameIndicator     
        }

        ; Add first separator if needed
        if (ShowFirstSeparator || ShowDriveLetter)
            _shortPath .= PathSeparator

        loop, % _size {
            _dir := _dirs[_index]
            _length  := StrLen(_dir)
            _dirName := SubStr(_dir, 1, Min(_length, DirNameLength))
            
            _shortPath .= _dirName
            if (_length > DirNameLength)
                _shortPath .= ShortNameIndicator
            
            if (_index == _stop)
                break

            _shortPath .= PathSeparator
            _index++
        }
        
        ; The shortened path fits into DirsCount 
        ; but there are still directories remaining
        if ((_index != _size) && (_length <= DirNameLength))
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
SendXyplorerScript(ByRef winId, ByRef script) {
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
SendTotalCommand(ByRef winId, ByRef command) {
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
    /*  
        Sends a message as an internal script.
        If the second panel is enabled, gets tabs from all panels, 
        otherwise gets tabs from the active panel.
        The path separator is |
        For each path, gets the real path (XY has special and virtual paths)
        Removes the extra | from the beginning of $reals
        Places $reals on the clipboard, parses it and puts all paths into the global array 
    */    
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
        
        SendXyplorerScript(winId, script)
        
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
GetTotalcmdTabs(ByRef winId) {
;───────────────────────────────────────────────────────────────────────────── 
    /*     
        Creates user command (if necessary) in usercmd.ini 
        and uses it to request the current tabs file. 
        If the second panel is enabled, file contains tabs from all panels, 
        otherwise file contains tabs from the active panel 
    */
        
    static COMMAND := "EM_SaveAllTabs"
    static REG     := "HKEY_CURRENT_USER\SOFTWARE\Ghisler\Total Commander"
    static created := false
    static TABS_RESULT
    
    if created
        return TABS_RESULT
    
    ; Search for TC root directory
    RegRead, _regPath, % REG, InstallDir
    WinGet, _winPath, ProcessPath, ahk_id %winId%
 
    ; Remove exe name and leading slash \
    _winPath := SubStr(_winPath, 1, InStr(_winPath, "\",, -12) - 1) 
    
    ; Search for configuration in registry
    _ini := ""
    if (_winPath = _regPath) {
        RegRead, _iniPath, % REG, IniFileName
        
        ; Convert env. variables        
        for _i, _part in StrSplit(_iniPath, "`%") {
            EnvGet, _env, % _part
            if _env
                _ini .= _env        
            else 
                _ini .= _part
        }
        
        ; Remove ini name and leading slash \
        _root := SubStr(_ini, 1, InStr(_ini, "\",, -10) - 1) 
    } 

    ; Registry path is invalid, search in current TC directory
    if !FileExist(_ini) {
        _root := _winPath
        Loop, Files, %_root%\wincmd.ini, R
        {   
            _ini := A_LoopFileLongPath
            break
        }
    }
    
    ; Config not found after 2 attempts    
    if !FileExist(_ini)
        return LogError(Exception("Unable to find wincmd.ini", "Total Commander config", "File `'" _ini "`' not found. Change your TC configuration settings: your configuration should be in any sub-directory in the " _root))
    
    _ini := StrReplace(_ini, "wincmd", "usercmd")      
    TABS_RESULT := _root "\Tabs.tab"     
        
    ; Check and create user command
    loop, 4 {
        ; Read the contents of the config until it appears or the loop ends with an error
        IniRead, _section, % _ini, % COMMAND
        if (_section && _section != "ERROR") {
            created := true
            return TABS_RESULT
        }            
        
        ; Set normal attributes (write access)
        FileSetAttrib, n, % _root
        FileSetAttrib, n, % _ini
        sleep, 20 * A_Index
        
        ; Create new section
        FileAppend,
        (LTrim
         # Please dont add commands with the same name
         [%COMMAND%]
         cmd=SaveTabs2 
         param=`"%TABS_RESULT%`"
            
        ), % _ini
        sleep, 50 * A_Index
    }
    return LogError(Exception("Unable to create configuration", "Total Commander config", _ini " doesnt exist and cannot be created. Create it manually in the " _root))
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalcmdPaths(ByRef winId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Requests a file with current tabs and analyzes it. 
    ; Searches for the active tab using the "activetab" parameter
    global Paths
       
    try { 
        _tabs := GetTotalcmdTabs(winId)
        try FileDelete, % _tabs
        SendTotalCommand(winId, "EM_SaveAllTabs")
        
        loop, 600 {
            if FileExist(_tabs) {
                _paths  := []
                
                ; Tabs index starts with 0, array index starts with 1
                _active := _last := 0
                
                Loop, read, % _tabs
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
                return
            }
            sleep, 20
        }
        return LogError(Exception("Unable to access tabs", "Total Commander tabs", "Restart Total Commander and retry"))
        
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
        ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowexw
        _previousHwnd := DllCall("FindWindowExW", "ptr", winId, "ptr", 0, "str", ADDRESS_BAR_CLASS, "ptr", 0)
        _startHwnd    := _previousHwnd
        _paths        := []
                
        loop {
            ; Pass every HWND to GetWindowText() and get the content
            ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowtextw
            if DllCall("GetWindowTextW", "ptr", _previousHwnd, "str", _text, "int", WINDOW_TEXT_SIZE) {
                _paths.push(_text)
            }
            _nextHwnd := DllCall("FindWindowExW", "ptr", winId, "ptr", _previousHwnd, "str", ADDRESS_BAR_CLASS, "ptr", 0)          
            
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
    /*  
        Requests paths from all applications whose window class 
        is recognized as a known file manager class (in Z-order).
        Updates the global array after each call 
    */    
    global Paths := []

    WinGet, _allWindows, list
    Loop, %_allWindows% {
        winId := _allWindows%A_Index%
        WinGetClass, _WinClass, ahk_id %winId%

        switch _WinClass {
            case "CabinetWClass":       
                GetWindowsPaths(winId)
            case "ThunderRT6FormDC":    
                GetXyplorerPaths(winId)
            case "dopus.lister":        
                GetDopusPaths(winId)
            case "TTOTAL_CMD":          
                GetTotalcmdPaths(winId)
        }
    }
}


