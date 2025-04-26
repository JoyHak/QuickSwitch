/*
    This is the Context Menu which allows to select the desired path.
    Displayed and actual paths are independent of each other,
    which allows menu to display anything (e.g. short path)
*/

AddMenuTitle(ByRef title) {
    Menu ContextMenu, Add, % title, Dummy
    Menu ContextMenu, Disable, % title
}

CheckMenuRadio(ByRef title, ByRef function, ByRef toggleIf) {
    Menu ContextMenu, Add, % title, % function, Radio

    if toggleIf
        Menu ContextMenu, Check, % title

}

;─────────────────────────────────────────────────────────────────────────────
;
AddMenuPaths() {
;─────────────────────────────────────────────────────────────────────────────
    global PathNumbers, ShortPath, Paths

    for _index, _path in Paths {
        _display := ""

        if PathNumbers
            _display .= "&" . _index . " "
        if ShortPath
            _display .= GetShortPath(_path)
        else
            _display .= _path

        Menu, ContextMenu, Insert,, % _display, SelectPath
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
AddMenuOptions() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogAction

    ; Add options to select
    Menu ContextMenu, Add
    AddMenuTitle("Settings")

    CheckMenuRadio("&Auto switch", "ToggleAutoSwitch", DialogAction = 1)
    CheckMenuRadio("&Black list", "ToggleBlackList", DialogAction = -1)

    Menu ContextMenu, Add
    Menu ContextMenu, Add, Menu &settings, ShowSettings
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowMenu() {
;─────────────────────────────────────────────────────────────────────────────
    global Paths, MenuColor
    try Menu ContextMenu, Delete        ; Delete previous menu

    if Paths.count() {
        ; Add paths and options
        ReadValues()
        AddMenuPaths()
        AddMenuOptions()

    } else {
        ; Display warning
        AddMenuTitle("No available paths")
    }

    Menu ContextMenu, Color, % MenuColor
    Menu ContextMenu, Show, 0, 100        ; Show new menu and halt the thread
    try Menu ContextMenu, Delete          ; Hide after loosing focus
}

