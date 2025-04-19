GetPaths() {
    /*  
        Requests paths from all applications whose window class 
        is recognized as a known file manager class (in Z-order).
        Updates the global array after each call 
    */    
    global Paths := []
    
    WinGet, _winIdList, list, ahk_group ManagerClasses		
    Loop, % _winIdList {
        _winId := _winIdList%A_Index%      
        WinGetClass, _winClass, ahk_id %_winId%

        Func(_winClass).call(_winId)    
    }
}

;─────────────────────────────────────────────────────────────────────────────
;
GetShortPath(ByRef path) {
;─────────────────────────────────────────────────────────────────────────────
    /*
        Full path is shortened according to user-specified global parameters 
        by shortening directory names to the specified length starting at the beginning 
        and separating them with the specified delimiter. 
        Additional options may change the final view.
    */
    global ShortenEnd, DirsCount, DirNameLength, ShowDriveLetter, PathSeparator, ShortNameIndicator, ShowFirstSeparator
    
    try {
        ; Return input path if it's really short
        if (StrLen(path) < 4)
            return path    ; Just drive and slash
        
        path  := RTrim(path, "\")
        _dirs := StrSplit(path, "\")
        _size := _dirs.count()
        
        if (_size = 1)
            return path
            
        ; Variable to return
        _shortPath := ShowDriveLetter ? _dirs[1] : ""
        
        ; Parse the _dirs array, omit drive letter
        if ShortenEnd {
            _index := 2
            _stop  := Min(DirsCount + 1, _size)
        } else {
            _index := Max(2, _size - DirsCount + 1)
            _stop  := _size
            
            ; An indication that there are more paths after the drive letter
            _shortPath .= ShortNameIndicator     
        }

        ; Add first separator if needed
        if (ShowFirstSeparator || ShowDriveLetter)
            _shortPath .= PathSeparator

        loop, % _size {
            _dir := _dirs[_index]
            _length  := StrLen(_dir)
            _dirName := SubStr(_dir, 1, Min(_length, DirNameLength))
            
            _shortPath .= _dirName
            if (_length > DirNameLength)
                _shortPath .= ShortNameIndicator
            
            if (_index == _stop)
                break

            _shortPath .= PathSeparator
            _index++
        }
        
        ; The shortened path fits into DirsCount 
        ; but there are still directories remaining
        if ((_index != _size) && (_length <= DirNameLength))
            _shortPath .= ShortNameIndicator

    } catch _error {
        LogError(_error)
        return path
    }
    return _shortPath
}


