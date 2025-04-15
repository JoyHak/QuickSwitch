/*
    These options are available in the Paths Menu.
    AutoSwitch() is called each time a dialogue is opened if it is enabled.
    Depends on DialogAction variable, which is bound to each window's FingerPrint.
*/

ToggleBlackList() {
    global

    DialogAction := (DialogAction = -1) ? 0 : -1
    IniWrite, % DialogAction, % INI, Dialogs, % FingerPrint
}

ToggleAutoSwitch() {
    global

    DialogAction := !DialogAction
    IniWrite, % DialogAction, % INI, Dialogs, % FingerPrint

    if DialogAction
        AutoSwitch()
}

AutoSwitch() {
    global
    FileDialog.call(DialogID, Paths[1])
}

Dummy() {
    Return
}

