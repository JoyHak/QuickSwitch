/*    
    Contains functions to find the location of the TC settings file (wincmd.ini). 

    Thanks to Dalai for the search steps:
    https://www.ghisler.ch/board/viewtopic.php?p=470238#p470238
    
    Documentation about ini location:
    https://www.ghisler.ch/wiki/index.php?title=Finding_the_paths_of_Total_Commander_files
*/

GetTotalConsoleIni(ByRef totalPid) {
    ; Searches the ini through the console, throws readable error

    ; Save clipboard to restore later
    _clipSaved := ClipboardAll
    Clipboard  := ""


    ; Create new console and get its PID
    SendTotalMessage(totalPid, 511)
    _consolePid := GetTotalConsolePid(totalPid)
    
    ; Send command to the console
    static COMMAND   :=  "set commander_ini_path"
    static INI_PATH  :=  A_Temp "\ini_path.txt"
    
    SendConsoleCommand(_consolePid, COMMAND " > " INI_PATH)  ; Export
    SendConsoleCommand(_consolePid, COMMAND " | clip")       ; Copy

    ClipWait, 5
    _clip     := Clipboard
    Clipboard := _clipSaved
    Process, Close, % _consolePid


    ; Parse the result
    _log := "PID: " totalPid "CMD PID: " _consolePid
    
    if (ErrorLevel || !_clip) {
        ; Read exported file
        _log .= "Failed to copy the result to the сlipboard."

        if FileExist(INI_PATH) {
            FileRead, _iniPath, % INI_PATH

            if (_iniPath && _pos := InStr(_iniPath, "="))
                return SubStr(_iniPath, _pos + 1)

            _log .= " Exported file is empty."

        } else {
            _log .= " Failed to export the result."
        }

    } else {
        ; Parse Clipboard
        if (_pos := InStr(_clip, "=")) {
            return SubStr(_clip, _pos + 1)
        }
        _log .= " Copied result is empty."
    }

    throw Exception("Unable to get INI", "TotalCmd console", "The env. variable was successfully requested. " _log)
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalLaunchIni(ByRef totalPid) {
;─────────────────────────────────────────────────────────────────────────────
    ; Searches the ini passed to TC via /i switch
    
    if (_arg := GetProcessProperty("CommandLine", "ProcessId=" totalPid)) {
        if (_pos := InStr(_arg, "/i")) {
            ; Switch found

            if (RegExMatch(_arg, """([^""]+)""|\s+(\S+)", match, _pos + 2)) {
                ; Path in quotes / after spaces found
                return (_match1 ? _match1 : _match2)
            }
            LogError(Exception("Total Commander /i argument is invalid"))
        }    
    }

    return false
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalRegistryIni() {
;─────────────────────────────────────────────────────────────────────────────
    ; Searches the ini in the registry

    static LEAF := "Software\Ghisler\Total Commander"
    try RegRead, _regPath, HKEY_CURRENT_USER\%LEAF%, IniFileName

    if !_regPath
        try RegRead, _regPath, HKEY_LOCAL_MACHINE\%LEAF%, IniFileName

    if !_regPath
        return false

    ; Resolve env. variables
    _ini := _env := ""
    for _i, _part in StrSplit(_regPath, "`%") {
        try EnvGet, _env, % _part
        if _env
            _ini .= _env
        else
            _ini .= _part
    }
    
    return _ini
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalPathIni(ByRef totalPid) {
;─────────────────────────────────────────────────────────────────────────────
    ; Searches the ini in the current TC directory
    WinGet, _winPath, ProcessPath, ahk_pid %totalPid%

    ; Remove exe name and leading slash \
    _winPath := SubStr(_winPath, 1, InStr(_winPath, "\",, -12) - 1)
    
    _ini := ""
    Loop, Files, %_winPath%\wincmd.ini, R
    {
        _ini := A_LoopFileLongPath

        ; https://www.ghisler.ch/wiki/index.php/Wincmd.ini
        IniRead, _flag, % _ini,	Configuration, UseIniInProgramDir, 0

        if !(_flag & 4) {
            _reg := GetTotalRegistryIni()
            
            if (_reg && FileExist(_reg))
                return _reg
            
            LogInfo("Registry config key is empty, but UseIniInProgramDir=" _flag " Search in current TC directory")
        }
        break
    }

    return _ini
}