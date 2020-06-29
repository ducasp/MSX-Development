/*
--
-- XYMODEM.c
--   X/YMODEM(G) for UNAPI Telnet Terminal.
--   Revision 1.00
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2019-2020 Oduvaldo Pavan Junior ( ducasp@gmail.com )
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

#include "../../fusion-c/header/io.h"
#include "../../fusion-c/header/msx_fusion.h"
#include "UnapiHelper.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "XYMODEM.h"
#include "print.h"

//X and YMODEM Vars
__at 0x8500 unsigned char RcvPkt[]; //make sure it works in your map file, need to be in 0x8000 and beyond
unsigned char filename[20];
//Indicates G-Modem transfer in progress
unsigned char G;
unsigned char TestTransfer;
unsigned long SentFileSize;
unsigned char chFileSize[30];
unsigned char chTransferConn;
unsigned char chDoubleFF;
char chProtocolString[128];

// Helper function for file transfers
char *ultostr(unsigned long value, char *ptr, int base)
{
  unsigned long t = 0, res = 0;
  unsigned long tmp = value;
  int count = 0;

  if (NULL == ptr)
  {
    return NULL;
  }

  if (tmp == 0)
  {
    count++;
  }

  while(tmp > 0)
  {
    tmp = tmp/base;
    count++;
  }

  ptr += count;

  *ptr = '\0';

  do
  {
    res = value - base * (t = value / base);
    if (res < 10)
    {
      * -- ptr = '0' + res;
    }
    else if ((res >= 10) && (res < 16))
    {
        * --ptr = 'A' - 10 + res;
    }
  } while ((value = t) != 0);

  return(ptr);
}

//X and YModem packets are similar in structure:
//Starts with SOH if 128 bytes packet or STX for 1024 bytes packet
//Then you get a packet sequence number, XMODEM starts with packet 1
//and the file data, while YMODEM starts with packet 0 that has the
//file information (name/size/date)
//Then you have the complement (i.e.: for 0, FF, for 1, FE, etc) of
//the packet sequence
//Then you have the 128 or 1024 bytes of data
//And finally after the data, two bytes containing CRC16 or a checksum
//
//Due to the way we handle the buffer as a pointer of a pointer, buffer
//MUST HAVE at least the double of a whole packet size, which means 2108
//bytes. This speeds up quite a bit the decoding of double FF's.
int GetPacket(unsigned char ** ucPacket, unsigned char * ucIs1K)
{
    int ret = 0;
	unsigned char is1K = *ucIs1K;
	unsigned int uiReadHelper = 0;
	unsigned int PktStatus = 0;
	unsigned int TimeOut,Time1;
	unsigned char TimeLeap;
	unsigned char ucFoundStart = 0;
	unsigned char ucSkipFF = 0;
	unsigned int uiI,uiJ;
	unsigned char *ucTmpPointer;

	// Timeout for a packet
    Time1 = uiTickCount;
    TimeOut = XYMODEM_PACKET_TIMEOUT + Time1;
    if (TimeOut<Time1)
        TimeLeap = 1;
    else
        TimeLeap = 0;


	//This is the packet receiving loop, it will exit upon timeout
    //or receiving the packet
    while (1)
    {
        if (!is1K)
            uiReadHelper = (133-PktStatus); //at least 128 bytes + 5 bytes header
        else
            uiReadHelper = (1029-PktStatus); //at least 1024 bytes + 5 bytes header

        ucTmpPointer = *ucPacket + PktStatus;

        // Read data
        if (RXData (chTransferConn, ucTmpPointer, &uiReadHelper,1))
        {
            if (!ucFoundStart)
            {
                //New package, so split information do not matter, we will wait SOH/STX/EOT/ETB/CAN
                for(uiI=0;uiI<uiReadHelper;++uiI)
                {
                    if (ucTmpPointer[uiI]==STX) //1024 bytes packet start
                    {
                        is1K = 1;
                        ucTmpPointer += uiI;
                        *ucPacket = ucTmpPointer;
                        ucFoundStart = 1;
                        uiReadHelper -= uiI;
                        break;
                    }
                    else if (ucTmpPointer[uiI]==SOH) //128 bytes packet start
                    {
                        is1K = 0;
                        ucTmpPointer += uiI;
                        *ucPacket = ucTmpPointer;
                        ucFoundStart = 1;
                        uiReadHelper -= uiI;
                        break;
                    }
                    else if ((ucTmpPointer[uiI] == EOT)||(ucTmpPointer[uiI] == ETB)||(ucTmpPointer[uiI] == CAN)) //transmission cancelled
                        return (ucTmpPointer[uiI]*-1);
                }
            }

            if (ucFoundStart)
            {
                if (TestTransfer)
                {
                   TestTransfer = 0;
                   if (uiReadHelper>3)
                    if ((ucTmpPointer[1]==0x00)&&(ucTmpPointer[2]==0xff)&&(ucTmpPointer[3]!=0xff))
                        chDoubleFF = 0;
                }

                if (chDoubleFF)
                {
                    for (uiI=0,uiJ=0;uiI<uiReadHelper;++uiI)
                    {
                        if (ucSkipFF) //Skip FF?
                        {
                            ++uiJ;
                            ucSkipFF=0;
                            continue;
                        }

                        if (ucTmpPointer[uiI] == 0xFF) //Telnet IAC?
                            ucSkipFF=1;

                        if (uiJ) //need to start moving bytes
                            ucTmpPointer[uiI-uiJ]=ucTmpPointer[uiI];
                    }
                    PktStatus += uiReadHelper;
                    PktStatus -= uiJ;
                }
                else
                {
                    PktStatus += uiReadHelper;
                }

                if ( ((is1K)&&(PktStatus>=1029)) || ((!is1K)&&(PktStatus>=133)) )
                {
                    TimeOut = 0;
                    break;
                }
            }

        }

        Breath();

        if (TimeLeap == 0)
        {
            if (uiTickCount>TimeOut)
            {
                //if timed out set 1 to indicate error
                TimeOut = 1;
                break;
            }
        }
        else
        {
            if (uiTickCount<120)
            {
                TimeLeap = 0;
                if (uiTickCount>TimeOut)
                {
                    TimeOut = 1;
                    break;
                }
            }
        }
    }

    if (TimeOut == 0) //Packet received
    {
        ret = 1; //Success
        *ucIs1K = is1K;
    }
    else
    {
        ret = 0; //Failure
        *ucIs1K = 0;
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
    unsigned int chrLen = 0;
    unsigned int chrTerm = 0;
    unsigned int i;
	unsigned int TimeOut,Time1;
	unsigned char TimeLeap;
	unsigned char Retries;
	unsigned char *ucReadBuffer;
	static long FileSize;
	static long ReceivedSize;
	int iGetPacketResult;

    //This is an escape indicating to just send an Action (i.e.: C, ACK, NAK)
	if (*File == -1)
	{
		ret = TxByte (chTransferConn, Action);

		if (ret == ERR_OK)
			return 1;
		else
			return 0;
	}

	// If sending a start of transmission XYMODEM_STARTPACKET_RETRIES retries
	if ((Action == 'C')||(Action == 'G'))
		Retries = XYMODEM_STARTPACKET_RETRIES;
	else //otherwise XYMODEM_PACKET_RETRIES
        if(!G)
            Retries = XYMODEM_PACKET_RETRIES;
        else
            Retries = 1; //YMODEM-G - no retries at all, once wrong, cancel

	//Ok, so let's do the packet game while we can retry
	for (i = 0; i<Retries; i++)
	{
	    // Timeout for a packet
		Time1 = uiTickCount;
		TimeOut = 360 + Time1;
		if (TimeOut<Time1)
			TimeLeap = 1;
		else
			TimeLeap = 0;

		//Send the Action (could either be an ACK or NAK or C)
		if (Action)
            ret = TxByte (chTransferConn, Action);

		//This is the packet receiving loop, it will exit upon timeout
		//or receiving the packet
		do
		{
		    ucReadBuffer = RcvPkt;
		    iGetPacketResult = GetPacket(&ucReadBuffer, &is1K);
		    if (iGetPacketResult==1) //success
            {
                //YMODEM
                //
                //First response to a C (start CRC session) or G won't be
                //a data packet, but a packet with number 0 containing
                //filename and possibly file size...
                if ((isYmodem)&&((Action == 'C')||(Action == 'G'))&&(ucReadBuffer[1] == 0))
                {
					//is NULL the filename?
					if (ucReadBuffer[3] == 0)
						//No file received, end of transmission
                        return 254;
                    else
                    {
                        ReceivedSize = 0;
                        //Let's check for file name
                        for (chrLen=3;chrLen<140;chrLen++)
                            if (ucReadBuffer[chrLen] == 0)
                                break;
                        ++chrLen;

                        if ((ucReadBuffer[chrLen]>='0')&&(ucReadBuffer[chrLen]<='9'))
                            FileSize = atol(&ucReadBuffer[chrLen]);

                        if (FileSize == 0)
                        {
                            sprintf(chProtocolString,"Receiving file: %s Unknown size.\r\n",&ucReadBuffer[3]);
                            print(chProtocolString);
                            FileSize = -1;
                        }
                        else
                        {
                            //Some servers do not comply to put a 0 after file size, use space
                            //so just fix it
                            for (chrTerm=chrLen; (ucReadBuffer[chrTerm]>='0')&&(ucReadBuffer[chrTerm]<='9'); ++chrTerm);
                            ucReadBuffer[chrTerm]=0;
                            sprintf(chProtocolString,"Receiving file: %s Size: %s\r\n",&ucReadBuffer[3],&ucReadBuffer[chrLen]);
                            print(chProtocolString);
                        }

                        strcpy (filename, &ucReadBuffer[3]);
                        *File = Open (&ucReadBuffer[3],O_CREAT);
                        if (*File != -1)
                        {
                            //File created, success
                            if ((Action != 'G')) //YMODEM G no ack, it will just stream file after receiving next G
                                ret = TxByte (chTransferConn, ACK);
                            return 255;
                        }
                        else // couldn't create file
                        {
                            //Failure creating file, can't move on
                            ret = TxByte (chTransferConn, NAK);
                            //Set timeout as 1 to indicate failure
                            TimeOut = 1;
                            break;
                        }
                    }
                }
                //not response to C or G, so packet numbers must match
                else if ( (ucReadBuffer[1] == PktNumber) && (ucReadBuffer[2] == (0xFF - PktNumber) ) )
                {
                    //Ok, write it
                    if (is1K)
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
                                Write(*File, &ucReadBuffer[3],1024 - (ReceivedSize-FileSize));
                            }
                            else //otherwise save the entire block
                                Write(*File, &ucReadBuffer[3],1024);
                        else //XMODEM you just save everything and file could be padded
                            Write(*File, &ucReadBuffer[3],1024);
                    }
                    else
                    {
                        //Same as above, but for 128 bytes blocks
                        if (isYmodem)
                            ReceivedSize += 128;

                        if (FileSize>0)
                            if (ReceivedSize>FileSize)
                            {
                                Write(*File, &ucReadBuffer[3],128 - (ReceivedSize-FileSize));
                            }
                            else
                                Write(*File, &ucReadBuffer[3],128);
                        else
                            Write(*File, &ucReadBuffer[3],128);
                    }
                    //Set time out as 0 to indicate success
                    TimeOut = 0;
                    break;
                }
                //Server might not like how long we are taking to reply
                //with ACK (MSX Disk I/O not really fast) and re-send
                //packets even before we send ACK/NAK. So, if that happens
                //we will get the same packet again. In this case we just
                //need to ignore it.
                //is this a previous packet being retried?
                else if (ucReadBuffer[1] == PktNumber - 1)
                {
                    //set timeout as 1 to indicate error and retry will do it
                    TimeOut = 1;
                    break;
                }
                else
                {
                    ret = TxByte (chTransferConn, NAK);
                    //set timeout as 1 to indicate error
                    TimeOut = 1;
                    break;
                }
            }
            else
                if (iGetPacketResult<0) //if negative, it is a control requesting termination
                    return (iGetPacketResult*-1);

            if (TimeLeap == 0)
			{
				if (uiTickCount>TimeOut)
				{
				    //if timed out set 1 to indicate error
					TimeOut = 1;
					break;
				}
			}
			else
			{
				if (uiTickCount<120)
				{
					TimeLeap = 0;
					if (uiTickCount>TimeOut)
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

//This will cancel an incoming/outcoming transfer
void CancelTransfer(void)
{
    int iNoFile=-1;
    //Ok, just CANcel it
    XYModemPacketReceive (&iNoFile, CAN, 0, 1);
    XYModemPacketReceive (&iNoFile, CAN, 0, 1);
    XYModemPacketReceive (&iNoFile, CAN, 0, 1);
    XYModemPacketReceive (&iNoFile, CAN, 0, 1);
    XYModemPacketReceive (&iNoFile, CAN, 0, 1);
}

// This function will deal with file reception
void XYModemGet (unsigned char chConn, unsigned char chTelnetTransfer)
{
	unsigned char ret;
	int iFile=0;
	int iNoFile=-1;
	unsigned char PktNumber;
	unsigned char key=0;
	unsigned char advance[4] = {'-','\\','|','/'};
	unsigned int FilesRcvd = 0;

	chTransferConn = chConn;
	chDoubleFF = chTelnetTransfer;

    print("\r\n\r\nXMODEM Download type file Name\r\nYMODEM Download type Y\r\nYMODEM-G Download type G: ");
	InputString(filename,sizeof(filename-1));
	print("\r\n");

	if ( ((filename[0]=='g')||(filename[0]=='G')) && (filename[1]==0) )
        G=1;
    else
        G=0;
	//Y-Modem?
	if ((G) || (((filename[0]=='y')||(filename[0]=='Y'))&&(filename[1]==0)))
	{
	    TestTransfer = 1; //test first packet, 00, if it is doubling ff or not
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
                // Request start of YMODEM-G 1K
                ret = XYModemPacketReceive (&iFile, 'G', PktNumber, 1);
            else
                // Request start of YMODEM 1K
                ret = XYModemPacketReceive (&iFile, 'C', PktNumber, 1);

            //Our nice animation to show we are not stuck
            printChar('S');

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

                        printChar(8); //backspace
                        printChar(advance[PktNumber%4]); // next char

                        ++PktNumber; //next packet
                        if (G)
                            ret = XYModemPacketReceive (&iFile, 0, PktNumber, 1);
                        else
                            ret = XYModemPacketReceive (&iFile, ACK, PktNumber, 1);
                    }
                    while (ret == 1); //basically, while receive packets with SOH/STX, continue receiving/writing

                    if (ret == 0) //Time Out or other errors
                    {
                        print ("Error receiving file\r\n");
                        key = 0x1b; //force send of CAN CAN CAN CAN CAN
                    }
                    else if (ret == CAN) //Host canceled the transfer
                    {
                        //Ok, just ACK it
                        XYModemPacketReceive (&iNoFile, ACK, PktNumber, 1);
                        print ("Server canceled transfer\r\n");
                    }
                    else if ((ret == EOT)||(ret == ETB)) //End of Transmission
                    {
                        //Ok, just ACK it
                        XYModemPacketReceive (&iNoFile, ACK, PktNumber, 1);
                        print ("File Transfer Completed!\r\n");
                    }
                    else if (key == 0x1b) //esc?
                        break;
                }
                else //error starting CRC section
                {
                    print("Timeout waiting for file...\r\n");
                    key = 0x1b; //force send of CAN CAN CAN CAN CAN
                }

                Close (iFile);
            }
            else if (ret == 254) //No file or no more files
            {
                //Ok, just ACK it
                XYModemPacketReceive (&iNoFile, ACK, PktNumber, 1);
                sprintf (chProtocolString,"DONE! Transferred %u files...\r\n",FilesRcvd);
                print (chProtocolString);
            }
            else
            {
                print("Unknown error waiting for file...\r\n");
                key = 0x1b; //force send of CAN CAN CAN CAN CAN
                break;
            }
        }
        while ((key != 0x1b)&&(ret != 254)); //Do this until any process break or no more files
	}
	else //X-Modem
	{
	    TestTransfer = 0; //in XMODEM we are not able to test packet 00 (STX or SOH, 00 and FF, if fourth byte is FF then it is doubling, otherwise not)
		//in XMODEM filename is up to the user, we've already asked it, so create the file
		iFile = Open (filename,O_CREAT);

		if (iFile != -1)
		{
			PktNumber = 1;
			//Our nice animation to show we are not stuck
            printChar('S');
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

                    printChar(8);
                    printChar(advance[PktNumber%4]);

					++PktNumber;
					ret = XYModemPacketReceive (&iFile, ACK, PktNumber, 0);
				}
				while (ret == 1); //basically, while receive packets with SOH/STX, continue receiving/writing

				if (ret == 0) //Time Out or other errors
                {
					print ("Error receiving file\r\n");
					key = 0x1b; //force send of CAN CAN CAN CAN CAN
                }
				else if (ret == CAN) //Host canceled the transfer
				{
					XYModemPacketReceive (&iNoFile, ACK, PktNumber, 0);
					print ("Server canceled transfer\r\n");
				}
				else if ((ret == EOT)||(ret == ETB)) //End of Transmission
				{
					XYModemPacketReceive (&iNoFile, ACK, PktNumber, 0);
					print ("File Transfer Completed!\r\n");
				}
			}
			else //error starting CRC section
            {
				print("Timeout waiting for file...\r\n");
				key = 0x1b; //force send of CAN CAN CAN CAN CAN
            }

			Close (iFile);
		}
		else
        {
			sprintf (chProtocolString,"Error creating file %s ...\r\n",filename);
			print (chProtocolString);
			key = 0x1b; //force send of CAN CAN CAN CAN CAN
        }
	}

	if (key == 0x1b) //cancelled
    {
        CancelTransfer();
    }
}
