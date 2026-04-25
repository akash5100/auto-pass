@echo off
:: Move to the directory where this script is located
cd /d "%~dp0"

cls
echo ======================================================
echo    STARTING AUTOMATION...
echo ======================================================
echo.
echo [INFO] Please keep this window open while working.
echo.

:: Run the automation using uv
uv run start.py

:: If something goes wrong, don't just close the window
if %ERRORLEVEL% neq 0 (
    echo.
    echo ------------------------------------------------------
    echo [ERROR] Something went wrong!
    echo [TIP  ] Please take a photo of this screen and share.
    echo ------------------------------------------------------
    pause
)
