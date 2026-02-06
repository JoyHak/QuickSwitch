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
SetForegroundWindow(ByRef winId) {
;─────────────────────────────────────────────────────────────────────────────
    /*
    FuPeiJiang: moves the specified window to the top of stack and activates it.
    Based on SetForegroundWindow():
    https://github.com/FuPeiJiang/VD.ahk/blob/235fedf6833d2b7d532ba9da1ff1c53e8ecfb7dd/VD.ahk#L435
    Inspired by AttemptSetForeground() and SetForegroundWindowEx() and :
    https://github.com/AutoHotkey/AutoHotkey/blob/d21b7f538f4273a871e248be26a92bd6f8622cda/source/window.cpp#L88
    */
    
    _oldWinId := DllCall("GetForegroundWindow", "Ptr")
    if (winId = _oldWinId)
        return winId
    
    static processId := DllCall("GetCurrentProcessId")
    if (DllCall("AllowSetForegroundWindow", "UInt", processId)  
     && DllCall("SetForegroundWindow", "Ptr", winId)) {        
        return winId
    }
    
    _LCtrlDown  :=  GetKeyState("LCtrl")
    _RCtrlDown  :=  GetKeyState("RCtrl")
    _LShiftDown :=  GetKeyState("LShift")
    _RShiftDown :=  GetKeyState("RShift")
    _LWinDown   :=  GetKeyState("LWin")
    _RWinDown   :=  GetKeyState("RWin")
    _LAltDown   :=  GetKeyState("LAlt")
    _RAltDown   :=  GetKeyState("RAlt")
    
    if ((_LCtrlDown || _RCtrlDown) 
     && (_LWinDown  || _RWinDown)) {
        _toRelease := ""
        if _LShiftDown
            _toRelease .= "{LShift Up}"
        if _RShiftDown
            _toRelease .= "{RShift Up}" 
            
        if _toRelease
            Send % "{Blind}" _toRelease
    }
    
    BlockInput % "On"
    Send % "{LAlt Down}{LAlt Down}"
    DllCall("SetForegroundWindow", "Ptr", winId)
    
    _toAppend := ""
    if !_LAltDown
        _toAppend .= "{LAlt Up}"
    if _RAltDown
        _toAppend .= "{RAlt Down}"    
    if _LCtrlDown
        _toAppend .= "{LCtrl Down}"    
    if _RCtrlDown
        _toAppend .= "{RCtrl Down}"    
    if _LShiftDown
        _toAppend .= "{LShift Down}"    
    if _RShiftDown 
        _toAppend .= "{RShift Down}"    
    if _LWinDown 
        _toAppend .= "{LWin Down}"    
    if _RWinDown 
        _toAppend .= "{RWin Down}"    
        
    if _toAppend 
        Send % "{Blind}" _toAppend
    
    BlockInput % "Off"
    
    _newWinId := DllCall("GetForegroundWindow", "Ptr")
    if (winId = _newWinId)
        return winId
    
    _ownerId := DllCall("GetWindow", "Ptr", winId, "UInt", 4)
    if (_newWinId != _oldWinId && winId = _ownerId)
        return _newWinId
    
    return false
}
