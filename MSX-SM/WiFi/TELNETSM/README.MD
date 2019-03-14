# TELNETSM

(c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

It is a simple TELNET client that allow you to connect to a TELNET server and 
interact with it. If used along with JANSI/J_ON/MEMMAN it will be able to 
receive and show ANSI escape codes / colors.

It supports receiving files through XMODEM CRC, XMODEM 1K CRC and YMODEM (do
not mistake it for YMODEM-g), including file batch in YMODEM.

Once the server is ready to send files, press CTRL+B and then type the filename
if XMODEM is being used, or Y if it is a YMODEM transfer.

Usage: 
telnetsm server:port [/sSPEED] [/mMODE] [/r]

server:port: 192.168.0.1:23 or bbs.hispamsx.org:23

/s force using a given baudrate to communicate with ESP:
/s0 - 115200, /s1 - 57600, /s2 - 38400 /s3 - 31250 /s4 - 19200
/s5 - 9600 /s6 - 4800 /s7 - 2400

***WARNING***

FIFO being FULL will most likely occur if you change speed. This program will
perform about 3000 I/O per sec. More than that, FIFO can be filled before we
can get its data out. 31250 for turbo CPU and 19200 for regular CPU is my
recommendation

/m0 - Single Connection /m1 - Multiple Connection

Example to connect to rainmaker:

telnetsm rainmaker.wunderground.com:23


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
