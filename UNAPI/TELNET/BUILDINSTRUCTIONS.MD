# HOW TO BUILD USING LINUX

Piter Punk was very kind in providing a Makefile that should worf with Linux.
It seems you just need to create a folder within fusion-c installation folder
and move all files, including make file, to it. :)

# HOW TO BUILD USING WINDOWS

My setup to build is:

- Windows PC
- Fusion-C Library ( you can get it for free at http://www.ebsoft.fr/shop/en/home/66-fusion-c.html )
- SDCC 4.0.0 ( Eric recommends 3.6.0 for fusion-c, but it is not good dealing with switch/case and 
  nested IFs and end-up causing errors with this code)
- CodeBlocks as Dev GUI

***LIBRARIES***

Remember to copy the needed libraries and headers to your fusion-c lib and header folders!

You will need the following libraries and their headers:

	- Konamiman's ASM.LIB ( https://www.konamiman.com/msx/sdcc/asmlib.zip )
	- Oduvaldo & Tobias Keizer MSX2ANSI.LIB ( https://github.com/ducasp/MSX-Development/tree/master/SDCC/MSX2ANSI )

***SET UP USING CODE BLOCKS***

In your fusion-c installation folder (mine is Windows and in C:\fusion-c), create a folder for this 
source code (i.e.: telnet) and then copy telnet.cbp, the src folder and all its contents to it. Make 
sure your fusion-c installation folder has hex2bin executable. 

Make sure hex2bin executable is in your fusion-c installation folder (i.e.: C:\fusion-c)

***I DON'T LIKE/WANT CODE BLOCKS***

If you don't wanna use CodeBlocks as a GUI for SDCC/Fusion-C, then you could extract the parameters 
from cbp project and create your own makefile / bat / script file.

P.s.: this is the output when building from codeblocks, so that might help if you wanna create your own 
makefile or bat file... :)

-------------- Clean: Release in Telnet (compiler: Small Device C Compiler)---------------

Cleaned "Telnet - Release"

-------------- Build: Release in Telnet (compiler: Small Device C Compiler)---------------

sdcc.exe --out-fmt-ihx --no-std-crt0 -mz80 --opt-code-speed --verbose --code-loc 0x180 --data-loc 0x0 --disable-warning 196 --allow-unsafe-read -I..\fusion-c\header -I"C:\Program Files\SDCC\include" -c src\print.c -o obj\Release\src\print.rel

sdcc.exe --out-fmt-ihx --no-std-crt0 -mz80 --opt-code-speed --verbose --code-loc 0x180 --data-loc 0x0 --disable-warning 196 --allow-unsafe-read -I..\fusion-c\header -I"C:\Program Files\SDCC\include" -c src\Telnet.c -o obj\Release\src\Telnet.rel

sdcc.exe --out-fmt-ihx --no-std-crt0 -mz80 --opt-code-speed --verbose --code-loc 0x180 --data-loc 0x0 --disable-warning 196 --allow-unsafe-read -I..\fusion-c\header -I"C:\Program Files\SDCC\include" -c src\UnapiHelper.c -o obj\Release\src\UnapiHelper.rel

sdcc.exe --out-fmt-ihx --no-std-crt0 -mz80 --opt-code-speed --verbose --code-loc 0x180 --data-loc 0x0 --disable-warning 196 --allow-unsafe-read -I..\fusion-c\header -I"C:\Program Files\SDCC\include" -c src\XYMODEM.c -o obj\Release\src\XYMODEM.rel

sdcc: Calling preprocessor...

sdcc: sdcpp.exe -nostdinc -Wall -std=c11 -I"..\fusion-c\header" -I"C:\Program Files\SDCC\include" -obj-ext=.rel -D__SDCC_STACK_AUTO -D__SDCC_CHAR_UNSIGNED -D__SDCC_INT_LONG_REENT -D__SDCC_FLOAT_REENT -D__SDCC=3_9_0 -D__SDCC_VERSION_MAJOR=3 -D__SDCC_VERSION_MINOR=9 -D__SDCC_VERSION_PATCH=0 -D__SDCC_REVISION=11195 -D__SDCC_z80 -D__STDC_NO_COMPLEX__=1 -D__STDC_NO_THREADS__=1 -D__STDC_NO_ATOMICS__=1 -D__STDC_NO_VLA__=1 -D__STDC_ISO_10646__=201409L -D__STDC_UTF_16__=1 -D__STDC_UTF_32__=1 -isystem "C:\Program Files\SDCC\bin\..\include\z80" -isystem "C:\Program Files\SDCC\bin\..\include" "src\XYMODEM.c"

sdcc: Generating code...

sdcc: Calling preprocessor...

sdcc: sdcpp.exe -nostdinc -Wall -std=c11 -I"..\fusion-c\header" -I"C:\Program Files\SDCC\include" -obj-ext=.rel -D__SDCC_STACK_AUTO -D__SDCC_CHAR_UNSIGNED -D__SDCC_INT_LONG_REENT -D__SDCC_FLOAT_REENT -D__SDCC=3_9_0 -D__SDCC_VERSION_MAJOR=3 -D__SDCC_VERSION_MINOR=9 -D__SDCC_VERSION_PATCH=0 -D__SDCC_REVISION=11195 -D__SDCC_z80 -D__STDC_NO_COMPLEX__=1 -D__STDC_NO_THREADS__=1 -D__STDC_NO_ATOMICS__=1 -D__STDC_NO_VLA__=1 -D__STDC_ISO_10646__=201409L -D__STDC_UTF_16__=1 -D__STDC_UTF_32__=1 -isystem "C:\Program Files\SDCC\bin\..\include\z80" -isystem "C:\Program Files\SDCC\bin\..\include" "src\Telnet.c"

sdcc: Generating code...

src\print.c:37: warning 85: in function print unreferenced function argument : 's'

src\print.c:51: warning 85: in function printChar unreferenced function argument : 'c'

sdcc: Calling preprocessor...

sdcc: sdcpp.exe -nostdinc -Wall -std=c11 -I"..\fusion-c\header" -I"C:\Program Files\SDCC\include" -obj-ext=.rel -D__SDCC_STACK_AUTO -D__SDCC_CHAR_UNSIGNED -D__SDCC_INT_LONG_REENT -D__SDCC_FLOAT_REENT -D__SDCC=3_9_0 -D__SDCC_VERSION_MAJOR=3 -D__SDCC_VERSION_MINOR=9 -D__SDCC_VERSION_PATCH=0 -D__SDCC_REVISION=11195 -D__SDCC_z80 -D__STDC_NO_COMPLEX__=1 -D__STDC_NO_THREADS__=1 -D__STDC_NO_ATOMICS__=1 -D__STDC_NO_VLA__=1 -D__STDC_ISO_10646__=201409L -D__STDC_UTF_16__=1 -D__STDC_UTF_32__=1 -isystem "C:\Program Files\SDCC\bin\..\include\z80" -isystem "C:\Program Files\SDCC\bin\..\include" "src\print.c"

sdcc: Generating code...

sdcc: Calling assembler...

sdcc: sdasz80.exe -plosgffw "obj\Release\src\print.rel" "obj\Release\src\print".asm

sdcc.exe -L"C:\Program Files\SDCC\lib" -o bin\Release\Telnet.exe --out-fmt-ihx --no-std-crt0 -mz80 --opt-code-speed --verbose --code-loc 0x180 --data-loc 0x0 --disable-warning 196 --allow-unsafe-read ..\fusion-c\include\crt0_msxdos_advanced.rel ..\fusion-c\lib\msx2ansi.lib ..\fusion-c\lib\fusion.lib ..\fusion-c\lib\asm.lib obj\Release\src\print.rel obj\Release\src\Telnet.rel obj\Release\src\UnapiHelper.rel obj\Release\src\XYMODEM.rel

sdcc: Calling preprocessor...

sdcc: sdcpp.exe -nostdinc -Wall -std=c11 -I"..\fusion-c\header" -I"C:\Program Files\SDCC\include" -obj-ext=.rel -D__SDCC_STACK_AUTO -D__SDCC_CHAR_UNSIGNED -D__SDCC_INT_LONG_REENT -D__SDCC_FLOAT_REENT -D__SDCC=3_9_0 -D__SDCC_VERSION_MAJOR=3 -D__SDCC_VERSION_MINOR=9 -D__SDCC_VERSION_PATCH=0 -D__SDCC_REVISION=11195 -D__SDCC_z80 -D__STDC_NO_COMPLEX__=1 -D__STDC_NO_THREADS__=1 -D__STDC_NO_ATOMICS__=1 -D__STDC_NO_VLA__=1 -D__STDC_ISO_10646__=201409L -D__STDC_UTF_16__=1 -D__STDC_UTF_32__=1 -isystem "C:\Program Files\SDCC\bin\..\include\z80" -isystem "C:\Program Files\SDCC\bin\..\include" "src\UnapiHelper.c"

sdcc: Generating code...

sdcc: Calling assembler...

sdcc: sdasz80.exe -plosgffw "obj\Release\src\UnapiHelper.rel" "obj\Release\src\UnapiHelper".asm

sdcc: Calling assembler...

sdcc: sdasz80.exe -plosgffw "obj\Release\src\Telnet.rel" "obj\Release\src\Telnet".asm

sdcc: Calling assembler...

sdcc: sdasz80.exe -plosgffw "obj\Release\src\XYMODEM.rel" "obj\Release\src\XYMODEM".asm

sdcc: Calling linker...

sdcc: sdldz80.exe -nf "bin\Release\Telnet.lk"

Output file is bin\Release\Telnet.exe with size 47.19 KB

Running target post-build steps

cmd /c ren bin\Release\Telnet.exe Telnet.ihx

cmd /c ..\hex2bin -e com bin\Release\Telnet.ihx

hex2bin v1.0.12, Copyright (C) 2012 Jacques Pelletier & contributors

Lowest address = 00000100

Highest address = 000052D9

Pad Byte = FF

8-bit Checksum = E1

Process terminated with status 0 (0 minute(s), 15 second(s))

0 error(s), 2 warning(s) (0 minute(s), 15 second(s))
