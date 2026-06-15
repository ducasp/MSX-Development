# SSH v1.00

(c)2019-2026 Oduvaldo Pavan Junior - ducasp@gmail.com


[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

# CHANGELOG v1.00
    - Base is Telnet 1.34
    - Support to Keyboard Interactive, User public key, anonymous and regular
      username/password authentication
    - Support to filter OSC escape codes
    - Support MSX 1 (why? not sure, but it does)

# DESCRIPTION

This is a SSH PTY client that allow you to connect to a SSH server / BBSs and
interact with it. If an MSX2 or better is used, it will be able to receive and 
show ANSI escape codes / colors. It should be MSX1 friendly as long as your 
UNAPI adapter is compatible with MSX1.

# USAGE

ssh server:port [a] [k] [n] [p] [o] [r] [C]

server:port: 192.168.0.1 or conchaos.synchro.net

(NOTE: :port is optional, and if it is not provided, will assume default ssh port,
22)

a - Will try anonymous connection, even though documment I don't think any place
supports it.

k - Keyboard Interactive authentication.

n - Disables usage of non-ANSI escape sequence filtering if implementation has it.

p - public key authentication, uses the key loaded or generated in the implementation
to authenticate the user

o - turns off ANSI rendering and uses MSX DOS text rendering (slow, no colors,
why someone would do it on a MSX2 or better? :)

r - if downloads do not work, try using this key, synchronet BBSs unfortunately seem to
not like the timing of MSX and they do not work no matter what.

c - turns off custom CP437 that is loaded ONLY when a MSX1 is detected

Most keys and CTRL+KEY combinations are sent to the shell.

To exit the program, press F5.

By default, echo is OFF. If for some reason that do not work, you can press F2 to change
the current echo state.

By default, program will send only CR upon pressing ENTER. If that doesn't work
for the server/BBS you are using, press F3 to change this behavior (there are
two possible behaviors: default, send only CR, non-default, send CR-LF).

To use the file download capabilities of this ssh client, once the server is
ready to send files, press F1 and then type the filename if XMODEM is being
used, or Y if it is a YMODEM transfer, or G for YMODEM-G. On recent Synchronet BBSs this
feature do not seems to be working fully.

My recommendation is YMODEM-G, it is way faster due to not having to wait for
client confirmation before sending the next packet. Most BBS's, like HISPAMSX,
even though not listing YMODEM-G as an option, will use YMODEM-G if you choose
YMODEM at the BBS end and YMODEM-G after pressing CTRL+B.

***KNOWN ISSUES***

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
You will need the following libraries:

    - Konamiman's ASM.LIB ( https://www.konamiman.com/msx/sdcc/asmlib.zip )
    - Oduvaldo & Tobias Keizer MSX2ANSI.LIB ( https://github.com/ducasp/MSX-Development/tree/master/SDCC/MSX2ANSI )

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
