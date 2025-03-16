/*
    This menu allows you to change global variables through the GUI.    
    All entered/checked values are saved in the INI only when you click OK
*/

ResetSettings() {
    ; Roll back values and show them in settings
    Gui, Destroy

    SetDefaultValues()
    WriteValues() 
    ShowMenuSettings()

    Return
}

SaveSettings() {
    ; Read current GUI (global) values
    Gui, Submit  
    WriteValues()
    ValidateAutoStartup()
    Return
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleShortPath() {
;───────────────────────────────────────────────────────────────────────────── 
    ; Hide or display additional options
    global
    
    Gui, Submit, NoHide   
    if (ShortPath)
        GuiControl,, ShortPath, Show short path, indicate as:
    else 
        GuiControl,, ShortPath, Show short path
    
    GuiControl, Show%ShortPath%, CutFromEnd
    GuiControl, Show%ShortPath%, ShowDriveLetter
    GuiControl, Show%ShortPath%, DirsCount
    GuiControl, Show%ShortPath%, DirsCountText
    GuiControl, Show%ShortPath%, DirNameLength
    GuiControl, Show%ShortPath%, DirNameLengthText
    GuiControl, Show%ShortPath%, PathSeparator
    GuiControl, Show%ShortPath%, PathSeparatorText
    GuiControl, Show%ShortPath%, ShortNameIndicator
    GuiControl, Show%ShortPath%, ShortNameIndicatorText

    Return
}

;─────────────────────────────────────────────────────────────────────────────
;
ShowMenuSettings() {
;───────────────────────────────────────────────────────────────────────────── 

    /*
        References to global variables are being used. 
        If possible, it would be advisable to avoid using 
        references to local variables and creating new ones. 
        Otherwise, in order to preserve their values, 
        it may be necessary to consider the synergy of many new functions, 
        the development of which will require careful thought!   
    */ 
    global 

    LastMenuItem := A_ThisMenuItem
    FromSettings := true
    
    Gui, Font,,%MainFont%
    Gui, Color, %GuiColor%, %GuiColor%
       
    ; LEFT ALIGNED TEXT					
    ;				type		coordinates		vVARIABLE  gGOTO							title                                                 
    Gui, 	Add, 	Checkbox, 	x12 y+20        vShowDriveLetter checked%ShowDriveLetter%,  Show &drive letter
    Gui, 	Add, 	Checkbox, 					vCutFromEnd checked%CutFromEnd%, 			&Cut from the end
    
    ; Section here is anchor YS pos for right aligned fields
    ; After this block edits will appear starting from this YS pos
    Gui, 	Add, 	Text, 		        	    vDirNameLengthText Section,				    Length of &dir names	    
    Gui, 	Add, 	Text, 		    y+13        vDirsCountText,						        Number of &dirs displayed		   
    Gui, 	Add, 	Text, 		    y+13        vPathSeparatorText,						    P&ath separator			       
    
    Gui, 	Add, 	Checkbox,       y+10        vShortPath gToggleShortPath checked%ShortPath%, 	Show short path, indicate as:											  
    Gui, 	Add, 	Checkbox, 	        		vVirtualPath checked%VirtualPath%, 			Show &virtual path	
   
    Gui, 	Add, 	Text, 		    y+20		,											Menu &backgroud color (HEX)                            
    Gui, 	Add, 	Text, 		    y+13		,											Dialogs background &color (HEX)
    
            
    ; LEFT ALIGNED CHECKBOXES		
    Gui, 	Add, 	CheckBox, 	xs y+20         vOpenMenu  		checked%OpenMenu%, 			&Always open Menu if AutoSwitch disabled
    Gui, 	Add, 	CheckBox, 					vReDisplayMenu  checked%ReDisplayMenu%, 	Show Menu a&fter leaving settings
    
    ; Folder numbers radio buttons states
    Radio0 := 0
    Radio1 := 0
    Radio%FolderNum% := 1    
    Gui, 	Add, 	Radio, 		   y+20 		vFolderNum    	checked%Radio0%, 			&No folder numbering
    Gui, 	Add, 	Radio, 									  	checked%Radio1%,			&Folder numbers with shortcuts 1-0 (10)
            
            
    ; hidden default button used for accepting {Enter} to leave GUI	
    local button := "y+20 xp w74"    
    Gui, 	Add, 	Button, 	%button%  	    Default  gSaveSettings, 					&OK
    Gui, 	Add, 	Button, 	%button%  		Cancel   gCancel, 							&Cancel
    Gui, 	Add, 	Button, 	%button%  		         gResetSettings, 					&Reset

   
    ; RIGHT ALIGNED FIELDS	
    ; Start from first text YS pos
    local edit   := "w63 r1 Limit6 -Wrap"
    Gui, 	Add, 	Edit,   ys-6 %edit%         vFolderNameLength, 						    %FolderNameLength%
    Gui, 	Add, 	Edit, 	y+4  %edit% 	    vFoldersCount, 								%FoldersCount%
    Gui, 	Add, 	Edit, 	y+4  %edit% 	    vPathSeparator, 							%PathSeparator%
    Gui, 	Add, 	Edit, 	y+4  %edit% 	    vShortNameIndicator, 						%ShortNameIndicator%
    
    Gui, 	Add, 	Edit, 	y+30 %edit% 	    vMenuColor, 								%MenuColor%
    Gui, 	Add, 	Edit, 	y+4  %edit% 	    vGuiColor, 				    				%GuiColor%
    
    
    ; SETUP AND SHOW GUI
    ; current checkbox state
    ToggleShortPath() 
        
    ; These dialog coord. are obtained in ShowPathsMenu()
    local Xpos := WinX
    local Ypos := WinY + 100 
    Gui, Show, AutoSize x%Xpos% y%Ypos%, Menu settings

    Return
}