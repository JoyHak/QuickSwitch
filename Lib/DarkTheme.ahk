; Contains functions for switching Menu and GUI to dark / light mode

SetDarkTheme(_controls) {
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

SetDefaultColors() {
    global    
    
    if DarkColors {    
        MenuColor := DarkTheme ? 202020 : ""
        GuiColor  := MenuColor
    }
    
    DarkColors := false
}

ToggleDarkTheme() {
    global DarkColors := true
}

;─────────────────────────────────────────────────────────────────────────────
;
InitDarkTheme() {
;─────────────────────────────────────────────────────────────────────────────
    ; Noticz: sets theme for Menu and GUI
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
IsDarkTheme() {
;─────────────────────────────────────────────────────────────────────────────
    ; Returns true if system or apps doesn't use light theme or (custom) theme contains dark theme words
    try {
        static reg := "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes"
        
        RegRead, _theme, % reg, % "CurrentTheme" 
        RegRead, _appLight, % reg "\Personalize", % "AppsUseLightTheme" 
        RegRead, _sysLight, % reg "\Personalize", % "SystemUsesLightTheme" 
        
        return !_appLight || !_sysLight || InStr(_theme, "dark|night|gray")
    } 
    
    return false
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