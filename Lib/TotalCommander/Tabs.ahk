ParseTotalTabs(ByRef tabsFile, ByRef paths, _activeTabOnly := false) {
    ; Parses tabsFile.
    ; Searches for the active tab using the "activetab" parameter

    loop, 150 {
        if !IsFile(tabsFile) {
            Sleep 20
            Continue
        }
            
        _paths  := []
        ; Tabs index starts with 0, array index starts with 1
        _active := _last := 1

        Loop, read, % tabsFile
        {
            ; Omit the InStr key and SubStr from value position
            if (_pos := InStr(A_LoopReadLine, "path=")) {
                _path := RTrim(SubStr(A_LoopReadLine, _pos + 5), "\")
                _paths.push([_path, "TotalCmd.ico", 1, ""])
            }
            if (_num := InStr(A_LoopReadLine, "activetab=")) {
                ; Skip next active tab by saving last
                _active := _last
                _last   := 1 + SubStr(A_LoopReadLine, _num + 10)
                
                if (_activeTabOnly && _paths.hasKey(_last)) {
                    paths.push(_paths.removeAt(_last))
                    return 1
                }
            }
        }

        ; Push the active tab to the global array first
        ; Remove duplicate and add the remaining tabs
        paths.push(_paths.removeAt(_active))
        paths.push(_paths*)

        try FileDelete, % tabsFile
        Sleep 100
        return _paths.length()
    }
    throw Exception("Unable to access tabs"
                    , "TotalCmd tabs"
                    , "Restart TotalCmd and retry`n"
                    . ValidateFile(tabsFile))
}