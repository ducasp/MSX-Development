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
#include "../../fusion-c/header/io.h"
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

unsigned int MyRead (int Handle, unsigned char *Buffer, unsigned int Size)
{
    unsigned int iRet;
    Z80_registers regs;

    regs.UWords.DE = (unsigned int)Buffer;
    regs.UWords.HL = Size;
    regs.Bytes.B = (unsigned char)(Handle & 0xff);
    DosCall(0x48, &regs, REGS_MAIN, REGS_MAIN);

    if (regs.Bytes.A == 0)
        iRet = regs.UWords.HL;
    else
        iRet = 0;

    return iRet;
}

unsigned char GenerateKey ()
{
    printf("Generating new key pair...\r\n");
    UnapiCall(&helperCodeBlock, SSH_KEY_GEN, &helperRegs, REGS_NONE, REGS_MAIN);
    if (helperRegs.Bytes.A == ERR_OK)
        printf("Key generated successfully\r\n");
    else if (helperRegs.Bytes.A == ERR_NOT_IMP)
        printf("Key generation not implemented\r\n");
    else
        printf("Error %d generating key\r\n", helperRegs.Bytes.A);
    return (helperRegs.Bytes.A == ERR_OK) ? 0 : 1;
}

unsigned char ImportKey(unsigned char *filename)
{
    unsigned char ucError = 0;
    unsigned char ucLastBlock = 0;
    unsigned int uiBytesRead;
    unsigned int uiChunkSize;
    int iFile;

    // Get implementation's max transfer size silently
    helperRegs.Bytes.B = 1;
    UnapiCall(&helperCodeBlock, SSH_GET_CAPAB, &helperRegs, REGS_MAIN, REGS_MAIN);
    if (helperRegs.Bytes.A == ERR_OK && helperRegs.UWords.DE > 0)
        uiChunkSize = helperRegs.UWords.DE;
    else
        uiChunkSize = 2048;
    if (uiChunkSize > 2048) uiChunkSize = 2048;

    printf("Importing private key from: %s\r\n", filename);

    iFile = Open((char*)filename, O_RDONLY);
    if (iFile == -1)
    {
        printf("Could not open file\r\n");
        return 1;
    }

    do {
        uiBytesRead = MyRead(iFile, ucTransferBuffer, uiChunkSize);
        if (uiBytesRead == 0) break;

        ucLastBlock = (uiBytesRead < uiChunkSize) ? 1 : 0;

        helperRegs.Bytes.C = ucLastBlock;
        helperRegs.UWords.DE = (unsigned int)ucTransferBuffer;
        helperRegs.UWords.HL = uiBytesRead;
        UnapiCall(&helperCodeBlock, SSH_KEY_IMPORT, &helperRegs, REGS_MAIN, REGS_MAIN);

        if (helperRegs.Bytes.A != ERR_OK)
        {
            printf("Error %d importing key\r\n", helperRegs.Bytes.A);
            ucError = 1;
            break;
        }
    } while (!ucLastBlock);

    Close(iFile);

    if (!ucError) printf("Key imported successfully\r\n");
    return ucError;
}

unsigned char ExportKey(unsigned char *filename, unsigned char ucWhat)
{
    unsigned char ucError = 0;
    unsigned char ucLastBlock = 0;
    unsigned int uiBytesWritten;
    int iFile;

    printf("Exporting %s key to: %s\r\n", (ucWhat == 0) ? "private" : "public", filename);

    iFile = Open((char*)filename, O_CREAT);
    if (iFile == -1)
    {
        printf("Could not create file\r\n");
        return 1;
    }

    do {
        helperRegs.Bytes.B = ucWhat;
        helperRegs.UWords.DE = (unsigned int)ucTransferBuffer;
        helperRegs.UWords.HL = 2048;
        UnapiCall(&helperCodeBlock, SSH_KEY_EXPORT, &helperRegs, REGS_MAIN, REGS_MAIN);

        if (helperRegs.Bytes.A != ERR_OK)
        {
            printf("Error %d exporting key\r\n", helperRegs.Bytes.A);
            ucError = 1;
            break;
        }

        uiBytesWritten = helperRegs.UWords.BC;
        ucLastBlock = helperRegs.Bytes.H & 0x01;

        if (uiBytesWritten > 0)
            Write(iFile, ucTransferBuffer, uiBytesWritten);
    } while (!ucLastBlock);

    Close(iFile);

    if (!ucError) printf("Key exported successfully\r\n");
    return ucError;
}

unsigned char GetCapabilities ()
{
    helperRegs.Bytes.B = 1;
    UnapiCall(&helperCodeBlock, SSH_GET_CAPAB, &helperRegs, REGS_MAIN, REGS_MAIN);
    if (helperRegs.Bytes.A == ERR_OK)
    {
        printf("Max. Sim. Connections: %d\r\nAvailable Connections: %d\r\n",helperRegs.Bytes.B,helperRegs.Bytes.C);
        printf("Max data per transfer: %u\r\n\n",helperRegs.UWords.DE);
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
            printf("Supports public key authentication\r\n");
        else
            printf("Does not support public key authentication\r\n");

        if(helperRegs.Bytes.H&0x8)
            printf("Supports keyboard-interactive authentication\r\n");
        else
            printf("Does not support keyboard-interactive authentication\r\n");

        if(helperRegs.Bytes.H&0x10)
            printf("Supports non ANSI escape code filtering\r\n");
        else
            printf("Does not support non ANSI escape code filtering\r\n");

        if(helperRegs.Bytes.H&0x20)
            printf("Supports host key verification\r\n");
        else
            printf("Does not support host key verification\r\n");

        if(helperRegs.Bytes.H&0x40)
            printf("Supports key import/export\r\n\n");
        else
            printf("Does not support key import/export\r\n\n");

        if(helperRegs.Bytes.H&0x4)
        {
            helperRegs.UWords.DE = 0;
            UnapiCall(&helperCodeBlock, SSH_KEY_INFO, &helperRegs, REGS_MAIN, REGS_MAIN);
            if (helperRegs.Bytes.A == ERR_OK)
            {
                if (helperRegs.Bytes.B & 0x01)
                {
                    printf("Key stored: Yes\r\n");
                    helperRegs.UWords.DE = (unsigned int)ucFingerprintBuffer;
                    UnapiCall(&helperCodeBlock, SSH_KEY_INFO, &helperRegs, REGS_MAIN, REGS_MAIN);
                    if (helperRegs.Bytes.A == ERR_OK)
                        printf("Fingerprint: %s\r\n\n", (char*)ucFingerprintBuffer);
                    else
                        printf("\r\n");
                }
                else
                    printf("Key stored: No\r\n\n");
            }
            else if (helperRegs.Bytes.A == SSH_ERR_NO_KEY)
                printf("Key stored: No\r\n\n");
            else
                printf("Error %d checking key info\r\n\n", helperRegs.Bytes.A);
        }
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
