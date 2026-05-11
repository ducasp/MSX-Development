;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.8.0 #10562 (MINGW64)
;--------------------------------------------------------
	.module CFGESP
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
	.globl _sendChipTypeResponse
	.globl _getChipTypeResponse
	.globl _endUpdate
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
;src\CFGESP.c:47: unsigned int MyRead (int Handle, unsigned char* Buffer, unsigned int Size)
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
;src\CFGESP.c:53: regs.Words.DE = (unsigned int) Buffer;
	ld	hl, #0x0000
	add	hl, sp
	ex	de, hl
	ld	hl, #0x0004
	add	hl, de
	ld	c, 6 (ix)
	ld	b, 7 (ix)
	ld	(hl), c
	inc	hl
	ld	(hl), b
;src\CFGESP.c:54: regs.Words.HL = Size;
	ld	hl, #0x0006
	add	hl, de
	ld	a, 8 (ix)
	ld	(hl), a
	inc	hl
	ld	a, 9 (ix)
	ld	(hl), a
;src\CFGESP.c:55: regs.Bytes.B = (unsigned char)(Handle&0xff);
	ld	hl, #0x0003
	add	hl, sp
	ld	a, 4 (ix)
	ld	(hl), a
;src\CFGESP.c:56: DosCall(0x48, &regs, REGS_MAIN, REGS_MAIN);
	ld	hl, #0x0000
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
;src\CFGESP.c:57: if (regs.Bytes.A == 0)
	ld	l, c
	ld	h, b
	inc	hl
	ld	a, (hl)
	or	a, a
	jr	NZ,00102$
;src\CFGESP.c:60: iRet = regs.Words.HL;
	push	bc
	pop	iy
	ld	l, 6 (iy)
	ld	h, 7 (iy)
	jr	00103$
00102$:
;src\CFGESP.c:63: iRet = 0;
	ld	hl, #0x0000
00103$:
;src\CFGESP.c:65: return iRet;
;src\CFGESP.c:66: }
	ld	sp, ix
	pop	ix
	ret
_Done_Version:
	.ascii "Made with FUSION-C 1.2 (ebsoft)"
	.db 0x00
_endUpdate:
	.db #0x45	; 69	'E'
	.db #0x00	; 0
_getChipTypeResponse:
	.db #0x62	; 98	'b'
	.db #0x00	; 0
	.db #0x00	; 0
_sendChipTypeResponse:
	.db #0x42	; 66	'B'
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
	.ascii "Usage:  CFGESP [options]"
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
	.ascii " FW.BIN       to update ESP firmware locally"
	.db 0x0d
	.db 0x0a
	.ascii " CERT.BIN /c  to update TLS certificates locally"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii " /u SERVER PORT FILEPATH  to update ESP firmware remotely"
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
	.ascii "Example:  CFGESP /u 192.168.31.1 80 /fw/fw.bin"
	.db 0x0d
	.db 0x0a
	.db 0x00
;src\CFGESP.c:69: unsigned int IsValidInput (char**argv, int argc, unsigned char *cServer, unsigned char *cFile, unsigned char *cPort)
;	---------------------------------
; Function IsValidInput
; ---------------------------------
_IsValidInput::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-8
	add	hl, sp
	ld	sp, hl
;src\CFGESP.c:71: unsigned int ret = 1;
	ld	bc, #0x0001
;src\CFGESP.c:72: unsigned char * Input = (unsigned char*)argv[0];
	ld	a, 4 (ix)
	ld	-6 (ix), a
	ld	a, 5 (ix)
	ld	-5 (ix), a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	a, (hl)
	ld	-8 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-7 (ix), a
;src\CFGESP.c:74: ucScan = 0;
	ld	iy, #_ucScan
	ld	0 (iy), #0x00
;src\CFGESP.c:76: if (argc)
	ld	a, 7 (ix)
	or	a, 6 (ix)
	jp	Z, 00162$
;src\CFGESP.c:78: if ((argc==1)||(argc==2)||(argc==4))
	ld	a, 6 (ix)
	dec	a
	or	a, 7 (ix)
	jr	NZ, 00286$
	ld	a, #0x01
	.db	#0x20
00286$:
	xor	a, a
00287$:
	ld	d,a
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
;src\CFGESP.c:82: if ((Input[0]=='/')&&((Input[1]=='s')||(Input[1]=='S')))
	pop	hl
	push	hl
	ld	a, (hl)
	sub	a, #0x2f
	jr	NZ, 00291$
	ld	a, #0x01
	.db	#0x20
00291$:
	xor	a, a
00292$:
	ld	e, a
;src\CFGESP.c:80: if ((argc==1)||(argc==2))
	ld	a, d
	or	a, a
	jr	NZ,00152$
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	jp	NZ,00153$
00152$:
;src\CFGESP.c:82: if ((Input[0]=='/')&&((Input[1]=='s')||(Input[1]=='S')))
	ld	a, e
	or	a, a
	jr	Z,00132$
	pop	hl
	push	hl
	inc	hl
	ld	a, (hl)
	cp	a, #0x73
	jr	Z,00131$
	sub	a, #0x53
	jr	NZ,00132$
00131$:
;src\CFGESP.c:83: ucScan = 1;
	ld	hl,#_ucScan + 0
	ld	(hl), #0x01
	jp	00163$
00132$:
;src\CFGESP.c:84: else if ((Input[0]=='/')&&((Input[1]=='n')||(Input[1]=='N')))
	ld	a, e
	or	a, a
	jr	Z,00127$
	pop	hl
	push	hl
	inc	hl
	ld	a, (hl)
	cp	a, #0x6e
	jr	Z,00126$
	sub	a, #0x4e
	jr	NZ,00127$
00126$:
;src\CFGESP.c:85: ucNagleOff = 1;
	ld	hl,#_ucNagleOff + 0
	ld	(hl), #0x01
	jp	00163$
00127$:
;src\CFGESP.c:86: else if ((Input[0]=='/')&&((Input[1]=='m')||(Input[1]=='M')))
	ld	a, e
	or	a, a
	jr	Z,00122$
	pop	hl
	push	hl
	inc	hl
	ld	a, (hl)
	cp	a, #0x6d
	jr	Z,00121$
	sub	a, #0x4d
	jr	NZ,00122$
00121$:
;src\CFGESP.c:87: ucNagleOn = 1;
	ld	hl,#_ucNagleOn + 0
	ld	(hl), #0x01
	jp	00163$
00122$:
;src\CFGESP.c:88: else if ((Input[0]=='/')&&((Input[1]=='o')||(Input[1]=='O')))
	ld	a, e
	or	a, a
	jr	Z,00117$
	pop	hl
	push	hl
	inc	hl
	ld	a, (hl)
	cp	a, #0x6f
	jr	Z,00116$
	sub	a, #0x4f
	jr	NZ,00117$
00116$:
;src\CFGESP.c:89: ucRadioOff = 1;
	ld	hl,#_ucRadioOff + 0
	ld	(hl), #0x01
	jp	00163$
00117$:
;src\CFGESP.c:90: else if ((Input[0]=='/')&&((Input[1]=='t')||(Input[1]=='T')))
	ld	a, e
	or	a, a
	jr	Z,00112$
	pop	hl
	push	hl
	inc	hl
	ld	a, (hl)
	cp	a, #0x74
	jr	Z,00111$
	sub	a, #0x54
	jr	NZ,00112$
00111$:
;src\CFGESP.c:92: ucSetTimeout = 1;
	ld	hl,#_ucSetTimeout + 0
	ld	(hl), #0x01
;src\CFGESP.c:93: Input = (unsigned char*)argv[1];
	pop	de
	pop	hl
	push	hl
	push	de
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFGESP.c:94: uiTimeout = atoi (Input);
	push	bc
	push	de
	call	_atoi
	pop	af
	pop	bc
	ld	(_uiTimeout), hl
;src\CFGESP.c:95: if (uiTimeout > 600)
	ld	a, #0x58
	ld	iy, #_uiTimeout
	cp	a, 0 (iy)
	ld	a, #0x02
	sbc	a, 1 (iy)
	jp	NC, 00163$
;src\CFGESP.c:96: uiTimeout = 600;
	ld	hl, #0x0258
	ld	(_uiTimeout), hl
	jp	00163$
00112$:
;src\CFGESP.c:100: strcpy (cFile,Input);
	push	bc
	ld	e, 10 (ix)
	ld	d, 11 (ix)
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	xor	a, a
00310$:
	cp	a, (hl)
	ldi
	jr	NZ, 00310$
	pop	bc
;src\CFGESP.c:101: ucLocalUpdate = 1;
	ld	hl,#_ucLocalUpdate + 0
	ld	(hl), #0x01
;src\CFGESP.c:102: if (argc==2)
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	jr	NZ,00109$
;src\CFGESP.c:104: Input = (unsigned char*)argv[1];
	pop	de
	pop	hl
	push	hl
	push	de
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFGESP.c:105: if ((Input[0]=='/')&&((Input[1]=='c')||(Input[1]=='C')))
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
;src\CFGESP.c:106: ucIsFw=0;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x00
	jp	00163$
00104$:
;src\CFGESP.c:108: ret=0;
	ld	bc, #0x0000
	jp	00163$
00109$:
;src\CFGESP.c:112: ucIsFw=1;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x01
	jp	00163$
00153$:
;src\CFGESP.c:117: if ((Input[0]=='/')&&((Input[1]=='u')||(Input[1]=='U')))
	ld	a, e
	or	a, a
	jp	Z, 00148$
	pop	hl
	push	hl
	inc	hl
	ld	a, (hl)
	cp	a, #0x75
	jr	Z,00147$
	sub	a, #0x55
	jp	NZ,00148$
00147$:
;src\CFGESP.c:119: ucIsFw = 1;
	ld	iy, #_ucIsFw
	ld	0 (iy), #0x01
;src\CFGESP.c:120: Input = (unsigned char*)argv[2];
	pop	de
	pop	hl
	push	hl
	push	de
	ld	de, #0x0004
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFGESP.c:121: if (strlen (Input)<7)
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
;src\CFGESP.c:123: strcpy(cPort,Input);
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
;src\CFGESP.c:124: Input = (unsigned char*)argv[1];
	pop	de
	pop	hl
	push	hl
	push	de
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	h, (hl)
;src\CFGESP.c:125: strcpy(cServer,Input);
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
;src\CFGESP.c:126: Input = (unsigned char*)argv[3];
	pop	de
	pop	hl
	push	hl
	push	de
	ld	de, #0x0006
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	h, (hl)
;src\CFGESP.c:127: strcpy(cFile,Input);
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
	ld	-1 (ix), d
	ld	-2 (ix), e
	ld	-3 (ix), h
	ld	-4 (ix), l
	ld	de, #_lPort
	ld	hl, #6
	add	hl, sp
	ld	bc, #4
	ldir
	pop	bc
;src\CFGESP.c:129: uiPort = (lPort&0xffff);
	ld	hl, (_lPort)
	ld	(_uiPort), hl
	jp	00163$
00137$:
;src\CFGESP.c:132: ret = 0;
	ld	bc, #0x0000
	jp	00163$
00148$:
;src\CFGESP.c:134: else if ((Input[0]=='/')&&((Input[1]=='c')||(Input[1]=='C')))
	ld	a, e
	or	a, a
	jp	Z, 00143$
	pop	hl
	push	hl
	inc	hl
	ld	a, (hl)
	cp	a, #0x63
	jr	Z,00142$
	sub	a, #0x43
	jp	NZ,00143$
00142$:
;src\CFGESP.c:136: ucIsFw = 0;
	ld	iy, #_ucIsFw
	ld	0 (iy), #0x00
;src\CFGESP.c:137: Input = (unsigned char*)argv[2];
	pop	de
	pop	hl
	push	hl
	push	de
	ld	de, #0x0004
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFGESP.c:138: if (strlen (Input)<7)
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
;src\CFGESP.c:140: strcpy(cPort,Input);
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
;src\CFGESP.c:141: Input = (unsigned char*)argv[1];
	pop	de
	pop	hl
	push	hl
	push	de
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	h, (hl)
;src\CFGESP.c:142: strcpy(cServer,Input);
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
;src\CFGESP.c:143: Input = (unsigned char*)argv[3];
	pop	de
	pop	hl
	push	hl
	push	de
	ld	de, #0x0006
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	h, (hl)
;src\CFGESP.c:144: strcpy(cFile,Input);
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
	ld	-1 (ix), d
	ld	-2 (ix), e
	ld	-3 (ix), h
	ld	-4 (ix), l
	ld	de, #_lPort
	ld	hl, #6
	add	hl, sp
	ld	bc, #4
	ldir
	pop	bc
;src\CFGESP.c:146: uiPort = (lPort&0xffff);
	ld	hl, (_lPort)
	ld	(_uiPort), hl
	jr	00163$
00140$:
;src\CFGESP.c:149: ret = 0;
	ld	bc, #0x0000
	jr	00163$
00143$:
;src\CFGESP.c:152: ret = 0;
	ld	bc, #0x0000
	jr	00163$
00157$:
;src\CFGESP.c:156: ret = 0;
	ld	bc, #0x0000
	jr	00163$
00162$:
;src\CFGESP.c:159: ret=0;
	ld	bc, #0x0000
00163$:
;src\CFGESP.c:161: return ret;
	ld	l, c
	ld	h, b
;src\CFGESP.c:162: }
	ld	sp, ix
	pop	ix
	ret
;src\CFGESP.c:164: void TxByte(char chTxByte)
;	---------------------------------
; Function TxByte
; ---------------------------------
_TxByte::
;src\CFGESP.c:166: while (myPort7&2);
00101$:
	in	a, (_myPort7)
	bit	1, a
	jr	NZ,00101$
;src\CFGESP.c:170: myPort7 = chTxByte;
	ld	hl, #2+0
	add	hl, sp
	ld	a, (hl)
	out	(_myPort7), a
;src\CFGESP.c:171: }
	ret
;src\CFGESP.c:173: char *ultostr(unsigned long value, char *ptr, int base)
;	---------------------------------
; Function ultostr
; ---------------------------------
_ultostr::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-13
	add	hl, sp
	ld	sp, hl
;src\CFGESP.c:176: unsigned long tmp = value;
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	e, 6 (ix)
	ld	d, 7 (ix)
;src\CFGESP.c:179: if (NULL == ptr) //if null pointer
	ld	a, 9 (ix)
	or	a, 8 (ix)
	jr	NZ,00102$
