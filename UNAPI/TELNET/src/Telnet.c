/*
--
-- telnet.c
--   Simple TELNET client using UNAPI for MSX.
--   Revision 0.70
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

#include "Telnet.h"
#include "UnapiHelper.h"
#include "XYMODEM.h"

/*
 *
 * START OF CODE
 *
 */

// This will handle CMD negotiation...
// Basically, the first time host send any command our client will send it
// is willing to send the following information:
// Terminal Type (xterm-16color if jANSI running or UNKNOWN if plain text)
// Window Size (80x25 if jANSI running or 80x24 if plain text
// Terminal Speed (UART Speed).
//
// Upon receiving a DO CMD_WINDOW_SIZE, respond with Window Size.
// Upon receiving TTYPE SUB OPTION request, respond accordingly whether dumb
// or ANSI (xterm-16color).
// Upon receiving TSPEED SUB OPTION request, respond accordingly our current
// UART Speed.
// Upon receiving WILL ECHO, turn off our ECHO (as host will ECHO), otherwise
// if receiving WONT ECHO or no ECHO negotiation, we will ECHO locally.
//
// Treat the DO for TTYPE and TSPEED with an WILL to tell that we are ready
// to send the information when requested.
//
// Any other negotiation requested will be replied as:
// Host asking us if we can DO something are replied as WONT do it
// Host telling that it WILL do something, we tell it to DO it
void negotiate(unsigned char ucConnNumber, unsigned char *ucBuf, int iLen)
{
    int i;

	if (!ucSentWill)
    {
        //send WILL of what we are ready to negotiate
        ucSentWill = 1;
		TxData (ucConnNumber, ucClientWill, sizeof(ucClientWill));
		// Need to process whatever host asked
    }

    if (ucBuf[1] == DO && ucBuf[2] == CMD_WINDOW_SIZE) { //request of our terminal window size
        if (ucAnsi)
            TxData (ucConnNumber, ucWindowSize1, sizeof(ucWindowSize1));
        else
            TxData (ucConnNumber, ucWindowSize, sizeof(ucWindowSize));

        return;
    }
	else if (ucBuf[1] == SB && ucBuf[2] == CMD_TTYPE) { //requesting Terminal Type list
        if (ucAnsi)
            TxData (ucConnNumber, ucTTYPE2, sizeof(ucTTYPE2));
        else
            TxData (ucConnNumber, ucTTYPE3, sizeof(ucTTYPE3));
        return;
    }
    else if (ucBuf[1] == SB && ucBuf[2] == CMD_TERMINAL_SPEED) { //requesting Terminal Speed
        TxData (ucConnNumber, ucSpeed800K, sizeof(ucSpeed800K));
        return;
    }
	else if (ucBuf[1] == WILL && ucBuf[2] == CMD_ECHO) { //Host is going to echo
		ucEcho = 0;
		TxData (ucConnNumber, ucEchoDo, sizeof(ucEchoDo));
		return;
	}
	else if (ucBuf[1] == WONT && ucBuf[2] == CMD_ECHO) { //Host is not going to echo
		ucEcho = 1;
		TxData (ucConnNumber, ucEchoDont, sizeof(ucEchoDont));
		return;
	}

    for (i = 0; i < iLen; i++) {
        if (ucBuf[i] == DO)
        {
            if ( (ucBuf[i+1] == CMD_TTYPE) || (ucBuf[i+1] == CMD_TERMINAL_SPEED))
                ucBuf[i] = WILL;
            else
                ucBuf[i] = WONT;
        }
        else if (ucBuf[i] == WILL)
            ucBuf[i] = DO;
    }
	TxData (ucConnNumber, ucBuf, iLen);
}

// Checks Input Data received from command Line and copy to the variables
// It is mandatory to have server:port as first argument
// All other arguments are optional
//
// SmoothScroll: if using JANSI, will turn on SmoothScroll... It is cool... but it isn't!
//
unsigned int IsValidInput (char**argv, int argc, unsigned char *ucServer, unsigned char *ucPort, unsigned char *ucSmoothScroll)
{
	unsigned int iRet = 0;
	unsigned char * ucMySeek = NULL;
	unsigned char * ucInput = (unsigned char*)argv[0];

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

		if (argc>1)
        {
            ucInput = (unsigned char*)argv[1];
            if ( (ucInput[0]=='s')||(ucInput[0]=='S') )
                *ucSmoothScroll = 1;
        }
	}

	return iRet;
}

