## Settings

>  User Interface, that allows to change app behavior

### Options text

#### Menu

>  Menu display behavior; menu options behavior

Show menu after: *[menu display behavior]*

- Disabling Auto Switch *[after diasbling Automatic Path Switching menu option]*
- Leaving settings *[after closing Settings window]*
- Selecting path *[after path was selected by user and successfully switched]*
- Always *[always display menu]*

Auto Switch `%AutoSwitchIndex%` path from `[..]` *[Automatic Switch by index from source]*

Always Auto Switch

Add file dialog owner process name to Black List *[exclude all future dialogs from current application behind the menu]*

Close old-style file dialog after switching path *[sends Enter to legacy file dialog]*

Select filename after switching path *[sends Ctrl+A to the file dialog]*

Show paths numbers and switch them with keys 0-9 *[show index before path]*

Delete duplicate paths *[remove equal paths from menu]*

Limit of displayed paths `integer` *[maximum visible paths]*

#### Theme

>  Colors; visible sections in the menu

Apply dark theme *[dark colors for settings window and menu]*

Menu color (HEX) *[hexadecimal color input]*

Settings color (HEX) *[hexadecimal color input]*

Menu font *[string font name input]*

Settings font *[string font name input]*

Show icons from *[path to the icons directory]*

Show sections in Menu: *[add group of paths to the menu]*

- Favorites from *[path to the directory with \*.lnk bookmarks, created by user]*

- Pinned paths *[paths placed on top by user click/keyboard shortcut]*

  - Pin path by *[hotkey to pin the path]*

