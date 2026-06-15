/*
--
-- UnapiHelper.c
--   UNAPI Abstraction functions for SSH.
--   Revision 1.00
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
#include "print.h"

unapi_code_block helperCodeBlock, helperCodeBlockTCP;
Z80_registers helperRegs; //auxiliary structure for asm function calling
char chHelperString[128];

unsigned char InitializeUNAPIS (unsigned char * ucInteractiveAuth, unsigned char * ucFilter, unsigned char * ucHostKeyVerification, unsigned char * ucPubKeyAuth)
{
    unsigned char uchRet = 0;
    uint uiSpecVersion;
    byte btReadChar;
    byte btVersionMain;
    byte btVersionSec;
    uint uiNameAddress;
    unsigned char ucCapH;
    int i;

#ifdef UNAPIHELPER_VERBOSE
    print("Looking for SSH UNAPI Implementations...\r\n");
#endif
	i = UnapiGetCount("SSH");
    if(i==0)
    {
#ifdef UNAPIHELPER_VERBOSE
        print("Error, no SSH UNAPI found...\r\n");
#endif
        uchRet = 0;
    }
    else
    {
        UnapiBuildCodeBlock(NULL, 1, &helperCodeBlock);
#ifdef UNAPIHELPER_VERBOSE
        print("Implementation name: ");
#endif
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
#ifdef UNAPIHELPER_VERBOSE
            printChar(btReadChar);
#endif
            uiNameAddress++;
        }
#ifdef UNAPIHELPER_VERBOSE
        sprintf(chHelperString," v%u.%u\r\n", btVersionMain, btVersionSec);
        print(chHelperString);
#endif
    }

#ifdef UNAPIHELPER_VERBOSE
    print("Looking for TCP/IP UNAPI Implementations...\r\n");
#endif
	i = UnapiGetCount("TCP/IP");
    if((i==0)||(uchRet==1))
    {
#ifdef UNAPIHELPER_VERBOSE
        print("Error, no TCP/IP UNAPI found...\r\n");
#endif
        uchRet = 0;
    }
    else
    {
        uchRet = 1;
        UnapiBuildCodeBlock(NULL, 1, &helperCodeBlockTCP);
#ifdef UNAPIHELPER_VERBOSE
        print("Implementation name: ");
#endif
        UnapiCall(&helperCodeBlockTCP, UNAPI_GET_INFO, &helperRegs, REGS_NONE, REGS_MAIN);
        btVersionMain = helperRegs.Bytes.B;
        btVersionSec = helperRegs.Bytes.C;
        uiNameAddress = helperRegs.UWords.HL;
        uiSpecVersion = helperRegs.UWords.DE;   //Also, save specification version implemented

        while(1) {
            btReadChar = UnapiRead(&helperCodeBlockTCP, uiNameAddress);
            if(btReadChar == 0) {
                break;
            }
#ifdef UNAPIHELPER_VERBOSE
            printChar(btReadChar);
#endif
            uiNameAddress++;
        }
#ifdef UNAPIHELPER_VERBOSE
        sprintf(chHelperString," v%u.%u\r\n", btVersionMain, btVersionSec);
        print(chHelperString);
#endif
    }

    if (uchRet != 0)
    {
        helperRegs.Bytes.B = 1; // block 1
        UnapiCall(&helperCodeBlock, SSH_GET_CAPAB, &helperRegs, REGS_MAIN, REGS_MAIN);
        if (helperRegs.Bytes.L&1)
        {
            uchRet = 1;
            // Check keyboard-interactive support
            if ((helperRegs.Bytes.H&8) == 0)
            {
                if (*ucInteractiveAuth)
                {
                    print("Keyboard-interactive authentication is not supported by this implementation\r\n");
                    uchRet = 0;
                }
                *ucInteractiveAuth = 0;
            }
            ucCapH = helperRegs.Bytes.H;
            // Check public key auth support
            if (*ucPubKeyAuth)
            {
                if ((ucCapH & 0x04) == 0)
                {
                    print("Public key authentication is not supported by this implementation\r\n");
                    uchRet = 0;
                }
                else
                {
                    helperRegs.UWords.DE = 0;
                    UnapiCall(&helperCodeBlock, SSH_KEY_INFO, &helperRegs, REGS_MAIN, REGS_MAIN);
                    if (helperRegs.Bytes.A != ERR_OK || (helperRegs.Bytes.B & 0x01) == 0)
                    {
                        print("No key loaded, use CHKSSH to generate or import a key first\r\n");
                        uchRet = 0;
                    }
                }
            }
            if ((ucCapH&16) == 0)
                *ucFilter = 0;
            if (ucCapH&32)
                *ucHostKeyVerification = 1;
            else
                *ucHostKeyVerification = 0;
        }
#ifdef UNAPIHELPER_VERBOSE
        else
            print("Implementation does not support PTY...\r\n");
#endif
    }

    return uchRet;
}

unsigned char RXData (unsigned char ucConnNumber, unsigned char * ucBuffer, unsigned int * uiSize)
{
    unsigned char ucRet = 0;

    helperRegs.Bytes.B = ucConnNumber;
    helperRegs.Words.DE = (int)ucBuffer;
    helperRegs.Words.HL = *uiSize;
    UnapiCall(&helperCodeBlock, SSH_RCV, &helperRegs, REGS_MAIN, REGS_MAIN);

    if (helperRegs.Bytes.A == ERR_OK)
        *uiSize = helperRegs.UWords.BC;
    else
        *uiSize = 0;

    if (*uiSize)
        ucRet = 1;

    return ucRet;
}

unsigned char IsConnected (unsigned char ucConnNumber, unsigned int *uiSize)
{
    unsigned char ucRet = 0;

    helperRegs.Bytes.B = ucConnNumber;
    helperRegs.Words.HL = 0;
    UnapiCall(&helperCodeBlock, SSH_STATE, &helperRegs, REGS_MAIN, REGS_MAIN);

    if ((helperRegs.Bytes.A == ERR_OK) && (helperRegs.Bytes.B == 3))
    {
        ucRet = 1;
        *uiSize = helperRegs.UWords.HL;
    }
    else
    {
        ucRet = 0;
        *uiSize = 0;
    }

    return ucRet;
}

unsigned char ConnState (unsigned char ucConnNumber, unsigned char *ucState)
{
    unsigned char ucRet = 0;

    helperRegs.Bytes.B = ucConnNumber;
    helperRegs.Words.HL = 0;
    UnapiCall(&helperCodeBlock, SSH_STATE, &helperRegs, REGS_MAIN, REGS_MAIN);

    if (helperRegs.Bytes.A == ERR_OK)
    {
        ucRet = 1;
        *ucState = helperRegs.Bytes.B;
    }
    else
    {
        ucRet = 0;
        *ucState = 4;
    }

    return ucRet;
}

unsigned char TxByte (unsigned char ucConnNumber, unsigned char uchByte)
{
    return TxUnsafeData (ucConnNumber,&uchByte,1);
}

unsigned char TxData (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize)
{
    do
    {
        helperRegs.Words.DE = (int)lpucData;
        helperRegs.UWords.HL = uiDataSize;
        helperRegs.Bytes.B = ucConnNumber;

        UnapiCall(&helperCodeBlock, SSH_SEND, &helperRegs, REGS_MAIN, REGS_MAIN);
    }
    while (helperRegs.Bytes.A == ERR_BUFFER);

    return helperRegs.Bytes.A;
}

unsigned char Respond (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize)
{
    helperRegs.Words.DE = (int)lpucData;
    helperRegs.UWords.HL = uiDataSize;
    helperRegs.Bytes.B = ucConnNumber;

    UnapiCall(&helperCodeBlock, SSH_AUTH_RESPOND, &helperRegs, REGS_MAIN, REGS_MAIN);

    return helperRegs.Bytes.A;
}

unsigned char TxUnsafeData (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize)
{
    if (uiDataSize>128)
        return ERR_INV_PARAM;
    memcpy (ucUnsafeDataTXBuffer,lpucData,uiDataSize);
    do
    {
        helperRegs.Words.DE = (int)ucUnsafeDataTXBuffer;
        helperRegs.UWords.HL = uiDataSize;
        helperRegs.Bytes.B = ucConnNumber;

        UnapiCall(&helperCodeBlock, SSH_SEND, &helperRegs, REGS_MAIN, REGS_MAIN);
        if (helperRegs.Bytes.A == ERR_BUFFER)
            Breath();
    }
    while (helperRegs.Bytes.A == ERR_BUFFER);

    return helperRegs.Bytes.A;
}

unsigned char CloseConnection (unsigned char ucConnNumber)
{
    helperRegs.Bytes.B = ucConnNumber;
    UnapiCall(&helperCodeBlock, SSH_CLOSE, &helperRegs, REGS_MAIN, REGS_MAIN);
    return helperRegs.Bytes.A;
}

void Breath()
{
    UnapiCall(&helperCodeBlockTCP, TCPIP_WAIT, &helperRegs, REGS_NONE, REGS_NONE);
}

unsigned char ResolveDNS(unsigned char * uchHostString, unsigned char * ucIP)
{
#ifdef UNAPIHELPER_VERBOSE
    sprintf(chHelperString,"Resolving host (%s)...\r\n",uchHostString);
    print(chHelperString);
#endif
    helperRegs.Words.HL = (int)uchHostString;
    helperRegs.Bytes.B = 0;
    UnapiCall(&helperCodeBlockTCP, TCPIP_DNS_Q, &helperRegs, REGS_MAIN, REGS_MAIN);
    if (helperRegs.Bytes.A != ERR_OK)
    {
#ifdef UNAPIHELPER_VERBOSE
        if(helperRegs.Bytes.A == ERR_NO_NETWORK)
            print("No network connection available\r\n");
        else if(helperRegs.Bytes.A == ERR_NO_DNS)
            print("There are no DNS servers configured\r\n");
        else if(helperRegs.Bytes.A == ERR_NOT_IMP)
            print("This TCP/IP UNAPI implementation does not support resolving host names.\nSpecify an IP address instead.\r\n");
        else
        {
            sprintf(chHelperString,"Unknown error when resolving the host name (code %i)\r\n", helperRegs.Bytes.A);
            print(chHelperString);
        }
#endif
        return helperRegs.Bytes.A;
    }

    do
    {
        Breath();
        helperRegs.Bytes.B = 0;
        UnapiCall(&helperCodeBlockTCP, TCPIP_DNS_S, &helperRegs, REGS_MAIN, REGS_MAIN);
    }
    while (helperRegs.Bytes.A == 0 && helperRegs.Bytes.B == 1);

    if(helperRegs.Bytes.A != 0)
    {
#ifdef UNAPIHELPER_VERBOSE
        if(helperRegs.Bytes.B == 2)
            print("DNS server failure\r\n");
        else if(helperRegs.Bytes.B == 3)
            print("Unknown host name\r\n");
        else if(helperRegs.Bytes.B == 5)
            print("DNS server refused the query\r\n");
        else if(helperRegs.Bytes.B == 16 || helperRegs.Bytes.B == 17)
            print("DNS server did not reply\r\n");
        else if(helperRegs.Bytes.B == 19)
            print("No network connection available\r\n");
        else if(helperRegs.Bytes.B == 0)
            print("DNS query failed\r\n");
        else
        {
            sprintf(chHelperString,"Unknown error returned by DNS server (code %i)\r\n", helperRegs.Bytes.B);
            print(chHelperString);
        }
#endif
    }
    else
    {
        ucIP[0] = helperRegs.Bytes.L;
        ucIP[1] = helperRegs.Bytes.H;
        ucIP[2] = helperRegs.Bytes.E;
        ucIP[3] = helperRegs.Bytes.D;
    }
    return helperRegs.Bytes.A;
}

unsigned char GetChallenge (unsigned char ucConnNumber, unsigned char * ucBuffer, unsigned int * uiSize, unsigned char * ucPrompts, unsigned char * ucEco)
{
    unsigned char ucRet = 0;

    helperRegs.Bytes.B = ucConnNumber;
    helperRegs.Words.DE = (int)ucBuffer;
    helperRegs.Words.HL = *uiSize;
    UnapiCall(&helperCodeBlock, SSH_AUTH_GET_CHALLENGE, &helperRegs, REGS_MAIN, REGS_MAIN);

    if (helperRegs.Bytes.A == ERR_OK)
    {
        *uiSize = helperRegs.UWords.BC;
        *ucPrompts = helperRegs.Bytes.H;
        *ucEco = helperRegs.Bytes.L;
    }
    else
        *uiSize = 0;

    return helperRegs.Bytes.A;
}

unsigned char OpenSingleConnection (unsigned char * username, unsigned char * password, unsigned char * uchHost, unsigned char * uchPort, unsigned char * uchConn, unsigned char ucAnonymous, unsigned char ucInteractive, unsigned char ucFilter, unsigned char ucHostKeyVerification, unsigned char ucPubKey)
{
    unsigned char uchRet;
    unsigned char uchIP[4];
    unsigned char paramsBlock[1024];
    unsigned int iPort = atoi(uchPort);

    uchRet = ResolveDNS(uchHost,uchIP);

    if (uchRet == ERR_OK)
    {
        paramsBlock[0] = uchIP[0];
        paramsBlock[1] = uchIP[1];
        paramsBlock[2] = uchIP[2];
        paramsBlock[3] = uchIP[3];
        paramsBlock[4] = (iPort&0xff); //remote port
        paramsBlock[5] = (iPort>>8)&0xff;
        paramsBlock[6] = 0; //PTY subsystem
        if (ucAnonymous)
        {
            paramsBlock[7] = 2; //Auth Anonymous
            paramsBlock[8] = 0;
            paramsBlock[9] = 0;
        }
        else if (ucPubKey)
        {
            paramsBlock[7] = 1; //Auth public key
            strcpy(&paramsBlock[8], username);
        }
        else
        {
            if (ucInteractive)
                paramsBlock[7] = 4; //Auth interactive
            else
                paramsBlock[7] = 0; //Auth password
            strcpy(&paramsBlock[8],username);
            strcpy(&paramsBlock[9+strlen(username)],password);
        }
        if (ucFilter)
            paramsBlock[7] |= 8;
        if (ucHostKeyVerification)
            paramsBlock[7] |= 16;
#ifdef UNAPIHELPER_VERBOSE
        sprintf(chHelperString,"OK, opening %u.%u.%u.%u:%u\r\n", paramsBlock[0], paramsBlock[1], paramsBlock[2], paramsBlock[3],iPort);
        print(chHelperString);
#endif
        helperRegs.UWords.HL = (int)paramsBlock; //conn info goes there
        UnapiCall(&helperCodeBlock, SSH_OPEN, &helperRegs, REGS_MAIN, REGS_MAIN);
        uchRet = helperRegs.Bytes.A;
        if (uchRet != ERR_OK)
        {
            if(uchRet == ERR_NO_FREE_CONN)
                print("No free SSH connections available\r\n");
            else if(uchRet == SSH_ERR_UNKNOWN_HOST)
            {
                print("Never connected to this host, SHA 256 fingerprint:\r\n");
                print(paramsBlock);
                print("\r\nAdd this host to known host and connect (Y/N)? ");
                unsigned char ucTmp;
                do
                {
                    ucTmp = Inkey ();
                }
                while ((ucTmp != 'y')&&(ucTmp != 'Y')&&(ucTmp != 'n')&&(ucTmp != 'N'));
                printChar(ucTmp);
                print("\r\n");
                if ((ucTmp == 'y')||(ucTmp == 'Y'))
                {
                     *uchConn = helperRegs.Bytes.B;
                    // Ok, connection number already in helperRegs.Bytes.B, just call SSH_ADD_KNOWN_HOST
                    UnapiCall(&helperCodeBlock, SSH_ADD_KNOWN_HOST, &helperRegs, REGS_MAIN, REGS_MAIN);
                    uchRet = helperRegs.Bytes.A;
                    if (uchRet != ERR_OK)
                    {
                        sprintf(chHelperString,"Error when opening SSH connection / adding known host (code %i)\r\n", helperRegs.Bytes.A);
                        print(chHelperString);
                    }
                }
            }
            else
            {
                sprintf(chHelperString,"Unknown error when opening SSH connection (code %i)\r\n", helperRegs.Bytes.A);
                print(chHelperString);
            }
        }
        else
            *uchConn = helperRegs.Bytes.B;
    }

    return uchRet;
}

unsigned char SetTermType (unsigned char ucTermType)
{
    helperRegs.Bytes.C = 1;
    helperRegs.Bytes.D = ucTermType;
    UnapiCall(&helperCodeBlock, SSH_TERM_TYPE, &helperRegs, REGS_MAIN, REGS_MAIN);
    return helperRegs.Bytes.A;
}

unsigned char SetTermWindow (unsigned char Rows, unsigned char Columns)
{
    helperRegs.Bytes.C = 1;
    helperRegs.Bytes.H = Rows;
    helperRegs.Bytes.L = Columns;
    UnapiCall(&helperCodeBlock, SSH_WIN_SIZE, &helperRegs, REGS_MAIN, REGS_MAIN);
    return helperRegs.Bytes.A;
}
