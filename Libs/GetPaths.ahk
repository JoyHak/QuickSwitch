; Here are the main functions for obtaining paths and interacting with them.
; All functions add values to the global paths array.

PathChoice() {  
  /*   
    ID, paths and FuncObj FeedDialog declared in ShowFolderPaths()
    The path is bound to the position of the menu item 
    and MUST BE ADDED to the array in the same order as the menu item 
  */
  global
  FeedDialog.call(DialogID, paths[A_ThisMenuItemPos])
}

ShowShortPath(ByRef _path) {
  /* 
    _fullPath is shortened to the last N folders (foldersCount) starting from the end of the path.
    Folders are selected as intervals between slashes, excluding them.
    boundaries = indexes of any slashes \ / in the path: /folder/folder/ 
  */
  global CutFromEnd, FoldersCount, FolderNameLength, ShowDriveLetter, PathSeparator, ShortNameIndicator 
  
  _length := StrLen(_path)
  If _length < 4 		
    Return _path  ; Just drive and slash
	
  If ShowDriveLetter 
  {
	SplitPath, _path,,,,, _letter
	_shortPath .= _letter
  } 
    
  
  ; The number of slashes (indexes) is 1 more than the number of folders: /f1/f2/ - 2 folders, 3 slashes
  _maxSlashes   := FoldersCount + 1
  ; If the number of slashes is less than FoldersCount, the array will contain -1
  ; This is necessary for handling paths where the number of folders is less than FoldersCount: C:/folder
  _slashIndexes := []
  Loop, % _maxSlashes 
  {
     _slashIndexes.Push(-1)
  }

	  
  ;_____________________________________________________________________________
  ;
  ; Parsing the path, looking for the indexes of slashes
  ;_____________________________________________________________________________  
  
  _fullPath  := _path . "/" 	; Last folder bound
  _length++
  If CutFromEnd 		
  {
	; Reverse slash search until enough is found 
	; to display the required number of folders
	_pathIndex 		:= _length
	_slashesCount 	:= _maxSlashes 
	while (_pathIndex >= 3 && _slashesCount >= 1) 	; 3 is pos of the 1st slash
	{
	  _char := SubStr(_fullPath, _pathIndex, 1)
	  If (_char == "/" || _char == "\") 
	  {
	    _slashIndexes[_slashesCount] := _pathIndex
	    _slashesCount--
	  }
	  _pathIndex--
	}
	If (_slashesCount > _maxSlashes - 2)
	  return _path   ; not enough to shorten the path
	
	_shortPath .= ShortNameIndicator   ; An indication that there are more paths after the drive letter
  }
  Else
  {
	; Direct search starting from the pos of the 1st slash 
	_pathIndex 		:= 3  
	_slashesCount 	:= 1
	while (_pathIndex <= _length && _slashesCount <= _maxSlashes)
	{
	  _char := SubStr(_fullPath, _pathIndex, 1)
	  If (_char == "/" || _char == "\") 
	  {
	    _slashIndexes[_slashesCount] := _pathIndex
	    _slashesCount++
	  }
	  _pathIndex++
	} 
	If (_slashesCount < 3)
	  return _path   ; not enough to shorten the path
  }
  ;_____________________________________________________________________________
  ;
  ; Parsing the slash indexes and extracting the folder names.
  ;_____________________________________________________________________________ 

  Loop, % FoldersCount
  {
	_left  := _slashIndexes[A_Index]
	_right := _slashIndexes[A_Index + 1]  
	If (_left != -1 && _right != -1) 
	{  
	  _left++ 	 ; exclude slash from name
	  
	  _length 	:= _right - _left
	  _nameLength := Min(_length, FolderNameLength)
	  _folderName := SubStr(_fullPath, _left, _nameLength)
	  _shortPath  .= PathSeparator . _folderName
	  
	  If (folderNameLength - _length < 0)
	  	_shortPath .= ShortNameIndicator
	} 
  }
  _shortPath .= ShortNameIndicator   ; An indication that there are more paths after the last folder
  Return _shortPath
}

/* 
  After execution XYscript waits for a signal and executes FeedXYdata 
  to get XYdata from XYplorer to Autohotkey. 
  
  Alternative variants are provided in Libs/Reserved, including v2
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

  Return DllCall("User32.dll\SendMessageW", "Ptr", _WinID, "UInt", 74, "Ptr", 0, "Ptr", &COPYDATA, "Ptr")
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

;_____________________________________________________________________________
;
GetXYpaths(_WinID)
;_____________________________________________________________________________ 
{
  ; Put path(s) to XYdata (the variable is filled in anew each time it is called)
  ; then push to array
  global XYdata, VirtualPath, paths, virtuals
  
  _script =
  ( LTrim Join
    ::
    load('
    
      $paths = get("tabs_sf", "|"); 
      $reals = ""; 
      foreach($path, $paths, "|") 
  	  {
  	    $reals .= "|" . pathreal($path); 
      } 
      $reals = replace($reals, "|",,,1,1); 
  	  copydata %A_ScriptHwnd%, $reals, 2`;
    
    ',,s)`;
  )
  XYscript(_WinID, _script)

  Loop, parse, XYdata, `| 
	paths.push(A_LoopField)
  
  If paths && VirtualPath
  {
    _script = ::copydata %A_ScriptHwnd%, get("tabs_sf", "|"), 2`;
	XYscript(_WinID, _script)
	Loop, parse, XYdata, `| 
      virtuals.push(A_LoopField)
  }
}
;_____________________________________________________________________________
;
GetWINpaths(_WinID)
;_____________________________________________________________________________ 
{ 
  global paths
  _virtuals := "::{F874310E-B6B7-47DC-BC84-B9E6B38F5903},::{E88865EA-0E1C-4E20-9AA6-EDCD0212C87C},::{645FF040-5081-101B-9F08-00AA002F954E},::{20D04FE0-3AEA-1069-A2D8-08002B30309D},::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
  
  For _instance in ComObjCreate("Shell.Application").Windows
  {
    If (_WinID == _instance.hwnd)
    {
	  _path := _instance.Document.Folder.Self.Path
      If !InStr(_virtuals, _path) 
		   paths.push(_path) 
    }
  }
  Return	  
}

;_____________________________________________________________________________
;
GetTCPaths(_WinID)
;_____________________________________________________________________________ 
{    
  global paths
  ; Save clipboard to restore later
  ClipSaved := ClipboardAll
  Clipboard := ""
    
  ; wait a little, or source path may not be captured!
  Sleep, 50
  SendMessage 1075, %cm_CopySrcPathToClip%, 0, , ahk_id %_WinID%
  Sleep, 50
  paths.push(clipboard)  
    
  SendMessage 1075, %cm_CopyTrgPathToClip%, 0, , ahk_id %_WinID%
  Sleep, 50
  paths.push(clipboard)   
  
  ; Restore  
  Clipboard := ClipSaved
  ClipSaved := ""
  
  Return  
}

;_____________________________________________________________________________
;
GetDOPUSPaths(_WinID)
;_____________________________________________________________________________ 
{
  global paths
  
  EnvGet, _tempfolder, TEMP
  _tempfile := _tempfolder . "\dopusinfo.xml"

  ; Arg comma needs escaping: `,
  _command = "%_dopus_exe%\..\dopusrt.exe" /info "%_tempfile%"`, paths
  Run, _command, , , DUMMY
  Sleep, 300
  FileRead, OpusInfo, %_tempfile%
  Sleep, 300
  FileDelete, %_tempfile%
  
  ;	Get active path of this lister (regex instead of XML library)
  RegExMatch(OpusInfo, "mO)^.*lister=\""" . _thisID . "\"".*tab_state=\""1\"".*\>(.*)\<\/path\>$", out)
  _thisFolder := out.Value(1)
  paths.push(_thisFolder)
  
  ;	Get passive path of this lister
  RegExMatch(OpusInfo, "mO)^.*lister=\""" . _thisID . "\"".*tab_state=\""2\"".*\>(.*)\<\/path\>$", out)
  _thisFolder := out.Value(1)
  paths.push(_thisFolder)
  
  _thisFolder := ""  
  Return
}

;_____________________________________________________________________________
;
GetPaths()
;_____________________________________________________________________________ 
{
  ; Update the values with each call
  global 	paths 		:= []
  global 	virtuals 	:= []
  
  global 	VirtualPath
  IniRead, 	VirtualPath, %INI%,	Menu, VirtualPath, %VirtualPath%
  
  WinGet, _allWindows, list
  Loop, %_allWindows%
  {
    _thisID := _allWindows%A_Index%
    WinGetClass, _thisClass, ahk_id %_thisID%

	If (_thisClass == "CabinetWClass") 	
	  GetWINpaths(_thisID)
    If (_thisClass == "ThunderRT6FormDC") 	
	  GetXYpaths(_thisID)
    If (_thisClass == "dopus.lister")   	
      GetDOPUSPaths(_thisID)
	If (_thisClass == "TTOTAL_CMD")  
      GetTCPaths(_thisID)
  }	
}
	

