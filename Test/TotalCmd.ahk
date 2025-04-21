#Requires AutoHotkey v1.1+

#Include C:\Configs and settings\AutoHotKey\QuickSwitch\Test\Include.ahk

#Include C:\Configs and settings\AutoHotKey\QuickSwitch\Libs\Log.ahk
#Include C:\Configs and settings\AutoHotKey\QuickSwitch\Libs\ManagerMessages.ahk
#Include C:\Configs and settings\AutoHotKey\QuickSwitch\Libs\Processes.ahk
#Include C:\Configs and settings\AutoHotKey\QuickSwitch\Libs\GetTotalcmdIni.ahk
#Include C:\Configs and settings\AutoHotKey\QuickSwitch\Libs\GetTotalcmdTabs.ahk

try {
    CreateTotalUserIni(1378828, "extra", "savetabs")
} catch errorgl {
    LogError(errorgl)
}
;LogInfo(GetTotalPathIni(13024), true) 

;LogInfo(GetTotalConsolePid(6576), true)
;SendConsoleCommand(9324, "set commander")