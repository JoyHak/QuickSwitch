; These functions are responsible for Tray menu and it's items behavior.

InitTrayMenu() {
    global MainIcon
    ValidateTrayIcon("MainIcon", MainIcon)

    Menu, % "Tray", % "NoStandard"
    AddTrayItem("&Menu",         "EnforceShowMenu",     MainIcon)
    AddTrayItem("&Settings",     "EnforceShowSettings", "SettingsOff.ico")
    Menu, % "Tray", % "Add"
    AddTrayItem("Repor&t error", "TrayIssueTracker",    "Bug.ico")
    AddTrayItem("&Errors log",   "TrayErrorsLog",       "Bug.ico")
    Menu, % "Tray", % "Add"
    AddTrayItem("&Restart",      "TrayRestart",         "Restart.ico")
    AddTrayItem("&Suspend",      "TraySuspend",         "Suspend.ico")
    AddTrayItem("E&xit",         "TrayExit",            "Close.ico")

    Menu, % "Tray", % "Default", % "&Menu"
    Menu, % "Tray", % "Click", 1    ; single click = open the Menu
    Menu, % "Tray", % "NoMainWindow"
}

ValidateTrayIcon(_paramName, ByRef icon) {
    /*
    If the file exists, changes the tray icon and returns "paramName=icon".
    If icon path is incorrect, reads it from INI
    */

    icon := Trim(icon, " `t\/.")
    icon := StrReplace(icon, "/" , "\")

    if !icon {
        Menu, % "Tray", % "Icon", *
        return _paramName "=`n"
    }

    try {
        ExpandVariables(icon)
        Menu, % "Tray", % "Icon", % icon, , 1
        return _paramName "=" icon "`n"
    }

    if !_paramName
        return ""

    LogError("Icon '" icon "' not found", "tray icon", "Specify the full path to the file")
    
    _default := ReadValue(_paramName, , A_Space)
    icon := _default
    return _paramName "=" _default "`n"
}

AddTrayItem(_title, _function, _icon, _options := "") {
    global ShowIcons, IconsDir, IconsSize

    Menu, % "Tray", % "Add", % _title, % _function, % _options

    if ShowIcons {
        if !IsFile(_icon)
            _icon := IconsDir "\" _icon

        try Menu, % "Tray", % "Icon", % _title, % _icon,, % IconsSize
    }
}

EnforceShowSettings() {
    ; Enforces settings display. Used by Tray menu.
    global IsEnforcedUi := true
    ShowSettings()
}

TrayIssueTracker() {
    global IssueTracker
    Run, % IssueTracker
}

TrayErrorsLog() {
    global ErrorsLog
    Run, % ErrorsLog
}

TrayRestart() {
    Reload
}

TraySuspend() {
    global MainIcon, IconsDir

    static toggle := 0
    toggle := !toggle

    _icon := toggle ? (IconsDir "\Suspend.ico") : MainIcon
    try Menu, % "Tray", % "Icon", % _icon, , 1

    Suspend % toggle
    Pause % toggle
}

TrayExit() {
    ExitApp
}
