; These functions are responsible for Tray menu and it's items behavior.

InitTrayMenu() {
    global MainIcon
    Menu, % "Tray", % "NoStandard"
    Menu, % "Tray", % "DeleteAll"

    AddTrayItem("&Menu",         "EnforceShowMenu",     MainIcon)
    AddTrayItem("&Settings",     "ShowSettings",        "Settings")
    Menu, % "Tray", % "Add"
    AddTrayItem("Repor&t error", "TrayIssueTracker",    "Bug")
    AddTrayItem("&Errors log",   "TrayErrorsLog",       "Bug")
    Menu, % "Tray", % "Add"
    AddTrayItem("&Restart",      "TrayRestart",         "Restart")
    AddTrayItem("&Suspend",      "TraySuspend",         "Suspend")
    AddTrayItem("E&xit",         "TrayExit",            "Close")

    Menu, % "Tray", % "Default", % "&Menu"
    Menu, % "Tray", % "Click", 1    ; single click = open the Menu
    Menu, % "Tray", % "NoMainWindow"
}

ValidateTrayIcon(_paramName, ByRef icon) {
    /*
    If the file exists, changes the tray icon and returns "paramName=icon".
    If icon path is incorrect, reads it from INI
    */

    icon := Trim(icon, " `t'""")
    icon := RTrim(icon, "\/.")
    icon := StrReplace(icon, "/" , "\")
    icon := ExpandVariables(icon)

    if !icon {
        Menu, % "Tray", % "Icon", *
        return _paramName "=`n"
    }

    try {
        Menu, % "Tray", % "Icon", % LoadIcon(icon), , 1
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
    global ShowIcons, IconsSize

    Menu, % "Tray", % "Add", % _title, % _function, % _options

    if ShowIcons {
        try Menu, % "Tray", % "Icon", % _title, % CreateIcon(_icon),, % IconsSize
    }
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
    global MainIcon, IconsDir, IconsSize, Last

    static toggle := 0
    toggle := !toggle

    static icons := {}
    if (IconsDir != Last.IconsDir || IconsSize != Last.IconsSize) {
        icons := {}
    }

    _icon := toggle ? "Suspend" : MainIcon
    if !icons.hasKey(_icon) {
        icons[_icon] := LoadIcon(_icon)
    }

    try Menu, % "Tray", % "Icon", % icons[_icon], , 1

    Suspend % toggle
    Pause % toggle
}

TrayExit() {
    ExitApp
}
