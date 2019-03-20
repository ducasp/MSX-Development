/*
--
-- telnetsm.c
--   Simple TELNET client using the WiFi module of your MSX-SM.
--   Revision 0.70
--
-- Requires SDCC and Fusion-C library and WiFiMSXSM to compile
-- Copyright (c) 2019 Oduvaldo Pavan Junior ( ducasp@ gmail.com )
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fusion-c/header/msx_fusion.h"
#include "fusion-c/header/io.h"
#include "fusion-c/header/asm.h"
#include "WiFiMSXSM.h"

//Defines for TELNET negotiations
//Telnet Protocol Definitions
#define DO 0xfd
#define WONT 0xfc
#define WILL 0xfb
#define DONT 0xfe
#define IAC 0xff
#define SB 0xfa
#define SE 0xf0
#define IS 0
#define SEND 1
//Telnet Commands
#define CMD_ECHO 1
#define CMD_SUPPRESS_GO_AHEAD 3
#define CMD_TTYPE 24
#define CMD_WINDOW_SIZE 31
#define CMD_TERMINAL_SPEED 32
#define CMD_REMOTE_FLOW_CONTROL 33
#define CMD_LINE_MODE 34
#define CMD_ENV_VARIABLES 36
#define CMD_ENCRYPTION 38

//Defines for X and YMODEM
#define SOH 0x01
#define STX 0x02
#define EOT 0x04
#define ACK 0x06
#define NAK 0x15
#define ETB 0x17
#define CAN 0x18

//Our big internal FIFOCMD as writing to screen is slower than receiving data
#define BUFFER_SIZE 24576
unsigned char rxbuffer[BUFFER_SIZE];
unsigned int Top = 0;
unsigned int Bottom = 0;
unsigned char Full = 0;

//Instructions
const char strUsage[] = "Usage: telnetsm <server:port> [/sSPEED] [/r]\n\n<server:port>: 192.168.0.1:23 or bbs.hispamsx.org:23\n\n/s0 - 115200, /s1 - 57600, /s2 - 38400 /s3 - 31250 /s4 - 19200\n    /s5 - 9600 /s6 - 4800 /s7 - 2400\n\n/r: Force reconnection/choosing AP\n";

//Our Flags
unsigned char Echo = 1; //Echo On?
unsigned char Ansi = 0; //Detected J-ANSI?
unsigned char SentWill; //Sent what information we are willing for negotiation?
unsigned char CmdInProgress = 0; //Is there a TELNET command in progress?
unsigned char EscInProgress = 0; //Is there an ESC command in progress?
unsigned char SubOptionInProgress = 0; // Is there a TELNET command sub option in progress?
unsigned char speed, reconnect;

//For data receive parsing
unsigned char escdata[25];
unsigned char rcvdata[1600];
unsigned int rcvdataSize = 0;
unsigned int rcvdataPointer = 0;

//MSX Variables that we will access
__at 0xF3DC unsigned char CursorY;
__at 0xF3DD unsigned char CursorX;
__at 0xFC9E unsigned int TickCount; //JIFFY

//I/O made simple...
__sfr __at 0x07 UartStatus; //reading this is same as IN and writing same as out, without extra instructions
                            //when using Inport and Outport from Fusion-C

//IMPORTANT: You need to check the map compiler generates to make sure this
//address do not overlap functions, variables, etc
//MEMMAN and jANSI require memory information passed to it to be in the
//upper memory segment, so we use this address to interface with it
__at 0xD000 unsigned char MemMamMemory[1024]; //area to hold data sent to jANSI, need to be in the 3rd 16K block

//File transfer RAMDISK stuff
#define NO_RAMDISK 0
#define RAMDISK_CREATED 1
#define RAMDISK_USED 2
int CurrentDrive;
char RamDisk;
char OurRamdisk;

//X and YMODEM Vars
unsigned char filename[20];
//Indicates G-Modem transfer in progress
unsigned char G=0;

// READ BEFORE CHANGING BELOW: it takes half a second to calculate CRC for 1K block
// In half a second, at 31250, about 1500 bytes have been received
// You could distribute the time updating CRC between bytes, but still it takes
// about .5ms to calculate 1 byte, and in that period 75 bytes have entered.
// This is a race we can't win... Probably using highly optimized CRC
// calculation, ASM, and tables, we could get there, but then, our data is being
// transferred in TCP packets, that have already been checked for integrity by
// ESP, so in the end, why bother? Data won't be corrupt.
// So please left this define commented, otherwise, you've been warned and low
// performance is waiting you, or lost packets if using YMODEM-G. I don't think
// it is wort the trouble optimizing CRC as data integrity has already been
// checked
//#define CRC_CHECK


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
void negotiate(unsigned char *buf, int len)
{
    int i;
	unsigned char *Speed;
	unsigned int SpeedSize;
	static unsigned char tmpClientWill[] = { IAC, WILL, CMD_WINDOW_SIZE,\ //we are willing to negotiate Window Size
                                      IAC, WILL, CMD_TTYPE,\ //we are willing to negotiate Terminal Type
                                      IAC, WILL, CMD_TERMINAL_SPEED\ //we are willing to negotiate Terminal Speed
                                      };
    static unsigned char tmpWindowSize[] = {IAC, SB, CMD_WINDOW_SIZE, 0, 80, 0, 24, IAC, SE}; //our terminal is 80x24
    static unsigned char tmpWindowSize1[] = {IAC, SB, CMD_WINDOW_SIZE, 0, 80, 0, 25, IAC, SE}; //our terminal is 80x25
    static unsigned char tmpEchoDont[3] = {IAC, DONT, CMD_ECHO};
    static unsigned char tmpEchoDo[3] = {IAC, DO, CMD_ECHO};
    static unsigned char tmpTTYPE2[] = {IAC, SB, CMD_TTYPE, IS, 'x', 't', 'e', 'r', 'm', '-', '1', '6', 'c', 'o', 'l', 'o', 'r', IAC, SE}; //Terminal xterm-16color
    static unsigned char tmpTTYPE3[] = {IAC, SB, CMD_TTYPE, IS, 'U', 'N', 'K', 'N', 'O', 'W', 'N', IAC, SE}; //Terminal UNKNOWN
    static unsigned char tmpSpeed115[] = {IAC, SB, CMD_TERMINAL_SPEED, IS, '1', '1', '5', '2', '0', '0', ',', '1', '1', '5', '2', '0', '0', IAC,SE}; //terminal speed response
    static unsigned char tmpSpeed57[] = {IAC, SB, CMD_TERMINAL_SPEED, IS, '5', '7', '6', '0', '0', ',', '5', '7', '6', '0', '0', IAC,SE}; //terminal speed response
    static unsigned char tmpSpeed38[] = {IAC, SB, CMD_TERMINAL_SPEED, IS, '3', '8', '4', '0', '0', ',', '3', '8', '4', '0', '0', IAC,SE}; //terminal speed response
    static unsigned char tmpSpeed31[] = {IAC, SB, CMD_TERMINAL_SPEED, IS, '3', '1', '2', '5', '0', ',', '3', '1', '2', '5', '0', IAC,SE}; //terminal speed response
    static unsigned char tmpSpeed19[] = {IAC, SB, CMD_TERMINAL_SPEED, IS, '1', '9', '2', '0', '0', ',', '1', '9', '2', '0', '0', IAC,SE}; //terminal speed response
    static unsigned char tmpSpeed9[] = {IAC, SB, CMD_TERMINAL_SPEED, IS, '9', '6', '0', '0', ',', '9', '6', '0', '0', IAC,SE}; //terminal speed response
    static unsigned char tmpSpeed4[] = {IAC, SB, CMD_TERMINAL_SPEED, IS, '4', '8', '0', '0', ',', '4', '8', '0', '0', IAC,SE}; //terminal speed response
    static unsigned char tmpSpeed2[] = {IAC, SB, CMD_TERMINAL_SPEED, IS, '2', '4', '0', '0', ',', '2', '4', '0', '0', IAC,SE}; //terminal speed response host do not negotiate, our default is to echo data

	if (!SentWill)
    {
        //send WILL of what we are ready to negotiate
        SentWill = 1;
		while(UartTXInprogress());
		TxData (tmpClientWill, sizeof(tmpClientWill));
		// Need to process whatever host asked
    }

    if (buf[1] == DO && buf[2] == CMD_WINDOW_SIZE) { //request of our terminal window size
		while(UartTXInprogress());
        if (Ansi)
            TxData (tmpWindowSize, sizeof(tmpWindowSize1));
        else
            TxData (tmpWindowSize, sizeof(tmpWindowSize));

        return;
    }
	else if (buf[1] == SB && buf[2] == CMD_TTYPE) { //requesting Terminal Type list
		while(UartTXInprogress());
        if (Ansi)
            TxData (tmpTTYPE2, sizeof(tmpTTYPE2));
        else
            TxData (tmpTTYPE3, sizeof(tmpTTYPE3));
        return;
    }
    else if (buf[1] == SB && buf[2] == CMD_TERMINAL_SPEED) { //requesting Terminal Speed
		while(UartTXInprogress());
		switch (speed)
		{
            case 0:
                Speed = tmpSpeed115;
                SpeedSize = sizeof(tmpSpeed115);
            break;
            case 1:
                Speed = tmpSpeed57;
                SpeedSize = sizeof(tmpSpeed57);
            break;
            case 2:
                Speed = tmpSpeed38;
                SpeedSize = sizeof(tmpSpeed38);
            break;
            case 3:
                Speed = tmpSpeed31;
                SpeedSize = sizeof(tmpSpeed31);
            break;
            case 4:
                Speed = tmpSpeed19;
                SpeedSize = sizeof(tmpSpeed19);
            break;
            case 5:
                Speed = tmpSpeed9;
                SpeedSize = sizeof(tmpSpeed9);
            break;
            case 6:
                Speed = tmpSpeed4;
                SpeedSize = sizeof(tmpSpeed4);
            break;
            case 7:
                Speed = tmpSpeed2;
                SpeedSize = sizeof(tmpSpeed2);
            break;
            default:
                Print("Unknown Speed, check code, this shouldn't happen!\n");
                Speed = tmpSpeed31;
                SpeedSize = sizeof(tmpSpeed31);
            break;
		}
        TxData (Speed, SpeedSize);
        return;
    }
	else if (buf[1] == WILL && buf[2] == CMD_ECHO) { //Host is going to echo
		Echo = 0;
		while(UartTXInprogress());
		TxData (tmpEchoDo, 3);
		return;
	}
	else if (buf[1] == WONT && buf[2] == CMD_ECHO) { //Host is not going to echo
		Echo = 1;
		while(UartTXInprogress());
		TxData (tmpEchoDont, 3);
		return;
	}

    for (i = 0; i < len; i++) {
        if (buf[i] == DO)
        {
            if ( (buf[i+1] == CMD_TTYPE) || (buf[i+1] == CMD_TERMINAL_SPEED))
                buf[i] = WILL;
            else
                buf[i] = WONT;
        }
        else if (buf[i] == WILL)
            buf[i] = DO;
    }
	while(UartTXInprogress());
	TxData (buf, len);
}

// Checks Input Data received from command Line and copy to the variables
// It is mandatory to have server:port as first argument
// All other arguments are optional
//
// Reconnect: will force the list of Access Points to be shown allowing to
//            connect to a different AP.
//
// Speed: Choose best communication speed... ESP will handle TCP/IP and hold
//        the buffers/reception of data, but once it sends over serial port
//        it will receive another packet, and if we did not clear FIFO,disaster
//        is bound to happen... The real performance throwing data into a buffer
//        is about 3000 I/O if nothing else (disk, keyboard, screen, etc) is
//        done... Going over 30Kbps (3KB/s) is not needed at this point and level
//        of performance of this program (perhaps optimizing in ASM or better
//        logic in C could squeeze more performance)
//
//
unsigned int IsValidInput (char**argv, int argc, unsigned char *Server, unsigned char *Port, unsigned char *Reconnect, unsigned char *Speed)
{
	unsigned int ret = 0;
	unsigned char * myseek = NULL;
	unsigned char * Input = (unsigned char*)argv[0];
	int param;

	if (argc)
	{
		//First the server:port
		myseek = strstr(Input,":");
		if ((myseek) && ((myseek - Input)<128))
		{
			myseek[0] = 0;
			strcpy (Server, Input);
			++myseek;
			if(strlen(myseek)<6)
			{
				strcpy (Port, myseek);
				ret = 1;
			}
		}

		//If server:port looks ok, let's move through
		if ((ret)&&(argc>1))
		{
			for (param=1; param<argc; param++)
			{
				//Check all other params, them should start with /
				Input = (unsigned char*)argv[param];
				if (Input[0]=='/')
				{
					switch (Input[1])
					{
						//if /r, force wifi connection selection
						case 'r':
						case 'R':
							*Reconnect = 1;
						break;
						//if /s, force usage of a certain UART speed
						case 's':
						case 'S':
							if ( (Input[2]>='0') && (Input[2]<='7') )
								*Speed = Input[2] - '0';
							else
								ret = 0;
						break;

						default:
							ret = 0;
						break;
					}
					if (ret == 0)
						break;
				}
				else
				{
					ret = 0;
					break;
				}
			}
		}
	}

	return ret;
}

// In order to work with big / massive ANSI screens/animations that can
// easily fill the ESP8266 FIFO buffer while we are drawing those, it is best
// that we dump all that into a big buffer to keep FIFO from reaching FULL
// status and start to lose data. Those functions work with that buffer in a
// FIFO like manner as efficient as possible.

// This function will Pop (Size) bytes out of RX Buffer
// If no byte in buffer, return 0 in Size
// Otherwise return how many bytes we got in Size
void BPopBuffer (unsigned char * Data, unsigned int * Size )
{
    unsigned int j;

    for (j = 0; j<*Size; ++j)
    {
        if ((Bottom != Top )||(Full))
        {
            Full = 0;
            Data[j] = rxbuffer[Bottom];
            if (Bottom < BUFFER_SIZE - 1)
                ++Bottom;
            else
                Bottom = 0;
        }
        else
            break;
    }
    *Size = j;
}

// This function will PUSH a byte into RX Buffer
void BPushBuffer (unsigned char myByte)
{
	if (Full == 0)
	{
		rxbuffer[Top] = myByte;
		if (Top < BUFFER_SIZE - 1)
			++Top;
		else
			Top = 0;
		if (Top == Bottom)
			Full = 1;
	}
}

#ifdef CRC_CHECK
//CRC Auxiliary functions for XMODEM and YMODEM
#define CRC_POLY 0x1021

unsigned int crc_update(unsigned int crc_in, int incr)
{
	unsigned int xor = crc_in >> 15;
	unsigned int out = crc_in << 1;

	if (incr)
			out++;

	if (xor)
			out ^= CRC_POLY;

	return out;
}

unsigned int crc16(char *data, unsigned int size)
{
        unsigned int crc, i;

        for (crc = 0; size > 0; size--, data++)
                for (i = 0x80; i; i >>= 1)
                        crc = crc_update(crc, *data & i);

        for (i = 0; i < 16; i++)
                crc = crc_update(crc, 0);

        return crc;
}
#endif

// This already implement retries, so if it fails, consider it done deal
//
// File - Pointer to the open file to write data to, if -1 will just send the control character
// Action - the action before sending packet
//      0 - None
//      C - Start Protocol in CRC mode
//      ACK/NAK - Previous Packet signaling
// PktNumber - The actual packet number
//
// Returns:
//      0 - Failure
//      1 - Packet Received and written
//		255 - YMODEM Started a new file
//		254 - YMODEM no more files
//      Other values - The control character (EOT/ETB/CAN) received
unsigned char XYModemPacketReceive (int *File, unsigned char Action, unsigned char PktNumber, unsigned char isYmodem)
{
	unsigned char ret = 0;
	unsigned char is1K = 0;
#ifdef CRC_CHECK
	unsigned int myCrc=0;
	unsigned int pktCrc=0;
#endif
    unsigned int chrLen = 0;
    unsigned int chrTerm = 0;
	unsigned int TimeOut,Time1;
	unsigned char TimeLeap;
	unsigned char RcvPkt[1036];
	unsigned char Retries;
	unsigned int i;
	unsigned int PktStatus;
	unsigned char CreateFile;
	unsigned char NoFile;
	unsigned char IgnorePkt;
	static long FileSize;
	static long ReceivedSize;

	//This is an escape indicating to just send an Action (i.e.: C, ACK, NAK)
	if (*File == -1)
	{
		ret = TxByte (Action);

		if (ret == RET_WIFI_MSXSM_OK)
			return 1;
		else
			return 0;
	}

	// If sending a start of transmission 3 retries
	if ((Action == 'C')||(Action == 'G'))
		Retries = 3;
	else //otherwise 10
        if(!G)
            Retries = 10;
        else
            Retries = 1; //YMODEM-G - no retries at all, once wrong, cancel

	//flags being cleared
	CreateFile = 0;
	NoFile = 0;
	IgnorePkt = 0;

	//Ok, so let's do the packet game while we can retry
	for (i = 0; i<Retries; i++)
	{
		// Timeout for a packet
		Time1 = TickCount;
		TimeOut = 360 + Time1;
		if (TimeOut<Time1)
			TimeLeap = 1;
		else
			TimeLeap = 0;

		//Start at position 0
		PktStatus = 0;

		//Send the Action (could either be an ACK or NAK or C)
		if (Action)
            ret = TxByte (Action);

		//This is the packet receiving loop, it will exit upon timeout
		//or receiving the packet
		do
		{
			// Is there DATA in the UART FIFO?
			if (UartRXData())
			{
				//Get a byte
				RcvPkt[PktStatus] = GetUARTData();
				if (RcvPkt[PktStatus] == 0xff) //telnet, FF will be doubled
				{
					while(!UartRXData());
					GetUARTData(); //discard the second 0xFF
				}

				//First PKT byte?
				if (PktStatus == 0)
				{
					//indication of Start of 128 bytes pkt?
					if (RcvPkt[PktStatus] == SOH)
					{
						//next byte
						++PktStatus;
						is1K = 0; //not 1K transfer
					}
					//indication of Start of 1024 bytes pkt?
					else if (RcvPkt[PktStatus] == STX)
					{
						//next byte
						++PktStatus;
						is1K = 1; //1K transfer
					}
					//End of Transmission of CANCEL and not in a packet? Return it so the protocol can procces it
					else if ((RcvPkt[PktStatus] == EOT)||(RcvPkt[PktStatus] == ETB)||(RcvPkt[PktStatus] == CAN))
					{
						return RcvPkt[PktStatus];
					}
				}
				else if (PktStatus == 1)
				{
					if (RcvPkt[PktStatus] == PktNumber)
						++PktStatus;
					else //error?
					{
					    //YMODEM
					    //
					    //First response to a C (start CRC session) or G won't be
					    //a data packet, but a packet with number 0 containing
					    //filename and possibly file size...
						if ((isYmodem)&&((Action == 'C')||(Action == 'G'))&&(RcvPkt[PktStatus] == 0))
							//Ok, receiving file name/size as response
							++PktStatus;
						else
						{
						    //Server might not like how long we are taking to reply
						    //with ACK (MSX Disk I/O not really fast) and re-send
						    //packets even before we send ACK/NAK. So, if that happens
						    //we will get the same packet again. In this case we just
						    //need to ignore it.
							//is this a previous packet being retried?
							if (RcvPkt[PktStatus] == PktNumber - 1)
							{
								IgnorePkt = 1;
								++PktStatus;
							}
							else
							{
								ret = TxByte (NAK);
								//set timeout as 1 to indicate error
								TimeOut = 1;
								break;
							}
						}
					}
				}
				else if (PktStatus == 2)
				{
				    //If Ignoring, just go ahead
					if (IgnorePkt)
						++PktStatus;
					else if (RcvPkt[PktStatus] == (0xFF - PktNumber) )
						++PktStatus;
					else //error?
					{
					    //YMODEM
					    //
					    //First response to a C (start CRC session) or G won't be
					    //a data packet, but a packet with number 0 containing
					    //filename and possibly file size... FF is the complement
					    //of 0.
						if ((isYmodem)&&((Action == 'C')||(Action == 'G'))&&(RcvPkt[PktStatus] == 0xFF))
						{
							//Ok, receiving file name/size as response
							++PktStatus;
							CreateFile = 1;
							FileSize = -1; //Unknown at this point
							ReceivedSize = 0;
						}
						else //otherwise it is just wrong
						{
							ret = TxByte (NAK);
							//set timeout as 1 to indicate error
							TimeOut = 1;
							break;
						}
					}
				}
				//YMODEM
                //
                //Data of a (0) packet in response to C is the filename, if no
                //filename, means that there are no more files (YMODEM is a
                //batch operation, allowing multiple files)
				else if ((isYmodem)&&((Action == 'C')||(Action == 'G'))&&(CreateFile)&&(PktStatus == 3))
				{
					//is NULL the filename?
					if (RcvPkt[PktStatus] == 0 )
						NoFile = 1;
					++PktStatus;
				}
				//128 bytes packet ends with two byte CRC as the 132nd and 133rd byte
				//1024 bytes CRC is in 1028th and 1029th bytes
				else if ( ((!is1K)&&(PktStatus == 131)) || ((is1K)&&(PktStatus == 1027)) )
				{
#ifdef CRC_CHECK
					myCrc = ((int)RcvPkt[PktStatus] << 8)&0xff00;
#endif
					++PktStatus;
				}
				else if ( ((!is1K)&&(PktStatus == 132)) || ((is1K)&&(PktStatus == 1028)) )
				{
				    //This is the last byte of the packet
				    PktStatus = 0;
#ifdef CRC_CHECK
					myCrc = myCrc|((int)RcvPkt[PktStatus]&0xff);
					if (is1K)
						pktCrc = crc16(&RcvPkt[3],1024);
					else
						pktCrc = crc16(&RcvPkt[3],128);
#endif

					if (IgnorePkt)
					{
						//Ok, finished the packet we need to ignore
						IgnorePkt = 0; //No longer ignoring anything
						PktStatus = 0; // start from 0
					}
#ifdef CRC_CHECK
					else if ( myCrc != pktCrc )
					{
						printf ("CRC error, expected %x received %x\r\n",myCrc,pktCrc);
						ret = TxByte (NAK);
						Set timeout as 1 to indicate error
						TimeOut = 1;
						break;
					}
#endif
					else
					{
						//Y Modem and received file name block?
						if ((isYmodem)&&((Action == 'C')||(Action == 'G'))&&(CreateFile))
						{
						    //No file received, end of transmission
							if (NoFile)
								return 254;

                            //Let's check for file name
                            //
							for (chrLen=3;chrLen<140;chrLen++)
								if (RcvPkt[chrLen] == 0)
									break;
							++chrLen;

							if ((RcvPkt[chrLen]>='0')&&(RcvPkt[chrLen]<='9'))
								FileSize = atol(&RcvPkt[chrLen]);

							if (FileSize == 0)
                            {
                                printf("Receiving file: %s Unknown size.\r\n",&RcvPkt[3]);
								FileSize = -1;
                            }
                            else
                            {
                                //Some servers do not comply to put a 0 after file size, use space
                                //so just fix it
                                for (chrTerm=chrLen; (RcvPkt[chrTerm]>='0')&&(RcvPkt[chrTerm]<='9'); ++chrTerm);
                                RcvPkt[chrTerm]=0;
                                printf("Receiving file: %s Size: %s\r\n",&RcvPkt[3],&RcvPkt[chrLen]);
                            }
                            strcpy (filename, &RcvPkt[3]);
							*File = Open (&RcvPkt[3],O_CREAT);
							if (*File != -1)
							{
							    //File created, success
								ret = TxByte (ACK);
								return 255;
							}
							else // couldn't create file
							{
							    //Failure creating file, can't move on
								ret = TxByte (NAK);
								//Set timeout as 1 to indicate failure
								TimeOut = 1;
								break;
							}
						}
						//Otherwise it is a regular packet to save to disk
						else if (is1K)
						{
						    // In YModem keep track of file size and received file size
							if (isYmodem)
								ReceivedSize += 1024;
                            //If we've received file size
							if (FileSize>0)
                                //If we've received more than the file size
								if (ReceivedSize>FileSize)
								{
								    //just save up to file size
									Write(*File, &RcvPkt[3],1024 - (ReceivedSize-FileSize));
								}
								else //otherwise save the entire block
									Write(*File, &RcvPkt[3],1024);
							else //XMODEM you just save everything and file could be padded
								Write(*File, &RcvPkt[3],1024);
						}
						else
						{
						    //Same as above, but for 128 bytes blocks
							if (isYmodem)
								ReceivedSize += 128;

							if (FileSize>0)
								if (ReceivedSize>FileSize)
								{
									Write(*File, &RcvPkt[3],128 - (ReceivedSize-FileSize));
								}
								else
									Write(*File, &RcvPkt[3],128);
							else
								Write(*File, &RcvPkt[3],128);
						}
						//Set time out as 0 to indicate success
						TimeOut = 0;
						break;
					}
				}
				else
					++PktStatus;
			}

			if (TimeLeap == 0)
			{
				if (TickCount>TimeOut)
				{
				    //if timed out set 1 to indicate error
					TimeOut = 1;
					break;
				}
			}
			else
			{
				if (TickCount<120)
				{
					TimeLeap = 0;
					if (TickCount>TimeOut)
					{
						TimeOut = 1;
						break;
					}
				}
			}
		}
		while(1);

		if (TimeOut == 0) //Packet received
		{
			ret = 1; //Success
			break;
		}
		else
			ret = 0; //Failure
	}

	return ret;
}

// This function will deal with file reception
void XYModemGet (void)
{
	unsigned char ret;
	int iFile=0;
	int iNoFile=-1;
	unsigned char PktNumber;
	unsigned char key=0;
	unsigned char advance[4] = {'-','\\','|','/'};
	unsigned int FilesRcvd = 0;

	rcvdataSize = 0;
	rcvdataPointer = 0;

	//No RAMDISK, no YMODEM-G
	//Reason: Nextor/DOS2 takes a whole life (6s in my 4GB partition) to
	//calculate free disk size, so the first write to the file and every
	//time disk buffer is flushed, it will take that long period before
	//effectively writing to disk. YMODEM G is a stream protocol that will
	//loose packets in that 6s (or 4, or 3, depend on your partition size).
	if (RamDisk == NO_RAMDISK)
        Print("XMODEM Download type file Name\nYMODEM Download type Y: ");
    else
        Print("XMODEM Download type file Name\nYMODEM Download type Y\nYMODEM-G Download type G: ");
	InputString(filename,sizeof(filename-1));
	Print("\n");

	ClearUartData();

	if ( (RamDisk != NO_RAMDISK) && ((((filename[0]=='g')||(filename[0]=='G'))&&(filename[1]==0))) )
        G=1;
    else
        G=0;
	//Y-Modem?
	if ( (((filename[0]=='y')||(filename[0]=='Y'))&&(filename[1]==0)) || (G) )
	{
        do
        {
            // A key has been hit?
            if (KeyboardHit())
            {
                // Get the key
                key = InputChar ();
                if (key == 0x1b) //esc?
                    break;
            }
            //First let's receive file name, size, etc...
            PktNumber = 1;

            if (G)
                // Request start of YMODEM 1K
                ret = XYModemPacketReceive (&iFile, 'G', PktNumber, 1);
            else
                // Request start of YMODEM 1K
                ret = XYModemPacketReceive (&iFile, 'C', PktNumber, 1);

            //Our nice animation to show we are not stuck
            PrintChar('S');
            if (ret == 255) //Created a file, cool, let's move on
            {
                // A key has been hit?
                if (KeyboardHit())
                {
                    // Get the key
                    key = InputChar ();
                    if (key == 0x1b) //esc?
                    {
                        Close (iFile);
                        break;
                    }
                }
                ++FilesRcvd;
                //Now transfer is like XMODEM for this file
                PktNumber = 1;

                if (G)
                    // Request start of YMODEMG
                    ret = XYModemPacketReceive (&iFile, 'G', PktNumber, 1);
                else
                    // Request start of XMODEM 1K
                    ret = XYModemPacketReceive (&iFile, 'C', PktNumber, 1);

                if (ret)
                {
                    do
                    {
                        // A key has been hit?
                        if (KeyboardHit())
                        {
                            // Get the key
                            key = InputChar ();
                            if (key == 0x1b) //esc?
                            {
                                Close (iFile);
                                break;
                            }
                        }

                        //Our nice animation to show we are not stuck
                        PrintChar(8); //backspace
                        PrintChar(advance[PktNumber%4]); // next char

                        ++PktNumber; //next packet
                        if (G)
                            ret = XYModemPacketReceive (&iFile, 0, PktNumber, 1);
                        else
                            ret = XYModemPacketReceive (&iFile, ACK, PktNumber, 1);
                    }
                    while (ret == 1); //basically, while receive packets with SOH/STX, continue receiving/writing

                    if (ret == 0) //Time Out or other errors
                    {
                        Print ("Error receiving file\n");
                        key == 0x1b; //force send of CAN CAN CAN CAN CAN
                    }
                    else if (ret == CAN) //Host canceled the transfer
                    {
                        //Ok, just ACK it
                        XYModemPacketReceive (&iNoFile, ACK, PktNumber, 1);
                        Print ("Server canceled transfer\n");
                    }
                    else if ((ret == EOT)||(ret == ETB)) //End of Transmission
                    {
                        //Ok, just ACK it
                        XYModemPacketReceive (&iNoFile, ACK, PktNumber, 1);
                        Print ("File Transfer Completed!\n");
                        if (RamDisk == RAMDISK_CREATED)
                            RamDisk = RAMDISK_USED;
                    }
                    else if (key == 0x1b) //esc?
                        break;
                }
                else //error starting CRC section
                {
                    Print("Timeout waiting for file...\n");
                    key == 0x1b; //force send of CAN CAN CAN CAN CAN
                }

                Close (iFile);
            }
            else if (ret == 254) //No file or no more files
            {
                //Ok, just ACK it
                XYModemPacketReceive (&iNoFile, ACK, PktNumber, 1);
                printf ("DONE! Transferred %u files...\r\n",FilesRcvd);
            }
            else
            {
                Print("Unknown error waiting for file...\n");
                key == 0x1b; //force send of CAN CAN CAN CAN CAN
                break;
            }
        }
        while ((key != 0x1b)&&(ret != 254)); //Do this until any process break or no more files
	}
	else //X-Modem
	{
		//in XMODEM filename is up to the user, we've already asked it, so create the file
		iFile = Open (filename,O_CREAT);

		if (iFile != -1)
		{
			PktNumber = 1;
			//Our nice animation to show we are not stuck
			PrintChar('S');
			// Request start of XMODEM 1K
			ret = XYModemPacketReceive (&iFile, 'C', PktNumber, 0);
			if (ret)
			{
				do
				{
				    // A key has been hit?
                    if (KeyboardHit())
                    {
                        // Get the key
                        key = InputChar ();
                        if (key == 0x1b) //esc?
                            break;
                    }
					//Our nice animation to show we are not stuck
					PrintChar(8);
					PrintChar(advance[PktNumber%4]);
					++PktNumber;
					ret = XYModemPacketReceive (&iFile, ACK, PktNumber, 0);
				}
				while (ret == 1); //basically, while receive packets with SOH/STX, continue receiving/writing

				if (ret == 0) //Time Out or other errors
                {
					Print ("Error receiving file\n");
					key == 0x1b; //force send of CAN CAN CAN CAN CAN
                }
				else if (ret == CAN) //Host canceled the transfer
				{
					XYModemPacketReceive (&iNoFile, ACK, PktNumber, 0);
					Print ("Server canceled transfer\n");
				}
				else if ((ret == EOT)||(ret == ETB)) //End of Transmission
				{
					XYModemPacketReceive (&iNoFile, ACK, PktNumber, 0);
					Print ("File Transfer Completed!\n");
					if (RamDisk == RAMDISK_CREATED)
                        RamDisk = RAMDISK_USED;
				}
			}
			else //error starting CRC section
            {
				Print("Timeout waiting for file...\n");
				key == 0x1b; //force send of CAN CAN CAN CAN CAN
            }

			Close (iFile);
		}
		else
        {
			printf ("Error creating file %s ...\r\n",filename);
			key == 0x1b; //force send of CAN CAN CAN CAN CAN
        }
	}

	if (key == 0x1b) //cancelled
    {
        //Ok, just CANcel it
        XYModemPacketReceive (&iNoFile, CAN, 0, 1);
        XYModemPacketReceive (&iNoFile, CAN, 0, 1);
        XYModemPacketReceive (&iNoFile, CAN, 0, 1);
        XYModemPacketReceive (&iNoFile, CAN, 0, 1);
        XYModemPacketReceive (&iNoFile, CAN, 0, 1);
    }
}

// This will handle each byte received to work on TELNET commands and sub options
void WorkOnReceivedData (unsigned char Data)
{
	// Have we flagged that a telnet CMD is being built?
	if (!CmdInProgress)
	{
		if (Data != IAC)
        {
            if ((!EscInProgress)&&(Ansi))
            {
                if (Data == 0x1b)
                {
                    escdata[EscInProgress]=Data;
                    ++EscInProgress;
                }
            }
            else
            {
                if( ((EscInProgress==1)&&(Data=='[')) || ((EscInProgress==2)&&(Data=='6')) || ((EscInProgress==3)&&(Data=='n')) )
                {
                    escdata[EscInProgress]=Data;
                    ++EscInProgress;
                    if(EscInProgress==4)
                    {
                        //return cursor position
                        escdata[0]=0x1b;
                        escdata[1]=0x5b;
                        sprintf(&escdata[2],"%u",CursorY);
                        escdata[strlen(escdata) + 1]=0;
                        escdata[strlen(escdata)]=0x3b;
                        sprintf(&escdata[strlen(escdata)],"%uR",CursorX);
                        TxData (escdata, strlen(escdata));
                        EscInProgress = 0;
                    }
                }
                else
                    EscInProgress = 0;
            }
			BPushBuffer (Data); //Just put in our buffer
        }
		else
		{
			rcvdata[0] = Data;
			CmdInProgress = 1; // flag a command or sub is in progress
#ifdef log_debug
			Print("IAC->");
#endif
		}
	}
	else // a CMD or sub option is in progress
	{
		// Get the byte in the proper position
		rcvdata[CmdInProgress] = Data;

#ifdef log_debug
		printf("{%x}",rcvdata[CmdInProgress]);
#endif
		// Is it the first byte after IAC? If yes and it is #define log_debug again
		if ( (CmdInProgress==1) && (rcvdata[CmdInProgress] == IAC))
		{
			//This is the way to mean receive 0xFF, so put FF in the buffer
			BPushBuffer (0xff);
			CmdInProgress = 0;
		}
		// Is it the first byte after IAC and now indicate a sub option?
		else if ( (CmdInProgress==1) && (rcvdata[CmdInProgress] == SB))
		{
			//ok, it is a sub option, keep going
			SubOptionInProgress = 1;
			++CmdInProgress;
		}
		// If receive IAC processing sub option, it could be the end of sub option
		else if ( (SubOptionInProgress == 1) && (rcvdata[CmdInProgress] == IAC) )//need to wait for IAC /SE
		{
			++SubOptionInProgress;
			++CmdInProgress;
		}
		// Was processing sub option, received IAC, is the next byte SE?
		else if ( (SubOptionInProgress == 2) && (rcvdata[CmdInProgress] == SE) )
		{
			//It is, so our sub option reception is done (ends w/ IAC SE)
			++CmdInProgress;
			SubOptionInProgress = 0;
			CmdInProgress = 0;
#ifdef log_debug
			Print("<-\n");
#endif
			//Negotiate the sub option
			negotiate(rcvdata,CmdInProgress);
		}
		// Was processing sub option, received IAC, but now it is not SE
		else if( (SubOptionInProgress == 2) && (rcvdata[CmdInProgress] != SE) )
			//Keep processing sub option, not the end
			SubOptionInProgress = 1;
		else //ok, nothing special, just data for IAC or SUB
			++CmdInProgress;

		//If not a sub option and is the third byte
		if ((SubOptionInProgress == 0) && (CmdInProgress == 3))
		{
#ifdef log_debug
		    Print("<-\n");
#endif
			//Commands are 3 bytes long, always
			negotiate(rcvdata,3);
			CmdInProgress = 0;
		}
	}
}

// That is where our program goes
int main(char** argv, int argc)
{
	char tx_data = 0; //where our key inputs go
	unsigned char ret; //return of functions
	unsigned char input[48]; //Use to get password of encrypted network
	unsigned int i; //auxiliary
	APList *myList = NULL; //structure to hold the access points listed by the device
	unsigned char server[128]; //will hold the name of the server we will connect
	unsigned char port[6]; //will hold the port that the server accepts connections
	unsigned char crlf[3]="\r\n"; //auxiliary
	unsigned char speedstr[8][8]={"115200","57600","38400","31250","19200","9600","4800","2400"}; //show speed
	unsigned int PrintSize = 20; //control flag of how many characters we can print at a time between receiving data
	//jANSI Stuff
    unsigned int MemMamFH = 0; //Handle of the MemMam function handler to access MemMam not through Expansion BIOS calls
    unsigned int MemMamXTCall = 0; //Handle to access MemMam TSR functions directly, bypassing MemMam
    unsigned int JANSIID = 0; //will hold the handle to access jANSI TSR through MemMam
    Z80_registers regs; //auxiliary structure for asm function calling


	// Reset our RXBuffer pointers
	Top = 0;
	Bottom = 0;
	// TX Buffer full control, if that happens, we will start to
	// lose data.
	Full = 0;
	// Flag that indicates that a SUB OPTION reception is in progress
	SubOptionInProgress = 0;
	// Speed to use to interface with ESP 8266, 31Kbps should be enough
	// so FIFO won't fill up before we can process them
	speed = 3;
	// If ESP indicates it is already connected, usually we do not list
	// available APs to connect. This flag will force showing the AP list
	// even if ESP is already connected.
	reconnect = 0;

	//JANSI TSR will leave the screen in mode 7, so if we are in mode 7
	//it should be loaded and started
	if ( Peek(0xFCAF) == 7 )
    {
		Ansi = 1; //for now, let's say we have ANSI
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
        AsmCall(0xFFCA, &regs, REGS_MAIN, REGS_MAIN);
#ifdef log_debug
        printf ("MemMam function handler at: %x%x\r\n",regs.Bytes.H,regs.Bytes.L);
#endif
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
        strcpy(MemMamMemory,"MST jANSI   "); //jANSI ID
        regs.UWords.HL = (unsigned int)MemMamMemory; //memman XTSRCall
        AsmCall(MemMamFH, &regs, REGS_MAIN, REGS_MAIN);
        if (!regs.Flags.C) //carry clear if success
        {
#ifdef log_debug
            printf ("jANSI TSR ID: %x%x\r\n",regs.Bytes.B,regs.Bytes.C);
#endif
            JANSIID = regs.UWords.BC;
            regs.Bytes.A = 2; //INIDMP
            regs.UWords.IX = JANSIID;
            regs.UWords.HL = 0; //return only after dumping all content
            AsmCall(MemMamXTCall, &regs, REGS_ALL, REGS_MAIN);

            strcpy(MemMamMemory,"\x1b[3.\x1b[31m> MSX-SM ESP8266 WIFI Module TELNET Client v0.70 <\r\n (c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\x1b[0m\r\n");
            regs.Bytes.A = 3; //DMPSTR
            regs.UWords.IX = JANSIID;
            regs.UWords.HL = (unsigned int)MemMamMemory;
            regs.UWords.DE = (unsigned int)strlen (MemMamMemory); //memman XTSRCall
            AsmCall(MemMamXTCall, &regs, REGS_ALL, REGS_MAIN);
        }
        else
        {
            Print("jANSI not found...\n");
            Ansi = 0;
        }

    }
	else
		Ansi = 0;

	//Start clean
	ClearUartData();

	if (!Ansi)
		Print("> MSX-SM ESP8266 WIFI Module TELNET Client v0.70 <\n (c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\n");

	// At least server:port should be received
	if (argc == 0)
	{
		Print(strUsage);
		return 0;
	}

	// Validate command line parameters
    if(!IsValidInput(argv, argc, server, port, &reconnect, &speed))
	{
		// If invalid parameters, just show some instructions
		Print(strUsage);
		return 0;
	}

	printf("Initializing ESP [%s bps] (takes a few seconds)...\r\n",speedstr[speed]);

	// Initialize ESP and set communication speed
	ret = InitializeWiFi(speed);

	if ( ( ret == RET_WIFI_MSXSM_OK ) || ( ret == RET_WIFI_MSXSM_OK_DISCONNECTED ) )
	{
		// If could communicate but disconnected from WiFi
		// Or if asked to reconnect to a different AP
		if ( ( ret == RET_WIFI_MSXSM_OK_DISCONNECTED )|| (reconnect!=0) )
		{
			do
			{
				if ( ret == RET_WIFI_MSXSM_OK_DISCONNECTED )
					Print("> Initialization OK, getting WiFi Access Points available...\n");
				else if ( ret != RET_WIFI_MSXSM_OK )
					printf("> Error %u connecting to AP.\r\n", ret);
				//Up to 10 SSIDs is plenty, we do not have lots of memory, 8 bit constraints
				// (SDCC stack is up to 1K, so if you exceed that in a parameter, it won't be good)
				myList = (APList *)malloc( sizeof (APList) + (9 * sizeof(AP)) );
				if (myList)
				{
					memset (myList,0, ( sizeof (APList) + (9 * sizeof(AP)) ) );
					myList->numOfElements = 10; //indicate how many we are supporting
					ret = GetWiFiAPList (myList);
					if ( ( ret == RET_WIFI_MSXSM_OK ) && (myList->numOfElements) )
					{
						Print("Choose Access Point to connect:\n\n");
						for ( i=0; i< myList->numOfElements; i++)
						{
							printf("%u - %s (",i ,myList->APst[i].APName);
							if (myList->APst[i].isEncrypted)
								Print("PWD)\n");
							else
								Print("OPEN)\n");
						}

						do
						{
							Print("\nWhich one to connect (ESC do not connect, R refresh list)? ");
							while (!(KeyboardHit()));
							tx_data = InputChar ();
							printf("%c\r\n",tx_data);
							if (tx_data == 0x1b || tx_data == 'R' || tx_data == 'r')
								break;

							if (myList->APst[tx_data-'0'].isEncrypted)
							{
								Print("Password? ");
								InputString(input,40);
								Print("\n");
								ret = JoinWiFiAP (&myList->APst[tx_data-'0'], input);
							}
							else
								ret = JoinWiFiAP (&myList->APst[tx_data-'0'], NULL);

						}
						while ( (tx_data<'0') || ( tx_data >= ('0' + myList->numOfElements) ) );
					}
					else
						Print("No AP available or error retrieving list...\n\n");

					free(myList);
				}
			}
			while ( tx_data == 'R' || tx_data == 'r' || ret != RET_WIFI_MSXSM_OK );
			tx_data = 0;
		}
		else
			Print("> Initialization OK!\n");

        //Let's create our RAMDISK
        //MSXDOS2 / NEXTOR take too much time calculating free space
        //on large partitions. This make it impossible to use streaming
        //protocols like YMODEM-G, as the first write takes several seconds
        //and it is a blocking operation. In that time several packets
        //will be lost and the transfer fails
        //
        //Why 2M? Well, this is to run on MSX-SM that has 4MB mapper, so lets
        //put to good use. Perhaps if porting for other MSX/Device you might
        //use less memory/ramdisk

        regs.Bytes.B = 128;//2M ramdisk
        DosCall(0x68, &regs, REGS_MAIN, REGS_MAIN);
        //Should be Ok or already exists
        if ((regs.Bytes.A != 0)&&(regs.Bytes.A != 0xBC))
        {
            printf("Error %x creating RAMDISK, YMODEM(G) not available...\r\n",regs.Bytes.A);
            RamDisk = NO_RAMDISK;
        }
        else
        {
            //If created, it was ours, if already existed, user.
            if (regs.Bytes.A == 0)
                OurRamdisk = 1;
            else
                OurRamdisk = 0;
            RamDisk = RAMDISK_CREATED;
            CurrentDrive = GetDisk();
            SetDisk(7);
        }

		printf ("Connecting to server: %s:%s \r\n", server, port);

		// Open TCP connection to server/port
		ret = OpenSingleConnection (CONNECTION_TYPE_TCP, server, port);

		if ( ret == RET_WIFI_MSXSM_OK)
		{
			Print("Connected!\n");

			SentWill = 0;

			// Ok, we are connected, now we stay looping into this state
			// machine until ESC key is pressed
			do
			{
				// A key has been hit?
				if (KeyboardHit())
				{
					// Get the key
					tx_data = InputChar ();

					if (tx_data == 0x02) //CTRL + B - Start XMODEM download
						XYModemGet();

					//If not enter/CR
					if (tx_data != 13)
					{
						// Make sure UART is not sending a byte
						while(UartTXInprogress());
						// Send the byte
						ret = TxByte (tx_data);
					}
					else // enter/CR
					{
						// Make sure UART is not sending a byte
						while(UartTXInprogress());
						// Send CR and LF as well
						ret = TxData (crlf, 2);
					}

					// If we are echoing our own keys
					if ((Echo)&&(ret == RET_WIFI_MSXSM_OK))
					{
						if (tx_data != 13)
						{
							PrintChar(tx_data);
						}
						else
						{
							printf("\r\n");
						}
					}
				}

				// Is there DATA in the UART FIFO?
				if (UartRXData())
				{
					//Check if FIFO Full occurred
					if (UartStatus&4)
					{
						Print("FIFO Full, possible data loss!\n");
					}

					WorkOnReceivedData(GetUARTData());
				}
				else //good time to print data
                {
                    // Why print only when no data in UART? If receiving consecutive bytes
                    // very fast we shouldn't allow the FIFO to overflow... But, generally,
					// there is a time between characters and we should be good
					// printing once between characters... This just control a trade-off
					// of holding printing for intensive reception (where bytes accumulated
					// in the FIFO)
                    PrintSize = 30;
                    BPopBuffer (MemMamMemory,&PrintSize);
                    //Data to print?
                    if(PrintSize)
                    {
                        MemMamMemory[PrintSize]=0;
                        if (!Ansi)
                            Print(MemMamMemory);
                        else
                        {
                            regs.Bytes.A = 3; //DMPSTR
                            regs.UWords.IX = JANSIID;
                            regs.UWords.HL = (unsigned int)MemMamMemory;
                            regs.UWords.DE = PrintSize; //memman XTSRCall
                            AsmCall(MemMamXTCall, &regs, REGS_ALL, REGS_MAIN);
                        }
                    }
                }
			}
			while (tx_data != 0x1b); //If ESC pressed, exit...

			Print("Closing connection...\n");
			ret = CloseSingleConnection();

			if (ret != RET_WIFI_MSXSM_OK)
				printf ("Error %u closing connection.\r\n", ret);
		}
		else
			printf ("Error %u connecting to server: %s:%s\r\n", ret, server, port);
	}
	else
		Print("> ESP Init error...\n");

    // Created RAM DISK but no files transferred
    if (RamDisk == RAMDISK_CREATED)
    {
        if(OurRamdisk)
        {
            //Let's destroy our RAMDISK as it was not used
            regs.Bytes.B = 0; // destroy
            DosCall(0x68, &regs, REGS_MAIN, REGS_MAIN);
        }
        SetDisk(CurrentDrive);
    }
    else if (RamDisk == RAMDISK_USED)
    {
        Print("Exiting in drive H:, copy the files transferred from RAMDISK to your disk drive,otherwise you will loose files upon reboot or power failure. Then you can destroy the drive/free memory using \"ramdisk 0\"\n");
    }

	return 0;
}
