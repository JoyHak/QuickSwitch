#Warn
#NoEnv
#Persistent
#SingleInstance force
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetWinDelay, -1
SetControlDelay, -1
FileEncoding, UTF-8

ScriptName    := "QuickSwitch"
MainIcon      := ""
INI           := ScriptName ".ini"
ErrorsLog     := "C:\Configs and settings\AutoHotKey\QuickSwitch\Errors.log"
BugReportLink := "https://github.com/JoyHak/QuickSwitch/issues/new?template=bug-report.yaml"

RestartApp() {
    Reload
}

Terminate() {
    ExitApp
}

Hotkey, ~^s, RestartApp 
Hotkey, ~^Esc, Terminate 
