# OCM-PLD v3.9.1plus

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

# Version Selection Cheat Sheet

| Firmware Version | OPL3 Mono | OPL3 Stereo | SN76489 | SMS VDP | PS/2 Mouse as MSX Mouse | Paddle using PS/2 Mouse | 2x PSG | MIDI Out | Turbo-R PCM | Second 4MB Mapper |
| :--------------- | :-------: | :---------: | :-----: | :-----: | :---------------------: | :---------------------: | :----: | :------: | :---------: | :---------------: |
| MC2P             | Yes       | Yes         | Yes     | Yes     | Yes                     | Yes                     | Yes    | Yes      | Yes         | Yes               |
| SM-X/SX2         | Yes       | No          | No      | No      | Yes                     | Yes                     | Yes    | Yes      | Yes         | Yes               |
| SM-X/SX2 Franky  | No        | No          | Yes     | Yes     | Yes                     | Yes                     | Yes    | Yes      | Yes         | Yes               |
| SM-X/SX2 Snd     | Yes       | No          | Yes     | No      | Yes                     | Yes                     | Yes    | Yes      | Yes         | Yes               |
| SM-X Mini        | Yes       | No          | No      | No      | Yes                     | Yes                     | Yes    | Yes      | Yes         | No                |
| SM-X Mini Franky | No        | No          | Yes     | Yes     | Yes                     | Yes                     | Yes    | Yes      | Yes         | No                |
| SM-X Mini Snd    | Yes       | No          | Yes     | No      | Yes                     | Yes                     | Yes    | Yes      | Yes         | No                |
| SM-X HB          | No        | No          | No      | No      | Yes                     | Yes                     | Yes    | Yes      | Yes         | No                |
| SM-X HB Franky   | No        | No          | Yes     | Yes     | No                      | No                      | Yes    | No       | No          | No                |
| SM-X HB Snd      | No        | No          | Yes     | No      | Yes                     | No                      | Yes    | Yes      | Yes         | No                |

NOTE: NEVER, EVER THINK ABOUT USING MC2P IF YOU DON'T HAVE MC2P, SM-X IF YOUR
DEVICE IS OTHER THAN SM-X, ETC... Cheat Sheet is only to help you choose what
version for your device has the features you want. If your device doesn't have
a feature or the combination of features you want, DO NOT USE THE FIRMWARE OF
OTHER DEVICE, IT WILL BRICK YOUR DEVICE AND YOU WILL ONLY BE ABLE TO RECOVER IT
USING USB BLASTER AND A PC. YOU'VE BEEN WARNED!

# New in relation to v3.9d

- Incorporated all 3.9.1 changes not present in 3.9d, check original KdL 3.9.1
  release for more information. Note: PS2 new controller was not Incorporated
  as my understanding is that it might make some keyboards currently working on
  3.9.0 to not work on it unless you make some proposed hardware changes.

# Release notes

OCM-PLD v3.9.1plusa is an extension on KdL OCM release v3.9.1. What this
extension brings to the table:

