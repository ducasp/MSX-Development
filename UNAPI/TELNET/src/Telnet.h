/*
--
-- telnet.h
--   Simple TELNET client using UNAPI for MSX.
--   Revision 1.33
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

#ifndef _TELNET_HEADER_INCLUDED
#define _TELNET_HEADER_INCLUDED
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../../fusion-c/header/msx_fusion.h"
#include "../../fusion-c/header/asm.h"

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
const unsigned char ucWindowSize[] = {IAC, WILL, CMD_WINDOW_SIZE, IAC, SB, CMD_WINDOW_SIZE, 0, 80, 0, 24, IAC, SE}; //our terminal is 80x24
const unsigned char ucWindowSize0[] = {IAC, WILL, CMD_WINDOW_SIZE, IAC, SB, CMD_WINDOW_SIZE, 0, 40, 0, 24, IAC, SE}; //our terminal is 40x24
const unsigned char ucWindowSize1[] = {IAC, WILL, CMD_WINDOW_SIZE, IAC, SB, CMD_WINDOW_SIZE, 0, 80, 0, 25, IAC, SE}; //our terminal is 80x25
const unsigned char ucTTYPE2[] = {IAC, SB, CMD_TTYPE, IS, 'A', 'N', 'S', 'I', IAC, SE}; //Terminal ANSI
const unsigned char ucTTYPE3[] = {IAC, SB, CMD_TTYPE, IS, 'V', 'T', '5', '2', IAC, SE}; //Terminal UNKNOWN

//Auxiliary strings
const unsigned char ucCrLf[3]="\r\n"; //auxiliary

//Instructions
const char ucUsage[] = "Usage: telnet <server[:port]> [a] [r]\r\n\r\n"
                       "<server[:port]>: 192.168.0.1:34 or bbs.hispamsx.org\r\n\r\n"
                       "a: turns off automatic download detection (some BBSs can't be used with it)\r\n"
                       "o: turns off ANSI rendering and use MSX-DOS text rendering\r\n"
                       "r: if file transfer fails try using this, some BBSs misbehave on file transfers\r\n\r\n";

//Versions
#ifndef AO_FOSSIL_ADAPTER
const char ucSWInfo[] = "> MSX UNAPI TELNET Client v1.33 <\r\n (c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com\r\n\r\n";
const char ucSWInfoANSI[] = "\x1b[31m> MSX UNAPI TELNET Client v1.33 <\r\n (c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com\x1b[0m\r\n";
#else
const char ucSWInfo[] = "\x1b[37m> MSX Serial ANSI Terminal, Andres Ortiz, 2020 <\r\n\x1b[31mA Fork of the UNAPI Telnet (c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com<\r\n\r\n";
const char ucSWInfoANSI[] = "\x1b[37m> MSX Serial ANSI Terminal, Andres Ortiz, 2020 <\r\n\x1b[31m>A Fork of the UNAPI Telnet (c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com<\x1b[0m\r\n";
unsigned char serialmode = 0;
#endif
const char ucCursor_Up[] = "\x1b[A";
const char ucCursor_Down[] = "\x1b[B";
const char ucCursor_Forward[] = "\x1b[C";
const char ucCursor_Backward[] = "\x1b[D";

//Our Flags
unsigned char ucEcho; //Echo On?
unsigned char ucAutoDownload; //Auto download on binary transfers?
unsigned char ucAnsi; //Using ANSI rendering?
unsigned char ucEnterHit; //user has input enter?
unsigned char ucWidth40; //Detected 40 Columns or less?
unsigned char ucState; //State of Telnet Data Parser
unsigned char ucCmdCounter; //If there is a TELNET command in progress, its size
unsigned char ucStandardDataTransfer; //Is this telnet server proper and transmitting files using telnet double FF?
unsigned char ucConnNumber; //hold the connection number received by UnapiHelper

//For data receive parsing
unsigned char ucRcvData[128];

//MSX Variables that we will access
__at 0xF3B0 unsigned char ucLinLen;
__at 0xFCA9 unsigned char ucCursorDisplayed;
__at 0xFBEB unsigned char ucMT6;
__at 0xFBEC unsigned char ucMT7;

//IMPORTANT: You need to check the map compiler generates to make sure this
//address do not overlap functions, variables, etc
//UNAPI requires memory buffer @ 0x8000 or higher...
#define RcvMemorySize 1024
#ifdef AO_FOSSIL_ADAPTER
unsigned char ucRcvDataMemory[RcvMemorySize]; //area to hold data sent to Fossil driver, avoid 0x8000 as it seems somehow it is used
#else
__at 0x8000 unsigned char ucRcvDataMemory[]; //area to hold data sent to UNAPI, need to be in the 3rd 16K block
#endif

unsigned int uiGetSize;

Z80_registers regs; //auxiliary structure for asm function calling

void negotiate(unsigned char *ucBuf);
unsigned int IsValidInput (char**argv, int argc, unsigned char *ucServer, unsigned char *ucPort, unsigned char *ucAnsiOption);
void ParseTelnetData(void);
void SendCursorPosition(unsigned int uiCursorPosition) __z88dk_fastcall;
#endif // _TELNET_HEADER_INCLUDED
