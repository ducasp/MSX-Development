/*
--
-- HUBGmenus.h
--   MSX HUB client using UNAPI for MSX2.
--   Revision 0.1
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2020 Oduvaldo Pavan Junior ( ducasp@gmail.com )
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

#ifndef _HUBGMENUS_HEADER_INCLUDED
#define _HUBGMENUS_HEADER_INCLUDED

//BIG, HUGE, GIGANTIC EXTRA LARGE WARNING!!!!
//Only edit this file on a text editor that supports CP850 or 437, otherwise strings converted to UTF8 will be looking like... meh!

const char chHubGMenu[] = "\x1bx5\x1b[0;31;40m\x1b[2J" //Clear Screen, red on black background
                       "…ÕÕÕÕÕÕÕÕÕÕ\x1b[1;37mMSX HUB Client for MSX2 by DucaSP (ducasp@gmail.com) v0.80\x1b[0;31mÕÕÕÕÕÕÕÕÕÕª"
                       "ÃÕ\x1b[38bÀÕ\x1b[37bπ"
					   "∫\x1b[3;41H∫\x1b[3;80H∫"
					   "ÃÕ\x1b[19bÀÕ\x1b[17b Õ\x1b[37bπ"
					   "∫\x1b[1;37mi\x1b[35mN\x1b[37mfo\x1b[0;31m\x1b[5;22H∫\x1b[5;80H∫"
					   "∫\x1b[6;22H∫\x1b[6;80H∫"
					   "∫\x1b[7;22H∫\x1b[7;80H∫"
					   "∫\x1b[8;22H∫\x1b[8;80H∫"
					   "ÃÕ\x1b[19bπ\x1b[9;80H∫"
					   "∫\x1b[10;22H∫\x1b[10;80H∫"
					   "∫\x1b[11;22H∫\x1b[11;80H∫"
					   "∫\x1b[12;22H∫\x1b[12;80H∫"
					   "∫\x1b[13;22H∫\x1b[13;80H∫"
					   "∫\x1b[14;22H∫\x1b[14;80H∫"
					   "∫\x1b[15;22H∫\x1b[15;80H∫"
					   "∫\x1b[16;22H∫\x1b[16;80H∫"
					   "∫\x1b[17;22H∫\x1b[17;80H∫"
					   "∫\x1b[18;22H∫\x1b[18;80H∫"
					   "∫\x1b[19;22H∫\x1b[19;80H∫"
					   "ÃÕ\x1b[19b Õ\x1b[56bπ"
					   "∫\x1b[21;80H∫"
					   "ÃÕÀÕ\x1b[75bπ"
					   "∫\x1b[23;3H∫\x1b[23;80H∫"
					   "»Õ Õ\x1b[75bº";
const char chLocalSelected[] =	"\x1b[3;13H\x1b[1;30;47mLOCAL  OPERATIONS\x1b[3;52H\x1b[40;35mR\x1b[37mEMOTE  OPERATIONS\x1b[6;2He\x1b[35mX\x1b[37m\x1b[8;2H      \x1b[6;4Hclude \x1b[7;2H\x1b[35mU\x1b[37mpgrade";
const char chRemoteSelected[] =	"\x1b[3;13H\x1b[1;40;35mL\x1b[37mOCAL  OPERATIONS\x1b[3;52H\x1b[30;47mREMOTE  OPERATIONS\x1b[6;2H\x1b[1;40;37min\x1b[40;35mS\x1b[37mtall  \x1b[7;2H\x1b[35mU\x1b[37mpgrade";
const char chClearInfoWindow[] = "\x1b[0;31;40m\x1b[5;23H\x1b[K\x1b[5;80H∫\x1b[6;23H\x1b[K\x1b[6;80H∫\x1b[7;23H\x1b[K\x1b[7;80H∫\x1b[8;23H\x1b[K\x1b[8;80H∫"
								 "\x1b[9;23H\x1b[K\x1b[9;80H∫\x1b[10;23H\x1b[K\x1b[10;80H∫\x1b[11;23H\x1b[K\x1b[11;80H∫\x1b[12;23H\x1b[K\x1b[12;80H∫"
								 "\x1b[13;23H\x1b[K\x1b[13;80H∫\x1b[14;23H\x1b[K\x1b[14;80H∫\x1b[15;23H\x1b[K\x1b[15;80H∫\x1b[16;23H\x1b[K\x1b[16;80H∫"
								 "\x1b[17;23H\x1b[K\x1b[17;80H∫\x1b[18;23H\x1b[K\x1b[18;80H∫\x1b[19;23H\x1b[K\x1b[19;80H∫";
const char chClearCategoriesWindow[] = "\x1b[0;31;40m\x1b[10;2H                   \x1b[11;2H                   \x1b[12;2H                   "
										"\x1b[13;2H                   \x1b[14;2H                   \x1b[15;2H                   "
										"\x1b[16;2H                   \x1b[17;2H                   \x1b[18;2H                   \x1b[19;2H                   ";
const char chClearBothStatusWindows[] = "\x1b[0;31;40m\x1b[21;3H\x1b[K\x1b[21;80H∫\x1b[23;4H\x1b[K\x1b[23;80H∫";
const char chIconOn[] = "\x1b[23;2H\x1b[1;32;40m*";
const char chIconOff[] = "\x1b[23;2H\x1b[0;31;40m ";
const char chClearBarWindow[] = "\x1b[0;31;40m\x1b[23;4H\x1b[K\x1b[23;80H∫";
#endif // _HUBGMENUS_HEADER_INCLUDED
