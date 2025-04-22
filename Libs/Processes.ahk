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

;─────────────────────────────────────────────────────────────────────────────
;
ProcessIsElevated(ByRef pid) {
;─────────────────────────────────────────────────────────────────────────────
    ;https://www.autohotkey.com/boards/viewtopic.php?t=26700

    static PROCESS_QUERY_LIMITED_INFORMATION := 0x1000
    static TOKEN_QUERY := 0x8
    static TOKEN_ELEVATION := 0x14

    ; For debugging only
    WinGet, _name, ProcessName, ahk_pid %pid%

    ; https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-openprocess
	if !(_pid := DllCall("kernel32\OpenProcess", "UInt", PROCESS_QUERY_LIMITED_INFORMATION, "Int", 0, "UInt", pid, "Ptr"))
		throw Exception("Unable open process " _name, "open process", pid " is passed to kernel32\OpenProcess")

    ; https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-openprocesstoken
	_tokenId := 0
	if !(DllCall("advapi32\OpenProcessToken", "Ptr", _pid, "UInt", TOKEN_QUERY, "Ptr*", _tokenId)) {
        ; https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle
        DllCall("kernel32\CloseHandle", "Ptr", _pid)

        throw Exception("Unable get token for " _name, "process token", pid " is passed to advapi32\OpenProcessToken")
	}

	; https://learn.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-gettokeninformation
	_elevated := _size := 0
	_result := DllCall("advapi32\GetTokenInformation", "Ptr", _tokenId, "Int", TOKEN_ELEVATION, "UInt*", _elevated, "UInt", 4, "UInt*", _size)


    DllCall("kernel32\CloseHandle", "Ptr", _tokenId)
	DllCall("kernel32\CloseHandle", "Ptr", _pid)

    if _result
        return _elevated

    throw Exception("Unable to determine process privileges: " _name, "process privileges", pid " is passed to advapi32\GetTokenInformation")
}

