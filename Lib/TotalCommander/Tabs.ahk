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
    ; Parses tabsFile.
    ; Searches for the active tab using the "activetab" parameter

    ; Tabs index starts with 0, array index starts with 1
    IniRead, _active, % tabsFile, % "activetabs", % "activetab", 0
    _active += 1
    _paths  := []

    Loop, read, % tabsFile
    {
        _line := A_LoopReadLine

        ; Get path, omit the "path=" key
        if (_path := InStr(_line, "path=")) {
            _path := RTrim(SubStr(_line, _path + 5), "\")
            _paths.push([_path, "TotalCmd.ico", 1, ""])
            continue
        }

        ; Get previous path options, omit the "options=" key
        if (!_showLockedTabs && (_bits := InStr(_line, "options="))) {
            _bits := SubStr(_line, _bits + 8)    ; bits 1|0|0...
            _lock := 0 + SubStr(_bits, 11, 1)    ; Integer at 11 pos.

            if (_lock > 0) {
                _paths.pop()

                ; If the element is removed to the left of _active,
                ; then shift _active to the left
                if (_paths.length() < _active)
                    _active--
            }
        }
    }

    ; Push the active tab to the array first.
    ; Remove duplicate and add the remaining tabs
    _count := _paths.length()
    if _paths.hasKey(_active)
        paths.push(_paths.removeAt(_active))

    paths.push(_paths*)
    return _count
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalUnlockedTab(ByRef tabsFile, ByRef paths) {
;─────────────────────────────────────────────────────────────────────────────
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

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalActiveTab(ByRef winId, ByRef paths) {
;─────────────────────────────────────────────────────────────────────────────
    ControlGetText, _text, % "Window4", % "ahk_id " winId
    _text := SubStr(_text, 1, -1)  ; RTrim ">" char
    paths.push([_text, "TotalCmd.ico", 1, ""])

    return 1
}
