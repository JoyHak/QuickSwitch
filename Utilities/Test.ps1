param(
    [string]$scriptPath     = "$PSScriptRoot\..\QuickSwitch.ahk",
    [string]$outDir         = "$PSScriptRoot\..\Releases",
    [string]$scriptVersion  = "",
    [string]$autoHotkeyDir  = "C:\Program Files\AutoHotkey",
    [string]$compiler       = "$autoHotkeyDir\Compiler\Ahk2Exe.exe"
)

$ErrorActionPreference = 'Stop'

$scriptName =  "QuickSwitch"
$outExe     =  "$outDir\$scriptName.exe"
Set-Location $outDir

$compileParams = @(
    '/in',     $scriptPath,
    '/out',    $outExe, 
    '/base',   "$autoHotkeyDir\AutoHotkeyU64.exe"
    '/silent', 'verbose'
)

&$compiler @compileParams | Out-String

if (!$scriptVersion) {
    $ver = (Get-Item $outExe).VersionInfo.FileVersion
    $scriptVersion = $ver.Trim('.0')
}

$newName = "{0}-{1}" -f $scriptName, $scriptVersion
if (!(Test-Path -Literal $newName)) {
    New-Item -ItemType Directory -Path $newName
}

Move-Item $outExe "$outDir\$newName" -force
