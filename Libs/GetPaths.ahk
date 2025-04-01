; Here are the main functions for obtaining paths and interacting with them.
; All functions add values to the global paths array.

SelectPath() {
    /*
        The path is bound to the position of the menu item
        and MUST BE ADDED to the array in the same order as the menu item
    */
    global
    FileDialog.call(DialogID, paths[A_ThisMenuItemPos])
}

GetShortPath(ByRef _path) {
    /*
        _fullPath is shortened to the last N dirs (DirsCount) starting from the end of the path.
        Dirs are selected as intervals between slashes, excluding them.
        boundaries = indexes of any slashes \ / in the path: /dir/dir/
    */
    global ShortenEnd, DirsCount, DirNameLength, ShowDriveLetter, PathSeparator, ShortNameIndicator
    
    try {
        ; Return input path if it's really short
        _length := StrLen(_path)
        if _length < 4
            Return _path    ; Just drive and slash
    
        ; Variable to return
        _shortPath := ShowDriveLetter ? Substr(_path, 1, 2) : ""
          
        ; The number of slashes (indexes) is one more than the number of dirs: C:/dir/dir/ - 2 dirs, 3 slashes
        _maxSlashes := DirsCount + 1
        ; if the number of slashes is less than DirsCount, the array will contain -1
        ; This is necessary for handling paths where the number of dirs is less than DirsCount: C:/dir
        _slashIndexes := []
        Loop, % _maxSlashes {
            _slashIndexes.Push(-1)
        }
    
        ;─────────────────────────────────────────────────────────────────────────────
        ;
        ; Parsing the path, looking for the indexes of slashes
        ;─────────────────────────────────────────────────────────────────────────────
    
        _fullPath := _path . "/"         ; Last dir bound
        _length++

        if ShortenEnd {
            ; Forward search starting from the pos of the 1st slash
            _pathIndex    := 3
            _slashesCount := 1
            while (_pathIndex <= _length and _slashesCount <= _maxSlashes) {
                _char := SubStr(_fullPath, _pathIndex, 1)
                if (_char = "\" || _char = "/") {
                    _slashIndexes[_slashesCount] := _pathIndex
                    _slashesCount++
                }
                _pathIndex++
            }
            if (_slashesCount < 3)
                return _path     ; not enough to shorten the path
        } else {
            ; Backward slash search until enough is found
            ; to display the required number of dirs
            _pathIndex    := _length
            _slashesCount := _maxSlashes
            while (_pathIndex >= 3 and _slashesCount >= 1) {     ; 3 is pos of the 1st slash
                _char := SubStr(_fullPath, _pathIndex, 1)
                if (_char = "\" || _char = "/") {
                    _slashIndexes[_slashesCount] := _pathIndex
                    _slashesCount--
                }
                _pathIndex--
            }
            if (_slashesCount > _maxSlashes - 2)
                return _path     ; not enough to shorten the path
    
            _shortPath .= ShortNameIndicator     ; An indication that there are more paths after the drive letter
        }
    
        ;─────────────────────────────────────────────────────────────────────────────
        ;
        ; Parsing the slash indexes and extracting the dir names.
        ;─────────────────────────────────────────────────────────────────────────────
    
        Loop, % DirsCount {
            _left    := _slashIndexes[A_Index]
            _right   := _slashIndexes[A_Index + 1]
            if (_left != -1 and _right != -1) {
                _left++     ; exclude slash from name
    
                _length     := _right - _left
                _nameLength := Min(_length, DirNameLength)
                _dirName := SubStr(_fullPath, _left, _nameLength)
                _shortPath  .= PathSeparator . _dirName
    
                if (DirNameLength - _length < 0)
                    _shortPath .= ShortNameIndicator
            }
        }
    } catch _error {
        LogError(_error)
        Return _path
    }
    Return _shortPath
}

