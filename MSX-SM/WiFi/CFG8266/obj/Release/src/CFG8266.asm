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
	.globl _PrintChar
	.globl _InputString
	.globl _Print
	.globl _strlen
	.globl _atol
	.globl _atoi
	.globl _puts
	.globl _printf
	.globl _uiTimeout
	.globl _ucSetTimeout
	.globl _ucRadioOff
	.globl _ucNagleOn
	.globl _ucNagleOff
	.globl _ucIsFw
	.globl _ucLocalUpdate
	.globl _lPort
	.globl _uiPort
	.globl _ucPort
	.globl _ucFile
	.globl _ucServer
	.globl _ucScan
	.globl _TickCount
	.globl _strUsage
	.globl _responseReady2
	.globl _radioOffResponse
	.globl _responseRadioOnTimeout
	.globl _responseOTASPIFF
	.globl _responseOTAFW
	.globl _responseWRBlock
	.globl _responseRSCERTUpdate
	.globl _responseRSFWUpdate
	.globl _apconfigurationResponse
	.globl _scanresResponse
	.globl _nagleoffResponse
	.globl _nagleonResponse
	.globl _scanResponse
	.globl _responseOK
	.globl _certificateDone
	.globl _endUpdate
	.globl _responseReady
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
_ucServer::
	.ds 256
_ucFile::
	.ds 256
_ucPort::
	.ds 6
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
	call	___sdcc_enter_ix
	ld	hl, #-14
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:49: unsigned int iRet = 0;
	ld	bc, #0x0000
;src\CFG8266.c:53: regs.Words.DE = (unsigned int) Buffer;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, #0x0004
	add	hl, de
	ld	a, 6 (ix)
	ld	-2 (ix), a
	ld	a, 7 (ix)
	ld	-1 (ix), a
	ld	a, -2 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -1 (ix)
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
	ex	de, hl
	ld	l, e
	ld	h, d
	push	bc
	push	de
	ld	de, #0x0202
	push	de
	push	hl
	ld	a, #0x48
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:57: if (regs.Bytes.A == 0)
	ld	l, e
	ld	h, d
	inc	hl
	ld	a, (hl)
	or	a, a
	jr	NZ,00102$
;src\CFG8266.c:60: iRet = regs.Words.HL;
	ex	de,hl
	ld	de, #0x0006
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
00102$:
;src\CFG8266.c:63: return iRet;
	ld	l, c
	ld	h, b
;src\CFG8266.c:64: }
	ld	sp, ix
	pop	ix
	ret
_Done_Version:
	.ascii "Made with FUSION-C 1.2 (ebsoft)"
	.db 0x00
_responseReady:
	.db #0x52	; 82	'R'
	.db #0x65	; 101	'e'
	.db #0x61	; 97	'a'
	.db #0x64	; 100	'd'
	.db #0x79	; 121	'y'
	.db #0x0d	; 13
	.db #0x0a	; 10
_endUpdate:
	.db #0x45	; 69	'E'
	.db #0x00	; 0
_certificateDone:
	.db #0x49	; 73	'I'
	.db #0x00	; 0
_responseOK:
	.db #0x4f	; 79	'O'
	.db #0x4b	; 75	'K'
_scanResponse:
	.db #0x53	; 83	'S'
	.db #0x00	; 0
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
_responseReady2:
	.db #0x52	; 82	'R'
	.db #0x65	; 101	'e'
	.db #0x61	; 97	'a'
	.db #0x64	; 100	'd'
	.db #0x79	; 121	'y'
	.db #0x0d	; 13
	.db #0x0a	; 10
_strUsage:
	.ascii "Usage: CFG8266 /s to scan networks and choose one to connect"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 /n to turn off Nagle Algorithm (default) or /"
	.ascii "m to turn it on"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 /o to turn off radio now if no connections ar"
	.ascii "e open"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 CERTFILE /c to update ESP8266 firmware locall"
	.ascii "y"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 FWFILE to update ESP8266 firmware locally"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 /u SERVER PORT FILEPATH to update ESP8266 fir"
	.ascii "mware remotely"
	.db 0x0d
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 /c SERVER PORT FILEPATH to update TLS certifi"
	.ascii "cates remotely"
	.db 0x0d
	.db 0x0a
	.ascii "       CFG8266 /t TIM to change the inactivity time in secon"
	.ascii "ds to disable radio               0-600 (0 means never disab"
	.ascii "le)"
	.db 0x0d
	.db 0x0a
	.ascii "Ex.:   CFG8266 /u 192.168.31.1 80 /fw/fw.bin"
	.db 0x00
;src\CFG8266.c:67: unsigned int IsValidInput (char**argv, int argc)
;	---------------------------------
; Function IsValidInput
; ---------------------------------
_IsValidInput::
	call	___sdcc_enter_ix
	push	af
	push	af
	push	af
	push	af
;src\CFG8266.c:69: unsigned int ret = 1;
	ld	bc, #0x0001
;src\CFG8266.c:70: unsigned char * Input = (unsigned char*)argv[0];
	ld	a, 4 (ix)
	ld	-8 (ix), a
	ld	a, 5 (ix)
	ld	-7 (ix), a
	pop	hl
	push	hl
	ld	a, (hl)
	ld	-3 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-2 (ix), a
;src\CFG8266.c:72: ucScan = 0;
	ld	hl,#_ucScan + 0
	ld	(hl), #0x00
;src\CFG8266.c:74: if (argc)
	ld	a, 7 (ix)
	or	a, 6 (ix)
	jp	Z, 00162$
;src\CFG8266.c:76: if ((argc==1)||(argc==2)||(argc==4))
	ld	a, 6 (ix)
	dec	a
	or	a, 7 (ix)
	ld	a, #0x01
	jr	Z,00287$
	xor	a, a
00287$:
	ld	-1 (ix), a
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	ld	a, #0x01
	jr	Z,00289$
	xor	a, a
00289$:
	ld	d, a
	ld	a, -1 (ix)
	or	a,a
	jr	NZ,00156$
	or	a,d
	jr	NZ,00156$
	ld	a, 6 (ix)
	sub	a, #0x04
	or	a, 7 (ix)
	jp	NZ,00157$
00156$:
;src\CFG8266.c:80: if ((Input[0]=='/')&&((Input[1]=='s')||(Input[1]=='S')))
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	ld	e, (hl)
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	inc	hl
;src\CFG8266.c:91: Input = (unsigned char*)argv[1];
	ld	a, -8 (ix)
	add	a, #0x02
	ld	-6 (ix), a
	ld	a, -7 (ix)
	adc	a, #0x00
	ld	-5 (ix), a
;src\CFG8266.c:80: if ((Input[0]=='/')&&((Input[1]=='s')||(Input[1]=='S')))
	ld	a, e
	sub	a, #0x2f
	ld	a, #0x01
	jr	Z,00293$
	xor	a, a
00293$:
	ld	e, a
;src\CFG8266.c:78: if ((argc==1)||(argc==2))
	ld	a, -1 (ix)
	or	a,a
	jr	NZ,00152$
	or	a,d
	jp	Z, 00153$
00152$:
;src\CFG8266.c:80: if ((Input[0]=='/')&&((Input[1]=='s')||(Input[1]=='S')))
	ld	a, e
	or	a, a
	jr	Z,00132$
	ld	a, (hl)
	cp	a, #0x73
	jr	Z,00131$
	sub	a, #0x53
	jr	NZ,00132$
00131$:
;src\CFG8266.c:81: ucScan = 1;
	ld	hl,#_ucScan + 0
	ld	(hl), #0x01
	jp	00163$
00132$:
;src\CFG8266.c:82: else if ((Input[0]=='/')&&((Input[1]=='n')||(Input[1]=='N')))
	ld	a, e
	or	a, a
	jr	Z,00127$
	ld	a, (hl)
	cp	a, #0x6e
	jr	Z,00126$
	sub	a, #0x4e
	jr	NZ,00127$
00126$:
;src\CFG8266.c:83: ucNagleOff = 1;
	ld	hl,#_ucNagleOff + 0
	ld	(hl), #0x01
	jp	00163$
00127$:
;src\CFG8266.c:84: else if ((Input[0]=='/')&&((Input[1]=='m')||(Input[1]=='M')))
	ld	a, e
	or	a, a
	jr	Z,00122$
	ld	a, (hl)
	cp	a, #0x6d
	jr	Z,00121$
	sub	a, #0x4d
	jr	NZ,00122$
00121$:
;src\CFG8266.c:85: ucNagleOn = 1;
	ld	hl,#_ucNagleOn + 0
	ld	(hl), #0x01
	jp	00163$
00122$:
;src\CFG8266.c:86: else if ((Input[0]=='/')&&((Input[1]=='o')||(Input[1]=='O')))
	ld	a, e
	or	a, a
	jr	Z,00117$
	ld	a, (hl)
	cp	a, #0x6f
	jr	Z,00116$
	sub	a, #0x4f
	jr	NZ,00117$
00116$:
;src\CFG8266.c:87: ucRadioOff = 1;
	ld	hl,#_ucRadioOff + 0
	ld	(hl), #0x01
	jp	00163$
00117$:
;src\CFG8266.c:88: else if ((Input[0]=='/')&&((Input[1]=='t')||(Input[1]=='T')))
	ld	a, e
	or	a, a
	jr	Z,00112$
	ld	a, (hl)
	cp	a, #0x74
	jr	Z,00111$
	sub	a, #0x54
	jr	NZ,00112$
00111$:
;src\CFG8266.c:90: ucSetTimeout = 1;
	ld	hl,#_ucSetTimeout + 0
	ld	(hl), #0x01
;src\CFG8266.c:91: Input = (unsigned char*)argv[1];
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:92: uiTimeout = atoi (Input);
	push	bc
	push	de
	call	_atoi
	pop	af
	pop	bc
	ld	(_uiTimeout), hl
;src\CFG8266.c:93: if (uiTimeout > 600)
	ld	a, #0x58
	ld	iy, #_uiTimeout
	cp	a, 0 (iy)
	ld	a, #0x02
	sbc	a, 1 (iy)
	jp	NC, 00163$
;src\CFG8266.c:94: uiTimeout = 600;
	ld	hl, #0x0258
	ld	(_uiTimeout), hl
	jp	00163$
00112$:
;src\CFG8266.c:98: strcpy (ucFile,Input);
	push	bc
	push	de
	ld	de, #_ucFile
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	xor	a, a
00309$:
	cp	a, (hl)
	ldi
	jr	NZ, 00309$
	pop	de
	pop	bc
