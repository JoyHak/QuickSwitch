; Contains functions for switching Menu and GUI to dark / light / mica mode

IsThemesAvailable := (VerCompare(A_OSVersion, "10.0.26100") >= 0) && !InStr(A_OSVersion, "WIN_")

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
            SendMessageW(A_LoopField, 0x0142, 0, 0xFFFF) ; remove selection (CB_SETEDITSEL)

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
    SendMessageW(_winId, WM_THEMECHANGED)
}

GetImmersiveDarkMode() {
    if (VerCompare(A_OSVersion, "10.0.17763") < 0) 
     || InStr(A_OSVersion, "WIN_")
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
    
    ; Extract components, cap each at 0xEE for readability with white font
    _color := ToHEX(_value)
    _r := (_color >> 16) & 0xFF
    _g := (_color >> 8) & 0xFF
    _b := _color & 0xFF
    _r := (_r > 0xEE) ? 0xEE : _r
    _g := (_g > 0xEE) ? 0xEE : _g
    _b := (_b > 0xEE) ? 0xEE : _b
    
    return SetControlColors(_hdc, (_b << 16) | (_g << 8) | _r, 0xFFFFFF)
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
    return Format("{:06x}", _hex)
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


ShowColorPicker(_winId := 0, _color := "FFFFFF", _fullPanel := true) {
    ; https://www.autohotkey.com/board/topic/94083-ahk-11-font-and-_color-dialogs
    ; https://github.com/TheArkive/ColorPicker_ahk2 

    _size := (A_PtrSize = 8) ? 72 : 36
    VarSetCapacity(_CHOOSECOLOR, _size, 0)
    VarSetCapacity(_CUSTOM, 16 * 4, 0)
    
    _bgr := ToBGR(ToHex(_color))
    _flags := _fullPanel ? 0x3 : 0x1 ; full panel / basic panel

    NumPut(_size,     _CHOOSECOLOR, 0,             "UInt")   ; lStructSize
    NumPut(_winId,    _CHOOSECOLOR, A_PtrSize,     "UPtr")   ; hwndOwner
    NumPut(_bgr,      _CHOOSECOLOR, 3 * A_PtrSize, "UInt")   ; rgbResult
    NumPut(&_CUSTOM,  _CHOOSECOLOR, 4 * A_PtrSize, "UPtr")   ; lpCustColors
    NumPut(_flags,    _CHOOSECOLOR, 5 * A_PtrSize, "UInt")   ; _flags

    if !DllCall("comdlg32\ChooseColor", "Ptr", &_CHOOSECOLOR, "Int")
        return ""
    
    ; BGR
    return NumGet(_CHOOSECOLOR, 3 * A_PtrSize, "UInt")
}

SetPickedColor(_control := 0) {
    global SettingsId
    
    ; Get associated color field
    GuiControlGet, _name, % "Name", % _control
    _name := StrReplace(_name, "Pick")
    
    ; Pick a color
    GuiControlGet, _color,, % _name
    
    _result := ShowColorPicker(SettingsId, _color)
    if (_result != "")
        GuiControl,, % _name, % ToHexString(ToBGR(_result))
}