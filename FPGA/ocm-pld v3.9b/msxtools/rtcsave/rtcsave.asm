;
; rtcsave.*
;   OCM-PLD Pack / OCM-SDBIOS Pack v1.3 or later / Third-party SDBIOS
;
; Copyright (c) 2008 NYYRIKKI / 2017-2109 KdL
; All rights reserved.
;
; Redistribution and use of this source code or any derivative works, are
; permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
; 3. Redistributions may not be sold, nor may they be used in a commercial
;    product or activity without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
; TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
; OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
; ----------------------------------------
;  Prog:    RTC save 3.0 for One Chip MSX
;  Made By: NYYRIKKI 2008 / KdL 2017-2109
;  Date:    2019.05.20
;  Coded in TWZ'CA3 w/ TASM80 v3.2ud
; ----------------------------------------
;

            .ORG  $0100

FN1         .EQU  'r'                     ; strings and options
FN2         .EQU  't'
FN3         .EQU  'c'
FN4         .EQU  's'
FN5         .EQU  'a'
FN6         .EQU  'v'
FN7         .EQU  'e'
VER1        .EQU  '3'
VER2        .EQU  '0'
YR1         .EQU  '2'
YR2         .EQU  '0'
YR3         .EQU  '1'
YR4         .EQU  '9'
SLASH       .EQU  '/'
MINUS       .EQU  '-'
OPTA        .EQU  'a'
OPTB        .EQU  'b'
OPTC        .EQU  'c'
OPTX        .EQU  'x'
HLP1        .EQU  'h'
HLP2        .EQU  '?'
NONE        .EQU  $ff

CODE        .EQU  $3fe0                   ; address of 'RTC CODE' located in SUB-ROM
DATA        .EQU  $3fc6                   ; address of the RTC data located in SUB-ROM
CODE0       .EQU  $3ef2                   ; address of 'MSX BASIC' located in MAIN-ROM
DATA0       .EQU  $3f90                   ; address of the COLOR data located in MAIN-ROM
SIZE        .EQU  1024                    ; ESE-RAM size (default is 1024kB)
BLKS        .EQU  SIZE/16                 ; amount of 16kB blocks

LOWERCASE   .EQU  %00100000               ; masks
UP          .EQU  -LOWERCASE
_           .EQU  %10000000               ; obfuscation mask, e.g. 'A'|_,'B'|_
DEOBF       .EQU  %01111111               ; de-obfuscation mask

NUL         .EQU  $00                     ; ascii table
LF          .EQU  $0a
CLS         .EQU  $0c
CR          .EQU  $0d
EOF         .EQU  $1a
SPC         .EQU  $20

PLENGHT     .EQU  $0080                   ; system calls
CALSLT      .EQU  $001c
CHPUT       .EQU  $00a2
LINL40      .EQU  $f3ae
LINL32      .EQU  $f3af
FORCLR      .EQU  $f3e9
BAKCLR      .EQU  $f3ea
BRDCLR      .EQU  $f3eb
OLDMOD      .EQU  $fcb0
EXPTBL      .EQU  $fcc1
_BDOS       .EQU  $0005
_STROUT     .EQU  $09                     ; string output

ONE         .EQU  $01                     ;   1 byte  for char
HLN         .EQU  $10                     ;  16 bytes for hex line
CLU         .EQU  $0100                   ; 256 bytes for cluster

K1          .EQU  'K'                     ; editable copyleft: 1st three chars
K2          .EQU  'd'
K3          .EQU  'L'
_1          .EQU  K1|_                    ; obfuscated copyleft
_2          .EQU  K2|_
_3          .EQU  K3|_
; ----------------------------------------
startProg:
            jr    mainProg                ; type support, A:\>TYPE FILENAME.COM
typeMsg:
;           .DB   CR,SPC,SPC,SPC,SPC,LF   ; 'jr mainProg' ctrl sequences mask
startMsg:
            .DB   CR,FN1+UP,FN2+UP,FN3+UP,SPC,FN4,FN5,FN6,FN7
            .DB   SPC,VER1,'.',VER2," for One Chip MSX",LF,CR
            .DB   "Made By: NYYRIKKI 2008 / "
clearCopyleft:
            .DB   K1,K2,K3," 2017-",YR1,YR2,YR3,YR4,CR
msgLF:
            .DB   LF,EOF
; ----------------------------------------
OPTION:     .DB   NONE                    ; vars
CURBLK:     .DB   BLKS
RTCSECTOR:  .DW   $0000
SCREEN:     .DB   $10
COLOR:      .DB   15,4,7
; ----------------------------------------
mainProg:
            di
            ld    c,LF+ONE                ; init 'call strDisp' to use
copyleftChk:
            ld    hl,clearCopyleft
            ld    a,_1
            and   DEOBF                   ; de-obfuscation
            cp    (hl)
            jr    nz,copyleftNext         ; protection: 'K' is confirmed here
            inc   hl
            ld    a,_2
            and   DEOBF                   ; de-obfuscation
            cp    (hl)
copyleftNext:
            jr    nz,jrnzSPC              ; protection: 'd' is confirmed here
            inc   hl
            ld    a,_3
            and   DEOBF                   ; de-obfuscation
            cp    (hl)
jrnzSPC:
            jr    nz,noParam              ; protection: parameter down!
