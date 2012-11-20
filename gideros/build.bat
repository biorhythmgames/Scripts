@echo off
setlocal
REM ************************************************
REM **** Here are the settings you need to edit ****
REM **** make sure they point at your paths!    ****
REM path to android SDK
SET ASDKPath="z:\full-path-to-your\android-sdk"
REM path to Ant bin directory
SET AntPath="z:\full-path-to-your-ant\bin\"
REM default target:(I have this set to 2 yours may differ)
SET tgt=2
REM Select the target if specified
IF "%1"=="-t" IF NOT "%2"=="" SET tgt=%2
REM **** Edit paths/settings above.
REM ************************************************
REM Feel free to modify the script below.

call :init
    IF %initfail%=="fail" exit /b

IF "%1"=="-h" goto help & exit /b
call :beginmessage

REM Get Android SDK to update the project for the target, etc
echo(
call :echoc 1f "attempting to update project to target "
call :echoc 0a "[%tgt%]" \n
CALL %ASDKPath%tools\android update project --path "%cd%" -t %tgt%

REM Build the APK with Ant debug.
echo(
call :echoc 1f "attempting to build debug APK" \n
CALL %AntPath%ant debug
REM get the path to the debug apk output:
SET deployAPK=
FOR %%f IN ("%cd%\bin\*Activity-debug.apk") DO SET deployAPK=%%f
echo(
call :echoc 1f "attempting to deploy APK to device" \n
REM if the apk is where it should be, deploy it to the device using adb:
IF NOT "%deployAPK%"=="" CALL %ASDKPath%platform-tools\adb install -r "%deployAPK%"
REM if not, tell the user we couldn't find it - maybe the build failed, or
REM maybe the project is configured to output the build somewhere else.
IF "%deployAPK%"=="" call :echoc c0 "could not find APK to deploy" \n

call :complete
exit /b

REM ****** DONE ******

:beginmessage
echo(
call :echoc a0 " --- executing build & deploy --- " \n
echo(
exit /b

:echoc Color  Str  [\n]
setlocal
set "str=%~2"
call :colorPrintVar %1 str %3
exit /b

:colorPrintVar  Color  StrVar  [\n]
if not defined %~2 exit /b
setlocal enableDelayedExpansion
set "str=a%DEL%!%~2:\=a%DEL%\..\%DEL%%DEL%%DEL%!"
set "str=!str:/=a%DEL%/..\%DEL%%DEL%%DEL%!"
set "str=!str:"=\"!"
pushd "%temp%"
findstr /p /A:%1 "." "!str!\..\x" nul
if /i "%~3"=="\n" echo(
exit /b

:initColorPrint
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "DEL=%%a"
<nul >"%temp%\x" set /p "=%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%.%DEL%"
exit /b

:cleanupColorPrint
del "%temp%\x"
exit /b

:complete
echo(
echo(
call :echoc 0f "See "
call :echoc 4e "http://BiorhythmGames.com/" 
call :echoc 0f " for details or updates on this script" \n
echo(
call :echoc 00 "for help type: "
call :echoc 08 "build -h" \n
echo(
pause
call :cleanupColorPrint
exit /b

:init
REM Initialize the color echoc stuff.
SET initfail=""
call :initColorPrint
call :echoc 08 "This script is provided AS IS without warranty of any kind - implied, inferred   or otherwise. The entire risk arising out of the use or performance of the     script and documentation remains with you." \n
echo(
call :echoc 3f "   *  Android Build & Deploy script  *   " \n
           echo This script uses Android SDK and ANT to build ^& deploy
           echo  a debug version of your Android app (APK).
call :echoc 08 "(The above tools will require you have the JDK installed)." \n
call :echoc 0a "Usage:"
call :echoc 0f "build" \n
           echo   builds and deploys an app to your
           echo   connected Android device.
call :echoc 0a "Usage:"
call :echoc 0f "build -t 3" \n
           echo -t [target id] builds the app for the target specified
           echo       - you can list the targets available using the following command:
call :echoc 03 "        >"
call :echoc 08 "android"
call :echoc 08 " list targets" \n
           echo         from your android SDK tools directory
           echo    builds to specified target and deploys an app to your
           echo    connected Android device.
echo(
call :echoc 0f "See "
call :echoc 4c "http://BiorhythmGames.com/"
call :echoc 0f " for details or updates on this script" \n

IF %ASDKPath%=="z:\full-path-to-your\android-sdk" goto setpaths
IF %AntPath%=="z:\full-path-to-your-ant\bin\" goto setpaths
exit /b

:setpaths
SET initfail="fail"
echo( & call :echoc ce "WARNING "
call :echoc cf "- you must set your "
call :echoc ce "paths"
call :echoc cf " before using this script." \n
:help
echo( & call :echoc 0f "For more help visit "
call :echoc 4c "http://BiorhythmGames.com/" \n
pause
exit /b
