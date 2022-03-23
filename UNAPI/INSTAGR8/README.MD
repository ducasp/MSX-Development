# INSTAGR8 v0.20

(c)2020 Oduvaldo Pavan Junior - ducasp@gmail.com
(c)2020 Thomas F. Glufke - https://github.com/glufke/instagr8

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)
# CHANGELOG v0.20

	- First release of INSTAGR8, an Instagram Viewer that is a client of the
	  InstaGR8 server that Thomas F. Glufke created. That server was created
	  along with InstaGR8 basic program by Thomas F. Glufke as well. Unlike the
	  MSX Basic program that works only with GR8NET, this one works with any 
	  MSX Network Adapter as long it is TCP-IP Unapi compatible

# DESCRIPTION

This is an Instagram Viewer based on INSTAGR8 MSX Basic software that is a
client to Glufke's server. His server will translate instagram pictures into
MSX1 Screen2 or MSX2 Screen 8 compatible images. Those images, along with a
few characters of the image description are shown on screen. This MSX-DOS
client of InstaGR8 server has the advantage of not needing GR8NET, working on
ObsoNet, Denyonet, SM-X WiFi, GR8NET and any other adapter for MSX that is 
TCP-IP UNAPI Compliant.
	
As it doesn't rely on GR8NET specific API, it is not possible to show the 
picture as fast as original Glufke program does. This is because GR8NET simply 
store the whole image in its own buffer and then transfer directly to VRAM. 
Meanwhile, in this program case, it needs to handle all the HTTP protocol to 
receive files, and fill the VRAM as it receives every 512 bytes or 1024 bytes, 
depending on your adapter TCP-IP buffer. If we are talking more specifically 
about Obsonet, then it is well known that it is not capable of much more than a
couple KB/s transfers, and a Screen 8 picture is 53KB large, that means it will
take quite a bit to finish a single image. On SM-X, that has a fully 
accelerated network stack, it is pretty fast, taking a couple of seconds. Now,
for MSX1 images, those have 12KB, so loading times are faster.

# USAGE

It is pretty simple, a screen asking for the instagram user name (without @) or
a hashtag (including the #). I.e.: to access Glufke's Instagram, type glufke 
and enter, to access One Piece related pictures, type #onepiece.

By default, the program will use the best quality available, if you have a MSX2
and want to see the same image in MSX1 mode or want faster transfers, you can
enter MSX1 mode by hitting 1 in your keyboard while viewing an image, and you
can return to MSX2 mode by hitting 2 in your keyboard while viewing an image.

If you hit the right arrow, Instagr8 will request and load the next image, if
you hit ESC, you will return to the menu to enter username or hashtag, any key
other than ESC, 1, 2 and right arrow will exit the program.

***WARNING***

I just have an OCM like MSX ( SM-X by Victor Trucco ) and I'm using its built
in WiFi capabilities with a customized ESP8266 firmware and an UNAPI driver 
made by me. My other option to test this is using BlueMSX OBSONET emulation. So
I've not tested it with other UNAPI adapters, but it should work fine. :)

***KNOWN ISSUES***

	- It seems that glufke's server sometimes fail to translate an image, i.e.:
	  it is not working if trying to access my Instagram account, and it does
	  not generate the files, in such cases the program will exit
	  
	- This program doesn't remember your previous width/screen mode/colors, so
	  it will basically use width 80, screen 0, black and white for MSX2 and 
	  width 40, screen 0, black and white for MSX1 when exiting

***IMPORTANT***

I want to say THANK YOU to glufke, the creator of InstaGR8 basic software as 
well the server that translates images, and making all this open source. This
is what allowed this Instagram Viewer to exist. Parts of the code are based
on his Instagr8 software and I've tried to kept it faithful to his vision of
user interface and how the program works.

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