; ----------------------------------------
startParser:
            ld    hl,PLENGHT
            ld    b,(hl)
            ld    a,b
            cp    NUL
            jr    z,noParam               ; jump if no chars
            ld    a,(PLENGHT+ONE)
            cp    SPC                     ; ignore this policy:
            jr    nz,noParam              ; e.g. A:\>FILENAME/x
preLoop:
            inc   hl
            ld    a,(jrnzSPC)             ; protection: jrnzSPC = $20
            cp    (hl)
            jr    nz,getParam             ; get 1st parameter:
            djnz  preLoop                 ; e.g. A:\>FILENAME      -x
noParam:
            jr    sdbiosChk               ; no parameters
getParam:
            ld    a,(hl)
            ld    e,a
            djnz  getOption               ; if no option, get invalid parameter
invalidParam:
            ld    hl,errorMsg0
            call  strDisp                 ; 'invalid parameter' without prefix
            jr    nearestExit             ; jump to the nearest exit, 2 bytes
getOption:
            inc   hl
            ld    a,(hl)
            or    LOWERCASE               ; 1st option forced to lowercase
            ld    d,a
            djnz  postLoop                ; if end of PLENGHT, parameter is get
            jr    prefixChk
postLoop:
            inc   hl
postLoop1:
            ld    a,(jrnzSPC)             ; protection: jrnzSPC = $20
            cp    (hl)
            jr    nz,invalidParam         ; get 2nd parameter as invalid:
postLoop2:
            djnz  postLoop                ; e.g. A:\>FILENAME -x    abcdef
prefixChk:
            ld    a,e
            cp    MINUS                   ; '-'
            jr    z,paramChk
            cp    SLASH                   ; '/'
            jr    nz,invalidParam
; ----------------------------------------
paramChk:
            ld    a,d
            ld    (OPTION),a
            cp    OPTA
            jr    z,sdbiosChk             ; jump if 'a'
            cp    OPTB
            jr    z,sdbiosChk             ; jump if 'b'
            cp    OPTC
            jr    z,sdbiosChk             ; jump if 'c'
            cp    OPTX
            jr    z,sdbiosChk             ; jump if 'x'
            cp    HLP1
            jr    z,isHelp                ; jump if 'h'
            cp    HLP2
            jr    nz,invalidOption        ; jump if '?'
isHelp:
            ld    a,(OLDMOD)              ; check mode
            cp    NUL                     ; check width < 33
            jr    nz,mode64
            ld    a,(LINL40)
            ld    b,63                    ; check width > 63
testWidth:
            cp    b
            jr    z,mode40
            djnz  testWidth
mode64:                                   ; width < 33 and > 63
            ld    hl,$0100                ; .DB NUL,1 = SPC
            ld    (helpMsg0),hl           ; replace LF,CR
            ld    (helpMsg1),hl           ; replace LF,CR
            ld    (helpMsg2),hl           ; replace LF,CR
mode40:                                   ; width from 33 to 63
            ld    hl,helpMsg              ; help message
nearestExit:
            jp    lastDisp
invalidOption:
            ld    hl,errorMsg0
            call  strDisp
            ld    hl,errorMsg2
            jr    nearestExit             ; 'invalid option'
; ----------------------------------------
sdbiosChk:
            ld    hl,startMsg             ; 'RTC save 3.0 for One Chip MSX'
                                          ; 'Made By: NYYRIKKI 2008 / KdL 2017-2019'
            call  lastDisp
            di                            ; use after every 'call  lastDisp'
; ----------------------------------------
            ld    de,$0000
            call  readSector
            ld    ix,$3e00                ; find ROM file
            ld    l,(ix+$0e)              ; reserved sectors
            ld    h,(ix+$0f)
            ld    e,(ix+$11)              ; root entries
            ld    d,(ix+$12)
            ld    a,e
            and   $0f
            ld    b,$04
_F1C2:
            srl   d
            rr    e
            djnz  _F1C2
            or    a
            jr    z,_F1CC
            inc   de
_F1CC:
            push  de
            ld    b,(ix+$10)              ; number of FATs
            ld    e,(ix+$16)              ; sectors / FAT
            ld    d,(ix+$17)
_F1D7:
            add   hl,de
            djnz  _F1D7
            pop   de
            add   hl,de

            push  hl
; ----------------------------------------
            ld    de,(BLKS-1)*32+31       ; offest to correct place
; ----------------------------------------
            add   hl,de
            ld    (RTCSECTOR),hl
            pop   de
            call  readSector
            jp    c,isUnsupp              ; 'UNSUPPORTED KERNEL FOUND!'

            ld    hl,($3e00)
            ld    de,$4241                ; ROM header 'AB'
            or    a
            sbc   hl,de

            ld    hl,nobiosMsg            ; 'MSX-BIOS not found from SD/SDHC, please install SDBIOS first'
            jp    nz,lastDisp
; ----------------------------------------
idScan:
            ld    de,(RTCSECTOR)
            call  readSector
            jp    c,isUnsupp              ; 'UNSUPPORTED KERNEL FOUND!'

            ld    hl,CODE
            ld    de,codeStr              ; check for 'RTC CODE'
idLoop:
            ld    a,(de)
            and   DEOBF
            and   a
            jr    z,idFound
            cp    (hl)
            jr    nz,chgBlk
            inc   hl
            inc   de
            jr    idLoop
