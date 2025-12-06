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
    global
    
    if _toggle {
        ; Pre-select key in the ListBox        
        GuiControl, % "ChooseString", % _type "MouseListBox", % %_type%MousePlaceholder
    }
        
    GuiControl, % "Show" _toggle, % _type "MousePlaceholder"
    GuiControl, % "Hide",         % _type "MouseListBox"
    GuiControl, % "Hide" _toggle, % _type "Key"  ; Hotkey control
}

;─────────────────────────────────────────────────────────────────────────────
;
TogglePinMouse(_control := 0) {
;─────────────────────────────────────────────────────────────────────────────
    global MainMousePlaceholder, RestartMousePlaceholder
    static toggle := false
    toggle := !toggle

    ; Hide controls below to select mouse key from listbox
    GuiControl, % "Hide" toggle, % "MainKey"
    GuiControl, % "Hide" toggle, % "MainMousePlaceholder"
;@Ahk2Exe-IgnoreBegin
    GuiControl, % "Hide" toggle, % "RestartKey"
    GuiControl, % "Hide" toggle, % "RestartMousePlaceholder"
;@Ahk2Exe-IgnoreEnd
/*@Ahk2Exe-Keep
    GuiControl, % "Hide" toggle, % "MainIcon"
*/    
    GuiControl, % "Show" toggle, % "PinMouseListbox"
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

    ; Hide control below to select mouse key from listbox  
;@Ahk2Exe-IgnoreBegin    
    GuiControl, % "Hide" toggle, % "RestartKey"
    GuiControl, % "Hide" toggle, % "RestartMousePlaceholder"
;@Ahk2Exe-IgnoreEnd
    GuiControl, % "Hide" toggle, % "MainIcon"
    
    if !toggle
        return InitKeybdMode("Main")

    ; Set visibility
    GuiControl, % "Show" toggle, % "MainMousePlaceholder"
    GuiControl, % "Show" toggle, % "MainMouseListbox"
    GuiControl, % "Hide" toggle, % "MainKey" ; Hotkey control
}

;@Ahk2Exe-IgnoreBegin
ToggleRestartMouse(_control := 0) {
    static toggle := false

    ; Toggle mouse input controls and set button caption
    toggle := !toggle
    InitMouseMode("Restart", toggle)

    ; Set button caption
    GuiControl,, % "RestartMouseButton", % (toggle ? "keybd" : "mouse")

    ; Hide controls below to select mouse key from listbox
    GuiControl, % "Hide" toggle, % "RestartKey"
    GuiControl, % "Hide" toggle, % "RestartWhere"
    GuiControl, % "Hide" toggle, % "MainIcon"

    if !toggle
        return InitKeybdMode("Restart")

    ; Set visibility
    GuiControl, % "Show" toggle, % "RestartMousePlaceholder"
    GuiControl, % "Show" toggle, % "RestartMouseListbox"    
}
;@Ahk2Exe-IgnoreEnd

;─────────────────────────────────────────────────────────────────────────────
;
GetMouseKey(_control := 0) {
;─────────────────────────────────────────────────────────────────────────────
    ; Gets value from the listbox

    ; Hide drop-down list
    _type := StrReplace(A_GuiControl, "MouseListbox")
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
    ; Stores and returns mouse keys and keyboard modifiers friendly names.
    static mouseButtons := {"Left": "LButton", "Right": "RButton", "Middle": "MButton", "Backward": "XButton1", "Forward": "XButton2"}
    static modKeys      := {"Ctrl": "^", "Win": "#", "Alt": "!", "Shift": "+"}

    static buttonsList  := "Middle|Backward|Forward|Right"
    static specialList  := "Tab|Capslock|LWin|Space"
    
    static mouseList    := buttonsList "|Ctrl+Left|Ctrl+Right|Ctrl+Middle|Ctrl+Backward|Ctrl+Forward|Shift+Left|Shift+Right|Shift+Middle|Shift+Backward|Shift+Forward|Win+Left|Win+Right|Win+Middle|Win+Backward|Win+Forward|Alt+Left|Alt+Right|Alt+Middle|Alt+Backward|Alt+Forward"
   
    switch (_action) {  
        case "pinList":
            return specialList "|" buttonsList
        case "mouseList":
            return specialList "|" mouseList
        
        case "isMouse":
            return InStr(_sequence, "Button") || InStr(mouseList, _sequence)
        case "isSpecial":
            return InStr(specialList, _sequence)
        
        case "convertMouse":
            _sequence := StrReplace(_sequence, "+")

            for _mouse, _value in mouseButtons
                _sequence := StrReplace(_sequence, _mouse, _value)

            for _mod, _value in modKeys
                _sequence := StrReplace(_sequence, _mod, _value)

            return _sequence
    }
}