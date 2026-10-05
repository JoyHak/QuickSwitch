; Contains functions for switching Menu and GUI font family and size (GUI font size affects GUI scaling).

SetMenuFont(_name := "", _size := 0, _weight := 0, _isItalic := -1) {
    ; Sets font and font attributes for all menus in the system.
    ; Returns true on success

    static SPI_GETNONCLIENTMETRICS := 0x29
    static SPI_SETNONCLIENTMETRICS := 0x2A
    static SPI_SETICONTITLELOGFONT := 0x22
    static SPIF_UPDATEINIFILE      := 0x1
    static SPIF_SENDCHANGE         := 0x2

    static sizeOfLFW := 92
    static sizeOfNCM := 40 + 5 * sizeOfLFW
    
    ; Get the font
    VarSetCapacity(_metrics, sizeOfNCM, 0)
    NumPut(sizeOfNCM, &_metrics, 0, "UInt")  ; cbSize

    if !DllCall("SystemParametersInfoW"
        , "UInt", SPI_GETNONCLIENTMETRICS
        , "UInt", sizeOfNCM
        , "Ptr",  &_metrics
        , "UInt", 0) {
        return LogError("Unable to retrieve system font"
                      , "menu font"
                      , "Result: " A_LastError)
    }
    
    ; Get pointer to lfMenuFont
    _offset  := 40 + 2 * sizeOfLFW
    _address := &_metrics + _offset

    if _name {
        ; The length of this string must not exceed 32 characters incl. \0
        StrPut(_name, _address + 28, 31)  ; lfFaceName
    }

    if _size {
        ; Negative value = character height (not cell height)
        _height := -DllCall("MulDiv"
            , "Int", _size
            , "Int", A_ScreenDPI
            , "Int", 72)
        NumPut(_height, _address + 0, "Int")
    }

    if _weight
        NumPut(_weight, _address + 16, "Int")

    if (_isItalic = 1 || _isItalic = 0)
        NumPut(_isItalic, &_address + 20, "UChar")

    if !DllCall("SystemParametersInfoW"
        , "UInt", SPI_SETNONCLIENTMETRICS
        , "UInt", sizeOfNCM
        , "Ptr",  &_metrics
        , "UInt", SPIF_UPDATEINIFILE | SPIF_SENDCHANGE) {
        return LogError("Unable to set system font"
                      , "menu font"
                      , "Result: " A_LastError)
    }
    
    ; Allow system time to broadcast WM_SETTINGCHANGE and update UI
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
    
    ValidateFont("MenuFont", _font := _name)
    if (_font != _name) {
        return "MenuFont=" Last.MenuFont "`nMenuFontSize=" Last.MenuFontSize "`n"
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
        Last.MenuFont := _name
        Last.MenuFontSize := _size
        return "MenuFont=" Last.MenuFont "`nMenuFontSize=" Last.MenuFontSize "`n"
    }

    return "MenuFont=" _name "`nMenuFontSize=" _size "`n"
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

; Using Unicode emojis and fonts is cheaper than separate icons files,
; but we need fallback algorithm for old Windows builds
Char(_fontName, _char, _default := "#") {
    ; Detects whether a Unicode character renders as "tofu" (missing glyph)
    ; by checking if Uniscribe falls back to a symbol font.
    ; Returns _char if it renders properly, otherwise returns _default.
    ; https://stackoverflow.com/q/47840800

    _hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
    if (!_hdc) {
        return _default
    }

    ; Create enhanced metafile DC
    ; Uniscribe will record its font fallback/linking decisions here
    _metaDC := DllCall("gdi32\CreateEnhMetaFileW", "ptr", _hdc, "ptr", 0, "ptr", 0, "ptr", 0, "ptr")
    if (!_metaDC) {
        DllCall("DeleteDC", "Ptr", _hdc)
        return _default
    }

    ; Select font into metafile DC
    ; This gives Uniscribe a reasonable starting font for analysis
    if (_fontName) {
        ; Create font from the passed font name
        static sizeOfLFW  := 92
        VarSetCapacity(_logFont, sizeOfLFW, 0)
        NumPut(92,  _logFont, 0,  "int")    ; lfHeight (negative = character height)
        NumPut(400, _logFont, 16, "int")    ; lfWeight (FW_NORMAL)
        NumPut(1,   _logFont, 23, "uchar")  ; lfCharSet (DEFAULT_CHARSET)

        ; The length of this string must not exceed 32 characters incl. \0
        StrPut(_fontName, &_logFont + 28, 31, "UTF-16")  ; lfFaceName

        _font := DllCall("gdi32\CreateFontIndirectW", "ptr", &_logFont, "ptr")
        DllCall("gdi32\SelectObject", "ptr", _metaDC, "ptr", _font)
    } else {
        ; Use system default font
        _systemFont := DllCall("gdi32\GetStockObject", "int", 17, "ptr")
        DllCall("gdi32\SelectObject", "ptr", _metaDC, "ptr", _systemFont)
        _font := 0  ; Don't delete stock objects
    }

    ; Let Uniscribe analyze the character.
    ; Performs font fallback and linking, recording the chosen font to the metafile
    static SSA_METAFILE := 0x00000020  ; Record font choices to metafile
    static SSA_FALLBACK := 0x00000040  ; Enable font fallback
    static SSA_GLYPHS   := 0x00000080  ; Generate glyph indices
    static SSA_LINK     := 0x00000800  ; Enable font linking

    _len := StrLen(_char)
    _analyzed := DllCall("usp10\ScriptStringAnalyse"
        , "ptr",  _metaDC
        , "wstr", _char
        , "int",  _len
        , "int",  0
        , "int", -1
        , "int",  SSA_METAFILE | SSA_FALLBACK | SSA_GLYPHS | SSA_LINK
        , "int",  0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0
        , "ptr*", _ssa := 0)

    if (_analyzed >= 0) {
        DllCall("usp10\ScriptStringOut"
            , "ptr", _ssa
            , "int", 0, "int", 0, "int", 0
            , "ptr", 0, "int", 0, "int", 0, "int", 0)

        DllCall("usp10\ScriptStringFree", "ptr*", _ssa)
    }

    _metaFile := DllCall("gdi32\CloseEnhMetaFile", "ptr", _metaDC, "ptr")
    _firstGlyph := 0
    _fallbackFont := 0

    if (_analyzed >= 0) {
        ; Capture the fallback font that Uniscribe chose
        VarSetCapacity(_fallbackLogFont, sizeOfLFW, 0)
        _EnumMetafileFont := RegisterCallback("EnumMetafileFont", "", 5)
        DllCall("gdi32\EnumEnhMetaFile"
            , "ptr", 0
            , "ptr", _metaFile
            , "ptr", _EnumMetafileFont
            , "ptr", &_fallbackLogFont
            , "ptr", 0)

        DllCall("GlobalFree", "Ptr", _EnumMetafileFont, "Ptr")

        ; Select the fallback font and get glyph indices
        _fallbackFont := DllCall("gdi32\CreateFontIndirectW", "ptr", &_fallbackLogFont, "ptr")
        DllCall("gdi32\SelectObject", "ptr", _hdc, "ptr", _fallbackFont, "ptr")

        ; GCP_RESULTSW struct for GetCharacterPlacementW
        static sizeOfGCP    := (A_PtrSize = 8) ? 64 : 36
        static lpGlyphsOff  := (A_PtrSize = 8) ? 48 : 24
        static nGlyphsOff   := (A_PtrSize = 8) ? 56 : 28
        static GCP_GLYPHSHAPE := 0x00000010  ; get glyph indices

        VarSetCapacity(_gcpResults, sizeOfGCP, 0)   ; GCP_RESULTSW
        VarSetCapacity(_glyphs, _len * 2, 0)        ; WORD array for glyph indices

        NumPut(sizeOfGCP,  _gcpResults, 0,           "uint")
        NumPut(&_glyphs,   _gcpResults, lpGlyphsOff, "ptr")
        NumPut(_len,       _gcpResults, nGlyphsOff,  "uint")

        _result := DllCall("gdi32\GetCharacterPlacementW"
            , "ptr",  _hdc
            , "wstr", _char
            , "int",  _len
            , "int",  0
            , "ptr",  &_gcpResults
            , "uint", GCP_GLYPHSHAPE, "uint")

        if (_result = 0) {
            ; Treat as tofu
            _firstGlyph := 0
        } else {
            _firstGlyph := NumGet(_glyphs, 0, "ushort")  ; Glyph indices are WORD (2 bytes)
        }
    }
    
    ; Cleanup
    DllCall("gdi32\DeleteEnhMetaFile", "ptr", _metaFile)
    DllCall("DeleteDC", "Ptr", _hdc)
    if (_font) {
        DllCall("gdi32\DeleteObject", "ptr", _font)
    }
    if (_fallbackFont) {
        DllCall("gdi32\DeleteObject", "ptr", _fallbackFont)
    }

    ; Check for tofu indicators
    if (_firstGlyph = 0     ; character not in font (XP behavior)
     || _firstGlyph = 3)    ; fallback to .notdef/symbol glyph (Win7+ behavior)
        return _default

    return _char
}

EnumMetafileFont(_hdc, _table, _record, _tableEntries, _logFont) {
    ; Extracts LOGFONTW from font creation records
    static EMR_EXTCREATEFONTINDIRECTW := 82
    static sizeOfLFW := 92
    static elfLogFontOff := 12

    if (NumGet(_record + 0, "uint") = EMR_EXTCREATEFONTINDIRECTW) {
        ; *reinterpret_cast<LOGFONT*>(_logFont) = _record->elfw.elfLogFont;
        DllCall("RtlMoveMemory", "ptr", _logFont, "ptr", _record + elfLogFontOff, "ptr", sizeOfLFW)
    }
    return 1
}