;src\CFGESP.c:180: return NULL; //nothing to do
	ld	hl, #0x0000
	jp	00118$
00102$:
;src\CFGESP.c:188: tmp = tmp/base;
	ld	a, 10 (ix)
	ld	-13 (ix), a
	ld	a, 11 (ix)
	ld	-12 (ix), a
	rla
	sbc	a, a
	ld	-11 (ix), a
	ld	-10 (ix), a
;src\CFGESP.c:182: if (tmp == 0) //if value is zero
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jr	NZ,00123$
;src\CFGESP.c:183: ++count; //one digit
	ld	c, #0x01
	jr	00108$
;src\CFGESP.c:186: while(tmp > 0)
00123$:
	ld	-9 (ix), #0x00
00103$:
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jr	Z,00129$
;src\CFGESP.c:188: tmp = tmp/base;
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	push	hl
	ld	l, -13 (ix)
	ld	h, -12 (ix)
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
;src\CFGESP.c:189: ++count;
	inc	-9 (ix)
	jr	00103$
00129$:
	ld	c, -9 (ix)
00108$:
;src\CFGESP.c:193: ptr += count; // so, after the LSB
	ld	a, 8 (ix)
	add	a, c
	ld	8 (ix), a
	jr	NC,00166$
	inc	9 (ix)
00166$:
;src\CFGESP.c:194: *ptr = '\0'; // null terminator
	ld	c, 8 (ix)
	ld	b, 9 (ix)
	xor	a, a
	ld	(bc), a
;src\CFGESP.c:196: do
00115$:
;src\CFGESP.c:198: t = value / base; // useful now (find remainder) as well later (next value of value)
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	push	hl
	ld	l, -13 (ix)
	ld	h, -12 (ix)
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
	ld	-1 (ix), d
	ld	-2 (ix), e
	ld	-3 (ix), h
	ld	-4 (ix), l
;src\CFGESP.c:199: res = value - base * t; // get what remains of dividing base
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	push	hl
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	push	hl
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	a, 4 (ix)
	sub	a, l
	ld	c, a
	ld	a, 5 (ix)
	sbc	a, h
	ld	b, a
	ld	a, 6 (ix)
	sbc	a, e
	ld	e, a
	ld	a, 7 (ix)
	sbc	a, d
	ld	d, a
	ld	-8 (ix), c
	ld	-7 (ix), b
	ld	-6 (ix), e
	ld	-5 (ix), d
;src\CFGESP.c:201: if (res < 10)
	ld	a, -8 (ix)
	sub	a, #0x0a
	ld	a, -7 (ix)
	sbc	a, #0x00
	ld	a, -6 (ix)
	sbc	a, #0x00
	ld	a, -5 (ix)
	sbc	a, #0x00
	ld	a, #0x00
	rla
	or	a, a
	jr	Z,00113$
;src\CFGESP.c:202: * -- ptr = '0' + res; // convert the remainder to ASCII and put in the current position of pointer, move pointer after operation
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	dec	hl
	ld	8 (ix), l
	ld	9 (ix), h
	ld	c, l
	ld	b, h
	ld	a, -8 (ix)
	add	a, #0x30
	ld	(bc), a
	jr	00116$
00113$:
;src\CFGESP.c:203: else if ((res >= 10) && (res < 16)) // Otherwise is a HEX value and a digit above 9
	or	a, a
	jr	NZ,00116$
	ld	a, -8 (ix)
	sub	a, #0x10
	ld	a, -7 (ix)
	sbc	a, #0x00
	ld	a, -6 (ix)
	sbc	a, #0x00
	ld	a, -5 (ix)
	sbc	a, #0x00
	jr	NC,00116$
;src\CFGESP.c:204: * --ptr = 'A' - 10 + res; // convert the remainder to ASCII and put in the current position of pointer, move pointer after operation
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	dec	hl
	ld	8 (ix), l
	ld	9 (ix), h
	ld	c, l
	ld	b, h
	ld	a, -8 (ix)
	add	a, #0x37
	ld	(bc), a
00116$:
;src\CFGESP.c:205: } while ((value = t) != 0); //value is now t, and if t is other than zero, still work to do
	ld	hl, #17
	add	hl, sp
	ex	de, hl
	ld	hl, #9
	add	hl, sp
	ld	bc, #4
	ldir
	ld	a, -1 (ix)
	or	a, -2 (ix)
	or	a, -3 (ix)
	or	a, -4 (ix)
	jp	NZ, 00115$
;src\CFGESP.c:207: return(ptr); // and return own pointer as successful conversion has been made
	ld	l, 8 (ix)
	ld	h, 9 (ix)
00118$:
;src\CFGESP.c:208: }
	ld	sp, ix
	pop	ix
	ret
;src\CFGESP.c:210: bool WaitForRXData(unsigned char *uchData, unsigned int uiDataSize, unsigned int Timeout, bool bVerbose, bool bShowReceivedData, unsigned char *uchData2, unsigned int uiDataSize2)
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
;src\CFGESP.c:212: bool bReturn = false;
	ld	-9 (ix), #0x00
;src\CFGESP.c:217: unsigned int i = 0;
	ld	-2 (ix), #0x00
	ld	-1 (ix), #0x00
;src\CFGESP.c:219: if (bShowReceivedData)
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00104$
;src\CFGESP.c:221: printf ("Waiting for: ");
	ld	hl, #___str_2
	push	hl
	call	_printf
	pop	af
;src\CFGESP.c:222: for (i=0;i<uiDataSize;++i)
	ld	bc, #0x0000
00144$:
	ld	a, c
	sub	a, 6 (ix)
	ld	a, b
	sbc	a, 7 (ix)
	jr	NC,00101$
;src\CFGESP.c:223: printf("%c",uchData[i]);
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
;src\CFGESP.c:222: for (i=0;i<uiDataSize;++i)
	inc	bc
	jr	00144$
00101$:
;src\CFGESP.c:224: printf (" / ");
	ld	hl, #___str_4
	push	hl
	call	_printf
	pop	af
;src\CFGESP.c:225: for (i=0;i<uiDataSize;++i)
	ld	bc, #0x0000
00147$:
	ld	a, c
	sub	a, 6 (ix)
	ld	a, b
	sbc	a, 7 (ix)
	jr	NC,00102$
;src\CFGESP.c:226: printf("{%x}",uchData[i]);
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
;src\CFGESP.c:225: for (i=0;i<uiDataSize;++i)
	inc	bc
	jr	00147$
00102$:
;src\CFGESP.c:227: printf ("\r\n");
	ld	hl, #___str_7
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:228: i = 0;
	ld	-2 (ix), #0x00
	ld	-1 (ix), #0x00
00104$:
;src\CFGESP.c:231: Timeout1 = TickCount + 9; //Drives the animation every 9 ticks or so
	ld	iy, #_TickCount
	ld	a, 0 (iy)
	add	a, #0x09
	ld	-14 (ix), a
	ld	a, 1 (iy)
	adc	a, #0x00
	ld	-13 (ix), a
;src\CFGESP.c:232: Timeout2 = TickCount + Timeout; //Wait up to 5 minutes
	ld	iy, (_TickCount)
	ld	e, 8 (ix)
	ld	d, 9 (ix)
	add	iy, de
	push	iy
	pop	af
	ld	-5 (ix), a
	push	iy
	dec	sp
	pop	af
	inc	sp
	ld	-6 (ix), a
;src\CFGESP.c:234: ResponseSt = 0;
	ld	-8 (ix), #0x00
	ld	-7 (ix), #0x00
;src\CFGESP.c:235: ResponseSt2 = 0;
	ld	-4 (ix), #0x00
	ld	-3 (ix), #0x00
;src\CFGESP.c:237: do
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	jr	NZ, 00268$
	ld	a, #0x01
	.db	#0x20
00268$:
	xor	a, a
00269$:
	ld	-11 (ix), a
	ld	a, #0x84
	cp	a, 8 (ix)
	ld	a, #0x03
	sbc	a, 9 (ix)
	ld	a, #0x00
	rla
	ld	-12 (ix), a
	ld	a, -2 (ix)
	ld	-16 (ix), a
	ld	a, -1 (ix)
	ld	-15 (ix), a
00138$:
;src\CFGESP.c:239: if (Timeout>900)
	ld	a, -12 (ix)
	or	a, a
	jr	Z,00108$
;src\CFGESP.c:241: if (TickCount>Timeout1)
	ld	a, -14 (ix)
	ld	iy, #_TickCount
	sub	a, 0 (iy)
	ld	a, -13 (ix)
	sbc	a, 1 (iy)
	jr	NC,00108$
;src\CFGESP.c:243: Timeout1 = TickCount + 9;
	ld	a, 0 (iy)
	add	a, #0x09
	ld	-14 (ix), a
	ld	a, 1 (iy)
	adc	a, #0x00
	ld	-13 (ix), a
;src\CFGESP.c:244: printf("%s",advance[i%5]); // next char
	ld	hl, #0x0005
	push	hl
	ld	l, -16 (ix)
	ld	h, -15 (ix)
	push	hl
	call	__moduint
	pop	af
	pop	af
	ld	-17 (ix), h
	ld	-18 (ix), l
	pop	bc
	push	bc
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ex	(sp), hl
	ld	a, #<(_advance)
	add	a, -18 (ix)
	ld	-18 (ix), a
	ld	a, #>(_advance)
	adc	a, -17 (ix)
	ld	-17 (ix), a
	pop	hl
	push	hl
	push	hl
	ld	hl, #___str_8
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFGESP.c:245: ++i;
	inc	-16 (ix)
	jr	NZ,00270$
	inc	-15 (ix)
00270$:
00108$:
;src\CFGESP.c:248: if(UartRXData())
	in	a, (_myPort7)
	rrca
	jp	NC,00135$
;src\CFGESP.c:250: rx_data = GetUARTData();
	in	a, (_myPort6)
	ld	-10 (ix), a
;src\CFGESP.c:252: if (rx_data == uchData[ResponseSt])
	ld	a, 4 (ix)
	add	a, -8 (ix)
	ld	l, a
	ld	a, 5 (ix)
	adc	a, -7 (ix)
	ld	h, a
	ld	a, (hl)
	ld	-18 (ix), a
	ld	a, -10 (ix)
	sub	a, -18 (ix)
	jr	NZ,00126$
;src\CFGESP.c:254: if (bShowReceivedData)
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00110$
;src\CFGESP.c:255: printf ("{%x}",rx_data);
	ld	c, -10 (ix)
	ld	b, #0x00
	push	bc
	ld	hl, #___str_5
	push	hl
	call	_printf
	pop	af
	pop	af
00110$:
;src\CFGESP.c:256: ++ResponseSt;
	inc	-8 (ix)
	jr	NZ,00274$
	inc	-7 (ix)
00274$:
;src\CFGESP.c:257: if (ResponseSt == uiDataSize)
	ld	a, -8 (ix)
	sub	a, 6 (ix)
	jp	NZ,00127$
	ld	a, -7 (ix)
	sub	a, 7 (ix)
	jp	NZ,00127$
;src\CFGESP.c:259: bReturn = 1;
	ld	-9 (ix), #0x01
;src\CFGESP.c:260: break;
	jp	00140$
00126$:
;src\CFGESP.c:265: if ((ResponseSt)&&(bShowReceivedData))
	ld	a, -7 (ix)
	or	a, -8 (ix)
	jr	Z,00116$
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00116$
;src\CFGESP.c:266: printf ("{%x} != [%x]",rx_data,uchData[ResponseSt]);
	ld	e, -18 (ix)
	ld	d, #0x00
	ld	c, -10 (ix)
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
;src\CFGESP.c:267: else if (bShowReceivedData)
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00117$
;src\CFGESP.c:268: printf ("}%x{",rx_data);
	ld	c, -10 (ix)
	ld	b, #0x00
	push	bc
	ld	hl, #___str_10
	push	hl
	call	_printf
	pop	af
	pop	af
00117$:
;src\CFGESP.c:269: if ((uiDataSize==2)&&(ResponseSt==1))
	ld	a, -11 (ix)
	or	a, a
	jr	Z,00123$
	ld	a, -8 (ix)
	dec	a
	or	a, -7 (ix)
	jr	NZ,00123$
;src\CFGESP.c:271: if ((bVerbose)&&(!uchData2))
	ld	a, 10 (ix)
	or	a, a
	jr	Z,00120$
	ld	a, 13 (ix)
	or	a, 12 (ix)
	jr	NZ,00120$
;src\CFGESP.c:272: printf ("Error %u on command %c...\r\n",rx_data,uchData[0]);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	e, (hl)
	ld	d, #0x00
	ld	c, -10 (ix)
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
;src\CFGESP.c:273: return false;
	ld	l, #0x00
	jp	00149$
00123$:
;src\CFGESP.c:275: ResponseSt = 0;
	ld	-8 (ix), #0x00
	ld	-7 (ix), #0x00
00127$:
;src\CFGESP.c:278: if ((uchData2)&&(rx_data == uchData2[ResponseSt2]))
	ld	a, 13 (ix)
	or	a, 12 (ix)
	jr	Z,00131$
	ld	a, 12 (ix)
	add	a, -4 (ix)
	ld	-18 (ix), a
	ld	a, 13 (ix)
	adc	a, -3 (ix)
	ld	-17 (ix), a
	pop	hl
	push	hl
	ld	a,-10 (ix)
	sub	a,(hl)
	jr	NZ,00131$
;src\CFGESP.c:280: ++ResponseSt2;
	inc	-4 (ix)
	jr	NZ,00281$
	inc	-3 (ix)
00281$:
;src\CFGESP.c:281: if (ResponseSt2 == uiDataSize2)
	ld	a, -4 (ix)
	sub	a, 14 (ix)
	jr	NZ,00135$
	ld	a, -3 (ix)
	sub	a, 15 (ix)
	jr	NZ,00135$
;src\CFGESP.c:283: bReturn = 2;
	ld	-9 (ix), #0x02
;src\CFGESP.c:284: break;
	jr	00140$
00131$:
;src\CFGESP.c:288: ResponseSt2 = 0;
	ld	-4 (ix), #0x00
	ld	-3 (ix), #0x00
00135$:
;src\CFGESP.c:291: if (TickCount>Timeout2)
	ld	a, -6 (ix)
	ld	iy, #_TickCount
	sub	a, 0 (iy)
	ld	a, -5 (ix)
	sbc	a, 1 (iy)
	jp	NC, 00138$
