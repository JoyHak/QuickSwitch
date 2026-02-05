/*
    Contains tabs getters for different cases.
    All functions add options to the array and return the number of added paths.
    See options and documentation in Lib\MenuFrontend
*/

WaitForTabs(ByRef tabsDir, ByRef tabsFile, _attempts := 3) {
    ; Waits for access to a file with tabs. Monitors write changes for a dynamic fast timeout instead of Sleep().

    _notificationId := DllCall("FindFirstChangeNotificationW", "ptr", &tabsDir, "int", 1, "uint", 17)
    if (_notificationId = -1)
       throw Exception("Tabs directory doesn't exist"
                     , "TotalCmd tabs"
                     , "Please create it manually: '" tabsDir "'")

    loop % _attempts {
        ; Wait for the write changes with timeout
        _result := DllCall("WaitForSingleObject", "ptr", _notificationId, "uint", 500)
        DllCall("FindNextChangeNotification", "ptr", _notificationId)
        
        if (_result != 0)
            continue
        
        ; Request access to the file
        ; Wait in case the tabs is writed again
        Sleep 50  
        _fileId := DllCall("CreateFileW"
            , "ptr", &tabsFile
            , "uint", 0x80000000          ; Read access
            , "uint", 0, "uint", 0
            , "uint", 3                   ; Open only if exists
            , "uint", 0, "uint", 0)

        if (_fileId = -1) {
            ; File is being used
            Sleep 50    
            continue
        }

        DllCall("CloseHandle", "ptr", _fileId)
        DllCall("FindCloseChangeNotification", "ptr", _notificationId)
        return true
    }

    DllCall("FindCloseChangeNotification", "ptr", _notificationId)

    throw Exception("Unable to access tabs"
        , "TotalCmd tabs"
        , "`nWatcher result: " _result " Last error: " A_LastError "`n"
        . ValidateFile(tabsFile))
}

ParseTotalTabs(ByRef tabsFile, ByRef paths, _showLockedTabs := false) {
    /*
    Parses tabsFile (must be UTF-16 INI file):
    - "activetab" key contains active tab index (zero-based).
    - "activetabs" section contains tabs from active pane.    
    Returns number of added paths.    
    */
    _activeIdx := 0
    _length := paths.length() + 1

    IniRead, _tabs, % tabsFile, % "activetabs"    
    if true { ; reserved for future _activePaneOnly
        IniRead, _tabsI, % tabsFile, % "inactivetabs"
        _tabs .= "`n" _tabsI
    }      

    Loop, parse, % _tabs, `n, `r
    {
        _line := A_LoopField

        ; Get the path, omit the "path=" key
        if (_path := InStr(_line, "path=")) {
            paths.push([RTrim(SubStr(_line, _path + 5), "\ "), "TotalCmd.ico"])
            continue
        }
        
        ; Get active tab index, omit the "activetab=" key
        if (!_activeIdx && (_num := InStr(_line, "activetab="))) {
            _activeIdx := _length + SubStr(_line, _num + 10)
            continue
        }

        ; Get previous path options, omit the "options=" key
        if (!_showLockedTabs && (_bits := InStr(_line, "options="))) {
            _bits := SubStr(_line, _bits + 8)  ; bits 1|0|0...
            _lock := SubStr(_bits, 11, 1)      ; 11th bit
            if (_lock = "0")
               continue 
            
            ; Remove previous path because it's locked
            paths.pop() 

            ; If the element is removed to the left of activeIdx,
            ; then shift activeIdx to the left
            if (paths.length() < _activeIdx)
                _activeIdx--
        }
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
GetTotalUnlockedTab(ByRef tabsFile, ByRef paths) {
;─────────────────────────────────────────────────────────────────────────────
    /*
    Parses tabsFile (must be UTF-16 INI file):
    - "activetab" key contains active tab index that will be used to read other keys.
    - "{index}_options" key contains bits that allows to determine whether the active tab is unlocked.
    */
    IniRead, _active, % tabsFile, % "activetabs", % "activetab", 0
    IniRead, _bits,   % tabsFile, % "activetabs", % _active "_options", % A_Space
    _lock := SubStr(_bits, 11, 1)  ; 11th bit

    if (_lock != "0")
        return 0

    IniRead, _path,   % tabsFile, % "activetabs", % _active "_path", 0
    if !(_path := RTrim(_path, "\ "))
        return 0
    
    paths.push([_path, "TotalCmd.ico"])
    return 1
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalActiveTab(ByRef winId, ByRef paths) {
;─────────────────────────────────────────────────────────────────────────────
    ; Sends script to TotalCmd and parses the clipboard.
    _clipSaved  := ClipboardAll
    A_Clipboard := ""
    
    loop, 2 {
        if !SendMessage(winId, 1075, 2028 + A_Index)  ; copy source/target path   
            continue
        
        ClipWait 1
        if !A_Clipboard
            continue
        
        paths.push([A_Clipboard, "TotalCmd.ico"])
        A_Clipboard := _clipSaved

        return 1
    }
    
    A_Clipboard := _clipSaved
    return 0
}
