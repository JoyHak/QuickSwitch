/*
    This GUI uses global variables because they can be changed anywhere,
    but it doesn't update / check / read values (from INI).
    
    All global variables are looked again each time and update the 
    corresponding options / checkboxes etc.
    
    All entered/checked values are saved in the INI only when you click OK.
*/

ShowSettings() {
    global
    FromSettings := true

    ; Options that affects subsequent controls
    Gui, -E0x200 -SysMenu +AlwaysOnTop  ; hide window border and header
    Gui, Font, q5, %MainFont%           ; clean quality
    Gui, Color, %GuiColor%, %GuiColor%

    ; Edit fields: fixed width, one row, max 6 symbols, no multi-line word wrap and vertical scrollbar
    local edit   := "w63 r1 -Wrap -vscroll"

    ; Split settings to the tabs
    Gui, Add, Tab3, -Wrap +Background +Theme AltSubmit vLastTabSettings Choose%LastTabSettings%, Menu|Short path|App

    /*
        To align "Edit" fields to the right after the "Text" fields,
        we memorize the YS position of the 1st "Text" fields using the "Section" keyword.
        Then when all the controls on the left are added one after another,
        we add "Edits" on the right starting from the memorized YS position.
        The X position is chosen automatically depending on the length of the widest "Text" field.
    */

    ;				type,	  [ coordinates options	    vVARIABLE       gGOTO       Section      ],	title
    Gui,    Tab,    1       ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, 	Add, 	CheckBox, 	                        vOpenMenu  		checked%OpenMenu%, 			&Always open Menu if AutoSwitch disabled
    Gui, 	Add, 	CheckBox, 					        vReDisplayMenu  checked%ReDisplayMenu%, 	&Show Menu after leaving settings
    Gui, 	Add, 	CheckBox, 					        vPathNumbers	checked%PathNumbers%,		&Path numbers with shortcuts 1-0 (10)


    Gui, 	Add, 	Text, 		y+20		                                        Section,		&Menu backgroud color (HEX)
    Gui, 	Add, 	Text, 		y+13,											                    &Dialogs background color (HEX)

    Gui, 	Add, 	Edit, 	    ys-4 %edit% Limit8	    vMenuColor, 								%MenuColor%
    Gui, 	Add, 	Edit, 	    y+4  %edit% Limit8	    vGuiColor, 				    				%GuiColor%

    Gui,    Tab,    2       ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, 	Add, 	Checkbox,                           vShortPath gToggleShortPath checked%ShortPath% Section, 	Show short path, indicate as

    Gui, 	Add, 	Text, 	    y+13                    vPathSeparatorText,		                    Path &separator
    Gui, 	Add, 	Text, 	    y+13                    vDirsCountText,						        Number of &dirs displayed
    Gui, 	Add, 	Text, 	    y+13    	            vDirNameLengthText,		                    &Length of dir names
    Gui, 	Add, 	Checkbox,   y+20                    vShowDriveLetter checked%ShowDriveLetter%,  Show &drive letter
    Gui, 	Add, 	Checkbox, 					        vShowFirstSeparator checked%ShowFirstSeparator%, Show &first separator
    Gui, 	Add, 	Checkbox, 					        vShortenEnd checked%ShortenEnd%, 			Shorten the &end

    Gui, 	Add, 	Edit, 	    ys-4 %edit% Limit	    vShortNameIndicator, 						%ShortNameIndicator%
    Gui, 	Add, 	Edit, 	    y+4  %edit% Limit	    vPathSeparator, 							%PathSeparator%

    Gui, 	Add, 	Edit, 	    y+4  %edit% Limit4
    Gui, 	Add, 	UpDown,     Range1-9999             vDirsCount, 								%DirsCount%
    Gui, 	Add, 	Edit,       y+4  %edit% Limit4
    Gui, 	Add, 	UpDown,     Range1-9999             vDirNameLength, 						    %DirNameLength%

    Gui,    Tab,    3       ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, 	Add, 	CheckBox, 	             	        vAutoStartup checked%AutoStartup%,          Launch at &system startup

    Gui, 	Add, 	Text, 		y+20                                                    Section,	Open &menu by
    Gui, 	Add, 	Text, 		y+13,						                                        App &restart by
    Gui, 	Add, 	Text, 		y+13,						                                        Restart only &in
    Gui, 	Add, 	Text, 		y+13,						                                        Icon (&tray)
    Gui, 	Add, 	Text, 		y+13,                                                               Font (&GUI)

    edit := "w160 r1 -Wrap -vscroll"
    Gui, 	Add, 	Hotkey,     ys-4 %edit% w100	    vMainKey                        Section, 	%MainKey%
    Gui, 	Add, 	Hotkey,     y+4  %edit% w100	    vRestartKey, 							    %RestartKey%
    Gui, 	Add, 	CheckBox,   ys+4                    vMainKeyHook    checked%MainKeyHook%, 	    hook
    Gui, 	Add, 	CheckBox,   y+12	                vRestartKeyHook checked%RestartKeyHook%,    hook

    Gui, 	Add, 	Edit, 	    xs    %edit% 	        vRestartWhere, 					            %RestartWhere%
    Gui, 	Add, 	Edit, 	    y+4   %edit% 	        vMainIcon, 						            %MainIcon%
    Gui, 	Add, 	Edit, 	    y+4   %edit% 	        vMainFont, 					                %MainFont%

    Gui,    Tab     ; BUTTONS   ────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, 	Add, 	Button, 	w74             Default  gSaveSettings, 					        &OK
    Gui, 	Add, 	Button, 	wp x+20 yp  	Cancel   gCancel, 							        &Cancel

    if NukeSettings {
        NukeSettings := false
        Gui,  Add,    Button,     wp x+20 yp  gNukeSettings,   &Nuke
    } else {
        Gui,  Add,    Button,     wp x+20 yp  gResetSettings,  &Reset
    }

    Gui, 	Add, 	Button, 	wp xp ym-4               gShowDebug, 				                &Debug


    ; SETUP AND SHOW GUI        ────────────────────────────────────────────────────────────────────────────────────────────────────────
    ; Current checkbox state
    ToggleShortPath()

    local Xpos := WinX
    local Ypos := WinY + 100
    Gui, Show, AutoSize x%Xpos% y%Ypos%, Menu settings
    return
}