;src\CFGESP.c:294: while (1);
00140$:
;src\CFGESP.c:296: if (Timeout>900)
	ld	a, -12 (ix)
	or	a, a
	jr	Z,00142$
;src\CFGESP.c:297: printf("%s",aDone); // clear line
	ld	hl, #_aDone
	push	hl
	ld	hl, #___str_8
	push	hl
	call	_printf
	pop	af
	pop	af
00142$:
;src\CFGESP.c:299: return bReturn;
	ld	l, -9 (ix)
00149$:
;src\CFGESP.c:300: }
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
;src\CFGESP.c:302: void FinishUpdate (bool bSendReset)
;	---------------------------------
; Function FinishUpdate
; ---------------------------------
_FinishUpdate::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-7
	add	hl, sp
	ld	sp, hl
;src\CFGESP.c:304: unsigned int iRetries = 3;
	ld	hl, #0x0003
	ex	(sp), hl
;src\CFGESP.c:308: bool bReset = bSendReset;
	ld	a, 4 (ix)
	ld	-2 (ix), a
;src\CFGESP.c:310: printf("\rFinishing flash, this will take some time, WAIT!\r\n");
	ld	hl, #___str_13
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:312: do
	ld	-1 (ix), #0x02
00135$:
;src\CFGESP.c:314: bRet = true;
	ld	l, #0x01
;src\CFGESP.c:315: --ucRetries;
	dec	-1 (ix)
;src\CFGESP.c:316: if (bReset)
	ld	a, -2 (ix)
	or	a, a
	jr	Z,00154$
;src\CFGESP.c:317: TxByte('R'); //Request Reset
	push	hl
	ld	a, #0x52
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	hl
	jr	00110$
;src\CFGESP.c:320: do
00154$:
	pop	bc
	push	bc
;src\CFGESP.c:322: for (uchHalt=60;uchHalt>0;--uchHalt)
00152$:
	ld	a, #0x3c
00140$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFGESP.c:322: for (uchHalt=60;uchHalt>0;--uchHalt)
	dec	a
	or	a, a
	jr	NZ,00140$
;src\CFGESP.c:324: TxByte('E'); //End Update
	push	bc
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
	pop	bc
;src\CFGESP.c:326: iRetries--;
	dec	bc
;src\CFGESP.c:328: while ((!bRet)&&(iRetries));
	ld	a, l
	or	a, a
	jr	NZ,00170$
	ld	a, b
	or	a, c
	jr	NZ,00152$
00170$:
	inc	sp
	inc	sp
	push	bc
;src\CFGESP.c:330: if (bRet)
	ld	a, l
	or	a, a
	jr	Z,00110$
;src\CFGESP.c:331: bReset=true;
	ld	-2 (ix), #0x01
00110$:
;src\CFGESP.c:334: if (!bRet)
	ld	a, l
	or	a, a
	jr	NZ,00133$
;src\CFGESP.c:335: printf("\rTimeout waiting to end update...\r\n");
	ld	hl, #___str_15
	push	hl
	call	_puts
	pop	af
	jp	00136$
00133$:
;src\CFGESP.c:338: if (ucRetries)
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00115$
;src\CFGESP.c:340: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00112$
;src\CFGESP.c:341: printf("\rFirmware Update done, ESP is restarting, WAIT...\r\n");
	ld	hl, #___str_17
	push	hl
	call	_puts
	pop	af
	jr	00115$
00112$:
;src\CFGESP.c:343: printf("\rCertificates Update done, ESP is restarting, WAIT...\r\n");
	ld	hl, #___str_19
	push	hl
	call	_puts
	pop	af
00115$:
;src\CFGESP.c:346: if (WaitForRXData(responseReady2,7,2700,false,false,NULL,0)) //Wait up to 45 seconds
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
;src\CFGESP.c:348: if (!ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jp	NZ, 00125$
;src\CFGESP.c:350: printf("\rESP Reset Ok, now let's request creation of index file...\r\n");
	ld	hl, #___str_21
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:352: do
	ld	-4 (ix), #0x0a
	ld	-3 (ix), #0x00
;src\CFGESP.c:354: for (uchHalt=60;uchHalt>0;--uchHalt)
00162$:
	ld	a, #0x3c
00142$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFGESP.c:354: for (uchHalt=60;uchHalt>0;--uchHalt)
	dec	a
	or	a, a
	jr	NZ,00142$
;src\CFGESP.c:356: TxByte('I'); //End Update
	ld	a, #0x49
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:357: bRet = WaitForRXData(certificateDone,2,3600,false,false,NULL,0); //Wait up to 1 minute, certificate index creation takes time
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
	ld	-5 (ix), l
;src\CFGESP.c:358: iRetries--;
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	dec	hl
	ld	-4 (ix), l
	ld	-3 (ix), h
;src\CFGESP.c:360: while ((!bRet)&&(iRetries));
	ld	a, -5 (ix)
	or	a, a
	jr	NZ,00120$
	ld	a, -3 (ix)
	or	a, -4 (ix)
	jr	NZ,00162$
00120$:
;src\CFGESP.c:361: if (bRet)
	ld	a, -5 (ix)
	or	a, a
	jr	Z,00122$
;src\CFGESP.c:362: printf("\rDone!                                \r\n");
	ld	hl, #___str_23
	push	hl
	call	_puts
	pop	af
	jr	00137$
00122$:
;src\CFGESP.c:364: printf("\rDone, but time-out on creating certificates index file!\r\n");
	ld	hl, #___str_25
	push	hl
	call	_puts
	pop	af
	jr	00137$
00125$:
;src\CFGESP.c:367: printf("\rDone!                              \r\n");
	ld	hl, #___str_27
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:368: break;
	jr	00137$
00130$:
;src\CFGESP.c:371: if (!ucRetries)
	ld	a, -1 (ix)
	or	a, a
	jr	NZ,00136$
;src\CFGESP.c:372: printf("\rTimeout error\r\n");
	ld	hl, #___str_29
	push	hl
	call	_puts
	pop	af
00136$:
;src\CFGESP.c:375: while (ucRetries);
	ld	a, -1 (ix)
	or	a, a
	jp	NZ, 00135$
00137$:
;src\CFGESP.c:377: return;
;src\CFGESP.c:378: }
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
;src\CFGESP.c:380: int main(char** argv, int argc)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-4820
	add	hl, sp
	ld	sp, hl
;src\CFGESP.c:389: unsigned int i = 0;
	ld	-65 (ix), #0x00
	ld	-64 (ix), #0x00
;src\CFGESP.c:397: unsigned char ucFirstBlock = 1;
	ld	-5 (ix), #0x01
;src\CFGESP.c:419: ucLocalUpdate = 0;
	ld	hl,#_ucLocalUpdate + 0
	ld	(hl), #0x00
;src\CFGESP.c:420: ucNagleOff = 0;
	ld	hl,#_ucNagleOff + 0
	ld	(hl), #0x00
;src\CFGESP.c:421: ucNagleOn = 0;
	ld	hl,#_ucNagleOn + 0
	ld	(hl), #0x00
;src\CFGESP.c:422: ucRadioOff = 0;
	ld	hl,#_ucRadioOff + 0
	ld	(hl), #0x00
;src\CFGESP.c:423: ucSetTimeout = 0;
	ld	hl,#_ucSetTimeout + 0
	ld	(hl), #0x00
;src\CFGESP.c:424: ucScanPage = 0;
	ld	-39 (ix), #0x00
;src\CFGESP.c:426: ucVerMajor = 0;
	ld	-16 (ix), #0x00
;src\CFGESP.c:427: ucVerMinor = 0;
	ld	-28 (ix), #0x00
;src\CFGESP.c:428: TickCount = 0; //this guarantees no leap for 18 minutes, more than enough so we do not need to check for jiffy leaping
	ld	hl, #0x0000
	ld	(_TickCount), hl
;src\CFGESP.c:429: ucESP32 = 0;
	ld	-29 (ix), #0x00
;src\CFGESP.c:432: printf("> SM-X ESP Wi-Fi Module Configuration v2.00 <\r\n(c) 2026 Oduvaldo Pavan Junior - ducasp@gmail.com\r\n\n");
	ld	hl, #___str_31
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:434: if (IsValidInput(argv, argc, ucServer, ucFile, ucPort))
	ld	hl, #0x0138
	add	hl, sp
	ex	de, hl
	ld	hl, #0x013e
	add	hl, sp
	ld	-47 (ix), l
	ld	-46 (ix), h
	ld	c, l
	ld	b, h
	ld	hl, #0x026a
	add	hl, sp
	ld	-55 (ix), l
	ld	-54 (ix), h
	push	de
	push	bc
	push	hl
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
	ld	-52 (ix), h
	ld	-53 (ix), l
	ld	a, -52 (ix)
	or	a, -53 (ix)
	jp	Z, 00412$
;src\CFGESP.c:436: do
	ld	-3 (ix), #0x00
00103$:
;src\CFGESP.c:439: myPort6 = speed;
	ld	a, -3 (ix)
	out	(_myPort6), a
;src\CFGESP.c:440: ClearUartData();
	ld	a, #0x14
	out	(_myPort6), a
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFGESP.c:442: TxByte('?');
	ld	a, #0x3f
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:444: bResponse = WaitForRXData(responseOK,2,60,false,false,NULL,0);
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
;src\CFGESP.c:446: if (bResponse)
	or	a, a
	jr	NZ,00105$
;src\CFGESP.c:448: ++speed;
	inc	-3 (ix)
;src\CFGESP.c:450: while (speed<10);
	ld	a, -3 (ix)
	sub	a, #0x0a
	jr	C,00103$
00105$:
;src\CFGESP.c:452: if (speed<10)
	ld	a, -3 (ix)
	sub	a, #0x0a
	jp	NC, 00409$
;src\CFGESP.c:454: printf ("Baud Rate: %s\r\n",speedStr[speed]);
	ld	a, -3 (ix)
	ld	-53 (ix), a
	ld	-52 (ix), #0x00
	sla	-53 (ix)
	rl	-52 (ix)
	ld	a, #<(_speedStr)
	add	a, -53 (ix)
	ld	-53 (ix), a
	ld	a, #>(_speedStr)
	adc	a, -52 (ix)
	ld	-52 (ix), a
	ld	l, -53 (ix)
	ld	h, -52 (ix)
	ld	a, (hl)
	ld	-53 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-52 (ix), a
	ld	l, -53 (ix)
	ld	h, -52 (ix)
	push	hl
	ld	hl, #___str_32
	push	hl
	call	_printf
	pop	af
;src\CFGESP.c:456: TxByte('b'); //Request chiptype
	ld	h,#0x62
	ex	(sp),hl
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:457: bResponse = WaitForRXData(getChipTypeResponse,3,20,true,false,NULL,0);
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
	ld	l, #0x03
	push	hl
	ld	hl, #_getChipTypeResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	a, l
;src\CFGESP.c:458: if (bResponse)
	or	a, a
	jr	Z,00116$
;src\CFGESP.c:460: ucESP32 = 1;
	ld	-29 (ix), #0x01
;src\CFGESP.c:461: while(!UartRXData());
00106$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00106$
;src\CFGESP.c:462: ucChipTypeRspSize = GetUARTData();
	in	a, (_myPort6)
	ld	e, a
;src\CFGESP.c:463: printf ("Chip Type: ");
	push	de
	ld	hl, #___str_33
	push	hl
	call	_printf
	pop	af
	pop	de
;src\CFGESP.c:465: while(ucChipTypeRspSize)
	ld	hl, #0x0000
	add	hl, sp
	ld	-53 (ix), l
	ld	-52 (ix), h
	ld	bc, #0x0000
	ld	-59 (ix), e
00112$:
	ld	a, -59 (ix)
	or	a, a
	jr	Z,00590$
;src\CFGESP.c:467: while(!UartRXData());
00109$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00109$
;src\CFGESP.c:468: ucChipTypeString[i++] = GetUARTData();
	ld	e, c
	ld	d, b
	inc	bc
	ld	a, -53 (ix)
	add	a, e
	ld	e, a
	ld	a, -52 (ix)
	adc	a, d
	ld	d, a
	in	a, (_myPort6)
	ld	(de), a
;src\CFGESP.c:469: --ucChipTypeRspSize;
	dec	-59 (ix)
	jr	00112$
00590$:
	ld	-65 (ix), c
	ld	-64 (ix), b
;src\CFGESP.c:471: printf ("%s\r\n", ucChipTypeString);
	ld	c, -53 (ix)
	ld	b, -52 (ix)
	push	bc
	ld	hl, #___str_34
	push	hl
	call	_printf
	pop	af
	pop	af
	jr	00117$
00116$:
;src\CFGESP.c:474: printf ("Chip Type: ESP8266\r\n");
	ld	hl, #___str_36
	push	hl
	call	_puts
	pop	af
00117$:
;src\CFGESP.c:476: TxByte('V'); //Request version
	ld	a, #0x56
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:477: bResponse = WaitForRXData(versionResponse,1,20,true,false,NULL,0);
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
;src\CFGESP.c:478: if (bResponse)
	ld	-59 (ix), l
	ld	a, l
	or	a, a
	jr	Z,00125$
;src\CFGESP.c:480: while(!UartRXData());
00118$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00118$
;src\CFGESP.c:481: ucVerMajor = GetUARTData();
	in	a, (_myPort6)
	ld	-16 (ix), a
;src\CFGESP.c:482: while(!UartRXData());
00121$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00121$
;src\CFGESP.c:483: ucVerMinor = GetUARTData();
	in	a, (_myPort6)
	ld	-28 (ix), a
00125$:
;src\CFGESP.c:485: printf ("FW Version: %c.%c\r\n",ucVerMajor+'0',ucVerMinor+'0');
	ld	c, -28 (ix)
	ld	b, #0x00
	ld	hl, #0x0030
	add	hl, bc
	ex	de, hl
	ld	c, -16 (ix)
	ld	b, #0x00
	ld	hl, #0x0030
	add	hl, bc
	ld	bc, #___str_37+0
	push	de
	push	hl
	push	bc
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;src\CFGESP.c:487: if ((ucScan)||(ucNagleOff)||(ucNagleOn)||(ucRadioOff)||(ucSetTimeout))
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	NZ,00401$
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00401$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	NZ,00401$
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	NZ,00401$
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jp	Z, 00402$
00401$:
;src\CFGESP.c:490: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jp	Z, 00160$
;src\CFGESP.c:492: if ((ucESP32)||((ucVerMajor>=1)||((ucVerMajor==1)&&(ucVerMinor>=2)))) // new firmware allow get current ap and connection status
	ld	a, -29 (ix)
	or	a, a
	jr	NZ,00140$
	ld	a, -16 (ix)
	sub	a, #0x01
	jr	NC,00140$
	ld	a, -16 (ix)
	dec	a
	jp	NZ,00141$
	ld	a, -28 (ix)
	sub	a, #0x02
	jp	C, 00141$
