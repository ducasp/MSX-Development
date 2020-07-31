;
; ESP8266 TCP/IP UNAPI 1.2 - Restart to Wi-Fi Setup
; (c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com
;
; Port #F2 support is provided by KdL (2020.06.27)
;

;--- System variables and routines:
_BDOS:					equ #0005
_STROUT:				equ	#09

;--- I/O ports:
PORT_F2:				equ	#F2

	org	#0100

	jp	INIT

	; A:\>TYPE ESPSETUP.COM
	db	CR
	db	"ESP8266 TCP/IP UNAPI 1.2 - Restart to Wi-Fi Setup"	,CR,LF
	db	"(c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com"	,CR,LF,LF
;---
	db	"Hold F1 during system boot to enter setup or simply run this tool."	,CR,LF,LF,EOF
;---

INIT:
	ld	a,#F1
	out	(PORT_F2),a
	in	a,(PORT_F2)
	cp	#F1
	jr	nz,UNSUPP_CMD				; If not #F1, unsupported command
	ld	ix,0
	ld	iy,(#FCC0)
	call  #001C						; soft reset
	ld	de,UNEXPECTED				; Print Unexpected error
	jr	PRINT
UNSUPP_CMD:
	ld	de,UNSUPPORTED				; Print Unsupported command
; Routine to print the string addressed by HL
PRINT:
	ld	c,_STROUT
	jp	_BDOS						; When string is finished, done and exit!

;--- Strings
LF						equ	10
CR						equ	13
EOF						equ 26

UNSUPPORTED:
	db	LF
	db	"*** Unsupported command"	,CR,LF,"$"

UNEXPECTED:
	db	LF
	db	"*** Unexpected error"		,CR,LF,"$"

ID_END:	ds	384+#00F0-ID_END,#FF

BUILD_NAME:				db	"[ ESPSETUP.COM ]"

SEG_CODE_END:
; Final size must be 384 bytes
