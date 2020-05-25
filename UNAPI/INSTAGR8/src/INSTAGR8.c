/*
--
-- instagr8.c
--   INSTAGR8, but for UNAPI, not only GR8NET
--   Revision 0.20
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2020 Oduvaldo Pavan Junior ( ducasp@gmail.com )
-- Totally based on the GR8 work of Thomas F. Glufke
-- https://github.com/glufke/instagr8
-- And totally dependent on his server being UP as well
--
-- What I means is: I've just converted his BASIC client that works only with
-- GR8NET on a MSX-DOS2 client that works with ANY UNAPI adapter
--
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
#include "INSTAGR8.h"

/*
 *
 * START OF CODE
 *
 */

void exitsetup()
{
    ShowDisplay();
    hgetfinish(); //makes sure pending connection / file is closed, if there is one
    Screen(0);
    SetColors(15,1,1);
    if (ReadMSXtype())
        Width(80);
    else
        Width(40);
}

unsigned char instagr8queryserver(unsigned char *ucServerString, unsigned int uiBufferSize)
{
    unsigned char ucRet = 0;
    int iRet;
    unsigned int uiSize = uiBufferSize;

    iRet = hget(uciGr8ServerQuery,NULL,NULL,0,ucServerString,&uiSize,0,0,false);
    if ((iRet == ERR_TCPIPUNAPI_OK)&&(uiSize))
    {
        ucRet = 1;
        ucServerString[uiSize-1]='\0'; //null terminate it, server ends the data with 0x0a, replace it with null
    }

    return ucRet;
}

void instagr8menu(unsigned char *ucUserInput, int iMaxLen)
{
    Screen(0);
    Width(40);
    SetColors(11,1,1);
    uiSessionIndex = 0;
    printf("MSX InstaGR8 - The Instagram for MSX");
    Locate(0,21);
    printf("By Thomas Glufke ( Twitter @plsql )");
    Locate(0,22);
    printf("UNAPI version: Ducasp ducasp@gmail.com");
    Locate(2,5);
    printf("www.instagram.com/");
    InputString(ucUserInput,iMaxLen);
    printf("Loading %s ...",ucUserInput);
}

unsigned char instagr8startsession(unsigned char *ucUserInput)
{
    unsigned char ucRet = 0;
    unsigned int uiRnd;

    if (strlen(ucUserInput))
    {
        ucRet = 1;
        srand(TickCount);
        uiRnd = rand()%10;
        ucInstaGR8Session[0] = '0' + uiRnd;
        uiRnd = rand()%10;
        ucInstaGR8Session[1] = '0' + uiRnd;
        uiRnd = rand()%10;
        ucInstaGR8Session[2] = '0' + uiRnd;
        uiRnd = rand()%10;
        ucInstaGR8Session[3] = '0' + uiRnd;
        uiRnd = rand()%10;
        ucInstaGR8Session[4] = '0' + uiRnd;
        ucInstaGR8Session[5] = '\0';
        strcpy(ucInstaGR8ServerRequest,ucInstaGR8Server);
        strcat(ucInstaGR8ServerRequest,"/instagr8/msxinsta.php?s=");
        strcat(ucInstaGR8ServerRequest,ucInstaGR8Session);
        if (ucUserInput[0]!='#')
        {
            strcat(ucInstaGR8ServerRequest,"&t=u&u=");
            strcat(ucInstaGR8ServerRequest,ucUserInput);
        }
        else
        {
            strcat(ucInstaGR8ServerRequest,"&t=t&u=");
            strcat(ucInstaGR8ServerRequest,&ucUserInput[1]);
        }
        if (ucIsMSX2)
            strcat(ucInstaGR8ServerRequest,"&v=2");
        else
            strcat(ucInstaGR8ServerRequest,"&v=1");
     }
     return ucRet;
}

void SC2RcvChrCallBack(char *rcv_buffer, int bytes_read)
{
    static unsigned int uiChrDestRamAddr;
    static unsigned char ucChrIgnoreChars;
    char *chChrBuff = rcv_buffer;
    unsigned int uiChrRead = bytes_read;

    if (ucIsFirstCall)
    {
        uiChrDestRamAddr = 0x0000;
        ucChrIgnoreChars = 7;
        ucIsFirstCall = false;
    }

    if (ucChrIgnoreChars)
    {
        while ((ucChrIgnoreChars)&&(uiChrRead))
        {
            ++chChrBuff;
            --uiChrRead;
            --ucChrIgnoreChars;
        }
    }

    if(uiChrRead)
    {
        CopyRamToVram((void *)chChrBuff, uiChrDestRamAddr, uiChrRead);
        uiChrDestRamAddr+=uiChrRead;
    }
}

void SC2RcvClrCallBack(char *rcv_buffer, int bytes_read)
{
    static unsigned int uiClrDestRamAddr;
    static unsigned char ucClrIgnoreChars;
    char *chClrBuff = rcv_buffer;
    unsigned int uiClrRead = bytes_read;

    if (ucIsFirstCall)
    {
        uiClrDestRamAddr = 0x2000;
        ucClrIgnoreChars = 7;
        ucIsFirstCall = false;
    }

    if (ucClrIgnoreChars)
    {
        while ((ucClrIgnoreChars)&&(uiClrRead))
        {
            ++chClrBuff;
            --uiClrRead;
            --ucClrIgnoreChars;
        }
    }

    if(uiClrRead)
    {
        CopyRamToVram((void *)chClrBuff, uiClrDestRamAddr, uiClrRead);
        uiClrDestRamAddr+=uiClrRead;
    }
}

