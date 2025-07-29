/*
    Contains all global variables necessary for the application,
    functions that read/write INI configuration,
    functions that check (validate) values for compliance
    with the requirements of different libraries.

    "INI" param must be a path to a write-accessible file (with any extension)
 */

; These parameters are not saved in the INI
; You can find the meaning of each option in the Main and Lib\SettingsBackend files
LastTabSettings     :=  1
SelectPathAttempts  :=  3
DialogId            :=  0
EditId              :=  0
LastDialogProcess   :=  ""

WriteDialogAction   :=  false
WritePinnedPaths    :=  false
FromSettings        :=  false
    
DeleteDialogs       :=  false
DeletePinned        :=  false
DeleteFavorites     :=  false
DeleteClipboard     :=  false
DeleteKeys          :=  false
NukeSettings        :=  false

RegisteredSpecialKeys := {}

SetDefaultValues() {
    /*
        Sets defaults without overwriting existing INI.

        These values are used if:
        - INI settings are invalid
        - INI doesn't exist (yet)
        - the values must be reset
        
        You can find the meaning of each option in Lib\SettingsFrontend
    */
    global
    
    DarkTheme           :=  IsDarkTheme()
    DarkColors          :=  true  
    
    ShowManagers        :=  true
    AutoStartup         :=  false
    PathNumbers         :=  true
    DeleteDuplicates    :=  true
    ShowIcons           :=  true
    ShowNoSwitch        :=  true
    ShowAfterSettings   :=  true

    ShowAlways          :=  false
    ShowAfterSelect     :=  false
    SendEnter           :=  false
    
    AutoSwitch          :=  false
    BlackListProcess    :=  false
    
    ActiveTabOnly       :=  false
    ShowLockedTabs      :=  false
    ShowFavorites       :=  false
    ShowPinned          :=  false
    ShowClipboard       :=  false
    
    ShortPath           :=  false
    ShortenEnd          :=  false
    ShowDriveLetter     :=  false
    ShowFirstSeparator  :=  false

    IconsSize      := 25
    DirsCount      := 3
    DirNameLength  := 20
    PathLimit      := 9
    PathSeparator  := "\"
    RestartWhere   := "ahk_exe notepad++.exe"
    MainFont       := "Tahoma"
    ShortNameIndicator := ".."
    
    PinMousePlaceholder     := "Right"
    MainMousePlaceholder    := ""
    RestartMousePlaceholder := ""
    
    ; Requires validation
    PinKey         := "RButton"
    MainKey        := "^sc10"
    RestartKey     := "^sc1F"
    IconsDir       := "Icons"
    FavoritesDir   := "Favorites"
    MainIcon       := ""
    MenuColor      := ""
    GuiColor       := ""
    SetDefaultColors()

    ;@Ahk2Exe-IgnoreBegin
    MainIcon := IconsDir "\QuickSwitch.ico"
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
    DarkTheme="               DarkTheme               "
    DarkColors="              DarkColors              "
    ShowManagers="            ShowManagers            "
    AutoStartup="             AutoStartup             "
    PathNumbers="             PathNumbers             "
    DeleteDuplicates="        DeleteDuplicates        "
    ShowIcons="               ShowIcons               "
    ShowNoSwitch="            ShowNoSwitch            "
    ShowAfterSettings="       ShowAfterSettings       "
    ShowAlways="              ShowAlways              "
    ShowAfterSelect="         ShowAfterSelect         "
    SendEnter="               SendEnter               "
    AutoSwitch="              AutoSwitch              "
    BlackListProcess="        BlackListProcess        "
    ActiveTabOnly="           ActiveTabOnly           "
    ShowLockedTabs="          ShowLockedTabs          "
    ShowFavorites="           ShowFavorites           "
    ShowPinned="              ShowPinned              "
    ShowClipboard="           ShowClipboard           "
    ShortPath="               ShortPath               "
    ShortenEnd="              ShortenEnd              "
    ShowDriveLetter="         ShowDriveLetter         "
    ShowFirstSeparator="      ShowFirstSeparator      "
    IconsSize="               IconsSize               "
    DirsCount="               DirsCount               "
    DirNameLength="           DirNameLength           "
    PathLimit="               PathLimit               "
    PathSeparator="           PathSeparator           "
    RestartWhere="            RestartWhere            "
    MainFont="                MainFont                "
    ShortNameIndicator="      ShortNameIndicator      "
    PinMousePlaceholder="     PinMousePlaceholder     "
    MainMousePlaceholder="    MainMousePlaceholder    "
    RestartMousePlaceholder=" RestartMousePlaceholder "
    )"

    _values .= "`n"
    . ValidateKey(      "PinKey",        (PinMousePlaceholder     ? PinMousePlaceholder     : PinKey),     "",   "Off", "Dummy") ; Init and dont use this key
    . ValidateKey(      "MainKey",       (MainMousePlaceholder    ? MainMousePlaceholder    : MainKey),    "",   "Off", "^#+0")
    . ValidateKey(      "RestartKey",    (RestartMousePlaceholder ? RestartMousePlaceholder : RestartKey), "~",  "On",  "RestartApp")
    . ValidateColor(    "GuiColor",      GuiColor)
    . ValidateColor(    "MenuColor",     MenuColor)
    . ValidateTrayIcon( "MainIcon",      MainIcon)
    . ValidateDirectory("IconsDir",      IconsDir)
    . ValidateDirectory("FavoritesDir",  FavoritesDir)

    try {
        IniWrite, % _values, % INI, % "Global"
    } catch {
        LogError("Please create INI with UTF-16 LE BOM encoding manually: `'" INI "`'"
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

    local _values, _array, _variable, _value
    IniRead, _values, % INI, % "Global"

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
IsFile(ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    ; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathfileexistsw
    static shlwapi := DllCall("GetModuleHandle", "str", "Shlwapi", "ptr")
    static IsFile  := DllCall("GetProcAddress", "ptr", shlwapi, "astr", "PathFileExistsW", "ptr")
    
    return DllCall(IsFile, "ptr", &path)
}

;─────────────────────────────────────────────────────────────────────────────
;
ExpandVariables(ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    ; Performs a dereference of all built-in, declared and env. variables
    ; Returns the number of expanded variables.
    _pos := _count := 0
    while (_pos := RegExMatch(path, "%(\w+)%", _var, ++_pos)) {
        if IsSet(%_var1%) {
            path := StrReplace(path, "%" _var1 "%", %_var1%)
            ++_count
        } else {
            EnvGet, _env, % _var1
            path := StrReplace(path, "%" _var1 "%", _env)
            ++_count
        }
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateDirectory(_paramName, ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    ; If the dir exists, returns a string of the form "paramName=result",
    ; otherwise returns value from config
    ; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathisdirectoryw
    global INI
    
    static shlwapi := DllCall("GetModuleHandle", "str", "Shlwapi", "ptr")
    static IsPath  := DllCall("GetProcAddress", "Ptr", shlwapi, "astr", "PathIsDirectoryW", "ptr")
    
    ; Filter the path
    path := Trim(path, " `t\/.")
    path := StrReplace(path, "/" , "\")
    ExpandVariables(path)

    loop, 2 {
        ; Сheck the correctness of the directory
        if (DllCall(IsPath, "str", path))
            return _paramName "=" path "`n"
        
        ; If this is a file or an incorrect directory, get the parent
        path := SubStr(path, 1, InStr(path, "\",, -1))
    }
    
    if !_paramName
        return ""
    
    LogError("Directory not found: `'" path "`'", _paramName, "Specify the full path to the directory")
    
    ; Return value from config        
    IniRead, _default, % INI, % "Global", % _paramName, % A_Space
    return _paramName "=" _default "`n"
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateTrayIcon(_paramName, ByRef icon) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        If the file exists, changes the tray icon
        and returns a string of the form "paramName=result",
        otherwise returns value from config
    */
    global INI
    
    if !icon {
        Menu, % "Tray", % "Icon", *
        return _paramName "=`n"
    }

    try {
        ExpandVariables(icon)        
        Menu, % "Tray", % "Icon", % icon
        return _paramName "=" icon "`n"
    }
    
    if !_paramName
        return ""
        
    LogError("Icon `'" icon "`' not found", "tray icon", "Specify the full path to the file")
    
    IniRead, _default, % INI, % "Global", % _paramName, % A_Space
    return _paramName "=" _default "`n"
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateColor(_paramName, ByRef color) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Searches for a HEX number in any form, e.g. 0x, #, h

        If found, returns the string of the form "paramName=result",
        otherwise returns empty color
    */
    global INI
    
    if color {
        if (RegExMatch(color, "i)[a-f0-9]{6}$", _color))
            return _paramName "=" _color "`n"
        
        if !_paramName
            return ""
        
        LogError("Wrong color: `'" color "`'. Enter the HEX value", _paramName)
        
        IniRead, _default, % INI, % "Global", % _paramName, % A_Space
        return _paramName "=" _default "`n"
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
        otherwise returns value from config
    */
    global INI, RegisteredSpecialKeys

    try {
        if !_sequence
            return _paramName "=`n"            
        
        _isSpecial := false
        if (_sequence ~= "i)sc[a-f0-9]+") {
            ; Already converted
            _key := _sequence
        } else if (GetMouseList("isMouse", _sequence)) {
            ; Convert to mouse buttons
            _key := GetMouseList("convertMouse", _sequence)
        
        } else if (GetMouseList("isSpecial", _sequence)) {
            ; Don't change, use hook
            _key       :=  _sequence
            _prefix    :=  "$"
            _isSpecial :=  true
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
            if _isSpecial
                RegisteredSpecialKeys[_key] := true
            
            if !_paramName
                return ""
            
            try {
                ; Remove old if exist
                IniRead, _old, % INI, % "Global", % _paramName, % A_Space
                if (_old && (_old != _key)) {
                    Hotkey, % _prefix . _old, % "Off"
                    Hotkey, % _old, % "Off"
                    
                    if _isSpecial
                        RegisteredSpecialKeys[_old] := false
                }
            }

        } else {
            ; Set state for existing hotkey
            Hotkey, % _prefix . _key, % _state
        }
            
        return _paramName "=" _key "`n"

    } catch _ex {        
        if !_paramName
            return ""
            
        LogException(_ex)
        
        ; Return value from config
        IniRead, _default, % INI, % "Global", % _paramName, % A_Space
        return _paramName "=" _default "`n"
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateFile(ByRef filePath) {
;─────────────────────────────────────────────────────────────────────────────
    _extra := "Cant write data to the file"

    if !filePath {
        _extra := "File path is empty"
    } else if !IsFile(filePath) {
        _extra := "Unable to create file"
    } else {
        _file := FileOpen(filePath, "r")

        if !IsObject(_file) {
            FileGetAttrib, _attr, % filePath
            _extra := "Unable to get access to the file"
        } else {
            _extra     := "`nReading existing file`n"

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

    return "`'" filePath "`' - " _extra "`n"
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidatePinnedPaths(_paramName, ByRef paths, _state := false) {
;─────────────────────────────────────────────────────────────────────────────
    ; Restores or saves the "paths" array depending on the flags.
    ; Returns the number of paths in the array after processing.
    global INI, WritePinnedPaths
    
    if (_state && !paths.length()) {
        IniRead, _paths, % INI, % "App", % _paramName, % A_Space
        if _paths {
            loop, parse, _paths, `|
            {
                paths.push([A_LoopField, "Pin.ico", 1, ""])
            }
        }            
        return paths.length()
    }
    
    if ((!_state || WritePinnedPaths) && paths.length()) {
        WritePinnedPaths := false   
        _paths := ""
        for _, _arr in GetUniqPaths(paths)
            _paths .= "|" . _arr[1]
            
        try IniWrite, % LTrim(_paths, "|"), % INI, % "App", % _paramName
    }    
    
    if !_state
        paths := []
    
    return paths.length()
}