/* 
    These options are available in the folder menu. 
    AutoSwitch() is called each time a dialogue is opened if it is enabled.
    Their result is the value of the DialogAction variable, which is bound to each window's FingerPrint.
*/

AutoSwitch() {
    global
    IniWrite, 1, %INI%, Dialogs, %FingerPrint%
    DialogAction := 1

    ; ID and FuncObj FeedDialog declared in ShowFolderPaths()
    FeedDialog.call(DialogID, paths[1])
    LastMenuItem := A_ThisMenuItem

    Return
}

Never() {
    global 
    IniWrite, 0, %INI%, Dialogs, %FingerPrint%
    DialogAction := 0
    LastMenuItem := A_ThisMenuItem

    Return
}

ThisMenu() {
    global
    IniDelete, %INI%, Dialogs, %FingerPrint%
    DialogAction := ""
    LastMenuItem := A_ThisMenuItem

    Return
}

Dummy() {
    Return
}

