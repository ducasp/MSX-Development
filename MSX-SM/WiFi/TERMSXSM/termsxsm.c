/*
--
-- termsxsm.c
--   Simple terminal to send/receive data to ESP8266 of your MSX-SM. 
--   Revision 0.90
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2019 Oduvaldo Pavan Junior ( ducasp@ gmail.com )
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
#include "fusion-c/header/msx_fusion.h"
#include "WiFiMSXSM.h"

int main(char** argv, int argc)
{
	char tx_data = 0;
	char rx_data;
	unsigned char speed,ret;
	ClearUartData();

	Print("> MSX-SM ESP8266 WIFI Module Serial Terminal v0.90<\n(c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\nHit ESC to exit\n");
	
	speed = FindBaudRateWiFi();
	ret = SetBaudRateWiFi(speed);
	if (ret == RET_WIFI_MSXSM_OK)
	{
		do
		{			
			if (KeyboardHit())
			{ 
				tx_data = InputChar ();
				if ((tx_data == 13)||(tx_data>31))
					PrintChar(tx_data);
				TxByte(tx_data);
				if (tx_data == 13) //enter?
				{
					TxByte (10); // send LF
				}
			}
			
			if (UartRXData())
			{
				rx_data = GetUARTData();
				if ((rx_data == 10)||(rx_data>31))
					PrintChar (rx_data);
			}
		} 
		while (tx_data != 0x1b);
	}
	else
		Print("Couldn't find ESP8266, exiting...");

	return 0;
}
