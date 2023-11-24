NOT WORKING

The new IPL requires a ROM in FLASH memory, SM-X/SX2 has it, but
systems like MC2+, MiSTER, MiST, etc do not have it and just
load the RBF and need to use SD BIOS. But, to load SD BIOS now
you need the new IPL that is in flash, that for multi core FPGA
systems is non-existent.

Seems like 3.9.2 will progress to have a different way that will
allow SD LOADING only without having anything in FLASH, let's see,
if it doesn't have it, then I'll check if I can backport IPL and
keep the rest.