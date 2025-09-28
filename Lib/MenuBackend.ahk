; These functions are responsible for the Context Menu functionality and its Options

Dummy() {
    return
}

SwitchPath(ByRef path, _fromMenu := "") {
    global

    local _ex, _winPid, _log := ""
    loop % SelectPathAttempts {
        try {
            if FillDialog(EditId, path, SelectPathAttempts)
                return true

        } catch _ex {
            if !WinActive("ahk_id " DialogId)
                return false
        
            if (A_Index = SelectPathAttempts)
                _log := _ex.what " " _ex.message " " _ex.extra
        }
    }

    ; If dialog owner is elevated, show error in Main
    WinGet, _winPid, pid, % "ahk_id " DialogId

    if (IsAppElevated(_winPid)
     || AddElevatedName(_winPid))
        return false

    ; Log additional info and error details (if catched)
    return LogError("Failed to feed the file dialog"
                  , _fromMenu ? "Menu selection" : "AutoSwitch"
                  , "Timeout. " _log)
}

SelectPath(ByRef paths, _fromMenu := "", _pos := 1) {
    global
    
    if (ShowPinned && GetKeyState(PinKey)) {
        if (_pos > PinnedPaths.Length())
            PinnedPaths.InsertAt(1, [paths[_pos][1], "Pin.ico", 1, ""])
        else
            PinnedPaths.RemoveAt(_pos)

        WritePinnedPaths := true
        return CreateMenu()
    }

    if IsDialogClosed
        return SendPath(paths[_pos][1])
    
    SwitchPath(paths[_pos][1], _fromMenu)
    if (ShowAlways || ShowAfterSelect)
        ShowMenu()
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
    return ShowAlways && DialogAction != -1
        || ShowNoSwitch && DialogAction = 0
        || ShowAfterSettings && FromSettings
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleAutoSwitch() {
;─────────────────────────────────────────────────────────────────────────────
    global

    DialogAction := (DialogAction = 1) ? 0 : 1
    WriteDialogAction := true
    AddMenuOption("AutoSwitch", "ToggleAutoSwitch", DialogAction = 1)
    
    if (DialogAction = 1)
        SwitchPath(ManagersPaths[1][1])

    if IsMenuReady()
        ShowMenu()
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleBlackList() {
;─────────────────────────────────────────────────────────────────────────────
    global

    DialogAction := (DialogAction = -1) ? 0 : -1
    WriteDialogAction := true
    AddMenuOption("BlackList", "ToggleBlackList", DialogAction = -1)
    
    if BlackListProcess
        FingerPrint := DialogProcess

    if IsMenuReady()
       ShowMenu()
}