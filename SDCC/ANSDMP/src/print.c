#include "../../fusion-c/header/asm.h"

Z80_registers prtregs; //auxiliary structure for asm function calling

// This print function has been copied from HGET / Konamiman
// Using it as fusion-c Print uses bios calls, and do not work with PUT9000
// That hooks the dos call.
void print(char* s) __naked
{
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

void initExtAnsi()
{
    AsmCall(0xb000, &prtregs, REGS_NONE, REGS_NONE);
}

void endExtAnsi()
{
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
