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
    ; Array must be array of arrays: [path, iconName]
    global IconsDir, IconsSize, ShortPath, PathLimit, PathNumbers, LastPathIndex

    for _, _options in array {
        _display := ""

        if (PathNumbers && (LastPathIndex < 10))
            _display .= "&" LastPathIndex++ " "
        if ShortPath
            _display .= GetShortPath(_options[1])
        else
            _display .= _options[1]

        Menu, ContextMenu, Insert,, % _display, % _function
        Menu, ContextMenu, Icon, % _display, % IconsDir "\" _options[2],, % IconsSize
        
        if (LastPathIndex = PathLimit)
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
    try Menu ContextMenu, Delete            ; Delete previous menu
    
    (Stack := []).Push(Paths*)
    Stack.Push(Clips*)

    if (Stack.length()) {
        AddMenuPaths(Stack, Func("SelectPath").bind(Stack))
        AddMenuOptions()
    } else {
        AddMenuTitle("No available paths")
        Menu ContextMenu, Add, &Settings, ShowSettings
    }

    FromSettings  := false
    LastPathIndex := 1
    
    Menu ContextMenu, Color, % MenuColor
    WinActivate, ahk_id %DialogId%          ; Activate dialog to prevent Menu flickering
    Menu ContextMenu, Show, 0, 100          ; Show new menu and halt the thread
}

