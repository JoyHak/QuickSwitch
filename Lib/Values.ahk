/*
    Contains all global variables necessary for the application,
    functions that read/write INI configuration,
    functions that check (validate) values for compliance
    with the requirements of different libraries.

    "INI" param must be a path to a write-accessible file (with any extension)
 */

; These parameters are not saved in the INI
FingerPrint       :=  ""
DialogAction      :=  ""
SaveDialogAction  :=  false
FromSettings      :=  false
NukeSettings      :=  false
LastTabSettings   :=  1
Paths             := []

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
    MainKeyHook         :=  true
    ShowNoSwitch        :=  true
    ShowAfterSettings   :=  true

    AutoSwitch          :=  false
    ShowAlways          :=  false
    ShowAfterSelect     :=  false
    RestartKeyHook      :=  false
    CloseDialog         :=  false
    PathNumbers         :=  false
    ShortPath           :=  false
    ShortenEnd          :=  false
    ShowDriveLetter     :=  false
    ShowFirstSeparator  :=  false

    GuiColor := MenuColor := ""

    ShortNameIndicator := ".."
    DirsCount      := 3
    DirNameLength  := 20
    PathSeparator  := "\"

    RestartWhere   := "ahk_exe notepad++.exe"
    MainFont       := "Tahoma"
    MainKey        := "^sc10"
    RestartKey     := "^sc1F"
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

    Values := "
    (LTrim
         AutoStartup="          AutoStartup           "
         AutoSwitch="           AutoSwitch            "
         ShowAlways="           ShowAlways            "
         ShowNoSwitch="         ShowNoSwitch          "
         ShowAfterSelect="      ShowAfterSelect       "
         ShowAfterSettings="    ShowAfterSettings     "
         CloseDialog="          CloseDialog           "
         PathNumbers="          PathNumbers           "
         ShortPath="            ShortPath             "
         ShortenEnd="           ShortenEnd            "
         ShowDriveLetter="      ShowDriveLetter       "
         ShowFirstSeparator="   ShowFirstSeparator    "
         DirsCount="            DirsCount             "
         DirNameLength="        DirNameLength         "
         MainFont="             MainFont              "
         RestartWhere="         RestartWhere          "
         MainKeyHook="          MainKeyHook           "
         RestartKeyHook="       RestartKeyHook        "
    )"

    Values .= "`n"
            . ValidateTrayIcon( "MainIcon",             MainIcon)
            . ValidateColor(    "GuiColor",             GuiColor)
            . ValidateColor(    "MenuColor",            MenuColor)
            . ValidateString(   "PathSeparator",        PathSeparator)
            . ValidateString(   "ShortNameIndicator",   ShortNameIndicator)
            . ValidateKey(      "MainKey",              MainKey,            MainKeyHook,        "Off",      "ShowMenu")
            . ValidateKey(      "RestartKey",           RestartKey,         RestartKeyHook,     "On",       "RestartApp")

    try {
        IniWrite, % Values, % INI, Global
    } catch {
        LogError(Exception("Failed to write values to the configuration"
                          , INI " write"
                          , "Create INI file with UTF-16 LE BOM encoding manually or change the INI global variable"))
    }
    Values := ""
}

;─────────────────────────────────────────────────────────────────────────────
;
ReadValues() {
;─────────────────────────────────────────────────────────────────────────────
    ; Reads values from INI
    global

    if !FileExist(INI)
        return

    try {
        IniRead, Values, % INI, Global
        for Variable, Value in Object(StrSplit(Values, ["`n", "="]))
            %Variable% := Value
    }
    Values := ""
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateKey(ByRef paramName, ByRef sequence, ByRef useHook, ByRef state := "On", ByRef funcName := "") {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Replaces chars / letters in sequence with
        standard modifiers ! ^ + #
        and SC codes, e.g. Q -> sc10

        If converted, returns the string of the form "paramName=result",
        otherwise returns empty string
    */
    global INI

    try {
        if (sequence ~= "i)sc[a-f0-9]+") {
            _key := sequence
        } else {
            ; Convert sequence to Scan Codes (if not converted)
            _key := ""
            Loop, parse, sequence
            {
                if (!(A_LoopField ~= "[\!\^\+\#<>]")
                    && _scCode := GetKeySC(A_LoopField)) {
                    ; Not a modifier, found scancode
                    _key .= Format("sc{:x}", _scCode)
                } else {
                    ; Don't change
                    _key .= A_LoopField
                }
            }
        }

        _prefix := useHook ? "" : "~"
        if funcName {
            ; Register new hotkey
            Hotkey, % _prefix . _key, % funcName, % state

            try {
                ; Remove old if exist
                IniRead, _old, % INI, Global, % paramName, % _key
                if (_old != _key) {
                    Hotkey, % "~" . _old, Off
                    Hotkey, % _old, Off
                }
            }

        } else {
            ; Set state for existing hotkey
            Hotkey, % _prefix . _key, % state
        }
        return paramName "=" _key "`n"

    } catch _error {
        LogError(_error)
    }
    return ""
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateColor(ByRef paramName, ByRef color) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Searches for a HEX number in any form, e.g. 0x, #, h

        If found, returns the string of the form "paramName=result",
        otherwise returns empty string
    */

    if !color
        return ""

    if !(_matchPos := RegExMatch(color, "i)[a-f0-9]{6}$")) {
        LogError(Exception("`'" color "`' is wrong color! Enter the HEX value", paramName))
        return ""
    }

    return paramName . "=" . SubStr(color, _matchPos) . "`n"
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateString(ByRef paramName, ByRef string) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Converts input value to string

        If not empty, returns the string of the form "paramName=result",
        otherwise returns empty string
    */

    if !string
        return ""

    return paramName . "=" . Format("{}", string) . "`n"
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateTrayIcon(ByRef paramName, ByRef icon) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        If the file exists, changes the tray icon
        and returns a string of the form "paramName=result",
        otherwise returns empty string
    */

    if !icon
        return ""

    if !FileExist(icon) {
        LogError(Exception("Icon `'" icon "`' not found", "tray icon", "Specify the full path to the file"))
        return ""
    }

    Menu, Tray, Icon, % icon
    return paramName "=" icon "`n"
}