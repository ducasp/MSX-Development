;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11570 (MINGW64)
;--------------------------------------------------------
	.module CFG8266
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _FinishUpdate
	.globl _WaitForRXData
	.globl _ultostr
	.globl _TxByte
	.globl _IsValidInput
	.globl _MyRead
	.globl _DosCall
	.globl _Close
	.globl _Open
	.globl _Inkey
	.globl _Cls
	.globl _Beep
	.globl _InputString
	.globl _Print
	.globl _strlen
	.globl _atol
	.globl _atoi
	.globl _puts
	.globl _printf
	.globl _speedStr
	.globl _strAPSts
	.globl _uiTimeout
	.globl _ucSetTimeout
	.globl _ucRadioOff
	.globl _ucNagleOn
	.globl _ucNagleOff
	.globl _ucIsFw
	.globl _ucLocalUpdate
	.globl _lPort
	.globl _uiPort
	.globl _ucScan
	.globl _TickCount
	.globl _chFiller2
	.globl _strUsage
	.globl _responseReady2
	.globl _aDone
	.globl _advance
	.globl _radioOffResponse
	.globl _responseRadioOnTimeout
	.globl _responseOTASPIFF
	.globl _responseOTAFW
	.globl _responseWRBlock
	.globl _responseRSCERTUpdate
	.globl _responseRSFWUpdate
	.globl _apstsResponse
	.globl _apconfigurationResponse
	.globl _scanresResponse
	.globl _nagleoffResponse
	.globl _nagleonResponse
	.globl _scanresNoNetwork
	.globl _scanResponse
	.globl _responseOK
	.globl _certificateDone
	.globl _versionResponse
	.globl _endUpdate
	.globl _chFiller
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
_myPort6	=	0x0006
_myPort7	=	0x0007
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_TickCount	=	0xfc9e
_ucScan::
	.ds 1
_uiPort::
	.ds 2
_lPort::
	.ds 4
_ucLocalUpdate::
	.ds 1
_ucIsFw::
	.ds 1
_ucNagleOff::
	.ds 1
_ucNagleOn::
	.ds 1
_ucRadioOff::
	.ds 1
_ucSetTimeout::
	.ds 1
_uiTimeout::
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_strAPSts::
	.ds 12
_speedStr::
	.ds 20
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;src\CFG8266.c:47: unsigned int MyRead (int Handle, unsigned char* Buffer, unsigned int Size)
;	---------------------------------
; Function MyRead
; ---------------------------------
_MyRead::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-12
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:53: regs.Words.DE = (unsigned int) Buffer;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, #0x0004
	add	hl, de
	ld	c, 6 (ix)
	ld	a, 7 (ix)
	ld	(hl), c
	inc	hl
	ld	(hl), a
;src\CFG8266.c:54: regs.Words.HL = Size;
	ld	hl, #0x0006
	add	hl, de
	ld	a, 8 (ix)
	ld	(hl), a
	inc	hl
	ld	a, 9 (ix)
	ld	(hl), a
;src\CFG8266.c:55: regs.Bytes.B = (unsigned char)(Handle&0xff);
	ld	hl, #3
	add	hl, sp
	ld	a, 4 (ix)
	ld	(hl), a
;src\CFG8266.c:56: DosCall(0x48, &regs, REGS_MAIN, REGS_MAIN);
	ld	hl, #0
	add	hl, sp
	ld	c, l
	ld	b, h
	ld	e, c
	ld	d, b
	push	bc
	ld	bc, #0x0202
	push	bc
	push	de
	ld	a, #0x48
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
	pop	bc
;src\CFG8266.c:57: if (regs.Bytes.A == 0)
	ld	l, c
	ld	h, b
	inc	hl
	ld	a, (hl)
	or	a, a
	jr	NZ,00102$
;src\CFG8266.c:60: iRet = regs.Words.HL;
	ld	l, c
	ld	h, b
	ld	de, #0x0006
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	jr	00103$
00102$:
;src\CFG8266.c:63: iRet = 0;
	ld	bc, #0x0000
00103$:
;src\CFG8266.c:65: return iRet;
	ld	l, c
	ld	h, b
;src\CFG8266.c:66: }
	ld	sp, ix
	pop	ix
	ret
_Done_Version:
	.ascii "Made with FUSION-C 1.2 (ebsoft)"
	.db 0x00
_chFiller:
	.db #0x43	; 67	'C'
	.db #0x46	; 70	'F'
	.db #0x47	; 71	'G'
	.db #0x38	; 56	'8'
	.db #0x32	; 50	'2'
	.db #0x36	; 54	'6'
	.db #0x36	; 54	'6'
	.db #0x20	; 32
	.db #0x59	; 89	'Y'
	.db #0x6f	; 111	'o'
	.db #0x75	; 117	'u'
	.db #0x20	; 32
	.db #0x68	; 104	'h'
	.db #0x61	; 97	'a'
	.db #0x76	; 118	'v'
	.db #0x65	; 101	'e'
	.db #0x20	; 32
	.db #0x61	; 97	'a'
	.db #0x20	; 32
	.db #0x67	; 103	'g'
	.db #0x6f	; 111	'o'
	.db #0x6f	; 111	'o'
	.db #0x64	; 100	'd'
	.db #0x20	; 32
	.db #0x74	; 116	't'
	.db #0x69	; 105	'i'
	.db #0x6d	; 109	'm'
	.db #0x65	; 101	'e'
	.db #0x20	; 32
	.db #0x72	; 114	'r'
	.db #0x65	; 101	'e'
	.db #0x61	; 97	'a'
	.db #0x64	; 100	'd'
	.db #0x69	; 105	'i'
	.db #0x6e	; 110	'n'
	.db #0x67	; 103	'g'
	.db #0x20	; 32
	.db #0x74	; 116	't'
	.db #0x68	; 104	'h'
	.db #0x69	; 105	'i'
	.db #0x73	; 115	's'
	.db #0x20	; 32
	.db #0x74	; 116	't'
	.db #0x61	; 97	'a'
	.db #0x6c	; 108	'l'
	.db #0x65	; 101	'e'
	.db #0x20	; 32
	.db #0x6f	; 111	'o'
	.db #0x66	; 102	'f'
	.db #0x20	; 32
	.db #0x61	; 97	'a'
	.db #0x6e	; 110	'n'
	.db #0x20	; 32
	.db #0x77	; 119	'w'
	.db #0x65	; 101	'e'
	.db #0x69	; 105	'i'
	.db #0x72	; 114	'r'
	.db #0x64	; 100	'd'
	.db #0x20	; 32
	.db #0x62	; 98	'b'
	.db #0x65	; 101	'e'
	.db #0x68	; 104	'h'
	.db #0x61	; 97	'a'
	.db #0x76	; 118	'v'
	.db #0x69	; 105	'i'
	.db #0x6f	; 111	'o'
	.db #0x72	; 114	'r'
	.db #0x2c	; 44
	.db #0x20	; 32
	.db #0x73	; 115	's'
	.db #0x69	; 105	'i'
	.db #0x74	; 116	't'
	.db #0x20	; 32
	.db #0x61	; 97	'a'
	.db #0x6e	; 110	'n'
	.db #0x64	; 100	'd'
	.db #0x20	; 32
	.db #0x68	; 104	'h'
	.db #0x61	; 97	'a'
	.db #0x76	; 118	'v'
	.db #0x65	; 101	'e'
	.db #0x20	; 32
	.db #0x66	; 102	'f'
	.db #0x75	; 117	'u'
	.db #0x6e	; 110	'n'
	.db #0x20	; 32
	.db #0x61	; 97	'a'
	.db #0x73	; 115	's'
	.db #0x20	; 32
	.db #0x74	; 116	't'
	.db #0x68	; 104	'h'
	.db #0x69	; 105	'i'
	.db #0x73	; 115	's'
	.db #0x20	; 32
	.db #0x69	; 105	'i'
	.db #0x73	; 115	's'
	.db #0x20	; 32
	.db #0x6f	; 111	'o'
	.db #0x76	; 118	'v'
	.db #0x65	; 101	'e'
	.db #0x72	; 114	'r'
	.db #0x77	; 119	'w'
	.db #0x72	; 114	'r'
	.db #0x69	; 105	'i'
	.db #0x74	; 116	't'
	.db #0x74	; 116	't'
	.db #0x65	; 101	'e'
	.db #0x6e	; 110	'n'
	.db #0x21	; 33
	.db #0x0d	; 13
	.db #0x0a	; 10
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
_endUpdate:
	.db #0x45	; 69	'E'
	.db #0x00	; 0
_versionResponse:
	.db #0x56	; 86	'V'
_certificateDone:
	.db #0x49	; 73	'I'
	.db #0x00	; 0
_responseOK:
	.db #0x4f	; 79	'O'
	.db #0x4b	; 75	'K'
_scanResponse:
	.db #0x53	; 83	'S'
	.db #0x00	; 0
_scanresNoNetwork:
	.db #0x53	; 83	'S'
	.db #0x02	; 2
_nagleonResponse:
	.db #0x44	; 68	'D'
	.db #0x00	; 0
_nagleoffResponse:
	.db #0x4e	; 78	'N'
	.db #0x00	; 0
_scanresResponse:
	.db #0x73	; 115	's'
	.db #0x00	; 0
_apconfigurationResponse:
	.db #0x41	; 65	'A'
	.db #0x00	; 0
_apstsResponse:
	.db #0x67	; 103	'g'
	.db #0x00	; 0
	.db #0x00	; 0
_responseRSFWUpdate:
	.db #0x5a	; 90	'Z'
	.db #0x00	; 0
_responseRSCERTUpdate:
	.db #0x59	; 89	'Y'
	.db #0x00	; 0
_responseWRBlock:
	.db #0x7a	; 122	'z'
	.db #0x00	; 0
_responseOTAFW:
	.db #0x55	; 85	'U'
	.db #0x00	; 0
_responseOTASPIFF:
	.db #0x75	; 117	'u'
	.db #0x00	; 0
_responseRadioOnTimeout:
	.db #0x54	; 84	'T'
	.db #0x00	; 0
_radioOffResponse:
	.db #0x4f	; 79	'O'
	.db #0x00	; 0
_advance:
	.db #0x5b	; 91
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x5d	; 93
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x00	; 0
	.db #0x5b	; 91
	.db #0x20	; 32
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x20	; 32
	.db #0x5d	; 93
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x00	; 0
	.db #0x5b	; 91
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x5d	; 93
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x00	; 0
	.db #0x5b	; 91
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x5d	; 93
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x00	; 0
	.db #0x5b	; 91
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x01	; 1
	.db #0x57	; 87	'W'
	.db #0x5d	; 93
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x1d	; 29
	.db #0x00	; 0
_aDone:
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x0d	; 13
	.db #0x00	; 0
_responseReady2:
	.db #0x52	; 82	'R'
	.db #0x65	; 101	'e'
	.db #0x61	; 97	'a'
	.db #0x64	; 100	'd'
	.db #0x79	; 121	'y'
	.db #0x0d	; 13
	.db #0x0a	; 10
_strUsage:
	.ascii "Usage:  CFG8266 [options]"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii " /s  to scan networks and choose one to connect"
	.db 0x0d
	.db 0x0a
	.ascii " /m  to turn on Nagle Algorithm"
	.db 0x0d
	.db 0x0a
	.ascii " /n  to turn off Nagle Algorithm (default)"
	.db 0x0d
	.db 0x0a
	.ascii " /o  to turn off radio now if no connections are open"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii " FW.BIN       to update ESP8266 firmware locally"
	.db 0x0d
	.db 0x0a
	.ascii " CERT.BIN /c  to update TLS certificates locally"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii " /u SERVER PORT FILEPATH  to update ESP8266 firmware remotel"
	.ascii "y"
	.db 0x0d
	.db 0x0a
	.ascii " /c SERVER PORT FILEPATH  to update TLS certificates remotel"
	.ascii "y"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii " /t TIME  to change the inactivity time in seconds to disabl"
	.ascii "e radio"
	.db 0x0d
	.db 0x0a
	.ascii "          time range is 0-600 seconds (0 means never disable"
	.ascii ")"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii "Example:  CFG8266 /u 192.168.31.1 80 /fw/fw.bin"
	.db 0x0d
	.db 0x0a
	.db 0x00
_chFiller2:
	.db #0x43	; 67	'C'
	.db #0x46	; 70	'F'
	.db #0x47	; 71	'G'
	.db #0x38	; 56	'8'
	.db #0x32	; 50	'2'
	.db #0x36	; 54	'6'
	.db #0x36	; 54	'6'
	.db #0x20	; 32
	.db #0x59	; 89	'Y'
	.db #0x6f	; 111	'o'
	.db #0x75	; 117	'u'
	.db #0x20	; 32
	.db #0x68	; 104	'h'
	.db #0x61	; 97	'a'
	.db #0x76	; 118	'v'
	.db #0x65	; 101	'e'
	.db #0x20	; 32
	.db #0x61	; 97	'a'
	.db #0x20	; 32
	.db #0x67	; 103	'g'
	.db #0x6f	; 111	'o'
	.db #0x6f	; 111	'o'
	.db #0x64	; 100	'd'
	.db #0x20	; 32
	.db #0x74	; 116	't'
	.db #0x69	; 105	'i'
	.db #0x6d	; 109	'm'
	.db #0x65	; 101	'e'
	.db #0x20	; 32
	.db #0x72	; 114	'r'
	.db #0x65	; 101	'e'
	.db #0x61	; 97	'a'
	.db #0x64	; 100	'd'
	.db #0x69	; 105	'i'
	.db #0x6e	; 110	'n'
	.db #0x67	; 103	'g'
	.db #0x20	; 32
	.db #0x74	; 116	't'
	.db #0x68	; 104	'h'
	.db #0x69	; 105	'i'
	.db #0x73	; 115	's'
	.db #0x20	; 32
	.db #0x74	; 116	't'
	.db #0x61	; 97	'a'
	.db #0x6c	; 108	'l'
	.db #0x65	; 101	'e'
	.db #0x20	; 32
	.db #0x6f	; 111	'o'
	.db #0x66	; 102	'f'
	.db #0x20	; 32
	.db #0x61	; 97	'a'
	.db #0x6e	; 110	'n'
	.db #0x20	; 32
	.db #0x77	; 119	'w'
	.db #0x65	; 101	'e'
	.db #0x69	; 105	'i'
	.db #0x72	; 114	'r'
	.db #0x64	; 100	'd'
	.db #0x20	; 32
	.db #0x62	; 98	'b'
	.db #0x65	; 101	'e'
	.db #0x68	; 104	'h'
	.db #0x61	; 97	'a'
	.db #0x76	; 118	'v'
	.db #0x69	; 105	'i'
	.db #0x6f	; 111	'o'
	.db #0x72	; 114	'r'
	.db #0x2c	; 44
	.db #0x20	; 32
	.db #0x73	; 115	's'
	.db #0x69	; 105	'i'
	.db #0x74	; 116	't'
	.db #0x20	; 32
	.db #0x61	; 97	'a'
	.db #0x6e	; 110	'n'
	.db #0x64	; 100	'd'
	.db #0x20	; 32
	.db #0x68	; 104	'h'
	.db #0x61	; 97	'a'
	.db #0x76	; 118	'v'
	.db #0x65	; 101	'e'
	.db #0x20	; 32
	.db #0x66	; 102	'f'
	.db #0x75	; 117	'u'
	.db #0x6e	; 110	'n'
	.db #0x20	; 32
	.db #0x61	; 97	'a'
	.db #0x73	; 115	's'
	.db #0x20	; 32
	.db #0x74	; 116	't'
	.db #0x68	; 104	'h'
	.db #0x69	; 105	'i'
	.db #0x73	; 115	's'
	.db #0x20	; 32
	.db #0x69	; 105	'i'
	.db #0x73	; 115	's'
	.db #0x20	; 32
	.db #0x6f	; 111	'o'
	.db #0x76	; 118	'v'
	.db #0x65	; 101	'e'
	.db #0x72	; 114	'r'
	.db #0x77	; 119	'w'
	.db #0x72	; 114	'r'
	.db #0x69	; 105	'i'
	.db #0x74	; 116	't'
	.db #0x74	; 116	't'
	.db #0x65	; 101	'e'
	.db #0x6e	; 110	'n'
	.db #0x21	; 33
	.db #0x0d	; 13
	.db #0x0a	; 10
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
;src\CFG8266.c:69: unsigned int IsValidInput (char**argv, int argc, unsigned char *cServer, unsigned char *cFile, unsigned char *cPort)
;	---------------------------------
; Function IsValidInput
; ---------------------------------
_IsValidInput::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;src\CFG8266.c:71: unsigned int ret = 1;
	ld	bc, #0x0001