void ClearTelnetDoubleFF()
{
    unsigned int uiTmp = 0;

    do
    {
        if (ucMemMamMemory[uiTmp] == IAC)
        {
            if (ucMemMamMemory[uiTmp+1] == IAC)
            {
                if(uiGetSize>(uiTmp+2))
                    memcpy (&ucMemMamMemory[uiTmp+1],&ucMemMamMemory[uiTmp+2],(uiGetSize-uiTmp-2));
                --uiGetSize;
            }
        }
    }
    while ((++uiTmp)<uiGetSize);
}

// This will handle each byte received to work on TELNET commands and sub options
void WorkOnReceivedData (unsigned char ucConnNumber)
{
    unsigned int uiTmp = 0;

    do
    {
        // Have we flagged that a telnet CMD is being built?
        if (!ucCmdInProgress)
        {
            if (ucMemMamMemory[uiTmp] != IAC)
            {
                PrintChar(ucMemMamMemory[uiTmp]);
                if ((!ucEscInProgress)&&(ucAnsi))
                {
                    if (ucMemMamMemory[uiTmp] == 0x1b)
                    {
                        ucEscData[ucEscInProgress]=ucMemMamMemory[uiTmp];
                        ++ucEscInProgress;
                    }
                }
                else
                {
                    if( ((ucEscInProgress==1)&&(ucMemMamMemory[uiTmp]=='[')) || ((ucEscInProgress==2)&&(ucMemMamMemory[uiTmp]=='6')) || ((ucEscInProgress==3)&&(ucMemMamMemory[uiTmp]=='n')) )
                    {
                        ucEscData[ucEscInProgress]=ucMemMamMemory[uiTmp];
                        ++ucEscInProgress;
                        if(ucEscInProgress==4)
                        {
                            //return cursor position
                            ucEscData[0]=0x1b;
                            ucEscData[1]=0x5b;
                            sprintf(&ucEscData[2],"%u",ucCursorY);
                            ucEscData[strlen(ucEscData) + 1]=0;
                            ucEscData[strlen(ucEscData)]=0x3b;
                            sprintf(&ucEscData[strlen(ucEscData)],"%uR",ucCursorX);
                            TxData (ucConnNumber, ucEscData, strlen(ucEscData));
                            ucEscInProgress = 0;
                        }
                    }
                    else
                        ucEscInProgress = 0;
                }
            }
            else
            {
                ucRcvData[0] = ucMemMamMemory[uiTmp];
                ucCmdInProgress = 1; // flag a command or sub is in progress
#ifdef log_debug
                Print("IAC->");
#endif
            }
        }
        else // a CMD or sub option is in progress
        {
            // Get the byte in the proper position
            ucRcvData[ucCmdInProgress] = ucMemMamMemory[uiTmp];

#ifdef log_debug
            printf("{%x}",ucRcvData[ucCmdInProgress]);
#endif
            // Is it the first byte after IAC? If yes and it IAC again
            if ( (ucCmdInProgress==1) && (ucRcvData[ucCmdInProgress] == IAC))
            {
                PrintChar(ucMemMamMemory[uiTmp]); //print FF
                ucCmdInProgress = 0;
            }
            // Is it the first byte after IAC and now indicate a sub option?
            else if ( (ucCmdInProgress==1) && (ucRcvData[ucCmdInProgress] == SB))
            {
                //ok, it is a sub option, keep going
                ucSubOptionInProgress = 1;
                ++ucCmdInProgress;
            }
            // If receive IAC processing sub option, it could be the end of sub option
            else if ( (ucSubOptionInProgress == 1) && (ucRcvData[ucCmdInProgress] == IAC) )//need to wait for IAC /SE
            {
                ++ucSubOptionInProgress;
                ++ucCmdInProgress;
            }
            // Was processing sub option, received IAC, is the next byte SE?
            else if ( (ucSubOptionInProgress == 2) && (ucRcvData[ucCmdInProgress] == SE) )
            {
                //It is, so our sub option reception is done (ends w/ IAC SE)
                ++ucCmdInProgress;
                ucSubOptionInProgress = 0;
                ucCmdInProgress = 0;
#ifdef log_debug
                Print("<-\n");
#endif
                //Negotiate the sub option
                negotiate(ucConnNumber, ucRcvData, ucCmdInProgress);
            }
            // Was processing sub option, received IAC, but now it is not SE
            else if( (ucSubOptionInProgress == 2) && (ucRcvData[ucCmdInProgress] != SE) )
                //Keep processing sub option, not the end
                ucSubOptionInProgress = 1;
            else //ok, nothing special, just data for IAC or SUB
                ++ucCmdInProgress;

            //If not a sub option and is the third byte
            if ((ucSubOptionInProgress == 0) && (ucCmdInProgress == 3))
            {
#ifdef log_debug
                Print("<-\n");
#endif
                //Commands are 3 bytes long, always
                negotiate(ucConnNumber, ucRcvData,3);
                ucCmdInProgress = 0;
            }
        }
    }
    while ((++uiTmp)<uiGetSize);
    uiGetSize = 0;
}

