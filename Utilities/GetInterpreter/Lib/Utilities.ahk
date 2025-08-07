IsDir(path) {
    static shlwapi := DllCall('GetModuleHandle', 'str', 'Shlwapi', 'ptr')
    static IsPath  := DllCall('GetProcAddress', 'Ptr', shlwapi, 'astr', 'PathIsDirectoryW', 'ptr')
    return DllCall(IsPath, 'str', path)
}

IsFile(path) {
    static shlwapi := DllCall('GetModuleHandle', 'str', 'Shlwapi', 'ptr')
    static IsFile  := DllCall('GetProcAddress', 'Ptr', shlwapi, 'astr', 'PathFileExistsW', 'ptr')
    return DllCall(IsFile, 'str', path)
}

GetParentDirectory(path, offset := 1) => SubStr(path, 1, InStr(path, '\',, -1, -offset) - 1)

FindFile(path, recursive := 'R', &base := '') {
    if IsFile(path)
        return path
    
    loop files, path, recursive {
        base := StrReplace(A_LoopFileName, '.' A_LoopFileExt)
        return A_LoopFileFullPath
    }
    
    StdErr('Unable to locate the file: `'' path '`'. Script will be terminated.')
    ExitApp
}

SafeDelete(path, attempts := 10, timeout := 200) {
    try {
        loop attempts {
            FileDelete(path)
            Sleep(timeout)
            if !IsFile(path)
                return true        
        }
        return false
    }    
    return true
}

GetDependenciesPaths(relativeTo, list, sep := '|') {   
    FindDependency(&path) {
        loop files, path, 'D' {
            return A_LoopFileFullPath
        }
        return ''
    }
    
    if !IsDir(relativeTo) {
        StdOut('Non-existing directory for the relative path of dependencies: ' relativeTo)
        return ''
    }
    
    paths := ''
    loop parse, list, sep {
        if !(IsFile(
                (&path := A_LoopField)
             && (&path := relativeTo '\' A_LoopField)
        ) && (path := FindDependency(&path))) {
            StdOut('Unable to find the dependency: ' relativeTo '\' A_LoopField)
            continue
        }
        
        paths .= '"' path '" '
    }
    
    return Trim(paths)
}