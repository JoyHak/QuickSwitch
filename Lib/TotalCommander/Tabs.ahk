/*  
    Contains tabs getters for different cases.  
    All functions add options to the array and return the number of added paths. 
    See options and documentation in Lib\MenuFrontend
*/

ParseTotalTabs(ByRef tabsFile, ByRef paths, _showLockedTabs := false) {
    ; Parses tabsFile.
    ; Searches for the active tab using the "activetab" parameter

    loop, 150 {
        if !IsFile(tabsFile) {
            Sleep 20
            continue
        }
            
        _paths  := []
        Loop, read, % tabsFile
        {
            _line := A_LoopReadLine
            
            ; Get path, omit the "path=" key
            if (_pos := InStr(_line, "path=")) {
                _path := RTrim(SubStr(_line, _pos + 5), "\")
                _paths.push([_path, "TotalCmd.ico", 1, ""])
                continue
            }
            
            ; Get previous path options, omit the "options=" key 
            if (!_showLockedTabs && (_bits := InStr(_line, "options="))) {
                _bits := SubStr(_line, _bits + 8)    ; bits 1|0|0...
                _lock := 0 + SubStr(_bits, 11, 1)    ; Integer at 11 pos.
                
                if (_lock > 0)
                    _paths.pop()
            }
        }

        ; Tabs index starts with 0, array index starts with 1
        IniRead, _active, % tabsFile, % "activetabs", % "activetab", 0
        _active += 1
        
        ; Push the active tab to the array first.
        ; Remove duplicate and add the remaining tabs
        _count := _paths.length()
        if _paths.hasKey(_active)
            paths.push(_paths.removeAt(_active))
        
        paths.push(_paths*)

        try FileDelete, % tabsFile
        Sleep 100
        return _count
    }
    throw Exception("Unable to access tabs"
                    , "TotalCmd tabs"
                    , "Restart TotalCmd and retry`n"
                    . ValidateFile(tabsFile))
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalUnlockedTab(ByRef tabsFile, ByRef paths) {
;─────────────────────────────────────────────────────────────────────────────
    loop, 150 {
        if !IsFile(tabsFile) {
            Sleep 20
            continue
        }
        
        ; Get active tab number (starts from 0)
        IniRead, _active, % tabsFile, % "activetabs", % "activetab", 0
        
        ; Get active tab options, omit the "options=" key 
        IniRead, _bits, % tabsFile, % "activetabs", % _active "_options", % A_Space
        _lock := 0 + SubStr(_bits, 11, 1)    ; Integer at 11 pos.
        
        if (_lock > 0)
            return 0
        
        IniRead, _path, % tabsFile, % "activetabs", % _active "_path", 0
        paths.push([_path, "TotalCmd.ico", 1, ""])
        return 1    
    }    
    
    throw Exception("Unable to get non-locked tab"
                    , "TotalCmd tab"
                    , "Restart TotalCmd and retry`n"
                    . ValidateFile(tabsFile))
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalActiveTab(ByRef winId, ByRef paths) {
;─────────────────────────────────────────────────────────────────────────────
    ControlGetText, _text, % "Window4", % "ahk_id " winId 
    _text := SubStr(_text, 1, -1)  ; RTrim ">" char
    paths.push([_text, "TotalCmd.ico", 1, ""])
    return 1
}