00140$:
;src\CFGESP.c:494: TxByte('g'); //Request current AP status
	ld	a, #0x67
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:495: bResponse = WaitForRXData(apstsResponse,3,30,true,false,NULL,0);
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
;src\CFGESP.c:496: if (bResponse)
	ld	-59 (ix), l
	ld	a, l
	or	a, a
	jr	Z,00141$
;src\CFGESP.c:498: while(!UartRXData());
00126$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00126$
;src\CFGESP.c:499: ucAPstsRspSize=GetUARTData();
	in	a, (_myPort6)
	ld	-53 (ix), a
;src\CFGESP.c:503: while(!UartRXData());
	ld	hl, #0x10fc
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0000
00129$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00129$
;src\CFGESP.c:504: chAPStsInfo[i]=GetUARTData();
	ld	l, c
	ld	h, b
	add	hl, de
	in	a, (_myPort6)
	ld	(hl), a
;src\CFGESP.c:505: ++i;
	inc	bc
;src\CFGESP.c:507: while(i<ucAPstsRspSize);
	ld	l, -53 (ix)
	ld	h, #0x00
	ld	a, c
	sub	a, l
	ld	a, b
	sbc	a, h
	jr	C,00129$
;src\CFGESP.c:508: if (chAPStsInfo[0] < 6)
	ld	a, (de)
	ld	c,a
	sub	a, #0x06
	jr	NC,00136$
;src\CFGESP.c:509: printf("%s%s\r\n\n",strAPSts[chAPStsInfo[0]],&chAPStsInfo[1]);
	inc	de
	ld	l, c
	ld	h, #0x00
	add	hl, hl
	ld	bc, #_strAPSts
	add	hl, bc
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	push	de
	push	bc
	ld	hl, #___str_38
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	jr	00141$
00136$:
;src\CFGESP.c:511: printf("Unknown status of AP!!!\r\n\n");
	ld	hl, #___str_40
	push	hl
	call	_puts
	pop	af
00141$:
;src\CFGESP.c:514: TxByte('S'); //Request SCAN
	ld	a, #0x53
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jp	00161$
00160$:
;src\CFGESP.c:516: else if (ucNagleOff)
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	Z,00157$
;src\CFGESP.c:517: TxByte('N'); //Request nagle off for future connections
	ld	a, #0x4e
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jp	00161$
00157$:
;src\CFGESP.c:518: else if (ucNagleOn)
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00154$
;src\CFGESP.c:519: TxByte('D'); //Request nagle on for future connections
	ld	a, #0x44
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00161$
00154$:
;src\CFGESP.c:520: else if (ucRadioOff)
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	Z,00151$
;src\CFGESP.c:521: TxByte('O'); //Request to turn off Wi-Fi radio immediately
	ld	a, #0x4f
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00161$
00151$:
;src\CFGESP.c:522: else if (ucSetTimeout)
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jr	Z,00161$
;src\CFGESP.c:524: ucTimeOutMSB = ((unsigned char)((uiTimeout&0xff00)>>8));
	ld	iy, #_uiTimeout
	ld	c, 1 (iy)
	ld	-17 (ix), c
;src\CFGESP.c:525: ucTimeOutLSB = ((unsigned char)(uiTimeout&0xff));
	ld	a, 0 (iy)
	ld	-8 (ix), a
;src\CFGESP.c:526: if (uiTimeout)
	ld	a, 1 (iy)
	or	a, 0 (iy)
	jr	Z,00146$
;src\CFGESP.c:527: printf("\r\nSetting Wi-Fi idle timeout to %u...\r\n",uiTimeout);
	ld	hl, (_uiTimeout)
	push	hl
	ld	hl, #___str_41
	push	hl
	call	_printf
	pop	af
	pop	af
	jr	00147$
00146$:
;src\CFGESP.c:529: printf("\r\nSetting Wi-Fi to always on!\r\n");
	ld	hl, #___str_43
	push	hl
	call	_puts
	pop	af
00147$:
;src\CFGESP.c:530: TxByte('T'); //Request to set time-out
	ld	a, #0x54
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:531: TxByte(0);
	xor	a, a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:532: TxByte(2);
	ld	a, #0x02
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:533: TxByte(ucTimeOutMSB);
	ld	a, -17 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:534: TxByte(ucTimeOutLSB);
	ld	a, -8 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00161$:
;src\CFGESP.c:537: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	Z,00174$
;src\CFGESP.c:538: bResponse = WaitForRXData(scanResponse,2,60,true,false,NULL,0);
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
	ld	-59 (ix), l
	jp	00175$
00174$:
;src\CFGESP.c:539: else if (ucNagleOff)
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	Z,00171$
;src\CFGESP.c:540: bResponse = WaitForRXData(nagleoffResponse,2,60,true,false,NULL,0);
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
	ld	-59 (ix), l
	jp	00175$
00171$:
;src\CFGESP.c:541: else if (ucNagleOn)
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00168$
;src\CFGESP.c:542: bResponse = WaitForRXData(nagleonResponse,2,60,true,false,NULL,0);
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
	ld	-59 (ix), l
	jr	00175$
00168$:
;src\CFGESP.c:543: else if (ucRadioOff)
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	Z,00165$
;src\CFGESP.c:544: bResponse = WaitForRXData(radioOffResponse,2,60,true,false,NULL,0);
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
	ld	-59 (ix), l
	jr	00175$
00165$:
;src\CFGESP.c:545: else if (ucSetTimeout)
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jr	Z,00175$
;src\CFGESP.c:546: bResponse = WaitForRXData(responseRadioOnTimeout,2,60,true,false,NULL,0);
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
	ld	-59 (ix), l
00175$:
;src\CFGESP.c:549: if ((bResponse)&&(ucScan))
	ld	a, -59 (ix)
	or	a, a
	jp	Z, 00311$
	ld	iy, #_ucScan
	ld	a, 0 (iy)
	or	a, a
	jp	Z, 00311$
;src\CFGESP.c:552: do
	ld	c, #0x14
00178$:
;src\CFGESP.c:554: --ucRetries;
	dec	c
;src\CFGESP.c:555: for (ucHalt = 30;ucHalt>0;--ucHalt)
	ld	b, #0x1e
00417$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFGESP.c:555: for (ucHalt = 30;ucHalt>0;--ucHalt)
	ld	a, b
	dec	a
	ld	b, a
	or	a, a
	jr	NZ,00417$
;src\CFGESP.c:557: TxByte('s'); //Request SCAN result
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
;src\CFGESP.c:560: while ((ucRetries)&&(!bResponse));
	ld	a, c
	or	a, a
	jr	Z,00180$
	ld	a, l
	or	a, a
	jr	Z,00178$
00180$:
;src\CFGESP.c:562: if (bResponse==1)
	dec	l
	jp	NZ,00285$
;src\CFGESP.c:565: while(!UartRXData());
00181$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00181$
;src\CFGESP.c:566: ucAPs = GetUARTData();
	in	a, (_myPort6)
	ld	-4 (ix), a
;src\CFGESP.c:567: if (ucAPs>100)
	ld	a, #0x64
	sub	a, -4 (ix)
	jr	NC,00185$
;src\CFGESP.c:568: ucAPs=100;
	ld	-4 (ix), #0x64
00185$:
;src\CFGESP.c:570: printf ("\r\n");
	ld	hl, #___str_45
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:571: do
	ld	hl, #0x0396
	add	hl, sp
	ld	-53 (ix), l
	ld	-52 (ix), h
	ld	-2 (ix), #0x00
;src\CFGESP.c:576: while(!UartRXData());
00485$:
	ld	c, -2 (ix)
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
	add	a, -53 (ix)
	ld	c, a
	ld	a, d
	adc	a, -52 (ix)
	ld	b, a
	ld	e, #0x00
00186$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00186$
;src\CFGESP.c:577: rx_data=GetUARTData();
	in	a, (_myPort6)
	ld	-67 (ix), a
;src\CFGESP.c:578: stAP[tx_data].APName[ucIndex++]=rx_data;
	ld	l, e
	inc	e
	ld	h, #0x00
	add	hl, bc
	ld	a, -67 (ix)
	ld	(hl), a
;src\CFGESP.c:580: while(rx_data!=0);
	ld	a, -67 (ix)
	or	a, a
	jr	NZ,00186$
;src\CFGESP.c:581: while(!UartRXData());
00192$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00192$
;src\CFGESP.c:582: rx_data=GetUARTData();
	in	a, (_myPort6)
	ld	c, a
;src\CFGESP.c:583: stAP[tx_data].isEncrypted = (rx_data == 'E') ? 1 : 0;
	ld	e, -2 (ix)
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
	ld	a, -53 (ix)
	add	a, e
	ld	e, a
	ld	a, -52 (ix)
	adc	a, d
	ld	d, a
	ld	hl, #0x0021
	add	hl, de
	ld	-31 (ix), l
	ld	-30 (ix), h
	ld	a, c
	sub	a, #0x45
	jr	NZ,00435$
	ld	-49 (ix), #0x01
	ld	-48 (ix), #0x00
	jr	00436$
00435$:
	ld	-49 (ix), #0x00
	ld	-48 (ix), #0x00
00436$:
	ld	a, -49 (ix)
	ld	l, -31 (ix)
	ld	h, -30 (ix)
	ld	(hl), a
;src\CFGESP.c:584: ++tx_data;
	inc	-2 (ix)
;src\CFGESP.c:586: while (tx_data!=ucAPs);
	ld	a, -2 (ix)
	sub	a, -4 (ix)
	jp	NZ,00485$
;src\CFGESP.c:587: ClearUartData();
	ld	a, #0x14
	out	(_myPort6), a
;src\CFGESP.c:589: do
	ld	hl, #0x10fc
	add	hl, sp
	ld	-49 (ix), l
	ld	-48 (ix), h
	ld	a, -28 (ix)
	sub	a, #0x02
	ld	a, #0x00
	rla
	ld	-31 (ix), a
	ld	a, -16 (ix)
	sub	a, #0x01
	ld	a, #0x00
	rla
	ld	-67 (ix), a
	ld	-9 (ix), #0x00
00281$:
;src\CFGESP.c:591: printf("Choose AP:\r\n\n");
	ld	hl, #___str_47
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:593: ucIndex = scanPageLimit*ucScanPage;
	ld	a, -9 (ix)
	ld	c, a
	add	a, a
	add	a, a
	add	a, c
	add	a, a
	ld	-66 (ix), a
;src\CFGESP.c:595: if ((ucAPs-ucIndex)<=scanPageLimit)
	ld	a, -4 (ix)
	ld	-51 (ix), a
	ld	-50 (ix), #0x00
	ld	c, -66 (ix)
	ld	b, #0x00
	ld	a, -51 (ix)
	sub	a, c
	ld	c, a
	ld	a, -50 (ix)
	sbc	a, b
	ld	b, a
	ld	a, #0x0a
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	jp	PO, 01159$
	xor	a, #0x80
01159$:
	jp	M, 00199$
;src\CFGESP.c:596: ucPageCheck = ucAPs;
	ld	a, -4 (ix)
	ld	-19 (ix), a
	jr	00495$
00199$:
;src\CFGESP.c:598: ucPageCheck = ucIndex + scanPageLimit;
	ld	a, -66 (ix)
	ld	-58 (ix), a
	add	a, #0x0a
	ld	-19 (ix), a
00495$:
	ld	a, -66 (ix)
	ld	-58 (ix), a
00420$:
;src\CFGESP.c:600: for (;ucIndex<ucPageCheck;ucIndex++)
	ld	a, -58 (ix)
	sub	a, -19 (ix)
	jr	NC,00204$
;src\CFGESP.c:602: printf("%u - %s",(ucIndex%scanPageLimit),stAP[ucIndex].APName);
	ld	c, -58 (ix)
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
	ld	l, -53 (ix)
	ld	h, -52 (ix)
	add	hl, de
	ld	-57 (ix), l
	ld	-56 (ix), h
	ld	c, -58 (ix)
	ld	b, #0x00
	push	de
	ld	hl, #0x000a
	push	hl
	push	bc
	call	__modsint
	pop	af
	pop	af
	ld	c, -57 (ix)
	ld	b, -56 (ix)
	push	bc
	push	hl
	ld	hl, #___str_48
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
;src\CFGESP.c:603: if (stAP[ucIndex].isEncrypted)
	ld	l, -53 (ix)
	ld	h, -52 (ix)
	add	hl, de
	ld	de, #0x0021
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	Z,00202$
;src\CFGESP.c:604: printf(" (PWD)\r\n");
	ld	hl, #___str_50
	push	hl
	call	_puts
	pop	af
	jr	00421$
00202$:
;src\CFGESP.c:606: printf(" (OPEN)\r\n");
	ld	hl, #___str_52
	push	hl
	call	_puts
	pop	af
00421$:
;src\CFGESP.c:600: for (;ucIndex<ucPageCheck;ucIndex++)
	inc	-58 (ix)
	jr	00420$
00204$:
;src\CFGESP.c:609: if (ucAPs-ucIndex) // still APs left to list?
	ld	c, -58 (ix)
	ld	b, #0x00
	ld	a, -51 (ix)
	sub	a, c
	ld	-57 (ix), a
	ld	a, -50 (ix)
	sbc	a, b
	ld	-56 (ix), a
	or	a, -57 (ix)
	jr	Z,00206$
;src\CFGESP.c:610: printf("\r\nWhich one to connect? (ESC exit/SPACE BAR next page)");
	ld	hl, #___str_53
	push	hl
	call	_printf
	pop	af
	jr	00221$
00206$:
;src\CFGESP.c:612: printf("\r\nWhich one to connect? (ESC exit)");
	ld	hl, #___str_54
	push	hl
	call	_printf
	pop	af
;src\CFGESP.c:614: do
00221$:
;src\CFGESP.c:616: tx_data = Inkey ();
	call	_Inkey
	ld	c, l
