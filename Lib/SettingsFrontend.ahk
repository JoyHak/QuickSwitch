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
    Gui, -E0x200 -SysMenu -DPIScale +AlwaysOnTop
    Gui, Color, % GuiColor, % GuiColor
    Gui, Font, % "q5 " (DarkTheme ? "c" InvertColor(GuiColor) : ""), % MainFont

    ; Edit fields: fixed width, one row, max 6 symbols, no multi-line word wrap and vertical scrollbar
    local edit := "w63 r1 -Wrap -vscroll"

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

    Gui, Add, Text,,                                                                                                Show menu after:
    Gui, Add, CheckBox,                                     vShowNoSwitch         checked%ShowNoSwitch%,            &Disabling Auto Switch
    Gui, Add, CheckBox,                                     vShowAfterSettings    checked%ShowAfterSettings%,       Leaving &settings
    Gui, Add, CheckBox,                                     vShowAfterSelect      checked%ShowAfterSelect%,         Selecting &path
    Gui, Add, CheckBox,     gToggleShowAlways               vShowAlways           checked%ShowAlways%,              Always

    Gui, Add, Text,         y+20                                                  Section,                          Auto Switch
    Gui, Add, Edit,         ys-5 w40 r1 -Wrap -vscroll      Limit2
    Gui, Add, UpDown,       Range1-99                       vAutoSwitchIndex      Section,                          %AutoSwitchIndex%
    Gui, Add, Text,         ys+5                                                  Section,                          path from
    Gui, Add, DropDownList, ys-5 w105                       vAutoSwitchTarget,                                      % StrReplace("PinnedPaths|FavoritePaths|ManagersPaths|ClipboardPaths|MenuStack", AutoSwitchTarget, AutoSwitchTarget "|")

    Gui, Add, CheckBox,     y+10 xm+15                      vAutoSwitch           checked%AutoSwitch%,              &Always Auto Switch
    Gui, Add, CheckBox,                                     vBlackListProcess     checked%BlackListProcess%,        Add process names to &Black list
    Gui, Add, CheckBox,                                     vPathNumbers          checked%PathNumbers%,             Path numbers &with shortcuts 0-9
    Gui, Add, CheckBox,                                     vDeleteDuplicates     checked%DeleteDuplicates%,        &Delete duplicate paths

    Gui, Add, Text,         y+13                                                  Section,                          &Limit of displayed paths
    Gui, Add, Edit,         ys-4  %edit% Limit4
    Gui, Add, UpDown,       Range1-9999                     vPathLimit,                                             %PathLimit%

    Gui, Tab, 2 ;────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, Add, CheckBox,           gToggleDarkTheme          vDarkTheme            checked%DarkTheme%,               Apply &dark theme
    Gui, Add, Text,         y+13                                                  Section,                          &Menu back color (HEX)
    Gui, Add, Text,         y+13,                                                                                   Settings &back color (HEX)
    Gui, Add, CheckBox,     y+13  gToggleIcons              vShowIcons            checked%ShowIcons%,               &Show icons from

    Gui, Add, Edit,         ys-6  %edit% w153 Limit8        vMenuColor,                                             %MenuColor%
    Gui, Add, Edit,         y+4   %edit% wp   Limit8        vGuiColor,                                              %GuiColor%
    Gui, Add, Edit,         y+4   %edit% w100               vIconsDir             Section,                          %IconsDir%

    Gui, Add, Edit,         ys    %edit% w40  Limit3        vIconsSizePlaceholder
    Gui, Add, UpDown,       Range1-200                      vIconsSize,                                             %IconsSize%
    Gui, Add, Edit,      xs y+40  %edit% w153               vFavoritesDir         Section,                          %FavoritesDir%

    Gui, Add, Text,         ys-20 xm+15,                                                                            Show sections in Menu:
    Gui, Add, CheckBox,     y+10  gToggleFavorites          vShowFavorites        checked%ShowFavorites%,           &Favorites from
    Gui, Add, CheckBox,                                     vShowPinned           checked%ShowPinned%,              &Pinned paths
    Gui, Add, CheckBox,                                     vShowClipboard        checked%ShowClipboard%,           Paths from &Clipboard
    Gui, Add, CheckBox,           gToggleManagersTabs       vShowManagers         checked%ShowManagers%,            Fil&e managers paths
    Gui, Add, CheckBox,     xp+20 y+10                      vActiveTabOnly        checked%ActiveTabOnly%,           only the &active tab
    Gui, Add, CheckBox,                                     vShowLockedTabs       checked%ShowLockedTabs%,          &locked tabs

    Gui, Tab, 3 ;────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, Add, Checkbox,     gToggleShortPath                vShortPath    Section checked%ShortPath%,               &Show short path, indicate as

    Gui, Add, Text,         y+13                            vPathSeparatorText,                                     Path &separator
    Gui, Add, Text,         y+13                            vDirsCountText,                                         Number of &dirs displayed
    Gui, Add, Text,         y+13                            vDirNameLengthText,                                     &Length of dir names
    Gui, Add, Checkbox,     y+20                            vShowDriveLetter        checked%ShowDriveLetter%,       Show &drive letter
    Gui, Add, Checkbox,                                     vShowFirstSeparator     checked%ShowFirstSeparator%,    Show &first separator
    Gui, Add, Checkbox,                                     vShortenEnd             checked%ShortenEnd%,            Shorten the &end

    Gui, Add, Edit,         ys-4 %edit%                     vShortNameIndicator,                                    %ShortNameIndicator%
    Gui, Add, Edit,         y+4  %edit%                     vPathSeparator,                                         %PathSeparator%

    Gui, Add, Edit,         y+4  %edit%     Limit4
    Gui, Add, UpDown,       Range1-9999                     vDirsCount,                                             %DirsCount%
    Gui, Add, Edit,         y+4  %edit%     Limit4
    Gui, Add, UpDown,       Range1-9999                     vDirNameLength,                                         %DirNameLength%

    Gui, Tab, 4 ;────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, Add, CheckBox,                                     vAutoStartup          checked%AutoStartup%,             Launch at &system startup

    Gui, Add, Text,         y+20                                                  Section,                          &Pin path holding
    Gui, Add, Text,         y+17,                                                                                   &Show menu by
    Gui, Add, Text,         y+17,                                                                                   &Restart app by
    Gui, Add, Text,         y+23,                                                                                   R&estart only in
    Gui, Add, Text,         y+13,                                                                                   &Font (GUI)
    Gui, Add, Text,         y+13,                                                                                   Icon (t&ray)
    /*
        Entering each key and the choice of one mouse button consists of two parts:
        - Hotkey control (Keyboard input mode)
        - Several mouse buttons choice controls (Mouse input mode).
        See the implementation and documentation in Lib\SettingsMouse)
    */
    ; Keyboard input controls
    edit := "w120 r1 -Wrap -vscroll"
    Gui, Add, Edit,         ys-4  %edit%    ReadOnly        vPinKey               Section                           ; Dummy for positioning
    Gui, Add, Hotkey,             %edit%                    vMainKey,                                               %MainKey%
    Gui, Add, Hotkey,             %edit%                    vRestartKey,                                            %RestartKey%

    ; Button (keybd / mouse): toggles between Keyboard / Mouse input modes
    ; Add at section Y and after Hotkey X pos
    Gui, Add, Button,       ys w22   gTogglePinMouse,                                                               mouse
    Gui, Add, Button,           wp   gToggleMainMouse       vMainMouseButton,                                       mouse
    Gui, Add, Button,           wp   gToggleRestartMouse    vRestartMouseButton,                                    mouse

    ; Non-mouse: add after previous controls at the left edge X
    Gui, Add, Edit,         xs    %edit%    w185            vRestartWhere,                                          %RestartWhere%
    Gui, Add, Edit,         y+4   %edit%    wp              vMainFont,                                              %MainFont%
    Gui, Add, Edit,         y+4   %edit%    wp              vMainIcon,                                              %MainIcon%

    ; ListBox: allows user to select the mouse buttons
    static buttons  := GetMouseList("specialList") . "|" . GetMouseList("buttonsList")
    static mouse    := GetMouseList("specialList") . "|" . GetMouseList("mouseList")

    Gui, Add, ListBox,   xs ys+25 w120 h45  gGetMouseKey    vPinMouseListBox,                                       %buttons%
    Gui, Add, ListBox,   xs ys+60 wp hp     gGetMouseKey    vMainMouseListBox,                                      %mouse%
    Gui, Add, ListBox,   xs ys+90 wp hp     gGetMouseKey    vRestartMouseListBox,                                   %mouse%

    ; Placeholder (edit): displays the mouse button selected in Listbox.
    ; Placed exactly in the position of the Hotkey and corresponds to its width and height.
    Gui, Add, Edit,         xs ys %edit%    ReadOnly        vPinMousePlaceholder,                                   %PinMousePlaceholder%
    Gui, Add, Edit,         y+8   %edit%    ReadOnly        vMainMousePlaceholder,                                  %MainMousePlaceholder%
    Gui, Add, Edit,         y+8   %edit%    ReadOnly        vRestartMousePlaceholder,                               %RestartMousePlaceholder%

    Gui, Tab, 5 ;────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Gui, Add, Text,,                                                                                                Delete from configuration:
    Gui, Add, CheckBox,     y+20                            vDeleteDialogs,                                         &Black List and Auto Switch
    Gui, Add, CheckBox,                                     vDeleteFavorites,                                       &Favorite paths
    Gui, Add, CheckBox,                                     vDeletePinned,                                          &Pinned paths
    Gui, Add, CheckBox,                                     vDeleteClipboard,                                       &Clipboard paths
    Gui, Add, CheckBox,                                     vDeleteKeys,                                            &Hotkeys and mouse buttons
    Gui, Add, CheckBox,     y+20                            vNukeSettings,                                          &Nuke configration

    Gui, Tab ; BUTTONS ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    local button := NukeSettings ? "Nuke" : "Reset"
    NukeSettings := false

    Gui, Add, Button,       w74 xm+40       Default         gSaveSettings,                                          &OK
    Gui, Add, Button,       wp x+20 yp      Cancel          gGuiEscape,                                             &Cancel
    Gui, Add, Button,       wp x+20 yp                      g%button%Settings,                                      &%button%
    Gui, Add, Button,       x+-20 ym-4                      gShowDebug,                                             &Debug

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

    ; Get dialog position
    local _pos  := ""
        , _posX := ""
        , _posY := ""
    WinGetPos, _posX, _posY,,, A

    if (_posX && _posY)
        _pos := " x" _posX " y" _posY + 100
    else
        _pos := " x0 y100"

    Gui, Show, % "AutoSize " _pos, Settings
}