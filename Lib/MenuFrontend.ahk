/*
    This is the Context Menu which allows to select the desired path.
    Displayed and actual paths are independent of each other,
    which allows menu to display anything (e.g. short path)
*/

AddMenuTitle(_title) {
    Menu ContextMenu, Add, % _title, Dummy
    Menu ContextMenu, Disable, % _title
}

AddMenuOption(_title, _function, _isToggle := false) {
    Menu ContextMenu, Add, % _title, % _function, Radio

    if _isToggle
        Menu ContextMenu, Check, % _title
}

;─────────────────────────────────────────────────────────────────────────────
;
AddMenuPaths(ByRef array, _function, _limit := 20, _showNumbers := true) {
;─────────────────────────────────────────────────────────────────────────────
    ; Array must be array of arrays: [path, iconName]
    global IconsDir, IconsSize, ShortPath

    for _index, _options in array {
        _display := ""

        if (_showNumbers && (_index < 10))
            _display .= "&" _index " "
        if ShortPath
            _display .= GetShortPath(_options[1])
        else
            _display .= _options[1]

        Menu, ContextMenu, Insert,, % _display, % _function
        Menu, ContextMenu, Icon, % _display, % IconsDir "\" _options[2],, % IconsSize

        if (_index = _limit)
            return
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
AddMenuOptions() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogAction

    ; Add options to select
    Menu ContextMenu, Add
    AddMenuTitle("Options")

    AddMenuOption("&Auto switch", "ToggleAutoSwitch", DialogAction = 1)
    AddMenuOption("&Black list",  "ToggleBlackList",  DialogAction = -1)

    Menu ContextMenu, Add
    Menu ContextMenu, Add, &Settings, ShowSettings
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowMenu() {
;─────────────────────────────────────────────────────────────────────────────
    global
    FromSettings := false
    try Menu ContextMenu, Delete            ; Delete previous menu

    AddMenuPaths(Paths, Func("SelectPath").bind(Paths), PathLimit, PathNumbers)

    if (DllCall("GetMenuItemCount", "ptr", MenuGetHandle("ContextMenu")) = -1) {
        AddMenuTitle("No available paths")
    } else {
        AddMenuOptions()
    }

    Menu ContextMenu, Color, % MenuColor
    WinActivate, ahk_id %DialogId%          ; Activate dialog to prevent Menu flickering
    Menu ContextMenu, Show, 0, 100          ; Show new menu and halt the thread
}

