/*
    Contains functions for debugging and testing code.
    Any functions to test the performance of the code
    (other than logging) should be stored here.
    Library must be imported first to be used in other libraries!
*/

Timer(R := 0) {
    /*
        Measure script performance
        Start: Timer(1).
        Save:  Timer(0)
    */

    static P := 0, F := 0, Q := DllCall("QueryPerformanceFrequency", "Int64P", F)
    return !DllCall("QueryPerformanceCounter", "Int64P", Q) + (R ? (P := Q) / F : (Q - P) / F)
}

ExportDebug() {
    ; Export dialog controls from ListView to CSV
    global FingerPrint, FileDialog

    try {
        _fileName := A_ScriptDir "\" FingerPrint ".csv"
        _file := FileOpen(_fileName, "w")

        if !IsObject(_file)
            return LogError(Exception(_fileName
                                      , "export"
                                      , "File closed for writing. Check the attributes of the target directory"))

        ; Header
        _line := FileDialog.name "`n" FingerPrint "`n`n"
        _line .= "ControlName;ID;PID;Text;X;Y;Width;Height"
        _file.writeLine(_line)

        ; Get content of each line
        Gui, ListView
        Loop, % LV_GetCount() {
            _line     := ""
            _colIndex := A_index

            ; Append content of each column
            Loop, 8 {
                LV_GetText(_text, _colIndex, A_index)
                _line .= _text ";"
            }
            _file.writeLine(_line)
        }

        _file.close()
        clipboard := _filename
        TrayTip, % "Successfully exported (path in clipboard)", % _filename

    } catch _error {
        LogError(_error)
    }
}

CancelLV() {
    LV_Delete()
    Gui, Destroy
}

ShowDebug() {
    ; Displays information about the file dialog Controls
    global FileDialog
    Gui, Destroy

    SetFormat, Integer, D
    Gui, Add, ListView, r30 w1024, Control|ID|PID||Text|X|Y|Width|Height

    WinGet, ActivecontrolList, ControlList, A
    Loop, Parse, ActivecontrolList, `n
    {
        ControlGet, _ctrlHandle, Hwnd, , %A_LoopField%, A
        ControlGetText _ctrlText, , ahk_id %_ctrlHandle%
        ControlGetPos _X, _Y, _Width, _Height, , ahk_id %_ctrlHandle%

        ; Get PID
        _parentHandle := DllCall("GetParent", "Ptr", _ctrlHandle)
        ; Abs for hex to dec
        LV_Add(, A_LoopField, abs(_ctrlHandle), _parentHandle, _ctrlText, _X, _Y, _Width, _Height)
    }

    ; Auto-size each column to fit its contents
    LV_ModifyCol()
    LV_ModifyCol(2, "Integer")
    LV_ModifyCol(3, "Integer")

    Gui, Add, Button, y+10 w74 gExportDebug,    &Export
    Gui, Add, Button, x+10 wp  gCancelLV,       &Cancel
    Gui, Add, Button, x+10 wp  gNukeSettings,   &Nuke
    Gui, Show,, % FileDialog.name
}