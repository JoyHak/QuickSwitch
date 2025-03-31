/*
    This menu allows you to change global variables through the GUI.
    All entered/checked values are saved in the INI only when you click OK
    References to global variables are being used.

    If possible, it would be advisable to avoid using
    references to local variables and creating new ones.

    Otherwise, in order to preserve their values,
    it may be necessary to consider the synergy of many new functions,
    the development of which will require careful thought!
*/

ShowMenuSettings() {

    global
    LastMenuItem := A_ThisMenuItem
    FromSettings := true

    ; Options that affects subsequent controls
    Gui, -E0x200 -SysMenu           ; hide window border and header
    Gui, Font, q5, %MainFont%       ; clean quality
    Gui, Color, %GuiColor%, %GuiColor%

    ; Edit fields: fixed width, one row, max 6 symbols, no multi-line word wrap and vertical scrollbar
    local edit   := "w63 r1 Limit6 -Wrap -vscroll"

    ; Split settings to the tabs
    Gui, Add, Tab3, -Wrap -Background +Theme AltSubmit vLastTabSettings Choose%LastTabSettings%, Menu|Short path|App

    /*
        To align "Edit" fields to the right after the "Text" fields,
        we memorize the YS position of the 1st "Text" fields using the "Section" keyword.
        Then when all the controls on the left are added one after another,
        we add "Edits" on the right starting from the memorized YS position.
        The X position is chosen automatically depending on the length of the widest "Text" field.
    */

    ;				type,	  [ coordinates	    vVARIABLE       gGOTO       Section      ],	title

    Gui,    Tab,    Menu       ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, 	Add, 	CheckBox, 	                vOpenMenu  		checked%OpenMenu%, 			&Always open Menu if AutoSwitch disabled
    Gui, 	Add, 	CheckBox, 					vReDisplayMenu  checked%ReDisplayMenu%, 	Show Menu a&fter leaving settings
    Gui, 	Add, 	CheckBox, 					vPathNumbers	checked%PathNumbers%,		&Path numbers with shortcuts 1-0 (10)


    Gui, 	Add, 	Text, 		    y+20		                             Section,		    Menu &backgroud color (HEX)
    Gui, 	Add, 	Text, 		    y+13,											        Dialogs background &color (HEX)

    Gui, 	Add, 	Edit, 	    ys-4 %edit% 	vMenuColor, 								%MenuColor%
    Gui, 	Add, 	Edit, 	    y+4  %edit% 	vGuiColor, 				    				%GuiColor%

    Gui,    Tab,    Short path  ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, 	Add, 	Checkbox,                   vShortPath gToggleShortPath checked%ShortPath% Section, 	Show short path, indicate as

    Gui, 	Add, 	Text, 		    y+13        vPathSeparatorText,		                    P&ath separator
    Gui, 	Add, 	Text, 		    y+13        vDirsCountText,						        Number of &dirs displayed
    Gui, 	Add, 	Text, 		    y+13    	vDirNameLengthText,		                    Length of &dir names
    Gui, 	Add, 	Checkbox, 	    y+20        vShowDriveLetter checked%ShowDriveLetter%,  Show &drive letter
    Gui, 	Add, 	Checkbox, 					vShortenEnd checked%ShortenEnd%, 			&Shorten the end

    Gui, 	Add, 	Edit, 	    ys-4  %edit% 	vShortNameIndicator, 						%ShortNameIndicator%
    Gui, 	Add, 	Edit, 	    y+4   %edit% 	vPathSeparator, 							%PathSeparator%
    Gui, 	Add, 	Edit, 	    y+4   %edit% 	vDirsCount, 								%DirsCount%
    Gui, 	Add, 	Edit,       y+4   %edit%    vDirNameLength, 						    %DirNameLength%

    Gui,    Tab,    App         ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, 	Add, 	CheckBox, 	             	vAutoStartup checked%AutoStartup%,          Launch at &system startup

    Gui, 	Add, 	Text, 		y+20                                        Section,		Open &menu by
    Gui, 	Add, 	Text, 		y+13,						                                App &restart by
    Gui, 	Add, 	Text, 		y+13,						                                Restart only in
    Gui, 	Add, 	Text, 		y+13,						                                Icon (tray)
    Gui, 	Add, 	Text, 		y+13,                                                       Font (GUI)

    edit := "w160 r1 -Wrap -vscroll"
    Gui, 	Add, 	Hotkey,   ys-4 %edit% w100	vMainKey                    Section, 		%MainKey%
    Gui, 	Add, 	Hotkey,   y+4  %edit% w100	vRestartKey, 							    %RestartKey%
    Gui, 	Add, 	CheckBox, ys+4              vMainKeyHook    checked%MainKeyHook%, 	    hook
    Gui, 	Add, 	CheckBox, y+12	            vRestartKeyHook checked%RestartKeyHook%,    hook

    Gui, 	Add, 	Edit, 	  xs    %edit% 	    vRestartWhere, 					            %RestartWhere%
    Gui, 	Add, 	Edit, 	  y+4   %edit% 	    vMainIcon, 						            %MainIcon%
    Gui, 	Add, 	Edit, 	  y+4   %edit% 	    vMainFont, 					                %MainFont%

    Gui,    Tab     ; BUTTONS   ────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, 	Add, 	Button, 	w74             Default  gSaveSettings, 					&OK
    Gui, 	Add, 	Button, 	wp x+20 yp  	Cancel   gCancel, 							&Cancel
    Gui, 	Add, 	Button, 	wp x+20 yp 		         gResetSettings, 					&Reset


    ; SETUP AND SHOW GUI        ────────────────────────────────────────────────────────────────────────────────────────────────────────
    ; current checkbox state
    ToggleShortPath()

    ; These dialog coord. are obtained in ShowPathsMenu()
    local Xpos := WinX
    local Ypos := WinY + 100
    Gui, Show, AutoSize x%Xpos% y%Ypos%, Menu settings
    Return
}