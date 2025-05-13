/*
    Contains functions for getting information about the app's operation and additional information.
    Any user notification functions should be placed here.
    "ErrorsLog" param must be a path to a write-accessible file (with any extension)
    Library must be imported first!
 */

MsgWarn(_text) {
    ; Yes/No, Warn icon, default is "No", always on top without title bar
    MsgBox, % (4 + 48 + + 256 + 262144), , % _text
    IfMsgBox Yes
        return true

    return false
}

LogError(_message := "Unknown error", _what := "LogError", _extra := "") {
    return LogException(Exception(_message, _what, _extra), 2)
}

LogException(_ex, _offset := 1) {
    ; Accepts Exception / any custom object with similar attributes
    global ErrorsLog, ScriptName

    ; Generate call stack
    _stack := ""
    Loop {
        ; Skip functions from stack using the offset
        _e    := Exception(".", _index := - A_Index - _offset)
        _func := _e.what

        if (_func = _index)
            break

        _stack := _func " > " _stack
    }

    ; Log
    _what := _ex.what
    _msg  := _ex.message

    FormatTime, _date,, dd.MM HH:mm:ss
    try FileAppend, % _date "    [" _stack _what "]    " _msg "    " _ex.extra "`n", % ErrorsLog

    TrayTip, % ScriptName ": " _what " error", % _msg,, 0x2
    return false
}

LogInfo(_text, _silent := false) {
    global ErrorsLog, ScriptName

    FormatTime, _date,, dd.MM HH:mm:ss
    try FileAppend, % _date "    " _text "`n", % ErrorsLog

    if !_silent
        TrayTip, % ScriptName " log", % _text
}

LogHeader() {
    ; Header about log and OS
    global ErrorsLog, ScriptName

    static REPORT_LINK  :=  "https://github.com/JoyHak/QuickSwitch/issues/new?template=bug-report.yaml"
    static LEAF         :=  "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

    RegRead, _OSname, % LEAF, ProductName
    RegRead, _OSversion, % LEAF, DisplayVersion
    RegRead, _OSbuild, % LEAF, CurrentBuild
    RegRead, _lang, HKEY_CURRENT_USER\Control Panel\International, LocaleName

    try FileAppend, % "
    (LTrim
        Report about error: " REPORT_LINK "
        AHK " A_AhkVersion "
        " _OSname " " _OSversion " | " _OSbuild " " _lang "

    )", % ErrorsLog
}

LogVersion() {
    ; Info about current launched script / compiled app
    global ErrorsLog

    _bit  := (A_PtrSize * 8) . "-bit"
    _arch := A_Is64bitOS ? "64-bit" : "32-bit"

    _header := "`n"
    /*@Ahk2Exe-Keep
        _ver := ""
        try FileGetVersion, _ver, % A_ScriptFullPath
        _header .= "Script is compiled. Version: " _ver "`n"
    */
    _header .= _bit " script for " _arch " system `n`n"
    try FileAppend, % _header, % ErrorsLog
}

InitLog() {
    global INI, ErrorsLog, ScriptName

    ; Clean log
    if FileExist(ErrorsLog) {
        FileGetSize, _size, % ErrorsLog, K
        if (_size > 8) {
            FileRecycle, % ErrorsLog
            Sleep, 500
        }
    }

    ; Create again after cleanup / first launch
    if !FileExist(ErrorsLog) {
        LogHeader()
        LogVersion()
        return
    }

    ; does the cur. dir. match the dir. of the script
    ; that previously created this log?
    _curPath := A_ScriptFullPath
    IniRead, _lastPath, % INI, App, LastPath
    if ((_lastPath != "ERROR") && (_lastPath != _curPath)) {
        ; New info about the script
        try IniWrite, % _curPath, % INI, App, LastPath
        LogVersion()
    }
}