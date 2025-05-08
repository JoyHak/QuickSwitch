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
AddMenuPaths(ByRef array, _function) {
;─────────────────────────────────────────────────────────────────────────────
    global PathNumbers, ShortPath

    for _index, _path in array {
        _display := ""

        if PathNumbers
            _display .= "&" . _index . " "
        if ShortPath
            _display .= GetShortPath(_path)
        else
            _display .= _path

        Menu, ContextMenu, Insert,, % _display, % _function
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
    global Paths, SelectMenuPath, MenuColor, DialogId
    try Menu ContextMenu, Delete            ; Delete previous menu

    if Paths.count() {
        AddMenuPaths(Paths, SelectMenuPath)
        AddMenuOptions()
    } else {
        AddMenuTitle("No available paths")
    }
    
    WinActivate % "ahk_id " DialogId        ; Activate dialog in case of menu flickering
    Menu ContextMenu, Color, % MenuColor
    Menu ContextMenu, Show, 0, 100          ; Show new menu and halt the thread
}

