; These functions are responsible for the Context Menu functionality and its Options

Dummy() {
    return
}

SwitchPath(ByRef path, _fromMenu := "") {
    global

    local _ex, _processId, _activeId, _log := "", _windowsIds := ""
    
    loop % SelectPathAttempts {
        try {
            if FillDialog(EditId, path, SendEnter)
                return true
        } catch _ex {
            ; See CreateMenu()
            _activeId := WinGetActive()
            _windowsIds := "script: " Abs(A_ScriptHwnd) ", dialog: " Abs(DialogId) ", active: " Abs(_activeId)
                         . "`nedit field: " Abs(EditId) ", SendEnter: " SendEnter
            
            if (_activeId != A_ScriptHwnd) {
                _log .= "`n" _windowsIds
                return LogError("Active window is not a dialog"
                              , _fromMenu ? "Menu selection" : "AutoSwitch"
                              , _log, true)
            }
        
            if (A_Index = SelectPathAttempts)
                _log := _ex.what " " _ex.message " " _ex.extra "`n" _windowsIds
        }
    }

    ; If dialog owner is elevated, show error in Main
    WinGet, _processId, pid, % "ahk_id " DialogId

    if (IsAppElevated(_processId)
     || AddElevatedName(_processId))
        return false

    ; Log additional info and error details (if catched)
    return LogError("Failed to feed the file dialog"
                  , _fromMenu ? "Menu selection" : "AutoSwitch"
                  , "Timeout. " _log)
}

SelectPath(ByRef paths, _offset := 0, _fromMenu := "", _pos := 1) {
    global
    
    _pos -= _offset
    
    if (ShowPinned && GetKeyState(PinKey)) {
        if (_pos > PinnedPaths.Length())
            PinnedPaths.InsertAt(1, [paths[_pos][1], "Pin"])
        else
            PinnedPaths.RemoveAt(_pos)

        CreateMenu()
        return ShowMenu()
    }

    if IsDialogClosed
        return SendPath(paths[_pos][1])
    
    SwitchPath(paths[_pos][1], _fromMenu)
    if (ShowAlways || ShowAfterSelect)
        return ShowMenu()
}

;─────────────────────────────────────────────────────────────────────────────
;
SendPath(_path) {
;─────────────────────────────────────────────────────────────────────────────
    ; Send path to the current file manager / active window
    global DialogId
    
    WinGet, _exe, % "ProcessPath", % "ahk_id " DialogId
    WinGetClass, _class, % "ahk_id " DialogId
    
    _path := """" _path """"
    _exe  := """" _exe """"

    switch (_class) {
        case "CabinetWClass":
            SendExplorerPath(DialogId, _path)
        case "ThunderRT6FormDC":
            Run, % _exe " /feed=|::goto " _path ";|"
        case "dopus.lister":
            SplitPath, _exe,, _dir
            Run, %  """" _exeDir "\..\dopusrt.exe"" /acmd go " _path
        case "TTOTAL_CMD":
            Run, % _exe " /O /S /L=" _path
        case "Progman", "Shell_TrayWnd", "":
            ; Run in default file manager
            Run, % _path
        default:
            Run, % _exe " " _path
    }
}

IsMenuReady() {
    global
    return ShowAlways && DialogAction != -1
        || ShowNoSwitch && DialogAction = 0
        || ShowAfterSettings && FromSettings
}

ToggleAutoSwitch() {
    global

    DialogAction := (DialogAction = 1) ? 0 : 1
    FileDialogs[FingerPrint] := DialogAction
    
    ; Check only current item
    AddMenuOption("AutoSwitch", "ToggleAutoSwitch", DialogAction = 1)
    AddMenuOption("BlackList",  "ToggleBlackList",  false)
    
    if (DialogAction = 1 && %AutoSwitchTarget%.Length())
        SwitchPath(%AutoSwitchTarget%[AutoSwitchIndex][1])

    if IsMenuReady()
        ShowMenu()
    else
        SetForegroundWindow(DialogId)
}

ToggleBlackList() {
    global

    DialogAction := (DialogAction = -1) ? 0 : -1
    
    if BlackListProcess {
        ; All file dialogs, created by this process are added in the Black List
        FileDialogs[DialogProcess] := DialogAction
    } else {
        FileDialogs[FingerPrint] := DialogAction
    }
    
    ; Check only current item
    AddMenuOption("AutoSwitch", "ToggleAutoSwitch", false)
    AddMenuOption("BlackList",  "ToggleBlackList",  DialogAction = -1)

    if IsMenuReady()
        ShowMenu()
    else
        SetForegroundWindow(DialogId)
}