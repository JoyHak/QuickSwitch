; Contains functions for selecting mouse buttons in the GUI.

InitKeybdMode(_type := "Main", _toggle := true) { 
    ; Switches the key input mode
    ; Show hotkey control
    InitMouseMode(_type, !_toggle)      
    
    if _toggle {    
        ; Reset global mouse
        ; Focus hotkey control
        GuiControl,, %_type%Mouse, % ""
        GuiControl, Focus, %_type%Key   
    }
}

InitMouseMode(_type := "Main", _toggle := false) {
    ; Switches the visibility of mouse buttons selection controls
    GuiControl, Show%_toggle%, %_type%Mouse ; Mouse keys placeholder
    GuiControl, Hide,          %_type%      ; Drop-down list
    GuiControl, Hide%_toggle%, %_type%Key   ; Hotkey control
}


;─────────────────────────────────────────────────────────────────────────────
;
ToggleMainMouse(_control := 0) {
;─────────────────────────────────────────────────────────────────────────────
    static toggle := false    
    
    ; Toggle mouse input controls and set button caption
    toggle := !toggle
    InitMouseMode("Main", toggle)
    
    ; Set button caption
    GuiControl,, % "MainMouseButton", % (toggle ? "keybd" : "mouse")
    
    ; Hide controls below to select mouse key from drop-down list
    GuiControl, Hide%toggle%, RestartKey
    GuiControl, Hide%toggle%, RestartMouse
    if !toggle
        return InitKeybdMode("Main")

    ; Set visibility
    GuiControl, Show%toggle%, MainMouse     ; Mouse buttons placeholder
    GuiControl, Show%toggle%, Main          ; Drop-down list
    GuiControl, Hide%toggle%, MainKey       ; Hotkey control
}

ToggleRestartMouse(_control := 0) {
    static toggle := false
    toggle := !toggle
    InitMouseMode("Restart", toggle)
    
    ; Set visibility
    GuiControl, Show%toggle%, RestartMouse  ; Mouse buttons placeholder
    GuiControl, Show%toggle%, Restart       ; Drop-down list
    
    ; Hide controls below to select mouse key from drop-down list
    GuiControl, Hide%toggle%, RestartKey
    GuiControl, Hide%toggle%, RestartWhere
}

;─────────────────────────────────────────────────────────────────────────────
;
GetMouseKey(_control := 0) {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets value from the mouse input mode (drop-down list)
    ; Get value and mouse button name
    GuiControlGet, _key,, % _control
    GuiControlGet, name, Name, % _control
    
    ; Hide drop-down list
    Toggle%name%Mouse()
    
    ; Set placeholder to the selected mouse button
    GuiControl,, %name%Mouse, % _key
    GuiControl, Show, %name%Mouse
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