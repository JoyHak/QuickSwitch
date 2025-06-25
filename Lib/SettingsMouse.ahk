/* 
    Contains functions for selecting mouse buttons in the GUI.
    Toggles between keyboard and mouse input modes (GUI).
*/

InitMouseMode(_control, toggle, _text := "") {
    GuiControl,, % _control, % (toggle ? "keybd" : "mouse")
    GuiControlGet, name, name , % _control
    name := StrReplace(name, "MouseButton")

    if _text
        GuiControl,, %name%KeyPlaceholder, % _text
    
    GuiControl, Hide%toggle%, %name%Key
    GuiControl, Show%toggle%, %name%KeyPlaceholder
    GuiControl, Hide,         %name%Mouse
}

ToggleMainMouse(_control := 0) {
    static toggle := false
    toggle := !toggle
    InitMouseMode(_control, toggle)
    
    ; Mouse button selection mode 
    GuiControl, Show%toggle%, MainMouse
    GuiControl, Hide%toggle%, MainKey
    GuiControl, Hide%toggle%, RestartKey 
    GuiControl, Hide%toggle%, RestartKeyPlaceholder    
}

ToggleRestartMouse(_control := 0) {
    static toggle := false
    toggle := !toggle
    InitMouseMode(_control, toggle)
    
    ; Mouse button selection mode 
    GuiControl, Show%toggle%, RestartMouse
    GuiControl, Hide%toggle%, RestartWhere
    GuiControl, Hide%toggle%, RestartKey     
}

;─────────────────────────────────────────────────────────────────────────────
;
GetMouseKey(_control := 0) {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets value from the mouse input mode (drop-down list) 
    global MainMice, RestartMice
    Gui, Submit, NoHide
    
    ; Get user choice
    GuiControlGet, _key,, % _control
    GuiControlGet, name, name, % _control
    
    ; Set global key
    name := StrReplace(name, "Mouse")
    %name%Mice := _key
    
    ; Set placeholder to the selected mouse button
    GuiControl,, %name%KeyPlaceholder, % _key
    GuiControl, Show, %name%KeyPlaceholder
    Toggle%name%Mouse()
}

;─────────────────────────────────────────────────────────────────────────────
;
GetMouseList(_action, _sequence := "") {
;─────────────────────────────────────────────────────────────────────────────
    ; Stores and returns mouse _keys in a friendly way
    ; Returns specific mouse data on "action"
    static buttons := {"Left": "LButton", "Right": "RButton", "Middle": "MButton", "Backward": "XButton1", "Forward": "XButton2"}
    static modifiers := {"Ctrl+": "^", "Win+": "#", "Alt+": "!", "Shift+": "+"}
    
    static list := ""
    if !(list) {
        ; Convert to permanent drop-down list with modifiers
        for _key, _ in buttons {
            list .= "|" . _key 
            for _mod, _ in modifiers {
                list .= "|" . _mod . _key
            }
        }
        list := LTrim(list, "|")
    }
    
    switch (_action) {
        case "list":
            return list
        case "isMouse":
            return InStr(_sequence, "Button") || InStr(list, _sequence)
            
        case "convert":
            for _key, _value in buttons
                _sequence := StrReplace(_sequence, _key, _value)

            for _mod, _value in modifiers
                _sequence := StrReplace(_sequence, _mod, _value)
                
            return _sequence                
    }
}