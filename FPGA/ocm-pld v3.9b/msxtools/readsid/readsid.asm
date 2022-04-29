;
; readsid.*
;
; Copyright (c) 2020 KdL
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
;     Prog: Read Silicon ID v1.1 by KdL
;     Date: 2020.01.09
;     Coded in TWZ'CA3 w/ TASM80 v3.2ud
; ----------------------------------------
;

              .ORG  $0100

LF            .EQU  $0a                   ; ascii table
CR            .EQU  $0d
EOF           .EQU  $1a

_BDOS         .EQU  $0005
_STROUT       .EQU  $09                   ; string output

ENASLT        .EQU  $0024
RAMAD1        .EQU  $f342

MEGACON_HIGH  .EQU  $60
MEGACON_PORT  .EQU  MEGACON_HIGH*256
DOS2_BANK     .EQU  $00
ASMI_BANK     .EQU  $60
ASMI_SLOT     .EQU  %10001011             ; slot 3-2
ASMI_PORT     .EQU  $4000
ASMI_HIGH     .EQU  $5000
ACMD_RD_SID   .EQU  %10101011

ONE           .EQU  $01                   ;   1 byte  for char
HLN           .EQU  $10                   ;  16 bytes for hex line
CLU           .EQU  $0100                 ; 256 bytes for cluster
; ----------------------------------------
startProg:
              jr    mainProg              ; type support, A:\>TYPE FILENAME.COM
typeMsg:
;             .DB   CR,SPC,SPC,SPC,SPC,LF ; 'jr mainProg' ctrl sequences mask
              .DB   CR,"Read Silicon ID v1.1 by KdL 2020",CR
              .DB   LF,EOF
; ----------------------------------------
mainProg:
              ld    h,MEGACON_HIGH        ; init connection with epcs
              ld    a,ASMI_SLOT
              call  ENASLT
              ld    hl,MEGACON_PORT
              ld    (hl),ASMI_BANK
              ld    hl,ASMI_PORT
              ld    (hl),ACMD_RD_SID
              ld    (hl),a                ; 1st dummy byte
              ld    (hl),a                ; 2nd dummy byte
              ld    (hl),a                ; 3rd dummy byte
              ld    a,(hl)                ; 1st attempt
              ld    a,(hl)                ; 2nd attempt
              ld    a,(hl)                ; 3rd attempt
              ld    a,(hl)                ; 4th attempt
              ld    a,(hl)                ; 5th attempt
              ld    (_silicon_id),a       ; a = silicon id
              ld    a,(ASMI_HIGH)

              ld    hl,MEGACON_PORT       ; close connection with epcs
              ld    (hl),DOS2_BANK
              ld    a,(RAMAD1)
              ld    h,MEGACON_HIGH
              call  ENASLT

              ld    a,(_silicon_id)       ; bit-7 to ascii char
              and   %10000000
              rlc   a
              or    %00110000
              ld    (_msgdata),a

              ld    a,(_silicon_id)       ; bit-6 to ascii char
              and   %01000000
              rlc   a
              rlc   a
              or    %00110000
              ld    (_msgdata+1),a

              ld    a,(_silicon_id)       ; bit-5 to ascii char
              and   %00100000
              rlc   a
              rlc   a
              rlc   a
              or    %00110000
              ld    (_msgdata+2),a

              ld    a,(_silicon_id)       ; bit-4 to ascii char
              and   %00010000
              rlc   a
              rlc   a
              rlc   a
              rlc   a
              or    %00110000
              ld    (_msgdata+3),a

              ld    a,(_silicon_id)       ; bit-3 to ascii char
              and   %00001000
              rrc   a
              rrc   a
              rrc   a
              or    %00110000
              ld    (_msgdata+5),a

              ld    a,(_silicon_id)       ; bit-2 to ascii char
              and   %00000100
              rrc   a
              rrc   a
              or    %00110000
              ld    (_msgdata+6),a

              ld    a,(_silicon_id)       ; bit-1 to ascii char
              and   %00000010
              rrc   a
              or    %00110000
              ld    (_msgdata+7),a

              ld    a,(_silicon_id)       ; bit-0 to ascii char
              and   %00000001
              or    %00110000
              ld    (_msgdata+8),a

              ld    a,(_silicon_id)
              cp    %00010000             ; epcs1 id
              jr    z,is_epcs1
              cp    %00010010             ; epcs4 id
              jr    z,is_epcs4
              cp    %00010100             ; epcs16 id
              jr    z,is_epcs16
              cp    %00010110             ; epcs64 id
              jr    nz,is_unknown

is_epcs64:
              ld    de,_epcs64
              jr    print_sid

is_epcs16:
              ld    de,_epcs16
              jr    print_sid

is_epcs4:
              ld    de,_epcs4
              jr    print_sid

is_epcs1:
              ld    de,_epcs1
              jr    print_sid

is_unknown:
              ld    de,_unknown

print_sid:
              ld    c,_STROUT
              call  _BDOS
              ld    de,_msgdata0
              ld    c,_STROUT
              jp    _BDOS                 ; print and exit

; ----------------------------------------
_silicon_id:
              nop
; ----------------------------------------
_epcs1:
              .DB "(EPCS1",'$'
_epcs4:
              .DB "(EPCS4",'$'
_epcs16:
              .DB "(EPCS16",'$'
_epcs64:
              .DB "(EPCS64",'$'
_unknown:
              .DB "(Unknown",'$'
_msgdata0:
              .DB ") Silicon ID = b'"
_msgdata:
              .DB "???? ????",LF,CR,'$'
; ----------------------------------------
startFill:                                ; $FF fill the 1st hex line
              .FILL ((((startFill-startProg)/HLN)+ONE)*HLN-(startFill-startProg))
endProg:                                  ; $FF fill the cluster
;             .FILL ((((endProg-startProg)/CLU)+ONE)*CLU-(endProg-startProg))-HLN
                                          ; [ FILENAME.COM ] at last hex line
              .DB   "[ READSID .COM ]"

              .END


