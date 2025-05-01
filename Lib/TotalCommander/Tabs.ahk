ParseTotalTabs(ByRef tabsFile) {
    ; Parses tabsFile.
    ; Searches for the active tab using the "activetab" parameter
    global Paths

    loop, 150 {
        if FileExist(tabsFile) {
            _paths  := []

            ; Tabs index starts with 0, array index starts with 1
            _active := _last := 0

            Loop, read, % tabsFile
            {
                ; Omit the InStr key and SubStr from value position
                if (_pos := InStr(A_LoopReadLine, "path=")) {
                    _path := SubStr(A_LoopReadLine, _pos + 5)
                    _paths.push(RTrim(_path, "\"))
                }
                if (_num := InStr(A_LoopReadLine, "activetab=")) {
                    ; Skip next active tab by saving last
                    _active := _last
                    _last   := SubStr(A_LoopReadLine, _num + 10)
                }
            }

            ; Push the active tab to the global array first
            ; Remove duplicate and add the remaining tabs
            Paths.push(_paths.removeAt(_active + 1))
            Paths.push(_paths*)

            try FileDelete, % tabsFile
            return true
        }
        sleep, 20
    }
    throw Exception("Unable to access tabs"
                    , "TotalCmd tabs"
                    , "Restart Total Commander and retry`n"
                    . ValidateFile(tabsFile))
}