/*
--
-- waitwifi.c
--   Added explanation about /T
--   KdL updated the animation so it won't update as much as it was updating before,
--   so it is easier on the eye
--   Revision 0.13
--
--   Revision by Luca Chiodi (KdL), thanks!
--   Added /T parameter (= terse output) to show only the connection result.
--   Minor text improvements.
--   Revision 0.12
--
--   Wait up to 10 seconds for the first TCP-IP UNAPI implementation to be connected.
--   Useful for WiFi modules that need time to connect after UNAPI is loaded.
--   Revision 0.11
--
-- Requires SDCC
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
#include "asm.h"

__at 0xFC9E unsigned int TickCount;
unsigned char uchMessage[255];
#define _TERM0 0

enum TcpipUnapiFunctions {
    UNAPI_GET_INFO = 0,
    TCPIP_GET_CAPAB = 1,
    TCPIP_NET_STATE = 3,
    TCPIP_DNS_Q = 6,
    TCPIP_DNS_S = 7,
    TCPIP_UDP_OPEN = 8,
    TCPIP_UDP_CLOSE = 9,
    TCPIP_UDP_STATE = 10,
    TCPIP_UDP_SEND = 11,
    TCPIP_UDP_RCV = 12,
    TCPIP_TCP_OPEN = 13,
    TCPIP_TCP_CLOSE = 14,
    TCPIP_TCP_STATE = 16,
    TCPIP_TCP_SEND = 17,
    TCPIP_TCP_RCV = 18,
    TCPIP_WAIT = 29
};

enum TcpipErrorCodes {
    ERR_OK,
    ERR_NOT_IMP,
    ERR_NO_NETWORK,
    ERR_NO_DATA,
    ERR_INV_PARAM,
    ERR_QUERY_EXISTS,
    ERR_INV_IP,
    ERR_NO_DNS,
    ERR_DNS,
    ERR_NO_FREE_CONN,
    ERR_CONN_EXISTS,
    ERR_NO_CONN,
    ERR_CONN_STATE,
    ERR_BUFFER,
    ERR_LARGE_DGRAM,
    ERR_INV_OPER
};

const char strPresentation[] = "UNAPI TCP Wait Connection Tool v0.13\r\n(c)2020 Oduvaldo Pavan Junior - ducasp@gmail.com\r\n\n";

Z80_registers regs;
int i;
int HideStr;
uint specVersion;
unapi_code_block codeBlock;
// This variable will hold JIFFY value, that is increased every VDP interrupt,
// that means usually it will be increased 60 (NTSC/PAL-M) or 50 (PAL) times
// every second
__at 0xFC9E unsigned int TickCount;

// This print function has been copied from HGET / Konamiman
// Using it as fusion-c Print uses bios calls, and do not work with PUT9000
// That hooks the dos call.
void print(char* s) __z88dk_fastcall
{
    __asm
    push    ix
loop:
    ld  a,(hl)
    or  a
    jr  z,end
    ld  e,a
    ld  c,#2
    push    hl
    call    #5
    pop hl
    inc hl
    jr  loop
end:
    pop ix
    __endasm;
}

void printChar(char c) __z88dk_fastcall
{
    __asm
    push    ix
    ld  e,l
    ld  c,#2
    call    #5
    pop ix
    __endasm;
}

void PrintImplementationName()
{
    byte readChar;
    byte versionMain;
    byte versionSec;
    uint nameAddress;

    print("Implementation name: ");

    UnapiCall(&codeBlock, UNAPI_GET_INFO, &regs, REGS_NONE, REGS_MAIN);
    versionMain = regs.Bytes.B;
    versionSec = regs.Bytes.C;
    nameAddress = regs.UWords.HL;

    specVersion = regs.UWords.DE;   //Also, save specification version implemented

    while(1) {
        readChar = UnapiRead(&codeBlock, nameAddress);
        if(readChar == 0) {
            break;
        }
        printChar(readChar);
        nameAddress++;
    }

    sprintf(uchMessage," v%u.%u\r\nWaiting it to have connection state OPEN...\r\n", versionMain, versionSec);
    print(uchMessage);
}

int main (char** argv, int argc)
{
    unsigned int Time0,Time1,TimeOut,TimeLeap;
    unsigned char advance[4] = {'-','\\','|','/'};

    TickCount = 0;

    Time0 = TickCount + 5;
    // Timeout for a packet
    Time1 = TickCount;
    TimeOut = 600 + Time1;
    if (TimeOut<Time1)
        TimeLeap = 1;
    else
        TimeLeap = 0;

    i = 0;
    // Check if the terse parameter is set
    if ((argv[i][0]=='/') && ( (argv[i][1]=='t') || (argv[i][1]=='T')) )
        HideStr = 0;
    else
        HideStr = -1;

    if (HideStr)
        print(strPresentation);

    i = UnapiGetCount("TCP/IP");
    if(i==0)
    {
        print("No TCP/IP UNAPI implementations found\r\n\n");
        return 1;
    }

    UnapiBuildCodeBlock(NULL, 1, &codeBlock);

    i = 0;
    if (HideStr)
        PrintImplementationName();

    do
    {
        // Check if timeout expired
        if (TimeLeap == 0)
        {
            if (TickCount>TimeOut)
            {
                print("\rTime-out and not connected!\r\n\n");
                return 1;
            }
        }
        else
        {
            if (TickCount<1200)
            {
                TimeLeap = 0;
                if (TickCount>TimeOut)
                    break;
            }
        }

        // Our nice animation to show we are not stuck
        if (TickCount>Time0)
        {
            Time0 = TickCount + 5;
            printChar(advance[i%4]); // next char
            printChar(29); // move left a char
            ++i;
        }
        // Check Connection
        UnapiCall(&codeBlock, TCPIP_NET_STATE, &regs, REGS_NONE, REGS_MAIN);
    }
    while (regs.Bytes.B != 2);

    if (regs.Bytes.B == 2)
    {
        print("\rConnected!\r\n\n");
        return 0;
    }
    else
    {
        print("\rNot connected...\r\n\n");
        return 1;
    }
}
