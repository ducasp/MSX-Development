;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.9.0 #11195 (MINGW32)
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
	.globl __size
	.globl __seek
	.globl __tell
	.globl _Close
	.globl _Open
	.globl _KeyboardHit
	.globl _PrintChar
	.globl _InputString
	.globl _InputChar
	.globl _Print
	.globl _strlen
	.globl _atol
	.globl _puts
	.globl _printf
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
;../fusion-c/header/io.h:155: extern	unsigned long _tell(int fH) { return B8dH.rand_record; }
;	---------------------------------
; Function _tell
; ---------------------------------
__tell::
	call	___sdcc_enter_ix
	ld	bc, #__buf8_fcbs+0
	ld	e, 4 (ix)
	ld	d, 5 (ix)
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, bc
	ld	de, #0x0021
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, c
	ld	h, b
	pop	ix
	ret
;../fusion-c/header/io.h:157: extern	void 	_seek(int fH, long pos, int ot)
;	---------------------------------
; Function _seek
; ---------------------------------
__seek::
	call	___sdcc_enter_ix
	push	af
	push	af
	push	af
	push	af
;../fusion-c/header/io.h:159: if(ot==SEEK_CUR) B8dH.rand_record+=pos;
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ex	de, hl
	push	de
	ld	hl, #2
	add	hl, sp
	ex	de, hl
	ld	hl, #16
	add	hl, sp
	ld	bc, #4
	ldir
	pop	de
	ld	a, 10 (ix)
	dec	a
	or	a, 11 (ix)
	jr	NZ,00102$
	ld	hl, #__buf8_fcbs+0
	add	hl, de
	ex	de, hl
	ld	hl, #0x0021
	add	hl, de
	ex	de, hl
	ld	l, e
	ld	h, d
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
	ld	h, a
	ld	a, c
	add	a, -8 (ix)
	ld	-4 (ix), a
	ld	a, b
	adc	a, -7 (ix)
	ld	-3 (ix), a
	ld	a, l
	adc	a, -6 (ix)
	ld	-2 (ix), a
	ld	a, h
	adc	a, -5 (ix)
	ld	-1 (ix), a
	ld	hl, #0x0004
	add	hl, sp
	ld	bc, #0x0004
	ldir
	jr	00104$
00102$:
;../fusion-c/header/io.h:160: else B8dH.rand_record = (ot==SEEK_END ? B8dH.file_size+pos : pos );
	ld	hl, #__buf8_fcbs+0
	add	hl, de
	ld	a, l
	add	a, #0x21
	ld	e, a
	ld	a, h
	adc	a, #0x00
	ld	d, a
	ld	a, 10 (ix)
	sub	a, #0x02
	or	a, 11 (ix)
	jr	NZ,00106$
	ld	bc, #0x0010
	add	hl, bc
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
	ld	h, a
	ld	a, c
	add	a, -8 (ix)
	ld	-4 (ix), a
	ld	a, b
	adc	a, -7 (ix)
	ld	-3 (ix), a
	ld	a, l
	adc	a, -6 (ix)
	ld	-2 (ix), a
	ld	a, h
	adc	a, -5 (ix)
	ld	-1 (ix), a
	jr	00107$
00106$:
	push	de
	ld	hl, #6
	add	hl, sp
	ex	de, hl
	ld	hl, #16
	add	hl, sp
	ld	bc, #4
	ldir
	pop	de
00107$:
	ld	hl, #0x0004
	add	hl, sp
	ld	bc, #0x0004
	ldir
00104$:
;../fusion-c/header/io.h:161: }
	ld	sp, ix
	pop	ix
	ret
;../fusion-c/header/io.h:163: extern	unsigned long _size(int fH) { return B8dH.file_size; }
;	---------------------------------
; Function _size
; ---------------------------------
__size::
	call	___sdcc_enter_ix
	ld	bc, #__buf8_fcbs+0
	ld	e, 4 (ix)
	ld	d, 5 (ix)
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, bc
	ld	de, #0x0010
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, c
	ld	h, b
	pop	ix
	ret
;src\CFG8266.c:124: unsigned int MyRead (int Handle, unsigned char* Buffer, unsigned int Size)
;	---------------------------------
; Function MyRead
; ---------------------------------
_MyRead::
	call	___sdcc_enter_ix
	ld	hl, #-14
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:126: unsigned int iRet = 0;
	ld	-2 (ix), #0x00
	ld	-1 (ix), #0x00
;src\CFG8266.c:130: regs.Words.DE = (unsigned int) Buffer;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, #0x0004
	add	hl, de
	ld	c, 6 (ix)
	ld	b, 7 (ix)
	ld	(hl), c
	inc	hl
	ld	(hl), b
;src\CFG8266.c:131: regs.Words.HL = Size;
	ld	hl, #0x0006
	add	hl, de
	ld	a, 8 (ix)
	ld	(hl), a
	inc	hl
	ld	a, 9 (ix)
	ld	(hl), a
;src\CFG8266.c:132: regs.Bytes.B = (unsigned char)(Handle&0xff);
	ld	hl, #3
	add	hl, sp
	ld	a, 4 (ix)
	ld	(hl), a
;src\CFG8266.c:133: DosCall(0x48, &regs, REGS_MAIN, REGS_MAIN);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	c, e
	ld	b, d
	push	de
	ld	de, #0x0202
	push	de
	push	bc
	ld	a, #0x48
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
	pop	de
;src\CFG8266.c:134: if (regs.Bytes.A == 0)
	ld	l, e
	ld	h, d
	inc	hl
	ld	a, (hl)
	or	a, a
	jr	NZ,00102$
;src\CFG8266.c:137: iRet = regs.Words.HL;
	push	de
	pop	iy
	ld	a, 6 (iy)
	ld	-2 (ix), a
	ld	a, 7 (iy)
	ld	-1 (ix), a
00102$:
;src\CFG8266.c:140: return iRet;
	ld	l, -2 (ix)
	ld	h, -1 (ix)
;src\CFG8266.c:141: }
	ld	sp, ix
	pop	ix
	ret
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
_strUsage:
	.ascii "Usage: CFG8266 /s to scan networks and choose one to connect"
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 /n to turn off Nagle Algorithm (default) or /"
	.ascii "m to turn it on"
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 CERTFILE /c to update ESP8266 firmware locall"
	.ascii "y"
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 FWFILE to update ESP8266 firmware locally"
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 /u SERVER PORT FILEPATH to update ESP8266 fir"
	.ascii "mware remotely"
	.db 0x0a
	.db 0x0a
	.ascii "       CFG8266 /c SERVER PORT FILEPATH to update TLS certifi"
	.ascii "cates remotely"
	.db 0x0a
	.ascii "Ex.:   CFG8266 /u 192.168.31.1 80 /fw/fw.bin"
	.db 0x00
;src\CFG8266.c:144: unsigned int IsValidInput (char**argv, int argc)
;	---------------------------------
; Function IsValidInput
; ---------------------------------
_IsValidInput::
	call	___sdcc_enter_ix
	push	af
	push	af
	push	af
	dec	sp
;src\CFG8266.c:146: unsigned int ret = 1;
	ld	bc, #0x0001
;src\CFG8266.c:147: unsigned char * Input = (unsigned char*)argv[0];
	ld	a, 4 (ix)
	ld	-7 (ix), a
	ld	a, 5 (ix)
	ld	-6 (ix), a
	pop	hl
	push	hl
	ld	a, (hl)
	ld	-5 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-4 (ix), a
;src\CFG8266.c:149: ucScan = 0;
	ld	iy, #_ucScan
	ld	0 (iy), #0x00
;src\CFG8266.c:151: if (argc)
	ld	a, 7 (ix)
	or	a, 6 (ix)
	jp	Z, 00150$
;src\CFG8266.c:153: if ((argc==1)||(argc==2)||(argc==4))
	ld	a, 6 (ix)
	dec	a
	or	a, 7 (ix)
	jr	NZ, 00249$
	ld	a, #0x01
	.db	#0x20
00249$:
	xor	a, a
00250$:
	ld	d, a
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	jr	NZ, 00251$
	ld	a, #0x01
	.db	#0x20
00251$:
	xor	a, a
00252$:
	ld	e, a
	ld	a, d
	or	a,a
	jr	NZ,00144$
	or	a,e
	jr	NZ,00144$
	ld	a, 6 (ix)
	sub	a, #0x04
	or	a, 7 (ix)
	jp	NZ,00145$
00144$:
;src\CFG8266.c:157: if ((Input[0]=='/')&&((Input[1]=='s')||(Input[1]=='S')))
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	ld	a, (hl)
	ld	-1 (ix), a
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	inc	hl
;src\CFG8266.c:169: Input = (unsigned char*)argv[1];
	ld	a, -7 (ix)
	add	a, #0x02
	ld	-3 (ix), a
	ld	a, -6 (ix)
	adc	a, #0x00
	ld	-2 (ix), a
;src\CFG8266.c:157: if ((Input[0]=='/')&&((Input[1]=='s')||(Input[1]=='S')))
	ld	a, -1 (ix)
	sub	a, #0x2f
	jr	NZ, 00255$
	ld	a, #0x01
	.db	#0x20
00255$:
	xor	a, a
00256$:
	ld	-1 (ix), a
;src\CFG8266.c:155: if ((argc==1)||(argc==2))
	ld	a, d
	or	a,a
	jr	NZ,00140$
	or	a,e
	jp	Z, 00141$
