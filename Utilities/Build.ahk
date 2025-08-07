; Builds AHK script, it's dependencies (scripts, files, directories, ...) into self-extracting archive (SFX).
; Selects an interpreter based on the script.
; It passes only two parameters to Ahk2exe: /in, /out, /base.
; Other parameters must be replaced with Ahk2exe directives inside the target script.

#Requires AutoHotkey v2.0.19
#Include 'GetInterpreter\GetInterpreter.ahk'
#SingleInstance ignore
#Warn


; ── Variables ──────────────────────────────────────────────────────────────────────────────────────────────────────
; ── Script
scriptName := 'QuickSwitch'                     ; Internal name
scriptDir  := GetParentDirectory(A_ScriptDir)   ; Directory with script and dependencies
scriptPath := FindFile(scriptDir '\' scriptName '*.ahk',, &scriptBase := '')
outDir     := scriptDir '\Releases'             ; Directory where the final SFX will be created
outName    := scriptName '.exe'                 ; Rename script and place it in the SFX. Replace with scriptBase if you don't want to rename it.

; ── Interpreter
autohotkey    := GetInterpreter(scriptPath)
autohotkeyDir := GetParentDirectory(autohotkey, 2)
ahk2exe       := FindFile(autohotkeyDir '\Compiler\Ahk2Exe.exe')

; ── Archiver (comment what you don't need)
sevenZipDir := VerifyRegistryPath("SOFTWARE\7-zip", "Path")                             ; Path to CLI version to create archives
sevenZip    := FindFile(sevenZipDir '\7zG.exe')
archiveName := scriptBase '.zip'

; Write the list of files / dirs that you need to archive with the final .exe: icons, dependencies, readme, ...
; Relative to scriptDir or absolute paths are allowed. You can change 'relativeTo' param.
; .exe will be included so you don't need to include it here.
; Leave blank if the script has no dependence (e.g. single script).
dependencies := GetDependenciesPaths(scriptDir, 'Icons|Favorites')
; Write the list of source .ahk files / their dirs that you need to archive with the main .ahk script (zip archive)
; Comment the variable if you need SFX only. Leave blank if the script has no other source files (e.g. single script).
library      := GetDependenciesPaths(scriptDir, 'Lib')

; ── Build .ahk and it's dependencies  ────────────────────────────────────────────────────────────────────────────

SetWorkingDir(outDir)
if !IsDir(outDir)
    DirCreate(outDir)


ShowTooltip("Building started")

; Comment unnecessary OS architectures
Build('64')
Build('32')
 
ShowTooltip("Building complete")


Build(bitness := '') {
    global autohotkey, ahk2exe, sevenZip, scriptPath, scriptDir, outDir, outName, archiveName, extractDir, dependencies, library

    ; ── Assemble .ahk to .exe ──────────────────────────────────────────────────────────────────────────────────────

    outExe := outDir . '\' outName
    if bitness
        autohotkey := RegExReplace(autohotkey, '\d{2}.exe', bitness ".exe")
    
    Exec(
        '`"' ahk2exe '`" /in `"' scriptPath '`" /out `"' outExe '`" /base `"' autohotkey '`"',
        'Failed to build the script using Ahk2Exe'
    )
     
    if !(IsSet(sevenZip) && IsSet(sevenZipDir))
        return

    ; ── Prepare 7-zip ──────────────────────────────────────────────────────────────────────────────────────────────

    ; Switches documentation: https://documentation.help/7-Zip/index6.htm
    ; (a)rchive, (-y)es to all prompts, (-sae)exact archive name
    ; (-mx=0)no compression [to prevent antivirus and scan issues],
    ; archive name -- files and dirs to include.
    static switches := 'a -y -sae -mx=0'

    ; Prepare arguments for 7-zip in readable form, add quotes
    archName   := IsSet(archiveName)   ?   archiveName                   :  outName
    scriptDeps := IsSet(dependencies)  ?   dependencies                  :  ''
    scriptLib  := IsSet(library)       ?   library                       :  ''

    SplitPath(archName,,, &archExtension, &archBase)
    if (archExtension = 'exe')
        archExtension := 'zip'
       
    zip := '`"' sevenZip '`" ' switches
    
    ; ── Archive source code ────────────────────────────────────────────────────────────────────────────────────────

    static isArchived := false    
    archName := archBase '.' archExtension

    if !isArchived {
        try {
            outScript := scriptPath

            ; Give the source script a similar outName and put in the archive
            outBase   := SubStr(outName, 1, InStr(outName, '.',, -1))
            outScript := outDir '\' outBase 'ahk'
            FileCopy(scriptPath, outScript)

        } catch {
            return FileErr('Unable to rename the source script', scriptPath)
        }

        SafeDelete(outDir '\' archName)        
        Exec(
            zip ' `"' archName '`" `"' outScript '`" ' scriptDeps ' ' scriptLib,
            'Failed to archive source code'
        )
        
        isArchived := true
    }

    ; ── Archive .exe and it's dependencies ─────────────────────────────────────────────────────────────────────────

    if bitness
        archName := archBase '-x' bitness '.' archExtension

    SafeDelete(outDir '\' archName)    
    Exec(
        zip ' `"' archName '`" `"' outExe '`" ' scriptDeps,
        'Failed to archive executable'
    )       
    
    ; Delete created files
    try FileDelete(outExe)
    try FileDelete(outScript)
    try FileDelete(outDir '\*.log')    
    sleep 200

    return true
}


Exec(cmd, errorMsg, cmdLog := '', returnOutput := false) {
    global outDir
    EolTrim(text) => Trim(text, ' `t`r`n')
        
    consoleLog := 'Console.log'
    if RunWait(A_ComSpec ' /c (' cmd ') > ' consoleLog ' 2>&1', outDir, "Hide") {
        output := EolTrim(FileRead(consoleLog))
        if cmdLog
            output .= '`n`n' EolTrim(FileRead(cmdLog))
        else
            cmdLog := consoleLog
                        
        if (output := EolTrim(output))
            errorMsg .= ':`n`n' output
        
        StdErr(errorMsg '`n`nSee details in ' cmdLog)        
        FileAppend('`nExecuted command:`n' cmd, cmdLog)        
        
        ExitApp 1
    }
    
    return returnOutput ? EolTrim(FileRead(consoleLog)) : true
}