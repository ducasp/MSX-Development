# TELNET BINARY PACK WITH JANSI

(c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

This pack includes MEMMAN and JANSI as well as TELNET.

As far as I know those are free and it is ok to distribute.

If you have a MSX2/2+ with KANJI rom, you can use JANSI by
calling ANSI.BAT before executing TELNET.

P.s.: MEMMAN loads in BASIC, and by going to BASIC and then
returning to DOS, all your environment variables like PATH
will be lost... :)

# TELNET v0.80

(c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

# CHANGELOG

	- Fix the program crashing when receiving two bytes TELNET commands. We do
	  not execute those, but need to properly parse. It no longer crashes if
	  you log-in at HISPAMSX and leave it logged/untouched
	  
	- Fix on X/YMODEM(G) transfers corrupting some bytes of data
	
	- Enhancement on YMODEM(G) performance, got up to 8KB/s using MSX-SM WiFi
	  UNAPI adapter
	  
	- Some BBSs allow the Telnet Client to know that a transfer is in progress
	  by sending Telnet command WILL TRANSFER_BINARY. Now this client is able
	  to recognize it and it will pop-up the transfer protocol selection 
	  automatically. If the BBS do not send WILL TRANSFER_BINARY, you still 
	  can invoke the transfer protocol selection
	  
	- Fix YMODEM/YMODEM-G not detecting the end of a batch or single file
	  transfer properly. Now it detects properly. Exception is HISPAMSX when
	  using YMODEM-G (you need to lie to it telling you want YMODEM as it does
	  not list YMODEM-G as an option, so you tell it you are going to download
	  YMODEM, configure your user options with YMODEM as preferred protocol, 
	  and when downloading a batch ou single file choose YMODEM but on the 
	  telnet client you choose YMODEM-G and the transfer will occur as YMODEM
	  G, which is a blessing as XMODEM and YMODEM use 128 bytes long blocks at
	  HISPA which is really slow, not sure why they do not enable 1K blocks)
	  
	- ESC no longer quits the program, as this key might be requested to 
	  interact with some BBSs. Now, to quit the program hit CTRL+E
	  
	- It should now work fine with MSX1 as long as you have an UNAPI adapter 
	  that works with it. It will understand that it is a MSX1 and not try to
	  set 80 columns mode, but set it to 40 columns if less are set. Also, on
	  MSX 2/2+/TR it will set the screen to 80 columns if less are set and 
	  jANSI is not installed (with jANSI, it always use 80x25). BBSs will be
	  aware that terminal is 40x24 or 80x24. Also, if you have a MSX-1 with
	  an 80 columns adapter that reports properly the number of columns in use,
	  this software will not try to change anything so it should work on those
	  as well
	  
	- Instead of returning the real cursor position on 6n escape code, it will
	  return 25x80 as some BBSs use this information to determine terminal 
	  window size
	  
	- Not really an update, it was alway like that, but just making sure it is
	  clear, jANSI/MEMMAN is not mandatory. It will work without it, but it is
	  not going to tell the other end it is ANSI and of course colors and ANSI
	  animations won't work. 	

# DESCRIPTION

This is a TELNET client that allow you to connect to a TELNET server / BBSs and
interact with it. If used along with MEMMAN and JANSI it will be able to 
receive and show ANSI escape codes / colors. It should be MSX1 friendly as long
as your UNAPI adapter is compatible with MSX1.

How is it different than TCPCON? Why not keep using it?

	- It implement telnet negotiations, as such, echo is used as the other end
	  requests (no need to turn on or off manually), tell terminal type (Dumb
	  if jANSI is not running or xterm 16 colors otherwise), tell window size 
	  as 40x24 (MSX1) or 80x24 if jANSI is not running or 80x25 otherwise)
	  
	- If using JANSI, ANSI capabilities are automatically detected by most BBSs
	  either by telnet negotiation of Window Size or responding to ANSI request
	  to cursor position (some BBS's use this to detect if terminal is ANSI 
	  capable, this is done only once or until enter is pressed so performance
	  is not impacted by analyzing it along with other ANSI escape codes)
	
	- It will use MS-DOS character set, which allow seeing ANSI animations and
	  menus as they are
	
	- It accesses jANSI directly instead of using jANSI built in hook into DOS
	  functions. Also it will initialize jANSI if it is installed but screen 
	  mode is not jANSI, and it is possible to active jANSI smooth scroll mode
	  
	- Will send all data to be printed at once once it is received and not do
	  it byte per byte (and in case of jANSI uses DMPSTR function)
	  
	- It supports receiving files through XMODEM CRC, XMODEM 1K CRC, YMODEM and
	  YMODEM-G, including file batch in YMODEM/YMODEM-G
	  
