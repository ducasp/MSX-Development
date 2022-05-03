@echo off
rem --- '1_sm_mega-build_and_collect.cmd' v2.7 by Ducasp (2022.04.21)

set TIMEOUT=1
set PROJECT=ocm_sm
set OUTPUT=output_files\
set CURSEED=Not detected
set SEEDENV=%PROJECT%_synthesis_seed.env
if "%1"=="" color 1f&title AUTO-COLLECT for %PROJECT%
if not exist %PROJECT%_device.env goto err_init
set DEVSTR=&set /P DEVICE=<%PROJECT%_device.env
if "%DEVICE%"=="smx" set DEVSTR= for SM-X
if "%DEVICE%"=="smx_frankysnd" set DEVSTR= for SM-X w/ Franky Sound
if "%DEVICE%"=="smxhb" set DEVSTR= for SMX-HB
if "%DEVICE%"=="smxhb_frankysnd" set DEVSTR= for SMX-HB w/ Franky Sound
if "%DEVICE%"=="smxmini" set DEVSTR= for SM-X Mini
if "%DEVICE%"=="smxmini_frankysnd" set DEVSTR= for SM-X Mini w/ Franky Sound
if "%DEVICE%"=="sx2" set DEVSTR= for SX-2
if "%DEVICE%"=="sx2_frankysnd" set DEVSTR= for SX-2 w/ Franky Sound
if "%1"=="--no-wait" color 1f&title Task "%~dp0%PROJECT%.qpf"%DEVSTR%
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cycloneive" goto err_quartus
if not exist src_addons\ goto err_msg
if exist %SEEDENV% set /P CURSEED=<%SEEDENV%
if "%1"=="" echo.&echo Building %DEVICE%...&echo. >nul 2>nul
echo.&echo Please wait...&echo.&if "%1"=="" echo Output path: "%~dp0output_files\"&echo.
rem ---------------cleanup----------------
call 2_sm_finalize.cmd --no-wait
call 3_sm_collect.cmd --no-wait
rem --------------------------------------
if exist old_packed_files if not exist old_packed_files\ del old_packed_files >nul 2>nul
if exist packed_files if not exist packed_files\ del packed_files >nul 2>nul
if exist packed_files\ if exist old_packed_files\ rd /S /Q old_packed_files\ >nul 2>nul
if exist packed_files\ ren packed_files old_packed_files >nul 2>nul
md packed_files\ >nul 2>nul
set PROJECT_KBD=us
echo.&echo Building %PROJECT_KBD% layout...
copy ..\esemsx3\src\peripheral\keymap.vhd.%PROJECT_KBD% ..\esemsx3\src\peripheral\keymap.vhd /y
call :build_current
call :pack_properly
set PROJECT_KBD=spanish
echo.&echo Building %PROJECT_KBD% layout...
copy ..\esemsx3\src\peripheral\keymap.vhd.%PROJECT_KBD% ..\esemsx3\src\peripheral\keymap.vhd /y
call :build_current
call :pack_properly
set PROJECT_KBD=french
echo.&echo Building %PROJECT_KBD% layout...
copy ..\esemsx3\src\peripheral\keymap.vhd.%PROJECT_KBD% ..\esemsx3\src\peripheral\keymap.vhd /y
call :build_current
call :pack_properly
set PROJECT_KBD=brazilian
echo.&echo Building %PROJECT_KBD% layout...
copy ..\esemsx3\src\peripheral\keymap.vhd.%PROJECT_KBD% ..\esemsx3\src\peripheral\keymap.vhd /y
call :build_current
call :pack_properly
goto timer

:pack_properly
ren recovery_d_b.jic recovery.jic >nul 2>nul
ren %PROJECT%_d_b.pld %PROJECT%.pld >nul 2>nul
tar -caf packed_files\%PROJECT%_%DEVICE%_dual_epbios_backslash_%PROJECT_KBD%.zip recovery.jic %PROJECT%.pld >nul 2>nul
del recovery.jic >nul 2>nul
del ocm_sm.pld >nul 2>nul
ren recovery_s_b.jic recovery.jic >nul 2>nul
ren %PROJECT%_s_b.pld %PROJECT%.pld >nul 2>nul
tar -caf packed_files\%PROJECT%_%DEVICE%_single_epbios_backslash_%PROJECT_KBD%.zip recovery.jic %PROJECT%.pld >nul 2>nul
ren recovery_d_y.jic recovery.jic >nul 2>nul
ren %PROJECT%_d_y.pld %PROJECT%.pld >nul 2>nul
tar -caf packed_files\%PROJECT%_%DEVICE%_dual_epbios_yen_%PROJECT_KBD%.zip recovery.jic %PROJECT%.pld >nul 2>nul
ren recovery_s_y.jic recovery.jic >nul 2>nul
ren %PROJECT%_s_y.pld %PROJECT%.pld >nul 2>nul
tar -caf packed_files\%PROJECT%_%DEVICE%_single_epbios_yen_%PROJECT_KBD%.zip recovery.jic %PROJECT%.pld >nul 2>nul
del *.jic
del *.pld
exit /b 0

