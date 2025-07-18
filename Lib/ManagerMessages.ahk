; Contains file manager request senders
; Returns true on success

SendMessage(ByRef winId, _message := 74, ByRef wParam := 0, ByRef lParam := 0) {
    try {
        SendMessage, % _message, % wParam, % lParam,, % "ahk_id " winId
        return true
    } catch _ex {
        throw Exception("Unable to send message"
                      , GetWinProccess(winId) " message"
                      , Format("`nHWND: {:d} Message: {} wParam: {} lParam: {}`nDetails: {}"
                      , winId, _message, wParam, lParam, _ex.what " " _ex.message " " _ex.extra))
    }
}

SendExplorerPath(ByRef winId, ByRef path) {
    try {
        for _win in ComObjCreate("Shell.Application").windows {
            if (winId = _win.hwnd) {
                _win.Navigate(Trim(path, " ""\/"))
                break
            }
        }
        _win := ""
    }
}

SendTotalInternalCmd(ByRef winPid, _cmd) {
    ; Internal commands can be found in totalcmd.inc
    WinGet, _winId, % "id", % "ahk_pid " winPid
    return SendMessage(_winId, 1075, _cmd)
}

SendTotalUserCmd(ByRef winId, ByRef cmd) {
    ; Command must be defined as "EM_..." in usercmd.ini (may be user-defined filename)
    VarSetCapacity(_copyData, A_PtrSize * 3)
    VarSetCapacity(_result, StrPut(cmd, "UTF-8"))
    _size := StrPut(cmd, &_result, "UTF-8")

    ; EM command (user-defined): Asc("E") + 256 * Asc("M")
    NumPut(19781, _copyData, 0)
    NumPut(_size, _copyData, A_PtrSize)
    NumPut(&_result , _copyData, A_PtrSize * 2)

    ; Send data without recieve
    return SendMessage(winId, 74, 0, &_copyData)
}

;─────────────────────────────────────────────────────────────────────────────
;
SendXyplorerScript(ByRef winId, ByRef script) {
;─────────────────────────────────────────────────────────────────────────────
    ; "script" param must be one-line string prefixed with ::
    _size := StrLen(script)
    VarSetCapacity(_copyData, A_PtrSize * 3, 0)

    ; CopyData command with text mode
    NumPut(4194305, _copyData, 0, "Ptr")
    NumPut(_size * 2, _copyData, A_PtrSize, "UInt")
    NumPut(&script, _copyData, A_PtrSize * 2, "Ptr")

    ; Send data without recieve
    return SendMessage(winId, 74, 0, &_copyData)
}

;─────────────────────────────────────────────────────────────────────────────
;
SendConsoleCommand(ByRef pid, _command) {
;─────────────────────────────────────────────────────────────────────────────
    ; Send command to external cmd.exe
    try {
        ControlSend,, % "{Text}" _command "`n", % "ahk_pid " pid
        LogInfo("Executed console command: " _command, "NoTraytip")
        return true
    } catch _ex {
        throw Exception("Unable to send console command"
                      , "console"
                      , Format("`nCommand: [{}]  HWND: {:d}`nDetails: {}`n"
                      , _command, pid, _ex.what " " _ex.message " " _ex.extra))
    }
}