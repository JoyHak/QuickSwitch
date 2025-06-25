/*
    Contains functions for selecting mouse buttons in the GUI.
    Toggles between keyboard and mouse input modes (GUI).
*/

InitMouseMode(_type := "Main", _toggle := false) {
    ; Set button caption
    GuiControl,, % _type "MouseButton", % (_toggle ? "keybd" : "mouse")
    
    ; Set visibility
    GuiControl, Show%_toggle%, %_type%Mouse ; Mouse keys placeholder
    GuiControl, Hide%_toggle%, %_type%Key   ; Hotkey control
    GuiControl, Hide,          %_type%      ; Drop-down list
}

ToggleMainMouse(_control := 0) {
    static toggle := false
    toggle := !toggle
    InitMouseMode("Main", toggle)

    ; Set visibility
    GuiControl, Show%toggle%, MainMouse     ; Mouse keys placeholder
    GuiControl, Hide%toggle%, MainKey       ; Hotkey control
    
    ; Hide controls below to select mouse key from drop-down list
    GuiControl, Hide%toggle%, RestartKey
    GuiControl, Hide%toggle%, RestartMouse
}

ToggleRestartMouse(_control := 0) {
    static toggle := false
    toggle := !toggle
    
    InitMouseMode("Restart", toggle)
    GuiControl, Show%toggle%, RestartMouse  ; Mouse keys placeholder
    
    ; Hide controls below to select mouse key from drop-down list
    GuiControl, Hide%toggle%, RestartKey
    GuiControl, Hide%toggle%, RestartWhere
}

;─────────────────────────────────────────────────────────────────────────────
;
GetMouseKey(_control := 0) {
;─────────────────────────────────────────────────────────────────────────────
    ; Get value from the mouse input mode (drop-down list)
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