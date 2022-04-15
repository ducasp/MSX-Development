# SMX_FRANKYSND

Do you like what I do and want to pay me a Coffee as a thank you? 
https://ko-fi.com/R6R2BRGX6
Just do it if you feel like it :)

IMPORTANT! READ THIS AND BE CAREFUL! BRICKING SM-X ISN'T FUN! IT IS A PAIN TO
RESTORE IT USING JIC / USB BLASTER AS YOU WILL NEED TO CONNECT IT TO AN USB
BLASTER TO RESTORE IT. YOU HAVE BEEN WARNED! REALLY!

ONLY USE SMXFLASH.COM to update your SX2. ONLY USE A FIRMWARE THAT IS MEANT TO
SX2. NO, SMX-HB firmware IS NOT COMPATIBLE. SM-X MINI firmware IS NOT
COMPATIBLE. SM-X firmware IS NOT COMPATIBLE. IF THE FIRMWARE IS NOT SAYING IT
IS FOR SX2 STAY AWAY FROM IT.

The version of SMXFLASH.COM that is sent along with the firmware file also
works on NEXTOR. Older versions of SMXFLASH.COM requires MSX DOS 2 Kernel to be
loaded. Why would you use other version? I have no idea. Read this fully and
be carefull to not have any issues. Command line to update:

SMXFLASH OCM_SM.PLD

Wait until it quits to the dos prompt telling it is done. If there is an error
message after it started erasing or writing, try again until it works, as if
you power it down with an unfinished update, it will BRICK and you will need
to use an USB Blaster and JIC file to restore it, like said above, a pain!

Also, be aware that if power fails during update, you are most likely to end up
with a bricked unit and you will need to use an USB Blaster and JIC file to
restore it, again, a pain!

OCM-PLD v3.9a is an extension on KdL OCM release v3.9. What this extension
brings to the table on this frankysnd version:

    - Extra: I've added partial support to a built-in Franky. That partial
      support is good enough to work with SG1000, COL4MMM (using COM\Franky
      versions) VGMPLAY and Sofarun (remember to set it to use MSX VDP and
      Franky's PSG). As Franky sound uses I/O ports 0x48 and 0x49, and those
      ports are part of the switched I/O, it is usually disabled, as OCM IPL
      loader will leave switched I/O selected after booting. There are 
      different ways to enable Franky sound:

        - VGMPLAY will automatically disable switched I/O, so you can play a
        VGM song that uses SN76489 and after exiting VGMPLAY you can use other
        software.

        - De-select the internal switched I/O by sending the basic command
        OUT &H40,0

        - Use SETSMART -8C to enable the I/O ports 0x48 and 0x49 for that, so
        any program relying on reading OCM information on those ports won't
        get it.

    - Fix: I've fixed OPL3, it had two issues that prevented it to work with
      the latest VGMPlay version:

        - IRQ was not connected, so timers programmed wouldn't trigger,
          instead only the VDP interrupt, to slow, so music would play darn
          slow with VGMPlay.

        - Even after fixing that, playing speed was almost half of the correct
          speed for VGMs. The timer scaler was not properly set causing it to
          trigger slower than programmed.

      Since VGMPlay 1.3 relies on OPL3 timer when present to drive a high speed
      interrupt, not having IRQ and not having the proper scaler for timer
      caused its timing to be slow, darn slow...

- Planned for the future SM-X, SM-X mini and SX-2 will have a franky build:

    - Missing: FPGA in those devices can't fit OPL3 along with Franky VDP and
      PSG, so that build won't have OPL3 support.

    - Extra: this is a WIP, please wait, but it will have Franky VDP :P

All source code and binaries:
(c)2022 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
