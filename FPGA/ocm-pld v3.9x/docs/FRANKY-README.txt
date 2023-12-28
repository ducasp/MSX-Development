Use SSMS to run Sega Master System roms.

Copy SSMS.INI file to the folder where you have SSMS / Sofarun. It has all
known extra patches added by retrocanada76 up to December 28th / 2023.

Remember to use SETSMART -8C before, otherwise you might not have sound.

If using Sofa Run, remember to check SMS settings in Sofa Run settings and make
sure ALL settings except AUDIO and VIDEO (should be set to Franky) are set to
DEFAULT, otherwise the changes on SSMS.INI will be ignored and your Sofa Run
settings will be applied!

IMPORTANT: SOFA SMS STILL DOESN'T WORK WHEN PATCHING MANY GAMES. It is
absolutely normal that a game doesn't work. Some will work perfectly as Prince
of Persia or Montezuma's Revenge, others you might have more success if you
download Alexito's pre-patched versions (like his excellent version of Alex
Kidd in Shinobi World) in MRC:
https://www.msx.org/forum/development/msx-development/franky-projects-smsmsx-conversions-remakes-tools-emulatorocm-etc?page=10
, all games in SSMS.INI will work (make sure you have the right version the INI
file requests, unfortunately SSMS uses a CRC32 calculation of only the first
16KB of the files, so the CRC32 values normally published of each files are not
the ones in the INI file), and of course, you can test any other games.

If you feel inclined to help, retrocanada76 explained how to make patches by
yourself for any game:
https://www.msx.org/forum/msx-talk/general-discussion/franky-ssmscom-patches-where-are-they?page=0
Remember to publish your patches if you create one :)