00140$:
;src\CFG8266.c:157: if ((Input[0]=='/')&&((Input[1]=='s')||(Input[1]=='S')))
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00120$
	ld	a, (hl)
	cp	a, #0x73
	jr	Z,00119$
	sub	a, #0x53
	jr	NZ,00120$
00119$:
;src\CFG8266.c:158: ucScan = 1;
	ld	hl,#_ucScan + 0
	ld	(hl), #0x01
	jp	00151$
00120$:
;src\CFG8266.c:159: else if ((Input[0]=='/')&&((Input[1]=='n')||(Input[1]=='N')))
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00115$
	ld	a, (hl)
	cp	a, #0x6e
	jr	Z,00114$
	sub	a, #0x4e
	jr	NZ,00115$
00114$:
;src\CFG8266.c:160: ucNagleOff = 1;
	ld	hl,#_ucNagleOff + 0
	ld	(hl), #0x01
	jp	00151$
00115$:
;src\CFG8266.c:161: else if ((Input[0]=='/')&&((Input[1]=='m')||(Input[1]=='M')))
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00110$
	ld	a, (hl)
	cp	a, #0x6d
	jr	Z,00109$
	sub	a, #0x4d
	jr	NZ,00110$
00109$:
;src\CFG8266.c:162: ucNagleOn = 1;
	ld	hl,#_ucNagleOn + 0
	ld	(hl), #0x01
	jp	00151$
00110$:
;src\CFG8266.c:165: strcpy (ucFile,Input);
	push	bc
	push	de
	ld	de, #_ucFile
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	xor	a, a
00266$:
	cp	a, (hl)
	ldi
	jr	NZ, 00266$
	pop	de
	pop	bc
;src\CFG8266.c:166: ucLocalUpdate = 1;
	ld	hl,#_ucLocalUpdate + 0
	ld	(hl), #0x01
;src\CFG8266.c:167: if (argc==2)
	ld	a, e
	or	a, a
	jr	Z,00107$
;src\CFG8266.c:169: Input = (unsigned char*)argv[1];
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:170: if ((Input[0]=='/')&&((Input[1]=='c')||(Input[1]=='C')))
	ld	a, (de)
	sub	a, #0x2f
	jr	NZ,00102$
	ex	de,hl
	inc	hl
	ld	a, (hl)
	cp	a, #0x63
	jr	Z,00101$
	sub	a, #0x43
	jr	NZ,00102$
00101$:
;src\CFG8266.c:171: ucIsFw=0;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x00
	jp	00151$
00102$:
;src\CFG8266.c:173: ret=0;
	ld	bc, #0x0000
	jp	00151$
00107$:
;src\CFG8266.c:177: ucIsFw=1;
	ld	hl,#_ucIsFw + 0
	ld	(hl), #0x01
	jp	00151$
00141$:
;src\CFG8266.c:185: Input = (unsigned char*)argv[2];
	ld	a, -7 (ix)
	add	a, #0x04
	ld	e, a
	ld	a, -6 (ix)
	adc	a, #0x00
	ld	d, a
;src\CFG8266.c:191: Input = (unsigned char*)argv[3];
	ld	a, -7 (ix)
	add	a, #0x06
	ld	-5 (ix), a
	ld	a, -6 (ix)
	adc	a, #0x00
	ld	-4 (ix), a
;src\CFG8266.c:182: if ((Input[0]=='/')&&((Input[1]=='u')||(Input[1]=='U')))
	ld	a, -1 (ix)
	or	a, a
	jp	Z, 00136$
	ld	a, (hl)
	cp	a, #0x75
	jr	Z,00135$
	sub	a, #0x55
	jp	NZ,00136$
00135$:
;src\CFG8266.c:184: ucIsFw = 1;
	ld	iy, #_ucIsFw
	ld	0 (iy), #0x01
;src\CFG8266.c:185: Input = (unsigned char*)argv[2];
	ex	de,hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:186: if (strlen (Input)<7)
	push	bc
	push	de
	call	_strlen
	pop	af
	pop	bc
	ld	a, l
	sub	a, #0x07
	ld	a, h
	sbc	a, #0x00
	jr	NC,00125$
;src\CFG8266.c:188: strcpy(ucPort,Input);
	ld	hl, #_ucPort
	push	bc
	ex	de, hl
	xor	a, a
00275$:
	cp	a, (hl)
	ldi
	jr	NZ, 00275$
	pop	bc
;src\CFG8266.c:189: Input = (unsigned char*)argv[1];
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:190: strcpy(ucServer,Input);
	ld	hl, #_ucServer+0
	push	bc
	ex	de, hl
	xor	a, a
00276$:
	cp	a, (hl)
	ldi
	jr	NZ, 00276$
	pop	bc
;src\CFG8266.c:191: Input = (unsigned char*)argv[3];
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:192: strcpy(ucFile,Input);
	ld	hl, #_ucFile+0
	push	bc
	ex	de, hl
	xor	a, a
00277$:
	cp	a, (hl)
	ldi
	jr	NZ, 00277$
	ld	hl, #_ucPort
	push	hl
	call	_atol
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	de, #_lPort
	ld	hl, #5
	add	hl, sp
	ld	bc, #4
	ldir
	pop	bc
;src\CFG8266.c:194: uiPort = (lPort&0xffff);
	ld	hl, (_lPort)
	ld	(_uiPort), hl
	jp	00151$
00125$:
;src\CFG8266.c:197: ret = 0;
	ld	bc, #0x0000
	jp	00151$
00136$:
;src\CFG8266.c:199: else if ((Input[0]=='/')&&((Input[1]=='c')||(Input[1]=='C')))
	ld	a, -1 (ix)
	or	a, a
	jp	Z, 00131$
	ld	a, (hl)
	cp	a, #0x63
	jr	Z,00130$
	sub	a, #0x43
	jp	NZ,00131$
00130$:
;src\CFG8266.c:201: ucIsFw = 0;
	ld	iy, #_ucIsFw
	ld	0 (iy), #0x00
;src\CFG8266.c:202: Input = (unsigned char*)argv[2];
	ex	de,hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:203: if (strlen (Input)<7)
	push	bc
	push	de
	call	_strlen
	pop	af
	pop	bc
	ld	a, l
	sub	a, #0x07
	ld	a, h
	sbc	a, #0x00
	jr	NC,00128$
;src\CFG8266.c:205: strcpy(ucPort,Input);
	ld	hl, #_ucPort
	push	bc
	ex	de, hl
	xor	a, a
00281$:
	cp	a, (hl)
	ldi
	jr	NZ, 00281$
	pop	bc
;src\CFG8266.c:206: Input = (unsigned char*)argv[1];
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:207: strcpy(ucServer,Input);
	ld	hl, #_ucServer+0
	push	bc
	ex	de, hl
	xor	a, a
00282$:
	cp	a, (hl)
	ldi
	jr	NZ, 00282$
	pop	bc
;src\CFG8266.c:208: Input = (unsigned char*)argv[3];
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;src\CFG8266.c:209: strcpy(ucFile,Input);
	ld	hl, #_ucFile+0
	push	bc
	ex	de, hl
	xor	a, a
00283$:
	cp	a, (hl)
	ldi
	jr	NZ, 00283$
	ld	hl, #_ucPort
	push	hl
	call	_atol
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	de, #_lPort
	ld	hl, #5
	add	hl, sp
	ld	bc, #4
	ldir
	pop	bc
;src\CFG8266.c:211: uiPort = (lPort&0xffff);
	ld	hl, (_lPort)
	ld	(_uiPort), hl
	jr	00151$
00128$:
;src\CFG8266.c:214: ret = 0;
	ld	bc, #0x0000
	jr	00151$
00131$:
;src\CFG8266.c:217: ret = 0;
	ld	bc, #0x0000
	jr	00151$
00145$:
;src\CFG8266.c:221: ret = 0;
	ld	bc, #0x0000
	jr	00151$
00150$:
;src\CFG8266.c:224: ret=0;
	ld	bc, #0x0000
00151$:
;src\CFG8266.c:226: return ret;
	ld	l, c
	ld	h, b
;src\CFG8266.c:227: }
	ld	sp, ix
	pop	ix
	ret
;src\CFG8266.c:229: void TxByte(char chTxByte)
;	---------------------------------
; Function TxByte
; ---------------------------------
_TxByte::
;src\CFG8266.c:232: do
00103$:
;src\CFG8266.c:234: UartStatus = myPort7&2 ;
	in	a, (_myPort7)
	bit	1, a
	jr	NZ,00103$
;src\CFG8266.c:235: if (!UartStatus)
;src\CFG8266.c:240: myPort7 = chTxByte;
	ld	hl, #2+0
	add	hl, sp
	ld	a, (hl)
	out	(_myPort7), a
;src\CFG8266.c:244: while (1);
;src\CFG8266.c:245: }
	ret
;src\CFG8266.c:247: char *ultostr(unsigned long value, char *ptr, int base)
;	---------------------------------
; Function ultostr
; ---------------------------------
_ultostr::
	call	___sdcc_enter_ix
	ld	hl, #-15
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:250: unsigned long tmp = value;
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	e, 6 (ix)
	ld	d, 7 (ix)
;src\CFG8266.c:251: int count = 0;
	ld	-2 (ix), #0x00
	ld	-1 (ix), #0x00
;src\CFG8266.c:253: if (NULL == ptr)
	ld	a, 9 (ix)
	or	a, 8 (ix)
	jr	NZ,00102$
