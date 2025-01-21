#Requires AutoHotkey v1.1

script = ::copydata %G_OwnHWND%, get("tabs_sf", "|")`, 2`;
script = ::copytext get("tabs_sf", "|")`;

RealPath =
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

data = get("tabs_sf", "|")
