# FIRMWARE

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

IMPORTANT! READ THIS AND BE CAREFUL! BRICKING YOUR 2nd GEN FPGA MSX ISN'T FUN!
IT IS A PAIN TO RESTORE IT USING JIC / USB BLASTER AS YOU WILL NEED TO CONNECT
IT TO AN USB BLASTER TO RESTORE IT. YOU HAVE BEEN WARNED! REALLY!

ONLY USE SMXFLASH.COM to update your 2nd Gen FPGA MSX (SM-X, SMX-HB, SM-X Mini,
SX2). ONLY USE A FIRMWARE THAT IS MEANT TO YOUR DEVICE. EACH DEVICE USE A
DIFFERENT SET OF CONNECTIONS, SOME USE DIFFERENT FPGAs, SO DO NOT EVER THINK OF
USING A 1ST GEN PLD FILE OR A 2ND GEN PLD FILE THAT DOESN'T CARRY YOUR DEVICE
NAME IN THE PACKAGE.

The version of SMXFLASH.COM that is sent along with the firmware files also
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

How to choose the firmware?

1 - Obviously, you will download the one for your device. (i.e.: I have a SM-X,
so I get firmware files from folders that start with smx_)

2 - Next step is to find out if you want vanilla or Franky Sound version. If
you don't own a Franky cartridge or a Playsoniq cartridge, go ahead with the
Franky Sound version. If you have one of those two interfaces, a Franky or
Franky Sound version will conflict with your cartridge, so it is best to stick
with a vanilla version. (Vanilla means nothing after the device name)

3 - (FUTURE ONLY, NOT NOW) You've found out that your 2nd Gen device has
support for a FrankyFull version. If in 2 you would choose Franky Sound, then
seems like choosing FrankyFull (that has Master System VDP support) would be a
no brainer, right? Wrong... Unfortunately it is not possible to fit Master
System VDP / CRAM / VRAM along with OPL3. So if you like VGMPLAY and use it to
play OPL3 VGMs or have other uses for OPL3, you may prefer to use Franky Sound
version instead.

4 - WOW! That folder contains 16 different firmware files!!! I have no idea how
to choose from...

    - Do not worry, first, let's get down to four different files, you do this
    by figuring out your PS/2 Keyboard Layout, French, Spanish, Brazilian or
    US. IMPORTANT: SD-BIOS DO NOT CHANGE Keyboard Layout, so it is important
    to choose the correct one :)
    - Now, you have four different versions, let's get down to two. Do you
    prefer backslash symbol to be shown as a real backslash or do you prefer a
    it to be shown as the yen symbol like japanese MSX's? Based on that, choose
    yen or backslash. If you use SD-BIOS, then this is not relevant as the
    SD-BIOS will override whatever is flashed in that regards
    - Finally, you will have SINGLE EPBIOS or DUAL EPBIOS. On DUAL EPBIOS, if
    you do not use a SD-BIOS, you can easily switch between Nextor or MSX Dos 2
    kernel by flicking dip-switch 7. In the position for 4096 MB Mapper it will
    use Nextor Kernel (this change needs turning the device off and then on to
    take effect), in the position for 2048 MB Mapper it will use MSX Dos 2
    Kernel. Single EPBIOS use only MSX Dos 2 Kernel. If you use SD-BIOS, then
    this is not relevant as the SD-BIOS will override whatever is flashed in
    that regards

5 - Now you have your firmware file, just use it :)

All source code and binaries:
(c)2022 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
