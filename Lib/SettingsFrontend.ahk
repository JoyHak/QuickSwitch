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
    Gui, Destroy
    Gui, -E0x200 -SysMenu +DPIScale +AlwaysOnTop +HwndSettingsId
    Gui, Color, % GuiColor, % GuiColor
    
    local _options := "q5"
    if DarkTheme
        _options .= " c" InvertColor(GuiColor)
    if MainFontSize
        _options .= " s" MainFontSize
    
    Gui, Font, % _options, % MainFont
    
    ; The larger the font size and DPI, the wider the input fields
    local scale := (MainFontSize != 0) ? (MainFontSize - 8) : 0

    ; Edit fields: one row, no multi-line word wrap, no vertical scrollbar
    local fieldDefault := "r1 -Wrap -vscroll w"
    local updown := fieldDefault . 4  * (10 + scale) . " Limit2"
    local tiny   := fieldDefault . 5  * (10 + scale)
    local short  := fieldDefault . 10 * (10 + scale)
    local list   := "r4 w"       . 10 * (10 + scale)
    local long   := fieldDefault . 14 * (10 + scale)

    ; Split settings to the tabs
    Gui, Add, Tab3, -Wrap +Background +Theme AltSubmit vLastTabSettings Choose%LastTabSettings%, Menu|Theme|Short path|App|Reset

    /*
        To align "Edit" fields to the right after the "Text" fields,
        we memorize the YS position of the 1st "Text" fields using the "Section" keyword.
        Then when all the controls on the left are added one after another,
        we add "Edits" on the right starting from the memorized YS position.
        The X position is chosen automatically depending on the length of the widest "Text" field.
    */

    ;         Control,    [ Coordinates / Callback          Variable              State / Section                ], Title
    Gui, Tab, 1 ;────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, Add, Text,                                         vShowMenuAfterText,                                     Show menu after:
    Gui, Add, CheckBox,                                     vShowNoSwitch         checked%ShowNoSwitch%,            &Disabling Auto Switch
    Gui, Add, CheckBox,                                     vShowAfterSettings    checked%ShowAfterSettings%,       Leaving &settings
    Gui, Add, CheckBox,                                     vShowAfterSelect      checked%ShowAfterSelect%,         Selecting &path
    Gui, Add, CheckBox,     gToggleShowAlways               vShowAlways           checked%ShowAlways%,              Always
    
    GuiControlGet, Margin, pos, ShowMenuAfterText
    Gui, Add, Text,         y+%MarginH%                                           Section,                          Auto Switch
    Gui, Add, Edit,         ys-4  %updown%      
    Gui, Add, UpDown,       Range1-99                       vAutoSwitchIndex      Section,                          %AutoSwitchIndex%
    Gui, Add, Text,         ys+4                            vCenteredText         Section,                          path from
    Gui, Add, DropDownList, ys-3  w%MarginW%                vAutoSwitchTarget,                                      PinnedPaths|FavoritePaths|ManagersPaths|ClipboardPaths|MenuStack
    GuiControl, % "ChooseString", % "AutoSwitchTarget",   % AutoSwitchTarget
    
    GuiControlGet, Center, pos, CenteredText
    Gui, Add, CheckBox,     y+%MarginH% x%MarginX%          vAutoSwitch           checked%AutoSwitch%,              &Always Auto Switch
    Gui, Add, CheckBox,                                     vBlackListProcess     checked%BlackListProcess%,        Add process names to &Black list
    Gui, Add, CheckBox,                                     vSendEnter            checked%SendEnter%,               &Close old-style file dialog after selecting path
    Gui, Add, CheckBox,                                     vPathNumbers          checked%PathNumbers%,             Path numbers &with shortcuts 0-9
    Gui, Add, CheckBox,                                     vDeleteDuplicates     checked%DeleteDuplicates%,        &Delete duplicate paths

    Gui, Add, Text,         y+%MarginH%                                           Section,                          &Limit of displayed paths
    Gui, Add, Edit,         ys-4  %updown%
    Gui, Add, UpDown,       Range1-9999                     vPathLimit,                                             %PathLimit%

    Gui, Tab, 2 ;────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, Add, CheckBox,           gToggleDarkTheme          vDarkTheme            checked%DarkTheme%,               Apply &dark theme
    Gui, Add, Text,         y+%MarginH%                                           Section,                          &Menu color (HEX)
    Gui, Add, Text,         y+12,                                                                                   &Settings color (HEX) 
    Gui, Add, Text,         y+12,                                                                                   &Menu font
    Gui, Add, Text,         y+12,                                                                                   &Settings font
    Gui, Add, CheckBox,     y+12  gToggleIcons              vShowIcons            checked%ShowIcons%,               Sho&w icons from

    Gui, Add, Edit,         ys-4  %short% Limit8            vMenuColor            Section,                          %MenuColor%
    Gui, Add, Edit,         y+4   %short% Limit8            vGuiColor,                                              %GuiColor%

    Gui, Add, Edit,         y+4   %short%                   vMenuFont,                                              %MenuFont%
    Gui, Add, Edit,     x+m yp    %updown%      
    Gui, Add, UpDown,       Range0-99                       vMenuFontSize,                                          %MenuFontSize%    
    Gui, Add, Edit,     xs  y+4   %short%                   vMainFont,                                              %MainFont%    
    Gui, Add, Edit,     x+m yp    %updown%      
    Gui, Add, UpDown,       Range0-99                       vMainFontSize,                                          %MainFontSize%
    
    Gui, Add, Edit,      xs y+4   %short%                   vIconsDir             Section,                          %IconsDir%
    Gui, Add, Edit,         ys    %updown%                  vIconsSizePlaceholder
    Gui, Add, UpDown,       Range1-200                      vIconsSize,                                             %IconsSize%
    
    Gui, Add, Text,         y+%MarginH%  x%MarginX%,                                                                Show sections in Menu:
    Gui, Add, CheckBox,           gToggleFavorites          vShowFavorites        checked%ShowFavorites%,           Fa&vorites from
    Gui, Add, Edit,      xs yp-5  %long%                    vFavoritesDir,                                          %FavoritesDir%
    
    Gui, Add, CheckBox,     y+%scale%    x%MarginX%         vShowPinned           checked%ShowPinned%,              &Pinned paths
    Gui, Add, CheckBox,                                     vShowClipboard        checked%ShowClipboard%,           Paths from &Clipboard
    Gui, Add, CheckBox,           gToggleManagersTabs       vShowManagers         checked%ShowManagers%,            &File managers paths
    Gui, Add, CheckBox,     y+10         xp+%MarginH%       vActiveTabOnly        checked%ActiveTabOnly%,           only the &active tab
    Gui, Add, CheckBox,                                     vShowLockedTabs       checked%ShowLockedTabs%,          &locked tabs

    Gui, Tab, 3 ;────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, Add, Checkbox,     gToggleShortPath                vShortPath    Section checked%ShortPath%,               &Show short path, indicate as

    Gui, Add, Text,         y+13                            vPathSeparatorText,                                     Path &separator
    Gui, Add, Text,         y+13                            vDirsCountText,                                         Number of &dirs displayed
    Gui, Add, Text,         y+13                            vDirNameLengthText,                                     &Length of dir names
    Gui, Add, Checkbox,     y+%MarginH%                     vShowDriveLetter        checked%ShowDriveLetter%,       Show &drive letter
    Gui, Add, Checkbox,                                     vShowFirstSeparator     checked%ShowFirstSeparator%,    Show &first separator
    Gui, Add, Checkbox,                                     vShortenEnd             checked%ShortenEnd%,            Shorten the &end

    Gui, Add, Edit,         ys-4 %tiny%                     vShortNameIndicator,                                    %ShortNameIndicator%
    Gui, Add, Edit,         y+4  %tiny%                     vPathSeparator,                                         %PathSeparator%

    Gui, Add, Edit,         y+4  %tiny%     Limit4
    Gui, Add, UpDown,       Range1-9999                     vDirsCount,                                             %DirsCount%
    Gui, Add, Edit,         y+4  %tiny%     Limit4
    Gui, Add, UpDown,       Range1-9999                     vDirNameLength,                                         %DirNameLength%

    Gui, Tab, 4 ;────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, Add, CheckBox,                                     vAutoStartup          checked%AutoStartup%,             Launch at &system startup

    Gui, Add, Text,         y+%MarginH%                                           Section,                          &Pin path (hold && click)
    Gui, Add, Text,         y+%MarginH%,                                                                            &Show menu by
    /*
        Keyboard input or selecting mouse keys is performed by 4 elements:
        - Hotkey: allows to input keyboard shortcut.
        - Listbox: allows to select the mouse buttons or shortcuts.
        - Placeholder: displays the mouse button selected in Listbox.
        - Button: toggles Listbox and Placeholder visibility
        See the implementation and documentation in Lib\SettingsMouse
    */
    local listbox := list  " wp xp yp+" MarginH + 9

    Gui, Add, Edit,         ys-4  %short%    ReadOnly       vPinKey               Section                         ; Dummy for positioning
    Gui, Add, Edit,      xp yp    %short%    ReadOnly       vPinMousePlaceholder,                                 % PinMousePlaceholder
    Gui, Add, ListBox,            %listbox%  gGetMouseKey   vPinMouseListBox,                                     % GetMouseList("pinList")
    Gui, Add, Button,       ys               gTogglePinMouse,                                                       mouse
    
    Gui, Add, Hotkey,    xs y+8   %short%                   vMainKey              Section,                        % MainKey
    Gui, Add, Edit,      xp yp    %short%    ReadOnly       vMainMousePlaceholder,                                % MainMousePlaceholder
    Gui, Add, ListBox,            %listbox%  gGetMouseKey   vMainMouseListBox,                                    % GetMouseList("mouseList")
    Gui, Add, Button,    hs   ys           gToggleMainMouse vMainMouseButton,                                       mouse

