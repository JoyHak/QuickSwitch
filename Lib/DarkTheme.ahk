; Contains functions for switching Menu and GUI to dark / light mode

SetColors(_control := 0) {
    ; Sets default colors for each theme (light/dark)
    global DefaultColor, DarkColor

    GuiControlGet, _darkTheme,, % "DarkTheme"
    GuiControlGet, _menuColor,, % "MenuColor"
    GuiControlGet, _guiColor,,  % "GuiColor"

    if (!_menuColor && _darkTheme) {
        GuiControl,, % "MenuColor", % DarkColor
    }
    if (!_guiColor && _darkTheme) {
        GuiControl,, % "GuiColor", % DarkColor
    }
    if (_menuColor = DarkColor && !_darkTheme) {
        GuiControl,, % "MenuColor", % DefaultColor
    }
    if (_guiColor = DarkColor && !_darkTheme) {
        GuiControl,, % "GuiColor", % DefaultColor
    }
}

SetDarkControls(_winId) {
    ; Sets dark theme for all non-text window controls.

    WinGet, _ctrlIdList, % "ControlListHwnd", % "ahk_id " _winId
    Loop, parse, _ctrlIdList, `n
    {
        WinGetClass, _ctrlClass, % "ahk_id " A_LoopField
        
        switch _ctrlClass {
        case "ComboBox", "Edit":
            SetWindowTheme(A_LoopField, "DarkMode_CFD")
        case "msctls_hotkey32":
            SetWindowTheme(A_LoopField, "DarkMode_CFD", true)
        case "msctls_updown32", "ListBox", "CheckBox":
            SetWindowTheme(A_LoopField, "DarkMode_Explorer")
        case "Button":
            SetWindowTheme(A_LoopField, "DarkMode_Explorer")
        case "SysListView32", "SysHeader32":
            SetWindowTheme(A_LoopField, "DarkMode_ItemsView")
        ; case "SysTabControl32": 
        ;
        default:
            SetWindowTheme(A_LoopField, "DarkMode_Explorer", true)
        }
    }
    
}

SetWindowTheme(_winId, _theme := "DarkMode_DarkTheme", _enforce := false) {
    static SetWindowTheme := DllCall("GetProcAddress"
        , "ptr", DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
        , "astr", "SetWindowTheme", "ptr")
    
    static fullyDark := VerCompare(A_OSVersion, "10.0.26100") >= 0
    if (fullyDark && !_enforce)
        return DllCall(SetWindowTheme, "ptr", _winId, "str", "DarkMode_DarkTheme", "ptr", 0)
        
    return DllCall(SetWindowTheme, "ptr", _winId, "str", _theme, "ptr", 0)    
}


InitControlsColorsHandlers(_state := true) {
    global GuiColor, DarkTheme, DarkColor, LightColor

    if DarkTheme {
        _color := GuiColor ? GuiColor : DarkColor
    } else {
        _color := GuiColor ? GuiColor : LightColor
    }

    global ControlsBackColor := ToBGR(DarkenColor(ToHEX(_color)))
    global ControlsTextColor := ToHEX(InvertColor(ToHEX(_color)))
    global GuiBackColor      := ToBGR(ToHEX(_color))

    OnMessage(0x0133, "OnEditColor", _state)
    OnMessage(0x0134, "OnListBoxRender", _state)
    OnMessage(0x0135, "OnButtonRender", _state)

    if !_state {
        ; Cleanup cache
        OnEditColor(false, false)
        CreateBrush(false)
    }
}

InitDarkTheme() {
	; https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661&hilit=dark#p426437
    ; https://gist.github.com/rounk-ctrl/b04e5622e30e0d62956870d5c22b7017
	global

    InitControlsColorsHandlers(false)

    ; if (Last.DarkTheme = DarkTheme) {
        ; return
    ; }
    
    static uxTheme := DllCall("GetModuleHandle", "str", "uxTheme", "ptr")
	static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxTheme, "ptr", 135, "ptr")
	static FlushThemes := DllCall("GetProcAddress", "ptr", uxTheme, "ptr", 136, "ptr")

	DllCall(SetPreferredAppMode, "int", DarkTheme ? 2 : 0)
	DllCall(FlushThemes)
}

CreateBrush(_color) {
    static brushes := {}
    
    if (_color = false) {
        for _, brush in brushes {
            DllCall("DeleteObject", "Ptr", brush)
        }
        brushes := {}
        return 0
    }
    
    if !brushes.hasKey(_color) {
        brushes[_color] := DllCall("gdi32\CreateSolidBrush", "UInt", _color, "Ptr")
    }

    return brushes[_color]
}

SetControlColors(_hdc, _back := 0, _text := 0) {
    global ControlsBackColor, ControlsTextColor
    
    if !_back {
        _back := ControlsBackColor
    }
    if !_text {
        _text := ControlsTextColor
    }

    DllCall("gdi32\SetBkColor",   "Ptr", _hdc, "UInt", _back)
    DllCall("gdi32\SetTextColor", "Ptr", _hdc, "UInt", _text)
    DllCall("gdi32\SetBkMode",    "Ptr", _hdc, "Int", 1)   ; transparent
    
    return CreateBrush(_back)
}

OnEditColor(_hdc, _control) {
    ; Sets background color of the control based on it's value.
    ; Allows to demonstrate a color by rendering it as control's background.
    static last := {}
    if (_hdc = false && _control = false) {
        last := {}
        return 0
    }

    GuiControlGet, _name, % "Name", % _control
    if !InStr(_name, "Color")
        return SetControlColors(_hdc)

    GuiControlGet, _text,, % _control
    if (_text = "")
        return 0

    if !(RegExMatch(_text, "i)^(\#|0x)?([a-f0-9]{6,})$", _color))
        return 0

    ; Clamp number with 6+ digits
    _value := _color2
    if (StrLen(_value) > 6) {
        if last.hasKey(_name) {
            GuiControl,, % _control, % last[_name]
        } else {
            _c := _color1 . SubStr(_value, 1, 6)
            GuiControl,, % _control, % _c
            last[_name] := _c
        }
        _value := last[_name]
    } else {
        last[_name] := _color1 . _value
    }

    _color := Min(ToHEX(_value), 0xEEEEEE)  ; clamp for readability    
    return SetControlColors(_hdc, ToBGR(_color), 0xFFFFFF)
}

OnListBoxRender(_hdc, _control) {
    return SetControlColors(_hdc)
}

OnButtonRender(_hdc, _control) {
    global GuiBackColor
    DllCall("gdi32\SetBkMode", "Ptr", _hdc, "Int", 1)   ; transparent
    return CreateBrush(GuiBackColor)
}

InvertColor(_color) {
    _R := (_color >> 16) & 0xFF
    _G := (_color >> 8) & 0xFF
    _B := _color & 0xFF

    _luminance := 0.299 * _R + 0.587 * _G + 0.114 * _B

    ; Dynamic gray to add readability.
    _gray := _luminance < 128
        ? Round(255 - _luminance * 35 / 128)       ; 255 -> 220
        : Round((_luminance - 128) * 40 / 127)     ; 0 -> 40

    ; To RGB
    return Format("{:x}", _gray | (_gray << 8) | (_gray << 16))
}

DarkenColor(_color, _factor := 0.85) {
    _R := (_color >> 16) & 0xFF
    _G := (_color >> 8) & 0xFF
    _B := _color & 0xFF
    
    _R := Round(_R  * _factor)
    _G := Round(_G  * _factor)
    _B := Round(_B  * _factor)
    
    return (_R << 16) | (_G << 8) | _B
}

ToBGR(_color) {
    return ((_color >> 16) & 0xFF)
         | (_color & 0x00FF00)
         | ((_color & 0xFF) << 16)
}

ToHEX(_hex) {
    _hex := "0x" . _hex
    _hex := _hex + 0
    return _hex
}

IsDarkTheme() {
    ; Returns true if system or apps doesn't use light theme or (custom) theme contains dark theme words
    try {
        static reg := "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes"

        RegRead, _theme,    % reg,                % "CurrentTheme"
        RegRead, _appLight, % reg "\Personalize", % "AppsUseLightTheme"
        ; RegRead, _sysLight, % reg "\Personalize", % "SystemUsesLightTheme"

        return (_appLight = 0)
            && !(_theme ~= "Ui).*\b(dark|night|gray)\b.*")
    }
    return false
}


GetInstalledFonts() {
    _list := ""
    Loop, Reg, % "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    {
        ; Extract base font name
        _name := RegExReplace(A_LoopRegName, " \(.*\)$")
        _name := RegExReplace(_name, "\d+(,\d+)*$")
        _list .= "|" . _name
    }
    return LTrim(_list, "|")
}

GetFontList(_font) {
    static list := GetInstalledFonts()

    if _font
        return _font "||" list  ; pre-select font in the list

    return list
}


SetMenuFont(_name := "", _size := 0, _weight := 0, _isItalic := -1) {
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

InitMenuFont() {
    ; Sets font and font attributes for all menus in the system.
    ; Prevents multiple font changes.
    global

    if (MenuFont = Last.MenuFont && MenuFontSize = Last.MenuFontSize)
        return

    if !SetMenuFont(MenuFont, MenuFontSize)
        return

    MsgBox % "
    (LTrim Join`s
    The font has been changed. To roll back changes, open the settings,
    make the field empty and set the size to 0.
    `n`nRestart the " ScriptName " manually.
    )"

    ExitApp
}

ValidateMenuFont(_name, _size) {
    ; Returns a pairs "param=value" where `value` is the new font and it's size
    ; if the user agreed to change the font, otherwise the old ones.
    ; See SetMenuFont() and InitMenuFont()
    global ScriptName, Last

    if (_name = Last.MenuFont && _size = Last.MenuFontSize) {
        return "MenuFont=" _name "`nMenuFontSize=" _size "`n"
    }

    _warningMsg := "The font "
    if !(_name || _size)
        _warningMsg .= "will be reset to system defaults "

    if _name
        _warningMsg .= "will be set to """ _name """ "
    if (_name && _size)
        _warningMsg .= "and its "
    if _size
        _warningMsg .= "size will be set to " _size " "

    _warningMsg .= "
    (LTrim Join`s
    for all menus in the system.
    `n`nThe font in the tray menu and context menu will be changed;
    the font in the " ScriptName " menu will be changed.
    `n`nDo you want to continue?
    )"

    if !MsgWarn(_warningMsg) {
        ; Restore previous values
        return "MenuFont=" Last.MenuFont "`nMenuFontSize=" Last.MenuFontSize "`n"
    }

    return "MenuFont=" _name "`nMenuFontSize=" _size "`n"
}