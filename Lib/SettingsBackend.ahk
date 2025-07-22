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
    InitSections()
    ShowSettings()
}

SaveSettings() {
    ; Write current GUI (global) values
    Gui, Submit

    DeleteSections()
    SetDefaultColors()

    WriteValues()
    ReadValues()

    InitAutoStartup()
    InitDarkTheme()
    InitSections()
}

RestartApp() {
    global RestartWhere

    if !RestartWhere
        Reload
    if WinActive(RestartWhere)
        Reload
}

GuiEscape() {
    Gui, Destroy
}

NukeSettings() {
    global INI

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

    if DeleteFavorites
        DeleteFile(FavoritesDir "\*.lnk", "favorites")

    if DeleteKeys {
        PinKey := MainKey := RestartKey := ""
        PinMousePlaceholder := RestartMouselaceholder := MainMouselaceholder := ""
    }

    if DeleteClipboard
        ClipboardPaths := []

    if DeletePinned {
        PinnedPaths := []
        try IniDelete, % INI, % "App", % "PinnedPaths"
    }

    if NukeSettings
        return NukeSettings()

    if DeleteDialogs
        try IniDelete, % INI, % "Dialogs"
}

;─────────────────────────────────────────────────────────────────────────────
;
InitSections(_all := false) {
;─────────────────────────────────────────────────────────────────────────────
    ; Clear / Init global arrays to remove sections from the menu
    global
    
    if _all
        PinnedPaths := []
    
    ValidatePinnedPaths("PinnedPaths", PinnedPaths, ShowPinned)
    
    if (!ShowFavorites || _all)
        FavoritePaths  := []
    if (!ShowManagers  || _all)
        ManagersPaths  := []
    if (!ShowClipboard || _all)
        ClipboardPaths := []
    if (!ShowDragNDrop || _all)
        DragNDropPaths := []
}

;─────────────────────────────────────────────────────────────────────────────
;
InitAutoStartup() {
;─────────────────────────────────────────────────────────────────────────────
    global AutoStartup, ScriptName

    try {
        _link := A_Startup "\" ScriptName ".lnk"

        if AutoStartup {
            if !IsFile(_link) {
                LogInfo("Auto Startup enabled")
            }
            FileCreateShortcut, % A_ScriptFullPath, % _link, % A_ScriptDir
        } else {
            if IsFile(_link) {
                FileDelete, % _link
                LogInfo("Auto Startup disabled")
            }
        }
    } catch _ex {
        LogException(_ex)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleShowAlways() {
;─────────────────────────────────────────────────────────────────────────────
    global ShowAlways
    Gui, Submit, NoHide

    GuiControl,  % "Disable" ShowAlways, % "ShowNoSwitch"
    GuiControl,  % "Disable" ShowAlways, % "ShowNoSwitch"
    GuiControl,  % "Disable" ShowAlways, % "ShowAfterSettings"
    GuiControl,  % "Disable" ShowAlways, % "ShowAfterSelect"
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleShortPath() {
;─────────────────────────────────────────────────────────────────────────────
    ; Hide or display additional options
    global ShortPath
    Gui, Submit, NoHide
    GuiControl,, % "ShortPath", % "&Show short path" . (ShortPath ? " indicate as" : "")

    GuiControl,  % "Enable" ShortPath,   % "ShortenEnd"
    GuiControl,  % "Enable" ShortPath,   % "ShowDriveLetter"
    GuiControl,  % "Enable" ShortPath,   % "DirsCount"
    GuiControl,  % "Enable" ShortPath,   % "DirsCountText"
    GuiControl,  % "Enable" ShortPath,   % "DirNameLength"
    GuiControl,  % "Enable" ShortPath,   % "DirNameLengthText"
    GuiControl,  % "Enable" ShortPath,   % "PathSeparator"
    GuiControl,  % "Enable" ShortPath,   % "PathSeparatorText"
    GuiControl,  % "Enable" ShortPath,   % "ShowFirstSeparator"

    GuiControl,  % "Show" ShortPath,     % "ShortNameIndicator"
    GuiControl,  % "Show" ShortPath,     % "ShortNameIndicatorText"
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleIcons() {
;─────────────────────────────────────────────────────────────────────────────
    ; Hide or display input fields
    global ShowIcons
    Gui, Submit, NoHide
    GuiControl,, % "ShowIcons", % "&Show icons" . (ShowIcons ? " from" : "")

    GuiControl,  % "Show" ShowIcons,     % "IconsDir"
    GuiControl,  % "Show" ShowIcons,     % "IconsSize"
    GuiControl,  % "Show" ShowIcons,     % "IconsSizePlaceholder"
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleFavorites() {
;─────────────────────────────────────────────────────────────────────────────
    ; Hide or display path input field
    global ShowFavorites
    Gui, Submit, NoHide
    GuiControl,, % "ShowFavorites", % "&Favorites" . (ShowFavorites ? " from" : "")

    GuiControl,  % "Show" ShowFavorites, % "FavoritesDir"
}