;src\CFG8266.c:99: ucLocalUpdate = 1;
	ld	hl,#_ucLocalUpdate + 0
	ld	(hl), #0x01
;src\CFG8266.c:100: if (argc==2)
	ld	a, d
	or	a, a
	jr	Z,00109$
;src\CFG8266.c:102: Input = (unsigned char*)argv[1];
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:103: if ((Input[0]=='/')&&((Input[1]=='c')||(Input[1]=='C')))
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
;src\CFG8266.c:104: ucIsFw=0;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x00
	jp	00163$
00104$:
;src\CFG8266.c:106: ret=0;
	ld	bc, #0x0000
	jp	00163$
00109$:
;src\CFG8266.c:110: ucIsFw=1;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x01
	jp	00163$
00153$:
;src\CFG8266.c:118: Input = (unsigned char*)argv[2];
	ld	a, -8 (ix)
	add	a, #0x04
	ld	-4 (ix), a
	ld	a, -7 (ix)
	adc	a, #0x00
	ld	-3 (ix), a
;src\CFG8266.c:124: Input = (unsigned char*)argv[3];
	ld	a, -8 (ix)
	add	a, #0x06
	ld	-2 (ix), a
	ld	a, -7 (ix)
	adc	a, #0x00
	ld	-1 (ix), a
;src\CFG8266.c:115: if ((Input[0]=='/')&&((Input[1]=='u')||(Input[1]=='U')))
	ld	a, e
	or	a, a
	jp	Z, 00148$
	ld	a, (hl)
	cp	a, #0x75
	jr	Z,00147$
	sub	a, #0x55
	jp	NZ,00148$
00147$:
;src\CFG8266.c:117: ucIsFw = 1;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x01
;src\CFG8266.c:118: Input = (unsigned char*)argv[2];
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:119: if (strlen (Input)<7)
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
;src\CFG8266.c:121: strcpy(ucPort,Input);
	ld	hl, #_ucPort
	push	bc
	ex	de, hl
	xor	a, a
00318$:
	cp	a, (hl)
	ldi
	jr	NZ, 00318$
	pop	bc
;src\CFG8266.c:122: Input = (unsigned char*)argv[1];
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:123: strcpy(ucServer,Input);
	ld	hl, #_ucServer+0
	push	bc
	ex	de, hl
	xor	a, a
00319$:
	cp	a, (hl)
	ldi
	jr	NZ, 00319$
	pop	bc
;src\CFG8266.c:124: Input = (unsigned char*)argv[3];
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:125: strcpy(ucFile,Input);
	ld	hl, #_ucFile+0
	push	bc
	ex	de, hl
	xor	a, a
00320$:
	cp	a, (hl)
	ldi
	jr	NZ, 00320$
	ld	hl, #_ucPort
	push	hl
	call	_atol
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	de, #_lPort
	ld	hl, #6
	add	hl, sp
	ld	bc, #4
	ldir
	pop	bc
;src\CFG8266.c:127: uiPort = (lPort&0xffff);
	ld	hl, (_lPort)
	ld	(_uiPort), hl
	jp	00163$
00137$:
;src\CFG8266.c:130: ret = 0;
	ld	bc, #0x0000
	jp	00163$
00148$:
;src\CFG8266.c:132: else if ((Input[0]=='/')&&((Input[1]=='c')||(Input[1]=='C')))
	ld	a, e
	or	a, a
	jp	Z, 00143$
	ld	a, (hl)
	cp	a, #0x63
	jr	Z,00142$
	sub	a, #0x43
	jp	NZ,00143$
00142$:
;src\CFG8266.c:134: ucIsFw = 0;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x00
;src\CFG8266.c:135: Input = (unsigned char*)argv[2];
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:136: if (strlen (Input)<7)
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
;src\CFG8266.c:138: strcpy(ucPort,Input);
	ld	hl, #_ucPort
	push	bc
	ex	de, hl
	xor	a, a
00324$:
	cp	a, (hl)
	ldi
	jr	NZ, 00324$
	pop	bc
;src\CFG8266.c:139: Input = (unsigned char*)argv[1];
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:140: strcpy(ucServer,Input);
	ld	hl, #_ucServer+0
	push	bc
	ex	de, hl
	xor	a, a
00325$:
	cp	a, (hl)
	ldi
	jr	NZ, 00325$
	pop	bc
;src\CFG8266.c:141: Input = (unsigned char*)argv[3];
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:142: strcpy(ucFile,Input);
	ld	hl, #_ucFile+0
	push	bc
	ex	de, hl
	xor	a, a
00326$:
	cp	a, (hl)
	ldi
	jr	NZ, 00326$
	ld	hl, #_ucPort
	push	hl
	call	_atol
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	de, #_lPort
	ld	hl, #6
	add	hl, sp
	ld	bc, #4
	ldir
	pop	bc
;src\CFG8266.c:144: uiPort = (lPort&0xffff);
	ld	hl, (_lPort)
	ld	(_uiPort), hl
	jr	00163$
00140$:
;src\CFG8266.c:147: ret = 0;
	ld	bc, #0x0000
	jr	00163$
00143$:
;src\CFG8266.c:150: ret = 0;
	ld	bc, #0x0000
	jr	00163$
00157$:
;src\CFG8266.c:154: ret = 0;
	ld	bc, #0x0000
	jr	00163$
00162$:
;src\CFG8266.c:157: ret=0;
	ld	bc, #0x0000
00163$:
;src\CFG8266.c:159: return ret;
	ld	l, c
	ld	h, b
;src\CFG8266.c:160: }
	ld	sp, ix
	pop	ix
	ret
;src\CFG8266.c:162: void TxByte(char chTxByte)
;	---------------------------------
; Function TxByte
; ---------------------------------
_TxByte::
;src\CFG8266.c:165: do
00103$:
;src\CFG8266.c:167: UartStatus = myPort7&2 ;
	in	a, (_myPort7)
	bit	1, a
	jr	NZ,00103$
;src\CFG8266.c:168: if (!UartStatus)
;src\CFG8266.c:173: myPort7 = chTxByte;
	ld	hl, #2+0
	add	hl, sp
	ld	a, (hl)
	out	(_myPort7), a
;src\CFG8266.c:177: while (1);
;src\CFG8266.c:178: }
	ret
;src\CFG8266.c:180: char *ultostr(unsigned long value, char *ptr, int base)
;	---------------------------------
; Function ultostr
; ---------------------------------
_ultostr::
	call	___sdcc_enter_ix
	ld	hl, #-15
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:183: unsigned long tmp = value;
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	e, 6 (ix)
	ld	d, 7 (ix)
;src\CFG8266.c:184: int count = 0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
;src\CFG8266.c:186: if (NULL == ptr)
	ld	a, 9 (ix)
	or	a, 8 (ix)
	jr	NZ,00102$
;src\CFG8266.c:188: return NULL;
	ld	hl, #0x0000
	jp	00117$
00102$:
;src\CFG8266.c:191: if (tmp == 0)
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jr	NZ,00122$
;src\CFG8266.c:193: count++;
	ld	-2 (ix), #0x01
	xor	a, a
	ld	-1 (ix), a
;src\CFG8266.c:196: while(tmp > 0)
00122$:
00105$:
;src\CFG8266.c:198: tmp = tmp/base;
	ld	a, 10 (ix)
	ld	-15 (ix), a
	ld	a, 11 (ix)
	ld	-14 (ix), a
	rla
	sbc	a, a
	ld	-13 (ix), a
	ld	-12 (ix), a
;src\CFG8266.c:196: while(tmp > 0)
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jr	Z,00107$
;src\CFG8266.c:198: tmp = tmp/base;
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	push	hl
	ld	l, -15 (ix)
	ld	h, -14 (ix)
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
;src\CFG8266.c:199: count++;
	inc	-2 (ix)
	jr	NZ,00105$
	inc	-1 (ix)
	jr	00105$
00107$:
;src\CFG8266.c:202: ptr += count;
	ld	a, 8 (ix)
	add	a, -2 (ix)
	ld	8 (ix), a
	ld	a, 9 (ix)
	adc	a, -1 (ix)
	ld	9 (ix), a
;src\CFG8266.c:204: *ptr = '\0';
	ld	c, 8 (ix)
	ld	b, 9 (ix)
	xor	a, a
	ld	(bc), a
;src\CFG8266.c:206: do
00114$:
;src\CFG8266.c:208: res = value - base * (t = value / base);
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	push	hl
	ld	l, -15 (ix)
	ld	h, -14 (ix)
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
	ld	-11 (ix), l
	ld	-10 (ix), h
	ld	-9 (ix), e
	ld	-8 (ix), d
	push	de
	push	hl
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	push	hl
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	push	hl
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	a, 4 (ix)
	sub	a, -4 (ix)
	ld	c, a
	ld	a, 5 (ix)
	sbc	a, -3 (ix)
	ld	b, a
	ld	a, 6 (ix)
	sbc	a, -2 (ix)
	ld	e, a
	ld	a, 7 (ix)
	sbc	a, -1 (ix)
	ld	d, a
	ld	-7 (ix), c
	ld	-6 (ix), b
	ld	-5 (ix), e
	ld	-4 (ix), d
;src\CFG8266.c:209: if (res < 10)
	ld	a, -7 (ix)
	sub	a, #0x0a
	ld	a, -6 (ix)
	sbc	a, #0x00
	ld	a, -5 (ix)
	sbc	a, #0x00
	ld	a, -4 (ix)
	sbc	a, #0x00
	ld	a, #0x00
	rla
	ld	-3 (ix), a
;src\CFG8266.c:211: * -- ptr = '0' + res;
	ld	a, 8 (ix)
	add	a, #0xff
	ld	-2 (ix), a
	ld	a, 9 (ix)
	adc	a, #0xff
	ld	-1 (ix), a
	ld	c, -7 (ix)
;src\CFG8266.c:209: if (res < 10)
	ld	a, -3 (ix)
	or	a, a
	jr	Z,00112$
;src\CFG8266.c:211: * -- ptr = '0' + res;
	ld	a, -2 (ix)
	ld	8 (ix), a
	ld	a, -1 (ix)
	ld	9 (ix), a
	ld	e, 8 (ix)
	ld	d, 9 (ix)
	ld	a, c
	add	a, #0x30
	ld	(de), a
	jr	00115$
