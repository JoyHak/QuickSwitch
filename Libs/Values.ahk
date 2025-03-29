; These parameters are not saved in the INI
FromSettings  := false
LastMenuItem  := ""

; These parameters must not be reset
LastTabSettings  := AutoStartup := MainKeyHook := 1
MainFont         := "Tahoma"
, MainKey        := "^q"
, RestartKey     := "^s"
, RestartKeyHook := 0
, RestartWhere   := "ahk_exe notepad++.exe"

; The array of available paths is filled in after receiving the DialogID in QuickSwitch.ahk
paths := []

; set defaults without overwriting existing INI
; these values are used if the INI settings are invalid
SetDefaultValues() {
    global 
    
    OpenMenu := ReDisplayMenu := CutFromEnd := 1
    PathNumbers := ShortPath := ShowDriveLetter := 0
    
    DirsCount            := 3
    , DirNameLength      := 20
    , PathSeparator      := "/"
    , ShortNameIndicator := ".."
    , GuiColor           := ""
    , MenuColor          := ""

    Return
}

;─────────────────────────────────────────────────────────────────────────────
;
WriteValues() {
;─────────────────────────────────────────────────────────────────────────────
    /*
        The status of the checkboxes from the settings menu is writed immediately
        Strings and colors from fields are checked before writing.
        file, section, param name, global var and its value reference
        are identical to those in ReadValues()
    */
    global

    try {
        ; 			value						INI name	section		param name
        IniWrite, 	%AutoStartup%, 				%INI%, 		App, 		AutoStartup
        IniWrite, 	%MainFont%, 			    %INI%, 		App, 	    MainFont
        IniWrite, 	%RestartWhere%, 			%INI%, 		App, 	    RestartWhere
        IniWrite, 	%MainKeyHook%, 			    %INI%, 		App, 	    MainKeyHook
        IniWrite, 	%RestartKeyHook%, 			%INI%, 		App, 	    RestartKeyHook
        IniWrite, 	%LastTabSettings%, 			%INI%, 		App, 	    LastTabSettings
        IniWrite, 	%OpenMenu%, 				%INI%, 		Menu, 		OpenMenu
        IniWrite, 	%ShortPath%, 				%INI%, 		Menu, 		ShortPath
        IniWrite, 	%ReDisplayMenu%, 			%INI%, 		Menu, 		ReDisplayMenu
        IniWrite, 	%PathNumbers%, 				%INI%, 		Menu, 		PathNumbers
        IniWrite, 	%ShowDriveLetter%, 			%INI%, 		Menu, 		ShowDriveLetter
        IniWrite, 	%CutFromEnd%, 				%INI%, 		Menu, 		CutFromEnd
    } catch {
        LogError(Exception("Failed to write values to the configuration", INI . " write", "Create INI file manually or change the INI global variable"))
    }

    ValidateWriteInteger(DirsCount, 		"DirsCount")
    ValidateWriteInteger(DirNameLength, 	"DirNameLength")

    ValidateWriteString(PathSeparator, 		"PathSeparator")
    ValidateWriteString(ShortNameIndicator, "ShortNameIndicator")

    ValidateWriteKey(MainKey, 		"MainKey",      "ShowPathsMenu",    "Off",      MainKeyHook)
    ValidateWriteKey(RestartKey, 	"RestartKey",   "RestartApp",       "On",       RestartKeyHook)

    ValidateWriteColor(GuiColor, 	"GuiColor")
    ValidateWriteColor(MenuColor, 	"MenuColor")
    ValidateWriteTrayIcon(MainIcon, "MainIcon")

    Return
}

