#Include %A_LineFile%\..\TotalCommander
#Include Ini.ahk
#Include Search.ahk
#Include Create.ahk
#Include Tabs.ahk

GetTotalPaths(ByRef winId, ByRef paths) {
    /*
        Requests tabs file.

        If unsuccessful, searches for the location of wincmd.ini to create usercmd.ini
        in that directory with the EM_ user command to export tabs to the file
    */

    static userCmd      :=  "EM_ScriptCommand_QuickSwitch_SaveAllTabs"
    static internalCmd  :=  "SaveTabs2"
    static tabsFile     :=  A_Temp "\TotalTabs.tab"

    try {
        SendTotalUserCmd(winId, userCmd)
        ParseTotalTabs(tabsFile, paths)
    } catch _ex {
        WinGet, _winPid, % "pid", % "ahk_id " winId
        
        if (!A_IsAdmin && IsProcessElevated(_winPid))
            throw Exception("Unable to obtain TotalCmd paths"
                          , "admin permission"
                          , _ex.what " " _ex.message " " _ex.extra)

        LogInfo("Required to create TotalCmd command: " userCmd, "NoTraytip")
        CreateTotalUserCmd(GetTotalIni(winId), userCmd, internalCmd, tabsFile)
        
        Sleep 200
        SendTotalUserCmd(winId, userCmd)
        ParseTotalTabs(tabsFile, paths)
    }
}