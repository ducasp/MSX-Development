#include "../../fusion-c/header/asm.h"
#include "print.h"

Z80_registers prtregs; //auxiliary structure for asm function calling

unsigned char usingAnsiDrv;

void initPrint()
{
    usingAnsiDrv = 0;
}

// This print function has been copied from HGET / Konamiman
// Using it as fusion-c Print uses bios calls, and do not work with PUT9000
// That hooks the dos call.
void print(char* s) __naked
{
    if (usingAnsiDrv)
    {
        printExtAnsi(s);
    }
    __asm
    push    ix
    ld     ix,#4
    add ix,sp
    ld  l,(ix)
    ld  h,1(ix)
loop:
    ld  a,(hl)
    or  a
    jr  z,end
    ld  e,a
    ld  c,#2
    push    hl
    call    #5
    pop hl
    inc hl
    jr  loop
end:
    pop ix
    ret
    __endasm;
}

void print_strout(char* s) __naked
{
    __asm
    push    ix
    ld     ix,#4
    add ix,sp
    ld  e,(ix)
    ld  d,1(ix)
    ld  c,#9
    call    #5
    pop ix
    ret
    __endasm;
}

void initExtAnsi(unsigned int uiCallBackFunction)
{
    usingAnsiDrv = 1;
    AsmCall(0xb000, &prtregs, REGS_NONE, REGS_NONE);
    prtregs.UWords.HL = uiCallBackFunction;
    AsmCall(0xb00f, &prtregs, REGS_MAIN, REGS_NONE);
}

void endExtAnsi()
{
    usingAnsiDrv = 0;
    AsmCall(0xb003, &prtregs, REGS_NONE, REGS_NONE);
}

void printExtAnsi(unsigned char * ucString) __naked
{
    __asm
    push    ix
    ld     ix,#4
    add ix,sp
    ld  l,(ix)
    ld  h,1(ix)
    call 0xb009
    pop ix
    ret
    __endasm;
}

void printCharExtAnsi(unsigned char ucChar) __naked
{
    __asm
    ld		hl, #2
	add		hl, sp

	ld		a, (hl)
    call    0xb006
    ret
    __endasm;
}

void printGetCursorInfo(unsigned char * ucRow, unsigned char * ucColumn) __naked
{
    __asm
    push ix
	ld ix,#0
	add ix,sp
	ld c,4(ix)
	ld b,5(ix)
	ld e,6(ix)
	ld d,7(ix)
	pop ix
	push bc
	push de
    call    0xb00c
    pop de
    pop bc
    ld      a,l
    ld      (de),a
    ld      a,h
    ld      (bc),a
    ret
    __endasm;
}
