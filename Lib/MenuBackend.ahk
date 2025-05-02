; These functions are responsible for the Context Menu functionality and its Options

Dummy() {
    Return
}

SelectPath(_name := "", _position := 1) {
    global

    local _extra := ""
    loop, 3 {
        try {
            WinActivate % "ahk_id " DialogID
            if !WinActive("ahk_id " DialogID)
                return

            if !(FileDialog.call(Paths[_position]))
                continue

            if ((ShowAfterSelect && _name) || ShowAlways)
                return ShowMenu()

            return

        } catch FeedError {
            if (A_Index = 3)
                _extra .= FileDialog.name ": " FeedError.what " " FeedError.message " " FeedError.extra
        }
    }

    _extra .= " Timeout."
    local _message := _name ? "Menu selection" : "Auto Switch"
    LogError(Exception("Failed to feed the file dialog", _message, _extra))
}

;─────────────────────────────────────────────────────────────────────────────
;
IsMenuReady() {
;─────────────────────────────────────────────────────────────────────────────
    global

    return ( WinActive("ahk_id " DialogID)
        && ( ((ShowNoSwitch || ShowAlways)
            && (DialogAction = 0))
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