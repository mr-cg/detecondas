@echo off
setlocal enabledelayedexpansion

echo Starting simplified setup script...

REM Navigate to the script directory
echo Changing to script directory...
cd /d "%~dp0"
if !errorlevel! neq 0 (
    echo Failed to change directory. Error level: !errorlevel!
    goto :error
)
echo Current directory: %cd%

REM Check if Node.js is installed by checking node version
echo Checking if Node.js is installed...
node -v
if !errorlevel! neq 0 (
    echo Node.js is not installed. Error level: !errorlevel!
    goto :error
)

REM Detailed npm check
echo Checking if npm is working...
echo Attempting to run 'where npm'...
where npm
if !errorlevel! neq 0 (
    echo npm not found in PATH. Error level: !errorlevel!
    goto :error
)
echo npm found at:
where npm

echo Attempting to run 'npm -v'...
npm -v
if !errorlevel! neq 0 (
    echo npm -v command failed. Error level: !errorlevel!
    echo Checking npm installation...
    
    REM Try to repair npm
    echo Attempting to repair npm...
    node "%ProgramFiles%\nodejs\node_modules\npm\bin\npm-cli.js" install -g npm
    if !errorlevel! neq 0 (
        echo Failed to repair npm. Error level: !errorlevel!
        goto :error
    )
    
    REM Check npm again after repair attempt
    echo Checking npm after repair attempt...
    npm -v
    if !errorlevel! neq 0 (
        echo npm still not working after repair attempt. Error level: !errorlevel!
        goto :error
    )
)
echo npm check completed successfully.

echo Script completed. Press any key to exit...
pause >nul
exit /b 0

:error
echo.
echo An error occurred. Error details above. Press any key to exit...
pause >nul
exit /b 1