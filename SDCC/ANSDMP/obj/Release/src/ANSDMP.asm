;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (MINGW64)
;--------------------------------------------------------
	.module ANSDMP
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _CountVdpInterrupt
	.globl _EndMyInterruptHandler
	.globl _InitializeMyInterruptHandler
	.globl _InterruptHandlerHelper
	.globl _AnsiPrint
	.globl _AnsiFinish
	.globl _AnsiInit
	.globl _DosCall
	.globl _Inkey
	.globl _Print
	.globl _printf
	.globl _uiIntCount
	.globl _RAMAD3
	.globl _AllIntHook
	.globl _VdpIntHook
	.globl _TypeOfInt
	.globl _IntFunc
	.globl _MyHook
	.globl _OldHook
	.globl _regs
	.globl _uiGetSize
	.globl _ucBufferMemorySize
	.globl _ucCursor_On
	.globl _ucCursorOff
	.globl _ucSWInfoANSI
	.globl _ucSWInfo
	.globl _ucUsage
	.globl _IsValidInput
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_ucBufferMemorySize	=	0x3000
_uiGetSize::
	.ds 2
_regs::
	.ds 12
_OldHook::
	.ds 5
_MyHook::
	.ds 5
_IntFunc::
	.ds 5
_TypeOfInt::
	.ds 1
_VdpIntHook	=	0xfd9f
_AllIntHook	=	0xfd9a
_RAMAD3	=	0xf344
_uiIntCount::
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;src\ANSDMP.c:54: void InterruptHandlerHelper (void) __naked
;	---------------------------------
; Function InterruptHandlerHelper
; ---------------------------------
_InterruptHandlerHelper::
;src\ANSDMP.c:61: __endasm;
	push	af
	call	_IntFunc
	pop	af
	jp	_OldHook
;src\ANSDMP.c:62: }
;src\ANSDMP.c:64: void InitializeMyInterruptHandler (int myInterruptHandlerFunction, unsigned char isVdpInterrupt)
;	---------------------------------
; Function InitializeMyInterruptHandler
; ---------------------------------
_InitializeMyInterruptHandler::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;src\ANSDMP.c:67: MyHook[0]=0xF7; //RST 30 is interslot call both with bios or dos
	ld	hl, #_MyHook
	ld	(hl), #0xf7
;src\ANSDMP.c:68: MyHook[1]=RAMAD3; //Page 3 generally is not paged out and is the slot of the ram, so this should be good
	ld	hl, #(_MyHook + 0x0001)
	ld	iy, #_RAMAD3
	ld	a, 0 (iy)
	ld	(hl), a
;src\ANSDMP.c:69: MyHook[2]=(unsigned char)((int)InterruptHandlerHelper&0xff);
	ld	bc, #_MyHook + 2
	ld	a, #<(_InterruptHandlerHelper)
	ld	(bc), a
;src\ANSDMP.c:70: MyHook[3]=(unsigned char)(((int)InterruptHandlerHelper>>8)&0xff);
	ld	hl, #_MyHook + 3
	ld	bc, #_InterruptHandlerHelper
	ld	c, b
	ld	a, c
	rlc	a
	sbc	a, a
	ld	(hl), c
;src\ANSDMP.c:71: MyHook[4]=0xC9;
	ld	hl, #(_MyHook + 0x0004)
	ld	(hl), #0xc9
;src\ANSDMP.c:72: IntFunc[0]=0xCD; //CALL
	ld	hl, #_IntFunc
	ld	(hl), #0xcd
;src\ANSDMP.c:73: IntFunc[1]=(unsigned char)((int)myInterruptHandlerFunction&0xff);
	ld	bc, #_IntFunc + 1
	ld	a, 4 (ix)
	ld	(bc), a
;src\ANSDMP.c:74: IntFunc[2]=(unsigned char)(((int)myInterruptHandlerFunction>>8)&0xff);
	inc	hl
	inc	hl
	ld	c, 5 (ix)
	ld	a, c
	rlc	a
	sbc	a, a
	ld	b, a
	ld	(hl), c
;src\ANSDMP.c:75: IntFunc[3]=0xC9;
	ld	hl, #(_IntFunc + 0x0003)
	ld	(hl), #0xc9
;src\ANSDMP.c:76: TypeOfInt = isVdpInterrupt;
	ld	a, 6 (ix)
	ld	(_TypeOfInt+0), a
;src\/../../fusion-c/header/msx_fusion.h:296: __endasm; 
	di
;src\ANSDMP.c:79: if (isVdpInterrupt)
	or	a, a
	jr	Z,00125$
;src\ANSDMP.c:81: for(ui=0;ui<5;ui++)
	ld	c, #0x00
