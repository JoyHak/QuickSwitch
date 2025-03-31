Timer(R := 0) {
    /* 
        Measure script performance
        Start timer by Timer(1).
        Save result by Timer(0)
    */   
    
    static P := 0, F := 0, Q := DllCall("QueryPerformanceFrequency", "Int64P", F)
    return !DllCall("QueryPerformanceCounter", "Int64P", Q) + (R ? (P := Q) / F : (Q - P) / F) 
}

DebugExport() {
    global FingerPrint
    
    try {
        _fileName := A_ScriptDir . "\" . FingerPrint . ".csv"
        oFile := FileOpen(_fileName, "w") ; Creates a new file, overwriting any existing file.
    
        if IsObject(oFile) {
            ; Header
            _line := "ControlName;ID;PID;Text;X;Y;Width;Height"
            oFile.WriteLine(_line)
            Gui, ListView
    
            Loop % LV_GetCount() {
                LV_GetText(_col1, A_index, 1)
                LV_GetText(_col2, A_index, 2)
                LV_GetText(_col3, A_index, 3)
                LV_GetText(_col4, A_index, 4)
                LV_GetText(_col5, A_index, 5)
                LV_GetText(_col6, A_index, 6)
                LV_GetText(_col7, A_index, 7)
                LV_GetText(_col8, A_index, 8)
    
                _line := _col1 ";" _col2 "," _col3 ";" _col4 ";" _col5 ";" _col6 ";" _col7 ";" _col8 ";"
                oFile.WriteLine(_line)
            }
    
            oFile.Close()
            oFile:=""
            
            TrayTip, Successfully exported, Results exported to %_filename%
        } else {                                          ; File could not be initialized
            LogError(Exception("Cant create " _fileName,, "File unavailable for writing. Check the attributes of the target directory"))
        }
    } catch _error {
        LogError(_error)
    }    
}

CancelLV() {
    LV_Delete()
    GUI, Destroy
}

ShowDebugMenu() {
    ; Add ControlGetPos [, X, Y, Width, Height, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
    ; Change dir to ahk
    ; Change name to fingerpringt.csv

    global GuiColor
    GUI, Destroy

    SetFormat, Integer, D
    ; Header for list
    Gui, Add, ListView, r30 w1024, Control|ID|PID||Text|X|Y|Width|Height
    ; Loop through controls
    WinGet, ActivecontrolList, ControlList, A

    Loop, Parse, ActivecontrolList, `n
    {
        ;Get ID
        ControlGet, _ctrlHandle, Hwnd, , %A_LoopField%, A
        ;Get Text
        ControlGetText _ctrlText, , ahk_id %_ctrlHandle%
        ;Get control coordinates
        ControlGetPos _X, _Y, _Width, _Height, , ahk_id %_ctrlHandle%
        ;Get PID
        _parentHandle := DllCall("GetParent", "Ptr", _ctrlHandle)
        ;Add to listview ; abs for hex to dec
        LV_Add(, A_LoopField, abs(_ctrlHandle), _parentHandle, _ctrlText, _X, _Y, _Width, _Height)
    }

    LV_ModifyCol() ; Auto-size each column to fit its contents.
    LV_ModifyCol(2, "Integer")
    LV_ModifyCol(3, "Integer")

    Gui, Add, Button, y+10 w100 h30 gDebugExport, Export
    Gui, Add, Button, x+10 w100 h30 gCancelLV, Cancel

    Gui, Color, %GuiColor%
    Gui, Show
    Return
}