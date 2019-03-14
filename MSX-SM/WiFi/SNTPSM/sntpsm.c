/*
--
-- sntpsm.c
--   Simple SNTP client using the WiFi module of your MSX-SM. 
--   Revision 0.20
--
-- Based on SNTP client for UNAPI By Konamiman /2010
-- konamiman@konamiman.com
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
#include "WiFiMSXSM.h"
#include "fusion-c/header/asm.h"

#define _SDATE 0x2B
#define _STIME 0x2D
#define SECS_IN_MINUTE ((unsigned long)(60))
#define SECS_IN_HOUR ((unsigned long)(SECS_IN_MINUTE * 60))
#define SECS_IN_DAY ((unsigned long)(SECS_IN_HOUR * 24))
#define SECS_IN_MONTH_28 ((unsigned long)(SECS_IN_DAY * 28))
#define SECS_IN_MONTH_29 ((unsigned long)(SECS_IN_DAY * 29))
#define SECS_IN_MONTH_30 ((unsigned long)(SECS_IN_DAY * 30))
#define SECS_IN_MONTH_31 ((unsigned long)(SECS_IN_DAY * 31))
#define SECS_IN_YEAR ((unsigned long)(SECS_IN_DAY * 365))
#define SECS_IN_LYEAR ((unsigned long)(SECS_IN_DAY * 366))
//Secs from 1900-1-1 to 2010-1-1
#define SECS_1900_TO_2010 ((unsigned long)(3471292800))
//Secs from 2036-1-1 0:00:00 to 2036-02-07 6:28:16
#define SECS_2036_TO_2036 ((unsigned long)(3220096))

unsigned long SecsPerMonth[12];
unsigned char * timeZoneString;
const char strUsage[] = "Usage: sntpsm <time zone> [/r] \n\n<time zone>: Formatted as [+|-]hh:mm where hh=00-12, mm=00-59\n    This value will be added or subtracted from the received time.\n[/r]: force AP listing and choosing (reconnect to different WiFi)\n";

const char strInvalidTimeZone[] = "Invalid time zone";	

Z80_registers regs;
	
int IsDigit(unsigned char theChar)
{
	return (theChar>='0' && theChar<='9');
}	
	
int IsValidTimeZone(unsigned char * timeZoneString)
{
	if(!(timeZoneString[0]=='+' || timeZoneString[0]=='-')) 
		return 0;
    
	if(!(IsDigit(timeZoneString[1]) && IsDigit(timeZoneString[2]) && IsDigit(timeZoneString[4]) && IsDigit(timeZoneString[5])))
		return 0;

    if(timeZoneString[3] != ':')
        return 0;
    
    return 1;
}	
	
void SecondsToDate(unsigned long seconds, int* year, unsigned char* month, unsigned char* day, unsigned char* hour, unsigned char* minute, unsigned char* second)
{
    int IsLeapYear = 0;
    unsigned long SecsInCurrentMoth;

    if((seconds & 0x80000000) == 0) {
        *year = 2036;
        seconds += SECS_2036_TO_2036;
    }
    else {
        *year = 2010;
        seconds -= SECS_1900_TO_2010;
    }

    //* Calculate year

    while(1) {
        IsLeapYear = ((*year & 3) == 0);
        if((!IsLeapYear && (seconds < SECS_IN_YEAR)) || (IsLeapYear && (seconds < SECS_IN_LYEAR))) {
            break;
        }
        seconds -= (IsLeapYear ? SECS_IN_LYEAR : SECS_IN_YEAR);
        *year = *year+1;
    }

    //* Calculate month

    *month = 1;

    while(1) {
        if(*month == 2 && IsLeapYear) {
            SecsInCurrentMoth = SECS_IN_MONTH_29;
        }
        else {
            SecsInCurrentMoth = SecsPerMonth[*month - 1];
        }

        if(seconds < SecsInCurrentMoth) {
            break;
        }

        seconds -= SecsInCurrentMoth;
        *month = (unsigned char)(*month + 1);
    }

    //* Calculate day

    *day = 1;

     while(seconds > SECS_IN_DAY) {
         seconds -= SECS_IN_DAY;
         *day = (unsigned char)(*day + 1);
     }

     //* Calculate hour

     *hour = 0;

     while(seconds > SECS_IN_HOUR) {
         seconds -= SECS_IN_HOUR;
         *hour = (unsigned char)(*hour + 1);
     }

     //* Calculate minute

     *minute = 0;

     while(seconds > SECS_IN_MINUTE) {
         seconds -= SECS_IN_MINUTE;
         *minute = (unsigned char)(*minute + 1);
     }

     //* The remaining are the seconds

     *second = (unsigned char)seconds;
}

int main(char** argv, int argc)
{
	char tx_data = 0;
	unsigned char ret;
	unsigned char stpdata[48];
	unsigned char input[48];
	unsigned int stpDataSize;
	unsigned int i;
	APList *myList = NULL;
	
	unsigned char NTPServer[]="pool.ntp.org";
	unsigned char NTPPort[]="123";
	
	long seconds;
	int year;
	unsigned char month, day, hour, minute, second;	
	unsigned int timeZoneSeconds;
	unsigned int timeZoneHours;
	unsigned int timeZoneMinutes;
	unsigned char reconnect = 0;
	unsigned int retry = 360;
	DATE stDate;
	TIME stTime;
	
	timeZoneString = NULL;
	
	Print("> MSX-SM ESP8266 WIFI Module SNTP Client v0.20 <\n(c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\n");	
	
	SecsPerMonth[0]=SECS_IN_MONTH_31;
    SecsPerMonth[1]=SECS_IN_MONTH_28;
    SecsPerMonth[2]=SECS_IN_MONTH_31;
    SecsPerMonth[3]=SECS_IN_MONTH_30;
    SecsPerMonth[4]=SECS_IN_MONTH_31;
    SecsPerMonth[5]=SECS_IN_MONTH_30;
    SecsPerMonth[6]=SECS_IN_MONTH_31;
    SecsPerMonth[7]=SECS_IN_MONTH_31;
    SecsPerMonth[8]=SECS_IN_MONTH_30;
    SecsPerMonth[9]=SECS_IN_MONTH_31;
    SecsPerMonth[10]=SECS_IN_MONTH_30;
    SecsPerMonth[11]=SECS_IN_MONTH_31;

	ClearUartData();	
	
	if (argc == 0)
	{
		Print(strUsage);
		return 0;
	}
	
	timeZoneString = argv[0];
    if(!IsValidTimeZone(timeZoneString)) 
	{
		Print(strInvalidTimeZone);
		return 0;
	}
	
	for (i=1;i<argc;i++)
	{
		if ((argv[i][0]=='/') && ( (argv[i][1]=='r') || (argv[i][1]=='R')) )
			reconnect = 1;
	}
	
	//* Parse time zone
    
	timeZoneHours = (((unsigned char)(timeZoneString[1])-'0')*10) + (unsigned char)(timeZoneString[2]-'0');
	if(timeZoneHours > 12)
	{
		Print("Can't use more than 12 hours to set time zone!\n");
		return 0;
	}
	
	timeZoneMinutes = (((unsigned char)(timeZoneString[4])-'0')*10) + (unsigned char)(timeZoneString[5]-'0');
	if(timeZoneMinutes > 59)
	{
		Print("Can't use more than 59 minutes to set time zone!\n");
		return 0;
	}
	
	timeZoneSeconds = ((timeZoneHours * (int)SECS_IN_HOUR)) + ((timeZoneMinutes * (int)SECS_IN_MINUTE));
	
	Print("> Initializing ESP (takes a few seconds)...\n");
	
	ret = InitializeWiFi(0);
	
	if ( ( ret == RET_WIFI_MSXSM_OK ) || ( ret == RET_WIFI_MSXSM_OK_DISCONNECTED ) )
	{
		if (( ret == RET_WIFI_MSXSM_OK_DISCONNECTED ) || (reconnect))
		{
			do
			{
				if ( ret == RET_WIFI_MSXSM_OK_DISCONNECTED )
				{
					Print("> Initialization OK, getting WiFi Access Points availables...\n");				
				}
				else if ( ret != RET_WIFI_MSXSM_OK )
				{
					printf("> Error %u connecting to AP.\r\n", ret);
				}
				//Up to 10 SSIDs is plenty, we do not have lots of memory, 8 bit constraints
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
		{
				Print("> Initialization OK!\n");	
		}
		
		printf ("Connecting to server: %s \r\n", NTPServer);
		ret = OpenConnection (CONNECTION_TYPE_UDP, NTPServer, NTPPort, '0');
		if ( ret == RET_WIFI_MSXSM_OK)
		{
			Print("Connected! Requesting time...\n");
			ClearUartData();
			memset (stpdata, 0, sizeof(stpdata));
			stpdata[0] = 0b11100011;
			stpdata[1] = 0;
			stpdata[2] = 6;
			stpdata[3] = 0xEC;
			ret = SendData (stpdata, 48, '0');
			if (ret == RET_WIFI_MSXSM_OK)
			{
				stpDataSize = 48;
				while(!UartRXData())
				{
					if (retry == 0)
					{
						Print("No response from server...\n");
						return 0;
					}
					Halt();
					retry--;					
				}
				ret = ReceiveData(stpdata, &stpDataSize, '0');
				if (ret == RET_WIFI_MSXSM_OK)
				{
					GetDate(&stDate);
					GetTime(&stTime);
					printf("Actual MSX Time:   %i-%i-%i, %i:%i:%i\r\n", stDate.year, stDate.month, stDate.day, stTime.hour, stTime.min, stTime.sec);
					
					if(stpdata[0] & 0xC0 == 0xC0 )
					{
						Print("WARNING: Error returned by server: clock is not synchronized\n");
						return 0;
					}
					((unsigned char*)&seconds)[0]=stpdata[43];
					((unsigned char*)&seconds)[1]=stpdata[42];
					((unsigned char*)&seconds)[2]=stpdata[41];
					((unsigned char*)&seconds)[3]=stpdata[40];
					
					if(timeZoneString[0] == '-')
						seconds -= timeZoneSeconds;
					else
						seconds += timeZoneSeconds;
					
					SecondsToDate(seconds, &year, &month, &day, &hour, &minute, &second);
					printf("Time from server:   %i-%i-%i, %i:%i:%i\r\nUpdating MSX time...\r\n", year, month, day, hour, minute, second);					
					
					regs.UWords.HL = year;
					regs.Bytes.D = month;
					regs.Bytes.E = day;
					DosCall(_SDATE, &regs, REGS_MAIN, REGS_AF);
					if(regs.Bytes.A != 0) {
							printf("MSX Clock didn't like: %i-%i-%i\r\n",year,month,day);
					}
					
					regs.Bytes.H = hour;
					regs.Bytes.L = minute;
					regs.Bytes.D = second;
					DosCall(_STIME, &regs, REGS_MAIN, REGS_AF);
					if(regs.Bytes.A != 0) {
							printf("MSX Clock didn't like: %i:%i:%i\r\n",hour,minute,second);
					}
				}
				else
				{
						printf ("Error %u receiving server response...\r\n", ret);
				}
			}
			else
			{
					printf ("Error %u sending request...\r\n", ret);
			}
			
			CloseConnection('0');
		}
		else
		{
				printf ("Error %u connecting to server: %s\r\n", ret, NTPServer);
		}
	}
	else
	{
			Print("> ESP Init error...\n");
	}

	return 0;
}