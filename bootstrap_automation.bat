@echo off
setlocal enabledelayedexpansion

:: ==========================================
:: CONFIGURATION 
:: (Change these after you create your GitHub repo)
:: ==========================================
set "GITHUB_USER=akash5100"
set "GITHUB_REPO=auto-pass"
set "TARGET_FOLDER=%USERPROFILE%\Downloads\Automation_Tool"

:: ==========================================
:: LOGIC
:: ==========================================
cls
echo ======================================================
echo    WELCOME TO AUTOMATION TOOL INSTALLER
echo ======================================================
echo.

:: 1. Define URLs and paths
set "ZIP_URL=https://github.com/%GITHUB_USER%/%GITHUB_REPO%/archive/refs/heads/main.zip"
set "TEMP_ZIP=%TEMP%\automation_download.zip"

:: 2. Create the target folder
if not exist "%TARGET_FOLDER%" (
    echo [INFO] Creating folder in Downloads...
    mkdir "%TARGET_FOLDER%"
)

:: 3. Download from GitHub
echo [INFO] Downloading the latest code from GitHub...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%TEMP_ZIP%'"

if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Failed to download. 
    echo [TIP  ] Make sure you are connected to the internet.
    echo [TIP  ] Make sure the GitHub repository is PUBLIC.
    echo.
    pause
    exit /b
)

:: 4. Extracting
echo [INFO] Extracting files...
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%TARGET_FOLDER%' -Force"

:: 5. Cleanup ZIP
del "%TEMP_ZIP%"

:: 6. Find the 'install.bat' inside the extracted folder
:: GitHub ZIPs usually create a folder like 'repo-main' inside the destination
echo [INFO] Locating the installer...
for /d %%D in ("%TARGET_FOLDER%\*") do (
    if exist "%%D\install.bat" (
        echo [OK] Found it! Starting the setup...
        echo.
        cd /d "%%D"
        
        :: Run the installer
        call install.bat
        goto :done
    )
)

echo.
echo [ERROR] Could not find 'install.bat' in the downloaded files.
echo [TIP  ] Check if the file is named correctly in your GitHub repo.
pause
exit /b

:done
echo.
echo ======================================================
echo    ALL DONE! 
echo.
echo    The tool has been installed in your Downloads:
echo    %TARGET_FOLDER%
echo.
echo    You can now close this window.
echo ======================================================
pause
