# SMX

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

IMPORTANT! READ THIS AND BE CAREFUL! BRICKING SM-X ISN'T FUN! IT IS A PAIN TO
RESTORE IT USING JIC / USB BLASTER AS YOU WILL NEED TO CONNECT IT TO AN USB
BLASTER TO RESTORE IT. YOU HAVE BEEN WARNED! REALLY!

ONLY USE SMXFLASH.COM to update your SM-X. ONLY USE A FIRMWARE THAT IS MEANT TO
SM-X. NO, SMX-HB firmware IS NOT COMPATIBLE. SM-X MINI firmware IS NOT
COMPATIBLE. SX2 firmware IS NOT COMPATIBLE. IF THE FIRMWARE IS NOT SAYING IT
IS FOR SM-X STAY AWAY FROM IT.

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
brings to the table on this version:

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

    - Fix: I've fixed OPL3 sound rendering as it was discarding all information
      that is on right output channel only, unfortunately we do not have enough
      FPGA resources to run the sequencer for two channels, but a clever trick
      allow all songs content to be properly played in MONO glory :P Try as an
      example Doom soundtrack track 3 before updating and after updating it. :)

- Planned for the future SM-X, SM-X mini and SX-2 will have a franky build:

    - Missing: FPGA in those devices can't fit OPL3 along with Franky VDP and
      PSG, so that build won't have OPL3 support.

    - Extra: this is a WIP, please wait, but it will have Franky VDP :P

All source code and binaries:
(c)2022 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
