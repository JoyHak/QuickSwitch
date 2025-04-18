/*
    This is the Context Menu which allows to select the desired path.
    Displayed and actual paths are independent of each other,
    which allows menu to display anything (e.g. short path)
*/

AddMenuTitle(ByRef title) {
    Menu ContextMenu, Add, % title, Dummy
    Menu ContextMenu, Disable, % title
}

CheckMenuToggle(ByRef title, ByRef function, ByRef toggleIf) {
    Menu ContextMenu, Add, % title, % function
    
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
    
    CheckMenuToggle("&Auto switch", "ToggleAutoSwitch", DialogAction = 1)
    CheckMenuToggle("&Black list", "ToggleBlackList", DialogAction = -1)
    
    Menu ContextMenu, Add
    Menu ContextMenu, Add, Menu &settings, ShowSettings
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowMenu() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogID, Paths, MenuColor, WinX, WinY, WinWidth, WinHeight

    ; Get dialog position (also used for settings menu positon)
    WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %DialogID%
    
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
    Menu ContextMenu, Show, 0, 100      ; Show new menu and halt the thread
    Menu ContextMenu, Delete            ; Delete previous menu    
}

