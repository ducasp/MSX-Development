;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.9.0 #11195 (MINGW32)
;--------------------------------------------------------
	.module print
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _printCharExtAnsi
	.globl _printExtAnsi
	.globl _endExtAnsi
	.globl _initExtAnsi
	.globl _print_strout
	.globl _print
	.globl _AsmCall
	.globl _prtregs
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_prtregs::
	.ds 12
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
;src\print.c:8: void print(char* s) __naked
;	---------------------------------
; Function print
; ---------------------------------
_print::
;src\print.c:30: __endasm;
	push	ix
	ld	ix,#4
	add	ix,sp
	ld	l,(ix)
	ld	h,1(ix)
	loop:
	ld	a,(hl)
	or	a
	jr	z,end
	ld	e,a
	ld	c,#2
	push	hl
	call	#5
	pop	hl
	inc	hl
	jr	loop
	end:
	pop	ix
	ret
;src\print.c:31: }
;src\print.c:33: void print_strout(char* s) __naked
;	---------------------------------
; Function print_strout
; ---------------------------------
_print_strout::
;src\print.c:45: __endasm;
	push	ix
	ld	ix,#4
	add	ix,sp
	ld	e,(ix)
	ld	d,1(ix)
	ld	c,#9
	call	#5
	pop	ix
	ret
;src\print.c:46: }
;src\print.c:48: void initExtAnsi()
;	---------------------------------
; Function initExtAnsi
; ---------------------------------
_initExtAnsi::
;src\print.c:50: AsmCall(0xb000, &prtregs, REGS_NONE, REGS_NONE);
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	ld	hl, #_prtregs
	push	hl
	ld	hl, #0xb000
	push	hl
	call	_AsmCall
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;src\print.c:51: }
	ret
;src\print.c:53: void endExtAnsi()
;	---------------------------------
; Function endExtAnsi
; ---------------------------------
_endExtAnsi::
;src\print.c:55: AsmCall(0xb003, &prtregs, REGS_NONE, REGS_NONE);
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	ld	hl, #_prtregs
	push	hl
	ld	hl, #0xb003
	push	hl
	call	_AsmCall
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;src\print.c:56: }
	ret
;src\print.c:58: void printExtAnsi(unsigned char * ucString) __naked
;	---------------------------------
; Function printExtAnsi
; ---------------------------------
_printExtAnsi::
;src\print.c:69: __endasm;
	push	ix
	ld	ix,#4
	add	ix,sp
	ld	l,(ix)
	ld	h,1(ix)
	call	0xb009
	pop	ix
	ret
;src\print.c:70: }
;src\print.c:72: void printCharExtAnsi(unsigned char ucChar) __naked
;	---------------------------------
; Function printCharExtAnsi
; ---------------------------------
_printCharExtAnsi::
;src\print.c:81: __endasm;
	ld	hl, #2
	add	hl, sp
	ld	a, (hl)
	call	0xb006
	ret
;src\print.c:82: }
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