;src\CFG8266.c:72: unsigned char * Input = (unsigned char*)argv[0];
	ld	a, 4 (ix)
	ld	-4 (ix), a
	ld	a, 5 (ix)
	ld	-3 (ix), a
	pop	hl
	push	hl
	ld	a, (hl)
	ld	-2 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-1 (ix), a
;src\CFG8266.c:74: ucScan = 0;
	ld	hl,#_ucScan + 0
	ld	(hl), #0x00
;src\CFG8266.c:76: if (argc)
	ld	a, 7 (ix)
	or	a, 6 (ix)
	jp	Z, 00162$
;src\CFG8266.c:78: if ((argc==1)||(argc==2)||(argc==4))
	ld	a, 6 (ix)
	dec	a
	or	a, 7 (ix)
	ld	a, #0x01
	jr	Z,00287$
	xor	a, a
00287$:
	ld	d, a
	or	a, a
	jr	NZ,00156$
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	jr	Z,00156$
	ld	a, 6 (ix)
	sub	a, #0x04
	or	a, 7 (ix)
	jp	NZ,00157$
00156$:
;src\CFG8266.c:82: if ((Input[0]=='/')&&((Input[1]=='s')||(Input[1]=='S')))
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	a, (hl)
	sub	a, #0x2f
	ld	a, #0x01
	jr	Z,00292$
	xor	a, a
00292$:
	ld	e, a
;src\CFG8266.c:80: if ((argc==1)||(argc==2))
	ld	a, d
	or	a, a
	jr	NZ,00152$
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	jp	NZ,00153$
00152$:
;src\CFG8266.c:82: if ((Input[0]=='/')&&((Input[1]=='s')||(Input[1]=='S')))
	ld	a, e
	or	a, a
	jr	Z,00132$
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	inc	hl
	ld	a, (hl)
	cp	a, #0x73
	jr	Z,00131$
	sub	a, #0x53
	jr	NZ,00132$
00131$:
;src\CFG8266.c:83: ucScan = 1;
	ld	hl,#_ucScan + 0
	ld	(hl), #0x01
	jp	00163$
00132$:
;src\CFG8266.c:84: else if ((Input[0]=='/')&&((Input[1]=='n')||(Input[1]=='N')))
	ld	a, e
	or	a, a
	jr	Z,00127$
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	inc	hl
	ld	a, (hl)
	cp	a, #0x6e
	jr	Z,00126$
	sub	a, #0x4e
	jr	NZ,00127$
00126$:
;src\CFG8266.c:85: ucNagleOff = 1;
	ld	hl,#_ucNagleOff + 0
	ld	(hl), #0x01
	jp	00163$
00127$:
;src\CFG8266.c:86: else if ((Input[0]=='/')&&((Input[1]=='m')||(Input[1]=='M')))
	ld	a, e
	or	a, a
	jr	Z,00122$
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	inc	hl
	ld	a, (hl)
	cp	a, #0x6d
	jr	Z,00121$
	sub	a, #0x4d
	jr	NZ,00122$
00121$:
;src\CFG8266.c:87: ucNagleOn = 1;
	ld	hl,#_ucNagleOn + 0
	ld	(hl), #0x01
	jp	00163$
00122$:
;src\CFG8266.c:88: else if ((Input[0]=='/')&&((Input[1]=='o')||(Input[1]=='O')))
	ld	a, e
	or	a, a
	jr	Z,00117$
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	inc	hl
	ld	a, (hl)
	cp	a, #0x6f
	jr	Z,00116$
	sub	a, #0x4f
	jr	NZ,00117$
00116$:
;src\CFG8266.c:89: ucRadioOff = 1;
	ld	hl,#_ucRadioOff + 0
	ld	(hl), #0x01
	jp	00163$
00117$:
;src\CFG8266.c:90: else if ((Input[0]=='/')&&((Input[1]=='t')||(Input[1]=='T')))
	ld	a, e
	or	a, a
	jr	Z,00112$
	pop	de
	pop	hl
	push	hl
	push	de
	inc	hl
	ld	a, (hl)
	cp	a, #0x74
	jr	Z,00111$
	sub	a, #0x54
	jr	NZ,00112$
00111$:
;src\CFG8266.c:92: ucSetTimeout = 1;
	ld	hl,#_ucSetTimeout + 0
	ld	(hl), #0x01
;src\CFG8266.c:93: Input = (unsigned char*)argv[1];
	pop	hl
	push	hl
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:94: uiTimeout = atoi (Input);
	push	bc
	push	de
	call	_atoi
	pop	af
	pop	bc
	ld	(_uiTimeout), hl
;src\CFG8266.c:95: if (uiTimeout > 600)
	ld	a, #0x58
	ld	iy, #_uiTimeout
	cp	a, 0 (iy)
	ld	a, #0x02
	sbc	a, 1 (iy)
	jp	NC, 00163$
;src\CFG8266.c:96: uiTimeout = 600;
	ld	hl, #0x0258
	ld	(_uiTimeout), hl
	jp	00163$
00112$:
;src\CFG8266.c:100: strcpy (cFile,Input);
	push	bc
	ld	e, 10 (ix)
	ld	d, 11 (ix)
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	xor	a, a
00310$:
	cp	a, (hl)
	ldi
	jr	NZ, 00310$
	pop	bc
;src\CFG8266.c:101: ucLocalUpdate = 1;
	ld	hl,#_ucLocalUpdate + 0
	ld	(hl), #0x01
;src\CFG8266.c:102: if (argc==2)
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	jr	NZ,00109$
;src\CFG8266.c:104: Input = (unsigned char*)argv[1];
	pop	hl
	push	hl
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:105: if ((Input[0]=='/')&&((Input[1]=='c')||(Input[1]=='C')))
	ld	a, (de)
	sub	a, #0x2f
	jr	NZ,00104$
	ex	de,hl
	inc	hl
	ld	a, (hl)
	cp	a, #0x63
	jr	Z,00103$
	sub	a, #0x43
	jr	NZ,00104$
00103$:
;src\CFG8266.c:106: ucIsFw=0;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x00
	jp	00163$
00104$:
;src\CFG8266.c:108: ret=0;
	ld	bc, #0x0000
	jp	00163$
00109$:
;src\CFG8266.c:112: ucIsFw=1;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x01
	jp	00163$
00153$:
;src\CFG8266.c:117: if ((Input[0]=='/')&&((Input[1]=='u')||(Input[1]=='U')))
	ld	a, e
	or	a, a
	jp	Z, 00148$
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	inc	hl
	ld	a, (hl)
	cp	a, #0x75
	jr	Z,00147$
	sub	a, #0x55
	jp	NZ,00148$
00147$:
;src\CFG8266.c:119: ucIsFw = 1;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x01
;src\CFG8266.c:120: Input = (unsigned char*)argv[2];
	pop	hl
	push	hl
	ld	de, #0x0004
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:121: if (strlen (Input)<7)
	push	bc
	push	de
	call	_strlen
	pop	af
	pop	bc
	ld	a, l
	sub	a, #0x07
	ld	a, h
	sbc	a, #0x00
	jr	NC,00137$
;src\CFG8266.c:123: strcpy(cPort,Input);
	push	bc
	ex	de,hl
	ld	e, 12 (ix)
	ld	d, 13 (ix)
	xor	a, a
00321$:
	cp	a, (hl)
	ldi
	jr	NZ, 00321$
	pop	bc
;src\CFG8266.c:124: Input = (unsigned char*)argv[1];
	pop	hl
	push	hl
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	h, (hl)
;src\CFG8266.c:125: strcpy(cServer,Input);
	push	bc
	ld	l, e
	ld	e, 8 (ix)
	ld	d, 9 (ix)
	xor	a, a
00322$:
	cp	a, (hl)
	ldi
	jr	NZ, 00322$
	pop	bc
;src\CFG8266.c:126: Input = (unsigned char*)argv[3];
	pop	hl
	push	hl
	ld	de, #0x0006
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	h, (hl)
;src\CFG8266.c:127: strcpy(cFile,Input);
	push	bc
	ld	l, e
	ld	e, 10 (ix)
	ld	d, 11 (ix)
	xor	a, a
00323$:
	cp	a, (hl)
	ldi
	jr	NZ, 00323$
	ld	l, 12 (ix)
	ld	h, 13 (ix)
	push	hl
	call	_atol
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	de, #_lPort
	ld	hl, #2
	add	hl, sp
	ld	bc, #4
	ldir
	pop	bc
;src\CFG8266.c:129: uiPort = (lPort&0xffff);
	ld	hl, (_lPort)
	ld	(_uiPort), hl
	jp	00163$
00137$:
;src\CFG8266.c:132: ret = 0;
	ld	bc, #0x0000
	jp	00163$
00148$:
;src\CFG8266.c:134: else if ((Input[0]=='/')&&((Input[1]=='c')||(Input[1]=='C')))
	ld	a, e
	or	a, a
	jp	Z, 00143$
	pop	de
	pop	hl
	push	hl
	push	de
	inc	hl
	ld	a, (hl)
	cp	a, #0x63
	jr	Z,00142$
	sub	a, #0x43
	jp	NZ,00143$
00142$:
;src\CFG8266.c:136: ucIsFw = 0;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x00
;src\CFG8266.c:137: Input = (unsigned char*)argv[2];
	pop	hl
	push	hl
	ld	de, #0x0004
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:138: if (strlen (Input)<7)
	push	bc
	push	de
	call	_strlen
	pop	af
	pop	bc
	ld	a, l
	sub	a, #0x07
	ld	a, h
	sbc	a, #0x00
	jr	NC,00140$
;src\CFG8266.c:140: strcpy(cPort,Input);
	push	bc
	ex	de,hl
	ld	e, 12 (ix)
	ld	d, 13 (ix)
	xor	a, a
00327$:
	cp	a, (hl)
	ldi
	jr	NZ, 00327$
	pop	bc
;src\CFG8266.c:141: Input = (unsigned char*)argv[1];
	pop	hl
	push	hl
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	h, (hl)
;src\CFG8266.c:142: strcpy(cServer,Input);
	push	bc
	ld	l, e
	ld	e, 8 (ix)
	ld	d, 9 (ix)
	xor	a, a
00328$:
	cp	a, (hl)
	ldi
	jr	NZ, 00328$
	pop	bc
;src\CFG8266.c:143: Input = (unsigned char*)argv[3];
	pop	hl
	push	hl
	ld	de, #0x0006
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	h, (hl)
;src\CFG8266.c:144: strcpy(cFile,Input);
	push	bc
	ld	l, e
	ld	e, 10 (ix)
	ld	d, 11 (ix)
	xor	a, a
00329$:
	cp	a, (hl)
	ldi
	jr	NZ, 00329$
	ld	l, 12 (ix)
	ld	h, 13 (ix)
	push	hl
	call	_atol
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	de, #_lPort
	ld	hl, #2
	add	hl, sp
	ld	bc, #4
	ldir
	pop	bc
;src\CFG8266.c:146: uiPort = (lPort&0xffff);
	ld	hl, (_lPort)
	ld	(_uiPort), hl
	jr	00163$
00140$:
;src\CFG8266.c:149: ret = 0;
	ld	bc, #0x0000
	jr	00163$
00143$:
;src\CFG8266.c:152: ret = 0;
	ld	bc, #0x0000
	jr	00163$
00157$:
;src\CFG8266.c:156: ret = 0;
	ld	bc, #0x0000
	jr	00163$
00162$:
;src\CFG8266.c:159: ret=0;
	ld	bc, #0x0000
00163$:
;src\CFG8266.c:161: return ret;
	ld	l, c
	ld	h, b
;src\CFG8266.c:162: }
	ld	sp, ix
	pop	ix
	ret
;src\CFG8266.c:164: void TxByte(char chTxByte)
;	---------------------------------
; Function TxByte
; ---------------------------------
_TxByte::
;src\CFG8266.c:166: while (myPort7&2);
00101$:
	in	a, (_myPort7)
	bit	1, a
	jr	NZ,00101$
;src\CFG8266.c:170: myPort7 = chTxByte;
	ld	hl, #2+0
	add	hl, sp
	ld	a, (hl)
	out	(_myPort7), a
;src\CFG8266.c:171: }
	ret
;src\CFG8266.c:173: char *ultostr(unsigned long value, char *ptr, int base)
;	---------------------------------
; Function ultostr
; ---------------------------------
_ultostr::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-12
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:176: unsigned long tmp = value;
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	e, 6 (ix)
	ld	d, 7 (ix)
;src\CFG8266.c:179: if (NULL == ptr) //if null pointer
	ld	a, 9 (ix)
	or	a, 8 (ix)
	jr	NZ,00102$
