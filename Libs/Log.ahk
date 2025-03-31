LogError(_error) {
    global ErrorsLog, ScriptName

    ; generate call stack
    _stack := ""
	Loop {
		_e := Exception(".", offset := -A_Index-1)  ; skip current func
        _call := _e.What
		if (_call == offset)
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

LogHeader() {
    ; Header about log and OS
    global ErrorsLog, BugReportLink, ScriptName

    _reg := "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    RegRead, _OSname, % _reg, ProductName
    RegRead, _OSversion, % _reg, DisplayVersion
    RegRead, _OSbuild, % _reg, CurrentBuild

    FileAppend,
    (LTrim
        Contains only %ScriptName% errors!
        Report about error: %BugReportLink%
        AHK %A_AhkVersion%
        %_OSname% %_OSversion% | %_OSbuild% [lang %A_Language%]


    ), % ErrorsLog

    ; A_Language 4-digit code: https://www.autohotkey.com/docs/v1/misc/Languages.htm
}

LogInfo() {
    ; Info about current launched script/compiled app
    global ErrorsLog

    _bit  := A_PtrSize * 8
    _arch := A_Is64bitOS ? "64-bit" : "32-bit"

    _header := "`n"
    /*@Ahk2Exe-Keep
        FileGetVersion, _ver, % A_ScriptFullPath
        _header .= "Script is compiled. Version: " _ver "`n"
    */
    _header .= _bit "-bit script for " _arch " system `n`n"
    FileAppend, % _header, % ErrorsLog
}

ValidateLog() {
    global INI, ErrorsLog, ScriptName

    if (FileExist(ErrorsLog)) {
        ; Clean log
        FileGetSize, _size, % ErrorsLog, K
        if (_size > 30) {
            FileDelete, % ErrorsLog
            Sleep, 500
        }
    }
    if !FileExist(ErrorsLog) {
        LogHeader()
        LogInfo()
        Return
    }

    ; does the cur. dir. match the dir. of the script that previously created this log?
    IniRead, _lastPath, % INI, App, LastPath
    _curPath := A_ScriptFullPath
    if (_lastPath != _curPath) {
        ; New info about the script
        IniWrite, % _curPath, % INI, App, LastPath
        LogInfo()
    }
}