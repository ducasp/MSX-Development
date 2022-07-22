# SMX_FRANKYSND

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

# New in relation to v3.9c

    - Improvements from KdL to the SDRAM controller allowing features like 1MB
      VRAM to work with Victor Trucco SDRAM controller

# Release notes

OCM-PLD v3.9d is an extension on KdL OCM release v3.9. What this extension
brings to the table:

- OPL3 related:

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

    - Fix for second gen devices: I've fixed OPL3 sound rendering as it was
      discarding all information that is on right output channel only,
      unfortunately we do not have enough FPGA resources to run the sequencer
      for two channels, but a clever trick allows all songs content to be
      properly played in MONO glory :P Try as an example Doom soundtrack track
      3 before updating and after updating it. :)

- SN76489 / Second PSG related:

    - Extra: I've added partial support to a built-in Franky. That partial
      support is good enough to work with SG1000, COL4MMM (using COM\Franky
      versions) VGMPLAY, ROBOPLAY and Sofarun (remember to set it to use MSX
      VDP and Franky's PSG). As Franky sound uses I/O ports 0x48 and 0x49, and
      those ports are part of the switched I/O, it is usually disabled, as OCM
      IPL loader will leave switched I/O selected after booting. There are 
      different ways to enable Franky sound:

        - Latest release of COL4MMM automatically disables switched I/O, so no
        need for a SETSMART command or using VGMPLAY before.

        - VGMPLAY will automatically disable switched I/O, so you can play a
        VGM song that uses SN76489 and after exiting VGMPLAY you can use other
        software.

        - De-select the internal switched I/O by sending the basic command
        OUT &H40,0

        - Use SETSMART -8C to enable the I/O ports 0x48 and 0x49 for that, so
        any program relying on reading OCM information on those ports won't
        get it.

    - Extra: Second PSG on ports 0x10 to 0x13. It also allows the PSG registers
      to be read back.

- For all devices:

    - Improved: Victor Trucco made improvements on the SDRAM controller so it
      is able to work with different chips. Some SM-X mini and SMX-HB use chips
      that need this to work. KdL kindly worked on that code from Victor Trucco
      to extrapolate it to uncovered scenarios, making it aware of OCM 3.9
      SD-RAM usage, thanks KdL! :)

    - Extra: I've added Paddle emulation when using a PS/2 mouse. To enable
      VAUS (Arkanoid/Taito) Paddle emulation use SETSMART -8E, to enable MSX
      standard paddle emulation use SETSMART -8F, to disable it (default) use
      SETSMART -8D. Note that MSX Standard paddle only works properly if Z80
      clock is 3.58MHz, like a real MSX Standard paddle on a MSX machine with
      turbo CPU.

    - Fix: I've fixed mouse emulation. It was not possible to move a single
      pixel on X axis, now it is. Also, four different levels of sensibility
      are available by clicking the third mouse button (if your mouse is not an
      intellimouse compatible mouse w/ 3 buttons, sensibility will be fixed 
      almost the same as before)

    - Fix: Mouse emulation would not work nice if you had an eight button mega
      drive joystick connected with joymega. Now it detects properly

    - Fix: When switching from mouse to joystick or joystick to mouse, joystick
      port is "disconnected" for 1 second. On a real MSX it is not possible to
      change from joystick to mouse without disconnecting each one so HIDTEST
      and software that uses HIDLIB to detect rely on the device being
      disconnected for a while to detect its removal and then be able to see
      the new device being connected

    - Improvement: ported the Multicore 2+ Mouse emulation to all devices. It
      is a better approach as it has a time-out to return to the first state
      after a few time without communication, like a real MSX mouse.

All source code and binaries that changed in relation to OCM 3.9:
(c)2022 Oduvaldo Pavan Junior - ducasp@gmail.com

All source code from OCM 3.9 originally is a work of many people, including
KdL and Hara-san that are really huge contributors to it!

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
