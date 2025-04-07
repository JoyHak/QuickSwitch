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

;─────────────────────────────────────────────────────────────────────────────
;
GetFileDialog(ByRef dialogId) {
;─────────────────────────────────────────────────────────────────────────────
    ; Detection of a File dialog by checking specific controls existence. 
    ; Returns FuncObj if required controls found,
    ; otherwise returns false
    
    try {      
        _edit := _listView := _treeView := _header := _toolbar := _directUI := 0
     
        try ControlGet, _edit,      Hwnd,,  Edit1,             ahk_id %dialogId%
        try ControlGet, _listView,  Hwnd,,  SysListView321,    ahk_id %dialogId%
        try ControlGet, _treeView,  Hwnd,,  SysTreeView321,    ahk_id %dialogId%
        try ControlGet, _header,    Hwnd,,  SysHeader321,      ahk_id %dialogId%
        try ControlGet, _toolbar,   Hwnd,,  ToolbarWindow321,  ahk_id %dialogId%
        try ControlGet, _directUI,  Hwnd,,  DirectUIHWND1,     ahk_id %dialogId%

        if (_edit && _toolbar && _directUI)
            return Func("FeedDialogSYSTREEVIEW")
        if (_listView && _toolbar && _header)
            return Func("FeedDialogSYSTREEVIEW")
        if (_listView && _toolbar)
            return Func("FeedDialogSYSLISTVIEW")
        if (_listView && _header)
            return Func("FeedDialogSYSLISTVIEW")

    } catch _error {
        LogError(_error)
    }
    return false
}