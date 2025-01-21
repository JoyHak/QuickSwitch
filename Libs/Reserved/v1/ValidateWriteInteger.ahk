#Requires AutoHotkey v1.1

;_____________________________________________________________________________
;
ValidateWriteInteger(_new, _iniParamName) 	; reserved
;_____________________________________________________________________________
{  
  global INI

  If _new is Integer
	IniWrite, %_new%, %INI%, Menu, %_iniParamName%
}