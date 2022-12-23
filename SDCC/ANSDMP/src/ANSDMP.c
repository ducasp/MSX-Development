/*
--
-- ansdmp.c
--   Simple Ansi Dumper using Sonic_Aka_T ANSI libraries for MSX.
--   Revision 0.10
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2019 Oduvaldo Pavan Junior ( ducasp@gmail.com )
-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--    product or activity without specific prior written permission.
-- 4. Source code of derivative works MUST be published to the public.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
*/
#include "ANSDMP.h"
#include "../../fusion-c/header/io.h"
#include "../../fusion-c/header/msx2ansi.h"

/*
 *
 * START OF INTERRUPT HANDLING CODE
 *
 */

unsigned char OldHook[5];
unsigned char MyHook[5];
unsigned char IntFunc[5];
unsigned char TypeOfInt;
__at 0xFD9F unsigned char VdpIntHook[];
__at 0xFD9A unsigned char AllIntHook[];
__at 0xF344 unsigned char RAMAD3;

void InterruptHandlerHelper (void) __naked
{
__asm
    push af
    call _IntFunc
    pop af
    jp _OldHook
__endasm;
}

void InitializeMyInterruptHandler (int myInterruptHandlerFunction, unsigned char isVdpInterrupt)
{
    unsigned char ui;
    MyHook[0]=0xF7; //RST 30 is interslot call both with bios or dos
    MyHook[1]=RAMAD3; //Page 3 generally is not paged out and is the slot of the ram, so this should be good
    MyHook[2]=(unsigned char)((int)InterruptHandlerHelper&0xff);
    MyHook[3]=(unsigned char)(((int)InterruptHandlerHelper>>8)&0xff);
    MyHook[4]=0xC9;
    IntFunc[0]=0xCD; //CALL
    IntFunc[1]=(unsigned char)((int)myInterruptHandlerFunction&0xff);
    IntFunc[2]=(unsigned char)(((int)myInterruptHandlerFunction>>8)&0xff);
    IntFunc[3]=0xC9;
    TypeOfInt = isVdpInterrupt;
    //Interrupts must be disabled so no one messes with what we are doing
    DisableInterrupt();
    if (isVdpInterrupt)
    {
        for(ui=0;ui<5;ui++)
            OldHook[ui]=VdpIntHook[ui];
        for(ui=0;ui<5;ui++)
            VdpIntHook[ui]=MyHook[ui];
    }
    else
    {
        for(ui=0;ui<5;ui++)
            OldHook[ui]=AllIntHook[ui];
        for(ui=0;ui<5;ui++)
            AllIntHook[ui]=MyHook[ui];
    }

    //Re-enable Interrupts
    EnableInterrupt();
}

void EndMyInterruptHandler (void)
{
    unsigned char ui;
    //Interrupts must be disabled so no one messes with what we are doing
    DisableInterrupt();

    if (TypeOfInt)
        for(ui=0;ui<5;ui++)
            VdpIntHook[ui]=OldHook[ui];
    else
        for(ui=0;ui<5;ui++)
            AllIntHook[ui]=OldHook[ui];

    //Re-enable Interrupts
    EnableInterrupt();

}

/*
 *
 * START OF GENERAL CODE
 *
 */

// Checks Input Data received from command Line and copy to the variables
// It is mandatory to have server:port as first argument
// All other arguments are optional
//
unsigned int IsValidInput (char**argv, int argc, unsigned char *ucFile)
{
	unsigned int iRet = 0;
	unsigned char * ucInput = (unsigned char*)argv[0];

	if (argc)
	{
        strcpy (ucFile, ucInput);
        iRet = 1;
	}

	return iRet;
}

unsigned int uiIntCount;

void CountVdpInterrupt()
{
    uiIntCount++;
}

// That is where our program goes
int main(char** argv, int argc)
{
	char ucTxData = 0; //where our key inputs go
	unsigned char ucFile[128]; //will hold the name of the ansi file
	unsigned char fileHandle,error;
	unsigned char ucFirst = 1;
	unsigned int uiPrint;

    // no bytes read yet
    uiGetSize = 0;

	// Validate command line parameters
    if(!IsValidInput(argv, argc, ucFile))
	{
		// If invalid parameters, just show some instructions
		Print(ucSWInfo);
		Print(ucUsage);
		return 0;
	}

	regs.Words.DE = (int)ucFile;
	regs.Bytes.A = 1; //open for read
	DosCall(0x43, &regs, REGS_MAIN, REGS_MAIN);
	error = regs.Bytes.A;
	fileHandle = regs.Bytes.B;

	if (regs.Bytes.A!=0)
	{
        printf ("Failed to open file %s\r\n",ucFile);
        return 0;
	}

    AnsiInit();

    // Ok, we are connected, now we stay looping into this state
    // machine until CTRL+E key is pressed or dump finished
    do
    {
        // Is there DATA?
        uiGetSize = BufferMemorySize;

      	regs.Words.DE = (int)(ucBufferMemorySize); //where to data read
      	regs.UWords.HL = uiGetSize; //get up to...
        regs.Bytes.B = fileHandle; //file handle
        DosCall(0x48, &regs, REGS_MAIN, REGS_MAIN);
        error = regs.Bytes.A;
        if (ucFirst)
        {
                ucFirst = 0;
                uiIntCount = 0;
                InitializeMyInterruptHandler ((int)CountVdpInterrupt,1);
        }


        if (error==0)
        {
            uiGetSize = regs.UWords.HL;

            ucBufferMemorySize[uiGetSize] = 0;
            AnsiPrint(ucBufferMemorySize);
            //uiPrint = 0;
            //while (uiGetSize!=uiPrint){
                //AnsiPutChar(ucBufferMemorySize[uiPrint]);
                //if (ucBufferMemorySize[uiPrint++] == 0x0a)
                    //while (!Inkey());
            //}
        }
        else
            break;

    }
    while (1);
    EndMyInterruptHandler();

    while (!Inkey());

    // Get the key
    //ucTxData = InputChar ();

    AnsiFinish();

    printf("Interrupt counted %u ticks...\r\n",uiIntCount);

	return 0;
}
