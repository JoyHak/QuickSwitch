; These functions are responsible for the Context Menu functionality and its Options

SelectPath() {
    ; The path is bound to the position of the menu item
    global
    FileDialog.call(DialogID, Paths[A_ThisMenuItemPos])
}

AutoSwitch() {
    global
    FileDialog.call(DialogID, Paths[1])
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
        AutoSwitch()
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleBlackList() {
;─────────────────────────────────────────────────────────────────────────────
    global

    DialogAction := (DialogAction = -1) ? 0 : -1
    IniWrite, % DialogAction, % INI, Dialogs, % FingerPrint
}