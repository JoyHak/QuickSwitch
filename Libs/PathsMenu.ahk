/* 
    This is the context menu from which you can select the desired path. 
    Please note that the displayed and actual paths are independent of each other, 
    which allows you to display anything. 
    
    For further information on working with paths, please read GetPaths.ahk. 
    AutoSwitch settings code in AutoSwitch.ahk. 
*/

ShouldOpen() {
    global
    Return OpenMenu or (FromSettings and ReDisplayMenu)
}

;─────────────────────────────────────────────────────────────────────────────
;
AddPathsMenuItems() {
;─────────────────────────────────────────────────────────────────────────────  

    global VirtualPath, PathNumbers, ShortPath, paths, virtuals
    _paths := VirtualPath ? virtuals : paths

    for _index, _path in _paths {
        _display := ""
        
        if PathNumbers
            _display .= "&" . _index . " " 
        if ShortPath
            _display .= ShowShortPath(_path)
        else
            _display .= _path

        Menu, ContextMenu, Insert,, %_display%, SelectPath
        _display := ""
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
    ; Only show AutoSwitchException if AutoSwitch is activated.
    
    if DialogAction
        Menu ContextMenu, Check, &Allow AutoSwitch
    else if !DialogAction
        Menu ContextMenu, Check, Never &here
    else
        Menu ContextMenu, Check, &Not now
    
    ; new GUI added for other settings
    Menu ContextMenu, Add,
    Menu ContextMenu, Add, Menu &settings, ShowMenuSettings
    Menu ContextMenu, Add, &App settings,  ShowAppSettings
}

;─────────────────────────────────────────────────────────────────────────────
;
HidePathsMenu() {
;───────────────────────────────────────────────────────────────────────────── 
    global
    Menu ContextMenu, UseErrorLevel  ; Ignore errors
    Menu ContextMenu, Delete         ; Delete previous menu
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowPathsMenu() {
;─────────────────────────────────────────────────────────────────────────────  
    global DialogID, paths, MenuColor
    global WinX, WinY, WinWidth, WinHeight, MenuColor
    global FromSettings := false
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
    Return
}

