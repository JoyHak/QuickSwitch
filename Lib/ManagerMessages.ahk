; Contains file manager request senders

SendMessage(ByRef winId, ByRef data, _message := 74) {
    try {
        SendMessage, % _message, 0, &data,, ahk_id %winId%
    } catch _e {
        throw Exception("Unable to send message"
                      , GetWinProccess(winId) " message"
                      , Format("`nMessage: {}  HWND: {:d}  Data: {}`n Details: {}`n"
                      , _message, winId, data, _e.what " " _e.message " " _e.extra))
    }
}


SendTotalMessage(ByRef winPid, _message) {
    ; Internal messages can be found in totalcmd.inc
    WinGet, _winId, id, ahk_pid %winPid%
    SendMessage(_winId, _message, 1075)
}

SendExplorerPath(ByRef winId, ByRef path) {    
    try {
        for _win in ComObjCreate("Shell.Application").windows {
            if (winId = _win.hwnd) {
                _win.Navigate(path)
                break
            }
        }
        _win := ""        
    }
}

SendTotalCommand(ByRef winId, ByRef command) {
    ; Command must be defined as "EM_..." in usercmd.ini (may be user-defined filename)
    VarSetCapacity(_copyData, A_PtrSize * 3)
    VarSetCapacity(_result, StrPut(command, "UTF-8"))
    _size := StrPut(command, &_result, "UTF-8")
    
    ; EM command (user-defined): Asc("E") + 256 * Asc("M") 
    NumPut(19781, _copyData, 0)
    NumPut(_size, _copyData, A_PtrSize)
    NumPut(&_result , _copyData, A_PtrSize * 2)

    ; Send data without recieve
    SendMessage(winId, _copyData, 74)
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
    SendMessage(winId, _copyData, 74)
}

;─────────────────────────────────────────────────────────────────────────────
;
SendConsoleCommand(ByRef pid, _command) {
;─────────────────────────────────────────────────────────────────────────────
    ; Send command to external cmd.exe
    try {
        ControlSend,, % "{Text}" _command "`n", % "ahk_pid " pid
        LogInfo("Executed console command: " _command, "NoTraytip")
    } catch _e {
        throw Exception("Unable to send console command"
                      , "console"
                      , Format("`nCommand: [{}]  HWND: {:d}  Details: {}`n"
                      , _command, pid, _e.what " " _e.message " " _e.extra))
    }
}