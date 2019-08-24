# ANSI-DRV

ANSI-DRV is an amazing piece of software by Tobias Keizer!

It is a very, very, very fast ANSI COLOR Text Rendering engine for MSX2 and beyond.

But, it had a few shortcomings for what I would like to use, so I've asked Toby if it would be ok to change it, and he was
really kind sending me the source code.

Also, he was really kind by allowing me to share the source code on my GitHub!

My changes:

- I've made a few commentaries on the source code where I researched to understand what was going on...
- I've changed the way it proccess strings to work with C-Strings instead of Pascal Strings.
- I've tweaked the code a bit to allow the screen border color to be the same as the background color.
- I've tweaked the code a bit to allow the screen to have 25 lines of text like IBM-PC.
- I've fixed the behavior of when ANSI Cursor Down and ANSI Cursor Forward is used with a parameter too big (it would overlap and result in the line/column to not be the limit as it should).
- I've added the possibility to retrieve the current cursor position (important for telnet terminals that want to look good on 
Synchronet BBSs).
- I've fixed an issue where, after a few lines of text scrolled, some lines that were deleted would appear on the bottom.
- I've added the possibility to have a callback function to handle returning cursor position when 6n escape command is received (for
examples on how to use that, check the TELNET terminal source code).

How to integrate it in your program:

- It should be loaded at 0xb000
- CALL 0xb000 is to initialize the screen
- CALL 0xb003 is to de-initialize the screen and go back to screen 0 (otherwise DOS won't show anything)
- CALL 0xb006 is PUTCHAR, character in register A
- CALL 0xb009 is PUTSTR, C-String, 0 terminated, address of it in HL
- CALL 0xb00c is GETCSRPOS, get current cursor position, H will have ROW and L will have COLUMN
- CALL 0xb00f is SETCSRCBK, HL has the address of a function to be called when 6n cursor position request command is processed, this
function can either call GETCSRPOS or just get the current position that is in HL

All source code and binaries: 
(c)Tobias Keizer (original version)
(c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com (modified version, remember, all hard work was done by Toby!)

All code can be re-used, re-written, as long as the source code of changes is made public as well.
