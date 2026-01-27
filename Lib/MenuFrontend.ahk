/*
    This is the Context Menu which allows to select the desired path.
    Displayed and actual paths are independent of each other,
    which allows menu to display anything (e.g. short path)
*/

AddMenuTitle(_title) {
    Menu, % "ContextMenu", % "Add", % _title, % "Dummy"
    Menu, % "ContextMenu", % "Disable", % _title
}

AddMenuIcon(_title, _icon, _iconNumber := 1, _isToggle := false) {
    /*
        Adds an icon to a menu item. If icons are disabled, adds a check mark.

        _icon:          abosolute / relative to IconsDir path to ICO, CUR, ANI, EXE, DLL, CPL, SCR and other resource that contains icons.
        _iconNumber:    postive number from non-ICO resource.
        _isToggle:      add check mark if ShowIcons is false.
    */
    global ShowIcons, IconsDir, IconsSize

    try {
        if ShowIcons {
            if !IsFile(_icon)
                _icon := IconsDir "\" _icon

            Menu, % "ContextMenu", % "Icon",  % _title, % _icon, % _iconNumber, % IconsSize
        } else {
            Menu, % "ContextMenu", % _isToggle ? "Check" : "UnCheck", % _title
        }
    } catch _ex {
        LogError("Wrong path to the icon: '" _ex.Extra "'", "icon")
        ShowIcons := false
    }
}

AddMenuOption(_title, _function, _isToggle := false, _type := "Radio") {
    ; Underline the first letter to activate using keyboard
    _item := "&" _title
    Menu, % "ContextMenu", % "Add", % _item, % _function, % _type

    ; Add icon with a postfix depending on the toggle
    AddMenuIcon(_item, _title . (_isToggle ? "On" : "Off") . ".ico", 1, _isToggle)
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

    Menu, % "ContextMenu", % "Add"
    AddMenuOption("Settings",   "ShowSettings")
}

;─────────────────────────────────────────────────────────────────────────────
;
AddMenuPaths(ByRef paths, _function) {
;─────────────────────────────────────────────────────────────────────────────
    ; Array must be array of arrays: [path, icon, iconNumber?, title?]
    ; If the "title" of menu item is specified, it will be used instead of short path.
    global ShortPath, PathNumbers

    for _index, _options in paths {
        _title := "&"

        if (PathNumbers && (_index < 10))
            _title .= _index " "
        if _options[4]
            _title .= _options[4]
        else if ShortPath
            _title .= GetShortPath(_options[1])
        else
            _title .= _options[1]

        Menu, % "ContextMenu", % "Insert",, % _title, % _function
        AddMenuIcon(_title, _options[2], _options[3] + 0)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
CreateMenu() {
;─────────────────────────────────────────────────────────────────────────────
    global
    FromSettings := false
    try Menu, % "ContextMenu", % "Delete"  ; Delete previous menu

    MenuStack := []
    MenuStack.Push(PinnedPaths*)
    MenuStack.Push(FavoritePaths*)
    MenuStack.Push(ManagersPaths*)
    MenuStack.Push(ClipboardPaths*)

    if (stackLength := MenuStack.Length()) {
        if DeleteDuplicates
            MenuStack := GetUniqPaths(MenuStack)

        MenuStack.RemoveAt(PathLimit + 1, stackLength)
        AddMenuPaths(MenuStack, Func("SelectPath").Bind(MenuStack))
        AddMenuOptions()
    } else {
        AddMenuTitle("No available paths")
        AddMenuOption("Settings", "ShowSettings")
    }

    Menu, % "ContextMenu", % "Color", % MenuColor
    return true
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowMenu() {
;─────────────────────────────────────────────────────────────────────────────
    /*
    Rafaello: to prevent the Menu from stuck on the screen (issue #88), 
    we must first activate the hidden (main) script window by its handle (A_ScriptHwnd):
    https://github.com/AutoHotkey/AutoHotkey/blob/16ea5db9247812593c53bbb0444422524cf1a1df/source/script_menu.cpp#L1389
    https://github.com/AutoHotkey/AutoHotkey/blob/16ea5db9247812593c53bbb0444422524cf1a1df/source/script_menu.cpp#L1429
    
    In rare cases, script window will suddenly appear in the middle of the screen, closing the file dialog.
    This occurs inside WinActivate() after WinShow() call if IsIconic() is `true`:
    https://github.com/AutoHotkey/AutoHotkey/blob/16ea5db9247812593c53bbb0444422524cf1a1df/source/window.cpp#L182
    To prevent this we must use different approach, see SetForegroundWindow() in Lib\Windows.ahk
    */
    global DialogId
    WinGetPos, _posX, _posY,,, % "ahk_id " DialogId
    ; Check coordinates for emptiness, not zero
    if (_posX = "" || _posY = "")
        return false
        
    SetForegroundWindow(A_ScriptHwnd)  ; file dialog is not active anymore!

    _menuId := MenuGetHandle("ContextMenu")
    if (!_menuId) {
        ; The Menu doesn't exist yet
        CreateMenu()  
        _menuId := MenuGetHandle("ContextMenu")
    }
    /*
    FuPeiJiang: the return value is the menu-item identifier of the item that the user selected. 
    If the user cancels the Menu without making a selection, or if an error occurs, the return value is zero.
    https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackpopupmenuex
    */
    _cmd := DllCall("TrackPopupMenuEx"
                  , "Ptr", _menuId
                  , "Uint", 0x100  ; TPM_LEFTALIGN | TPM_LEFTBUTTON | TPM_RETURNCMD
                  , "int", _posX, "int", _posY + 100
                  , "Ptr", A_ScriptHwnd  ; handle to the activated script window that will own the Menu
                  , "Ptr", 0) 
    
    if (_cmd) { 
        ; Execute menu action (send WM_COMMAND)
        return DllCall("SendMessageW", "Ptr", A_ScriptHwnd, "Uint", 0x0111, "Ptr", _cmd, "Ptr", 0)
    } else {
        ; Activate file dialog again 
        return SetForegroundWindow(DialogId)
    }
}

