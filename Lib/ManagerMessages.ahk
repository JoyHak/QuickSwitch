; Contains file manager request senders

SendXyplorerScript(ByRef winId, ByRef script) {
    ; https://www.xyplorer.com/xyfc/viewtopic.php?p=179654#p179654
    ; "script" param must be one-line string (use LTrim / Join)
    _size := StrLen(script)

    VarSetCapacity(_copyData, A_PtrSize * 3, 0)
    NumPut(4194305, _copyData, 0, "Ptr")
    NumPut(_size * 2, _copyData, A_PtrSize, "UInt")
    NumPut(&script, _copyData, A_PtrSize * 2, "Ptr")

    try {
        ; WM_COPYDATA without recieve
        SendMessage, 74, 0, &_copyData,, ahk_id %winId%
    } catch _e {
        throw Exception("Unable to send the script"
                      , "Xyplorer script"
                      , Format("HWND: {:d}  Size: {}  Details: {}`n"
                      , winId, _size, _e.what " " _e.message " " _e.extra))
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
SendTotalCommand(ByRef winId, ByRef command) {
;─────────────────────────────────────────────────────────────────────────────
    ; Command must be defined as "EM_..." in usercmd.ini (may be user-defined filename)
    VarSetCapacity(_copyData, A_PtrSize * 3)
    VarSetCapacity(_result, StrPut(command, "UTF-8"))
    _size := StrPut(command, &_result, "UTF-8")

    NumPut(19781, _copyData, 0)
    NumPut(_size, _copyData, A_PtrSize)
    NumPut(&_result , _copyData, A_PtrSize * 2)

    try {
        ; WM_COPYDATA without recieve
        SendMessage, 74, 0, &_copyData,, ahk_id %winId%
    } catch _e {
        throw Exception("Unable to execute user command"
                      , "TotalCmd command"
                      , Format("`nCommand: [{}] HWND: {:d}  Details: {}`n"
                      , command, winId, _e.what " " _e.message " " _e.extra))
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
SendTotalMessage(ByRef winPid, _command) {
;─────────────────────────────────────────────────────────────────────────────
    ; Commands can be found in totalcmd.inc
    try {
        SendMessage 1075, % _command, 0, , % "ahk_pid " winPid
    } catch _e {
        throw Exception("Unable to send internal command"
                      , "TotalCmd command"
                      , Format("`nCommand: {}  HWND: {:d}  Details: {}`n"
                      , _command, winPid, _e.what " " _e.message " " _e.extra))
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
SendConsoleCommand(ByRef consolePid, _command) {
;─────────────────────────────────────────────────────────────────────────────
    ; Send command to external cmd.exe
    try {
        ControlSend,, % "{Text}" _command "`n", % "ahk_pid " consolePid
        LogInfo("Executed console command: " _command, "NoTraytip")
    } catch _e {
        throw Exception("Unable to send console command"
                      , "console"
                      , Format("`nCommand: [{}]  HWND: {:d}  Details: {}`n"
                      , _command, consolePid, _e.what " " _e.message " " _e.extra))
    }
}