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
    _clipSaved   := ClipboardAll
    A_Clipboard  := ""

    ; Create new console process and get its PID
    SendTotalInternalCmd(totalPid, 511)
    _consolePid := GetTotalConsolePid(totalPid)

    ; Send command to the console
    static command     :=  "echo %commander_ini%"
    static exportFile  :=  A_Temp "\TotalCmdIni.txt"

    SendConsoleCommand(_consolePid, command " > " exportFile)  ; Export
    Sleep 150
    SendConsoleCommand(_consolePid, command " | clip")         ; Copy

    ClipWait 5
    _clip       := A_Clipboard
    A_Clipboard := _clipSaved
    try Process, Close, % _consolePid

    ; Parse the result
    _log := "TotalCmd PID: " totalPid " Console PID: " _consolePid
    
    if _clip {
        LogInfo(_log " The result is copied to the clipboard.", "NoTraytip")
        return _clip
    }
    

    ; Read exported file
    _log .= " Failed to copy the result to the clipboard."

    if IsFile(exportFile) {
        FileRead, _path, % exportFile

        if _path {
            LogInfo(_log, "NoTraytip")
            return _path
        }

        _log .= " Exported file is empty."

    } else {
        _log .= " Failed to export the result."
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

            if (RegExMatch(_arg, "[""`']([^""`']+)[""`']|\s+([^\/\r\n""`']+)", _match, _pos)) {
                LogInfo("Found /i launch argument", "NoTraytip")
                return (_match1 ? _match1 : _match2)
            }
            LogError("/i argument is invalid", "TotalCmd argument", "Cant find quotes or spaces after /i")
        }
    }

    return false
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalRegistryIni() {
;─────────────────────────────────────────────────────────────────────────────
    ; Searches the ini in the registry

    static totalCmd := "Software\Ghisler\Total Commander"
    static iniKey   := "IniFileName"
    _path := ""
    
    try RegRead, _path, % "HKEY_CURRENT_USER\" totalCmd, % iniKey

    if !_path
        try RegRead, _path, % "HKEY_LOCAL_MACHINE\" totalCmd, % iniKey

    if !_path
        return ""

    ExpandVariables(_path)
    return _path
}

;─────────────────────────────────────────────────────────────────────────────
;
UseIniInProgramDir(ByRef ini) {
;─────────────────────────────────────────────────────────────────────────────
    ; This flag affects the choice of configuration: from the registry or from the TC directory
    ; https://www.ghisler.ch/wiki/index.php/Wincmd.ini

    _flag := 0
    IniRead, _flag, % ini, % "Configuration", % "UseIniInProgramDir", 0
    LogInfo("Config: UseIniInProgramDir=" _flag, "NoTraytip")

    return (_flag & 4)
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalPathIni(ByRef totalPid) {
;─────────────────────────────────────────────────────────────────────────────
    ; Searches the ini in the current TC directory
    WinGet, _winPath, % "ProcessPath", % "ahk_pid " totalPid

    ; Remove exe name
    _winPath := SubStr(_winPath, 1, InStr(_winPath, "\",, -12))

    _ini := ""
    Loop, Files, % _winPath "wincmd.ini", R
    {
        _ini := A_LoopFileFullPath
        break
    }

    ; Search in TC directory and in registry and make decisions
    _reg := GetTotalRegistryIni()

    if _ini {
        LogInfo("Found config in TotalCmd directory", "NoTraytip")

        if UseIniInProgramDir(_ini)
            return _ini

        if _reg {
            LogInfo("Found config in registry", "NoTraytip")

            if UseIniInProgramDir(_reg) {
                LogInfo("Ignored registry config key", "NoTraytip")
                return _ini
            }

            return _reg
        }

        LogInfo("Registry config key is empty", "NoTraytip")
        return _ini
    }

    if _reg {
        LogInfo("Сonfig not found in TotalCmd directory but found in registry", "NoTraytip")
        return _reg
    }

    throw Exception("Unable to find wincmd.ini"
                    , "TotalCmd config"
                    , "Config not found in current TC directory and registry is empty")
}