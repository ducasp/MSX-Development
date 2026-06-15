/*
--
-- ssh.c
--   Simple SSH PTY client using UNAPI for MSX.
--   Revision 1.00
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2026 Oduvaldo Pavan Junior ( ducasp@gmail.com )
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
#include "ssh.h"
#include "print.h"
#include "UnapiHelper.h"
#include "XYMODEM.h"

/*
 *
 * START OF CODE
 *
 */

// This is a callback function
// MSX2ANSI will call this function when ESC[6n is received
// And we will send the current cursor position over the connection
// This is crucial for quite a few BBSs terminal window size detection routines
// As well Synchronet BBSs that have avatars that will be misplaced without this
void SendCursorPosition(unsigned int uiCursorPosition) __z88dk_fastcall
{
    unsigned char uchPositionResponse[12];
    unsigned char uchRow,uchColumn;

    uchColumn = 80;
    uchRow = 25;
    //return cursor position
    sprintf(uchPositionResponse,"\x1b[%u;%uR",uchRow,uchColumn);
    TxUnsafeData (ucConnNumber, uchPositionResponse, strlen((char*)uchPositionResponse));
}

// Checks Input Data received from command Line and copy to the variables
// It is mandatory to have server as first argument
// All other arguments are optional
unsigned int IsValidInput (char**argv, int argc, unsigned char *ucServer, unsigned char *ucPort, unsigned char *ucAnsiOption, unsigned char *ucMSX1CustomFont, unsigned char *ucAnonymous, unsigned char *ucFilter, unsigned char *ucInteractive, unsigned char *ucPubKeyAuth)
{
	unsigned int iRet = 0;
	unsigned char * ucMySeek = NULL;
	unsigned char * ucInput = (unsigned char*)argv[0];
	unsigned char ucTmp;

	//Defaults
	*ucInteractive = 0;
	*ucPubKeyAuth = 0;
	*ucFilter = 1;
    ucStandardDataTransfer = 1;
    *ucAnonymous = 0;
    *ucAnsiOption = 1; //try to render ANSI if possible
    *ucMSX1CustomFont = 1; //custom CP437 font

	if (argc)
	{
		//First the server:port
		ucMySeek = strstr(ucInput,":");
		if ((ucMySeek) && ((ucMySeek - ucInput)<128))
		{
			ucMySeek[0] = 0;
			strcpy (ucServer, ucInput);
			++ucMySeek;
			if(strlen(ucMySeek)<6)
			{
				strcpy (ucPort, ucMySeek);
				iRet = 1;
			}
		}
		else if((!ucMySeek) && (strlen(ucInput)<128))
		{
            strcpy (ucServer, ucInput);
            strcpy (ucPort, "22");
            iRet = 1;
		}

		if (argc>1)
        {
            for (ucTmp = 1; ucTmp<=argc;ucTmp++)
            {
                ucInput = (unsigned char*)argv[ucTmp];
                if ( (ucInput[0]=='o')||(ucInput[0]=='O') )
                    *ucAnsiOption = 0; //turn off ansi rendering
                else if ( (ucInput[0]=='c')||(ucInput[0]=='C') )
                    *ucMSX1CustomFont = 0; //turn off custom font for MSX1
                else if ( (ucInput[0]=='k')||(ucInput[0]=='K') )
                    *ucInteractive = 1; //try keyboard interactive authentication
                else if ( (ucInput[0]=='a')||(ucInput[0]=='A') )
                    *ucAnonymous = 1; //no password or username
                else if ( (ucInput[0]=='n')||(ucInput[0]=='N') )
                    *ucFilter = 0; //no filtering
                else if ( (ucInput[0]=='p')||(ucInput[0]=='P') )
                    *ucPubKeyAuth = 1; //public key authentication
                else if ( (ucInput[0]=='r')||(ucInput[0]=='R') )
                    ucStandardDataTransfer = 0; //server misbehave and do not double FF on file transfers
            }
        }
	}
	return iRet;
}

