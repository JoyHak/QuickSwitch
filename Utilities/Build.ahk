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
winRar      := FindFile('C:\Program Files\WinRAR\WinRar.exe')                           ; WinRar: creates SFX archive and a separate archive with the source code
resHacker   := FindFile('C:\Program Files (x86)\Resource Hacker\ResourceHacker.exe')    ; Resource Hacker: copies the version and description of the script in SFX

; Comment all unnecessary variables below
archiveIcon := FindFile(scriptDir '\' scriptName '*.ico')       ; Icon of the final SFX. Only .ICO files, .exe is not allowed. Defaults to the archive icon.
archiveName := scriptBase '.exe'                                ; Name of the final SFX.
extractDir  := scriptName                                       ; Extract SFX into the directory relative to current dir. Defaults to the current dir.

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
try TraySetIcon(winRar)
if !IsDir(outDir)
    DirCreate(outDir)


ShowTooltip("Building started")

; Comment unnecessary OS architectures
Build('64')
Build('32')

ShowTooltip("Building complete")


Build(bitness := '') {
    global autohotkey, ahk2exe, winRar, scriptPath, scriptDir, outDir, outName, archiveIcon, archiveName, extractDir, dependencies, library

    ; ── Assemble .ahk to .exe ──────────────────────────────────────────────────────────────────────────────────────

    outExe := outDir . '\' outName
    if bitness
        autohotkey := RegExReplace(autohotkey, '\d{2}.exe', bitness ".exe")

    Exec(
        '`"' ahk2exe '`" /in `"' scriptPath '`" /out `"' outExe '`" /base `"' autohotkey '`"',
        'Failed to build the script using Ahk2Exe'
    )

    if !IsSet(winRar)
        return

    ; ── Prepare WinRAR ──────────────────────────────────────────────────────────────────────────────────────────────

    ; Switches documentation: https://documentation.help/WinRAR/HELPSwitches.htm
    ; (a)rchive, (-cfg-)ignore default config, (-s)olid, (-t)est after packaging, (-k)block archive changes, (-y)es to all prompts,
    ; (-m0)no compression [to prevent antivirus and scan issues],
    ; (-ep1)exclude current base dir, (-sfx)self extracting, (-scu)UTF-16 config, (-z)path to config,
    ; archive name, files and dirs to include.
    static switches := 'a -cfg- -s -t -k -y -m0 -ep1'

    ; Prepare arguments for WinRar in readable form, add quotes
    logName    := outDir '\SfxBuild.log'  ; Doesn't work with relative path
    rar        := '`"' winRar '`" ' switches ' -ilog`"' logName '`"'

    sfxModule  := '-sfxDefault' . ((bitness = '32') ? '32.sfx' : '.sfx')
    sfxConfig  := '-z`"' . CreateSfxConfig(IsSet(extractDir) ? extractDir '\' outName : outName) . '`"'

    sfxIcon    := IsSet(archiveIcon)   ?   '-iicon`"' archiveIcon '`"'   :  ''
    extractTo  := IsSet(extractDir)    ?   '-ap`"' extractDir '`"'       :  ''
    sfxName    := IsSet(archiveName)   ?   archiveName                   :  outName
    scriptDeps := IsSet(dependencies)  ?   dependencies                  :  ''
    scriptLib  := IsSet(library)       ?   library                       :  ''

    ; Append file postfix
    SplitPath(sfxName,,, &sfxExtension, &sfxBase)

    ; ── Archive .exe and it's dependencies to SFX ──────────────────────────────────────────────────────────────────

    if bitness
        sfxName := sfxBase '-x' bitness '.' sfxExtension

    try {
        if (sfxName = outName) {
            FileMove(outExe, outExe '.tmp')
            outExe .= '.tmp'
        }
    } catch {
        return FileErr('Unable to rename the script to avoid conflict of names', outExe)
    }

    SafeDelete(outDir '\' sfxName)
    Exec(
        rar ' -sfx -scu ' sfxModule ' ' sfxConfig ' ' sfxIcon ' ' extractTo ' `"' sfxName '`" `"' outExe '`" ' scriptDeps,
        'Failed to build the script into SFX',
        logName
    )
    SetVersionInfo(outExe, sfxName)

    ; ── Archive source code ────────────────────────────────────────────────────────────────────────────────────────

    static isArchived    := false
    static archExtension := '.zip'

    archName      := sfxBase . archExtension
    archExtension := '-af' archExtension

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
            rar ' ' archExtension ' ' extractTo ' `"' archName '`" `"' outScript '`" ' scriptDeps ' ' scriptLib,
            'Failed to archive source code',
            logName
        )

        isArchived := true
    }

    ; Delete created files
    try FileDelete(outExe)
    try FileDelete(outScript)
    try FileDelete(outDir '\*.log')
    sleep 200

    return true
}


CreateSfxConfig(app) {
    ; Config documentation: https://documentation.help/WinRAR/HELPGUISFXScript.htm
    global outDir
    static config := outDir '\SfxConfig.ini'
    ; try FileDelete(config)  ; It's faster to reuse existing config

    if IsFile(config) {
        IniWrite('`"' app '`"', config, 'Global', 'Setup')
        return config
    }

    IniWrite('Setup=`"' app '`"`nSilent=1', config, 'Global')
    loop 10 {
        sleep 200
        if IsFile(config)
            break
    }

    return config
}


SetVersionInfo(source, target) {
    global resHacker
    if !IsSet(resHacker)
        return false

    logName := 'VersionInfo.log'
    hacker  := '`"' resHacker '`" -log `"' logName '`"'

    Exec(cmd, errorMsg) {
        if RunWait(cmd,, "Hide") {
            StdErr(errorMsg ':`n' FileRead(logName) '`n`nSee details in ' logName)
            ExitApp 1
        }

        return true
    }

    Exec(
        hacker ' -open `"' source '`" -save VersionInfo.rc -action extract -mask VersionInfo',
        'Failed to get resource from ' source
    )

    Exec(
        hacker ' -open VersionInfo.rc -save VersionInfo.res -action compile',
        'Failed to compile resource'
    )

    Exec(
        hacker ' -open `"' target '`" -save `"' target '`" -resource VersionInfo.res -action AddOverwrite -mask VersionInfo',
        'Failed to update VersionInfo for ' target
    )

    try FileDelete('VersionInfo*')
    try FileDelete(logName)
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