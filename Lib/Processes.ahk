; Contains functions for interacting with processes and their windows

GetWinProccess(ByRef id) {
    ; Slice everything before .exe
    WinGet, _name, % "ProcessName", % "ahk_id " id
    return SubStr(_name, 1, -4)
}

GetProcessName(ByRef pid) {
    ; Slice everything before .exe
    WinGet, _name, % "ProcessName", % "ahk_pid " pid
    return SubStr(_name, 1, -4)
}

;─────────────────────────────────────────────────────────────────────────────
;
GetProcessProperty(_property := "name", _rules := "") {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets the process property using "winmgmts".
    ; "rules" param must be a string "property=value [optional: AND, OR...]"

    ; Full list of allowed properties:
    ; https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process?redirectedfrom=MSDN


    for _process in ComObjGet("winmgmts:").ExecQuery("select * from Win32_Process where " _rules) {
        try {
            return _process[_property]
        } catch _e {
            _extra := 

            throw Exception(_process.name " cant return property"
                          , "process property"
                          , Format("Property: {} Rules: {}`nDetails: {}"
                          , _property, _rules, _e.what " " _e.message " " _e.extra))
        }
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalConsolePid(ByRef totalPid) {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets TC console prompt PID, throws readable error

    _pid := 0
    loop, 3 {
        sleep 1000

        if (_pid := GetProcessProperty("ProcessId", "Name='cmd.exe' and ParentProcessId=" totalPid))
            return _pid
    }

    throw Exception("Unable to find console", "TotalCmd console")
}

;─────────────────────────────────────────────────────────────────────────────
;
CloseChildWindows(ByRef processId, ByRef excludeWinId := 0) {
;─────────────────────────────────────────────────────────────────────────────
    ; Closes child windows of the specified process except main window with winId

    WinGet, _childs, % "list", % "ahk_pid " processId
    Loop, % _childs {
        _winId := _childs%A_Index%
        if (_winId != excludeWinId)
            WinClose % "ahk_id " _winId
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
CloseProcess(_name) {
;─────────────────────────────────────────────────────────────────────────────
    ; Closes the process tree with the specified name

    Loop, 100 {
        Process, % "Close", % _name
        Process, % "Exist", % _name
    } Until !ErrorLevel
}

;─────────────────────────────────────────────────────────────────────────────
;
WinMoveBottom(_winId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Moves the specified window to the bottom of stack (beneath all other windows)
    ; https://github.com/AutoHotkey/AutoHotkey/blob/a34bc07d357b7299ca229757162cef8a91e37f52/source/lib/win.cpp#L1598
    
    static SWP_NOACTIVATE := 0x0010
    static SWP_NOSIZE  := 0x0001
    static SWP_NOMOVE  := 0x0002
    static HWND_BOTTOM := 1
    
    if !DllCall("SetWindowPos"
        , "ptr", _winId
        , "ptr", HWND_BOTTOM
        , "int", 0, "int", 0, "int", 0, "int", 0
        , "uint", SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE
        , "int") {
            WinGetClass, _class, % "ahk_id " _winId
            
            throw Exception(Format("Unable to move {} ({}) to the bottom", _class, _winId)
            , "SetWindowPos"
            , "Last error: " A_LastError)
    }
}


