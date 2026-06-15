#include "../../fusion-c/header/asm.h"
#include "print.h"
#include "../../fusion-c/header/msx2ansi.h"
#include "../../fusion-c/header/msx_fusion.h"

unsigned char usingAnsiDrv;

void initPrint()
{
    usingAnsiDrv = 0;
}

void StartPrintBuffer()
{
    if (usingAnsiDrv)
        AnsiStartBuffer();
}

void EndPrintBuffer()
{
    if (usingAnsiDrv)
        AnsiEndBuffer();
}

// This print function has been copied from HGET / Konamiman
// Using it as fusion-c Print uses bios calls, and do not work with PUT9000
// That hooks the dos call.
void print(char* s) __z88dk_fastcall
{
    __asm
    ld  a,(#_usingAnsiDrv)
    or  a
    jp  nz,_AnsiPrint;
    push    ix
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
    __endasm;
}

void printChar(char c) __z88dk_fastcall
{
    __asm
    ld  a,(#_usingAnsiDrv)
    or  a
    jp  nz,_AnsiPutChar;
    push    ix
    ld  e,l
    ld  c,#2
    call    #5
    pop ix
    __endasm;
}

void initAnsi(unsigned int uiCallBackFunction)
{
    usingAnsiDrv = 1;
    AnsiInit();
    AnsiCallBack(uiCallBackFunction);
}

void endAnsi()
{
    print("\r\nHit any key to exit...");
    while (Inkey() == 0);
    usingAnsiDrv = 0;
    AnsiFinish();
}

void GetDataFromKeyboard(unsigned char *ucBuffer, unsigned int uiLen, unsigned char ucMask)
{
    unsigned char *ucTmp = ucBuffer;
    unsigned int uiMyLen = 0;
    do
    {
        *ucTmp = Inkey ();
        if (*ucTmp!=0)
        {
            if (*ucTmp == 8)
            {
                if (uiMyLen)
                {
                    print("\x08\x20\x08");
                    --uiMyLen;
                    --ucTmp;
                }
            }
            else
            {
                if ((ucMask) && (*ucTmp!=13))
                    printChar('*');
                else
                    printChar(*ucTmp);
                if (*ucTmp!=13)
                {
                    ++ucTmp;
                    ++uiMyLen;
                }
                else
                {
                    printChar(0x0a);
                    break;
                }
            }
        }
    }
    while (uiMyLen<uiLen-1);
    *ucTmp = 0x00;
}
