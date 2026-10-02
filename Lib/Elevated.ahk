ElevatedApps := {updated: false}

AddElevatedName(ByRef processId) {
    ; Updates the dictionary by "processId" key.
    ; Returns true if script isn't elevated and value is added
    global ElevatedApps

    if (A_IsAdmin || ElevatedApps.hasKey(processId))
        return false

    ElevatedApps["updated"] := true
    ElevatedApps[processId] := {elevated:  IsProcessElevated(processId), name: Format("{} ({})", GetProcessName(processId), processId)}
    return true
}

LogElevatedNames(_silent := false) {
    ; Logs elevated processes names.
    ; Non-existing processes are deleted
    global ElevatedApps, ScriptName

    if !(ElevatedApps["updated"])
        return ""

    ElevatedApps["updated"] := false
    _names := ""
    for _pid, _info in ElevatedApps {
        try {
            _isClosed := !WinExist("ahk_pid " _pid)
            if _isClosed
                _info["name"] .= " [closed]"

            if _info["elevated"]
                _names .= _info["name"] . ", "

            if _isClosed
                ElevatedApps.delete(_pid)

        } catch _ex {
            LogException(_ex, 1, _silent)
        }
    }

    _names := RTrim(_names, ", ")

    LogError("
     (LTrim
       Unable to get paths from " _names "
       Run this apps as non-admin or run " ScriptName " as admin | with UI access
     )"
    , "admin permission"
    , "`nUnable to send messages to these processes"
    , _silent)

    return _names
}

IsAppElevated(ByRef processId) {
    global ElevatedApps
    return !A_IsAdmin && ElevatedApps.hasKey(processId) && ElevatedApps[processId]["elevated"]
}

;─────────────────────────────────────────────────────────────────────────────
;
IsProcessElevated(ByRef processId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Checks if the process is running as administrator
    ; https://www.autohotkey.com/boards/viewtopic.php?t=26700

    static PROCESS_QUERY_INFORMATION         := 0x0400
    static PROCESS_QUERY_LIMITED_INFORMATION := 0x1000
    static TOKEN_QUERY                       := 0x0008
    static TOKEN_QUERY_SOURCE                := 0x0010
    static TOKEN_ELEVATION                   := 20
    static advapi := DllCall("LoadLibrary", "str", "advapi32.dll", "ptr")
    
    ; For debugging only
    _what := GetProcessName(processId) . " admin permission"
    _pid  := ". PID: " . processId
    
    _process := DllCall("OpenProcess", "UInt", PROCESS_QUERY_INFORMATION, "Int", False, "UInt", processId, "Ptr")
    if ((_process = 0) || (_process = -1)) {
        _process := DllCall("OpenProcess", "UInt", PROCESS_QUERY_LIMITED_INFORMATION, "Int", False, "UInt", processId, "Ptr")

        if ((_process = 0) || (_process = -1))
            throw Exception("Unable to open process", _what, "kernel32!OpenProcess(" processId ")" _pid)
    }

    if !(DllCall("advapi32\OpenProcessToken", "Ptr", _process, "UInt", TOKEN_QUERY | TOKEN_QUERY_SOURCE, "Ptr*", _token := 0)) {
        DllCall("CloseHandle", "Ptr", _process)

        throw Exception("Unable to get token", _what, "advapi32!OpenProcessToken(" _process ")" _pid)
    }

    if !(DllCall("advapi32\GetTokenInformation", "Ptr", _token, "Int", TOKEN_ELEVATION, "UInt*", _isElevated := 0, "UInt", 4, "UInt*", _size := 0)) {
        DllCall("CloseHandle", "Ptr", _token)
        DllCall("CloseHandle", "Ptr", _process)

        throw Exception("Unable to get privileges", _what, "advapi32!GetTokenInformation(" _token ")" _pid)
    }

    DllCall("CloseHandle", "Ptr", _token)
    DllCall("CloseHandle", "Ptr", _process)

    return _isElevated
}

