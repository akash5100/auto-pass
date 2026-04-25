@echo off
REM Move to the directory where this script is located
cd /d "%~dp0"

cls
echo ======================================================
echo    STARTING AUTOMATION...
echo ======================================================
echo.
echo [INFO] Please keep this window open while working.
echo.

REM Check if uv is in PATH
where uv >nul 2>nul
if %ERRORLEVEL% neq 0 (
    REM Try common installation paths
    if exist "%APPDATA%\uv\bin\uv.exe" (
        set "PATH=%APPDATA%\uv\bin;%PATH%"
    ) else if exist "%USERPROFILE%\.cargo\bin\uv.exe" (
        set "PATH=%USERPROFILE%\.cargo\bin;%PATH%"
    ) else (
        echo [ERROR] 'uv' not found. Please run install.bat first.
        pause
        exit /b 1
    )
)

REM Run the automation using uv
uv run start.py

REM If something goes wrong, don't just close the window
if %ERRORLEVEL% neq 0 (
    echo.
    echo ------------------------------------------------------
    echo [ERROR] Something went wrong!
    echo [TIP  ] Please take a photo of this screen and share.
    echo ------------------------------------------------------
    pause
)
