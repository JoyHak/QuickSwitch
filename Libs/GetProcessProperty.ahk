; Contains windows processes properties getters

GetProcessProperty(ByRef property := "name", ByRef rules := "") {
    ; Gets the process property using "winmgmts".
    ; "rules" param must be a string "property=value [optional: AND, OR...]"

    ; Full list of allowed properties:
    ; https://learn.microsoft.com/ru-ru/windows/win32/cimwin32prov/win32-process?redirectedfrom=MSDN


    for _process in ComObjGet("winmgmts:").ExecQuery("select * from Win32_Process where " rules) {
        if !(_process.hasKey(property))
            throw Exception(_process.name " process has no `'" property "`' property", "process property", "Rules: " rules)

        return _process[property]
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalConsolePid(ByRef totalPid) {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets TC console prompt PID, throws readable error

    _pid := 0
    loop, 10 {
        sleep 1000

        if (_pid := GetProcessProperty("ProcessId", "Name='cmd.exe' and ParentProcessId=" totalPid))
            return _pid
    }

    throw Exception("Unable to find console", "TotalCmd console")
}

