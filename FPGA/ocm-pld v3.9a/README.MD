# OCM-PLD v3.9a

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

OCM-PLD v3.9a is an extension on KdL OCM release v3.9. What this extension
brings to the table:

- For regular SM-X, SM-X mini and SX-2:

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

    - Improved: Victor Trucco made improvements on the SDRAM controller so it
      is able to work with different chips. Some SM-X mini and SMX-HB use chips
      that need this to work.

- Adds support to SMX-HB (as it has only initial support for OCM 3.7.1)

    - Extra: I've allowed Joystick port debounce to be disabled, this perhaps
      can alleviate the issues some users were having with paddles. To turn off
      Joystick port debounce use the command SETSMART -89 , to turn it back on
      use the command SETSMART -8A , power cycle will restore default, on.

    - Extra: I've added support to different keyboard map tables. This is handy
      as the internal keyboard of Hotbit is not standard and its map is very
      peculiar, while PS/2 keyboards have a different mapping. DIP switch 9 set
      to OFF is the default, using the internal mapping, if set to ON it will
      use the mapping the firmware was built-in, that is handy when you want to
      use an external keyboard.

    - Fix: Select key was not working on original 3.7.1 based release, it works
      now. Also, SELECT + UP and SELECT + DOWN replaces Page Up and Page Down,
      so it is possible to activate the autofire module using only SMX-HB
      internal keyboard.

    - Missing: SMX-HB FPGA has less cells than other SM-X devices as it uses
      a FPGA with about 70% of the capacity of the other devices, so it doesn't
      support OPL3 as it won't fit

- Adds to regular SMX-HB, SM-X, SM-X mini and SX-2 a frankysnd build:

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

- Planned for the future SM-X, SM-X mini and SX-2 will have a franky build:

    - Missing: FPGA in those devices can't fit OPL3 along with Franky VDP and
      PSG, so that build won't have OPL3 support.

    - Extra: this is a WIP, please wait, but it will have Franky VDP :P

All source code and binaries that changed in relation to OCM 3.9:
(c)2022 Oduvaldo Pavan Junior - ducasp@gmail.com

All source code from OCM 3.9 originally is a work of many people, including
KdL and Hara-san that are really huge contributors to it!

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
