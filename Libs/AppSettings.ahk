; This menu allows you to change the behaviour of the app

RestartApp() {
    global RestartWhere

    if RestartWhere {
        IfWinActive, %RestartWhere%
            Reload
    } else {
        Reload
    }    
}

ValidateAutoStartup() {
	global AutoStartup, ScriptName
    
    IniRead, AutoStartup, %INI%, App, AutoStartup, %AutoStartup%
	link := A_Startup . "\" . ScriptName . ".lnk"	    
	
    if AutoStartup {
		if !FileExist(link) {
			FileCreateShortcut, %A_ScriptFullPath%, %link%, %A_ScriptDir%
			TrayTip, %ScriptName%, AutoStartup enabled 
		}
	} else {
		if FileExist(link) {
			FileDelete, %link%
            TrayTip, %ScriptName%, AutoStartup disabled,, 0x2 
		}
	}
}

;_____________________________________________________________________________
;
ShowAppSettings() {
;_____________________________________________________________________________ 
    global 
    
    Gui, Font,,%MainFont%
    Gui, Color, %GuiColor%

    ; SHORT fIELDS
    ;				type		coordinates		vVARIABLE  gGOTO							title 
    Gui, 	Add, 	CheckBox, 	x30 y+10  w200 	vAutoStartup checked%AutoStartup%,          Launch at &system startup
   
    Gui, 	Add, 	Text, 		y+20,						                                Open &menu key	
    Gui, 	Add, 	Edit, 		x120 yp-4 w63 	vMainKey, 							        %MainKey%    
    Gui, 	Add, 	Text, 		x30,						                                App &restart key	
    Gui, 	Add, 	Edit, 		x120 yp-4 w63 	vRestartKey, 							    %RestartKey%
      
    ; WIDE FIELDS
    Gui, 	Add, 	Text, 		x30,						                                Restart only in	
    Gui, 	Add, 	Edit, 		x120 yp-4 w174 	vRestartWhere -Wrap r1, 					%RestartWhere%    
    Gui, 	Add, 	Text, 		x30,						                                Icon (tray)	
    Gui, 	Add, 	Edit, 		x120 yp-4 w174 	vMainIcon -Wrap r1, 						%MainIcon%
    Gui, 	Add, 	Text, 		x30,						                                Font 
    Gui, 	Add, 	Edit, 		x120 yp-4 w174 	vMainFont -Wrap r1, 					    %MainFont%  
    
    ; hidden default button used for accepting {Enter} to leave GUI	
    Gui, 	Add, 	Button, 	x30 y+20 w74 	Default  gOK, 								&OK
    Gui, 	Add, 	Button, 	x+20 w74 		Cancel   gCancel, 							&Cancel
    Gui, 	Add, 	Button, 	x+20 w74 		         gShowDebugMenu, 					&Debug
    
    ; SETUP AND SHOW GUI
    local Xpos := WinX
    local Ypos := WinY + 100 
    Gui, Show, x%Xpos% y%Ypos%, %ScriptName% settings
    
    Return    
}