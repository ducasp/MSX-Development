VGMPlay MSX change log
======================

For the complete list of changes please refer to the
[revision history](https://hg.sr.ht/~grauw/vgmplay-msx/log).

[1.3] — 2020-07-26
------------------

  * New chips: YM2203 OPN, YM2608 OPNA, YM2610 OPNB, YM2610B OPNB-B, YM2612 OPN2
  * New sound expansions: Makoto, Neotron, Darky, DalSoRi R2, OPL3 (C0H)
  * New timer: 1130 Hz if a MoonSound or OPL3 is present
  * Emulation of SN76489 DCSG on PSG
  * Emulation of YM2203 OPN, YM2608 OPNA and YM2612 OPN2 on Yamaha SFG
  * Translation of YM2612 OPN2 frequencies to correct tuning
  * Playback of YM2612 OPN2 PCM samples on MSX turboR
  * Playback of dual YM2203 OPN on a single Makoto + PSG or Yamaha SFG + 2x PSG
  * Playback of Y8950 MSX-AUDIO on MoonSound or OPL3, without ADPCM
  * Support of the DalSoRi R2 4MB RAM mode
  * Dual chip support for more chips
  * Support for VGM loop base and modifier
  * Improved detection of MSX-AUDIO, MoonSound, PSG, MMM and Franky
  * Improved sound chip reset and muting
  * Improved playback processing speed and accuracy
  * Samples load prior to playback
  * Added length and loop length to track information
  * Improved VGM chip overview output
  * Ability to stop playback with joystick buttons
  * Ability to use more than 4 MB memory by modifying a compile-time constant
  * Removed 1chipMSX / Zemmix Neo bug workaround (fixed in KdL firmware v3.3.1)
  * Fixed MSX-MUSIC playback issues on turbo R
  * Fixed MSX-AUDIO problem loading samples >128K
  * Fixed screen going blank on MSX1 during playback
  * Many code structure and footprint improvements

[1.2] — 2016-01-23
------------------

  * VGZ file loading support
  * K052539 SCC+ music playback support
  * Dual chip support for AY-3-8910 PSG and SN76489 DCSG
  * YMF278B OPL4 ROM data playback support (preliminary)
  * High-resolution timing (300 Hz) on MSX2/2+ and MSX1 with V9938 VDP
  * Showing which sound module is used for playback
  * Improved Y8950 MSX-AUDIO sample loading speed
  * No longer force-enable the R800 on turboR
  * No longer auto-switch to 60 Hz, removed /5 and /6 options
  * New /o option to work around 1chipMSX / Zemmix Neo timing bug

[1.1] — 2015-07-10
------------------

  * Nonprimary memory mappers supported, all available RAM can now be used.
  * High-resolution timing (4000 Hz) on MSX turboR.
  * A more informative error is shown for compressed (vgz) files.
  * Unsupported DMA commands are now skipped.
  * Franky/PlaySoniq SN76489 muting bug fixed.
  * Improved MSX-MUSIC detection.
  * Performance optimisations.

[1.0] — 2015-03-21
------------------

Initial release.


[1.3]: https://hg.sr.ht/~grauw/vgmplay-msx/log?rev=release-1.3
[1.2]: https://hg.sr.ht/~grauw/vgmplay-msx/log?rev=release-1.2
[1.1]: https://hg.sr.ht/~grauw/vgmplay-msx/log?rev=release-1.1
[1.0]: https://hg.sr.ht/~grauw/vgmplay-msx/log?rev=release-1.0
