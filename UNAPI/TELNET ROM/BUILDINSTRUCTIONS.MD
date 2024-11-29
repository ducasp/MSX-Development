# HOW TO BUILD USING LINUX

Should be possible as Danilo Angelo Templates should work with it. But I do not use it and have
no idea or will to test it on Linux, feel free to use https://github.com/DamnedAngel/MSX-Templates-for-VisualStudio
for Linux to try making it :)

# HOW TO BUILD USING WINDOWS

My setup to build is:

- Windows PC
- Visual Studio Community Edition
- SDCC 4.3 stable released
- Danilo Angelo MSX Templates for VisualStudio ( https://github.com/DamnedAngel/MSX-Templates-for-VisualStudio )

***LIBRARIES***

The following libraries and their headers are included:

	- Konamiman's ASM.LIB ( https://www.konamiman.com/msx/sdcc/asmlib.zip ), header slightly modified due to this
      library using old SDCC calling convetion
	- Oduvaldo & Tobias Keizer MSX2ANSI.LIB ( https://github.com/ducasp/MSX-Development/tree/master/SDCC/MSX2ANSI ),
      a specific version to be used in ROMs was made and used