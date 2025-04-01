/*
    This is the context menu from which you can select the desired path.
    Please note that the displayed and actual paths are independent of each other,
    which allows you to display anything.
*/

AddPathsMenuItems() {
    global PathNumbers, ShortPath, paths

    for _index, _path in paths {
        _display := ""

        if PathNumbers
            _display .= "&" . _index . " "
        if ShortPath
            _display .= GetShortPath(_path)
        else
            _display .= _path

        Menu, ContextMenu, Add, %_display%, SelectPath
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
HidePathsMenu() {
;─────────────────────────────────────────────────────────────────────────────
    Menu ContextMenu, UseErrorLevel  ; Ignore errors
    Menu ContextMenu, Delete         ; Delete previous menu
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowPathsMenu() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogID, paths, MenuColor, WinX, WinY, WinWidth, WinHeight

    ReadValues()

    ; Get dialog position (also used for settings menu positon)
    WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %DialogID%
    if paths.Count() {
        AddPathsMenuItems()
        AddPathsMenuSettings()

        Menu ContextMenu, Color, %MenuColor%
        Menu ContextMenu, Show, 0, 100
        HidePathsMenu()
    }
}

