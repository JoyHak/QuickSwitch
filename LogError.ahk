LogError(_error := "", _trayLabel := "", _trayMessage := "") {
    global ERRORS, ScriptName
    
    ; Log
    FormatTime, _time,, Time
    if _error 
        _logMessage := _time " [" _error.Line "]: " _error.What " | " _error.Message A_Tab _error.Extra "`n"
    else 
        _logMessage := _time "    : " _trayLabel " | " _trayMessage "`n"

    FileAppend, %_logMessage%, %ERRORS%

    ; Display. If locals is unset, display Exception object
    _trayLabel      := _trayLabel   ? _trayLabel    : _error.What
    _trayMessage    := _trayMessage ? _trayMessage  : _error.Message
    
    TrayTip, %ScriptName%: %_trayLabel% error, %_trayMessage%,, 0x2 
    Return true
}
OnError("LogError")

;_____________________________________________________________________________
;
ValidateWriteColor(_color, _paramName) {    ; valid HEX / empty value only
;_____________________________________________________________________________ 
    global INI

    _matchPos := RegExMatch(_color, "i)[a-f0-9]{6}$")
    if (_color == "" or _matchPos > 0) {
        _result := SubStr(_color, _matchPos)
        IniWrite, %_result%, %INI%, Colors, %_paramName%
    } else {
        LogError(, _paramName, "Wrong color" _color "! Enter the HEX value")
    }
}