;src\CFG8266.c:180: return NULL; //nothing to do
	ld	hl, #0x0000
	jp	00118$
00102$:
;src\CFG8266.c:188: tmp = tmp/base;
	ld	a, 10 (ix)
	ld	-8 (ix), a
	ld	a, 11 (ix)
	ld	-7 (ix), a
	rla
	sbc	a, a
	ld	-6 (ix), a
	ld	-5 (ix), a
;src\CFG8266.c:182: if (tmp == 0) //if value is zero
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jr	NZ,00123$
;src\CFG8266.c:183: ++count; //one digit
	ld	c, #0x01
	jr	00108$
;src\CFG8266.c:186: while(tmp > 0)
00123$:
	xor	a, a
	ld	-1 (ix), a
00103$:
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jr	Z,00129$
;src\CFG8266.c:188: tmp = tmp/base;
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	push	de
	push	bc
	call	__divulong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c, l
	ld	b, h
;src\CFG8266.c:189: ++count;
	inc	-1 (ix)
	jr	00103$
00129$:
	ld	c, -1 (ix)
00108$:
;src\CFG8266.c:193: ptr += count; // so, after the LSB
	ld	a, 8 (ix)
	add	a, c
	ld	8 (ix), a
	jr	NC,00166$
	inc	9 (ix)
00166$:
;src\CFG8266.c:194: *ptr = '\0'; // null terminator
	ld	c, 8 (ix)
	ld	b, 9 (ix)
	xor	a, a
	ld	(bc), a
;src\CFG8266.c:196: do
00115$:
;src\CFG8266.c:198: t = value / base; // useful now (find remainder) as well later (next value of value)
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	__divulong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c, l
	ld	b, h
;src\CFG8266.c:199: res = value - base * t; // get what remains of dividing base
	push	bc
	push	de
	push	de
	push	bc
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-12 (ix), l
	ld	-11 (ix), h
	ld	-10 (ix), e
	ld	-9 (ix), d
	pop	de
	pop	bc
	ld	a, 4 (ix)
	sub	a, -12 (ix)
	ld	-4 (ix), a
	ld	a, 5 (ix)
	sbc	a, -11 (ix)
	ld	-3 (ix), a
	ld	a, 6 (ix)
	sbc	a, -10 (ix)
	ld	-2 (ix), a
	ld	a, 7 (ix)
	sbc	a, -9 (ix)
	ld	-1 (ix), a
;src\CFG8266.c:201: if (res < 10)
	ld	a, -4 (ix)
	sub	a, #0x0a
	ld	a, -3 (ix)
	sbc	a, #0x00
	ld	a, -2 (ix)
	sbc	a, #0x00
	ld	a, -1 (ix)
	sbc	a, #0x00
	ld	a, #0x00
	rla
	or	a, a
	jr	Z,00113$
;src\CFG8266.c:202: * -- ptr = '0' + res; // convert the remainder to ASCII and put in the current position of pointer, move pointer after operation
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	dec	hl
	ld	8 (ix), l
	ld	9 (ix), h
	ld	a, -4 (ix)
	add	a, #0x30
	ld	(hl), a
	jr	00116$
00113$:
;src\CFG8266.c:203: else if ((res >= 10) && (res < 16)) // Otherwise is a HEX value and a digit above 9
	bit	0, a
	jr	NZ,00116$
	ld	a, -4 (ix)
	sub	a, #0x10
	ld	a, -3 (ix)
	sbc	a, #0x00
	ld	a, -2 (ix)
	sbc	a, #0x00
	ld	a, -1 (ix)
	sbc	a, #0x00
	jr	NC,00116$
;src\CFG8266.c:204: * --ptr = 'A' - 10 + res; // convert the remainder to ASCII and put in the current position of pointer, move pointer after operation
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	dec	hl
	ld	8 (ix), l
	ld	9 (ix), h
	ld	a, -4 (ix)
	add	a, #0x37
	ld	(hl), a
00116$:
;src\CFG8266.c:205: } while ((value = t) != 0); //value is now t, and if t is other than zero, still work to do
	ld	4 (ix), c
	ld	5 (ix), b
	ld	6 (ix), e
	ld	7 (ix), d
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jp	NZ, 00115$
;src\CFG8266.c:207: return(ptr); // and return own pointer as successful conversion has been made
	ld	l, 8 (ix)
	ld	h, 9 (ix)
00118$:
;src\CFG8266.c:208: }
	ld	sp, ix
	pop	ix
	ret
;src\CFG8266.c:210: bool WaitForRXData(unsigned char *uchData, unsigned int uiDataSize, unsigned int Timeout, bool bVerbose, bool bShowReceivedData, unsigned char *uchData2, unsigned int uiDataSize2)
;	---------------------------------
; Function WaitForRXData
; ---------------------------------
_WaitForRXData::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-18
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:212: bool bReturn = false;
	xor	a, a
	ld	-16 (ix), a
;src\CFG8266.c:217: unsigned int i = 0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
;src\CFG8266.c:219: if (bShowReceivedData)
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00104$
;src\CFG8266.c:221: printf ("Waiting for: ");
	ld	hl, #___str_2
	push	hl
	call	_printf
	pop	af
;src\CFG8266.c:222: for (i=0;i<uiDataSize;++i)
	ld	bc, #0x0000
00144$:
	ld	a, c
	sub	a, 6 (ix)
	ld	a, b
	sbc	a, 7 (ix)
	jr	NC,00101$
;src\CFG8266.c:223: printf("%c",uchData[i]);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	add	hl, bc
	ld	e, (hl)
	ld	d, #0x00
	push	bc
	push	de
	ld	hl, #___str_3
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	bc
;src\CFG8266.c:222: for (i=0;i<uiDataSize;++i)
	inc	bc
	jr	00144$
00101$:
;src\CFG8266.c:224: printf (" / ");
	ld	hl, #___str_4
	push	hl
	call	_printf
	pop	af
;src\CFG8266.c:225: for (i=0;i<uiDataSize;++i)
	ld	bc, #0x0000
00147$:
	ld	a, c
	sub	a, 6 (ix)
	ld	a, b
	sbc	a, 7 (ix)
	jr	NC,00102$
;src\CFG8266.c:226: printf("{%x}",uchData[i]);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	add	hl, bc
	ld	e, (hl)
	ld	d, #0x00
	push	bc
	push	de
	ld	hl, #___str_5
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	bc
;src\CFG8266.c:225: for (i=0;i<uiDataSize;++i)
	inc	bc
	jr	00147$
00102$:
;src\CFG8266.c:227: printf ("\r\n");
	ld	hl, #___str_7
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:228: i = 0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00104$:
;src\CFG8266.c:231: Timeout1 = TickCount + 9; //Drives the animation every 9 ticks or so
	ld	iy, #_TickCount
	ld	a, 0 (iy)
	add	a, #0x09
	ld	-15 (ix), a
	ld	a, 1 (iy)
	adc	a, #0x00
	ld	-14 (ix), a
;src\CFG8266.c:232: Timeout2 = TickCount + Timeout; //Wait up to 5 minutes
	ld	a, 0 (iy)
	add	a, 8 (ix)
	ld	c, a
	ld	a, 1 (iy)
	adc	a, 9 (ix)
	ld	b, a
	ld	-13 (ix), c
	ld	-12 (ix), b
;src\CFG8266.c:234: ResponseSt = 0;
	xor	a, a
	ld	-6 (ix), a
	ld	-5 (ix), a
;src\CFG8266.c:235: ResponseSt2 = 0;
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
;src\CFG8266.c:237: do
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	ld	a, #0x01
	jr	Z,00269$
	xor	a, a
00269$:
	ld	-11 (ix), a
	ld	a, #0x84
	cp	a, 8 (ix)
	ld	a, #0x03
	sbc	a, 9 (ix)
	ld	a, #0x00
	rla
	ld	-10 (ix), a
00138$:
;src\CFG8266.c:239: if (Timeout>900)
	ld	a, -10 (ix)
	or	a, a
	jr	Z,00108$
;src\CFG8266.c:241: if (TickCount>Timeout1)
	ld	a, -15 (ix)
	ld	iy, #_TickCount
	sub	a, 0 (iy)
	ld	a, -14 (ix)
	sbc	a, 1 (iy)
	jr	NC,00108$
;src\CFG8266.c:243: Timeout1 = TickCount + 9;
	ld	a, 0 (iy)
	add	a, #0x09
	ld	-15 (ix), a
	ld	a, 1 (iy)
	adc	a, #0x00
	ld	-14 (ix), a
;src\CFG8266.c:244: printf("%s",advance[i%5]); // next char
	ld	hl, #0x0005
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	call	__moduint
	pop	af
	pop	af
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	c,l
	ld	b,h
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ex	(sp), hl
	ld	a, #<(_advance)
	add	a, -18 (ix)
	ld	-8 (ix), a
	ld	a, #>(_advance)
	adc	a, -17 (ix)
	ld	-7 (ix), a
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	ld	hl, #___str_8
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:245: ++i;
	inc	-2 (ix)
	jr	NZ,00270$
	inc	-1 (ix)
00270$:
00108$:
;src\CFG8266.c:248: if(UartRXData())
	in	a, (_myPort7)
	rrca
	jp	NC,00135$
;src\CFG8266.c:250: rx_data = GetUARTData();
	in	a, (_myPort6)
	ld	-9 (ix), a
;src\CFG8266.c:252: if (rx_data == uchData[ResponseSt])
	ld	a, 4 (ix)
	add	a, -6 (ix)
	ld	l, a
	ld	a, 5 (ix)
	adc	a, -5 (ix)
	ld	h, a
	ld	a, (hl)
	ld	-7 (ix), a
	ld	a, -9 (ix)
	sub	a, -7 (ix)
	jr	NZ,00126$
;src\CFG8266.c:254: if (bShowReceivedData)
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00110$
;src\CFG8266.c:255: printf ("{%x}",rx_data);
	ld	c, -9 (ix)
	ld	b, #0x00
	push	bc
	ld	hl, #___str_5
	push	hl
	call	_printf
	pop	af
	pop	af
00110$:
;src\CFG8266.c:256: ++ResponseSt;
	inc	-6 (ix)
	jr	NZ,00274$
	inc	-5 (ix)
00274$:
;src\CFG8266.c:257: if (ResponseSt == uiDataSize)
	ld	a, -6 (ix)
	sub	a, 6 (ix)
	jp	NZ,00127$
	ld	a, -5 (ix)
	sub	a, 7 (ix)
	jp	NZ,00127$
;src\CFG8266.c:259: bReturn = 1;
	ld	-16 (ix), #0x01
;src\CFG8266.c:260: break;
	jp	00140$
00126$:
;src\CFG8266.c:265: if ((ResponseSt)&&(bShowReceivedData))
	ld	a, -5 (ix)
	or	a, -6 (ix)
	jr	Z,00116$
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00116$
;src\CFG8266.c:266: printf ("{%x} != [%x]",rx_data,uchData[ResponseSt]);
	ld	e, -7 (ix)
	ld	d, #0x00
	ld	c, -9 (ix)
	ld	b, #0x00
	push	de
	push	bc
	ld	hl, #___str_9
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	jr	00117$
00116$:
;src\CFG8266.c:267: else if (bShowReceivedData)
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00117$
;src\CFG8266.c:268: printf ("}%x{",rx_data);
	ld	c, -9 (ix)
	ld	b, #0x00
	push	bc
	ld	hl, #___str_10
	push	hl
	call	_printf
	pop	af
	pop	af
00117$:
;src\CFG8266.c:269: if ((uiDataSize==2)&&(ResponseSt==1))
	ld	a, -11 (ix)
	or	a, a
	jr	Z,00123$
	ld	a, -6 (ix)
	dec	a
	or	a, -5 (ix)
	jr	NZ,00123$
;src\CFG8266.c:271: if ((bVerbose)&&(!uchData2))
	ld	a, 10 (ix)
	or	a, a
	jr	Z,00120$
	ld	a, 13 (ix)
	or	a, 12 (ix)
	jr	NZ,00120$
;src\CFG8266.c:272: printf ("Error %u on command %c...\r\n",rx_data,uchData[0]);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	e, (hl)
	ld	d, #0x00
	ld	c, -9 (ix)
	ld	b, #0x00
	push	de
	push	bc
	ld	hl, #___str_11
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
00120$:
;src\CFG8266.c:273: return false;
	ld	l, #0x00
	jp	00149$
00123$:
;src\CFG8266.c:275: ResponseSt = 0;
	xor	a, a
	ld	-6 (ix), a
	ld	-5 (ix), a
00127$:
;src\CFG8266.c:278: if ((uchData2)&&(rx_data == uchData2[ResponseSt2]))
	ld	a, 13 (ix)
	or	a, 12 (ix)
	jr	Z,00131$
	ld	a, 12 (ix)
	add	a, -4 (ix)
	ld	-8 (ix), a
	ld	a, 13 (ix)
	adc	a, -3 (ix)
	ld	-7 (ix), a
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	a,-9 (ix)
	sub	a,(hl)
	jr	NZ,00131$
;src\CFG8266.c:280: ++ResponseSt2;
	inc	-4 (ix)
	jr	NZ,00281$
	inc	-3 (ix)
00281$:
;src\CFG8266.c:281: if (ResponseSt2 == uiDataSize2)
	ld	a, -4 (ix)
	sub	a, 14 (ix)
	jr	NZ,00135$
	ld	a, -3 (ix)
	sub	a, 15 (ix)
	jr	NZ,00135$
;src\CFG8266.c:283: bReturn = 2;
	ld	-16 (ix), #0x02
;src\CFG8266.c:284: break;
	jr	00140$
00131$:
;src\CFG8266.c:288: ResponseSt2 = 0;
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
00135$:
;src\CFG8266.c:291: if (TickCount>Timeout2)
	ld	a, -13 (ix)
	ld	iy, #_TickCount
	sub	a, 0 (iy)
	ld	a, -12 (ix)
	sbc	a, 1 (iy)
	jp	NC, 00138$
;src\CFG8266.c:294: while (1);
00140$:
;src\CFG8266.c:296: if (Timeout>900)
	ld	a, -10 (ix)
	or	a, a
	jr	Z,00142$
;src\CFG8266.c:297: printf("%s",aDone); // clear line
	ld	hl, #_aDone
	push	hl
	ld	hl, #___str_8
	push	hl
	call	_printf
	pop	af
	pop	af
00142$:
;src\CFG8266.c:299: return bReturn;
	ld	l, -16 (ix)
00149$:
;src\CFG8266.c:300: }
	ld	sp, ix
	pop	ix
	ret
___str_2:
	.ascii "Waiting for: "
	.db 0x00
___str_3:
	.ascii "%c"
	.db 0x00
