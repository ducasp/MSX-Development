#include "../../fusion-c/header/io.h"
#include "../../fusion-c/header/msx_fusion.h"
#include "UnapiHelper.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "XYMODEM.h"

//X and YMODEM Vars
__at 0xB000 unsigned char RcvPkt[]; //make sure it works in your map file, need to be in 0x8000 and beyond
unsigned char filename[20];
//Indicates G-Modem transfer in progress
unsigned char G;
unsigned long SentFileSize;
unsigned char chFileSize[30];
unsigned char chTransferConn;

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

int ParseReceivedData(unsigned char * ucReceived, unsigned int uiIndex, unsigned int uiReceivedSize, unsigned char * ucIs1K)
{
    unsigned int uiRet = 0;
    unsigned int uiI;
    unsigned char ucContinueAfterHeaderFound = 0;
    static unsigned char ucSplitFF = 0;

    if (!uiIndex) //Index 0 means packet has not started yet
    {
        ucSplitFF = 0;
        for (uiI=0;uiI<uiReceivedSize;++uiI)
        {
            if (ucReceived[uiI]  == SOH) //128 bytes packet
            {
                //printf ("[%x]",ucReceived[uiI]);
                ucContinueAfterHeaderFound = 1;
                memcpy (ucReceived,&ucReceived[uiI],(uiReceivedSize-uiI));
                uiReceivedSize-= uiI;
                *ucIs1K = 0;
                break;
            }
            else if (ucReceived[uiI] == STX) //1024 bytes packet
            {
                //printf ("[%x]",ucReceived[uiI]);
                ucContinueAfterHeaderFound = 1;
                memcpy (ucReceived,&ucReceived[uiI],(uiReceivedSize-uiI));
                uiReceivedSize-= uiI;
                *ucIs1K = 1;
                break;
            }
            else if ((ucReceived[uiI] == EOT)||(ucReceived[uiI] == ETB)||(ucReceived[uiI] == CAN))
            {
                //printf ("(%x)",ucReceived[uiI]);
                return (ucReceived[uiI]*-1);
            }
            //else
                //printf ("{%x}",ucReceived[uiI]);
        }
    }

    if ((uiIndex)||(ucContinueAfterHeaderFound)) //packet has started
    {
        //now get rid of all double FF's replacing by  single FF
        for (uiI=0;uiI<uiReceivedSize;++uiI)
        {
            if (ucReceived[uiI+uiIndex]  != 0xFF) //not telnet IAC
            {
                //printf ("<%x>",ucReceived[uiI+uiIndex]);
                ++uiRet;
            }
            else
            {
                if (ucSplitFF)
                {
                    ucSplitFF = 0;
                    if (uiI==0) //first after a split? Ignore, otherwise continue checking
                        continue; //this might confuse you, continue will jump to next iteration of loop and not execute the rest of the code below
                }

                if ( (uiI<(uiReceivedSize-1)) && (ucReceived[uiI+uiIndex+1] == 0xff) )
                {
                    //printf (">%x<",ucReceived[uiI+uiIndex]);
                    ++uiRet;
                    if (uiI<(uiReceivedSize-2))
                        memcpy (&ucReceived[uiI+uiIndex+1],&ucReceived[uiI+uiIndex+2], (uiReceivedSize-(uiI+2)) );
                    --uiReceivedSize;
                }
                else if (uiI != (uiReceivedSize-1)) //not double FF, not a chance of being split, weird...
                {
                    ++uiRet;
                    //printf ("|%x|",ucReceived[uiI+uiIndex]);
                }
                else //an alone FF in the last byte, should have been split
                {
                    ucSplitFF = 1;
                    ++uiRet;
                }
            }
        }
    }

    return uiRet;
}

int GetPacket(unsigned char * ucPacket, unsigned char * ucIs1K)
{
    int ret = 0;
	unsigned char is1K = 0;
	unsigned int uiReadHelper = 0;
	unsigned int PktStatus = 0;
	unsigned int TimeOut,Time1;
	unsigned char TimeLeap;
	int iParseResult;

	// Timeout for a packet
    Time1 = uiTickCount;
    TimeOut = 360 + Time1;
    if (TimeOut<Time1)
        TimeLeap = 1;
    else
        TimeLeap = 0;


	//This is the packet receiving loop, it will exit upon timeout
    //or receiving the packet
    do
    {
        if (!is1K)
            uiReadHelper = (133-PktStatus); //at least 128 bytes + 5 bytes header
        else
            uiReadHelper = (1029-PktStatus); //at least 1024 bytes + 5 bytes header

        // Read remaining data
        if (RXData (chTransferConn, &ucPacket[PktStatus], &uiReadHelper))
        {
            iParseResult = ParseReceivedData(ucPacket, PktStatus, uiReadHelper, &is1K);
            //printf ("Iparse got: %i out of %u received bytes\r\n",iParseResult,uiReadHelper);
            if (iParseResult>0)
            {
                PktStatus += iParseResult;
                //printf ("Packet actual size: %u\r\n",PktStatus);
                if ( ((is1K)&&(PktStatus>=1029)) || ((!is1K)&&(PktStatus>=133)) )
                {
                    TimeOut = 0;
                    break;
                }
            }
            else if (iParseResult<0)
                return iParseResult;
        }

        UnapiBreath();

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
    while (1);

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

	// If sending a start of transmission 3 retries
	if ((Action == 'C')||(Action == 'G'))
		Retries = 3;
	else //otherwise 10
        if(!G)
            Retries = 10;
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
		    iGetPacketResult = GetPacket(RcvPkt, &is1K);
		    if (iGetPacketResult==1) //success
            {
                //YMODEM
                //
                //First response to a C (start CRC session) or G won't be
                //a data packet, but a packet with number 0 containing
                //filename and possibly file size...
                if ((isYmodem)&&((Action == 'C')||(Action == 'G'))&&(RcvPkt[1] == 0))
                {
					//is NULL the filename?
					if (RcvPkt[2] == 0)
						//No file received, end of transmission
                        return 254;
                    else
                    {
                        ReceivedSize = 0;
                        //Let's check for file name
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
                else if ( (RcvPkt[1] == PktNumber) && (RcvPkt[2] == (0xFF - PktNumber) ) )
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
                //Server might not like how long we are taking to reply
                //with ACK (MSX Disk I/O not really fast) and re-send
                //packets even before we send ACK/NAK. So, if that happens
                //we will get the same packet again. In this case we just
                //need to ignore it.
                //is this a previous packet being retried?
                else if (RcvPkt[1] == PktNumber - 1)
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
void XYModemGet (unsigned char chConn)
{
	unsigned char ret;
	int iFile=0;
	int iNoFile=-1;
	unsigned char PktNumber;
	unsigned char key=0;
	unsigned char advance[4] = {'-','\\','|','/'};
	unsigned int FilesRcvd = 0;

	chTransferConn = chConn;

    Print("XMODEM Download type file Name\nYMODEM Download type Y\nYMODEM-G Download type G: ");
	InputString(filename,sizeof(filename-1));
	Print("\n");

	if ( ((filename[0]=='g')||(filename[0]=='G')) && (filename[1]==0) )
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
                // Request start of YMODEM-G 1K
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
        CancelTransfer();
    }
}
