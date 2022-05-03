VGMPlay for MSX change log
==========================

For the complete list of changes please refer to the
[revision history](https://bitbucket.org/grauw/vgmplay-msx/commits/all).

[1.3-rc5] — 2019-10-13
----------------------

  * https://www.msx.org/forum/msx-talk/software/vgmplay-msx

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


[1.2]: https://bitbucket.org/grauw/vgmplay-msx/commits/tag/release-1.2
[1.1]: https://bitbucket.org/grauw/vgmplay-msx/commits/tag/release-1.1
[1.0]: https://bitbucket.org/grauw/vgmplay-msx/commits/tag/release-1.0
