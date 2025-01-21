#Requires AutoHotkey v1.1

;_____________________________________________________________________________
;
ValidateWriteColor(_color, _default, _iniParamName)
;_____________________________________________________________________________
;
{
  global INI
  
  _result 	:= _default
  _matchPos := RegExMatch(_color, "i)[a-f0-9]{6}$")
  If (_matchPos > 0)
    _result := SubStr(_color, _matchPos)
    
  ; default is new
  IniWrite, %_result%, %INI%, Colors, %_iniParamName%
  Return _result
}

;_____________________________________________________________________________
;
ValidateWriteInteger(_new, _default, _iniParamName, _maximum := 0)
;_____________________________________________________________________________
;
{
  ; Validates whether the value is a integer
  ; If _maximum is specified, it validates whether the number is in the range [0-max].
  ; The checked value _new is written to INI, otherwise it is written _default
  ; returns the value written to the file
  
  global INI
  _result := _default

  If _new is Integer
  {
	If _maximum > 0 and _maximum is Integer
    {
	  If _new between 0 and _maximum
        _result := _new
	} 
	Else
	{
	  _result := _new
	}
  }
  IniWrite, %_result%, %INI%, Menu, %_iniParamName%
  Return _result
}

;_____________________________________________________________________________
;
ValidateWriteString(_new, _default, _iniParamName, _onErrorString := "")
;_____________________________________________________________________________
;
{
  ; Converts the value to a string. 
  ; If an error occurs, it converts _default to a string. 
  ; In the case of this error, the final value will be _onErrorString.
  ; The final value is written to the INI and returned to
  
  global INI
  _result        := _onErrorString  
  _newString     := Format("{}", _new)
  _defaultString := Format("{}", _default)
  
  If _newString
	_result      := _newString
  Else If _defaultString
    _result      := _defaultString
  
  IniWrite, %_result%, %INI%, Menu, %_iniParamName%
  Return _result
}


;_____________________________________________________________________________
;
ReadValues(_validate := true)
;_____________________________________________________________________________
;
{
  ; read values from INI
  ; the current value of global variables is set in the SetDefaultValues() function, 
  ; so it is passed to IniRead as "default value"
  
  ;			  temp						INI name	section		param name					default value
  IniRead, 	  OpenMenu,      			%INI%,		Menu, 		AlwaysOpenMenu, 	        %OpenMenu%
  IniRead, 	  ShortPath,     			%INI%,		Menu, 		ShortPath,      	        %ShortPath%
  IniRead, 	  ReDisplayMenu, 			%INI%,		Menu, 		ReDisplayMenu,  	        %ReDisplayMenu%
  IniRead, 	  FolderNum,     			%INI%,		Menu, 		ShowFolderNumbers, 			%FolderNum%
  
  IniRead, 	  PathSeparator,     		%INI%,		Menu, 		PathSeparator,      	    %PathSeparator%
  IniRead, 	  ShortNameIndicator,    	%INI%,		Menu, 		ShortNameIndicator,      	%ShortNameIndicator%
  
  IniRead, 	  GuiBGColor,    			%INI%,		Colors, 	GuiBGColor, 				%GuiColor%
  IniRead, 	  MenuBGColor,   			%INI%,		Colors, 	MenuBGColor, 				%MenuColor%
  
  If _validate
  {
    ; check INI values, only use them if valid, otherwise use defaults
    OpenMenu      		:= ValidateWriteInteger(OpenMenu     , 		OpenMenu     , 		"AlwaysOpenMenu")
    ShortPath     		:= ValidateWriteInteger(ShortPath 	 , 		ShortPath    , 		"ShortPath")
    ReDisplayMenu 		:= ValidateWriteInteger(ReDisplayMenu, 		ReDisplayMenu, 		"ReDisplayMenu")
    FolderNum     		:= ValidateWriteInteger(FolderNum    , 		FolderNum    , 		"ShowFolderNumbers")
	
	PathSeparator  	:= ValidateWriteString(PathSeparator, 		PathSeparator, 		"PathSeparator")
    ShortNameIndicator := ValidateWriteString(ShortNameIndicator,  ShortNameIndicator, 	"ShortNameIndicator")
	
    GuiColor      		:= ValidateWriteColor(GuiBGColor     , 		GuiColor     , 		"GuiBGColor")
    MenuColor     		:= ValidateWriteColor(MenuBGColor    , 		MenuColor    , 		"MenuBGColor")
  }
  Return
}