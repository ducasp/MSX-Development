/*
--
-- UnapiHelper.c
--   UNAPI Abstraction functions.
--   Revision 0.60
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2026 Oduvaldo Pavan Junior ( ducasp@gmail.com )
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
#include "../../fusion-c/header/asm.h"
#include "UnapiHelper.h"

unapi_code_block helperCodeBlock;
Z80_registers helperRegs; //auxiliary structure for asm function calling
char chHelperString[128];

unsigned char InitializeSSH ()
{
    unsigned char uchRet = 0;
    uint uiSpecVersion;
    byte btReadChar;
    byte btVersionMain;
    byte btVersionSec;
    uint uiNameAddress;
    int i;

    printf("Looking for SSH UNAPI Implementations...\r\n");

	i = UnapiGetCount("SSH");
    if(i==0)
    {
        printf("No SSH UNAPI found...\r\n");
        uchRet = 0;
    }
    else
    {
        uchRet = 1;
        UnapiBuildCodeBlock(NULL, 1, &helperCodeBlock);
        printf("Implementation name: ");
        UnapiCall(&helperCodeBlock, UNAPI_GET_INFO, &helperRegs, REGS_NONE, REGS_MAIN);
        btVersionMain = helperRegs.Bytes.B;
        btVersionSec = helperRegs.Bytes.C;
        uiNameAddress = helperRegs.UWords.HL;
        uiSpecVersion = helperRegs.UWords.DE;   //Also, save specification version implemented

        while(1) {
            btReadChar = UnapiRead(&helperCodeBlock, uiNameAddress);
            if(btReadChar == 0) {
                break;
            }
            printf("%c",btReadChar);
            uiNameAddress++;
        }
        printf(" v%u.%u\r\n", btVersionMain, btVersionSec);
    }

    return uchRet;
}

unsigned char GetCapabilities ()
{
    helperRegs.Bytes.B = 1;
    UnapiCall(&helperCodeBlock, SSH_GET_CAPAB, &helperRegs, REGS_MAIN, REGS_MAIN);
    if (helperRegs.Bytes.A == ERR_OK)
    {
        printf("Max. Sim. Connections: %d\r\nAvailable Connections: %d\r\n\n",helperRegs.Bytes.B,helperRegs.Bytes.C);
        if(helperRegs.Bytes.L&0x01)
            printf("Supports PTY\r\n");
        else
            printf("Does not support PTY\r\n");

        if(helperRegs.Bytes.L&0x02)
            printf("Supports SFTP\r\n");
        else
            printf("Does not support SFTP\r\n");

        if(helperRegs.Bytes.L&0x04)
            printf("Supports SCP\r\n");
        else
            printf("Does not support SCP\r\n");

        if(helperRegs.Bytes.L&0x08)
            printf("Supports RAW\r\n");
        else
            printf("Does not support RAW\r\n");

        if(helperRegs.Bytes.H&0x1)
            printf("TCP/IP built-in\r\n");
        else
            printf("Needs UNAPI TCP/IP device\r\n");

        if(helperRegs.Bytes.H&0x2)
            printf("Connections shared with TCP/IP UNAPI\r\n");
        else
            printf("Connections independent of TCP/IP UNAPI\r\n");

        if(helperRegs.Bytes.H&0x4)
            printf("Supports public key authentication\r\n\n");
        else
            printf("Does not support public key authentication\r\n\n");
    }
    else
        printf("Error %d trying to get capabilities...\r\n", helperRegs.Bytes.A);

    helperRegs.Bytes.C = 0;
    UnapiCall(&helperCodeBlock, SSH_TERM_TYPE, &helperRegs, REGS_MAIN, REGS_MAIN);
    if (helperRegs.Bytes.A == ERR_OK)
    {
        switch (helperRegs.Bytes.D)
        {
            case 0:
                printf("Terminal Type set to VT-52\r\n");
            break;
            case 1:
                printf("Terminal Type set to ANSI(16 Colors)\r\n");
            break;
            case 2:
                printf("Terminal Type set to xterm\r\n");
            break;
            default:
                printf("Terminal Type %d unknown\r\n",helperRegs.Bytes.D);
            break;
        }
    }
    else
        printf("Error %d trying to get terminal type currently set...\r\n", helperRegs.Bytes.A);

    helperRegs.Bytes.C = 0;
    UnapiCall(&helperCodeBlock, SSH_WIN_SIZE, &helperRegs, REGS_MAIN, REGS_MAIN);
    if (helperRegs.Bytes.A == ERR_OK)
    {
        printf("Window Size: %d X %d\r\n\n",helperRegs.Bytes.L,helperRegs.Bytes.H);
    }
    else
        printf("Error %d trying to get terminal window size set...\r\n");

    return 0;
}
