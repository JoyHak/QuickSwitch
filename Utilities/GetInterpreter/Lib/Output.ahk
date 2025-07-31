StdOutVars(list, sep := A_Space) {  
    loop parse, list, sep
        result .= A_LoopField ':`t' %A_LoopField% '`n'
    
    return StdOut(RTrim(result, "`n")) 
}

StdOut(msg) {
    try
        FileAppend(msg "`n", "*")
    catch
        MsgBox(msg "`n")
        
    return false
}

StdErr(msg) {
    try
        FileAppend(msg "`n", "**")
    catch
        MsgBox(msg "`n", A_ScriptName " error", "Iconx")
        
    return false
}

FileErr(msg, fileName) => StdErr(msg ':`n' OsError(A_LastError).Message '`n`n' fileName)

RequirementError(require, ScriptPath) {    
    return StdOut(
    (
        'Unable to locate the appropriate interpreter to build this script.
        
        Script:`t' ScriptPath '
        Requires: `t' StrReplace(require, ',', ' ')
    ))
}

StdException(ex, *) {
    if ex.what
        ex.what .= ": "  
    
    return StdErr(ex.what . ex.message . "`n" . ex.extra)
}

OnError StdException


ShowTooltip(text) {
	ToolTip Format("{}", text)             
    SetTimer ToolTip, -2000
}

