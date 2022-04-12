# OCM-PLD v3.9a

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

OCM-PLD v3.9a is an extension on KdL OCM release v3.9. What this extensiong
brings to the table:

- Adds support to SMX-HB (as it has only initial support for OCM 3.7.1)

    - Extra: I've allowed Joystick port debounce to be disabled, this perhaps
      can alleviate the issues some users were having with paddles. To turn off
      Joystick port debounce use the command SETSMART -89 , to turn it back on
      use the command SETSMART -8A , power cycle will restore default, on.

    - Extra: I've added support to different keyboard map tables. This is handy
      as the internal keyboard of Hotbit is not standard and its map is very
      peculiar, while PS/2 keyboards have a different mapping. DIP switch 9 set
      to OFF is the default, using the internal mapping, if set to ON it will
      use the mapping the firmware was built-in (my releases are usually for
      Brazilian Keyboards, let me know if you need for a different layout that
      is covered by KdL regular releases), that is handy when you want to use
      an external keyboard.

    - Extra: I've added partial support to a built-in Franky. SMX-HB FPGA has
      less cells than other SM-X devices, and as it already did not support
      OPL3, it apparently doesn't have space for SMS VDP implementation (I'm
      still checking if somehow I can fit it). That partial support is good
      enough to work with SG1000, COL4MMM (using COM\Franky versions) and
      probably (did not test) Sofarun as well (remember to set it to use MSX
      VDP, not Franky's). As Franky sound uses I/O ports 0x48 and 0x49, and
      those ports are part of the switched I/O, it is usually disabled, as
      OCM IPL loader will leave switched I/O selected. There are two ways to
      enable Franky sound:
        - Use SETSMART -8C to enable the I/O ports 0x48 and 0x49 for that, so
        any program relying on reading OCM information on those ports won't
        get it
        - De-select the internal switched I/O by sending the basic command
        OUT &H40,0
      It shouldn't work with VGMPLAY as VGMPLAY checks SMS VDP presence on I/O
      0x88/0x89, which SMX-HB doesn't have, sorry :(

- SM-X, SM-X mini and SX-2 will have full Franky support:

    - Extra: this is a WIP, please wait :P

All source code and binaries:
(c)2022 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
