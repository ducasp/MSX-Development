/*
--
-- WiFiMSXSM.c
--   Functions that allow your program to access the WiFi module
--   of your MSX-SM.
--   Revision 0.50
--
-- Requires SDCC and Fusion-C library to compile
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
#include <string.h>
#include <stdlib.h>
#include "fusion-c/header/msx_fusion.h"
#include "WiFiMSXSM.h"

//List of ESP8266 commands we use
const char resetESP[] = "AT+RST\r\n";
const char RSPresetESP[] = "ready\r\n";
const char echoOffESP[] = "ATE0\r\n";
//SET AP + STATION, allow to work multiple connections
const char setESPMode[] = "AT+CWMODE_CUR=3\r\n";
const char setMultipleConn[] = "AT+CIPMUX=1\r\n";
const char setSingleConn[] = "AT+CIPMUX=0\r\n";
const char setTranspConn[] = "AT+CIPMODE=1\r\n";
const char escapeTranspConn[] = "+++";
const char setRegularConn[] = "AT+CIPMODE=0\r\n";
const char setPassive[] = "AT+CIPRECVMODE=1\r\n";
const char resetPassive[] = "AT+CIPRECVMODE=0\r\n";
const char getPassive[] = "AT+CIPRECVDATA=";
const char getConnSts[] = "AT+CIPSTATUS\r\n";
const char setAPListMode[] = "AT+CWLAPOPT=1,3\r\n";
const char setUART2400[] = "AT+UART_DEF=2400,8,1,0,0\r\n";
const char setUART4800[] = "AT+UART_DEF=4800,8,1,0,0\r\n";
const char setUART9600[] = "AT+UART_DEF=9600,8,1,0,0\r\n";
const char setUART19200[] = "AT+UART_DEF=19200,8,1,0,0\r\n";
const char setUART31250[] = "AT+UART_DEF=31250,8,1,0,0\r\n";
const char setUART38400[] = "AT+UART_DEF=38400,8,1,0,0\r\n";
const char setUART57600[] = "AT+UART_DEF=57600,8,1,0,0\r\n";
const char setUART115200[] = "AT+UART_DEF=115200,8,1,0,0\r\n";
const char getAPList[] = "AT+CWLAP\r\n";
const char joinAPheader[] = "AT+CWJAP_DEF=\"";
const char noSleep[] = "AT+SLEEP=0\r\n";
const char startConn[] = "AT+CIPSTART=0,";
const char startSingleConn[] = "AT+CIPSTART=";
const char sendData[] = "AT+CIPSEND=0,";
const char startTransparent[] = "AT+CIPSEND\r\n";
const char ConnTCP[] = "\"TCP\",";
const char ConnUDP[] = "\"UDP\",";
const char ConnSSL[] = "\"SSL\",";
const char endConn[] = "AT+CIPCLOSE=0\r\n";
const char endSingleConn[] = "AT+CIPCLOSE\r\n";
const char ESPTerminator[] = "\r\n";

//Possible responses
const char RSPOkESP[] = "OK\r\n";
const char RSPErrorESP[] = "ERROR\r\n";
const char RSPFailESP[] = "FAIL\r\n";
const char RSPFailDNSESP[] = "DNS Fail\r\n";
const char RSPAlreadyConn[] = "ALREADY CONNECTED\r\n";
const char RSPPromptESP[] = ">";
const char RSPgetPassive[] = ",";

//Possible unsolicited messages
const char wifiDisconn[] = "WIFI DISCONNECTED\r\n";
const char wifiConnected[] = "WIFI CONNECTED\r\n";
const char wifiGotIp[] = "WIFI GOT IP\r\n";
const char closed0[] = "0,CLOSED\r\n";
const char closed1[] = "1,CLOSED\r\n";
const char closed2[] = "2,CLOSED\r\n";
const char closed3[] = "3,CLOSED\r\n";
const char closed4[] = "4,CLOSED\r\n";
const char rcvd0[] = "+IPD,0,";
const char rcvd1[] = "+IPD,1,";
const char rcvd2[] = "+IPD,2,";
const char rcvd3[] = "+IPD,3,";
const char rcvd4[] = "+IPD,4,";

//Global Flags
unsigned char isInitialized = 0;
unsigned char isSingleConnection = 0;

//Global Arrays (no need to declare multiple times, single instance and low memory)
unsigned char cmd[200];
unsigned char rsp[200];
unsigned int rspsize = sizeof(rsp);

//I/O made simple...
__sfr __at 0x06 myPort6; //reading this is same as IN and writing same as out, without extra instructions
                         //when using Inport and Outport from Fusion-C
__sfr __at 0x07 myPort7; //reading this is same as IN and writing same as out, without extra instructions
                         //when using Inport and Outport from Fusion-C

__at 0xFC9E unsigned int TickCount;

unsigned char TxByte(char chTxByte)
{
	unsigned char ret = RET_WIFI_MSXSM_TX_TIMEOUT;
	unsigned char UartStatus;
	unsigned char Leaping;
	unsigned int Retries;

	Retries = TickCount + 3; //Wait up to 3 Interrupts
	if (Retries<TickCount) //Leaping?
		Leaping = 1;
	else
		Leaping = 0;

	do
	{
		UartStatus = myPort7&2 ;
		if (UartStatus)
		{
			if (Leaping)
			{
				if (TickCount<10)
				{
					Leaping = 0;
					if (TickCount>Retries)
						break;
				}
				else
					if (TickCount>Retries)
						break;
			}
			else
				if (TickCount>Retries)
					break;
		}
		else
		{
			myPort7 = chTxByte;
			ret = RET_WIFI_MSXSM_OK;
			break;
		}
	}
	while (1);

#ifdef log_verbose
	if (UartStatus)
		Print("> UART Status- TX Stuck after 3 interrupts...\n");
#endif

	return ret;
}

void ClearUartData(void )
{
	myPort6 = 20;
}

unsigned char UartTXInprogress(void )
{
	if (myPort7 & 2)
		return 1;
	else
		return 0;
}

unsigned char UartRXData(void )
{
	if (myPort7 & 1)
		return 1;
	else
		return 0;
}

unsigned char GetUARTData (void)
{
	return myPort6;
}

unsigned char TxData(char * chData, unsigned char Size)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;

	unsigned char i;

	if(Size==0)
	{
		for (i = 0; (chData[i]!=0 && ret == RET_WIFI_MSXSM_OK); i++)
			ret	= TxByte(chData[i]);
	}
	else
	{
		for (i = 0; ( i < Size && ret == RET_WIFI_MSXSM_OK); i++)
			ret	= TxByte(chData[i]);
	}


	return ret;
}

unsigned char WaitResponse (char *chResponse, unsigned char ResponseSize, unsigned char TimeOut)
{
	unsigned char ret = RET_WIFI_MSXSM_RX_TIMEOUT;
	unsigned char CompareIndex = 0;
	unsigned char Tmp;
	unsigned char Leaping;
	unsigned int Timer;

	Timer = (60 * TimeOut) + TickCount;

	if (Timer<TickCount) //Leaping?
		Leaping = 1;
	else
		Leaping = 0;

	do
	{
		if (UartRXData())
		{
			Tmp = GetUARTData();
			if( Tmp == chResponse[CompareIndex] )
			{
				++CompareIndex;
				if (CompareIndex == ResponseSize)
				{
					ret = RET_WIFI_MSXSM_OK;
					break;
				}
			}
			else
			{
				CompareIndex = 0;
			}
		}
		else
		{
			if (Leaping)
			{
				if (TickCount<10)
				{
					Leaping = 0;
					if (TickCount>Timer)
						break;
				}
				else
					if (TickCount>Timer)
						break;
			}
			else
				if (TickCount>Timer)
						break;
		}
	}
	while (1); //don't worry, will break per time-out  or response received

	return ret;
}

unsigned char GetResponse (char *chResponse, unsigned int * ResponseSize, unsigned char TimeOut)
{
	unsigned char ret = RET_WIFI_MSXSM_RX_TIMEOUT;
	unsigned int MaxSize = *ResponseSize;
	unsigned char Tmp;
	unsigned char State=0;
	unsigned char StateCounter=0;
	unsigned char Leaping;
	unsigned int Timer;

	Timer = (60 * TimeOut) + TickCount;

	if (Timer<TickCount) //Leaping?
		Leaping = 1;
	else
		Leaping = 0;

	*ResponseSize = 0;

	do
	{
		if (UartRXData())
		{
			Tmp = GetUARTData();
			chResponse[*ResponseSize] = Tmp;
			*ResponseSize = *ResponseSize + 1;
			switch (State)
			{
				case 0: //did not find ok or error characters
					if( Tmp == RSPOkESP[0] )
					{
						State =1;
						StateCounter = 1;
					}
					else if ( Tmp == RSPErrorESP[0] )
					{
						State =2;
						StateCounter = 1;
					}
					else if ( Tmp == RSPFailESP[0] )
					{
						State =3;
						StateCounter = 1;
					}
					else if ( Tmp == RSPFailDNSESP[0] )
					{
						State =4;
						StateCounter = 1;
					}
					else if ( Tmp == RSPAlreadyConn[0] )
					{
						State =5;
						StateCounter = 1;
					}
				break;

				case 1:
					if( Tmp == RSPOkESP[StateCounter] )
					{
						State =255;
						StateCounter = 0;
					}
					else
						State = 0;
				break;

				case 2:
					if( Tmp == RSPErrorESP[StateCounter] )
					{
						if (StateCounter == sizeof(RSPErrorESP) - 2)
							State =254;
						else
							++StateCounter;
					}
					else
						State = 0;
				break;

				case 3:
					if( Tmp == RSPFailESP[StateCounter] )
					{
						if (StateCounter == sizeof(RSPFailESP) - 2)
							State =253;
						else
							++StateCounter;
					}
					else
						State = 0;
				break;

				case 4:
					if( Tmp == RSPFailDNSESP[StateCounter] )
					{
						if (StateCounter == sizeof(RSPFailDNSESP) - 2)
							State =252;
						else
							++StateCounter;
					}
					else
						State = 0;
				break;

				case 5:
					if( Tmp == RSPAlreadyConn[StateCounter] )
					{
						if (StateCounter == sizeof(RSPAlreadyConn) - 2)
							State =251;
						else
							++StateCounter;
					}
					else
						State = 0;
				break;

				default:
					State = 0;
				break;
			}

			if (*ResponseSize == MaxSize)
			{
				ret = RET_WIFI_MSXSM_RX_OVERFLOW;
				break;
			}

			if (State == 255) // found Ok
			{
				ret = RET_WIFI_MSXSM_OK;
				break;
			} else if (State == 254) //found Error
			{
				ret = RET_WIFI_MSXSM_CMD_ERROR;
				break;
			} else if (State == 253) //found Failure
			{
				ret = RET_WIFI_MSXSM_CMD_FAIL;
				break;
			} else if (State == 252) //found Failure DNS
			{
				ret = RET_WIFI_MSXSM_DNS_FAILURE;
				break;
			} else if (State == 251) //found Already Connected
			{
				ret = RET_WIFI_MSXSM_ALREADY_CONN;
				break;
			}
		}
		else
		{
			if (Leaping)
			{
				if (TickCount<10)
				{
					Leaping = 0;
					if (TickCount>Timer)
						break;
				}
				else
					if (TickCount>Timer)
						break;
			}
			else
				if (TickCount>Timer)
						break;
		}
	}
	while (1);

	return ret;
}

unsigned char SendCommand (char *chCmd, unsigned int Size, char *chExpectedResponse, unsigned char ExpectedResponseSize, unsigned char TimeOut)
{
	unsigned char ret;

	ret = TxData(chCmd, Size);

	if ( (ret == RET_WIFI_MSXSM_OK) && (chExpectedResponse) && (ExpectedResponseSize) )
		ret = WaitResponse( chExpectedResponse, ExpectedResponseSize, TimeOut);

	return ret;
}

unsigned char SendCommand2 (char *chCmd, char *chResponse, unsigned int * MaxResponseSize, unsigned char TimeOut)
{
	unsigned char ret;
	ret = TxData(chCmd, 0);

	if ( (ret == RET_WIFI_MSXSM_OK) && (chResponse) && (MaxResponseSize) && (*MaxResponseSize>0) )
		ret = GetResponse( chResponse, MaxResponseSize, TimeOut);

	return ret;
}

unsigned char FindBaudRateWiFi (void)
{
	unsigned char ret = 0xff;
	unsigned char ret2;
	unsigned char speed = 0;

	do
	{
		//Set Speed
		myPort6 = speed;
		Halt();
		ClearUartData();

		ret2 = SendCommand( echoOffESP, 0, RSPOkESP, sizeof(RSPOkESP)-1, 1);
		if (ret2 == RET_WIFI_MSXSM_OK)
		{
			ret = speed;
			break;
		}
		else
			++speed;
	}
	while (speed < 8);

	return ret;
}

unsigned char SetBaudRateWiFi (unsigned char speed)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;

	switch (speed)
	{
		case BAUD115200:
			ret = SendCommand( setUART115200, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
		break;

		case BAUD57600:
			ret = SendCommand( setUART57600, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
		break;

		case BAUD38400:
			ret = SendCommand( setUART38400, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
		break;

		case BAUD31250:
			ret = SendCommand( setUART31250, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
		break;

		case BAUD19200:
			ret = SendCommand( setUART19200, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
		break;

		case BAUD9600:
			ret = SendCommand( setUART9600, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
		break;

		case BAUD4800:
			ret = SendCommand( setUART4800, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
		break;

		case BAUD2400:
			ret = SendCommand( setUART2400, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
		break;

		default:
			return ret;
		break;
	}

	Halt();
	Halt();
	//Set Speed
	myPort6 = speed;
	Halt();
	ClearUartData();

	return ret;
}

unsigned char InitializeWiFi (unsigned char speed)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;
	unsigned char *charseek = NULL;

	//First, scan all possible baud rates to check if device is here
	speed = FindBaudRateWiFi();
	//Now we have the current speed, just set the one we want and go
	ret = SetBaudRateWiFi(speed);
	if (ret != RET_WIFI_MSXSM_OK)
	{
#ifdef log_verbose
		printf ("Error setting baud\r\n");
#endif
		//If this fails, more likely means ESP not present
		return RET_WIFI_MSXSM_NOT_INITIALIZED;
	}

	rspsize = sizeof(rsp);
	rsp[sizeof(rsp)-1]=0;
	// First, reset ESP to start from scratch
	ret = SendCommand( resetESP, 0, RSPresetESP, sizeof(RSPresetESP)-1, 10);
	if (ret == RET_WIFI_MSXSM_OK)
	{
		//Wait up to 10s to give time to ESP to connect to known network
		ret = WaitResponse(wifiGotIp,sizeof(wifiGotIp)-1,10);
		ClearUartData();

		//Turn ECHO off
		ret = SendCommand( echoOffESP, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
		if (ret == RET_WIFI_MSXSM_OK)
		{
			//Set mode
			ret = SendCommand( setESPMode, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
			if (ret == RET_WIFI_MSXSM_OK)
			{
				//Turn off sleeping, we don't use batteries, so let's go for
				//better performance
				ret = SendCommand( noSleep, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
				if (ret == RET_WIFI_MSXSM_OK)
				{
					//Now, guarantee that we just get the data we need when listing APs
					ret = SendCommand( setAPListMode, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
					if (ret == RET_WIFI_MSXSM_OK)
					{
						ClearUartData();
						//Check if it is already connected
						ret = SendCommand2( getConnSts, rsp, &rspsize, 2);
						if (ret == RET_WIFI_MSXSM_OK)
						{
							// All commands ok, so init succes!
							isInitialized = 1;
							if (rspsize)
							{
								rsp[rspsize]=0;
								charseek = strstr (rsp,"S:");
								if (charseek)
								{
									if(charseek[2]!='2') //connected
									{
										ret = RET_WIFI_MSXSM_OK_DISCONNECTED;
										rspsize = sizeof(rsp);
									}
									else
									{
										//Just set multiple connections at start
										ret = SendCommand2( setMultipleConn, rsp, &rspsize, 2);
										if (ret == RET_WIFI_MSXSM_OK)
										{
											isSingleConnection = 0;
										}
									}
								}
								else
									ret = RET_WIFI_MSXSM_OK_DISCONNECTED;
							}

						}
					}
				}
			}
		}
	}

	return ret;
}

unsigned char GetWiFiAPList (APList * stList)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;
	unsigned char MaxAPs;
	unsigned char chAPList [1200];
	unsigned char *charseek = NULL;
	unsigned char *charseek2 = NULL;
	unsigned int APListBufferSize,APListBufferSize2;

	if (isInitialized)
	{
		if ((stList) && (stList->numOfElements<11) && (stList->numOfElements>0))
		{
			MaxAPs  = stList->numOfElements;
			ClearUartData();
			APListBufferSize =  sizeof(chAPList);
			APListBufferSize2 = APListBufferSize;

			ret = SendCommand2( getAPList, chAPList, &APListBufferSize, 20);
			if ( ( ret == RET_WIFI_MSXSM_OK ) && (APListBufferSize) )
			{
				chAPList[APListBufferSize2-1]=0; //guarantee strstr won't go beyond our memory
				chAPList[APListBufferSize]=0; //guarantee strstr won't go beyond our memory
				stList->numOfElements = 0;
				charseek = chAPList;

				while ( (stList->numOfElements < MaxAPs) && (charseek < (chAPList + APListBufferSize) ) )
				{
					charseek = strstr (charseek,"+CWLAP:(");
					if (charseek)
					{
						charseek+=8; //jump token and go to enc
						if (charseek[0]=='0')
							stList->APst[stList->numOfElements].isEncrypted = 0;
						else
							stList->APst[stList->numOfElements].isEncrypted = 1;

						charseek+=3; //jump " and go to start of SSID name
						charseek2 = strstr (charseek,"\"");
						if (charseek2)
						{
							memcpy(stList->APst[stList->numOfElements].APName, charseek, (charseek2 - charseek));
							stList->APst[stList->numOfElements].APName[charseek2 - charseek]=0;
							++stList->numOfElements;
						}
						else
							break;
					}
					else
						break;
				}
			}
			free(chAPList);
		}
		else
			ret = RET_WIFI_MSXSM_INVALIDPARAMETER;
	}
	else
		ret = RET_WIFI_MSXSM_NOT_INITIALIZED;

	return ret;
}

unsigned char JoinWiFiAP (AP * stAP, unsigned char * Password)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;

	if (isInitialized)
	{
		if ( ((stAP->isEncrypted) && (Password )) || (stAP->isEncrypted == 0) )
		{
#ifdef log_verbose
			printf ("\nConnecting to [%s]\r\n",stAP->APName );
#endif
			cmd[sizeof(cmd)-1] = 0;
			rsp[sizeof(rsp)-1] = 0;
			rspsize = sizeof(rsp);
			strcpy (cmd, joinAPheader);
			strcat (cmd, stAP->APName);

			if (stAP->isEncrypted)
			{
				strcat (cmd, "\",\"");
				strcat (cmd, Password);
				strcat (cmd, "\"\r\n");
			}
			else
				strcat (cmd, "\",\"\"\r\n");

			ret = SendCommand2( cmd, rsp, &rspsize, 30);
			if ( ret == RET_WIFI_MSXSM_OK )
			{
				rspsize = sizeof(rsp);
				ret = SendCommand2( setMultipleConn, rsp, &rspsize, 2);
			}
		}
		else
			ret = RET_WIFI_MSXSM_INVALIDPARAMETER;
	}
	else
		ret = RET_WIFI_MSXSM_NOT_INITIALIZED;

	return ret;
}

#ifndef USE_WIFI_SINGLE_CONNECTION_ONLY
unsigned char OpenConnection (unsigned char Conn_type, unsigned char * Address, unsigned char * Port, unsigned char Number)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;

	if ((isInitialized)&&(isSingleConnection==0))
	{
		if ( (Address) && (Conn_type <= CONNECTION_TYPE_SSL ) && ((Number >= '0') && (Number < '5')) )
		{
			cmd[sizeof(cmd)-1] = 0;
			rsp[sizeof(rsp)-1] = 0;
			rspsize = sizeof(rsp);
			strcpy (cmd, startConn);
			cmd[sizeof(startConn)-3] = Number;

			switch (Conn_type)
			{
				case CONNECTION_TYPE_TCP:
					strcat (cmd, ConnTCP);
				break;

				case CONNECTION_TYPE_UDP:
					strcat (cmd, ConnUDP);
				break;

				case CONNECTION_TYPE_SSL:
					strcat (cmd, ConnSSL);
				break;
			}
			strcat (cmd,"\"");
			strcat (cmd,Address);
			strcat (cmd,"\",");
			strcat (cmd,Port);
			strcat (cmd,ESPTerminator);
			ret = SendCommand2( cmd, rsp, &rspsize, 30);
		}
		else
			ret = RET_WIFI_MSXSM_INVALIDPARAMETER;
	}
	else
	{
		if (!isInitialized)
			ret = RET_WIFI_MSXSM_NOT_INITIALIZED;
		else
			ret = RET_WIFI_MSXSM_WRONG_MODE;
	}

	return ret;
}

unsigned char CloseConnection (unsigned char Number)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;

	if ((isInitialized)&&(isSingleConnection==0))
	{
		if ( ( Number >= '0') && (Number < '5') )
		{
			cmd[sizeof(cmd)-1] = 0;
			rsp[sizeof(rsp)-1] = 0;
			rspsize = sizeof(rsp);
			strcpy (cmd, endConn);
			cmd[12] = Number;

			ret = SendCommand2( cmd, rsp, &rspsize, 30);
		}
		else
			ret = RET_WIFI_MSXSM_INVALIDPARAMETER;
	}
	else
	{
		if (!isInitialized)
			ret = RET_WIFI_MSXSM_NOT_INITIALIZED;
		else
			ret = RET_WIFI_MSXSM_WRONG_MODE;
	}

	return ret;
}

unsigned char SendData (unsigned char * Data, unsigned int DataSize, unsigned char Number)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;
	unsigned char Size[6];
	unsigned int i = 0;

	if ((isInitialized)&&(isSingleConnection==0))
	{
		if ( ( Number >= '0') && (Number < '5') )
		{
			cmd[sizeof(cmd)-1] = 0;
			rsp[sizeof(rsp)-1] = 0;
			rspsize = sizeof(rsp);
			strcpy (cmd, sendData);
			cmd[sizeof(sendData)-3] = Number;
			sprintf(Size,"%u",DataSize);
			strcat (cmd,Size);
			strcat (cmd,ESPTerminator);
			//First send the command, and wait the prompt indicating device is
			//listening to receive the data
			ret = SendCommand( cmd, 0, RSPPromptESP, sizeof(RSPPromptESP)-1, 10);
			if (ret == RET_WIFI_MSXSM_OK)
			{
				//Now send the data and then wait for the OK
				ret = SendCommand( Data, DataSize, RSPOkESP, sizeof(RSPOkESP) -1, 10);
			}
		}
		else
			ret = RET_WIFI_MSXSM_INVALIDPARAMETER;
	}
	else
	{
		if(!isInitialized)
			ret = RET_WIFI_MSXSM_NOT_INITIALIZED;
		else
			ret = RET_WIFI_MSXSM_WRONG_MODE;
	}

	return ret;
}

unsigned char ReceiveData (unsigned char * Data, unsigned int * DataSize, unsigned char Number)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;
	unsigned int BufSize = *DataSize;
	unsigned char RcvSize[6];
	unsigned char RcvSizeBytes=0;
	unsigned int BytesToGet;
	unsigned int i;
	unsigned char Leaping;
	unsigned int Timer;

	Timer = 120 + TickCount;

	if (Timer<TickCount) //Leaping?
		Leaping = 1;
	else
		Leaping = 0;

    *DataSize = 0;

	if ((isInitialized)&&(isSingleConnection==0))
	{
		if ( ( Number >= '0') && (Number < '5') )
		{
			//First, we wait up to 1s (as the function do not allow less) for +IPD
			switch (Number)
			{
				case '0':
					ret = WaitResponse(rcvd0,sizeof(rcvd0)-1,1);
				break;

				case '1':
					ret = WaitResponse(rcvd1,sizeof(rcvd1)-1,1);
				break;

				case '2':
					ret = WaitResponse(rcvd2,sizeof(rcvd2)-1,1);
				break;

				case '3':
					ret = WaitResponse(rcvd3,sizeof(rcvd3)-1,1);
				break;

				case '4':
					ret = WaitResponse(rcvd4,sizeof(rcvd4)-1,1);
				break;
			}

			//Found +IPD?
			if (ret == RET_WIFI_MSXSM_OK)
			{
				do
				{
					//Now work to get rid of the extra chars and then get the data size
					if (UartRXData())
					{
						RcvSize[RcvSizeBytes] = GetUARTData();

						if( ( RcvSize[RcvSizeBytes] == ':' ) || ( RcvSize[RcvSizeBytes] == '\n' ) )
						{
							if (RcvSizeBytes == 0) //no size byte received yet?
								ret = RET_WIFI_MSXSM_RX_TIMEOUT;
							break;
						}
						else if ( (RcvSize[RcvSizeBytes] >= '0')&&(RcvSize[RcvSizeBytes] <= '9') )
						{
							if (RcvSizeBytes<5)
								++RcvSizeBytes;
							else
							{
								ret = RET_WIFI_MSXSM_RX_OVERFLOW;
								break;
							}
						}
						else if ( RcvSize[RcvSizeBytes] != '\r' )
						{
							ret = RET_WIFI_MSXSM_RX_TIMEOUT;
							break;
						}
					}
					else
					{
						if (Leaping)
						{
							if (TickCount<10)
							{
								Leaping = 0;
								if (TickCount>Timer)
									break;
							}
							else
								if (TickCount>Timer)
									break;
						}
						else
							if (TickCount>Timer)
									break;
					}
				}
				while (1);

				BytesToGet = 0;

				if ((ret == RET_WIFI_MSXSM_OK) && (RcvSizeBytes))
				{
					// Ok, no error so far and we have data to receive

					//Perhaps atoi is faster? Who knows... Just avoiding stacking and CALLs and RETs :-)
					for (i=0; i<RcvSizeBytes;i++)
					{
						if(i==0)
							BytesToGet = (unsigned int)(RcvSize[RcvSizeBytes-1] - '0');
						else if(i==1)
							BytesToGet = BytesToGet + (unsigned int)(RcvSize[RcvSizeBytes-2] - '0')*10;
						else if(i==2)
							BytesToGet = BytesToGet + (unsigned int)(RcvSize[RcvSizeBytes-3] - '0')*100;
						else if(i==3)
							BytesToGet = BytesToGet + (unsigned int)(RcvSize[RcvSizeBytes-4] - '0')*1000;
						else if(i==4)
							BytesToGet = BytesToGet + (unsigned int)(RcvSize[RcvSizeBytes-5] - '0')*10000;
					}

					//Do we have enough space to store our data?
					//If we don't, that is a big issue... Tokens were already stripped and data won't be
					//understood afterwards...
					//
					//Perhaps a future improvement is to copy whatever we can and then return
					//Anyway, application should handle this OVERFLOW and get the data on their own
					if(BytesToGet <= BufSize )
					{
						*DataSize = 0;
						//At 2400 BPS, it would take about 7s to empty our FIFO
						//So 10s (60Hz) or 12s (50Hz) is more than enough time-out
						Timer = 600 + TickCount;
						if (Timer<TickCount) //Leaping?
							Leaping = 1;
						else
							Leaping = 0;

						do
						{
							if (UartRXData())
							{
								Data[*DataSize] = GetUARTData();
								++*DataSize;
								--BytesToGet;
							}
							else
							{
								if (Leaping)
								{
									if (TickCount<10)
									{
										Leaping = 0;
										if (TickCount>Timer)
											break;
									}
									else
										if (TickCount>Timer)
											break;
								}
								else
									if (TickCount>Timer)
											break;
							}
						}
						while ((BytesToGet));

						if (BytesToGet) // we could not get all bytes, timer expired
							ret = RET_WIFI_MSXSM_RX_TIMEOUT;
					}
					else
					{
						ret = RET_WIFI_MSXSM_RX_OVERFLOW;
						*DataSize = BytesToGet; //just in case app want to get on their own
					}
				}
			}
			else //ok, token not found, try later
				ret = RET_WIFI_MSXSM_RX_TIMEOUT;
		}
		else
			ret = RET_WIFI_MSXSM_INVALIDPARAMETER;
	}
	else
	{
		if (!isInitialized)
			ret = RET_WIFI_MSXSM_NOT_INITIALIZED;
		else
			ret = RET_WIFI_MSXSM_WRONG_MODE;
	}

	return ret;
}
#endif

#ifndef USE_WIFI_MULTIPLE_CONNECTION_ONLY
unsigned char OpenSingleConnection (unsigned char Conn_type, unsigned char * Address, unsigned char * Port)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;

	if (isInitialized)
	{
		if ( (Address) && (Conn_type <= CONNECTION_TYPE_SSL ) )
		{
			//First, set single connection
			ret = SendCommand( setSingleConn, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
			if (ret == RET_WIFI_MSXSM_OK)
			{
				//Now, in a single connection, let's use transparent mode where whatever
				//is sent to ESP is sent over to the other end immediately and what the
				//other end send back to us is received without tokens or extra data
				//This might introduce a delay from ESP waiting for more data on the
				//serial port, but if that is not ok, then just use multiple connection
				//mode and open only one port.
				ret = SendCommand( setTranspConn, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
				if (ret == RET_WIFI_MSXSM_OK)
				{
					cmd[sizeof(cmd)-1] = 0;
					rsp[sizeof(rsp)-1] = 0;
					rspsize = sizeof(rsp);
					strcpy (cmd, startSingleConn);

					switch (Conn_type)
					{
						case CONNECTION_TYPE_TCP:
							strcat (cmd, ConnTCP);
						break;

						case CONNECTION_TYPE_UDP:
							strcat (cmd, ConnUDP);
						break;

						case CONNECTION_TYPE_SSL:
							strcat (cmd, ConnSSL);
						break;
					}
					strcat (cmd,"\"");
					strcat (cmd,Address);
					strcat (cmd,"\",");
					strcat (cmd,Port);
					strcat (cmd,ESPTerminator);
					// Now effectively open the connection
					ret = SendCommand2( cmd, rsp, &rspsize, 30);
					if (ret == RET_WIFI_MSXSM_OK)
					{
						// If connection ok, start transparent mode, meaning, we are ready to
						// send data
						ret = SendCommand( startTransparent, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
						if (ret == RET_WIFI_MSXSM_OK)
						{
							isSingleConnection=1;
						}
					}
				}
			}
		}
		else
			ret = RET_WIFI_MSXSM_INVALIDPARAMETER;
	}
	else
		ret = RET_WIFI_MSXSM_NOT_INITIALIZED;

	return ret;
}

unsigned char CloseSingleConnection (void)
{
	unsigned char ret = RET_WIFI_MSXSM_OK;
	unsigned char Leaping;
	unsigned int Timer;

	if ((isInitialized)&&(isSingleConnection==1))
	{
		//First check if last byte transmission has been done 16~30ms is more than enough
		Timer = 2 + TickCount;

		if (Timer<TickCount) //Leaping?
			Leaping = 1;
		else
			Leaping = 0;

		while (UartTXInprogress())
		{
			if (Leaping)
			{
				if (TickCount<10)
				{
					Leaping = 0;
					if (TickCount>Timer)
						break;
				}
				else
					if (TickCount>Timer)
						break;
			}
			else
				if (TickCount>Timer)
						break;
		}

		//Wait one second to make sure there is a time between our exit token and the last sent data
		Timer = 60 + TickCount;

		if (Timer<TickCount) //Leaping?
			Leaping = 1;
		else
			Leaping = 0;

		while (1)
		{
			if (Leaping)
			{
				if (TickCount<10)
				{
					Leaping = 0;
					if (TickCount>Timer)
						break;
				}
				else
					if (TickCount>Timer)
						break;
			}
			else
				if (TickCount>Timer)
						break;
		}

		//Escape sequence, three consecutive +
		while (UartTXInprogress());
		myPort7 = '+';
		myPort7 = '+';
		myPort7 = '+';

		//Wait more than 2 seconds
		Timer = 200 + TickCount;

		if (Timer<TickCount) //Leaping?
			Leaping = 1;
		else
			Leaping = 0;

		while (1)
		{
			if (Leaping)
			{
				if (TickCount<10)
				{
					Leaping = 0;
					if (TickCount>Timer)
						break;
				}
				else
					if (TickCount>Timer)
						break;
			}
			else
				if (TickCount>Timer)
						break;
		}

		//Exit transparent mode
		ret = SendCommand( setRegularConn, 0, RSPOkESP, sizeof(RSPOkESP)-1, 2);
		if ( ret == RET_WIFI_MSXSM_OK)
		{
			isSingleConnection=0;
			cmd[sizeof(cmd)-1] = 0;
			rsp[sizeof(rsp)-1] = 0;
			rspsize = sizeof(rsp);
			strcpy (cmd, endSingleConn);

			ret = SendCommand2( cmd, rsp, &rspsize, 30);
		}
	}
	else
	{
		if (!isInitialized)
			ret = RET_WIFI_MSXSM_NOT_INITIALIZED;
		else
			ret = RET_WIFI_MSXSM_WRONG_MODE;
	}

	return ret;
}
#endif