;src\CFG8266.c:255: return NULL;
	ld	hl, #0x0000
	jp	00117$
00102$:
;src\CFG8266.c:258: if (tmp == 0)
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jr	NZ,00122$
;src\CFG8266.c:260: count++;
	ld	-2 (ix), #0x01
	ld	-1 (ix), #0x00
;src\CFG8266.c:263: while(tmp > 0)
00122$:
00105$:
;src\CFG8266.c:265: tmp = tmp/base;
	ld	a, 10 (ix)
	ld	-15 (ix), a
	ld	a, 11 (ix)
	ld	-14 (ix), a
	rla
	sbc	a, a
	ld	-13 (ix), a
	ld	-12 (ix), a
;src\CFG8266.c:263: while(tmp > 0)
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jr	Z,00107$
;src\CFG8266.c:265: tmp = tmp/base;
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
;src\CFG8266.c:266: count++;
	inc	-2 (ix)
	jr	NZ,00105$
	inc	-1 (ix)
	jr	00105$
00107$:
;src\CFG8266.c:269: ptr += count;
	ld	a, 8 (ix)
	add	a, -2 (ix)
	ld	8 (ix), a
	ld	a, 9 (ix)
	adc	a, -1 (ix)
	ld	9 (ix), a
;src\CFG8266.c:271: *ptr = '\0';
	ld	c, 8 (ix)
	ld	b, 9 (ix)
	xor	a, a
	ld	(bc), a
;src\CFG8266.c:273: do
00114$:
;src\CFG8266.c:275: res = value - base * (t = value / base);
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
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	hl, #4
	add	hl, sp
	ex	de, hl
	ld	hl, #11
	add	hl, sp
	ld	bc, #4
	ldir
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
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
	ld	-7 (ix), c
	ld	-6 (ix), b
	ld	-5 (ix), e
	ld	-4 (ix), d
;src\CFG8266.c:276: if (res < 10)
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
;src\CFG8266.c:278: * -- ptr = '0' + res;
	ld	a, 8 (ix)
	add	a, #0xff
	ld	-2 (ix), a
	ld	a, 9 (ix)
	adc	a, #0xff
	ld	-1 (ix), a
	ld	c, -7 (ix)
;src\CFG8266.c:276: if (res < 10)
	ld	a, -3 (ix)
	or	a, a
	jr	Z,00112$
;src\CFG8266.c:278: * -- ptr = '0' + res;
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
;src\CFG8266.c:280: else if ((res >= 10) && (res < 16))
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
;src\CFG8266.c:282: * --ptr = 'A' - 10 + res;
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
;src\CFG8266.c:284: } while ((value = t) != 0);
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
;src\CFG8266.c:286: return(ptr);
	ld	l, 8 (ix)
	ld	h, 9 (ix)
00117$:
;src\CFG8266.c:287: }
	ld	sp, ix
	pop	ix
	ret
;src\CFG8266.c:289: bool WaitForRXData(unsigned char *uchData, unsigned int uiDataSize, unsigned int uiTimeout, bool bVerbose)
;	---------------------------------
; Function WaitForRXData
; ---------------------------------
_WaitForRXData::
	call	___sdcc_enter_ix
	ld	hl, #-15
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:291: bool bReturn = false;
	ld	-11 (ix), #0x00
;src\CFG8266.c:296: unsigned char advance[4] = {'-','\\','|','/'};
	ld	hl, #0
	add	hl, sp
	ld	-10 (ix), l
	ld	-9 (ix), h
	ld	(hl), #0x2d
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	inc	hl
	ld	(hl), #0x5c
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	inc	hl
	inc	hl
	ld	(hl), #0x7c
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	(hl), #0x2f
;src\CFG8266.c:300: TickCount = 0;
	ld	hl, #0x0000
	ld	(_TickCount), hl
;src\CFG8266.c:301: Timeout = TickCount + uiTimeout; //Wait up to 5 minutes
	ld	iy, (_TickCount)
	ld	e, 8 (ix)
	ld	d, 9 (ix)
	add	iy, de
	push	iy
	pop	de
;src\CFG8266.c:302: if (Timeout<TickCount) //Leaping?
	ld	hl, #_TickCount
	ld	a, e
	sub	a, (hl)
	ld	a, d
	inc	hl
	sbc	a, (hl)
	jr	NC,00102$
;src\CFG8266.c:303: Leaping = 1;
	ld	c, #0x01
	jr	00103$
00102$:
;src\CFG8266.c:305: Leaping = 0;
	ld	c, #0x00
00103$:
;src\CFG8266.c:306: ResponseSt=0;
	ld	-4 (ix), #0x00
	ld	-3 (ix), #0x00
;src\CFG8266.c:307: if (uiTimeout>900)
	ld	a, #0x84
	cp	a, 8 (ix)
	ld	a, #0x03
	sbc	a, 9 (ix)
	ld	a, #0x00
	rla
	ld	-8 (ix), a
	or	a, a
	jr	Z,00144$
;src\CFG8266.c:308: PrintChar('W');
	push	bc
	push	de
	ld	a, #0x57
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:309: do
00144$:
	ld	a, 6 (ix)
	sub	a, #0x02
	or	a, 7 (ix)
	jr	NZ, 00199$
	ld	a, #0x01
	.db	#0x20
00199$:
	xor	a, a
00200$:
	ld	-7 (ix), a
	ld	-2 (ix), #0x00
	ld	-1 (ix), #0x00
00129$:
;src\CFG8266.c:311: if (uiTimeout>900)
	ld	a, -8 (ix)
	or	a, a
	jr	Z,00107$
;src\CFG8266.c:314: PrintChar(8); //backspace
	push	bc
	push	de
	ld	a, #0x08
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:315: PrintChar(advance[i%4]); // next char
	ld	a, -2 (ix)
	and	a, #0x03
	ld	b, a
	ld	h, #0x00
	ld	a, -10 (ix)
	add	a, b
	ld	l, a
	ld	a, -9 (ix)
	adc	a, h
	ld	h, a
	ld	a, (hl)
	push	bc
	push	de
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:316: ++i;
	inc	-2 (ix)
	jr	NZ,00201$
	inc	-1 (ix)
00201$:
00107$:
;src\CFG8266.c:318: if(UartRXData())
	in	a, (_myPort7)
	rrca
	jr	NC,00119$
;src\CFG8266.c:320: rx_data = GetUARTData();
	in	a, (_myPort6)
	ld	-5 (ix), a
;src\CFG8266.c:321: if (rx_data == uchData[ResponseSt])
	ld	a, 4 (ix)
	add	a, -4 (ix)
	ld	l, a
	ld	a, 5 (ix)
	adc	a, -3 (ix)
	ld	h, a
	ld	b, (hl)
	ld	a, -5 (ix)
	sub	a, b
	jr	NZ,00116$
;src\CFG8266.c:323: ++ResponseSt;
	inc	-4 (ix)
	jr	NZ,00205$
	inc	-3 (ix)
00205$:
;src\CFG8266.c:324: if (ResponseSt == uiDataSize)
	ld	a, -4 (ix)
	sub	a, 6 (ix)
	jr	NZ,00119$
	ld	a, -3 (ix)
	sub	a, 7 (ix)
	jr	NZ,00119$
;src\CFG8266.c:326: bReturn = true;
	ld	-11 (ix), #0x01
;src\CFG8266.c:327: break;
	jr	00131$
00116$:
;src\CFG8266.c:332: if ((uiDataSize==2)&&(ResponseSt==1))
	ld	a, -7 (ix)
	or	a, a
	jr	Z,00113$
	ld	a, -4 (ix)
	dec	a
	or	a, -3 (ix)
	jr	NZ,00113$
;src\CFG8266.c:334: if (bVerbose)
	ld	a, 10 (ix)
	or	a, a
	jr	Z,00111$
;src\CFG8266.c:335: printf ("Error %u on command %c...\r\n",rx_data,uchData[0]);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	e, (hl)
	ld	d, #0x00
	ld	c, -5 (ix)
	ld	b, #0x00
	push	de
	push	bc
	ld	hl, #___str_1
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
00111$:
;src\CFG8266.c:336: return false;
	ld	l, #0x00
	jr	00132$
00113$:
;src\CFG8266.c:338: ResponseSt = 0;
	ld	-4 (ix), #0x00
	ld	-3 (ix), #0x00
00119$:
;src\CFG8266.c:342: if (Leaping)
	ld	a, c
	or	a, a
	jr	Z,00127$
;src\CFG8266.c:344: if (TickCount&0x8000==0)
	ld	-6 (ix), #0x00
	ld	-5 (ix), #0x00
	ld	iy, #_TickCount
	ld	a, -5 (ix)
	or	a, -6 (ix)
	jp	Z, 00129$
;src\CFG8266.c:346: Leaping = 0;
	ld	c, #0x00
;src\CFG8266.c:347: if (TickCount>Timeout)
	ld	a, e
	sub	a, 0 (iy)
	ld	a, d
	sbc	a, 1 (iy)
	jr	C,00131$
;src\CFG8266.c:348: break;
	jp	00129$
00127$:
;src\CFG8266.c:352: if (TickCount>Timeout)
	ld	a, e
	ld	iy, #_TickCount
	sub	a, 0 (iy)
	ld	a, d
	sbc	a, 1 (iy)
	jp	NC, 00129$
;src\CFG8266.c:355: while (1);
00131$:
;src\CFG8266.c:357: return bReturn;
	ld	l, -11 (ix)
