#Requires AutoHotkey v1.1
/* 
  After execution XYscript waits for a signal and executes FeedXYdata 
  to get XYdata from XYplorer to Autohotkey. 
  Alternatively, a clipboard can be used.
  v1: https://www.xyplorer.com/xyfc/viewtopic.php?p=221155&hilit=Autohotkey+get#p221155
  
  v2: https://www.xyplorer.com/xyfc/viewtopic.php?p=207593#p207593
*/

XYscript(_WinID, _script)
{  
  _size := StrLen(_script)
  ; deprecated in v2 and must be deleted: _data := _script
  If !(A_IsUnicode) 
  {
    VarSetCapacity(_data, _size * 2, 0)
    StrPut(_script, &_data, "UTF-16")
  }
  Else
  {
    _data := _script
  }

  VarSetCapacity(COPYDATA, A_PtrSize * 3, 0) 	; BufferObj in v2
  NumPut(4194305, COPYDATA, 0, "Ptr")
  NumPut(_size * 2, COPYDATA, A_PtrSize, "UInt")
  NumPut(&_data, COPYDATA, A_PtrSize * 2, "Ptr") ; StrPtr(_data) in v2
  result := DllCall("User32.dll\SendMessageW", "Ptr", _WinID, "UInt", 74, "Ptr", 0, "Ptr", &COPYDATA, "Ptr")
  Return 
}

FeedXYdata(_wParam, _lParam) 
{
   global XYdata

   _stringAddress := NumGet(_lParam + 2 * A_PtrSize)
   _copyOfData := StrGet(_stringAddress)
   _cbData := NumGet(_lParam + A_PtrSize) / 2
   StringLeft, XYdata, _copyOfData, _cbData

   return
}
OnMessage(0x4a, "FeedXYdata") 
