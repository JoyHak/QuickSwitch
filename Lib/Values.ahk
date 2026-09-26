/*
Contains all global variables necessary for the application.
Objects are intentionally not used due to their inconsistent behavior on v1.1.

Сontains functions for reading and writing to disk (to the .ini file).
"INI" param must be a path to a write-accessible file with UTF-16 LE BOM encoding:
https://www.autohotkey.com/docs/v1/lib/IniRead.htm

Contains validators that are responsible for parsing and rolling back incorrect values from settings
back to values from the INI; disabling certain options when values are empty.
Validators return a string "paramName=value", which will be written to INI.
It is not recommended to write values directly via IniWrite as they may be incorrect.
*/

; These parameters are not saved in the INI.
; You can find the meaning of each option in the Main and Lib\SettingsBackend.ahk files
LastTabSettings     :=  1
SelectPathAttempts  :=  3
DialogAction        :=  0
DialogId            :=  0
EditId              :=  0
DialogProcess       :=  "Dummy"
IsDialogClosed      :=  true
IsEnforcedUi        :=  false
FromSettings        :=  false

DeleteDialogs       :=  false
DeletePinned        :=  false
DeleteFavorites     :=  false
DeleteClipboard     :=  false
DeleteKeys          :=  false
NukeSettings        :=  false


; stores previous value of some global variables
Last := {DialogId: 0, DialogProcess: ""}  

SetDefaultValues() {
    /*
    Sets defaults without overwriting existing INI.
    These values are used if:
    - INI settings are invalid;
    - INI doesn't exist (yet);
    - the values must be reset;

    You can find the meaning of each option in Lib\SettingsFrontend.ahk
    */
    global

    DarkTheme           :=  IsDarkTheme()
    DarkColors          :=  true

    ShowManagers        :=  true
    AutoStartup         :=  true
    PathNumbers         :=  true
    DeleteDuplicates    :=  true
    ShowIcons           :=  true
    ShowNoSwitch        :=  true
    ShowAfterSettings   :=  true

    ShowAlways          :=  false
    ShowAfterSelect     :=  false
    BlackListProcess    :=  false
    SendEnter           :=  false

    ActiveListerOnly    :=  false
    ActivePaneOnly      :=  false
    ActiveTabOnly       :=  false
    ShowAllDesktops     :=  false
    ShowLockedTabs      :=  false

    ShowFavorites       :=  false
    ShowPinned          :=  false
    ShowClipboard       :=  false

    ShortPath           :=  false
    ShortenEnd          :=  false
    ShowDriveLetter     :=  false
    ShowFirstSeparator  :=  false
    IsNewUser           :=  false
    SaveUiPosition      :=  false
;@Ahk2Exe-IgnoreBegin
    ShowAfterRestart    :=  false
    ShowUiAfterRestart  :=  false
    ShowOpenDialog      :=  false
    ShowSaveAsDialog    :=  false
    SaveLastTab         :=  true
;@Ahk2Exe-IgnoreEnd

    IconsSize     := 25
    MainFontSize  := 10
    MenuFontSize  := 0
    ListerIndex   := 0

    DirsCount     := 3
    DirNameLength := 20
    PathLimit     := 9
    PathSeparator := "\"
    MainFont      := "Tahoma"
    MenuFont      := ""
    
    Last.MenuFont  := MenuFont
    Last.MenuFontSize := MenuFontSize

    ShortNameIndicator := ".."

    PinMousePlaceholder     := "Right"
    MainMousePlaceholder    := ""
    EnforceMousePlaceholder := "Ctrl+Shift+Win+0"
    RestartMousePlaceholder := ""

    AutoSwitch       := false
    AutoSwitchIndex  := 1
    AutoSwitchTarget := "ManagersPaths"

    ; Requires validation
    PinKey       := "RButton"
    MainKey      := "^sc10"  ; Ctrl+Q
    EnforceKey   := ""
    RestartKey   := ""
    IconsDir     := "Icons"
    FavoritesDir := "Favorites"
    MenuColor    := ""
    GuiColor     := ""
    SetDefaultColors()
    
    MainIcon     := IconsDir "\QuickSwitch.ico"
    if !IsFile(MainIcon)
        MainIcon := ""

;@Ahk2Exe-IgnoreBegin
    RestartKey   := "^sc1F"  ; Ctrl+S
    RestartWhere := "ahk_exe notepad++.exe"
    UiPosX := UiPosY := 0
;@Ahk2Exe-IgnoreEnd
}

