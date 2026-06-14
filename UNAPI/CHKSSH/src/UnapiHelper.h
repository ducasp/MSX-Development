/*
--
-- UnapiHelper.h
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

#ifndef _UNAPIHELPER_HEADER_INCLUDED
#define _UNAPIHELPER_HEADER_INCLUDED
//Comment the define bellow if you do not want messages printed by this code
#define UNAPIHELPER_VERBOSE

enum SSHUnapiFunctions {
    UNAPI_GET_INFO = 0,
    SSH_GET_CAPAB = 1,
    SSH_TERM_TYPE = 7,
    SSH_WIN_SIZE = 8,
    SSH_KEY_GEN = 12,
    SSH_KEY_EXPORT = 13,
    SSH_KEY_IMPORT = 14,
    SSH_KEY_INFO = 15
};

enum SSHErrorCodes {
    ERR_OK = 0,
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

enum SSHSpecificErrorCodes {
    SSH_ERR_NO_KEY = 133,
    SSH_ERR_KEY_INV_DATA = 134
};

__at 0x9000 unsigned char ucUnsafeDataTXBuffer[];
__at 0x8000 unsigned char ucFingerprintBuffer[64];
__at 0x8040 unsigned char ucTransferBuffer[2048];

// InitializeSSH
//
// Check if there are any SSH Unapi Implementations available, and if there
// are, use the first available
//
// Return 0 if no SSH Unapi implementation found
// Return 1 if a SSH Unapi implementation has been found
unsigned char InitializeSSH ();

unsigned char GetCapabilities ();
unsigned char GenerateKey ();
unsigned char ImportKey (unsigned char *filename);
unsigned char ExportKey (unsigned char *filename, unsigned char ucWhat);
unsigned int MyRead (int Handle, unsigned char *Buffer, unsigned int Size);

#endif //#ifndef _UNAPIHELPER_HEADER_INCLUDED
