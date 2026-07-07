@echo off
setlocal EnableDelayedExpansion

:: ==========================================
:: Configuration Section
:: ==========================================
set "TITLE=Minecraft Bedrock Dedicated Server - Menu"
set "PLAYIT_EXE=C:\Program Files\playit_gg\bin\playit.exe"
set "PLAYIT_PROCESS=playit.exe"
set "PLAYIT_URL=https://playit.gg/account/tunnels"

set "SERVER_BASE_DIR=C:\Users\abril\Documents\MinecraftServers"
set "SERVER_EXE=bedrock_server.exe"
set "SERVER_DIR="
set "SERVER_PATH="
set "SERVER_LOG=%temp%\bds-live.log"
set "PLAYER_COUNT=0"
set "AUTO_SHUTDOWN_ENABLED=1"
set "PC_SHUTDOWN_ENABLED=0"
set "SHUTDOWN_GRACE_PERIOD=180"
set "SHUTDOWN_TIMER=0"

set "MC_PROCESS=C:\XboxGames\Minecraft for Windows\Content\Minecraft.Windows.exe"

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
echo       Bedrock Dedicated Server - Menu
echo ==========================================
echo.
echo Notice:
echo This script will activate following services:
echo [1] Tunnel (playit.gg)
echo [2] Minecraft Bedrock Dedicated Server (BDS)
echo.
echo Server Base Folder: %SERVER_BASE_DIR%
echo.
echo Do you want to continue the process? (Y/N)
set /p "q= "
if /I "%q%" == "N" exit /b
if /I "%q%" NEQ "Y" goto menu

goto select_server

:: ==========================================
:: Server Folder Selection
:: ==========================================
:select_server
cls
echo ==========================================
echo       Select Bedrock Server Folder
echo ==========================================
echo.
echo Base Folder: %SERVER_BASE_DIR%
echo.

if not exist "%SERVER_BASE_DIR%" (
    echo ALERT: Server base folder not found at "%SERVER_BASE_DIR%"
    pause
    goto menu
)

set /a SERVER_COUNT=0
for /D %%D in ("%SERVER_BASE_DIR%\*") do (
    if exist "%%~fD\%SERVER_EXE%" (
        set /a SERVER_COUNT+=1
        set "SERVER_!SERVER_COUNT!=%%~fD"
        echo [!SERVER_COUNT!] %%~nxD
    )
)

if %SERVER_COUNT% EQU 0 (
    echo No valid server folders found.
    echo Each server folder must contain %SERVER_EXE%.
    pause
    goto menu
)

echo.
echo [B] Back to main menu
echo.
set /p "server_choice=Choose server: "

if /I "%server_choice%" == "B" goto menu

set "SERVER_DIR="
for /L %%I in (1,1,%SERVER_COUNT%) do (
    if "%server_choice%" == "%%I" set "SERVER_DIR=!SERVER_%%I!"
)

if not defined SERVER_DIR (
    echo Invalid selection.
    pause
    goto select_server
)

set "SERVER_PATH=%SERVER_DIR%\%SERVER_EXE%"

goto start

:start
cls
echo [1/2] Starting playit.gg...

:: Check if playit exists
if not exist "%PLAYIT_EXE%" (
    echo ALERT: playit.exe not found at "%PLAYIT_EXE%"
    pause
    goto menu
)

:: Start playit if not already running
tasklist /FI "IMAGENAME eq %PLAYIT_PROCESS%" | find /I "%PLAYIT_PROCESS%" >nul
if %errorlevel% neq 0 (
    echo Starting playit.exe...
    start "" "%PLAYIT_EXE%"
    timeout /t 2 >nul
) else (
    echo playit.exe is already running.
)

:: Only open URL if lock file doesn't exist (prevents duplicate tabs)
if not exist "%temp%\playit_url_opened.lock" (
    echo Opening playit.gg dashboard...
    start "" "%PLAYIT_URL%"
    echo opened> "%temp%\playit_url_opened.lock"
) else (
    echo Dashboard tab already open. Skipping.
)

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

:: Start server as a separate process and pipe output to log
:: We use a temporary script to ensure it runs correctly in its own window
> "%temp%\run_bds.bat" echo @echo off
>> "%temp%\run_bds.bat" echo title BDS Server
>> "%temp%\run_bds.bat" echo cd /d "%SERVER_DIR%"
>> "%temp%\run_bds.bat" echo type nul ^> "%SERVER_LOG%"
>> "%temp%\run_bds.bat" echo powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%SERVER_PATH%' 2>&1 | ForEach-Object { $_; Add-Content -LiteralPath '%SERVER_LOG%' -Value $_ -Encoding UTF8 }"
>> "%temp%\run_bds.bat" echo exit

