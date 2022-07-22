# MC2+

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

IMPORTANT! MULTICORE 2+ DOESN'T FLASH NEW OCM FIRMWARE! THE OCM FIRMWARE IS THE
CORE FILE (.MCP). BY REPLACING YOUR OLD .MCP FILE WITH THIS ONE YOU ARE DONE!

DO NOT USE SMXFLASH.COM!!! RESULTS ARE UNPREDICTABLE! YOU HAVE BEEN WARNED!

Multicore 2+ has two possibilities:

    1 - Use a dedicated SD for MSX. That SD must have a SD-BIOS and I recommend
    using KdL kit to make a SD with SD-BIOS. KdL kit is available by request,
    access http://gnogni.altervista.org/index.html and click OCM-SDBIOS Pack
    link, it will redirect you to request access to it. KdL is really nice and
    usually replies within the same day or next day. After making the SD using
    that kit, copy the OCM_SM.MCP file to the root of the card and rename it to
    CORE.MCP, then copy CORE.INI file to the root of the card. If you don't do
    that it will think it has to load image files and won't work with the SD.

    2 - Use an IMG file that is an image of an SD like the one created in step
    one, except it doesn't need to have MCP and INI file (not an issue if it
    has those files though). You can either create your own SD card and then
    create the image using a tool like Win32DiskImager, or, you can try some
    pre-built disk images available at Victor Trucco git lab:

    https://gitlab.com/victor.trucco/Multicore_Bitstreams/-/tree/master/Multicore%202%20Plus/Computers/SM-X/sdimg

    In that case your SD can be formatted as FAT, FAT32 or preferably FATX.
    You will copy the image file, ocm_sm.mcp and ocm_sm.ini to the same folder
    and access SM-X by loading OCM_SM in the multicore menu. After a while, you
    will probably get a blank screen, press F12 and choose LOAD IMAGE, select
    the IMG file and answer YES when asked if you want to automatically load
    that image next time.

    NOTE: I've added a disk image based on Focosi released disk image, it
    probably is ok as it doesn't have any copyrighted software after Nishi
    allowed everyone to use MSX-DOS2 and Nextor to be created and distributed
    freely. If there are any issues with that image, let me know and I will
    take it down. That disk image is good as long as you have SM-X extension
    connected, as it has a SD-BIOS using Wi-Fi bios. If you don't have that
    extension or it is not connected, boot will take longer due to the BIOS
    waiting for the ESP to respond. If you have the extension, hit the red
    button while keeping F1 pressed, then release the red button, you will
    be greeted with Wi-Fi setup. Setup your network and also set it up to
    update automatically MSX date and time on boot, it is way faster than
    having to load ESP8266.COM and SNTP.COM to do that :)

NOTE: You need at least version 1.07 of Multicore Menu core and version 2.00 of
STM Firmware. It is not in the scope of this to document this update procedure,
please seek help through Victor Trucco git lab or Facebook dedicate Multicore
groups.

# OCM-PLD v3.9d

# Release notes

