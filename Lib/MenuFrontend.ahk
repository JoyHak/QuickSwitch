/*
    This is the Context Menu which allows to select the desired path.
    Displayed and actual paths are independent of each other,
    which allows menu to display anything (e.g. short path)
*/

AddMenuTitle(_title) {
    Menu, % "ContextMenu", % "Add", % _title, % "Dummy"
    Menu, % "ContextMenu", % "Disable", % _title
}

AddMenuIcon(_title, _iconName, _isToggle := false) {
    global ShowIcons, IconsDir, IconsSize
    
    try {
        if ShowIcons
            Menu, % "ContextMenu", % "Icon",  % _title, % IconsDir "\" _iconName,, % IconsSize
        else if _isToggle
            Menu, % "ContextMenu", % "Check", % _title
    } catch _ex {
        LogError("Wrong path to the icon: `'" _ex.Extra "`'", "icon")
        ShowIcons := false
    }
}

AddMenuOption(_title, _function, _isToggle := false) {
    global ShowIcons
    
    ; Underline the first letter to activate using keyboard
    _name := "&" . _title
    Menu, % "ContextMenu", % "Add", % _name, % _function, % "Radio"
    
    ; Add icon with a postfix depending on the toggle
    AddMenuIcon(_name, _title . (_isToggle ? "On" : "Off") . ".ico", _isToggle)        
}

;─────────────────────────────────────────────────────────────────────────────
;
AddMenuPaths(ByRef paths, _function) {
;─────────────────────────────────────────────────────────────────────────────
    ; Array must be array of arrays: [path, iconName]
    global ShortPath, PathLimit, PathNumbers

    for _index, _options in paths {
        _display := ""

        if (PathNumbers && (_index < 10))
            _display .= "&" _index++ " "
        if ShortPath
            _display .= GetShortPath(_options[1])
        else
            _display .= _options[1]

        Menu, % "ContextMenu", % "Insert",, % _display, % _function
        AddMenuIcon(_display, _options[2])
        
        if (_index = PathLimit)
            return
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
AddMenuOptions() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogAction

    ; Add options to select
    Menu, % "ContextMenu", % "Add"
    AddMenuTitle("Options")

    AddMenuOption("AutoSwitch", "ToggleAutoSwitch", DialogAction = 1)
    AddMenuOption("BlackList",  "ToggleBlackList",  DialogAction = -1)

    Menu, % "ContextMenu", Add
    AddMenuOption("Settings",   "ShowSettings")
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowMenu() {
;─────────────────────────────────────────────────────────────────────────────
    global
    FromSettings  := false
    try Menu, % "ContextMenu", % "Delete"  ; Delete previous menu
    
    MenuStack := []
    MenuStack.Push(ManagersPaths*)
    MenuStack.Push(ClipboardPaths*)

    if (MenuStack.length()) {
        AddMenuPaths(MenuStack, Func("SelectPath").bind(MenuStack))
        AddMenuOptions()
    } else {
        AddMenuTitle("No available paths")
        AddMenuOption("Settings", "ShowSettings")
    }

    Menu, % "ContextMenu", % "Color", % MenuColor
    WinActivate, % "ahk_id " DialogId           ; Activate dialog to prevent Menu flickering
    Menu, % "ContextMenu", % "Show", 0, 100     ; Show new menu and halt the thread
}

