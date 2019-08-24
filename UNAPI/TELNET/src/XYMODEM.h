/*
--
-- XYMODEM.h
--   X/YMODEM(G) for UNAPI Telnet Terminal.
--   Revision 0.80
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

#ifndef _XYMODEM_HEADER_INCLUDED
#define _XYMODEM_HEADER_INCLUDED

/*
 * This implementation of X/Y MODEM doesn't CRC check packets during downloads
 * Mostly for three reasons:
 *
 * 1 - A few BBSs send bad CRC's not following the right CRC approach
 * 2 - Packet won't be corrupted, TCP takes care of that
 * 3 - CRC Check can be very intensive on a z80
 *
 * Thus, this implementation is meant to be used on TCP connections and do not
 * implement CRC checks.
 *
 */

//Defines for X and YMODEM
#define SOH 0x01
#define STX 0x02
#define EOT 0x04
#define ACK 0x06
#define NAK 0x15
#define ETB 0x17
#define CAN 0x18

__at 0xFC9E unsigned int uiTickCount;

char *ultostr(unsigned long value, char *ptr, int base);
unsigned char XYModemPacketReceive (int *File, unsigned char Action, unsigned char PktNumber, unsigned char isYmodem);
void CancelTransfer(void);
void XYModemGet (unsigned char chConn, unsigned char chTelnetTransfer, unsigned char uchAnsi);
int GetPacket(unsigned char * ucPacket, unsigned char * ucIs1K);
int ParseReceivedData(unsigned char * ucReceived, unsigned char * ucPacket,  unsigned int uiIndex, unsigned int uiReceivedSize, unsigned char * ucIs1K);
#endif // _XYMODEM_HEADER_INCLUDED
