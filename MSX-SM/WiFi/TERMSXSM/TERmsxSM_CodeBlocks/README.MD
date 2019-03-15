# Code::Blocks Project

If you want to compile using a nice IDE, Code::Blocks integrate with SDCC.

This project assumes that the general code (WiFiMSXSM.c, WiFiMSXSM.h and 
termsxsm.c) are in your fusion-c working folder (i.e.: C:\fusion-c) and that
the project file itself is in a folder in it (i.e.: C:\fusion-c\TERmsxSM)

Also there are some post build events, to rename from .exe to .ihx (couldn't
get Code::Blocks to output an .ihx file name, even though that is what sdcc
outputs) and to use hex2bin to generate the .COM file from the .ihx file. It
assumes hex2bin is in fusion-c folder and also it invokes windows CMD to do
those steps. If your configuration is different you might need to change the
project to your liking.
