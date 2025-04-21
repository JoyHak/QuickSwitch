; Contains functions for getting and analyzing tabs file from Total Commander

CreateTotalUserCommand(ByRef ini, ByRef cmd, ByRef internalCmd, ByRef param := "") {
    ; Creates cmd in specified ini config.
    ; "cmd" param must start with EM_

    loop, 4 {
        ; Read the contents of the config until it appears or the loop ends with an error
        IniRead, _section, % ini, % cmd
        if (_section && _section != "ERROR") {
            return true
        }

        ; Set normal attributes (write access)
        FileSetAttrib, n, % ini
        sleep, 20 * A_Index

        ; Create new section
        FileAppend,
        (LTrim
         # Please dont add commands with the same name
         [%cmd%]
         cmd=%internalCmd%
         param=%param%

        ), % ini
        sleep, 50 * A_Index
    }
    throw Exception("Unable to create configuration", "TotalCmd config", ini " doesnt exist and cannot be created. Create it manually")
}

;─────────────────────────────────────────────────────────────────────────────
;
CreateTotalUserIni(ByRef winId, ByRef cmd, ByRef internalCmd, ByRef param := "") {
;─────────────────────────────────────────────────────────────────────────────
    ; Searches for the location of wincmd.ini to create usercmd.ini 
    ; in that directory with the "cmd" user command
    
    ; Thanks to Dalai for the search steps:
    ; https://www.ghisler.ch/board/viewtopic.php?p=470238#p470238
        
    WinGet, _winPid, PID, ahk_id %winId%
    _ini := ""
    
    for _index, _func in ["GetTotalConsoleIni", "GetTotalLaunchIni", "GetTotalPathIni"] {
        ; Search for wincmd.ini and display error on each step 
        if (_ini := Func(_func).call(_winPid))
            break
        }
    }
 
    if !FileExist(_ini)
        throw Exception("Unable to find wincmd.ini", "TotalCmd config", "File `'" _ini "`' not found. Change your TC configuration settings")
    
    _userIni := StrReplace(_ini, "wincmd", "usercmd")
    CreateTotalUserCommand(_userIni, cmd, internalCmd, param)
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalTabs(ByRef tabsFile) {
;─────────────────────────────────────────────────────────────────────────────
    ; Parses tabsFile.
    ; Searches for the active tab using the "activetab" parameter
    global Paths

    try FileDelete, % tabsFile
    loop, 600 {
        if FileExist(tabsFile) {
            _paths  := []

            ; Tabs index starts with 0, array index starts with 1
            _active := _last := 0

            Loop, read, % tabsFile
            {
                ; Omit the InStr key and SubStr from value position
                if (_pos := InStr(A_LoopReadLine, "path=")) {
                    _path := SubStr(A_LoopReadLine, _pos + 5)
                    _paths.push(RTrim(_path, "\"))
                }
                if (_num := InStr(A_LoopReadLine, "activetab=")) {
                    ; Skip next active tab by saving last
                    _active := _last
                    _last   := SubStr(A_LoopReadLine, _num + 10)
                }
            }

            ; Push the active tab to the global array first
            ; Remove duplicate and add the remaining tabs
            Paths.push(_paths.removeAt(_active + 1))
            Paths.push(_paths*)

            return true
        }
        sleep, 20
    }
    throw Exception("Unable to access tabs", "TotalCmd tabs", "Restart Total Commander and retry")
}