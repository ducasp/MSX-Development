;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.0 #9615 (MINGW32)
;--------------------------------------------------------
	.module sntp
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _UnapiCall
	.globl _UnapiBuildCodeBlock
	.globl _UnapiGetCount
	.globl _DosCall
	.globl __size
	.globl __seek
	.globl __tell
	.globl _sprintf
	.globl _printf
	.globl _strOK
	.globl _strInvalidTimeZone
	.globl _strNoNetwork
	.globl _strInvalidParameter
	.globl _strUsage
	.globl _strPresentation
	.globl _timeZoneBuffer
	.globl _paramsBlock
	.globl _sysTimerHold
	.globl _ticksWaited
	.globl _timeZoneMinutes
	.globl _timeZoneHours
	.globl _timeZoneSeconds
	.globl _hostString
	.globl _timeZoneString
	.globl _seconds
	.globl _second
	.globl _minute
	.globl _hour
	.globl _day
	.globl _month
	.globl _year
	.globl _buffer
	.globl _conn
	.globl _paramLetter
	.globl _displayOnly
	.globl _verbose
	.globl _codeBlock
	.globl _param
	.globl _i
	.globl _regs
	.globl _SecsPerMonth
	.globl _PrintUsageAndEnd
	.globl _SecondsToDate
	.globl _IsValidTimeZone
	.globl _IsDigit
	.globl _Terminate
	.globl _CheckYear
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_SecsPerMonth::
	.ds 48
_regs::
	.ds 12
_i::
	.ds 2
_param::
	.ds 2
_codeBlock::
	.ds 24
_verbose::
	.ds 2
_displayOnly::
	.ds 2
_paramLetter::
	.ds 1
_conn::
	.ds 2
_buffer::
	.ds 2
_year::
	.ds 2
_month::
	.ds 1
_day::
	.ds 1
_hour::
	.ds 1
_minute::
	.ds 1
_second::
	.ds 1
_seconds::
	.ds 4
_timeZoneString::
	.ds 2
_hostString::
	.ds 2
_timeZoneSeconds::
	.ds 2
_timeZoneHours::
	.ds 2
_timeZoneMinutes::
	.ds 2
_ticksWaited::
	.ds 2
_sysTimerHold::
	.ds 2
_paramsBlock::
	.ds 8
_timeZoneBuffer::
	.ds 8
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_strPresentation::
	.ds 2
_strUsage::
	.ds 2
_strInvalidParameter::
	.ds 2
_strNoNetwork::
	.ds 2
_strInvalidTimeZone::
	.ds 2
_strOK::
	.ds 2
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
;fusion-c/header/io.h:155: extern	unsigned long _tell(int fH) { return B8dH.rand_record; }
;	---------------------------------
; Function _tell
; ---------------------------------
__tell::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	bc,#__buf8_fcbs+0
	ld	e,4 (ix)
	ld	d,5 (ix)
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl,bc
	ld	de, #0x0021
	add	hl, de
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l,c
	ld	h,b
	pop	ix
	ret
;fusion-c/header/io.h:157: extern	void 	_seek(int fH, long pos, int ot)
;	---------------------------------
; Function _seek
; ---------------------------------
__seek::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-8
	add	hl,sp
	ld	sp,hl
;fusion-c/header/io.h:159: if(ot==SEEK_CUR) B8dH.rand_record+=pos;
	ld	c,4 (ix)
	ld	b,5 (ix)
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ld	c,l
	ld	b,h
	ld	a,6 (ix)
	ld	-4 (ix),a
	ld	a,7 (ix)
	ld	-3 (ix),a
	ld	a,8 (ix)
	ld	-2 (ix),a
	ld	a,9 (ix)
	ld	-1 (ix),a
	ld	a,10 (ix)
	dec	a
	jr	NZ,00102$
	ld	a,11 (ix)
	or	a, a
	jr	NZ,00102$
	ld	hl,#__buf8_fcbs+0 + 0x0021
	add	hl,bc
	ld	e,l
	ld	d,h
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	a,c
	add	a, -4 (ix)
	ld	-8 (ix),a
	ld	a,b
	adc	a, -3 (ix)
	ld	-7 (ix),a
	ld	a,l
	adc	a, -2 (ix)
	ld	-6 (ix),a
	ld	a,h
	adc	a, -1 (ix)
	ld	-5 (ix),a
	ld	hl, #0x0000
	add	hl, sp
	ld	bc, #0x0004
	ldir
	jr	00104$
00102$:
;fusion-c/header/io.h:160: else B8dH.rand_record = (ot==SEEK_END ? B8dH.file_size+pos : pos );
	ld	hl,#__buf8_fcbs+0
	add	hl,bc
	ld	a,l
	add	a, #0x21
	ld	e,a
	ld	a,h
	adc	a, #0x00
	ld	d,a
	ld	a,10 (ix)
	sub	a, #0x02
	jr	NZ,00106$
	ld	a,11 (ix)
	or	a, a
	jr	NZ,00106$
	ld	bc, #0x0010
	add	hl, bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	a,c
	add	a, -4 (ix)
	ld	-8 (ix),a
	ld	a,b
	adc	a, -3 (ix)
	ld	-7 (ix),a
	ld	a,l
	adc	a, -2 (ix)
	ld	-6 (ix),a
	ld	a,h
	adc	a, -1 (ix)
	ld	-5 (ix),a
	jr	00107$
00106$:
	ld	a,6 (ix)
	ld	-8 (ix),a
	ld	a,7 (ix)
	ld	-7 (ix),a
	ld	a,8 (ix)
	ld	-6 (ix),a
	ld	a,9 (ix)
	ld	-5 (ix),a
00107$:
	ld	hl, #0x0000
	add	hl, sp
	ld	bc, #0x0004
	ldir
00104$:
	ld	sp, ix
	pop	ix
	ret
;fusion-c/header/io.h:163: extern	unsigned long _size(int fH) { return B8dH.file_size; }
;	---------------------------------
; Function _size
; ---------------------------------
__size::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	bc,#__buf8_fcbs+0
	ld	e,4 (ix)
	ld	d,5 (ix)
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl,bc
	ld	de, #0x0010
	add	hl, de
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l,c
	ld	h,b
	pop	ix
	ret
;sntp.c:159: int main(char** argv, int argc)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-6
	add	hl,sp
	ld	sp,hl
;sntp.c:165: verbose = 0;
	ld	hl,#0x0000
	ld	(_verbose),hl
;sntp.c:166: displayOnly = 0;
	ld	l, #0x00
	ld	(_displayOnly),hl
;sntp.c:167: timeZoneBuffer[0] = 0;
	ld	bc,#_timeZoneBuffer+0
	xor	a, a
	ld	(bc),a
;sntp.c:168: timeZoneString = NULL;
	ld	l, #0x00
	ld	(_timeZoneString),hl
;sntp.c:169: buffer = BUFFER;
	ld	h, #0x80
	ld	(_buffer),hl
;sntp.c:170: conn = 0;
	ld	h, #0x00
	ld	(_conn),hl
;sntp.c:172: SecsPerMonth[0]=SECS_IN_MONTH_31;
	ld	hl,#0xde80
	ld	(_SecsPerMonth), hl
	ld	hl,#0x0028
	ld	(_SecsPerMonth+2), hl
;sntp.c:173: SecsPerMonth[1]=SECS_IN_MONTH_28;
	ld	hl,#0xea00
	ld	((_SecsPerMonth + 0x0004)), hl
	ld	hl,#0x0024
	ld	((_SecsPerMonth + 0x0004)+2), hl
;sntp.c:174: SecsPerMonth[2]=SECS_IN_MONTH_31;
	ld	hl,#0xde80
	ld	((_SecsPerMonth + 0x0008)), hl
	ld	hl,#0x0028
	ld	((_SecsPerMonth + 0x0008)+2), hl
;sntp.c:175: SecsPerMonth[3]=SECS_IN_MONTH_30;
	ld	hl,#0x8d00
	ld	((_SecsPerMonth + 0x000c)), hl
	ld	hl,#0x0027
	ld	((_SecsPerMonth + 0x000c)+2), hl
;sntp.c:176: SecsPerMonth[4]=SECS_IN_MONTH_31;
	ld	hl,#0xde80
	ld	((_SecsPerMonth + 0x0010)), hl
	ld	hl,#0x0028
	ld	((_SecsPerMonth + 0x0010)+2), hl
;sntp.c:177: SecsPerMonth[5]=SECS_IN_MONTH_30;
	ld	hl,#0x8d00
	ld	((_SecsPerMonth + 0x0014)), hl
	ld	hl,#0x0027
	ld	((_SecsPerMonth + 0x0014)+2), hl
;sntp.c:178: SecsPerMonth[6]=SECS_IN_MONTH_31;
	ld	hl,#0xde80
	ld	((_SecsPerMonth + 0x0018)), hl
	ld	hl,#0x0028
	ld	((_SecsPerMonth + 0x0018)+2), hl
;sntp.c:179: SecsPerMonth[7]=SECS_IN_MONTH_31;
	ld	hl,#0xde80
	ld	((_SecsPerMonth + 0x001c)), hl
	ld	hl,#0x0028
	ld	((_SecsPerMonth + 0x001c)+2), hl
