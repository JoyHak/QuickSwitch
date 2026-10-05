; These functions are responsible for the GUI Settings functionality and its Controls
; Also contains additional out-of-category functions needed for the app

ResetSettings() {
    ; Show "Nuke" button once after pressing "Reset" button
    if (A_GuiControl = "ResetButton")
        global NukeSettings := true
    
    ; Roll back values and show them in settings
    Gui, Destroy
    InitControlsColorsHandlers(false)

    SetDefaultValues()
    WriteValues()

    InitAutoStartup()
    SetMenuDarkTheme()
    InitMenuFont()
    ShowSettings()
}

SaveSettings() {
    global
;@Ahk2Exe-IgnoreBegin
    if SaveUiPosition
        try WinGetPos, UiPosX, UiPosY,,, % "ahk_id " SettingsId
;@Ahk2Exe-IgnoreEnd

    Gui, Submit
    InitControlsColorsHandlers(false)
    DeleteSections()
    
    WriteValues()
    ReadValues()
    
    if ShowFavorites
        GetFavoritePaths(FavoritePaths, FavoritesDir)

    InitAutoStartup()
    SetMenuDarkTheme()
    InitMenuFont()
}

;@Ahk2Exe-IgnoreBegin
RestartApp() {
    global RestartWhere, ShowUiAfterRestart

    if ShowUiAfterRestart
        SaveSettings()

    if !RestartWhere
        Reload
    if WinActive(RestartWhere)
        Reload
}
;@Ahk2Exe-IgnoreEnd

GuiEscape() {
    Gui, Destroy
    InitControlsColorsHandlers(false)
}

NukeSettings() {
    global

    DeleteFile(INI, "configuration")
    ResetSettings()
}