00132$:
;src\CFG8266.c:358: }
	ld	sp, ix
	pop	ix
	ret
___str_1:
	.ascii "Error %u on command %c..."
	.db 0x0d
	.db 0x0a
	.db 0x00
;src\CFG8266.c:360: void FinishUpdate (bool bSendReset)
;	---------------------------------
; Function FinishUpdate
; ---------------------------------
_FinishUpdate::
	call	___sdcc_enter_ix
	push	af
	push	af
;src\CFG8266.c:362: unsigned int iRetries = 3;
	ld	hl, #0x0003
	ex	(sp), hl
;src\CFG8266.c:366: bool bReset = bSendReset;
	ld	a, 4 (ix)
	ld	-2 (ix), a
;src\CFG8266.c:368: Print("Finishing flash, this will take some time, WAIT!\n");
	ld	hl, #___str_2
	push	hl
	call	_Print
	pop	af
;src\CFG8266.c:370: do
	ld	-1 (ix), #0x02
00135$:
;src\CFG8266.c:372: bRet = true;
	ld	l, #0x01
;src\CFG8266.c:373: --ucRetries;
	dec	-1 (ix)
;src\CFG8266.c:374: if (bReset)
	ld	a, -2 (ix)
	or	a, a
	jr	Z,00152$
;src\CFG8266.c:375: TxByte('R'); //Request Reset
	push	hl
	ld	a, #0x52
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	hl
	jp	00110$
;src\CFG8266.c:378: do
00152$:
	pop	bc
	push	bc
;src\CFG8266.c:380: for (uchHalt=60;uchHalt>0;--uchHalt)
00150$:
	ld	a, #0x3c
00138$:
;src\CFG8266.c:381: Halt();
	halt;	
;src\CFG8266.c:380: for (uchHalt=60;uchHalt>0;--uchHalt)
	dec	a
	jp	NZ, 00138$
;src\CFG8266.c:382: TxByte('E'); //End Update
	push	bc
	ld	a, #0x45
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	ld	a, #0x01
	push	af
	inc	sp
	ld	hl, #0x0384
	push	hl
	ld	hl, #0x0002
	push	hl
	ld	hl, #_endUpdate
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	inc	sp
	pop	bc
;src\CFG8266.c:384: iRetries--;
	dec	bc
;src\CFG8266.c:386: while ((!bRet)&&(iRetries));
	ld	a, l
	or	a, a
	jr	NZ,00168$
	ld	a, b
	or	a, c
	jp	NZ, 00150$
00168$:
	inc	sp
	inc	sp
	push	bc
;src\CFG8266.c:387: if (bRet)
	ld	a, l
	or	a, a
	jr	Z,00110$
;src\CFG8266.c:389: bReset=true;
	ld	-2 (ix), #0x01
00110$:
;src\CFG8266.c:393: if (!bRet)
	ld	a, l
	or	a, a
	jr	NZ,00133$
;src\CFG8266.c:394: Print("Timeout waiting to end update...\n");
	ld	hl, #___str_3
	push	hl
	call	_Print
	pop	af
	jp	00136$
00133$:
;src\CFG8266.c:397: if (ucRetries)
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00115$
;src\CFG8266.c:399: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00112$
;src\CFG8266.c:400: Print("\nFirmware Update done, ESP is restarting, WAIT...\n");
	ld	hl, #___str_4
	push	hl
	call	_Print
	pop	af
	jr	00115$
00112$:
;src\CFG8266.c:402: Print("\nCertificates Update done, ESP is restarting, WAIT...\n");
	ld	hl, #___str_5
	push	hl
	call	_Print
	pop	af
00115$:
;src\CFG8266.c:405: if (WaitForRXData(responseReady,7,2700,false)) //Wait up to 45 seconds
	xor	a, a
	push	af
	inc	sp
	ld	hl, #0x0a8c
	push	hl
	ld	hl, #0x0007
	push	hl
	ld	hl, #_responseReady
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	inc	sp
	ld	a, l
	or	a, a
	jp	Z, 00130$
;src\CFG8266.c:407: if (!ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jp	NZ, 00125$
;src\CFG8266.c:409: Print("ESP Reset Ok, now let's request creation of index file...\n");
	ld	hl, #___str_6
	push	hl
	call	_Print
	pop	af
;src\CFG8266.c:411: do
	ld	-2 (ix), #0x0a
	ld	-1 (ix), #0x00
;src\CFG8266.c:413: for (uchHalt=60;uchHalt>0;--uchHalt)
00160$:
	ld	a, #0x3c
00140$:
;src\CFG8266.c:414: Halt();
	halt;	
;src\CFG8266.c:413: for (uchHalt=60;uchHalt>0;--uchHalt)
	dec	a
	jp	NZ, 00140$
;src\CFG8266.c:415: TxByte('I'); //End Update
	ld	a, #0x49
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:416: bRet = WaitForRXData(certificateDone,2,3600,false); //Wait up to 1 minute, certificate index creation takes time
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
	inc	sp
	ld	-3 (ix), l
;src\CFG8266.c:417: iRetries--;
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	dec	hl
	ld	-2 (ix), l
	ld	-1 (ix), h
;src\CFG8266.c:419: while ((!bRet)&&(iRetries));
	ld	a, -3 (ix)
	or	a, a
	jr	NZ,00120$
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jp	NZ, 00160$
00120$:
;src\CFG8266.c:420: if (bRet)
	ld	a, -3 (ix)
	or	a, a
	jr	Z,00122$
;src\CFG8266.c:421: Print("Done!\n");
	ld	hl, #___str_7
	push	hl
	call	_Print
	pop	af
	jr	00137$
00122$:
;src\CFG8266.c:423: Print("Done, but time-out on creating certificates index file!\n");
	ld	hl, #___str_8
	push	hl
	call	_Print
	pop	af
	jr	00137$
00125$:
;src\CFG8266.c:426: Print("Done!\n");
	ld	hl, #___str_7
	push	hl
	call	_Print
	pop	af
;src\CFG8266.c:427: break;
	jr	00137$
00130$:
;src\CFG8266.c:430: if (!ucRetries)
	ld	a, -1 (ix)
	or	a, a
	jr	NZ,00136$
;src\CFG8266.c:431: Print("Timeout error\n");
	ld	hl, #___str_9
	push	hl
	call	_Print
	pop	af
00136$:
;src\CFG8266.c:434: while (ucRetries);
	ld	a, -1 (ix)
	or	a, a
	jp	NZ, 00135$
00137$:
;src\CFG8266.c:436: return;
;src\CFG8266.c:437: }
	ld	sp, ix
	pop	ix
	ret
___str_2:
	.ascii "Finishing flash, this will take some time, WAIT!"
	.db 0x0a
	.db 0x00
___str_3:
	.ascii "Timeout waiting to end update..."
	.db 0x0a
	.db 0x00
___str_4:
	.db 0x0a
	.ascii "Firmware Update done, ESP is restarting, WAIT..."
	.db 0x0a
	.db 0x00
___str_5:
	.db 0x0a
	.ascii "Certificates Update done, ESP is restarting, WAIT..."
	.db 0x0a
	.db 0x00
___str_6:
	.ascii "ESP Reset Ok, now let's request creation of index file..."
	.db 0x0a
	.db 0x00
___str_7:
	.ascii "Done!"
	.db 0x0a
	.db 0x00
___str_8:
	.ascii "Done, but time-out on creating certificates index file!"
	.db 0x0a
	.db 0x00
___str_9:
	.ascii "Timeout error"
	.db 0x0a
	.db 0x00
;src\CFG8266.c:439: int main(char** argv, int argc)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	call	___sdcc_enter_ix
	ld	hl, #-485
	add	hl, sp
	ld	sp, hl
;src\CFG8266.c:451: unsigned char advance[4] = {'-','\\','|','/'};
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
;src\CFG8266.c:459: unsigned char ucFirstBlock = 1;
	ld	-16 (ix), #0x01
;src\CFG8266.c:464: ucLocalUpdate = 0;
	ld	hl,#_ucLocalUpdate + 0
	ld	(hl), #0x00
;src\CFG8266.c:465: ucNagleOff = 0;
	ld	hl,#_ucNagleOff + 0
	ld	(hl), #0x00
;src\CFG8266.c:466: ucNagleOn = 0;
	ld	hl,#_ucNagleOn + 0
	ld	(hl), #0x00
;src\CFG8266.c:467: Print("> MSX-SM ESP8266 WIFI Module Configuration v1.00<\n(c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com\n\n");
	ld	hl, #___str_10
	push	hl
	call	_Print
	pop	af
;src\CFG8266.c:469: if (IsValidInput(argv, argc))
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
	jp	Z, 00263$
;src\CFG8266.c:471: do
	ld	-1 (ix), #0x00
00103$:
;src\CFG8266.c:474: myPort6 = speed;
	ld	a, -1 (ix)
	out	(_myPort6), a
;src\CFG8266.c:475: ClearUartData();
	ld	a, #0x14
	out	(_myPort6), a
;src\CFG8266.c:476: TxByte('?');
	ld	a, #0x3f
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:477: Halt();
	halt;	
;src\CFG8266.c:479: bResponse = WaitForRXData(responseOK,2,4,false);
	xor	a, a
	push	af
	inc	sp
	ld	hl, #0x0004
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_responseOK
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	inc	sp
;src\CFG8266.c:481: if (bResponse)
	ld	-3 (ix), l
	ld	a, l
	or	a, a
	jr	NZ,00105$