;─────────────────────────────────────────────────────────────────────────────
;
WriteValues() {
;─────────────────────────────────────────────────────────────────────────────
    /*
    Calls validators and writes global variables to INI.

    The boolean (checkbox) values is writed immediately.
    The individual special values are checked before writing.
    */
    global

    local _values := "
    (LTrim
    DarkTheme="               DarkTheme               "
    DarkColors="              DarkColors              "
    ShowManagers="            ShowManagers            "
    AutoStartup="             AutoStartup             "
    PathNumbers="             PathNumbers             "
    DeleteDuplicates="        DeleteDuplicates        "
    ShowNoSwitch="            ShowNoSwitch            "
    ShowAfterSettings="       ShowAfterSettings       "
    ShowAlways="              ShowAlways              "
    ShowAfterSelect="         ShowAfterSelect         "
    AutoSwitch="              AutoSwitch              "
    AutoSwitchIndex="         AutoSwitchIndex         "
    AutoSwitchTarget="        AutoSwitchTarget        "
    BlackListProcess="        BlackListProcess        "
    SendEnter="               SendEnter               "
    ListerIndex="             ListerIndex             "
    ShowAllDesktops="         ShowAllDesktops         "
    ActivePaneOnly="          ActivePaneOnly          "
    ActiveTabOnly="           ActiveTabOnly           "
    ShowLockedTabs="          ShowLockedTabs          "
    ShowPinned="              ShowPinned              "
    ShowClipboard="           ShowClipboard           "
    ShortPath="               ShortPath               "
    ShortenEnd="              ShortenEnd              "
    ShowDriveLetter="         ShowDriveLetter         "
    ShowFirstSeparator="      ShowFirstSeparator      "
    IsNewUser="               IsNewUser               "
    IconsSize="               IconsSize               "
    MainFontSize="            MainFontSize            "
    DirsCount="               DirsCount               "
    DirNameLength="           DirNameLength           "
    PathLimit="               PathLimit               "
    PathSeparator="           PathSeparator           "
    MainFont="                MainFont                "
    ShortNameIndicator="      ShortNameIndicator      "
    PinMousePlaceholder="     PinMousePlaceholder     "
    MainMousePlaceholder="    MainMousePlaceholder    "
    EnforceMousePlaceholder=" EnforceMousePlaceholder "
    )"

    _values .= "`n"
    . ValidateKey(      "PinKey",        (PinMousePlaceholder     ? PinMousePlaceholder     : PinKey),      "",  "Off",  "Dummy")  ; Init and dont use this key
    . ValidateKey(      "MainKey",       (MainMousePlaceholder    ? MainMousePlaceholder    : MainKey),     "",  "Off",  "ShowMenu")
    . ValidateKey(      "EnforceKey",    (EnforceMousePlaceholder ? EnforceMousePlaceholder : EnforceKey),  "$", "On",   "EnforceShowMenu")
    . ValidateColor(    "GuiColor",      GuiColor)
    . ValidateColor(    "MenuColor",     MenuColor)
    . ValidateMenuFont(  MenuFont,       MenuFontSize)
    . ValidateTrayIcon( "MainIcon",      MainIcon)
    . ValidateDirectory("IconsDir",      IconsDir,      "ShowIcons",     ShowIcons)
    . ValidateDirectory("FavoritesDir",  FavoritesDir,  "ShowFavorites", ShowFavorites)


;@Ahk2Exe-IgnoreBegin
    _values .= "
    (LTrim
    RestartWhere="            RestartWhere            "
    RestartMousePlaceholder=" RestartMousePlaceholder "
    ShowAfterRestart="        ShowAfterRestart        "
    ShowUiAfterRestart="      ShowUiAfterRestart      "
    SaveLastTab="             SaveLastTab             "
    SaveUiPosition="          SaveUiPosition          "
    UiPosX="                  UiPosX                  "
    UiPosY="                  UiPosY                  "
    ShowOpenDialog="          ShowOpenDialog          "
    ShowSaveAsDialog="        ShowSaveAsDialog        "
    )"

    _values .= "`n"
    . ValidateKey(    "RestartKey",     (RestartMousePlaceholder ? RestartMousePlaceholder : RestartKey), "~", "On", "RestartApp")
    . (SaveLastTab ? ("LastTabSettings=" LastTabSettings "`n") : "")
;@Ahk2Exe-IgnoreEnd


    try {
        IniWrite, % _values, % INI, % "Global"
    } catch {
        LogError("Please create INI with UTF-16 LE BOM encoding manually: '" INI "'"
               , "config"
               , ValidateFile(INI))
    }
}

