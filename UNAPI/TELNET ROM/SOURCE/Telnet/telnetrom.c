/*
--
-- telnetrom.c
--   Simple TELNET client using UNAPI for MSX.
--   Revision 1.00
--
-- Copyright (c) 2019 - 2024 Oduvaldo Pavan Junior ( ducasp@gmail.com )
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
-- The ROM version is simplified a lot so it can be run on a cartridge:
--
-- 1. For now, MSX2 or greater only, no MSX1 mode.
-- 2. If using on any cartridge, make sure UNAPI device ROM is in an slot that
--    is initialized first.
-- 3. Very likely you won't be able to use this with UNAPI devices that uses
--    a RAM driver unless you do some vodoo (or I'm dumb and it is possible,
--    who knows? :P), anyway if you need to load a driver in DOS environment
--    you are better off with the DOS version of TELNET
-- 4. Sorry, no file transfers using X or Y modem at this moment
*/
#include "MSX/BIOS/msxbios.h"
#include "targetconfig.h"
#include "applicationsettings.h"
#include "printinterface.h"
#include "inkey.h"
#include "asm.h"
#include "UnapiHelper.h"
#include "msx2ansi.h"
#include "Telnet.h"

unsigned char ucRcvDataMemory[RcvMemorySize];


// This will handle CMD negotiation...
// Basically, the first time host send any command our client will send it
// is willing to send the following information:
// Terminal Type (ANSI if on MSX 2 or better or UNKNOWN if plain text / MSX1)
// Window Size (80x25 if ANSI running or 80x24 / 40x24 if MSX1)
//
// Upon receiving a DO CMD_WINDOW_SIZE, respond with Window Size.
// Upon receiving TTYPE SUB OPTION request, respond accordingly whether dumb
// or ANSI.
//
// Upon receiving WILL ECHO, turn off our ECHO (as host will ECHO), otherwise
// if receiving WONT ECHO or no ECHO negotiation, we will ECHO locally.
// Upon receiving TRANSMIT_BINARY, will just acknowledge if enter was not hit
// as some BBSs send it at start negotiations, but after that, invoke the
// file transfer function automatically (this works only on Synchronet BBSs)
//
// Treat the DO for TTYPE with an WILL to tell that we are ready to send the
// information when requested.
//
// Any other negotiation requested will be replied as:
// Host asking us if we can DO something are replied as WONT do it
// Host telling that it WILL do something, we tell it to DO it
void negotiate(unsigned char* ucBuf)
{
    switch (ucBuf[1])
    {
    case DO:
        switch (ucBuf[2])
        {
        case CMD_WINDOW_SIZE:
            //request of our terminal window size
            TxData(ucConnNumber, ucWindowSize1, sizeof(ucWindowSize1)); //80x25
            break;
            //we are willing to negotiate TTYPE and TERMINAL SPEED
        case CMD_TTYPE:
        case CMD_TRANSMIT_BINARY:
            ucBuf[1] = WILL;
            TxData(ucConnNumber, ucBuf, 3);
            break;
        default:
            ucBuf[1] = WONT;
            TxData(ucConnNumber, ucBuf, 3);
            break;
        }
        break;
    case WILL:
        switch (ucBuf[2])
        {
        case CMD_ECHO:
            //Host is going to echo
            ucEcho = 0;
            ucBuf[1] = DO;
            TxData(ucConnNumber, ucBuf, 3); //Ok host, you can echo, I'm not going to echo
            break;
        case CMD_TRANSMIT_BINARY:
            //Ok, can do it
            ucBuf[1] = DO;
            TxData(ucConnNumber, ucBuf, 3);
            break;
        default:
            ucBuf[1] = DO;
            TxData(ucConnNumber, ucBuf, 3);
            break;
        }
        break;
    case SB:
        if (ucBuf[2] == CMD_TTYPE)
        {
            //requesting Terminal Type list
            TxData(ucConnNumber, ucTTYPE2, sizeof(ucTTYPE2)); //ANSI
        }
        break;
    case WONT:
        if (ucBuf[2] == CMD_ECHO)
            //Host is not going to echo
            ucEcho = 1;
        ucBuf[1] = DONT;
        TxData(ucConnNumber, ucBuf, 3);
        break;
    case DONT:
        ucBuf[1] = WONT;
        TxData(ucConnNumber, ucBuf, 3);
        break;
    }
}

