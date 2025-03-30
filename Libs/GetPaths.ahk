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

ShowShortPath(ByRef _path) {
    /*
        _fullPath is shortened to the last N dirs (DirsCount) starting from the end of the path.
        Dirs are selected as intervals between slashes, excluding them.
        boundaries = indexes of any slashes \ / in the path: /dir/dir/
    */
    global CutFromEnd, DirsCount, DirNameLength, ShowDriveLetter, PathSeparator, ShortNameIndicator

    ; Return input path if it's really short
    _length := StrLen(_path)
    if _length < 4
        Return _path    ; Just drive and slash

    ; Declare variable to return
    if ShowDriveLetter {
        SplitPath, _path,,,,, _letter
        _shortPath := _letter
    } else {
        _shortPath := ""
    }


    ; The number of slashes (indexes) is one more than the number of dirs: /f1/f2/ - 2 dirs, 3 slashes
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
    if CutFromEnd {
        ; Reverse slash search until enough is found
        ; to display the required number of dirs
        _pathIndex    := _length
        _slashesCount := _maxSlashes
        while (_pathIndex >= 3 and _slashesCount >= 1) {     ; 3 is pos of the 1st slash
            _char := SubStr(_fullPath, _pathIndex, 1)
            if (_char == "/" || _char == "\") {
                _slashIndexes[_slashesCount] := _pathIndex
                _slashesCount--
            }
            _pathIndex--
        }
        if (_slashesCount > _maxSlashes - 2)
            return _path     ; not enough to shorten the path

        _shortPath .= ShortNameIndicator     ; An indication that there are more paths after the drive letter
    } else {
        ; Direct search starting from the pos of the 1st slash
        _pathIndex    := 3
        _slashesCount := 1
        while (_pathIndex <= _length and _slashesCount <= _maxSlashes) {
            _char := SubStr(_fullPath, _pathIndex, 1)
            if (_char == "/" || _char == "\") {
                _slashIndexes[_slashesCount] := _pathIndex
                _slashesCount++
            }
            _pathIndex++
        }
        if (_slashesCount < 3)
            return _path     ; not enough to shorten the path
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
            _shortPath    .= PathSeparator . _dirName

            if (DirNameLength - _length < 0)
                _shortPath .= ShortNameIndicator

        }
    }
    _shortPath .= ShortNameIndicator     ; An indication that there are more paths after the last dir
    Return _shortPath
}

/*
    After execution XYscript waits for a signal and executes FeedXYdata
    to get XYdata from XYplorer to Autohotkey.

    Alternative variants are provided in Libs/Reserved, including v2
*/

XYscript(ByRef _WinID, ByRef _script) {
    _size := StrLen(_script)
    if !(A_IsUnicode) {
        VarSetCapacity(_data, _size * 2, 0)
        StrPut(_script, &_data, "UTF-16")
    } else {
        _data := _script
    }

    VarSetCapacity(COPYDATA, A_PtrSize * 3, 0)
    NumPut(4194305, COPYDATA, 0, "Ptr")
    NumPut(_size * 2, COPYDATA, A_PtrSize, "UInt")
    NumPut(&_data, COPYDATA, A_PtrSize * 2, "Ptr")

    Return DllCall("User32.dll\SendMessageW", "Ptr", _WinID, "UInt", 74, "Ptr", 0, "Ptr", &COPYDATA, "Ptr")
}

FeedXYdata(_wParam, _lParam) {
     global XYdata

     _stringAddress := NumGet(_lParam + 2 * A_PtrSize)
     _copyOfData := StrGet(_stringAddress)
     _cbData := NumGet(_lParam + A_PtrSize) / 2
     StringLeft, XYdata, _copyOfData, _cbData

     Return
}
OnMessage(0x4a, "FeedXYdata")

