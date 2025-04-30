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

    MainFont       := "Tahoma"
    MainKey        := "^sc10"
    RestartKey     := "^sc1F"
    RestartWhere   := "ahk_exe notepad++.exe"
}

;─────────────────────────────────────────────────────────────────────────────
;
WriteValues() {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Calls validators and writes values to INI.

        The boolean (checkbox) values is writed immediately.
        The individual special values are checked before writing.

        Global var and its value must be identical to ReadValues()
    */
    global

    try {
        IniWrite,
        (LTrim
            AutoStartup         =  %AutoStartup%
            AutoSwitch          =  %AutoSwitch%
            ShowAlways          =  %ShowAlways%
            ShowNoSwitch        =  %ShowNoSwitch%
            ShowAfterSelect     =  %ShowAfterSelect%
            ShowAfterSettings   =  %ShowAfterSettings%
            CloseDialog         =  %CloseDialog%
            PathNumbers         =  %PathNumbers%
            ShortPath           =  %ShortPath%
            ShortenEnd          =  %ShortenEnd%
            ShowDriveLetter     =  %ShowDriveLetter%
            ShowFirstSeparator  =  %ShowFirstSeparator%
            DirsCount           =  %DirsCount%
            DirNameLength       =  %DirNameLength%
            MainFont            =  %MainFont%
            RestartWhere        =  %RestartWhere%
            MainKeyHook         =  %MainKeyHook%
            RestartKeyHook      =  %RestartKeyHook%
        ), % INI, Global

    } catch {
        LogError(Exception("Failed to write values to the configuration"
                            , INI . " write"
                            , "Create INI file manually or change the INI global variable"))
    }

    ValidateWriteColor(GuiColor,    "GuiColor")
    ValidateWriteColor(MenuColor,   "MenuColor")
    ValidateWriteTrayIcon(MainIcon, "MainIcon")

    ValidateWriteString(PathSeparator,      "PathSeparator")
    ValidateWriteString(ShortNameIndicator, "ShortNameIndicator")

    ValidateWriteKey(MainKey,    "MainKey",    "ShowMenu",   "Off",  MainKeyHook)
    ValidateWriteKey(RestartKey, "RestartKey", "RestartApp", "On",   RestartKeyHook)


}

;─────────────────────────────────────────────────────────────────────────────
;
ReadValues() {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Reads values from INI.

        All global variables are updated if:
        - the configuration exists
        - values exist in the configuration
        - variables have been declared

        File, section, param name, global var and its value reference
        must be identical to WriteValues()
    */
    global

    if !FileExist(INI)
        return LogError(Exception("Failed to read values to the configuration"
                                  , INI . " read"
                                  , "Create INI file manually or change the INI global variable"))

    IniRead, Values, % INI, Global
    Loop, Parse, % Values, `n
    {
        Data     := StrSplit(A_LoopField, "=")
        Variable := Data[1]
        Value    := Data[2]

        if (Variable && Value)
            %Variable% := Value
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteKey(ByRef sequence, ByRef paramName, ByRef funcName := "", ByRef state := "On", ByRef useHook := false) {
;─────────────────────────────────────────────────────────────────────────────
    global INI

    try {
        ; Convert sequence to Scan Codes (if not converted)
        if !(sequence ~= "i)sc[a-f0-9]+") {
            _key := ""
            Loop, parse, sequence
            {
                if (!(A_LoopField ~= "[\!\^\+\#<>]")
                    && _scCode := GetKeySC(A_LoopField)) {
                    _key .= Format("sc{:x}", _scCode)
                } else {
                    _key .= A_LoopField
                }
            }
        } else {
            _key := sequence
        }

        _prefix := useHook ? "" : "~"
        if funcName {
            ; Create new hotkey
            Hotkey, % _prefix . _key, % funcName, % state

            try {
                ; Remove old if exist
                IniRead, _old, % INI, App, % paramName, % _key
                if (_old != _key) {
                    Hotkey, % "~" . _old, Off
                    Hotkey, % _old, Off
                }
                IniWrite, % _key, % INI, App, % paramName
            }

        } else {
            ; Set state for existing hotkey
            Hotkey, % _prefix . _key, % state
        }

    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteColor(ByRef color, ByRef paramName) {
;─────────────────────────────────────────────────────────────────────────────
    global INI

    if !color {
        try IniWrite, % A_Space, % INI, Colors, % paramName
        return
    }

    if !(_matchPos := RegExMatch(color, "i)[a-f0-9]{6}$"))
        return LogError(Exception("`'" color "`' is wrong color! Enter the HEX value", paramName))

    _result := SubStr(color, _matchPos)
    try IniWrite, % _result, % INI, Colors, % paramName
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteString(ByRef string, ByRef paramName) {
;─────────────────────────────────────────────────────────────────────────────
    global INI

    _result := Format("{}", string)
    try IniWrite, % _result, % INI, Menu, % paramName
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteTrayIcon(ByRef icon, ByRef paramName) {
;─────────────────────────────────────────────────────────────────────────────
    global INI, MainIcon

    if !icon {
        try IniWrite, % A_Space, % INI, App, % paramName
        return
    }

    if !FileExist(icon)
        return LogError(Exception("Icon `'" icon "`' not found", "tray icon", "Specify the full path to the file"))

    Menu, Tray, Icon, %MainIcon%
    try IniWrite, % icon, % INI, App, % paramName
}