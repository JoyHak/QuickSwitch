GetTotalcmdTabs(ByRef winId) {
    /*     
        Creates user command (if necessary) in usercmd.ini 
        and uses it to request the current tabs file. 
        If the second panel is enabled, file contains tabs from all panels, 
        otherwise file contains tabs from the active panel 
    */
        
    static COMMAND := "EM_SaveAllTabs"
    static REG     := "HKEY_CURRENT_USER\SOFTWARE\Ghisler\Total Commander"
    static created := false
    static TABS_RESULT
    
    if created
        return TABS_RESULT
    
    ; Search for TC root directory
    RegRead, _regPath, % REG, InstallDir
    WinGet, _winPath, ProcessPath, ahk_id %winId%
 
    ; Remove exe name and leading slash \
    _winPath := SubStr(_winPath, 1, InStr(_winPath, "\",, -12) - 1) 
    
    ; Search for configuration in registry
    _ini := ""
    if (_winPath = _regPath) {
        RegRead, _iniPath, % REG, IniFileName
        
        ; Convert env. variables        
        for _i, _part in StrSplit(_iniPath, "`%") {
            EnvGet, _env, % _part
            if _env
                _ini .= _env        
            else 
                _ini .= _part
        }
        
        ; Remove ini name and leading slash \
        _root := SubStr(_ini, 1, InStr(_ini, "\",, -10) - 1) 
    } 

    ; Registry path is invalid, search in current TC directory
    if !FileExist(_ini) {
        _root := _winPath
        Loop, Files, %_root%\wincmd.ini, R
        {   
            _ini := A_LoopFileLongPath
            break
        }
    }
    
    ; Config not found after 2 attempts    
    if !FileExist(_ini)
        return LogError(Exception("Unable to find wincmd.ini", "Total Commander config", "File `'" _ini "`' not found. Change your TC configuration settings: your configuration should be in any sub-directory in the " _root))
    
    _ini := StrReplace(_ini, "wincmd", "usercmd")      
    TABS_RESULT := _root "\Tabs.tab"     
        
    ; Check and create user command
    loop, 4 {
        ; Read the contents of the config until it appears or the loop ends with an error
        IniRead, _section, % _ini, % COMMAND
        if (_section && _section != "ERROR") {
            created := true
            return TABS_RESULT
        }            
        
        ; Set normal attributes (write access)
        FileSetAttrib, n, % _root
        FileSetAttrib, n, % _ini
        sleep, 20 * A_Index
        
        ; Create new section
        FileAppend,
        (LTrim
         # Please dont add commands with the same name
         [%COMMAND%]
         cmd=SaveTabs2 
         param=`"%TABS_RESULT%`"
            
        ), % _ini
        sleep, 50 * A_Index
    }
    return LogError(Exception("Unable to create configuration", "Total Commander config", _ini " doesnt exist and cannot be created. Create it manually in the " _root))
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalcmdPaths(ByRef winId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Requests a file with current tabs and analyzes it. 
    ; Searches for the active tab using the "activetab" parameter
    global Paths
       
    try { 
        _tabs := GetTotalcmdTabs(winId)
        try FileDelete, % _tabs
        SendTotalCommand(winId, "EM_SaveAllTabs")
        
        loop, 600 {
            if FileExist(_tabs) {
                _paths  := []
                
                ; Tabs index starts with 0, array index starts with 1
                _active := _last := 0
                
                Loop, read, % _tabs
                {
                    ; Omit the InStr key and SubStr from value position
                    if (_pos := InStr(A_LoopReadLine, "path=")) {  
                        _path := SubStr(A_LoopReadLine, _pos + 5)
                        _paths.push(RTrim(_path, "\"))
                    }
                    if (_num := InStr(A_LoopReadLine, "activetab=")) {
                        ; Skip next active tab by saving last
                        _active := _last
                        _last   := SubStr(A_LoopReadLine, _num + 10)                
                    }
                }

                ; Push the active tab to the global array first
                Paths.push(_paths[_active + 1])
                
                ; Remove duplicate and add the remaining tabs
                _paths.removeAt(_active + 1)
                Paths.push(_paths*)
                return
            }
            sleep, 20
        }
        return LogError(Exception("Unable to access tabs", "Total Commander tabs", "Restart Total Commander and retry"))
        
    } catch _error {
        LogError(_error)
    }
}