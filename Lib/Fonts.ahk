; Contains functions for switching Menu and GUI font family and size (GUI font size affects GUI scaling).

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
    ; Sets font name and font attributes for all menus in the system.
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


GetFontList(_font) {
    static list := GetInstalledFonts()

    if _font
        return _font "||" list  ; pre-select font in the list

    return list
}

GetInstalledFonts() {
    ; Inspired by GetFontNames from teadrinker
    ; https://www.autohotkey.com/boards/viewtopic.php?t=66000

    _hdc := DllCall("GetDC", "Ptr", 0)
    VarSetCapacity(_LOGFONT, 92, 0)
    NumPut(1, &_LOGFONT + 23, "UChar")  ; DEFAULT_CHARSET

    ; Create callback for EnumFontFamiliesExW
    _EnumFontFamilies := RegisterCallback("EnumFontFamilies", "F", 4)

    DllCall("EnumFontFamiliesExW"
        , "Ptr", _hdc
        , "Ptr", &_LOGFONT
        , "Ptr", _EnumFontFamilies
        , "Ptr", _fontsPtr := Object(_fonts := {})
        , "UInt", 0)

    ObjRelease(_fontsPtr)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", _hdc)
    DllCall("GlobalFree", "Ptr", _EnumFontFamilies, "Ptr")
    
    _list := ""
    for _name, _ in _fonts {
        _list .= "|" _name
    }

    return LTrim(_list, "|")
}

EnumFontFamilies(_lpelfe, _lpntme, _fontType, _lParam) {
    _font := StrGet(_lpelfe + 28, "UTF-16")

    ; Skip vertical fonts
    if (SubStr(_font, 1, 1) = "@")
        return 1

    ; Check exclusions
    for _, _val in ["8514oem", "Roman", "Script", "Courier", "Fixedsys"
        , "MS Sans Serif", "MS Serif", "Modern", "Small Fonts"
        , "System", "Terminal"] 
    {
        if (_val = _font) {
            return 1
        }
    }

    Object(_lParam)[_font] := true
    return 1  ; continue enumeration
}

; Using emojis and fonts is cheaper than separate icons files, 
; but we need additional code for old Windows builds
IsSupportedChar(_fontName, _char) {
    ; Create font
    _fontId := DllCall("gdi32\CreateFontW"
      , "int",  -16,  ; nHeight
      , "int",  0,    ; nWidth
      , "int",  0,    ; nEscapement
      , "int",  0,    ; nOrientation
      , "int",  400,  ; fnWeight (FW_NORMAL)
      , "uint", 0,    ; fdwItalic
      , "uint", 0,    ; fdwUnderline
      , "uint", 0,    ; fdwStrikeOut
      , "uint", 0,    ; fdwCharSet (DEFAULT)
      , "uint", 0,    ; fdwOutputPrecision
      , "uint", 0,    ; fdwClipPrecision
      , "uint", 0,    ; fdwQuality
      , "uint", 0,    ; fdwPitchAndFamily
      , "str",  _fontName,   ; lpszFaceName
      , "ptr")

    ; Create compatible DC
    _hdc := DllCall("gdi32\CreateCompatibleDC", "ptr", 0, "ptr")
    _fontCopy := DllCall("gdi32\SelectObject", "ptr", _hdc, "ptr", _fontId, "ptr")

    ; Get _glyph index
    _glyph := DllCall("gdi32\Get_glyphIndicesW"
        , "ptr",  _hdc,
        , "wstr", _char,
        , "int",  2,  ; length in UTF‑16 code units
        , "ptr",  0,  ; not used
        , "uint", 0,  ; flags
        , "uint")

    ; Clean up
    DllCall("gdi32\SelectObject", "ptr", _hdc, "ptr", _fontCopy)
    DllCall("gdi32\DeleteObject", "ptr", _fontId)
    DllCall("gdi32\DeleteDC",     "ptr", _hdc)

    return (_glyph != 0xFFFF)
}

GetCharOrDefault(_char, _default) {
    global MainFont
    return IsSupportedChar(MainFont, _char) ? _char : _default
}