; Contains functions for switching Menu and GUI to dark / light / mica mode

IsThemesAvailable := VerCompare(A_OSVersion, "10.0.26100") >= 0

SetDarkTheme(_winId) {
    ; Sets dark theme for all non-text window controls.
    ; Inspired by DarkMode from jNizM
    ; https://www.autohotkey.com/boards/viewtopic.php?f=92&t=115952&p=621245#p621245
    
    if (_winId = -1) {
        ; Last Found window
        WinGet, _ctrlIdList, % "ControlListHwnd"        
    } else {
        WinGet, _ctrlIdList, % "ControlListHwnd", % "ahk_id " _winId
    }

    Loop, parse, _ctrlIdList, `n
    {
        WinGetClass, _ctrlClass, % "ahk_id " A_LoopField

        switch _ctrlClass {
        case "Edit":
            SetWindowTheme(A_LoopField, "DarkMode_CFD")
        case "Combobox":
            SetWindowTheme(A_LoopField, "DarkMode_CFD")  ; edit field
            SetWindowTheme(GetComboList(A_LoopField), "DarkMode_Explorer")  ; internal list
            SendMessage(A_LoopField, 0x0142, 0, 0xFFFF) ; remove selection (CB_SETEDITSEL)

        case "msctls_hotkey32":
            SetWindowTheme(A_LoopField, "DarkMode_CFD", true)
        case "msctls_updown32", "ListBox", "CheckBox":
            SetWindowTheme(A_LoopField, "DarkMode_Explorer")
        case "Button":
            global IsThemesAvailable
            if (IsThemesAvailable || !IsCheckbox(A_LoopField)) {
                ; Checkbox text may become inverted on previous Windows builds
                SetWindowTheme(A_LoopField, "DarkMode_Explorer")
            }
        case "SysListView32", "SysHeader32":
            SetWindowTheme(A_LoopField, "DarkMode_ItemsView", true)
        }
    }
}

GetComboList(_control) {
    ; https://www.autohotkey.com/boards/viewtopic.php?f=92&t=139862&p=613750&hilit=dark+checkbox#p613750

    CBISize := 40 + (A_PtrSize * 3)
    VarSetCapacity(CBI, CBISize, 0)
    NumPut(CBISize, CBI, 0, "UInt")
    DllCall("GetComboBoxInfo", "Ptr", _control, "Ptr", &CBI)

    return NumGet(CBI, 40 + (A_PtrSize * 2), "Ptr")
}

IsCheckbox(_control) {
    _s := 0x000F & GetWindowLong(_control)
    
    ; BS_CHECKBOX, BS_AUTOCHECKBOX, BS_3STATE, BS_AUTO3STATE
    return _s = 0x0002 || _s = 0x0003 || _s = 0x0005 || _s = 0x0006
}


SetWindowTheme(_winId, _theme := "DarkMode_DarkTheme", _enforce := false) {
    global IsThemesAvailable
    
    static uxTheme := DllCall("GetModuleHandle", "str", "uxTheme", "ptr")
	static SetWindowTheme := DllCall("GetProcAddress", "ptr", uxTheme, "astr", "SetWindowTheme", "ptr")
    static WM_THEMECHANGED := 0x031A
    
    SetImmersiveDarkMode(_winId)

    if (IsThemesAvailable && !_enforce) {
        _theme := "DarkMode_DarkTheme"
    }
    
    DllCall(SetWindowTheme, "ptr", _winId, "str", _theme, "ptr", 0)
    SendMessage(_winId, WM_THEMECHANGED)
}

GetImmersiveDarkMode() {
    if VerCompare(A_OSVersion, "10.0.17763") < 0
        return 0
    if VerCompare(A_OSVersion, "10.0.18985") < 0
        return 19
        
    return 20
}

SetImmersiveDarkMode(_winId, _state := true) {
    static AllowDarkModeForWindow := 0
    static DwmSetWindowAttribute  := 0

    static mode := GetImmersiveDarkMode()
    if !mode
        return
        
    if !AllowDarkModeForWindow {        
        AllowDarkModeForWindow := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "uxTheme", "ptr"), "ptr", 133, "ptr")
    }
    if !DwmSetWindowAttribute {
        DwmSetWindowAttribute  := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "dwmapi", "ptr"), "astr", "DwmSetWindowAttribute", "ptr")
    }
    
    DllCall(AllowDarkModeForWindow, "Ptr", _winId, "UInt", _state)
    DllCall(DwmSetWindowAttribute,  "Ptr", _winId, "Int", mode, "Int*", _state, "Int", 4)
}


SetGlassTheme(_winId, _mode := 3) {
    ; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=140577&p=617944&hilit=Mica#p617944
    
    if (_mode >= 4 || _mode <= 0)
        _mode := 1

    static GWL_EXSTYLE   := -20
    static WS_EX_LAYERED := 0x80000
    ; static WS_OVERLAPPEDWINDOW := 0x00CF0000    ; causes glitches

    _style := GetWindowLong(_winId, GWL_EXSTYLE)
    if (_mode != 1)
        _style |= WS_EX_LAYERED
    else
        _style &= ~WS_EX_LAYERED
    
    SetWindowLong(_winId, GWL_EXSTYLE, _style)
    
    DllCall("SetLayeredWindowAttributes",   "Ptr", _winId, "UInt", 0, "UChar", 255, "UInt", 2)    ; LWA_ALPHA 
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", _winId, "UInt", 38, "Int*", _mode, "UInt", 4)  ; DWMWA_SYSTEMBACKDROP_TYPE

    ; Apply Glass Margins into the entire client area
    VarSetCapacity(_margins, 16, 0)
    _size := (_mode != 1) ? -1 : 0

    NumPut(_size, _margins,  0, "Int")  ; left
    NumPut(_size, _margins,  4, "Int")  ; top
    NumPut(_size, _margins,  8, "Int")  ; right
    NumPut(_size, _margins, 12, "Int")  ; bottom
    
    DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Ptr", _winId, "Ptr", &_margins)

    ; Force a frame redraw so the new extended style takes effect immediately
    ; SWP_FRAMECHANGED, SWP_NOMOVE, SWP_NOSIZE, SWP_NOZORDER, SWP_NOACTIVATE
    DllCall("SetWindowPos", "Ptr", _winId, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0
          , "UInt", 0x0020 | 0x0002 | 0x0001 | 0x0004 | 0x0010)
}

SetSettingsGlassTheme() {
    global SettingsId
    GuiControlGet, _glassTheme,, % "GlassTheme"
    SetGlassTheme(SettingsId, _glassTheme)
}

SetSettingsInputColors(_control := 0) {
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

InitControlsColorsHandlers(_state := true) {
    ; Registers control render handlers 
    ; that apply background colors to controls
    
    global GuiColor
    global GuiBackColor, ControlsBackColor, ControlsTextColor

    if _state {
        ; Setup colors
        switch GuiColor {
        case "":
            GuiBackColor := ""   ; default

            ; Controls must have a color to be readable
            static backColor  := DllCall("GetSysColor", "Int", 5, "UInt")
            static textColor  := DllCall("GetSysColor", "Int", 8, "UInt")
            
            ControlsBackColor := DarkenColor(backColor)
            ControlsTextColor := textColor
        case 0:
            GuiBackColor := 0    ; black
            _color := 0x0c0c0c   ; very dark gray
            ControlsBackColor := _color
            ControlsTextColor := InvertColor(_color)
        default:
            _color := ToHEX(GuiColor)
            GuiBackColor := ToBGR(_color)
            ControlsBackColor := DarkenColor(_color)
            ControlsTextColor := InvertColor(_color)
        }
    } else {
        ; Cleanup cache
        OnEditColor(-1, -1)
        CreateBrush(-1)
    }

    OnMessage(0x0133, "OnEditColor", _state)
    OnMessage(0x0134, "OnListBoxRender", _state)
    OnMessage(0x0135, "OnButtonRender", _state && GuiColor != "")
    OnMessage(0x0138, "OnStaticRender", _state)
}

CreateBrush(_color) {
    static brushes := {}

    if (_color = -1) {
        for _, brush in brushes {
            DllCall("DeleteObject", "Ptr", brush)
        }
        brushes := {}
        return 0
    }

    if !brushes.hasKey(_color) {
        brushes[_color] := (_color != "")
          ? DllCall("gdi32\CreateSolidBrush", "UInt", _color, "Ptr")
          : 0
    }

    return brushes[_color]
}

SetControlColors(_hdc, _back := 0, _text := 0) {
    ; Inspired by DarkGui from TrueCrimeDev
    ; https://github.com/TrueCrimeDev/DarkGui/blob/adf5e7389b80bb7d4d895d037f0d6153a871271b/DarkModeModular.ahk#L2053
    global ControlsBackColor, ControlsTextColor

    if !_back {
        _back := ControlsBackColor
    }
    if !_text {
        _text := ControlsTextColor
    }

    DllCall("gdi32\SetBkColor",   "Ptr", _hdc, "UInt", _back)
    DllCall("gdi32\SetTextColor", "Ptr", _hdc, "UInt", _text)
    DllCall("gdi32\SetBkMode",    "Ptr", _hdc, "Int",  1)   ; transparent

    return CreateBrush(_back)
}

OnEditColor(_hdc, _control) {
    ; Sets background color of the control based on it's value.
    ; Allows to demonstrate a color by rendering it as control's background.
    static last := {}
    if (_hdc = -1 && _control = -1) {
        last := {}
        return 0
    }

    GuiControlGet, _name, % "Name", % _control
    if !InStr(_name, "Color")
        return SetControlColors(_hdc)

    GuiControlGet, _text,, % _control
    if (_text = ""
     || !RegExMatch(_text, "i)^(\#|0x)?([a-f0-9]{6,})$", _color))
        return SetControlColors(_hdc)

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

OnStaticRender(_hdc, _control) {
    global GuiBackColor, ControlsTextColor
    
    if (GetWindowLong(_control) & 0x0800) {  ; ES_READONLY
        ; Edit control
        return SetControlColors(_hdc)
    }

    ; Text/Checkbox
    SetControlColors(_hdc, GuiBackColor, ControlsTextColor)
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

    ; Fill each component
    return (_gray << 16) | (_gray << 8) | _gray
}

DarkenColor(_color, _factor := 0.85) {
    _R := (_color >> 16) & 0xFF
    _G := (_color >> 8) & 0xFF
    _B := _color & 0xFF

    _R := Round(_R  * _factor)
    _G := Round(_G  * _factor)
    _B := Round(_B  * _factor)

    return (_B << 16) | (_G << 8) | _R
}

ToBGR(_color) {
    return ((_color >> 16) & 0xFF)
         | (_color & 0x00FF00)
         | ((_color & 0xFF) << 16)
}

ToHEX(_string) {
    _num := "0x" . _string
    return _num + 0
}

ToHexString(_hex) {
    return Format("{:x}", _hex)
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

SetMenuDarkTheme() {
    ; Applies dark theme to the context menu
	; https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661&hilit=dark#p426437
    ; https://gist.github.com/rounk-ctrl/b04e5622e30e0d62956870d5c22b7017
	global

    if (Last.DarkTheme = DarkTheme) {
        return
    }

    static uxTheme := DllCall("GetModuleHandle", "str", "uxTheme", "ptr")
	static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxTheme, "ptr", 135, "ptr")
	static FlushThemes := DllCall("GetProcAddress", "ptr", uxTheme, "ptr", 136, "ptr")

	DllCall(SetPreferredAppMode, "int", DarkTheme ? 2 : 0)
	DllCall(FlushThemes)
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