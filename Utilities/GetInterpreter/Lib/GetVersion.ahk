GetIntegerVersion(v) {
    Loop Parse, v, '.-+'
        return Integer(A_LoopField)
    throw ValueError('Invalid version number', -1, v)
}

ParseRequires(s) {
    return RegExMatch(s, 'i)^(?!(?:32|64)-bit$)(?<op>[<>=]*)v?(?<version>(?<major>\d+)\b\S*)', &m) ? m : 0
}

ChooseVersion(ScriptPath, require:='', prefer:='') {
    majors := Map()
    Loop 2
        if f := LocateAhk(A_Index ',' require, prefer)
            majors[A_Index] := f
    switch majors.Count {
    case 1:
        for , f in majors
            return f
    case 0:
        StdErr('Failed to locate any interpreters')
        return {Path: ROOT_DIR, Version: A_AhkVersion}
    }
    
    RequirementError(require, ScriptPath)
} 