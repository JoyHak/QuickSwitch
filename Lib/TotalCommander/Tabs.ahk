ParseTotalTabs(ByRef tabsFile, ByRef paths) {
    ; Parses tabsFile.
    ; Searches for the active tab using the "activetab" parameter

    loop, 150 {
        if !IsFile(tabsFile) {
            Sleep 20
            Continue
        }
            
        _paths  := []
        ; Tabs index starts with 0, array index starts with 1
        _active := _last := 0

        Loop, read, % tabsFile
        {
            ; Omit the InStr key and SubStr from value position
            if (_pos := InStr(A_LoopReadLine, "path=")) {
                _path := RTrim(SubStr(A_LoopReadLine, _pos + 5), "\")
                _paths.push([_path, "TotalCmd.ico"])
            }
            if (_num := InStr(A_LoopReadLine, "activetab=")) {
                ; Skip next active tab by saving last
                _active := _last
                _last   := SubStr(A_LoopReadLine, _num + 10)
            }
        }

        ; Push the active tab to the global array first
        ; Remove duplicate and add the remaining tabs
        paths.push(_paths.removeAt(_active + 1))
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