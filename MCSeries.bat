@echo off
cls
goto play

:play
cls
Title Minecraft Bedrock Dedicated Server - Menu
goto menu

:menu
cls
echo =======================
echo    BDS Menu by abril
echo =======================
goto menu2

:menu2
echo.
echo Bedrock Dedicated Server Menu.
echo.
echo Notice:
echo To turn activate Bedrock Dedicated Server, please activate the following requests.
echo [1] Tunnel
echo [2] BDS
echo [3] VC
echo.
echo In a few moments the preparations will begin. Do you want to continue the process? (Y/N) 
set /p "q= "
if /I "%q%" == "Y" goto start
if /I "%q%" == "N" goto menu2

:start
cls
start "" "C:\Program Files\playit_gg\bin\playit.exe"
start "" "https://playit.gg/account/tunnels"
timeout /t 2 >nul
:CEK
tasklist /FI "IMAGENAME playit.exe" | find /I "playit.exe" >nul
if %errorlevel%==0 (
    echo playit.exe is not running. Please retry!
    echo.
    goto CEK
) else (
    echo playit.exe is running.
)

echo.
echo Activating the "Minecraft Bedrock Dedicated Server"..
echo.
:: Create a temporary script to run the server as administrator
echo @echo off > "%temp%\run_bds.bat"
echo start "" "C:\Users\abril\Documents\MCServer\World1\bedrock_server.exe" >> "%temp%\run_bds.bat"
echo exit >> "%temp%\run_bds.bat"

:: Run the temporary script as administrator
powershell -Command "Start-Process cmd -ArgumentList '/c %temp%\run_bds.bat' -Verb RunAs"
timeout /t 2 >nul

:CEK2
tasklist /FI "IMAGENAME eq bedrock_server.exe" | find /I "bedrock_server.exe" >nul
if %errorlevel%==0 (
    echo bedrock_server.exe is running.
) else (
    echo bedrock_server.exe is not running. Please retry!
    goto CEK2
)

@REM echo Activating the "Proximity Voice Chat"..
@REM echo.
@REM :: Create a temporary script to run the VC as administrator
@REM echo @echo off > "%temp%\run_vc.bat"
@REM echo start "" "D:\Abril\Application\minecraft\VoiceCraft.Server\VoiceCraft.Server.exe" >> "%temp%\run_vc.bat"
@REM echo exit >> "%temp%\run_vc.bat"

@REM :: Run the temporary script as administrator
@REM powershell -Command "Start-Process cmd -ArgumentList '/c %temp%\run_vc.bat' -Verb RunAs"
@REM timeout /t 2 >nul

@REM :CEK3
@REM tasklist /FI "IMAGENAME eq VoiceCraft.Server.exe" | find /I "VoiceCraft.Server.exe" >nul
@REM if %errorlevel%==0 (
@REM     echo VoiceCraft.Server.exe is running.
@REM     echo.
@REM     echo Follow the next command to complete VC mode.
@REM     echo Enter the following IP address and Port.
@REM     echo IP  : 127.0.0.1
@REM     echo PORT: 9050
@REM     echo Use the following command to enable VC mode. 
@REM     echo "/scriptevent voicecraft:voice connect [IP] [Port]"
@REM ) else (
@REM     echo VoiceCraft.Server.exe is not running. Please retry!
@REM     goto CEK3
@REM )

:menu3
cls
echo =======================
echo    BDS Menu by abril
echo =======================
echo.
echo Bedrock Dedicated Server Status: Activated
echo Tunnel: Online
echo BDS   : Online
echo VC    : Online
echo.
echo.
pause
echo [Exit] to exit
echo [Restart] to restart
set /p "q1= "
if /I "%q1%" == "exit" goto exit
if /I "%q1%" == "restart" goto start

:exit
echo.
echo Exiting the script and closing all related applications...
echo.

:: Terminate the running applications gracefully
taskkill /F /T /IM "bedrock_server.exe" >nul 2>&1
timeout /t 2 >nul
taskkill /F /T /IM "VoiceCraft.Server.exe" >nul 2>&1
timeout /t 2 >nul
taskkill /F /T /IM "playit-windows-x86_64-signed.exe" >nul 2>&1
timeout /t 2 >nul

echo All applications have been terminated.
pause
exit /b