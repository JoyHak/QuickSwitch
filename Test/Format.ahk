#Requires AutoHotkey v1.1+

#Include C:\Configs and settings\AutoHotKey\QuickSwitch
#Include Test\Include.ahk
#Include Libs\Log.ahk

try {
    MsgBox error

} catch e {
    msg := Format("Extra: {}" e*)
    LogError(Exception(msg))
}
