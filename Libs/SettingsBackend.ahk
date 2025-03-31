; These functions are responsible for the GUI Settings functionality and its Controls

ResetSettings() {
    ; Roll back values and show them in settings
    Gui, Destroy

    SetDefaultValues()
    WriteValues()
    ShowMenuSettings()
}

SaveSettings() {
    ; Read current GUI (global) values
    Gui, Submit
    WriteValues()
    ValidateAutoStartup()
}

RestartApp() {
    global RestartWhere

    if RestartWhere {
        IfWinActive, %RestartWhere%
            Reload
    } else {
        Reload
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleShortPath() {
;─────────────────────────────────────────────────────────────────────────────
    ; Hide or display additional options
    global

    Gui, Submit, NoHide
    if (ShortPath)
        GuiControl,, ShortPath, Show short path, indicate as
    else
        GuiControl,, ShortPath, Show short path

    GuiControl, Enable%ShortPath%, CutFromEnd
    GuiControl, Enable%ShortPath%, ShowDriveLetter
    GuiControl, Enable%ShortPath%, DirsCount
    GuiControl, Enable%ShortPath%, DirsCountText
    GuiControl, Enable%ShortPath%, DirNameLength
    GuiControl, Enable%ShortPath%, DirNameLengthText
    GuiControl, Enable%ShortPath%, PathSeparator
    GuiControl, Enable%ShortPath%, PathSeparatorText
    GuiControl, Show%ShortPath%,   ShortNameIndicator
    GuiControl, Show%ShortPath%,   ShortNameIndicatorText
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateAutoStartup() {
;─────────────────────────────────────────────────────────────────────────────
	global AutoStartup, ScriptName, INI
    
    try {
        IniRead, AutoStartup, %INI%, App, AutoStartup, %AutoStartup%
        link := A_Startup . "\" . ScriptName . ".lnk"
    
        if AutoStartup {
            if !FileExist(link) {
                FileCreateShortcut, %A_ScriptFullPath%, %link%, %A_ScriptDir%
                TrayTip, %ScriptName%, AutoStartup enabled
            }
        } else {
            if FileExist(link) {
                FileDelete, %link%
                TrayTip, %ScriptName%, AutoStartup disabled,, 0x2
            }
        }
    } catch _error {
        LogError(_error)
    }
}