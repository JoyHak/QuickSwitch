/*
    Contains all global variables necessary for the application,
    functions that read/write INI configuration,
    functions that check (validate) values for compliance
    with the requirements of different libraries.

    "INI" param must be a path to a write-accessible file (with any extension)
 */

; These parameters are not saved in the INI
SelectPathAttempts :=  3
DialogId           :=  0
EditId             :=  0
FingerPrint        :=  ""
DialogAction       :=  ""
SaveDialogAction   :=  false
FromSettings       :=  false
NukeSettings       :=  false
LastTabSettings    :=  1
Paths              :=  []
ElevatedApps       :=  {updated: false}

SetDefaultValues() {
    /*
        Sets defaults without overwriting existing INI.

        These values are used if:
        - INI settings are invalid
        - INI doesn't exist (yet)
        - the values must be reset
    */
    global

    AutoStartup         :=  true
    ShowNoSwitch        :=  true
    ShowAfterSettings   :=  true
    PathNumbers         :=  true

    AutoSwitch          :=  false
    BlackListExe        :=  false
    DeleteDialogs       :=  false
    ShowAlways          :=  false
    ShowAfterSelect     :=  false
    DarkTheme           :=  false
    SendEnter           :=  false
    ShortPath           :=  false
    ShortenEnd          :=  false
    ShowDriveLetter     :=  false
    ShowFirstSeparator  :=  false

    GuiColor := MenuColor := ""
    RestartMouse := MainMouse := ""

    ShortNameIndicator := ".."
    DirsCount      := 3
    DirNameLength  := 20
    PathLimit      := 9
    PathSeparator  := "\"

    RestartWhere   := "ahk_exe notepad++.exe"
    MainFont       := "Tahoma"
    MainKey        := "^sc10"
    RestartKey     := "^sc1F"
    MainIcon       := ""

    ;@Ahk2Exe-IgnoreBegin
    MainIcon := "QuickSwitch.ico"
    ;@Ahk2Exe-IgnoreEnd
}