;@Ahk2Exe-IgnoreBegin
    Gui, Add, Hotkey,    xs y+8   %short%                   vRestartKey           Section,                        % RestartKey
    Gui, Add, Edit,         xp yp %short%    ReadOnly       vRestartMousePlaceholder,                             % RestartMousePlaceholder
    Gui, Add, ListBox,            %listbox%  gGetMouseKey   vRestartMouseListBox,                                 % GetMouseList("mouseList")
    Gui, Add, Button,       ys          gToggleRestartMouse vRestartMouseButton,                                    mouse
    Gui, Add, Text,    x%MarginX% ys+4,                                                                             &Restart app by
;@Ahk2Exe-IgnoreEnd       
    Gui, Add, Edit,xs y+%MarginH% %long%                    vMainIcon             Section,                        % MainIcon
    Gui, Add, Text,    x%MarginX% ys+4,                                                                             Icon (t&ray)
;@Ahk2Exe-IgnoreBegin 
    Gui, Add, Edit,        xs y+8 %long%                    vRestartWhere,                                        % RestartWhere        
    Gui, Add, Text,    x%MarginX% yp+4,                                                                             &Restart only in
    Gui, Add, CheckBox,y+%MarginH%                          vShowAfterRestart     checked%ShowAfterRestart%,        Show &Menu after restart
    Gui, Add, CheckBox,                                     vShowNearCursor       checked%ShowNearCursor%,          Show Menu near the mouse cursor
    Gui, Add, CheckBox,                                     vShowUiAfterRestart   checked%ShowUiAfterRestart%,      Show &settings after restart
    Gui, Add, CheckBox,                                     vSaveLastTab          checked%SaveLastTab%,             Open &last settings tab after restart
    Gui, Add, CheckBox,                                     vSaveUiPosition       checked%SaveUiPosition%,          Save settings window position

    Gui, Add, CheckBox,y+%MarginH%                          vShowOpenDialog       checked%ShowOpenDialog%,          Open "Op&en" dialog before Menu
    Gui, Add, CheckBox,                                     vShowSaveAsDialog     checked%ShowSaveAsDialog%,        Open "&Save As" dialog before Menu
