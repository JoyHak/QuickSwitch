; These functions are responsible for the Context Menu functionality and its Options

Dummy() {
    Return
}

SelectPath(_showMenu := false, _attempts := 3, _name := "", _position := 1) {
    global DialogId, FileDialog, Paths, ElevatedApps

    _log := ""
    loop, % _attempts {
        try {
            if !WinActive("ahk_id " DialogId)
                return

            if (FileDialog.call(Paths[_position]), _attempts)
                return _showMenu ? ShowMenu() : 0

        } catch _ex {
            if (A_Index = _attempts)
                _log := _ex.what " " _ex.message " " _ex.extra
        }
    }

    ; If dialog owner is elevated, show error in Main
    WinGet, _winPid, pid, % "ahk_id " DialogId

    if (IsAppElevated(_winPid, ElevatedApps)
     || AddElevatedName(_winPid, ElevatedApps)) {
        return
    }

    ; Log additional info and error details (if catched)
    _log  :=  FileDialog.name ": Timeout. " _log
    _msg  :=  _name ? "Menu selection" : "Auto Switch"

    LogError("Failed to feed the file dialog", _msg, _log)
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
        SendEvent ^#+0
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleBlackList() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogAction, SaveDialogAction

    DialogAction     := (DialogAction = -1) ? 0 : -1
    SaveDialogAction := true

    if IsMenuReady()
       SendEvent ^#+0
}