; These parameters are not saved in the INI
FromSettings    := false
LastTabSettings := 1

; The array of available paths is filled in after receiving the DialogID in QuickSwitch.ahk
Paths := []

; set defaults without overwriting existing INI
; these values are used if the INI settings are invalid
SetDefaultValues() {
    global

    MainKeyHook := OpenMenu := ReDisplayMenu := AutoStartup := 1
    RestartKeyHook := PathNumbers := ShortPath := ShowDriveLetter := ShowFirstSeparator := ShortenEnd := 0

    GuiColor := MenuColor := ""

    ShortNameIndicator := ".."
    DirsCount      := 3
    DirNameLength  := 20
    PathSeparator  := "\"

    MainFont       := "Tahoma"
    MainKey        := "^sc10"
    RestartKey     := "^sc1F"
    RestartKeyHook := 0
    RestartWhere   := "ahk_exe notepad++.exe"
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
        IniWrite, 	%ShortenEnd%, 				%INI%, 		Menu, 		ShortenEnd
        IniWrite, 	%ShowFirstSeparator%, 		%INI%, 		Menu, 		ShowFirstSeparator
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
    IniRead, 	MainKey, 				    %INI%,		App, 		MainKey, 	                %MainKey%
    IniRead, 	MainFont, 				    %INI%,		App, 		MainFont, 	                %MainFont%
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
    IniRead, 	ShortenEnd, 				%INI%,		Menu, 		ShortenEnd, 				%ShortenEnd%
    IniRead, 	ShowFirstSeparator, 		%INI%,		Menu, 		ShowFirstSeparator, 		%ShowFirstSeparator%

    IniRead, 	DirsCount, 				    %INI%,		Menu, 		DirsCount,      	    	%DirsCount%
    IniRead, 	DirNameLength, 			    %INI%,		Menu, 		DirNameLength,      	    %DirNameLength%

    IniRead, 	PathSeparator, 				%INI%,		Menu, 		PathSeparator,      	    %PathSeparator%
    IniRead, 	ShortNameIndicator, 	 	%INI%,		Menu, 		ShortNameIndicator,      	%ShortNameIndicator%

    IniRead, 	MainIcon, 				    %INI%,		App, 		MainIcon, 	                %A_Space%
    IniRead, 	GuiColor, 					%INI%,		Colors, 	GuiColor, 				    %A_Space%
    IniRead, 	MenuColor, 					%INI%,		Colors, 	MenuColor, 				    %A_Space%
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
            }
            IniWrite, % _key, % INI, App, % paramName

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
ValidateWriteInteger(ByRef number, ByRef paramName) {
;─────────────────────────────────────────────────────────────────────────────
    global INI

    if number is Integer
        IniWrite, % number, % INI, Menu, % paramName
    else
        LogError(Exception(number " is not an integer for the " paramName " parameter", paramName))
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteColor(ByRef color, ByRef paramName) {
;─────────────────────────────────────────────────────────────────────────────
    global INI

    if !color {
        IniWrite, % A_Space, % INI, Colors, % paramName
        return
    }

    try {
        _matchPos := RegExMatch(color, "i)[a-f0-9]{6}$")
        if _matchPos {
            _result := SubStr(color, _matchPos)
            IniWrite, % _result, % INI, Colors, % paramName
        } else {
            LogError(Exception("`'" color "`' is wrong color! Enter the HEX value", paramName))
        }
    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteString(ByRef string, ByRef paramName) {
;─────────────────────────────────────────────────────────────────────────────
    global INI

    try {
        _result := Format("{}", string)
        IniWrite, % _result, % INI, Menu, % paramName
    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
ValidateWriteTrayIcon(ByRef icon, ByRef paramName) {
;─────────────────────────────────────────────────────────────────────────────
    global INI, MainIcon

    if !(icon && paramName)
        return

    if !FileExist(icon) {
        return LogError(Exception("Icon `'" icon "`' not found", "tray icon", "Specify the full path to the file"))
    }

    try {
        Menu, Tray, Icon, %MainIcon%
        IniWrite, % icon, % INI, App, % paramName
    } catch _error {
        LogError(_error)
    }
}