ParseTotalTabs(ByRef tabsFile, ByRef paths, _activeTabOnly := false, _showLockedTabs := false) {
    ; Parses tabsFile.
    ; Searches for the active tab using the "activetab" parameter

    loop, 150 {
        if !IsFile(tabsFile) {
            Sleep 20
            continue
        }
            
        _paths  := []
        _active := -1

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
                    
                continue
            }
            
            ; Get active tab from current pane, return it if _activeTabOnly is true
            if ((_active = -1) && (_num := InStr(_line, "activetab="))) {
                ; Tabs index starts with 0, array index starts with 1
                _active := 1 + SubStr(_line, _num + 10)
                
                if (_activeTabOnly && _paths.hasKey(_active)) {
                    paths.push(_paths.removeAt(_active))
                    return 1
                }
            }
        }

        ; Push the active tab to the global array first
        ; Remove duplicate and add the remaining tabs
        if _paths.hasKey(_active)
            paths.push(_paths.removeAt(_active))
        
        paths.push(_paths*)

        try FileDelete, % tabsFile
        Sleep 100
        return _paths.length() + 1
    }
    throw Exception("Unable to access tabs"
                    , "TotalCmd tabs"
                    , "Restart TotalCmd and retry`n"
                    . ValidateFile(tabsFile))
}