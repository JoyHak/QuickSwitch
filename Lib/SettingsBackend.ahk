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
    
    InitAutoStartup()
    InitDarkTheme()
    ShowSettings()
}

SaveSettings() {
    ; Write current GUI (global) values
    Gui, Submit
    WriteValues()
    ReadValues()
    DeleteDialogs()
    
    InitAutoStartup()
    InitDarkTheme()
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
InitDarkTheme() {
;─────────────────────────────────────────────────────────────────────────────
    ; Noticz: sets dark UI colors if Windows dark mode is enabled
	; https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661&hilit=dark#p426437
    ; https://gist.github.com/rounk-ctrl/b04e5622e30e0d62956870d5c22b7017    
	global DarkTheme
	
    static uxTheme := DllCall("GetModuleHandle", "str", "uxTheme", "ptr")
	static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxTheme, "ptr", 135, "ptr")
	static FlushThemes := DllCall("GetProcAddress", "ptr", uxTheme, "ptr", 136, "ptr")
    
    ; 0 = Light theme, 1 = Dark theme
	DllCall(SetPreferredAppMode, "int", DarkTheme)
	DllCall(FlushThemes)
}

;─────────────────────────────────────────────────────────────────────────────
;
SetDarkTheme(_controls) {
;─────────────────────────────────────────────────────────────────────────────
    ; Sets dark theme for controls names list
    static SetWindowTheme := DllCall("GetProcAddress"
                                    , "ptr", DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
                                    , "astr", "SetWindowTheme", "ptr")
        
    Loop, parse, _controls, | 
    {
        GuiControlGet, _id, hwnd, % A_LoopField
        if (_id)
            DllCall(SetWindowTheme, "ptr", _id, "str", "DarkMode_Explorer", "ptr", 0)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
InvertColor(color) {
;─────────────────────────────────────────────────────────────────────────────
    ; Noticz: inverts UI color if Windows dark mode is enabled
	c1 := 0xFF & color >> 16
	c2 := 0xFF & color >> 8
	c3 := 0xFF & color
	c1 := ((c1 < 0x80) * 0xFF) << 16
	c2 := ((c2 < 0x80) * 0xFF) << 8
	c3 := (c3 < 0x80) * 0xFF
	
    return Format("{:x}", c1 + c2 + c3)
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