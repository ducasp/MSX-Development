VDP_08: EQU   $FFE7
VDP_09: EQU   $FFE8
VDP_23: EQU   $FFF6



V99XX_InitScreen:
	LD	A,$07
	LD	IX,$005F
	CALL	BIOS_C
	LD	A,$00
	LD	(VDP_23),A
	DI
	LD	A,$F0
	OUT	($99),A
	LD	A,$80+7
	OUT	($99),A
	LD	A,(VDP_08)
	OR	%00000010
	LD	(VDP_08),A
	OUT	($99),A
	LD	A,$80+8
	OUT	($99),A
	LD	A,(VDP_09)
	AND	%01111111
	LD	(VDP_09),A
	OUT	($99),A
	LD	A,$80+9
	OUT	($99),A
	LD	A,$00
	OUT	($99),A
	LD	A,$80+16
	OUT	($99),A
	EI
	LD	HL,ANSI_PAL
	LD	BC,$209A
	OTIR
	JP	V99XX_ClearScreen



V99XX_RestScreen:
	DI
	LD	A,$00
	OUT	($99),A
	LD	A,$80+23
	OUT	($99),A
	LD	A,$00
	OUT	($99),A
	LD	A,$80+16
	OUT	($99),A
	EI
	LD	HL,NORM_PAL
	LD	BC,$209A
	OTIR
	LD	A,$00
	LD	IX,$005F
	JP	BIOS_C



V99XX_PrintChar:
	CP	$20
	JR	Z,.SPC
	CP	$DB
	JR	Z,.FIL
	LD	DE,FontData
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	LD	DE,ColorTable
	LD	A,(HL)
	AND	%11000000
	RLC	A
	RLC	A
	ADD	A,ColorTable AND 255
	LD	E,A
	LD	A,(DE)
	LD	(HMMC_CMD.CLR),A
	PUSH	HL
	CALL	DO_HMMC
	POP	HL
	LD	BC,$089B
	JR	.BP1
.BP0:	LD	A,(HL)
	AND	%11000000
	RLC	A
	RLC	A
	ADD	A,ColorTable AND 255
	LD	E,A
	LD	A,(DE)
	OUT	(C),A
.BP1:	LD	A,(HL)
	AND	%00110000
	RRCA
	RRCA
	RRCA
	RRCA
	ADD	A,ColorTable AND 255
	LD	E,A
	LD	A,(DE)
	OUT	(C),A
.BP2:	LD	A,(HL)
	AND	%00001100
	RRCA
	RRCA
	ADD	A,ColorTable AND 255
	LD	E,A
	LD	A,(DE)
	OUT	(C),A
.RLP:	INC	HL
	DJNZ	.BP0
	RET
.SPC:	LD	A,(ColorTable+0)
	LD	(HMMC_CMD.CLR),A
	CALL	DO_HMMC
	LD	A,(ColorTable+0)
.OUT:	LD	BC,$179B
.SPL:	OUT	(C),A
	DJNZ	.SPL
	RET
.FIL:	LD	A,(ColorTable+3)
	LD	(HMMC_CMD.CLR),A
	CALL	DO_HMMC
	LD	A,(ColorTable+3)
	JR	.OUT



V99XX_LineFeed:
	PUSH	HL
	LD	A,24
	CALL	V99XX_ClearLine
	POP	HL
	LD	A,(VDP_23)
	ADD	$08
	LD	(VDP_23),A
	DI
	OUT	($99),A
	LD	A,$80+23
	OUT	($99),A
	EI
	RET



V99XX_SetCursorX:
	LD	A,(CursorCol)
	LD	B,A
	ADD	A,A
	ADD	A,B
	LD	(HMMC_CMD.DXL),A
	RET



V99XX_SetCursorY:
	LD	A,(CursorRow)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	(HMMC_CMD.DYL),A
	RET



V99XX_ClearLine:
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	(HMMV_CMD.DYL),A
	LD	A,$08
	LD	(HMMV_CMD.NYL),A
	XOR	A
	LD	(HMMV_CMD.NYH),A
	LD	(HMMV_CMD.DXL),A
	LD	A,$E0
	LD	(HMMV_CMD.NXL),A
	LD	A,$01
	LD	(HMMV_CMD.NXH),A
	LD	A,(BackColor)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	B,A
	LD	A,(BackColor)
	OR	B
	LD	(HMMV_CMD.CLR),A
	JP	DO_HMMV



V99XX_ClearScreen:
	CALL	V99XX_WaitCmd
	DI
	LD	A,$24
	OUT	($99),A
	LD	A,$91
	OUT	($99),A
	EI
	LD	C,$9B
	XOR	A
	OUT	(C),A	; DXL
	NOP
	OUT	(C),A	; DXH
	NOP
	OUT	(C),A	; DYL
	NOP
	OUT	(C),A	; DYH
	NOP
	OUT	(C),A	; NXL
	LD	A,$02
	OUT	(C),A	; NXH
	XOR	A
	OUT	(C),A	; NYL
	INC	A
	OUT	(C),A	; NYH
	LD	A,(BackColor)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	B,A
	LD	A,(BackColor)
	OR	B
	OUT	(C),A	; CLR
	LD	A,$00
	OUT	(C),A	; ARG
	LD	A,$C0
	OUT	(C),A	; CMD
	RET



