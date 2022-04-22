# SMXHB

Do you like what I do and want to pay me a Coffee as a thank you? 
https://ko-fi.com/R6R2BRGX6
Just do it if you feel like it :)

IMPORTANT! READ THIS AND BE CAREFUL! BRICKING SMX-HB ISN'T FUN! IT IS A PAIN
TO RESTORE IT USING JIC / USB BLASTER AS YOU WILL NEED TO DISASSEMBLE IT, TAKE
OUT THE FPGA BOARD, FEED IT WITH AN EXTERNAL POWER SUPPLY AND CONNECT IT TO AN
USB BLASTER TO RESTORE IT. THE JTAG CONNECTOR IS NOT ACCESSIBLE WITH HOTBIT
CASE ASSEMBLED, AND IT IS NOT ACCESSIBLE WITH THE FPGA BOARD CONNECTED TO THE
SMX-HB MOTHERBOARD. YOU HAVE BEEN WARNED! REALLY!

ONLY USE SMXFLASH.COM to update your SMX-HB. ONLY USE A FIRMWARE THAT IS MEANT
TO SMX-HB. NO, SM-X firmware IS NOT COMPATIBLE. SM-X MINI firmware IS NOT
COMPATIBLE. SX2 firmware IS NOT COMPATIBLE. IF THE FIRMWARE IS NOT SAYING IT
IS FOR SMX-HB STAY AWAY FROM IT.

The version of SMXFLASH.COM that is sent along with the firmware file also
works on NEXTOR. Older versions of SMXFLASH.COM requires MSX DOS 2 Kernel to be
loaded. Why would you use other version? I have no idea. Read this fully and
be careful to not have any issues. Command line to update:

SMXFLASH OCM_SM.PLD

Wait until it quits to the dos prompt telling it is done. If there is an error
message after it started erasing or writing, try again until it works, as if
you power it down with an unfinished update, it will BRICK and you will need
to use an USB Blaster and JIC file to restore it, like said above, a pain!

Also, be aware that if power fails during update, you are most likely to end up
with a bricked unit and you will need to use an USB Blaster and JIC file to
restore it, again, a pain!

OCM-PLD v3.9a is an extension on KdL OCM release v3.9. What this extension
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
      use the mapping the firmware was built-in, that is handy when you want to
      use an external keyboard.

    - Fix: Select key was not working on original 3.7.1 based release, it works
      now. Also, SELECT + +/=, SELECT + -/_, SELECT + F1 to F4 replaces Page Up
      , Page Down, F9 to F12, so it is possible to activate the autofire module
      and most of the OCM Hotkey shortcuts using only SMX-HB internal keyboard.

    - Missing: SMX-HB FPGA has less cells than other SM-X devices as it uses
      a FPGA with about 70% of the capacity of the other devices, so it doesn't
      support OPL3 as it won't fit

All source code and binaries that changed in relation to OCM 3.9:
(c)2022 Oduvaldo Pavan Junior - ducasp@gmail.com

All source code from OCM 3.9 originally is a work of many people, including
KdL and Hara-san that are really huge contributors to it!

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
