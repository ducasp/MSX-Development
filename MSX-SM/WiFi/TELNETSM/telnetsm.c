/*
--
-- telnetsm.c
--   Simple TELNET client using the WiFi module of your MSX-SM.
--   Revision 0.20
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
#include "WiFiMSXSM.h"

//Defines for TELNET negotiations
#define DO 0xfd
#define WONT 0xfc
#define WILL 0xfb
#define DONT 0xfe
#define CMD 0xff
#define SB 0xfa
#define SE 0xf0
#define CMD_ECHO 1
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

//Our big internal FIFO as writing to screen is slower than receiving data
#define BUFFER_SIZE 24576
unsigned char rxbuffer[BUFFER_SIZE];
unsigned int Top = 0;
unsigned int Bottom = 0;
unsigned char Full = 0;

//X and YMODEM globals
unsigned char filename[20];

//Instructions
const char strUsage[] = "Usage: telnetsm <server:port> [/sSPEED] [/mMODE] [/r]\n\n<server:port>: 192.168.0.1:23 or bbs.hispamsx.org:23\n\n/s0 - 115200, /s1 - 57600, /s2 - 38400 /s3 - 31250 /s4 - 19200\n    /s5 - 9600 /s6 - 4800 /s7 - 2400\n\n/m0 - Single Connection /m1 - Multiple Connection\n\n/r: Force reconnection/choosing AP\n";

//Our Flags
unsigned char Echo = 1; //Echo On?
unsigned char Ansi = 0; //Detected J-ANSI / Screen 7?
unsigned char SentTTYPE; //Sent Terminal Type for negotiation?
unsigned char CmdInProgress = 0; //Is there a TELNET command in progress?
unsigned char SubOptionInProgress = 0; // Is there a TELNET command sub option in progress?
unsigned char mode = 0; //connection mode, 0 is single, faster... 1 is multiple, well, for the future

//For data receive parsing
unsigned char rcvdata[1600];
unsigned int rcvdataSize = 0;
unsigned int rcvdataPointer = 0;

// This will handle CMD negotiation...
// Basically, the first time host send any command our client will tell
// terminal type and if ANSI is available or not. Also, upon receiving a DO
// CMD_WINDOW_SIZE, tell our Windows is 80x24. Upon receiving TTYPE requests,
// respond accordingly whether dumb or ANSI. On ECHO, will act with ECHO as
// requested by the host. If host do not negotiate, our default is to echo data
//
// Any other negotiation requested will be replied as:
// Host asking us if we can DO something are replied as WONT do it
// Host telling that it WILL do something, we tell it to DO it
void negotiate(unsigned char *buf, int len) {
    int i;
	unsigned char tmp1[10] = {255, 251, 31};
	unsigned char tmp2[10] = {255, 250, 31, 0, 80, 0, 24, 255, 240};
	unsigned char tmpEchoWill[10] = {CMD, WILL, CMD_ECHO};
	unsigned char tmpEchoWont[10] = {CMD, WONT, CMD_ECHO};
	unsigned char tmpEchoDo[10] = {CMD, DO, CMD_ECHO};
	unsigned char tmpTTYPE[10] = {255, 251, 24};
	unsigned char tmpTTYPE2[11] = {255, 250, 24, 0, 65, 78, 83, 73, 255, 240};

	if (Ansi != 0 && SentTTYPE == 0) {   //send WILL TERMINAL TYPE
		SentTTYPE = 1;
		if (mode == 0)
		{
			while(UartTXInprogress());
			TxData (tmpTTYPE, 3);
			TxData (tmpTTYPE2, 10);
		}
		else
		{
			SendData (tmpTTYPE, 3, '0');
			SendData (tmpTTYPE2, 10, '0');
		}
		// Need to process whatever host asked
    }

    if (buf[1] == DO && buf[2] == CMD_WINDOW_SIZE) {
		while(UartTXInprogress());
		if (mode == 0)
		{
			TxData (tmp1, 3);
			TxData (tmp2, 9);
		}
		else
		{
			SendData (tmp1, 3, '0');
			SendData (tmp2, 9, '0');
		}
        return;
    }
	else if (Ansi != 0 && buf[1] == 250 && buf[2] == CMD_TTYPE) {
		while(UartTXInprogress());
		if (mode == 0)
			TxData (tmpTTYPE2, 10);
		else
			SendData (tmpTTYPE2, 10, '0');
        return;
    }
	else if (Ansi != 0 && buf[1] == DO && buf[2] == CMD_TTYPE) {
		while(UartTXInprogress());
		if (mode == 0)
			TxData (tmpTTYPE, 3);
		else
			SendData (tmpTTYPE, 3, '0');
        return;
    }
	else if (buf[1] == DO && buf[2] == CMD_ECHO) {
		Echo = 1;
		while(UartTXInprogress());
		if (mode == 0)
			TxData (tmpEchoWill, 3);
		else
			SendData (tmpEchoWill, 3, '0');
		return;
	}
	else if (buf[1] == WILL && buf[2] == CMD_ECHO) {
		Echo = 0;
		while(UartTXInprogress());
		if (mode == 0)
			TxData (tmpEchoDo, 3);
		else
			SendData (tmpEchoDo, 3, '0');
		return;
	}

    for (i = 0; i < len; i++) {
        if (buf[i] == DO)
            buf[i] = WONT;
        else if (buf[i] == WILL)
            buf[i] = DO;
    }
	while(UartTXInprogress());
	if (mode == 0)
		TxData (buf, len);
	else
		SendData (buf, len, '0');
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
// Mode: This is a work in progress. For a simple TELNET client single mode (0)
//       is the best approach. But, TELNET is the basis for other services like
//       FTP, and those will require multiple connections and the larger latency
//       of this mode is a valid trade-off
//
unsigned int IsValidInput (char**argv, int argc, unsigned char *Server, unsigned char *Port, unsigned char *Reconnect, unsigned char *Speed, unsigned char *Mode)
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
						//if /m, force the communication mode
						case 'm':
						case 'M':
							if ( (Input[2]=='0') || (Input[2]=='1') )
								*Mode = Input[2] - '0';
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

// This function will Print a byte POPed out of RX Buffer
void PPopBuffer (void )
{
	if ((Bottom != Top )||(Full))
	{
		Full = 0;
		PrintChar(rxbuffer[Bottom]);
		if (Bottom < BUFFER_SIZE - 1)
			++Bottom;
		else
			Bottom = 0;
	}
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

//Support for multiple connection mode - File Transfer
unsigned char BufferRXData (void )
{
	//Data in buffer?
	if (rcvdataSize)
		return 1; //we have data
	else
		return UartRXData(); //otherwise just check if UART has data
}

unsigned char GetBufferData (void)
{
	unsigned char ret;

	if (!rcvdataSize)
	{
		//We can clear up to the size of our buffer
		//That is as big as the MSX-SM FIFO
		rcvdataSize = sizeof (rcvdata);
		ret = ReceiveData (rcvdata, &rcvdataSize, '0');
		if ((ret == RET_WIFI_MSXSM_OK) && (rcvdataSize))
		{
			rcvdataPointer = 0;
			rcvdataSize--;
			ret = rcvdata[rcvdataPointer];
			++rcvdataPointer;
		}
		else //simulate fifo false read
		{
		    rcvdataSize = 0;
		    rcvdataPointer = 0;
			printf ("ReceiveData error %u",ret);
			ret = 0xff;
		}
	}
	else
	{
		rcvdataSize--;
		ret = rcvdata[rcvdataPointer];
		++rcvdataPointer;
	}

	return ret;
}

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
	unsigned int myCrc=0;
	unsigned int pktCrc=0;
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
		if (mode == 0)
			ret = TxByte (Action);
		else
			ret = SendData (&Action, 1, '0');

		if (ret == RET_WIFI_MSXSM_OK)
			return 1;
		else
			return 0;
	}

	// If sending a start of transmission 3 retries
	if (Action == 'C')
		Retries = 3;
	else //otherwise 10
		Retries = 10;

	//flags being cleared
	CreateFile = 0;
	NoFile = 0;
	IgnorePkt = 0;

	//Ok, so let's do the packet game while we can retry
	for (i = 0; i<Retries; i++)
	{
		// Timeout for a packet
		Time1 = GetTickCount();
		TimeOut = 360 + Time1;
		if (TimeOut<Time1)
			TimeLeap = 1;
		else
			TimeLeap = 0;

		//Start at position 0
		PktStatus = 0;

		//Send the Action (could either be an ACK or NAK or C)
		if (mode == 0)
			ret = TxByte (Action);
		else
			ret = SendData (&Action, 1, '0');

		//This is the packet receiving loop, it will exit upon timeout
		//or receiving the packet
		do
		{
			// Is there DATA in the UART FIFO?
			if ( ((mode == 0)&&(UartRXData())) || ((mode == 1)&&(BufferRXData())) )
			{
				//Get a byte
				if (mode == 0)
					RcvPkt[PktStatus] = GetUARTData();
				else
					RcvPkt[PktStatus] = GetBufferData();

				if (RcvPkt[PktStatus] == 0xff) //telnet, FF will be doubled
				{
					if (mode == 0)
					{
						while(!UartRXData());
						GetUARTData(); //discard the second 0xFF
					}
					else
					{
						while(!BufferRXData());
						GetBufferData(); //discard the second 0xFF
					}
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
						is1K = 1; //not 1K transfer
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
						if ((isYmodem)&&(Action == 'C')&&(RcvPkt[PktStatus] == 0))
							//Ok, receiving file name/size as response
							++PktStatus;
						else
						{
							//is this a previous packet being retried?
							if (RcvPkt[PktStatus] == PktNumber - 1)
							{
								IgnorePkt = 1;
								++PktStatus;
							}
							else
							{
								ret = TxByte (NAK);
								TimeOut = 1;
								break;
							}
						}
					}
				}
				else if (PktStatus == 2)
				{
					if (IgnorePkt)
						++PktStatus;
					else if (RcvPkt[PktStatus] == (0xFF - PktNumber) )
						++PktStatus;
					else //error
					{
						if ((isYmodem)&&(Action == 'C')&&(RcvPkt[PktStatus] == 0xFF))
						{
							//Ok, receiving file name/size as response
							++PktStatus;
							CreateFile = 1;
							FileSize = -1; //Unknown at this point
							ReceivedSize = 0;
						}
						else
						{
							ret = TxByte (NAK);
							TimeOut = 1;
							break;
						}
					}
				}
				else if ((isYmodem)&&(Action == 'C')&&(CreateFile)&&(PktStatus == 3))
				{
					//is NULL the filename?
					if (RcvPkt[PktStatus] == 0 )
						NoFile = 1;
					++PktStatus;
				}
				else if ( ((!is1K)&&(PktStatus == 131)) || ((is1K)&&(PktStatus == 1027)) )
				{
					myCrc = ((int)RcvPkt[PktStatus] << 8)&0xff00;
					++PktStatus;
				}
				else if ( ((!is1K)&&(PktStatus == 132)) || ((is1K)&&(PktStatus == 1028)) )
				{
					myCrc = myCrc|((int)RcvPkt[PktStatus]&0xff);
					PktStatus = 0;
					if (is1K)
						pktCrc = crc16(&RcvPkt[3],1024);
					else
						pktCrc = crc16(&RcvPkt[3],128);

					if (IgnorePkt)
					{
						//Ok, finished the packet we need to ignore
						IgnorePkt = 0; //No longer ignoring anything
						PktStatus = 0; // start from 0
					}
					else if ( myCrc != pktCrc )
					{
						printf ("CRC error, expected %x received %x\r\n",myCrc,pktCrc);
						ret = TxByte (NAK);
						TimeOut = 1;
						break;
					}
					else
					{
						//Y Modem and received file name block?
						if ((isYmodem)&&(Action == 'C')&&(CreateFile))
						{
							if (NoFile)
								return 254;
							for (myCrc=3;myCrc<140;myCrc++)
								if (RcvPkt[myCrc] == 0)
									break;
							++myCrc;

							if ((RcvPkt[myCrc]>='0')&&(RcvPkt[myCrc]<='9'))
								FileSize = atol(&RcvPkt[myCrc]);

							if (FileSize == 0)
                            {
                                printf("Receiving file: %s Unknown size.\r\n",&RcvPkt[3]);
								FileSize = -1;
                            }
                            else
                                printf("Receiving file: %s Size: %s\r\n",&RcvPkt[3],&RcvPkt[myCrc]);

							*File = Open (&RcvPkt[3],O_CREAT);
							if (*File != -1)
							{
								ret = TxByte (ACK);
								return 255;
							}
							else // couldn't create file
							{
								ret = TxByte (NAK);
								TimeOut = 1;
								break;
							}
						}
						else if (is1K)
						{
							if (isYmodem)
								ReceivedSize += 1024;

							if (FileSize>0)
								if (ReceivedSize>FileSize)
								{
									Write(*File, &RcvPkt[3],1024 - (ReceivedSize-FileSize));
								}
								else
									Write(*File, &RcvPkt[3],1024);
							else
								Write(*File, &RcvPkt[3],1024);
						}
						else
						{
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
						TimeOut = 0;
						break;
					}
				}
				else
					++PktStatus;
			}

			if (TimeLeap == 0)
			{
				if (GetTickCount()>TimeOut)
				{
					TimeOut = 1;
					break;
				}
			}
			else
			{
				if (GetTickCount()<10)
				{
					TimeLeap = 0;
					if (GetTickCount()>TimeOut)
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
			ret = 1;
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
	int iFile;
	int iNoFile=-1;
	unsigned char PktNumber;
	unsigned char advance[4] = {'-','\\','|','/'};
	unsigned int FilesRcvd = 0;

	rcvdataSize = 0;
	rcvdataPointer = 0;

	Print("XMODEM Download, File Name (or Y for Y-Modem transfer: ");
	InputString(filename,sizeof(filename-1));
	Print("\n");

	ClearUartData();

	//Y-Modem?
	if (((filename[0]=='y')||(filename[0]=='Y'))&&(filename[1]==0))
	{
		do
		{
			//First let's receive file name, size, etc...
			PktNumber = 1;
			iFile = 0;

			// Request start of YMODEM 1K
			ret = XYModemPacketReceive (&iFile, 'C', PktNumber, 1);
			if (ret == 255) //Created a file, cool, let's move on
			{
				++FilesRcvd;
				//Now transfer is like XMODEM for this file
				PktNumber = 1;

				//Our nice animation to show we are not stuck
				PrintChar('S');
				// Request start of XMODEM 1K
				ret = XYModemPacketReceive (&iFile, 'C', PktNumber, 1);
				if (ret)
				{
					do
					{
						//Our nice animation to show we are not stuck
						PrintChar(8);
						PrintChar(advance[PktNumber%4]);
						++PktNumber;
						ret = XYModemPacketReceive (&iFile, ACK, PktNumber, 1);
					}
					while (ret == 1); //basically, while receive packets with SOH/STX, continue receiving/writing

					if (ret == 0) //Time Out or other errors
						Print ("Error receiving file\n");
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
					}
				}
				else //error starting CRC section
					Print("Timeout waiting for file...\n");

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
				break;
			}
		}
		while (ret != 254); //Do this until any procces break or no more files
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
					//Our nice animation to show we are not stuck
					PrintChar(8);
					PrintChar(advance[PktNumber%4]);
					++PktNumber;
					ret = XYModemPacketReceive (&iFile, ACK, PktNumber, 0);
				}
				while (ret == 1); //basically, while receive packets with SOH/STX, continue receiving/writing

				if (ret == 0) //Time Out or other errors
					Print ("Error receiving file\n");
				else if (ret == CAN) //Host canceled the transfer
				{
					XYModemPacketReceive (&iNoFile, ACK, PktNumber, 0);
					Print ("Server canceled transfer\n");
				}
				else if ((ret == EOT)||(ret == ETB)) //End of Transmission
				{
					XYModemPacketReceive (&iNoFile, ACK, PktNumber, 0);
					Print ("File Transfer Completed!\n");
				}
			}
			else //error starting CRC section
				Print("Timeout waiting for file...\n");

			Close (iFile);
		}
		else
			printf ("Error creating file %s ...\r\n",filename);
	}
}

// This will handle each byte received to work on TELNET commands and sub options
void WorkOnReceivedData (unsigned char Data)
{
	// Have we flagged that a telnet CMD is being built?
	if (!CmdInProgress)
	{
		if (Data != CMD)
			BPushBuffer (Data); //Just put in our buffer
		else
		{
			rcvdata[0] = Data;
			CmdInProgress = 1; // flag a command or sub is in progress
			Print("CMD->");
		}
	}
	else // a CMD or sub option is in progress
	{
		// Get the byte in the proper position
		rcvdata[CmdInProgress] = Data;
		printf("{%x}",rcvdata[CmdInProgress]);
		// Is it the first byte after CMD? If yes and it is CMD again
		if ( (CmdInProgress==1) && (rcvdata[CmdInProgress] == CMD))
		{
			//This is the way to mean receive 0xFF, so put FF in the buffer
			BPushBuffer (0xff);
			CmdInProgress = 0;
		}
		// Is it the first byte after CMD and now indicate a sub option?
		else if ( (CmdInProgress==1) && (rcvdata[CmdInProgress] == SB))
		{
			//ok, it is a sub option, keep going
			SubOptionInProgress = 1;
			++CmdInProgress;
		}
		// If receive CMD processing sub option, it could be the end of sub option
		else if ( (SubOptionInProgress == 1) && (rcvdata[CmdInProgress] == CMD) )//need to wait for CMD /SE
		{
			++SubOptionInProgress;
			++CmdInProgress;
		}
		// Was processing sub option, received CMD, is the next byte SE?
		else if ( (SubOptionInProgress == 2) && (rcvdata[CmdInProgress] == SE) )
		{
			//It is, so our sub option reception is done (ends w/ CMD SE)
			++CmdInProgress;
			SubOptionInProgress = 0;
			CmdInProgress = 0;
			Print("<-\n");
			//Negotiate the sub option
			negotiate(rcvdata,CmdInProgress);
		}
		// Was processing sub option, received CMD, but now it is not SE
		else if( (SubOptionInProgress == 2) && (rcvdata[CmdInProgress] != SE) )
			//Keep processing sub option, not the end
			SubOptionInProgress = 1;
		else //ok, nothing special, just data for CMD or SUB
			++CmdInProgress;

		//If not a sub option and is the third byte
		if ((SubOptionInProgress == 0) && (CmdInProgress == 3))
		{
		    Print("<-\n");
			//Commands are 3 bytes long, always
			negotiate(rcvdata,3);
			CmdInProgress = 0;
		}
	}
}

int main(char** argv, int argc)
{
	char tx_data = 0;
	unsigned char ret;
	unsigned char rxdata[1600];
	unsigned int rxdatasize;
	unsigned char input[48];
	unsigned int i;
	APList *myList = NULL;
	unsigned char server[128];
	unsigned char port[6];
	unsigned char crlf[3]="\r\n";
	unsigned char speedstr[8][8]={"115200","57600","38400","31250","19200","9600","4800","2400"};
	unsigned char speed, reconnect;
	unsigned char CanPrint;

	// Reset our RXBuffer pointers
	Top = 0;
	Bottom = 0;
	// TX Buffer full control, if that happens, we will start to
	// lose data.
	Full = 0;
	// This variable control whether Input was the last operation.
	// If so, skip printing data, if any.
	CanPrint = 1;
	// Flag that indicates that a SUB OPTION reception is in progress
	SubOptionInProgress = 0;
	// Speed to use to interface with ESP 8266, 31Kbps should be enough
	// so buffers won't fill up before we can process them
	speed = 3;
	// If ESP indicates it is already connected, usually we do not list
	// available APs to connect. This flag will force showing the AP list
	// even if ESP is already connected.
	reconnect = 0;
	// Connection mode, default is single, it is faster, lower latency
	// Multiple can introduce big latency for small data (like data being
	// typed and sent byte per byte), but is needed for FTP as an example.
	mode = 0;

	//JANSI TSR will leave the screen in mode 7, so if we are in mode 7
	//it should be loaded
	if ( Peek(0xFCAF) == 7 )
		Ansi = 1;
	else
		Ansi = 0;

	//Start clean
	ClearUartData();

	if (!Ansi)
		Print("> MSX-SM ESP8266 WIFI Module TELNET Client v0.50 <\n(c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\n");
	else
		Print("\x1b[31m> MSX-SM ESP8266 WIFI Module TELNET Client v0.5cd tel0 <\n(c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\x1b[0m\n");

	// At least server:port should be received
	if (argc == 0)
	{
		Print(strUsage);
		return 0;
	}

	// Validate command line parameters
    if(!IsValidInput(argv, argc, server, port, &reconnect, &speed, &mode))
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

		printf ("Connecting to server: %s:%s \r\n", server, port);
		SentTTYPE = 0;

		// Open TCP connection to server/port
		if (mode == 0)
			ret = OpenSingleConnection (CONNECTION_TYPE_TCP, server, port);
		else
			ret = OpenConnection (CONNECTION_TYPE_TCP, server, port,'0');

		if ( ret == RET_WIFI_MSXSM_OK)
		{
			Print("Connected!\n");

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
						if (mode == 0)
							ret = TxByte (tx_data);
						else
							ret = SendData(&tx_data,1,'0');
					}
					else // enter/CR
					{
						// Make sure UART is not sending a byte
						while(UartTXInprogress());
						// Send CR and LF as well
						if (mode == 0)
							ret = TxData (crlf, 2);
						else
							ret = SendData(crlf,2,'0');
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

				// Ok, this is the way we currently print data
				// If the last operation was not a read from UART FIFO/ESP
				// Print one byte on the screen. Since printing on the screen
				// is generally slower than Internet Speeds / UART speed, if
				// we block processing printing lots of data FIFO might get
				// full while we are still printing (specially if using JANSI)
				if (CanPrint)
					PPopBuffer ();
				else
					CanPrint = 1;

				// Is there DATA in the UART FIFO?
				if (UartRXData())
				{
					//Check if FIFO Full occurred
					if (InPort(7)&4)
					{
						Print("Buffer OVERRUN! :-(\n");
					}

					// Why stop printing? If receiving consecutive bytes very fast
					// we shouldn't allow the FIFO to overflow... But, generally,
					// there is a time between characters and we should be good
					// printing once between characters... This just control a trade-off
					// of holding printing for intensive reception (where bytes accumulated
					// in the FIFO)
					CanPrint = 0;

					if (mode == 0) //Single connection mode reception is simple
					{
						WorkOnReceivedData(GetUARTData());
					}
					else // Multiple Connection Mode
					{
						//We can clear up to the size of our buffer
						//That is as big as the MSX-SM FIFO
						rxdatasize = sizeof (rxdata);
						ret = ReceiveData (rxdata, &rxdatasize, '0');
						if ((ret == RET_WIFI_MSXSM_OK) && (rxdatasize))
						{
							//Not really efficient but works for now
							//Treat the data as if coming from single
							//connection, byte per byte
							for (i=0;i<rxdatasize;i++)
							{
								WorkOnReceivedData(rxdata[i]);
							}
						}
						else
							printf (">>Error %u trying to receive data, %u bytes left...\r\n<<",ret,rxdatasize);
					}
				}
			}
			while (tx_data != 0x1b); //If ESC pressed, exit...

			Print("Closing connection...\n");
			if (mode == 0)
				ret = CloseSingleConnection();
			else
				ret = CloseConnection('0');

			if (ret != RET_WIFI_MSXSM_OK)
				printf ("Error %u closing connection.\r\n", ret);
		}
		else
			printf ("Error %u connecting to server: %s:%s\r\n", ret, server, port);
	}
	else
		Print("> ESP Init error...\n");

	return 0;
}
