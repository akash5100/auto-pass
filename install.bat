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
echo    STEP 2: CHECKING SYSTEM DEPENDENCIES
echo ======================================================
echo.

REM Check for Visual C++ Redistributable (Required for many Python packages like greenlet)
if not exist "%SystemRoot%\System32\vcruntime140.dll" (
    echo [INFO] Visual C++ Redistributable not found.
    echo [INFO] This is required for automation. Downloading...
    powershell -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%TEMP%\vc_redist.x64.exe'"
    
    echo [INFO] Installing... Please allow any administrator prompts.
    start /wait "" "%TEMP%\vc_redist.x64.exe" /install /quiet /norestart
    
    del "%TEMP%\vc_redist.x64.exe"
    echo [OK] Visual C++ Redistributable installation triggered.
) else (
    echo [OK] Visual C++ Redistributable is already installed.
)

echo.
echo ======================================================
echo    STEP 3: PREPARING PYTHON ENVIRONMENT
echo ======================================================
echo.

REM Sync dependencies - installs Python automatically if needed
uv sync
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to sync dependencies.
    pause
    exit /b 1
)

REM Health Check: Verify if greenlet (Playwright dependency) can be imported
echo [INFO] Verifying environment health...
uv run python -c "import greenlet; print('[OK] greenlet imported successfully')" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Environment health check failed! 
    echo [ERROR] DLL load failed for 'greenlet'. 
    echo [TIP  ] Try restarting your computer to finalize the C++ Redistributable install.
    echo.
    pause
    exit /b 1
)

echo.
echo ======================================================
echo    STEP 4: PREPARING CHROME BROWSER
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
