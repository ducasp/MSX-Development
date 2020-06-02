# MSX2ANSI

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

# MSX2ANSI v1.7: 

Piter Punk provided the following fixes:

Fix on Backspace behavior, when called as sub on the first column it was not
behaving properly, causing the code to wander a print garbage
Fix on ErDis1, wrong opcodes used and it was not multiplying A contents
Fix on DO_HMMV, when doing a second pass, the second run would add the line
offset again in DYL, being that the value was already adjusted

And I have done this:

Minor improvments on unnecessary returns and unnecessary loading of parameters
that do not change at all
Fix on LineFeed, the previous version would always return cursor column to 0
on LF which was not correct
Ugly hack to fix Insert and Delete lines, work for now, beautyful code might
come in another release :)

# MSX2ANSI v1.6: 

Piter Punk provided an initial support to ANSI DL (Delete Lines)

And I have done this:
Changed the way HMMC is handled in the code, this resulted in 7% faster 
rendering of HISPAMSX MSX boot logo Ansi Art on a z80 at regular speeds
Changed the way HMMM is handled in the code, it should be faster but it is 
difficult to determine the performance increase, anyway, code is cleaner and 
easier to understand as well
Changed how AnsiPrint and AnsiPutChar work, which results in 8% faster 
rendering of HISPAMSXMSX boot logo Ansi Art on a z80 at regular speeds. Total
is a 15% speed improvment!
Reworked YMMM function provided by PK to work faster not having to calculate on
the fly, doing all calculations before sending can save some time if VDP still 
is processing a command
Reworked CopyBlock provided by PK as CopyBlockDown and made it work calculating
before calling YMMM
Reworked ANSI DL provided by PK, it was not taking into consideration when 
cursor is at the last line or if deleted lines exceed line capability of screen
Created Insert Lines and CopyBlockUp that is used by it

# MSX2ANSI v1.5: 

This version has lots fixes and additions kindly provided by Piter Punk:
Added Support to CSI\#d (ANSI VPA), CSI\#e (ANSI VPR), CSI\#G (ANSI CHA), 
CSI\#I (ANSI CHT), CSI\#S and CSI\#T (ANSI Scroll), CSI\#X (ANSI ECH) and 
CSI\#Z (ANSI CBT)
Added Support to CSInb, ANSI REP, which repeats the last char
Rewrite HorizontalTab routine to move cursor to a tabstop
Added back HorizontalTab (0x09) handling
Added save and restore cursor VT100 control codes
Added support to concealed mode

This has been fixed by me:
CSI\#J had issues depending how many lines were scrolled
Fixed a few wrong characters in the table below 0x20
Fixed an issue where sometimes the background color would be wrong after ANSI 
delete commands

This has been improved by me:
Added the possibility of disabling cursor while putting text with 
AnsiPutChar through AnsiStartBuffer and AnsiEndBuffer, this might generate a 
more pleasant screen rendering without the cursor moving and also speed up 
certain operations like screen clearing and line deletions
Improved performance of ECH and fixed scroll down
Added proper support to FF (12 or 0x0C), it now clears the screen
Added support to CSI\#@ (ANSI Insert)

# MSX2ANSI v1.4

When "printing" character 7 (BELL) now it BEEPs properly
Piter Punk offered some help on a new way to call BEEP, which is more reliable, the previous way
was crashing on some configurations

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

Thanks to Piter Punk for his contributions on making msx2ansi better suited to present text from Linux daemons!

All code can be re-used, re-written, as long as the source code of changes is made public as well and the original authors are credited.
