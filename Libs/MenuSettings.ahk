/*
    This menu allows you to change global variables through the GUI.    
    All entered/checked values are saved in the INI only when you click OK
*/

ResetToDefaults() {
    Gui, Destroy

    ; Rolling back values and showing them in settings
    SetDefaultValues()
    WriteValues() 
    ShowMenuSettings()

    Return
}

OK() {
    ; read current GUI (global) values
    Gui, Submit    
    WriteValues()
    ValidateAutoStartup()
    Return
}

ShortPath() {
    ; Hides or displays additional options
    global
    
    Gui, Submit, NoHide   
    if (ShortPath)
        GuiControl,, ShortPath, Show short path, indicate as:
    else 
        GuiControl,, ShortPath, Show short path
    
    GuiControl, Show%ShortPath%, CutFromEnd
    GuiControl, Show%ShortPath%, ShowDriveLetter
    GuiControl, Show%ShortPath%, FoldersCount
    GuiControl, Show%ShortPath%, FoldersCountText
    GuiControl, Show%ShortPath%, FolderNameLength
    GuiControl, Show%ShortPath%, FolderNameLengthText
    GuiControl, Show%ShortPath%, PathSeparator
    GuiControl, Show%ShortPath%, PathSeparatorText
    GuiControl, Show%ShortPath%, ShortNameIndicator
    GuiControl, Show%ShortPath%, ShortNameIndicatorText

    Return
}

;_____________________________________________________________________________
;
ShowMenuSettings() {
;_____________________________________________________________________________ 

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
    
    ; Folder numbers radio buttons states
    Radio0 := 0
    Radio1 := 0
    ; Toggle radio depends on FolderNum global state
    Radio%FolderNum% := 1		
    
    Gui, Font,,%MainFont%
       
    ; SHORT PATH					
    ;				type		coordinates		vVARIABLE  gGOTO							title                                                 
    Gui, 	Add, 	Checkbox, 	x30  w200 y+10  vShowDriveLetter checked%ShowDriveLetter%, 	Show &drive letter
    Gui, 	Add, 	Checkbox, 					vCutFromEnd checked%CutFromEnd%, 			&Cut from the end
    
    Gui, 	Add, 	Text, 		x30				vFolderNameLengthText,						Length of &folder names	
    Gui, 	Add, 	Edit, 		x230 yp-4 w63 	vFolderNameLength, 							%FolderNameLength%
    
    Gui, 	Add, 	Text, 		x30				vFoldersCountText,							Number of &folders displayed		
    Gui, 	Add, 	Edit, 		x230 yp-4 w63 	vFoldersCount, 								%FoldersCount%
    
    Gui, 	Add, 	Text, 		x30				vPathSeparatorText,							P&ath separator			
    Gui, 	Add, 	Edit, 		x230 yp-4 w63 	vPathSeparator, 							%PathSeparator%
    
    Gui, 	Add, 	Checkbox, 	x30  w200		vShortPath gShortPath checked%ShortPath%, 	Show &short path											
    Gui, 	Add, 	Edit, 		x230 yp-4 w63 	vShortNameIndicator, 						%ShortNameIndicator%
    
    Gui, 	Add, 	Checkbox, 	x30  w200		vVirtualPath checked%VirtualPath%, 			Show &virtual path											
        
    ; MENU SETTINS		
    Gui, 	Add, 	CheckBox, 	         		vOpenMenu  		checked%OpenMenu%, 			&Always open Menu if AutoSwitch disabled
    Gui, 	Add, 	CheckBox, 					vReDisplayMenu  checked%ReDisplayMenu%, 	Show Menu a&fter leaving settings
                        
    Gui, 	Add, 	Text, 		x30, 														Menu &backgroud color (HEX)
    Gui, 	Add, 	Edit, 		x230 yp-4 w63 	vMenuColor, 								%MenuColor%
                        
    Gui, 	Add, 	Text, 		x30, 														Dialogs background &color (HEX)
    Gui, 	Add, 	Edit, 		x230 yp-4 w63 	vGuiColor, 				    				%GuiColor%
                    
    Gui, 	Add, 	Radio, 		x30 y+15 		vFolderNum    	Checked%Radio0%, 			&No folder numbering
    Gui, 	Add, 	Radio, 									  	Checked%Radio1%,			&Folder numbers with shortcuts 1-0 (10)
            
            
    ; hidden default button used for accepting {Enter} to leave GUI			
    Gui, 	Add, 	Button, 	y+20 w74  	    Default  gOK, 								&OK
    Gui, 	Add, 	Button, 	x+20 w74  		Cancel   gCancel, 							&Cancel
    Gui, 	Add, 	Button, 	x+20 w74  		         gResetToDefaults, 					&Reset
    
    
    ; SETUP AND SHOW GUI
    ; current checkbox state
    ShortPath() 
    Gui, Color, %GuiColor%
    
    ; These dialog coord. are obtained in ShowPathsMenu()
    local Xpos := WinX
    local Ypos := WinY + 100 
    Gui, Show, x%Xpos% y%Ypos%, Menu settings
    
    Return
}