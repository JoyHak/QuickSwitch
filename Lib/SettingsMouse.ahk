; Contains functions for selecting mouse buttons in the GUI.

InitKeybdMode(_type := "Main", _toggle := true) {
    ; Switches the key input mode
    ; Show hotkey control
    InitMouseMode(_type, !_toggle)

    if _toggle {
        ; Reset global mouse
        ; Focus hotkey control
        GuiControl,, % _type "Mouse", % ""
        GuiControl, % "Focus", % _type "Key"
    }
}

InitMouseMode(_type := "Main", _toggle := false) {
    ; Switches the visibility of mouse buttons selection controls
    GuiControl, % "Show" _toggle, % _type "Mouse" ; Mouse keys placeholder
    GuiControl, % "Hide" _toggle, % _type "Key"   ; Hotkey control
    GuiControl, % "Hide",         % _type         ; Drop-down list
}

;─────────────────────────────────────────────────────────────────────────────
;
TogglePinMouse(_control := 0) {
;─────────────────────────────────────────────────────────────────────────────
    static toggle := false

    ; Toggle mouse input controls and set button caption
    toggle := !toggle
    InitMouseMode("Pin", toggle)

    ; Set button caption
    GuiControl,, % "PinMouseButton", % (toggle ? "keybd" : "mouse")

    ; Hide control below to select mouse key from drop-down list
    GuiControlGet, _mouse,, % "MainMouse"
    GuiControl, % "Hide" toggle, % "Main" . (_mouse ? "Mouse" : "Key")
    if !toggle
        return InitKeybdMode("Pin")

    ; Set visibility
    GuiControl, % "Show" toggle, % "PinMouse"    ; Mouse buttons placeholder
    GuiControl, % "Show" toggle, % "Pin"         ; Drop-down list
    GuiControl, % "Hide" toggle, % "PinKey"      ; Hotkey control
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

    ; Hide control below to select mouse key from drop-down list
    GuiControlGet, _mouse,, % "RestartMouse"
    GuiControl, % "Hide" toggle, % "Restart" . (_mouse ? "Mouse" : "Key")
    if !toggle
        return InitKeybdMode("Main")

    ; Set visibility
    GuiControl, % "Show" toggle, % "MainMouse"    ; Mouse buttons placeholder
    GuiControl, % "Show" toggle, % "Main"         ; Drop-down list
    GuiControl, % "Hide" toggle, % "MainKey"      ; Hotkey control
}

;─────────────────────────────────────────────────────────────────────────────
;
ToggleRestartMouse(_control := 0) {
;─────────────────────────────────────────────────────────────────────────────
    static toggle := false

    ; Toggle mouse input controls and set button caption
    toggle := !toggle
    InitMouseMode("Restart", toggle)

    ; Set button caption
    GuiControl,, % "RestartMouseButton", % (toggle ? "keybd" : "mouse")

    ; Hide controls below to select mouse key from drop-down list
    GuiControl, % "Hide" toggle, % "RestartKey"
    GuiControl, % "Hide" toggle, % "RestartWhere"

    if !toggle
        return InitKeybdMode("Restart")

    ; Set visibility
    GuiControl, % "Show" toggle, % "RestartMouse" ; Mouse buttons placeholder
    GuiControl, % "Show" toggle, % "Restart"      ; Drop-down list
}

;─────────────────────────────────────────────────────────────────────────────
;
GetMouseKey(_control := 0) {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets value from the mouse input mode (drop-down list)
    ; Get value and mouse button name
    _type := A_GuiControl

    ; Hide drop-down list
    Toggle%_type%Mouse()
    
    ; Set placeholder to the selected mouse button
    GuiControlGet, _key,, % _control
    GuiControl,, % _type "Mouse", % _key
    
    ; Show placeholder and hide hotkey control 
    GuiControl, % "Show", % _type "Mouse"
    GuiControl, % "Hide", % _type "Key"      
}

;─────────────────────────────────────────────────────────────────────────────
;
GetMouseList(_action, _sequence := "") {
;─────────────────────────────────────────────────────────────────────────────
    ; Stores and returns mouse keys and keyboard modifiers friendly names
    ; Returns specific mouse data on "action"
    static mouseButtons   := {"Left": "LButton", "Right": "RButton", "Middle": "MButton", "Backward": "XButton1", "Forward": "XButton2"}
    static modKeys        := {"Ctrl": "^", "Win": "#", "Alt": "!", "Shift": "+"}

    static mouseList := ""
    static keysList  := ""
    
    if !(mouseList) {
        ; Convert to permanent drop-down list "key+mouse"
        for _mouse, _ in mouseButtons {
            mouseList .= "|" _mouse
            for _key, _ in modKeys {
                mouseList .= "|" _key "+" _mouse
            }
        }
        mouseList := LTrim(mouseList, "|")
    }
    
    if !(keysList) {
        ; Convert to permanent drop-down list "key1+key2"
        for _key1, _ in modKeys {
            keysList .= "|" _key1
            for _key2, _ in modKeys {
                if (_key1 != _key2) {
                    keysList .= "|" _key1 "+" _key2
                }
            }
        }
        keysList := LTrim(keysList, "|")
    }

    switch (_action) {
        case "mouseList":
            return mouseList
        case "keysList":
            return keysList   
        case "isMouse":
            return InStr(_sequence, "Button") || InStr(mouseList, _sequence)

        case "convert":
            _sequence := StrReplace(_sequence, "+")
            
            for _key, _value in mouseButtons
                _sequence := StrReplace(_sequence, _key, _value)

            for _mod, _value in modKeys
                _sequence := StrReplace(_sequence, _mod, _value)

            return _sequence
    }
}