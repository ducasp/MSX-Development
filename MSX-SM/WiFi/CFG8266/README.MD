# CFG8266

Simple Tool to Scan Networks / Configure Parameters / Update Firmware of ESP
in your MSX-SM / SM-X

Now telling about how to configure WiFi and some parameters:

	Use CFG8266.COM (it is in WIFI folder, that should be on your PATH as well)
	
	To connect to your router/access point:
		CFG8266.COM /S 
	It will scan available networks, list up to 10, and you can choose it. If
	a password is required, it will be requested (password is SHOWN on screen).
	
	To change Nagle Algorithm and turn it on (default is off once powered up):
		CFG8266.COM /M
	To turn Nagle Algorithm off:
		CFG8266.COM /N
	About Nagle Algorithm: basically it will hold sending data over network
	until the previous data has been ACKed or a certain treshold of data size
	waiting to be sent is reached. As an example, FTP will send data, and even
	though it has already requested a second packet to be sent, that packet 
	won't be sent until the ACK from the server telling it has received the 1st
	packet is received. This might hurt performance on connections with high
	latency as well on connections with computers/servers that use delayed ACK
	(i.e.: Windows uses 250ms delayed ACK, so it won't send back the ACK until
	a second package is received or 250ms have passed. In this case, our side
	with Nagle On is waiting ACK before sending the second package... End result
	is that you end-up transferring only 4 packets per second no matter how
	fast your MSX and Internet Connection are.
	On the other hand Nagle might be handy for certain applications that send
	several small packets (i.e.: telnet). So, you have the option to turn Nagle
	On to try to improove performance on some applications.

Copyright (c) 2019 Oduvaldo Pavan Junior ( ducasp@ gmail.com )
All rights reserved.

A simple terminal console where what you type is sent to the ESP and what
the ESP send back is put on screen. Useful to toy around with it and see
how it works with AT commands or testing concepts. 

Requires WiFiMSXSM, SDCC and Fusion-C library to compile

Redistribution and use of this source code or any derivative works, are
permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Redistributions may not be sold, nor may they be used in a commercial
   product or activity without specific prior written permission.
4. Source code of derivative works MUST be published to the public.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