OCM-PLD v3.9d is an extension on KdL OCM release v3.9. What this extension
brings to the table:

    - Multicore 2+: it is like a MiSTER device, but with less FPGA capacity (
    more than double of second gen devices, but about half of MiSTER) and also
    without an extra ARM core to help with USB devices (so it uses SEGA Genesis
    / Mega Drive controllers or SEGA Master System controllers and PS/2 mouse
    and keyboards). One advantage it has over MiSTER is that it was made with
    an expansion slot that you can insert expansions that allows to use real
    cartridges/interfaces for the device. There is a SM-X expansion available
    that adds three MSX Slots and ESP Wi-Fi.

        - Legacy: all features from OCM 3.8 build by Roberto Focosi and Victor
        Trucco were ported, so it supports the external slots extension, usage
        of images instead of needing a dedicated SD card, keyboard layout
        selection using OSD menu, etc.

        - Fix: when using images instead of dedicated SD card, writing to the
        card could cause errors / failures, now it should be working fine
        everytime.

        - Improvement: MC2+ has SEGA Genesis / Mega Drive joystick port. As
        such, my initial 3.7.1 version used only two buttons of any joystick
        and allowed invoking OSD using MODE + START on an eight button joystick
        , Focosi release ditched invoking OSD for sake of simplicity of design,
        I've restored invoking OSD and now ALL 8 buttons can be used on Joymega
        compatible games/software as well, for both joysticks. It also works
        with 4 buttons joysticks (Joymega) and 2 buttons joysticks (Master
        System joystick detected as regular MSX joystick).

        - Unique behavior: since MC2+ doesn't have dip switches but uses OSD
        being invoked through F12 key, turbo changing through F12 key was
        removed and it can be adjusted only on the OSD menu (F12 or MODE+START
        on joystick 1) or using switched I/O or software that sets the CPU
        speed. Since you need to hit F12 to invoke OSD and hit it back to
        remove it, it was not nice having F12 also switching the CPU clock.

        - Unique behavior: paddle emulation is turned on/off through the OSD
        menu, SETSMART commands for paddle won't have any effect.

        - Improvement: in general all DIP settings are done through the OSD. If
        you are using a disk image, settings are saved / kept on the SD Card,
        and restored back when OSD is invoked. When using a dedicated SD Card,
        since the card is owned by the MSX as a whole, it is not possible to
        save settings in it as the SD Card I/O is not assigned to the MC2+
        microcontroller that makes the OSD a reality, so whenever you pop up
        the OSD, settings are reset to "default values", since microcontroller
        doesn't know settings on FPGA and could not save the settings into the
        SD Card to read back when invoked again. Due to that I've changed a few
        of those settings to alow sane defaults. Remember: if using dedicated
        SD card, set all settings the way you want before exiting OSD. If you
        invoke OSD again the default values will be loaded and your settings
        all lost / need to set it again. There is no other way around it
        currently.

        - Extra: if you have a ZX Next Expansion for MC2+ but doesn't have the
        SM-X one, you can use it after enabling it on the OSD. Currently the
        only feature supported is use of Wi-Fi / ESP. IMPORTANT: SM-X / Second
        Gen OCM devices use a customized ESP firmware, and ZX Next use standard
        "AT" firmware from Espressif. In order to make this feature useful, you
        need to have a second ESP-01 module flashed with the customized ESP
        firmware, so you can just put it into the extension when using it for
        MSX, and put back the original one when using it for ZX Next.
        Instructions on how to flash the custom ESP firmware are available at:
        https://youtu.be/uoaiEamWUUg

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

    - Improvement for Multicore 2+: I've fixed OPL3 sound rendering as it was
      discarding all information that is on right output channel only, since
      MC2+ has a really large FPGA, OPL3 works in real stereo mode since it can
      acommodate the extra registers needed for it that do not fit on regular
      second gen devices.

- SN76489 / Second PSG:

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

- Other updates:

    - Improved: Victor Trucco made improvements on the SDRAM controller so it
      is able to work with different chips. Some SM-X mini and SMX-HB use chips
      that need this to work. KdL kindly worked on that code from Victor Trucco
      to extrapolate it to uncovered scenarios, making it aware of OCM 3.9
      SD-RAM usage, thanks KdL! :)

    - Extra: I've added Paddle emulation when using a PS/2 mouse. To enable
      VAUS (Arkanoid/Taito) Paddle emulation, MSX Standard Paddle emulation 
      or disable it, use the OSD (F12 or MODE + START on Joystick 1). Note that
      MSX Standard paddle only works properly if Z80 clock is 3.58MHz, like a
      real MSX Standard paddle on a MSX machine with turbo CPU.

    - Fix: I've fixed mouse emulation. It was not possible to move a single
      pixel on X axis, now it is. Also, four different levels of sensibility
      are available by clicking the third mouse button (if your mouse is not an
      intellimouse compatible mouse w/ 3 buttons, sensibility will be fixed 
      almost the same as before)

    - Fix: When switching from mouse to joystick or joystick to mouse, joystick
      port is "disconnected" for 1 second. On a real MSX it is not possible to
      change from joystick to mouse without disconnecting each one so HIDTEST
      and software that uses HIDLIB to detect rely on the device being
      disconnected for a while to detect its removal and then be able to see
      the new device being connected

- Future:

    - Extra: this is a WIP, please wait, but it will have Franky VDP :P

All source code and binaries that changed in relation to OCM 3.9:
(c)2022 Oduvaldo Pavan Junior - ducasp@gmail.com

All source code from OCM 3.9 originally is a work of many people, including
KdL and Hara-san that are really huge contributors to it!

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