chgBlk:                                   ; auto-scanning
            ld    a,(CURBLK)
            dec   a                       ; current block - 1
            cp    NUL
            jp    z,noID
            ld    (CURBLK),a
            ld    hl,(RTCSECTOR)
            ld    de,$0020                ; 32 sectors by 512 bytes = 1 block
            sbc   hl,de
            ld    (RTCSECTOR),hl
            jr    idScan
; ----------------------------------------
idFound:
            ld    hl,DATA
            ld    c,%00010000
rLoop:
            call  rRTC
            and   $0f
            push  af
            inc   c
            call  rRTC
            inc   c
            and   $0f
            rrca
            rrca
            rrca
            rrca
            ld    b,a
            pop   af
            or    b
            ld    (hl),a
            inc   hl
            ld    a,c
            and   $0f
            cp    $0e
            jr    nz,rLOOP
            inc   c
            inc   c
            ld    a,%01000000
            cp    c
            jr    nz,rLOOP
            ld    de,(RTCSECTOR)
            call  writeSector
            ld    hl,wrterrMsg            ; 'WRITE ERROR!'
            jp    c,lastDisp
; ----------------------------------------
            ld    a,($3fd0)
            and   %00001111
            ld    (COLOR),a               ; foreground color from RTC
            ld    a,($3fd0)
            and   %11110000
            rra
            rra
            rra
            rra
            ld    (COLOR+1),a             ; background color from RTC
            ld    a,($3fd1)
            and   %00001111
            ld    (COLOR+2),a             ; border color from RTC
            ld    a,($3fce)
            and   %11110000
            ld    (SCREEN),a              ; $00 = SCREEN 0 from RTC, $10 = SCREEN 1 from RTC
; ----------------------------------------
            ld    a,BLKS
            ld    (CURBLK),a
; ----------------------------------------
idScan0:
            ld    de,(RTCSECTOR)
            call  readSector
            jr    c,optionX               ; exclude MAIN-ROM from saving

            ld    hl,CODE0
            ld    de,codeStr0             ; check for 'MSX BASIC'
idLoop0:
            ld    a,(de)
            and   DEOBF
            and   a
            jr    z,idFound0
            cp    (hl)
            jr    nz,chgBlk0
            inc   hl
            inc   de
            jr    idLoop0
chgBlk0:                                  ; auto-scanning
            ld    a,(CURBLK)
            dec   a                       ; current block - 1
            cp    NUL
            jr    z,optionX               ; exclude MAIN-ROM from saving
            ld    (CURBLK),a
            ld    hl,(RTCSECTOR)
            ld    de,$0020                ; 32 sectors by 512 bytes = 1 block
            sbc   hl,de
            ld    (RTCSECTOR),hl
            jr    idScan0
; ----------------------------------------
idFound0:
            ld    a,(OPTION)
            cp    NONE
            jr    z,noParam0              ; jump if no parameters
            cp    OPTA
            jr    z,optionA               ; jump if 'a'
            cp    OPTB
            jr    z,optionB               ; jump if 'b'
            cp    OPTC
            jr    z,optionC               ; jump if 'c'
; ----------------------------------------
optionX:
            ld    hl,partialMsg           ; 'Partial '
            call  strDisp                 ; 'RTC saved'
            jr    lastDisp                ; exclude MAIN-ROM from saving
optionA:
            ld    a,(COLOR+2)
            ld    (COLOR+1),a
            jr    setColor                ; COLOR foregr,border,border from RTC
optionB:
            ld    a,15
            ld    (COLOR),a
            xor   a
            ld    (COLOR+1),a
            ld    (COLOR+2),a
            jr    setColor                ; COLOR white,black,black (15,0,0)
optionC:
            ld    a,(FORCLR)
            ld    (COLOR),a
            ld    a,(BAKCLR)
            ld    (COLOR+1),a
            ld    a,(BRDCLR)
            ld    (COLOR+2),a
            jr    setColor                ; COLOR from System Variables in RAM
; ----------------------------------------
noParam0:
            ld    a,(SCREEN)
            cp    NUL
            jr    nz,setColor
            ld    a,(COLOR+1)             ; if SCREEN 0  set COLOR foregr,backgr,backgr from RTC
            ld    (COLOR+2),a
setColor:                                 ; if SCREEN 1  set COLOR foregr,backgr,border from RTC
            ld    hl,DATA0
            ld    a,(COLOR)
            ld    (hl),a
            inc   hl
            ld    a,(COLOR+1)
            ld    (hl),a
            inc   hl
            ld    a,(COLOR+2)
            ld    (hl),a
            ld    de,(RTCSECTOR)
            call  writeSector
            ld    hl,partialMsg           ; 'Partial '
            call  c,strDisp
            ld    hl,okayMsg              ; 'RTC saved'
            jr    lastDisp
; ----------------------------------------
noID:
            ld    hl,noidMsg              ; 'No custom SDBIOS found!'
            jr    lastDisp
isUnsupp:
            ld    hl,unsuppMsg            ; 'UNSUPPORTED KERNEL FOUND!'
; ----------------------------------------
lastDisp:
            dec   c                       ; use 'jr lastDisp' or 'jp lastDisp'