;src\CFG8266.c:483: ++speed;
	inc	-1 (ix)
;src\CFG8266.c:485: while (speed<10);
	ld	a, -1 (ix)
	sub	a, #0x0a
	jp	C, 00103$
00105$:
;src\CFG8266.c:487: if (speed<10)
	ld	a, -1 (ix)
	sub	a, #0x0a
	jp	NC, 00260$
;src\CFG8266.c:489: printf ("Using Baud Rate #%u\r\n",speed);
	ld	a, -1 (ix)
	ld	-2 (ix), a
	ld	-1 (ix), #0x00
	ld	l, a
	ld	h, #0x00
	push	hl
	ld	hl, #___str_11
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:490: if ((ucScan)||(ucNagleOff)||(ucNagleOn)) //Scan and choose network to connect?
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	NZ,00254$
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00254$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jp	Z, 00255$
00254$:
;src\CFG8266.c:492: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	Z,00112$
;src\CFG8266.c:493: TxByte('S'); //Request SCAN
	ld	a, #0x53
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00113$
00112$:
;src\CFG8266.c:494: else if (ucNagleOff)
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	Z,00109$
;src\CFG8266.c:495: TxByte('N'); //Request nagle off for future connections
	ld	a, #0x4e
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00113$
00109$:
;src\CFG8266.c:496: else if (ucNagleOn)
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00113$
;src\CFG8266.c:497: TxByte('D'); //Request nagle on for future connections
	ld	a, #0x44
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00113$:
;src\CFG8266.c:499: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	Z,00120$
;src\CFG8266.c:500: bResponse = WaitForRXData(scanResponse,2,4,true);
	ld	a, #0x01
	push	af
	inc	sp
	ld	hl, #0x0004
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_scanResponse
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	inc	sp
	ld	-3 (ix), l
	jr	00121$
00120$:
;src\CFG8266.c:501: else if (ucNagleOff)
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	Z,00117$
;src\CFG8266.c:502: bResponse = WaitForRXData(nagleoffResponse,2,4,true);
	ld	a, #0x01
	push	af
	inc	sp
	ld	hl, #0x0004
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_nagleoffResponse
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	inc	sp
	ld	-3 (ix), l
	jr	00121$
00117$:
;src\CFG8266.c:503: else if (ucNagleOn)
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00121$
;src\CFG8266.c:504: bResponse = WaitForRXData(nagleonResponse,2,4,true);
	ld	a, #0x01
	push	af
	inc	sp
	ld	hl, #0x0004
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_nagleonResponse
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	inc	sp
	ld	-3 (ix), l
00121$:
;src\CFG8266.c:507: if ((bResponse)&&(ucScan))
	ld	a, -3 (ix)
	or	a, a
	jp	Z, 00187$
	ld	iy, #_ucScan
	ld	a, 0 (iy)
	or	a, a
	jp	Z, 00187$
;src\CFG8266.c:510: do
	ld	c, #0x0a
00124$:
;src\CFG8266.c:512: --ucRetries;
	dec	c
;src\CFG8266.c:513: for (ucHalt = 60;ucHalt>0;--ucHalt)
	ld	b, #0x3c
00265$:
;src\CFG8266.c:514: Halt();
	halt;	
;src\CFG8266.c:513: for (ucHalt = 60;ucHalt>0;--ucHalt)
	ld	a, b
	dec	a
	ld	b, a
	or	a, a
	jp	NZ, 00265$
;src\CFG8266.c:515: TxByte('s'); //Request SCAN result
	push	bc
	ld	a, #0x73
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	xor	a, a
	push	af
	inc	sp
	ld	hl, #0x000a
	push	hl
	ld	l, #0x02
	push	hl
	ld	hl, #_scanresResponse
	push	hl
	call	_WaitForRXData
	pop	af
	pop	af
	pop	af
	inc	sp
	pop	bc
;src\CFG8266.c:518: while ((ucRetries)&&(!bResponse));
	ld	a, c
	or	a, a
	jr	Z,00126$
	ld	a, l
	or	a, a
	jp	Z, 00124$
00126$:
;src\CFG8266.c:520: if (bResponse)
	ld	a, l
	or	a, a
	jp	Z, 00176$
;src\CFG8266.c:523: while(!UartRXData());
00127$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00127$
;src\CFG8266.c:524: ucAPs = GetUARTData();
	in	a, (_myPort6)
	ld	-8 (ix), a
;src\CFG8266.c:525: if (ucAPs>10)
	ld	a, #0x0a
	sub	a, -8 (ix)
	jr	NC,00131$
;src\CFG8266.c:526: ucAPs=10;
	ld	-8 (ix), #0x0a
00131$:
;src\CFG8266.c:528: Print ("\n");
	ld	hl, #___str_12
	push	hl
	call	_Print
	pop	af
;src\CFG8266.c:529: do
	ld	hl, #81
	add	hl, sp
	ld	-7 (ix), l
	ld	-6 (ix), h
	ld	-1 (ix), #0x00
;src\CFG8266.c:534: while(!UartRXData());
00298$:
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
00132$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00132$
;src\CFG8266.c:535: rx_data=GetUARTData();
	in	a, (_myPort6)
	ld	-2 (ix), a
;src\CFG8266.c:536: stAP[tx_data].APName[ucIndex++]=rx_data;
	ld	l, e
	inc	e
	ld	h, #0x00
	add	hl, bc
	ld	a, -2 (ix)
	ld	(hl), a
;src\CFG8266.c:538: while(rx_data!=0);
	ld	a, -2 (ix)
	or	a, a
	jr	NZ,00132$
;src\CFG8266.c:539: while(!UartRXData());
00138$:
	in	a, (_myPort7)
	sub	a,#0x01
	ld	a, #0x00
	rla
	bit	0, a
	jr	NZ,00138$
;src\CFG8266.c:540: rx_data=GetUARTData();
	in	a, (_myPort6)
	ld	c, a
;src\CFG8266.c:541: stAP[tx_data].isEncrypted = (rx_data == 'E') ? 1 : 0;
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
	jr	NZ,00276$
	ld	-3 (ix), #0x01
	ld	-2 (ix), #0x00
	jr	00277$
00276$:
	ld	-3 (ix), #0x00
	ld	-2 (ix), #0x00
00277$:
	ld	a, -3 (ix)
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	ld	(hl), a
;src\CFG8266.c:542: ++tx_data;
	inc	-1 (ix)
;src\CFG8266.c:544: while (tx_data!=ucAPs);
	ld	a, -1 (ix)
	sub	a, -8 (ix)
	jp	NZ,00298$
;src\CFG8266.c:545: ClearUartData();
	ld	a, #0x14
	out	(_myPort6), a
;src\CFG8266.c:546: Print("Choose AP:\n\n");
	ld	hl, #___str_13
	push	hl
	call	_Print
	pop	af
;src\CFG8266.c:547: for (ucIndex=0;ucIndex<ucAPs;ucIndex++)
	ld	-1 (ix), #0x00
00268$:
	ld	a, -1 (ix)
	sub	a, -8 (ix)
	jr	NC,00147$
;src\CFG8266.c:549: printf("%u - %s",ucIndex,stAP[ucIndex].APName);
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
	ld	bc, #___str_14
	push	bc
	call	_printf
	pop	af
	pop	af
	pop	af
	pop	hl
;src\CFG8266.c:550: if (stAP[ucIndex].isEncrypted)
	ld	de, #0x0021
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	Z,00145$
;src\CFG8266.c:551: printf(" (PWD)\r\n");
	ld	hl, #___str_16
	push	hl
	call	_puts
	pop	af
	jr	00269$
00145$:
;src\CFG8266.c:553: printf(" (OPEN)\r\n");
	ld	hl, #___str_18
	push	hl
	call	_puts
	pop	af
00269$:
;src\CFG8266.c:547: for (ucIndex=0;ucIndex<ucAPs;ucIndex++)
	inc	-1 (ix)
	jr	00268$
00147$:
;src\CFG8266.c:555: Print("\nWhich one to connect? (ESC exit)");
	ld	hl, #___str_19
	push	hl
	call	_Print
	pop	af
;src\CFG8266.c:556: tx_data = 0;
	ld	l, #0x00
;src\CFG8266.c:557: do
00153$:
;src\CFG8266.c:559: if (KeyboardHit())
	push	hl
	call	_KeyboardHit
	ld	a, l
	pop	hl
	or	a, a
	jr	Z,00149$
;src\CFG8266.c:561: tx_data = InputChar ();
	call	_InputChar
00149$:
;src\CFG8266.c:563: if (tx_data==0x1b)
	ld	a, l
	sub	a, #0x1b
	jr	NZ, 00646$
	ld	a, #0x01
	.db	#0x20
00646$:
	xor	a, a
00647$:
	ld	c,a
	or	a, a
	jr	NZ,00155$
;src\CFG8266.c:566: while ((tx_data<'0')||(tx_data>'9'));
	ld	a, l
	sub	a, #0x30
	jr	C,00153$
	ld	a, #0x39
	sub	a, l
	jr	C,00153$
00155$:
;src\CFG8266.c:567: if (tx_data!=0x1b)
	bit	0, c
	jp	NZ, 00173$
;src\CFG8266.c:569: ucIndex = tx_data-'0';
	ld	a, l
	add	a, #0xd0
