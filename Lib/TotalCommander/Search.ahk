GetTotalIni(ByRef winId) {
    /*
        Searches for the location of wincmd.ini
        Needed to create usercmd.ini in that directory
        with the "cmd" user command

        Thanks to Dalai for the search steps:
        https://www.ghisler.ch/board/viewtopic.php?p=470238#p470238
    */

    WinGet, _winPid, % "pid", % "ahk_id " winId

    ; Close the child windows of the current TC instance
    ; to ensure that messages are sent correctly
    CloseChildWindows(_winPid, winId)

    _ini := ""
    for _, _func in ["GetTotalConsoleIni", "GetTotalLaunchIni", "GetTotalPathIni"] {
        try {
            if (_ini := %_func%(_winPid)) {
                break
            }
        } catch _ex {
            LogException(_ex)
        }
    }

    if _ini {
        _ini := RTrim(_ini, " `r`n\/")
        _ini := StrReplace(_ini, "/" , "\")
    }

    if !IsFile(_ini)
        throw Exception("Unable to find wincmd.ini"
                        , "TotalCmd config"
                        , "File `'" _ini "`' not found. Change your TC configuration settings")

    LogInfo("Found TotalCmd config: `'" _ini "`'", "NoTraytip")
    return SubStr(_ini, 1, InStr(_ini, "\",, -1)) . "usercmd.ini"
}