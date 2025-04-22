/*
    Contains functions to find the location of the TC settings file (wincmd.ini).

    Thanks to Dalai for the search steps:
    https://www.ghisler.ch/board/viewtopic.php?p=470238#p470238

    Documentation about ini location:
    https://www.ghisler.ch/wiki/index.php?title=Finding_the_paths_of_Total_Commander_files
*/

GetTotalConsoleIni(ByRef totalPid) {
    ; Searches the ini through the console, throws readable error
    
    global ScriptName
    if (ProcessIsElevated(totalPid) && !A_IsAdmin) {
        throw Exception("Unable to open TotalCmd console", "admin permission", "`nRun " ScriptName " as admin / with UI access or run TC as not admin.`nThis will allow " ScriptName " to get the exact configuration directly from TC console.")
    }
    
    ; Save clipboard to restore later
    _clipSaved := ClipboardAll
    Clipboard  := ""

    ; Create new console process and get its PID
    SendTotalMessage(totalPid, 511)
    _consolePid := GetTotalConsolePid(totalPid)
    
    ; Send command to the console
    static COMMAND   :=  "echo `%commander_ini`%"
    static INI_PATH  :=  A_Temp "\ini_path.txt"

    SendConsoleCommand(_consolePid, COMMAND " > " INI_PATH)  ; Export
    sleep, 150
    SendConsoleCommand(_consolePid, COMMAND " | clip")       ; Copy

    ClipWait, 5
    _clip     := Clipboard
    Clipboard := _clipSaved    
    try Process, Close, % _consolePid    

    ; Parse the result
    _log := "TotalCmd PID: " totalPid " Console PID: " _consolePid

    if !_clip {
        ; Read exported file
        _log .= " Failed to copy the result to the clipboard."

        if FileExist(INI_PATH) {
            FileRead, _iniPath, % INI_PATH

            if _iniPath {
                LogInfo(_log, true)
                return _iniPath
            }

            _log .= " Exported file is empty."

        } else {
            _log .= " Failed to export the result."
        }

    } else {
        LogInfo(_log " The result is copied to the clipboard.", true)
        return _clip
    }

    _log .= " Copied result is empty."
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

            if (RegExMatch(_arg, "[""`']([^""`']+)[""`']|\s+([^\/\r\n""`']+)", _match, _pos)) {
                LogInfo("Found /i launch argument", true)
                return (_match1 ? _match1 : _match2)
            }
            LogError(Exception("/i argument is invalid", "TotalCmd argument", "Cant find quotes or spaces after /i"))
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

    if InStr(_regPath, "`%") {
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
    return _regPath
}

;─────────────────────────────────────────────────────────────────────────────
;
UseIniInProgramDir(ByRef ini) {
;─────────────────────────────────────────────────────────────────────────────
    ; This flag affects the choice of configuration: from the registry or from the TC directory
    ; https://www.ghisler.ch/wiki/index.php/Wincmd.ini
    
    _flag := 0
    IniRead, _flag, % ini, Configuration, UseIniInProgramDir, 0
    LogInfo("Config: UseIniInProgramDir=" _flag, true)
    
    return (_flag & 4)
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalPathIni(ByRef totalPid) {
;─────────────────────────────────────────────────────────────────────────────
    ; Searches the ini in the current TC directory
    WinGet, _winPath, ProcessPath, ahk_pid %totalPid%

    ; Remove exe name
    _winPath := SubStr(_winPath, 1, InStr(_winPath, "\",, -12))
    
    _ini := ""
    Loop, Files, % _winPath "wincmd.ini", R
    {
        _ini := A_LoopFileLongPath
        break
    }
    
    ; Search in TC directory and in registry and make decisions
    _reg := GetTotalRegistryIni()

    if _ini {
        LogInfo("Found config in TotalCmd directory", true)
        
        if UseIniInProgramDir(_ini)
            return _ini       
        
        if _reg {
            LogInfo("Found config in registry", true)            
            
            if UseIniInProgramDir(_reg) {
                LogInfo("Ignored registry config key", true)
                return _ini
            }          
            
            return _reg
        }  
        
        LogInfo("Registry config key is empty", true)
        return _ini
    }
    
    if _reg {
        LogInfo("Сonfig not found in TotalCmd directory but found in registry", true)
        return _reg
    }

    throw Exception("Unable to find wincmd.ini", "TotalCmd config", "Config not found in current TC directory and registry is empty")
}