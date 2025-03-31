; Here are the main functions for obtaining paths and interacting with them.
; All functions add values to the global paths array.

SelectPath() {
    /*
        The path is bound to the position of the menu item
        and MUST BE ADDED to the array in the same order as the menu item
    */
    global
    FileDialog.call(DialogID, paths[A_ThisMenuItemPos])
}

GetShortPath(ByRef _path) {
    /*
        _fullPath is shortened to the last N dirs (DirsCount) starting from the end of the path.
        Dirs are selected as intervals between slashes, excluding them.
        boundaries = indexes of any slashes \ / in the path: /dir/dir/
    */
    global ShortenEnd, DirsCount, DirNameLength, ShowDriveLetter, PathSeparator, ShortNameIndicator
    
    try {
        ; Return input path if it's really short
        _length := StrLen(_path)
        if _length < 4
            Return _path    ; Just drive and slash
    
        ; Variable to return
        _shortPath := ShowDriveLetter ? Substr(_path, 1, 2) : ""
          
        ; The number of slashes (indexes) is one more than the number of dirs: C:/dir/dir/ - 2 dirs, 3 slashes
        _maxSlashes := DirsCount + 1
        ; if the number of slashes is less than DirsCount, the array will contain -1
        ; This is necessary for handling paths where the number of dirs is less than DirsCount: C:/dir
        _slashIndexes := []
        Loop, % _maxSlashes {
            _slashIndexes.Push(-1)
        }
    
        ;─────────────────────────────────────────────────────────────────────────────
        ;
        ; Parsing the path, looking for the indexes of slashes
        ;─────────────────────────────────────────────────────────────────────────────
    
        _fullPath := _path . "/"         ; Last dir bound
        _length++

        if ShortenEnd {
            ; Forward search starting from the pos of the 1st slash
            _pathIndex    := 3
            _slashesCount := 1
            while (_pathIndex <= _length and _slashesCount <= _maxSlashes) {
                _char := SubStr(_fullPath, _pathIndex, 1)
                if (_char = "\" || _char = "/") {
                    _slashIndexes[_slashesCount] := _pathIndex
                    _slashesCount++
                }
                _pathIndex++
            }
            if (_slashesCount < 3)
                return _path     ; not enough to shorten the path
        } else {
            ; Backward slash search until enough is found
            ; to display the required number of dirs
            _pathIndex    := _length
            _slashesCount := _maxSlashes
            while (_pathIndex >= 3 and _slashesCount >= 1) {     ; 3 is pos of the 1st slash
                _char := SubStr(_fullPath, _pathIndex, 1)
                if (_char = "\" || _char = "/") {
                    _slashIndexes[_slashesCount] := _pathIndex
                    _slashesCount--
                }
                _pathIndex--
            }
            if (_slashesCount > _maxSlashes - 2)
                return _path     ; not enough to shorten the path
    
            _shortPath .= ShortNameIndicator     ; An indication that there are more paths after the drive letter
        }
    
        ;─────────────────────────────────────────────────────────────────────────────
        ;
        ; Parsing the slash indexes and extracting the dir names.
        ;─────────────────────────────────────────────────────────────────────────────
    
        Loop, % DirsCount {
            _left    := _slashIndexes[A_Index]
            _right   := _slashIndexes[A_Index + 1]
            if (_left != -1 and _right != -1) {
                _left++     ; exclude slash from name
    
                _length     := _right - _left
                _nameLength := Min(_length, DirNameLength)
                _dirName := SubStr(_fullPath, _left, _nameLength)
                _shortPath  .= PathSeparator . _dirName
    
                if (DirNameLength - _length < 0)
                    _shortPath .= ShortNameIndicator
            }
        }
    } catch _error {
        LogError(_error)
        Return _path
    }
    Return _shortPath
}

/*
    After execution XYscript waits for a signal and executes FeedXyplorerData
    to get XyplorerData from XYplorer to Autohotkey.

    Alternative variants are provided in Libs/Reserved, including v2
*/