00110$:
;src\ANSDMP.c:82: OldHook[ui]=VdpIntHook[ui];
	ld	a, #<(_OldHook)
	add	a, c
	ld	e, a
	ld	a, #>(_OldHook)
	adc	a, #0x00
	ld	d, a
	ld	hl, #_VdpIntHook
	ld	b, #0x00
	add	hl, bc
	ld	a, (hl)
	ld	(de), a
;src\ANSDMP.c:81: for(ui=0;ui<5;ui++)
	inc	c
	ld	a, c
	sub	a, #0x05
	jr	C,00110$
;src\ANSDMP.c:83: for(ui=0;ui<5;ui++)
	ld	c, #0x00
00112$:
;src\ANSDMP.c:84: VdpIntHook[ui]=MyHook[ui];
	ld	de, #_VdpIntHook+0
	ld	a, e
	add	a, c
	ld	e, a
	jr	NC,00164$
	inc	d
00164$:
	ld	hl, #_MyHook
	ld	b, #0x00
	add	hl, bc
	ld	a, (hl)
	ld	(de), a
;src\ANSDMP.c:83: for(ui=0;ui<5;ui++)
	inc	c
	ld	a, c
	sub	a, #0x05
	jr	C,00112$
	jr	00107$
;src\ANSDMP.c:88: for(ui=0;ui<5;ui++)
00125$:
	ld	c, #0x00
00114$:
;src\ANSDMP.c:89: OldHook[ui]=AllIntHook[ui];
	ld	a, #<(_OldHook)
	add	a, c
	ld	e, a
	ld	a, #>(_OldHook)
	adc	a, #0x00
	ld	d, a
	ld	hl, #_AllIntHook
	ld	b, #0x00
	add	hl, bc
	ld	a, (hl)
	ld	(de), a
;src\ANSDMP.c:88: for(ui=0;ui<5;ui++)
	inc	c
	ld	a, c
	sub	a, #0x05
	jr	C,00114$
;src\ANSDMP.c:90: for(ui=0;ui<5;ui++)
	xor	a, a
	ld	-1 (ix), a
00116$:
;src\ANSDMP.c:91: AllIntHook[ui]=MyHook[ui];
	ld	bc, #_AllIntHook+0
	ld	a, c
	add	a, -1 (ix)
	ld	c, a
	jr	NC,00165$
	inc	b
00165$:
	ld	a, #<(_MyHook)
	add	a, -1 (ix)
	ld	e, a
	ld	a, #>(_MyHook)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
	ld	(bc), a
;src\ANSDMP.c:90: for(ui=0;ui<5;ui++)
	inc	-1 (ix)
	ld	a, -1 (ix)
	sub	a, #0x05
	jr	C,00116$
00107$:
;src\/../../fusion-c/header/msx_fusion.h:291: __endasm; 
	ei
;src\ANSDMP.c:95: EnableInterrupt();
;src\ANSDMP.c:96: }
	inc	sp
	pop	ix
	ret
_Done_Version:
	.ascii "Made with FUSION-C 1.2 (ebsoft)"
	.db 0x00
_ucUsage:
	.ascii "Usage: ansdmp <file>"
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.ascii "<file>: name of file containing ANSI image/animation"
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x00
_ucSWInfo:
	.ascii "> MSX ANSDMP v0.01 <"
	.db 0x0d
	.db 0x0a
	.ascii " (c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com"
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x00
_ucSWInfoANSI:
	.db 0x1b
	.ascii "[31m> MSX ANSDMP v0.01 <"
	.db 0x0d
	.db 0x0a
	.ascii " (c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com"
	.db 0x1b
	.ascii "[0m"
	.db 0x0d
	.db 0x0a
	.db 0x00
_ucCursorOff:
	.db 0x1b
	.ascii "x5"
	.db 0x00
_ucCursor_On:
	.db 0x1b
	.ascii "y5"
	.db 0x00
;src\ANSDMP.c:98: void EndMyInterruptHandler (void)
;	---------------------------------
; Function EndMyInterruptHandler
; ---------------------------------
_EndMyInterruptHandler::
;src\/../../fusion-c/header/msx_fusion.h:296: __endasm; 
	di
;src\ANSDMP.c:104: if (TypeOfInt)
	ld	iy, #_TypeOfInt
	ld	a, 0 (iy)
	or	a, a
	jr	Z,00117$
;src\ANSDMP.c:105: for(ui=0;ui<5;ui++)
	ld	c, #0x00
00108$:
;src\ANSDMP.c:106: VdpIntHook[ui]=OldHook[ui];
	ld	a, #<(_VdpIntHook)
	add	a, c
	ld	e, a
	ld	a, #>(_VdpIntHook)
	adc	a, #0x00
	ld	d, a
	ld	hl, #_OldHook
	ld	b, #0x00
	add	hl, bc
	ld	a, (hl)
	ld	(de), a
