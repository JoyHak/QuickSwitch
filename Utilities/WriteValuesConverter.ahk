; Converts variable declarations from SetDefaultValues() 
; into vertically aligned assignments with quoted names for WriteValues()

#Requires AutoHotKey v2.0.19
#Warn
#SingleInstance force

KeyHistory(0)
ListLines(false)

SetKeyDelay(-1, -1)
SetWinDelay(-1)
SetWorkingDir(A_ScriptDir)
try TraySetIcon('Converter.ico')


ui := Gui("-DpiScale")

ui.SetFont("q5 s13", "Maple mono")
cData := ui.Add("Edit", "w1290 h900 vData")

ui.Add("Button", "+Default", "Convert").OnEvent("Click",     (*) => (cData.value := Convert()))
ui.Add("Button", "yp x+5", "◁").OnEvent("Click",             (*) => (cData.value := Convert(true)))
ui.Add("Button", "yp x+5", "▷").OnEvent("Click",             (*) => (cData.value := Convert(, true)))
     
ui.Add("Button", "yp x+5", "Copy").OnEvent("Click",          (*) => (A_Clipboard := ui.Submit(0).data))
ui.Add("Button", "yp x+5 Section", "Clear").OnEvent("Click", (*) => (cData.value := ""))

ui.Add("Checkbox", "ys+11 x+15 vIsSection", "Section").OnEvent("Click", (*) => (cData.value := Convert()))

ui.Add("Text", "ys+11 x+10", "Quote")
cQuote := ui.Add("DropDownList", "ys+6 w40 x+5 Choose1 vQuote", ["`"", "`'"])

ui.Add("Text", "ys+11 x+20", "Indent. size")
ui.Add("Edit", "ys+6 w40 x+5")
ui.Add("UpDown", "vIndentSize Range1-100", 4)

ui.Add("Text", "ys+11 x+20", "Move level")
ui.Add("Edit", "ys+6 w40 x+5")
ui.Add("UpDown", "vTrimLevel Range1-100", 1)

ui.Add("Text", "ys+11 x+20", "Min. padding")
ui.Add("Edit", "ys+6 w40 x+5")
ui.Add("UpDown", "vMinPadding Range1-100", 4)

ui.OnEvent("Escape", (*) => ui.Destroy())
ui.Show()


Convert(moveLeft := false, moveRight := false) {
    global ui
    u := ui.Submit(0)
    
    output := ""  ; Output string for the formatted result
    maxLen := 0   ; Maximum variable name length for alignment

    ; Build an array of spaces + variable names to determine max length
    variables := []
    quote     := ""
    
    loop parse, u.data, "`n", "`r" {                    
        if RegExMatch(A_LoopField, "S)^[ \t]*([`"`']?)(\w+)", &match) {            
            if moveLeft {
                ; SubStr if there are spaces / tabs in the string,
                ; i.e. the starting position is less than variable pos.
                var := SubStr(match[0], Min(u.IndentSize * u.TrimLevel + 1, match.pos(2)))
            } else if moveRight {
                ; Fill additional spaces
                var := Format("{:" (u.IndentSize * u.TrimLevel) "}{}", "", match[0])       
            } else {
                ; Whole pattern: spaces + variable name
                var := match[0]          
            }

            variables.Push(var)      ; spaces + name
            len := StrLen(match[2])  ; var. name 
            if (len > maxLen)
                maxLen := len
                
            if match[1]
                quote := match[1]   ; Section opening quote
        }
    }

    if !variables.length
        return ""

    if (!u.IsSection && quote) {
        ; Increase the length of the variable for the correct alignment of the last quote in the line
        variables[1] := " " variables[1]
    }
    
    ; Apply vertical alignment
    for var in variables {
        varName := Trim(var, " `"`'`t")
        
        ; Fill the string with spaces
        padding := Format("{:" (maxLen - StrLen(varName) + u.MinPadding) "}", "")        
        output .= var . "=" u.quote . padding . varName . padding . u.quote . "`n"
    }

    if u.IsSection {  
        ; Add section parenthesis and opening quote (if needed)
        indent := ""

        ; Get 1st variable padding
        if RegExMatch(variables[1], "S)(^[ \t]*)([`"`']?)(\w+)", &match) {
            padding := match[1] 
            ; The section indent level is 1 less than the variable padding
            indent  := SubStr(padding, Min(u.IndentSize * u.TrimLevel + 1, match.pos(3)))
        }
        
        if quote {
            if (quote != u.quote) {
                ; Opening quote does not match with the chosen
                output := StrReplace(output, quote, u.quote,,, 1)
            }

            ; Open quote found, don't add again 
            return indent . "(`n" . RTrim(output, "`n") . "`n" . indent . ")"
        }
        
        ; No open quote: add quote, reduce padding by 1 for correct alignment
        return indent . "(`n" . SubStr(padding, 2) . u.quote . Trim(output, " `"`'`t`n") . "`n" . indent . ")"
    }   
    
    ; Delete the opening quote if it was added
    return quote
      ? StrReplace(RTrim(output, "`n"), quote,,,, 1) 
      : RTrim(output, "`n")
}
