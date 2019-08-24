# ANSI-DRV

ANSI-DRV is an amazing piece of software by Tobias Keizer!

It is a very, very, very fast ANSI COLOR Text Rendering engine for MSX2 and beyond.

But, it had a few shortcomings for what I would like to use, so I've asked Toby if it would be ok to change it, and he was
really kind sending me the source code.

Also, he was really kind by allowing me to share the source code on my GitHub!

My changes:

- I've made a few commentaries on the source code where I reasearched to understand what was going on...
- I've changed the way it proccess strings to work with C-Strings instead of Pascal Strings.
- I've tweaked the code a bit to allow the screen border color to be the same as the background color.
- I've tweaked the code a bit to allow the screen to have 25 lines of text like IBM-PC.
- I've fixed the behavior of when ANSI Cursor Down and ANSI Cursor Forward is used with a parameter too big (it would overlap and result in the line/column to not be the limit as it should).
- I've added the possibility to retrieve the current cursor position (important for telnet terminals that want to look good on 
Synchronet BBSs).
- I've fixed an issue where, after a few lines of text scrolled, some lines that were deleted would appear on the bottom.

All source code and binaries: 
(c)Tobias Keizer (original version)
(c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com (modified version, remember, all hard work was done by Toby!)

All code can be re-used, re-written, as long as the source code of changes is made public as well.