// That is where our program goes
int main(char** argv, int argc)
{
	char ucTxData = 0; //where our key inputs go
	unsigned char ucRet; //return of functions
    unsigned char ucCursorSave;
    unsigned char ucFnkBackup[160];
    unsigned char *ucFnkStr = (unsigned char*)0xF87F;
    unsigned char ucF5Exit = 0;
    unsigned char ucUseCrLf = 0;
    unsigned char ucLockF2 = 0;
    unsigned char ucLockF3 = 0;
    unsigned int uiChrDestRamAddr;
    unsigned char ucHostKeyVerification;
    unsigned char *ucRcvDataMemoryTmp, *ucPromptStringTmp;
    unsigned char ucAnonymous,ucInteractive, ucPubKey, ucPrompts, ucEcho, ucPrompts2, ucState, ucInteractiveFail, ucFilter, ucPromptResponseEcho;

    //we detect if enter was hit to avoid popping up protocol selection if transmit binary command is received in initial negotiations
    ucEnterHit = 0;
    //no bytes received yet
    uiGetSize = 0;
    //save cursor status
	ucCursorSave = ucCursorDisplayed;
	ucState = 0;

	// If server do not negotiate, we will not echo
	ucEcho = 0;
    // Initialize our text print engine
	initPrint();

	// Validate command line parameters
    if(!IsValidInput(argv, argc, ucServer, ucPort, &ucAnsi, &ucCP437, &ucAnonymous, &ucFilter, &ucInteractive, &ucPubKey))
	{
		// If invalid parameters, just show some instructions
		print(ucSWInfo);
		print(ucUsage);
		//restore cursor status
        ucCursorDisplayed = ucCursorSave;
		return 0;
	}

	//What type of MSX?
    if(ReadMSXtype()!=0) //>MSX-1
    {
        ucWidth40 = 0;
        // are we going to render ansi?
        if (ucAnsi)
            initAnsi((unsigned int)SendCursorPosition);
        else // if not, let's ensure 80 columns mode
            Width(80);
    }
    else
    {
        ucAnsi = 0;
        //Ok, no ANSI, do we have 80 columns?
        if (ucLinLen<41)
        {
            //Ok, it is not 80 columns capable
            //but some have 80 columns cards
            //so if LinLen is >=40, leave at that
            if (ucLinLen<41)
            {
                Screen(0);
                Width(40);
                ucWidth40 = 1;
            }

            if (ucCP437)
            {
                ucCP437 = 0xff ; //Signal custom font was loaded
                uiChrDestRamAddr = 0x0800; //Address of patterns for screen 0
                CopyRamToVram((void *)ucCP437Font, uiChrDestRamAddr, sizeof(ucCP437Font));
            }
        }
        else
        {
            //hopefully it will be 80
            //won't custom load fonts on a MSX1 saying more than 40 columns
            //have no idea how the 80 columns card fonts are loaded and there are different cards
            //don't think it is feasible to do without cards to test, so, unless someone jump-in to support it, it won't be done
            ucWidth40 = 0;
        }
    }

    if (!ucAnsi)
    {
        print(ucSWInfo);
    }
    else
        print(ucSWInfoANSI);

    // Time to check for SSH availability
	if (!InitializeUNAPIS(&ucInteractive, &ucFilter, &ucHostKeyVerification, &ucPubKey))
    {
        if (ucAnsi) //Using MSX2ANSI?
            endAnsi();
        //restore cursor status
        ucCursorDisplayed = ucCursorSave;
        return 0;
    }

    if (ucAnsi)
    {
        //ANSI 80x25
        SetTermType(1);
        SetTermWindow(25,80);
    }
    else
    {
        //VT-52 and 40 or 80
        SetTermType(0);
        if (ucWidth40)
            SetTermWindow(24,40);
        else
            SetTermWindow(24,80);
    }

    // Backup function keys
    memcpy(ucFnkBackup,ucFnkStr,160);
    // Make sure those won't have any text
    memset(ucFnkStr,'\0',160);

    if (!ucAnonymous)
    {
        if (ucAnsi) //Using MSX2ANSI?
            sprintf(chTextLine,"\x1b[0mWill connect to %s:%s\r\n",ucServer, ucPort);
        else
            sprintf(chTextLine,"Will connect to %s:%s\r\n",ucServer, ucPort);
        print (chTextLine);
        print("Username: ");
        GetDataFromKeyboard(ucUser,128,0);

        if (!ucPubKey && ucInteractive == 0)
        {
            print("Password: ");
            GetDataFromKeyboard(ucPwd,512,1);
            if (ucAnsi)
                print("\x1b[37m");
        }
    }
    else
    {
        if (ucAnsi) //Using MSX2ANSI?
            sprintf(chTextLine,"\x1b[0mWill connect to %s:%s\r\n",ucServer, ucPort);
        else
            sprintf(chTextLine,"Will connect to %s:%s\r\n",ucServer, ucPort);
        print(chTextLine);
    }

    // Open SSH PTY connection to server/port
    ucRet = OpenSingleConnection (ucUser, ucPwd, ucServer, ucPort, &ucConnNumber, ucAnonymous, ucInteractive, ucFilter, ucHostKeyVerification, ucPubKey);
    if (ucRet == ERR_OK && ucInteractive != 0)
    {
        ucInteractiveFail = 0;
        // Ok, need to figure out what server wants
        do
        {
            uiGetSize = RcvMemorySize;
            ucRet = GetChallenge (ucConnNumber, ucRcvDataMemory, &uiGetSize, &ucPrompts, &ucEcho);
            if (ucRet == ERR_OK)
            {
                sprintf(chTextLine,"Interactive login, %d prompt(s) left... Echo: %d\r\n",ucPrompts, ucEcho);
                print(chTextLine);
                ucRcvDataMemoryTmp = ucRcvDataMemory;

                // Title, if any
                if (ucRcvDataMemoryTmp[0]!=0)
                {
                    print (ucRcvDataMemoryTmp);
                    do ++ucRcvDataMemoryTmp; while (ucRcvDataMemoryTmp[0]!=0);
                    print ("\r\n");
                }
                ++ucRcvDataMemoryTmp;

                // Instruction, if any
                if (ucRcvDataMemoryTmp[0]!=0)
                {
                    print (ucRcvDataMemoryTmp);
                    do ++ucRcvDataMemoryTmp; while (ucRcvDataMemoryTmp[0]!=0);
                    print ("\r\n");
                }
                ++ucRcvDataMemoryTmp;
                ucPromptStringTmp = ucPromptString;
                uiGetSize = 0;
                ucPrompts2 = 0;
                while (ucPrompts)
                {
                    switch (ucPrompts2)
                    {
                        case 0:
                            ucPromptResponseEcho = ucEcho & 1 != 0 ? 1:0;
                            break;
                        case 1:
                            ucPromptResponseEcho = ucEcho & 2 != 0 ? 1:0;
                            break;
                        case 2:
                            ucPromptResponseEcho = ucEcho & 4 != 0 ? 1:0;
                            break;
                        case 3:
                            ucPromptResponseEcho = ucEcho & 8 != 0 ? 1:0;
                            break;
                        case 4:
                            ucPromptResponseEcho = ucEcho & 16 != 0 ? 1:0;
                            break;
                        case 5:
                            ucPromptResponseEcho = ucEcho & 32 != 0 ? 1:0;
                            break;
                        case 6:
                            ucPromptResponseEcho = ucEcho & 64 != 0 ? 1:0;
                            break;
                        case 7:
                            ucPromptResponseEcho = ucEcho & 128 != 0 ? 1:0;
                            break;
                        default:
                            ucPromptResponseEcho = 0;
                            break;
                    }
                    // prompt
                    print (ucRcvDataMemoryTmp);
                    do ++ucRcvDataMemoryTmp; while (ucRcvDataMemoryTmp[0]!=0);
                    GetDataFromKeyboard(ucPromptStringTmp,512,ucPromptResponseEcho);
                    print ("\r\n");
                    uiGetSize += strlen (ucPromptStringTmp) + 1;
                    do ++ucPromptStringTmp; while (ucPromptStringTmp[0]!=0);
                    ucPromptStringTmp+=2;
                    ucPromptStringTmp[0] = 0;
                    --ucPrompts;
                    ++ucPrompts2;
                }
                ++uiGetSize;
            }
            else
            {
                ucInteractiveFail = 1;
                break;
            }
            sprintf(chTextLine,"Interactive login, %d prompt(s) answered...\r\n",ucPrompts2);
            print(chTextLine);

            ucRcvDataMemory[0] = ucPrompts2;
            memcpy (&ucRcvDataMemory[1],ucPromptString,uiGetSize);
            ++uiGetSize;
            ucRet = Respond(ucConnNumber,ucRcvDataMemory,uiGetSize);
            if (ucRet != ERR_OK)
                ConnState(ucConnNumber, &ucState);
        }
        while ((ucRet == ERR_OK) && (ucState == 0x05));
        if (ucRet != ERR_OK)
            CloseConnection(ucConnNumber);
    }

    if ( ucRet == ERR_OK)
    {
        // Ok, we are connected, now we stay looping into this state
        // machine until key assigned to exit is pressed
        do
        {
            if ((ucMT6 & 0x21)==1) //F1 and not shift: Start Transfer
                XYModemGet(ucConnNumber, ucStandardDataTransfer); //no need to lock, function will wait for key input

            if ((ucMT6 & 0x41)==1) //F2 and not shift: Change Echo
                ucLockF2 = 1; //key pressed, wait until it is released
            else if ((ucLockF2)&&(ucMT6&0x40)) //key released, let's do it
            {
               ucEcho = !ucEcho;
               ucLockF2 = 0;
            }

            if ((ucMT6 & 0x81)==1) //F3 and not shift: Change Cr / CrLf
                ucLockF3 = 1; //key pressed, wait until it is released
            else if ((ucLockF3)&&(ucMT6&0x80)) //key released, let's do it
            {
                ucUseCrLf = !ucUseCrLf;
                ucLockF3 = 0;
            }

            if ((!(ucMT7 & 0x2))&&((ucMT6&0x1))) //F5 and not shift: Exit
            {
                //no need to lock, exit immediatelly
                ucF5Exit = 1;
                break;
            }

            ucTxData = Inkey ();
            // A key has been hit?
            if (ucTxData)
            {
                if (ucTxData == 13) // enter/CR ?
                {
                    if (ucUseCrLf)
                        // Send CR and LF as well
                        TxUnsafeData (ucConnNumber, ucCrLf, 2);
                    else //just send cr
                        TxByte (ucConnNumber, ucTxData);
                    // Update flag that enter has been hit
                    ucEnterHit = 1;
                }
                else if (ucTxData == 28) // right?
                    TxUnsafeData (ucConnNumber, ucCursor_Forward, 3);
                else if (ucTxData == 29) // left?
                    TxUnsafeData (ucConnNumber, ucCursor_Backward, 3);
                else if (ucTxData == 30) // up?
                    TxUnsafeData (ucConnNumber, ucCursor_Up, 3);
                else if (ucTxData == 31) // down?
                    TxUnsafeData (ucConnNumber, ucCursor_Down, 3);
                else
                    // Send the byte directly
                    TxByte (ucConnNumber, ucTxData);

                // If we are echoing our own keys
                if (ucEcho)
                {
                    if (ucTxData != 13)
                        printChar(ucTxData);
                    else
                        print("\r\n");
                }
            }

            if (IsConnected (ucConnNumber,&uiGetSize))
            {
                if (uiGetSize != 0)
                {
                    // Is there DATA?
                    uiGetSize = RcvMemorySize;
                    if (RXData(ucConnNumber, ucRcvDataMemory, &uiGetSize))
                    {
                        //Data received?
                        if(uiGetSize)
                        {
                            ucRcvDataMemoryTmp = ucRcvDataMemory;
                            //Warn we are going to print a whole buffer
                            StartPrintBuffer();
                            while(uiGetSize)
                            {
                                printChar(*ucRcvDataMemoryTmp);
                                ++ucRcvDataMemoryTmp;
                                --uiGetSize;
                            }
                            //Buffer Processing finished
                            EndPrintBuffer();
                        }
                    }
                }
            }
            else
                break;
        }
        while (1);

        if (ucAnsi) //using msx2ansi?
            endAnsi(); //terminate its screen mode
        else if (ucCP437==0xff) //using custom fonts?
        {
            //re-initialize screen fonts by re-initializing screen mode
            Screen(0);
            Width(40);
        }

        if (ucF5Exit) //F5 pressed?
            print("Closing connection...\r\n"); //Yes, so we are closing
        else
            print("Connection closed on the other end...\r\n"); //No, so we will try to close after the other end closed
        ucRet = CloseConnection(ucConnNumber);

        if (ucRet != 0)
        {
            sprintf (chTextLine,"Error %u closing connection.\r\n", ucRet);
            print (chTextLine);
        }
    }
    else
    {
        if (ucAnsi) //loaded msx2ansi?
            endAnsi();
        sprintf (chTextLine,"Error %u connecting to server: %s:%s\r\n", ucRet, ucServer, ucPort);
        print (chTextLine);
    }

    //restore cursor status
    ucCursorDisplayed = ucCursorSave;
    //restore function keys
    memcpy(ucFnkStr,ucFnkBackup,160);

	return 0;
}