;src\CFGESP.c:618: if (tx_data==0x1b)
;src\CFGESP.c:621: if ((tx_data==' ')&&(ucAPs-ucIndex))
	ld	a,c
	cp	a,#0x1b
	jr	Z,00223$
	sub	a, #0x20
	jr	NZ,00211$
	ld	a, -56 (ix)
	or	a, -57 (ix)
	jr	NZ,00223$
;src\CFGESP.c:622: break;
00211$:
;src\CFGESP.c:624: if ((tx_data>='0')&&(tx_data<='9'))
	ld	a, c
	sub	a, #0x30
	jr	C,00217$
	ld	a, #0x39
	sub	a, c
	jr	C,00217$
;src\CFGESP.c:626: if (((tx_data-'0')<scanPageLimit)&&(((scanPageLimit*ucScanPage)+(tx_data-'0'))<ucAPs))
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
	jr	NC,00217$
	ld	l, -9 (ix)
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
	sub	a, -51 (ix)
	ld	a, d
	sbc	a, -50 (ix)
	jp	PO, 01163$
	xor	a, #0x80
01163$:
	jp	M, 00223$
;src\CFGESP.c:627: break;
00217$:
;src\CFGESP.c:629: if (tx_data)
	ld	a, c
	or	a, a
	jr	Z,00221$
;src\CFGESP.c:630: Beep();
	call	_Beep
;src\CFGESP.c:632: while (1);
	jr	00221$
00223$:
;src\CFGESP.c:634: if ((tx_data!=0x1b)&&(tx_data!=' ')) // AP Choosen?
	ld	a,c
	cp	a,#0x1b
	jp	Z,00278$
	sub	a, #0x20
	jp	Z,00278$
;src\CFGESP.c:637: printf(" %c\r\n\n",tx_data); // Print accepted char
	ld	e, c
	ld	d, #0x00
	push	bc
	push	de
	ld	hl, #___str_55
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	bc
;src\CFGESP.c:638: ucIndex = (scanPageLimit*ucScanPage) + (tx_data-'0');
	ld	a, -39 (ix)
	ld	e, a
	add	a, a
	add	a, a
	add	a, e
	add	a, a
	ld	e, a
	ld	a, c
	add	a, #0xd0
	add	a, e
;src\CFGESP.c:639: if (stAP[ucIndex].isEncrypted)
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
	ld	-57 (ix), l
	ld	-56 (ix), h
	ld	a, -53 (ix)
	add	a, -57 (ix)
	ld	c, a
	ld	a, -52 (ix)
	adc	a, -56 (ix)
	ld	b, a
	ld	hl, #0x0021
	add	hl, bc
	ld	-51 (ix), l
	ld	-50 (ix), h
	ld	a, (hl)
	or	a, a
	jr	Z,00225$
;src\CFGESP.c:642: printf("Password? ");
	push	bc
	ld	hl, #___str_56
	push	hl
	call	_printf
	pop	af
	pop	bc
;src\CFGESP.c:643: InputString(ucPWD,64);
	ld	hl, #0x1250
	add	hl, sp
	push	bc
	ld	de, #0x0040
	push	de
	push	hl
	call	_InputString
	pop	af
	ld	hl, #___str_45
	ex	(sp),hl
	call	_puts
	pop	af
	pop	bc
00225$:
;src\CFGESP.c:647: printf("Connecting to: %s \r\n",stAP[ucIndex].APName);
	ld	e, c
	ld	d, b
	push	bc
	push	de
	ld	hl, #___str_58
	push	hl
	call	_printf
	pop	af
	pop	af
	call	_strlen
	pop	af
	inc	hl
	ld	c,l
	ld	b,h
;src\CFGESP.c:650: if (stAP[ucIndex].isEncrypted)
	ld	l, -51 (ix)
	ld	h, -50 (ix)
	ld	a, (hl)
	or	a, a
	jr	Z,00227$
;src\CFGESP.c:651: uiCMDLen += strlen(ucPWD);
	ld	hl, #0x1250
	add	hl, sp
	push	bc
	push	hl
	call	_strlen
	pop	af
	pop	bc
	add	hl, bc
	ld	c, l
	ld	b, h
00227$:
;src\CFGESP.c:652: TxByte('A'); //Request connect AP
	push	bc
	ld	a, #0x41
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFGESP.c:653: TxByte((unsigned char)((uiCMDLen&0xff00)>>8));
	ld	a, b
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFGESP.c:654: TxByte((unsigned char)(uiCMDLen&0xff));
	ld	d, c
	push	bc
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFGESP.c:656: do
	ld	a, -57 (ix)
	add	a, -53 (ix)
	ld	-57 (ix), a
	ld	a, -56 (ix)
	adc	a, -52 (ix)
	ld	-56 (ix), a
	ld	-1 (ix), #0x00
00229$:
;src\CFGESP.c:658: tx_data = stAP[ucIndex].APName[rx_data];
	ld	a, -57 (ix)
	add	a, -1 (ix)
	ld	e, a
	ld	a, -56 (ix)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
	ld	d, a
;src\CFGESP.c:659: TxByte(tx_data);
	push	bc
	push	de
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	de
	pop	bc
;src\CFGESP.c:660: --uiCMDLen;
	dec	bc
;src\CFGESP.c:661: ++rx_data;
	inc	-1 (ix)
;src\CFGESP.c:663: while((uiCMDLen)&&(tx_data!=0));
	ld	a, b
	or	a, c
	jr	Z,00231$
	ld	a, d
	or	a, a
	jr	NZ,00229$
00231$:
;src\CFGESP.c:664: if(uiCMDLen)
	ld	a, b
	or	a, c
	jr	Z,00236$
;src\CFGESP.c:667: do
	ld	hl, #0x1250
	add	hl, sp
	ld	-57 (ix), l
	ld	-56 (ix), h
	ld	-1 (ix), #0x00
00232$:
;src\CFGESP.c:669: tx_data = ucPWD[rx_data];
	ld	a, -57 (ix)
	add	a, -1 (ix)
	ld	e, a
	ld	a, -56 (ix)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
;src\CFGESP.c:670: TxByte(tx_data);
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFGESP.c:671: --uiCMDLen;
	dec	bc
;src\CFGESP.c:672: ++rx_data;
	inc	-1 (ix)
;src\CFGESP.c:674: while(uiCMDLen);
	ld	a, b
	or	a, c
	jr	NZ,00232$
00236$:
;src\CFGESP.c:678: bResponse = WaitForRXData(apconfigurationResponse,2,600,true,false,NULL,0); //Wait up to 10s
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
;src\CFGESP.c:679: if (bResponse)
	or	a, a
	jr	Z,00258$
;src\CFGESP.c:680: printf("Success, AP configured to be used.\r\n");
	ld	hl, #___str_60
	push	hl
	call	_puts
	pop	af
	jp	00413$
00258$:
;src\CFGESP.c:683: if ((ucVerMajor>=1)&&(ucVerMinor>=2)) // new firmware allow get current ap and connection status
	bit	0, -67 (ix)
	jp	NZ, 00254$
	bit	0, -31 (ix)
	jp	NZ, 00254$
;src\CFGESP.c:685: for (i=90;i>0;--i)
	ld	bc, #0x005a
00422$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFGESP.c:685: for (i=90;i>0;--i)
	dec	bc
	ld	a, b
	or	a, c
	jr	NZ,00422$
;src\CFGESP.c:687: TxByte('g'); //Request current AP status
	ld	a, #0x67
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:688: bResponse = WaitForRXData(apstsResponse,3,120,true,false,NULL,0);
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
;src\CFGESP.c:689: if (bResponse)
	or	a, a
	jr	Z,00251$
;src\CFGESP.c:691: while(!UartRXData());
00238$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00238$
;src\CFGESP.c:692: ucAPstsRspSize=GetUARTData();
	in	a, (_myPort6)
	ld	-18 (ix), a
;src\CFGESP.c:696: while(!UartRXData());
	ld	e, -49 (ix)
	ld	d, -48 (ix)
	ld	-11 (ix), #0x00
	ld	-10 (ix), #0x00
00241$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00241$
;src\CFGESP.c:697: chAPStsInfo[i]=GetUARTData();
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	add	hl, de
	in	a, (_myPort6)
	ld	(hl), a
;src\CFGESP.c:698: ++i;
	inc	-11 (ix)
	jr	NZ,01166$
	inc	-10 (ix)
01166$:
;src\CFGESP.c:700: while(i<ucAPstsRspSize);
	ld	c, -18 (ix)
	ld	b, #0x00
	ld	a, -11 (ix)
	sub	a, c
	ld	a, -10 (ix)
	sbc	a, b
	jr	C,00241$
;src\CFGESP.c:702: if (chAPStsInfo[0]==2)
	ld	a, (de)
	sub	a, #0x02
	jr	NZ,00248$
;src\CFGESP.c:703: printf("Error, wrong password!\r\n");
	ld	hl, #___str_62
	push	hl
	call	_puts
	pop	af
	jp	00413$
00248$:
;src\CFGESP.c:705: printf("Error, if protected network, check password.\r\n");
	ld	hl, #___str_64
	push	hl
	call	_puts
	pop	af
	jp	00413$
00251$:
;src\CFGESP.c:708: printf("Error, if protected network, check password.\r\n");
	ld	hl, #___str_64
	push	hl
	call	_puts
	pop	af
	jp	00413$
00254$:
;src\CFGESP.c:711: printf("Error, if protected network, check password.\r\n");
	ld	hl, #___str_64
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:714: break;
	jp	00413$
00278$:
;src\CFGESP.c:716: else if (tx_data==0x1b)
	ld	a, c
	sub	a, #0x1b
	jr	NZ,00275$
;src\CFGESP.c:718: printf("\r\nUser canceled by ESC key...\r\n");
	ld	hl, #___str_68
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:719: break;
	jp	00413$
00275$:
;src\CFGESP.c:723: if ((ucVerMajor>=1)&&(ucVerMinor>=2)) // new firmware allow get current ap and connection status
	bit	0, -67 (ix)
	jr	NZ,00272$
	bit	0, -31 (ix)
	jr	NZ,00272$
;src\CFGESP.c:725: TxByte('g'); //Request current AP status
	ld	a, #0x67
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:726: bResponse = WaitForRXData(apstsResponse,3,30,true,false,NULL,0);
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
;src\CFGESP.c:727: if (bResponse)
	or	a, a
	jr	Z,00272$
;src\CFGESP.c:729: while(!UartRXData());
00260$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00260$
;src\CFGESP.c:730: ucAPstsRspSize=GetUARTData();
	in	a, (_myPort6)
	ld	-57 (ix), a
;src\CFGESP.c:734: while(!UartRXData());
	ld	de, #0x0000
00263$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00263$
;src\CFGESP.c:735: chAPStsInfo[i]=GetUARTData();
	ld	l, -49 (ix)
	ld	h, -48 (ix)
	add	hl, de
	in	a, (_myPort6)
	ld	(hl), a
;src\CFGESP.c:736: ++i;
	inc	de
;src\CFGESP.c:738: while(i<ucAPstsRspSize);
	ld	c, -57 (ix)
	ld	b, #0x00
	ld	a, e
	sub	a, c
	ld	a, d
	sbc	a, b
	jr	C,00263$
00272$:
;src\CFGESP.c:741: ++ucScanPage;
	inc	-9 (ix)
	ld	a, -9 (ix)
	ld	-39 (ix), a
;src\CFGESP.c:744: while(1);
	jp	00281$
00285$:
;src\CFGESP.c:747: printf("\r\nScan results: no answer...\r\n");
	ld	hl, #___str_70
	push	hl
	call	_puts
	pop	af
	jp	00413$
00311$:
;src\CFGESP.c:751: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	Z,00308$
;src\CFGESP.c:752: printf ("\rScan request: no answer...\r\n");
	ld	hl, #___str_72
	push	hl
	call	_puts
	pop	af
	jp	00413$
00308$:
;src\CFGESP.c:753: else if (((ucNagleOff)||(ucNagleOn))&&(bResponse))
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00306$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00303$
00306$:
	ld	a, -59 (ix)
	or	a, a
	jr	Z,00303$
;src\CFGESP.c:755: printf("\rNagle set as requested...\r\n");
	ld	hl, #___str_74
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:756: return 0;
	ld	hl, #0x0000
	jp	00431$
00303$:
;src\CFGESP.c:758: else if ((ucNagleOff)||(ucNagleOn))
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00298$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00299$
00298$:
;src\CFGESP.c:760: printf("\rNagle not set as requested, error!\r\n");
	ld	hl, #___str_76
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:761: return 0;
	ld	hl, #0x0000
	jp	00431$
00299$:
;src\CFGESP.c:763: else if (ucRadioOff)
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	Z,00296$
;src\CFGESP.c:765: if (bResponse)
	ld	a, -59 (ix)
	or	a, a
	jr	Z,00288$
;src\CFGESP.c:766: printf("\rRequested to turn off Wi-Fi Radio...\r\n");
	ld	hl, #___str_78
	push	hl
	call	_puts
	pop	af
	jr	00289$
00288$:
;src\CFGESP.c:768: printf("\rRequest to turnoff Wi-Fi Radio error!\r\n");
	ld	hl, #___str_80
	push	hl
	call	_puts
	pop	af
00289$:
;src\CFGESP.c:769: return 0;
	ld	hl, #0x0000
	jp	00431$
00296$:
;src\CFGESP.c:771: else if (ucSetTimeout)
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jp	Z, 00413$
;src\CFGESP.c:773: if (bResponse)
	ld	a, -59 (ix)
	or	a, a
	jr	Z,00291$
;src\CFGESP.c:774: printf("\rWi-Fi radio on Time-out set successfully...\r\n");
	ld	hl, #___str_82
	push	hl
	call	_puts
	pop	af
	jr	00292$
00291$:
;src\CFGESP.c:776: printf("\rError setting Wi-Fi radio on Time-out!\r\n");
	ld	hl, #___str_84
	push	hl
	call	_puts
	pop	af
00292$:
;src\CFGESP.c:777: return 0;
	ld	hl, #0x0000
	jp	00431$