- Paths from Clipboard *[copied paths, placed into the Window Clipboard]*

  - invidiual for each file dialog *[each file dialog stores it's own set of copied paths]*

  - reset after opening another file dialog *[app stores exactly one set of copied paths for each dialog]*

- File managers paths *[paths from file managers]*

  - only from `%ListerIndex%` lister (Z-order)

  >  Display paths from specific window by it's Z-order index, where 1 = active window, 2 = last active window; lister means "window with paths/tabs list"

  - from all virtual desktops *[additional separate desktop with it's own windows]*
  - only from active pane *[part of the file manager window that contains tabs or paths]*
  - only the active tab *[active path in the each file manager]*
  - show locked tabs *[tab that restricts path changing, i.e. pinned tab]*

- Menu history *[previous paths, displayed in the menu]*

- File managers history *[previous paths from file managers]*

#### Short path

>  Each path can be truncated to the specified amount of directories, separated by set of characters: ~user, Windows/System32, ../parent

Show short path, indicate as `string` *[..\ ~\ etc. - set of characters]*

Path separator `string` *[set of characters between each directory in path]*

Number of dirs displayed `integer` *[maxiumum directories in the visible path]*

Length of dir names `integer` *[maxiumum length of each directory in the path]*

Show drive letter `bool` *[C, D - drive letter at the beginnig]*

Show first separator `bool` *[..\ ~\ etc. - set of characters at the beginnig]*

Shorten the end `bool` *[truncation and dirs count starts from the end, not beginning]*

#### App

>  QuickSwitch-specific values; global values

Launch at system startup *[launch application after log in]*

Pin path (hold and click) *[hotkey to pin the path]*

Show menu in dialog *[hotkey to show the menu in file dialog]*

Show menu everywhere *[hotkey to show the menu in any application/desktop]*

Restart app by *[hotkey to restart application]*

Restart only in *[window title, handle, process ID - window criterion]*

Icon (tray) *[path to the tray icon]*

mouse *[mouse selection button]*

keybd *[hotkey input button]*

Show Menu after restart *[display menu after restart]*

Show settings after restart *[display settings window after restart]*

Open last settings tab after restart *[open last tab in the settings window after restart]*

Save settings window position *[save settings coordinates, display settings at this coord.]*

Open "Open" dialog before Menu *[display "open" file dialog before menu appears]*

Open "Save As" dialog before Menu *[display "save as" file dialog before menu appears]*

#### Reset

>  Clean, delete values, sections and settings

Delete from configuration: *[delete values below from \*.ini file]*

- Black List and Auto Switch *[delete black list and automatic switch values]*
- Favorite paths *[delete \*.lnk shortcucts from specific dir.]*
- Pinned paths *[delete pinned paths from the menu]*
- Clipboard paths *[cleanup clipboard]*
- Hotkeys and mouse buttons *[unregister hotkeys and mouse hooks]*
- Nuke configuration *[remove \*.ini file]*

### Tooltips

>  Smal help windows, displayed under mouse cursor after pointing at specific option above

Menu display behavior

Show menu if AutoSwitch is disabled

Show menu after leaving the Settings window

Show menu again if the path was successfully switched

Always show menu

AutoSwitch by path index from specified Menu section

- path index, counting from the top

- tab number, starting with the active tab

- path from the menu (if not empty)

- special path (if enabled)

Always Switch path after opening file dialog

Don't show the Menu in file dialogs, created by current application behind the Settings

Send Enter to legacy file dialog

Send Ctrl+A to the file dialog

Show index for each path. Enable the ability to switch the path by pressing a number on the keyboard

Remove duplicate paths from all Menu sections

Maximum amount of visible paths in the Menu

Dark colors for Settings window and Menu

Hexadecimal color value: RRGGBB, 0xRRGGBB or #RRGGBB

Name of the font

Path to the directory with \.ico whose names match name of the icons in the release archive

Enable special paths in the Menu

- Enable bookmarks (\.lnk shortcuts)

  - Path to the directory with \.lnk shortcuts

- Enable the ability to pin paths (and place them at the top)

  - A key or shortcut to hold down that pins the path

Copied paths, placed into the Clipboard

- For each file dialog, a separate set of copied paths will be collected and displayed
- Delete copied paths and start collecting again after opening a file dialog in another application

Paths from file managers

- Show paths from specific window by it's Z-order index, where 0 = all windows, 1 = active window, 2 = last active window, and so on. Indiviual for each file manager.

- 0 = all windows, 1 = active window, 2 = last active window, and so on *[separate tooltip for number input]*

- Include paths from all desktops (if Z-order index is 0)

- Show only the active path in the each file manager

- Show only paths from the "active" part of the window that contains tabs

- Include tabs that restricts path changing (pinned tabs)

Previous paths, included in the Menu earlier

Previous paths from file managers (history is individual for each file manager!)

Each path can be truncated to the specified amount of directories, separated by set of characters (string)

String that symbolizes a truncated path

String between each directory in the path

Maxiumum amount of directories in the path

Maxiumum length of each directory in the path

Include drive letter at the beginnig

String between each directory in the path must be displayed at the beginnig too

Truncation and dir. count starts from the end, not the beginning

Launch application automatically after log in

Hotkey to show the Menu in the active file dialog

Hotkey to show the menu in any application

Hotkey to restart application

Path to the icon file, that will be displayed in the tray menu

Save settings coordinates, display settings at this coord. later

Delete values below from \*.ini file

Delete BlackList and AutoSwitch values for all file dialogs

Delete all .lnk shortcucts from specified Favorites directory

Delete pinned paths from the Menu

Delete copied paths from the Menu

Unregister hotkeys and mouse buttons

Delete .ini file with all values, stored by this Settings window

Reset all values in .ini file to their defaults

Save all values to the .ini file

Close window and don't change anything

Display a help window with all available settings description

## Menu

>  Context menu that allows to change file dialog path

### Options

- AutoSwitch *[automatically switch the path after file dialog becomes focused]*

> alternatives: automatic switch, automatic changing, auto-set path

- BlackList *[exclude current file dialog from menu auto-display]*

> alternatives: add to exclusions, hide menu here, ignore this dialog

- SelectAndWait *[send path to the file dialog, do not send Enter to "switch" it]*

> alternatives: send and do nothing, selection inserts path, insert and show menu again

- SwitchAndClose *[send path to the file dialog, send Enter, close file dialog]*

> alternatives: Enter closes dialog, Send and close, close on selection, terminate after switching, hide after path was changed

- Send path, open new instance *[open new file manager window with selected path]*
- Settings *[open UI to change values]*

### Messages

>  Help messages at the top of the menu

No available paths

Open any file manager first

Restart as administrator

Close locked tabs

Close special tabs like 'This PC'

Make sure the icon directory exists

Hold `%key%` and click on any path to pin it

Create .lnk in `%favoritesDir%` dir to make it favorite

All file dialogs are excluded

### Tips

>  Smal hints, displayed immediately after path or option in the menu

*AutoSwitch* Always is On / Only here

*BlackList* all dialogs / only this

*SelectAndWait* switch path / insert path

*SwitchAndClose* file dialog / stay open

Click `%key%` to pin
