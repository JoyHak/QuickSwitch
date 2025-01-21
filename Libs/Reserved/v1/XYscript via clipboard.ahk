#Requires AutoHotkey v1.1

GetXYpaths(_WinID)
{
  global paths
  ClipSaved := ClipboardAll
  Clipboard := ""
  
  script = ::copytext get('tabs_sf', '|')  
  ExecuteXYscript(_WinID, script)
  
  Loop, parse, clipboard, `|
  {  
    paths.push(A_LoopField)
  }
  
  Clipboard := ClipSaved
  ClipSaved := ""
  
  Return
}