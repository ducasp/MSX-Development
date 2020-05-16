@echo off
if %1.==. (SET ASMFILE=msx2ansi) else (SET ASMFILE=%1)
@echo on
SDASZ80 -o msx2ansi.rel %ASMFILE%.asm
SDAR -rc msx2ansi.lib msx2ansi.rel
copy msx2ansi.lib c:\fusion-c\fusion-c\lib /y