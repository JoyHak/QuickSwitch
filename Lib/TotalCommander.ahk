#Include %A_LineFile%\..\TotalCommander
#Include Ini.ahk
#Include Search.ahk
#Include Create.ahk
#Include Tabs.ahk

GetTotalPaths(ByRef winId, ByRef array) {
    /*
        Requests tabs file.

        If unsuccessful, searches for the location of wincmd.ini to create usercmd.ini
        in that directory with the EM_ user command to export tabs to the file
    */

    static USER_COMMAND     :=  "EM_ScriptCommand_QuickSwitch_SaveAllTabs"
    static EXPORT_COMMAND   :=  "SaveTabs2"
    static TABS_FILE        :=  A_Temp "\TotalTabs.tab"

    try {
        SendTotalCommand(winId, USER_COMMAND)
        ParseTotalTabs(TABS_FILE, array)
    } catch {
        WinGet, _winPid, pid, % "ahk_id " winId
        if (!A_IsAdmin && IsProcessElevated(_winPid))
            throw Exception("Unable to obtain TotalCmd paths", "admin permission")

        LogInfo("Required to create TotalCmd command: " USER_COMMAND, true)

        _userIni := GetTotalIni(winId)
        CreateTotalUserCommand(_userIni, USER_COMMAND, EXPORT_COMMAND, TABS_FILE)

        SendTotalCommand(winId, USER_COMMAND)
        ParseTotalTabs(TABS_FILE, array)
    }
}