start "BDS Server" "%temp%\run_bds.bat"
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
:: Calculate Player Count
set /a PLAYER_COUNT=0
if exist "%SERVER_LOG%" (
    for /f %%A in ('findstr /c:"Player connected:" "%SERVER_LOG%" 2^>nul ^| find /c /v ""') do set /a PLAYER_COUNT+=%%A
    for /f %%A in ('findstr /c:"Player disconnected:" "%SERVER_LOG%" 2^>nul ^| find /c /v ""') do set /a PLAYER_COUNT-=%%A
    if !PLAYER_COUNT! LSS 0 set /a PLAYER_COUNT=0
)

:: Auto-shutdown logic: increment timer if no players, reset if players present
if %AUTO_SHUTDOWN_ENABLED% EQU 1 (
    if !PLAYER_COUNT! EQU 0 (
        set /a SHUTDOWN_TIMER+=1
    ) else (
        set /a SHUTDOWN_TIMER=0
    )
)

:: Check if shutdown timer reached grace period (180 seconds = 3 minutes)
set /a SHUTDOWN_REMAINING=%SHUTDOWN_GRACE_PERIOD% - %SHUTDOWN_TIMER%
if %SHUTDOWN_TIMER% GEQ %SHUTDOWN_GRACE_PERIOD% (
    cls
    echo ==========================================
    echo       Auto-Shutdown Triggered
    echo ==========================================
    echo.
    echo No players detected for 3 minutes.
    if %PC_SHUTDOWN_ENABLED% EQU 1 (
        echo Shutting down server and PC...
        echo.
        goto exit_and_shutdown
    ) else (
        echo Shutting down server...
        echo.
        goto exit
    )
)

cls
echo ==========================================
echo       Bedrock Dedicated Server - Status
echo ==========================================
echo.
echo Tunnel: ONLINE
echo BDS   : ONLINE
echo Players: !PLAYER_COUNT!
if %AUTO_SHUTDOWN_ENABLED% EQU 1 (
    if !PLAYER_COUNT! EQU 0 (
        echo Auto-shutdown in: !SHUTDOWN_REMAINING! seconds
    ) else (
        echo Auto-shutdown: PAUSED ^(players online^)
    )
)
if %PC_SHUTDOWN_ENABLED% EQU 1 (
    echo PC Shutdown: ENABLED
)
echo.
echo ------------------------------------------
echo Options:
echo [R] Refresh player count
echo [P] Launch Minecraft Bedrock
echo [A] Toggle auto-shutdown
echo [S] Toggle PC shutdown on idle
echo [X] Terminate all and close
echo [T] Restart the activation process
echo.
choice /C RPASXT /N /T 1 /D R /M "Selection: "
if errorlevel 6 (
    echo Restarting...
    taskkill /F /T /IM "%SERVER_EXE%" >nul 2>&1
    taskkill /F /T /IM "%PLAYIT_PROCESS%" >nul 2>&1
    taskkill /F /T /IM "playit-windows-x86_64-signed.exe" >nul 2>&1
    timeout /t 1 >nul
    start "" "%~f0"
    exit /b
)
if errorlevel 5 goto exit
if errorlevel 4 (
    if %PC_SHUTDOWN_ENABLED% EQU 1 (
        set PC_SHUTDOWN_ENABLED=0
        echo PC Shutdown DISABLED.
    ) else (
        set PC_SHUTDOWN_ENABLED=1
        echo PC Shutdown ENABLED.
    )
    timeout /t 2 >nul
    goto status
)
if errorlevel 3 (
    if %AUTO_SHUTDOWN_ENABLED% EQU 1 (
        set AUTO_SHUTDOWN_ENABLED=0
        echo Auto-shutdown DISABLED.
    ) else (
        set AUTO_SHUTDOWN_ENABLED=1
        set /a SHUTDOWN_TIMER=0
        echo Auto-shutdown ENABLED.
    )
    timeout /t 2 >nul
    goto status
)
if errorlevel 2 goto launch_minecraft
goto status

:launch_minecraft
:: Check if Minecraft Bedrock is already running
tasklist /FI "IMAGENAME eq %MC_PROCESS%" | find /I "%MC_PROCESS%" >nul
if %errorlevel% equ 0 (
    echo.
    echo Minecraft Bedrock is already running.
    timeout /t 2 >nul
    goto status
)

:: Launch Minecraft Bedrock via protocol
echo.
echo Launching Minecraft Bedrock...
start "" "minecraft:"
timeout /t 2 >nul
goto status

:exit
taskkill /F /T /IM "%SERVER_EXE%" >nul 2>&1
taskkill /F /T /IM "%PLAYIT_PROCESS%" >nul 2>&1
taskkill /F /T /IM "playit-windows-x86_64-signed.exe" >nul 2>&1
exit

:exit_and_shutdown
taskkill /F /T /IM "%SERVER_EXE%" >nul 2>&1
taskkill /F /T /IM "%PLAYIT_PROCESS%" >nul 2>&1
taskkill /F /T /IM "playit-windows-x86_64-signed.exe" >nul 2>&1
timeout /t 3 >nul
shutdown /s /t 0
exit
