# CFG8266 v1.30

Simple Tool to Scan Networks / Configure Parameters / Update Firmware of ESP
in your MSX-SM / SM-X

CAUTION!!!! The following options:

	/T
	/N
	/M

Change FLASH memory contents! So, DO NOT, and I repeat just in case, DO NOT
have those options in your AUTOEXEC routines or Multimente, etc... There is
absolutely NO NEED to do so, the last value set will be saved and restored when
device is powered on again, and you do not want to end up with a bad flash
memory on your ESP!!! Flash Memory has 10000 write cycles or less, it is more
than enough to you to not worry using it at will to change those parameters
when you feel you need something different (i.e.: if you change it once a day
it will take 30 years to wear out Flash Memory). But if you have in autoexec
and will turn on your SM-X 10 times a day, this goes down to 3 years...

Now telling about how to configure WiFi and some parameters:

	Use CFG8266.COM (it is in WIFI folder, that should be on your PATH as well)

	To connect to your router/access point:
		CFG8266.COM /S 
	It will scan available networks, list up to 10, and you can choose it. If
	a password is required, it will be requested (password is SHOWN on screen).

	To turn off WiFi radio immediately (FW 1.00 or newer):
		CFG8266.COM /O

	To change the WiFi radio On time-out to 1 minute (FW 1.00 or newer):
		CFG8266.COM /T 60

	To disable the WiFi radio On time-out (always on, FW 1.00 or newer):
		CFG8266.COM /T 0

	About WiFi radio off/time-out:
	Some revisions of SM-X unfortunatelly suffer from interference of the WiFi
	radio of ESP8266 on the audio output. My version doesn't, so I've never
	thought about turning WiFi off, no reason whatsoever. But later I was made
	aware of that by Victor Trucco and KdL and worked on this solution. Using
	the ESP8266 firmware version 1.00 or newer, if no command is received when
	turning ESP8266 on, it won't connect to WiFi, once a command is received,
	WiFi radio will be turned on for at least 2 minutes. After 2 minutes of
	inactivity, if no connections are open, it will turn WiFi radio off.

	If the driver is not loaded, no command is sent, so interference won't
	happen at all. Timeout can be changed back to always on (0) or a different
	time-out in seconds (i.e.: 30 to 30 seconds, up to 600 meaning 10 minutes).

	Also, I know I lot of people just use WiFi to simply set the time/clock of
	SM-X using SNTP, so, I've added an option to stop the radio immediatelly,
	so you just need to add CFG8266.COM /O as the last command of your AUTOEXEC
	batch file.

	I recommend leaving the default setting of 2 minutes for automatic disable
	and, add CFG8266.COM /O as the last command of your AUTOEXEC routine (that
	probably has two batch files, so the last one, as one is responsible for
	loading RAMHELPR and then invoking the second BAT file), so if you are not
	using network applications, noise won't bother you, if you do, radio will
	turn on. I also recommend using WAITWIFI.COM before using a network
	application in such scenario, most applications (HUB, HUBG, TELNET) will
	work just fine, while others, that do not call DNS functions or use UDP or
	local addresses might give an error on the first try. This is because the
	WiFi is off and even though it turns on on the first command, it takes a
	while to connect to the router again, WaitWifi will do that and then you
	can call the application within 2 minutes and be asured it will work first
	time (or, you can wait a few seconds after failure and try again). This is
	a minor nuisance for few applications (i.e.: HGET, or TFTP when using an
	IP address that needs no DNS resolution) and you can always go back to the
	previous behavior by turning this off at all, CFG8266 /T 0.

	P.s.: even though you can try any value, ESP will accept 0 (do not turn off
	automatically) and 30 - 600 (30 seconds to 10 minutes). Values between the
	range from 1 to 29 will be adjusted to 30 seconds, and larger than 600 will
	be adjusted to 600 seconds. A too small time-out might cause undesirable
	application behavior.

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

Copyright (c) 2019-2020 Oduvaldo Pavan Junior ( ducasp@ gmail.com )
All rights reserved.

Requires SDCC and Fusion-C library to compile

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