00112$:
;src\CFG8266.c:213: else if ((res >= 10) && (res < 16))
	bit	0,-3 (ix)
	jr	NZ,00115$
	ld	a, -7 (ix)
	sub	a, #0x10
	ld	a, -6 (ix)
	sbc	a, #0x00
	ld	a, -5 (ix)
	sbc	a, #0x00
	ld	a, -4 (ix)
	sbc	a, #0x00
	jr	NC,00115$
;src\CFG8266.c:215: * --ptr = 'A' - 10 + res;
	ld	a, -2 (ix)
	ld	8 (ix), a
	ld	a, -1 (ix)
	ld	9 (ix), a
	ld	e, 8 (ix)
	ld	d, 9 (ix)
	ld	a, c
	add	a, #0x37
	ld	(de), a
00115$:
;src\CFG8266.c:217: } while ((value = t) != 0);
	ld	hl, #19
	add	hl, sp
	ex	de, hl
	ld	hl, #4
	add	hl, sp
	ld	bc, #4
	ldir
	ld	a, -8 (ix)
	or	a, -9 (ix)
	or	a, -10 (ix)
	or	a, -11 (ix)
	jp	NZ, 00114$
;src\CFG8266.c:219: return(ptr);
	ld	l, 8 (ix)
	ld	h, 9 (ix)
00117$:
;src\CFG8266.c:220: }
	ld	sp, ix
	pop	ix
	ret
;src\CFG8266.c:222: bool WaitForRXData(unsigned char *uchData, unsigned int uiDataSize, unsigned int Timeout, bool bVerbose, bool bShowReceivedData)
;	---------------------------------
; Function WaitForRXData
; ---------------------------------
_WaitForRXData::
	call	___sdcc_enter_ix
	ld	hl, #-17
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:224: bool bReturn = false;
	ld	c, #0x00
;src\CFG8266.c:228: unsigned char advance[4] = {'-','\\','|','/'};
	ld	hl, #0
	add	hl, sp
	ld	-13 (ix), l
	ld	-12 (ix), h
	ld	(hl), #0x2d
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	inc	hl
	ld	(hl), #0x5c
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	inc	hl
	inc	hl
	ld	(hl), #0x7c
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	(hl), #0x2f
;src\CFG8266.c:229: unsigned int i = 0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
;src\CFG8266.c:231: if (bShowReceivedData)
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00104$
;src\CFG8266.c:233: printf ("Waiting for: ");
	push	bc
	ld	hl, #___str_2
	push	hl
	call	_printf
	pop	af
	pop	bc
;src\CFG8266.c:234: for (i=0;i<uiDataSize;++i)
	ld	de, #0x0000
00132$:
	ld	a, e
	sub	a, 6 (ix)
	ld	a, d
	sbc	a, 7 (ix)
	jr	NC,00101$
;src\CFG8266.c:235: printf("%c",uchData[i]);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	add	hl, de
	ld	l, (hl)
	ld	h, #0x00
	push	bc
	push	de
	push	hl
	ld	hl, #___str_3
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	de
	pop	bc
;src\CFG8266.c:234: for (i=0;i<uiDataSize;++i)
	inc	de
	jr	00132$
00101$:
;src\CFG8266.c:236: printf (" / ");
	push	bc
	ld	hl, #___str_4
	push	hl
	call	_printf
	pop	af
	pop	bc
;src\CFG8266.c:237: for (i=0;i<uiDataSize;++i)
	ld	de, #0x0000
00135$:
	ld	a, e
	sub	a, 6 (ix)
	ld	a, d
	sbc	a, 7 (ix)
	jr	NC,00102$
;src\CFG8266.c:238: printf("{%x}",uchData[i]);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	add	hl, de
	ld	l, (hl)
	ld	h, #0x00
	push	bc
	push	de
	push	hl
	ld	hl, #___str_5
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	de
	pop	bc
;src\CFG8266.c:237: for (i=0;i<uiDataSize;++i)
	inc	de
	jr	00135$
00102$:
;src\CFG8266.c:239: printf ("\r\n");
	push	bc
	ld	hl, #___str_7
	push	hl
	call	_puts
	pop	af
	pop	bc
;src\CFG8266.c:240: i = 0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00104$:
;src\CFG8266.c:243: TickCount = 0;
	ld	hl, #0x0000
	ld	(_TickCount), hl
;src\CFG8266.c:244: Timeout1 = TickCount + 5;
	ld	iy, #_TickCount
	ld	a, 0 (iy)
	add	a, #0x05
	ld	-11 (ix), a
	ld	a, 1 (iy)
	adc	a, #0x00
	ld	-10 (ix), a
;src\CFG8266.c:245: Timeout2 = TickCount + Timeout; //Wait up to 5 minutes
	ld	a, 0 (iy)
	add	a, 8 (ix)
	ld	e, a
	ld	a, 1 (iy)
	adc	a, 9 (ix)
	ld	d, a
;src\CFG8266.c:247: ResponseSt=0;
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
;src\CFG8266.c:249: do
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	ld	a, #0x01
	jr	Z,00227$
	xor	a, a
00227$:
	ld	-9 (ix), a
	ld	a, #0x84
	cp	a, 8 (ix)
	ld	a, #0x03
	sbc	a, 9 (ix)
	ld	a, #0x00
	rla
	ld	-8 (ix), a
00128$:
;src\CFG8266.c:251: if (Timeout>900)
	ld	a, -8 (ix)
	or	a, a
	jr	Z,00108$
;src\CFG8266.c:253: if (TickCount>Timeout1)
	ld	a, -11 (ix)
	ld	iy, #_TickCount
	sub	a, 0 (iy)
	ld	a, -10 (ix)
	sbc	a, 1 (iy)
	jr	NC,00108$
;src\CFG8266.c:255: Timeout1 = TickCount + 5;
	ld	a, 0 (iy)
	add	a, #0x05
	ld	-11 (ix), a
	ld	a, 1 (iy)
	adc	a, #0x00
	ld	-10 (ix), a
;src\CFG8266.c:256: PrintChar(advance[i%4]); // next char
	ld	a, -2 (ix)
	and	a, #0x03
	ld	b, #0x00
	add	a, -13 (ix)
	ld	l, a
	ld	a, b
	adc	a, -12 (ix)
	ld	h, a
	ld	a, (hl)
	push	bc
	push	de
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
	ld	a, #0x1d
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:258: ++i;
	inc	-2 (ix)
	jr	NZ,00228$
	inc	-1 (ix)
00228$:
00108$:
;src\CFG8266.c:261: if(UartRXData())
	in	a, (_myPort7)
	rrca
	jp	NC,00125$
;src\CFG8266.c:263: rx_data = GetUARTData();
	in	a, (_myPort6)
	ld	b, a
;src\CFG8266.c:265: if (rx_data == uchData[ResponseSt])
	ld	a, 4 (ix)
	add	a, -4 (ix)
	ld	l, a
	ld	a, 5 (ix)
	adc	a, -3 (ix)
	ld	h, a
	ld	a, (hl)
	ld	-7 (ix), a
;src\CFG8266.c:268: printf ("{%x}",rx_data);
	ld	-6 (ix), b
	xor	a, a
	ld	-5 (ix), a
;src\CFG8266.c:265: if (rx_data == uchData[ResponseSt])
	ld	a, -7 (ix)
	sub	a, b
	jr	NZ,00122$
;src\CFG8266.c:267: if (bShowReceivedData)
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00110$
;src\CFG8266.c:268: printf ("{%x}",rx_data);
	push	bc
	push	de
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	hl, #___str_5
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	de
	pop	bc
00110$:
;src\CFG8266.c:269: ++ResponseSt;
	inc	-4 (ix)
	jr	NZ,00232$
	inc	-3 (ix)
00232$:
;src\CFG8266.c:270: if (ResponseSt == uiDataSize)
	ld	a, -4 (ix)
	sub	a, 6 (ix)
	jr	NZ,00125$
	ld	a, -3 (ix)
	sub	a, 7 (ix)
	jr	NZ,00125$
;src\CFG8266.c:272: bReturn = true;
	ld	c, #0x01
;src\CFG8266.c:273: break;
	jr	00130$
00122$:
;src\CFG8266.c:278: if ((ResponseSt)&&(bShowReceivedData))
	ld	a, -3 (ix)
	or	a, -4 (ix)
	jr	Z,00114$
	ld	a, 11 (ix)
	or	a, a
	jr	Z,00114$
;src\CFG8266.c:279: printf ("{%x} != [%x]",rx_data,uchData[ResponseSt]);
	ld	l, -7 (ix)
	ld	h, #0x00
	push	bc
	push	de
	push	hl
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	hl, #___str_8
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
	pop	de
	pop	bc
00114$:
;src\CFG8266.c:280: if ((uiDataSize==2)&&(ResponseSt==1))
	ld	a, -9 (ix)
	or	a, a
	jr	Z,00119$
	ld	a, -4 (ix)
	dec	a
	or	a, -3 (ix)
	jr	NZ,00119$
;src\CFG8266.c:282: if (bVerbose)
	ld	a, 10 (ix)
	or	a, a
	jr	Z,00117$
;src\CFG8266.c:283: printf ("Error %u on command %c...\r\n",rx_data,uchData[0]);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	c, (hl)
	ld	b, #0x00
	push	bc
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	hl, #___str_9
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
00117$:
;src\CFG8266.c:284: return false;
	ld	l, #0x00
	jr	00137$
00119$:
;src\CFG8266.c:286: ResponseSt = 0;
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
00125$:
;src\CFG8266.c:290: if (TickCount>Timeout2)
	ld	a, e
	ld	iy, #_TickCount
	sub	a, 0 (iy)
	ld	a, d
	sbc	a, 1 (iy)
	jp	NC, 00128$
;src\CFG8266.c:293: while (1);
00130$:
;src\CFG8266.c:295: return bReturn;
	ld	l, c
00137$:
;src\CFG8266.c:296: }
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
	.ascii "{%x} != [%x]"
	.db 0x00
___str_9:
	.ascii "Error %u on command %c..."
	.db 0x0d
	.db 0x0a
	.db 0x00
;src\CFG8266.c:298: void FinishUpdate (bool bSendReset)
;	---------------------------------
; Function FinishUpdate
; ---------------------------------
_FinishUpdate::
	call	___sdcc_enter_ix
	push	af
	push	af
;src\CFG8266.c:300: unsigned int iRetries = 3;
	ld	hl, #0x0003
	ex	(sp), hl
