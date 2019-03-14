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