___str_4:
	.ascii " / "
	.db 0x00
___str_5:
	.ascii "{%x}"
	.db 0x00
___str_7:
	.db 0x0d
	.db 0x00
___str_8:
	.ascii "%s"
	.db 0x00
___str_9:
	.ascii "{%x} != [%x]"
	.db 0x00
___str_10:
	.ascii "}%x{"
	.db 0x00
___str_11:
	.ascii "Error %u on command %c..."
	.db 0x0d
	.db 0x0a
	.db 0x00
;src\CFG8266.c:302: void FinishUpdate (bool bSendReset)
;	---------------------------------
; Function FinishUpdate
; ---------------------------------
_FinishUpdate::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;src\CFG8266.c:304: unsigned int iRetries = 3;
	ld	hl, #0x0003
	ex	(sp), hl
;src\CFG8266.c:308: bool bReset = bSendReset;
	ld	a, 4 (ix)
	ld	-2 (ix), a
;src\CFG8266.c:310: printf("\rFinishing flash, this will take some time, WAIT!\r\n");
	ld	hl, #___str_13
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:312: do
	ld	-1 (ix), #0x02
00135$:
;src\CFG8266.c:314: bRet = true;
	ld	l, #0x01
;src\CFG8266.c:315: --ucRetries;
	dec	-1 (ix)
;src\CFG8266.c:316: if (bReset)
	ld	a, -2 (ix)
	or	a, a
	jr	Z,00154$
;src\CFG8266.c:317: TxByte('R'); //Request Reset
	push	hl
	ld	a, #0x52
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	hl
	jr	00110$
;src\CFG8266.c:320: do
00154$:
	pop	de
	push	de
;src\CFG8266.c:322: for (uchHalt=60;uchHalt>0;--uchHalt)
00152$:
	ld	a, #0x3c
00140$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFG8266.c:322: for (uchHalt=60;uchHalt>0;--uchHalt)
	dec	a
	jr	NZ,00140$
;src\CFG8266.c:324: TxByte('E'); //End Update
	push	de
	ld	a, #0x45
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x0708
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	hl, #_endUpdate
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	pop	de
;src\CFG8266.c:326: iRetries--;
	dec	de
;src\CFG8266.c:328: while ((!bRet)&&(iRetries));
	ld	a, l
	or	a, a
	jr	NZ,00170$
	ld	a, d
	or	a, e
	jr	NZ,00152$
00170$:
	inc	sp
	inc	sp
	push	de
;src\CFG8266.c:330: if (bRet)
	ld	a, l
	or	a, a
	jr	Z,00110$
;src\CFG8266.c:331: bReset=true;
	ld	-2 (ix), #0x01
00110$:
;src\CFG8266.c:334: if (!bRet)
	ld	a, l
	or	a, a
	jr	NZ,00133$
;src\CFG8266.c:335: printf("\rTimeout waiting to end update...\r\n");
	ld	hl, #___str_15
	push	hl
	call	_puts
	pop	af
	jp	00136$
00133$:
;src\CFG8266.c:338: if (ucRetries)
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00115$
;src\CFG8266.c:340: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00112$
;src\CFG8266.c:341: printf("\rFirmware Update done, ESP is restarting, WAIT...\r\n");
	ld	hl, #___str_17
	push	hl
	call	_puts
	pop	af
	jr	00115$
00112$:
;src\CFG8266.c:343: printf("\rCertificates Update done, ESP is restarting, WAIT...\r\n");
	ld	hl, #___str_19
	push	hl
	call	_puts
	pop	af
00115$:
;src\CFG8266.c:346: if (WaitForRXData(responseReady2,7,2700,false,false,NULL,0)) //Wait up to 45 seconds
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	ld	hl, #0x0a8c
	push	hl
	ld	hl, #0x0007
	push	hl
	ld	hl, #_responseReady2
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	a, l
	or	a, a
	jp	Z, 00130$
;src\CFG8266.c:348: if (!ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jp	NZ, 00125$
;src\CFG8266.c:350: printf("\rESP Reset Ok, now let's request creation of index file...\r\n");
	ld	hl, #___str_21
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:352: do
	ld	-2 (ix), #0x0a
	xor	a, a
	ld	-1 (ix), a
;src\CFG8266.c:354: for (uchHalt=60;uchHalt>0;--uchHalt)
00162$:
	ld	a, #0x3c
00142$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFG8266.c:354: for (uchHalt=60;uchHalt>0;--uchHalt)
	dec	a
	jr	NZ,00142$
;src\CFG8266.c:356: TxByte('I'); //End Update
	ld	a, #0x49
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:357: bRet = WaitForRXData(certificateDone,2,3600,false,false,NULL,0); //Wait up to 1 minute, certificate index creation takes time
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	ld	hl, #0x0e10
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	hl, #_certificateDone
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	-3 (ix), l
;src\CFG8266.c:358: iRetries--;
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	dec	hl
	ld	-2 (ix), l
	ld	-1 (ix), h
;src\CFG8266.c:360: while ((!bRet)&&(iRetries));
	ld	a, -3 (ix)
	or	a, a
	jr	NZ,00120$
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ,00162$
00120$:
;src\CFG8266.c:361: if (bRet)
	ld	a, -3 (ix)
	or	a, a
	jr	Z,00122$
;src\CFG8266.c:362: printf("\rDone!                                \r\n");
	ld	hl, #___str_23
	push	hl
	call	_puts
	pop	af
	jr	00137$
00122$:
;src\CFG8266.c:364: printf("\rDone, but time-out on creating certificates index file!\r\n");
	ld	hl, #___str_25
	push	hl
	call	_puts
	pop	af
	jr	00137$
00125$:
;src\CFG8266.c:367: printf("\rDone!                              \r\n");
	ld	hl, #___str_27
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:368: break;
	jr	00137$
00130$:
;src\CFG8266.c:371: if (!ucRetries)
	ld	a, -1 (ix)
	or	a, a
	jr	NZ,00136$
;src\CFG8266.c:372: printf("\rTimeout error\r\n");
	ld	hl, #___str_29
	push	hl
	call	_puts
	pop	af
00136$:
;src\CFG8266.c:375: while (ucRetries);
	ld	a, -1 (ix)
	or	a, a
	jp	NZ, 00135$
00137$:
;src\CFG8266.c:377: return;
;src\CFG8266.c:378: }
	ld	sp, ix
	pop	ix
	ret
___str_13:
	.db 0x0d
	.ascii "Finishing flash, this will take some time, WAIT!"
	.db 0x0d
	.db 0x00
___str_15:
	.db 0x0d
	.ascii "Timeout waiting to end update..."
	.db 0x0d
	.db 0x00
___str_17:
	.db 0x0d
	.ascii "Firmware Update done, ESP is restarting, WAIT..."
	.db 0x0d
	.db 0x00
___str_19:
	.db 0x0d
	.ascii "Certificates Update done, ESP is restarting, WAIT..."
	.db 0x0d
	.db 0x00
___str_21:
	.db 0x0d
	.ascii "ESP Reset Ok, now let's request creation of index file..."
	.db 0x0d
	.db 0x00
___str_23:
	.db 0x0d
	.ascii "Done!                                "
	.db 0x0d
	.db 0x00
___str_25:
	.db 0x0d
	.ascii "Done, but time-out on creating certificates index file!"
	.db 0x0d
	.db 0x00
___str_27:
	.db 0x0d
	.ascii "Done!                              "
	.db 0x0d
	.db 0x00
___str_29:
	.db 0x0d
	.ascii "Timeout error"
	.db 0x0d
	.db 0x00
;src\CFG8266.c:380: int main(char** argv, int argc)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-4188
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:397: unsigned char ucFirstBlock = 1;
	ld	-11 (ix), #0x01
;src\CFG8266.c:415: ucLocalUpdate = 0;
	ld	hl,#_ucLocalUpdate + 0
	ld	(hl), #0x00
;src\CFG8266.c:416: ucNagleOff = 0;
	ld	hl,#_ucNagleOff + 0
	ld	(hl), #0x00
;src\CFG8266.c:417: ucNagleOn = 0;
	ld	hl,#_ucNagleOn + 0
	ld	(hl), #0x00
;src\CFG8266.c:418: ucRadioOff = 0;
	ld	hl,#_ucRadioOff + 0
	ld	(hl), #0x00
;src\CFG8266.c:419: ucSetTimeout = 0;
	ld	hl,#_ucSetTimeout + 0
	ld	(hl), #0x00
;src\CFG8266.c:420: ucScanPage = 0;
	xor	a, a
	ld	-17 (ix), a
;src\CFG8266.c:422: ucVerMajor = 0;
	xor	a, a
	ld	-1 (ix), a
;src\CFG8266.c:423: ucVerMinor = 0;
	xor	a, a
	ld	-2 (ix), a
;src\CFG8266.c:424: TickCount = 0; //this guarantees no leap for 18 minutes, more than enough so we do not need to check for jiffy leaping
	ld	hl, #0x0000
	ld	(_TickCount), hl
;src\CFG8266.c:426: printf("> SM-X ESP8266 Wi-Fi Module Configuration v1.30 <\r\n(c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com\r\n\n");
	ld	hl, #___str_31
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:428: if (IsValidInput(argv, argc, ucServer, ucFile, ucPort))
	ld	hl, #4165
	add	hl, sp
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	a, -4 (ix)
	ld	-6 (ix), a
	ld	a, -3 (ix)
	ld	-5 (ix), a
	ld	hl, #3865
	add	hl, sp
	ld	-4 (ix), l
	ld	-3 (ix), h
	ex	de,hl
	ld	hl, #3565
	add	hl, sp
	ld	-10 (ix), l
	ld	-9 (ix), h
	ld	c, l
	ld	b, h
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	push	de
	push	bc
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_IsValidInput
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ld	-6 (ix), l
	ld	-5 (ix), h
	ld	a, h
	or	a, -6 (ix)
	jp	Z, 00374$
;src\CFG8266.c:430: do
	xor	a, a
	ld	-5 (ix), a
00103$:
;src\CFG8266.c:433: myPort6 = speed;
	ld	a, -5 (ix)
	out	(_myPort6), a
