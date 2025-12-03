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

    FormatTime, _date,, % "dd.MM HH:mm:ss"
    try FileAppend, % _date "    [" _stack _what "]    " _msg "    " _ex.extra "`n", % ErrorsLog
    
    if !_silent
        TrayTip, % ScriptName ": " _what " error", % _msg,, 0x2
    
    return ""
}

LogInfo(_text, _silent := false) {
    global ErrorsLog, ScriptName

    FormatTime, _date,, % "dd.MM HH:mm:ss"
    try FileAppend, % _date "    " _text "`n", % ErrorsLog

    if !_silent {        
        ; ToolTip % _text
        TrayTip, % ScriptName " log", % _text
    }
    
    return ""
}

LogHeader() {
    ; Header with information about OS and script
    global ErrorsLog
    
    static REPORT_LINK := "https://github.com/JoyHak/QuickSwitch/issues/new?template=bug-report.yaml"
    static NT_VERSION  := "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    
    _name    := A_OSType
    _version := ""
    _build   := A_OSVersion
    _lang    := A_Language
    _bitness := A_Is64bitOS ? "64-bit" : "32-bit"
       
    try RegRead, _version, % NT_VERSION, % "DisplayVersion"
    try RegRead, _build,   % NT_VERSION, % "CurrentBuild"
    try RegRead, _lang, % "HKEY_CURRENT_USER\Control Panel\International", % "LocaleName"
    
    ; "ProductName" registry key shows incorrect OS name
    ; https://dennisbabkin.com/blog/?t=how-to-tell-the-real-version-of-windows-your-app-is-running-on#ver_string
    try if !(_name := DllCall("winbrand.dll\BrandingFormatString", "str", "%WINDOWS_LONG%", "str")) {
        try RegRead, _name, % NT_VERSION, % "ProductName"
    }
             
    FileAppend, % "
    (LTrim
    Report about error: " REPORT_LINK "
    AHK " A_AhkVersion "
    " _name " " _version " | " _build " " _bitness " " _lang "

        
    )", % ErrorsLog
}
       

ClearLog(_enforce := false) {
    global ErrorsLog

    try {       
        _size := 0
        FileGetSize, _size, % ErrorsLog, K
        if (_size < 7 && !_enforce)
            return ""
        
        _date := ""
        try {                
            FileGetTime, _date, % ErrorsLog, M
            FormatTime, _date, % _date, % "dd.MM HH:mm:ss"
        }
        
        FileRecycle, % ErrorsLog
        Sleep, 500
        return Format("The previous log has been deleted "
                    . "({} KB, last modified {}). See Recycle Bin"
                    , _size, _date)
        
    } catch _ex {
        return LogError("Unable to clean the log"  
                      , "Log cleanup"
                      , _ex.what " " _ex.message " " _ex.extra)
    }  
}

InitLog() {
    global INI, ErrorsLog

    try {
        ; Clear the log
        _logClearedMsg := ""
        if IsFile(ErrorsLog)            
            _logClearedMsg := ClearLog()
            
        ; Create log after cleanup / first launch
        if !IsFile(ErrorsLog)
            LogHeader() 
        
        if _logClearedMsg
            LogInfo(_logClearedMsg, "NoTrayTip")
            
    } catch _ex {
        LogError("Unable to initialize the log"  
               , "Log init"
               , _ex.what " " _ex.message " " _ex.extra)
    }
}