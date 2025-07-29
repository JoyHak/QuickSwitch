StdOut(msg) {
    try
        FileAppend(msg "`n", "*")
    catch
        MsgBox(msg "`n")
}

StdErr(msg) {
    try
        FileAppend(msg "`n", "**")
    catch
        MsgBox(msg "`n", A_ScriptName " error", "Iconx")
}

StdOutVars(list, sep := A_Space) {  
    loop parse, list, sep
        result .= A_LoopField ':`t' %A_LoopField% '`n'
    
    StdOut(RTrim(result, "`n")) 
}

RequirementError(require, ScriptPath) {    
    StdOut(
    (
        'Unable to locate the appropriate interpreter to build this script.
        
        Script:`t' ScriptPath '
        Requires: `t' StrReplace(require, ',', ' ')
    ))
}

StdException(ex, *) {
    if ex.what
        ex.what .= ": "  
    
    StdErr(ex.what . ex.message . "`n" . ex.extra)
}

OnError StdException