WriteValue(_paramName, _value, _section) {
    global INI
    
    try {
        if (_section = "")
            throw Exception("Section cannot be empty")    
        if (_section = "Global")
            throw Exception("The value will be overwritten in WriteValues()")
            
        IniWrite, % _value, % INI, % _section, % _paramName
    } catch _ex {
        _ex.what  .= " " _paramName
        _ex.extra .= " " ValidateFile(INI)
        _ex.message := "Unable to write """ _paramName """ to [" _section "]. " . _ex.message
        
        throw _ex    
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ReadValues() {
;─────────────────────────────────────────────────────────────────────────────
    ; Reads values from INI and updates global variables
    global

    local _values, _array, _variable, _value
    IniRead, _values, % INI, % "Global"

    Loop, Parse, _values, `n
    {
        _array      := StrSplit(A_LoopField, "=")
        _variable   := _array[1]
        _value      := _array[2]
        %_variable% := _value
    }
    
    Last.SendEnter := SendEnter
}

ReadValue(_paramName, _section := "Global", _default := "") {
    global INI
    IniRead, _value, % INI, % _section, % _paramName, % _default
    
    if (_value = "ERROR") {
        throw Exception("Parameter """ _paramName """ not found in [" _section "]"
                      , _paramName " read"
                      , ValidateFile(INI))
    }
    
    return _value
}

IsFile(_path) {
    ; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathfileexistsw
    static shlwapi := DllCall("GetModuleHandle", "str", "Shlwapi", "ptr")
    static IsFile  := DllCall("GetProcAddress", "ptr", shlwapi, "astr", "PathFileExistsW", "ptr")

    return DllCall(IsFile, "str", _path)
}

ExpandVariables(_path) {
    ; Performs a dereference of all built-in, declared and env. variables
    ; Returns the number of expanded variables.
    _pos := 0
    while (_pos := RegExMatch(_path, "%(\w+)%", _var, ++_pos)) {
        if IsSet(%_var1%) {
            _path := StrReplace(_path, "%" _var1 "%", %_var1%)
        } else {
            EnvGet, _env, % _var1
            _path := StrReplace(_path, "%" _var1 "%", _env)
        }
    }
    return _path
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateDirectory(_paramName, ByRef path, _associatedParamName := "", ByRef associatedParam := false) {
;─────────────────────────────────────────────────────────────────────────────
    /*
    Resolves variables in path, filters it, checks if its exists.
    If not, sets `associatedParam` value to 0.
    Returns 2-line string which depends on path existence:
   "paramName=path or config value
    associatedParamName=it's value"

    Returns an empty string if `paramName` is empty and path doesn't exist.
    */

    ; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathisdirectoryw
    static shlwapi := DllCall("GetModuleHandle", "str", "Shlwapi", "ptr")
    static IsPath  := DllCall("GetProcAddress", "Ptr", shlwapi, "astr", "PathIsDirectoryW", "ptr")

    ; Filter the path
    path := Trim(path, " `t'""")
    path := RTrim(path, "\/.")
    path := StrReplace(path, "/" , "\")
    path := ExpandVariables(path)
    _path := path

    loop, 2 {
        ; Сheck the existence
        if DllCall(IsPath, "str", path) {
            if _associatedParamName
               _associatedParamName .= "=" associatedParam "`n"

            return _paramName "=" path "`n" _associatedParamName
        }

        ; If this is a file or an incorrect directory, slice the path
        if !(_len := InStr(path, "\",, -1))
            break

        path := SubStr(path, 1, _len - 1)
    }

    if !_paramName
        return ""

    ; If path is empty, assume it's intentional and skip this block
    _default := ""
    if (path) {
        try {
            _default := ReadValue(_paramName)
            if (associatedParam) {
                LogError("Directory not found: '" _path "'", _paramName, "Specify the full path to the directory")
            }
        }
    }

    if DllCall(IsPath, "str", _default)
        path := _default
    else
        associatedParam := false

    if _associatedParamName
       _associatedParamName .= "=" associatedParam "`n"

    return _paramName "=" path "`n" _associatedParamName
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateColor(_paramName, ByRef color) {
;─────────────────────────────────────────────────────────────────────────────
    /*
    Searches for a HEX number in any form: 0x, #, h, ...

    If found, returns "paramName=color".
    If color is incorrect, reads it from INI
    */

    if color {
        if (RegExMatch(color, "i)[a-f0-9]{6}$", _color))
            return _paramName "=" _color "`n"

        if !_paramName
            return ""

        LogError("Wrong color: '" color "'. Enter the HEX value", _paramName)
        _default := ReadValue(_paramName, , A_Space)
        color := _default
        return _paramName "=" _default "`n"
    }

    return _paramName "=`n"
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateKey(_paramName, _sequence, _prefix := "", _state := "On", _function := "") {
;─────────────────────────────────────────────────────────────────────────────
    /*
    Converts `sequence` to scancodes or internal mouse buttons.
    Replaces modifier names to standard modifiers symbols:  ! ^ + #

    If converted, returns "paramName=key", creates a new key in `hotkeys`.
    Disables old key bound to `function` (if any) and removes it from `hotkeys`.
    If key is incorrect, reads it from INI
    */
    static hotkeys := {}

    try {
        if !_sequence {
            if hotkeys.HasKey(_paramName) {
                ; Unregister hotkey
                Hotkey, % hotkeys[_paramName], % "Off"
                hotkeys.Delete(_paramName)
            }
            return _paramName "=`n"
        }

        ; Early return: set state for existing hotkey
        if (!_function && hotkeys.HasKey(_paramName)) {
            Hotkey, % hotkeys[_paramName], % _state
            return ""
        }

        if (_sequence ~= "i)sc[a-f0-9]+") {
            ; Already converted to Scan Code
            _key := _sequence
        } else if (GetMouseList("isMouse", _sequence)) {
            ; Convert mouse button from friendly to internal name
            _key := GetMouseList("convertMouse", _sequence)
        } else if (GetMouseList("isSpecial", _sequence)) {
            ; Don't convert, use hook
            _key    := _sequence
            _prefix := "$"
        } else {
            ; Convert sequence to Scan Code
            _key := ""
            Loop, parse, _sequence
            {
                if (!(A_LoopField ~= "[\!\^\+\#<>]")
                  && _code := GetKeySC(A_LoopField)) {
                    ; Not a modifier, found scancode
                    _key .= Format("sc{:x}", _code)
                } else {
                    ; Don't convert
                    _key .= A_LoopField
                }
            }
        }
        
        ; Remove previous hotkey if it exists
        if hotkeys.HasKey(_paramName) {
            Hotkey, % hotkeys[_paramName], % "Off"
        }
        ; Register new hotkey
        Hotkey, % _prefix . _key, % _function, % _state
        hotkeys[_paramName] := _prefix . _key

        if !_paramName {
            return ""
        }
        return _paramName "=" _key "`n"

    } catch _ex {
        if !_paramName {
            return ""
        }
        
        _ex.what    .= " " _paramName
        _ex.message := "Unable to register hotkey """ . _prefix . _sequence . """. " . _ex.message
        _ex.extra   .= " `nBound to " _function "(), state = " _state
        LogException(_ex)

        ; Return value from config
        _default := ReadValue(_paramName, , A_Space)
        return _paramName "=" _default "`n"
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateFile(_filePath) {
;─────────────────────────────────────────────────────────────────────────────
    ; Collects debugging information about the file and attempts to read it.
    _extra := "Cant write data to the file"

    if !_filePath {
        _extra := "File path is empty"
    } else if !IsFile(_filePath) {
        _extra := "Unable to create file"
    } else {
        _file := FileOpen(_filePath, "r")

        if !IsObject(_file) {
            FileGetAttrib, _attr, % _filePath
            _extra := "Unable to get access to the file"
        } else {
            _extra     := "`nReading existing file`n"

            _firstLine := RTrim(_file.readLine(), " `r`n")
            _extra     .= Format("Encoding: {} First line: {}, Size in bytes: {} HWND: {}`n"
                                 , _file.encoding, _firstLine, _file.length, _file.handle)
        }
        _file.Close()

        try {
            FileGetAttrib, _attr, % _filePath
            _extra .= "File attributes: " _attr
        }
    }

    return "'" _filePath "' - " _extra "`n"
}

OnExitCleanup() {
    global
    
    WritePinnedPaths(PinnedPaths)
    WriteDialogs()
}