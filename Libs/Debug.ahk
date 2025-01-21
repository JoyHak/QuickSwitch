DebugExport()
{
  global FingerPrint
  _fileName := A_ScriptDir . "\" . FingerPrint . ".csv"
  oFile := FileOpen(_fileName, "w") ; Creates a new file, overwriting any existing file.

  If IsObject(oFile)
  {
    ;	Header
    _line := "ControlName;ID;PID;Text;X;Y;Width;Height"
    oFile.WriteLine(_line)
    Gui, ListView

    Loop % LV_GetCount()
    {
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

    Msgbox Results exported to:`n`n"%_filename%"
  }
  Else						; File could not be initialized
  {
    Msgbox Cant create %_fileName%
  }
  Return
}

CancelLV()
{
  LV_Delete()
  GUI, Destroy

  Return
}

DebugControls()
{
  GUI, Destroy
  ; Add ControlGetPos [, X, Y, Width, Height, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
  ; change folder to ahk folder. change name to fingerpringt.csv
  global GuiColor
  SetFormat, Integer, D
  ;	Header for list
  Gui, Add, ListView, r30 w1024, Control|ID|PID||Text|X|Y|Width|Height
  ;	Loop through controls
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