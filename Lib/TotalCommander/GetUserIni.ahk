GetTotalIni(ByRef winId, ByRef processId) {
    /*
    Searches for the location of wincmd.ini
    Needed to create usercmd.ini in that directory
    with the "cmd" user command

    Thanks to Dalai for the search steps:
    https://www.ghisler.ch/board/viewtopic.php?p=470238#p470238
    */

    ; Close the child windows of the current TC instance
    ; to ensure that messages are sent correctly
    WinWaitActive, % "ahk_class #32770 ahk_pid " processId,, 0.25
    CloseChildWindows(processId, winId)

    _ini := ""
    for _, _func in ["GetTotalConsoleIni", "GetTotalLaunchIni", "GetTotalPathIni"] {
        try if (_ini := %_func%(processId))
            break
        catch _ex {
            _ex.what := _func
            _ex.extra .= " PID: " processId
            LogException(_ex)
        }
    }

    if !IsFile(_ini)
        throw Exception("Unable to find wincmd.ini"
                        , "TotalCmd config"
                        , "File `'" _ini "`' not found. Change your TC configuration settings")

    LogInfo("Found TotalCmd config: `'" _ini "`'", "NoTraytip")
    return SubStr(_ini, 1, InStr(_ini, "\",, -1)) . "usercmd.ini"
}