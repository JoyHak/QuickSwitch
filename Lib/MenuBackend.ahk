; These functions are responsible for the Context Menu functionality and its Options

Dummy() {
    Return
}

SelectPath(_name := "", _position := 1) {
    global

    loop, 3 {
        try {
            if (!WinActive("ahk_id " DialogID) || FileDialog.call(DialogID, Paths[_position])) {
                if (ShowAfterSelect || ShowAlways)
                    ShowMenu()
            
                return
            }

        } catch FeedError {
            if (A_Index = 3)
                LogError(Exception("Failed to feed the file dialog", FileDialog.name, FeedError.what " " FeedError.message " " FeedError.extra))
        }
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
isMenuReady() {
;─────────────────────────────────────────────────────────────────────────────
    global
    
    return ( WinActive("ahk_id " DialogID) 
            && ( (ShowNoSwitch && (DialogAction = 0)) 
                 || (ShowAfterSettings && FromSettings) 
                 || ShowAlways) ) 
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleAutoSwitch() {
;─────────────────────────────────────────────────────────────────────────────
    global

    DialogAction := (DialogAction = 1) ? 0 : 1
    IniWrite, % DialogAction, % INI, Dialogs, % FingerPrint

    if (DialogAction = 1)
        SelectPath()
    else if isMenuReady()
        ShowMenu()
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleBlackList() {
;─────────────────────────────────────────────────────────────────────────────
    global

    DialogAction := (DialogAction = -1) ? 0 : -1
    IniWrite, % DialogAction, % INI, Dialogs, % FingerPrint
    Menu ContextMenu, ToggleCheck, &Black list
    
    if isMenuReady()
        ShowMenu()
}