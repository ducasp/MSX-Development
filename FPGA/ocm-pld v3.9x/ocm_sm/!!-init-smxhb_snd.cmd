@echo off
rem --- '!!-init-smxhb_snd.cmd' v2.7 by Ducasp (2022.04.10)
rem based on '!!-init-smx.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set FOLDER=init_
set DEVICE=smxhb_snd
if "%1"=="" color 71&title INIT for SMX-HB w/ Extra Sound Support
if not exist "%FOLDER%%DEVICE%\" goto err_msg
rem ---------------cleanup----------------
call !!-cleanup.cmd --no-wait
rem --------------------------------------

:smx
rem.>"__%DEVICE%__"
xcopy /S /E /Y "%FOLDER%%DEVICE%\*.*" >nul 2>nul
echo.&echo SMX-HB w/ Extra Sound Support is ready to compile!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%FOLDER%%DEVICE%\' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
