;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@  SjAsmPlus frontend for Dmn-Network-_OcmWifi.asm (WinAPE syntax wrapper)   @
;@                                                                            @
;@  Maps the WinAPE assembler directives to their SjAsmPlus counterparts      @
;@  (same technique as sjasmplus examples/SymbOS_nslookup/Cmd-NsLookUp-sj.asm)@
;@  DEFINE is case-sensitive, so both spellings are mapped.                   @
;@                                                                            @
;@  OCM Wi-Fi daemon based on the msx-picoverse-symbos-network-daemon by      @
;@  Jzzy: https://github.com/Jzzy-dev/msx-picoverse-symbos-network-daemon     @
;@                                                                            @
;@  Build:  sjasmplus Dmn-Network-_OcmWifi-sj.asm                             @
;@  Output: netd-ocm.exe                                                      @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    DEFINE write OUTPUT
    DEFINE WRITE OUTPUT
    DEFINE READ INCLUDE
    DEFINE read INCLUDE
    DEFINE nolist OPT listoff
    DEFINE NOLIST OPT listoff
    DEFINE print DISPLAY
    DEFINE PRINT DISPLAY

    OPT --syntax=abfw --dirbol

    INCLUDE "Dmn-Network-_OcmWifi.asm"