00402$:
;src\CFGESP.c:781: else if (ucLocalUpdate)
	ld	a,(#_ucLocalUpdate + 0)
	or	a, a
	jp	Z, 00399$
;src\CFGESP.c:784: iFile = Open (ucFile,O_RDONLY);
	ld	c, -47 (ix)
	ld	b, -46 (ix)
	ld	hl, #0x0000
	push	hl
	push	bc
	call	_Open
	pop	af
	pop	af
	ld	-57 (ix), l
	ld	-56 (ix), h
;src\CFGESP.c:786: if (iFile!=-1)
	ld	a, -57 (ix)
	inc	a
	jr	NZ,01171$
	ld	a, -56 (ix)
	inc	a
	jp	Z,00372$
01171$:
;src\CFGESP.c:793: regs.Words.HL = 0; //set pointer as 0
	ld	hl, #0x012c
	add	hl, sp
	ex	de, hl
	ld	hl, #0x0006
	add	hl, de
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;src\CFGESP.c:794: regs.Words.DE = 0; //so it will return the position
	ld	hl, #0x0004
	add	hl, de
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;src\CFGESP.c:795: regs.Bytes.A = 2; //relative to the end of file, i.e.:file size
	ld	hl, #0x012c
	add	hl, sp
	ex	de, hl
	ld	l, e
	ld	h, d
	inc	hl
	ld	(hl), #0x02
;src\CFGESP.c:796: regs.Bytes.B = (unsigned char)(iFile&0xff);
	inc	de
	inc	de
	inc	de
	ld	h, d
	ld	a, -57 (ix)
	ld	l, e
	ld	(hl), a
;src\CFGESP.c:797: DosCall(0x4A, &regs, REGS_ALL, REGS_ALL); // MOVE FILE HANDLER
	ld	hl, #0x012c
	add	hl, sp
	ld	-51 (ix), l
	ld	-50 (ix), h
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
;src\CFGESP.c:798: if (regs.Bytes.A == 0) //moved, now get the file handler position, i.e.: size
	ld	l, -51 (ix)
	ld	h, -50 (ix)
	inc	hl
	ld	a, (hl)
	ld	-58 (ix), a
	or	a, a
	jp	NZ, 00315$
;src\CFGESP.c:799: SentFileSize = (unsigned long)(regs.Words.HL)&0xffff | ((unsigned long)(regs.Words.DE)<<16)&0xffff0000;
	ld	a, -51 (ix)
	ld	-49 (ix), a
	ld	a, -50 (ix)
	ld	-48 (ix), a
	ld	l, -49 (ix)
	ld	h, -48 (ix)
	ld	de, #0x0006
	add	hl, de
	ld	a, (hl)
	ld	-49 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-48 (ix), a
	ld	a, -49 (ix)
	ld	-39 (ix), a
	ld	a, -48 (ix)
	ld	-38 (ix), a
	rla
	sbc	a, a
	ld	-37 (ix), a
	ld	-36 (ix), a
	ld	a, -39 (ix)
	ld	-39 (ix), a
	ld	a, -38 (ix)
	ld	-38 (ix), a
	ld	-37 (ix), #0x00
	ld	-36 (ix), #0x00
	ld	l, -51 (ix)
	ld	h, -50 (ix)
	ld	de, #0x0004
	add	hl, de
	ld	a, (hl)
	ld	-51 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-50 (ix), a
	ld	a, -51 (ix)
	ld	-63 (ix), a
	ld	a, -50 (ix)
	ld	-62 (ix), a
	rla
	sbc	a, a
	ld	-61 (ix), a
	ld	-60 (ix), a
	ld	b, #0x10
01172$:
	sla	-63 (ix)
	rl	-62 (ix)
	rl	-61 (ix)
	rl	-60 (ix)
	djnz	01172$
	ld	bc, #0x0000
	ld	e, -61 (ix)
	ld	d, -60 (ix)
	ld	a, c
	or	a, -39 (ix)
	ld	c, a
	ld	a, b
	or	a, -38 (ix)
	ld	b, a
	ld	a, e
	or	a, -37 (ix)
	ld	e, a
	ld	a, d
	or	a, -36 (ix)
	ld	d, a
	ld	-15 (ix), c
	ld	-14 (ix), b
	ld	-13 (ix), e
	ld	-12 (ix), d
	jr	00316$
00315$:
;src\CFGESP.c:801: SentFileSize = 0;
	xor	a, a
	ld	-15 (ix), a
	ld	-14 (ix), a
	ld	-13 (ix), a
	ld	-12 (ix), a
00316$:
;src\CFGESP.c:803: ultostr(SentFileSize,chFileSize,10);
	ld	hl, #0x10de
	add	hl, sp
	ld	c, l
	ld	b, h
	push	hl
	ld	de, #0x000a
	push	de
	push	bc
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	push	hl
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	push	hl
	call	_ultostr
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
	ld	c, -57 (ix)
	ld	b, -56 (ix)
	push	bc
	call	_Close
	pop	af
	pop	hl
;src\CFGESP.c:805: printf ("File: %s Size: %s \r\n",ucFile,chFileSize);
	ld	c, -47 (ix)
	ld	b, -46 (ix)
	ld	de, #___str_85+0
	push	hl
	push	bc
	push	de
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;src\CFGESP.c:807: if ((ucESP32) && (ucIsFw))
	ld	a, -29 (ix)
	or	a, a
	jp	Z, 00336$
	ld	iy, #_ucIsFw
	ld	a, 0 (iy)
	or	a, a
	jp	Z, 00336$
;src\CFGESP.c:809: strcpy(ucDatFile, ucFile);
	ld	hl, #0x1124
	add	hl, sp
	ld	-63 (ix), l
	ld	-62 (ix), h
	ld	a, -63 (ix)
	ld	-57 (ix), a
	ld	a, -62 (ix)
	ld	-56 (ix), a
	ld	a, -47 (ix)
	ld	-51 (ix), a
	ld	a, -46 (ix)
	ld	-50 (ix), a
	ld	e, -57 (ix)
	ld	d, -56 (ix)
	ld	l, -51 (ix)
	ld	h, -50 (ix)
	xor	a, a
01174$:
	cp	a, (hl)
	ldi
	jr	NZ, 01174$
;src\CFGESP.c:810: for (i = 0; i < sizeof(ucDatFile);++i)
	ld	-65 (ix), #0x00
	ld	-64 (ix), #0x00
	ld	-11 (ix), #0x00
	ld	-10 (ix), #0x00
00427$:
;src\CFGESP.c:812: if (ucDatFile[i] == 0x00)
	ld	a, -63 (ix)
	add	a, -11 (ix)
	ld	c, a
	ld	a, -62 (ix)
	adc	a, -10 (ix)
	ld	b, a
	ld	a, (bc)
	ld	-57 (ix), a
	or	a, a
	jr	NZ,00318$
;src\CFGESP.c:814: printf("DAT File naming error, ESP32 FW update most likely to not work...\r\n");
	ld	hl, #___str_87
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:815: break;
	jp	00336$
00318$:
;src\CFGESP.c:817: if ((ucDatFile[i] == '.') && (i < (sizeof(ucDatFile)-4)))
	ld	a, -57 (ix)
	sub	a, #0x2e
	jp	NZ,00428$
	ld	a, -11 (ix)
	sub	a, #0x28
	ld	a, -10 (ix)
	sbc	a, #0x01
	jp	NC, 00428$
;src\CFGESP.c:819: ucDatFile[i+1]='d';
	ld	c, -65 (ix)
	ld	b, -64 (ix)
	inc	bc
	ld	l, -63 (ix)
	ld	h, -62 (ix)
	add	hl, bc
	ld	(hl), #0x64
;src\CFGESP.c:820: ucDatFile[i+2]='a';
	ld	c, -65 (ix)
	ld	b, -64 (ix)
	inc	bc
	inc	bc
	ld	l, -63 (ix)
	ld	h, -62 (ix)
	add	hl, bc
	ld	(hl), #0x61
;src\CFGESP.c:821: ucDatFile[i+3]='t';
	ld	c, -65 (ix)
	ld	b, -64 (ix)
	inc	bc
	inc	bc
	inc	bc
	ld	l, -63 (ix)
	ld	h, -62 (ix)
	add	hl, bc
	ld	(hl), #0x74
;src\CFGESP.c:822: ucDatFile[i+4]=0x00;
	ld	a, -65 (ix)
	add	a, #0x04
	ld	c, a
	ld	a, -64 (ix)
	adc	a, #0x00
	ld	b, a
	ld	l, -63 (ix)
	ld	h, -62 (ix)
	add	hl, bc
	ld	(hl), #0x00
;src\CFGESP.c:823: printf ("ESP32, trying to open %s file to confirm firmware type...\r\n", ucDatFile);
	ld	a, -63 (ix)
	ld	-57 (ix), a
	ld	a, -62 (ix)
	ld	-56 (ix), a
	ld	l, -57 (ix)
	ld	h, -56 (ix)
	push	hl
	ld	hl, #___str_88
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFGESP.c:824: iFileDat = Open (ucDatFile,O_RDONLY);
	ld	c, -63 (ix)
	ld	b, -62 (ix)
	ld	hl, #0x0000
	push	hl
	push	bc
	call	_Open
	pop	af
	pop	af
	ld	-7 (ix), l
	ld	-6 (ix), h
;src\CFGESP.c:826: if (iFileDat!=-1)
	ld	a, -7 (ix)
	inc	a
	jr	NZ,01177$
	ld	a, -6 (ix)
	inc	a
	jp	Z,00329$
01177$:
;src\CFGESP.c:828: FileRead = MyRead(iFileDat, ucServer,24); //try to read up to 24 bytes of data
	ld	c, -55 (ix)
	ld	b, -54 (ix)
	ld	hl, #0x0018
	push	hl
	push	bc
	ld	l, -7 (ix)
	ld	h, -6 (ix)
	push	hl
	call	_MyRead
	pop	af
	pop	af
	pop	af
	ld	-57 (ix), l
	ld	-56 (ix), h
;src\CFGESP.c:829: if (FileRead > 5)
	ld	a, #0x05
	cp	a, -57 (ix)
	ld	a, #0x00
	sbc	a, -56 (ix)
	jp	NC, 00326$
;src\CFGESP.c:831: if (ucServer[FileRead-1] != 0x00)
	ld	a, -57 (ix)
	add	a, #0xff
	ld	-51 (ix), a
	ld	a, -56 (ix)
	adc	a, #0xff
	ld	-50 (ix), a
	ld	a, -51 (ix)
	add	a, -55 (ix)
	ld	-51 (ix), a
	ld	a, -50 (ix)
	adc	a, -54 (ix)
	ld	-50 (ix), a
	ld	l, -51 (ix)
	ld	h, -50 (ix)
	ld	a, (hl)
	or	a, a
	jr	Z,00320$
;src\CFGESP.c:833: ucServer[FileRead] = 0x00;
	ld	a, -55 (ix)
	add	a, -57 (ix)
	ld	c, a
	ld	a, -54 (ix)
	adc	a, -56 (ix)
	ld	b, a
	xor	a, a
	ld	(bc), a
;src\CFGESP.c:834: FileRead++;
	inc	-57 (ix)
	jr	NZ,01178$
	inc	-56 (ix)
01178$:
00320$:
;src\CFGESP.c:837: TxByte('B'); //Request to validate firmware type
	ld	a, #0x42
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:838: TxByte((unsigned char)((FileRead&0xff00)>>8));
	ld	b, -56 (ix)
	ld	c, #0x00
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:839: TxByte((unsigned char)(FileRead&0xff));
	ld	b, -57 (ix)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:840: for (i = 0; i < FileRead; ++i)
	ld	bc, #0x0000
00425$:
	ld	a, c
	sub	a, -57 (ix)
	ld	a, b
	sbc	a, -56 (ix)
	jr	NC,00586$
;src\CFGESP.c:841: TxByte(ucServer[i]);
	ld	l, -55 (ix)
	ld	h, -54 (ix)
	add	hl, bc
	ld	d, (hl)
	push	bc
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFGESP.c:840: for (i = 0; i < FileRead; ++i)
	inc	bc
	jr	00425$
00586$:
	ld	-65 (ix), c
	ld	-64 (ix), b
;src\CFGESP.c:843: bResponse = WaitForRXData(sendChipTypeResponse,2,60,true,false,NULL,0);
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
	ld	hl, #_sendChipTypeResponse
	push	hl
	call	_WaitForRXData
	ld	iy, #12
	add	iy, sp
	ld	sp, iy
	ld	a, l
;src\CFGESP.c:844: if (!bResponse)
	or	a, a
	jr	NZ,00323$
;src\CFGESP.c:845: printf("Firmware File not correct, ESP32 FW not go on and fail on Z command...\r\n");
	ld	hl, #___str_90
	push	hl
	call	_puts
	pop	af
	jr	00327$
00323$:
;src\CFGESP.c:847: printf("Firmware type correct, will proceed sending it!\r\n");
	ld	hl, #___str_92
	push	hl
	call	_puts
	pop	af
	jr	00327$
00326$:
;src\CFGESP.c:850: printf("DAT File not valid, ESP32 FW update most likely to not work...\r\n");
	ld	hl, #___str_94
	push	hl
	call	_puts
	pop	af
00327$:
;src\CFGESP.c:851: Close(iFileDat);
	ld	l, -7 (ix)
	ld	h, -6 (ix)
	push	hl
	call	_Close
	pop	af
	jr	00336$
00329$:
;src\CFGESP.c:854: printf("DAT File not found, ESP32 FW update most likely to not work...\r\n");
	ld	hl, #___str_96
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:855: break;
	jr	00336$
00428$:
;src\CFGESP.c:810: for (i = 0; i < sizeof(ucDatFile);++i)
	inc	-11 (ix)
	jr	NZ,01179$
	inc	-10 (ix)
01179$:
	ld	a, -11 (ix)
	ld	-65 (ix), a
	ld	a, -10 (ix)
	ld	-64 (ix), a
	ld	a, -11 (ix)
	sub	a, #0x2c
	ld	a, -10 (ix)
	sbc	a, #0x01
	jp	C, 00427$
00336$:
;src\CFGESP.c:859: if (SentFileSize)
	ld	a, -12 (ix)
	or	a, -13 (ix)
	or	a, -14 (ix)
	or	a, -15 (ix)
	jp	Z, 00369$
;src\CFGESP.c:861: iFile = Open (ucFile,O_RDONLY);
	ld	c, -47 (ix)
	ld	b, -46 (ix)
	ld	hl, #0x0000
	push	hl
	push	bc
	call	_Open
	pop	af
	pop	af
	ld	-27 (ix), l
	ld	-26 (ix), h
;src\CFGESP.c:862: if (iFile!=-1)
	ld	a, -27 (ix)
	inc	a
	jr	NZ,01180$
	ld	a, -26 (ix)
	inc	a
	jp	Z,00366$
01180$:
;src\CFGESP.c:864: FileRead = MyRead(iFile, ucServer,256); //try to read 256 bytes of data
	ld	c, -55 (ix)
	ld	b, -54 (ix)
	ld	hl, #0x0100
	push	hl
	push	bc
	ld	l, -27 (ix)
	ld	h, -26 (ix)
	push	hl
	call	_MyRead
	pop	af
	pop	af
	pop	af
	ld	-23 (ix), l
	ld	-22 (ix), h
;src\CFGESP.c:865: if (FileRead == 256)
	ld	a, -23 (ix)
	or	a, a
	jp	NZ,00363$
	ld	a, -22 (ix)
	dec	a
	jp	NZ,00363$
;src\CFGESP.c:868: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00339$
;src\CFGESP.c:869: TxByte('Z'); //Request start of RS232 update
	ld	a, #0x5a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00340$
00339$:
;src\CFGESP.c:871: TxByte('Y'); //Request start of RS232 cert update
	ld	a, #0x59
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00340$:
;src\CFGESP.c:872: TxByte(0);
	xor	a, a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:873: TxByte(12);
	ld	a, #0x0c
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:874: TxByte((unsigned char)(SentFileSize&0xff));
	ld	b, -15 (ix)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:875: TxByte((unsigned char)((SentFileSize&0xff00)>>8));
	ld	b, -14 (ix)
	ld	c, #0x00
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:876: TxByte((unsigned char)((SentFileSize&0xff0000)>>16));
	ld	c, -13 (ix)
	ld	b, c
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:877: TxByte((unsigned char)((SentFileSize&0xff000000)>>24));
	ld	c, -12 (ix)
	ld	b, c
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:878: TxByte((unsigned char)((SentFileSize&0xff00000000)>>32));
	ld	a, -15 (ix)
	ld	-47 (ix), a
	ld	a, -14 (ix)
	ld	-46 (ix), a
	ld	a, -13 (ix)
	ld	-45 (ix), a
	ld	a, -12 (ix)
	ld	-44 (ix), a
	ld	-43 (ix), #0x00
	ld	-42 (ix), #0x00
	ld	-41 (ix), #0x00
	ld	-40 (ix), #0x00
	ld	-39 (ix), #0x00
	ld	-38 (ix), #0x00
	ld	-37 (ix), #0x00
	ld	-36 (ix), #0x00
	ld	a, -43 (ix)
	ld	-35 (ix), a
	ld	-34 (ix), #0x00
	ld	-33 (ix), #0x00
	ld	-32 (ix), #0x00
	ld	b, #0x20
01187$:
	sra	-32 (ix)
	rr	-33 (ix)
	rr	-34 (ix)
	rr	-35 (ix)
	rr	-36 (ix)
	rr	-37 (ix)
	rr	-38 (ix)
	rr	-39 (ix)
	djnz	01187$
	ld	b, -39 (ix)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:879: TxByte((unsigned char)((SentFileSize&0xff0000000000)>>40));
	ld	-39 (ix), #0x00
	ld	-38 (ix), #0x00
	ld	-37 (ix), #0x00
	ld	-36 (ix), #0x00
	ld	-35 (ix), #0x00
	ld	a, -42 (ix)
	ld	-34 (ix), a
	ld	-33 (ix), #0x00
	ld	-32 (ix), #0x00
	ld	b, #0x28
01189$:
	sra	-32 (ix)
	rr	-33 (ix)
	rr	-34 (ix)
	rr	-35 (ix)
	rr	-36 (ix)
	rr	-37 (ix)
	rr	-38 (ix)
	rr	-39 (ix)
	djnz	01189$
	ld	b, -39 (ix)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:880: TxByte((unsigned char)((SentFileSize&0xff000000000000)>>48));
	ld	-39 (ix), #0x00
	ld	-38 (ix), #0x00
	ld	-37 (ix), #0x00
	ld	-36 (ix), #0x00
	ld	-35 (ix), #0x00
	ld	-34 (ix), #0x00
	ld	a, -41 (ix)
	ld	-33 (ix), a
	ld	-32 (ix), #0x00
	ld	b, #0x30
01191$:
	sra	-32 (ix)
	rr	-33 (ix)
	rr	-34 (ix)
	rr	-35 (ix)
	rr	-36 (ix)
	rr	-37 (ix)
	rr	-38 (ix)
	rr	-39 (ix)
	djnz	01191$
	ld	b, -39 (ix)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:881: TxByte((unsigned char)((SentFileSize&0xff00000000000000)>>56));
	ld	a, -15 (ix)
	ld	-39 (ix), a
	ld	a, -14 (ix)
	ld	-38 (ix), a
	ld	a, -13 (ix)
	ld	-37 (ix), a
	ld	a, -12 (ix)
	ld	-36 (ix), a
	ld	-35 (ix), #0x00
	ld	-34 (ix), #0x00
	ld	-33 (ix), #0x00
	ld	-32 (ix), #0x00
	ld	-39 (ix), #0x00
	ld	-38 (ix), #0x00
	ld	-37 (ix), #0x00
	ld	-36 (ix), #0x00
	ld	-35 (ix), #0x00
	ld	-34 (ix), #0x00
	ld	-33 (ix), #0x00
	ld	a, -32 (ix)
	ld	-32 (ix), a
	ld	b, #0x38
01193$:
	srl	-32 (ix)
	rr	-33 (ix)
	rr	-34 (ix)
	rr	-35 (ix)
	rr	-36 (ix)
	rr	-37 (ix)
	rr	-38 (ix)
	rr	-39 (ix)
	djnz	01193$
	ld	b, -39 (ix)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:882: TxByte(ucServer[0]);
	ld	l, -55 (ix)
	ld	h, -54 (ix)
	ld	b, (hl)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:883: TxByte(ucServer[1]);
	ld	l, -55 (ix)
	ld	h, -54 (ix)
	inc	hl
	ld	b, (hl)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:884: TxByte(ucServer[2]);
	ld	l, -55 (ix)
	ld	h, -54 (ix)
	inc	hl
	inc	hl
	ld	b, (hl)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:885: TxByte(ucServer[3]);
	ld	l, -55 (ix)
	ld	h, -54 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	b, (hl)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:887: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00342$
;src\CFGESP.c:888: bResponse = WaitForRXData(responseRSFWUpdate,2,60,true,false,NULL,0);
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
	ld	-63 (ix), l
	jr	00343$
00342$:
;src\CFGESP.c:890: bResponse = WaitForRXData(responseRSCERTUpdate,2,60,true,false,NULL,0);
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
	ld	-63 (ix), l
00343$:
;src\CFGESP.c:892: if (!bResponse)
	ld	a, -63 (ix)
	or	a, a
	jr	NZ,00360$
;src\CFGESP.c:893: printf("Error requesting to start firmware update.\r\n");
	ld	hl, #___str_98
	push	hl
	call	_puts
	pop	af
	jp	00364$
00360$:
;src\CFGESP.c:896: uiAnimationTimeOut = TickCount + 9;
	ld	iy, #_TickCount
	ld	a, 0 (iy)
	add	a, #0x09
	ld	-25 (ix), a
	ld	a, 1 (iy)
	adc	a, #0x00
	ld	-24 (ix), a
;src\CFGESP.c:897: do
	ld	a, -55 (ix)
	ld	-57 (ix), a
	ld	a, -54 (ix)
	ld	-56 (ix), a
	ld	a, -65 (ix)
	ld	-51 (ix), a
	ld	a, -64 (ix)
	ld	-50 (ix), a
00354$:
;src\CFGESP.c:899: --uiAnimationTimeOut;
	ld	l, -25 (ix)
	ld	h, -24 (ix)
	dec	hl
	ld	-25 (ix), l
	ld	-24 (ix), h
;src\CFGESP.c:900: if (TickCount>=uiAnimationTimeOut)
	ld	iy, #_TickCount
	ld	a, 0 (iy)
	sub	a, -25 (ix)
	ld	a, 1 (iy)
	sbc	a, -24 (ix)
	jr	C,00345$
;src\CFGESP.c:902: uiAnimationTimeOut = 9;
	ld	-25 (ix), #0x09
	ld	-24 (ix), #0x00
;src\CFGESP.c:904: printf("%s",advance[i%5]); // next animation step
	ld	hl, #0x0005
	push	hl
	ld	l, -51 (ix)
	ld	h, -50 (ix)
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
	ld	hl, #___str_99
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFGESP.c:905: ++i;
	inc	-51 (ix)
	jr	NZ,01195$
	inc	-50 (ix)
01195$:
00345$:
;src\CFGESP.c:907: if (!ucFirstBlock)
	ld	a, -5 (ix)
	or	a, a
	jr	NZ,00349$
;src\CFGESP.c:909: FileRead = MyRead(iFile, ucServer,256); //try to read 256 bytes of data
	ld	c, -57 (ix)
	ld	b, -56 (ix)
	ld	hl, #0x0100
	push	hl
	push	bc
	ld	l, -27 (ix)
	ld	h, -26 (ix)
	push	hl
	call	_MyRead
	pop	af
	pop	af
	pop	af
	ld	-23 (ix), l
;src\CFGESP.c:910: if (FileRead ==0)
	ld	-22 (ix), h
	ld	a, h
	or	a, -23 (ix)
	jr	NZ,00350$
;src\CFGESP.c:912: printf("\rError reading file...\r\n");
	ld	hl, #___str_101
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:913: break;
	jp	00356$
00349$:
;src\CFGESP.c:917: ucFirstBlock = 0;
	ld	-5 (ix), #0x00
00350$:
;src\CFGESP.c:919: TxByte('z'); //Write block
	ld	a, #0x7a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:920: TxByte((unsigned char)((FileRead&0xff00)>>8));
	ld	b, -22 (ix)
	ld	c, #0x00
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:921: TxByte((unsigned char)(FileRead&0xff));
	ld	b, -23 (ix)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:922: for (ii=0;ii<256;ii++)
	ld	bc, #0x0000
00429$:
;src\CFGESP.c:923: TxByte(ucServer[ii]);
	ld	l, -55 (ix)
	ld	h, -54 (ix)
	add	hl, bc
	ld	d, (hl)
	push	bc
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFGESP.c:922: for (ii=0;ii<256;ii++)
	inc	bc
	ld	a, b
	sub	a, #0x01
	jr	C,00429$
;src\CFGESP.c:925: bResponse = WaitForRXData(responseWRBlock,2,600,true,false,NULL,0);
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
;src\CFGESP.c:927: if (!bResponse)
	ld	-63 (ix), l
	ld	a, l
	or	a, a
	jr	NZ,00353$
;src\CFGESP.c:929: printf("\rError requesting to write firmware block.\r\n");
	ld	hl, #___str_103
	push	hl
	call	_puts
	pop	af
;src\CFGESP.c:930: break;
	jr	00356$
00353$:
;src\CFGESP.c:932: SentFileSize = SentFileSize - FileRead;
	ld	c, -23 (ix)
	ld	b, -22 (ix)
	ld	de, #0x0000
	ld	a, -15 (ix)
	sub	a, c
	ld	-15 (ix), a
	ld	a, -14 (ix)
	sbc	a, b
	ld	-14 (ix), a
	ld	a, -13 (ix)
	sbc	a, e
	ld	-13 (ix), a
	ld	a, -12 (ix)
	sbc	a, d
;src\CFGESP.c:934: while(SentFileSize);
	ld	-12 (ix), a
	or	a, -13 (ix)
	or	a, -14 (ix)
	or	a, -15 (ix)
	jp	NZ, 00354$
00356$:
;src\CFGESP.c:935: printf("%s",aDone);
	ld	hl, #_aDone
	push	hl
	ld	hl, #___str_99
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFGESP.c:938: if (bResponse)
	ld	a, -63 (ix)
	or	a, a
	jr	Z,00364$
;src\CFGESP.c:939: FinishUpdate(false);
	xor	a, a
	push	af
	inc	sp
	call	_FinishUpdate
	inc	sp
	jr	00364$
00363$:
;src\CFGESP.c:943: Print("\rError reading firmware file!\r\n");
	ld	hl, #___str_104
	push	hl
	call	_Print
	pop	af
00364$:
;src\CFGESP.c:944: Close(iFile);
	ld	l, -27 (ix)
	ld	h, -26 (ix)
	push	hl
	call	_Close
	pop	af
	jp	00413$
00366$:
;src\CFGESP.c:948: printf("Error, couldn't open %s ...\r\n",ucFile);
	ld	a, -47 (ix)
	ld	-63 (ix), a
	ld	a, -46 (ix)
	ld	-62 (ix), a
	ld	a, -63 (ix)
	ld	-63 (ix), a
	ld	a, -62 (ix)
	ld	-62 (ix), a
	ld	l, -63 (ix)
	ld	h, -62 (ix)
	push	hl
	ld	hl, #___str_105
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFGESP.c:949: return 0;
	ld	hl, #0x0000
	jp	00431$
00369$:
;src\CFGESP.c:954: printf("Error, %s is 0 bytes long...\r\n",ucFile);
	ld	a, -47 (ix)
	ld	-63 (ix), a
	ld	a, -46 (ix)
	ld	-62 (ix), a
	ld	a, -63 (ix)
	ld	-63 (ix), a
	ld	a, -62 (ix)
	ld	-62 (ix), a
	ld	l, -63 (ix)
	ld	h, -62 (ix)
	push	hl
	ld	hl, #___str_106
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFGESP.c:955: return 0;
	ld	hl, #0x0000
	jp	00431$
00372$:
;src\CFGESP.c:960: printf("Error, couldn't open %s ...\r\n",ucFile);
	ld	a, -47 (ix)
	ld	-63 (ix), a
	ld	a, -46 (ix)
	ld	-62 (ix), a
	ld	a, -63 (ix)
	ld	-63 (ix), a
	ld	a, -62 (ix)
	ld	-62 (ix), a
	ld	l, -63 (ix)
	ld	h, -62 (ix)
	push	hl
	ld	hl, #___str_105
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFGESP.c:961: return 0;
	ld	hl, #0x0000
	jp	00431$
00399$:
;src\CFGESP.c:966: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00375$
;src\CFGESP.c:967: printf ("Ok, updating FW using server: %s port: %u\r\nFile path: %s\nPlease Wait, it can take up to a few minutes!\r\n",ucServer,uiPort,ucFile);
	ld	e, -47 (ix)
	ld	d, -46 (ix)
	ld	c, -55 (ix)
	ld	b, -54 (ix)
	push	de
	ld	hl, (_uiPort)
	push	hl
	push	bc
	ld	hl, #___str_107
	push	hl
	call	_printf
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
	jr	00376$
00375$:
;src\CFGESP.c:969: printf ("Ok, updating certificates using server: %s port: %u\r\nFile path: %s\nPlease Wait, it can take up to a few minutes!\r\n",ucServer,uiPort,ucFile);
	ld	e, -47 (ix)
	ld	d, -46 (ix)
	ld	c, -55 (ix)
	ld	b, -54 (ix)
	push	de
	ld	hl, (_uiPort)
	push	hl
	push	bc
	ld	hl, #___str_108
	push	hl
	call	_printf
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
00376$:
;src\CFGESP.c:970: uiCMDLen = strlen(ucServer) + 3; //3 = 0 terminator + 2 bytes port
	ld	c, -55 (ix)
	ld	b, -54 (ix)
	push	bc
	call	_strlen
	pop	af
	ld	-62 (ix), h
	ld	-63 (ix), l
	ld	a, l
	add	a, #0x03
	ld	-21 (ix), a
	ld	a, -62 (ix)
	adc	a, #0x00
	ld	-20 (ix), a
;src\CFGESP.c:971: uiCMDLen += strlen(ucFile);
	ld	a, -47 (ix)
	ld	-63 (ix), a
	ld	a, -46 (ix)
	ld	-62 (ix), a
	ld	a, -63 (ix)
	ld	-63 (ix), a
	ld	a, -62 (ix)
	ld	-62 (ix), a
	ld	l, -63 (ix)
	ld	h, -62 (ix)
	push	hl
	call	_strlen
	pop	af
	ld	-62 (ix), h
	ld	-63 (ix), l
	ld	a, l
	add	a, -21 (ix)
	ld	-63 (ix), a
	ld	a, -62 (ix)
	adc	a, -20 (ix)
	ld	-62 (ix), a
;src\CFGESP.c:972: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00378$
;src\CFGESP.c:973: TxByte('U'); //Request Update Main Firmware remotely
	ld	a, #0x55
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00379$
00378$:
;src\CFGESP.c:975: TxByte('u'); //Request Update spiffs remotely
	ld	a, #0x75
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00379$:
;src\CFGESP.c:976: TxByte((unsigned char)((uiCMDLen&0xff00)>>8));
	ld	-57 (ix), #0x00
	ld	a, -62 (ix)
	ld	-56 (ix), a
	ld	-57 (ix), a
	ld	-56 (ix), #0x00
	ld	a, -57 (ix)
	ld	-57 (ix), a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:977: TxByte((unsigned char)(uiCMDLen&0xff));
	ld	b, -63 (ix)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:978: TxByte((unsigned char)(uiPort&0xff));
	ld	hl,#_uiPort + 0
	ld	b, (hl)
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:979: TxByte((unsigned char)((uiPort&0xff00)>>8));
	ld	-57 (ix), #0x00
	ld	a,(#_uiPort + 1)
	ld	-56 (ix), a
	ld	-57 (ix), a
	ld	-56 (ix), #0x00
	ld	a, -57 (ix)
	ld	-57 (ix), a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:981: do
	ld	c, -63 (ix)
	ld	b, -62 (ix)
	ld	-1 (ix), #0x00
00381$:
;src\CFGESP.c:983: tx_data = ucServer[rx_data];
	ld	a, -55 (ix)
	add	a, -1 (ix)
	ld	e, a
	ld	a, -54 (ix)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
	ld	d, a
;src\CFGESP.c:984: TxByte(tx_data);
	push	bc
	push	de
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	de
	pop	bc
;src\CFGESP.c:985: --uiCMDLen;
	dec	bc
;src\CFGESP.c:986: ++rx_data;
	inc	-1 (ix)
;src\CFGESP.c:988: while((uiCMDLen)&&(tx_data!=0));
	ld	a, b
	or	a, c
	jr	Z,00383$
	ld	a, d
	or	a, a
	jr	NZ,00381$
00383$:
;src\CFGESP.c:990: do
	ld	-21 (ix), c
	ld	-20 (ix), b
	ld	-1 (ix), #0x00
00386$:
;src\CFGESP.c:992: tx_data = ucFile[rx_data];
	ld	a, -47 (ix)
	add	a, -1 (ix)
	ld	-63 (ix), a
	ld	a, -46 (ix)
	adc	a, #0x00
	ld	-62 (ix), a
	ld	l, -63 (ix)
	ld	h, -62 (ix)
	ld	a, (hl)
;src\CFGESP.c:993: if (tx_data==0)
	or	a, a
	jr	Z,00388$
;src\CFGESP.c:995: TxByte(tx_data);
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFGESP.c:996: --uiCMDLen;
	ld	l, -21 (ix)
	ld	h, -20 (ix)
	dec	hl
	ld	-21 (ix), l
	ld	-20 (ix), h
;src\CFGESP.c:997: ++rx_data;
	inc	-1 (ix)
;src\CFGESP.c:999: while(uiCMDLen);
	ld	a, -20 (ix)
	or	a, -21 (ix)
	jr	NZ,00386$
00388$:
;src\CFGESP.c:1001: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00390$
;src\CFGESP.c:1002: bResponse = WaitForRXData(responseOTAFW,2,18000,true,false,NULL,0);
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
	jr	00391$
00390$:
;src\CFGESP.c:1004: bResponse = WaitForRXData(responseOTASPIFF,2,18000,true,false,NULL,0);
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
00391$:
;src\CFGESP.c:1006: if (bResponse)
	ld	a, c
	or	a, a
	jr	Z,00396$
;src\CFGESP.c:1008: if ((!ucIsFw))
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	NZ,00393$
;src\CFGESP.c:1009: printf("\rSuccess updating certificates!\r\n");
	ld	hl, #___str_110
	push	hl
	call	_puts
	pop	af
	jr	00394$
00393$:
;src\CFGESP.c:1011: printf("\rSuccess, firmware updated, wait a minute so it is fully flashed.\r\n");
	ld	hl, #___str_112
	push	hl
	call	_puts
	pop	af
00394$:
;src\CFGESP.c:1012: FinishUpdate(true);
	ld	a, #0x01
	push	af
	inc	sp
	call	_FinishUpdate
	inc	sp
;src\CFGESP.c:1013: return 0;
	ld	hl, #0x0000
	jr	00431$
00396$:
;src\CFGESP.c:1016: printf("\rFailed to update from remote server...\r\n");
	ld	hl, #___str_114
	push	hl
	call	_puts
	pop	af
	jr	00413$
00409$:
;src\CFGESP.c:1020: printf("ESP device not found...\r\n");
	ld	hl, #___str_116
	push	hl
	call	_puts
	pop	af
	jr	00413$
00412$:
;src\CFGESP.c:1023: printf(strUsage);
	ld	hl, #_strUsage
	push	hl
	call	_printf
	pop	af
00413$:
;src\CFGESP.c:1025: return 0;
	ld	hl, #0x0000
00431$:
;src\CFGESP.c:1026: }
	ld	sp, ix
	pop	ix
	ret
___str_31:
	.ascii "> SM-X ESP Wi-Fi Module Configuration v2.00 <"
	.db 0x0d
	.db 0x0a
	.ascii "(c) 2026 Oduvaldo Pavan Junior - ducasp@gmail.com"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_32:
	.ascii "Baud Rate: %s"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_33:
	.ascii "Chip Type: "
	.db 0x00
___str_34:
	.ascii "%s"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_36:
	.ascii "Chip Type: ESP8266"
	.db 0x0d
	.db 0x00
___str_37:
	.ascii "FW Version: %c.%c"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_38:
	.ascii "%s%s"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.db 0x00
___str_40:
	.ascii "Unknown status of AP!!!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_41:
	.db 0x0d
	.db 0x0a
	.ascii "Setting Wi-Fi idle timeout to %u..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_43:
	.db 0x0d
	.db 0x0a
	.ascii "Setting Wi-Fi to always on!"
	.db 0x0d
	.db 0x00
___str_45:
	.db 0x0d
	.db 0x00
___str_47:
	.ascii "Choose AP:"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_48:
	.ascii "%u - %s"
	.db 0x00
___str_50:
	.ascii " (PWD)"
	.db 0x0d
	.db 0x00
___str_52:
	.ascii " (OPEN)"
	.db 0x0d
	.db 0x00
___str_53:
	.db 0x0d
	.db 0x0a
	.ascii "Which one to connect? (ESC exit/SPACE BAR next page)"
	.db 0x00
___str_54:
	.db 0x0d
	.db 0x0a
	.ascii "Which one to connect? (ESC exit)"
	.db 0x00
___str_55:
	.ascii " %c"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.db 0x00
___str_56:
	.ascii "Password? "
	.db 0x00
___str_58:
	.ascii "Connecting to: %s "
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_60:
	.ascii "Success, AP configured to be used."
	.db 0x0d
	.db 0x00
___str_62:
	.ascii "Error, wrong password!"
	.db 0x0d
	.db 0x00
___str_64:
	.ascii "Error, if protected network, check password."
	.db 0x0d
	.db 0x00
___str_68:
	.db 0x0d
	.db 0x0a
	.ascii "User canceled by ESC key..."
	.db 0x0d
	.db 0x00
___str_70:
	.db 0x0d
	.db 0x0a
	.ascii "Scan results: no answer..."
	.db 0x0d
	.db 0x00
___str_72:
	.db 0x0d
	.ascii "Scan request: no answer..."
	.db 0x0d
	.db 0x00
___str_74:
	.db 0x0d
	.ascii "Nagle set as requested..."
	.db 0x0d
	.db 0x00
___str_76:
	.db 0x0d
	.ascii "Nagle not set as requested, error!"
	.db 0x0d
	.db 0x00
___str_78:
	.db 0x0d
	.ascii "Requested to turn off Wi-Fi Radio..."
	.db 0x0d
	.db 0x00
___str_80:
	.db 0x0d
	.ascii "Request to turnoff Wi-Fi Radio error!"
	.db 0x0d
	.db 0x00
___str_82:
	.db 0x0d
	.ascii "Wi-Fi radio on Time-out set successfully..."
	.db 0x0d
	.db 0x00
___str_84:
	.db 0x0d
	.ascii "Error setting Wi-Fi radio on Time-out!"
	.db 0x0d
	.db 0x00
___str_85:
	.ascii "File: %s Size: %s "
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_87:
	.ascii "DAT File naming error, ESP32 FW update most likely to not wo"
	.ascii "rk..."
	.db 0x0d
	.db 0x00
___str_88:
	.ascii "ESP32, trying to open %s file to confirm firmware type..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_90:
	.ascii "Firmware File not correct, ESP32 FW not go on and fail on Z "
	.ascii "command..."
	.db 0x0d
	.db 0x00
___str_92:
	.ascii "Firmware type correct, will proceed sending it!"
	.db 0x0d
	.db 0x00
___str_94:
	.ascii "DAT File not valid, ESP32 FW update most likely to not work."
	.ascii ".."
	.db 0x0d
	.db 0x00
___str_96:
	.ascii "DAT File not found, ESP32 FW update most likely to not work."
	.ascii ".."
	.db 0x0d
	.db 0x00
___str_98:
	.ascii "Error requesting to start firmware update."
	.db 0x0d
	.db 0x00
___str_99:
	.ascii "%s"
	.db 0x00
___str_101:
	.db 0x0d
	.ascii "Error reading file..."
	.db 0x0d
	.db 0x00
___str_103:
	.db 0x0d
	.ascii "Error requesting to write firmware block."
	.db 0x0d
	.db 0x00
___str_104:
	.db 0x0d
	.ascii "Error reading firmware file!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_105:
	.ascii "Error, couldn't open %s ..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_106:
	.ascii "Error, %s is 0 bytes long..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_107:
	.ascii "Ok, updating FW using server: %s port: %u"
	.db 0x0d
	.db 0x0a
	.ascii "File path: %s"
	.db 0x0a
	.ascii "Please Wait, it can take up to a few minutes!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_108:
	.ascii "Ok, updating certificates using server: %s port: %u"
	.db 0x0d
	.db 0x0a
	.ascii "File path: %s"
	.db 0x0a
	.ascii "Please Wait, it can take up to a few minutes!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_110:
	.db 0x0d
	.ascii "Success updating certificates!"
	.db 0x0d
	.db 0x00
___str_112:
	.db 0x0d
	.ascii "Success, firmware updated, wait a minute so it is fully flas"
	.ascii "hed."
	.db 0x0d
	.db 0x00
___str_114:
	.db 0x0d
	.ascii "Failed to update from remote server..."
	.db 0x0d
	.db 0x00
___str_116:
	.ascii "ESP device not found..."
	.db 0x0d
	.db 0x00
	.area _CODE
___str_117:
	.ascii "Wi-Fi is Idle, AP: "
	.db 0x00
___str_118:
	.ascii "Wi-Fi Connecting to AP: "
	.db 0x00
___str_119:
	.ascii "Wi-Fi Wrong Password for AP: "
	.db 0x00
___str_120:
	.ascii "Wi-Fi Did not find AP: "
	.db 0x00
___str_121:
	.ascii "Wi-Fi Failed to connect to: "
	.db 0x00
___str_122:
	.ascii "Wi-Fi Connected to: "
	.db 0x00
___str_123:
	.ascii "859372 bps"
	.db 0x00
___str_124:
	.ascii "346520 bps"
	.db 0x00
___str_125:
	.ascii "231014 bps"
	.db 0x00
___str_126:
	.ascii "115200 bps"
	.db 0x00
___str_127:
	.ascii "57600 bps"
	.db 0x00
___str_128:
	.ascii "38400 bps"
	.db 0x00
___str_129:
	.ascii "31250 bps"
	.db 0x00
___str_130:
	.ascii "19200 bps"
	.db 0x00
___str_131:
	.ascii "9600 bps"
	.db 0x00
___str_132:
	.ascii "4800 bps"
	.db 0x00
	.area _INITIALIZER
__xinit__strAPSts:
	.dw ___str_117
	.dw ___str_118
	.dw ___str_119
	.dw ___str_120
	.dw ___str_121
	.dw ___str_122
__xinit__speedStr:
	.dw ___str_123
	.dw ___str_124
	.dw ___str_125
	.dw ___str_126
	.dw ___str_127
	.dw ___str_128
	.dw ___str_129
	.dw ___str_130
	.dw ___str_131
	.dw ___str_132
	.area _CABS (ABS)
