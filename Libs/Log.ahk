LogError(_error) {
    global ERRORS, ScriptName
    
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
    FormatTime, _time,, Time
    FileAppend, % _time "    [" _stack _what "]    " _msg "    " _error.Extra "`n", % ERRORS
    
    TrayTip, % ScriptName ": " _what " error", % _msg,, 0x2 
    Return true
}
OnError("LogError")


LogHeader() {
    ; Header about log and OS
    global ERRORS

    FileAppend, Contains only %ScriptName% errors! `n, % ERRORS
    FileAppend, Report about error: https://github.com/JoyHak/QuickSwitch/issues/new?template=bug-report.yaml `n, % ERRORS
    FileAppend, AHK %A_AhkVersion% `n, % ERRORS    
        
    _reg := "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    RegRead, _OSname, % _reg, ProductName
    RegRead, _OSversion, % _reg, DisplayVersion
    RegRead, _OSbuild, % _reg, CurrentBuild
    FileAppend, % _OSname " " _OSversion "|" _OSbuild " [lang " A_Language "]`n`n", % ERRORS   ; A_Language 4-digit code: https://www.autohotkey.com/docs/v1/misc/Languages.htm
}

LogInfo() {
    ; Info about current launched script/compiled app
    global ERRORS
    
    FileAppend, `n-------- `n`n, % ERRORS
    /*@Ahk2Exe-Keep
        FileAppend, Script is compiled by %A_UserName% `n, % ERRORS
        
        FileGetVersion, _ver, % A_ScriptFullPath
        FileAppend, Version: %_ver% `n`n, % ERRORS
    */
    _bit  := A_PtrSize * 8
    _arch := A_Is64bitOS ? "64-bit" : "32-bit"
    FileAppend, %_bit%-bit script for %_arch% system `n`n, % ERRORS 
}

ValidateLog() {
    global INI, ERRORS, ScriptName
    
    if FileExist(ERRORS) { 
        ; Clean log
        FileGetSize, _size, % ERRORS, K
        if (_size > 30) {
            FileDelete, % ERRORS
            Sleep, 500
        }    
    }
    if !FileExist(ERRORS) 
        LogHeader()
    
    ; does the cur. dir. match the dir. of the script that previously created this log?
    IniRead, _lastPath, % INI, App, _lastPath
    _curPath := A_ScriptFullPath
    if (_lastPath != _curPath) {
        ; New info about the script
        IniWrite, % _curPath, % INI, App, _lastPath
        LogInfo()
    }
    
    FormatTime, _date
    FileAppend, `n-------- %A_ScriptName% started at %_date% `n`n, % ERRORS
}