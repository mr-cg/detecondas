@echo off
setlocal enabledelayedexpansion

echo Starting setup script...

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

REM Check if npm is working
echo Checking if npm is working...
npm -v
if !errorlevel! neq 0 (
    echo npm is not working. Error level: !errorlevel!
    goto :error
)
echo npm is working correctly.

REM Check if the node_modules folder exists, if not, install dependencies
echo Checking for node_modules folder...
if not exist "node_modules" (
    echo node_modules not found. Installing project dependencies...
    
    echo Installing express...
    call npm install express
    if !errorlevel! neq 0 (
        echo Failed to install express. Error level: !errorlevel!
        goto :error
    )
    
    echo Installing esptool-js...
    call npm install https://github.com/espressif/esptool-js.git
    if !errorlevel! neq 0 (
        echo Failed to install esptool-js. Error level: !errorlevel!
        goto :error
    )
) else (
    echo Dependencies are already installed. Verifying...
    call npm list express esptool-js
    if !errorlevel! neq 0 (
        echo Dependency verification failed. Attempting to reinstall...
        rmdir /s /q node_modules
        call npm install
        if !errorlevel! neq 0 (
            echo Failed to reinstall dependencies. Error level: !errorlevel!
            goto :error
        )
    )
)

REM Create 'uploads' directory if it doesn't exist
echo Checking for 'uploads' directory...
if not exist "uploads" (
    echo Creating 'uploads' directory...
    mkdir uploads
    if !errorlevel! neq 0 (
        echo Failed to create 'uploads' directory. Error level: !errorlevel!
        goto :error
    )
) else (
    echo 'uploads' directory already exists.
)

REM Check if port 3000 is already in use
echo Checking if port 3000 is available...
netstat -ano | find "LISTENING" | find ":3000 "
if !errorlevel! equ 0 (
    echo Port 3000 is already in use. Please close the application using this port and try again.
    goto :error
)

REM Start the server
echo Starting the server...
echo The server will start in a new window. Please check that window for any error messages.
start "Node.js Server" cmd /k "node server.js"
if !errorlevel! neq 0 (
    echo Failed to start the server. Error level: !errorlevel!
    goto :error
)

REM Wait for the server to start
echo Waiting for the server to start...
timeout /t 5 /nobreak > nul

REM Check if the server is running
echo Checking if the server is running...
netstat -ano | find "LISTENING" | find ":3000 "
if !errorlevel! neq 0 (
    echo Server does not appear to be running on port 3000.
    goto :error
)

REM Open the browser
echo Opening the browser...
start http://localhost:3000

echo Script completed successfully.
echo The server should be running in a separate window. You can close this window.
pause
exit /b 0

:error
echo.
echo An error occurred. Press any key to exit...
pause >nul
exit /b 1