# HOW TO BUILD

My setup to build is:

- Windows PC
- Fusion-C Library ( you can get it for free at http://www.ebsoft.fr/shop/en/home/66-fusion-c.html )
- SDCC 4.0.0
- CodeBlocks as Dev GUI

***LIBRARIES***

Remember to copy the needed libraries and headers to your fusion-c lib and header folders!

You will need the following libraries and their headers:

	- Konamiman's ASM.LIB and BASE64.LIB ( https://www.konamiman.com/msx/sdcc/asmlib.zip https://www.konamiman.com/msx/sdcc/base64lib.zip )
	- Oduvaldo & Tobias Keizer MSX2ANSI.LIB ( https://github.com/ducasp/MSX-Development/tree/master/SDCC/MSX2ANSI )

***SET UP USING CODE BLOCKS***

In your fusion-c installation folder (mine is Windows and in C:\fusion-c), create a folder for this 
source code (i.e.: HUBG) and then copy HUBG.cbp, the src folder and all its contents to it. Make 
sure your fusion-c installation folder has hex2bin executable. 

Make sure hex2bin executable is in your fusion-c installation folder (i.e.: C:\fusion-c)

***I DON'T LIKE/WANT CODE BLOCKS***

If you don't wanna use CodeBlocks as a GUI for SDCC/Fusion-C, then you could extract the parameters 
from cbp project and create your own makefile / bat / script file.

P.s.: this is the output when building from codeblocks, so that might help if you wanna create your own 
makefile or bat file... :)

-------------- Clean: Release in HUBG (compiler: Small Device C Compiler)---------------

Cleaned "HUBG - Release"

-------------- Build: Release in HUBG (compiler: Small Device C Compiler)---------------

sdcc.exe  --out-fmt-ihx --no-std-crt0 -mz80 --opt-code-speed --verbose --code-loc 0x180 --data-loc 0x0 --disable-warning 196  --allow-unsafe-read    -I..\fusion-c\header -I"C:\Program Files\SDCC\include" -c src\HUBG.c -o obj\Release\src\HUBG.rel
sdcc.exe  --out-fmt-ihx --no-std-crt0 -mz80 --opt-code-speed --verbose --code-loc 0x180 --data-loc 0x0 --disable-warning 196  --allow-unsafe-read    -I..\fusion-c\header -I"C:\Program Files\SDCC\include" -c src\hget.c -o obj\Release\src\hget.rel
sdcc: Calling preprocessor...
sdcc: sdcpp.exe -nostdinc -Wall -std=c11 -I"..\fusion-c\header" -I"C:\Program Files\SDCC\include" -obj-ext=.rel -D__SDCC_STACK_AUTO -D__SDCC_CHAR_UNSIGNED -D__SDCC_INT_LONG_REENT -D__SDCC_FLOAT_REENT -D__SDCC=4_0_0 -D__SDCC_VERSION_MAJOR=4 -D__SDCC_VERSION_MINOR=0 -D__SDCC_VERSION_PATCH=0 -D__SDCC_REVISION=11528 -D__SDCC_z80 -D__STDC_NO_COMPLEX__=1 -D__STDC_NO_THREADS__=1 -D__STDC_NO_ATOMICS__=1 -D__STDC_NO_VLA__=1 -D__STDC_ISO_10646__=201409L -D__STDC_UTF_16__=1 -D__STDC_UTF_32__=1 -isystem "C:\Program Files\SDCC\bin\..\include\z80" -isystem "C:\Program Files\SDCC\bin\..\include"  "src\HUBG.c" 
sdcc: Generating code...
src\HUBG.c:1386: warning 85: in function main unreferenced function argument : 'argv'
src\HUBG.c:1386: warning 85: in function main unreferenced function argument : 'argc'
sdcc: Calling assembler...
sdcc: sdasz80.exe -plosgffw "obj\Release\src\HUBG.rel" "obj\Release\src\HUBG".asm
sdcc.exe  --out-fmt-ihx --no-std-crt0 -mz80 --opt-code-speed --verbose --code-loc 0x180 --data-loc 0x0 --disable-warning 196  --allow-unsafe-read    -I..\fusion-c\header -I"C:\Program Files\SDCC\include" -c src\dos.c -o obj\Release\src\dos.rel
sdcc: Calling preprocessor...
sdcc: sdcpp.exe -nostdinc -Wall -std=c11 -I"..\fusion-c\header" -I"C:\Program Files\SDCC\include" -obj-ext=.rel -D__SDCC_STACK_AUTO -D__SDCC_CHAR_UNSIGNED -D__SDCC_INT_LONG_REENT -D__SDCC_FLOAT_REENT -D__SDCC=4_0_0 -D__SDCC_VERSION_MAJOR=4 -D__SDCC_VERSION_MINOR=0 -D__SDCC_VERSION_PATCH=0 -D__SDCC_REVISION=11528 -D__SDCC_z80 -D__STDC_NO_COMPLEX__=1 -D__STDC_NO_THREADS__=1 -D__STDC_NO_ATOMICS__=1 -D__STDC_NO_VLA__=1 -D__STDC_ISO_10646__=201409L -D__STDC_UTF_16__=1 -D__STDC_UTF_32__=1 -isystem "C:\Program Files\SDCC\bin\..\include\z80" -isystem "C:\Program Files\SDCC\bin\..\include"  "src\hget.c" 
sdcc: Generating code...
sdcc: Calling assembler...
sdcc: sdasz80.exe -plosgffw "obj\Release\src\hget.rel" "obj\Release\src\hget".asm
sdcc.exe -L"C:\Program Files\SDCC\lib" -o bin\Release\HUBG.exe  --out-fmt-ihx --no-std-crt0 -mz80 --opt-code-speed --verbose --code-loc 0x180 --data-loc 0x0 --disable-warning 196  --allow-unsafe-read    ..\fusion-c\include\crt0_msxdos_advanced.rel  ..\fusion-c\lib\msx2ansi.lib ..\fusion-c\lib\fusion.lib ..\fusion-c\lib\asm.lib ..\fusion-c\lib\base64.lib obj\Release\src\HUBG.rel obj\Release\src\hget.rel obj\Release\src\dos.rel
sdcc: Calling preprocessor...
sdcc: sdcpp.exe -nostdinc -Wall -std=c11 -I"..\fusion-c\header" -I"C:\Program Files\SDCC\include" -obj-ext=.rel -D__SDCC_STACK_AUTO -D__SDCC_CHAR_UNSIGNED -D__SDCC_INT_LONG_REENT -D__SDCC_FLOAT_REENT -D__SDCC=4_0_0 -D__SDCC_VERSION_MAJOR=4 -D__SDCC_VERSION_MINOR=0 -D__SDCC_VERSION_PATCH=0 -D__SDCC_REVISION=11528 -D__SDCC_z80 -D__STDC_NO_COMPLEX__=1 -D__STDC_NO_THREADS__=1 -D__STDC_NO_ATOMICS__=1 -D__STDC_NO_VLA__=1 -D__STDC_ISO_10646__=201409L -D__STDC_UTF_16__=1 -D__STDC_UTF_32__=1 -isystem "C:\Program Files\SDCC\bin\..\include\z80" -isystem "C:\Program Files\SDCC\bin\..\include"  "src\dos.c" 
sdcc: Generating code...
sdcc: Calling assembler...
sdcc: sdasz80.exe -plosgffw "obj\Release\src\dos.rel" "obj\Release\src\dos".asm
sdcc: Calling linker...
sdcc: sdldz80.exe -nf "bin\Release\HUBG.lk"
Output file is bin\Release\HUBG.exe with size 82.91 KB
Running target post-build steps
cmd /c ren bin\Release\HUBG.exe HUBG.ihx
cmd /c ..\hex2bin -e com bin\Release\HUBG.ihx
hex2bin v1.0.12, Copyright (C) 2012 Jacques Pelletier & contributors
Lowest address  = 00000100
Highest address = 0000B56D
Pad Byte        = FF
8-bit Checksum = 5E
Process terminated with status 0 (0 minute(s), 11 second(s))
0 error(s), 2 warning(s) (0 minute(s), 11 second(s))