;src\CFG8266.c:304: bool bReset = bSendReset;
	ld	a, 4 (ix)
	ld	-2 (ix), a
;src\CFG8266.c:306: printf("\rFinishing flash, this will take some time, WAIT!\r\n");
	ld	hl, #___str_11
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:308: do
	ld	-1 (ix), #0x02
00135$:
;src\CFG8266.c:310: bRet = true;
	ld	l, #0x01
;src\CFG8266.c:311: --ucRetries;
	dec	-1 (ix)
;src\CFG8266.c:312: if (bReset)
	ld	a, -2 (ix)
	or	a, a
	jr	Z,00154$
;src\CFG8266.c:313: TxByte('R'); //Request Reset
	push	hl
	ld	a, #0x52
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	hl
	jr	00110$
;src\CFG8266.c:316: do
00154$:
	pop	de
	push	de
;src\CFG8266.c:318: for (uchHalt=60;uchHalt>0;--uchHalt)
00152$:
	ld	a, #0x3c
00140$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFG8266.c:318: for (uchHalt=60;uchHalt>0;--uchHalt)
	dec	a
	jr	NZ,00140$
;src\CFG8266.c:320: TxByte('E'); //End Update
	push	de
	ld	a, #0x45
	push	af
	inc	sp
	call	_TxByte
	inc	sp
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
	pop	af
	pop	af
	pop	af
	pop	af
	pop	de
;src\CFG8266.c:322: iRetries--;
	dec	de
;src\CFG8266.c:324: while ((!bRet)&&(iRetries));
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
;src\CFG8266.c:325: if (bRet)
	ld	a, l
	or	a, a
	jr	Z,00110$
;src\CFG8266.c:327: bReset=true;
	ld	-2 (ix), #0x01
00110$:
;src\CFG8266.c:331: if (!bRet)
	ld	a, l
	or	a, a
	jr	NZ,00133$
;src\CFG8266.c:332: printf("\rTimeout waiting to end update...\r\n");
	ld	hl, #___str_13
	push	hl
	call	_puts
	pop	af
	jp	00136$
00133$:
;src\CFG8266.c:335: if (ucRetries)
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00115$
;src\CFG8266.c:337: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00112$
;src\CFG8266.c:338: printf("\rFirmware Update done, ESP is restarting, WAIT...\r\n");
	ld	hl, #___str_15
	push	hl
	call	_puts
	pop	af
	jr	00115$
00112$:
;src\CFG8266.c:340: printf("\rCertificates Update done, ESP is restarting, WAIT...\r\n");
	ld	hl, #___str_17
	push	hl
	call	_puts
	pop	af
00115$:
;src\CFG8266.c:343: if (WaitForRXData(responseReady2,7,2700,false,false)) //Wait up to 45 seconds
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
	pop	af
	pop	af
	pop	af
	pop	af
	ld	a, l
	or	a, a
	jp	Z, 00130$
;src\CFG8266.c:345: if (!ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	NZ,00125$
;src\CFG8266.c:347: printf("\rESP Reset Ok, now let's request creation of index file...\r\n");
	ld	hl, #___str_19
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:349: do
	ld	-2 (ix), #0x0a
	xor	a, a
	ld	-1 (ix), a
;src\CFG8266.c:351: for (uchHalt=60;uchHalt>0;--uchHalt)
00162$:
	ld	a, #0x3c
00142$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFG8266.c:351: for (uchHalt=60;uchHalt>0;--uchHalt)
	dec	a
	jr	NZ,00142$
;src\CFG8266.c:353: TxByte('I'); //End Update
	ld	a, #0x49
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:354: bRet = WaitForRXData(certificateDone,2,3600,false,false); //Wait up to 1 minute, certificate index creation takes time
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
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-3 (ix), l
;src\CFG8266.c:355: iRetries--;
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	dec	hl
	ld	-2 (ix), l
	ld	-1 (ix), h
;src\CFG8266.c:357: while ((!bRet)&&(iRetries));
	ld	a, -3 (ix)
	or	a, a
	jr	NZ,00120$
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ,00162$
00120$:
;src\CFG8266.c:358: if (bRet)
	ld	a, -3 (ix)
	or	a, a
	jr	Z,00122$
;src\CFG8266.c:359: printf("\rDone!                                \r\n");
	ld	hl, #___str_21
	push	hl
	call	_puts
	pop	af
	jr	00137$
00122$:
;src\CFG8266.c:361: printf("\rDone, but time-out on creating certificates index file!\r\n");
	ld	hl, #___str_23
	push	hl
	call	_puts
	pop	af
	jr	00137$
00125$:
;src\CFG8266.c:364: printf("\rDone!                              \r\n");
	ld	hl, #___str_25
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:365: break;
	jr	00137$
00130$:
;src\CFG8266.c:368: if (!ucRetries)
	ld	a, -1 (ix)
	or	a, a
	jr	NZ,00136$
;src\CFG8266.c:369: printf("\rTimeout error\r\n");
	ld	hl, #___str_27
	push	hl
	call	_puts
	pop	af
00136$:
;src\CFG8266.c:372: while (ucRetries);
	ld	a, -1 (ix)
	or	a, a
	jp	NZ, 00135$
00137$:
;src\CFG8266.c:374: return;
;src\CFG8266.c:375: }
	ld	sp, ix
	pop	ix
	ret
___str_11:
	.db 0x0d
	.ascii "Finishing flash, this will take some time, WAIT!"
	.db 0x0d
	.db 0x00
___str_13:
	.db 0x0d
	.ascii "Timeout waiting to end update..."
	.db 0x0d
	.db 0x00
___str_15:
	.db 0x0d
	.ascii "Firmware Update done, ESP is restarting, WAIT..."
	.db 0x0d
	.db 0x00
___str_17:
	.db 0x0d
	.ascii "Certificates Update done, ESP is restarting, WAIT..."
	.db 0x0d
	.db 0x00
___str_19:
	.db 0x0d
	.ascii "ESP Reset Ok, now let's request creation of index file..."
	.db 0x0d
	.db 0x00
___str_21:
	.db 0x0d
	.ascii "Done!                                "
	.db 0x0d
	.db 0x00
___str_23:
	.db 0x0d
	.ascii "Done, but time-out on creating certificates index file!"
	.db 0x0d
	.db 0x00
___str_25:
	.db 0x0d
	.ascii "Done!                              "
	.db 0x0d
	.db 0x00
___str_27:
	.db 0x0d
	.ascii "Timeout error"
	.db 0x0d
	.db 0x00
;src\CFG8266.c:377: int main(char** argv, int argc)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	call	___sdcc_enter_ix
	ld	hl, #-485
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:389: unsigned char advance[4] = {'-','\\','|','/'};
	ld	hl, #421
	add	hl, sp
	ld	-18 (ix), l
	ld	-17 (ix), h
	ld	(hl), #0x2d
	ld	l, -18 (ix)
	ld	h, -17 (ix)
	inc	hl
	ld	(hl), #0x5c
	ld	l, -18 (ix)
	ld	h, -17 (ix)
	inc	hl
	inc	hl
	ld	(hl), #0x7c
	ld	l, -18 (ix)
	ld	h, -17 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	(hl), #0x2f
;src\CFG8266.c:397: unsigned char ucFirstBlock = 1;
	ld	-16 (ix), #0x01
;src\CFG8266.c:404: ucLocalUpdate = 0;
	ld	hl,#_ucLocalUpdate + 0
	ld	(hl), #0x00
;src\CFG8266.c:405: ucNagleOff = 0;
	ld	hl,#_ucNagleOff + 0
	ld	(hl), #0x00
;src\CFG8266.c:406: ucNagleOn = 0;
	ld	hl,#_ucNagleOn + 0
	ld	(hl), #0x00
;src\CFG8266.c:407: ucRadioOff = 0;
	ld	hl,#_ucRadioOff + 0
	ld	(hl), #0x00
;src\CFG8266.c:408: ucSetTimeout = 0;
	ld	hl,#_ucSetTimeout + 0
	ld	(hl), #0x00
;src\CFG8266.c:410: printf("> SM-X ESP8266 WIFI Module Configuration v1.20 <\r\n(c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com\r\n\n");
	ld	hl, #___str_29
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:412: if (IsValidInput(argv, argc))
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_IsValidInput
	pop	af
	pop	af
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	a, h
	or	a, -2 (ix)
	jp	Z, 00293$
;src\CFG8266.c:414: do
	xor	a, a
	ld	-1 (ix), a
00103$:
;src\CFG8266.c:417: myPort6 = speed;
	ld	a, -1 (ix)
	out	(_myPort6), a
;src\CFG8266.c:418: ClearUartData();
	ld	a, #0x14
	out	(_myPort6), a
;src\CFG8266.c:419: TxByte('?');
	ld	a, #0x3f
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFG8266.c:422: bResponse = WaitForRXData(responseOK,2,60,false,false);
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
	ld	hl, #_responseOK
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	pop	af
;src\CFG8266.c:424: if (bResponse)
	ld	-3 (ix), l
	ld	a, l
	or	a, a
	jr	NZ,00105$
;src\CFG8266.c:426: ++speed;
	inc	-1 (ix)
;src\CFG8266.c:428: while (speed<10);
	ld	a, -1 (ix)
	sub	a, #0x0a
	jr	C,00103$
00105$:
;src\CFG8266.c:430: if (speed<10)
	ld	a, -1 (ix)
	sub	a, #0x0a
	jp	NC, 00290$
;src\CFG8266.c:432: printf ("Using Baud Rate #%u\r\n",speed);
	ld	a, -1 (ix)
	ld	-2 (ix), a
	xor	a, a
	ld	-1 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	hl, #___str_30
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:433: if ((ucScan)||(ucNagleOff)||(ucNagleOn)||(ucRadioOff)||(ucSetTimeout))
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	NZ,00282$
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00282$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	NZ,00282$
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	NZ,00282$
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jp	Z, 00283$
00282$:
;src\CFG8266.c:436: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	Z,00121$
;src\CFG8266.c:437: TxByte('S'); //Request SCAN
	ld	a, #0x53
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jp	00122$
00121$:
;src\CFG8266.c:438: else if (ucNagleOff)
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	Z,00118$
;src\CFG8266.c:439: TxByte('N'); //Request nagle off for future connections
	ld	a, #0x4e
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jp	00122$
00118$:
;src\CFG8266.c:440: else if (ucNagleOn)
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00115$
;src\CFG8266.c:441: TxByte('D'); //Request nagle on for future connections
	ld	a, #0x44
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00122$
00115$:
;src\CFG8266.c:442: else if (ucRadioOff)
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	Z,00112$
;src\CFG8266.c:443: TxByte('O'); //Request to turn off wifi radio immediately
	ld	a, #0x4f
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00122$
00112$:
;src\CFG8266.c:444: else if (ucSetTimeout)
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jr	Z,00122$
;src\CFG8266.c:446: ucTimeOutMSB = ((unsigned char)((uiTimeout&0xff00)>>8));
	ld	iy, #_uiTimeout
	ld	c, 1 (iy)
	ld	-2 (ix), c