;src\ANSDMP.c:105: for(ui=0;ui<5;ui++)
	inc	c
	ld	a, c
	sub	a, #0x05
	jr	C,00108$
	jr	00105$
;src\ANSDMP.c:108: for(ui=0;ui<5;ui++)
00117$:
	ld	c, #0x00
00110$:
;src\ANSDMP.c:109: AllIntHook[ui]=OldHook[ui];
	ld	de, #_AllIntHook+0
	ld	a, e
	add	a, c
	ld	e, a
	jr	NC,00136$
	inc	d
00136$:
	ld	hl, #_OldHook
	ld	b, #0x00
	add	hl, bc
	ld	a, (hl)
	ld	(de), a
;src\ANSDMP.c:108: for(ui=0;ui<5;ui++)
	inc	c
	ld	a, c
	sub	a, #0x05
	jr	C,00110$
00105$:
;src\/../../fusion-c/header/msx_fusion.h:291: __endasm; 
	ei
;src\ANSDMP.c:112: EnableInterrupt();
;src\ANSDMP.c:114: }
	ret
;src\ANSDMP.c:126: unsigned int IsValidInput (char**argv, int argc, unsigned char *ucFile)
;	---------------------------------
; Function IsValidInput
; ---------------------------------
_IsValidInput::
	push	ix
	ld	ix,#0
	add	ix,sp
;src\ANSDMP.c:128: unsigned int iRet = 0;
	ld	bc, #0x0000
;src\ANSDMP.c:129: unsigned char * ucInput = (unsigned char*)argv[0];
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	e, (hl)
	inc	hl
	ld	h, (hl)
;src\ANSDMP.c:131: if (argc)
	ld	a, 7 (ix)
	or	a, 6 (ix)
	jr	Z,00102$
;src\ANSDMP.c:133: strcpy (ucFile, ucInput);
	ld	l, e
	ld	e, 8 (ix)
	ld	d, 9 (ix)
	xor	a, a
00110$:
	cp	a, (hl)
	ldi
	jr	NZ, 00110$
;src\ANSDMP.c:134: iRet = 1;
	ld	bc, #0x0001
00102$:
;src\ANSDMP.c:137: return iRet;
	ld	l, c
	ld	h, b
;src\ANSDMP.c:138: }
	pop	ix
	ret
;src\ANSDMP.c:142: void CountVdpInterrupt()
;	---------------------------------
; Function CountVdpInterrupt
; ---------------------------------
_CountVdpInterrupt::
;src\ANSDMP.c:144: uiIntCount++;
	ld	hl, (_uiIntCount)
	inc	hl
	ld	(_uiIntCount), hl
;src\ANSDMP.c:145: }
	ret
;src\ANSDMP.c:148: int main(char** argv, int argc)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-133
	add	hl, sp
	ld	sp, hl
;src\ANSDMP.c:153: unsigned char ucFirst = 1;
	ld	-5 (ix), #0x01
;src\ANSDMP.c:157: uiGetSize = 0;
	ld	hl, #0x0000
	ld	(_uiGetSize), hl
;src\ANSDMP.c:160: if(!IsValidInput(argv, argc, ucFile))
	ld	hl, #0
	add	hl, sp
	ld	-4 (ix), l
	ld	-3 (ix), h
	push	hl
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_IsValidInput
	pop	af
	pop	af
	pop	af
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	a, h
	or	a, -2 (ix)
	jr	NZ,00102$
;src\ANSDMP.c:163: Print(ucSWInfo);
	ld	hl, #_ucSWInfo
	push	hl
	call	_Print
;src\ANSDMP.c:164: Print(ucUsage);
	ld	hl, #_ucUsage
	ex	(sp),hl
	call	_Print
	pop	af
;src\ANSDMP.c:165: return 0;
	ld	hl, #0x0000
	jp	00116$
00102$:
;src\ANSDMP.c:168: regs.Words.DE = (int)ucFile;
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	ld	-2 (ix), c
	ld	-1 (ix), b
	ld	hl, #(_regs + 0x0004)
	ld	a, -2 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -1 (ix)
	ld	(hl), a
;src\ANSDMP.c:169: regs.Bytes.A = 1; //open for read
	ld	hl, #(_regs + 0x0001)
	ld	(hl), #0x01
