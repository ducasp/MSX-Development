
V99XX_InitScreen:
	LD	A,%00000010
	OUT	($67),A
	PUSH	IX
	POP	IX
	LD	A,%00000000
	OUT	($67),A

	LD	A,06
	OUT	($64),A
	LD	HL,ModeCommand
	LD	BC,$0F63
	OTIR

	LD	A,44
	OUT	($64),A
	LD	A,%00000000
	OUT	($63),A
	LD	A,%00001100
	OUT	($63),A
	LD	A,%11111111
	OUT	($63),A
	OUT	($63),A
	
	LD	HL,ANSI_PAL
	LD	BC,$3061
	OTIR

	JP	V99XX_ClearScreen

;	LD	A,REG
;	OUT	($64),A
;	LD	A,DATA
;	OUT	($63),A



V99XX_RestScreen:
	DI
	LD	A,$00
	OUT	($99),A
	LD	A,$80+23
	OUT	($99),A
	EI
	LD	A,$00
	LD	IX,$005F
	JP	BIOS_C



V99XX_PrintChar:
	LD	DE,FontData
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	PUSH	HL
	CALL	DO_CMMC
	POP	HL
;	LD	BC,$0862
;	OTIR
	CALL	OUTBITS
	CALL	OUTBITS
	RET



OUTBITS:
	LD	A,(HL)
	INC	HL
	LD	B,A
	LD	A,(HL)
	INC	HL
	LD	C,A
	RLC	A
	RLC	A
	AND	%00000011
	OR	B
	OUT	($62),A
	LD	A,C
	ADD	A,A
	ADD	A,A
	AND	%11110000
	LD	B,A
	LD	A,(HL)
	INC	HL
	LD	C,A
	RRCA
	RRCA
	RRCA
	RRCA
	AND	%00001111
	OR	B
	OUT	($62),A
	LD	A,C
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	AND	%11000000
	LD	B,A
	LD	A,(HL)
	INC	HL
	RRCA
	RRCA
	AND	%00111111
	OR	B
	OUT	($62),A
	RET



V99XX_LineFeed:
	PUSH	HL
	LD	A,24
	CALL	V99XX_ClearLine
	LD	A,25
	CALL	V99XX_ClearLine
	LD	A,26
	CALL	V99XX_ClearLine
	LD	A,27
	CALL	V99XX_ClearLine
	LD	A,28
	CALL	V99XX_ClearLine
	POP	HL
	LD	A,17
	OUT	($64),A
	LD	A,(Screen_YO)
	ADD	$08
	LD	(Screen_YO),A
	OUT	($63),A
	RET



V99XX_SetCursorX:
	LD	A,(CursorCol)
	LD	B,A
	ADD	A,A
	ADD	A,B
	PUSH	HL
	LD	L,A
	LD	H,0
	ADD	HL,HL
	LD	(CMMC_CMD.DXL),HL
	POP	HL
	RET



V99XX_SetCursorY:
	LD	A,(CursorRow)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	(CMMC_CMD.DYL),A
	RET



V99XX_ClearLine:
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	(LMMV_CMD.DYL),A
	LD	A,$08
	LD	(LMMV_CMD.NYL),A
	XOR	A
	LD	(LMMV_CMD.NYH),A
	LD	(LMMV_CMD.DXL),A
	LD	(LMMV_CMD.DXH),A
	LD	A,$E0
	LD	(LMMV_CMD.NXL),A
	LD	A,$01
	LD	(LMMV_CMD.NXH),A
	LD	A,(ByteColors.BCC)
	LD	(LMMV_CMD.FCL),A
	LD	(LMMV_CMD.FCH),A
	JP	DO_LMMV



V99XX_ClearScreen:
	CALL	V99XX_WaitCmd
	LD	A,36
	OUT	($64),A
	XOR	A
	OUT	($63),A	; DXL
	OUT	($63),A	; DXH
	OUT	($63),A	; DYL
	OUT	($63),A	; DYH
	OUT	($63),A	; NXL
	LD	A,$02
	OUT	($63),A	; NXH
	XOR	A
	OUT	($63),A	; NYL
	INC	A
	OUT	($63),A	; NYH

	LD	A,48
	OUT	($64),A
	LD	A,(ByteColors.BCC)
	OUT	($63),A	; FCL
	OUT	($63),A	; FCH
	OUT	($63),A	; BCL
	OUT	($63),A	; BCH
	LD	A,$20
	OUT	($63),A	; CMD
	RET



V99XX_ErLin0:
	LD	A,(CursorCol)
	LD	B,A
	ADD	A,A
	ADD	A,B
	LD	L,A
	LD	H,0
	ADD	HL,HL
	LD	(LMMV_CMD.DXL),HL
	LD	A,80
	SUB	A,B
	LD	B,A
	ADD	A,A
	ADD	A,B
	LD	L,A
	LD	H,0
	ADD	HL,HL
