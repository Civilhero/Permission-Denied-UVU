@echo off
setlocal enabledelayedexpansion

echo ============================================
echo  Permission Denied - Repo Setup
echo ============================================
echo.
echo This script does NOT assume anything about your computer's
echo drive layout, username, or existing folder structure. It will
echo detect what's installed and ask you where to put things.
echo.

REM ============================================
REM  Step 1: Check for Git
REM ============================================
where git >nul 2>nul
if errorlevel 1 (
    echo [MISSING] Git was not found on this computer.
    where winget >nul 2>nul
    if errorlevel 1 (
        echo winget is not available here either, so this script can't install
        echo Git automatically. Please install it yourself from:
        echo     https://git-scm.com/downloads
        echo Then re-run this script.
        pause
        exit /b 1
    )
    echo Attempting to install Git via winget...
    winget install --id Git.Git -e --source winget
    if errorlevel 1 (
        echo Automatic install failed. Please install Git manually from:
        echo     https://git-scm.com/downloads
        echo Then re-run this script.
        pause
        exit /b 1
    )
    echo [OK] Git installed. You may need to close and re-open this window
    echo      for PATH changes to take effect if the next check fails.
) else (
    echo [OK] Git found.
)

REM ============================================
REM  Step 2: Check for Git LFS
REM  (Modern Git for Windows already bundles git-lfs, so check that
REM  first before pulling in the separate GitHub.GitLFS package -
REM  installing both can cause PATH conflicts.)
REM ============================================
git lfs version >nul 2>nul
if errorlevel 1 (
    echo [MISSING] Git LFS was not found.
    where winget >nul 2>nul
    if errorlevel 1 (
        echo winget is not available, so this script can't install Git LFS
        echo automatically. Please install it yourself from:
        echo     https://git-lfs.github.com
        echo Then re-run this script.
        pause
        exit /b 1
    )
    echo Attempting to install Git LFS via winget...
    winget install --id GitHub.GitLFS -e --source winget
    if errorlevel 1 (
        echo Automatic install failed. Please install Git LFS manually from:
        echo     https://git-lfs.github.com
        echo Then re-run this script.
        pause
        exit /b 1
    )
) else (
    echo [OK] Git LFS found.
)

REM ============================================
REM  Step 3: Set up Git LFS hooks (one-time, per machine)
REM ============================================
git lfs install
if errorlevel 1 (
    echo Failed to run "git lfs install". Try closing and re-opening this
    echo window ^(PATH may need to refresh after a fresh install^), then
    echo re-run this script.
    pause
    exit /b 1
)
echo [OK] Git LFS hooks installed.
echo.

REM ============================================
REM  Step 4: Ask where to clone the repo
REM  (No default assumed - every machine's folder layout is different.)
REM ============================================
set "CLONE_PATH="
echo Where do you want the project folder created?
echo Example: C:\Projects   or   D:\Games\UnrealProjects
set /p CLONE_PATH="Enter a full folder path: "

if "%CLONE_PATH%"=="" (
    echo No path entered. Exiting without cloning.
    pause
    exit /b 1
)

if not exist "%CLONE_PATH%" (
    echo That folder doesn't exist yet.
    set /p MAKE_IT="Create it now? (Y/N): "
    if /i not "!MAKE_IT!"=="Y" (
        echo Exiting without cloning.
        pause
        exit /b 1
    )
    mkdir "%CLONE_PATH%"
    if errorlevel 1 (
        echo Failed to create "%CLONE_PATH%". Check the path is valid and you
        echo have permission to create folders there, then try again.
        pause
        exit /b 1
    )
)

cd /d "%CLONE_PATH%"
if errorlevel 1 (
    echo Could not access "%CLONE_PATH%". Check the path and try again.
    pause
    exit /b 1
)

REM ============================================
REM  Step 5: Clone (skip if already present)
REM ============================================
if exist "Permission-Denied-UVU\.git" (
    echo [OK] Repo already exists at "%CLONE_PATH%\Permission-Denied-UVU" - skipping clone.
) else (
    echo Cloning repository into "%CLONE_PATH%\Permission-Denied-UVU"...
    echo This repo is public, so cloning it doesn't require logging in.
    echo If you ARE asked to authenticate repeatedly during cloning, something
    echo unrelated is likely misconfigured on this machine's Git credential
    echo setup - it's not an access-permission issue on the repo itself.
    echo.
    git clone https://github.com/Shadowisp911/Permission-Denied-UVU.git
    if errorlevel 1 (
        echo Clone failed. Common causes: no GitHub access to this repo yet
        echo ^(ask to be added as a collaborator^), or no internet connection.
        pause
        exit /b 1
    )
)

REM ============================================
REM  Step 6: Verify LFS content actually downloaded
REM  ("git clone" can report success even if the LFS smudge/download step
REM  silently failed, leaving broken pointer files instead of real assets -
REM  so check for that explicitly instead of trusting clone's exit code.)
REM ============================================
cd /d "Permission-Denied-UVU"
if errorlevel 1 (
    echo Could not enter the cloned repo folder to verify LFS content.
    pause
    exit /b 1
)

echo Verifying Git LFS content downloaded correctly...
git lfs pull
if errorlevel 1 (
    echo.
    echo [FAILED] Git LFS content did not download correctly. Your repo
    echo files exist, but large assets ^(.uasset, .umap, textures, etc.^)
    echo may be small placeholder pointer files instead of the real thing.
    echo.
    echo This usually means an authentication problem specifically with
    echo Git LFS - re-run this script, or from inside the repo folder run:
    echo     git lfs pull
    echo and watch for an authentication or permission error in the output.
    pause
    exit /b 1
)
echo [OK] Git LFS content verified.
cd /d "%CLONE_PATH%"

echo.
echo ============================================
echo  Setup complete
echo ============================================
echo  Repo location: %CLONE_PATH%\Permission-Denied-UVU
echo.
echo  Next steps (see CONTRIBUTING.md for full details):
echo   1. Install Unreal Engine 5.8 if you haven't. No compiler is needed -
echo      the project is Blueprint-only.
echo   2. Open:
echo      %CLONE_PATH%\Permission-Denied-UVU\Permission_Denied\Permission_Denied.uproject
echo   3. Before editing shared maps or Blueprints, read the section
echo      on working together without locking in CONTRIBUTING.md.
echo ============================================
pause