strDisp:
            inc   c                       ; use 'call strDisp'
charLoop:
            ld    a,(hl)                  ; load 1st char, ascii < 127 only
            and   DEOBF                   ; de-obfuscation
            ld    ix,CHPUT                ; init chput
            ld    iy,(EXPTBL-1)           ; init main-rom slot
            call  CALSLT                  ; NUL and EOF are not valid as 1st
            inc   hl
            xor   a
            cp    (hl)
            jr    nz,nextChar             ; NUL,n = SPC(n)
            inc   hl
            ld    b,(hl)                  ; b = n
            ld    a,(jrnzSPC)             ; protection: jrnzSPC = $20
;           and   DEOBF                   ; de-obfuscation (optional)
spcLoop:
            ld    ix,CHPUT                ; init chput
            ld    iy,(EXPTBL-1)           ; init main-rom slot
            call  CALSLT                  ; print SPC until b = 0
            djnz  spcLoop
            inc   hl
nextChar:
            ld    a,EOF
            cp    (hl)
            jr    nz,charLoop             ; EOF = end of string
            inc   hl                      ; point to the next string at exit
            dec   c
            ld    a,LF
            cp    c                       ; c = LF is 'lastDisp'
            ret   nz                      ; exit of 'strDisp'
            ld    de,strLFCR              ; print LF + CR after 'lastDisp'
            ld    c,_STROUT               ; 'OPTION' and 'PREFIX' will be lost
            call  _BDOS
mainExit:
            xor   a
            ld    (PLENGHT),a             ; reset PLENGHT for the next command
            ei
            ret
strLFCR:
            .DB   LF,CR,'$'
; ----------------------------------------
readSector:
            ld    a,$3f                   ; CCF
            jr    rwSector
writeSector:
            xor   a                       ; NOP
rwSector:
            ld    (setrwSector),a
            ld    hl,$3e00
            ld    bc,$01f0
            xor   a
            scf
setrwSector:
            ccf                           ; CCF = read sector, NOP = write sector
            rst   30
            .DB   %10001011               ; slot 3-2
            .DW   $4010
            ld    c,LF+ONE                ; init 'call strDisp' to use
            ret
; ----------------------------------------
rRTC:
            rst   30
            .DB   %10000111               ; slot 3-1
            .DW   $01f5
            ret
; ----------------------------------------
codeStr:
            .DB   'R'|_,'T'|_,'C'|_,' '|_,'C'|_,'O'|_,'D'|_,'E'|_,NUL
codeStr0:
            .DB   'M'|_,'S'|_,'X'|_,' '|_,'B'|_,'A'|_,'S'|_,'I'|_,'C'|_,NUL
; ----------------------------------------
helpMsg:                                  ; texts comply with 40 columns
            .DB   LF|_
            .DB   CLS|_,'S'|_,'y'|_,'n'|_,'t'|_,'a'|_,'x'|_,':'|_,' '|_,FN1|_,FN2|_,FN3|_,FN4|_,FN5|_,FN6|_,FN7|_,' '|_
            .DB   '['|_,'{'|_,SLASH|_,'|'|_,MINUS|_,'}'|_,'o'|_,'p'|_,'t'|_,'i'|_,'o'|_,'n'|_,']'|_
            .DB   LF|_

            .DB   LF|_,CR|_,'M'|_,'A'|_,'I'|_,'N'|_,'-'|_,'R'|_,'O'|_,'M'|_,' '|_,'C'|_,'O'|_,'L'|_,'O'|_,'R'
            .DB   LF|_,CR|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_
            .DB   LF|_,CR|_,'D'|_,'e'|_,'f'|_,'a'|_,'u'|_,'l'|_,'t'|_,' '|_,'s'|_,'e'|_,'t'|_,'t'|_,'i'|_,'n'|_,'g'|_,'s'|_,' '|_
            .DB   'w'|_,'i'|_,'t'|_,'h'|_,' '|_,'n'|_,'o'|_,' '|_,'p'|_,'a'|_,'r'|_,'a'|_,'m'|_,'e'|_,'t'|_,'e'|_,'r'|_,':'|_
            .DB   LF|_,CR|_,' '|_,'i'|_,'f'|_,' '|_,'S'|_,'C'|_,'R'|_,'E'|_,'E'|_,'N'|_,' '|_,'0'|_,' '|_,' '|_,'s'|_,'e'|_,'t'|_
helpMsg0:
            .DB   LF|_,CR|_,'C'|_,'O'|_,'L'|_,'O'|_,'R'|_,' '|_,'f'|_,'o'|_,'r'|_,'e'|_,'g'|_,'r'|_,','|_
            .DB   'b'|_,'a'|_,'c'|_,'k'|_,'g'|_,'r'|_,','|_,'b'|_,'a'|_,'c'|_,'k'|_,'g'|_,'r'|_,' '|_
            .DB   'f'|_,'r'|_,'o'|_,'m'|_,' '|_,'R'|_,'T'|_,'C'|_
            .DB   LF|_,CR|_,' '|_,'i'|_,'f'|_,' '|_,'S'|_,'C'|_,'R'|_,'E'|_,'E'|_,'N'|_,' '|_,'1'|_,' '|_,' '|_,'s'|_,'e'|_,'t'|_