.SNX:	LD	(LMMV_CMD.NXL),HL
	LD	A,(CursorRow)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	(LMMV_CMD.DYL),A
	LD	A,$08
	LD	(LMMV_CMD.NYL),A
	XOR	A
	LD	(LMMV_CMD.DYH),A
	LD	(LMMV_CMD.NYH),A
	CALL	DO_LMMV
	LD	HL,(EndAddress)
	JP	PrintText.RLP



V99XX_ErLin1:
	XOR	A
	LD	(LMMV_CMD.DXL),A
	LD	(LMMV_CMD.DXH),A
	LD	A,(CursorCol)
	LD	B,A
	ADD	A,A
	ADD	A,B
	LD	L,A
	LD	H,0
	ADD	HL,HL
	JP	V99XX_ErLin0.SNX



V99XX_ErLin2:
	LD	A,(CursorRow)	; Clear Entire Line
	CALL	V99XX_ClearLine
	XOR	A
	LD	(CursorCol),A
	CALL	V99XX_SetCursorX
	LD	HL,(EndAddress)
	JP	PrintText.RLP



V99XX_SetColors:
	LD	A,(HiLighted)
	OR	A
	LD	A,(ForeColor)
	JR	Z,.NHA
	ADD	$08
.NHA:	LD	B,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	OR	B
	LD	(ByteColors.FCC),A
	LD	A,(BackColor)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	B,A
	LD	A,(BackColor)
	OR	B
	LD	(ByteColors.BCC),A
	RET



V99XX_WaitCmd:
	IN	A,($65)
	BIT	0,A
	RET	Z
	JP	V99XX_WaitCmd



DO_CMMC:
	CALL	V99XX_WaitCmd

	LD	A,36
	OUT	($64),A

	LD	HL,(CMMC_CMD.DXL)
	LD	DE,$0010
	ADD	HL,DE
	LD	A,L
	OUT	($63),A	; DXL
	LD	A,H
	OUT	($63),A	; DXH
	
	LD	A,(CMMC_CMD.DYL)
	LD	B,A
	LD	A,(Screen_YO)
	ADD	A,B
	OUT	($63),A	; DYL
	XOR	A
	OUT	($63),A	; DYH
	
	LD	A,$06
	OUT	($63),A	; NXL
	XOR	A
	OUT	($63),A	; NXH

	LD	A,$08
	OUT	($63),A	; NYL
	XOR	A
	OUT	($63),A	; NYH

	LD	A,48
	OUT	($64),A

	LD	A,(ByteColors.FCC)
	OUT	($63),A
	OUT	($63),A

	LD	A,(ByteColors.BCC)
	OUT	($63),A
	OUT	($63),A

	LD	A,$50
	OUT	($63),A
	RET



DO_LMMV:
	CALL	V99XX_WaitCmd

	LD	HL,(LMMV_CMD.DXL)
	LD	DE,$0010
	ADD	HL,DE
	LD	(LMMV_CMD.DXL),HL

	LD	A,(LMMV_CMD.DYL)
	LD	B,A
	LD	A,(Screen_YO)
	ADD	A,B
	LD	(LMMV_CMD.DYL),A

	LD	A,(ByteColors.BCC)
	LD	(LMMV_CMD.FCL),A
	LD	(LMMV_CMD.FCH),A

	LD	A,36
	OUT	($64),A
	LD	HL,LMMV_CMD
	LD	BC,$0863
	OTIR
	LD	A,48
	OUT	($64),A
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	RET



Screen_YO:
	DB	$00



ByteColors:
.FCC:	DB	$00
.BCC:	DB	$00



ModeCommand:
.R06:	DB	%10010101
.R07:	DB	%00000000
.R08:	DB	%11000010
.R09:	DB	%00000000
.R10:	DB	%00000000
.R11:	DB	%00000000
.R12:	DB	%00000000
.R13:	DB	%00000000
.R14:	DB	%00000000
.R15:	DB	%00000000
.R16:	DB	%00000000
.R17:	DB	%00000000
.R18:	DB	%01000000
.R19:	DB	%00000000
.R20:	DB	%00000000



CMMC_CMD:
.DXL:	DB	$00
.DXH:	DB	$00
.DYL:	DB	$00
.DYH:	DB	$00
.NXL:	DB	$06
.NXH:	DB	$00
.NYL:	DB	$08
.NYH:	DB	$00

.FCL:	DB	$00
.FCH:	DB	$00
.BCL:	DB	$00
.BCH:	DB	$00
.CMD:	DB	$50



LMMV_CMD:
.DXL:	DB	$00
.DXH:	DB	$00
.DYL:	DB	$00
.DYH:	DB	$00
.NXL:	DB	$00
.NXH:	DB	$00
.NYL:	DB	$00
.NYH:	DB	$00

.FCL:	DB	$00
.FCH:	DB	$00
.BCL:	DB	$00
.BCH:	DB	$00
.CMD:	DB	$20



ANSI_PAL:
	DB	00,00,00, 21,00,00, 00,21,00, 21,11,00
	DB	00,00,21, 21,00,21, 00,21,21, 21,21,21
	DB	11,11,11, 31,11,11, 11,31,11, 31,31,11
	DB	11,11,31, 31,11,31, 11,31,31, 31,31,31
