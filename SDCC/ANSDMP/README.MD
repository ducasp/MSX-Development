# ANSDMP v0.10

(c)2019 - 2022 Oduvaldo Pavan Junior - ducasp@gmail.com

# FIRST RELEASE v0.10

    - This is a simple dumper of files following ANSI 16 colors encoding to
      the screen of a MSX2 or better.
      It will wait for a key to be pressed after finishing, and it will show
      how many VDP ticks occurred (each one is 1/50s for PAL or 1/60s for NTSC)
      since it started presenting the file. This is a really simple and just to
      show a way to handle interrupts with SDCC easily and also to serve as an
      example of usage of MSX2ANSI sdcc library.


# DESCRIPTION

This is a simple dumper of files following ANSI 16 colors encoding to the
screen of a MSX2 or better. It will wait for a key to be pressed after
finishing, and it will show how many VDP ticks occurred (each one is 1/50s for
PAL or 1/60s for NTSC) since it started presenting the file. This is a really
simple and just to show a way to handle interrupts with SDCC easily and also to
serve as an example of usage of MSX2ANSI sdcc library.


# USAGE

ansdmp filename.ext

***IMPORTANT COMPILATION NOTES***

Remember to copy the files in fusion-c\lib and fusion-c\header to your fusion-c
lib and header folders!
I recommend using Code::Blocks, it is a full featured UI that will allow you to
check references, etc.

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