;─────────────────────────────────────────────────────────────────────────────
;
WriteValues() {
;─────────────────────────────────────────────────────────────────────────────
      /*
          Calls validators and writes values to INI

          The boolean (checkbox) values is writed immediately.
          The individual special values are checked before writing.
      */
    global

    local _values := "
    (LTrim
         AutoStartup="          AutoStartup             "
         AutoSwitch="           AutoSwitch              "
         BlackListExe="         BlackListExe            "
         DeleteDialogs="        DeleteDialogs           "
         ShowAlways="           ShowAlways              "
         ShowNoSwitch="         ShowNoSwitch            "
         ShowAfterSelect="      ShowAfterSelect         "
         ShowAfterSettings="    ShowAfterSettings       "
         SendEnter="            SendEnter               "
         PathNumbers="          PathNumbers             "
         ShortPath="            ShortPath               "
         PathSeparator="        PathSeparator           "
         ShortNameIndicator="   ShortNameIndicator      "
         DirsCount="            DirsCount               "
         DirNameLength="        DirNameLength           "
         PathLimit="            PathLimit               "
         ShortenEnd="           ShortenEnd              "
         ShowDriveLetter="      ShowDriveLetter         "
         ShowFirstSeparator="   ShowFirstSeparator      "
         MainFont="             MainFont                "
         RestartWhere="         RestartWhere            "
         RestartMouse="         RestartMouse            "
         MainMouse="            MainMouse               "
         DarkTheme="            DarkTheme               "
    )"

    _values .= "`n"
            . ValidateTrayIcon( "MainIcon",    MainIcon)
            . ValidateColor(    "GuiColor",    GuiColor)
            . ValidateColor(    "MenuColor",   MenuColor)
            . ValidateKey(      "MainKey",     MainMouse ? MainMouse : MainKey,          "",  "Off", "^#+0")
            . ValidateKey(      "RestartKey",  RestartMouse ? RestartMouse : RestartKey, "~", "On",  "RestartApp")

    try {
        IniWrite, % _values, % INI, Global
    } catch {
        LogError("Please create this file with UTF-16 LE BOM encoding manually: `'" INI "`'"
               , "config"
               , ValidateFile(INI))
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ReadValues() {
;─────────────────────────────────────────────────────────────────────────────
    ; Reads values from INI
    global

    if !FileExist(INI)
        return

    local _values, _array, _variable, _value
    IniRead, _values, % INI, Global

    Loop, Parse, _values, `n
    {
        _array      := StrSplit(A_LoopField, "=")
        _variable   := _array[1]
        _value      := _array[2]
        %_variable% := _value
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateTrayIcon(_paramName, ByRef icon) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        If the file exists, changes the tray icon
        and returns a string of the form "paramName=result",
        otherwise returns empty string
    */

    if icon {
        if FileExist(icon) {
            Menu, Tray, Icon, % icon
            return _paramName "=" icon "`n"
        }
        LogError("Icon `'" icon "`' not found", "tray icon", "Specify the full path to the file")
    }
    return ""
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateColor(_paramName, ByRef color) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Searches for a HEX number in any form, e.g. 0x, #, h

        If found, returns the string of the form "paramName=result",
        otherwise returns "paramName= " (empty color)
    */

    if color {
        if (_matchPos := RegExMatch(color, "i)[a-f0-9]{6}$")) {
            return _paramName . "=" . SubStr(color, _matchPos) . "`n"
        }
        LogError("Wrong color: `'" color "`'. Enter the HEX value", _paramName)
    }

    return _paramName "=`n"
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateKey(_paramName, _sequence, _prefix := "", _state := "On", _function := "") {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Replaces modifier names with
        standard modifiers ! ^ + #

        Replaces chars / letters in sequence with
        scan codes, e.g. Q -> sc10

        If converted, returns the string of the form "paramName=result",
        otherwise returns empty string
    */
    global INI

    try {
        if !(_sequence)
            return false
            
        if (_sequence ~= "i)sc[a-f0-9]+") {
            ; Already converted
            _key := _sequence
        } else if (GetMouseList("isMouse", _sequence)) {
            ; Convert to mouse buttons
            _key := GetMouseList("convert", _sequence)
        } else {
            ; Convert sequence to Scan Codes (if not converted)
            _key := ""
            Loop, parse, _sequence
            {
                if (!(A_LoopField ~= "[\!\^\+\#<>]")
                    && _code := GetKeySC(A_LoopField)) {
                    ; Not a modifier, found scancode
                    _key .= Format("sc{:x}", _code)
                } else {
                    ; Don't change
                    _key .= A_LoopField
                }
            }
        }

        if _function {
            ; Register new hotkey
            Hotkey, % _prefix . _key, % _function, % _state
            try {
                ; Remove old if exist
                IniRead, _old, % INI, Global, % _paramName, % _key
                if (_old != _key) {
                    Hotkey, % _prefix . _old, % "Off"
                    Hotkey, % _old, % "Off"
                }
            }

        } else {
            ; Set state for existing hotkey
            Hotkey, % _prefix . _key, % _state
        }
        return _paramName "=" _key "`n"

    } catch _ex {
        LogException(_ex)
    }
    return ""
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateFile(ByRef filePath) {
;─────────────────────────────────────────────────────────────────────────────
    _extra := "Cant write data to the file"

    if !filePath {
        _extra := "File path is empty: `'" filePath "`'"
    } else if !FileExist(filePath) {
        _extra := "Unable to create file"
    } else {
        _file := FileOpen(filePath, "r")

        if !IsObject(_file) {
            FileGetAttrib, _attr, % filePath
            _extra := "Unable to get access to the file"
        } else {
            _extra     := "`nRead existing `'" filePath "`'`n"

            _firstLine := RTrim(_file.readLine(), " `r`n")
            _extra     .= Format("Encoding: {} First line: {}, Size in bytes: {} HWND: {}`n"
                                 , _file.encoding, _firstLine, _file.length, _file.handle)
        }
        _file.Close()

        try {
            FileGetAttrib, _attr, % filePath
            _extra .= "File attributes: " _attr
        }
    }

    return _extra "`n"
}