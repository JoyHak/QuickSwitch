/*
    This is the Context Menu which allows to select the desired path.
    Displayed and actual paths are independent of each other,
    which allows menu to display anything (e.g. short path)
*/

AddTitle(ByRef title) {
    Menu ContextMenu, Add, % title, Dummy
    Menu ContextMenu, Disable, % title
}

;─────────────────────────────────────────────────────────────────────────────
;
AddPathsMenuItems() {
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
AddPathsMenuSettings() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogAction

    Menu ContextMenu, Add,
    
    ; Add options to select
    AddTitle("Settings")

    Menu ContextMenu, Add, &Auto switch, ToggleAutoSwitch
    Menu ContextMenu, Add, &Black list, ToggleBlackList
    
    ; Toggle options
    if (DialogAction = 1)
        Menu ContextMenu, Check, &Auto switch
    
    if (DialogAction = -1)
        Menu ContextMenu, Check, &Black list
    
    ; New GUI added for other settings
    Menu ContextMenu, Add,
    Menu ContextMenu, Add, Menu &settings, ShowMenuSettings
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowPathsMenu() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogID, Paths, MenuColor, WinX, WinY, WinWidth, WinHeight

    ; Get dialog position (also used for settings menu positon)
    WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %DialogID%
    
    if Paths.count() {
        ; Add paths and options
        ReadValues()
        AddPathsMenuItems()
        AddPathsMenuSettings()

    } else {
        ; Display warning
        AddTitle("No available paths")
    }
    
    Menu ContextMenu, Color, %MenuColor%
    Menu ContextMenu, Show, 0, 100      ; Show new menu and halt the thread
    Menu ContextMenu, Delete            ; Delete previous menu    
}