;─────────────────────────────────────────────────────────────────────────────
;
GetXYpaths(ByRef _WinID) {
;─────────────────────────────────────────────────────────────────────────────

    ; Put path(s) to XYdata (the variable is filled in anew each time it is called)
    ; then push to array
    global XYdata, VirtualPath, paths, virtuals

    _script =
    ( LTrim Join
        ::
        load('
            $paths = get("tabs_sf", "|");
            $reals = "";
            foreach($path, $paths, "|") {
                $reals .= "|" . pathreal($path);
            }
            $reals = replace($reals, "|",,,1,1);
            copydata %A_ScriptHwnd%, $reals, 2`;
        ',,s)`;
    )
    XYscript(_WinID, _script)

    Loop, parse, XYdata, `|
        paths.push(A_LoopField)

    if paths and VirtualPath {
        _script = ::copydata %A_ScriptHwnd%, get("tabs_sf", "|"), 2`;
        XYscript(_WinID, _script)
        Loop, parse, XYdata, `|
            virtuals.push(A_LoopField)

    }
}
;─────────────────────────────────────────────────────────────────────────────
;
GetWINpaths(ByRef _WinID) {
;─────────────────────────────────────────────────────────────────────────────
    global paths

    for _instance in ComObjCreate("Shell.Application").Windows {
        if (_WinID == _instance.hwnd) {
            _path := _instance.Document.Folder.Self.Path
            if !InStr(_path, "::{")
                paths.push(_path)

        }
    }
    Return
}

;─────────────────────────────────────────────────────────────────────────────
;
GetTCPaths(_WinID) {
;─────────────────────────────────────────────────────────────────────────────

    global paths
    ; Save clipboard to restore later
    ClipSaved := ClipboardAll
    Clipboard := ""

    ; wait a little, or source path may not be captured!
    Sleep, 50
    SendMessage 1075, 2029, 0, , ahk_id %_WinID%    ; CopySrcPathToClip
    Sleep, 50
    paths.push(clipboard)

    SendMessage 1075, 2030, 0, , ahk_id %_WinID%    ; CopyTrgPathToClip
    Sleep, 50
    paths.push(clipboard)

    ; Restore
    Clipboard := ClipSaved
    ClipSaved := ""

    Return
}

;─────────────────────────────────────────────────────────────────────────────
;
GetDOPUSPaths(_WinID) {
;─────────────────────────────────────────────────────────────────────────────
    global paths

    EnvGet, _temp, TEMP
    _dopusInfo := _temp . "\dopusinfo.xml"

    ; Arg comma needs escaping: `,
    _command = "%_dopus_exe%\..\dopusrt.exe" /info "%_dopusInfo%"`, paths
    Run, _command, , , DUMMY
    Sleep, 300
    FileRead, OpusInfo, %_dopusInfo%
    Sleep, 300
    FileDelete, %_dopusInfo%

    ; Get active path of this lister (regex instead of XML library)
    RegExMatch(OpusInfo, "mO)^.*lister=\""" . _WinID . "\"".*tab_state=\""1\"".*\>(.*)\<\/path\>$", out)
    _path := out.Value(1)
    paths.push(_path)

    ; Get passive path of this lister
    RegExMatch(OpusInfo, "mO)^.*lister=\""" . _WinID . "\"".*tab_state=\""2\"".*\>(.*)\<\/path\>$", out)
    _path := out.Value(1)
    paths.push(_path)

    Return
}

;─────────────────────────────────────────────────────────────────────────────
;
GetPaths() {
;─────────────────────────────────────────────────────────────────────────────

    ; Update the values after each call
    global paths    := []
    global virtuals := []

    global VirtualPath
    IniRead, VirtualPath, %INI%, Menu, VirtualPath, %VirtualPath%

    WinGet, _allWindows, list
    Loop, %_allWindows% {
        _WinID := _allWindows%A_Index%
        WinGetClass, _thisClass, ahk_id %_WinID%

        if (_thisClass == "CabinetWClass")
            GetWINpaths(_WinID)
        if (_thisClass == "ThunderRT6FormDC")
            GetXYpaths(_WinID)
        if (_thisClass == "dopus.lister")
            GetDOPUSPaths(_WinID)
        if (_thisClass == "TTOTAL_CMD")
            GetTCPaths(_WinID)

   }
}