helpMsg1:
            .DB   LF|_,CR|_,'C'|_,'O'|_,'L'|_,'O'|_,'R'|_,' '|_,'f'|_,'o'|_,'r'|_,'e'|_,'g'|_,'r'|_,','|_
            .DB   'b'|_,'a'|_,'c'|_,'k'|_,'g'|_,'r'|_,','|_,'b'|_,'o'|_,'r'|_,'d'|_,'e'|_,'r'|_,' '|_
            .DB   'f'|_,'r'|_,'o'|_,'m'|_,' '|_,'R'|_,'T'|_,'C'|_
            .DB   LF|_

            .DB   LF|_,CR|_,'C'|_,'u'|_,'s'|_,'t'|_,'o'|_,'m'|_,' '|_,'s'|_,'e'|_,'t'|_,'t'|_,'i'|_,'n'|_,'g'|_,'s'|_,' '|_
            .DB   't'|_,'h'|_,'r'|_,'o'|_,'u'|_,'g'|_,'h'|_,' '|_,'o'|_,'p'|_,'t'|_,'i'|_,'o'|_,'n'|_,'s'|_,':'|_
            .DB   LF|_,CR|_,' '|_,OPTA|_,' '|_,' '|_,'C'|_,'O'|_,'L'|_,'O'|_,'R'|_,' '|_,'f'|_,'o'|_,'r'|_,'e'|_,'g'|_,'r'|_,','|_
            .DB   'b'|_,'o'|_,'r'|_,'d'|_,'e'|_,'r'|_,','|_,'b'|_,'o'|_,'r'|_,'d'|_,'e'|_,'r'|_,' '|_
            .DB   'f'|_,'r'|_,'o'|_,'m'|_,' '|_,'R'|_,'T'|_,'C'|_
            .DB   LF|_,CR|_,' '|_,OPTB|_,' '|_,' '|_,'C'|_,'O'|_,'L'|_,'O'|_,'R'|_,' '|_,'w'|_,'h'|_,'i'|_,'t'|_,'e'|_,','|_
            .DB   'b'|_,'l'|_,'a'|_,'c'|_,'k'|_,','|_,'b'|_,'l'|_,'a'|_,'c'|_,'k'|_,' '|_
            .DB   '('|_,'1'|_,'5'|_,','|_,'0'|_,','|_,'0'|_,')'|_
            .DB   LF|_,CR|_,' '|_,OPTC|_,' '|_,' '|_,'C'|_,'O'|_,'L'|_,'O'|_,'R'|_,' '|_,'f'|_,'r'|_,'o'|_,'m'|_,' '|_
            .DB   'S'|_,'y'|_,'s'|_,'t'|_,'e'|_,'m'|_,' '|_,'V'|_,'a'|_,'r'|_,'i'|_,'a'|_,'b'|_,'l'|_,'e'|_,'s'|_,' '|_
            .DB   'i'|_,'n'|_,' '|_,'R'|_,'A'|_,'M'|_
            .DB   LF|_,CR|_,' '|_,OPTX|_,' '|_,' '|_,'e'|_,'x'|_,'c'|_,'l'|_,'u'|_,'d'|_,'e'|_,' '|_
            .DB   'M'|_,'A'|_,'I'|_,'N'|_,'-'|_,'R'|_,'O'|_,'M'|_,' '|_,'f'|_,'r'|_,'o'|_,'m'|_,' '|_
            .DB   's'|_,'a'|_,'v'|_,'i'|_,'n'|_,'g'|_
            .DB   LF|_

            .DB   LF|_,CR|_,'S'|_,'U'|_,'B'|_,'-'|_,'R'|_,'O'|_,'M'|_,' '|_,'R'|_,'T'|_,'C'|_,' '|_,'C'|_,'O'|_,'D'|_,'E'|_
            .DB   LF|_,CR|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_,'-'|_
            .DB   LF|_,CR|_,'P'|_,'e'|_,'r'|_,'f'|_,'o'|_,'r'|_,'m'|_,' '|_,'S'|_,'E'|_,'T'|_,' '|_
            .DB   'S'|_,'C'|_,'R'|_,'E'|_,'E'|_,'N'|_,' '|_,'f'|_,'r'|_,'o'|_,'m'|_,' '|_
            .DB   'B'|_,'A'|_,'S'|_,'I'|_,'C'|_,' '|_,'b'|_,'e'|_,'f'|_,'o'|_,'r'|_,'e'|_
helpMsg2:
            .DB   LF|_,CR|_,'s'|_,'a'|_,'v'|_,'i'|_,'n'|_,'g'|_,' '|_,'t'|_,'h'|_,'e'|_,' '|_
            .DB   'R'|_,'T'|_,'C'|_,' '|_,'c'|_,'o'|_,'d'|_,'e'|_

            .DB   EOF
wrterrMsg:
            .DB   'W'|_,'R'|_,'I'|_,'T'|_,'E'|_,' '|_,'E'|_,'R'|_,'R'|_,'O'|_,'R'|_,'!'|_,EOF
partialMsg:
            .DB   'P'|_,'a'|_,'r'|_,'t'|_,'i'|_,'a'|_,'l'|_,' '|_,EOF
okayMsg:
            .DB   'R'|_,'T'|_,'C'|_,' '|_,'s'|_,'a'|_,'v'|_,'e'|_,'d'|_,EOF
