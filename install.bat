@echo off
setlocal

REM Clear screen and show a friendly header
cls
echo ======================================================
echo    STEP 1: INSTALLING SOFTWARE - PLEASE WAIT
echo ======================================================
echo.

REM 1. Check if uv is installed
where uv >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [INFO] uv - Python Manager not found. 
    echo [INFO] Downloading and installing uv...
    echo.
    
    REM Use PowerShell to install uv
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    
    REM Manually add uv to PATH for this specific session
    set "PATH=%APPDATA%\uv\bin;%USERPROFILE%\.cargo\bin;%PATH%"
) else (
    echo [OK] 'uv' is already installed.
)

REM 2. Ensure we are in the right directory
cd /d "%~dp0"

echo.
echo ======================================================
echo    STEP 2: PREPARING PYTHON ENVIRONMENT
echo ======================================================
echo.

REM Sync dependencies - installs Python automatically if needed
uv sync

echo.
echo ======================================================
echo    STEP 3: PREPARING CHROME BROWSER
echo ======================================================
echo.

REM Install Chromium - only this browser to avoid bloat
uv run python -m playwright install --with-deps chromium

echo.
echo ======================================================
echo    ALL DONE!
echo ======================================================
echo.
echo [SUCCESS] Setup complete!
echo.
echo [ACTION ] You can now close this window.
echo [ACTION ] Double-click 'run.bat' to start the work.
echo.
echo ======================================================
pause
