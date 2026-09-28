; These functions are responsible for the GUI Settings functionality and its Controls
; Also contains additional out-of-category functions needed for the app

ResetSettings() {
    ; Show "Nuke" button once after pressing "Reset" button
    if (A_GuiControl = "&Reset")
        global NukeSettings := true

    ; Roll back values and show them in settings
    Gui, Destroy

    SetDefaultValues()
    WriteValues()

    InitAutoStartup()
    InitDarkTheme()
    InitMenuFont()
    ShowSettings()
}

SaveSettings() {
    ; Write current GUI (global) values

;@Ahk2Exe-IgnoreBegin
    global SaveUiPosition, SettingsId, UiPosX, UiPosY
    if SaveUiPosition
        try WinGetPos, UiPosX, UiPosY,,, % "ahk_id " SettingsId
;@Ahk2Exe-IgnoreEnd
    Gui, Submit

    DeleteSections()

    WriteValues()
    ReadValues()

    InitAutoStartup()
    InitDarkTheme()
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