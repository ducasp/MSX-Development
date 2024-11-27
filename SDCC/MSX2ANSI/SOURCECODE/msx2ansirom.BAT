@echo off
if %1.==. (SET ASMFILE=msx2ansirom) else (SET ASMFILE=%1)
@echo on
SDASZ80 -o msx2ansirom.rel %ASMFILE%.asm
SDAR -rc msx2ansirom.lib msx2ansirom.rel