;─────────────────────────────────────────────────────────────────────────────
;
ReadValues() {
;─────────────────────────────────────────────────────────────────────────────
    /*
        read values from INI
        the current value of global variables is set at the top of the script
        so it is passed to IniRead as "default value".
        file, section, param name, global var and its value reference are identical
        to those in WriteValues()
    */
    global

    ;			global						INI name	section		param name					default value
    IniRead, 	AutoStartup, 				%INI%,		App, 		AutoStartup, 	            %AutoStartup%
    IniRead, 	MainIcon, 				    %INI%,		App, 		MainIcon, 	                %MainIcon%
    IniRead, 	MainFont, 				    %INI%,		App, 		MainFont, 	                %MainFont%
    IniRead, 	MainKey, 				    %INI%,		App, 		MainKey, 	                %MainKey%
    IniRead, 	RestartKey, 				%INI%,		App, 		RestartKey, 	            %RestartKey%

    IniRead, 	MainKeyHook, 				%INI%,		App, 		MainKeyHook, 	            %MainKeyHook%
    IniRead, 	RestartKeyHook, 			%INI%,		App, 		RestartKeyHook, 	        %RestartKeyHook%
    IniRead, 	RestartWhere, 				%INI%,		App, 		RestartWhere, 	            %RestartWhere%
    IniRead, 	LastTabSettings, 			%INI%,		App, 		LastTabSettings, 	        %LastTabSettings%

    IniRead, 	OpenMenu, 					%INI%,		Menu, 		OpenMenu, 	                %OpenMenu%
    IniRead, 	ShortPath, 					%INI%,		Menu, 		ShortPath,      	        %ShortPath%
    IniRead, 	ReDisplayMenu, 				%INI%,		Menu, 		ReDisplayMenu,  	        %ReDisplayMenu%
    IniRead, 	PathNumbers, 				%INI%,		Menu, 		PathNumbers, 			    %PathNumbers%
    IniRead, 	ShowDriveLetter, 			%INI%,		Menu, 		ShowDriveLetter, 			%ShowDriveLetter%
    IniRead, 	CutFromEnd, 				%INI%,		Menu, 		CutFromEnd, 				%CutFromEnd%

    IniRead, 	DirsCount, 				    %INI%,		Menu, 		DirsCount,      	    	%DirsCount%
    IniRead, 	DirNameLength, 			    %INI%,		Menu, 		DirNameLength,      	    %DirNameLength%

    IniRead, 	PathSeparator, 				%INI%,		Menu, 		PathSeparator,      	    %PathSeparator%
    IniRead, 	ShortNameIndicator, 	 	%INI%,		Menu, 		ShortNameIndicator,      	%ShortNameIndicator%

    IniRead, 	GuiColor, 					%INI%,		Colors, 	GuiColor, 				    %A_Space%
    IniRead, 	MenuColor, 					%INI%,		Colors, 	MenuColor, 				    %A_Space%

    Return
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteKey(_new, _paramName, _funcObj, _state := "On", _useHook := false) {       ; bind key
;─────────────────────────────────────────────────────────────────────────────
    global INI
    _prefix := _useHook ? "" : "~"

    try {
        Hotkey, % _prefix . _new, % _funcObj, % _state       ; create hotkey
        IniWrite, % _new, % INI, App, % _paramName           ; save
    } catch _error {
        LogError(_error)
        Return
    }
    IniRead, _old, % INI, App, % _paramName, % _new          ; remove old if exist
    if (_old != _new) {
        Hotkey, % _old, Off
        Hotkey, % "~" . _old, Off
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteInteger(_new, _paramName) {    ; integer only
;─────────────────────────────────────────────────────────────────────────────
    global INI

    if _new is Integer
        IniWrite, % _new, % INI, Menu, % _paramName
    else
        throw Exception(_new " is not an integer for the " _paramName " parameter", _paramName)
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteColor(_color, _paramName) {    ; valid HEX / empty value only
;─────────────────────────────────────────────────────────────────────────────
    global INI

    _matchPos := RegExMatch(_color, "i)[a-f0-9]{6}$")
    if (_color == "" or _matchPos > 0) {
        _result := SubStr(_color, _matchPos)
        IniWrite, % _result, % INI, Colors, % _paramName
    } else {
        throw Exception("`'" _color "`' is wrong color! Enter the HEX value", _paramName)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteString(_new, _paramName) {     ; format to string
;─────────────────────────────────────────────────────────────────────────────
    global INI

    _result := Format("{}", _new)
    IniWrite, % _result, % INI, Menu, % _paramName
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteTrayIcon(_new, _paramName) {
;─────────────────────────────────────────────────────────────────────────────
    global INI, MainIcon

    if !(_new && _paramName)
        Return

    if !FileExist(_new) {
        LogError(Exception("Icon `'" _new "`' not found", "Tray icon", "Specify the full path to the file"))
        Return
    }

    try {
        Menu, Tray, Icon, %MainIcon%
        IniWrite, % _new, % INI, App, % _paramName
    } catch _error {
        LogError(_error)
    }
}