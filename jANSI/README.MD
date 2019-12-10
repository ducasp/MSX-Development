# jANSI and MEMMAN

MEMMAN and jANSI are two great pieces of software for MSX developed by MST 
(MSX Software Team) in Netherlands by early 90's.

MEMMAN allow you to easily allocate and switch memory mapper pages into your
program space, and also, allow the usage of TSRs (Terminate and Stay Resident)
that MSX DOS 1/2 do not allow.

jANSI is one TSR that will hook the text output of BIOS and DOS and if Kanji
mode is active (J_ON.com will do it) it will convert ANSI 16 color escape codes
properly. 

I've added an ANSI.BAT file that will load MEMMAN, load jANSI and activate
Kanji mode automatically.

P.s.: this jANSI.tsr file is modified by me, look at the README.MD of src to
understand changes

**This is useful for the MSX-SM Telnet Client. I have no participation in MEMMAN
and jANSI development, I've just included it here in distributable format.**