:build_current
if exist "%QUARTUS_ROOTDIR%\bin64" set BIT=64
set STARTTIME=%TIME%
echo ^>^> Compile Design
echo   ^>^> Phase 1 - Analysis ^& Synthesis
"%QUARTUS_ROOTDIR%\bin%BIT%\quartus_map.exe" %PROJECT%.qpf >nul 2>nul
echo   ^>^> Phase 2 - Fitter (Place ^& Route)
"%QUARTUS_ROOTDIR%\bin%BIT%\quartus_fit.exe" %PROJECT%.qpf >nul 2>nul
echo   ^>^> Phase 3 - Assembler (Generate programming files)
"%QUARTUS_ROOTDIR%\bin%BIT%\quartus_asm.exe" %PROJECT%.qpf >nul 2>nul
echo   ^>^> Phase 4 - Convert programming files (EPCS64 Device)
set CONFIG=%PROJECT%_512k_dual_epbios_backslash
copy /Y %CONFIG%.cof %PROJECT%_512k.cof >nul 2>nul
"%QUARTUS_ROOTDIR%\bin%BIT%\quartus_cpf.exe" -c %PROJECT%_512k.cof >nul 2>nul
del %PROJECT%_512k.cof >nul 2>nul
ren %PROJECT%.jic recovery_d_b.jic >nul 2>nul
set CONFIG=%PROJECT%_512k_dual_epbios_yen
if not exist %PROJECT%_512k.cof copy /Y %CONFIG%.cof %PROJECT%_512k.cof >nul 2>nul
"%QUARTUS_ROOTDIR%\bin%BIT%\quartus_cpf.exe" -c %PROJECT%_512k.cof >nul 2>nul
del %PROJECT%_512k.cof >nul 2>nul
ren %PROJECT%.jic recovery_d_y.jic >nul 2>nul
set CONFIG=%PROJECT%_512k_single_epbios_backslash
copy /Y %CONFIG%.cof %PROJECT%_512k.cof >nul 2>nul
"%QUARTUS_ROOTDIR%\bin%BIT%\quartus_cpf.exe" -c %PROJECT%_512k.cof >nul 2>nul
del %PROJECT%_512k.cof >nul 2>nul
ren %PROJECT%.jic recovery_s_b.jic >nul 2>nul
set CONFIG=%PROJECT%_512k_single_epbios_yen
copy /Y %CONFIG%.cof %PROJECT%_512k.cof >nul 2>nul
"%QUARTUS_ROOTDIR%\bin%BIT%\quartus_cpf.exe" -c %PROJECT%_512k.cof >nul 2>nul
del %PROJECT%_512k.cof >nul 2>nul
ren %PROJECT%.jic recovery_s_y.jic >nul 2>nul
set ENDTIME=%TIME%
rem ---------------finalize----------------
if "%1"=="" color 1f&title FINALIZE for %PROJECT% for Layout %PROJECT_KBD%
rem.>%PROJECT%.qpf
rd /S /Q db\ >nul 2>nul
rd /S /Q greybox_tmp\ >nul 2>nul
rd /S /Q incremental_db\ >nul 2>nul
rd /S /Q simulation\ >nul 2>nul
del "## BUILDING FAILED ##.log" >nul 2>nul
del PLLJ_PLLSPE_INFO.txt >nul 2>nul
del *.map* >nul 2>nul
del *.qws* >nul 2>nul
del /S /Q *.bak >nul 2>nul
if "%1"=="" if not exist recovery_d_b.jic goto err_msg_fin
if "%1"=="" if not exist recovery_d_y.jic goto err_msg_fin
if "%1"=="" if not exist recovery_s_b.jic goto err_msg_fin
if "%1"=="" if not exist recovery_s_y.jic goto err_msg_fin
jic2pld recovery_d_b.jic %PROJECT%_d_b.pld >nul 2>nul
jic2pld recovery_d_y.jic %PROJECT%_d_y.pld >nul 2>nul
jic2pld recovery_s_b.jic %PROJECT%_s_b.pld >nul 2>nul
jic2pld recovery_s_y.jic %PROJECT%_s_y.pld >nul 2>nul
rem ---------------collect----------------
if not exist %PROJECT%_d_b.pld goto err_msg_col
if not exist %PROJECT%_d_y.pld goto err_msg_col
if not exist %PROJECT%_s_b.pld goto err_msg_col
if not exist %PROJECT%_s_y.pld goto err_msg_col
if "%1"=="" rd /S /Q %OUTPUT% >nul 2>nul
rem --------------------------------------
for /F "tokens=1-4 delims=:.," %%a in ("%STARTTIME%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
for /F "tokens=1-4 delims=:.," %%a in ("%ENDTIME%") do (
   set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
set /A elapsed=end-start
set /A hh=elapsed/(60*60*100), rest=elapsed%%(60*60*100), mm=rest/(60*100), rest%%=60*100, ss=rest/100
echo.&echo All done for this build!&echo.
exit /b 0

:not_done
if "%1"=="" color f0
echo.&echo Building failed!
if exist fw if not exist fw\ ren fw "## BUILDING FAILED ##.log" >nul 2>nul
rem.>>"## BUILDING FAILED ##.log"
goto timer

:err_init
if "%1"=="" color f0
echo.&echo Please initialize a device first!
goto timer

:err_quartus
if "%1"=="" color f0
echo.&echo Quartus II was not found or unsupported device!
goto timer

:err_msg_fin
if "%1"=="" color f0
echo.&echo '%PROJECT%.jic' not found!
goto timer

:err_msg_col
if "%1"=="" color f0
echo.&echo '%PROJECT%.pld' not found!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo 'src_addons\' not found!

:timer
waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
rem --- if "%1"=="" call 5_sm_fw-upload.cmd --no-wait
rem exit
