/*
--
-- chkssh.c
--   UNAPI SSH Checker / Key Manager.
--   Revision 1.10
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
#include "chkssh.h"
#include "UnapiHelper.h"

const char ucHelpText[] = "\r\nCHKSSH - UNAPI SSH Checker / Key Manager v1.10\r\n\
(c) 2026 Oduvaldo Pavan Junior - ducasp@gmail.com\r\n\r\n\
Usage:\r\n\
  CHKSSH c              Show SSH implementation capabilities\r\n\
  CHKSSH g              Generate a new key pair\r\n\
  CHKSSH <file>         Import private key from file\r\n\
  CHKSSH <file> k       Export private key to file\r\n\
  CHKSSH <file> p       Export public key to file\r\n\r\n";

/*
 *
 * START OF CODE
 *
 */

int main(char** argv, int argc)
{
    if (argc == 0)
    {
        printf(ucHelpText);
        return 0;
    }

    if (!InitializeSSH()) return 1;

    if ((strcmp(argv[0], "c") == 0) || (strcmp(argv[0], "C") == 0))
        GetCapabilities();
    else if ((strcmp(argv[0], "g") == 0) || (strcmp(argv[0], "G") == 0))
        GenerateKey();
    else if (argc == 1)
        ImportKey((unsigned char*)argv[0]);
    else if (argc == 2)
    {
        if ((strcmp(argv[1], "k") == 0) || (strcmp(argv[1], "K") == 0))
            ExportKey((unsigned char*)argv[0], 0);
        else if ((strcmp(argv[1], "p") == 0) || (strcmp(argv[1], "P") == 0))
            ExportKey((unsigned char*)argv[0], 1);
        else
            printf(ucHelpText);
    }
    else
        printf(ucHelpText);

    return 0;
}
