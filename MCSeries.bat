@echo off
setlocal EnableDelayedExpansion

:: ==========================================
:: Configuration Section
:: ==========================================
set "TITLE=Minecraft Bedrock Dedicated Server - Menu"
set "PLAYIT_EXE=C:\Program Files\playit_gg\bin\playit.exe"
set "PLAYIT_PROCESS=playit.exe"
set "PLAYIT_URL=https://playit.gg/account/tunnels"

set "SERVER_DIR=C:\Users\abril\Documents\VibeCoding\MCServer\NewLife_1.26.13.1"
set "SERVER_EXE=bedrock_server.exe"
set "SERVER_PATH=%SERVER_DIR%\%SERVER_EXE%"

:: ==========================================
:: Elevation Check
:: ==========================================
:check_Permissions
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :init
) else (
    echo.
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:init
title %TITLE%
cls

:: ==========================================
:: Main Menu
:: ==========================================
:menu
cls
echo ==========================================
echo       BDS Menu - Improved by Antigravity
echo ==========================================
echo.
echo Notice:
echo This script will activate following services:
echo [1] Tunnel (playit.gg)
echo [2] Minecraft Bedrock Dedicated Server (BDS)
echo.
echo Do you want to continue the process? (Y/N)
set /p "q= "
if /I "%q%" == "N" exit /b
if /I "%q%" NEQ "Y" goto menu

:start
cls
echo [1/2] Starting playit.gg...

:: Check if playit exists
if not exist "%PLAYIT_EXE%" (
    echo ALERT: playit.exe not found at "%PLAYIT_EXE%"
    pause
    goto menu
)

:: Start playit
start "" "%PLAYIT_EXE%"
start "" "%PLAYIT_URL%"
timeout /t 2 >nul

:cek_playit
tasklist /FI "IMAGENAME eq %PLAYIT_PROCESS%" | find /I "%PLAYIT_PROCESS%" >nul
if %errorlevel% neq 0 (
    echo playit.exe is not running. Retrying...
    timeout /t 2 >nul
    goto cek_playit
)
echo playit.exe is running.

echo.
echo [2/2] Starting Bedrock Dedicated Server...

:: Check if server exists
if not exist "%SERVER_PATH%" (
    echo ALERT: bedrock_server.exe not found at "%SERVER_PATH%"
    pause
    goto menu
)

:: Start server as a separate process
:: We use a temporary script to ensure it runs correctly in its own window
echo @echo off > "%temp%\run_bds.bat"
echo cd /d "%SERVER_DIR%" >> "%temp%\run_bds.bat"
echo start "%SERVER_EXE%" "%SERVER_PATH%" >> "%temp%\run_bds.bat"
echo exit >> "%temp%\run_bds.bat"

start "" "%temp%\run_bds.bat"
timeout /t 3 >nul

:cek_server
tasklist /FI "IMAGENAME eq %SERVER_EXE%" | find /I "%SERVER_EXE%" >nul
if %errorlevel% neq 0 (
    echo bedrock_server.exe is not running. Retrying...
    timeout /t 2 >nul
    goto cek_server
)
echo bedrock_server.exe is running.

:: ==========================================
:: Status Menu
:: ==========================================
:status
cls
echo ==========================================
echo       BDS Server Status: ACTIVATED
echo ==========================================
echo.
echo Tunnel: ONLINE
echo BDS   : ONLINE
echo.
echo ------------------------------------------
echo Options:
echo [Exit]    Terminate all and close
echo [Restart] Restart the activation process
echo.
set /p "q1=Selection: "
if /I "%q1%" == "exit" goto exit
if /I "%q1%" == "restart" (
    echo Restarting...
    taskkill /F /T /IM "%SERVER_EXE%" >nul 2>&1
    taskkill /F /T /IM "%PLAYIT_PROCESS%" >nul 2>&1
    taskkill /F /T /IM "playit-windows-x86_64-signed.exe" >nul 2>&1
    timeout /t 1 >nul
    start "" "%~f0"
    exit /b
)
goto status

:exit
cls
echo.
echo Terminating running applications...
echo.

:: Taskkill with forceful termination
taskkill /F /T /IM "%SERVER_EXE%" >nul 2>&1
taskkill /F /T /IM "%PLAYIT_PROCESS%" >nul 2>&1
:: Also kill the signed version seen in original code
taskkill /F /T /IM "playit-windows-x86_64-signed.exe" >nul 2>&1

timeout /t 2 >nul
echo.
echo All applications have been terminated.
pause
exit /b
