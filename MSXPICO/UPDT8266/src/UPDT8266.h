
/*
--
-- UPDT8266.h
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

#define bool unsigned char
#define true 1
#define false 0

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

// MSX PICO has Port 6 and Port 7 mapped to those memory addresses
__at 0x7F06 unsigned char myPort6;
__at 0x7F07 unsigned char myPort7;
// What is originally mapped in Page 1 so we can restore it back
__at 0xF342 unsigned char uchPage1RamSlot;
// This variable will hold JIFFY value, that is increased every VDP interrupt,
// that means usually it will be increased 60 (NTSC/PAL-M) or 50 (PAL) times
// every second
__at 0xFC9E unsigned int TickCount;
// Information if slots are expanded or not
__at 0xFCC1 unsigned char uchSlot0Expanded;
__at 0xFCC2 unsigned char uchSlot1Expanded;
__at 0xFCC3 unsigned char uchSlot2Expanded;
__at 0xFCC4 unsigned char uchSlot3Expanded;

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
#define GetUARTData() myPort6

/*
-- UartRXData - Check if UART FIFO has data available
--
-- Input - none
-- Return - 0 if UART FIFO is empty
--          1 if UART FIFO has data
--
*/
#define UartRXData() myPort7&1 ? 1 : 0
const char chFiller[128] = {'U','P','D','8','2','6','6',' ','Y','o','u',' ','h','a','v','e',' ','a',' ','g','o','o','d',' ','t','i','m','e',' ','r','e','a','d','i','n','g',' ','t','h','i','s',' ','t','a','l','e',' ','o','f',' ','a','n',' ','w','e','i','r','d',' ','b','e','h','a','v','i','o','r',',',' ','s','i','t',' ','a','n','d',' ','h','a','v','e',' ','f','u','n',' ','a','s',' ','t','h','i','s',' ','i','s',' ','o','v','e','r','w','r','i','t','t','e','n','!',0x0d,0x0a,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
const char endUpdate[2] = {'E',0};
const char versionResponse[1] = {'V'};
const char certificateDone[2] = {'I',0};
const char responseOK[2] = {'O','K'};
const char responseRSFWUpdate[2] = {'Z',0};
const char responseRSCERTUpdate[2] = {'Y',0};
const char responseWRBlock[2] = {'z',0};
const char responseOTAFW[2] = {'U',0};
const char responseOTASPIFF[2] = {'u',0};
const char advance[5][18]={{'[',0x01,0x57,0x01,0x57,0x01,0x57,' ',' ',']',0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x00},\
                            {'[',' ',0x01,0x57,0x01,0x57,0x01,0x57,' ',']',0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x00},\
                            {'[',' ',' ',0x01,0x57,0x01,0x57,0x01,0x57,']',0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x00},\
                            {'[',0x01,0x57,' ',' ',0x01,0x57,0x01,0x57,']',0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x00},\
                            {'[',0x01,0x57,0x01,0x57,' ',' ',0x01,0x57,']',0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x1d,0x00}};
const char aDone[9] = {' ',' ',' ',' ',' ',' ',' ',0x0d,0x00};
const char responseReady2[7] = {'R','e','a','d','y',0x0d,0x0a};

const char strUsage[] = "Usage:  UPDT8266 [options]\r\n\n"
                        " FW.BIN       to update ESP8266 firmware locally\r\n"
                        " CERT.BIN /c  to update TLS certificates locally\r\n\n"
                        " /u SERVER PORT FILEPATH  to update ESP8266 firmware remotely\r\n"
                        " /c SERVER PORT FILEPATH  to update TLS certificates remotely\r\n\n"
                        "Example:  UPDT8266 /u 192.168.31.1 80 /fw/fw.bin\r\n";
const char chFiller2[128] = {'U','P','D','8','2','6','6',' ','Y','o','u',' ','h','a','v','e',' ','a',' ','g','o','o','d',' ','t','i','m','e',' ','r','e','a','d','i','n','g',' ','t','h','i','s',' ','t','a','l','e',' ','o','f',' ','a','n',' ','w','e','i','r','d',' ','b','e','h','a','v','i','o','r',',',' ','s','i','t',' ','a','n','d',' ','h','a','v','e',' ','f','u','n',' ','a','s',' ','t','h','i','s',' ','i','s',' ','o','v','e','r','w','r','i','t','t','e','n','!',0x0d,0x0a,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
unsigned int uiPort;
long lPort;
unsigned char ucLocalUpdate;
unsigned char ucIsFw;
unsigned int uiTimeout;
unsigned char uchOriginalProgramSlot,uchOriginalProgramSubSlot;
unsigned char uchOriginalPicoSlot,uchOriginalPicoMemSubSlot;
