
/*
--
-- CFG8266.h
--   Set-up the Wi-Fi module of your MSX-SM / SM-X.
--   Revision 1.30
--
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2019-2020 Oduvaldo Pavan Junior ( ducasp@ gmail.com )
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

#define bool unsigned char
#define true 1
#define false 0

//#define DEBUG_RS232

typedef struct AP {
   char APName[33]; //Per specs up to 32 characters
   unsigned char isEncrypted; //0 if open, 1 if encrypted // pwd needed
} AP;

const char* strAPSts[6] = {
	"Wi-Fi is Idle, AP: ",
	"Wi-Fi Connecting to AP: ",
	"Wi-Fi Wrong Password for AP: ",
	"Wi-Fi Did not find AP: ",
	"Wi-Fi Failed to connect to: ",
	"Wi-Fi Connected to: "};

const char* speedStr[10] = {
    "859372 bps",
    "346520 bps",
    "231014 bps",
    "115200 bps",
    "57600 bps",
    "38400 bps",
    "31250 bps",
    "19200 bps",
    "9600 bps",
    "4800 bps",
};

//I/O made simple...
__sfr __at 0x06 myPort6; //reading this is same as IN and writing same as out, without extra instructions
                         //when using Inport and Outport from Fusion-C
__sfr __at 0x07 myPort7; //reading this is same as IN and writing same as out, without extra instructions
                         //when using Inport and Outport from Fusion-C
//This variable will hold JIFFY value, that is increased every VDP interrupt,
//that means usually it will be increased 60 (NTSC/PAL-M) or 50 (PAL) times
//every second
__at 0xFC9E unsigned int TickCount;

#define ClearUartData() myPort6 = 20

/*
-- GetUARTData - Receive a byte from ESP8266
--
-- Input - none
-- Return - one byte from the FIFO
--
-- This function should only be used after checking that there is data in
-- the FIFO with UartRXData. Otherwise, you will get junk if the FIFO is
-- empty.
*/
#ifndef DEBUG_RS232
#define GetUARTData() myPort6
#else
unsigned char GetUARTData()
{
    unsigned char uchRet;
    uchRet = myPort6;
    printf ("{%x}",uchRet);
    return uchRet;
}
#endif
/*
-- UartRXData - Check if UART FIFO has data available
--
-- Input - none
-- Return - 0 if UART FIFO is empty
--          1 if UART FIFO has data
--
*/
#define UartRXData() myPort7&1 ? 1 : 0
#define scanPageLimit 10
const char chFiller[128] = {'C','F','G','8','2','6','6',' ','Y','o','u',' ','h','a','v','e',' ','a',' ','g','o','o','d',' ','t','i','m','e',' ','r','e','a','d','i','n','g',' ','t','h','i','s',' ','t','a','l','e',' ','o','f',' ','a','n',' ','w','e','i','r','d',' ','b','e','h','a','v','i','o','r',',',' ','s','i','t',' ','a','n','d',' ','h','a','v','e',' ','f','u','n',' ','a','s',' ','t','h','i','s',' ','i','s',' ','o','v','e','r','w','r','i','t','t','e','n','!',0x0d,0x0a,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
const char endUpdate[2] = {'E',0};
const char versionResponse[1] = {'V'};
const char certificateDone[2] = {'I',0};
const char responseOK[2] = {'O','K'};
const char scanResponse[2] = {'S',0};
const char scanresNoNetwork[2] = {'S',2};
const char nagleonResponse[2] = {'D',0};
const char nagleoffResponse[2] = {'N',0};
const char scanresResponse[2] = {'s',0};
const char apconfigurationResponse[2] = {'A',0};
const char apstsResponse[3] = {'g',0,0};
const char responseRSFWUpdate[2] = {'Z',0};
const char responseRSCERTUpdate[2] = {'Y',0};
const char responseWRBlock[2] = {'z',0};
const char responseOTAFW[2] = {'U',0};
const char responseOTASPIFF[2] = {'u',0};
const char responseRadioOnTimeout[2] = {'T',0};
const char radioOffResponse[2] = {'O',0};
const char advance[5][18]={{'[',0x01,0x57,0x01,0x57,0x01,0x57,' ',' ',']',0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x00},\
                            {'[',' ',0x01,0x57,0x01,0x57,0x01,0x57,' ',']',0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x00},\
                            {'[',' ',' ',0x01,0x57,0x01,0x57,0x01,0x57,']',0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x00},\
                            {'[',0x01,0x57,' ',' ',0x01,0x57,0x01,0x57,']',0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x00},\
                            {'[',0x01,0x57,0x01,0x57,' ',' ',0x01,0x57,']',0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x00}};
const char aDone[9] = {' ',' ',' ',' ',' ',' ',' ',0x0d,0x00};
const char responseReady2[7] = {'R','e','a','d','y',0x0d,0x0a};

const char strUsage[] = "Usage:  CFG8266 [options]\r\n\n"
                        " /s  to scan networks and choose one to connect\r\n"
                        " /m  to turn on Nagle Algorithm\r\n"
                        " /n  to turn off Nagle Algorithm (default)\r\n"
                        " /o  to turn off radio now if no connections are open\r\n\n"
                        " FW.BIN       to update ESP8266 firmware locally\r\n"
                        " CERT.BIN /c  to update TLS certificates locally\r\n\n"
                        " /u SERVER PORT FILEPATH  to update ESP8266 firmware remotely\r\n"
                        " /c SERVER PORT FILEPATH  to update TLS certificates remotely\r\n\n"
                        " /t TIME  to change the inactivity time in seconds to disable radio\r\n"
                        "          time range is 0-600 seconds (0 means never disable)\r\n\n"
                        "Example:  CFG8266 /u 192.168.31.1 80 /fw/fw.bin\r\n";
const char chFiller2[128] = {'C','F','G','8','2','6','6',' ','Y','o','u',' ','h','a','v','e',' ','a',' ','g','o','o','d',' ','t','i','m','e',' ','r','e','a','d','i','n','g',' ','t','h','i','s',' ','t','a','l','e',' ','o','f',' ','a','n',' ','w','e','i','r','d',' ','b','e','h','a','v','i','o','r',',',' ','s','i','t',' ','a','n','d',' ','h','a','v','e',' ','f','u','n',' ','a','s',' ','t','h','i','s',' ','i','s',' ','o','v','e','r','w','r','i','t','t','e','n','!',0x0d,0x0a,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
unsigned char ucScan;
unsigned int uiPort;
long lPort;
unsigned char ucLocalUpdate;
unsigned char ucIsFw;
unsigned char ucNagleOff,ucNagleOn,ucRadioOff,ucSetTimeout;
unsigned int uiTimeout;
