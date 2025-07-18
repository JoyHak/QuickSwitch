/*
    Contains functions for getting information about the app's operation and additional information.
    Any user notification functions should be placed here.
    "ErrorsLog" param must be a path to a write-accessible file (with any extension)
    Library must be imported first!
 */

MsgWarn(_text) {
    ; Yes/No, Warn icon, default is "No", always on top without title bar
    MsgBox, % (4 + 48 + 256 + 262144),, % _text
    IfMsgBox, % "yes"
        return true

    return false
}

LogError(_message := "Unknown error", _what := "LogError", _extra := "", _silent := false) {
    return LogException(Exception(_message, _what, _extra), 2, _silent)
}

LogException(_ex, _offset := 1, _silent := false) {
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
    
    if !_silent
        TrayTip, % ScriptName ": " _what " error", % _msg,, 0x2
    
    return ""
}

LogInfo(_text, _silent := false) {
    global ErrorsLog, ScriptName

    FormatTime, _date,, dd.MM HH:mm:ss
    try FileAppend, % _date "    " _text "`n", % ErrorsLog

    if !_silent
        TrayTip, % ScriptName " log", % _text
    
    return ""
}

InitLog() {
    global INI, ErrorsLog, ScriptName

    ; Clean log
    if IsFile(ErrorsLog) {
        FileGetSize, _size, % ErrorsLog, K
        if (_size > 8) {
            FileRecycle, % ErrorsLog
            Sleep, 500
        }
    }

    ; Create again after cleanup / first launch
    if !IsFile(ErrorsLog) {
        try FileAppend, % "
        (LTrim
            Report about error: https://github.com/JoyHak/QuickSwitch/issues/new?template=bug-report.yaml
            AHK " A_AhkVersion "
            " A_ScriptName "
            
        )", % ErrorsLog
        
        return
    }

    ; Does the cur. dir. match the dir. of the script
    ; That previously created this log?
    _curPath := A_ScriptFullPath
    IniRead, _lastPath, % INI, % "App", % "LastPath", % A_Space
    if (_lastPath && (_lastPath != _curPath)) {
        ; New info about the script
        try IniWrite, % _curPath, % INI, % "App", % "LastPath"
        try FileAppend, % "`n`n`n" A_ScriptName "`n`n", % ErrorsLog
    }
}