;src\CFG8266.c:447: ucTimeOutLSB = ((unsigned char)(uiTimeout&0xff));
	ld	a, 0 (iy)
	ld	-1 (ix), a
;src\CFG8266.c:448: if (uiTimeout)
	ld	a, 1 (iy)
	or	a, 0 (iy)
	jr	Z,00107$
;src\CFG8266.c:449: printf("\r\nSetting WiFi idle timeout to %u...\r\n",uiTimeout);
	ld	hl, (_uiTimeout)
	push	hl
	ld	hl, #___str_31
	push	hl
	call	_printf
	pop	af
	pop	af
	jr	00108$
00107$:
;src\CFG8266.c:451: printf("\r\nSetting WiFi to always on!\r\n");
	ld	hl, #___str_33
	push	hl
	call	_puts
	pop	af
00108$:
;src\CFG8266.c:452: TxByte('T'); //Request to set time-out
	ld	a, #0x54
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:453: TxByte(0);
	xor	a, a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:454: TxByte(2);
	ld	a, #0x02
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:455: TxByte(ucTimeOutMSB);
	ld	a, -2 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:456: TxByte(ucTimeOutLSB);
	ld	a, -1 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00122$:
;src\CFG8266.c:459: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	Z,00135$
;src\CFG8266.c:460: bResponse = WaitForRXData(scanResponse,2,60,true,false);
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x003c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_scanResponse
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-3 (ix), l
	jp	00136$
00135$:
;src\CFG8266.c:461: else if (ucNagleOff)
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	Z,00132$
;src\CFG8266.c:462: bResponse = WaitForRXData(nagleoffResponse,2,60,true,false);
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x003c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_nagleoffResponse
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-3 (ix), l
	jr	00136$
00132$:
;src\CFG8266.c:463: else if (ucNagleOn)
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00129$
;src\CFG8266.c:464: bResponse = WaitForRXData(nagleonResponse,2,60,true,false);
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x003c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_nagleonResponse
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-3 (ix), l
	jr	00136$
00129$:
;src\CFG8266.c:465: else if (ucRadioOff)
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	Z,00126$
;src\CFG8266.c:466: bResponse = WaitForRXData(radioOffResponse,2,60,true,false);
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x003c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_radioOffResponse
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-3 (ix), l
	jr	00136$
00126$:
;src\CFG8266.c:467: else if (ucSetTimeout)
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jr	Z,00136$
;src\CFG8266.c:468: bResponse = WaitForRXData(responseRadioOnTimeout,2,60,true,false);
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x003c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_responseRadioOnTimeout
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-3 (ix), l
00136$:
;src\CFG8266.c:471: if ((bResponse)&&(ucScan))
	ld	a, -3 (ix)
	or	a, a
	jp	Z, 00215$
	ld	iy, #_ucScan
	ld	a, 0 (iy)
	or	a, a
	jp	Z, 00215$
;src\CFG8266.c:474: do
	ld	c, #0x0a
00139$:
;src\CFG8266.c:476: --ucRetries;
	dec	c
;src\CFG8266.c:477: for (ucHalt = 60;ucHalt>0;--ucHalt)
	ld	b, #0x3c
00297$:
;c:/fusion-c/fusion-c/header/../../fusion-c/header/msx_fusion.h:301: __endasm; 
	halt
;src\CFG8266.c:477: for (ucHalt = 60;ucHalt>0;--ucHalt)
	ld	a, b
	dec	a
	ld	b, a
	or	a, a
	jr	NZ,00297$
;src\CFG8266.c:479: TxByte('s'); //Request SCAN result
	push	bc
	ld	a, #0x73
	push	af
	inc	sp
	call	_TxByte
	inc	sp
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
	pop	af
	pop	af
	pop	af
	pop	af
	pop	bc
;src\CFG8266.c:482: while ((ucRetries)&&(!bResponse));
	ld	a, c
	or	a, a
	jr	Z,00141$
	ld	a, l
	or	a, a
	jr	Z,00139$
00141$:
;src\CFG8266.c:484: if (bResponse)
	ld	a, l
	or	a, a
	jp	Z, 00189$
;src\CFG8266.c:487: while(!UartRXData());
00142$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00142$
;src\CFG8266.c:488: ucAPs = GetUARTData();
	in	a, (_myPort6)
	ld	-8 (ix), a
;src\CFG8266.c:489: if (ucAPs>10)
	ld	a, #0x0a
	sub	a, -8 (ix)
	jr	NC,00146$
;src\CFG8266.c:490: ucAPs=10;
	ld	-8 (ix), #0x0a
00146$:
;src\CFG8266.c:492: printf ("\r\n");
	ld	hl, #___str_35
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:493: do
	ld	hl, #81
	add	hl, sp
	ld	-7 (ix), l
	ld	-6 (ix), h
	xor	a, a
	ld	-1 (ix), a
;src\CFG8266.c:498: while(!UartRXData());
00337$:
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
	ld	a, e
	add	a, -7 (ix)
	ld	c, a
	ld	a, d
	adc	a, -6 (ix)
	ld	b, a
	ld	e, #0x00
00147$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00147$
;src\CFG8266.c:499: rx_data=GetUARTData();
	in	a, (_myPort6)
	ld	-2 (ix), a
;src\CFG8266.c:500: stAP[tx_data].APName[ucIndex++]=rx_data;
	ld	a, e
	inc	e
	ld	l, a
	ld	h, #0x00
	add	hl, bc
	ld	a, -2 (ix)
	ld	(hl), a
;src\CFG8266.c:502: while(rx_data!=0);
	ld	a, -2 (ix)
	or	a, a
	jr	NZ,00147$
;src\CFG8266.c:503: while(!UartRXData());
00153$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00153$
;src\CFG8266.c:504: rx_data=GetUARTData();
	in	a, (_myPort6)
	ld	c, a
;src\CFG8266.c:505: stAP[tx_data].isEncrypted = (rx_data == 'E') ? 1 : 0;
	ld	e, -1 (ix)
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
	ld	a, -7 (ix)
	add	a, e
	ld	e, a
	ld	a, -6 (ix)
	adc	a, d
	ld	d, a
	ld	hl, #0x0021
	add	hl, de
	ld	-5 (ix), l
	ld	-4 (ix), h
	ld	a, c
	sub	a, #0x45
	jr	NZ,00308$
	ld	-3 (ix), #0x01
	xor	a, a
	ld	-2 (ix), a
	jr	00309$
00308$:
	xor	a, a
	ld	-3 (ix), a
	ld	-2 (ix), a
00309$:
	ld	a, -3 (ix)
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	ld	(hl), a
;src\CFG8266.c:506: ++tx_data;
	inc	-1 (ix)
;src\CFG8266.c:508: while (tx_data!=ucAPs);
	ld	a, -1 (ix)
	sub	a, -8 (ix)
	jp	NZ,00337$
;src\CFG8266.c:509: ClearUartData();
	ld	a, #0x14
	out	(_myPort6), a
;src\CFG8266.c:510: printf("Choose AP:\r\n\n");
	ld	hl, #___str_37
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:511: for (ucIndex=0;ucIndex<ucAPs;ucIndex++)
	xor	a, a
	ld	-1 (ix), a
00300$:
	ld	a, -1 (ix)
	sub	a, -8 (ix)
	jr	NC,00162$
;src\CFG8266.c:513: printf("%u - %s",ucIndex,stAP[ucIndex].APName);
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
	ld	l, -7 (ix)
	ld	h, -6 (ix)
	add	hl, de
	ld	e, l
	ld	d, h
	ld	c, -1 (ix)
	ld	b, #0x00
	push	hl
	push	de
	push	bc
	ld	bc, #___str_38
	push	bc
	call	_printf
	pop	af
	pop	af
	pop	af
	pop	hl
;src\CFG8266.c:514: if (stAP[ucIndex].isEncrypted)
	ld	de, #0x0021
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	Z,00160$
;src\CFG8266.c:515: printf(" (PWD)\r\n");
	ld	hl, #___str_40
	push	hl
	call	_puts
	pop	af
	jr	00301$
00160$:
;src\CFG8266.c:517: printf(" (OPEN)\r\n");
	ld	hl, #___str_42
	push	hl
	call	_puts
	pop	af
00301$:
;src\CFG8266.c:511: for (ucIndex=0;ucIndex<ucAPs;ucIndex++)
	inc	-1 (ix)
	jr	00300$
00162$:
;src\CFG8266.c:519: printf("\r\nWhich one to connect? (ESC exit)");
	ld	hl, #___str_43
	push	hl
	call	_printf
	pop	af
;src\CFG8266.c:521: do
00166$:
;src\CFG8266.c:523: tx_data = Inkey ();
	call	_Inkey
;src\CFG8266.c:524: if (tx_data==0x1b)
	ld	a, l
	sub	a, #0x1b
	ld	a, #0x01
	jr	Z,00734$
	xor	a, a
00734$:
	ld	c, a
	or	a, a
	jr	NZ,00168$
;src\CFG8266.c:527: while ((tx_data<'0')||(tx_data>'9'));
	ld	a, l
	sub	a, #0x30
	jr	C,00166$
	ld	a, #0x39
	sub	a, l
	jr	C,00166$
00168$:
;src\CFG8266.c:528: if (tx_data!=0x1b)
	bit	0, c
	jp	NZ, 00186$
;src\CFG8266.c:530: printf(" %c\r\n",tx_data);
	ld	e, l
	ld	d, #0x00
	ld	bc, #___str_44+0
	push	hl
	push	de
	push	bc
	call	_printf
	pop	af
	pop	af
	pop	hl
;src\CFG8266.c:531: ucIndex = tx_data-'0';
	ld	a, l
	add	a, #0xd0