// This function will handle a received buffer from a TELNET connection. If
// there are TELNET commands or sub-commands, it will properly remove and not
// print those, as well try to negotiate it using our negotiate function.
// Also clear double FF's (this is how telnet indicate FF) and replace by a
// single FF.
void ParseTelnetData()
{
    unsigned char* chTmp = ucRcvDataMemory;
    unsigned char* chLimit = chTmp + uiGetSize;
    char chHelpStr[80];

    do
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
            }
            else
            {
                // Do it until IAC or hit the limit
                for (;(chTmp < chLimit) && (*chTmp != IAC);++chTmp)
                    AnsiPutChar(*chTmp);
            }
            break;
        case TELNET_CMD_INPROGRESS:
            // Get the byte in the proper position
            ucRcvData[ucCmdCounter] = *chTmp;
            // Is it the first byte after IAC? If yes and it is IAC again
            if ((ucCmdCounter == 1) && (*chTmp == IAC))
            {
                ++chTmp; //skip current FF
                ucState = TELNET_IDLE; //CMD finished
                AnsiPutChar(0xff);
            }
            // Is it a two byte command? Just ignore, we do not react to those
            else if ((ucCmdCounter == 1) && (*chTmp <= GA) && (*chTmp >= NOP))
            {
                ++chTmp; //jump the CMD
                ucState = TELNET_IDLE; //CMD finished
            }
            // Is it the first byte after IAC and now indicate a sub option?
            else if ((ucCmdCounter == 1) && (*chTmp == SB))
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
    } while (chTmp < chLimit); //While we have data in the buffer
}

// This is a callback function
// MSX2ANSI will call this function when ESC[6n is received
// And we will send the current cursor position over the connection
// This is crucial for quite a few BBSs terminal window size detection routines
// As well Synchronet BBSs that have avatars that will be misplaced without this
void SendCursorPosition(unsigned int uiCursorPosition) __z88dk_fastcall
{
    unsigned char uchPositionResponse[12];
    unsigned char uchRow, uchColumn;

    uchColumn = uiCursorPosition & 0xff;
    uchRow = (uiCursorPosition >> 8) & 0xff;
    //return cursor position
    sprintf(uchPositionResponse, "\x1b[%u;%uR", uchRow, uchColumn);
    TxData(ucConnNumber, uchPositionResponse, strlen((char*)uchPositionResponse));
}

