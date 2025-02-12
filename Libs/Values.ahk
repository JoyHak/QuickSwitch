; INI file
global ScriptName := "QuickSwitch"
;SplitPath, A_ScriptFullPath,,,, ScriptName
global INI := ScriptName . ".ini"

; set defaults without overwriting existing INI
; these values are used if the INI settings are invalid
SetDefaultValues() {
    global AutoStartup               := 1
    global OpenMenu                  := 0
    global ReDisplayMenu             := 1
    global FolderNum                 := 1
    
    global ShortPath                 := 0
    global VirtualPath 		         := 0  
    global ShowDriveLetter 	         := 0 
    global CutFromEnd 		         := 1  
    global FoldersCount              := 3    
    global FolderNameLength          := 20  
                                     
    global PathSeparator             := "/"
    global ShortNameIndicator        := ".."
                                     
    global GuiColor                  := "202020"
    global MenuColor                 := "202020"
    
    Return    
}
SetDefaultValues()

; These parameters are not saved in the INI
global LastMenuItem  := ""
global FromSettings  := false
global NrOfEntries 	 := 0

; The array of available paths is filled in after receiving the DialogID in QuickSwitch.ahk
paths    := []
; Virtual paths are used only in the PathsMenu
virtuals := []


;_____________________________________________________________________________
;
ValidateWriteString(_new, _iniParamName) {     ; format to string
;_____________________________________________________________________________     
    global INI
    
    _result := Format("{}", _new)    
    IniWrite, %_result%, %INI%, Menu, %_iniParamName%
}

;_____________________________________________________________________________
;
ValidateWriteInteger(_new, _iniParamName) {    ; write if integer
;_____________________________________________________________________________     
    global INI

    if _new is Integer
        IniWrite, %_new%, %INI%, Menu, %_iniParamName%
    else
        TrayTip, %ScriptName% error, You did not enter an integer for the %_iniParamName% parameter,, 0x2 
}

;_____________________________________________________________________________
;
ValidateWriteColor(_color, _iniParamName) {    ; valid only
;_____________________________________________________________________________ 
    global INI
    
    _matchPos := RegExMatch(_color, "i)[a-f0-9]{6}$")
    if (_matchPos > 0) {
        _result := SubStr(_color, _matchPos)
        IniWrite, %_result%, %INI%, Colors, %_iniParamName%
    } else {
        TrayTip, %ScriptName% error, You have chosen the wrong color for %_iniParamName%! Enter the HEX value,, 0x2 
    }
}

;_____________________________________________________________________________
;
WriteValues() { 
;_____________________________________________________________________________     
    /*     
        The status of the checkboxes from the settings menu is writed immediately
        Strings and colors from fields are checked before writing.
        file, section, param name, global var and its value reference 
        are identical to those in ReadValues() 
    */
    global
    FolderNum--
    
    ; 			value						INI name	section		param name
    IniWrite, 	%OpenMenu%, 				%INI%, 		Menu, 		AlwaysOpenMenu
    IniWrite, 	%ShortPath%, 				%INI%, 		Menu, 		ShortPath
    IniWrite, 	%ReDisplayMenu%, 			%INI%, 		Menu, 		ReDisplayMenu
    IniWrite, 	%FolderNum%, 				%INI%, 		Menu, 		ShowFolderNumbers
    IniWrite, 	%VirtualPath%, 				%INI%, 		Menu, 		VirtualPath
    IniWrite, 	%ShowDriveLetter%, 			%INI%, 		Menu, 		ShowDriveLetter
    IniWrite, 	%CutFromEnd%, 				%INI%, 		Menu, 		CutFromEnd
    
    ValidateWriteInteger(FoldersCount, 		"FoldersCount")
    ValidateWriteInteger(FolderNameLength, 	"FolderNameLength")
    
    ValidateWriteString(PathSeparator, 		"PathSeparator")
    ValidateWriteString(ShortNameIndicator, "ShortNameIndicator")
    
    ValidateWriteColor(GuiColor, 	"GuiBGColor")
    ValidateWriteColor(MenuColor, 	"MenuBGColor")

    Return
}

;_____________________________________________________________________________
;
ReadValues() {
;_____________________________________________________________________________ 
    /*     
        read values from INI
        the current value of global variables is set at the top of the script
        so it is passed to IniRead as "default value".
        file, section, param name, global var and its value reference are identical 
        to those in WriteValues() 
    */
    global
    
    ;			global						INI name	section		param name					default value
    IniRead, 	OpenMenu, 					%INI%,		Menu, 		AlwaysOpenMenu, 	        %OpenMenu%
    IniRead, 	ShortPath, 					%INI%,		Menu, 		ShortPath,      	        %ShortPath%
    IniRead, 	ReDisplayMenu, 				%INI%,		Menu, 		ReDisplayMenu,  	        %ReDisplayMenu%
    IniRead, 	FolderNum, 					%INI%,		Menu, 		ShowFolderNumbers, 			%FolderNum%
    IniRead, 	VirtualPath, 				%INI%,		Menu, 		VirtualPath, 				%VirtualPath%
    IniRead, 	ShowDriveLetter, 			%INI%,		Menu, 		ShowDriveLetter, 			%ShowDriveLetter%
    IniRead, 	CutFromEnd, 				%INI%,		Menu, 		CutFromEnd, 				%CutFromEnd%
                    
    IniRead, 	FoldersCount, 				%INI%,		Menu, 		FoldersCount,      	    	%FoldersCount%
    IniRead, 	FolderNameLength, 			%INI%,		Menu, 		FolderNameLength,      	    %FolderNameLength%
    
    IniRead, 	PathSeparator, 				%INI%,		Menu, 		PathSeparator,      	    %PathSeparator%
    IniRead, 	ShortNameIndicator, 	 	%INI%,		Menu, 		ShortNameIndicator,      	%ShortNameIndicator%
                
    IniRead, 	GuiColor, 					%INI%,		Colors, 	GuiBGColor, 				%GuiColor%
    IniRead, 	MenuColor, 					%INI%,		Colors, 	MenuBGColor, 				%MenuColor%
    Return
}