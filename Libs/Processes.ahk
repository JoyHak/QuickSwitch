; Contains functions for interacting with processes and their windows

GetProcessProperty(ByRef property := "name", ByRef rules := "") {
    ; Gets the process property using "winmgmts".
    ; "rules" param must be a string "property=value [optional: AND, OR...]"

    ; Full list of allowed properties:
    ; https://learn.microsoft.com/ru-ru/windows/win32/cimwin32prov/win32-process?redirectedfrom=MSDN


    for _process in ComObjGet("winmgmts:").ExecQuery("select * from Win32_Process where " rules) {
        try {
            return _process[property]
        } catch _e {
            _extra := Format("Property: {} Rules: {}  Details: {}" property, rules,  _e.what " " _e.message " " _e.extra)
            throw Exception(_process.name " cant return property", "process property",  _extra)
        }
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalConsolePid(ByRef totalPid) {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets TC console prompt PID, throws readable error

    _pid := 0
    loop, 5 {
        sleep 1000

        if (_pid := GetProcessProperty("ProcessId", "Name='cmd.exe' and ParentProcessId=" totalPid))
            return _pid
    }

    throw Exception("Unable to find console", "TotalCmd console")
}

;─────────────────────────────────────────────────────────────────────────────
;
CloseChildWindows(ByRef winId, ByRef winPid) {
;─────────────────────────────────────────────────────────────────────────────
    ; Closes child windows of the specified process
    
    WinGet, _childs, list, ahk_pid %winPid%
    Loop, % _childs {
        _winId := _childs%A_Index%
        if (_winId != winId) {        
            WinClose, ahk_id %_winId%
        }
    }
}

