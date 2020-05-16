# MSX2ANSI Library Source Code

MSX2ANSI is based on ANSI-DRV.BIN, an amazing piece of software by Tobias Keizer!

It is a very, very, very fast ANSI COLOR Text Rendering engine for MSX2 and beyond.

It is a SDCC library that can be freely used on any MSX2 or higher project. :)

It has the following features:

- Supports all ANSI commands expected for a 16 color ANSI terminal, as defined
  in http://ansi-bbs.org/ansi-bbs-core-server.html (even though it supports all
  commands, it doesn't support all renditions modes, Dim intensity and Blink 
  are not supported and won't change rendition), blink might be supported at
  some point, but faint won't ever be supported (G6 mode of V9938 is needed and
  it only supports a 16 colors palette, we would need at least 24 colors 
  palette for that extra set of colors)
- Supports some VT-52 terminal commands
- Supports attaching a callback function to handle sending cursor position information
- Supports a sprite cursor

As an usage example, check my TELNET terminal source code:

https://github.com/ducasp/MSX-Development/tree/master/UNAPI/TELNET

All source code and binaries: 
(c)Tobias Keizer (original version of ANSI-DRV.BIN)
(c)2019-2020 Oduvaldo Pavan Junior - ducasp@gmail.com (modified version, adding sprite cursor and fixing a few bugs and adding some features, remember, all hard work on the rendering engine was done by Toby!)

Thanks to Piter Punk for his contributions on making msx2ansi better suited to present text from Linux daemons!

All code can be re-used, re-written, as long as the source code of changes is made public as well and the original authors are credited.
