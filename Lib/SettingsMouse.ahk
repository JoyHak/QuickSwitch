/* 
    Entering hotkey and the choice of one mouse button consists of two parts: 
    - Hotkey control (next, we will call it Key input mode) 
    - Several mouse buttons choice controls (next, we will call them Mouse input mode).
    
    Mouse input mode works using:
    - Listbox: allows user to select the mouse buttons. 
      Imitates Drop-Down List, but this is a more convenient control for switching between Mouse / Key input modes.
      Appears under Placeholder.
    
    - Placeholder (edit): displays the mouse button selected in Listbox. 
      It is displayed in the place of Hotkey control.
    
    - Button (keybd / mouse): toggles between Mouse / Key input modes. 
      Shows controls above, hides everything that overlaps with them, hides Hotkey Control.
      If the controls are already visible above, upon repeated pressing the process is in the reverse order: 
      show previously hidden controls, hide Listbox and so on.
*/ 

InitKeybdMode(_type := "Main", _toggle := true) {
    ; Switches the key input mode
    ; Show hotkey control
    InitMouseMode(_type, !_toggle)

    if _toggle {
        GuiControl,, % _type "MousePlaceholder", % ""   ; Reset global mouse
        GuiControl, % "Focus", % _type "Key"            ; Focus hotkey control
    }
}

InitMouseMode(_type := "Main", _toggle := false) {
    ; Changes the visibility of mouse buttons selection controls
    GuiControl, % "Show" _toggle, % _type "MousePlaceholder"
    GuiControl, % "Hide",         % _type "MouseListBox"
    GuiControl, % "Hide" _toggle, % _type "Key"  ; Hotkey control
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
    ; If the mouse button is selected -> hide Hotkey control and vice versa
    GuiControlGet, _mouse,, % "MainMousePlaceholder"
    GuiControl, % "Hide" toggle, % "Main" . (_mouse ? "MousePlaceholder" : "Key")
    
    if !toggle
        return InitKeybdMode("Pin")

    ; Set visibility
    GuiControl, % "Show" toggle, % "PinMousePlaceholder"
    GuiControl, % "Show" toggle, % "PinMouseListbox"    
    GuiControl, % "Hide" toggle, % "PinKey" ; Hotkey control
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
    ; If the mouse button is selected -> hide Hotkey control and vice versa
    GuiControlGet, _mouse,, % "RestartMousePlaceholder"     
    GuiControl, % "Hide" toggle, % "Restart" . (_mouse ? "MousePlaceholder" : "Key")
    
    if !toggle
        return InitKeybdMode("Main")

    ; Set visibility
    GuiControl, % "Show" toggle, % "MainMousePlaceholder"
    GuiControl, % "Show" toggle, % "MainMouseListbox"
    GuiControl, % "Hide" toggle, % "MainKey" ; Hotkey control
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
    GuiControl, % "Show" toggle, % "RestartMousePlaceholder"
    GuiControl, % "Show" toggle, % "RestartMouseListbox"    
}

;─────────────────────────────────────────────────────────────────────────────
;
GetMouseKey(_control := 0) {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets value from the mouse input mode (drop-down list)
    ; Get value and mouse button name
    _type := StrReplace(A_GuiControl, "MouseListbox")

    ; Hide drop-down list
    Toggle%_type%Mouse()
    
    ; Set placeholder to the selected mouse button and show it
    GuiControlGet, _userChoice,, % _control
    GuiControl,, % _type "MousePlaceholder", % _userChoice
    GuiControl, % "Show", % _type "MousePlaceholder"
    
    ; Hide hotkey control 
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
    ; static specialKeys    := ["Space", "Tab"]

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