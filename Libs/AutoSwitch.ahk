/*
    These options are available in the Paths Menu.
    AutoSwitch() is called each time a dialogue is opened if it is enabled.
    Depends on DialogAction variable, which is bound to each window's FingerPrint.
*/

AutoSwitch() {
    global
    IniWrite, 1, %INI%, Dialogs, %FingerPrint%
    DialogAction := 1

    FileDialog.call(DialogID, Paths[1])
}

Never() {
    global
    IniWrite, 0, %INI%, Dialogs, %FingerPrint%
    DialogAction := 0
}

ThisMenu() {
    global
    IniDelete, %INI%, Dialogs, %FingerPrint%
    DialogAction := ""
}

Dummy() {
    Return
}

