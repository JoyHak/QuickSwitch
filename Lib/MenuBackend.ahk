; These functions are responsible for the Context Menu functionality and its Options

Dummy() {
    Return
}

SelectPath(_showMenu := false, _name := "", _position := 1) {
    global DialogID, FileDialog, Paths
    
    _extra := ""
    loop, 3 {
        try {
            WinActivate % "ahk_id " DialogID
            if !WinActive("ahk_id " DialogID)
                return

            if (FileDialog.call(Paths[_position]))                    
                return _showMenu ? ShowMenu() : 0

        } catch _e {
            if (A_Index = 3)
                _extra .= _e.name ": " _e.what " " _e.message " " _e.extra
        }
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

    return ( WinActive("ahk_id " DialogID)
        && ( ShowAlways
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