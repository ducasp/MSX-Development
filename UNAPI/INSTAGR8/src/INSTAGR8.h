/*
--
--   INSTAGR8, but for UNAPI, not only GR8NET
--   Revision 0.20
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2020 Oduvaldo Pavan Junior ( ducasp@gmail.com )
-- Totally based on the GR8 work of Thomas F. Glufke
-- https://github.com/glufke/instagr8
-- And totally dependent on his server being UP as well
--
-- What I means is: I've just converted his BASIC client that works only with
-- GR8NET on a MSX-DOS2 client that works with ANY UNAPI adapter
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

#ifndef _INSTAGR8_HEADER_INCLUDED
#define _INSTAGR8_HEADER_INCLUDED
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../../fusion-c/header/msx_fusion.h"
#include "../../fusion-c/header/asm.h"
#include "../../fusion-c/header/vdp_graph1.h"
#include "hgetlib.h"

//Where we will allocate memory for hget
#define HI_MEMBLOCK_START 0xC000

__at 0xFC9E unsigned int TickCount;

const unsigned char uciGr8ServerQuery[]="http://glufke.ddns.net:8080/instagr8.url";
unsigned char ucInstaGR8Session[6];
unsigned char ucInstaGR8Server[128];
unsigned char ucInstaGR8UserInput[128];
unsigned char ucInstaGR8HttpRequest[256];
unsigned char ucInstaGR8ServerRequest[256];
unsigned char ucInstaGR8Description[130];
Z80_registers regs; //auxiliary structure for asm function calling
unsigned char ucIsMSX2;
unsigned char ucIsFirstCall;
unsigned int uiSessionIndex;

void exitsetup();
unsigned char instagr8queryserver(unsigned char *ucServerString, unsigned int uiBufferSize);
void instagr8menu(unsigned char *ucUserInput, int iMaxLen);
unsigned char instagr8startsession(unsigned char *ucUserInput);
void SC2RcvChrCallBack(char *rcv_buffer, int bytes_read);
void SC2RcvClrCallBack(char *rcv_buffer, int bytes_read);
#endif // _INSTAGR8_HEADER_INCLUDED