XyplorerScript(ByRef _WinID, ByRef _script) {
    _size := StrLen(_script)

    VarSetCapacity(COPYDATA, A_PtrSize * 3, 0)
    NumPut(4194305, COPYDATA, 0, "Ptr")
    NumPut(_size * 2, COPYDATA, A_PtrSize, "UInt")
    NumPut(&_script, COPYDATA, A_PtrSize * 2, "Ptr")

    Return DllCall("User32.dll\SendMessageW", "Ptr", _WinID, "UInt", 74, "Ptr", 0, "Ptr", &COPYDATA, "Ptr")
}

;─────────────────────────────────────────────────────────────────────────────
;
GetXyplorerPaths(ByRef _WinID) {
;─────────────────────────────────────────────────────────────────────────────
    ; If second pane enabled, get tabs from all panes, otherwise get from active pane,
    ; separate paths by |
    ; For each path get real path (XY have special and virtual paths)
    ; Remove | from $reals beginning
    ; Place $reals to clipboard, parse it and push all paths to the array
    
    global paths
    
    try {
        _script =
        ( LTrim Join
            ::$paths = <get tabs_sf | a>;
            if (get("#800")) { 
                $paths .= |<get tabs_sf | i>
            }
            $reals = "";
            foreach($path, $paths, "|") {
                $reals .= "|" . pathreal($path);
            }
            $reals = replace($reals, "|",,,1,1);
            copytext $reals;
        )
        XyplorerScript(_WinID, _script)
        
        ClipWait
        Loop, parse, Clipboard, `| 
        {
            paths.push(A_LoopField)
        }
    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetWindowsPaths(ByRef _WinID) {
;─────────────────────────────────────────────────────────────────────────────
    global paths
    
    try {
        for _instance in ComObjCreate("Shell.Application").Windows {
            if (_WinID == _instance.hwnd) {
                _path := _instance.Document.Folder.Self.Path
                if !InStr(_path, "::{") {
                    paths.push(_path)
                }
            }
        }
    } catch _error {
        LogError(_error)
    }
    
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTotalCommanderPaths(_WinID) {
;─────────────────────────────────────────────────────────────────────────────
    global paths
    
    try {
        SendMessage 1075, 2029, 0, , ahk_id %_WinID%    ; cm_CopySrcPathToClip
        ClipWait
        paths.push(clipboard)
    
        SendMessage 1075, 2030, 0, , ahk_id %_WinID%    ; cm_CopyTrgPathToClip
        ClipWait
        paths.push(clipboard)
    } catch _error {
        LogError(_error)
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetDopusPaths(_WinID) {
;─────────────────────────────────────────────────────────────────────────────
    global paths

    try {
        ; Configure parameters to get paths via DOpus CLI (dopusrt)
        WinGet, _exe, ProcessPath, ahk_id %_WinID%
        _dir := StrReplace(_exe, "\dopus.exe")
        _result := _dir "\paths.xml"

        ; Arg comma needs escaping: `,
        RunWait, dopusrt.exe /info %_result%`,paths, %_dir%
        
        Loop, read, % _result
        {
            if (A_Index > 2) {  ; skip first lines
                ; Backward: omit closing </path> tag + possible short path C:\
                _start := InStr(A_LoopReadLine, ">",, -10)

                ; Forward: omit ">" char at the beginning, omit closing </path> tag at the end
                if (_start && _path := SubStr(A_LoopReadLine, _start + 1, -7))
                    paths.push(_path)
            }
        }
    } catch _error {
        LogError(_error)
    }
    Return
}

;─────────────────────────────────────────────────────────────────────────────
;
GetPaths() {
;─────────────────────────────────────────────────────────────────────────────

    ; Update the values after each call
    global paths := []
    
    ; Save clipboard to restore later
    ClipSaved := ClipboardAll
    Clipboard := ""

    WinGet, _allWindows, list
    Loop, %_allWindows% {
        _WinID := _allWindows%A_Index%
        WinGetClass, _WinClass, ahk_id %_WinID%

        switch _WinClass {
            case "CabinetWClass":       GetWindowsPaths(_WinID)
            case "ThunderRT6FormDC":    GetXyplorerPaths(_WinID)
            case "TTOTAL_CMD":          GetTotalCommanderPaths(_WinID)
            case "dopus.lister":        GetDopusPaths(_WinID)
        }
    }

    ; Restore
    Clipboard := ClipSaved
    ClipSaved := ""
}