;src\CFG8266.c:434: ClearUartData();
	ld	a, #0x14
	out	(_myPort6), a
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFG8266.c:436: TxByte('?');
	ld	a, #0x3f
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:438: bResponse = WaitForRXData(responseOK,2,60,false,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	ld	l, #0x3c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_responseOK
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	a, l
;src\CFG8266.c:440: if (bResponse)
	or	a, a
	jr	NZ,00105$
;src\CFG8266.c:442: ++speed;
	inc	-5 (ix)
;src\CFG8266.c:444: while (speed<10);
	ld	a, -5 (ix)
	sub	a, #0x0a
	jr	C,00103$
00105$:
;src\CFG8266.c:446: if (speed<10)
	ld	a, -5 (ix)
	sub	a, #0x0a
	jp	NC, 00371$
;src\CFG8266.c:448: printf ("Baud Rate: %s\r\n",speedStr[speed]);
	ld	a, -5 (ix)
	ld	-6 (ix), a
	xor	a, a
	ld	-5 (ix), a
	ld	a, -6 (ix)
	ld	-6 (ix), a
	ld	a, -5 (ix)
	ld	-5 (ix), a
	sla	-6 (ix)
	rl	-5 (ix)
	ld	a, #<(_speedStr)
	add	a, -6 (ix)
	ld	-8 (ix), a
	ld	a, #>(_speedStr)
	adc	a, -5 (ix)
	ld	-7 (ix), a
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	a, (hl)
	ld	-6 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-5 (ix), a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	hl, #___str_32
	push	hl
	call	_printf
	pop	af
;src\CFG8266.c:449: TxByte('V'); //Request version
	ld	h,#0x56
	ex	(sp),hl
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:450: bResponse = WaitForRXData(versionResponse,1,20,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x14
	push	hl
	ld	l, #0x01
	push	hl
	ld	hl, #_versionResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
;src\CFG8266.c:451: if (bResponse)
	ld	-5 (ix), l
	ld	a, l
	or	a, a
	jr	Z,00113$
;src\CFG8266.c:453: while(!UartRXData());
00106$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00106$
;src\CFG8266.c:454: ucVerMajor = GetUARTData();
	in	a, (_myPort6)
	ld	-1 (ix), a
;src\CFG8266.c:455: while(!UartRXData());
00109$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00109$
;src\CFG8266.c:456: ucVerMinor = GetUARTData();
	in	a, (_myPort6)
	ld	-2 (ix), a
00113$:
;src\CFG8266.c:458: printf ("FW Version: %c.%c\r\n",ucVerMajor+'0',ucVerMinor+'0');
	ld	c, -2 (ix)
	ld	b, #0x00
	ld	hl, #0x0030
	add	hl, bc
	ex	de, hl
	ld	c, -1 (ix)
	ld	b, #0x00
	ld	hl, #0x0030
	add	hl, bc
	push	de
	push	hl
	ld	hl, #___str_33
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:460: if ((ucScan)||(ucNagleOff)||(ucNagleOn)||(ucRadioOff)||(ucSetTimeout))
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	NZ,00363$
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00363$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	NZ,00363$
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	NZ,00363$
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jp	Z, 00364$
00363$:
;src\CFG8266.c:463: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jp	Z, 00143$
;src\CFG8266.c:465: if ((ucVerMajor>=1)&&(ucVerMinor>=2)) // new firmware allow get current ap and connection status
	ld	a, -1 (ix)
	sub	a, #0x01
	jr	C,00126$
	ld	a, -2 (ix)
	sub	a, #0x02
	jr	C,00126$
;src\CFG8266.c:467: TxByte('g'); //Request current AP status
	ld	a, #0x67
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:468: bResponse = WaitForRXData(apstsResponse,3,30,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x1e
	push	hl
	ld	l, #0x03
	push	hl
	ld	hl, #_apstsResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
;src\CFG8266.c:469: if (bResponse)
	ld	-5 (ix), l
	ld	a, l
	or	a, a
	jr	Z,00126$
;src\CFG8266.c:471: while(!UartRXData());
00114$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00114$
;src\CFG8266.c:472: ucAPstsRspSize=GetUARTData();
	in	a, (_myPort6)
	ld	-3 (ix), a
;src\CFG8266.c:476: while(!UartRXData());
	ld	hl, #3525
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0000
00117$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00117$
;src\CFG8266.c:477: chAPStsInfo[i]=GetUARTData();
	ld	l, e
	ld	h, d
	add	hl, bc
	in	a, (_myPort6)
	ld	(hl), a
;src\CFG8266.c:478: ++i;
	inc	bc
;src\CFG8266.c:480: while(i<ucAPstsRspSize);
	ld	l, -3 (ix)
	ld	h, #0x00
	ld	a, c
	sub	a, l
	ld	a, b
	sbc	a, h
	jr	C,00117$
00126$:
;src\CFG8266.c:483: TxByte('S'); //Request SCAN
	ld	a, #0x53
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jp	00144$
00143$:
;src\CFG8266.c:485: else if (ucNagleOff)
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	Z,00140$
;src\CFG8266.c:486: TxByte('N'); //Request nagle off for future connections
	ld	a, #0x4e
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jp	00144$
00140$:
;src\CFG8266.c:487: else if (ucNagleOn)
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00137$
;src\CFG8266.c:488: TxByte('D'); //Request nagle on for future connections
	ld	a, #0x44
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00144$
00137$:
;src\CFG8266.c:489: else if (ucRadioOff)
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	Z,00134$
;src\CFG8266.c:490: TxByte('O'); //Request to turn off Wi-Fi radio immediately
	ld	a, #0x4f
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00144$
00134$:
;src\CFG8266.c:491: else if (ucSetTimeout)
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jr	Z,00144$
;src\CFG8266.c:493: ucTimeOutMSB = ((unsigned char)((uiTimeout&0xff00)>>8));
	ld	iy, #_uiTimeout
	ld	c, 1 (iy)
	ld	-4 (ix), c
;src\CFG8266.c:494: ucTimeOutLSB = ((unsigned char)(uiTimeout&0xff));
	ld	a, 0 (iy)
	ld	-3 (ix), a
;src\CFG8266.c:495: if (uiTimeout)
	ld	a, 1 (iy)
	or	a, 0 (iy)
	jr	Z,00129$
;src\CFG8266.c:496: printf("\r\nSetting Wi-Fi idle timeout to %u...\r\n",uiTimeout);
	ld	hl, (_uiTimeout)
	push	hl
	ld	hl, #___str_34
	push	hl
	call	_printf
	pop	af
	pop	af
	jr	00130$
00129$:
;src\CFG8266.c:498: printf("\r\nSetting Wi-Fi to always on!\r\n");
	ld	hl, #___str_36
	push	hl
	call	_puts
	pop	af
00130$:
;src\CFG8266.c:499: TxByte('T'); //Request to set time-out
	ld	a, #0x54
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:500: TxByte(0);
	xor	a, a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:501: TxByte(2);
	ld	a, #0x02
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:502: TxByte(ucTimeOutMSB);
	ld	a, -4 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:503: TxByte(ucTimeOutLSB);
	ld	a, -3 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00144$:
;src\CFG8266.c:506: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	Z,00157$
;src\CFG8266.c:507: bResponse = WaitForRXData(scanResponse,2,60,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x3c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_scanResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	-5 (ix), l
	jp	00158$
00157$:
;src\CFG8266.c:508: else if (ucNagleOff)
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	Z,00154$
;src\CFG8266.c:509: bResponse = WaitForRXData(nagleoffResponse,2,60,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x3c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_nagleoffResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	-5 (ix), l
	jp	00158$
00154$:
;src\CFG8266.c:510: else if (ucNagleOn)
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00151$
;src\CFG8266.c:511: bResponse = WaitForRXData(nagleonResponse,2,60,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x3c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_nagleonResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	-5 (ix), l
	jr	00158$
00151$:
;src\CFG8266.c:512: else if (ucRadioOff)
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	Z,00148$
;src\CFG8266.c:513: bResponse = WaitForRXData(radioOffResponse,2,60,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x3c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_radioOffResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	-5 (ix), l
	jr	00158$
00148$:
;src\CFG8266.c:514: else if (ucSetTimeout)
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jr	Z,00158$
;src\CFG8266.c:515: bResponse = WaitForRXData(responseRadioOnTimeout,2,60,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x3c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_responseRadioOnTimeout
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	-5 (ix), l
00158$:
;src\CFG8266.c:518: if ((bResponse)&&(ucScan))
	ld	a, -5 (ix)
	or	a, a
	jp	Z, 00294$
	ld	iy, #_ucScan
	ld	a, 0 (iy)
	or	a, a
	jp	Z, 00294$
;src\CFG8266.c:521: do
	ld	c, #0x14
00161$:
;src\CFG8266.c:523: --ucRetries;
	dec	c
;src\CFG8266.c:524: for (ucHalt = 30;ucHalt>0;--ucHalt)
	ld	b, #0x1e
00379$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFG8266.c:524: for (ucHalt = 30;ucHalt>0;--ucHalt)
	ld	a, b
	dec	a
	ld	b, a
	or	a, a
	jr	NZ,00379$
;src\CFG8266.c:526: TxByte('s'); //Request SCAN result
	push	bc
	ld	a, #0x73
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	ld	hl, #0x0002
	push	hl
	ld	hl, #_scanresNoNetwork
	push	hl
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	ld	hl, #0x003c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_scanresResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	pop	bc
;src\CFG8266.c:529: while ((ucRetries)&&(!bResponse));
	ld	a, c
	or	a, a
	jr	Z,00163$
	ld	a, l
	or	a, a
	jr	Z,00161$
00163$:
;src\CFG8266.c:531: if (bResponse==1)
	dec	l
	jp	NZ,00268$
;src\CFG8266.c:534: while(!UartRXData());
00164$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00164$
;src\CFG8266.c:535: ucAPs = GetUARTData();
	in	a, (_myPort6)
	ld	-16 (ix), a
;src\CFG8266.c:536: if (ucAPs>100)
	ld	a, #0x64
	sub	a, -16 (ix)
	jr	NC,00168$
;src\CFG8266.c:537: ucAPs=100;
	ld	-16 (ix), #0x64
00168$:
;src\CFG8266.c:539: printf ("\r\n");
	ld	hl, #___str_38
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:540: do
	ld	hl, #83
	add	hl, sp
	ld	-15 (ix), l
	ld	-14 (ix), h
	xor	a, a
	ld	-3 (ix), a
;src\CFG8266.c:545: while(!UartRXData());
00433$:
	ld	c, -3 (ix)
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ex	de, hl
	ld	a, e
	add	a, -15 (ix)
	ld	c, a
	ld	a, d
	adc	a, -14 (ix)
	ld	b, a
	ld	e, #0x00
00169$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00169$
;src\CFG8266.c:546: rx_data=GetUARTData();
	in	a, (_myPort6)
	ld	-4 (ix), a
;src\CFG8266.c:547: stAP[tx_data].APName[ucIndex++]=rx_data;
	ld	a, e
	inc	e
	ld	l, a
	ld	h, #0x00
	add	hl, bc
	ld	a, -4 (ix)
	ld	(hl), a
;src\CFG8266.c:549: while(rx_data!=0);
	ld	a, -4 (ix)
	or	a, a
	jr	NZ,00169$
;src\CFG8266.c:550: while(!UartRXData());
00175$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00175$
;src\CFG8266.c:551: rx_data=GetUARTData();
	in	a, (_myPort6)
	ld	c, a
;src\CFG8266.c:552: stAP[tx_data].isEncrypted = (rx_data == 'E') ? 1 : 0;
	ld	e, -3 (ix)
	ld	d, #0x00
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	add	hl, hl
	ex	de, hl
	ld	a, -15 (ix)
	add	a, e
	ld	e, a
	ld	a, -14 (ix)
	adc	a, d
	ld	d, a
	ld	hl, #0x0021
	add	hl, de
	ld	-7 (ix), l
	ld	-6 (ix), h
	ld	a, c
	sub	a, #0x45
	jr	NZ,00392$
	ld	-5 (ix), #0x01
	xor	a, a
	ld	-4 (ix), a
	jr	00393$
00392$:
	xor	a, a
	ld	-5 (ix), a
	ld	-4 (ix), a
00393$:
	ld	a, -5 (ix)
	ld	l, -7 (ix)
	ld	h, -6 (ix)
	ld	(hl), a
;src\CFG8266.c:553: ++tx_data;
	inc	-3 (ix)
;src\CFG8266.c:555: while (tx_data!=ucAPs);
	ld	a, -3 (ix)
	sub	a, -16 (ix)
	jp	NZ,00433$
;src\CFG8266.c:556: ClearUartData();
	ld	a, #0x14
	out	(_myPort6), a
;src\CFG8266.c:558: do
	ld	a, -2 (ix)
	sub	a, #0x02
	ld	a, #0x00
	rla
	ld	-13 (ix), a
	ld	a, -1 (ix)
	sub	a, #0x01
	ld	a, #0x00
	rla
	ld	-12 (ix), a
	ld	hl, #3525
	add	hl, sp
	ld	-11 (ix), l
	ld	-10 (ix), h
	ld	a, -11 (ix)
	add	a, #0x01
	ld	-9 (ix), a
	ld	a, -10 (ix)
	adc	a, #0x00
	ld	-8 (ix), a
	xor	a, a
	ld	-2 (ix), a
00264$:
;src\CFG8266.c:560: Cls();
	call	_Cls
;src\CFG8266.c:561: printf("%s%s\r\n\n",strAPSts[chAPStsInfo[0]],&chAPStsInfo[1]);
	ld	a, -9 (ix)
	ld	-6 (ix), a
	ld	a, -8 (ix)
	ld	-5 (ix), a
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	ld	a, (hl)
	ld	-1 (ix), a
	ld	-4 (ix), a
	xor	a, a
	ld	-3 (ix), a
	ld	a, -4 (ix)
	ld	iy, #16
	add	iy, sp
	ld	0 (iy), a
	ld	a, -3 (ix)
	ld	1 (iy), a
	sla	0 (iy)
	rl	1 (iy)
	ld	a, #<(_strAPSts)
	ld	hl, #16
	add	hl, sp
	add	a, (hl)
	ld	-4 (ix), a
	ld	a, #>(_strAPSts)
	inc	hl
	adc	a, (hl)
	ld	-3 (ix), a
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	a, (hl)
	ld	-4 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	ld	hl, #___str_39
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:562: printf("Choose AP:\r\n\n");
	ld	hl, #___str_41
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:564: ucIndex = scanPageLimit*ucScanPage;
	ld	a, -2 (ix)
	ld	c, a
	add	a, a
	add	a, a
	add	a, c
	add	a, a
	ld	-1 (ix), a
;src\CFG8266.c:566: if ((ucAPs-ucIndex)<=scanPageLimit)
	ld	a, -16 (ix)
	ld	-7 (ix), a
	xor	a, a
	ld	-6 (ix), a
	ld	a, -1 (ix)
	ld	iy, #16
	add	iy, sp
	ld	0 (iy), a
	xor	a, a
	ld	1 (iy), a
	ld	hl, #16
	add	hl, sp
	ld	a, -7 (ix)
	sub	a, (hl)
	ld	-4 (ix), a
	ld	a, -6 (ix)
	inc	hl
	sbc	a, (hl)
	ld	-3 (ix), a
	ld	a, #0x0a
	cp	a, -4 (ix)
	ld	a, #0x00
	sbc	a, -3 (ix)
	jp	PO, 01009$
	xor	a, #0x80
01009$:
	jp	M, 00182$
;src\CFG8266.c:567: ucPageCheck = ucAPs;
	ld	a, -16 (ix)
	ld	-5 (ix), a
	jr	00443$
00182$:
;src\CFG8266.c:569: ucPageCheck = ucIndex + scanPageLimit;
	ld	a, -1 (ix)
	ld	-3 (ix), a
	add	a, #0x0a
	ld	-5 (ix), a
00443$:
00382$:
;src\CFG8266.c:571: for (;ucIndex<ucPageCheck;ucIndex++)
	ld	a, -1 (ix)
	sub	a, -5 (ix)
	jr	NC,00187$
;src\CFG8266.c:573: printf("%u - %s",(ucIndex%scanPageLimit),stAP[ucIndex].APName);
	ld	c, -1 (ix)
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ex	de, hl
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	add	hl, de
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	c, -1 (ix)
	ld	b, #0x00
	push	de
	ld	hl, #0x000a
	push	hl
	push	bc
	call	__modsint
	pop	af
	pop	af
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	push	bc
	push	hl
	ld	hl, #___str_42
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
;src\CFG8266.c:574: if (stAP[ucIndex].isEncrypted)
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	add	hl, de
	ld	de, #0x0021
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	Z,00185$
;src\CFG8266.c:575: printf(" (PWD)\r\n");
	ld	hl, #___str_44
	push	hl
	call	_puts
	pop	af
	jr	00383$
00185$:
;src\CFG8266.c:577: printf(" (OPEN)\r\n");
	ld	hl, #___str_46
	push	hl
	call	_puts
	pop	af
00383$:
;src\CFG8266.c:571: for (;ucIndex<ucPageCheck;ucIndex++)
	inc	-1 (ix)
	jr	00382$
00187$:
;src\CFG8266.c:580: if (ucAPs-ucIndex) // still APs left to list?
	ld	c, -1 (ix)
	ld	b, #0x00
	ld	a, -7 (ix)
	sub	a, c
	ld	-4 (ix), a
	ld	a, -6 (ix)
	sbc	a, b
	ld	-3 (ix), a
	or	a, -4 (ix)
	jr	Z,00189$
;src\CFG8266.c:581: printf("\r\nWhich one to connect? (ESC exit/SPACE BAR next page)");
	ld	hl, #___str_47
	push	hl
	call	_printf
	pop	af
	jr	00204$
00189$:
;src\CFG8266.c:583: printf("\r\nWhich one to connect? (ESC exit)");
	ld	hl, #___str_48
	push	hl
	call	_printf
	pop	af
;src\CFG8266.c:585: do
00204$:
;src\CFG8266.c:587: tx_data = Inkey ();
	call	_Inkey
	ld	c, l
;src\CFG8266.c:589: if (tx_data==0x1b)
;src\CFG8266.c:592: if ((tx_data==' ')&&(ucAPs-ucIndex))
	ld	a,c
	cp	a,#0x1b
	jr	Z,00206$
	sub	a, #0x20
	jr	NZ,00194$
	ld	a, -3 (ix)
	or	a, -4 (ix)
	jr	NZ,00206$
;src\CFG8266.c:593: break;
00194$:
;src\CFG8266.c:595: if ((tx_data>='0')&&(tx_data<='9'))
	ld	a, c
	sub	a, #0x30
	jr	C,00200$
	ld	a, #0x39
	sub	a, c
	jr	C,00200$
;src\CFG8266.c:597: if (((tx_data-'0')<scanPageLimit)&&(((scanPageLimit*ucScanPage)+(tx_data-'0'))<ucAPs))
	ld	b, c
	ld	d, #0x00
	ld	a, b
	add	a, #0xd0
	ld	e, a
	ld	a, d
	adc	a, #0xff
	ld	d, a
	ld	a, e
	sub	a, #0x0a
	ld	a, d
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC,00200$
	ld	l, -2 (ix)
	ld	h, #0x00
	push	de
	ld	e, l
	ld	d, h
	add	hl, hl
	add	hl, hl
	add	hl, de
	add	hl, hl
	pop	de
	add	hl, de
	ex	de, hl
	ld	a, e
	sub	a, -7 (ix)
	ld	a, d
	sbc	a, -6 (ix)
	jp	PO, 01013$
	xor	a, #0x80
01013$:
	jp	M, 00206$
;src\CFG8266.c:598: break;
00200$:
;src\CFG8266.c:600: if (tx_data)
	ld	a, c
	or	a, a
	jr	Z,00204$
;src\CFG8266.c:601: Beep();
	call	_Beep
;src\CFG8266.c:603: while (1);
	jr	00204$
00206$:
;src\CFG8266.c:605: if ((tx_data!=0x1b)&&(tx_data!=' ')) // AP Choosen?
	ld	a,c
	cp	a,#0x1b
	jp	Z,00261$
	sub	a, #0x20
	jp	Z,00261$
;src\CFG8266.c:608: printf(" %c\r\n\n",tx_data); // Print accepted char
	ld	e, c
	ld	d, #0x00
	push	bc
	push	de
	ld	hl, #___str_49
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	bc
;src\CFG8266.c:609: ucIndex = (scanPageLimit*ucScanPage) + (tx_data-'0');
	ld	a, -17 (ix)
	ld	e, a
	add	a, a
	add	a, a
	add	a, e
	add	a, a
	ld	e, a
	ld	a, c
	add	a, #0xd0
	add	a, e
;src\CFG8266.c:610: if (stAP[ucIndex].isEncrypted)
	ld	c, a
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	a, -15 (ix)
	add	a, -4 (ix)
	ld	c, a
	ld	a, -14 (ix)
	adc	a, -3 (ix)
	ld	b, a
	ld	hl, #0x0021
	add	hl, bc
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	a, (hl)
	or	a, a
	jr	Z,00208$
;src\CFG8266.c:613: printf("Password? ");
	push	bc
	ld	hl, #___str_50
	push	hl
	call	_printf
	pop	af
	pop	bc
;src\CFG8266.c:614: InputString(ucPWD,64);
	ld	hl, #18
	add	hl, sp
	push	bc
	ld	de, #0x0040
	push	de
	push	hl
	call	_InputString
	pop	af
	ld	hl, #___str_38
	ex	(sp),hl
	call	_puts
	pop	af
	pop	bc
00208$:
;src\CFG8266.c:618: printf("Connecting to: %s \r\n",stAP[ucIndex].APName);
	ld	e, c
	ld	d, b
	push	bc
	push	de
	ld	hl, #___str_52
	push	hl
	call	_printf
	pop	af
	pop	af
	call	_strlen
	pop	af
	inc	hl
	ld	c,l
	ld	b,h
;src\CFG8266.c:621: if (stAP[ucIndex].isEncrypted)
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	a, (hl)
	or	a, a
	jr	Z,00210$
;src\CFG8266.c:622: uiCMDLen += strlen(ucPWD);
	ld	hl, #18
	add	hl, sp
	push	bc
	push	hl
	call	_strlen
	pop	af
	pop	bc
	add	hl, bc
	ld	c, l
	ld	b, h
00210$:
;src\CFG8266.c:623: TxByte('A'); //Request connect AP
	push	bc
	ld	a, #0x41
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:624: TxByte((unsigned char)((uiCMDLen&0xff00)>>8));
	ld	a, b
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:625: TxByte((unsigned char)(uiCMDLen&0xff));
	ld	a, c
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:627: do
	ld	a, -4 (ix)
	add	a, -15 (ix)
	ld	-2 (ix), a
	ld	a, -3 (ix)
	adc	a, -14 (ix)
	ld	-1 (ix), a
	ld	e, #0x00
00212$:
;src\CFG8266.c:629: tx_data = stAP[ucIndex].APName[rx_data];
	ld	a, -2 (ix)
	add	a, e
	ld	d, a
	ld	a, -1 (ix)
	adc	a, #0x00
	ld	l, d
	ld	h, a
	ld	d, (hl)
;src\CFG8266.c:630: TxByte(tx_data);
	push	bc
	push	de
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:631: --uiCMDLen;
	dec	bc
;src\CFG8266.c:632: ++rx_data;
	inc	e
;src\CFG8266.c:634: while((uiCMDLen)&&(tx_data!=0));
	ld	a, b
	or	a, c
	jr	Z,00214$
	ld	a, d
	or	a, a
	jr	NZ,00212$
00214$:
;src\CFG8266.c:635: if(uiCMDLen)
	ld	a, b
	or	a, c
	jr	Z,00219$
;src\CFG8266.c:638: do
	ld	hl, #18
	add	hl, sp
	ld	-3 (ix), l
	ld	-2 (ix), h
	xor	a, a
	ld	-1 (ix), a
00215$:
;src\CFG8266.c:640: tx_data = ucPWD[rx_data];
	ld	a, -3 (ix)
	add	a, -1 (ix)
	ld	e, a
	ld	a, -2 (ix)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
;src\CFG8266.c:641: TxByte(tx_data);
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:642: --uiCMDLen;
	dec	bc
;src\CFG8266.c:643: ++rx_data;
	inc	-1 (ix)
;src\CFG8266.c:645: while(uiCMDLen);
	ld	a, b
	or	a, c
	jr	NZ,00215$
00219$:
;src\CFG8266.c:649: bResponse = WaitForRXData(apconfigurationResponse,2,600,true,false,NULL,0); //Wait up to 10s
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x0258
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	hl, #_apconfigurationResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	a, l
;src\CFG8266.c:650: if (bResponse)
	or	a, a
	jr	Z,00241$
;src\CFG8266.c:651: printf("Success, AP configured to be used.\r\n");
	ld	hl, #___str_54
	push	hl
	call	_puts
	pop	af
	jp	00375$
00241$:
;src\CFG8266.c:654: if ((ucVerMajor>=1)&&(ucVerMinor>=2)) // new firmware allow get current ap and connection status
	bit	0, -12 (ix)
	jp	NZ, 00237$
	bit	0, -13 (ix)
	jp	NZ, 00237$
;src\CFG8266.c:656: for (i=90;i>0;--i)
	ld	bc, #0x005a
00384$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFG8266.c:656: for (i=90;i>0;--i)
	dec	bc
	ld	a, b
	or	a, c
	jr	NZ,00384$
;src\CFG8266.c:658: TxByte('g'); //Request current AP status
	ld	a, #0x67
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:659: bResponse = WaitForRXData(apstsResponse,3,120,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x78
	push	hl
	ld	l, #0x03
	push	hl
	ld	hl, #_apstsResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	a, l
;src\CFG8266.c:660: if (bResponse)
	or	a, a
	jr	Z,00234$
;src\CFG8266.c:662: while(!UartRXData());
00221$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00221$
;src\CFG8266.c:663: ucAPstsRspSize=GetUARTData();
	in	a, (_myPort6)
	ld	c, a
;src\CFG8266.c:667: while(!UartRXData());
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00224$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00224$
;src\CFG8266.c:668: chAPStsInfo[i]=GetUARTData();
	ld	a, -11 (ix)
	add	a, -2 (ix)
	ld	e, a
	ld	a, -10 (ix)
	adc	a, -1 (ix)
	ld	d, a
	in	a, (_myPort6)
	ld	(de), a
;src\CFG8266.c:669: ++i;
	inc	-2 (ix)
	jr	NZ,01016$
	inc	-1 (ix)
01016$:
;src\CFG8266.c:671: while(i<ucAPstsRspSize);
	ld	b, c
	ld	e, #0x00
	ld	a, -2 (ix)
	sub	a, b
	ld	a, -1 (ix)
	sbc	a, e
	jr	C,00224$
;src\CFG8266.c:673: if (chAPStsInfo[0]==2)
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	ld	a, (hl)
	sub	a, #0x02
	jr	NZ,00231$
;src\CFG8266.c:674: printf("Error, wrong password!\r\n");
	ld	hl, #___str_56
	push	hl
	call	_puts
	pop	af
	jp	00375$
00231$:
;src\CFG8266.c:676: printf("Error, if protected network, check password.\r\n");
	ld	hl, #___str_58
	push	hl
	call	_puts
	pop	af
	jp	00375$
00234$:
;src\CFG8266.c:679: printf("Error, if protected network, check password.\r\n");
	ld	hl, #___str_58
	push	hl
	call	_puts
	pop	af
	jp	00375$
00237$:
;src\CFG8266.c:682: printf("Error, if protected network, check password.\r\n");
	ld	hl, #___str_58
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:685: break;
	jp	00375$
00261$:
;src\CFG8266.c:687: else if (tx_data==0x1b)
	ld	a, c
	sub	a, #0x1b
	jr	NZ,00258$
;src\CFG8266.c:689: printf("\r\nUser canceled by ESC key...\r\n");
	ld	hl, #___str_62
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:690: break;
	jp	00375$
00258$:
;src\CFG8266.c:694: if ((ucVerMajor>=1)&&(ucVerMinor>=2)) // new firmware allow get current ap and connection status
	bit	0, -12 (ix)
	jr	NZ,00255$
	bit	0, -13 (ix)
	jr	NZ,00255$
;src\CFG8266.c:696: TxByte('g'); //Request current AP status
	ld	a, #0x67
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:697: bResponse = WaitForRXData(apstsResponse,3,30,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x1e
	push	hl
	ld	l, #0x03
	push	hl
	ld	hl, #_apstsResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	a, l
;src\CFG8266.c:698: if (bResponse)
	or	a, a
	jr	Z,00255$
;src\CFG8266.c:700: while(!UartRXData());
00243$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00243$
;src\CFG8266.c:701: ucAPstsRspSize=GetUARTData();
	in	a, (_myPort6)
	ld	-1 (ix), a
;src\CFG8266.c:705: while(!UartRXData());
	ld	de, #0x0000
00246$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00246$
;src\CFG8266.c:706: chAPStsInfo[i]=GetUARTData();
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	add	hl, de
	in	a, (_myPort6)
	ld	(hl), a
;src\CFG8266.c:707: ++i;
	inc	de
;src\CFG8266.c:709: while(i<ucAPstsRspSize);
	ld	c, -1 (ix)
	ld	b, #0x00
	ld	a, e
	sub	a, c
	ld	a, d
	sbc	a, b
	jr	C,00246$
00255$:
;src\CFG8266.c:712: ++ucScanPage;
	inc	-2 (ix)
	ld	a, -2 (ix)
	ld	-17 (ix), a
;src\CFG8266.c:715: while(1);
	jp	00264$
00268$:
;src\CFG8266.c:718: printf("\r\nScan results: no answer...\r\n");
	ld	hl, #___str_64
	push	hl
	call	_puts
	pop	af
	jp	00375$
00294$:
;src\CFG8266.c:722: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	Z,00291$
;src\CFG8266.c:723: printf ("\rScan request: no answer...\r\n");
	ld	hl, #___str_66
	push	hl
	call	_puts
	pop	af
	jp	00375$
00291$:
;src\CFG8266.c:724: else if (((ucNagleOff)||(ucNagleOn))&&(bResponse))
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00289$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00286$
00289$:
	ld	a, -5 (ix)
	or	a, a
	jr	Z,00286$
;src\CFG8266.c:726: printf("\rNagle set as requested...\r\n");
	ld	hl, #___str_68
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:727: return 0;
	ld	hl, #0x0000
	jp	00388$
00286$:
;src\CFG8266.c:729: else if ((ucNagleOff)||(ucNagleOn))
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00281$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00282$
00281$:
;src\CFG8266.c:731: printf("\rNagle not set as requested, error!\r\n");
	ld	hl, #___str_70
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:732: return 0;
	ld	hl, #0x0000
	jp	00388$
00282$:
;src\CFG8266.c:734: else if (ucRadioOff)
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	Z,00279$
;src\CFG8266.c:736: if (bResponse)
	ld	a, -5 (ix)
	or	a, a
	jr	Z,00271$
;src\CFG8266.c:737: printf("\rRequested to turn off Wi-Fi Radio...\r\n");
	ld	hl, #___str_72
	push	hl
	call	_puts
	pop	af
	jr	00272$
00271$:
;src\CFG8266.c:739: printf("\rRequest to turnoff Wi-Fi Radio error!\r\n");
	ld	hl, #___str_74
	push	hl
	call	_puts
	pop	af
00272$:
;src\CFG8266.c:740: return 0;
	ld	hl, #0x0000
	jp	00388$
00279$:
;src\CFG8266.c:742: else if (ucSetTimeout)
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jp	Z, 00375$
;src\CFG8266.c:744: if (bResponse)
	ld	a, -5 (ix)
	or	a, a
	jr	Z,00274$
;src\CFG8266.c:745: printf("\rWi-Fi radio on Time-out set successfully...\r\n");
	ld	hl, #___str_76
	push	hl
	call	_puts
	pop	af
	jr	00275$
00274$:
;src\CFG8266.c:747: printf("\rError setting Wi-Fi radio on Time-out!\r\n");
	ld	hl, #___str_78
	push	hl
	call	_puts
	pop	af
00275$:
;src\CFG8266.c:748: return 0;
	ld	hl, #0x0000
	jp	00388$
00364$:
;src\CFG8266.c:752: else if (ucLocalUpdate)
	ld	a,(#_ucLocalUpdate + 0)
	or	a, a
	jp	Z, 00361$
;src\CFG8266.c:755: iFile = Open (ucFile,O_RDONLY);
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	ld	hl, #0x0000
	push	hl
	push	bc
	call	_Open
	pop	af
	pop	af
	ld	-2 (ix), l
	ld	-1 (ix), h
;src\CFG8266.c:757: if (iFile!=-1)
	ld	a, -2 (ix)
	and	a, -1 (ix)
	inc	a
	jp	Z,00334$
;src\CFG8266.c:764: regs.Words.HL = 0; //set pointer as 0
	ld	hl, #3483
	add	hl, sp
	ex	de, hl
	ld	hl, #0x0006
	add	hl, de
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;src\CFG8266.c:765: regs.Words.DE = 0; //so it will return the position
	inc	de
	inc	de
	inc	de
	inc	de
	xor	a, a
	ld	(de), a
	inc	de
	ld	(de), a
;src\CFG8266.c:766: regs.Bytes.A = 2; //relative to the end of file, i.e.:file size
	ld	hl, #3483
	add	hl, sp
	ex	de, hl
	ld	l, e
	ld	h, d
	inc	hl
	ld	(hl), #0x02
;src\CFG8266.c:767: regs.Bytes.B = (unsigned char)(iFile&0xff);
	inc	de
	inc	de
	inc	de
	ld	a, d
	ld	c, -2 (ix)
	ld	l, e
	ld	h, a
	ld	(hl), c
;src\CFG8266.c:768: DosCall(0x4A, &regs, REGS_ALL, REGS_ALL); // MOVE FILE HANDLER
	ld	hl, #3483
	add	hl, sp
	ld	-6 (ix), l
	ld	-5 (ix), h
	ld	c, l
	ld	b, h
	ld	de, #0x0303
	push	de
	push	bc
	ld	a, #0x4a
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
;src\CFG8266.c:769: if (regs.Bytes.A == 0) //moved, now get the file handler position, i.e.: size
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	inc	hl
	ld	a, (hl)
	ld	-7 (ix), a
	or	a, a
	jp	NZ, 00298$
;src\CFG8266.c:770: SentFileSize = (unsigned long)(regs.Words.HL)&0xffff | ((unsigned long)(regs.Words.DE)<<16)&0xffff0000;
	ld	a, -6 (ix)
	ld	-8 (ix), a
	ld	a, -5 (ix)
	ld	-7 (ix), a
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	de, #0x0006
	add	hl, de
	ld	a, (hl)
	ld	-8 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-7 (ix), a
	ld	a, -8 (ix)
	ld	-15 (ix), a
	ld	a, -7 (ix)
	ld	-14 (ix), a
	rla
	sbc	a, a
	ld	-13 (ix), a
	ld	-12 (ix), a
	ld	a, -15 (ix)
	ld	iy, #14
	add	iy, sp
	ld	0 (iy), a
	ld	a, -14 (ix)
	ld	1 (iy), a
	ld	2 (iy), #0x00
	ld	3 (iy), #0x00
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	de, #0x0004
	add	hl, de
	ld	a, (hl)
	ld	-6 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-5 (ix), a
	ld	a, -6 (ix)
	ld	-8 (ix), a
	ld	a, -5 (ix)
	ld	-7 (ix), a
	rla
	sbc	a, a
	ld	-6 (ix), a
	ld	-5 (ix), a
	ld	b, #0x10
01022$:
	sla	-8 (ix)
	rl	-7 (ix)
	rl	-6 (ix)
	rl	-5 (ix)
	djnz	01022$
	ld	-15 (ix), #0x00
	ld	-14 (ix), #0x00
	ld	a, -6 (ix)
	ld	-13 (ix), a
	ld	a, -5 (ix)
	ld	-12 (ix), a
	ld	a, 0 (iy)
	or	a, -15 (ix)
	ld	-8 (ix), a
	ld	a, 1 (iy)
	or	a, -14 (ix)
	ld	-7 (ix), a
	ld	a, 2 (iy)
	or	a, -13 (ix)
	ld	-6 (ix), a
	ld	a, 3 (iy)
	or	a, -12 (ix)
	ld	-5 (ix), a
	jr	00299$
00298$:
;src\CFG8266.c:772: SentFileSize = 0;
	xor	a, a
	ld	-8 (ix), a
	ld	-7 (ix), a
	ld	-6 (ix), a
	ld	-5 (ix), a
00299$:
;src\CFG8266.c:774: ultostr(SentFileSize,chFileSize,10);
	ld	hl, #3495
	add	hl, sp
	ld	c, l
	ld	b, h
	push	hl
	ld	de, #0x000a
	push	de
	push	bc
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	call	_ultostr
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	push	bc
	call	_Close
	pop	af
	pop	hl
;src\CFG8266.c:776: printf ("File: %s Size: %s \r\n",ucFile,chFileSize);
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	ld	de, #___str_79+0
	push	hl
	push	bc
	push	de
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:777: if (SentFileSize)
	ld	a, -5 (ix)
	or	a, -6 (ix)
	or	a, -7 (ix)
	or	a, -8 (ix)
	jp	Z, 00331$
;src\CFG8266.c:779: iFile = Open (ucFile,O_RDONLY);
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	ld	hl, #0x0000
	push	hl
	push	bc
	call	_Open
	pop	af
	pop	af
	ld	iy, #16
	add	iy, sp
	ld	0 (iy), l
	ld	1 (iy), h
;src\CFG8266.c:780: if (iFile!=-1)
	ld	a, 0 (iy)
	inc	a
	jr	NZ,01024$
	ld	a, 1 (iy)
	inc	a
	jp	Z,00328$
01024$:
;src\CFG8266.c:782: FileRead = MyRead(iFile, ucServer,256); //try to read 256 bytes of data
	ld	c, -10 (ix)
	ld	b, -9 (ix)
	ld	hl, #0x0100
	push	hl
	push	bc
	ld	l, 0 (iy)
	ld	h, 1 (iy)
	push	hl
	call	_MyRead
	pop	af
	pop	af
	pop	af
	ld	-16 (ix), l
	ld	-15 (ix), h
;src\CFG8266.c:783: if (FileRead == 256)
	ld	a, -16 (ix)
	or	a, a
	jp	NZ,00325$
	ld	a, -15 (ix)
	dec	a
	jp	NZ,00325$
;src\CFG8266.c:786: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00301$
;src\CFG8266.c:787: TxByte('Z'); //Request start of RS232 update
	ld	a, #0x5a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00302$
00301$:
;src\CFG8266.c:789: TxByte('Y'); //Request start of RS232 cert update
	ld	a, #0x59
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00302$:
;src\CFG8266.c:790: TxByte(0);
	xor	a, a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:791: TxByte(12);
	ld	a, #0x0c
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:792: TxByte((unsigned char)(SentFileSize&0xff));
	ld	a, -8 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:793: TxByte((unsigned char)((SentFileSize&0xff00)>>8));
	ld	b, -7 (ix)
	ld	c, #0x00
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:794: TxByte((unsigned char)((SentFileSize&0xff0000)>>16));
	ld	a, -6 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:795: TxByte((unsigned char)((SentFileSize&0xff000000)>>24));
	ld	a, -5 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:796: TxByte((unsigned char)((SentFileSize&0xff00000000)>>32));
	ld	a, -8 (ix)
	ld	iy, #0
	add	iy, sp
	ld	0 (iy), a
	ld	a, -7 (ix)
	ld	1 (iy), a
	ld	a, -6 (ix)
	ld	2 (iy), a
	ld	a, -5 (ix)
	ld	3 (iy), a
	xor	a, a
	ld	4 (iy), a
	ld	5 (iy), a
	ld	6 (iy), a
	ld	7 (iy), a
	ld	iy, #8
	add	iy, sp
	ld	0 (iy), #0x00
	ld	1 (iy), #0x00
	ld	2 (iy), #0x00
	ld	3 (iy), #0x00
	ld	hl, #0+4
	add	hl, sp
	ld	a, (hl)
	ld	iy, #8
	add	iy, sp
	ld	4 (iy), a
	ld	5 (iy), #0x00
	ld	6 (iy), #0x00
	ld	7 (iy), #0x00
	ld	b, #0x20
01031$:
	sra	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	01031$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:797: TxByte((unsigned char)((SentFileSize&0xff0000000000)>>40));
	ld	iy, #8
	add	iy, sp
	ld	0 (iy), #0x00
	ld	1 (iy), #0x00
	ld	2 (iy), #0x00
	ld	3 (iy), #0x00
	ld	4 (iy), #0x00
	ld	hl, #0+5
	add	hl, sp
	ld	a, (hl)
	ld	iy, #8
	add	iy, sp
	ld	5 (iy), a
	ld	6 (iy), #0x00
	ld	7 (iy), #0x00
	ld	b, #0x28
01033$:
	sra	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	01033$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:798: TxByte((unsigned char)((SentFileSize&0xff000000000000)>>48));
	ld	iy, #8
	add	iy, sp
	ld	0 (iy), #0x00
	ld	1 (iy), #0x00
	ld	2 (iy), #0x00
	ld	3 (iy), #0x00
	ld	4 (iy), #0x00
	ld	5 (iy), #0x00
	ld	hl, #0+6
	add	hl, sp
	ld	a, (hl)
	ld	iy, #8
	add	iy, sp
	ld	6 (iy), a
	ld	7 (iy), #0x00
	ld	b, #0x30
01035$:
	sra	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	01035$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:799: TxByte((unsigned char)((SentFileSize&0xff00000000000000)>>56));
	ld	a, -8 (ix)
	ld	iy, #8
	add	iy, sp
	ld	0 (iy), a
	ld	a, -7 (ix)
	ld	1 (iy), a
	ld	a, -6 (ix)
	ld	2 (iy), a
	ld	a, -5 (ix)
	ld	3 (iy), a
	xor	a, a
	ld	4 (iy), a
	ld	5 (iy), a
	ld	6 (iy), a
	ld	7 (iy), a
	ld	0 (iy), #0x00
	ld	1 (iy), #0x00
	ld	2 (iy), #0x00
	ld	3 (iy), #0x00
	ld	4 (iy), #0x00
	ld	5 (iy), #0x00
	ld	6 (iy), #0x00
	ld	a, 7 (iy)
	ld	7 (iy), a
	ld	b, #0x38
01037$:
	srl	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	01037$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:800: TxByte(ucServer[0]);
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	a, (hl)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:801: TxByte(ucServer[1]);
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	inc	hl
	ld	a, (hl)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:802: TxByte(ucServer[2]);
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	inc	hl
	inc	hl
	ld	a, (hl)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:803: TxByte(ucServer[3]);
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	a, (hl)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:805: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00304$
;src\CFG8266.c:806: bResponse = WaitForRXData(responseRSFWUpdate,2,60,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x3c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_responseRSFWUpdate
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	-14 (ix), l
	jr	00305$
00304$:
;src\CFG8266.c:808: bResponse = WaitForRXData(responseRSCERTUpdate,2,60,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	l, #0x3c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_responseRSCERTUpdate
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	-14 (ix), l
00305$:
;src\CFG8266.c:810: if (!bResponse)
	ld	a, -14 (ix)
	or	a, a
	jr	NZ,00322$
;src\CFG8266.c:811: printf("Error requesting to start firmware update.\r\n");
	ld	hl, #___str_81
	push	hl
	call	_puts
	pop	af
	jp	00326$
00322$:
;src\CFG8266.c:814: uiAnimationTimeOut = TickCount + 9;
	ld	iy, #_TickCount
	ld	a, 0 (iy)
	add	a, #0x09
	ld	-4 (ix), a
	ld	a, 1 (iy)
	adc	a, #0x00
	ld	-3 (ix), a
;src\CFG8266.c:815: do
	ld	a, -10 (ix)
	ld	-13 (ix), a
	ld	a, -9 (ix)
	ld	-12 (ix), a
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00316$:
;src\CFG8266.c:817: --uiAnimationTimeOut;
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	dec	hl
	ld	-4 (ix), l
	ld	-3 (ix), h
;src\CFG8266.c:818: if (TickCount>=uiAnimationTimeOut)
	ld	iy, #_TickCount
	ld	a, 0 (iy)
	sub	a, -4 (ix)
	ld	a, 1 (iy)
	sbc	a, -3 (ix)
	jr	C,00307$
;src\CFG8266.c:820: uiAnimationTimeOut = 9;
	ld	-4 (ix), #0x09
	xor	a, a
	ld	-3 (ix), a
;src\CFG8266.c:822: printf("%s",advance[i%5]); // next animation step
	ld	hl, #0x0005
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	call	__moduint
	pop	af
	pop	af
	ld	c, l
	ld	b, h
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ld	de, #_advance
	add	hl, de
	push	hl
	ld	hl, #___str_82
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:823: ++i;
	inc	-2 (ix)
	jr	NZ,01039$
	inc	-1 (ix)
01039$:
00307$:
;src\CFG8266.c:825: if (!ucFirstBlock)
	ld	a, -11 (ix)
	or	a, a
	jr	NZ,00311$
;src\CFG8266.c:827: FileRead = MyRead(iFile, ucServer,256); //try to read 256 bytes of data
	ld	c, -13 (ix)
	ld	b, -12 (ix)
	ld	hl, #0x0100
	push	hl
	push	bc
	ld	hl, #20
	add	hl, sp
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	push	bc
	call	_MyRead
	pop	af
	pop	af
	pop	af
	ld	-16 (ix), l
;src\CFG8266.c:828: if (FileRead ==0)
	ld	-15 (ix), h
	ld	a, h
	or	a, -16 (ix)
	jr	NZ,00312$
;src\CFG8266.c:830: printf("\rError reading file...\r\n");
	ld	hl, #___str_84
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:831: break;
	jp	00318$
00311$:
;src\CFG8266.c:835: ucFirstBlock = 0;
	xor	a, a
	ld	-11 (ix), a
00312$:
;src\CFG8266.c:837: TxByte('z'); //Write block
	ld	a, #0x7a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:838: TxByte((unsigned char)((FileRead&0xff00)>>8));
	ld	b, -15 (ix)
	ld	c, #0x00
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:839: TxByte((unsigned char)(FileRead&0xff));
	ld	a, -16 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:840: for (ii=0;ii<256;ii++)
	ld	bc, #0x0000
00386$:
;src\CFG8266.c:841: TxByte(ucServer[ii]);
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	add	hl, bc
	ld	a, (hl)
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:840: for (ii=0;ii<256;ii++)
	inc	bc
	ld	a, b
	sub	a, #0x01
	jr	C,00386$
;src\CFG8266.c:843: bResponse = WaitForRXData(responseWRBlock,2,600,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x0258
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	hl, #_responseWRBlock
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
;src\CFG8266.c:845: if (!bResponse)
	ld	-14 (ix), l
	ld	a, l
	or	a, a
	jr	NZ,00315$
;src\CFG8266.c:847: printf("\rError requesting to write firmware block.\r\n");
	ld	hl, #___str_86
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:848: break;
	jr	00318$
00315$:
;src\CFG8266.c:850: SentFileSize = SentFileSize - FileRead;
	ld	c, -16 (ix)
	ld	b, -15 (ix)
	ld	de, #0x0000
	ld	a, -8 (ix)
	sub	a, c
	ld	-8 (ix), a
	ld	a, -7 (ix)
	sbc	a, b
	ld	-7 (ix), a
	ld	a, -6 (ix)
	sbc	a, e
	ld	-6 (ix), a
	ld	a, -5 (ix)
	sbc	a, d
;src\CFG8266.c:852: while(SentFileSize);
	ld	-5 (ix), a
	or	a, -6 (ix)
	or	a, -7 (ix)
	or	a, -8 (ix)
	jp	NZ, 00316$
00318$:
;src\CFG8266.c:853: printf("%s",aDone);
	ld	hl, #_aDone
	push	hl
	ld	hl, #___str_82
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:856: if (bResponse)
	ld	a, -14 (ix)
	or	a, a
	jr	Z,00326$
;src\CFG8266.c:857: FinishUpdate(false);
	xor	a, a
	push	af
	inc	sp
	call	_FinishUpdate
	inc	sp
	jr	00326$
00325$:
;src\CFG8266.c:861: Print("\rError reading firmware file!\r\n");
	ld	hl, #___str_87
	push	hl
	call	_Print
	pop	af
00326$:
;src\CFG8266.c:862: Close(iFile);
	ld	hl, #16
	add	hl, sp
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	push	bc
	call	_Close
	pop	af
	jp	00375$
00328$:
;src\CFG8266.c:866: printf("Error, couldn't open %s ...\r\n",ucFile);
	ld	a, -4 (ix)
	ld	-2 (ix), a
	ld	a, -3 (ix)
	ld	-1 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	hl, #___str_88
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:867: return 0;
	ld	hl, #0x0000
	jp	00388$
00331$:
;src\CFG8266.c:872: printf("Error, %s is 0 bytes long...\r\n",ucFile);
	ld	a, -4 (ix)
	ld	-2 (ix), a
	ld	a, -3 (ix)
	ld	-1 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	hl, #___str_89
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:873: return 0;
	ld	hl, #0x0000
	jp	00388$
00334$:
;src\CFG8266.c:878: printf("Error, couldn't open %s ...\r\n",ucFile);
	ld	a, -4 (ix)
	ld	-2 (ix), a
	ld	a, -3 (ix)
	ld	-1 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	hl, #___str_88
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:879: return 0;
	ld	hl, #0x0000
	jp	00388$
00361$:
;src\CFG8266.c:884: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00337$
;src\CFG8266.c:885: printf ("Ok, updating FW using server: %s port: %u\r\nFile path: %s\nPlease Wait, it can take up to a few minutes!\r\n",ucServer,uiPort,ucFile);
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	c, -10 (ix)
	ld	b, -9 (ix)
	push	de
	ld	hl, (_uiPort)
	push	hl
	push	bc
	ld	hl, #___str_90
	push	hl
	call	_printf
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
	jr	00338$
00337$:
;src\CFG8266.c:887: printf ("Ok, updating certificates using server: %s port: %u\r\nFile path: %s\nPlease Wait, it can take up to a few minutes!\r\n",ucServer,uiPort,ucFile);
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	c, -10 (ix)
	ld	b, -9 (ix)
	push	de
	ld	hl, (_uiPort)
	push	hl
	push	bc
	ld	hl, #___str_91
	push	hl
	call	_printf
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
00338$:
;src\CFG8266.c:888: uiCMDLen = strlen(ucServer) + 3; //3 = 0 terminator + 2 bytes port
	ld	c, -10 (ix)
	ld	b, -9 (ix)
	push	bc
	call	_strlen
	pop	af
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	a, -2 (ix)
	add	a, #0x03
	ld	-8 (ix), a
	ld	a, -1 (ix)
	adc	a, #0x00
	ld	-7 (ix), a
;src\CFG8266.c:889: uiCMDLen += strlen(ucFile);
	ld	a, -4 (ix)
	ld	-2 (ix), a
	ld	a, -3 (ix)
	ld	-1 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	call	_strlen
	pop	af
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	a, -2 (ix)
	add	a, -8 (ix)
	ld	-6 (ix), a
	ld	a, -1 (ix)
	adc	a, -7 (ix)
	ld	-5 (ix), a
;src\CFG8266.c:890: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00340$
;src\CFG8266.c:891: TxByte('U'); //Request Update Main Firmware remotely
	ld	a, #0x55
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00341$
00340$:
;src\CFG8266.c:893: TxByte('u'); //Request Update spiffs remotely
	ld	a, #0x75
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00341$:
;src\CFG8266.c:894: TxByte((unsigned char)((uiCMDLen&0xff00)>>8));
	ld	-2 (ix), #0x00
	ld	a, -5 (ix)
	ld	-1 (ix), a
	ld	-2 (ix), a
	ld	-1 (ix), #0x00
	ld	a, -2 (ix)
	ld	-1 (ix), a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:895: TxByte((unsigned char)(uiCMDLen&0xff));
	ld	a, -6 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:896: TxByte((unsigned char)(uiPort&0xff));
	ld	a,(#_uiPort + 0)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:897: TxByte((unsigned char)((uiPort&0xff00)>>8));
	ld	-2 (ix), #0x00
	ld	a,(#_uiPort + 1)
	ld	-1 (ix), a
	ld	-2 (ix), a
	ld	-1 (ix), #0x00
	ld	a, -2 (ix)
	ld	-1 (ix), a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:899: do
	ld	c, -6 (ix)
	ld	b, -5 (ix)
	xor	a, a
	ld	-1 (ix), a
00343$:
;src\CFG8266.c:901: tx_data = ucServer[rx_data];
	ld	a, -10 (ix)
	add	a, -1 (ix)
	ld	e, a
	ld	a, -9 (ix)
	adc	a, #0x00
	ld	l, e
	ld	h, a
	ld	d, (hl)
;src\CFG8266.c:902: TxByte(tx_data);
	push	bc
	push	de
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:903: --uiCMDLen;
	dec	bc
;src\CFG8266.c:904: ++rx_data;
	inc	-1 (ix)
;src\CFG8266.c:906: while((uiCMDLen)&&(tx_data!=0));
	ld	a, b
	or	a, c
	jr	Z,00345$
	ld	a, d
	or	a, a
	jr	NZ,00343$
00345$:
;src\CFG8266.c:908: do
	ld	-6 (ix), c
	ld	-5 (ix), b
	xor	a, a
	ld	-1 (ix), a
00348$:
;src\CFG8266.c:910: tx_data = ucFile[rx_data];
	ld	a, -4 (ix)
	add	a, -1 (ix)
	ld	-8 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-7 (ix), a
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	a, (hl)
;src\CFG8266.c:911: if (tx_data==0)
	or	a, a
	jr	Z,00350$
;src\CFG8266.c:913: TxByte(tx_data);
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:914: --uiCMDLen;
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	dec	hl
	ld	-6 (ix), l
	ld	-5 (ix), h
;src\CFG8266.c:915: ++rx_data;
	inc	-1 (ix)
;src\CFG8266.c:917: while(uiCMDLen);
	ld	a, -5 (ix)
	or	a, -6 (ix)
	jr	NZ,00348$
00350$:
;src\CFG8266.c:919: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00352$
;src\CFG8266.c:920: bResponse = WaitForRXData(responseOTAFW,2,18000,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x4650
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	hl, #_responseOTAFW
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	c, l
	jr	00353$
00352$:
;src\CFG8266.c:922: bResponse = WaitForRXData(responseOTASPIFF,2,18000,true,false,NULL,0);
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x4650
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	hl, #_responseOTASPIFF
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	c, l
00353$:
;src\CFG8266.c:924: if (bResponse)
	ld	a, c
	or	a, a
	jr	Z,00358$
;src\CFG8266.c:926: if ((!ucIsFw))
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	NZ,00355$
;src\CFG8266.c:927: printf("\rSuccess updating certificates!\r\n");
	ld	hl, #___str_93
	push	hl
	call	_puts
	pop	af
	jr	00356$
00355$:
;src\CFG8266.c:929: printf("\rSuccess, firmware updated, wait a minute so it is fully flashed.\r\n");
	ld	hl, #___str_95
	push	hl
	call	_puts
	pop	af
00356$:
;src\CFG8266.c:930: FinishUpdate(true);
	ld	a, #0x01
	push	af
	inc	sp
	call	_FinishUpdate
	inc	sp
;src\CFG8266.c:931: return 0;
	ld	hl, #0x0000
	jr	00388$
00358$:
;src\CFG8266.c:934: printf("\rFailed to update from remote server...\r\n");
	ld	hl, #___str_97
	push	hl
	call	_puts
	pop	af
	jr	00375$
00371$:
;src\CFG8266.c:938: printf("ESP device not found...\r\n");
	ld	hl, #___str_99
	push	hl
	call	_puts
	pop	af
	jr	00375$
00374$:
;src\CFG8266.c:941: printf(strUsage);
	ld	hl, #_strUsage
	push	hl
	call	_printf
	pop	af
00375$:
;src\CFG8266.c:943: return 0;
	ld	hl, #0x0000
00388$:
;src\CFG8266.c:944: }
	ld	sp, ix
	pop	ix
	ret
___str_31:
	.ascii "> SM-X ESP8266 Wi-Fi Module Configuration v1.30 <"
	.db 0x0d
	.db 0x0a
	.ascii "(c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_32:
	.ascii "Baud Rate: %s"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_33:
	.ascii "FW Version: %c.%c"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_34:
	.db 0x0d
	.db 0x0a
	.ascii "Setting Wi-Fi idle timeout to %u..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_36:
	.db 0x0d
	.db 0x0a
	.ascii "Setting Wi-Fi to always on!"
	.db 0x0d
	.db 0x00
___str_38:
	.db 0x0d
	.db 0x00
___str_39:
	.ascii "%s%s"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.db 0x00
___str_41:
	.ascii "Choose AP:"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_42:
	.ascii "%u - %s"
	.db 0x00
___str_44:
	.ascii " (PWD)"
	.db 0x0d
	.db 0x00
___str_46:
	.ascii " (OPEN)"
	.db 0x0d
	.db 0x00
___str_47:
	.db 0x0d
	.db 0x0a
	.ascii "Which one to connect? (ESC exit/SPACE BAR next page)"
	.db 0x00
___str_48:
	.db 0x0d
	.db 0x0a
	.ascii "Which one to connect? (ESC exit)"
	.db 0x00
___str_49:
	.ascii " %c"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.db 0x00
___str_50:
	.ascii "Password? "
	.db 0x00
___str_52:
	.ascii "Connecting to: %s "
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_54:
	.ascii "Success, AP configured to be used."
	.db 0x0d
	.db 0x00
___str_56:
	.ascii "Error, wrong password!"
	.db 0x0d
	.db 0x00
___str_58:
	.ascii "Error, if protected network, check password."
	.db 0x0d
	.db 0x00
___str_62:
	.db 0x0d
	.db 0x0a
	.ascii "User canceled by ESC key..."
	.db 0x0d
	.db 0x00
___str_64:
	.db 0x0d
	.db 0x0a
	.ascii "Scan results: no answer..."
	.db 0x0d
	.db 0x00
___str_66:
	.db 0x0d
	.ascii "Scan request: no answer..."
	.db 0x0d
	.db 0x00
___str_68:
	.db 0x0d
	.ascii "Nagle set as requested..."
	.db 0x0d
	.db 0x00
___str_70:
	.db 0x0d
	.ascii "Nagle not set as requested, error!"
	.db 0x0d
	.db 0x00
___str_72:
	.db 0x0d
	.ascii "Requested to turn off Wi-Fi Radio..."
	.db 0x0d
	.db 0x00
___str_74:
	.db 0x0d
	.ascii "Request to turnoff Wi-Fi Radio error!"
	.db 0x0d
	.db 0x00
___str_76:
	.db 0x0d
	.ascii "Wi-Fi radio on Time-out set successfully..."
	.db 0x0d
	.db 0x00
___str_78:
	.db 0x0d
	.ascii "Error setting Wi-Fi radio on Time-out!"
	.db 0x0d
	.db 0x00
___str_79:
	.ascii "File: %s Size: %s "
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_81:
	.ascii "Error requesting to start firmware update."
	.db 0x0d
	.db 0x00
___str_82:
	.ascii "%s"
	.db 0x00
___str_84:
	.db 0x0d
	.ascii "Error reading file..."
	.db 0x0d
	.db 0x00
___str_86:
	.db 0x0d
	.ascii "Error requesting to write firmware block."
	.db 0x0d
	.db 0x00
___str_87:
	.db 0x0d
	.ascii "Error reading firmware file!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_88:
	.ascii "Error, couldn't open %s ..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_89:
	.ascii "Error, %s is 0 bytes long..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_90:
	.ascii "Ok, updating FW using server: %s port: %u"
	.db 0x0d
	.db 0x0a
	.ascii "File path: %s"
	.db 0x0a
	.ascii "Please Wait, it can take up to a few minutes!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_91:
	.ascii "Ok, updating certificates using server: %s port: %u"
	.db 0x0d
	.db 0x0a
	.ascii "File path: %s"
	.db 0x0a
	.ascii "Please Wait, it can take up to a few minutes!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_93:
	.db 0x0d
	.ascii "Success updating certificates!"
	.db 0x0d
	.db 0x00
___str_95:
	.db 0x0d
	.ascii "Success, firmware updated, wait a minute so it is fully flas"
	.ascii "hed."
	.db 0x0d
	.db 0x00
___str_97:
	.db 0x0d
	.ascii "Failed to update from remote server..."
	.db 0x0d
	.db 0x00
___str_99:
	.ascii "ESP device not found..."
	.db 0x0d
	.db 0x00
	.area _CODE
___str_100:
	.ascii "Wi-Fi is Idle, AP: "
	.db 0x00
___str_101:
	.ascii "Wi-Fi Connecting to AP: "
	.db 0x00
___str_102:
	.ascii "Wi-Fi Wrong Password for AP: "
	.db 0x00
___str_103:
	.ascii "Wi-Fi Did not find AP: "
	.db 0x00
___str_104:
	.ascii "Wi-Fi Failed to connect to: "
	.db 0x00
___str_105:
	.ascii "Wi-Fi Connected to: "
	.db 0x00
___str_106:
	.ascii "859372 bps"
	.db 0x00
___str_107:
	.ascii "346520 bps"
	.db 0x00
___str_108:
	.ascii "231014 bps"
	.db 0x00
___str_109:
	.ascii "115200 bps"
	.db 0x00
___str_110:
	.ascii "57600 bps"
	.db 0x00
___str_111:
	.ascii "38400 bps"
	.db 0x00
___str_112:
	.ascii "31250 bps"
	.db 0x00
___str_113:
	.ascii "19200 bps"
	.db 0x00
___str_114:
	.ascii "9600 bps"
	.db 0x00
___str_115:
	.ascii "4800 bps"
	.db 0x00
	.area _INITIALIZER
__xinit__strAPSts:
	.dw ___str_100
	.dw ___str_101
	.dw ___str_102
	.dw ___str_103
	.dw ___str_104
	.dw ___str_105
__xinit__speedStr:
	.dw ___str_106
	.dw ___str_107
	.dw ___str_108
	.dw ___str_109
	.dw ___str_110
	.dw ___str_111
	.dw ___str_112
	.dw ___str_113
	.dw ___str_114
	.dw ___str_115
	.area _CABS (ABS)