;─────────────────────────────────────────────────────────────────────────────
;
GetWindowsPaths(ByRef _WinID) {
;─────────────────────────────────────────────────────────────────────────────
    ; Analyzes open Explorer windows and looks for non-virtual paths
    global paths
    
    try {
        for _instance in ComObjCreate("Shell.Application").Windows {
            if (_WinID == _instance.hwnd) {
                _path := _instance.Document.Folder.Self.Path
                if !InStr(_path, "::{") {
                    paths.push(_path)
                }
            }
        }
    } catch _error {
        LogError(_error)
    }
    
}

;─────────────────────────────────────────────────────────────────────────────
;
TotalCommanderUserCommand(ByRef _WinID, ByRef _command) {
;─────────────────────────────────────────────────────────────────────────────
    VarSetCapacity(_copyData, A_PtrSize * 3)
    VarSetCapacity(_result, StrPut(_command, "UTF-8"))	
    _size := StrPut(_command, &_result, "UTF-8")
    
    NumPut(19781, _copyData, 0)
    NumPut(_size, _copyData, A_PtrSize)
    NumPut(&_result , _copyData, A_PtrSize * 2)
    
    ; WM_COPYDATA without recieve
    SendMessage, 74, 0, &_copyData,, ahk_id %_WinID%
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalCommanderTabs(ByRef _WinID) {
;───────────────────────────────────────────────────────────────────────────── 
    ; Creates user command (if necessary) in usercmd.ini 
    ; and uses it to request the current tabs file. 
    ; If the second panel is enabled, file contains tabs from all panels, 
    ; otherwise file contains tabs from the active panel
    
    static APPDATA_PATH := A_AppData "\GHISLER"
    static TABS_RESULT  := APPDATA_PATH "\Tabs.tab"
    static CONFIG       := APPDATA_PATH "\usercmd.ini"
    static COMMAND      := "EM_SaveAllTabs"
    
    ; Check and create user command
    _created := false
    loop, 4 {
        ; Read the contents of the config until it appears or the loop ends with an error
        IniRead, _section, % CONFIG, % COMMAND
        if (FileExist(CONFIG) && _section && _section != "ERROR") {
            _created := true
            break
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
    
    if _created { 
        ; Send and wait
        TotalCommanderUserCommand(_WinID, COMMAND)
        loop, 10 {
            if (FileExist(TABS_RESULT)) {
                return TABS_RESULT
            }  
            sleep, 20
        }
        ; Loop finished without return
        throw Exception("Unable to access tabs", "Total Commander " TABS_RESULT, "Close TotalCommander. The architecture/bitness of the script and TotalCommander must be the same (e.g. x64)")

    }
    ; Flag not rised
    throw Exception("Unable to create configuration", "Total Commander " CONFIG, CONFIG " doesnt exist and cannot be created. Create it manually in the " APPDATA_PATH)
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalCommanderPaths(ByRef _WinID) {
;─────────────────────────────────────────────────────────────────────────────
    ; Requests a file with current tabs and analyzes it. 
    ; Searches for the active tab using the "activetab" parameter
    global paths
       
    try {           
        Loop, read, % GetTotalCommanderTabs(_WinID)
        {
            if (_pos := InStr(A_LoopReadLine, "path=")) {
                ; Omit "path=" key and start from value position
                paths.push(SubStr(A_LoopReadLine, _pos + 5))
            }
        }
        
    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
XyplorerScript(ByRef _WinID, ByRef _script) {
;─────────────────────────────────────────────────────────────────────────────
    ; https://www.xyplorer.com/xyfc/viewtopic.php?p=179654#p179654
    _size := StrLen(_script)

    VarSetCapacity(_copyData, A_PtrSize * 3, 0)
    NumPut(4194305, _copyData, 0, "Ptr")
    NumPut(_size * 2, _copyData, A_PtrSize, "UInt")
    NumPut(&_script, _copyData, A_PtrSize * 2, "Ptr")
    
    ; WM_COPYDATA without recieve
    SendMessage, 74, 0, &_copyData,, ahk_id %_WinID%
}

;─────────────────────────────────────────────────────────────────────────────
;
GetXyplorerPaths(ByRef _WinID) {
;─────────────────────────────────────────────────────────────────────────────
    ; Sends a message as an internal script.
    ; If the second panel is enabled, gets tabs from all panels, 
    ; otherwise gets tabs from the active panel.
    ; The path separator is |
    ; For each path, gets the real path (XY has special and virtual paths)
    ; Removes the extra | from the beginning of $reals
    ; Places $reals on the clipboard, parses it and puts all paths into the global array    
    global paths
    
    try {
        _script =
        ( LTrim Join
            ::$paths = <get tabs_sf | a>;
            if (get("#800")) { 
                $paths .= |<get tabs_sf | i>
            }
            $reals = "";
            foreach($path, $paths, "|") {
                $reals .= "|" . pathreal($path);
            }
            $reals = replace($reals, "|",,,1,1);
            copytext $reals;
        )
        XyplorerScript(_WinID, _script)
        
        ClipWait, 3
        if ErrorLevel
            Return
                
        Loop, parse, Clipboard, `| 
        {
            paths.push(A_LoopField)
        }
    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetDopusPaths(ByRef _WinID) {
;─────────────────────────────────────────────────────────────────────────────
    ; Analyzes the text of address bars of each tab using MS C++ functions. 
    ; Searches for active tab using DOpus window title    
    global paths
    
    try {
        ; Each tab has its own address bar, so we can use it to determine the path of each tab
        static ADDRESS_BAR_CLASS := "dopus.filedisplaycontainer" 
        ; Defined in AutoHotkey source
        static WINDOW_TEXT_SIZE := 32767 
        VarSetCapacity(_text, WINDOW_TEXT_SIZE * 2)
        
        ; Find the first address bar HWND
        ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowexa
        _previousHwnd := DllCall("FindWindowEx", "ptr", _WinID, "ptr", 0, "str", ADDRESS_BAR_CLASS, "ptr", 0)
        _startHwnd    := _previousHwnd
        _paths        := []

        loop {
            ; Pass every HWND to GetWindowText() and get the content
            ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowtexta
            if DllCall("GetWindowText", "ptr", _previousHwnd, "str", _text, "int", WINDOW_TEXT_SIZE) {
                _paths.push(_text)
            }
            _nextHwnd := DllCall("FindWindowEx", "ptr", _WinID, "ptr", _previousHwnd, "str", ADDRESS_BAR_CLASS, "ptr", 0)          
            
            ; The loop iterates through all the tabs over and over again, 
            ; so we must stop when it repeats
            if (_nextHwnd = _startHwnd)
                break
            
            _previousHwnd := _nextHwnd
        }
        
        ; Push the active tab to the global array first
        WinGetTitle, _title, ahk_id %_WinID%
        for _index, _path in _paths {
            if InStr(_path, _title) {
                paths.push(_path)
            }
        }
        ; Add the remaining tabs (contains a duplicate)
        paths.push(_paths*)
            
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
    global paths := []
    
    ; Save clipboard to restore later
    ClipSaved := ClipboardAll
    Clipboard := ""

    WinGet, _allWindows, list
    Loop, %_allWindows% {
        _WinID := _allWindows%A_Index%
        WinGetClass, _WinClass, ahk_id %_WinID%

        switch _WinClass {
            case "CabinetWClass":       
                GetWindowsPaths(_WinID)
            case "ThunderRT6FormDC":    
                GetXyplorerPaths(_WinID)
            case "TTOTAL_CMD":          
                GetTotalCommanderPaths(_WinID)
            case "dopus.lister":        
                GetDopusPaths(_WinID)
        }
    }

    ; Restore
    Clipboard := ClipSaved
    ClipSaved := ""
}