;src\ANSDMP.c:170: DosCall(0x43, &regs, REGS_MAIN, REGS_MAIN);
	ld	de, #0x0202
	push	de
	ld	hl, #_regs
	push	hl
	ld	a, #0x43
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
;src\ANSDMP.c:172: fileHandle = regs.Bytes.B;
	ld	a,(#(_regs + 0x0003) + 0)
	ld	-2 (ix), a
;src\ANSDMP.c:174: if (regs.Bytes.A!=0)
	ld	a,(#(_regs + 0x0001) + 0)
	ld	-1 (ix), a
	or	a, a
	jr	Z,00104$
;src\ANSDMP.c:176: printf ("Failed to open file %s\r\n",ucFile);
	ld	a, -4 (ix)
	ld	-2 (ix), a
	ld	a, -3 (ix)
	ld	-1 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	hl, #___str_6
	push	hl
	call	_printf
	pop	af
	pop	af
;src\ANSDMP.c:177: return 0;
	ld	hl, #0x0000
	jp	00116$
00104$:
;src\ANSDMP.c:180: AnsiInit();
	call	_AnsiInit
;src\ANSDMP.c:184: do
00110$:
;src\ANSDMP.c:187: uiGetSize = BufferMemorySize;
	ld	hl, #0x8000
	ld	(_uiGetSize), hl
;src\ANSDMP.c:189: regs.Words.DE = (int)(ucBufferMemorySize); //where to data read
	ld	hl, #_ucBufferMemorySize
	ld	((_regs + 0x0004)), hl
;src\ANSDMP.c:190: regs.UWords.HL = uiGetSize; //get up to...
	ld	bc, #_regs + 6
	ld	l, c
	ld	h, b
	ld	iy, #_uiGetSize
	ld	a, 0 (iy)
	ld	(hl), a
	inc	hl
	ld	a, 1 (iy)
	ld	(hl), a
;src\ANSDMP.c:191: regs.Bytes.B = fileHandle; //file handle
	ld	hl, #(_regs + 0x0003)
	ld	a, -2 (ix)
	ld	(hl), a
;src\ANSDMP.c:192: DosCall(0x48, &regs, REGS_MAIN, REGS_MAIN);
	push	bc
	ld	de, #0x0202
	push	de
	ld	hl, #_regs
	push	hl
	ld	a, #0x48
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
	pop	bc
;src\ANSDMP.c:193: error = regs.Bytes.A;
	ld	hl, #(_regs + 0x0001) + 0
	ld	e, (hl)
;src\ANSDMP.c:194: if (ucFirst)
	ld	a, -5 (ix)
	or	a, a
	jr	Z,00106$
;src\ANSDMP.c:196: ucFirst = 0;
	xor	a, a
	ld	-5 (ix), a
;src\ANSDMP.c:197: uiIntCount = 0;
	ld	hl, #0x0000
	ld	(_uiIntCount), hl
;src\ANSDMP.c:198: InitializeMyInterruptHandler ((int)CountVdpInterrupt,1);
	ld	hl, #_CountVdpInterrupt
	push	bc
	push	de
	ld	a, #0x01
	push	af
	inc	sp
	push	hl
	call	_InitializeMyInterruptHandler
	pop	af
	inc	sp
	pop	de
	pop	bc
00106$:
;src\ANSDMP.c:202: if (error==0)
	ld	a, e
	or	a, a
	jr	NZ,00112$
;src\ANSDMP.c:204: uiGetSize = regs.UWords.HL;
	ld	l, c
	ld	h, b
	ld	a, (hl)
	ld	(_uiGetSize+0), a
	inc	hl
	ld	a, (hl)
	ld	(_uiGetSize+1), a
;src\ANSDMP.c:206: ucBufferMemorySize[uiGetSize] = 0;
	ld	bc, #_ucBufferMemorySize+0
	ld	hl, (_uiGetSize)
	add	hl, bc
	ld	(hl), #0x00
;src\ANSDMP.c:207: AnsiPrint(ucBufferMemorySize);
	ld	hl, #_ucBufferMemorySize
	call	_AnsiPrint
;src\ANSDMP.c:219: while (1);
	jp	00110$
00112$:
;src\ANSDMP.c:220: EndMyInterruptHandler();
	call	_EndMyInterruptHandler
;src\ANSDMP.c:222: while (!Inkey());
00113$:
	call	_Inkey
	ld	-1 (ix), l
	ld	a, l
	or	a, a
	jr	Z,00113$
;src\ANSDMP.c:227: AnsiFinish();
	call	_AnsiFinish
;src\ANSDMP.c:229: printf("Interrupt counted %u ticks...\r\n",uiIntCount);
	ld	hl, (_uiIntCount)
	push	hl
	ld	hl, #___str_7
	push	hl
	call	_printf
	pop	af
	pop	af
;src\ANSDMP.c:231: return 0;
	ld	hl, #0x0000
00116$:
;src\ANSDMP.c:232: }
	ld	sp, ix
	pop	ix
	ret
___str_6:
	.ascii "Failed to open file %s"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_7:
	.ascii "Interrupt counted %u ticks..."
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
