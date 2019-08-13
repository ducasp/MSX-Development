/*
--
-- telnet.c
--   Simple TELNET client using UNAPI for MSX.
--   Revision 0.90
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
// Upon receiving TSPEED SUB OPTION request, respond accordingly our fake 800000
// Speed.
// Upon receiving WILL ECHO, turn off our ECHO (as host will ECHO), otherwise
// if receiving WONT ECHO or no ECHO negotiation, we will ECHO locally.
// Upon receiving TRANSMIT_BINARY, will just acknowledge if enter was not hit
// as some BBSs send it at start negotiations, but after that, invoke the
// file transfer function automatically (some bbss do that before sending files)
//
// Treat the DO for TTYPE and TSPEED with an WILL to tell that we are ready
// to send the information when requested.
//
// Any other negotiation requested will be replied as:
// Host asking us if we can DO something are replied as WONT do it
// Host telling that it WILL do something, we tell it to DO it
unsigned char negotiate(unsigned char ucConnNumber, unsigned char *ucBuf, int iLen)
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
            TxData (ucConnNumber, ucWindowSize1, sizeof(ucWindowSize1)); //80x25
        else
            if (!ucWidth40)
                TxData (ucConnNumber, ucWindowSize, sizeof(ucWindowSize)); //80x24
            else
                TxData (ucConnNumber, ucWindowSize0, sizeof(ucWindowSize0)); //40x24
        return 1;
    }
	else if (ucBuf[1] == SB && ucBuf[2] == CMD_TTYPE) { //requesting Terminal Type list
        if (ucAnsi)
            TxData (ucConnNumber, ucTTYPE2, sizeof(ucTTYPE2)); //xterm 16 colors
        else
            TxData (ucConnNumber, ucTTYPE3, sizeof(ucTTYPE3)); //dumb/unknown
        return 1;
    }
    else if (ucBuf[1] == SB && ucBuf[2] == CMD_TERMINAL_SPEED) { //requesting Terminal Speed
        TxData (ucConnNumber, ucSpeed800K, sizeof(ucSpeed800K)); //lets say 800Kbps
        return 1;
    }
	else if (ucBuf[1] == WILL && ucBuf[2] == CMD_ECHO) { //Host is going to echo
		ucEcho = 0;
		TxData (ucConnNumber, ucEchoDo, sizeof(ucEchoDo)); //Ok host, you can echo, I'm not going to echo
		return 1;
	}
	else if (ucBuf[1] == WILL && ucBuf[2] == CMD_TRANSMIT_BINARY) { //Host is going to send a file?
		TxData (ucConnNumber, ucBinaryDo, sizeof(ucBinaryDo));
		if ((ucEnterHit)&&(ucAutoDownload))
        {
            //Some BBSs use transmit binary at start of telnet negotiations, thus why not do
            //this before ENTER is HIT (which is Ok, ANSI data is 8 bit)
            //
            //Also some BBBs use it before transmitting any data, which is really not needed
            //it is like a kid asking are we there yet? ... You said once, no need to say
            //every darn time you are sending a screen. This is why there is a command to
            //disable the download detection (which works for Syncrhonet BBSs just fine, and
            //since those are the majority nowadays, why this option default is ON)
            XYModemGet(ucConnNumber, ucStandardDataTransfer);
            return 0;
        }
        else
            return 1;
	}
	else if (ucBuf[1] == WONT && ucBuf[2] == CMD_ECHO) { //Host is not going to echo
		ucEcho = 1;
		TxData (ucConnNumber, ucEchoDont, sizeof(ucEchoDont)); //Ok, don't echo, I'm doing it by myself
		return 1;
	}

	//if we are here, none of the above mentioned cases
    for (i = 0; i < iLen; i++) {
        if (ucBuf[i] == DO)
        {
            //we are willing to negotiate TTYPE and TERMINAL SPEED
            if ( (ucBuf[i+1] == CMD_TTYPE) || (ucBuf[i+1] == CMD_TERMINAL_SPEED))
                ucBuf[i] = WILL;
            else //otherwise, not
                ucBuf[i] = WONT;
        }
        else if (ucBuf[i] == WILL)
            ucBuf[i] = DO;
    }
	TxData (ucConnNumber, ucBuf, iLen);

	return 1;
}

// This function will handle a received buffer from a TELNET connection. If
// there are TELNET commands or sub-commands, it will properly remove and not
// print those, as well try to negotiate it using our negotiate function.
// Also clear double FF's (this is how telnet indicate FF) and replace by a
// single FF.
void ParseTelnetData(unsigned char ucConnNumber)
{
    unsigned int uiTmp = 0;
    unsigned char ucTmp;
    unsigned char ucI;
    unsigned int uiPrintCount=0;
    unsigned int uiPrintIndex=0;

    //While we have data in the buffer
    while (uiTmp<uiGetSize)
    {
        // Have we flagged that a telnet CMD is being built?
        if (!ucCmdInProgress)
        {
            //No command is being built, so is the character IAC?
            if (ucMemMamMemory[uiTmp] == IAC)
            {
                ucRcvData[0] = ucMemMamMemory[uiTmp]; //copy to command buffer
                ucCmdInProgress = 1; // flag a command or sub is in progress
                ++uiTmp;
            }
            else if (ucAnsi) //will reply ESC[6n with current cursor position only if we are working with ANSI
            {
                //Have we flagged an ESC code was in progress?
                if (!ucEscInProgress)
                {
                    //No, so check if current character is ESC
                    if (ucMemMamMemory[uiTmp] == 0x1b)
                    {
                        //It is, copy to ESC cmd buffer
                        ucEscData[ucEscInProgress]=ucMemMamMemory[uiTmp];
                        ++ucEscInProgress; //Esc cmd state
                        ++uiTmp;
                        ++uiPrintCount;
                    }
                    else
                    {
                        //It is not, ok, nothing special, move-on
                        ++uiTmp;
                        ++uiPrintCount;
                    }
                }
                else
                {
                    //Ok, it was in progress, so check if remaining bytes are [, 6 and n
                    if( ((ucEscInProgress==1)&&(ucMemMamMemory[uiTmp]=='[')) || ((ucEscInProgress==2)&&(ucMemMamMemory[uiTmp]=='6')) || ((ucEscInProgress==3)&&(ucMemMamMemory[uiTmp]=='n')) )
                    {
                        //it is, copy to ESC cmd buffer
                        ucEscData[ucEscInProgress]=ucMemMamMemory[uiTmp];
                        ++ucEscInProgress; // update ESC cmd state
                        ++uiTmp;
                        ++uiPrintCount;
                        if(ucEscInProgress==4) // we've reached state 4, which means ESC[6n was received
                        {
                            //First we are going to print through all, excluding this command
                            //otherwise cursor position will not be correct :)
                            myBulkPrint(&ucMemMamMemory[uiPrintIndex],uiPrintCount-4);
                            //now return cursor position
                            ucEscData[0]=0x1b;
                            ucEscData[1]=0x5b;
                            ucI = 2;

                            ucTmp = ucCursorY/10;
                            if(ucTmp)
                                ucEscData[ucI++] = ucTmp+'0';
                            ucTmp = ucCursorY%10;
                            ucEscData[ucI++] = ucTmp+'0';
                            ucEscData[ucI++] = 0x3b;

                            ucTmp = ucCursorX/10;
                            if(ucTmp)
                                ucEscData[ucI++] = ucTmp+'0';
                            ucTmp = ucCursorX%10;
                            ucEscData[ucI++] = ucTmp+'0';
                            ucEscData[ucI++] = 'R';
                            ucEscData[ucI++] = 0;
                            TxData (ucConnNumber, ucEscData, strlen((char*)ucEscData));
                            //Now, command built and replied, no longer in progress
                            ucEscInProgress = 0;
                            uiPrintIndex = uiTmp; //we've printed up to the current position, so new index to start
                            uiPrintCount = 0; //and for now we've 0 bytes to print
                        }
                    }
                    else
                    {
                        //any other escape sequences are not our business
                        ucEscInProgress = 0;
                        ++uiTmp;
                        ++uiPrintCount;
                    }
                }
            }
            else
            {
                //Ansi not supported, keep moving
                ++uiTmp;
                ++uiPrintCount;
            }
        }
        else // a CMD or sub option is in progress
        {
            // Get the byte in the proper position
            ucRcvData[ucCmdInProgress] = ucMemMamMemory[uiTmp];

            // Is it the first byte after IAC? If yes and it is IAC again
            if ( (ucCmdInProgress == 1) && (ucRcvData[ucCmdInProgress] == IAC))
            {
                ++uiPrintCount; //it is going to be printed
                //First we are going to print through all, including previous FF
                myBulkPrint(&ucMemMamMemory[uiPrintIndex],uiPrintCount);
                ++uiTmp; //skip current FF
                uiPrintIndex = uiTmp; //new index as we've printed up to here
                uiPrintCount = 0; //no more data to print for now
                ucCmdInProgress = 0; //CMD finished
            }
			// Is it a two byte command? Just ignore, we do not react to those
            else if ( (ucCmdInProgress == 1) && (
				  (ucRcvData[ucCmdInProgress] == GA) || (ucRcvData[ucCmdInProgress] == EL) || (ucRcvData[ucCmdInProgress] == EC) ||
				  (ucRcvData[ucCmdInProgress] == AYT) || (ucRcvData[ucCmdInProgress] == AO) || (ucRcvData[ucCmdInProgress] == IP) ||
				  (ucRcvData[ucCmdInProgress] == BRK) || (ucRcvData[ucCmdInProgress] == DM) || (ucRcvData[ucCmdInProgress] == NOP)
				 )
			   )
            {
                //First we are going to print through all data
                myBulkPrint(&ucMemMamMemory[uiPrintIndex],uiPrintCount);
                ++uiTmp; //jump the CMD
                uiPrintIndex = uiTmp; //new index
                uiPrintCount = 0; //no more data to print
                ucCmdInProgress = 0; //CMD finished
            }
            // Is it the first byte after IAC and now indicate a sub option?
            else if ( (ucCmdInProgress == 1) && (ucRcvData[ucCmdInProgress] == SB))
            {
                //ok, it is a sub option, keep going
                ucSubOptionInProgress = 1; //suboption state update
                ++ucCmdInProgress; //cmd state update
                ++uiTmp;
            }
            // If receive IAC processing sub option, it could be the end of sub option
            else if ( (ucSubOptionInProgress == 1) && (ucRcvData[ucCmdInProgress] == IAC) )//need to wait for IAC /SE
            {
                ++ucSubOptionInProgress; //suboption state update
                ++ucCmdInProgress; //cmd state update
                ++uiTmp;
            }
            // Was processing sub option, received IAC, is the next byte SE?
            else if ( (ucSubOptionInProgress == 2) && (ucRcvData[ucCmdInProgress] == SE) )
            {
                //First we are going to print through all, excluding the command
                myBulkPrint(&ucMemMamMemory[uiPrintIndex],uiPrintCount);
                ++uiTmp; //skip SE
                uiPrintIndex=uiTmp; //new index
                uiPrintCount = 0; //no more data to print
                ucCmdInProgress = 0; //CMD finished
                ucSubOptionInProgress = 0; //suboption finished
                //Negotiate the sub option
                negotiate(ucConnNumber, ucRcvData, ucCmdInProgress);
            }
            // Was processing sub option, received IAC, but now it is not SE
            else if( (ucSubOptionInProgress == 2) && (ucRcvData[ucCmdInProgress] != SE) )
            {
                //Keep processing sub option, not the end
                ucSubOptionInProgress = 1; //suboption state update
                ++ucCmdInProgress; //cmd state update
                ++uiTmp;
            }
            else //ok, nothing special, just data for IAC or SUB
            {
                ++ucCmdInProgress;
                ++uiTmp;
            }

            //If not a sub option and is the third byte
            if ((ucSubOptionInProgress == 0) && (ucCmdInProgress == 3))
            {
                //First we are going to print through all, excluding the command
                myBulkPrint(&ucMemMamMemory[uiPrintIndex],uiPrintCount);
                uiPrintIndex = uiTmp; //new index
                uiPrintCount = 0; //no more data to print
                ucCmdInProgress = 0; //no cmd in progress
                //Negotiate the sub option
                negotiate(ucConnNumber, ucRcvData, 3);
            }
        }
    }

    //Ok, finished parsing, still data to print?
    if (uiPrintCount)
        myBulkPrint(&ucMemMamMemory[uiPrintIndex],uiPrintCount);
}

// Checks Input Data received from command Line and copy to the variables
// It is mandatory to have server:port as first argument
// All other arguments are optional
//
// SmoothScroll: if using JANSI, will turn on SmoothScroll... It is cool... but it isn't!
//
unsigned int IsValidInput (char**argv, int argc, unsigned char *ucServer, unsigned char *ucPort)
{
	unsigned int iRet = 0;
	unsigned char * ucMySeek = NULL;
	unsigned char * ucInput = (unsigned char*)argv[0];
	unsigned char ucTmp;

	//Defaults
	ucSmoothScroll = 0; //no jANSI Smooth Scroll
    ucCursorOn = 0; //Cursor is off
    ucAutoDownload = 1; //Auto download On
    ucExtAnsi = 0; //try to find jANSI if not found, consider we are not ANSI capable
    ucStandardDataTransfer = 1; //usually standard

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
            for (ucTmp = 1; ucTmp<=argc;ucTmp++)
            {
                ucInput = (unsigned char*)argv[ucTmp];
                if ( (ucInput[0]=='s')||(ucInput[0]=='S') )
                    ucSmoothScroll = 1; //Turn on jANSI smooth scroll if jANSI is used
                else if ( (ucInput[0]=='c')||(ucInput[0]=='C') )
                    ucCursorOn = 1; //turn on cursor during telnet sessions
                else if ( (ucInput[0]=='a')||(ucInput[0]=='A') )
                    ucAutoDownload = 0; //turn off auto download selection pop-up when binary transmission command received
                else if ( (ucInput[0]=='e')||(ucInput[0]=='E') )
                    ucExtAnsi = 1; //leap of faith, do not check jANSI but tell we are 80x25 ANSI capable and it will be handled externally
                else if ( (ucInput[0]=='r')||(ucInput[0]=='R') )
                    ucStandardDataTransfer = 0; //server misbehave and do not double FF on file transfers
            }
        }
	}

	return iRet;
}

// This function will use jANSI DMPSTR to print A LOT FASTER
// or
// If jANSI is not being used directly, just throw data for
// regular print routines
void myBulkPrint(unsigned char *ucData, unsigned int uiSize)
{
    if (uiSize)
    {
        if ((!ucAnsi)||(ucExtAnsi))
        {
            ucData[uiSize]=0;
            Print(ucData);
        }
        else
        {
            regs.Bytes.A = 3; //DMPSTR
            regs.UWords.IX = JANSIID;
            regs.UWords.HL = (unsigned int)(ucData);//+uiPrintPage);
            regs.UWords.DE = uiSize; //memman XTSRCall
            AsmCall(MemMamXTCall, &regs, REGS_ALL, REGS_MAIN);
        }
    }
}

// This routine will detect if MEMMAN is installed
// If it is, then it will check for jANSI
// If jANSI is installed, configure STRDUMP for our needs
// return 1 if MEMMAN and jANSI installed, otherwise 0
unsigned char useJAnsi()
{
    unsigned char ucRet = 0;

    MemMamFH = 0; //Handle of the MemMam function handler to access MemMam not through Expansion BIOS calls
    MemMamXTCall = 0; //Handle to access MemMam TSR functions directly, bypassing MemMam
    JANSIID = 0; //will hold the handle to access jANSI TSR through MemMam

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
            ucRet = 1;
#ifdef log_debug
            printf ("jANSI TSR ID: %x%x\r\n",regs.Bytes.B,regs.Bytes.C);
#endif
            JANSIID = regs.UWords.BC;
            regs.Bytes.A = 2; //INIDMP
            regs.UWords.IX = JANSIID;
            regs.UWords.HL = 0; //won't return on cls, key hit or each full screen
            AsmCall(MemMamXTCall, &regs, REGS_ALL, REGS_MAIN);
        }
        else
        {
            Print("MEMMAN Installed, but jANSI was not found...\n");
            ucRet = 0;
        }
    }

    return ucRet;
}

// That is where our program goes
int main(char** argv, int argc)
{
	char ucTxData = 0; //where our key inputs go
	unsigned char ucRet; //return of functions
	unsigned char ucServer[128]; //will hold the name of the server we will connect
	unsigned char ucPort[6]; //will hold the port that the server accepts connections
    unsigned char ucAliveConnCount = 0; //when this is 0, check if connection is alive
    unsigned char ucConnNumber; //hold the connection number received by UnapiHelper

    //we detect if enter was hit to avoid popping up protocol selection if transmit binary command is received in initial negotiations
    ucEnterHit = 0;
    // no bytes received yet
    uiGetSize = 0;
    // For now, let's say we do not have ANSI
	ucAnsi = 0;

	// Telnet Protocol Flags
    // Flag that indicates that a SUB OPTION reception is in progress
	ucSubOptionInProgress = 0;
	// No CMD received
	ucCmdInProgress = 0;
	// No escape code to handle
	ucEscInProgress = 0;
	// If server do not negotiate, we will echo
	ucEcho = 1;

	// Validate command line parameters
    if(!IsValidInput(argv, argc, ucServer, ucPort))
	{
		// If invalid parameters, just show some instructions
		Print(ucSWInfo);
		Print(ucUsage);
		return 0;
	}

    if (!ucExtAnsi)
        ucAnsi = useJAnsi(); //not using external ANSI handler, so check if jANSI is available
    else
        ucAnsi = 1; //ok, let's tell we are ANSI terminal

    if (!ucAnsi)
    {
        //Ok, no ANSI, do we have 80 columns?
        if (ucLinLen<80)
        {
            //Nope, what type of MSX?
            if(ReadMSXtype()==0) //MSX-1?
            {
                //Ok, it is not 80 columns capable
                //but some have 80 columns cards
                //so if LinLen is >=40, leave at that
                if (ucLinLen<40)
                {
                    Screen(0);
                    Width(40);
                    ucWidth40 = 1;
                }
                else //hopefully it will be 80
                    ucWidth40 = 0;
            }
            else
            {
                //MSX2 or better, just set 80 columns
                Width(80);
                ucWidth40 = 0;
            }
        }
        Print(ucSWInfo);
    }
    else
    {
        if (!ucExtAnsi)
        {
            //jANSI, print string with or without Smooth Scroll command
            if (ucSmoothScroll)
                strcpy(ucMemMamMemory,ucSWInfoJANSISS);
            else
                strcpy(ucMemMamMemory,ucSWInfoJANSI);
        }
        else
            strcpy(ucMemMamMemory,ucSWInfoJANSI);
        myBulkPrint(ucMemMamMemory, strlen(ucMemMamMemory));
    }

    // Cursor on or off?
    if (!ucCursorOn)
        Print(ucCursorOff);

    // Time to check for UNAPI availability
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
            //ok, after 255 loops, we check for connection state, and this is the counter of loops
            ++ucAliveConnCount;
            //UNAPI Breathing just in case adapter need it
            UnapiBreath();

            // A key has been hit?
            if (KeyboardHit())
            {
                // Get the key
                ucTxData = InputChar ();

                if (ucTxData == 0x02) //CTRL + B - Start file download
                    XYModemGet(ucConnNumber, ucStandardDataTransfer);
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
                        // Update flag that enter has been hit
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
            if (RXData(ucConnNumber, ucMemMamMemory, &uiGetSize))
            {
                //Data received?
                if(uiGetSize)
                    //Parse it and do what is needed, including printing it
                    ParseTelnetData(ucConnNumber);
            }

            //Have we done 255 loops?
            if (!ucAliveConnCount)
            {
                //Check if connection still is alive
                if (!IsConnected (ucConnNumber))
                    break;
            }
        }
        while (ucTxData != 5); //If CTRL+E pressed, exit...

        if (ucTxData == 5) //CTRL+E pressed?
            Print("Closing connection...\n"); //Yes, so we are closing
        else
            Print("Connection closed on the other end...\n"); //No, so we will close after the other end closed
        ucRet = CloseConnection(ucConnNumber);

        if (ucRet != 0)
            printf ("Error %u closing connection.\r\n", ucRet);
    }
    else
        printf ("Error %u connecting to server: %s:%s\r\n", ucRet, ucServer, ucPort);

    if (ucAnsi) //make sure cursor is on when we leave
        printf("\x1by5\r\n");

	return 0;
}