GetCommandLine(ByRef processId) {
    ; https://www.autohotkey.com/boards/viewtopic.php?p=526409#p526409
    static PROCESS_QUERY_INFORMATION := 0x400
    static PROCESS_VM_READ := 0x10

    hProc := DllCall("OpenProcess", "UInt", PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, "Int", 0, "UInt", processId, "Ptr")

    IsWow64 := 0
    if A_Is64bitOS {
        DllCall("IsWow64Process", "Ptr", hProc, "UIntP", &IsWow64)
    }
    if (!A_Is64bitOS || IsWow64) {
        PtrSize := 4, PtrType := "UInt",  pPtr := "UIntP",  offsetCMD := 0x40
    } else {
        PtrSize := 8, PtrType := "Int64", pPtr := "Int64P", offsetCMD := 0x70
    }

    Ntdll := DllCall("GetModuleHandle", "str", "Ntdll", "Ptr")
    failed := ""
    if (A_PtrSize < PtrSize) {    ; script 32, dest proc 64
        if !(QueryInformationProcess := DllCall("GetProcAddress", "Ptr", Ntdll, "AStr", "NtWow64QueryInformationProcess64", "Ptr"))
            failed := "NtWow64QueryInformationProcess64"
        if !(ReadProcessMemory := DllCall("GetProcAddress", "Ptr", Ntdll, "AStr", "NtWow64ReadVirtualMemory64", "Ptr"))
            failed := "NtWow64ReadVirtualMemory64"

        info := 0, szPBI := 48, offsetPEB := 8
    } else {
        if !(QueryInformationProcess := DllCall("GetProcAddress", "Ptr", Ntdll, "AStr", "NtQueryInformationProcess", "Ptr"))
            failed := "NtQueryInformationProcess"

        ReadProcessMemory := "ReadProcessMemory"
        if (A_PtrSize > PtrSize)  {  ; script 64, dest proc 32
            info := 26, szPBI := 8, offsetPEB := 0
        } else {   ; script and dest proc the same bitness
            info := 0, szPBI := PtrSize * 6, offsetPEB := PtrSize
        }
    }

    if failed {
        DllCall("CloseHandle", "Ptr", hProc)
        throw Exception("Unable to get pointer", GetProcessName(processId) " command line", failed ". PID: " processId)
    }

    VarSetCapacity(PBI, 48, 0)
    if DllCall(QueryInformationProcess, "Ptr", hProc, "UInt", info, "Ptr", &PBI, "UInt", szPBI, "UIntP", bytes := 0) {
        DllCall("CloseHandle", "Ptr", hProc)
        throw Exception("Unable to query process", GetProcessName(processId) " command line", "hProc: " hProc " PID: " processId)
    }

    pPEB := NumGet(&PBI + offsetPEB, PtrType)
    DllCall(ReadProcessMemory, "Ptr", hProc, PtrType, pPEB + PtrSize * 4, pPtr, pRUPP := 0, PtrType, PtrSize, "UIntP", bytes := 0)
    DllCall(ReadProcessMemory, "Ptr", hProc, PtrType, pRUPP + offsetCMD, "UShortP", szCMD := 0, PtrType, 2, "UIntP", bytes)
    DllCall(ReadProcessMemory, "Ptr", hProc, PtrType, pRUPP + offsetCMD + PtrSize, pPtr, pCMD := 0, PtrType, PtrSize, "UIntP", bytes)

    VarSetCapacity(buf, szCMD, 0)
    DllCall(ReadProcessMemory, "Ptr", hProc, PtrType, pCMD, "Ptr", &buf, PtrType, szCMD, "UIntP", &bytes)
    DllCall("CloseHandle", "Ptr", hProc)

    return StrGet(&buf, "UTF-16")
}

GetProcessName(ByRef processId, _includeExe := false) {
    WinGet, _name, % "ProcessName", % "ahk_pid " processId
    return _includeExe ? _name : SubStr(_name, 1, -4)
}

GetWinProcess(ByRef winId, _includeExe := false) {
    WinGet, _name, % "ProcessName", % "ahk_id " winId
    return _includeExe ? _name : SubStr(_name, 1, -4)
}