- New supported devices:

    - SMX-HB, SMX-HB EX and SMX-HB MINI: It is a 1.75gen device. Its FPGA has
      about 1/3 less logic cells as result of components shortage. It is meant
      to replace the motherboard of Hotbit / Expert MSX Computers (HB / HB EX),
      adding (almost) the full OCM-SM experience. HB MINI is like the original
      SM-X in the fact it uses PS/2 keyboards and has its own case. As being a
      device with real MSX Keyboard (HB and EX ONLY), it has its own needs
      (some doesn't apply to HB MINI that uses only PS/2 keyboards):

        - I've allowed Joystick port debounce to be disabled, this perhaps can
        alleviate the issues some users were having with paddles. To turn off
        Joystick port debounce use the command SETSMART -89 , to turn it back
        on use SETSMART -8A , power cycle will restore default, on. NOTE: this
        option at this moment is not available and debounce is always active no
        matter the selection with SETSMART. (HB, EX and HB MINI)

        - I've added support to a third keyboard map table, so you have the one
        from the build (us/br/fr/es/it) and japanese if using PS/2 and one for
        the MSX keyboard Hotbit/Expert have. Hotbit and Expert keyboards are
        not standard and their mapping are very peculiar as PS/2 keyboards have
        a different mapping. DIP switch 9 set to OFF is the default, using the
        MSX Keyboard mapping, if set to ON it will use the mapping the firmware
        has built-in, that is handy when you want to use an external PS/2
        keyboard. (HB MINI always should have DIP 9 set to on)

        - Fix: Select key was not working on original 3.7.1 based release, it
        works now. (HB)

        - Improvement: SELECT + UP and SELECT + DOWN replaces Page Up and Page
        Down, so it is possible to activate the autofire module using only
        SMX-HB internal keyboard. Also, SELECT + F1 to F4 replaces F9 to F12,
        making it possible to use most of the keyboard shortcuts. (HB)

        - Missing: it doesn't support OPL3 as it won't fit on the FPGA used. It
          doesn't support paddle emulation on franky/snd version due to the
          same reason. In HB firmware, Franky version also doesn't have the
          following features: PS/2 mouse as MSX mouse, Turbo-R MIDI out through
          joystick port 2 and Turbo-R PCM. (HB, EX and HB MINI)

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

- For devices/builds supporting OPL3:

    - Fix: I've fixed OPL3, it had two issues that prevented it to work with
      the latest VGMPlay version (KdL's OCM 3.9.1 or newer also incorporates
      those fixes):

        - IRQ was not connected, so timers programmed wouldn't trigger,
          instead only the VDP interrupt, to slow, so music would play darn
          slow with VGMPlay.

        - Even after fixing that, playing speed was almost half of the correct
          speed for VGMs. The timer scaler was not properly set causing it to
          trigger slower than programmed.

      Since VGMPlay 1.3 relies on OPL3 timer when present to drive a high speed
      interrupt, not having IRQ and not having the proper scaler for timer
      caused its timing to be slow, darn slow...

    - Fix for second gen devices (KdL's OCM 3.9.1 or newer also incorporates
      those fixes): I've fixed OPL3 sound rendering as it was discarding all
      information that is on right output channel only, unfortunately we do not
      have enough FPGA resources to run the sequencer for two channels, but a
      clever trick allows all songs content to be properly played in MONO glory
      :P Try as an example Doom soundtrack track 3 before updating and after
      updating it. :)

    - Improvement for Multicore 2+: since MC2+ has a really large FPGA, OPL3
      works in real stereo mode since it can acommodate the extra registers
      needed for it that do not fit on regular second gen devices.

    - Extra (KdL's OCM 3.9.1 or newer also incorporates this): Second PSG on
      ports 0x10 to 0x13. It also allows the PSG registers to be read back.
      Unlike KdL's build, this one has the second PSG enabled as standard.

- For firmwares supporting Franky's SN76489 only:

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

- For firmwares with Franky VDP:

        - Sega Master System VDP embedded. Video switch is automatic, as soon
          as Franky VDP generates interrupts its video output is shown. When
          that VDP stops generating interruptions, MSX video is shown.

- For all devices:

    - Improved (KdL's OCM 3.9.1 or newer also incorporates this): Victor Trucco
      and KdL made improvements on the SDRAM controller so it is able to work
      with different chips. Some SM-X mini and SMX-HB use chips that need this
      to work. MC2P, SX2 and standard SM-X can activate a second 4MB memory
      mapper (this mapper was implemented by KdL).

    - Extra: I've added Paddle emulation when using a PS/2 mouse. To enable
      VAUS (Arkanoid/Taito) Paddle emulation use SETSMART -8E, to enable MSX
      standard paddle emulation use SETSMART -8F, to disable it (default) use
      SETSMART -8D. Note that MSX Standard paddle only works properly if Z80
      clock is 3.58MHz, like a real MSX Standard paddle on a MSX machine with
      turbo CPU. Supported on all builds except SMX-HB Snd/Franky.

    - Fix (KdL's OCM 3.9.1 or newer also incorporates this): I've fixed mouse
      emulation. It was not possible to move a single pixel on X axis.

    - Fix (KdL's OCM 3.9.1 or newer also incorporates this): Mouse emulation
      would not work nice if you had an eight button mega drive joystick
      connected with joymega. Now it detects properly.

    - Fix (KdL's OCM 3.9.1 or newer also incorporates this): When switching
      from mouse to joystick or joystick to mouse, joystick port is
      "disconnected" for 1 second. On a real MSX it is not possible to change
      from joystick to mouse without disconnecting each one so HIDTEST and
      software that uses HIDLIB to detect rely on the device being disconnected
      for a while to detect its removal and then be able to see the new device
      being connected.

    - Improvement (KdL's OCM 3.9.1 or newer also incorporates this): ported the
      Multicore 2+ Mouse emulation to all devices. It is a better approach as
      it has a time-out to return to the first state after a few time without
      communication, like a real MSX mouse.

    - Fix (KdL's OCM 3.9.1 or newer also incorporates this): there was a bug in
      z80 implementation causing issues while playing Lilly's Saga, fix
      provided by Hara-san.

All source code and binaries that changed in relation to OCM 3.9.1:
(c)2022-2023 Oduvaldo Pavan Junior - ducasp@gmail.com

All source code from OCM 3.9.1 originally is a work of many people, including
KdL and Hara-san that are really huge contributors to it!

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