;src\CFG8266.c:570: if (stAP[ucIndex].isEncrypted)
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
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	a, -7 (ix)
	add	a, -2 (ix)
	ld	c, a
	ld	a, -6 (ix)
	adc	a, -1 (ix)
	ld	b, a
	ld	hl, #0x0021
	add	hl, bc
	ex	de, hl
	ld	a, (de)
	or	a, a
	jr	Z,00157$
;src\CFG8266.c:573: Print("\nPassword? ");
	push	bc
	push	de
	ld	hl, #___str_20
	push	hl
	call	_Print
	pop	af
	pop	de
	pop	bc
;src\CFG8266.c:574: InputString(ucPWD,64);
	ld	iy,#16
	add	iy,sp
	push	bc
	push	de
	ld	hl, #0x0040
	push	hl
	push	iy
	call	_InputString
	pop	af
	ld	hl, #___str_12
	ex	(sp),hl
	call	_Print
	pop	af
	pop	de
	pop	bc
00157$:
;src\CFG8266.c:577: uiCMDLen = strlen(stAP[ucIndex].APName) + 1;
	push	bc
	call	_strlen
	pop	af
	inc	hl
	ld	b, l
	ld	c, h
;src\CFG8266.c:578: if (stAP[ucIndex].isEncrypted)
	ld	a, (de)
	or	a, a
	jr	Z,00159$
;src\CFG8266.c:579: uiCMDLen += strlen(ucPWD);
	ld	hl, #16
	add	hl, sp
	push	bc
	push	hl
	call	_strlen
	pop	af
	pop	bc
	ld	a, b
	add	a, l
	ld	b, a
	ld	a, c
	adc	a, h
	ld	c, a
00159$:
;src\CFG8266.c:580: TxByte('A'); //Request connect AP
	push	bc
	ld	a, #0x41
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:581: TxByte((unsigned char)((uiCMDLen&0xff00)>>8));
	ld	d, c
	ld	e, #0x00
	push	bc
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:582: TxByte((unsigned char)(uiCMDLen&0xff));
	ld	a, b
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:584: do
	ld	a, -7 (ix)
	add	a, -2 (ix)
	ld	e, a
	ld	a, -6 (ix)
	adc	a, -1 (ix)
	ld	d, a
	ld	-1 (ix), #0x00
00161$:
;src\CFG8266.c:586: tx_data = stAP[ucIndex].APName[rx_data];
	ld	a, e
	add	a, -1 (ix)
	ld	-3 (ix), a
	ld	a, d
	adc	a, #0x00
	ld	-2 (ix), a
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	ld	a, (hl)
	ld	-2 (ix), a
;src\CFG8266.c:587: TxByte(tx_data);
	push	bc
	push	de
	ld	a, -2 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:588: --uiCMDLen;
	ld	l, b
	ld	h, c
	dec	hl
	ld	b, l
	ld	c, h
;src\CFG8266.c:589: ++rx_data;
	inc	-1 (ix)
;src\CFG8266.c:591: while((uiCMDLen)&&(tx_data!=0));
	ld	a, c
	or	a, b
	jr	Z,00163$
	ld	a, -2 (ix)
	or	a, a
	jr	NZ,00161$
00163$:
;src\CFG8266.c:592: if(uiCMDLen)
	ld	a, c
	or	a, b
	jr	Z,00168$
;src\CFG8266.c:595: do
	ld	hl, #16
	add	hl, sp
	ld	-3 (ix), l
	ld	-2 (ix), h
	ld	a, c
	ld	c, b
	ld	b, a
	ld	-1 (ix), #0x00
00164$:
;src\CFG8266.c:597: tx_data = ucPWD[rx_data];
	ld	a, -3 (ix)
	add	a, -1 (ix)
	ld	e, a
	ld	a, -2 (ix)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
;src\CFG8266.c:598: TxByte(tx_data);
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:599: --uiCMDLen;
	dec	bc
;src\CFG8266.c:600: ++rx_data;
	inc	-1 (ix)
;src\CFG8266.c:602: while(uiCMDLen);
	ld	a, b
	or	a, c
	jr	NZ,00164$
00168$:
;src\CFG8266.c:606: bResponse = WaitForRXData(apconfigurationResponse,2,300,true); //Wait up to 5s
	ld	a, #0x01
	push	af
	inc	sp
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
	inc	sp
	ld	a, l
;src\CFG8266.c:607: if (bResponse)
	or	a, a
	jr	Z,00170$
;src\CFG8266.c:608: Print ("Success, AP configured to be used.\n");
	ld	hl, #___str_21
	push	hl
	call	_Print
	pop	af
	jp	00264$
00170$:
;src\CFG8266.c:610: Print ("Error, AP not configured!\n");
	ld	hl, #___str_22
	push	hl
	call	_Print
	pop	af
	jp	00264$
00173$:
;src\CFG8266.c:613: Print("User canceled by ESC key...\n");
	ld	hl, #___str_23
	push	hl
	call	_Print
	pop	af
	jp	00264$
00176$:
;src\CFG8266.c:616: Print ("Scan results: no answer...\n");
	ld	hl, #___str_24
	push	hl
	call	_Print
	pop	af
	jp	00264$
