<#
.SYNOPSIS
    Disables Epic's built-in Git source control plugin for this project's engine
    version, so the Git LFS 2 (UEGitPlugin) module can load without a module-name
    collision. Affects the engine install, not just this project - see README.md
    in this folder.

.PARAMETER EnginePath
    Optional. Explicit path to the engine root (the folder containing "Engine\"),
    e.g. "C:\Program Files\Epic Games\UE_5.8". If omitted, the script reads the
    EngineAssociation from the .uproject and searches common install locations.
#>
param(
    [string]$EnginePath
)

$ErrorActionPreference = "Stop"

function Find-UProjectFile {
    $repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
    Get-ChildItem -Path $repoRoot -Recurse -Filter *.uproject -File | Select-Object -First 1
}

function Find-EnginePath {
    param([string]$Version)

    $candidates = @(
        "C:\Program Files\Epic Games\UE_$Version",
        "C:\Epic Games\UE_$Version"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    return $null
}

if (-not $EnginePath) {
    $uproject = Find-UProjectFile
    if (-not $uproject) {
        Write-Error "Could not find a .uproject file in the repo, and no -EnginePath was given. Re-run with -EnginePath 'C:\Program Files\Epic Games\UE_5.8'."
    }
    $json = Get-Content $uproject.FullName -Raw | ConvertFrom-Json
    $version = $json.EngineAssociation
    Write-Host "Project targets engine version: $version"

    $EnginePath = Find-EnginePath -Version $version
    if (-not $EnginePath) {
        Write-Error "Could not auto-locate the UE_$version install. Re-run with -EnginePath 'C:\path\to\UE_$version'."
    }
}

$pluginFile = Join-Path $EnginePath "Engine\Plugins\Developer\GitSourceControl\GitSourceControl.uplugin"
$disabledFile = "$pluginFile.disabled"

if (Test-Path $disabledFile) {
    Write-Host "Already disabled: $disabledFile exists. Nothing to do."
    exit 0
}

if (-not (Test-Path $pluginFile)) {
    Write-Error "Expected to find $pluginFile but it doesn't exist. Engine layout may differ - check manually."
}

Rename-Item -Path $pluginFile -NewName "GitSourceControl.uplugin.disabled"
Write-Host "Disabled Epic's built-in Git plugin at: $pluginFile"
Write-Host "This affects every project that opens with this engine install (UE_$version), not just this one."
Write-Host "To undo, run Restore-EngineGitPlugin.ps1 in this same folder."
