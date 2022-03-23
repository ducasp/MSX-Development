# TELNETSM

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

(c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

It is a TELNET client that allow you to connect to a TELNET server and interact
with it. If used along with JANSI/J_ON/MEMMAN it will be able to receive and 
show ANSI escape codes / colors.

It supports receiving files through XMODEM CRC, XMODEM 1K CRC, YMODEM and
YMODEM-G), including file batch in YMODEM/YMODEM-G.

Once the server is ready to send files, press CTRL+B and then type the filename
if XMODEM is being used, or Y if it is a YMODEM transfer, or G for YMODEM-G.

My recommendation is YMODEM-G, it is way faster due to not having to wait for
client confirmation before sending the next packet.

In order to allow YMODEM-G high performance, this program will check for a 
RAMDISK or create a 2MB RAMDISK. It will be used to store the files. This is 
needed as MSX-DOS2/NEXTOR takes several seconds to calculate free disk space
on large partitions (in my 4GB Card it takes more than 4s!). The first write
to any file or whenever the disk buffer is fully flushed will check for 
available disk space, that means, in YMODEM-G when several 1K packages are
being sent, we are locked waiting the first block to be written. This make it
impossible to use such partitions to store YMODEM-G transfers (and make other
transfers to suffer delays) as the server will send packets, those will go to
the ESP, ESP will transfer to MSX-SM FIFO and it will be filled even before
the first block has been written to disk. As most MSX-SM users will have large
SD-CARDs with large partitions, this is the best option to overcome this. As
such, transfer file size or total batch transfer size is limited to 2MB.

***WARNING***

Make sure that after exiting the program, you copy data from RAMDISK (H:) to
your local disk. This program will be kind enough to warn you about that when
you exit.

Usage: 
telnetsm server:port [/sSPEED] [/r]

server:port: 192.168.0.1:23 or bbs.hispamsx.org:23

/s force using a given baudrate to communicate with ESP:
/s0 - 115200, /s1 - 57600, /s2 - 38400 /s3 - 31250 /s4 - 19200
/s5 - 9600 /s6 - 4800 /s7 - 2400

***WARNING***

FIFO being FULL will most likely occur if you change speed. This program will
perform about 3000 I/O per sec. More than that, FIFO can be filled before we
can get its data out. 31250 for turbo CPU and 19200 for regular CPU is my
recommendation

/r will list available access points so you can connect to a different one even
if ESP has connected automatically to other access point.

Example to connect to rainmaker:

telnetsm rainmaker.wunderground.com:23

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
