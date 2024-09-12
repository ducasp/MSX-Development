/*
--
-- UPDT8266.c
--   Update ESP8266 firmware MSX Pico.
--   Revision 1.00
--
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2024 Oduvaldo Pavan Junior ( ducasp@ gmail.com )
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
#include "../../fusion-c/header/msx_fusion.h"
#include "../../fusion-c/header/io.h"
#include "../../fusion-c/header/asm.h"
#include "UPDT8266.h"

void ChangePageOne(unsigned char uchSlot, unsigned char uchSubSlot)
{
    Z80_registers regs;

    if (uchSubSlot < 4)
        regs.Bytes.A = (uchSlot & 0x03) | ((uchSubSlot <<2)& 0x0c) | 0x80;
    else
        regs.Bytes.A = (uchSlot & 0x03);
    regs.Bytes.F = 0;

    regs.Bytes.H=0x40;
    AsmCall(0x0024, &regs, REGS_MAIN, REGS_NONE);
}

// Will restore slot configuration
void RestoreSlots(void)
{
    ChangePageOne(uchOriginalProgramSlot,uchOriginalProgramSubSlot);
}


// This will scan MSXPico on slots
unsigned char DetectMSXPico(void)
{
    unsigned char uchSlotLoop, uchSubSlotLoop;
    unsigned char uchReturn = 0;
    unsigned char* uchSignature = (unsigned char*)0x7fe0;
    unsigned char uchSlotExpanded[4];

    uchSlotExpanded[0] = uchSlot0Expanded &0x80;
    uchSlotExpanded[1] = uchSlot1Expanded &0x80;
    uchSlotExpanded[2] = uchSlot2Expanded &0x80;
    uchSlotExpanded[3] = uchSlot3Expanded &0x80;

    // Let's say it is undetected for now
    uchOriginalPicoSlot = 0xff;

    // First thing: we need to save original slot of page 1
    uchOriginalProgramSlot = uchPage1RamSlot & 0x03;

    if ((uchPage1RamSlot&0x80)!=0)
        uchOriginalProgramSubSlot = (uchPage1RamSlot >> 2) & 0x03;
    else
        uchOriginalProgramSubSlot = 0xff;

    // Now let's scan all slots, so we want to set page 1
    for (uchSlotLoop = 0; uchSlotLoop < 4; ++uchSlotLoop)
    {
        if (uchSlotExpanded[uchSlotLoop] == 0)
        {
            ChangePageOne(uchSlotLoop,0xff);
            // Well, lot simpler, just read it
            if ((uchSignature[0] =='[')&&(uchSignature[1] ==' ')&&(uchSignature[2] =='E')&&(uchSignature[3] =='S')&&\
                    (uchSignature[4] =='P')&&(uchSignature[5] =='8')&&(uchSignature[6] =='2')&&(uchSignature[7] =='6')&&\
                    (uchSignature[8] =='6')&&(uchSignature[9] =='P')&&(uchSignature[10] =='.')&&(uchSignature[11] =='R')&&\
                    (uchSignature[12] =='O')&&(uchSignature[13] =='M')&&(uchSignature[14] ==' ')&&(uchSignature[15] ==']'))
            {
                uchReturn = 1;
                uchOriginalPicoSlot = uchSlotLoop;
                uchOriginalPicoMemSubSlot = 0xff;
                break;
            }
        }
        else
        {
            for (uchSubSlotLoop = 0; uchSubSlotLoop < 4; ++uchSubSlotLoop)
            {
                ChangePageOne(uchSlotLoop,uchSubSlotLoop);
                if ((uchSignature[0] =='[')&&(uchSignature[1] ==' ')&&(uchSignature[2] =='E')&&(uchSignature[3] =='S')&&\
                    (uchSignature[4] =='P')&&(uchSignature[5] =='8')&&(uchSignature[6] =='2')&&(uchSignature[7] =='6')&&\
                    (uchSignature[8] =='6')&&(uchSignature[9] =='P')&&(uchSignature[10] =='.')&&(uchSignature[11] =='R')&&\
                    (uchSignature[12] =='O')&&(uchSignature[13] =='M')&&(uchSignature[14] ==' ')&&(uchSignature[15] ==']'))
                {
                    uchReturn = 1;
                    uchOriginalPicoSlot = uchSlotLoop;
                    uchOriginalPicoMemSubSlot = uchSubSlotLoop;
                    break;
                }
            }
            // If found on sub slot loop, end the slot loop as well
            if (uchReturn == 1)
                break;
        }
    }

    return uchReturn;
}

// This function read from the disk and return how many bytes have been read
unsigned int MyRead (int Handle, unsigned char* Buffer, unsigned int Size)
{
    unsigned int iRet;

    Z80_registers regs;

    regs.Words.DE = (unsigned int) Buffer;
    regs.Words.HL = Size;
    regs.Bytes.B = (unsigned char)(Handle&0xff);
    DosCall(0x48, &regs, REGS_MAIN, REGS_MAIN);
    if (regs.Bytes.A == 0)
    {
        //Return how many bytes were read
        iRet = regs.Words.HL;
    }
    else
        iRet = 0;

    return iRet;
}

// Checks Input Data received from command Line and copy to the variables
unsigned int IsValidInput (char**argv, int argc, unsigned char *cServer, unsigned char *cFile, unsigned char *cPort)
{
	unsigned int ret = 1;
	unsigned char * Input = (unsigned char*)argv[0];

	if (argc)
	{
		if ((argc==1)||(argc==2)||(argc==4))
		{
		    if ((argc==1)||(argc==2))
            {
                strcpy (cFile,Input);
                ucLocalUpdate = 1;
                if (argc==2)
                {
                    Input = (unsigned char*)argv[1];
                    if ((Input[0]=='/')&&((Input[1]=='c')||(Input[1]=='C')))
                        ucIsFw=0;
                    else
                        ret=0;

                }
                else
                    ucIsFw=1;
            }
            else
            {
                if ((Input[0]=='/')&&((Input[1]=='u')||(Input[1]=='U')))
                {
                    ucIsFw = 1;
                    Input = (unsigned char*)argv[2];
                    if (strlen (Input)<7)
                    {
                        strcpy(cPort,Input);
                        Input = (unsigned char*)argv[1];
                        strcpy(cServer,Input);
                        Input = (unsigned char*)argv[3];
                        strcpy(cFile,Input);
                        lPort = atol(cPort);
                        uiPort = (lPort&0xffff);
                    }
                    else
                        ret = 0;
                }
                else if ((Input[0]=='/')&&((Input[1]=='c')||(Input[1]=='C')))
                {
                    ucIsFw = 0;
                    Input = (unsigned char*)argv[2];
                    if (strlen (Input)<7)
                    {
                        strcpy(cPort,Input);
                        Input = (unsigned char*)argv[1];
                        strcpy(cServer,Input);
                        Input = (unsigned char*)argv[3];
                        strcpy(cFile,Input);
                        lPort = atol(cPort);
                        uiPort = (lPort&0xffff);
                    }
                    else
                        ret = 0;
                }
                else
                    ret = 0;
            }
		}
		else
            ret = 0;
	}
	else
        ret=0;

	return ret;
}

void TxByte(char chTxByte)
{
    while (myPort7&2);
    myPort7 = chTxByte;
}

char *ultostr(unsigned long value, char *ptr, int base)
{
    unsigned long t = 0, res = 0;
    unsigned long tmp = value;
    unsigned char count = 0;

    if (NULL == ptr) //if null pointer
        return NULL; //nothing to do

    if (tmp == 0) //if value is zero
        ++count; //one digit
    else
    {
        while(tmp > 0)
        {
            tmp = tmp/base;
            ++count;
        }
    }

    ptr += count; // so, after the LSB
    *ptr = '\0'; // null terminator

    do
    {
        t = value / base; // useful now (find remainder) as well later (next value of value)
        res = value - base * t; // get what remains of dividing base
        // We can work up to base 16, so need to make HEX if base allows values larger than 9
        if (res < 10)
            * -- ptr = '0' + res; // convert the remainder to ASCII and put in the current position of pointer, move pointer after operation
        else if ((res >= 10) && (res < 16)) // Otherwise is a HEX value and a digit above 9
            * --ptr = 'A' - 10 + res; // convert the remainder to ASCII and put in the current position of pointer, move pointer after operation
    } while ((value = t) != 0); //value is now t, and if t is other than zero, still work to do

    return(ptr); // and return own pointer as successful conversion has been made
}

bool WaitForRXData(unsigned char *uchData, unsigned int uiDataSize, unsigned int Timeout, bool bVerbose, bool bShowReceivedData, unsigned char *uchData2, unsigned int uiDataSize2)
{
    bool bReturn = false;
    unsigned char rx_data;
	unsigned int Timeout1,Timeout2;
	unsigned int ResponseSt = 0;
	unsigned int ResponseSt2 = 0;
	unsigned int i = 0;

	if (bShowReceivedData)
    {
        printf ("Waiting for: ");
        for (i=0;i<uiDataSize;++i)
            printf("%c",uchData[i]);
        printf (" / ");
        for (i=0;i<uiDataSize;++i)
            printf("{%x}",uchData[i]);
        printf ("\r\n");
        i = 0;
    }
    //Command sent, done, just wait response
    Timeout1 = TickCount + 9; //Drives the animation every 9 ticks or so
    Timeout2 = TickCount + Timeout; //Wait up to 5 minutes

    ResponseSt = 0;
    ResponseSt2 = 0;

    do
    {
        if (Timeout>900)
        {
            if (TickCount>Timeout1)
            {
                Timeout1 = TickCount + 9;
                printf("%s",advance[i%5]); // next char
                ++i;
            }
        }
        if(UartRXData())
        {
            rx_data = GetUARTData();

            if (rx_data == uchData[ResponseSt])
            {
                if (bShowReceivedData)
                    printf ("{%x}",rx_data);
                ++ResponseSt;
                if (ResponseSt == uiDataSize)
                {
                    bReturn = 1;
                    break;
                }
            }
            else
            {
                if ((ResponseSt)&&(bShowReceivedData))
                    printf ("{%x} != [%x]",rx_data,uchData[ResponseSt]);
                else if (bShowReceivedData)
                    printf ("}%x{",rx_data);
                if ((uiDataSize==2)&&(ResponseSt==1))
                {
                    if ((bVerbose)&&(!uchData2))
                        printf ("Error %u on command %c...\r\n",rx_data,uchData[0]);
                    return false;
                }
                ResponseSt = 0;
            }

            if ((uchData2)&&(rx_data == uchData2[ResponseSt2]))
            {
                ++ResponseSt2;
                if (ResponseSt2 == uiDataSize2)
                {
                    bReturn = 2;
                    break;
                }
            }
            else
                ResponseSt2 = 0;
        }

        if (TickCount>Timeout2)
            break;
    }
    while (1);

    if (Timeout>900)
        printf("%s",aDone); // clear line

    return bReturn;
}

void FinishUpdate (bool bSendReset)
{
	unsigned int iRetries = 3;
	unsigned char uchHalt = 60;
	bool bRet=true;
	unsigned char ucRetries = 2;
	bool bReset = bSendReset;

	printf("\rFinishing flash, this will take some time, WAIT!\r\n");

	do
    {
        bRet = true;
        --ucRetries;
        if (bReset)
            TxByte('R'); //Request Reset
        else
        {
            do
            {
                for (uchHalt=60;uchHalt>0;--uchHalt)
                    Halt();
                TxByte('E'); //End Update
                bRet = WaitForRXData(endUpdate,2,1800,true,false,NULL,0);
                iRetries--;
            }
            while ((!bRet)&&(iRetries));

            if (bRet)
                bReset=true;
        }

        if (!bRet)
            printf("\rTimeout waiting to end update...\r\n");
        else
        {
            if (ucRetries)
            {
                if (ucIsFw)
                    printf("\rFirmware Update done, ESP is restarting, WAIT...\r\n");
                else
                    printf("\rCertificates Update done, ESP is restarting, WAIT...\r\n");
            }

            if (WaitForRXData(responseReady2,7,2700,false,false,NULL,0)) //Wait up to 45 seconds
            {
                if (!ucIsFw)
                {
                    printf("\rESP Reset Ok, now let's request creation of index file...\r\n");
                    iRetries = 10;
                    do
                    {
                        for (uchHalt=60;uchHalt>0;--uchHalt)
                            Halt();
                        TxByte('I'); //End Update
                        bRet = WaitForRXData(certificateDone,2,3600,false,false,NULL,0); //Wait up to 1 minute, certificate index creation takes time
                        iRetries--;
                    }
                    while ((!bRet)&&(iRetries));
                    if (bRet)
                        printf("\rDone!                                \r\n");
                    else
                        printf("\rDone, but time-out on creating certificates index file!\r\n");
                }
                else
                    printf("\rDone!                              \r\n");
                break;
            }
            else
                if (!ucRetries)
                    printf("\rTimeout error\r\n");
        }
    }
    while (ucRetries);

    return;
}

int main(char** argv, int argc)
{
	unsigned char tx_data = 0;
	unsigned char rx_data;
	unsigned char speed = 0;
	unsigned int uiCMDLen;
	unsigned int i = 0;
	unsigned int ii = 0;
	int iFile;
    Z80_registers regs;
    unsigned long SentFileSize;
    unsigned char chFileSize[30];
    unsigned int FileRead;
    unsigned char ucFirstBlock = 1;
    bool bResponse = false;
    unsigned char ucVerMajor;
    unsigned char ucVerMinor;
    unsigned int uiAnimationTimeOut;
    unsigned char ucServer[300];
    unsigned char ucFile[300];
    unsigned char ucPort[6];

    //Global Variables Initialization is not working with current DOS CRT
    ucLocalUpdate = 0;
    ucVerMajor = 0;
    ucVerMinor = 0;
    TickCount = 0; //this guarantees no leap for 18 minutes, more than enough so we do not need to check for jiffy leaping

	printf("> MSX Pico ESP8266 FW Update Tool v1.00 <\r\n(c) 2024 Oduvaldo Pavan Junior - ducasp@gmail.com\r\n\n");

    if (IsValidInput(argv, argc, ucServer, ucFile, ucPort))
    {
        if (DetectMSXPico())
        {
            if (uchOriginalPicoMemSubSlot == 0xff)
                printf("MSX Pico Wi-Fi Detected on slot %d \r\n\n", uchOriginalPicoSlot);
            else
                printf("MSX Pico Wi-Fi Detected on slot %d sub slot %d \r\n\n", uchOriginalPicoSlot, uchOriginalPicoMemSubSlot);

            do
            {
                //Set Speed
                myPort6 = speed;
                ClearUartData();
                Halt();
                TxByte('?');

                bResponse = WaitForRXData(responseOK,2,60,false,false,NULL,0);

                if (bResponse)
                    break; //found speed which ESP replied
                ++speed;
            }
            while (speed<10);

            if (speed<10)
            {
                printf ("Baud Rate: %s\r\n",speedStr[speed]);
                TxByte('V'); //Request version
                bResponse = WaitForRXData(versionResponse,1,20,true,false,NULL,0);
                if (bResponse)
                {
                    while(!UartRXData());
                    ucVerMajor = GetUARTData();
                    while(!UartRXData());
                    ucVerMinor = GetUARTData();
                }
                printf ("FW Version: %c.%c\r\n",ucVerMajor+'0',ucVerMinor+'0');

                if (ucLocalUpdate)
                {
                    //ok, we are going to try to update fw from local file
                    iFile = Open (ucFile,O_RDONLY);
                    //Could open the file?
                    if (iFile!=-1)
                    {
                        // Why not use _size from fusion-c?
                        // Because it is not DOS2 compatible, and we use DOS2
                        // Why not use Lseek from fusion-c?
                        // Although it calls 0x4A in DOS 2, it won't update the pointer
                        // with the current position
                        regs.Words.HL = 0; //set pointer as 0
                        regs.Words.DE = 0; //so it will return the position
                        regs.Bytes.A = 2; //relative to the end of file, i.e.:file size
                        regs.Bytes.B = (unsigned char)(iFile&0xff);
                        DosCall(0x4A, &regs, REGS_ALL, REGS_ALL); // MOVE FILE HANDLER
                        if (regs.Bytes.A == 0) //moved, now get the file handler position, i.e.: size
                            SentFileSize = (unsigned long)(regs.Words.HL)&0xffff | ((unsigned long)(regs.Words.DE)<<16)&0xffff0000;
                        else
                            SentFileSize = 0;
                        // Convert to string
                        ultostr(SentFileSize,chFileSize,10);
                        Close(iFile);
                        if (ucIsFw)
                            printf ("Updating FW...\r\nPlease Wait, it can take up to a few minutes!\r\nAs long as the animation moves, it is in progress!\r\n");
                        else
                            printf ("Updating Certificates...\r\nPlease Wait, it can take up to a few minutes!\r\nAs long as the animation moves, it is in progress!\r\n");
                        printf ("File: %s Size: %s \r\n",ucFile,chFileSize);
                        if (SentFileSize)
                        {
                            iFile = Open (ucFile,O_RDONLY);
                            if (iFile!=-1)
                            {
                                FileRead = MyRead(iFile, ucServer,256); //try to read 256 bytes of data
                                if (FileRead == 256)
                                {
                                    //Now request to start update over serial
                                    if (ucIsFw)
                                        TxByte('Z'); //Request start of RS232 update
                                    else
                                        TxByte('Y'); //Request start of RS232 cert update
                                    TxByte(0);
                                    TxByte(12);
                                    TxByte((unsigned char)(SentFileSize&0xff));
                                    TxByte((unsigned char)((SentFileSize&0xff00)>>8));
                                    TxByte((unsigned char)((SentFileSize&0xff0000)>>16));
                                    TxByte((unsigned char)((SentFileSize&0xff000000)>>24));
                                    TxByte((unsigned char)((SentFileSize&0xff00000000)>>32));
                                    TxByte((unsigned char)((SentFileSize&0xff0000000000)>>40));
                                    TxByte((unsigned char)((SentFileSize&0xff000000000000)>>48));
                                    TxByte((unsigned char)((SentFileSize&0xff00000000000000)>>56));
                                    TxByte(ucServer[0]);
                                    TxByte(ucServer[1]);
                                    TxByte(ucServer[2]);
                                    TxByte(ucServer[3]);

                                    if (ucIsFw)
                                        bResponse = WaitForRXData(responseRSFWUpdate,2,60,true,false,NULL,0);
                                    else
                                        bResponse = WaitForRXData(responseRSCERTUpdate,2,60,true,false,NULL,0);

                                    if (!bResponse)
                                        printf("Error requesting to start firmware update.\r\n");
                                    else
                                    {
                                        uiAnimationTimeOut = TickCount + 9;
                                        do
                                        {
                                            --uiAnimationTimeOut;
                                            if (TickCount>=uiAnimationTimeOut)
                                            {
                                                uiAnimationTimeOut = 9;
                                                //Our nice animation to show we are not stuck
                                                printf("%s",advance[i%5]); // next animation step
                                                ++i;
                                            }
                                            if (!ucFirstBlock)
                                            {
                                                FileRead = MyRead(iFile, ucServer,256); //try to read 256 bytes of data
                                                if (FileRead ==0)
                                                {
                                                    printf("\rError reading file...\r\n");
                                                    break;
                                                }
                                            }
                                            else
                                                ucFirstBlock = 0;
                                            //Send the block
                                            TxByte('z'); //Write block
                                            TxByte((unsigned char)((FileRead&0xff00)>>8));
                                            TxByte((unsigned char)(FileRead&0xff));
                                            for (ii=0;ii<256;ii++)
                                                TxByte(ucServer[ii]);

                                            bResponse = WaitForRXData(responseWRBlock,2,600,true,false,NULL,0);

                                            if (!bResponse)
                                            {
                                                printf("\rError requesting to write firmware block.\r\n");
                                                break;
                                            }
                                            SentFileSize = SentFileSize - FileRead;
                                        }
                                        while(SentFileSize);
                                        printf("%s",aDone);

                                        //if here and last command was not error, time to finish flashing
                                        if (bResponse)
                                            FinishUpdate(false);
                                    }
                                }
                                else
                                    Print("\rError reading firmware file!\r\n");
                                Close(iFile);
                            }
                            else
                            {
                                printf("Error, couldn't open %s ...\r\n",ucFile);
                                return 0;
                            }
                        }
                        else
                        {
                            printf("Error, %s is 0 bytes long...\r\n",ucFile);
                            return 0;
                        }
                    }
                    else
                    {
                        printf("Error, couldn't open %s ...\r\n",ucFile);
                        return 0;
                    }
                }
                else //ok, we are going to try to update fw
                {
                    if (ucIsFw)
                        printf ("Ok, updating FW using server: %s port: %u\r\nFile path: %s\nPlease Wait, it can take up to a few minutes!\r\n",ucServer,uiPort,ucFile);
                    else
                        printf ("Ok, updating certificates using server: %s port: %u\r\nFile path: %s\nPlease Wait, it can take up to a few minutes!\r\n",ucServer,uiPort,ucFile);
                    uiCMDLen = strlen(ucServer) + 3; //3 = 0 terminator + 2 bytes port
                    uiCMDLen += strlen(ucFile);
                    if (ucIsFw)
                        TxByte('U'); //Request Update Main Firmware remotely
                    else
                        TxByte('u'); //Request Update spiffs remotely
                    TxByte((unsigned char)((uiCMDLen&0xff00)>>8));
                    TxByte((unsigned char)(uiCMDLen&0xff));
                    TxByte((unsigned char)(uiPort&0xff));
                    TxByte((unsigned char)((uiPort&0xff00)>>8));
                    rx_data = 0;
                    do
                    {
                        tx_data = ucServer[rx_data];
                        TxByte(tx_data);
                        --uiCMDLen;
                        ++rx_data;
                    }
                    while((uiCMDLen)&&(tx_data!=0));
                    rx_data = 0;
                    do
                    {
                        tx_data = ucFile[rx_data];
                        if (tx_data==0)
                            break;
                        TxByte(tx_data);
                        --uiCMDLen;
                        ++rx_data;
                    }
                    while(uiCMDLen);

                    if (ucIsFw)
                        bResponse = WaitForRXData(responseOTAFW,2,18000,true,false,NULL,0);
                    else
                        bResponse = WaitForRXData(responseOTASPIFF,2,18000,true,false,NULL,0);

                    if (bResponse)
                    {
                        if ((!ucIsFw))
                            printf("\rSuccess updating certificates!\r\n");
                        else
                            printf("\rSuccess, firmware updated, wait a minute so it is fully flashed.\r\n");
                        FinishUpdate(true);
                        return 0;
                    }
                    else
                        printf("\rFailed to update from remote server...\r\n");
                }
            }
            else
                printf("ESP device not found...\r\n");

            // Restore slots as they were
            RestoreSlots();
        }
        else
            printf("MSX Pico Wi-Fi Not Detected\r\n\n");
        /*



        */
    }
    else
        printf(strUsage);

	return 0;
}
