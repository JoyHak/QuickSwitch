$ErrorActionPreference = 'Stop'

$scriptPath = "$PSScriptRoot\..\QuickSwitch.ahk"
$scriptBase =  Split-Path $scriptPath -leafBase
$scriptDir  =  Split-Path $scriptPath -parent
$scriptVersion = ''

$outDir     = "$scriptDir\Releases"
$outExe     = "$outDir\$scriptBase.exe"

$sevenZip   = 'C:\Program Files\7-Zip\7z.exe'
$autoHotkeyDir = 'C:\Program Files\AutoHotkey'
$compiler   = "$autoHotkeyDir\Compiler\Ahk2Exe.exe"

Set-Location $outDir

$compileParams = @(
    '/in',    $scriptPath, 
    '/out',   $outExe, 
    '/base', "$autoHotkeyDir\AutoHotkeyU64.exe"
)

$zipParams  = @(
    'a',    # archive
    # '-bb1', # verbose output
    '-bso0', # disable non-error messages
    '-y',   # "yes" to all prompts (silent)
    '-aoa', # overwrite without prompts (silent)
    '-sae', # exact archive name  
    '-mx=0' # no compression (to prevent antivirus and scan issues)
)

$zipPaths = @(
    "$outExe",  # main file
    "$scriptDir\Icons", 
    "$scriptDir\Favorites"
)

ForEach($bitness in @('32', '64')) {
    $interpreterPath = "{0}\AutoHotkeyU{1}.exe" -f `
        $autoHotkeyDir, $bitness
    
    &$compiler @compileParams /base $interpreterPath | Out-Null
    
    if (!$scriptVersion) {
        $ver = (Get-Item $outExe).VersionInfo.FileVersionRaw
        $scriptVersion = "{0}.{1}" -f `
            $ver.major, $ver.minor
                          
        if ($ver.build) {
            $scriptVersion += '.' + $ver.build
        }
    }
    
    $archivePath = "{0}-{1}-x{2}.zip" -f `
        $scriptBase, $scriptVersion, $bitness

    &$sevenZip `
        @zipParams `
        $archivePath `
        "$outExe" `
        "$scriptDir\Icons" `
        "$scriptDir\Favorites" |
        Out-Null
}

# Archive source code
$archivePath = "{0}-{1}.zip" -f `
    $scriptBase, $scriptVersion

&$sevenZip `
    @zipParams `
    $archivePath `
    "$scriptPath" `
    "$scriptDir\Icons" `
    "$scriptDir\Favorites" `
    "$scriptDir\Lib" |
    Out-Null
    
Remove-Item $outExe 