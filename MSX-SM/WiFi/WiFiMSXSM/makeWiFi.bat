SET proga=WiFiMSXSM
@echo off
echo -------- Compilation of : 
echo %proga%
echo .
SET HEX2BINDIR=.\
SET HEX2BIN=hex2bin.exe 
SET ASM=sdasz80 
SET CC=sdcc 
SET DEST=dsk\

SET INCLUDEDIR=fusion-c\include\
SET LIBDIR=fusion-c\lib\

REM Use this if your application is not using main argc/argv like bellow
REM SET INC1=%INCLUDEDIR%crt0_msxdos.rel
REM SET ADDR_CODE=0x107

REM use this parameter if you are using crt0_msxdos_advanced
SET ADDR_CODE=0x180

SET ADDR_DATA=0x0

@echo on
SDCC --code-loc %ADDR_CODE% --data-loc %ADDR_DATA% --disable-warning 196 -mz80 --no-std-crt0 --opt-code-size fusion.lib -L %LIBDIR% WiFiMSXSM.c
@echo off

del %proga%.asm
del %proga%.ihx
del %proga%.lk
del %proga%.lst
del %proga%.map
del %proga%.noi
del %proga%.sym

:_end_
echo Done.