/*
    This is the context menu from which you can select the desired path.
    Please note that the displayed and actual paths are independent of each other,
    which allows you to display anything.
*/

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
    
        Menu, ContextMenu, Insert,, %_display%, SelectPath
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
AddPathsMenuSettings() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogAction

    Menu ContextMenu, Add,
    Menu ContextMenu, Add, Settings, Dummy
    Menu ContextMenu, disable, Settings

    Menu ContextMenu, Add, &Allow AutoSwitch, AutoSwitch, Radio
    Menu ContextMenu, Add, Never &here, Never, Radio
    Menu ContextMenu, Add, &Not now, ThisMenu, Radio

    ; Activate radiobutton for current setting (depends on INI setting)
    if (DialogAction = 1)
        Menu ContextMenu, Check, &Allow AutoSwitch
    else if (DialogAction = 0)
        Menu ContextMenu, Check, Never &here
    else
        Menu ContextMenu, Check, &Not now

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
    
    if Paths.Count() {
        ReadValues()
        AddPathsMenuItems()
        AddPathsMenuSettings()

        Menu ContextMenu, Color, %MenuColor%
        Menu ContextMenu, Show, 0, 100      ; Show new menu and halt the thread
        Menu ContextMenu, Delete            ; Delete previous menu
    } 
}

