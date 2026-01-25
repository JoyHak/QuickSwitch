; Contains functions for interacting with windows

CloseChildWindows(ByRef processId, ByRef excludeWinId := 0) {
    ; Closes child windows of the specified process except main window with winId

    WinGet, _childs, % "list", % "ahk_pid " processId
    Loop, % _childs {
        _winId := _childs%A_Index%
        if (_winId != excludeWinId)
            WinClose % "ahk_id " _winId
    }
}

WinMoveBottom(_winId) {
    ; Moves the specified window to the bottom of stack (beneath all other windows)
    ; https://github.com/AutoHotkey/AutoHotkey/blob/a34bc07d357b7299ca229757162cef8a91e37f52/source/lib/win.cpp#L1598
    
    static SWP_NOACTIVATE := 0x0010
    static SWP_NOSIZE  := 0x0001
    static SWP_NOMOVE  := 0x0002
    static HWND_BOTTOM := 1
    
    if !DllCall("SetWindowPos"
        , "ptr", _winId
        , "ptr", HWND_BOTTOM
        , "int", 0, "int", 0, "int", 0, "int", 0
        , "uint", SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE
        , "int") {
            WinGetClass, _class, % "ahk_id " _winId
            
            throw Exception(Format("Unable to move {} ({}) to the bottom", _class, _winId)
            , "SetWindowPos"
            , "Last error: " A_LastError)
    }
    return true
}

;─────────────────────────────────────────────────────────────────────────────
;
SetForegroundWindow(_winId) {
;─────────────────────────────────────────────────────────────────────────────
    /*
    FuPeiJiang: moves the specified window to the top of stack and activates it.
    Based on SetForegroundWindow():
    https://github.com/FuPeiJiang/VD.ahk/blob/235fedf6833d2b7d532ba9da1ff1c53e8ecfb7dd/VD.ahk#L435
    Inspired by AttemptSetForeground() and SetForegroundWindowEx() and :
    https://github.com/AutoHotkey/AutoHotkey/blob/d21b7f538f4273a871e248be26a92bd6f8622cda/source/window.cpp#L88
    */
    
    _oldWinId := DllCall("GetForegroundWindow")
    if (_winId = _oldWinId)
        return _winId
    
    if (DllCall("AllowSetForegroundWindow", "Uint", DllCall("GetCurrentProcessId"))  
     && DllCall("SetForegroundWindow", "Ptr", _winId)) {        
        return _winId
    }

    LCtrlDown := GetKeyState("LCtrl")
    RCtrlDown := GetKeyState("RCtrl")
    LShiftDown := GetKeyState("LShift")
    RShiftDown := GetKeyState("RShift")
    LWinDown := GetKeyState("LWin")
    RWinDown := GetKeyState("RWin")
    LAltDown := GetKeyState("LAlt")
    RAltDown := GetKeyState("RAlt")
    if ((LCtrlDown || RCtrlDown) && (LWinDown || RWinDown)) {
        toRelease := ""
        if (LShiftDown) {
            toRelease .= "{LShift Up}"
        }
        if (RShiftDown) {
            toRelease .= "{RShift Up}"
        }
        if (toRelease) {
            Send % "{Blind}" toRelease
        }
    }
    BlockInput % "On"
    Send % "{LAlt Down}{LAlt Down}"
    DllCall("SetForegroundWindow", "Ptr", _winId)
    toAppend := ""
    if (!LAltDown) {
        toAppend .= "{LAlt Up}"
    }
    if (RAltDown) {
        toAppend .= "{RAlt Down}"
    }
    if (LCtrlDown) {
        toAppend .= "{LCtrl Down}"
    }
    if (RCtrlDown) {
        toAppend .= "{RCtrl Down}"
    }
    if (LShiftDown) {
        toAppend .= "{LShift Down}"
    }
    if (RShiftDown) {
        toAppend .= "{RShift Down}"
    }
    if (LWinDown) {
        toAppend .= "{LWin Down}"
    }
    if (RWinDown) {
        toAppend .= "{RWin Down}"
    }
    if (toAppend) {
        Send % "{Blind}" toAppend
    }
    BlockInput % "Off"
    
    _newWinId := DllCall("GetForegroundWindow")
    if (_winId = _newWinId)
        return _winId
    
    _ownerId := DllCall("GetWindow", "ptr", _winId, "uint", 4)
    if (_newWinId != _oldWinId && _winId = _ownerId)
        return _newWinId
    
    return false
}