00187$:
;src\CFG8266.c:620: if (ucScan)
	ld	a,(#_ucScan + 0)
	or	a, a
	jr	Z,00184$
;src\CFG8266.c:621: Print ("Scan request: no answer...\n");
	ld	hl, #___str_25
	push	hl
	call	_Print
	pop	af
	jp	00264$
00184$:
;src\CFG8266.c:622: else if (((ucNagleOff)||(ucNagleOn))&&(bResponse))
	ld	a,(#_ucNagleOff + 0)
	or	a, a
	jr	NZ,00182$
	ld	a,(#_ucNagleOn + 0)
	or	a, a
	jr	Z,00179$
00182$:
	ld	a, -3 (ix)
	or	a, a
	jr	Z,00179$
;src\CFG8266.c:624: Print ("Nagle set as requested...\n");
	ld	hl, #___str_26
	push	hl
	call	_Print
	pop	af
;src\CFG8266.c:625: return 0;
	ld	hl, #0x0000
	jp	00272$
00179$:
;src\CFG8266.c:629: Print ("Nagle not set as requested, error!\n");
	ld	hl, #___str_27
	push	hl
	call	_Print
	pop	af
;src\CFG8266.c:630: return 0;
	ld	hl, #0x0000
	jp	00272$
00255$:
;src\CFG8266.c:634: else if (ucLocalUpdate)
	ld	a,(#_ucLocalUpdate + 0)
	or	a, a
	jp	Z, 00252$
;src\CFG8266.c:637: iFile = Open (ucFile,O_RDONLY);
	ld	hl, #0x0000
	push	hl
	ld	hl, #_ucFile
	push	hl
	call	_Open
	pop	af
	pop	af
	ld	-2 (ix), l
	ld	-1 (ix), h
;src\CFG8266.c:639: if (iFile!=-1)
	ld	a, -2 (ix)
	inc	a
	jr	NZ,00648$
	ld	a, -1 (ix)
	inc	a
	jp	Z,00225$
00648$:
;src\CFG8266.c:646: regs.Words.HL = 0; //set pointer as 0
	ld	hl, #425
	add	hl, sp
	ex	de, hl
	ld	hl, #0x0006
	add	hl, de
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;src\CFG8266.c:647: regs.Words.DE = 0; //so it will return the position
	ld	hl, #0x0004
	add	hl, de
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;src\CFG8266.c:648: regs.Bytes.A = 2; //relative to the end of file, i.e.:file size
	ld	hl, #425
	add	hl, sp
	ex	de, hl
	ld	l, e
	ld	h, d
	inc	hl
	ld	(hl), #0x02
;src\CFG8266.c:649: regs.Bytes.B = (unsigned char)(iFile&0xff);
	inc	de
	inc	de
	inc	de
	ld	a, -2 (ix)
	ld	(de), a
;src\CFG8266.c:650: DosCall(0x4A, &regs, REGS_ALL, REGS_ALL); // MOVE FILE HANDLER
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
;src\CFG8266.c:651: if (regs.Bytes.A == 0) //moved, now get the file handler position, i.e.: size
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	inc	hl
	ld	a, (hl)
	ld	-5 (ix), a
	or	a, a
	jp	NZ, 00191$
;src\CFG8266.c:652: SentFileSize = (unsigned long)(regs.Words.HL)&0xffff | ((unsigned long)(regs.Words.DE)<<16)&0xffff0000;
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
	ld	-14 (ix), a
	ld	a, -5 (ix)
	ld	-13 (ix), a
	rla
	sbc	a, a
	ld	-12 (ix), a
	ld	-11 (ix), a
	ld	a, -14 (ix)
	ld	-10 (ix), a
	ld	a, -13 (ix)
	ld	-9 (ix), a
	ld	-8 (ix), #0x00
	ld	-7 (ix), #0x00
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
	ld	b, #0x10
00649$:
	sla	-6 (ix)
	rl	-5 (ix)
	rl	-4 (ix)
	rl	-3 (ix)
	djnz	00649$
	ld	bc, #0x0000
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	a, c
	or	a, -10 (ix)
	ld	c, a
	ld	a, b
	or	a, -9 (ix)
	ld	b, a
	ld	a, e
	or	a, -8 (ix)
	ld	e, a
	ld	a, d
	or	a, -7 (ix)
	ld	d, a
	ld	-6 (ix), c
	ld	-5 (ix), b
	ld	-4 (ix), e
	ld	-3 (ix), d
	jr	00192$
00191$:
;src\CFG8266.c:654: SentFileSize = 0;
	xor	a, a
	ld	-6 (ix), a
	ld	-5 (ix), a
	ld	-4 (ix), a
	ld	-3 (ix), a
00192$:
;src\CFG8266.c:656: ultostr(SentFileSize,chFileSize,10);
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
;src\CFG8266.c:658: printf ("File: %s Size: %s \r\n",ucFile,chFileSize);
	ld	de, #_ucFile
	ld	bc, #___str_28+0
	push	hl
	push	de
	push	bc
	call	_printf
	pop	af
	pop	af
	pop	af
;src\CFG8266.c:659: if (SentFileSize)
	ld	a, -3 (ix)
	or	a, -4 (ix)
	or	a, -5 (ix)
	or	a, -6 (ix)
	jp	Z, 00222$
;src\CFG8266.c:661: iFile = Open (ucFile,O_RDONLY);
	ld	hl, #0x0000
	push	hl
	ld	hl, #_ucFile
	push	hl
	call	_Open
	pop	af
	pop	af
	ld	-15 (ix), l
	ld	-14 (ix), h
;src\CFG8266.c:662: if (iFile!=-1)
	ld	a, -15 (ix)
	inc	a
	jr	NZ,00651$
	ld	a, -14 (ix)
	inc	a
	jp	Z,00219$
00651$:
;src\CFG8266.c:664: FileRead = MyRead(iFile, ucServer,256); //try to read 256 bytes of data
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
;src\CFG8266.c:665: if (FileRead == 256)
	ld	a, -13 (ix)
	or	a, a
	jp	NZ,00216$
	ld	a, -12 (ix)
	dec	a
	jp	NZ,00216$
;src\CFG8266.c:668: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00194$
;src\CFG8266.c:669: TxByte('Z'); //Request start of RS232 update
	ld	a, #0x5a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	jr	00195$
00194$:
;src\CFG8266.c:671: TxByte('Y'); //Request start of RS232 cert update
	ld	a, #0x59
	push	af
	inc	sp
	call	_TxByte
	inc	sp
00195$:
;src\CFG8266.c:672: TxByte(0);
	xor	a, a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:673: TxByte(12);
	ld	a, #0x0c
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:674: TxByte((unsigned char)(SentFileSize&0xff));
	ld	a, -6 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:675: TxByte((unsigned char)((SentFileSize&0xff00)>>8));
	ld	b, -5 (ix)
	ld	c, #0x00
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:676: TxByte((unsigned char)((SentFileSize&0xff0000)>>16));
	ld	a, -4 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:677: TxByte((unsigned char)((SentFileSize&0xff000000)>>24));
	ld	a, -3 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:678: TxByte((unsigned char)((SentFileSize&0xff00000000)>>32));
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
	ld	4 (iy), #0x00
	ld	5 (iy), #0x00
	ld	6 (iy), #0x00
	ld	7 (iy), #0x00
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
00658$:
	sra	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	00658$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:679: TxByte((unsigned char)((SentFileSize&0xff0000000000)>>40));
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
00660$:
	sra	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	00660$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:680: TxByte((unsigned char)((SentFileSize&0xff000000000000)>>48));
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
00662$:
	sra	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	00662$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:681: TxByte((unsigned char)((SentFileSize&0xff00000000000000)>>56));
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
	ld	4 (iy), #0x00
	ld	5 (iy), #0x00
	ld	6 (iy), #0x00
	ld	7 (iy), #0x00
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
00664$:
	srl	7 (iy)
	rr	6 (iy)
	rr	5 (iy)
	rr	4 (iy)
	rr	3 (iy)
	rr	2 (iy)
	rr	1 (iy)
	rr	0 (iy)
	djnz	00664$
	ld	a, 0 (iy)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:682: TxByte(ucServer[0]);
	ld	a, (#_ucServer + 0)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:683: TxByte(ucServer[1]);
	ld	a, (#_ucServer + 1)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:684: TxByte(ucServer[2]);
	ld	a, (#_ucServer + 2)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:685: TxByte(ucServer[3]);
	ld	a, (#_ucServer + 3)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:687: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00197$
;src\CFG8266.c:688: bResponse = WaitForRXData(responseRSFWUpdate,2,60,true);
	ld	a, #0x01
	push	af
	inc	sp
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
	inc	sp
	ld	-11 (ix), l
	jr	00198$
00197$:
;src\CFG8266.c:690: bResponse = WaitForRXData(responseRSCERTUpdate,2,60,true);
	ld	a, #0x01
	push	af
	inc	sp
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
	inc	sp
	ld	-11 (ix), l
00198$:
;src\CFG8266.c:692: if (!bResponse)
	ld	a, -11 (ix)
	or	a, a
	jr	NZ,00213$
;src\CFG8266.c:693: printf("Error requesting to start firmware update.\r\n");
	ld	hl, #___str_30
	push	hl
	call	_puts
	pop	af
	jp	00217$
00213$:
;src\CFG8266.c:696: PrintChar('U');
	ld	a, #0x55
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
;src\CFG8266.c:697: do
	ld	-2 (ix), #0x00
	ld	-1 (ix), #0x00
00207$:
;src\CFG8266.c:700: PrintChar(8); //backspace
	ld	a, #0x08
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
;src\CFG8266.c:701: PrintChar(advance[i%4]); // next char
	ld	a, -2 (ix)
	and	a, #0x03
	ld	-10 (ix), a
	ld	-9 (ix), #0x00
	ld	a, -18 (ix)
	add	a, -10 (ix)
	ld	-8 (ix), a
	ld	a, -17 (ix)
	adc	a, -9 (ix)
	ld	-7 (ix), a
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	a, (hl)
	push	af
	inc	sp
	call	_PrintChar
	inc	sp
;src\CFG8266.c:702: ++i;
	inc	-2 (ix)
	jr	NZ,00666$
	inc	-1 (ix)
00666$:
;src\CFG8266.c:703: if (!ucFirstBlock)
	ld	a, -16 (ix)
	or	a, a
	jr	NZ,00202$
;src\CFG8266.c:705: FileRead = MyRead(iFile, ucServer,256); //try to read 256 bytes of data
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
;src\CFG8266.c:706: if (FileRead ==0)
	ld	-12 (ix), h
	ld	a, h
	or	a, -13 (ix)
	jr	NZ,00203$
;src\CFG8266.c:708: printf("Error reading file...\r\n");
	ld	hl, #___str_32
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:709: break;
	jp	00209$
00202$:
;src\CFG8266.c:713: ucFirstBlock = 0;
	ld	-16 (ix), #0x00
00203$:
;src\CFG8266.c:715: TxByte('z'); //Write block
	ld	a, #0x7a
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:716: TxByte((unsigned char)((FileRead&0xff00)>>8));
	ld	b, -12 (ix)
	ld	c, #0x00
	push	bc
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:717: TxByte((unsigned char)(FileRead&0xff));
	ld	a, -13 (ix)
	push	af
	inc	sp
	call	_TxByte
	inc	sp
;src\CFG8266.c:718: for (ii=0;ii<256;ii++)
	ld	bc, #0x0000
00270$:
;src\CFG8266.c:719: TxByte(ucServer[ii]);
	ld	hl, #_ucServer
	add	hl, bc
	ld	a, (hl)
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:718: for (ii=0;ii<256;ii++)
	inc	bc
	ld	a, b
	sub	a, #0x01
	jr	C,00270$
;src\CFG8266.c:721: bResponse = WaitForRXData(responseWRBlock,2,600,true);
	ld	a, #0x01
	push	af
	inc	sp
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
	inc	sp
;src\CFG8266.c:723: if (!bResponse)
	ld	-11 (ix), l
	ld	a, l
	or	a, a
	jr	NZ,00206$
;src\CFG8266.c:725: printf("Error requesting to write firmware block.\r\n");
	ld	hl, #___str_34
	push	hl
	call	_puts
	pop	af
;src\CFG8266.c:726: break;
	jr	00209$
00206$:
;src\CFG8266.c:728: SentFileSize = SentFileSize - FileRead;
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
;src\CFG8266.c:730: while(SentFileSize);
	ld	-3 (ix), a
	or	a, -4 (ix)
	or	a, -5 (ix)
	or	a, -6 (ix)
	jp	NZ, 00207$
00209$:
;src\CFG8266.c:733: if (bResponse)
	ld	a, -11 (ix)
	or	a, a
	jr	Z,00217$
;src\CFG8266.c:734: FinishUpdate(false);
	xor	a, a
	push	af
	inc	sp
	call	_FinishUpdate
	inc	sp
	jr	00217$
00216$:
;src\CFG8266.c:738: Print("Error reading firmware file!\n");
	ld	hl, #___str_35
	push	hl
	call	_Print
	pop	af
00217$:
;src\CFG8266.c:739: Close(iFile);
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	push	hl
	call	_Close
	pop	af
	jp	00264$
00219$:
;src\CFG8266.c:743: printf("Error, couldn't open %s ...\r\n",ucFile);
	ld	hl, #_ucFile
	push	hl
	ld	hl, #___str_36
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:744: return 0;
	ld	hl, #0x0000
	jp	00272$
00222$:
;src\CFG8266.c:749: printf("Error, %s is 0 bytes long...\r\n",ucFile);
	ld	hl, #_ucFile
	push	hl
	ld	hl, #___str_37
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:750: return 0;
	ld	hl, #0x0000
	jp	00272$
00225$:
;src\CFG8266.c:755: printf("Error, couldn't open %s ...\r\n",ucFile);
	ld	hl, #_ucFile
	push	hl
	ld	hl, #___str_36
	push	hl
	call	_printf
	pop	af
	pop	af
;src\CFG8266.c:756: return 0;
	ld	hl, #0x0000
	jp	00272$
00252$:
;src\CFG8266.c:761: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00228$
;src\CFG8266.c:762: printf ("Ok, updating FW using server: %s port: %u\r\nFile path: %s\nPlease Wait, it can take up to a few minutes!\r\n",ucServer,uiPort,ucFile);
	ld	hl, #_ucFile
	push	hl
	ld	hl, (_uiPort)
	push	hl
	ld	hl, #_ucServer
	push	hl
	ld	hl, #___str_38
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
	pop	af
	jr	00229$
00228$:
;src\CFG8266.c:764: printf ("Ok, updating certificates using server: %s port: %u\r\nFile path: %s\nPlease Wait, it can take up to a few minutes!\r\n",ucServer,uiPort,ucFile);
	ld	hl, #_ucFile
	push	hl
	ld	hl, (_uiPort)
	push	hl
	ld	hl, #_ucServer
	push	hl
	ld	hl, #___str_39
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
	pop	af
00229$:
;src\CFG8266.c:765: uiCMDLen = strlen(ucServer) + 3; //3 = 0 terminator + 2 bytes port
	ld	hl, #_ucServer
	push	hl
	call	_strlen
	pop	af
	ex	de,hl
	inc	de
	inc	de
	inc	de
;src\CFG8266.c:766: uiCMDLen += strlen(ucFile);
	ld	hl, #_ucFile
	push	hl
	call	_strlen
	pop	af
	add	hl, de
	ld	c, l
	ld	b, h
;src\CFG8266.c:767: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00231$
;src\CFG8266.c:768: TxByte('U'); //Request Update Main Firmware remotely
	push	bc
	ld	a, #0x55
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
	jr	00232$
00231$:
;src\CFG8266.c:770: TxByte('u'); //Request Update spiffs remotely
	push	bc
	ld	a, #0x75
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
00232$:
;src\CFG8266.c:771: TxByte((unsigned char)((uiCMDLen&0xff00)>>8));
	ld	a, b
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:772: TxByte((unsigned char)(uiCMDLen&0xff));
	ld	a, c
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:773: TxByte((unsigned char)(uiPort&0xff));
	ld	a,(#_uiPort + 0)
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:774: TxByte((unsigned char)((uiPort&0xff00)>>8));
	ld	a,(#_uiPort + 1)
	push	bc
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	bc
;src\CFG8266.c:776: do
	ld	e, #0x00
00234$:
;src\CFG8266.c:778: tx_data = ucServer[rx_data];
	ld	hl, #_ucServer
	ld	d, #0x00
	add	hl, de
	ld	d, (hl)
;src\CFG8266.c:779: TxByte(tx_data);
	push	bc
	push	de
	push	de
	inc	sp
	call	_TxByte
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:780: --uiCMDLen;
	dec	bc
;src\CFG8266.c:781: ++rx_data;
	inc	e
;src\CFG8266.c:783: while((uiCMDLen)&&(tx_data!=0));
	ld	a, b
	or	a, c
	jr	Z,00236$
	ld	a, d
	or	a, a
	jr	NZ,00234$
00236$:
;src\CFG8266.c:785: do
	ld	e, #0x00
00239$:
;src\CFG8266.c:787: tx_data = ucFile[rx_data];
	ld	hl, #_ucFile
	ld	d, #0x00
	add	hl, de
	ld	a, (hl)
;src\CFG8266.c:788: if (tx_data==0)
	or	a, a
	jr	Z,00241$
;src\CFG8266.c:790: TxByte(tx_data);
	push	bc
	push	de
	push	af
	inc	sp
	call	_TxByte
	inc	sp
	pop	de
	pop	bc
;src\CFG8266.c:791: --uiCMDLen;
	dec	bc
;src\CFG8266.c:792: ++rx_data;
	inc	e
;src\CFG8266.c:794: while(uiCMDLen);
	ld	a, b
	or	a, c
	jr	NZ,00239$
00241$:
;src\CFG8266.c:796: if (ucIsFw)
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	Z,00243$
;src\CFG8266.c:797: bResponse = WaitForRXData(responseOTAFW,2,18000,true);
	ld	a, #0x01
	push	af
	inc	sp
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
	inc	sp
	ld	c, l
	jr	00244$
00243$:
;src\CFG8266.c:799: bResponse = WaitForRXData(responseOTASPIFF,2,18000,true);
	ld	a, #0x01
	push	af
	inc	sp
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
	inc	sp
	ld	c, l
00244$:
;src\CFG8266.c:801: if (bResponse)
	ld	a, c
	or	a, a
	jr	Z,00249$
;src\CFG8266.c:803: if ((!ucIsFw))
	ld	a,(#_ucIsFw + 0)
	or	a, a
	jr	NZ,00246$
;src\CFG8266.c:804: Print ("Success updating certificates!\n");
	ld	hl, #___str_40
	push	hl
	call	_Print
	pop	af
	jr	00247$
00246$:
;src\CFG8266.c:806: Print ("Success, firmware updated, wait a minute so it is fully flashed.\n");
	ld	hl, #___str_41
	push	hl
	call	_Print
	pop	af
00247$:
;src\CFG8266.c:807: FinishUpdate(true);
	ld	a, #0x01
	push	af
	inc	sp
	call	_FinishUpdate
	inc	sp
;src\CFG8266.c:808: return 0;
	ld	hl, #0x0000
	jr	00272$
00249$:
;src\CFG8266.c:811: Print ("Failed to update from remote server...\n");
	ld	hl, #___str_42
	push	hl
	call	_Print
	pop	af
	jr	00264$
00260$:
;src\CFG8266.c:929: Print("ESP device not found...\n");
	ld	hl, #___str_43
	push	hl
	call	_Print
	pop	af
	jr	00264$
00263$:
;src\CFG8266.c:932: Print(strUsage);
	ld	hl, #_strUsage
	push	hl
	call	_Print
	pop	af
00264$:
;src\CFG8266.c:934: return 0;
	ld	hl, #0x0000
00272$:
;src\CFG8266.c:935: }
	ld	sp, ix
	pop	ix
	ret
___str_10:
	.ascii "> MSX-SM ESP8266 WIFI Module Configuration v1.00<"
	.db 0x0a
	.ascii "(c) 2019 Oduvaldo Pavan Junior - ducasp@gmail.com"
	.db 0x0a
	.db 0x0a
	.db 0x00
___str_11:
	.ascii "Using Baud Rate #%u"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_12:
	.db 0x0a
	.db 0x00
___str_13:
	.ascii "Choose AP:"
	.db 0x0a
	.db 0x0a
	.db 0x00
___str_14:
	.ascii "%u - %s"
	.db 0x00
___str_16:
	.ascii " (PWD)"
	.db 0x0d
	.db 0x00
___str_18:
	.ascii " (OPEN)"
	.db 0x0d
	.db 0x00
___str_19:
	.db 0x0a
	.ascii "Which one to connect? (ESC exit)"
	.db 0x00
___str_20:
	.db 0x0a
	.ascii "Password? "
	.db 0x00
___str_21:
	.ascii "Success, AP configured to be used."
	.db 0x0a
	.db 0x00
___str_22:
	.ascii "Error, AP not configured!"
	.db 0x0a
	.db 0x00
___str_23:
	.ascii "User canceled by ESC key..."
	.db 0x0a
	.db 0x00
___str_24:
	.ascii "Scan results: no answer..."
	.db 0x0a
	.db 0x00
___str_25:
	.ascii "Scan request: no answer..."
	.db 0x0a
	.db 0x00
___str_26:
	.ascii "Nagle set as requested..."
	.db 0x0a
	.db 0x00
___str_27:
	.ascii "Nagle not set as requested, error!"
	.db 0x0a
	.db 0x00
___str_28:
	.ascii "File: %s Size: %s "
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_30:
	.ascii "Error requesting to start firmware update."
	.db 0x0d
	.db 0x00
___str_32:
	.ascii "Error reading file..."
	.db 0x0d
	.db 0x00
___str_34:
	.ascii "Error requesting to write firmware block."
	.db 0x0d
	.db 0x00
___str_35:
	.ascii "Error reading firmware file!"
	.db 0x0a
	.db 0x00
___str_36:
	.ascii "Error, couldn't open %s ..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_37:
	.ascii "Error, %s is 0 bytes long..."
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_38:
	.ascii "Ok, updating FW using server: %s port: %u"
	.db 0x0d
	.db 0x0a
	.ascii "File path: %s"
	.db 0x0a
	.ascii "Please Wait, it can take up to a few minutes!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_39:
	.ascii "Ok, updating certificates using server: %s port: %u"
	.db 0x0d
	.db 0x0a
	.ascii "File path: %s"
	.db 0x0a
	.ascii "Please Wait, it can take up to a few minutes!"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_40:
	.ascii "Success updating certificates!"
	.db 0x0a
	.db 0x00
___str_41:
	.ascii "Success, firmware updated, wait a minute so it is fully flas"
	.ascii "hed."
	.db 0x0a
	.db 0x00
___str_42:
	.ascii "Failed to update from remote server..."
	.db 0x0a
	.db 0x00
___str_43:
	.ascii "ESP device not found..."
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