;─────────────────────────────────────────────────────────────────────────────
;
DeleteFile(ByRef path, _title := "config") {
;─────────────────────────────────────────────────────────────────────────────
    if MsgWarn("Do you want to delete the " _title "?`n" path) {
        try FileRecycle, % path
        LogInfo(_title " has been placed in the Recycle Bin")
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
DeleteSections() {
;─────────────────────────────────────────────────────────────────────────────
    ; Deletes sections from INI
    global

    if (DeleteFavorites
     && MsgWarn("Do you want to delete the favorites?`n" FavoritesDir "\*.lnk")) {
        RunWait, % A_ComSpec " /c del /s /q """ FavoritesDir "\*.lnk""",, % "Hide"
        if !ErrorLevel {
            FavoritePaths := []
            LogInfo("Favorites has been placed in the Recycle Bin")
        }
    }

    if DeleteKeys {
        PinKey := MainKey := EnforceKey := RestartKey := ""
        PinMousePlaceholder := RestartMousePlaceholder := MainMousePlaceholder := EnforceMousePlaceholder := ""
    }

    if DeletePinned {
        PinnedPaths := []
    }
    if DeleteClipboard {
        ClipboardPaths := []
    }
    if DeleteDialogs {
        FileDialogs := {}
        DialogAction := 0
    }
    if NukeSettings {
        NukeSettings()
    }
}

InitAutoStartup() {
    global Last, AutoStartup, ScriptName

    if (Last.AutoStartup = AutoStartup) {
        return
    }

    try {
        _link := A_Startup "\" ScriptName ".lnk"

        if AutoStartup {
            FileCreateShortcut, % A_ScriptFullPath, % _link, % A_ScriptDir
            LogInfo("Auto Startup enabled")
        } else if IsFile(_link) {
            FileDelete, % _link
            LogInfo("Auto Startup disabled")
        }
    } catch _ex {
        LogException(_ex)
    }
}

ToggleShowAlways() {
    GuiControlGet, _showAlways,, % "ShowAlways"

    GuiControl,  % "Disable" _showAlways, % "ShowNoSwitch"
    GuiControl,  % "Disable" _showAlways, % "ShowAfterSettings"
    GuiControl,  % "Disable" _showAlways, % "ShowAfterSelect"
}

ToggleShortPath() {
    ; Hide or display additional options
    GuiControlGet, _shortPath,, % "ShortPath"
    GuiControl,, % "ShortPath", % "&Show short path" . (_shortPath ? " indicate as" : "")

    GuiControl,  % "Enable" _shortPath,   % "ShortenEnd"
    GuiControl,  % "Enable" _shortPath,   % "ShowDriveLetter"
    GuiControl,  % "Enable" _shortPath,   % "DirsCount"
    GuiControl,  % "Enable" _shortPath,   % "DirsCountText"
    GuiControl,  % "Enable" _shortPath,   % "DirNameLength"
    GuiControl,  % "Enable" _shortPath,   % "DirNameLengthText"
    GuiControl,  % "Enable" _shortPath,   % "PathSeparator"
    GuiControl,  % "Enable" _shortPath,   % "PathSeparatorText"
    GuiControl,  % "Enable" _shortPath,   % "ShowFirstSeparator"
    GuiControl,  % "Show"   _shortPath,   % "ShortNameIndicator"
}

ToggleIcons() {
    ; Hide or display input fields
    GuiControlGet, _showIcons,, % "ShowIcons"
    GuiControl,, % "ShowIcons", % "&Show icons" . (_showIcons ? " from" : "")

    GuiControl,  % "Show" _showIcons,     % "IconsDir"
    GuiControl,  % "Show" _showIcons,     % "IconsSize"
    GuiControl,  % "Show" _showIcons,     % "IconsSizePlaceholder"
}

ToggleFavorites() {
    ; Hide or display path input field
    GuiControlGet, _showFavorites,, % "ShowFavorites"
    GuiControl,, % "ShowFavorites", % "&Favorites" . (_showFavorites ? " from" : "")
    GuiControl,  % "Show" _showFavorites, % "FavoritesDir"
}

ToggleManagersTabs() {
    ; Hide or display tabs checkboxes
    GuiControlGet, _showManagers,, % "ShowManagers"
    GuiControl,  % "Enable" _showManagers, % "ListerIndex"
    GuiControl,  % "Enable" _showManagers, % "ListerIndexText0"
    GuiControl,  % "Enable" _showManagers, % "ListerIndexText1"
    GuiControl,  % "Enable" _showManagers, % "ListerIndexText2"

    GuiControl,  % "Enable" _showManagers, % "ShowAllDesktops"
    GuiControl,  % "Enable" _showManagers, % "ActivePaneOnly"
    GuiControl,  % "Enable" _showManagers, % "ActiveTabOnly"
    GuiControl,  % "Enable" _showManagers, % "ShowLockedTabs"
}


CalculateGuiPosition(_centerX, _buttonsY) {
    global IsDialogClosed, DialogId
    _pos  := ""
    _posX := ""
    _posY := ""

    if IsDialogClosed {
        ; Show window contents above the cursor.
        ; Buttons like "OK" below the the cursor (Y axis), contents in the center (X axis).
        ; Show near the screen edge if the window part would be not visible (overflow)
        MouseGetPos, _mouseX, _mouseY
        
        static scaleX := A_ScreenDPI / 86
        static scaleY := A_ScreenDPI / 100

        _widthHalf := _centerX  * scaleX    ; half window width (in pixels)
        _height    := _buttonsY * scaleY    ; contents height (without buttons and title height)

        if (_mouseX + _widthHalf > A_ScreenWidth) {
            _posX := A_ScreenWidth - _widthHalf * 2     ; right edge
        } else if (_mouseX - _widthHalf < 0) {
            _posX := 0                                  ; left edge
        } else {
            _posX := _mouseX - _widthHalf               ; cursor in the window center (X axis)
        }

        if (_mouseY - _height > A_ScreenHeight) {
            _posY := A_ScreenHeight - _height * 1.2     ; bottom edge
        } else if (_mouseY - _height < 0) {
            _posY := 0                                  ; top edge
        } else {
            _posY := _mouseY - _height                  ; cursor above buttons
        }

        _pos := "x" _posX " y" _posY
    }

    if !_pos {
        WinGetPos, _posX, _posY,,, % "ahk_id " DialogId
        if (_posX != "" && _posY != "")
            _pos := "x" _posX " y" _posY + 100      ; dialog top left corner
        else
            _pos := "x0 y100"                       ; active window top left corner
    }
    
    return _pos
}