nobiosMsg:
            .DB   'M'|_,'S'|_,'X'|_,'-'|_,'B'|_,'I'|_,'O'|_,'S'|_,' '|_,'n'|_,'o'|_,'t'|_,' '|_
            .DB   'f'|_,'o'|_,'u'|_,'n'|_,'d'|_,' '|_,'f'|_,'r'|_,'o'|_,'m'|_,' '|_
            .DB   'S'|_,'D'|_,'/'|_,'S'|_,'D'|_,'H'|_,'C'|_,','|_,' '|_,'p'|_,'l'|_,'e'|_,'a'|_,'s'|_,'e'|_,' '|_
            .DB   'i'|_,'n'|_,'s'|_,'t'|_,'a'|_,'l'|_,'l'|_,' '|_,'S'|_,'D'|_,'B'|_,'I'|_,'O'|_,'S'|_,' '|_
            .DB   'f'|_,'i'|_,'r'|_,'s'|_,'t'|_,'!'|_,EOF
noidMsg:
            .DB   'N'|_,'o'|_,' '|_,'c'|_,'u'|_,'s'|_,'t'|_,'o'|_,'m'|_,' '|_,'S'|_,'D'|_,'B'|_,'I'|_,'O'|_,'S'|_,' '|_
            .DB   'f'|_,'o'|_,'u'|_,'n'|_,'d'|_,'!'|_,EOF
errorMsg0:
            .DB   LF|_,'*'|_,'*'|_,'*'|_,' '|_
            .DB   'I'|_,'n'|_,'v'|_,'a'|_,'l'|_,'i'|_,'d'|_,' '|_,EOF
errorMsg1:
            .DB   'p'|_,'a'|_,'r'|_,'a'|_,'m'|_,'e'|_,'t'|_,'e'|_,'r'|_,EOF
errorMsg2:
            .DB   'o'|_,'p'|_,'t'|_,'i'|_,'o'|_,'n'|_,EOF
unsuppMsg:
            .DB   'U'|_,'N'|_,'S'|_,'U'|_,'P'|_,'P'|_,'O'|_,'R'|_,'T'|_,'E'|_,'D'|_,' '|_
            .DB   'K'|_,'E'|_,'R'|_,'N'|_,'E'|_,'L'|_,' '|_,'F'|_,'O'|_,'U'|_,'N'|_,'D'|_,'!'|_,EOF
; ----------------------------------------
startFill:                                ; $FF fill the 1st hex line
;           .FILL ((((startFill-startProg)/HLN)+ONE)*HLN-(startFill-startProg))
endProg:                                  ; $FF fill the cluster
;           .FILL ((((endProg-startProg)/CLU)+ONE)*CLU-(endProg-startProg))-HLN
                                          ; [ FILENAME.COM ] at last hex line
            .DB   "[ ",FN1+UP,FN2+UP,FN3+UP,FN4+UP,FN5+UP,FN6+UP,FN7+UP,SPC
            .DB   ".COM ]"

            .END

