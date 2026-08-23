param(
    [string]$scriptPath     = "$PSScriptRoot\..\QuickSwitch.ahk",
    [string]$outDir         = "$PSScriptRoot\..\Releases",
    [string]$scriptVersion  = "",
    [string]$sevenZip       = "C:\Program Files\7-Zip\7z.exe",
    [string]$autoHotkeyDir  = "C:\Program Files\AutoHotkey",
    [string]$compiler       = "$autoHotkeyDir\Compiler\Ahk2Exe.exe"
)

$ErrorActionPreference = 'Stop'

$scriptBase =  Split-Path $scriptPath -leafBase
$scriptDir  =  Split-Path $scriptPath -parent
$outExe     =  Join-Path  $outDir "$scriptBase.exe"

$compileParams = @(
    '/in',     $scriptPath,
    '/out',    $outExe, 
    '/silent', 'verbose'
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

if (!(Test-Path -Literal $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}
Set-Location $outDir

# Archive for each platform
ForEach($bitness in @('32', '64')) {
    $interpreterPath = "{0}\AutoHotkeyU{1}.exe" -f `
        $autoHotkeyDir, $bitness

    &$compiler @compileParams /base $interpreterPath | Out-String

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
        Out-String
        
    Write-Host $archivePath    
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
    Out-String
    
Write-Host $archivePath

$artifact = Split-Path $archivePath -leafBase
"artifact=$artifact" >> $env:GITHUB_ENV

Remove-Item $outExe
