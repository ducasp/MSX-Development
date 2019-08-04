# TELNET

(c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

It is a TELNET client that allow you to connect to a TELNET server and interact
with it. If used along with MEMMAN and JANSI it will be able to receive and 
show ANSI escape codes / colors. How is it different than TCPCON?

	- It implement TELNET negotiations, as such, echo is used as the other end
	  requests (no need to turn on or off manually), tell terminal type (Dumb
	  if JANSI is not running or xterm 16 colors otherwise), tell window size 
	  as 80x24 if JANSI is not running or 80x25 otherwise). Also will respond
	  to ANSI request to cursor position, some BBS's use this to detect if 
	  terminal is ANSI capable. The first time you hit ENTER, it will stop
          TELNET negotiations to be faster rendering data on screen
	  
	- If using JANSI, ANSI capabilities are automatically detected by most BBSs
	
	- It will use MS-DOS character set, which allow seeing ANSI animations and
	  menus as they are
	
	- It accesses JANSI directly instead of using JANSI built in hook into DOS
	  functions, also it will initialize JANSI if it is installed but screen 
	  mode is not JANSI
	  
	- When possible, instead of sending byte per byte to the screen, will send
	  all data to be printed at once (and in case of JANSI uses DMPSTR function)
	  
	- It supports receiving files through XMODEM CRC, XMODEM 1K CRC, YMODEM and
	  YMODEM-G, including file batch in YMODEM/YMODEM-G
	  
As a result, if you use JANSI it is fast, on an OCM running at turbo speed it
will take almost the same time (11s) as a MSX TURBO-R using built-in telnet
client of GR8NET to draw the MSX boot animation of HISPAMSX BBS. It also draws
menus of ANSI BBSs really really fast at z80 turbo speeds. When using with 
regular z80 speeds it is very usable, taking a couple of seconds to draw ANSI
menus and 30s to draw the MSX boot animation of HISPAMSX BBS. As a reference 
TCPCON with JANSI takes 35s (vs. 11s) to draw HISPAMSX boot at OCM turbo speed
(and it is 85s vs. 30s at regular z80 speeds).	

To use the file download capabilities of this TELNET client, once the server is
ready to send files, press CTRL+B and then type the filename if XMODEM is being
used, or Y if it is a YMODEM transfer, or G for YMODEM-G.

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

JANSI is great when used directly, but its ANSI rendering, even though really
good, is not perfect. HISPAMSX MSX Boot animation won't show the black
rectangle around MSX, when Synchronet BBS's show user login information with
it's avatar, screen is not fully cleared and there is a pause as well. I've
checked that the same occurs with TCPCON. 

File download is very preliminar and there are known issues:

	- Some BBS's seem to not implement YMODEM and YMODEM-G correctly, after 
	  finishing the download of a single file, they should send a packet 0 with
	  no filename to a C or G request, but they exit after sending the only 
	  file. This is an error on their protocol implementation and will cause
	  YMODEM transfers of single files to terminate with an error after writing
	  on the screen transfer succesful. Don't worry, your file is ok
	  
	- I've not been able to test it on many BBS's, so if you have an issue,
	  please tell me which BBS and which file failed
	  
	- Maybe in the future YMODEM-G performance might be better, I won't make
	  any promisses, this is a hobby that I do in my spare time. :) XMODEM 
	  and YMODEM will always suck, sorry, those will send an ACK to the server
	  after receiving a block, so, you have 2x the ping to the server between 
	  each block. Let's say it is using 128 bytes per block, and 100ms ping, 
	  200ms between 128 bytes packets... Yeah, it won't work at great speeds. 
	  Using 1024 bytes packets it gets better, but HISPAMSX as an example will
	  use XMODEM and YMODEM with 128 bytes packets only (slow as you get about
	  512 bytes of data in a second)

Usage: 
telnet server:port [s]

server:port: 192.168.0.1:23 or bbs.hispamsx.org:23

s - Will activate smooth scroll if JANSI is installed, I really don't dig it,
but you can always test it and check if you like it.

Example to connect to rainmaker:

telnet rainmaker.wunderground.com:23

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
