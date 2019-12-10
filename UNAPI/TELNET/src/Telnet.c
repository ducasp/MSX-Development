/*
--
-- telnet.c
--   Simple TELNET client using UNAPI for MSX.
--   Revision 1.21
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
#include "print.h"
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
// file transfer function automatically (some BBSs do that before sending files)
//
// Treat the DO for TTYPE and TSPEED with an WILL to tell that we are ready
// to send the information when requested.
//
// Any other negotiation requested will be replied as:
// Host asking us if we can DO something are replied as WONT do it
// Host telling that it WILL do something, we tell it to DO it
unsigned char negotiate(unsigned char *ucBuf)
{
    if (ucBuf[1] == DO && ucBuf[2] == CMD_WINDOW_SIZE) { //request of our terminal window size
        if (ucAnsi)
            TxUnsafeData (ucConnNumber, ucWindowSize1, sizeof(ucWindowSize1)); //80x25
        else
            if (!ucWidth40)
                TxUnsafeData (ucConnNumber, ucWindowSize, sizeof(ucWindowSize)); //80x24
            else
                TxUnsafeData (ucConnNumber, ucWindowSize0, sizeof(ucWindowSize0)); //40x24
        return 1;
    }
	else if (ucBuf[1] == SB && ucBuf[2] == CMD_TTYPE) { //requesting Terminal Type list
        if (ucAnsi)
            TxUnsafeData (ucConnNumber, ucTTYPE2, sizeof(ucTTYPE2)); //xterm 16 colors
        else
            TxUnsafeData (ucConnNumber, ucTTYPE3, sizeof(ucTTYPE3)); //dumb/unknown
        return 1;
    }
    else if (ucBuf[1] == SB && ucBuf[2] == CMD_TERMINAL_SPEED) { //requesting Terminal Speed
        TxUnsafeData (ucConnNumber, ucSpeed800K, sizeof(ucSpeed800K)); //lets say 800Kbps
        return 1;
    }
	else if (ucBuf[1] == WILL && ucBuf[2] == CMD_ECHO) { //Host is going to echo
		ucEcho = 0;
		TxUnsafeData (ucConnNumber, ucEchoDo, sizeof(ucEchoDo)); //Ok host, you can echo, I'm not going to echo
		return 1;
	}
	else if (ucBuf[1] == WILL && ucBuf[2] == CMD_TRANSMIT_BINARY) { //Host is going to send a file?
		TxUnsafeData (ucConnNumber, ucBinaryDo, sizeof(ucBinaryDo));
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
		TxUnsafeData (ucConnNumber, ucEchoDont, sizeof(ucEchoDont)); //Ok, don't echo, I'm doing it by myself
		return 1;
	}

	//if we are here, none of the above mentioned cases
    if (ucBuf[1] == DO)
    {
        //we are willing to negotiate TTYPE and TERMINAL SPEED
        if ( (ucBuf[2] == CMD_TTYPE) || (ucBuf[2] == CMD_TERMINAL_SPEED))
            ucBuf[1] = WILL;
        else //otherwise, not
            ucBuf[1] = WONT;
    }
    else if (ucBuf[1] == WILL)
        ucBuf[1] = DO;
    else
        return 1;

	TxUnsafeData (ucConnNumber, ucBuf, 3);

	return 1;
}

// This is a callback function
// ANSI-DRV will call this function when ESC[6n is received
// And we will return current cursor position
// This is crucial for quite a few BBSs terminal window size detection routines
// As well Synchronet BBSs that have avatars
void SendCursorPosition(unsigned int uiCursorPosition) __z88dk_fastcall
{
    unsigned char uchPositionResponse[12];
    unsigned char uchRow,uchColumn;

    uchColumn = uiCursorPosition & 0xff;
    uchRow = (uiCursorPosition >> 8) & 0xff;
    //return cursor position
    sprintf(uchPositionResponse,"\x1b[%u;%uR",uchRow,uchColumn);
    TxUnsafeData (ucConnNumber, uchPositionResponse, strlen((char*)uchPositionResponse));
}

// This function will handle a received buffer from a TELNET connection. If
// there are TELNET commands or sub-commands, it will properly remove and not
// print those, as well try to negotiate it using our negotiate function.
// Also clear double FF's (this is how telnet indicate FF) and replace by a
// single FF.
void ParseTelnetData(unsigned char * ucBuffer)
{
    unsigned char * chTmp = ucBuffer;
    unsigned char * chLimit = chTmp + uiGetSize;

    //While we have data in the buffer
    while (chTmp<chLimit)
    {
        switch (ucState)
        {
            case TELNET_IDLE:
                //No command is being built, so is the character IAC?
                if (*chTmp == IAC)
                {
                    ucRcvData[0] = *chTmp; //copy to command buffer
                    ucState = TELNET_CMD_INPROGRESS; // flag a command or sub is in progress
                    ucCmdCounter = 1;
                    ++chTmp;
                    if (!ucSentWill)
                    {
                        //send WILL of what we are ready to negotiate
                        ucSentWill = 1;
                        TxUnsafeData (ucConnNumber, ucClientWill, sizeof(ucClientWill));
                        // Need to process whatever host asked
                    }
                }
                else
                {
                    printChar(*chTmp);
                    ++chTmp;
                }
            break;
            case TELNET_CMD_INPROGRESS:
                // Get the byte in the proper position
                ucRcvData[ucCmdCounter] = *chTmp;
                // Is it the first byte after IAC? If yes and it is IAC again
                if ( (ucCmdCounter == 1) && (*chTmp == IAC))
                {
                    ++chTmp; //skip current FF
                    ucState = TELNET_IDLE; //CMD finished
                    printChar(0xff);
                }
                // Is it a two byte command? Just ignore, we do not react to those
                else if ( (ucCmdCounter == 1) && (
                      (*chTmp == GA) || (*chTmp == EL) || (*chTmp == EC) ||
                      (*chTmp == AYT) || (*chTmp == AO) || (*chTmp == IP) ||
                      (*chTmp == BRK) || (*chTmp == DM) || (*chTmp == NOP)
                     )
                   )
                {
                    ++chTmp; //jump the CMD
                    ucState = TELNET_IDLE; //CMD finished
                }
                // Is it the first byte after IAC and now indicate a sub option?
                else if ( (ucCmdCounter == 1) && (*chTmp == SB))
                {
                    //ok, it is a sub option, keep going
                    ucState = TELNET_SUB_INPROGRESS; //suboption state update
                    ++ucCmdCounter; //cmd size update
                    ++chTmp;
                }
                else //ok, nothing special, just data for IAC or SUB
                {
                    ++ucCmdCounter;
                    ++chTmp;
                    if (ucCmdCounter == 3)
                    {
                        ucState = TELNET_IDLE; //CMD finished
                        //Negotiate the sub option
                        negotiate(ucRcvData);
                    }
                }
            break;
            case TELNET_SUB_INPROGRESS:
                // Get the byte in the proper position
                ucRcvData[ucCmdCounter] = *chTmp;
                // If receive IAC processing sub option, it could be the end of sub option
                if (*chTmp == IAC)//need to wait for IAC /SE
                {
                    ucState = TELNET_SUB_WAITEND;
                    ++ucCmdCounter; //cmd size update
                    ++chTmp;
                }
                else //ok, nothing special, just data for IAC or SUB
                {
                    ++ucCmdCounter;
                    ++chTmp;
                }
            break;
            case TELNET_SUB_WAITEND:
                // Get the byte in the proper position
                ucRcvData[ucCmdCounter] = *chTmp;
                // is the next byte SE?
                if (*chTmp == SE)
                {
                    ++chTmp; //skip SE
                    ucState = TELNET_IDLE; //CMD finished
                    //Negotiate the sub option
                    negotiate(ucRcvData);
                }
                // Was processing sub option, received IAC, but now it is not SE
                else
                {
                    //Keep processing sub option, not the end
                    ucState = TELNET_SUB_WAITEND;
                    ++ucCmdCounter; //cmd state update
                    ++chTmp;
                }
            break;
        }
    }
}

// Checks Input Data received from command Line and copy to the variables
// It is mandatory to have server:port as first argument
// All other arguments are optional
//
unsigned int IsValidInput (char**argv, int argc, unsigned char *ucServer, unsigned char *ucPort)
{
	unsigned int iRet = 0;
	unsigned char * ucMySeek = NULL;
	unsigned char * ucInput = (unsigned char*)argv[0];
	unsigned char ucTmp;

	//Defaults
    ucAutoDownload = 1; //Auto download On
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
                if ( (ucInput[0]=='a')||(ucInput[0]=='A') )
                    ucAutoDownload = 0; //turn off auto download selection pop-up when binary transmission command received
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
	unsigned char ucServer[128]; //will hold the name of the server we will connect
	unsigned char ucPort[6]; //will hold the port that the server accepts connections
    unsigned char ucAliveConnCount = 0; //when this is 0, check if connection is alive
    char chTextLine[128];

    //we detect if enter was hit to avoid popping up protocol selection if transmit binary command is received in initial negotiations
    ucEnterHit = 0;
    // no bytes received yet
    uiGetSize = 0;
    // For now, let's say we do not have ANSI
	ucAnsi = 0;

	// Telnet Protocol Flags
    // Flag that indicates that a SUB OPTION reception is in progress
    ucState = TELNET_IDLE;
	// If server do not negotiate, we will echo
	ucEcho = 1;
    // Initialize our text print engine
	initPrint();

	// Validate command line parameters
    if(!IsValidInput(argv, argc, ucServer, ucPort))
	{
		// If invalid parameters, just show some instructions
		print(ucSWInfo);
		print(ucUsage);
		return 0;
	}

	//What type of MSX?
    if(ReadMSXtype()!=0) //>MSX-1
    {
        ucAnsi = 1; //ok, let's tell we are ANSI terminal
        initAnsi((unsigned int)SendCursorPosition);
    }
    else
    {
        //Ok, no ANSI, do we have 80 columns?
        if (ucLinLen<80)
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
        print(ucSWInfo);
    }

    if (ucAnsi)
        print(ucSWInfoANSI);
    else
        print (ucSWInfoANSI);

    // Time to check for UNAPI availability
	if (!InitializeTCPIPUnapi())
    {
        if (ucAnsi) //loaded ansi-drv.bin?
            endAnsi();
        return 0;
    }

    sprintf (chTextLine,"Connecting to server: %s:%s \r\n", ucServer, ucPort);
    print (chTextLine);

    // Open TCP connection to server/port
    ucRet = OpenSingleConnection (ucServer, ucPort, &ucConnNumber);

    if ( ucRet == ERR_OK)
    {
        //print("Connected!\r\n");

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
                    if (ucTxData == 13) // enter/CR ?
                    {
                        // Send CR and LF as well
                        TxUnsafeData (ucConnNumber, ucCrLf, 2);
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
            }

            // Is there DATA?
            uiGetSize = RcvMemorySize - 1;
            if (RXData(ucConnNumber, ucRcvDataMemory, &uiGetSize))
            {
                //Data received?
                if(uiGetSize)
                    //Parse it and do what is needed, including printing it
                    ParseTelnetData(ucRcvDataMemory);
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

        if (ucAnsi) //loaded ansi-drv.bin?
            endAnsi();

        if (ucTxData == 5) //CTRL+E pressed?
            print("Closing connection...\r\n"); //Yes, so we are closing
        else
            print("Connection closed on the other end...\r\n"); //No, so we will close after the other end closed
        ucRet = CloseConnection(ucConnNumber);

        if (ucRet != 0)
        {
            sprintf (chTextLine,"Error %u closing connection.\r\n", ucRet);
            print (chTextLine);
        }
    }
    else
    {
        if (ucAnsi) //loaded ansi-drv.bin?
            endAnsi();
        sprintf (chTextLine,"Error %u connecting to server: %s:%s\r\n", ucRet, ucServer, ucPort);
        print (chTextLine);
    }

    print(ucCursor_On);

	return 0;
}
