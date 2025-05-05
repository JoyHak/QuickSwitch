; Contains functions for interacting with processes and their windows

GetProcessProperty(ByRef property := "name", ByRef rules := "") {
    ; Gets the process property using "winmgmts".
    ; "rules" param must be a string "property=value [optional: AND, OR...]"

    ; Full list of allowed properties:
    ; https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process?redirectedfrom=MSDN


    for _process in ComObjGet("winmgmts:").ExecQuery("select * from Win32_Process where " _rules) {
        try {
            return _process[_property]
        } catch _e {
            _extra := Format("Property: {} Rules: {} " _property, _rules)
            _extra .= "Details: " _e.what " " _e.message " " _e.extra
            throw Exception(_process.name " cant return property", "process property", _extra)
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

;─────────────────────────────────────────────────────────────────────────────
;
CloseProcess(ByRef name) {
;─────────────────────────────────────────────────────────────────────────────
    ; Closes the process tree with the specified name

    Loop, 100 {
        Process, Close, % name
        Process, Exist, % name
    } Until !ErrorLevel
}

;─────────────────────────────────────────────────────────────────────────────
;
IsProcessElevated(winPid) {
;─────────────────────────────────────────────────────────────────────────────
    ; https://www.autohotkey.com/boards/viewtopic.php?t=26700

    static PROCESS_QUERY_INFORMATION         := 0x0400
    static PROCESS_QUERY_LIMITED_INFORMATION := 0x1000
    static TOKEN_QUERY                       := 0x0008
    static TOKEN_QUERY_SOURCE                := 0x0010
    static TOKEN_ELEVATION                   := 20

    ; For debugging only
    WinGet, _name, ProcessName, ahk_pid %winPid%

    ; https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-openprocess
    _winPid := DllCall("OpenProcess", "UInt", PROCESS_QUERY_INFORMATION, "Int", False, "UInt", winPid, "Ptr")
    if ((_winPid = 0) || (_winPid = -1)) {
        _winPid := DllCall("OpenProcess", "UInt", PROCESS_QUERY_LIMITED_INFORMATION, "Int", False, "UInt", winPid, "Ptr")

        if ((_winPid = 0) || (_winPid = -1))
            throw Exception("Unable open process " _name, "open process", pid " is passed to kernel32\OpenProcess")
    }

    ; https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-openprocesstoken
    if !(DllCall("advapi32\OpenProcessToken", "Ptr", _winPid, "UInt", TOKEN_QUERY | TOKEN_QUERY_SOURCE, "Ptr*", _tokenId := 0)) {
        DllCall("CloseHandle", "Ptr", _winPid)

        throw Exception("Unable get token for " _name, "process token", pid " is passed to advapi32\OpenProcessToken")
    }

    ; https://learn.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-gettokeninformation
    if !(DllCall("advapi32\GetTokenInformation", "Ptr", _tokenId, "Int", TOKEN_ELEVATION, "UInt*", _isElevated := 0, "UInt", 4, "UInt*", _size := 0)) {

        ; https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle
        DllCall("CloseHandle", "Ptr", _tokenId)
        DllCall("CloseHandle", "Ptr", _winPid)

        throw Exception("Unable to determine process privileges: " _name, "process privileges", pid " is passed to advapi32\GetTokenInformation")
    }

    DllCall("CloseHandle", "Ptr", _tokenId)
    DllCall("CloseHandle", "Ptr", _winPid)

    return _isElevated
}