;
; -----------------------------------------------------------------------------
; APPENDIX
; -----------------------------------------------------------------------------
;
; ---| MSX-BIOS Configuration (OCM-PLD v3.4 or later) |------------------------
;
; 3-2 (4000h)  128kB  MEGASDHC.ROM + NULL64KB.ROM / NEXTOR16.ROM   blocks 01-08
; 0-0 (0000h)   32kB  MSX2P   .ROM / MSXTR   .ROM                  blocks 09-10
; 3-3 (4000h)   16kB  XBASIC2 .ROM / XBASIC21.ROM                  block  11
; 0-2 (4000h)   16kB  MSX2PMUS.ROM / MSXTRMUS.ROM                  block  12
; 3-1 (0000h)   16kB  MSX2PEXT.ROM / MSXTREXT.ROM                  block  13
; 3-1 (4000h)   32kB  MSXKANJI.ROM                                 blocks 14-15
; 0-3 (4000h)   16kB  FREE16KB.ROM / MSXTROPT.ROM                  block  16
; I/O          128kB  JIS1    .ROM                                 blocks 17-24
; I/O          128kB  JIS2    .ROM                        (512kB)  blocks 25-32
; -----------------------------------------------------------------------------
; Note: Slot0-1 has been replaced with Slot3-3 since OCM-PLD v3.5
; -----------------------------------------------------------------------------
;
; ---| MSX-BIOS Configuration (OCM-PLD v3.0 to v3.3.3) |-----------------------
;
; 3-2 (4000h)   64kB  MEGASDHC.ROM                                 blocks 01-04
; 0-0 (0000h)   32kB  MSX2P   .ROM                                 blocks 05-06
; 3-1 (0000h)   16kB  MSX2PEXT.ROM (patch S0-1 is required)        block  07
; 0-2 (4000h)   16kB  MSX2PMUS.ROM                                 block  08
; I/O          128kB  JIS1    .ROM                                 blocks 09-16
; 0-1 (0000h)   16kB  FREE16KB.ROM                                 block  17
; 0-1 (4000h)   32kB  MSXKANJI.ROM                                 blocks 18-19
; 0-1 (C000h)   16kB  FREE16KB.ROM                                 block  20
; 0-3 (0000h)   16kB  FREE16KB.ROM                                 block  21
; 0-3 (4000h)   16kB  XBASIC2 .ROM                                 block  22
; 0-3 (8000h)   16kB  FREE16KB.ROM                                 block  23
; 0-3 (C000h)   16kB  FREE16KB.ROM                                 block  24
; N/A          128kB  FREE16KB.ROM * 8                    (512kB)  blocks 25-32
; -----------------------------------------------------------------------------
;
; MAIN-ROM
; -----------------------------------------------------------------------------
; Offset(h) 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F                  
;
; 00003E00  00 C0 E7 30 04 EB 22 C2 F6 2A 08 80 23 22 76 F6  .Àç0.ë"Âö*.€#"vö
; 00003E10  7C 32 B1 FB CD 9A 62 C3 01 46 CD 1E 7E 5A 79 C5  |2±ûÍšbÃ.FÍ.~ZyÅ
; 00003E20  D5 CD 0C 00 D1 C1 57 B3 23 C9 3E 40 90 47 26 00  ÕÍ..ÑÁW³#É>@.G&.
; 00003E30  1F CB 1C 1F CB 1C 1F 1F E6 03 4F 78 06 00 E5 21  .Ë..Ë...æ.Ox..å!
; 00003E40  C1 FC 09 E6 0C B1 4F 7E E1 B1 C9 CF B7 CF EF CD  Áü.æ.±O~á±ÉÏ·ÏïÍ
; 00003E50  1C 52 C2 55 40 FE 10 D2 5A 47 22 A7 F6 F5 CD 1C  .RÂU@þ.ÒZG"§öõÍ.
; 00003E60  6C F1 CD 6B 7E CD A7 62 C3 01 46 F5 2A 4A FC 11  lñÍk~Í§bÃ.Fõ*Jü.
; 00003E70  F5 FE 19 3D F2 72 7E EB 2A 74 F6 44 4D 2A 72 F6  õþ.=òr~ë*töDM*rö
; 00003E80  7D 91 6F 7C 98 67 F1 E5 F5 01 8C 00 09 44 4D 2A  }‘o|˜gñåõ.Œ..DM* 
; 00003E90  C2 F6 09 E7 D2 75 62 F1 32 5F F8 6B 62 22 60 F8  Âö.çÒubñ2_økb"`ø
; 00003EA0  2B 2B 22 72 F6 C1 7D 91 6F 7C 98 67 22 74 F6 2B  ++"röÁ}‘o|˜g"tö+ 
; 00003EB0  2B C1 F9 C5 3A 5F F8 6F 2C 26 00 29 19 EB D5 01  +ÁùÅ:_øo,&.).ëÕ.
; 00003EC0  09 01 73 23 72 23 EB 36 00 09 EB 3D F2 C2 7E E1  ..s#r#ë6..ë=òÂ~á
; 00003ED0  01 09 00 09 22 62 F8 C9 4D 53 58 20 20 73 79 73  ...."bøÉMSX  sys
; 00003EE0  74 65 6D 00 76 65 72 73 69 6F 6E 20 33 2E 30 0D  tem.version 3.0.
; 00003EF0  0A 00 4D 53 58 20 42 41 53 49 43 20 00 43 6F 70  ..MSX BASIC .Cop
; 00003F00  79 72 69 67 68 74 20 31 39 38 38 20 62 79 20 4D  yright 1988 by M
; 00003F10  69 63 72 6F 73 6F 66 74 0D 0A 00 20 42 79 74 65  icrosoft... Byte
; 00003F20  73 20 66 72 65 65 00 D3 A8 5E 18 03 D3 A8 73 7A  s free.Ó¨^..Ó¨sz
; 00003F30  D3 A8 C9 D3 A8 08 CD 98 F3 08 F1 D3 A8 08 C9 DD  Ó¨ÉÓ¨.Í˜ó.ñÓ¨.ÉÝ 
; 00003F40  E9 5A 47 5A 47 5A 47 5A 47 5A 47 5A 47 5A 47 5A  éZGZGZGZGZGZGZGZ
; 00003F50  47 5A 47 5A 47 27 1D 1D 18 0E 00 00 00 00 00 08  GZGZG'..........
; 00003F60  00 00 00 00 00 18 00 20 00 00 00 1B 00 38 00 18  ....... .....8..
; 00003F70  00 20 00 00 00 1B 00 38 00 08 00 00 00 00 00 1B  . .....8........
; 00003F80  00 38 01 01 01 00 00 E0 00 00 00 00 00 00 00 FF  .8.....à.......ÿ
; 00003F90  0F 04 04 C3 00 00 C3 00 00 0F 59 F9 FF 01 32 F0  ...Ã..Ã...Yùÿ.2ð
; 00003FA0  FB F0 FB 53 5C 26 2D 0F 25 2D 0E 16 1F 53 5C 26  ûðûS\&-.%-...S\&
; 00003FB0  2D 0F 00 01 00 01 3A 11 89 FD A7 C0 04 C9 CD D1  -.....:.‰ý§À.ÉÍÑ
; 00003FC0  7F 5E 18 04 CD D1 7F 73 DB A8 E6 3F D3 A8 79 18  .^..ÍÑ.sÛ¨æ?Ó¨y.
; 00003FD0  15 0F 0F E6 03 57 DB A8 47 E6 3F D3 A8 3A FF FF  ...æ.WÛ¨Gæ?Ó¨:ÿÿ
; 00003FE0  2F 4F E6 FC B2 57 32 FF FF 78 D3 A8 7B C9 00 00  /Oæü²W2ÿÿxÓ¨{É..
; 00003FF0  00 00 DB 99 07 30 FB C3 1C 00 C3 CA FF C3 7D F3  ..Û™.0ûÃ..ÃÊÿÃ}ó
; -----------------------------------------------------------------------------
;
; SUB-ROM
; -----------------------------------------------------------------------------
; Offset(h) 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F                  
;
; 00003E00  3E EC D5 CD 3F 3E D1 7B FE 55 C8 3E 4C 18 2D FE  >ýi-?>Ð{¦U+>L.-¦
; 00003E10  59 20 06 CD 3C 3E 7B 18 0C FE 57 20 0D CD 3C 3E  Y .-<>{..¦W .-<>
; 00003E20  7B FE 49 28 E6 FE 45 C0 18 E1 FE 56 20 0C 3E 55  {¦I(µ¦E+.ß¦V .>U
; 00003E30  D5 CD 39 3E CD D7 3D 18 CD 5F 3E 51 CD 7C 3D 21  i-9>-Î=.-_>Q-|=!
; 00003E40  FC FA CB 7E 28 0E FE E0 38 04 D6 20 18 06 FE A0  ³·-~(.¦Ó8.Í ..¦á
; 00003E50  30 02 C6 20 2A F8 F3 77 23 7D FE 18 20 03 21 F0  0.ã *°¾w#}¦. .!­
; 00003E60  FB 3A FA F3 BD C8 22 F8 F3 C9 3A DB F3 A7 C8 3A  ¹:·¾¢+"°¾+:¦¾º+:
; 00003E70  D9 FB A7 C0 3E 0F 32 D9 FB F3 D3 AB 3E 0A 3D 20  +¹º+>.2+¹¾Ë½>.= 
; 00003E80  FD 3E 0E D3 AB FB C9 21 FC FA CB 46 28 05 CB 86  ²>.Ë½¹+!³·-F(.-å
; 00003E90  AF 18 19 3A AC FC 3C 28 10 3A EB FB 0F 38 08 AF  »..:¼³<(.:Ù¹.8.»
; 00003EA0  32 F9 FA CB C6 18 05 3E FF 32 AC FC F5 3E 0F D3  2¨·-ã..> 2¼³§>.Ë
; 00003EB0  A0 DB A2 E6 7F 47 F1 B7 3E 80 28 01 AF B0 D3 A1  á¦óµ.G±À>Ç(.»¦Ëí
; 00003EC0  C9 2A 3A 5D 5F 3F 3E 7B 7D 5C 40 3E 3F 5B 3C 7B  +*:]_?>{}\@>?[<{
; 00003ED0  7D B0 DE A1 A5 DF A4 A2 A3 0A 15 25 28 23 18 40  }¦ÌíÑ¯ñóú..%(#.@
; 00003EE0  21 05 16 4B 01 0A 06 04 19 28 80 08 02 03 17 40  !..K.....(Ç....@
; 00003EF0  49 8C 47 22 FD F4 92 F5 92 F6 F7 F8 F9 FA FB FC  IîG"²¶Æ§Æ÷¸°¨·¹³
; 00003F00  93 93 93 86 87 88 89 8A 8B 8C 88 8D 8A 8E FF FF  ôôôåçêëèïîê.èÄ  
; 00003F10  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF                  
; 00003F20  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF                  
; 00003F30  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF                  
; 00003F40  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF                  
; 00003F50  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF                  
; 00003F60  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF                  
; 00003F70  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF                  
; 00003F80  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF                  
; 00003F90  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF                  
; 00003FA0  21 C6 3F 0E 10 7E 23 F5 CD 9E 1C F1 0F 0F 0F 0F  !ã?..~#§-×.±....
; 00003FB0  0C CD 9E 1C 0C 79 E6 0F FE 0E 20 E9 0C 0C 3E 40  .-×..yµ.¦. Ú..>@
; 00003FC0  B9 20 E2 C3 8E 05 FF FF FF FF FF 0F 9F 0A 00 50  ¦ Ô+Ä.     .ƒ..P
; 00003FD0  4F 17 02 A0 00 00 00 00 00 00 B0 FF FF FF FF FF  O..á......¦     
; 00003FE0  52 54 43 20 43 4F 44 45 FF FF FF FF FF FF FF FF  RTC CODE        
; 00003FF0  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF                  
; -----------------------------------------------------------------------------
;
; DISKIO (#4010)  Sector(s) read/write
; -----------------------------------------------------------------------------
; Input:  [F]     carry set for write
;                 carry reset for read
;         [A]     Drive number (0 is A:)
;         [B]     Number of sectors to write
;         [C]     Media descriptor
;         [DE]    Logical sector number (starts at 0)
;         [HL]    Transfer address
;
; Output: [F]     carry set on error
;                 carry reset on success
;         [A]     If error: errorcode
;         [B]     Number of sectors transferred (always)
;
; Error codes in [A] can be:
;         0       Write protected
;         2       Not ready
;         4       Data (CRC) error
;         6       Seek error
;         8       Record not found
;         10      Write fault
;         12      Other errors
; -----------------------------------------------------------------------------
;
