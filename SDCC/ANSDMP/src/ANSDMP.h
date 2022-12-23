/*
--
-- ANSDMP.h
--   Simple Ansi Dumper using Sonic_Aka_T ANSI libraries for MSX.
--   Revision 0.10
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2019 Oduvaldo Pavan Junior ( ducasp@gmail.com )
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

#ifndef _ANSDMP_HEADER_INCLUDED
#define _ANSDMP_HEADER_INCLUDED
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../../fusion-c/header/msx_fusion.h"
#include "../../fusion-c/header/asm.h"

//Instructions
const char ucUsage[] = "Usage: ansdmp <file>\r\n\r\n"
                       "<file>: name of file containing ANSI image/animation\r\n\r\n";

//Versions
const char ucSWInfo[] = "> MSX ANSDMP v0.01 <\r\n (c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\r\n\r\n";
const char ucSWInfoANSI[] = "\x1b[31m> MSX ANSDMP v0.01 <\r\n (c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\x1b[0m\r\n";
const char ucCursorOff[] = "\x1bx5";
const char ucCursor_On[] = "\x1by5";

#define BufferMemorySize 32768
__at 0x3000 unsigned char ucBufferMemorySize[BufferMemorySize+1];

unsigned int uiGetSize;

Z80_registers regs; //auxiliary structure for asm function calling

unsigned int IsValidInput (char**argv, int argc, unsigned char *ucFile);
#endif // _ANSDMP_HEADER_INCLUDED
