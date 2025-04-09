/*
    There are a few different types of possible dialogues, and each one has its own function.
    There's also a function called GetFileDialog()
    It returns the FuncObj to call it later and feed the current dialogue.
*/

FeedEditField(ByRef winId, ByRef content, ByRef attempts := 10) {
    Loop, %attempts% {
        ControlSetText, Edit1, %content%, ahk_id %winId%       ; set
        sleep, 15
        ControlGetText, _editContent, Edit1, ahk_id %winId%    ; check
        if (_editContent == content)
            return true
    }
    return false
}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogSYSTREEVIEW(ByRef winId, ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    WinActivate, ahk_id %winId%

    ; Read the current text in the "File Name"
    ControlGetText _editOld, Edit1, ahk_id %winId%

    ; Make sure there exactly one slash at the end.
    path := RTrim(path , "\") . "\"

    if FeedEditField(winId, path) {
        ; Restore original filename
        ; or make empty in case of previous path
        ControlSend Edit1, {Enter}, ahk_id %winId%

        sleep, 20
        ControlFocus Edit1, ahk_id %winId%
        sleep, 20

        FeedEditField(winId, _editOld)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
FeedDialogSYSLISTVIEW(ByRef winId, ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    WinActivate, ahk_id %winId%

    ; Read the current text in the "File Name"
    ControlGetText _editOld, Edit1, ahk_id %winId%

    ; Make sure there exactly one slash at the end.
    path := RTrim(path , "\") . "\"

    ; Make sure no element is preselected in listview,
    ; it would always be used later on if you continue with {Enter}!
    Loop, 100 {
        Sleep, 15
        ControlFocus SysListView321, ahk_id %winId%
        ControlGetFocus, _focus, ahk_id %winId%

    } Until (_focus == "SysListView321")

    ControlSend SysListView321, {Home}, ahk_id %winId%

    Loop, 100 {
        Sleep, 15
        ControlSend SysListView321, ^{Space}, ahk_id %winId%
        ControlGet, _focus, List, Selected, SysListView321, ahk_id %winId%

    } Until !_focus

    if FeedEditField(winId, path) {
        ; Restore original filename
        ; or make empty in case of previous path
        ControlSend Edit1, {Enter}, ahk_id %winId%

        sleep, 15
        ControlFocus Edit1, ahk_id %winId%
        sleep, 15

        FeedEditField(winId, _editOld)
    }
}

FindControls(_winId, _classes, _flag := 0) {
    ; Recursive search for all controls from the specified array
    ; that contains win32 / custom class names without instance number (Class != ClassNN).    
    ; Returns bitwise flag where each bit represents the presence of a control from the array.
        
    ; Search in the current window using FindWindowEx():
    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowexa

    for _index, _class in _classes {
        if (_class && DllCall("FindWindowEx", "ptr", _winId, "ptr", 0, "str", _class, "ptr", 0)) {
            _flag |= 1 << (_index - 1)
            _classes[_index] := ""
        }
    }

    ; Search in child windows
    _child := DllCall("FindWindowEx", "ptr", _winId, "ptr", 0, "ptr", 0, "ptr", 0)
    while (_child) {
        _flag  := FindControls(_child, _classes, _flag)
        _child := DllCall("GetWindow", "ptr", _child, "uint", 2)  ; GW_HWNDNEXT 
    }

    return _flag
}

;─────────────────────────────────────────────────────────────────────────────
;
GetFileDialog(ByRef dialogId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Detection of a File dialog by checking specific controls existence.
    ; Returns FuncObj if required controls found,
    ; otherwise returns false
    static classes := ["Edit", "SysListView32", "SysTreeView32", "SysHeader32", "ToolbarWindow32", "DirectUIHWND"]
    
    try {
        ; Not a dialog
        if !DllCall("FindWindowEx", "ptr", dialogId, "ptr", 0, "str", "Button", "ptr", 0)
            return false
        
        if (_f := FindControls(dialogId, classes)) {
            MsgBox % _f
        
        }
        
    } catch _error {
        LogError(_error)
    }
    return false
}