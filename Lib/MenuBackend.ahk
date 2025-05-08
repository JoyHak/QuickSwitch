; These functions are responsible for the Context Menu functionality and its Options

Dummy() {
    Return
}

SelectPath(_showMenu := false, _name := "", _position := 1) {
    global DialogId, FileDialog, Paths, ElevatedApps

    _extra := FileDialog.name ": "
    loop, 3 {
        try {
            if !WinActive("ahk_id " DialogId)
                return

            if (FileDialog.call(Paths[_position]))
                return _showMenu ? ShowMenu() : 0

        } catch _e {
            if (A_Index = 3)
                _extra .= _e.what " " _e.message " " _e.extra
        }
    }

    ; If dialog owner is elevated, show error in Main
    WinGet, _winPid, pid, % "ahk_id " DialogId

    if (IsAppElevated(_winPid, ElevatedApps)
     || AddElevatedName(_winPid, ElevatedApps)) {
        return
    }

    _extra   .= " Timeout."
    _message := _name ? "Menu selection" : "Auto Switch"

    LogError(Exception("Failed to feed the file dialog", _message, _extra))
}

;─────────────────────────────────────────────────────────────────────────────
;
IsMenuReady() {
;─────────────────────────────────────────────────────────────────────────────
    global

    return ( WinActive("ahk_id " DialogId)
        && ( (ShowAlways && (DialogAction != -1))
          || (ShowNoSwitch && (DialogAction = 0))
          || (ShowAfterSettings && FromSettings) ) )
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleAutoSwitch() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogAction, SaveDialogAction

    DialogAction     := (DialogAction = 1) ? 0 : 1
    SaveDialogAction := true

    if (DialogAction = 1)
        SelectPath()
    if IsMenuReady()
        ShowMenu()
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleBlackList() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogAction, SaveDialogAction

    DialogAction     := (DialogAction = -1) ? 0 : -1
    SaveDialogAction := true

    if IsMenuReady()
        ShowMenu()
}