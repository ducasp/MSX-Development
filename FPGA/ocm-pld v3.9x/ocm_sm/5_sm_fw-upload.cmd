@echo off
rem --- '5_sm_fw-upload.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set PROJECT=ocm_sm
set CABLE="USB-Blaster [USB-0]"
if "%1"=="" color 1f&title FW-UPLOAD for %PROJECT%
if not exist %PROJECT%_device.env goto err_init
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cycloneive" goto err_quartus
if not exist fw\recovery.jic goto err_msg
if "%1"=="" echo.&echo Hardware Setup: %CABLE%&echo.&echo Press any key to start programming...&pause >nul 2>nul&cls
echo.&echo Uploading...&echo.&echo Firmware: "%~dp0fw\recovery.jic"&echo.

copy /Y fw\recovery.jic %PROJECT%.jic >nul 2>nul
"%QUARTUS_ROOTDIR%\bin\quartus_pgm.exe" -c %CABLE% %PROJECT%.cdf >nul 2>nul
if %ERRORLEVEL% == 0 (cls&echo.&echo PROGRAMMING SUCCEEDED!) else (color 4f&cls&echo.&echo PROGRAMMING FAILED!)
del %PROJECT%.jic >nul 2>nul
goto timer

:err_init
if "%1"=="" color f0
echo.&echo Please initialize a device first!
goto timer

:err_quartus
if "%1"=="" color f0
if "%1"=="" echo.&echo Quartus II was not found or unsupported device!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo 'fw\recovery.jic' not found!

:timer
waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