;@Ahk2Exe-IgnoreEnd 
    
    Gui, Tab, 5 ;────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, Add, Text,,                                                                                                Delete from configuration:
    Gui, Add, CheckBox,     y+%MarginH%                     vDeleteDialogs,                                         &Black List and Auto Switch
    Gui, Add, CheckBox,                                     vDeleteFavorites,                                       &Favorite paths
    Gui, Add, CheckBox,                                     vDeletePinned,                                          &Pinned paths
    Gui, Add, CheckBox,                                     vDeleteClipboard,                                       &Clipboard paths
    Gui, Add, CheckBox,                                     vDeleteKeys,                                            &Hotkeys and mouse buttons
    Gui, Add, CheckBox,     y+%MarginH%                     vNukeSettings,                                          &Nuke configration

    Gui, Tab ; BUTTONS ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    local button := NukeSettings ? "Nuke" : "Reset"
    NukeSettings := false

    Gui, Add, Button, % "x" ((CenterX >> 2) - scale) " w" CenterW " gSaveSettings Default",                       % "&OK"
    Gui, Add, Button, % "x+" CenterH " yp wp                gGuiEscape",                                          % "&Cancel"
    Gui, Add, Button, % "x+" CenterH " yp wp                g" button "Settings",                                 % "&" button
    Gui, Add, Button, % "x+" CenterH " yp wp                gShowDebug",                                          % "Debu&g"

    ; SETUP AND SHOW GUI ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    ; Current checkbox state
    ToggleShowAlways()
    ToggleIcons()
    ToggleFavorites()
    ToggleShortPath()

    ; Toggle between mouse and keyboard input mode
    InitMouseMode("Pin",     true)  ; Mouse buttons only
    InitMouseMode("Main",    MainMousePlaceholder    != "")
    InitMouseMode("Restart", RestartMousePlaceholder != "")

    if DarkTheme
        SetDarkTheme("&OK|&Cancel|&Nuke|&Debug|&Reset|msctls_hotkey321")

    ; Set settings window position
    local _pos  := ""
        , _posX := ""
        , _posY := ""
;@Ahk2Exe-IgnoreBegin
    if SaveUiPosition && UiPosX && UiPosY       
        _pos := "x" UiPosX " y" UiPosY
;@Ahk2Exe-IgnoreEnd
    if !_pos {
        WinGetPos, _posX, _posY,,, % "ahk_id " DialogId        
        if (_posX && _posY)
            _pos := "x" _posX " y" _posY + 100
        else
            _pos := "x0 y100"        
    }
    Gui, Show, % "AutoSize " _pos, Settings
}