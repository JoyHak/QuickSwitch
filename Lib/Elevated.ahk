AddElevatedName(ByRef winPid, ByRef elevatedDict) {
    ; Adds {PID: name} to the dictionary by "winPid" key.
    ; Returns true if script isn't elevated and value is aadded

    if (A_IsAdmin || elevatedDict.hasKey(winPid))
        return false

    WinGet, _name, ProcessName, ahk_pid %winPid%
    elevatedDict["updated"] := true
    elevatedDict[winPid]    := {elevated:  IsProcessElevated(winPid)
                              , name:      Format("{} ({})", SubStr(_name, 1, -4), winPid)}
    return true
}

GetElevatedNames(ByRef elevatedDict) {
    ; Returns a string with elevated processes names from "elevatedDict".
    ; Non-existing processes are deleted

    _names := ""
    for _pid, _info in elevatedDict {
        try {
            if !WinExist("ahk_pid " _pid) {
                elevatedDict.delete(_pid)
                continue
            }

            if _info["elevated"]
                _names .= _info["name"] . ", "

        } catch _error {
            LogError(_error)
        }
    }

    return RTrim(_names, ", ")
}

IsAppElevated(ByRef winPid, ByRef elevatedDict) {
    return !A_IsAdmin && elevatedDict.hasKey(winPid) && elevatedDict[winPid]["elevated"]
}

;─────────────────────────────────────────────────────────────────────────────
;
IsProcessElevated(ByRef winPid) {
;─────────────────────────────────────────────────────────────────────────────
    ; Checks if the process is running as administrator
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
            throw Exception("Unable open process " _name, "open process", _winPid " is passed to kernel32\OpenProcess")
    }

    ; https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-openprocesstoken
    if !(DllCall("advapi32\OpenProcessToken", "Ptr", _winPid, "UInt", TOKEN_QUERY | TOKEN_QUERY_SOURCE, "Ptr*", _tokenId := 0)) {
        DllCall("CloseHandle", "Ptr", _winPid)

        throw Exception("Unable get token for " _name, "process token", _winPid " is passed to advapi32\OpenProcessToken")
    }

    ; https://learn.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-gettokeninformation
    if !(DllCall("advapi32\GetTokenInformation", "Ptr", _tokenId, "Int", TOKEN_ELEVATION, "UInt*", _isElevated := 0, "UInt", 4, "UInt*", _size := 0)) {

        ; https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle
        DllCall("CloseHandle", "Ptr", _tokenId)
        DllCall("CloseHandle", "Ptr", _winPid)

        throw Exception("Unable to determine process privileges: " _name, "process privileges", _winPid " is passed to advapi32\GetTokenInformation")
    }

    DllCall("CloseHandle", "Ptr", _tokenId)
    DllCall("CloseHandle", "Ptr", _winPid)

    return _isElevated
}