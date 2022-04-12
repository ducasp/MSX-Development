@echo off
rem --- '!!-init-smx_franky.cmd' v2.7 by Ducasp (2022.04.11)

set TIMEOUT=1
set FOLDER=init_
set DEVICE=smx_franky
if "%1"=="" color 4f&title INIT for SM-X Franky
if not exist "%FOLDER%%DEVICE%\" goto err_msg
rem ---------------cleanup----------------
call !!-cleanup.cmd --no-wait
rem --------------------------------------

:smx
rem.>"__%DEVICE%__"
xcopy /S /E /Y "%FOLDER%%DEVICE%\*.*" >nul 2>nul
echo.&echo SM-X Franky is ready to compile!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%FOLDER%%DEVICE%\' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
