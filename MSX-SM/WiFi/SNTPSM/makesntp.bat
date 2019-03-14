SET proga=sntpsm
@echo off
echo -------- Compilation of : 
echo %proga%
echo .
SET HEX2BINDIR=.\
SET HEX2BIN=hex2bin.exe 
SET ASM=sdasz80 
SET CC=sdcc 

SET INCLUDEDIR=fusion-c\include\
SET LIBDIR=fusion-c\lib\

REM  Standard crt0
SET INC1=%INCLUDEDIR%crt0_msxdos_advanced.rel

REM use this parameter if you are using crt0_msxdos_advanced
SET ADDR_CODE=0x180

SET ADDR_DATA=0x0

IF NOT EXIST WiFiMSXSM.rel GOTO _generatelib_

:_compile_
@echo on
SDCC --code-loc %ADDR_CODE% --data-loc %ADDR_DATA% --disable-warning 196 -mz80 --no-std-crt0 --opt-code-size fusion.lib -L %LIBDIR% %INC1% %INC2% %INC3% %INC4% %INC5% %INC6% %INC7% %INC8% %INC9% %INCA% %INCB% %INCC% %INCD% %INCE% %INCF% %proga%.c  WiFiMSXSM.rel
@echo off

SET cpath=%~dp0

IF NOT EXIST %proga%.ihx GOTO _end_
echo ... Compilation OK
@echo on

hex2bin -e com %proga%.ihx

@echo off

del %proga%.asm
del %proga%.ihx
del %proga%.lk
del %proga%.lst
del %proga%.map
del %proga%.noi
del %proga%.sym
del %proga%.rel

GOTO _end_

:_generatelib_
IF NOT EXIST WiFiMSXSM.c GOTO _errorbat_
SDCC --code-loc %ADDR_CODE% --data-loc %ADDR_DATA% --disable-warning 196 -mz80 --no-std-crt0 --opt-code-size fusion.lib -L %LIBDIR% WiFiMSXSM.c
del WiFiMSXSM.asm
del WiFiMSXSM.ihx
del WiFiMSXSM.lk
del WiFiMSXSM.lst
del WiFiMSXSM.map
del WiFiMSXSM.noi
del WiFiMSXSM.sym
IF NOT EXIST WiFiMSXSM.rel GOTO _generateliberror_
GOTO _compile_

:_generateliberror_
echo Didn't generate a WiFiMSXSM.rel, can't compile!
GOTO _end_

:_errorbat_
echo No WiFiMSXSM.bat or WiFiMSXSM.rel files found, can't compile!
GOTO _end_

:_end_
echo Done.