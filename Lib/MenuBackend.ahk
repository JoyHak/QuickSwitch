; These functions are responsible for the Context Menu functionality and its Options

Dummy() {
    Return
}

SelectPath(ByRef paths, _name := "", _pos := 1) {
    global

    local _ex, _winPid, _log := ""
    loop, % SelectPathAttempts {
        try {
            ; Called from the Menu
            if _name {
                if (ShowPinned && GetKeyState(PinKey)) {
                    if (_pos > PinnedPaths.length())
                        PinnedPaths.InsertAt(1, [paths[_pos][1], "Pin.ico", 1, ""])
                    else
                        PinnedPaths.RemoveAt(_pos)

                    WritePinnedPaths := true
                    return ShowMenu()
                }

                if IsDialogClosed
                    return SendPath(paths[_pos][1])
            }

            ; Select path
            if FillDialog(EditId, paths[_pos][1], SelectPathAttempts)
                return ((_name && ShowAfterSelect) || ShowAlways) ? ShowMenu() : 0

        } catch _ex {
            if (A_Index = SelectPathAttempts)
                _log := _ex.what " " _ex.message " " _ex.extra
        }
    }

    ; If dialog owner is elevated, show error in Main
    WinGet, _winPid, pid, % "ahk_id " DialogId

    if (IsAppElevated(_winPid)
     || AddElevatedName(_winPid)) {
        return
    }

    ; Log additional info and error details (if catched)
    LogError("Failed to feed the file dialog"
            , _name ? "Menu selection" : "Auto Switch"
            , "Timeout. " _log)
}

;─────────────────────────────────────────────────────────────────────────────
;
SendPath(path) {
;─────────────────────────────────────────────────────────────────────────────
    ; Send path to the current file manager / active window
    WinGet, _id,  % "id", % "A"
    WinGet, _exe, % "ProcessPath", % "A"
    WinGetClass, _class, % "A"
    path := """" path """"

    switch (_class) {
        case "CabinetWClass":
            SendExplorerPath(_id, path)
        case "ThunderRT6FormDC":
            Run, % _exe " /feed=|::goto " path ";|"
        case "dopus.lister":
            Run, % _exe "\..\dopusrt.exe /acmd go " path
        case "TTOTAL_CMD":
            Run, % _exe " /O /S /L=" path
        default:
            Run, % _exe " " path
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
IsMenuReady() {
;─────────────────────────────────────────────────────────────────────────────
    global

    if !WinActive("ahk_id " DialogId)
        return false

    return ((ShowAlways || ShowNoSwitch) && (DialogAction = 0))
        || (ShowAfterSettings && FromSettings)
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleAutoSwitch() {
;─────────────────────────────────────────────────────────────────────────────
    global

    DialogAction := (DialogAction = 1) ? 0 : 1
    WriteDialogAction := true

    if (DialogAction = 1)
        SelectPath(ManagersPaths)
    if IsMenuReady()
        SendInput ^#+0
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleBlackList() {
;─────────────────────────────────────────────────────────────────────────────
    global

    DialogAction := (DialogAction = -1) ? 0 : -1
    WriteDialogAction := true

    if BlackListProcess
        FingerPrint := DialogProcess

    if IsMenuReady()
       SendInput ^#+0
}