// That is where our program goes
int main(char** argv, int argc)
{
	char ucTxData = 0; //where our key inputs go
	unsigned char ucRet; //return of functions
	unsigned char ucServer[128]; //will hold the name of the server we will connect
	unsigned char ucPort[6]; //will hold the port that the server accepts connections
	//jANSI Stuff
    unsigned int MemMamFH = 0; //Handle of the MemMam function handler to access MemMam not through Expansion BIOS calls
    unsigned int MemMamXTCall = 0; //Handle to access MemMam TSR functions directly, bypassing MemMam
    unsigned int JANSIID = 0; //will hold the handle to access jANSI TSR through MemMam
    unsigned int uiPrintPage;
    unsigned char ucConnNumber;
    unsigned char ucEnterHit = 0;
    unsigned char ucSmoothScroll = 0;
    unsigned char ucAliveConnCount = 0;

    uiGetSize = 0;
	// Flag that indicates that a SUB OPTION reception is in progress
	ucSubOptionInProgress = 0;
	// If server do not negotiate, we will echo
	ucEcho = 1;
	// No CMD received
	ucCmdInProgress = 0;
	// No escape code to handle
	ucEscInProgress = 0;

	// Validate command line parameters
    if(!IsValidInput(argv, argc, ucServer, ucPort, &ucSmoothScroll))
	{
		// If invalid parameters, just show some instructions
		Print(ucSWInfo);
		Print(ucUsage);
		return 0;
	}

    ucAnsi = 0; //for now, let's say we do not have ANSI
#ifdef log_debug
    regs.Bytes.D = 'M'; //memman
    regs.Bytes.E = 50; //memman get info
    regs.Bytes.B = 7; //memman get version info
    //Call Expansion BIOS Call, expansion MemMam
    AsmCall(0xFFCA, &regs, REGS_MAIN, REGS_MAIN);
    printf ("MemMam version: %u.%u\r\n",regs.Bytes.H,regs.Bytes.L);
#endif
    regs.Bytes.D = 'M'; //memman
    regs.Bytes.E = 50; //memman get info
    regs.Bytes.B = 6; //memman function handler
    regs.UWords.HL = 0;
    AsmCall(0xFFCA, &regs, REGS_MAIN, REGS_MAIN);
#ifdef log_debug
    printf ("MemMam function handler at: %x%x\r\n",regs.Bytes.H,regs.Bytes.L);
#endif
    if (regs.UWords.HL)
    {
        MemMamFH = regs.UWords.HL;

        regs.Bytes.D = 'M'; //memman
        regs.Bytes.E = 50; //memman get info
        regs.Bytes.B = 8; //memman XTSRCall
        AsmCall(MemMamFH, &regs, REGS_MAIN, REGS_MAIN);
#ifdef log_debug
        printf ("MemMam XTSRCall at: %x%x\r\n",regs.Bytes.H,regs.Bytes.L);
#endif
        MemMamXTCall = regs.UWords.HL;

        regs.Bytes.D = 'M'; //memman
        regs.Bytes.E = 62; //memman get tsr ID
        strcpy(ucMemMamMemory,"MST jANSI   "); //jANSI ID
        regs.UWords.HL = (unsigned int)ucMemMamMemory; //memman XTSRCall
        AsmCall(MemMamFH, &regs, REGS_MAIN, REGS_MAIN);
        if (!regs.Flags.C) //carry clear if success
        {
            ucAnsi = 1;
    #ifdef log_debug
            printf ("jANSI TSR ID: %x%x\r\n",regs.Bytes.B,regs.Bytes.C);
    #endif
            JANSIID = regs.UWords.BC;
            regs.Bytes.A = 2; //INIDMP
            regs.UWords.IX = JANSIID;
            regs.UWords.HL = 0; //won't return on cls, key hit or each full screen
            AsmCall(MemMamXTCall, &regs, REGS_ALL, REGS_MAIN);

            if (ucSmoothScroll)
                strcpy(ucMemMamMemory,ucSWInfoJANSISS);
            else
                strcpy(ucMemMamMemory,ucSWInfoJANSI);
            regs.Bytes.A = 3; //DMPSTR
            regs.UWords.IX = JANSIID;
            regs.UWords.HL = (unsigned int)ucMemMamMemory;
            regs.UWords.DE = (unsigned int)strlen (ucMemMamMemory); //memman XTSRCall
            AsmCall(MemMamXTCall, &regs, REGS_ALL, REGS_MAIN);
        }
        else
        {
            Print("MEMMAN Installed, but jANSI was not found...\n");
            ucAnsi = 0;
        }
    }

    if (!ucAnsi)
        Print(ucSWInfo);

	// At least server:port should be received
	if (argc == 0)
	{
		Print(ucUsage);
		return 0;
	}

	if (!InitializeTCPIPUnapi())
        return 0;

    printf ("Connecting to server: %s:%s \r\n", ucServer, ucPort);

    // Open TCP connection to server/port
    ucRet = OpenSingleConnection (ucServer, ucPort, &ucConnNumber);

    if ( ucRet == ERR_OK)
    {
        Print("Connected!\n");

        ucSentWill = 0;

        // Ok, we are connected, now we stay looping into this state
        // machine until ESC key is pressed
        do
        {
            ++ucAliveConnCount;
            UnapiBreath();
            // A key has been hit?
            if (KeyboardHit())
            {
                // Get the key
                ucTxData = InputChar ();

                if (ucTxData == 0x02) //CTRL + B - Start file download
                    XYModemGet(ucConnNumber);
#ifdef XYMODEM_UPLOAD_SUPPORT
                else if (ucTxData == 0x13) //CTRL + S - Start file upload
                {
                    if (filename[0]==0)
                        XYModemPrepareSend();
                    else
                        XYModemSend();
                }
#endif
                else
                {
                    //If not enter/CR
                    if (ucTxData != 13)
                        // Send the byte
                        TxByte (ucConnNumber, ucTxData);
                    else // enter/CR
                    {
                        // Send CR and LF as well
                        TxData (ucConnNumber, ucCrLf, sizeof(ucCrLf));
                        ucEnterHit = 1;
                    }

                    // If we are echoing our own keys
                    if (ucEcho)
                    {
                        if (ucTxData != 13)
                        {
                            PrintChar(ucTxData);
                        }
                        else
                        {
                            printf("\r\n");
                        }
                    }
                }
            }

            // Is there DATA?
            uiGetSize = MemMamMemorySize - 1;
            if ((RXData(ucConnNumber, ucMemMamMemory, &uiGetSize))&&(ucEnterHit==0))
                WorkOnReceivedData(ucConnNumber);

            if (ucEnterHit)
            {
                //Data to print?
                if(uiGetSize)
                {
                    ClearTelnetDoubleFF();
                    if (!ucAnsi)
                    {
                        ucMemMamMemory[uiGetSize]=0;
                        Print(ucMemMamMemory);
                    }
                    else
                    {
                        uiPrintPage = 0;
                        do
                        {
                            regs.Bytes.A = 3; //DMPSTR
                            regs.UWords.IX = JANSIID;
                            regs.UWords.HL = (unsigned int)(ucMemMamMemory+uiPrintPage);
                            if (uiGetSize <= 1024)
                                regs.UWords.DE = uiGetSize; //memman XTSRCall
                            else
                                regs.UWords.DE = 1024;
                            uiGetSize -= regs.UWords.DE;
                            uiPrintPage += regs.UWords.DE;
                            AsmCall(MemMamXTCall, &regs, REGS_ALL, REGS_MAIN);
                        }
                        while (uiGetSize);
                    }
                }
            }

            if (!ucAliveConnCount)
            {
                if (!IsConnected (ucConnNumber))
                    break;
            }
        }
        while (ucTxData != 0x1b); //If ESC pressed, exit...

        if (ucTxData == 0x1b)
            Print("Closing connection...\n");
        else
            Print("Connection closed on the other end...\n");
        ucRet = CloseConnection(ucConnNumber);

        if (ucRet != 0)
            printf ("Error %u closing connection.\r\n", ucRet);
    }
    else
        printf ("Error %u connecting to server: %s:%s\r\n", ucRet, ucServer, ucPort);

	return 0;
}