;src\CFG8266.c:532: if (stAP[ucIndex].isEncrypted)
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
	ld	-5 (ix), l
	ld	-4 (ix), h
	ld	a, -7 (ix)
	add	a, -5 (ix)
	ld	c, a
	ld	a, -6 (ix)
	adc	a, -4 (ix)
	ld	b, a
	ld	hl, #0x0021
	add	hl, bc
	ex	de, hl
	ld	a, (de)
	or	a, a
	jr	Z,00170$
;src\CFG8266.c:535: printf("Password? ");
	push	bc
	push	de
	ld	hl, #___str_45
	push	hl
	call	_printf
	pop	af
	pop	de
	pop	bc
;src\CFG8266.c:536: InputString(ucPWD,64);
	ld	hl, #16
	add	hl, sp
	ld	-2 (ix), l
	ld	-1 (ix), h
	push	bc
	push	de
	ld	hl, #0x0040
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	call	_InputString
	pop	af
	ld	hl, #___str_35
	ex	(sp),hl
	call	_puts
	pop	af
	pop	de
	pop	bc
00170$:
;src\CFG8266.c:539: uiCMDLen = strlen(stAP[ucIndex].APName) + 1;
	push	bc
	call	_strlen
	pop	af
	inc	hl
	ld	c,l
	ld	b,h
;src\CFG8266.c:540: if (stAP[ucIndex].isEncrypted)
	ld	a, (de)
	or	a, a
	jr	Z,00172$
;src\CFG8266.c:541: uiCMDLen += strlen(ucPWD);
	ld	hl, #16
	add	hl, sp
	push	bc
	push	hl
	call	_strlen
	pop	af
	pop	bc
	add	hl, bc
	ld	c, l
	ld	b, h
00172$:
;src\CFG8266.c:542: TxByte('A'); //Request connect AP
	push	bc
	ld	a, #0x41
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:543: TxByte((unsigned char)((uiCMDLen&0xff00)>>8));
	ld	d, b
	ld	e, #0x00
	push	bc
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:544: TxByte((unsigned char)(uiCMDLen&0xff));
	ld	a, c
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:546: do
	ld	a, -7 (ix)
	add	a, -5 (ix)
	ld	-3 (ix), a
	ld	a, -6 (ix)
	adc	a, -4 (ix)
	ld	-2 (ix), a
	xor	a, a
	ld	-1 (ix), a
00174$:
;src\CFG8266.c:548: tx_data = stAP[ucIndex].APName[rx_data];
	ld	a, -3 (ix)
	add	a, -1 (ix)
	ld	e, a
	ld	a, -2 (ix)
	adc	a, #0x00
	ld	l, e
	ld	h, a
	ld	d, (hl)
;src\CFG8266.c:549: TxByte(tx_data);
	push	bc
	push	de
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:550: --uiCMDLen;
	dec	bc
;src\CFG8266.c:551: ++rx_data;
	inc	-1 (ix)
;src\CFG8266.c:553: while((uiCMDLen)&&(tx_data!=0));
	ld	a, b
	or	a, c
	jr	Z,00176$
	ld	a, d
	or	a, a
	jr	NZ,00174$
00176$:
;src\CFG8266.c:554: if(uiCMDLen)
	ld	a, b
	or	a, c
	jr	Z,00181$
;src\CFG8266.c:557: do
	ld	hl, #16
	add	hl, sp
	ld	-3 (ix), l
	ld	-2 (ix), h
	xor	a, a
	ld	-1 (ix), a
00177$:
;src\CFG8266.c:559: tx_data = ucPWD[rx_data];
	ld	a, -3 (ix)
	add	a, -1 (ix)
	ld	e, a
	ld	a, -2 (ix)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
;src\CFG8266.c:560: TxByte(tx_data);
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:561: --uiCMDLen;
	dec	bc
;src\CFG8266.c:562: ++rx_data;
	inc	-1 (ix)
;src\CFG8266.c:564: while(uiCMDLen);
	ld	a, b
	or	a, c
	jr	NZ,00177$
00181$:
;src\CFG8266.c:568: bResponse = WaitForRXData(apconfigurationResponse,2,300,true,false); //Wait up to 5s
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x012c
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	hl, #_apconfigurationResponse
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	pop	af
	ld	a, l
;src\CFG8266.c:569: if (bResponse)
	or	a, a
	jr	Z,00183$
;src\CFG8266.c:570: printf("Success, AP configured to be used.\r\n");
	ld	hl, #___str_48
	push	hl
	call	_puts
	pop	af
	jp	00294$
00183$:
;src\CFG8266.c:572: printf("Error, AP not configured!\r\n");
	ld	hl, #___str_50
	push	hl
	call	_puts
	pop	af
	jp	00294$
00186$:
;src\CFG8266.c:575: printf("\r\nUser canceled by ESC key...\r\n");
	ld	hl, #___str_52
	push	hl
	call	_puts
	pop	af
	jp	00294$
00189$:
;src\CFG8266.c:578: printf("\r\nScan results: no answer...\r\n");
	ld	hl, #___str_54
	push	hl
	call	_puts
	pop	af
	jp	00294$
00215$:
;src\CFG8266.c:582: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	Z,00212$
;src\CFG8266.c:583: printf ("\rScan request: no answer...\n");
	ld	hl, #___str_56
	push	hl
	call	_puts
	pop	af
	jp	00294$
00212$:
;src\CFG8266.c:584: else if (((ucNagleOff)||(ucNagleOn))&&(bResponse))
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00210$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00207$
00210$:
	ld	a, -3 (ix)
	or	a, a
	jr	Z,00207$
;src\CFG8266.c:586: printf("\rNagle set as requested...\n");
	ld	hl, #___str_58
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:587: return 0;
	ld	hl, #0x0000
	jp	00304$
00207$:
;src\CFG8266.c:589: else if ((ucNagleOff)||(ucNagleOn))
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00202$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00203$
00202$:
;src\CFG8266.c:591: printf("\rNagle not set as requested, error!\n");
	ld	hl, #___str_60
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:592: return 0;
	ld	hl, #0x0000
	jp	00304$
