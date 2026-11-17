nolist

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@  SymbOS Network Daemon - OCM Wi-Fi wrapper (assembler entry point)         @
;@                                                                            @
;@  Based on the msx-picoverse-symbos-network-daemon by Jzzy:                 @
;@  https://github.com/Jzzy-dev/msx-picoverse-symbos-network-daemon           @
;@                                                                            @
;@  WinAPE syntax (READ/WRITE/print); the SjAsmPlus build uses                @
;@  Dmn-Network-_OcmWifi-sj.asm which maps these directives.                  @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

DRIVER      equ 7    ;0=localhost 1=denyonet 2=gr8net 3=m4cpc 4=net4cpc 5=m4ep 6=esp8266-unapi (picoverse) 7=OCM Wi-Fi (ESP8266 UNAPI, I/O ports)
M4BOARD     equ 0
low_buflen  equ 0
ESPDEBUG    equ 0    ;1 = compact driver version line in the status tab
LNGSKIP     equ 2    ;2 = direct texts, no language pack at all (use with Dmn-Network-i18n-direct.asm)
low_sockmax equ 4    ;max parallel TCP connections, must be defined BEFORE Dmn-Network.asm
low_vermaj  equ 0    ;driver version shown in the daemon info box
low_vermin  equ 9

org #1000

;--- output file, folder must exist
WRITE "netd-ocm.exe"
print "STEP 1 WRITE accepted"

;--- SymbOS constants file, use the file that really contains MSC_ MSR_ PRC_ etc.
;--- the original wrapper reads SymbOS-Constants.asm from SRC-Main
READ "SymbOS-Constants.asm"
print "STEP 2 constants read"
READ "Dmn-Network-head.asm"
print "STEP 3 head read"

;--- one flattened file replaces the three symbos_lib files
READ "Dmn-Network-libs.asm"
print "STEP 4 libs read"

READ "Dmn-Network.asm"
print "STEP 5 daemon read"
READ "Dmn-Network-OcmWifi.asm"
print "STEP 6 OCM Wi-Fi driver read"

App_EndTrns

relocate_table
relocate_end