// ----------------------------------------------------------
//	This is the main function for your C MSX APP!
//
//	Your fun starts here!!!
//	Replace the code below with your art.
void main(void) {
    char ucTxData = 0; //where our key inputs go
    unsigned char ucRet; //return of functions
    unsigned char ucServer[128]; //will hold the name of the server we will connect
    unsigned char ucPort[6]; //will hold the port that the server accepts connections
    unsigned char ucAliveConnCount = 0; //when this is 0, check if connection is alive
    char chTextLine[128];
    unsigned char* ucFnkStr = (unsigned char*)0xF87F;
    unsigned char ucF5Exit = 0;
    unsigned char ucUseCrLf = 0;
    unsigned char ucLockF2 = 0;
    unsigned char ucLockF3 = 0;
    unsigned char ucOption = 0;
    unsigned char ucDataPosition = 0;

	if (ucMSXVer > 0)
	{
        strcpy(ucCursor_Up, "\x1b[A");
        strcpy(ucCursor_Down, "\x1b[B");
        strcpy(ucCursor_Forward, "\x1b[C");
        strcpy(ucCursor_Backward, "\x1b[D");
        // Telnet Protocol Flags
        // Flag that indicates that a SUB OPTION reception is in progress
        ucState = TELNET_IDLE;
        //no bytes received yet
        uiGetSize = 0;
        // If server do not negotiate, we will echo
        ucEcho = 1;

        // Make sure those won't have any text
        memset(ucFnkStr, '\0', 160);
        AnsiInit();
        AnsiCallBack((unsigned int)SendCursorPosition);
        if (!InitializeTCPIP())
        {
            AnsiPrint("Failure initializing UNAPI implementation!");
            while (1);
        }

        do
        {
            // Clear keys
            while (Inkey() != 0);

            AnsiPrint(ucSWInfoANSI);  

            AnsiPrint(ucOptionMenu);

            do
            {
                ucOption = Inkey();
            } while (ucOption != '1' && ucOption != '2' && ucOption != '3' && ucOption != '4');

            switch (ucOption)
            {
                case '1':
                    strcpy(ucServer, "bbs.hispamsx.org");
                    strcpy(ucPort, "23");
                    break;
                case '2':
                    strcpy(ucServer, "sotanomsxbbs.org");
                    strcpy(ucPort, "23");
                    break;
                case '3':
                    strcpy(ucServer, "tbrasilis.ddns.net");
                    strcpy(ucPort, "23000");
                    break;
                default:
                    // If here, manual entry
                    AnsiPrint("Server Name or IP address: ");
                    ucDataPosition = 0;
                    do
                    { 
                        ucOption = Inkey();
                        if (ucOption > 31 && ucOption < 127)
                        {
                            AnsiPutChar(ucOption);
                            ucServer[ucDataPosition] = ucOption;
                            ++ucDataPosition;
                            if (ucDataPosition == 127)
                            {
                                ucServer[ucDataPosition] = 0x00;
                                break;
                            }
                        } 
                        else if (ucOption != 0)
                        {
                            switch (ucOption)
                            {
                                case 13:
                                    ucServer[ucDataPosition] = 0x00;
                                    break;
                                case 8:
                                    if (ucDataPosition > 0)
                                    {
                                        --ucDataPosition;
                                        AnsiPrint("\x08 \x08");
                                    }
                                    break;
                            }
                        }
                    } while (ucOption != 13 || ucDataPosition == 0);

                    AnsiPrint("\r\nPort (only numbers, up to 5 digits, default is 23): ");
                    ucDataPosition = 0;
                    do
                    {
                        ucOption = Inkey();
                        if (ucOption > 47 && ucOption < 58)
                        {
                            AnsiPutChar(ucOption);
                            ucPort[ucDataPosition] = ucOption;
                            ++ucDataPosition;
                            if (ucDataPosition == 5)
                            {
                                ucPort[ucDataPosition] = 0x00;
                                break;
                            }
                        }
                        else if (ucOption != 0)
                        {
                            switch (ucOption)
                            {
                            case 13:
                                ucPort[ucDataPosition] = 0x00;
                                break;
                            case 8:
                                if (ucDataPosition > 0)
                                {
                                    --ucDataPosition;
                                    AnsiPrint("\x08 \x08");
                                }
                                break;
                            }
                        }
                    } while (ucOption != 13 || ucDataPosition == 0);
                    AnsiPrint(ucCrLf);
                    break;
            }                    

            // Clear keys
            while (Inkey() != 0);

            sprintf(chTextLine, "Connecting to server: %s:%s \r\n", ucServer, ucPort);
            AnsiPrint(chTextLine);

            // Open TCP connection to server/port
            ucRet = OpenSingleConnection(ucServer, ucPort, &ucConnNumber);

            if (ucRet == ERR_OK)
            {
                // Ok, we are connected, now we stay looping into this state
                // machine until key assigned to exit is pressed
                do
                {
                    //ok, after 255 loops w/o data, we check for connection state, and this is the counter of loops
                    ++ucAliveConnCount;
                    //UNAPI Breathing just in case adapter need it
                    Breath();

                    //if ((ucMT6 & 0x21) == 1) //F1 and not shift: Start Transfer
                    //    XYModemGet(ucConnNumber, ucStandardDataTransfer); //no need to lock, function will wait for key input

                    if ((ucMT6 & 0x41) == 1) //F2 and not shift: Change Echo
                        ucLockF2 = 1; //key pressed, wait until it is released
                    else if ((ucLockF2) && (ucMT6 & 0x40)) //key released, let's do it
                    {
                        ucEcho = !ucEcho;
                        ucLockF2 = 0;
                    }

                    if ((ucMT6 & 0x81) == 1) //F3 and not shift: Change Cr / CrLf
                        ucLockF3 = 1; //key pressed, wait until it is released
                    else if ((ucLockF3) && (ucMT6 & 0x80)) //key released, let's do it
                    {
                        ucUseCrLf = !ucUseCrLf;
                        ucLockF3 = 0;
                    }

                    if ((!(ucMT7 & 0x2)) && ((ucMT6 & 0x1))) //F5 and not shift: Exit
                    {
                        //no need to lock, exit immediatelly
                        ucF5Exit = 1;
                        break;
                    }

                    ucTxData = Inkey();
                    // A key has been hit?
                    if (ucTxData)
                    {
                        if (ucTxData == 13) // enter/CR ?
                        {
                            if (ucUseCrLf)
                                // Send CR and LF as well
                                TxData(ucConnNumber, ucCrLf, 2);
                            else //just send cr
                                TxByte(ucConnNumber, ucTxData);
                        }
                        else if (ucTxData == 28) // right?
                            TxData(ucConnNumber, ucCursor_Forward, 3);
                        else if (ucTxData == 29) // left?
                            TxData(ucConnNumber, ucCursor_Backward, 3);
                        else if (ucTxData == 30) // up?
                            TxData(ucConnNumber, ucCursor_Up, 3);
                        else if (ucTxData == 31) // down?
                            TxData(ucConnNumber, ucCursor_Down, 3);
                        else
                            // Send the byte directly
                            TxByte(ucConnNumber, ucTxData);

                        // If we are echoing our own keys
                        if (ucEcho)
                        {
                            if (ucTxData != 13)
                                AnsiPutChar(ucTxData);
                            else
                                AnsiPrint("\r\n");

                        }
                    }

                    // Is there DATA?
                    uiGetSize = RcvMemorySize;
                    if (RXData(ucConnNumber, ucRcvDataMemory, &uiGetSize, 0))
                    {
                        //Data received?
                        if (uiGetSize)
                        {
                            //Warn we are going to print a whole buffer
                            AnsiStartBuffer();
                            //Parse it and do what is needed, including printing it
                            ParseTelnetData();
                            //Buffer Processing finished
                            AnsiEndBuffer();
                            //zero the connection alive count, no need to check while we are receiving data
                            ucAliveConnCount = 1;
                        }
                    }

                    //Have we done 255 loops w/o receiving data?
                    if (!ucAliveConnCount)
                    {
                        //Check if connection still is alive
                        if (!IsConnected(ucConnNumber))
                            break;
                    }
                } while (1);


                if (ucF5Exit) //F5 pressed?
                    AnsiPrint("Closing connection...\r\n"); //Yes, so we are closing
                else
                    AnsiPrint("Connection closed on the other end...\r\n"); //No, so we will try to close after the other end closed
                ucRet = CloseConnection(ucConnNumber);

                if (ucRet != 0)
                {
                    sprintf(chTextLine, "Error %u closing connection.\r\n", ucRet);
                    AnsiPrint(chTextLine);
                }
            }
            else
            {
                sprintf(chTextLine, "Error %u connecting to server: %s:%s\r\n", ucRet, ucServer, ucPort);
                AnsiPrint(chTextLine);
            }

            AnsiPrint("\r\nPress any key to return to main menu...");
            while (Inkey() == 0);
            AnsiPrint("\x1b[2J");
        }
        while (1);

	}
	else
		print("MSX1 Not supported, need at least a MSX2 or greater, sorry!\0");

	while (1);
}

