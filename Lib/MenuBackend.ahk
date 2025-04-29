; These functions are responsible for the Context Menu functionality and its Options

Dummy() {
    Return
}

SelectPath(_name := "", _position := 1) {
    global

    local _extra := ""
    loop, 3 {
        try {
            if !WinActive("ahk_id " DialogID)
                return

            if !(FileDialog.call(DialogID, Paths[_position]))
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
isMenuReady() {
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
    global DialogAction
    DialogAction := (DialogAction = 1) ? 0 : 1

    if (DialogAction = 1)
        SelectPath()
    if isMenuReady()
        ShowMenu()
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleBlackList() {
;─────────────────────────────────────────────────────────────────────────────
    global DialogAction
    DialogAction := (DialogAction = -1) ? 0 : -1

    if isMenuReady()
        ShowMenu()
}