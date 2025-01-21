#Requires AutoHotkey v2.0

global XYdata := ""

XYscript(_WinID, _script) {
   size := StrLen(_script)

   COPYDATA := Buffer(A_PtrSize * 3)
   NumPut("Ptr", 4194305, COPYDATA, 0)
   NumPut("UInt", size * 2, COPYDATA, A_PtrSize)
   NumPut("Ptr", StrPtr(_script), COPYDATA, A_PtrSize * 2)

   return DllCall("User32.dll\SendMessageW", "Ptr", _WinID, "UInt", 74, "Ptr", 0, "Ptr", COPYDATA, "Ptr")
}


FeedXYData(wParam, lParam, *) {
	global XYdata := StrGet(
		NumGet(lParam + 2 * A_PtrSize, 'Ptr'),   ; COPYDATASTRUCT.lpData, ptr to a str presumably
		NumGet(lParam + A_PtrSize, 'UInt') / 2   ; COPYDATASTRUCT.cbData, count bytes of lpData, /2 to get count chars in unicode str
	)
}