00203$:
;src\CFG8266.c:594: else if (ucRadioOff)
	ld	a,(#_ucRadioOff + 0)
	or	a, a
	jr	Z,00200$
;src\CFG8266.c:596: if (bResponse)
	ld	a, -3 (ix)
	or	a, a
	jr	Z,00192$
;src\CFG8266.c:597: printf("\rRequested to turn off WiFi Radio...\n");
	ld	hl, #___str_62
	push	hl
	call	_puts
	pop	af
	jr	00193$
00192$:
;src\CFG8266.c:599: printf("\rRequest to turnoff WiFi Radio error!\n");
	ld	hl, #___str_64
	push	hl
	call	_puts
	pop	af
00193$:
;src\CFG8266.c:600: return 0;
	ld	hl, #0x0000
	jp	00304$
00200$:
;src\CFG8266.c:602: else if (ucSetTimeout)
	ld	a,(#_ucSetTimeout + 0)
	or	a, a
	jp	Z, 00294$
;src\CFG8266.c:604: if (bResponse)
	ld	a, -3 (ix)
	or	a, a
	jr	Z,00195$
;src\CFG8266.c:605: printf("\rWiFi radio on Time-out set successfully...\n");
	ld	hl, #___str_66
	push	hl
	call	_puts
	pop	af
	jr	00196$
00195$:
;src\CFG8266.c:607: printf("\rError setting WiFi radio on Time-out!\n");
	ld	hl, #___str_68
	push	hl
	call	_puts
	pop	af
00196$:
;src\CFG8266.c:608: return 0;
	ld	hl, #0x0000
	jp	00304$
00283$:
;src\CFG8266.c:612: else if (ucLocalUpdate)
	ld	a,(#_ucLocalUpdate + 0)
	or	a, a
	jp	Z, 00280$
;src\CFG8266.c:615: iFile = Open (ucFile,O_RDONLY);
	ld	hl, #0x0000
	push	hl
	ld	hl, #_ucFile
	push	hl
	call	_Open
	pop	af
	pop	af
	ld	-2 (ix), l
	ld	-1 (ix), h
;src\CFG8266.c:617: if (iFile!=-1)
	ld	a, -2 (ix)
	and	a, -1 (ix)
	inc	a
	jp	Z,00253$
;src\CFG8266.c:624: regs.Words.HL = 0; //set pointer as 0
	ld	hl, #425
	add	hl, sp
	ex	de, hl
	ld	hl, #0x0006
	add	hl, de
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;src\CFG8266.c:625: regs.Words.DE = 0; //so it will return the position
	inc	de
	inc	de
	inc	de
	inc	de
	xor	a, a
	ld	(de), a
	inc	de
	ld	(de), a
;src\CFG8266.c:626: regs.Bytes.A = 2; //relative to the end of file, i.e.:file size
	ld	hl, #425
	add	hl, sp
	ex	de, hl
	ld	l, e
	ld	h, d
	inc	hl
	ld	(hl), #0x02
;src\CFG8266.c:627: regs.Bytes.B = (unsigned char)(iFile&0xff);
	inc	de
	inc	de
	inc	de
	ld	a, d
	ld	c, -2 (ix)
	ld	l, e
	ld	h, a
	ld	(hl), c
;src\CFG8266.c:628: DosCall(0x4A, &regs, REGS_ALL, REGS_ALL); // MOVE FILE HANDLER
	ld	hl, #425
	add	hl, sp
	ld	-4 (ix), l
	ld	-3 (ix), h
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
;src\CFG8266.c:629: if (regs.Bytes.A == 0) //moved, now get the file handler position, i.e.: size
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	inc	hl
	ld	a, (hl)
	ld	-5 (ix), a
	or	a, a
	jp	NZ, 00219$
;src\CFG8266.c:630: SentFileSize = (unsigned long)(regs.Words.HL)&0xffff | ((unsigned long)(regs.Words.DE)<<16)&0xffff0000;
	ld	a, -4 (ix)
	ld	-6 (ix), a
	ld	a, -3 (ix)
	ld	-5 (ix), a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	de, #0x0006
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
	ld	a, -8 (ix)
	ld	-15 (ix), a
	ld	a, -7 (ix)
	ld	-14 (ix), a
	ld	-13 (ix), #0x00
	ld	-12 (ix), #0x00
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	de, #0x0004
	add	hl, de
	ld	a, (hl)
	ld	-4 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	ld	a, -4 (ix)
	ld	-6 (ix), a
	ld	a, -3 (ix)
	ld	-5 (ix), a
	rla
	sbc	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
	ld	a, -6 (ix)
	ld	-8 (ix), a
	ld	a, -5 (ix)
	ld	-7 (ix), a
	xor	a, a
	ld	-10 (ix), a
	ld	-9 (ix), a
	ld	-6 (ix), #0x00
	ld	-5 (ix), #0x00
	ld	a, -8 (ix)
	ld	-4 (ix), a
	ld	a, -7 (ix)
	ld	-3 (ix), a
	ld	a, -15 (ix)
	or	a, -6 (ix)
	ld	-11 (ix), a
	ld	a, -14 (ix)
	or	a, -5 (ix)
	ld	-10 (ix), a
	ld	a, -13 (ix)
	or	a, -4 (ix)
	ld	-9 (ix), a
	ld	a, -12 (ix)
	or	a, -3 (ix)
	ld	-8 (ix), a
	ld	hl, #479
	add	hl, sp
	ex	de, hl
	ld	hl, #474
	add	hl, sp
	ld	bc, #4
	ldir
	jr	00220$
00219$:
;src\CFG8266.c:632: SentFileSize = 0;
	xor	a, a
	ld	-6 (ix), a
	ld	-5 (ix), a
	ld	-4 (ix), a
	ld	-3 (ix), a
00220$:
;src\CFG8266.c:634: ultostr(SentFileSize,chFileSize,10);
	ld	hl, #437
	add	hl, sp
	ld	c, l
	ld	b, h
	push	hl
	ld	de, #0x000a
	push	de
	push	bc
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	call	_ultostr
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	push	bc
	call	_Close
	pop	af
	pop	hl
;src\CFG8266.c:636: printf ("File: %s Size: %s \r\n",ucFile,chFileSize);
	ld	de, #_ucFile
	ld	bc, #___str_69+0
	push	hl
	push	de
	push	bc
	call	_printf
	pop	af
	pop	af
	pop	af
;src\CFG8266.c:637: if (SentFileSize)
	ld	a, -3 (ix)
	or	a, -4 (ix)
	or	a, -5 (ix)
	or	a, -6 (ix)
	jp	Z, 00250$
;src\CFG8266.c:639: iFile = Open (ucFile,O_RDONLY);
	ld	hl, #0x0000
	push	hl
	ld	hl, #_ucFile
	push	hl
	call	_Open
	pop	af
	pop	af
	ld	-15 (ix), l
	ld	-14 (ix), h
;src\CFG8266.c:640: if (iFile!=-1)
	ld	a, -15 (ix)
	and	a, -14 (ix)
	inc	a
	jp	Z,00247$
;src\CFG8266.c:642: FileRead = MyRead(iFile, ucServer,256); //try to read 256 bytes of data
	ld	hl, #0x0100
	push	hl
	ld	hl, #_ucServer
	push	hl
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	push	hl
	call	_MyRead
	pop	af
	pop	af
	pop	af
	ld	-13 (ix), l
	ld	-12 (ix), h
;src\CFG8266.c:643: if (FileRead == 256)
	ld	a, -13 (ix)
	or	a, a
	jp	NZ,00244$
	ld	a, -12 (ix)
	dec	a
	jp	NZ,00244$
;src\CFG8266.c:646: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00222$
;src\CFG8266.c:647: TxByte('Z'); //Request start of RS232 update
	ld	a, #0x5a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00223$
00222$:
;src\CFG8266.c:649: TxByte('Y'); //Request start of RS232 cert update
	ld	a, #0x59
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00223$:
;src\CFG8266.c:650: TxByte(0);
	xor	a, a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:651: TxByte(12);
	ld	a, #0x0c
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:652: TxByte((unsigned char)(SentFileSize&0xff));
	ld	a, -6 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:653: TxByte((unsigned char)((SentFileSize&0xff00)>>8));
	ld	b, -5 (ix)
	ld	c, #0x00
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:654: TxByte((unsigned char)((SentFileSize&0xff0000)>>16));
	ld	a, -4 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:655: TxByte((unsigned char)((SentFileSize&0xff000000)>>24));
	ld	a, -3 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:656: TxByte((unsigned char)((SentFileSize&0xff00000000)>>32));
	ld	a, -6 (ix)
	ld	iy, #0
	add	iy, sp
	ld	0 (iy), a
	ld	a, -5 (ix)
	ld	1 (iy), a
	ld	a, -4 (ix)
	ld	2 (iy), a
	ld	a, -3 (ix)
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
00745$:
	sra	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	00745$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:657: TxByte((unsigned char)((SentFileSize&0xff0000000000)>>40));
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
00747$:
	sra	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	00747$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:658: TxByte((unsigned char)((SentFileSize&0xff000000000000)>>48));
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
00749$:
	sra	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	00749$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:659: TxByte((unsigned char)((SentFileSize&0xff00000000000000)>>56));
	ld	a, -6 (ix)
	ld	iy, #8
	add	iy, sp
	ld	0 (iy), a
	ld	a, -5 (ix)
	ld	1 (iy), a
	ld	a, -4 (ix)
	ld	2 (iy), a
	ld	a, -3 (ix)
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
00751$:
	srl	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	00751$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:660: TxByte(ucServer[0]);
	ld	a, (#_ucServer + 0)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:661: TxByte(ucServer[1]);
	ld	a, (#_ucServer + 1)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:662: TxByte(ucServer[2]);
	ld	a, (#_ucServer + 2)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:663: TxByte(ucServer[3]);
	ld	a, (#_ucServer + 3)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:665: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00225$
;src\CFG8266.c:666: bResponse = WaitForRXData(responseRSFWUpdate,2,60,true,false);
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x003c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_responseRSFWUpdate
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-11 (ix), l
	jr	00226$
00225$:
;src\CFG8266.c:668: bResponse = WaitForRXData(responseRSCERTUpdate,2,60,true,false);
	xor	a, a
	ld	d,a
	ld	e,#0x01
	push	de
	ld	hl, #0x003c
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_responseRSCERTUpdate
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-11 (ix), l
00226$:
;src\CFG8266.c:670: if (!bResponse)
	ld	a, -11 (ix)
	or	a, a
	jr	NZ,00241$
;src\CFG8266.c:671: printf("Error requesting to start firmware update.\r\n");
	ld	hl, #___str_71
	push	hl
	call	_puts
	pop	af
	jp	00245$
00241$:
;src\CFG8266.c:674: PrintChar('U');
	ld	a, #0x55
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
;src\CFG8266.c:675: do
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00235$:
;src\CFG8266.c:678: PrintChar(8); //backspace
	ld	a, #0x08
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
;src\CFG8266.c:679: PrintChar(advance[i%4]); // next char
	ld	a, -2 (ix)
	and	a, #0x03
	ld	-10 (ix), a
	ld	-9 (ix), #0x00
	ld	a, -10 (ix)
	add	a, -18 (ix)
	ld	-8 (ix), a
	ld	a, -9 (ix)
	adc	a, -17 (ix)
	ld	-7 (ix), a
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	a, (hl)
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
;src\CFG8266.c:680: ++i;
	inc	-2 (ix)
	jr	NZ,00753$
	inc	-1 (ix)
00753$:
;src\CFG8266.c:681: if (!ucFirstBlock)
	ld	a, -16 (ix)
	or	a, a
	jr	NZ,00230$
;src\CFG8266.c:683: FileRead = MyRead(iFile, ucServer,256); //try to read 256 bytes of data
	ld	hl, #0x0100
	push	hl
	ld	hl, #_ucServer
	push	hl
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	push	hl
	call	_MyRead
	pop	af
	pop	af
	pop	af
	ld	-13 (ix), l
;src\CFG8266.c:684: if (FileRead ==0)
	ld	-12 (ix), h
	ld	a, h
	or	a, -13 (ix)
	jr	NZ,00231$
;src\CFG8266.c:686: printf("\rError reading file...\r\n");
	ld	hl, #___str_73
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:687: break;
	jp	00237$
00230$:
;src\CFG8266.c:691: ucFirstBlock = 0;
	xor	a, a
	ld	-16 (ix), a
00231$:
;src\CFG8266.c:693: TxByte('z'); //Write block
	ld	a, #0x7a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:694: TxByte((unsigned char)((FileRead&0xff00)>>8));
	ld	b, -12 (ix)
	ld	c, #0x00
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:695: TxByte((unsigned char)(FileRead&0xff));
	ld	a, -13 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:696: for (ii=0;ii<256;ii++)
	ld	bc, #0x0000
00302$:
;src\CFG8266.c:697: TxByte(ucServer[ii]);
	ld	hl, #_ucServer
	add	hl, bc
	ld	a, (hl)
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:696: for (ii=0;ii<256;ii++)
	inc	bc
	ld	a, b
	sub	a, #0x01
	jr	C,00302$
;src\CFG8266.c:699: bResponse = WaitForRXData(responseWRBlock,2,600,true,false);
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
	pop	af
	pop	af
	pop	af
	pop	af
;src\CFG8266.c:701: if (!bResponse)
	ld	-11 (ix), l
	ld	a, l
	or	a, a
	jr	NZ,00234$
;src\CFG8266.c:703: printf("\rError requesting to write firmware block.\r\n");
	ld	hl, #___str_75
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:704: break;
	jr	00237$
00234$:
;src\CFG8266.c:706: SentFileSize = SentFileSize - FileRead;
	ld	c, -13 (ix)
	ld	b, -12 (ix)
	ld	de, #0x0000
	ld	a, -6 (ix)
	sub	a, c
	ld	-6 (ix), a
	ld	a, -5 (ix)
	sbc	a, b
	ld	-5 (ix), a
	ld	a, -4 (ix)
	sbc	a, e
	ld	-4 (ix), a
	ld	a, -3 (ix)
	sbc	a, d
;src\CFG8266.c:708: while(SentFileSize);
	ld	-3 (ix), a
	or	a, -4 (ix)
	or	a, -5 (ix)
	or	a, -6 (ix)
	jp	NZ, 00235$
00237$:
;src\CFG8266.c:711: if (bResponse)
	ld	a, -11 (ix)
	or	a, a
	jr	Z,00245$
;src\CFG8266.c:712: FinishUpdate(false);
	xor	a, a
	push	af
	inc	sp
	call	_FinishUpdate
	inc	sp
	jr	00245$
00244$:
;src\CFG8266.c:716: Print("\rError reading firmware file!\n");
	ld	hl, #___str_76
	push	hl
	call	_Print
	pop	af
00245$:
;src\CFG8266.c:717: Close(iFile);
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	push	hl
	call	_Close
	pop	af
	jp	00294$
00247$:
;src\CFG8266.c:721: printf("Error, couldn't open %s ...\r\n",ucFile);
	ld	hl, #_ucFile
	push	hl
	ld	hl, #___str_77
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:722: return 0;
	ld	hl, #0x0000
	jp	00304$
00250$:
;src\CFG8266.c:727: printf("Error, %s is 0 bytes long...\r\n",ucFile);
	ld	hl, #_ucFile
	push	hl
	ld	hl, #___str_78
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:728: return 0;
	ld	hl, #0x0000
	jp	00304$
00253$:
;src\CFG8266.c:733: printf("Error, couldn't open %s ...\r\n",ucFile);
	ld	hl, #_ucFile
	push	hl
	ld	hl, #___str_77
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:734: return 0;
	ld	hl, #0x0000
	jp	00304$
00280$:
;src\CFG8266.c:739: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00256$
;src\CFG8266.c:740: printf ("Ok, updating FW using server: %s port: %u\r\nFile path: %s\nPlease Wait, it can take up to a few minutes!\r\n",ucServer,uiPort,ucFile);
	ld	hl, #_ucFile
	push	hl
	ld	hl, (_uiPort)
	push	hl
	ld	hl, #_ucServer
	push	hl
	ld	hl, #___str_79
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
	pop	af
	jr	00257$
00256$:
;src\CFG8266.c:742: printf ("Ok, updating certificates using server: %s port: %u\r\nFile path: %s\nPlease Wait, it can take up to a few minutes!\r\n",ucServer,uiPort,ucFile);
	ld	hl, #_ucFile
	push	hl
	ld	hl, (_uiPort)
	push	hl
	ld	hl, #_ucServer
	push	hl
	ld	hl, #___str_80
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
	pop	af
00257$:
;src\CFG8266.c:743: uiCMDLen = strlen(ucServer) + 3; //3 = 0 terminator + 2 bytes port
	ld	hl, #_ucServer
	push	hl
	call	_strlen
	pop	af
	ex	de,hl
	inc	de
	inc	de
	inc	de
;src\CFG8266.c:744: uiCMDLen += strlen(ucFile);
	ld	hl, #_ucFile
	push	hl
	call	_strlen
	pop	af
	add	hl, de
	ld	-2 (ix), l
	ld	-1 (ix), h
;src\CFG8266.c:745: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00259$
;src\CFG8266.c:746: TxByte('U'); //Request Update Main Firmware remotely
	ld	a, #0x55
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00260$
00259$:
;src\CFG8266.c:748: TxByte('u'); //Request Update spiffs remotely
	ld	a, #0x75
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00260$:
;src\CFG8266.c:749: TxByte((unsigned char)((uiCMDLen&0xff00)>>8));
	ld	a, -1 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:750: TxByte((unsigned char)(uiCMDLen&0xff));
	ld	a, -2 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:751: TxByte((unsigned char)(uiPort&0xff));
	ld	a,(#_uiPort + 0)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:752: TxByte((unsigned char)((uiPort&0xff00)>>8));
	ld	a,(#_uiPort + 1)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:754: do
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	ld	e, #0x00
00262$:
;src\CFG8266.c:756: tx_data = ucServer[rx_data];
	ld	hl, #_ucServer
	ld	d, #0x00
	add	hl, de
	ld	d, (hl)
;src\CFG8266.c:757: TxByte(tx_data);
	push	bc
	push	de
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:758: --uiCMDLen;
	dec	bc
;src\CFG8266.c:759: ++rx_data;
	inc	e
;src\CFG8266.c:761: while((uiCMDLen)&&(tx_data!=0));
	ld	a, b
	or	a, c
	jr	Z,00264$
	ld	a, d
	or	a, a
	jr	NZ,00262$
00264$:
;src\CFG8266.c:763: do
	xor	a, a
	ld	-1 (ix), a
00267$:
;src\CFG8266.c:765: tx_data = ucFile[rx_data];
	ld	a, #<(_ucFile)
	add	a, -1 (ix)
	ld	e, a
	ld	a, #>(_ucFile)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
;src\CFG8266.c:766: if (tx_data==0)
	or	a, a
	jr	Z,00269$
;src\CFG8266.c:768: TxByte(tx_data);
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:769: --uiCMDLen;
	dec	bc
;src\CFG8266.c:770: ++rx_data;
	inc	-1 (ix)
;src\CFG8266.c:772: while(uiCMDLen);
	ld	a, b
	or	a, c
	jr	NZ,00267$
00269$:
;src\CFG8266.c:774: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00271$
;src\CFG8266.c:775: bResponse = WaitForRXData(responseOTAFW,2,18000,true,false);
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
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c, l
	jr	00272$
00271$:
;src\CFG8266.c:777: bResponse = WaitForRXData(responseOTASPIFF,2,18000,true,false);
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
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c, l
00272$:
;src\CFG8266.c:779: if (bResponse)
	ld	a, c
	or	a, a
	jr	Z,00277$
;src\CFG8266.c:781: if ((!ucIsFw))
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	NZ,00274$
;src\CFG8266.c:782: printf("\rSuccess updating certificates!\r\n");
	ld	hl, #___str_82
	push	hl
	call	_puts
	pop	af
	jr	00275$
00274$:
;src\CFG8266.c:784: printf("\rSuccess, firmware updated, wait a minute so it is fully flashed.\r\n");
	ld	hl, #___str_84
	push	hl
	call	_puts
	pop	af
00275$:
;src\CFG8266.c:785: FinishUpdate(true);
	ld	a, #0x01
	push	af
	inc	sp
	call	_FinishUpdate
	inc	sp
;src\CFG8266.c:786: return 0;
	ld	hl, #0x0000
	jr	00304$
00277$:
;src\CFG8266.c:789: printf("\rFailed to update from remote server...\r\n");
	ld	hl, #___str_86
	push	hl
	call	_puts
	pop	af
	jr	00294$
00290$:
;src\CFG8266.c:793: printf("ESP device not found...\r\n");
	ld	hl, #___str_88
	push	hl
	call	_puts
	pop	af
	jr	00294$
00293$:
;src\CFG8266.c:796: printf(strUsage);
	ld	hl, #_strUsage
	push	hl
	call	_printf
	pop	af
00294$:
;src\CFG8266.c:798: return 0;
	ld	hl, #0x0000
00304$:
;src\CFG8266.c:799: }
	ld	sp, ix
	pop	ix
	ret
___str_29:
	.ascii "> SM-X ESP8266 WIFI Module Configuration v1.20 <"
	.db 0x0d
	.db 0x0a
	.ascii "(c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_30:
	.ascii "Using Baud Rate #%u"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_31:
	.db 0x0d
	.db 0x0a
	.ascii "Setting WiFi idle timeout to %u..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_33:
	.db 0x0d
	.db 0x0a
	.ascii "Setting WiFi to always on!"
	.db 0x0d
	.db 0x00
___str_35:
	.db 0x0d
	.db 0x00
___str_37:
	.ascii "Choose AP:"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_38:
	.ascii "%u - %s"
	.db 0x00
___str_40:
	.ascii " (PWD)"
	.db 0x0d
	.db 0x00
___str_42:
	.ascii " (OPEN)"
	.db 0x0d
	.db 0x00
___str_43:
	.db 0x0d
	.db 0x0a
	.ascii "Which one to connect? (ESC exit)"
	.db 0x00
___str_44:
	.ascii " %c"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_45:
	.ascii "Password? "
	.db 0x00
___str_48:
	.ascii "Success, AP configured to be used."
	.db 0x0d
	.db 0x00
___str_50:
	.ascii "Error, AP not configured!"
	.db 0x0d
	.db 0x00
___str_52:
	.db 0x0d
	.db 0x0a
	.ascii "User canceled by ESC key..."
	.db 0x0d
	.db 0x00
___str_54:
	.db 0x0d
	.db 0x0a
	.ascii "Scan results: no answer..."
	.db 0x0d
	.db 0x00
___str_56:
	.db 0x0d
	.ascii "Scan request: no answer..."
	.db 0x00
___str_58:
	.db 0x0d
	.ascii "Nagle set as requested..."
	.db 0x00
___str_60:
	.db 0x0d
	.ascii "Nagle not set as requested, error!"
	.db 0x00
___str_62:
	.db 0x0d
	.ascii "Requested to turn off WiFi Radio..."
	.db 0x00
___str_64:
	.db 0x0d
	.ascii "Request to turnoff WiFi Radio error!"
	.db 0x00
___str_66:
	.db 0x0d
	.ascii "WiFi radio on Time-out set successfully..."
	.db 0x00
___str_68:
	.db 0x0d
	.ascii "Error setting WiFi radio on Time-out!"
	.db 0x00
___str_69:
	.ascii "File: %s Size: %s "
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_71:
	.ascii "Error requesting to start firmware update."
	.db 0x0d
	.db 0x00
___str_73:
	.db 0x0d
	.ascii "Error reading file..."
	.db 0x0d
	.db 0x00
___str_75:
	.db 0x0d
	.ascii "Error requesting to write firmware block."
	.db 0x0d
	.db 0x00
___str_76:
	.db 0x0d
	.ascii "Error reading firmware file!"
	.db 0x0a
	.db 0x00
___str_77:
	.ascii "Error, couldn't open %s ..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_78:
	.ascii "Error, %s is 0 bytes long..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_79:
	.ascii "Ok, updating FW using server: %s port: %u"
	.db 0x0d
	.db 0x0a
	.ascii "File path: %s"
	.db 0x0a
	.ascii "Please Wait, it can take up to a few minutes!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_80:
	.ascii "Ok, updating certificates using server: %s port: %u"
	.db 0x0d
	.db 0x0a
	.ascii "File path: %s"
	.db 0x0a
	.ascii "Please Wait, it can take up to a few minutes!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_82:
	.db 0x0d
	.ascii "Success updating certificates!"
	.db 0x0d
	.db 0x00
___str_84:
	.db 0x0d
	.ascii "Success, firmware updated, wait a minute so it is fully flas"
	.ascii "hed."
	.db 0x0d
	.db 0x00
___str_86:
	.db 0x0d
	.ascii "Failed to update from remote server..."
	.db 0x0d
	.db 0x00
___str_88:
	.ascii "ESP device not found..."
	.db 0x0d
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
