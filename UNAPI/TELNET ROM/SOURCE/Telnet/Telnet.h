/*
--
-- telnet.h
--   Simple TELNET client using UNAPI for MSX.
--   Revision 1.00 for ROM
--
-- Copyright (c) 2019-2024 Oduvaldo Pavan Junior ( ducasp@gmail.com )
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

#ifndef _TELNET_HEADER_INCLUDED
#define _TELNET_HEADER_INCLUDED
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
//Telnet 2 bytes commands
#define GA 0xf9
#define EL 0xf8
#define EC 0xf7
#define AYT 0xf6
#define AO 0xf5
#define IP 0xf4
#define BRK 0xf3
#define DM 0xf2
#define NOP 0xf1
//Telnet 3 bytes Commands
#define CMD_TRANSMIT_BINARY 0
#define CMD_ECHO 1
#define CMD_SUPPRESS_GO_AHEAD 3
#define CMD_TTYPE 24 //0x18
#define CMD_WINDOW_SIZE 31 //0x1f
#define CMD_TERMINAL_SPEED 32 //0x20
#define CMD_REMOTE_FLOW_CONTROL 33 //0x21
#define CMD_LINE_MODE 34 //0x22
#define CMD_ENV_VARIABLES 36 //0x24
#define CMD_ENCRYPTION 38 //0x26

enum TelnetDataParserStates {
    TELNET_IDLE = 0,
    TELNET_CMD_INPROGRESS = 1,
    TELNET_SUB_INPROGRESS = 2,
    TELNET_SUB_WAITEND = 3,
    TELNET_ESC_INPROGRESS = 4
};

//Those won't change, so we won't waste memory and use global constants
const unsigned char ucWindowSize1[] = {IAC, WILL, CMD_WINDOW_SIZE, IAC, SB, CMD_WINDOW_SIZE, 0, 80, 0, 25, IAC, SE}; //our terminal is 80x25
const unsigned char ucTTYPE2[] = {IAC, SB, CMD_TTYPE, IS, 'A', 'N', 'S', 'I', IAC, SE}; //Terminal ANSI

//Auxiliary strings
const unsigned char ucCrLf[3]="\r\n"; //auxiliary

//Versions
const char ucSWInfoANSI[] = "\x1b[31m> MSX UNAPI TELNET ROM Client v1.00 <\r\n (c) 2024 Oduvaldo Pavan Junior - ducasp@gmail.com\x1b[0m\r\n\r\nWhile connected press:\r\nF2 - Change echo settings\r\nF3 - Toggle Cr or Cr/Lf\r\nF5 - Disconnect and return to main menu\r\n\r\n";
const char ucOptionMenu[] = "1 - Connect to HispaMSX BBS\r\n2 - Connect to Sotano MSX BBS\r\n3 - Connect to Terra Brasilis BBS\r\n4 - Enter server name and port to connect to\r\n\r\n";

// Leave this here and do not allocate anything not constant before this, so SDCC will allocate
// 0xC002 to 0xC13D, we will use it for msx2ansi
byte btReservedMemory[316];

// Will hold the data to send on arrow keys
unsigned char ucCursor_Up[4];
unsigned char ucCursor_Down[4];
unsigned char ucCursor_Forward[4];
unsigned char ucCursor_Backward[4];

//Our Flags
unsigned char ucEcho; //Echo On?
unsigned char ucState; //State of Telnet Data Parser
unsigned char ucCmdCounter; //If there is a TELNET command in progress, its size
unsigned char ucConnNumber; //hold the connection number received by UnapiHelper

//For data receive parsing
unsigned char ucRcvData[128];

//MSX Variables that we will access
__at 0xF3B0 unsigned char ucLinLen;
__at 0xFCA9 unsigned char ucCursorDisplayed;
__at 0xFBEB unsigned char ucMT6;
__at 0xFBEC unsigned char ucMT7;
__at 0xFC9E unsigned int uiJiffy;

#define RcvMemorySize 1024
unsigned int uiGetSize;

Z80_registers regs; //auxiliary structure for asm function calling

void negotiate(unsigned char *ucBuf);
void ParseTelnetData(void);
void SendCursorPosition(unsigned int uiCursorPosition) __z88dk_fastcall;
#endif // _TELNET_HEADER_INCLUDED
