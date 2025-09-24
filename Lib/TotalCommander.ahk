#Include %A_LineFile%\..\TotalCommander
#Include Ini.ahk
#Include Search.ahk
#Include Create.ahk
#Include Tabs.ahk

TTOTAL_CMD(ByRef winId, ByRef paths, _activeTabOnly := false, _showLockedTabs := false) {
    /*
        Requests tabs file.

        If unsuccessful, searches for the location of wincmd.ini to create usercmd.ini
        in that directory with the EM_ user command to export tabs to the file
    */

    static userCmd      :=  "EM_ScriptCommand_QuickSwitch_SaveAllTabs2"
         , internalCmd  :=  "SaveTabs2"
         , tabsDir      :=  A_Temp "\TotalTabs"
         , tabsFile     :=  tabsDir "\TotalTabs.tab"
         , lastWinId    :=  0
         , userIni      :=  ""
    
    try {
        if (_activeTabOnly && _showLockedTabs)
            return GetTotalActiveTab(winId, paths)
        
        SendTotalUserCmd(winId, userCmd)       
        WaitForTabs(tabsDir, tabsFile)
        
        if _activeTabOnly
            return GetTotalUnlockedTab(tabsFile, paths)
        
        return ParseTotalTabs(tabsFile, paths, _showLockedTabs)
        
    } catch _ex {
        ; Get proccess permissions
        WinGet, _winPid, % "pid", % "ahk_id " winId        
        if (!A_IsAdmin && IsProcessElevated(_winPid))
            throw Exception("Unable to obtain TotalCmd paths"
                          , "admin permission"
                          , _ex.what " " _ex.message " " _ex.extra)
        
        ; Check if required dir exists
        dirWasCreated := false 
        if !FileExist(tabsDir) {
            FileCreateDir % tabsDir
            dirWasCreated := true
        }
        
        ; Create user command and retry
        if (lastWinId != winId) {
            LogInfo("Required to create user command: [" userCmd "]", "NoTraytip")
            userIni := GetTotalIni(winId, _winPid)
        }
        lastWinId := winId
        
        ; Retry if user command or new dir was successfully created
        if (CreateTotalUserCmd(userIni, userCmd, internalCmd, tabsFile)
         || dirWasCreated) {
            return TTOTAL_CMD(winId, paths, _activeTabOnly, _showLockedTabs)
        }
        
        ; The user command already exists. Re-throw exception to the caller      
        throw _ex
    }
}