;sntp.c:180: SecsPerMonth[8]=SECS_IN_MONTH_30;
	ld	hl,#0x8d00
	ld	((_SecsPerMonth + 0x0020)), hl
	ld	hl,#0x0027
	ld	((_SecsPerMonth + 0x0020)+2), hl
;sntp.c:181: SecsPerMonth[9]=SECS_IN_MONTH_31;
	ld	hl,#0xde80
	ld	((_SecsPerMonth + 0x0024)), hl
	ld	hl,#0x0028
	ld	((_SecsPerMonth + 0x0024)+2), hl
;sntp.c:182: SecsPerMonth[10]=SECS_IN_MONTH_30;
	ld	hl,#0x8d00
	ld	((_SecsPerMonth + 0x0028)), hl
	ld	hl,#0x0027
	ld	((_SecsPerMonth + 0x0028)+2), hl
;sntp.c:183: SecsPerMonth[11]=SECS_IN_MONTH_31;
	ld	hl,#0xde80
	ld	((_SecsPerMonth + 0x002c)), hl
	ld	hl,#0x0028
	ld	((_SecsPerMonth + 0x002c)+2), hl
;sntp.c:187: timeZoneBuffer[0] = '\0';
	xor	a, a
	ld	(bc),a
;sntp.c:188: regs.Words.HL = (int)"TIMEZONE";
	ld	de,#___str_0+0
	ld	((_regs + 0x0006)), de
;sntp.c:189: regs.Words.DE = (int)timeZoneBuffer;
	ld	e, c
	ld	d, b
	ld	((_regs + 0x0004)), de
;sntp.c:190: regs.Bytes.B = 8;
	ld	hl,#(_regs + 0x0003)
	ld	(hl),#0x08
;sntp.c:191: DosCall(_GENV, &regs, REGS_MAIN, REGS_AF);
	push	bc
	ld	hl,#0x0102
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x6b
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
	pop	bc
