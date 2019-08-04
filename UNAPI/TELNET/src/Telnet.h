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
//Telnet Commands
#define CMD_ECHO 1
#define CMD_SUPPRESS_GO_AHEAD 3
#define CMD_TTYPE 24
#define CMD_WINDOW_SIZE 31
#define CMD_TERMINAL_SPEED 32
#define CMD_REMOTE_FLOW_CONTROL 33
#define CMD_LINE_MODE 34
#define CMD_ENV_VARIABLES 36
#define CMD_ENCRYPTION 38

//Those won't change, so we won't waste memory and use global constants
const unsigned char ucClientWill[] = { IAC, WILL, CMD_WINDOW_SIZE,\ //we are willing to negotiate Window Size
                                      IAC, WILL, CMD_TTYPE,\ //we are willing to negotiate Terminal Type
                                      IAC, WILL, CMD_TERMINAL_SPEED\ //we are willing to negotiate Terminal Speed
                                      };
const unsigned char ucWindowSize[] = {IAC, SB, CMD_WINDOW_SIZE, 0, 80, 0, 24, IAC, SE}; //our terminal is 80x24
const unsigned char ucWindowSize1[] = {IAC, SB, CMD_WINDOW_SIZE, 0, 80, 0, 25, IAC, SE}; //our terminal is 80x25
const unsigned char ucEchoDont[] = {IAC, DONT, CMD_ECHO};
const unsigned char ucEchoDo[] = {IAC, DO, CMD_ECHO};
const unsigned char ucTTYPE2[] = {IAC, SB, CMD_TTYPE, IS, 'x', 't', 'e', 'r', 'm', '-', '1', '6', 'c', 'o', 'l', 'o', 'r', IAC, SE}; //Terminal xterm-16color
const unsigned char ucTTYPE3[] = {IAC, SB, CMD_TTYPE, IS, 'U', 'N', 'K', 'N', 'O', 'W', 'N', IAC, SE}; //Terminal UNKNOWN
const unsigned char ucSpeed800K[] = {IAC, SB, CMD_TERMINAL_SPEED, IS, '8', '0', '0', '0', '0', '0', ',', '8', '0', '0', '0', '0', '0', IAC,SE}; //terminal speed response

//Auxiliary strings
const unsigned char ucCrLf[3]="\r\n"; //auxiliary

//Do not initialize global variables here
//fusion-c uses Konamiman crt0.s and it won't perform the initialization
//left by SDCC for crt0 to handle (like their implementation of crt0)

//Instructions
const char ucUsage[] = "Usage: telnet <server:port> [s] \n\n<server:port>: 192.168.0.1:23 or bbs.hispamsx.org:23\n\ns: turns on smooth scroll if JANSI is installed\n\n";

//Versions
const char ucSWInfo[] = "> MSX UNAPI TELNET Client v0.70 <\n (c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\n\n";
const char ucSWInfoJANSI[] = "\x1b[.\x1b[3.\x1b[31m> MSX UNAPI TELNET Client v0.70 <\r\n (c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\x1b[0m\r\n";
const char ucSWInfoJANSISS[] = "\x1b[.\x1b[3.\x1b[31m> MSX UNAPI TELNET Client v0.70 <\r\n (c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\x1b[0m\x1b[13;1.\r\n";

//Our Flags
unsigned char ucEcho; //Echo On?
unsigned char ucAnsi; //Detected J-ANSI?
unsigned char ucSentWill; //Sent what information we are willing for negotiation?
unsigned char ucCmdInProgress; //Is there a TELNET command in progress?
unsigned char ucEscInProgress; //Is there an ESC command in progress?
unsigned char ucSubOptionInProgress; // Is there a TELNET command sub option in progress?

//For data receive parsing
unsigned char ucEscData[25];
unsigned char ucRcvData[128];

//MSX Variables that we will access
__at 0xF3DC unsigned char ucCursorY;
__at 0xF3DD unsigned char ucCursorX;

//IMPORTANT: You need to check the map compiler generates to make sure this
//address do not overlap functions, variables, etc
//MEMMAN and jANSI require memory information passed to it to be in the
//upper memory segment, so we use this address to interface with it
__at 0xC000 unsigned char ucMemMamMemory[]; //area to hold data sent to jANSI, need to be in the 3rd 16K block
#define MemMamMemorySize 1025
unsigned int uiGetSize;

Z80_registers regs; //auxiliary structure for asm function calling

int negotiate(unsigned char ucConnNumber, unsigned char *ucBuf, int iLen);
unsigned int IsValidInput (char**argv, int argc, unsigned char *ucServer, unsigned char *ucPort, unsigned char *ucSmoothScroll);
void WorkOnReceivedData(unsigned char ucConnNumber);
void ClearTelnetDoubleFF();
#endif // _TELNET_HEADER_INCLUDED
