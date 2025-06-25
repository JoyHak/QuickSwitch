/*
    GUI updates global variables after user actions
    and displays their values as checkboxes, options, etc.

    All values are saved to the INI only after clicking OK
*/

ShowSettings() {
    global

    ReadValues()
    FromSettings := true

    ; Options that affects subsequent controls
    ; Hide window border and header
    Gui, -E0x200 -SysMenu -DPIScale +AlwaysOnTop 	
    Gui, Color, % GuiColor, % GuiColor
    Gui, Font, q5, % MainFont           ; Clean quality
    
    if DarkTheme
        Gui, Font, % "q5 c" InvertColor(GuiColor), % MainFont
    
    ; Edit fields: fixed width, one row, max 6 symbols, no multi-line word wrap and vertical scrollbar
    local edit := "w63 r1 -Wrap -vscroll"

    ; Split settings to the tabs
    Gui, Add, Tab3, -Wrap +Background +Theme AltSubmit vLastTabSettings Choose%LastTabSettings%, Menu|Theme|Short path|App

    /*
        To align "Edit" fields to the right after the "Text" fields,
        we memorize the YS position of the 1st "Text" fields using the "Section" keyword.
        Then when all the controls on the left are added one after another,
        we add "Edits" on the right starting from the memorized YS position.
        The X position is chosen automatically depending on the length of the widest "Text" field.
    */

    ;               type,     [ coordinates options     vVARIABLE       gGOTO       Section      ], title
    Gui,    Tab,    1       ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui,    Add,    CheckBox,   gToggleShowAlways       vShowAlways     checked%ShowAlways%,        Always &show Menu
    Gui,    Add,    CheckBox,                           vShowNoSwitch   checked%ShowNoSwitch%,      Show Menu if Menu options &disabled
    Gui,    Add,    CheckBox,                         vShowAfterSettings checked%ShowAfterSettings%,Show Menu after &leaving settings
    Gui,    Add,    CheckBox,                           vShowAfterSelect checked%ShowAfterSelect%,  Show Menu after selecting &path

    Gui,    Add,    CheckBox,   y+20 Section            vAutoSwitch     checked%AutoSwitch%,        &Always Auto Switch
    Gui,    Add,    CheckBox,   x+8 yp                  vDeleteDialogs,                             &del dialogs config
    Gui,    Add,    CheckBox,   xs                      vBlackListExe   checked%BlackListExe%,      &Black list: always add process, not the title
    Gui,    Add,    CheckBox,                           vSendEnter      checked%SendEnter%,         &Close old-style file dialog after selecting path
    Gui,    Add,    CheckBox,                           vPathNumbers    checked%PathNumbers%,       &Path numbers with shortcuts 0-9

    Gui,    Add,    Text,       y+20                                                  Section,      &Limit of displayed paths:

    Gui,    Add,    Edit,       ys-4 %edit% Limit4
    Gui,    Add,    UpDown,     Range1-9999             vPathLimit,                                 %PathLimit%

    Gui,    Tab,    2       ;───────────────────────────────────────────────────────────────────────────────────────────────────────
    
    Gui,    Add,    CheckBox,                           vDarkTheme      checked%DarkTheme%,         Enable dark theme
    
    Gui,    Add,    Text,       y+20                                                  Section,      &Menu backgroud color (HEX)
    Gui,    Add,    Text,       y+13,                                                               &Dialogs background color (HEX)

    Gui,    Add,    Edit,       ys-4 %edit% w90 Limit8      vMenuColor,                             %MenuColor%
    Gui,    Add,    Edit,       y+4  %edit% w90 Limit8      vGuiColor,                              %GuiColor%    
    
    Gui,    Tab,    3       ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui,    Add,    Checkbox,   gToggleShortPath        vShortPath checked%ShortPath%  Section,     Show short path, indicate as

    Gui,    Add,    Text,       y+13                    vPathSeparatorText,                         Path &separator
    Gui,    Add,    Text,       y+13                    vDirsCountText,                             Number of &dirs displayed
    Gui,    Add,    Text,       y+13                    vDirNameLengthText,                         &Length of dir names
    Gui,    Add,    Checkbox,   y+20                  vShowDriveLetter checked%ShowDriveLetter%,    Show &drive letter
    Gui,    Add,    Checkbox,                      vShowFirstSeparator checked%ShowFirstSeparator%, Show &first separator
    Gui,    Add,    Checkbox,                           vShortenEnd    checked%ShortenEnd%,         Shorten the &end

    Gui,    Add,    Edit,       ys-4 %edit% Limit       vShortNameIndicator,                        %ShortNameIndicator%
    Gui,    Add,    Edit,       y+4  %edit% Limit       vPathSeparator,                             %PathSeparator%

    Gui,    Add,    Edit,       y+4  %edit% Limit4
    Gui,    Add,    UpDown,     Range1-9999             vDirsCount,                                 %DirsCount%
    Gui,    Add,    Edit,       y+4  %edit% Limit4
    Gui,    Add,    UpDown,     Range1-9999             vDirNameLength,                             %DirNameLength%

    Gui,    Tab,    4       ;───────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui,    Add,    CheckBox,                           vAutoStartup checked%AutoStartup%,          Launch at &system startup

    Gui,    Add,    Text,       y+20                                                    Section,    Open &menu by
    Gui,    Add,    Text,       y+13,                                                               App &restart by
    Gui,    Add,    Text,       y+21,                                                               Restart only &in
    Gui,    Add,    Text,       y+13,                                                               Icon (&tray)
    Gui,    Add,    Text,       y+13,                                                               Font (&GUI)

    edit := "w120 r1 -Wrap -vscroll"
    
    ; Keyboard input controls
    Gui,    Add,    Hotkey,     ys-6  %edit%            vMainKey                        Section,    %MainKey%
    Gui,    Add,    Hotkey,     y+8   %edit%            vRestartKey,                                %RestartKey%
    
    ; Toggles between keyboard and mouse input modes
    Gui,    Add,    Button,     ys w22                  gToggleMainMouse    vMainMouseButton,       mouse
    Gui,    Add,    Button,        wp                   gToggleRestartMouse vRestartMouseButton,    mouse

    Gui,    Add,    Edit,       xs    %edit% w185       vRestartWhere,                              %RestartWhere%
    Gui,    Add,    Edit,       y+4   %edit% wp         vMainIcon,                                  %MainIcon%
    Gui,    Add,    Edit,       y+4   %edit% wp         vMainFont,                                  %MainFont%
    
    ; Mouse input controls
    local mouse := GetMouseList("list")
    
    Gui,    Add,    ListBox,    xs ys+25 w120 h45       gGetMouseKey vMain,                         %mouse%
    Gui,    Add,    ListBox,    xs ys+60 wp hp          gGetMouseKey vRestart,                      %mouse%
    
    Gui,    Add,    Edit,       xs ys %edit%            ReadOnly  vMainMouse,                       %MainMouse%
    Gui,    Add,    Edit,       y+8   %edit%            ReadOnly  vRestartMouse,                    %RestartMouse%

    Gui,    Tab     ; BUTTONS   ────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui,    Add,    Button,     xm+40   w74   Default   gSaveSettings,                              &OK
    Gui,    Add,    Button,     x+20 yp wp    Cancel    gCancel,                                    &Cancel

    local button := NukeSettings ? "Nuke" : "Reset"
    Gui,    Add,    Button,     x+20 yp wp           g%button%Settings,                             &%button%
    NukeSettings := false


    ; SETUP AND SHOW GUI        ────────────────────────────────────────────────────────────────────────────────────────────────────────
    ; Current checkbox state
    ToggleShowAlways()
    ToggleShortPath()
    
    ; Toggle between mouse and keyboard input mode
    InitMouseMode("Main",    MainMouse    != "")
    InitMouseMode("Restart", RestartMouse != "")
    
    if DarkTheme {
        SetDarkTheme("OkButton|CancelButton|NukeButton|ResetButton|DebugButton|msctls_hotkey321")
    }

    ; Get dialog position
    local _winX, _winY, _pos := ""
    WinGetPos, _winX, _winY,,, A

    if (_winX && _winY)
        _pos := " x" _winX " y" _winY + 100

    Gui, Show, % "AutoSize" _pos, Settings
}