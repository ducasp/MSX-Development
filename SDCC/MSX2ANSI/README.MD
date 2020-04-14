# MSX2ANSI

MSX2ANSI is based on ANSI-DRV.BIN, an amazing piece of software by Tobias Keizer!

It is a very, very, very fast ANSI COLOR Text Rendering engine for MSX2 and beyond.

It is a SDCC library that can be freely used on any MSX2 or higher project. :)

It has the following features:

- Supports most ANSI commands for a 16 color ANSI terminal
- Supports most VT-52 terminal commands
- Supports attaching a callback function to handle sending cursor position information
- Supports a sprite cursor

As an usage example, check my TELNET terminal source code:

https://github.com/ducasp/MSX-Development/tree/master/UNAPI/TELNET

# MSX2ANSI v1.4

When "printing" character 7 (BELL) now it BEEPs properly

# MSX2ANSI v1.3

Character 16 was not correct, fixed that

Piter Punk contributed with a fix for CSIm (no paramters), fixing a crash and a non-standard behavior

Piter Punk contributed with support for reverse colors mode

# MSX2ANSI v1.2

Added ESCx5 (turn off cursor) support
Added ESCy5 (turn on cursor) support
If a character is below 0x20 and not a screen control code, print it
Fix characters code 16, 17, 24, 25, 26, 27, 30 and 31
Probably not all characters below 0x20 (32) are correct... And it is very hard to achieve it with 6 pixels wide font


# MSX2ANSI v1.1

Fixed CSI J behavior when no parameter / 0 was choosen
Added CSI 1 J and CSI 2 J support
Fixed behavior when no parameters were given (it was not always correct)
Added CSI n P support for Linux telnet daemons

All source code and binaries: 
(c)Tobias Keizer (original version of ANSI-DRV.BIN)
(c)2019 - 2020 Oduvaldo Pavan Junior - ducasp@gmail.com (modified version, adding sprite cursor and fixing a few bugs and adding some features, remember, all hard work on the rendering engine was done by Toby!)

Thanks to Piter Punk for his contribution on fixing CSIm behavior!

All code can be re-used, re-written, as long as the source code of changes is made public as well and the original authors are credited.
