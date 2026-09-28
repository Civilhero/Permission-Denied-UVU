<#
.SYNOPSIS
    Reverses Disable-EngineGitPlugin.ps1 - restores Epic's built-in Git source
    control plugin for this project's engine version.

.PARAMETER EnginePath
    Optional. Explicit path to the engine root, e.g. "C:\Program Files\Epic Games\UE_5.8".
    If omitted, the script reads the EngineAssociation from the .uproject and
    searches common install locations.
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

$disabledFile = Join-Path $EnginePath "Engine\Plugins\Developer\GitSourceControl\GitSourceControl.uplugin.disabled"
$restoredFile = $disabledFile -replace '\.disabled$', ''

if (-not (Test-Path $disabledFile)) {
    if (Test-Path $restoredFile) {
        Write-Host "Already enabled: $restoredFile exists. Nothing to do."
        exit 0
    }
    Write-Error "Could not find $disabledFile. Engine layout may differ - check manually."
}

Rename-Item -Path $disabledFile -NewName "GitSourceControl.uplugin"
Write-Host "Restored Epic's built-in Git plugin at: $restoredFile"
Write-Host "Note: the Git LFS 2 plugin (Plugins\UEGitPlugin in this repo) will now collide with it on build."
Write-Host "Disable or remove Plugins\UEGitPlugin (or re-run Disable-EngineGitPlugin.ps1) before opening the project."
