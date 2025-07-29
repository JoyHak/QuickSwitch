; Builds AHK script, it's dependencies (scripts, files, directories, ...) into self-extracting archive (SFX). 
; Selects an interpreter based on the script.
; It passes only two parameters to Ahk2exe: /in, /out, /base.
; Other parameters must be replaced with Ahk2exe directives inside the target script.

#Requires AutoHotkey v2.0.19
#Include 'GetInterpreter\GetInterpreter.ahk'
#SingleInstance force
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
winRar      := FindFile('C:\Program Files\WinRAR\WinRar.exe')   ; WinRar: creates SFX archive and a separate archive with the source code
resHacker   := FindFile('C:\Program Files (x86)\Resource Hacker\ResourceHacker.exe')    ; Resource Hacker: copies the version and description of the script in SFX
; Comment all unnecessary variables below    
sfxIcon     := FindFile(scriptDir '\' scriptName '*.ico')       ; Icon of the final SFX. Only .ICO files, .exe is not allowed. Defaults to the archive icon.
sfxName     := scriptBase '.exe'                                ; Name of the final SFX.
extractTo   := scriptName                                       ; Remove extract SFX into the directory relative to current dir. Defaults to the current dir.

; Write the list of files / dirs that you need to archive with the final .exe: icons, dependencies, readme, ...
; Relative to scriptDir or absolute paths are allowed. You can change 'relativeTo' param.
; .exe will be included so you don't need to include it here. 
; Leave blank if the script has no dependence (e.g. single script).
dependencies := GetDependenciesPaths(scriptDir, 'Icons|Favorites')
; Write the list of source .ahk files / their dirs that you need to archive with the main .ahk script (zip archive)
; Comment the variable if you need SFX only. Leave blank if the script has no other source files (e.g. single script).
library      := GetDependenciesPaths(scriptDir, 'Lib')

; ── Build .ahk and it's dependencies  ────────────────────────────────────────────────────────────────────────────

try TraySetIcon(sfxIcon)
if !IsDir(&outDir)
    DirCreate(outDir)

; Comment unnecessary OS architectures
Build('64')
; Build('32')


Build(architecture?) {
    global
    
    ; ── Assemble .ahk to .exe ──────────────────────────────────────────────────────────────────────────────────────
    
    outPath := outDir . '\' outName
    if IsSet(architecture)
        autohotkey := RegExReplace(autohotkey, '\d{2}.exe', architecture ".exe")
    
    ; Success code is 0
    if RunWait('`"' ahk2exe '`" /in `"' scriptPath '`" /out `"' outPath '`" /base `"' autohotkey '`"', scriptDir) {
        StdErr('Failed to build the script using Ahk2Exe:`t' scriptPath)
        StdOutVars("ahk2exe scriptPath outPath autohotkey")
        return false 
    }
    
    if !IsSet(winRar)
        return true
    
    ; ── Archive .exe and it's dependencies to SFX ──────────────────────────────────────────────────────────────────
    
    SetWorkingDir(outDir)
    
    ; Config documentation: https://documentation.help/WinRAR/HELPGUISFXScript.htm
    config := 'config.ini'
    try FileDelete(config)    
    
    runAfterExtraction := IsSet(extractTo) ? extractTo '\' outName : outName
    FileAppend(
    (
        'Title=`"' outName '`"                 
        Setup=`"' runAfterExtraction '`" 
        Silent=1'
    ), config, 'UTF-8')
    
    loop 10 {
        sleep 200
        if FileExist(config)
            break        
    }
    
    ; Switches documentation: https://documentation.help/WinRAR/HELPSwitches.htm
    ; (a)rchive, (-cfg-)ignore default config, (-s)olid, (-t)est after packaging, (-k)block archive changes, (-y)es to all prompts,
    ; (-m0)no compression [to prevent antivirus and scan issues], 
    ; (-ep1)exclude current base dir, (-sfx)self extracting, (-scf)UTF-8 config, (-z)path to config,
    ; archive name, files and dirs to include.
    switches   := 'a -cfg- -s -t -k -y -m0 -ep1'
        
    ; Prepare arguments for WinRar in readable form, add quotes
    sfxModule  := '-sfxDefault' . ((architecture = '32') ? '32.sfx' : '.sfx')
    sfxConfig  := '-z`"' config '`"'    
    sfxIcon    := IsSet(sfxIcon)       ?   '-iicon`"' sfxIcon '`"'   :  ''
    extractTo  := IsSet(extractTo)     ?   '-ap`"' extractTo '`"'    :  ''
    sfxName    := IsSet(sfxName)       ?   sfxName                   :  outName

    ; Append file postfix
    SplitPath(sfxName,,, &sfxExtension, &sfxBase)
    if IsSet(architecture)
        sfxBase .= '-x' architecture        
    
    try {
        ; Updated base will be used later
        sfxName := sfxBase "." sfxExtension  

        if (sfxName = outName) {
            FileMove(outPath, outPath '.tmp')
            outPath .= '.tmp'
        }
    } catch as moveEx {
        return StdErr('Unable to rename the script to avoid conflict of names:`n' 
                     . OsError(A_LastError).Message) '`n`n' outPath
    }
    
    ; Prepare errors output
    logName := sfxBase '.log'
    sfxLog  := '-ilog`"' logName '`"'
    
    ; Delete old archives
    try FileDelete(sfxBase '*')
        
    ; Success code is 0
    command := '`"' winRar '`" ' switches ' -sfx -scf ' sfxModule ' ' sfxConfig ' ' sfxLog ' ' sfxIcon ' ' extractTo ' `"' sfxName '`" `"' outPath '`" ' dependencies
    if RunWait(command) {
        FileAppend('`n`nExecuted command:`n`n' command, logName)    
        return StdErr('Failed to build the script into SFX:`n`n' FileRead(logName))
    }
    
    command := '`"' winRar '`" ' switches ' -afzip ' sfxLog ' ' extractTo ' `"' sfxBase '.zip`" `"' scriptPath '`" ' dependencies ' ' library
    if RunWait(command) {
        FileAppend('`n`nExecuted command:`n`n' command, logName)    
        return StdErr('Failed to archive source code:`n`n' FileRead(logName))
    }
    
    if !IsSet(resHacker)
        goto success
        
    ; ── Change SFX VersionInfo (description, company, ...) ─────────────────────────────────────────────────────────
        
    ; Prepare output
    logName := 'VersionInfo.log'
    err(msg) => StdErr('VersionInfo error: ' msg '`n`n' FileRead(logName))
    resHacker := '`"' resHacker '`" -log ' logName 
    
    if RunWait(resHacker ' -open `"' outPath '`" -save VersionInfo.rc -action extract -mask VersionInfo')
        return err('Failed to get resource')

    if RunWait(resHacker ' -open VersionInfo.rc -save VersionInfo.res -action compile')
        return err('Failed to compile resource')
    
    if RunWait(resHacker ' -open `"' sfxName '`" -save `"' sfxName '`" -resource VersionInfo.res -action AddOverwrite -mask VersionInfo')
        return err('Failed to update VersionInfo')
    
    ; Delete created files
    success:
    try FileDelete('VersionInfo*')
    try FileDelete(outPath)
    try FileDelete(config)
    
    return true
}