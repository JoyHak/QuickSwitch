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
    
    if FeedEditField(winId, path) {
        ; Restore original filename 
        ; or make empty in case of previous path
        sleep, 20
        ControlFocus Edit1, ahk_id %winId%
        sleep, 20
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
        sleep, 20
        ControlFocus Edit1, ahk_id %winId%
        sleep, 20
        ControlSend Edit1, {Enter}, ahk_id %winId%
        
        sleep, 20
        ControlFocus Edit1, ahk_id %winId%
        sleep, 20
        
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

        ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowexw
        if DllCall("FindWindowExW", "ptr", dialogId, "int", 0, "str", "Button", "int", 0) {
            
            ; Dialog with buttons
            ; Get specific controls
            WinGet, _controlList, ControlList, ahk_id %dialogId%
            
            ; Search for...
            static classes := {Edit1: 0x1, SysListView321: 0x2, SysTreeView321: 0x4, SysHeader321: 0x8, ToolbarWindow321: 0x10, DirectUIHWND1: 0x20} 
            _classes := classes.clone()
            
            ; Find controls and set bitwise flag
            _f := 0
            Loop, Parse, _controlList, `n
            {   
                _class := _classes[A_LoopField]
                if _class {
                    _f |= _class
                    _classes.delete(A_LoopField)
                }
            }
       
            ; Check specific controls
            if (_f & 0x1) {
                if (_f & 0x10 && _f & 0x20)
                    return Func("FeedDialogSYSTREEVIEW")
                    
                if (_f & 0x2) {
                    if (_f & 0x8) {
                        if (_f & 0x10) {
                            return Func("FeedDialogSYSTREEVIEW")                        
                        }
                        return Func("FeedDialogSYSLISTVIEW")
                    }
                    if (_f & 0x10) {
                        return Func("FeedDialogSYSLISTVIEW")
                    }
                }
                
                if (_f & 0x4)
                    return Func("FeedEditField")
            }
        }
        
    } catch _error {
        LogError(_error)
    }
    return false
}