As a result, if you use jANSI it is fast, on an OCM running at turbo speed it
will take almost the same time (12s) as a MSX TURBO-R using built-in telnet
client of GR8NET to draw the MSX boot animation of HISPAMSX BBS. It also draws
menus of ANSI BBSs really really fast at z80 turbo speeds. When using with 
regular z80 speeds it is very usable, taking a couple of seconds to draw ANSI
menus and 30s to draw the MSX boot animation of HISPAMSX BBS. As a reference 
TCPCON with jANSI takes 35s (vs. 11s) to draw HISPAMSX boot at OCM turbo speed
(and it is 85s vs. 30s at regular z80 speeds).	

# USAGE

telnet server:port [s]

server:port: 192.168.0.1:23 or bbs.hispamsx.org:23

s - Will activate smooth scroll if jANSI is installed, I really don't dig it,
but you can always test it and check if you like it.

Example to connect to rainmaker:

telnet rainmaker.wunderground.com:23

Most keys and CTRL+KEY combinations are sent to the telnet server, exceptions
are CTRL+E (Exit the telnet client) and CTRL+B (Begin File Transfer).

To use the file download capabilities of this telnet client, once the server is
ready to send files, press CTRL+B and then type the filename if XMODEM is being
used, or Y if it is a YMODEM transfer, or G for YMODEM-G. On some servers (i.e.
Synchronet BBSs) you do not need to do this as they send a telnet command that
warns a binary data transfer is starting, so the list of protocol options pops
up automatically.

My recommendation is YMODEM-G, it is way faster due to not having to wait for
client confirmation before sending the next packet. Most BBS's, like HISPAMSX,
even though not listing YMODEM-G as an option, will use YMODEM-G if you choose
YMODEM at the BBS end and YMODEM-G after pressing CTRL+B.

***WARNING***

I just have an OCM like MSX ( MSX-SM by Victor Trucco ) and I'm using its built
in WiFi capabilities with a customized ESP8266 firmware and an UNAPI driver 
made by me. So I've not tested it with other UNAPI adapters like OBSONET,
GR8NET and DENYONET, but in theory it should work fine. :)

***KNOWN ISSUES***

jANSI is great when used directly, but its ANSI rendering, even though really
good, is not perfect. HISPAMSX MSX Boot animation won't show the black
rectangle around MSX, when Synchronet BBS's show user login information with
it's avatar, avatar and some information is misaligned fully cleared and there
 is a pause as well. I've checked that the same occurs with TCPCON. 
	
	- XMODEM and YMODEM(G) transfers are a work in progress, at this moment it
	  works on some BBSs, on others it just error. If you get errors, let me 
	  know the file/BBS.
	- XMODEM and YMODEM performance will generaly always suck, sorry! Those 
	  will send an ACK to the server after receiving a block, and the server
	  will wait receiving the ACK before sending the next block, so, you have
	  2x the ping to the server between each block. Let's say it is using 128 
	  bytes per block, and 100ms ping, 200ms between 128 bytes packets... Yeah,
	  it won't work at great speeds. Using 1024 bytes packets it gets better, 
	  but HISPAMSX as an example will use XMODEM and YMODEM with 128 bytes 
	  packets only. (I have a 180ms ping to HISPA server, so in my case this 
	  means ~350 bytes per second!) Use YMODEM-G if possible, it streams and 
	  is not ping/lag dependent, and most BBSs, even if not listing YMODEM-G,
	  work with it if you choose YMODEM at BBS side and YMODEM-G on the MSX
	  side. 

***IMPORTANT COMPILATION NOTES***

Remember to copy the files in fusion-c\lib and fusion-c\header to your fusion-c lib and header folders!
I recommend using Code::Blocks, it is a full featured UI that will allow you to check references, etc.

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
