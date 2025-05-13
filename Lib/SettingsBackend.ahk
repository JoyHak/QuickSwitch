; These functions are responsible for the GUI Settings functionality and its Controls
; Also contains additional out-of-category functions needed for the app

NukeSettings() {
    ; Delete configuration
    global INI, ScriptName

    if MsgWarn("Do you want to delete the configuration?`n" INI) {
        try FileRecycle, % INI
        LogInfo("Old configuration has been placed in the Recycle Bin")
        ResetSettings()
    }
}

ResetSettings() {
    ; Show "Nuke" button once after pressing "Reset" button
    if (A_GuiControl = "&Reset")
        global NukeSettings := true

    ; Roll back values and show them in settings
    Gui, Destroy

    SetDefaultValues()
    WriteValues()
    ShowSettings()
}

SaveSettings() {
    ; Write current GUI (global) values
    Gui, Submit
    WriteValues()
    ReadValues()
    DeleteDialogs()
    InitAutoStartup()
}

RestartApp() {
    global RestartWhere

    if !RestartWhere
        Reload
    if WinActive(RestartWhere)
        Reload
}

DeleteDialogs() {
    global DeleteDialogs, INI

    if DeleteDialogs {
        try IniDelete, % INI, Dialogs
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
InitAutoStartup() {
;─────────────────────────────────────────────────────────────────────────────
    global AutoStartup, ScriptName

    try {
        _link := A_Startup "\" ScriptName ".lnk"

        if AutoStartup {
            if !FileExist(_link) {
                LogInfo("Auto Startup enabled")
            }
            FileCreateShortcut, % A_ScriptFullPath, % _link, % A_ScriptDir
        } else {
            if FileExist(_link) {
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
    global

    Gui, Submit, NoHide
    GuiControl, Disable%ShowAlways%, ShowNoSwitch
    GuiControl, Disable%ShowAlways%, ShowAfterSettings
    GuiControl, Disable%ShowAlways%, ShowAfterSelect
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleShortPath() {
;─────────────────────────────────────────────────────────────────────────────
    ; Hide or display additional options
    global

    Gui, Submit, NoHide
    GuiControl,, ShortPath, % "Show short path" . (ShortPath ? " indicate as" : "")

    GuiControl, Enable%ShortPath%, ShortenEnd
    GuiControl, Enable%ShortPath%, ShowDriveLetter
    GuiControl, Enable%ShortPath%, DirsCount
    GuiControl, Enable%ShortPath%, DirsCountText
    GuiControl, Enable%ShortPath%, DirNameLength
    GuiControl, Enable%ShortPath%, DirNameLengthText
    GuiControl, Enable%ShortPath%, PathSeparator
    GuiControl, Enable%ShortPath%, PathSeparatorText
    GuiControl, Enable%ShortPath%, ShowFirstSeparator
    GuiControl, Show%ShortPath%,   ShortNameIndicator
    GuiControl, Show%ShortPath%,   ShortNameIndicatorText
}