V99XX_ErLin0:
	LD	A,(CursorCol)
	LD	B,A
	ADD	A,A
	ADD	A,B
	LD	(HMMV_CMD.DXL),A
	LD	B,A
	LD	A,240
	SUB	A,B
	ADD	A,A
	LD	(HMMV_CMD.NXL),A
	LD	A,$00
	JR	NC,.NXH
	INC	A
.NXH:	LD	(HMMV_CMD.NXH),A
	LD	A,(CursorRow)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	(HMMV_CMD.DYL),A
	LD	A,$08
	LD	(HMMV_CMD.NYL),A
	XOR	A
	LD	(HMMV_CMD.DYH),A
	LD	(HMMV_CMD.NYH),A
	CALL	DO_HMMV
	LD	HL,(EndAddress)
	JP	PrintText.RLP



V99XX_ErLin1:
	XOR	A
	LD	(HMMV_CMD.DXL),A
	LD	(HMMV_CMD.DXH),A
	LD	A,(CursorCol)
	LD	B,A
	ADD	A,A
	ADD	A,B
	LD	C,0
	ADD	A,A
	JR	NC,.CNT
	INC	C
.CNT:	LD	(HMMV_CMD.NXL),A
	LD	A,C
	JP	V99XX_ErLin0.NXH



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
	LD	(FontColor),A
	LD	A,(BackColor)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	B,A
	LD	A,(BackColor)
	OR	B
	LD	(ColorTable+00),A
	LD	A,(FontColor)
	AND	$0F
	OR	B
	LD	(ColorTable+01),A
	LD	A,(FontColor)
	AND	$F0
	LD	B,A
	LD	A,(BackColor)
	OR	B
	LD	(ColorTable+02),A
	LD	A,(FontColor)
	LD	(ColorTable+03),A
	RET



V99XX_WaitCmd:
	LD	A,$02
	DI
	OUT	($99),A
	LD	A,$80+15
	OUT	($99),A
	IN	A,($99)
	RRA
	LD	A,$00
	OUT	($99),A
	LD	A,$80+15
	EI
	OUT	($99),A
	RET	NC
	JP	V99XX_WaitCmd



DO_HMMC:
	CALL	V99XX_WaitCmd
	DI
	LD	A,$24
	OUT	($99),A
	LD	A,$91
	OUT	($99),A
	LD	HL,HMMC_CMD
	LD	C,$9B
	LD	A,(HL)
	INC	HL
	INC	HL
	ADD	$08
	ADD	A,A
	OUT	(C),A
	LD	A,$00
	JR	NC,.DXH
	INC	A
.DXH:	OUT	(C),A
	LD	A,(HL)
	INC	HL
	INC	HL
	LD	B,A
	LD	A,(VDP_23)
	ADD	A,B
	OUT	(C),A
	XOR	A
	OUT	(C),A
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	LD	A,$AC
	OUT	($99),A
	LD	A,$91
	OUT	($99),A
	EI
	RET



DO_HMMV:
	CALL	V99XX_WaitCmd
	DI
	LD	A,$24
	OUT	($99),A
	LD	A,$91
	OUT	($99),A
	LD	HL,HMMV_CMD
	LD	C,$9B
	LD	A,(HL)
	INC	HL
	INC	HL
	ADD	$08
	ADD	A,A
	OUT	(C),A
	LD	A,$00
	JR	NC,.DXH
	INC	A
.DXH:	OUT	(C),A
	LD	A,(HL)
	INC	HL
	INC	HL
	LD	B,A
	LD	A,(VDP_23)
	ADD	A,B
	OUT	(C),A
	XOR	A
	OUT	(C),A
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	EI
	RET



ColorTable:
	DB	$00
	DB	$0F
	DB	$F0
	DB	$FF



HMMC_CMD:
.DXL:	DB	$00
.DXH:	DB	$00
.DYL:	DB	$00
.DYH:	DB	$00
.NXL:	DB	$06
.NXH:	DB	$00
.NYL:	DB	$08
.NYH:	DB	$00
.CLR:	DB	$00
.ARG:	DB	$00
.CMD:	DB	$F0



HMMV_CMD:
.DXL:	DB	$00
.DXH:	DB	$00
.DYL:	DB	$00
.DYH:	DB	$00
.NXL:	DB	$00
.NXH:	DB	$00
.NYL:	DB	$00
.NYH:	DB	$00
.CLR:	DB	$00
.ARG:	DB	$00
.CMD:	DB	$C0



NORM_PAL:
	DB	$00,$00,$50,$00,$00,$05,$50,$02,$05,$00,$55,$00,$05,$05,$55,$05
	DB	$22,$02,$72,$02,$22,$07,$72,$07,$27,$02,$77,$02,$27,$07,$77,$07

ANSI_PAL:
	DB	$00,$00,$50,$00,$00,$05,$50,$02,$05,$00,$55,$00,$05,$05,$55,$05
	DB	$22,$02,$72,$02,$22,$07,$72,$07,$27,$02,$77,$02,$27,$07,$77,$07
