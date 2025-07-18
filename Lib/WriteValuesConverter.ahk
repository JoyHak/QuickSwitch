; Converts variable declarations from SetDefaultValues() for WriteValues() 

#Requires AutoHotkey v1.1.37.02 Unicode
#Warn
#NoEnv
#SingleInstance force
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetWinDelay, -1
SetWorkingDir, % A_ScriptDir

Gui, Font, q5 s10, Maple mono
Gui, Add, Edit, w640 h480 vPost
Gui, Add, Button, gUpdate, Convert
Gui, Add, Button, yp x+5 gCopy,  Copy
Gui, Add, Button, yp x+5 gClear, Clear
Gui, Show
return


GuiEscape() {
    ExitApp
}

GuiClose() {
    ExitApp
}

Update() {
    global Post
    
    Gui, Submit, NoHide
    GuiControl,, Post, % Convert(Post)
}

Copy() {
    global Post
    Gui, Submit, NoHide
    Clipboard := Post
}

Clear() {
    global Post
    
    Gui, Submit, NoHide
    GuiControl,, Post
}

; Converts variable declarations into vertically aligned assignments with quoted names
Convert(Post) {
    output := ""                  ; Output string for the formatted result
    maxLen := 0                   ; Maximum variable name length for alignment
    
    ; Build an array of variable names to determine max length
    varArr := []
    Loop, Parse, Post, `n, `r
    {
        line := A_LoopField
        if (Trim(line) = "")
            continue
        RegExMatch(line, "^[ \t]*(\w+)", varName)
        if (varName != "") {
            varArr.Push(varName)
            if (StrLen(varName) > maxLen)
                maxLen := StrLen(varName)
        }
    }

    ; Find max length for left part (VarName=)
    eqLen := 0
    for i, varName in varArr
    {
        if (StrLen(varName) > eqLen)
            eqLen := StrLen(varName)
    }
    eqLen += 1 ; for the "="

    ; Create the output with vertical alignment
    for i, varName in varArr
    {
        var := varName . "="
        leftPad := ""
        Loop, % eqLen - StrLen(var)
            leftPad .= " "

        rightPad := ""
        Loop, % maxLen - StrLen(varName)
            rightPad .= " "
        output .= var . """ " . leftPad . varName . rightPad . " """ . "`n"
    }
    return output
}
