/*
    Contains functions for getting information about the app's operation and additional information.
    Any user notification functions should be placed here.
    "ErrorsLog" param must be a path to a write-accessible file (with any extension)
    Library must be imported first!
 */

LogError(_error) {
    ; Accepts Exception object or any custom object with similar attributes
    global ErrorsLog, ScriptName

    ; Generate call stack
    _stack := ""
    Loop {
        ; Skip current func
        _e    := Exception(".", _offset := -A_Index-1)
        _call := _e.What

        if (_call = _offset)
            break

        _stack := _call " > " _stack
    }

    ; Log
    _what := _error.What
    _msg  := _error.Message

    FormatTime, _date,, dd.MM hh:mm:ss
    FileAppend, % _date "    [" _stack _what "]    " _msg "    " _error.Extra "`n", % ErrorsLog

    TrayTip, % ScriptName ": " _what " error", % _msg,, 0x2
    Return true
}

LogInfo(ByRef msg, _silent := false) {
    global ErrorsLog, ScriptName

    FormatTime, _date,, dd.MM hh:mm:ss
    FileAppend, % _date "    " msg "`n", % ErrorsLog

    if !_silent
        TrayTip, % ScriptName " log", % msg
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

    FileAppend,
    (LTrim
     Report about error: %REPORT_LINK%
     AHK %A_AhkVersion%
     %_OSname% %_OSversion% | %_OSbuild% %_lang%

    ), % ErrorsLog
}

LogVersion() {
    ; Info about current launched script/compiled app
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
    FileAppend, % _header, % ErrorsLog
}

InitLog() {
    global INI, ErrorsLog, ScriptName

    if FileExist(ErrorsLog) {
        ; Clean log
        FileGetSize, _size, % ErrorsLog, K
        if (_size > 30) {
            FileDelete, % ErrorsLog
            Sleep, 500
        }
    }
    if !FileExist(ErrorsLog) {
        LogHeader()
        LogVersion()
        return
    }

    ; does the cur. dir. match the dir. of the script that previously created this log?
    IniRead, _lastPath, % INI, App, LastPath
    _curPath := A_ScriptFullPath
    if (_lastPath != _curPath) {
        ; New info about the script
        try IniWrite, % _curPath, % INI, App, LastPath
        LogVersion()
    }
}