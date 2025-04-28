; These functions are responsible for the GUI Settings functionality and its Controls
; Also contains additional out-of-category functions needed for the app

NukeSettings() {
    ; Delete configuration
    global INI, ScriptName

    ; Yes/No, Warn icon, default is "No", always on top without title bar
    MsgBox, % (4 + 48 + + 256 + 262144), , % "Do you want to delete the configuration?`n" INI
    IfMsgBox No
        return

    try FileRecycle, % INI
    TrayTip, % ScriptName, Old configuration has been placed in the Recycle Bin,, 0x2
    ResetSettings()
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
    ; Read current GUI (global) values
    Gui, Submit
    WriteValues()
    ValidateAutoStartup()
}

RestartApp() {
    global RestartWhere

    if !RestartWhere
        Reload
    if WinActive(RestartWhere)
        Reload
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
    GuiControl,, ShortPath, % "Show short path" . (ShortPath ? "indicate as" : "")

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

;─────────────────────────────────────────────────────────────────────────────
;
ValidateAutoStartup() {
;─────────────────────────────────────────────────────────────────────────────
    global AutoStartup, ScriptName, INI

    try {
        IniRead, AutoStartup, % INI, App, AutoStartup, % AutoStartup
        link := A_Startup . "\" . ScriptName . ".lnk"

        if AutoStartup {
            FileCreateShortcut, % A_ScriptFullPath, % link, % A_ScriptDir
        } else {
            if FileExist(link) {
                FileDelete, % link
                TrayTip, % ScriptName, AutoStartup disabled,, 0x2
            }
        }
    } catch _error {
        LogError(_error)
    }
}