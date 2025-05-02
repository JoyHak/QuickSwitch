GetTotalIni(ByRef winId) {
    /*     
        Searches for the location of wincmd.ini 
        Needed to create usercmd.ini in that directory 
        with the "cmd" user command
    
        Thanks to Dalai for the search steps:
        https://www.ghisler.ch/board/viewtopic.php?p=470238#p470238
    */ 
    
    WinGet, _winPid, PID, ahk_id %winId%

    ; Close the child windows of the current TC instance
    ; to ensure that messages are sent correctly
    CloseChildWindows(winId, _winPid)
    
    _ini := ""
    for _index, _func in ["GetTotalConsoleIni", "GetTotalLaunchIni", "GetTotalPathIni"] {
        try {
            if (_ini := Func(_func).call(_winPid)) {
                break
            }

        } catch _e {
            LogError(_e)
        }
    }

    if _ini
        _ini := RTrim(_ini, " `r`n\/")

    if !FileExist(_ini)
        throw Exception("Unable to find wincmd.ini"
                        , "TotalCmd config"
                        , "File `'" _ini "`' not found. Change your TC configuration settings")

    LogInfo("Found Total Commander config: `'" _ini "`'", "NoTraytip")

    ; Remove ini name
    _pos := (_in := InStr(_ini, "\",, -1)) ? _in : InStr(_ini, "/",, -1)
    return (SubStr(_ini, 1, _pos) . "usercmd.ini")
}