;sntp.c:192: if(timeZoneBuffer[0] != (unsigned char)'\0' && IsValidTimeZone(timeZoneBuffer)) {
	ld	a,(bc)
	or	a, a
	jr	Z,00102$
	ld	e, c
	ld	d, b
	push	bc
	push	de
	call	_IsValidTimeZone
	pop	af
	pop	bc
	ld	a,h
	or	a,l
	jr	Z,00102$
;sntp.c:193: timeZoneString = timeZoneBuffer;
	ld	(_timeZoneString),bc
00102$:
;sntp.c:198: if(argc == 0) {
	ld	a,7 (ix)
	or	a,6 (ix)
	jr	NZ,00105$
;sntp.c:199: print(strPresentation);
	ld	hl,(_strPresentation)
	push	hl
	call	_printf
	pop	af
;sntp.c:200: PrintUsageAndEnd();
	call	_PrintUsageAndEnd
00105$:
;sntp.c:203: for(param=1; param<argc; param++) {
	ld	hl,#0x0001
	ld	(_param),hl
00237$:
	ld	iy,#_param
	ld	a,0 (iy)
	sub	a, 6 (ix)
	ld	a,1 (iy)
	sbc	a, 7 (ix)
	jp	PO, 00507$
	xor	a, #0x80
00507$:
	jp	P,00117$
;sntp.c:204: if(argv[param][0] == '/') {
	ld	bc,(_param)
	sla	c
	rl	b
	ld	l,4 (ix)
	ld	h,5 (ix)
	add	hl,bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,(bc)
	sub	a, #0x2f
	jr	NZ,00115$
;sntp.c:205: paramLetter = LowerCase(argv[param][1]);
	ld	l, c
	ld	h, b
	inc	hl
	ld	a,(hl)
	set	5, a
;sntp.c:206: if(paramLetter == 'v') {
	ld	c,a
	sub	a, #0x76
	jr	NZ,00110$
;sntp.c:207: verbose = 1;
	ld	hl,#0x0001
	ld	(_verbose),hl
	jr	00238$
00110$:
;sntp.c:208: } else if(paramLetter == 'd') {
	ld	a,c
	sub	a, #0x64
	jr	NZ,00107$
;sntp.c:209: displayOnly = 1;
	ld	hl,#0x0001
	ld	(_displayOnly),hl
	jr	00238$
00107$:
;sntp.c:211: Terminate(strInvalidParameter);
	ld	hl,(_strInvalidParameter)
	push	hl
	call	_Terminate
	pop	af
	jr	00238$
00115$:
;sntp.c:214: timeZoneString = argv[param];
	ld	(_timeZoneString),bc
;sntp.c:215: if(!IsValidTimeZone(timeZoneString)) {
	ld	hl,(_timeZoneString)
	push	hl
	call	_IsValidTimeZone
	pop	af
	ld	a,h
	or	a,l
	jr	NZ,00238$
;sntp.c:216: Terminate(strInvalidTimeZone);
	ld	hl,(_strInvalidTimeZone)
	push	hl
	call	_Terminate
	pop	af
00238$:
;sntp.c:203: for(param=1; param<argc; param++) {
	ld	iy,#_param
	inc	0 (iy)
	jr	NZ,00237$
	inc	1 (iy)
	jp	00237$
00117$:
;sntp.c:221: PrintIfVerbose(strPresentation);
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00119$
	ld	hl,(_strPresentation)
	push	hl
	call	_printf
	pop	af
00119$:
;sntp.c:226: if(argv[0][0]=='.' && argv[0][1]=='\0') {
	ld	l,4 (ix)
	ld	h,5 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,(bc)
;sntp.c:228: regs.Words.HL = (int)"TIMESERVER";
;sntp.c:229: regs.Words.DE = (int)buffer;
;sntp.c:230: regs.Bytes.B = 255;
;sntp.c:226: if(argv[0][0]=='.' && argv[0][1]=='\0') {
	ld	e,a
	sub	a, #0x2e
	jr	NZ,00125$
	ld	l, c
	ld	h, b
	inc	hl
	ld	a,(hl)
	or	a, a
	jr	NZ,00125$
;sntp.c:227: buffer[0] = '\0';
	ld	hl,(_buffer)
	ld	(hl),#0x00
;sntp.c:228: regs.Words.HL = (int)"TIMESERVER";
	ld	bc,#___str_1+0
	ld	((_regs + 0x0006)), bc
;sntp.c:229: regs.Words.DE = (int)buffer;
	ld	bc,(_buffer)
	ld	((_regs + 0x0004)), bc
;sntp.c:230: regs.Bytes.B = 255;
	ld	hl,#(_regs + 0x0003)
	ld	(hl),#0xff
;sntp.c:231: DosCall(_GENV, &regs, REGS_MAIN, REGS_AF);
	ld	hl,#0x0102
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x6b
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
;sntp.c:232: if(buffer[0] == '\0') {
	ld	hl,(_buffer)
	ld	a,(hl)
	or	a, a
	jr	NZ,00121$
;sntp.c:233: Terminate("No time server specified and no TIMESERVER environment item was found.");
	ld	hl,#___str_2
	push	hl
	call	_Terminate
	pop	af
00121$:
;sntp.c:235: hostString = buffer;
	ld	hl,(_buffer)
	ld	(_hostString),hl
;sntp.c:236: if(verbose) {
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00126$
;sntp.c:237: printf("Time server is: %s\r\n", buffer);
	ld	hl,(_buffer)
	push	hl
	ld	hl,#___str_3
	push	hl
	call	_printf
	pop	af
	pop	af
	jr	00126$
00125$:
;sntp.c:240: hostString = argv[0];
	ld	(_hostString),bc
00126$:
;sntp.c:245: if(timeZoneString != NULL) {
	ld	iy,#_timeZoneString
	ld	a,1 (iy)
	or	a,0 (iy)
	jp	Z,00133$
;sntp.c:246: timeZoneHours = (((byte)(timeZoneString[1])-'0')*10) + (byte)(timeZoneString[2]-'0');
	ld	hl,(_timeZoneString)
	inc	hl
	ld	c,(hl)
	ld	b,#0x00
	ld	a,c
	add	a,#0xd0
	ld	c,a
	ld	a,b
	adc	a,#0xff
	ld	b,a
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ld	c,l
	ld	b,h
	ld	hl,(_timeZoneString)
	inc	hl
	inc	hl
	ld	a,(hl)
	add	a,#0xd0
	ld	e,a
	ld	d,#0x00
	ld	a,c
	ld	hl,#_timeZoneHours
	add	a, e
	ld	(hl),a
	ld	a,b
	adc	a, d
	inc	hl
	ld	(hl),a
;sntp.c:247: if(timeZoneHours > 12) {
	ld	a,#0x0c
	ld	iy,#_timeZoneHours
	cp	a, 0 (iy)
	ld	a,#0x00
	sbc	a, 1 (iy)
	jr	NC,00129$
;sntp.c:248: Terminate(strInvalidTimeZone);
	ld	hl,(_strInvalidTimeZone)
	push	hl
	call	_Terminate
	pop	af
00129$:
;sntp.c:251: timeZoneMinutes = (((byte)(timeZoneString[4])-'0')*10) + (byte)(timeZoneString[5]-'0');
	ld	iy,(_timeZoneString)
	ld	a, 4 (iy)
	ld	b, #0x00
	add	a,#0xd0
	ld	c,a
	ld	a,b
	adc	a,#0xff
	ld	b,a
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ld	c,l
	ld	b,h
	ld	iy,(_timeZoneString)
	ld	a,5 (iy)
	add	a,#0xd0
	ld	e,a
	ld	d,#0x00
	ld	a,c
	ld	hl,#_timeZoneMinutes
	add	a, e
	ld	(hl),a
	ld	a,b
	adc	a, d
	inc	hl
	ld	(hl),a
;sntp.c:252: if(timeZoneMinutes > 59) {
	ld	a,#0x3b
	ld	iy,#_timeZoneMinutes
	cp	a, 0 (iy)
	ld	a,#0x00
	sbc	a, 1 (iy)
	jr	NC,00131$
;sntp.c:253: Terminate(strInvalidTimeZone);
	ld	hl,(_strInvalidTimeZone)
	push	hl
	call	_Terminate
	pop	af
00131$:
;sntp.c:256: timeZoneSeconds = ((timeZoneHours * (int)SECS_IN_HOUR)) + ((timeZoneMinutes * (int)SECS_IN_MINUTE));
	ld	bc,(_timeZoneHours)
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	c,l
	ld	b,h
	ld	de,(_timeZoneMinutes)
	ld	l, e
	ld	h, d
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, hl
	ex	de,hl
	ld	a,c
	ld	hl,#_timeZoneSeconds
	add	a, e
	ld	(hl),a
	ld	a,b
	adc	a, d
	inc	hl
	ld	(hl),a
00133$:
;sntp.c:261: i = UnapiGetCount("TCP/IP");
	ld	hl,#___str_4
	push	hl
	call	_UnapiGetCount
	pop	af
	ld	(_i),hl
;sntp.c:262: if(i==0) {
	ld	iy,#_i
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	NZ,00135$
;sntp.c:263: Terminate("No TCP/IP UNAPI implementations found");
	ld	hl,#___str_5
	push	hl
	call	_Terminate
	pop	af
00135$:
;sntp.c:265: UnapiBuildCodeBlock(NULL, 1, &codeBlock);
	ld	hl,#_codeBlock
	push	hl
	ld	hl,#0x0001
	push	hl
	ld	l, #0x00
	push	hl
	call	_UnapiBuildCodeBlock
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;sntp.c:267: regs.Bytes.B = 0;
	ld	hl,#(_regs + 0x0003)
	ld	(hl),#0x00
;sntp.c:268: UnapiCall(&codeBlock, TCPIP_UDP_CLOSE, &regs, REGS_MAIN, REGS_NONE);
	ld	hl,#0x0002
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x09
	push	af
	inc	sp
	ld	hl,#_codeBlock
	push	hl
	call	_UnapiCall
	ld	hl,#7
	add	hl,sp
	ld	sp,hl
;sntp.c:269: if(regs.Bytes.A == ERR_NOT_IMP) {
	ld	a, (#(_regs + 0x0001) + 0)
	dec	a
	jr	NZ,00137$
;sntp.c:270: Terminate("This TCP/IP UNAPI implementation does not support UDP connections");
	ld	hl,#___str_6
	push	hl
	call	_Terminate
	pop	af
00137$:
;sntp.c:273: regs.Words.HL = SNTP_PORT;
	ld	hl,#0x007b
	ld	((_regs + 0x0006)), hl
;sntp.c:274: regs.Bytes.B = 0;
	ld	hl,#(_regs + 0x0003)
	ld	(hl),#0x00
;sntp.c:275: UnapiCall(&codeBlock, TCPIP_UDP_OPEN, &regs, REGS_MAIN, REGS_MAIN);
	ld	hl,#0x0202
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x08
	push	af
	inc	sp
	ld	hl,#_codeBlock
	push	hl
	call	_UnapiCall
	ld	hl,#7
	add	hl,sp
	ld	sp,hl
;sntp.c:276: if(regs.Bytes.A == ERR_NO_FREE_CONN) {
	ld	a, (#(_regs + 0x0001) + 0)
	sub	a, #0x09
	jr	NZ,00144$
;sntp.c:277: Terminate("No free UDP connections available");
	ld	hl,#___str_7
	push	hl
	call	_Terminate
	pop	af
	jr	00145$
00144$:
;sntp.c:279: else if(regs.Bytes.A == ERR_CONN_EXISTS) {
	ld	a, (#(_regs + 0x0001) + 0)
	sub	a, #0x0a
	jr	NZ,00141$
;sntp.c:280: Terminate("There is a resident UDP connection which uses the SNTP port");
	ld	hl,#___str_8
	push	hl
	call	_Terminate
	pop	af
	jr	00145$
00141$:
;sntp.c:282: else if(regs.Bytes.A != 0) {
	ld	a, (#(_regs + 0x0001) + 0)
	or	a, a
	jr	Z,00145$
;sntp.c:283: sprintf(buffer, "Unknown error when opening UDP connection (code %i)", regs.Bytes.A);
	ld	hl, #(_regs + 0x0001) + 0
	ld	c,(hl)
	ld	b,#0x00
	push	bc
	ld	hl,#___str_9
	push	hl
	ld	hl,(_buffer)
	push	hl
	call	_sprintf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;sntp.c:284: Terminate(buffer);
	ld	hl,(_buffer)
	push	hl
	call	_Terminate
	pop	af
00145$:
;sntp.c:286: conn = regs.Bytes.B;
	ld	a, (#(_regs + 0x0003) + 0)
	ld	iy,#_conn
	ld	0 (iy),a
	ld	1 (iy),#0x00
;sntp.c:290: PrintIfVerbose("Resolving host name... ");
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00147$
	ld	hl,#___str_10
	push	hl
	call	_printf
	pop	af
00147$:
;sntp.c:292: regs.Words.HL = (int)hostString;
	ld	bc,(_hostString)
	ld	((_regs + 0x0006)), bc
;sntp.c:293: regs.Bytes.B = 0;
	ld	hl,#(_regs + 0x0003)
	ld	(hl),#0x00
;sntp.c:294: UnapiCall(&codeBlock, TCPIP_DNS_Q, &regs, REGS_MAIN, REGS_MAIN);
	ld	hl,#0x0202
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x06
	push	af
	inc	sp
	ld	hl,#_codeBlock
	push	hl
	call	_UnapiCall
	ld	hl,#7
	add	hl,sp
	ld	sp,hl
;sntp.c:295: if(regs.Bytes.A == ERR_NO_NETWORK) {
	ld	a, (#(_regs + 0x0001) + 0)
	sub	a, #0x02
	jr	NZ,00157$
;sntp.c:296: Terminate(strNoNetwork);
	ld	hl,(_strNoNetwork)
	push	hl
	call	_Terminate
	pop	af
	jr	00271$
00157$:
;sntp.c:297: } else if(regs.Bytes.A == ERR_NO_DNS) {
	ld	a, (#(_regs + 0x0001) + 0)
	sub	a, #0x07
	jr	NZ,00154$
;sntp.c:298: Terminate("There are no DNS servers configured");
	ld	hl,#___str_11
	push	hl
	call	_Terminate
	pop	af
	jr	00271$
00154$:
;sntp.c:299: } else if(regs.Bytes.A == ERR_NOT_IMP) {
	ld	a, (#(_regs + 0x0001) + 0)
	dec	a
	jr	NZ,00151$
;sntp.c:300: Terminate("This TCP/IP UNAPI implementation does not support resolving host names.\r\nSpecify an IP address instead.");
	ld	hl,#___str_12
	push	hl
	call	_Terminate
	pop	af
	jr	00271$
00151$:
;sntp.c:301: } else if(regs.Bytes.A != (byte)ERR_OK) {
	ld	a, (#(_regs + 0x0001) + 0)
	or	a, a
	jr	Z,00271$
;sntp.c:302: sprintf(buffer, "Unknown error when resolving the host name (code %i)", regs.Bytes.A);
	ld	hl, #(_regs + 0x0001) + 0
	ld	c,(hl)
	ld	b,#0x00
	push	bc
	ld	hl,#___str_13
	push	hl
	ld	hl,(_buffer)
	push	hl
	call	_sprintf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;sntp.c:303: Terminate(buffer);
	ld	hl,(_buffer)
	push	hl
	call	_Terminate
	pop	af
;sntp.c:306: do {
00271$:
00160$:
;sntp.c:307: UnapiCall(&codeBlock, TCPIP_WAIT, &regs, REGS_NONE, REGS_NONE);
	ld	hl,#0x0000
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x1d
	push	af
	inc	sp
	ld	hl,#_codeBlock
	push	hl
	call	_UnapiCall
	ld	hl,#7
	add	hl,sp
	ld	sp,hl
;sntp.c:308: regs.Bytes.B = 0;
	ld	hl,#(_regs + 0x0003)
	ld	(hl),#0x00
;sntp.c:309: UnapiCall(&codeBlock, TCPIP_DNS_S, &regs, REGS_MAIN, REGS_MAIN);
	ld	hl,#0x0202
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x07
	push	af
	inc	sp
	ld	hl,#_codeBlock
	push	hl
	call	_UnapiCall
	ld	hl,#7
	add	hl,sp
	ld	sp,hl
;sntp.c:310: } while (regs.Bytes.A == 0 && regs.Bytes.B == 1);
	ld	a, (#(_regs + 0x0001) + 0)
	or	a, a
	jr	NZ,00162$
	ld	a, (#(_regs + 0x0003) + 0)
	dec	a
	jr	Z,00160$
00162$:
;sntp.c:312: if(regs.Bytes.A != 0) {
	ld	a, (#(_regs + 0x0001) + 0)
	or	a, a
	jp	Z,00183$
;sntp.c:313: if(regs.Bytes.B == 2) {
	ld	a, (#(_regs + 0x0003) + 0)
	sub	a, #0x02
	jr	NZ,00180$
;sntp.c:314: Terminate("DNS server failure");
	ld	hl,#___str_14
	push	hl
	call	_Terminate
	pop	af
	jp	00183$
00180$:
;sntp.c:315: } else if(regs.Bytes.B == 3) {
	ld	a, (#(_regs + 0x0003) + 0)
	sub	a, #0x03
	jr	NZ,00177$
;sntp.c:316: Terminate("Unknown host name");
	ld	hl,#___str_15
	push	hl
	call	_Terminate
	pop	af
	jr	00183$
00177$:
;sntp.c:317: } else if(regs.Bytes.B == 5) {
	ld	a, (#(_regs + 0x0003) + 0)
	sub	a, #0x05
	jr	NZ,00174$
;sntp.c:318: Terminate("DNS server refused the query");
	ld	hl,#___str_16
	push	hl
	call	_Terminate
	pop	af
	jr	00183$
00174$:
;sntp.c:319: } else if(regs.Bytes.B == 16 || regs.Bytes.B == 17) {
	ld	a, (#(_regs + 0x0003) + 0)
	sub	a, #0x10
	jr	Z,00169$
	ld	a, (#(_regs + 0x0003) + 0)
	sub	a, #0x11
	jr	NZ,00170$
00169$:
;sntp.c:320: Terminate("DNS server did not reply");
	ld	hl,#___str_17
	push	hl
	call	_Terminate
	pop	af
	jr	00183$
00170$:
;sntp.c:321: } else if(regs.Bytes.B == 19) {
	ld	a, (#(_regs + 0x0003) + 0)
	sub	a, #0x13
	jr	NZ,00167$
;sntp.c:322: Terminate(strNoNetwork);
	ld	hl,(_strNoNetwork)
	push	hl
	call	_Terminate
	pop	af
	jr	00183$
00167$:
;sntp.c:323: } else if(regs.Bytes.B == 0) {
	ld	a, (#(_regs + 0x0003) + 0)
	or	a, a
	jr	NZ,00164$
;sntp.c:324: Terminate("DNS query failed");
	ld	hl,#___str_18
	push	hl
	call	_Terminate
	pop	af
	jr	00183$
00164$:
;sntp.c:326: sprintf(buffer, "Unknown error returned by DNS server (code %i)", regs.Bytes.B);
	ld	hl, #(_regs + 0x0003) + 0
	ld	c,(hl)
	ld	b,#0x00
	push	bc
	ld	hl,#___str_19
	push	hl
	ld	hl,(_buffer)
	push	hl
	call	_sprintf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;sntp.c:327: Terminate(buffer);
	ld	hl,(_buffer)
	push	hl
	call	_Terminate
	pop	af
00183$:
;sntp.c:331: paramsBlock[0] = regs.Bytes.L;
	ld	a, (#(_regs + 0x0006) + 0)
	ld	(#_paramsBlock),a
;sntp.c:332: paramsBlock[1] = regs.Bytes.H;
	ld	a, (#(_regs + 0x0007) + 0)
	ld	(#(_paramsBlock + 0x0001)),a
;sntp.c:333: paramsBlock[2] = regs.Bytes.E;
	ld	a, (#(_regs + 0x0004) + 0)
	ld	(#(_paramsBlock + 0x0002)),a
;sntp.c:334: paramsBlock[3] = regs.Bytes.D;
	ld	a, (#(_regs + 0x0005) + 0)
	ld	hl,#(_paramsBlock + 0x0003)
	ld	(hl),a
;sntp.c:336: if(verbose) {
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00185$
;sntp.c:337: printf("OK, %i.%i.%i.%i\r\n", paramsBlock[0], paramsBlock[1], paramsBlock[2], paramsBlock[3]);
	ld	hl, #(_paramsBlock + 0x0003) + 0
	ld	e,(hl)
	ld	d,#0x00
	ld	hl, #(_paramsBlock + 0x0002) + 0
	ld	c,(hl)
	ld	b,#0x00
	ld	a, (#(_paramsBlock + 0x0001) + 0)
	ld	-2 (ix),a
	ld	-1 (ix),#0x00
	ld	a, (#_paramsBlock + 0)
	ld	-4 (ix),a
	ld	-3 (ix),#0x00
	push	de
	push	bc
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	ld	hl,#___str_20
	push	hl
	call	_printf
	ld	hl,#10
	add	hl,sp
	ld	sp,hl
00185$:
;sntp.c:342: PrintIfVerbose("Querying the time server... ");
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00187$
	ld	hl,#___str_21
	push	hl
	call	_printf
	pop	af
00187$:
;sntp.c:344: *buffer=0x1B;
	ld	hl,(_buffer)
	ld	(hl),#0x1b
;sntp.c:345: for(i=1; i<48; i++) {
	ld	hl,#0x0001
	ld	(_i),hl
00239$:
;sntp.c:346: buffer[i]=0;
	ld	iy,(_buffer)
	ld	de,(_i)
	add	iy, de
	ld	0 (iy), #0x00
;sntp.c:345: for(i=1; i<48; i++) {
	ld	iy,#_i
	inc	0 (iy)
	jr	NZ,00543$
	inc	1 (iy)
00543$:
	ld	a,0 (iy)
	sub	a, #0x30
	ld	a,1 (iy)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00239$
;sntp.c:349: paramsBlock[4] = SNTP_PORT;
	ld	hl,#(_paramsBlock + 0x0004)
	ld	(hl),#0x7b
;sntp.c:350: paramsBlock[5] = 0;
	ld	hl,#(_paramsBlock + 0x0005)
	ld	(hl),#0x00
;sntp.c:351: paramsBlock[6] = 48;
	ld	hl,#(_paramsBlock + 0x0006)
	ld	(hl),#0x30
;sntp.c:352: paramsBlock[7] = 0;
	ld	hl,#(_paramsBlock + 0x0007)
	ld	(hl),#0x00
;sntp.c:354: regs.Bytes.B = conn;
	ld	hl,#_conn + 0
	ld	c, (hl)
	ld	hl,#(_regs + 0x0003)
	ld	(hl),c
;sntp.c:355: regs.Words.HL=(int)buffer;
	ld	bc,(_buffer)
	ld	((_regs + 0x0006)), bc
;sntp.c:356: regs.Words.DE=(int)paramsBlock;
	ld	bc,#_paramsBlock
	ld	((_regs + 0x0004)), bc
;sntp.c:358: UnapiCall(&codeBlock, TCPIP_UDP_SEND, &regs, REGS_MAIN, REGS_MAIN);
	ld	hl,#0x0202
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x0b
	push	af
	inc	sp
	ld	hl,#_codeBlock
	push	hl
	call	_UnapiCall
	ld	hl,#7
	add	hl,sp
	ld	sp,hl
;sntp.c:359: if(regs.Bytes.A != 0) {
	ld	a, (#(_regs + 0x0001) + 0)
	or	a, a
	jr	Z,00190$
;sntp.c:360: sprintf(buffer, "Unknown error when sending request to time server (code %i)", regs.Bytes.A);
	ld	hl, #(_regs + 0x0001) + 0
	ld	c,(hl)
	ld	b,#0x00
	push	bc
	ld	hl,#___str_22
	push	hl
	ld	hl,(_buffer)
	push	hl
	call	_sprintf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;sntp.c:361: Terminate(buffer);
	ld	hl,(_buffer)
	push	hl
	call	_Terminate
	pop	af
00190$:
;sntp.c:366: ticksWaited = 0;
	ld	hl,#0x0000
	ld	(_ticksWaited),hl
;sntp.c:367: do {
00200$:
;sntp.c:368: sysTimerHold = *SYSTIMER;
	ld	hl,#0xfc9e
	ld	a,(hl)
	ld	iy,#_sysTimerHold
	ld	0 (iy),a
	inc	hl
	ld	a,(hl)
	ld	1 (iy),a
;sntp.c:369: UnapiCall(&codeBlock, TCPIP_WAIT, &regs, REGS_MAIN, REGS_NONE);
	ld	hl,#0x0002
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x1d
	push	af
	inc	sp
	ld	hl,#_codeBlock
	push	hl
	call	_UnapiCall
	ld	hl,#7
	add	hl,sp
	ld	sp,hl
;sntp.c:370: while(*SYSTIMER == sysTimerHold);
00191$:
	ld	hl,#0xfc9e
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	de,(_sysTimerHold)
	ld	a,c
	sub	a, e
	jr	NZ,00544$
	ld	a,b
	sub	a, d
	jr	Z,00191$
00544$:
;sntp.c:371: ticksWaited++;
	ld	iy,#_ticksWaited
	inc	0 (iy)
	jr	NZ,00545$
	inc	1 (iy)
00545$:
;sntp.c:372: if(ticksWaited >= TICKS_TO_WAIT) {
	ld	a,0 (iy)
	sub	a, #0x96
	ld	a,1 (iy)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00195$
;sntp.c:373: Terminate("The time server did not send a reply");
	ld	hl,#___str_23
	push	hl
	call	_Terminate
	pop	af
00195$:
;sntp.c:375: regs.Bytes.B = conn;
	ld	hl,#_conn + 0
	ld	c, (hl)
	ld	hl,#(_regs + 0x0003)
	ld	(hl),c
;sntp.c:376: regs.Words.HL = (int)buffer;
	ld	bc,(_buffer)
	ld	((_regs + 0x0006)), bc
;sntp.c:377: regs.Words.DE = 48;
	ld	hl,#0x0030
	ld	((_regs + 0x0004)), hl
;sntp.c:378: UnapiCall(&codeBlock, TCPIP_UDP_RCV, &regs, REGS_MAIN, REGS_MAIN);
	ld	hl,#0x0202
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x0c
	push	af
	inc	sp
	ld	hl,#_codeBlock
	push	hl
	call	_UnapiCall
	ld	hl,#7
	add	hl,sp
	ld	sp,hl
;sntp.c:379: } while(regs.Bytes.A == ERR_NO_DATA || (
	ld	a, (#(_regs + 0x0001) + 0)
	sub	a, #0x03
	jp	Z,00200$
;sntp.c:380: (regs.Bytes.L != paramsBlock[0]) ||
	ld	hl, #(_regs + 0x0006) + 0
	ld	c,(hl)
	ld	hl, #_paramsBlock + 0
	ld	b,(hl)
	ld	a,c
	sub	a, b
	jp	NZ,00200$
;sntp.c:381: (regs.Bytes.H != paramsBlock[1]) ||
	ld	hl, #(_regs + 0x0007) + 0
	ld	c,(hl)
	ld	hl, #(_paramsBlock + 0x0001) + 0
	ld	b,(hl)
	ld	a,c
	sub	a, b
	jp	NZ,00200$
;sntp.c:382: (regs.Bytes.E != paramsBlock[2]) ||
	ld	hl, #(_regs + 0x0004) + 0
	ld	c,(hl)
	ld	hl, #(_paramsBlock + 0x0002) + 0
	ld	b,(hl)
	ld	a,c
	sub	a, b
	jp	NZ,00200$
;sntp.c:383: (regs.Bytes.D != paramsBlock[3])));
	ld	hl, #(_regs + 0x0005) + 0
	ld	c,(hl)
	ld	hl, #(_paramsBlock + 0x0003) + 0
	ld	b,(hl)
	ld	a,c
	sub	a, b
	jp	NZ,00200$
;sntp.c:385: if(regs.Bytes.A != 0) {
	ld	a, (#(_regs + 0x0001) + 0)
	or	a, a
	jr	Z,00204$
;sntp.c:386: sprintf(buffer, "Unknown error when waiting a reply from the time server (code %i)", regs.Bytes.A);
	ld	hl, #(_regs + 0x0001) + 0
	ld	c,(hl)
	ld	b,#0x00
	push	bc
	ld	hl,#___str_24
	push	hl
	ld	hl,(_buffer)
	push	hl
	call	_sprintf
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;sntp.c:387: Terminate(buffer);
	ld	hl,(_buffer)
	push	hl
	call	_Terminate
	pop	af
00204$:
;sntp.c:390: if(regs.UWords.BC < 48) {
	ld	hl, (#_regs + 2)
	ld	a,l
	sub	a, #0x30
	ld	a,h
	sbc	a, #0x00
	jr	NC,00206$
;sntp.c:391: Terminate("The server returned a too short packet");
	ld	hl,#___str_25
	push	hl
	call	_Terminate
	pop	af
00206$:
;sntp.c:394: if(buffer[1] == 0) {
	ld	hl,(_buffer)
	inc	hl
	ld	a,(hl)
	or	a, a
	jr	NZ,00208$
;sntp.c:395: Terminate("The server returned a \"Kiss of death\" packet\r\n(are you querying the server too often?)");
	ld	hl,#___str_26
	push	hl
	call	_Terminate
	pop	af
00208$:
;sntp.c:398: PrintIfVerbose(strOK);
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00210$
	ld	hl,(_strOK)
	push	hl
	call	_printf
	pop	af
00210$:
;sntp.c:400: if(buffer[0] & 0xC0 == 0xC0 && verbose) {
	ld	hl,(_buffer)
	ld	a,(hl)
	rrca
	jr	NC,00212$
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00212$
;sntp.c:401: print("WARNING: Error returned by server: clock is not synchronized\r\n");
	ld	hl,#___str_27
	push	hl
	call	_printf
	pop	af
00212$:
;sntp.c:406: ((byte*)&seconds)[0]=buffer[43];
	ld	bc,#_seconds+0
	ld	e, c
	ld	d, b
	ld	iy,(_buffer)
	ld	a,43 (iy)
	ld	(de),a
;sntp.c:407: ((byte*)&seconds)[1]=buffer[42];
	ld	e, c
	ld	d, b
	inc	de
	ld	iy,(_buffer)
	ld	a,42 (iy)
	ld	(de),a
;sntp.c:408: ((byte*)&seconds)[2]=buffer[41];
	ld	e, c
	ld	d, b
	inc	de
	inc	de
	ld	iy,(_buffer)
	ld	a,41 (iy)
	ld	(de),a
;sntp.c:409: ((byte*)&seconds)[3]=buffer[40];
	inc	bc
	inc	bc
	inc	bc
	ld	iy,(_buffer)
	ld	a,40 (iy)
	ld	(bc),a
;sntp.c:411: if(verbose) {
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00215$
;sntp.c:412: SecondsToDate(seconds, &year, &month, &day, &hour, &minute, &second);
	ld	hl,#_second
	push	hl
	ld	hl,#_minute
	push	hl
	ld	hl,#_hour
	push	hl
	ld	hl,#_day
	push	hl
	ld	hl,#_month
	push	hl
	ld	hl,#_year
	push	hl
	ld	hl,(_seconds + 2)
	push	hl
	ld	hl,(_seconds)
	push	hl
	call	_SecondsToDate
	ld	hl,#16
	add	hl,sp
	ld	sp,hl
;sntp.c:413: CheckYear();
	call	_CheckYear
;sntp.c:414: printf("Time returned by time server: %i-%i-%i, %i:%i:%i\r\n", year, month, day, hour, minute, second);
	ld	a,(#_second + 0)
	ld	-4 (ix),a
	ld	-3 (ix),#0x00
	ld	a,(#_minute + 0)
	ld	-2 (ix),a
	ld	-1 (ix),#0x00
	ld	a,(#_hour + 0)
	ld	-6 (ix),a
	ld	-5 (ix),#0x00
	ld	hl,#_day + 0
	ld	c, (hl)
	ld	b,#0x00
	ld	hl,#_month + 0
	ld	e, (hl)
	ld	d,#0x00
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	push	hl
	push	bc
	push	de
	ld	hl,(_year)
	push	hl
	ld	hl,#___str_28
	push	hl
	call	_printf
	ld	hl,#14
	add	hl,sp
	ld	sp,hl
00215$:
;sntp.c:417: if(timeZoneString != NULL) {
	ld	iy,#_timeZoneString
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00220$
;sntp.c:418: if(timeZoneString[0] == '-') {
	ld	hl,(_timeZoneString)
	ld	a,(hl)
	ld	-6 (ix),a
;sntp.c:419: seconds -= timeZoneSeconds;
	ld	hl,#_timeZoneSeconds
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	de,#0x0000
;sntp.c:418: if(timeZoneString[0] == '-') {
	ld	a,-6 (ix)
	sub	a, #0x2d
	jr	NZ,00217$
;sntp.c:419: seconds -= timeZoneSeconds;
	ld	hl,#_seconds
	ld	a,(hl)
	sub	a, c
	ld	(hl),a
	inc	hl
	ld	a,(hl)
	sbc	a, b
	ld	(hl),a
	inc	hl
	ld	a,(hl)
	sbc	a, e
	ld	(hl),a
	inc	hl
	ld	a,(hl)
	sbc	a, d
	ld	(hl),a
	jr	00220$
00217$:
;sntp.c:421: seconds += timeZoneSeconds;
	ld	hl,#_seconds
	ld	a,(hl)
	add	a, c
	ld	(hl),a
	inc	hl
	ld	a,(hl)
	adc	a, b
	ld	(hl),a
	inc	hl
	ld	a,(hl)
	adc	a, e
	ld	(hl),a
	inc	hl
	ld	a,(hl)
	adc	a, d
	ld	(hl),a
00220$:
;sntp.c:425: SecondsToDate(seconds, &year, &month, &day, &hour, &minute, &second);
	ld	hl,#_second
	push	hl
	ld	hl,#_minute
	push	hl
	ld	hl,#_hour
	push	hl
	ld	hl,#_day
	push	hl
	ld	hl,#_month
	push	hl
	ld	hl,#_year
	push	hl
	ld	hl,(_seconds + 2)
	push	hl
	ld	hl,(_seconds)
	push	hl
	call	_SecondsToDate
	ld	hl,#16
	add	hl,sp
	ld	sp,hl
;sntp.c:426: CheckYear();
	call	_CheckYear
;sntp.c:427: if(verbose && timeZoneString != NULL) {
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00222$
	ld	iy,#_timeZoneString
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00222$
;sntp.c:428: printf("Time adjusted to time zone:   %i-%i-%i, %i:%i:%i\r\n", year, month, day, hour, minute, second);
	ld	a,(#_second + 0)
	ld	-6 (ix),a
	ld	-5 (ix),#0x00
	ld	a,(#_minute + 0)
	ld	-4 (ix),a
	ld	-3 (ix),#0x00
	ld	a,(#_hour + 0)
	ld	-2 (ix),a
	ld	-1 (ix),#0x00
	ld	hl,#_day + 0
	ld	c, (hl)
	ld	b,#0x00
	ld	hl,#_month + 0
	ld	e, (hl)
	ld	d,#0x00
	pop	hl
	push	hl
	push	hl
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	push	bc
	push	de
	ld	hl,(_year)
	push	hl
	ld	hl,#___str_29
	push	hl
	call	_printf
	ld	hl,#14
	add	hl,sp
	ld	sp,hl
00222$:
;sntp.c:433: if(displayOnly) {
	ld	iy,#_displayOnly
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00234$
;sntp.c:434: if(!verbose) {
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jp	NZ,00235$
;sntp.c:435: printf("Time obtained from time server: %i-%i-%i, %i:%i:%i\r\n", year, month, day, hour, minute, second);
	ld	a,(#_second + 0)
	ld	-6 (ix),a
	ld	-5 (ix),#0x00
	ld	a,(#_minute + 0)
	ld	-4 (ix),a
	ld	-3 (ix),#0x00
	ld	a,(#_hour + 0)
	ld	-2 (ix),a
	ld	-1 (ix),#0x00
	ld	hl,#_day + 0
	ld	c, (hl)
	ld	b,#0x00
	ld	hl,#_month + 0
	ld	e, (hl)
	ld	d,#0x00
	pop	hl
	push	hl
	push	hl
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	push	bc
	push	de
	ld	hl,(_year)
	push	hl
	ld	hl,#___str_30
	push	hl
	call	_printf
	ld	hl,#14
	add	hl,sp
	ld	sp,hl
	jp	00235$
00234$:
;sntp.c:438: regs.UWords.HL = year;
	ld	hl,#(_regs + 0x0006)
	ld	iy,#_year
	ld	a,0 (iy)
	ld	(hl),a
	inc	hl
	ld	a,1 (iy)
	ld	(hl),a
;sntp.c:439: regs.Bytes.D = month;
	ld	hl,#(_regs + 0x0005)
	ld	a,(#_month + 0)
	ld	(hl),a
;sntp.c:440: regs.Bytes.E = day;
	ld	hl,#(_regs + 0x0004)
	ld	a,(#_day + 0)
	ld	(hl),a
;sntp.c:441: DosCall(_SDATE, &regs, REGS_MAIN, REGS_AF);
	ld	hl,#0x0102
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x2b
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
;sntp.c:442: if(regs.Bytes.A != 0) {
	ld	a, (#(_regs + 0x0001) + 0)
	or	a, a
	jr	Z,00227$
;sntp.c:443: Terminate("Invalid date for the MSX clock");
	ld	hl,#___str_31
	push	hl
	call	_Terminate
	pop	af
00227$:
;sntp.c:446: regs.Bytes.H = hour;
	ld	hl,#(_regs + 0x0007)
	ld	a,(#_hour + 0)
	ld	(hl),a
;sntp.c:447: regs.Bytes.L = minute;
	ld	hl,#(_regs + 0x0006)
	ld	a,(#_minute + 0)
	ld	(hl),a
;sntp.c:448: regs.Bytes.D = second;
	ld	hl,#(_regs + 0x0005)
	ld	a,(#_second + 0)
	ld	(hl),a
;sntp.c:449: DosCall(_STIME, &regs, REGS_MAIN, REGS_AF);
	ld	hl,#0x0102
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x2d
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
;sntp.c:450: if(regs.Bytes.A != 0) {
	ld	a, (#(_regs + 0x0001) + 0)
	or	a, a
	jr	Z,00229$
;sntp.c:451: Terminate("Invalid time for the MSX clock");
	ld	hl,#___str_32
	push	hl
	call	_Terminate
	pop	af
00229$:
;sntp.c:454: if(verbose) {
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00231$
;sntp.c:455: print("The clock has been set to the adjusted time.");
	ld	hl,#___str_33
	push	hl
	call	_printf
	pop	af
	jr	00235$
00231$:
;sntp.c:457: printf("The clock has been set to: %i-%i-%i, %i:%i:%i\r\n", year, month, day, hour, minute, second);
	ld	a,(#_second + 0)
	ld	-6 (ix),a
	ld	-5 (ix),#0x00
	ld	a,(#_minute + 0)
	ld	-4 (ix),a
	ld	-3 (ix),#0x00
	ld	a,(#_hour + 0)
	ld	-2 (ix),a
	ld	-1 (ix),#0x00
	ld	hl,#_day + 0
	ld	c, (hl)
	ld	b,#0x00
	ld	hl,#_month + 0
	ld	e, (hl)
	ld	d,#0x00
	pop	hl
	push	hl
	push	hl
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	push	bc
	push	de
	ld	hl,(_year)
	push	hl
	ld	hl,#___str_34
	push	hl
	call	_printf
	ld	hl,#14
	add	hl,sp
	ld	sp,hl
00235$:
;sntp.c:461: Terminate(NULL);
	ld	hl,#0x0000
	push	hl
	call	_Terminate
	pop	af
;sntp.c:462: return 0;
	ld	hl,#0x0000
	ld	sp, ix
	pop	ix
	ret
___str_0:
	.ascii "TIMEZONE"
	.db 0x00
___str_1:
	.ascii "TIMESERVER"
	.db 0x00
___str_2:
	.ascii "No time server specified and no TIMESERVER environment item "
	.ascii "was found."
	.db 0x00
___str_3:
	.ascii "Time server is: %s"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_4:
	.ascii "TCP/IP"
	.db 0x00
___str_5:
	.ascii "No TCP/IP UNAPI implementations found"
	.db 0x00
___str_6:
	.ascii "This TCP/IP UNAPI implementation does not support UDP connec"
	.ascii "tions"
	.db 0x00
___str_7:
	.ascii "No free UDP connections available"
	.db 0x00
___str_8:
	.ascii "There is a resident UDP connection which uses the SNTP port"
	.db 0x00
___str_9:
	.ascii "Unknown error when opening UDP connection (code %i)"
	.db 0x00
___str_10:
	.ascii "Resolving host name... "
	.db 0x00
___str_11:
	.ascii "There are no DNS servers configured"
	.db 0x00
___str_12:
	.ascii "This TCP/IP UNAPI implementation does not support resolving "
	.ascii "host names."
	.db 0x0d
	.db 0x0a
	.ascii "Specify an IP address instead."
	.db 0x00
___str_13:
	.ascii "Unknown error when resolving the host name (code %i)"
	.db 0x00
___str_14:
	.ascii "DNS server failure"
	.db 0x00
___str_15:
	.ascii "Unknown host name"
	.db 0x00
___str_16:
	.ascii "DNS server refused the query"
	.db 0x00
___str_17:
	.ascii "DNS server did not reply"
	.db 0x00
___str_18:
	.ascii "DNS query failed"
	.db 0x00
___str_19:
	.ascii "Unknown error returned by DNS server (code %i)"
	.db 0x00
___str_20:
	.ascii "OK, %i.%i.%i.%i"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_21:
	.ascii "Querying the time server... "
	.db 0x00
___str_22:
	.ascii "Unknown error when sending request to time server (code %i)"
	.db 0x00
___str_23:
	.ascii "The time server did not send a reply"
	.db 0x00
___str_24:
	.ascii "Unknown error when waiting a reply from the time server (cod"
	.ascii "e %i)"
	.db 0x00
___str_25:
	.ascii "The server returned a too short packet"
	.db 0x00
___str_26:
	.ascii "The server returned a "
	.db 0x22
	.ascii "Kiss of death"
	.db 0x22
	.ascii " packet"
	.db 0x0d
	.db 0x0a
	.ascii "(are you query"
	.ascii "ing the server too often?)"
	.db 0x00
___str_27:
	.ascii "WARNING: Error returned by server: clock is not synchronized"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_28:
	.ascii "Time returned by time server: %i-%i-%i, %i:%i:%i"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_29:
	.ascii "Time adjusted to time zone:   %i-%i-%i, %i:%i:%i"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_30:
	.ascii "Time obtained from time server: %i-%i-%i, %i:%i:%i"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_31:
	.ascii "Invalid date for the MSX clock"
	.db 0x00
___str_32:
	.ascii "Invalid time for the MSX clock"
	.db 0x00
___str_33:
	.ascii "The clock has been set to the adjusted time."
	.db 0x00
___str_34:
	.ascii "The clock has been set to: %i-%i-%i, %i:%i:%i"
	.db 0x0d
	.db 0x0a
	.db 0x00
;sntp.c:470: void PrintUsageAndEnd()
;	---------------------------------
; Function PrintUsageAndEnd
; ---------------------------------
_PrintUsageAndEnd::
;sntp.c:472: print(strUsage);
	ld	hl,(_strUsage)
	push	hl
	call	_printf
;sntp.c:473: DosCall(0, &regs, REGS_MAIN, REGS_NONE);
	ld	hl, #0x0002
	ex	(sp),hl
	ld	hl,#_regs
	push	hl
	xor	a, a
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
	ret
;sntp.c:476: void SecondsToDate(unsigned long seconds, int* year, byte* month, byte* day, byte* hour, byte* minute, byte* second)
;	---------------------------------
; Function SecondsToDate
; ---------------------------------
_SecondsToDate::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-8
	add	hl,sp
	ld	sp,hl
;sntp.c:482: *year = 2036;
	ld	a,8 (ix)
	ld	-2 (ix),a
	ld	a,9 (ix)
	ld	-1 (ix),a
;sntp.c:481: if((seconds & 0x80000000) == 0) {
	bit	7, 7 (ix)
	jr	NZ,00102$
;sntp.c:482: *year = 2036;
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	(hl),#0xf4
	inc	hl
	ld	(hl),#0x07
;sntp.c:483: seconds += SECS_2036_TO_2036;
	ld	a,4 (ix)
	add	a, #0x80
	ld	4 (ix),a
	ld	a,5 (ix)
	adc	a, #0x22
	ld	5 (ix),a
	ld	a,6 (ix)
	adc	a, #0x31
	ld	6 (ix),a
	ld	a,7 (ix)
	adc	a, #0x00
	ld	7 (ix),a
	jr	00110$
00102$:
;sntp.c:486: *year = 2010;
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	(hl),#0xda
	inc	hl
	ld	(hl),#0x07
;sntp.c:487: seconds -= SECS_1900_TO_2010;
	ld	a,4 (ix)
	add	a,#0x80
	ld	4 (ix),a
	ld	a,5 (ix)
	adc	a,#0x46
	ld	5 (ix),a
	ld	a,6 (ix)
	adc	a,#0x18
	ld	6 (ix),a
	ld	a,7 (ix)
	adc	a,#0x31
	ld	7 (ix),a
;sntp.c:492: while(1) {
00110$:
;sntp.c:493: IsLeapYear = ((*year & 3) == 0);
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	a,(hl)
	ld	-4 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-3 (ix),a
	ld	a,-4 (ix)
	and	a, #0x03
	ld	c,a
	ld	b,#0x00
	ld	a,c
	or	a, b
	jr	NZ,00199$
	ld	a,#0x01
	jr	00200$
00199$:
	xor	a,a
00200$:
	ld	c,a
	rla
	sbc	a, a
;sntp.c:494: if((!IsLeapYear && (seconds < SECS_IN_YEAR)) || (IsLeapYear && (seconds < SECS_IN_LYEAR))) {
	ld	b,a
	or	a,c
	jr	NZ,00108$
	ld	a,4 (ix)
	sub	a, #0x80
	ld	a,5 (ix)
	sbc	a, #0x33
	ld	a,6 (ix)
	sbc	a, #0xe1
	ld	a,7 (ix)
	sbc	a, #0x01
	jr	C,00111$
00108$:
	ld	a,b
	or	a,c
	jr	Z,00105$
	ld	a,5 (ix)
	sub	a, #0x85
	ld	a,6 (ix)
	sbc	a, #0xe2
	ld	a,7 (ix)
	sbc	a, #0x01
	jr	C,00111$
;sntp.c:495: break;
00105$:
;sntp.c:497: seconds -= (IsLeapYear ? SECS_IN_LYEAR : SECS_IN_YEAR);
	ld	a,b
	or	a,c
	jr	Z,00132$
	ld	bc,#0x8500
	ld	de,#0x01e2
	jr	00133$
00132$:
	ld	bc,#0x3380
	ld	de,#0x01e1
00133$:
	ld	a,4 (ix)
	sub	a, c
	ld	4 (ix),a
	ld	a,5 (ix)
	sbc	a, b
	ld	5 (ix),a
	ld	a,6 (ix)
	sbc	a, e
	ld	6 (ix),a
	ld	a,7 (ix)
	sbc	a, d
	ld	7 (ix),a
;sntp.c:498: *year = *year+1;
	ld	c,-4 (ix)
	ld	b,-3 (ix)
	inc	bc
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	(hl),c
	inc	hl
	ld	(hl),b
	jp	00110$
00111$:
;sntp.c:503: *month = 1;
	ld	e,10 (ix)
	ld	d,11 (ix)
	ld	a,#0x01
	ld	(de),a
;sntp.c:505: while(1) {
00119$:
;sntp.c:506: if(*month == 2 && IsLeapYear) {
	ld	a,(de)
	ld	-4 (ix), a
	sub	a, #0x02
	jr	NZ,00113$
	ld	a,b
	or	a,c
	jr	Z,00113$
;sntp.c:507: SecsInCurrentMoth = SECS_IN_MONTH_29;
	ld	-8 (ix),#0x80
	ld	-7 (ix),#0x3b
	ld	-6 (ix),#0x26
	ld	-5 (ix),#0x00
	jr	00114$
00113$:
;sntp.c:510: SecsInCurrentMoth = SecsPerMonth[*month - 1];
	ld	l,-4 (ix)
	dec	l
	ld	h,#0x00
	add	hl, hl
	add	hl, hl
	ld	a,#<(_SecsPerMonth)
	add	a, l
	ld	l,a
	ld	a,#>(_SecsPerMonth)
	adc	a, h
	ld	h,a
	push	de
	push	bc
	ex	de,hl
	ld	hl, #0x0004
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
	pop	de
00114$:
;sntp.c:513: if(seconds < SecsInCurrentMoth) {
	ld	a,4 (ix)
	sub	a, -8 (ix)
	ld	a,5 (ix)
	sbc	a, -7 (ix)
	ld	a,6 (ix)
	sbc	a, -6 (ix)
	ld	a,7 (ix)
	sbc	a, -5 (ix)
	jr	C,00120$
;sntp.c:517: seconds -= SecsInCurrentMoth;
	ld	a,4 (ix)
	sub	a, -8 (ix)
	ld	4 (ix),a
	ld	a,5 (ix)
	sbc	a, -7 (ix)
	ld	5 (ix),a
	ld	a,6 (ix)
	sbc	a, -6 (ix)
	ld	6 (ix),a
	ld	a,7 (ix)
	sbc	a, -5 (ix)
	ld	7 (ix),a
;sntp.c:518: *month = (byte)(*month + 1);
	ld	a,-4 (ix)
	inc	a
	ld	(de),a
	jp	00119$
00120$:
;sntp.c:523: *day = 1;
	ld	l,12 (ix)
	ld	h,13 (ix)
	ld	(hl),#0x01
;sntp.c:525: while(seconds > SECS_IN_DAY) {
	ld	c,4 (ix)
	ld	b,5 (ix)
	ld	e,6 (ix)
	ld	d,7 (ix)
00121$:
	ld	a,#0x80
	cp	a, c
	ld	a,#0x51
	sbc	a, b
	ld	a,#0x01
	sbc	a, e
	ld	a,#0x00
	sbc	a, d
	jr	NC,00123$
;sntp.c:526: seconds -= SECS_IN_DAY;
	ld	a,c
	add	a,#0x80
	ld	c,a
	ld	a,b
	adc	a,#0xae
	ld	b,a
	ld	a,e
	adc	a,#0xfe
	ld	e,a
	ld	a,d
	adc	a,#0xff
	ld	d,a
;sntp.c:527: *day = (byte)(*day + 1);
	inc	(hl)
	jr	00121$
00123$:
;sntp.c:532: *hour = 0;
	ld	l,14 (ix)
	ld	h,15 (ix)
	ld	(hl),#0x00
;sntp.c:534: while(seconds > SECS_IN_HOUR) {
00124$:
	ld	a,#0x10
	cp	a, c
	ld	a,#0x0e
	sbc	a, b
	ld	a,#0x00
	sbc	a, e
	ld	a,#0x00
	sbc	a, d
	jr	NC,00126$
;sntp.c:535: seconds -= SECS_IN_HOUR;
	ld	a,c
	add	a,#0xf0
	ld	c,a
	ld	a,b
	adc	a,#0xf1
	ld	b,a
	ld	a,e
	adc	a,#0xff
	ld	e,a
	ld	a,d
	adc	a,#0xff
	ld	d,a
;sntp.c:536: *hour = (byte)(*hour + 1);
	inc	(hl)
	jr	00124$
00126$:
;sntp.c:541: *minute = 0;
	ld	l,16 (ix)
	ld	h,17 (ix)
	ld	(hl),#0x00
;sntp.c:543: while(seconds >= SECS_IN_MINUTE) {
00127$:
	ld	a,c
	sub	a, #0x3c
	ld	a,b
	sbc	a, #0x00
	ld	a,e
	sbc	a, #0x00
	ld	a,d
	sbc	a, #0x00
	jr	C,00129$
;sntp.c:544: seconds -= SECS_IN_MINUTE;
	ld	a,c
	add	a,#0xc4
	ld	c,a
	ld	a,b
	adc	a,#0xff
	ld	b,a
	ld	a,e
	adc	a,#0xff
	ld	e,a
	ld	a,d
	adc	a,#0xff
	ld	d,a
;sntp.c:545: *minute = (byte)(*minute + 1);
	inc	(hl)
	jr	00127$
00129$:
;sntp.c:550: *second = (byte)seconds;
	ld	l,18 (ix)
	ld	h,19 (ix)
	ld	(hl),c
	ld	sp, ix
	pop	ix
	ret
;sntp.c:554: int IsValidTimeZone(byte* timeZoneString)
;	---------------------------------
; Function IsValidTimeZone
; ---------------------------------
_IsValidTimeZone::
;sntp.c:556: if(!(timeZoneString[0]==(byte)'+' || timeZoneString[0]==(byte)'-')) {
	pop	de
	pop	bc
	push	bc
	push	de
	ld	a,(bc)
	ld	e,a
	sub	a, #0x2b
	jr	Z,00102$
	ld	a,e
	sub	a, #0x2d
	jr	Z,00102$
;sntp.c:557: return 0;
	ld	hl,#0x0000
	ret
00102$:
;sntp.c:560: if(!(IsDigit(timeZoneString[1]) && IsDigit(timeZoneString[2]) && IsDigit(timeZoneString[4]) && IsDigit(timeZoneString[5])))
	ld	l, c
	ld	h, b
	inc	hl
	ld	d,(hl)
	push	bc
	push	de
	inc	sp
	call	_IsDigit
	inc	sp
	pop	bc
	ld	a,h
	or	a,l
	jr	Z,00104$
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	d,(hl)
	push	bc
	push	de
	inc	sp
	call	_IsDigit
	inc	sp
	pop	bc
	ld	a,h
	or	a,l
	jr	Z,00104$
	push	bc
	pop	iy
	ld	d,4 (iy)
	push	bc
	push	de
	inc	sp
	call	_IsDigit
	inc	sp
	pop	bc
	ld	a,h
	or	a,l
	jr	Z,00104$
	push	bc
	pop	iy
	ld	d,5 (iy)
	push	bc
	push	de
	inc	sp
	call	_IsDigit
	inc	sp
	pop	bc
	ld	a,h
	or	a,l
	jr	NZ,00105$
00104$:
;sntp.c:562: return 0;
	ld	hl,#0x0000
	ret
00105$:
;sntp.c:565: if(timeZoneString[3] != (byte)':' || timeZoneString[6] != 0)
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	sub	a, #0x3a
	jr	NZ,00109$
	push	bc
	pop	iy
	ld	a,6 (iy)
	or	a, a
	jr	Z,00110$
00109$:
;sntp.c:567: return 0;
	ld	hl,#0x0000
	ret
00110$:
;sntp.c:570: return 1;
	ld	hl,#0x0001
	ret
;sntp.c:574: int IsDigit(char theChar)
;	---------------------------------
; Function IsDigit
; ---------------------------------
_IsDigit::
	dec	sp
;sntp.c:576: return (theChar>='0' && theChar<='9');
	ld	iy,#3
	add	iy,sp
	ld	a,0 (iy)
	sub	a, #0x30
	jr	C,00103$
	ld	a,#0x39
	sub	a, 0 (iy)
	jr	NC,00104$
00103$:
	ld	l,#0x00
	jr	00105$
00104$:
	ld	l,#0x01
00105$:
	ld	h,#0x00
	inc	sp
	ret
;sntp.c:580: void Terminate(char* errorMessage)
;	---------------------------------
; Function Terminate
; ---------------------------------
_Terminate::
	push	ix
	ld	ix,#0
	add	ix,sp
;sntp.c:582: if(errorMessage != NULL) {
	ld	a,5 (ix)
	or	a,4 (ix)
	jr	Z,00105$
;sntp.c:583: if(verbose) {
	ld	iy,#_verbose
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00102$
;sntp.c:584: printf("\r\n*** ERROR: %s\r\n", errorMessage);
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	hl,#___str_35
	push	hl
	call	_printf
	pop	af
	pop	af
	jr	00105$
00102$:
;sntp.c:586: printf("*** SNTP ERROR: %s\r\n", errorMessage);
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	hl,#___str_36
	push	hl
	call	_printf
	pop	af
	pop	af
00105$:
;sntp.c:590: if(conn != 0) {
	ld	iy,#_conn
	ld	a,1 (iy)
	or	a,0 (iy)
	jr	Z,00107$
;sntp.c:591: regs.Bytes.B = conn;
	ld	bc,#_regs+3
	ld	a,0 (iy)
	ld	(bc),a
;sntp.c:592: UnapiCall(&codeBlock, TCPIP_UDP_CLOSE, &regs, REGS_MAIN, REGS_NONE);
	ld	hl,#0x0002
	push	hl
	ld	hl,#_regs
	push	hl
	ld	a,#0x09
	push	af
	inc	sp
	ld	hl,#_codeBlock
	push	hl
	call	_UnapiCall
	ld	hl,#7
	add	hl,sp
	ld	sp,hl
00107$:
;sntp.c:595: DosCall(_TERM0, &regs, REGS_NONE, REGS_NONE);
	ld	hl,#0x0000
	push	hl
	ld	hl,#_regs
	push	hl
	xor	a, a
	push	af
	inc	sp
	call	_DosCall
	pop	af
	pop	af
	inc	sp
	pop	ix
	ret
___str_35:
	.db 0x0d
	.db 0x0a
	.ascii "*** ERROR: %s"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_36:
	.ascii "*** SNTP ERROR: %s"
	.db 0x0d
	.db 0x0a
	.db 0x00
;sntp.c:599: void CheckYear()
;	---------------------------------
; Function CheckYear
; ---------------------------------
_CheckYear::
;sntp.c:601: if(year < 2010) {
	ld	iy,#_year
	ld	a,0 (iy)
	sub	a, #0xda
	ld	a,1 (iy)
	rla
	ccf
	rra
	sbc	a, #0x87
	jr	NC,00102$
;sntp.c:602: Terminate("The server returned a date that is before year 2010");
	ld	hl,#___str_37
	push	hl
	call	_Terminate
	pop	af
00102$:
;sntp.c:605: if(year > 2079) {
	ld	a,#0x1f
	ld	iy,#_year
	cp	a, 0 (iy)
	ld	a,#0x08
	sbc	a, 1 (iy)
	jp	PO, 00115$
	xor	a, #0x80
00115$:
	ret	P
;sntp.c:606: Terminate("The server returned a date that is after year 2079");
	ld	hl,#___str_38
	push	hl
	call	_Terminate
	pop	af
	ret
___str_37:
	.ascii "The server returned a date that is before year 2010"
	.db 0x00
___str_38:
	.ascii "The server returned a date that is after year 2079"
	.db 0x00
	.area _CODE
___str_39:
	.ascii "SNTP time setter for the TCP/IP UNAPI 1.1"
	.db 0x0d
	.db 0x0a
	.ascii "By Konamiman, 201"
	.ascii "0 v1.1 by Oduvaldo"
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_40:
	.ascii "Usage: sntp <host>|. [<time zone>] [/d] [/v]"
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.ascii "<host>: Name"
	.ascii " or IP address of the SNTP time server."
	.db 0x0d
	.db 0x0a
	.ascii "        If "
	.db 0x22
	.ascii "."
	.db 0x22
	.ascii " is s"
	.ascii "pecified, the environment item TIMESERVER will be used."
	.db 0x0d
	.db 0x0a
	.ascii "<ti"
	.ascii "me zone>: Formatted as [+|-]hh:mm where hh=00-12, mm=00-59"
	.db 0x0d
	.db 0x0a
	.ascii "    This value will be added or substracted from the receive"
	.ascii "d time."
	.db 0x0d
	.db 0x0a
	.ascii "    The time zone can also be specified in the envi"
	.ascii "ronment item TIMEZONE."
	.db 0x0d
	.db 0x0a
	.ascii "/d: Do not change MSX clock, only di"
	.ascii "splay the received value"
	.db 0x0d
	.db 0x0a
	.ascii "/v: Verbose mode"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_41:
	.ascii "Invalid parameter(s)"
	.db 0x00
___str_42:
	.ascii "No network connection available"
	.db 0x00
___str_43:
	.ascii "Invalid time zone"
	.db 0x00
___str_44:
	.ascii "OK"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area _INITIALIZER
__xinit__strPresentation:
	.dw ___str_39
__xinit__strUsage:
	.dw ___str_40
__xinit__strInvalidParameter:
	.dw ___str_41
__xinit__strNoNetwork:
	.dw ___str_42
__xinit__strInvalidTimeZone:
	.dw ___str_43
__xinit__strOK:
	.dw ___str_44
	.area _CABS (ABS)
