ParseTotalTabs(ByRef tabsFile, ByRef array) {
    ; Parses tabsFile.
    ; Searches for the active tab using the "activetab" parameter

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
            array.push(_paths.removeAt(_active + 1))
            array.push(_paths*)
            
            try {
                Loop, 10 {
                    FileDelete, % tabsFile
                    sleep 100
                    if !FileExist(tabsFile)
                        return
                }
            }
            return
        }
        sleep, 20
    }
    throw Exception("Unable to access tabs"
                    , "TotalCmd tabs"
                    , "Restart Total Commander and retry`n"
                    . ValidateFile(tabsFile))
}