@echo off
setlocal enabledelayedexpansion

REM ==========================================
REM CONFIGURATION 
REM (Change these after you create your GitHub repo)
REM ==========================================
set "GITHUB_USER=akash5100"
set "GITHUB_REPO=auto-pass"
set "TARGET_FOLDER=%USERPROFILE%\Downloads\Automation_Tool"

REM ==========================================
REM LOGIC
REM ==========================================
cls
echo ======================================================
echo    WELCOME TO AUTOMATION TOOL INSTALLER
echo ======================================================
echo.

REM 1. Define URLs and paths
set "ZIP_URL=https://github.com/%GITHUB_USER%/%GITHUB_REPO%/archive/refs/heads/main.zip"
set "TEMP_ZIP=%TEMP%\automation_download.zip"

REM 2. Create the target folder
if not exist "%TARGET_FOLDER%" (
    echo [INFO] Creating folder in Downloads...
    mkdir "%TARGET_FOLDER%"
)

REM 3. Download from GitHub
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

REM 4. Extracting
echo [INFO] Extracting files...
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%TARGET_FOLDER%' -Force"

REM 5. Cleanup ZIP
del "%TEMP_ZIP%"

REM 6. Find the 'install.bat' inside the extracted folder
REM GitHub ZIPs usually create a folder like 'repo-main' inside the destination
echo [INFO] Locating the installer...
for /d %%D in ("%TARGET_FOLDER%\*") do (
    if exist "%%D\install.bat" (
        echo [OK] Found it! Starting the setup...
        echo.
        cd /d "%%D"
        
        REM Run the installer
        call install.bat
        
        REM 7. Create Desktop Shortcut
        echo.
        echo [INFO] Creating Desktop Shortcut...
        set "SHORTCUT_PATH=%USERPROFILE%\Desktop\Start Automation.lnk"
        set "TARGET_PATH=%CD%\run.bat"
        
        powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT_PATH%');$s.TargetPath='%TARGET_PATH%';$s.WorkingDirectory='%CD%';$s.Save()"
        
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
