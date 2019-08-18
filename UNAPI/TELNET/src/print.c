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
