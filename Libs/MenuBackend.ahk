; These functions are responsible for the Context Menu functionality and its Options

SelectPath(_name := "", _position := 1) {
    global

    loop, 3 {
        try {
            if (!WinActive("ahk_id " DialogID) || FileDialog.call(DialogID, Paths[_position]))
                return

        } catch FeedError {
            if (A_Index = 3)
                LogError(Exception("Failed to feed the file dialog", FileDialog.name, FeedError.what " " FeedError.message " " FeedError.extra))
        }
    }
}

Dummy() {
    Return
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleAutoSwitch() {
;─────────────────────────────────────────────────────────────────────────────
    global

    DialogAction := !DialogAction
    IniWrite, % DialogAction, % INI, Dialogs, % FingerPrint

    if DialogAction
        SelectPath()
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleBlackList() {
;─────────────────────────────────────────────────────────────────────────────
    global

    DialogAction := (DialogAction = -1) ? 0 : -1
    IniWrite, % DialogAction, % INI, Dialogs, % FingerPrint
}