int main(char** argv, int argc)
{
	char ucKeybData = 27; //where our key inputs go
	unsigned int uiGetSize = 0;
	unsigned char ucTmp[10];
	unsigned char uc0,ucLimit,ucP0,ucPLen,ucLineCount;
	int iRet;

    if(ReadMSXtype()==0) //>MSX-1?
        ucIsMSX2=0;
    else
        ucIsMSX2=1;

	printf("InstaGR8 for UNAPI v0.10\r\nOduvaldo Pavan Junior/ducasp@gmail.com\r\n\r\n");
	printf("Inquiring InstaGR8 server...\r\n");

	// Allocate memory for HGET on page 2 so it won't conflict with memory page swapping
    if (hgetinit(HI_MEMBLOCK_START) != ERR_TCPIPUNAPI_OK)
    {
        printf ("Sorry, INSTAGR8 requires an working TCP-IP UNAPI interface...\r\n");
        return 0;
    }
    else
        printf ("HGET init: OK!\r\n");

    if(!instagr8queryserver(ucInstaGR8UserInput,sizeof(ucInstaGR8UserInput)))
    {
        printf ("Sorry, INSTAGR8 couldn't retrieve server address...\r\n");
        exitsetup();
        return 0;
    }

    strcpy(ucInstaGR8Server,"http://");
    strcat(ucInstaGR8Server,ucInstaGR8UserInput);
    printf ("Server: %s\r\n",ucInstaGR8Server);

	do
    {
        if (ucKeybData == 27)
        {
            instagr8menu(ucInstaGR8UserInput,sizeof(ucInstaGR8UserInput));
            if(!instagr8startsession(ucInstaGR8UserInput))
            {
                exitsetup();
                return 0;
            }
        }
        else if ((ucKeybData == '1') && (ucIsMSX2))
        {
            --uiSessionIndex;
            ucIsMSX2 = 0;
            if(!instagr8startsession(ucInstaGR8UserInput))
            {
                exitsetup();
                return 0;
            }
        }
        else if ((ucKeybData == '2') && (!ucIsMSX2) && (ReadMSXtype()))
        {
            --uiSessionIndex;
            ucIsMSX2 = 1;
            if(!instagr8startsession(ucInstaGR8UserInput))
            {
                exitsetup();
                return 0;
            }
        }

        ++uiSessionIndex;
        sprintf(ucTmp,"&n=%u",uiSessionIndex);
        strcpy(ucInstaGR8HttpRequest,ucInstaGR8ServerRequest);
        strcat(ucInstaGR8HttpRequest,ucTmp);
        //printf("\r\n%s",ucInstaGR8HttpRequest);

        uiGetSize = sizeof(ucInstaGR8Description);
        iRet = hget(ucInstaGR8HttpRequest,NULL,NULL,0,ucInstaGR8Description,&uiGetSize,0,0,true);
        if ((iRet != ERR_TCPIPUNAPI_OK)||(!uiGetSize))
        {
            exitsetup();
            return 0;
        }

        strcpy(ucInstaGR8HttpRequest,ucInstaGR8Server);
        strcat(ucInstaGR8HttpRequest,"/instagr8/img/out");
        strcat(ucInstaGR8HttpRequest,ucInstaGR8Session);
        strcat(ucInstaGR8HttpRequest,".CHR");
        if (!ucIsMSX2)
        {
            Screen(2);
            SetColors(1,15,15);
        }
        else
        {
            Screen(8);
            SetColors(1,255,255);
        }

        ucIsFirstCall = true;
        if(hget(ucInstaGR8HttpRequest,NULL,NULL,0,NULL,NULL,(int)SC2RcvChrCallBack,0,true)!=ERR_TCPIPUNAPI_OK)
        {
            exitsetup();
            return 0;
        }

        if (!ucIsMSX2)
        {
            strcpy(ucInstaGR8HttpRequest,ucInstaGR8Server);
            strcat(ucInstaGR8HttpRequest,"/instagr8/img/out");
            strcat(ucInstaGR8HttpRequest,ucInstaGR8Session);
            strcat(ucInstaGR8HttpRequest,".CLR");
            ucIsFirstCall = true;
            if(hget(ucInstaGR8HttpRequest,NULL,NULL,0,NULL,NULL,(int)SC2RcvClrCallBack,0,false)!=ERR_TCPIPUNAPI_OK)
            {
                exitsetup();
                return 0;
            }

            for (uc0=0, ucLimit=strlen(ucInstaGR8Description),ucP0=30,ucLineCount=0;(uc0<ucLimit)&&(ucLineCount<16);++ucLineCount)
            {
                ucPLen = strlen(&ucInstaGR8Description[uc0]);
                if (ucPLen > 8)
                    ucPLen = 8;
                memcpy(ucTmp,&ucInstaGR8Description[uc0],ucPLen);
                ucTmp[ucPLen]='\0';
                PutText(0,ucP0,ucTmp,0);
                ucP0+=8;
                uc0+=ucPLen;
            }
        }
        else
        {
            for (uc0=0, ucLimit=strlen(ucInstaGR8Description),ucP0=25,ucLineCount=0;(uc0<ucLimit)&&(ucLineCount<20);++ucLineCount)
            {
                ucPLen = strlen(&ucInstaGR8Description[uc0]);
                if (ucPLen > 5)
                    ucPLen = 5;
                memcpy(ucTmp,&ucInstaGR8Description[uc0],ucPLen);
                ucTmp[ucPLen]='\0';
                PutText(0,ucP0,ucTmp,0);
                ucP0+=8;
                uc0+=ucPLen;
            }
        }

        do
        {
            ucKeybData = Inkey ();
        }
        while (!ucKeybData);
    }
    while ((ucKeybData==27)||(ucKeybData==28)||(ucKeybData=='2')||(ucKeybData=='1'));

    exitsetup();
	return 0;
}
