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
        
        RegRead, _theme,    % reg,                % "CurrentTheme" 
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

;─────────────────────────────────────────────────────────────────────────────
;
SetMenuFont(_name := "", _size := 0, _weight := 0, _isItalic := -1) {
;─────────────────────────────────────────────────────────────────────────────
    ; Sets font and font attributes for all menus in the system. 
    ; Returns true on success

    static SPI_GETNONCLIENTMETRICS := 0x29
    static SPI_SETNONCLIENTMETRICS := 0x2A
    static SPI_SETICONTITLELOGFONT := 0x22
    static SPIF_UPDATEINIFILE      := 0x1
    static SPIF_SENDCHANGE         := 0x2

    static LOGFONT_SIZE := 92
    static NONCLIENTMETRICS_SIZE := 40 + 5 * LOGFONT_SIZE

    VarSetCapacity(NONCLIENTMETRICS, NONCLIENTMETRICS_SIZE, 0)
    NumPut(NONCLIENTMETRICS_SIZE, &NONCLIENTMETRICS, 0, "UInt")

    if !DllCall("SystemParametersInfoW"
        , "UInt", SPI_GETNONCLIENTMETRICS
        , "UInt", NONCLIENTMETRICS_SIZE
        , "Ptr",  &NONCLIENTMETRICS
        , "UInt", 0) {
        return LogError("Unable to retrieve system font"
                      , "menu font"
                      , "Result: " A_LastError)
    }

    _offset  := 40 + 2 * LOGFONT_SIZE
    _address := &NONCLIENTMETRICS + _offset

    if _name
        StrPut(_name, _address + 28, 32)

    if _size {
        _height := -DllCall("MulDiv"
            , "Int", _size
            , "Int", A_ScreenDPI
            , "Int", 72)
        NumPut(_height, _address + 0, "Int")
    }

    if _weight
        NumPut(_weight, _address + 16, "Int")

    if (_isItalic = 1) || (_isItalic = 0)
        NumPut(_isItalic, &_address + 20, "UChar")

    if !DllCall("SystemParametersInfoW"
        , "UInt", SPI_SETNONCLIENTMETRICS
        , "UInt", NONCLIENTMETRICS_SIZE
        , "Ptr",  &NONCLIENTMETRICS
        , "UInt", SPIF_UPDATEINIFILE | SPIF_SENDCHANGE) {
        return LogError("Unable to set system font"
                      , "menu font"
                      , "Result: " A_LastError)
    }
    
    Sleep 1000
    return true
}

;─────────────────────────────────────────────────────────────────────────────
;
InitMenuFont() {
;─────────────────────────────────────────────────────────────────────────────
    ; Sets font and font attributes for all menus in the system.
    ; Prevents multiple font changes. Shows warning.
    
    global ScriptName, INI, MenuFont, MenuFontSize
    
    _warningMsg := "The font "
    if !(MenuFont || MenuFontSize)
        _warningMsg .= "will be reset to system defaults "        
    
    if MenuFont
        _warningMsg .= "will be set to '" MenuFont "' "
    if (MenuFont && MenuFontSize)
        _warningMsg .= "and its "
    if MenuFontSize
        _warningMsg .= "size will be set to " MenuFontSize " "
        
    _warningMsg .= "
    (LTrim Join`s
    for all menus in the system. 
    `n`nThe font in the tray menu and context menu will be changed; 
    the font in the " ScriptName " menu will be changed.
    `n`nDo you want to continue?
    )"
    
    _restartMsg := "
    (LTrim Join`s
    The font has been changed. To roll back changes, open the settings, 
    make the field empty and set the size to 0.
    `n`nRestart the " ScriptName " manually.
    )"
    
    IniRead, _opt, % INI, % "App", % "MenuFont", % "_0"    
    _options := MenuFont "_" MenuFontSize 
    
    if (_opt = _options)
        return
        
    try IniWrite, % _options, % INI, % "App", % "MenuFont"
    if !MsgWarn(_warningMsg)
        return
    
    SetMenuFont(MenuFont, MenuFontSize)
    MsgBox % _restartMsg
    ExitApp
}