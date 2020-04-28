FNAME	"ANSIVIEW.COM"

	ORG	$0100



BEGINN:
	LD	A,($0080)
	OR	A
	RET	Z
	DEC	A
	RET	Z
	LD	HL,$0082
	LD	DE,NEWFCB+1
	LD	B,A
	CP	9
	JR	C,.SFN
	LD	B,8
.SFN:	LD	A,(HL)
	OR	A
	JR	Z,.DON
	CP	"."
	JR	Z,.DON
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	.SFN
.DON:	LD	DE,TestText+1
	LD	C,$1A
	CALL	$0005
	LD	DE,NEWFCB
	LD	C,$0F
	CALL	$0005
	OR	A
	RET	NZ
	LD	HL,$0000
	LD	(NEWFCB.RND+0),HL
	LD	(NEWFCB.RND+2),HL
	INC	HL
	LD	(NEWFCB.RSZ+0),HL

	CALL	V99XX_InitScreen

	LD	A,83
	LD	(TestText),A
.RLP:	LD	HL,83
	LD	DE,NEWFCB
	LD	C,$27
	CALL	$0005
	JR	NZ,.END
	LD	HL,TestText
	CALL	BufferText
	JR	.RLP
.END:	LD	IX,$009F
	CALL	BIOS_C

	CALL	V99XX_RestScreen

	LD	IX,$0156	; Clear Keyboard Buffer
	JP	BIOS_C





BufferChar:
	OR	A
	RET	Z
	LD	C,A
	LD	A,(ANSI_M)
	OR	A
	JR	NZ,.CNT
	LD	A,C
	CP	27
	JR	NZ,.PRT
.ESC:	LD	(ANSI_M),A
	LD	HL,ANSI_S
	LD	(HL),A
	INC	HL
	LD	(ANSI_P),HL
	RET
.CNT:	LD	HL,(ANSI_P)
	CP	27
	JR	Z,.CH2
	LD	A,C
	LD	(HL),A
	INC	HL
	LD	(ANSI_P),HL
	CP	48
	JR	C,.END
	CP	60
	JR	NC,.END
	RET
.END:	XOR	A
	LD	(HL),A
	LD	(ANSI_M),A
.RET:	LD	HL,ANSI_S
	JP	PrintText.RLP
.CH2:	LD	A,C
	LD	(HL),A
	INC	HL
	CP	"["
	JR	NZ,.END
	LD	(ANSI_M),A
	LD	(ANSI_P),HL
	RET
.PRT:	LD	(ANSI_S+0),A
	XOR	A
	LD	(ANSI_S+1),A
	JR	.RET
	
ANSI_M:	DB	$00
ANSI_P:	DW	ANSI_S
ANSI_S:	DS	$10



BufferText:
	LD	B,(HL)
	INC	HL
.RLP:	PUSH	BC
	LD	A,(HL)
	INC	HL
	PUSH	HL
	CALL	BufferChar
	POP	HL
	POP	BC
	DJNZ	BufferText.RLP
	RET
.LEN:	DB	$00



PrintText:
	CALL	MakeASCIIZ
.RLP:	LD	A,(HL)
	INC	HL
	CP	$20
	JP	C,ControlCode
	PUSH	HL
	CALL	V99XX_PrintChar
	POP	HL
	LD	A,(CursorCol)
	INC	A
	LD	(CursorCol),A
	PUSH	AF
	CALL	V99XX_SetCursorX
	POP	AF
	CP	80
	JP	C,PrintText.RLP
	XOR	A
	LD	(CursorCol),A
	JP	LineFeed



ControlCode:
	OR	A
	RET	Z
	CP	8
	JP	Z,BackSpace
	CP	10
	JP	Z,LineFeed
	CP	13
	JP	Z,CarriageReturn
	CP	27
	JP	Z,EscapeCode
;	CP	7
;	JP	Z,BellCode
;	CP	9
;	JP	Z,HorizontalTab
	JP	PrintText.RLP



EscapeCode:
	LD	A,(HL)
	INC	HL
	CP	"["
	JP	Z,Parameters
	CP	"A"
	JP	Z,VT52_UP
	CP	"B"
	JP	Z,VT52_DW
	CP	"C"
	JP	Z,VT52_RI
	CP	"D"
	JP	Z,VT52_LE
	CP	"H"
	JP	Z,VT52_HOME
	JP	PrintText.RLP



Parameters:
	LD	(OrgAddress),HL
	LD	DE,.PRM
	LD	(.PPT),DE
	XOR	A
	LD	(.PCT),A
.RLP:	LD	DE,.PST	; PARAMETER STRING
	LD	C,0
.SCN:	LD	A,(HL)
	INC	HL
	CP	";"
	JR	Z,.END
	CP	"0"
	JR	C,.END
	CP	":"
	JR	NC,.END
	INC	C
	LD	(DE),A
	INC	DE
	JR	.SCN
.END:	LD	(.TRM),A	; SAVE TERMINATING CHAR
	LD	A,C
	OR	A
	JR	Z,.OMT	; OMITTED VALUE
	CP	1
	JR	Z,.RD1	; READ ONE DIGIT
	CP	2
	JR	Z,.RD2	; READ TWO DIGITS
	CP	3
	JR	Z,.RD3	; READ THREE DIGITS
.ERR:	XOR	A
	JP	PrintText.RLP
.OMT:	INC	A
	JR	.SET
.RD1:	LD	A,(.PST+0)
	SUB	48
	JR	.SET
.RD2:	LD	A,(.PST+0)
	SUB	48
	ADD	A,A
	LD	C,A
	ADD	A,A
	ADD	A,A
	ADD	A,C
	LD	C,A
	LD	A,(.PST+1)
	SUB	48
	ADD	A,C
	JR	.SET
.RD3:	LD	A,(.PST+0)
	SUB	48
	ADD	A,A
	LD	C,A
	ADD	A,A
	ADD	A,A
	ADD	A,C
	LD	C,A
	LD	A,(.PST+1)
	SUB	48
	ADD	A,C
	ADD	A,A
	LD	C,A
	ADD	A,A
	ADD	A,A
	ADD	A,C
	LD	C,A
	LD	A,(.PST+2)
	SUB	48
	ADD	A,C
.SET:	LD	DE,(.PPT)	; PARAMETER POINTER
	LD	(DE),A
	INC	DE
	LD	(.PPT),DE
	LD	A,(.PCT)	; PARAMETER COUNT
	INC	A
	LD	B,A
	LD	(.PCT),A
	LD	A,(.TRM)	; TERMINATING CHARACTER
	CP	";"
	JP	Z,.RLP
	CP	20
	JP	C,.ERR

	LD	(EndAddress),HL

	CP	"H"
	JP	Z,ANSI_CUP
	CP	"f"
	JP	Z,ANSI_CUP
	CP	"R"
	JP	Z,ANSI_CUP
	CP	"A"
	JP	Z,ANSI_CUU
	CP	"B"
	JP	Z,ANSI_CUD
	CP	"C"
	JP	Z,ANSI_CUF
	CP	"D"
	JP	Z,ANSI_CUB
	CP	"s"
	JP	Z,ANSI_SCP
	CP	"u"
	JP	Z,ANSI_RCP
	CP	"J"
	JP	Z,ANSI_ED
	CP	"K"
	JP	Z,ANSI_EL
	CP	"L"
	JP	Z,ANSI_IL
	CP	"M"
	JP	Z,ANSI_DL
	CP	"m"
	JP	Z,ANSI_SGR

	JP	.ERR

.PST:	DB	"0123456789ABCDEF0123456789ABCDEF"
.TRM:	DB	$00
.PCT:	DB	$00
.PPT:	DW	.PRM
.PRM:	DB	$00,$00,$00,$00,$00,$00,$00,$00





ANSI_CUP:				; ANSI Cursor Position
	LD	A,B
	OR	A
	JR	Z,.HOM
	DEC	A
	JR	Z,.ROW
	LD	A,(Parameters.PRM+1)
	DEC	A
	LD	(CursorCol),A
.ROW:	LD	A,(Parameters.PRM+0)
	DEC	A
	LD	(CursorRow),A
	JR	.RET
.HOM:	XOR	A
	LD	(CursorRow),A
	LD	(CursorCol),A
.RET:	CALL	V99XX_SetCursorX
	CALL	V99XX_SetCursorY
	LD	HL,(EndAddress)
	JP	PrintText.RLP



ANSI_CUU:				; ANSI Cursor Up
	LD	A,B
	LD	B,1
	OR	A
	JR	Z,.SET
.GTC:	LD	A,(Parameters.PRM+0)
	LD	B,A
.SET:	LD	A,(CursorRow)
	SUB	A,B
	JR	NC,.SCP
	XOR	A
.SCP:	LD	(CursorRow),A
	CALL	V99XX_SetCursorY
	LD	HL,(EndAddress)
	JP	PrintText.RLP



ANSI_CUD:				; ANSI Cursor Down
	LD	A,B
	LD	B,1
	OR	A
	JR	Z,.SET
.GTC:	LD	A,(Parameters.PRM+0)
	LD	B,A
.SET:	LD	A,(CursorRow)
	ADD	A,B
	CP	24
	JR	C,.SCP
	LD	A,23
.SCP:	LD	(CursorRow),A
	CALL	V99XX_SetCursorY
	LD	HL,(EndAddress)
	JP	PrintText.RLP



ANSI_CUF:				; ANSI Cursor Forward
	LD	A,B
	LD	B,1
	OR	A
	JR	Z,.SET
.GTC:	LD	A,(Parameters.PRM+0)
	LD	B,A
.SET:	LD	A,(CursorCol)
	ADD	A,B
	CP	80
	JR	C,.SCP
	LD	A,79
.SCP:	LD	(CursorCol),A
	CALL	V99XX_SetCursorX
	LD	HL,(EndAddress)
	JP	PrintText.RLP



ANSI_CUB:				; ANSI Cursor Back
	LD	A,B
	LD	B,1
	OR	A
	JR	Z,.SET
.GTC:	LD	A,(Parameters.PRM+0)
	LD	B,A
.SET:	LD	A,(CursorCol)
	SUB	A,B
	JR	NC,.SCP
	XOR	A
.SCP:	LD	(CursorCol),A
	CALL	V99XX_SetCursorX
	LD	HL,(EndAddress)
	JP	PrintText.RLP



ANSI_SCP:				; ANSI Save Cursor Position
	LD	A,(CursorCol)
	LD	(SavedCol),A
	LD	A,(CursorRow)
	LD	(SavedRow),A
	LD	HL,(EndAddress)
	JP	PrintText.RLP



ANSI_RCP:				; ANSI Restore Cursor Position
	LD	A,(SavedCol)
	LD	(CursorCol),A
	LD	A,(SavedRow)
	LD	(CursorRow),A
	CALL	V99XX_SetCursorX
	CALL	V99XX_SetCursorY
	LD	HL,(EndAddress)
	JP	PrintText.RLP



ANSI_ED:				; ANSI Erase in display
	LD	A,B
	OR	A
	JR	Z,.ED2
	LD	A,(Parameters.PRM+0)
	CP	0
	JR	Z,.ED0
	CP	1
	JR	Z,.ED1
	CP	2
	JR	Z,.ED2
.ED0:	LD	HL,(EndAddress)
	JP	PrintText.RLP
.ED1:	LD	HL,(EndAddress)
	JP	PrintText.RLP
.ED2:	CALL	V99XX_ClearScreen
	XOR	A
	LD	(CursorRow),A
	LD	(CursorCol),A
	CALL	V99XX_SetCursorX
	CALL	V99XX_SetCursorY
	LD	HL,(EndAddress)
	JP	PrintText.RLP



ANSI_EL:				; ANSI Erase in Line
	DEC	HL
	DEC	HL
	LD	A,(HL)
	CP	"["
	JP	Z,V99XX_ErLin0
	LD	A,(Parameters.PRM+0)
	CP	1
	JP	Z,V99XX_ErLin1
	CP	2
	JP	Z,V99XX_ErLin2
	JP	V99XX_ErLin0



ANSI_IL:
	LD	HL,(EndAddress)
	JP	PrintText.RLP

ANSI_DL:
	LD	HL,(EndAddress)
	JP	PrintText.RLP



ANSI_SGR:				; ANSI Set Graphics Rendition
	LD	A,B
	OR	A
	JR	Z,.RET
	LD	DE,Parameters.PRM
.RLP:	PUSH	BC
	LD	A,(DE)
	INC	DE
	OR	A
	JR	Z,.RES		; RESET ATTRIBUTES
	CP	1
	JR	Z,.BLD		; SET FONT TO BOLD
	CP	30
	JR	C,.UNK		; UNKNOWN / UNSUPPORTED
	CP	38
	JR	C,.SFC		; SET FOREGROUND COLOR
	CP	40
	JR	C,.UNK		; UNKNOWN / UNSUPPORTED
	CP	48
	JR	C,.SBC		; SET BACKGROUND COLOR
.UNK:	POP	BC
	DJNZ	.RLP
.RET:	LD	HL,(EndAddress)
	JP	PrintText.RLP
.RES:	XOR	A			; RESET ATTRIBUTES
	LD	(HiLighted),A
	LD	(BackColor),A
	LD	A,$07
	LD	(ForeColor),A
	JR	.CLR
.BLD:	LD	A,$01
	LD	(HiLighted),A
	JR	.CLR
.SFC:	SUB	30
	LD	(ForeColor),A
	JR	.CLR
.SBC:	SUB	40
	LD	(BackColor),A
	JR	.CLR
.CLR:	CALL	V99XX_SetColors
	JR	.UNK



ANSI_TCP:				; ANSI Transmit Cursor Position
	LD	A,(CursorRow)
	LD	B,0
.CR1:	CP	10
	JR	C,.CR2
	SUB	10
	INC	B
	JR	.CR1
.CR2:	ADD	48
	LD	(.STR+4),A
	LD	A,B
	ADD	48
	LD	(.STR+3),A
	LD	A,(CursorCol)
	LD	B,0
.CC1:	CP	10
	JR	C,.CC2
	SUB	10
	INC	B
	JR	.CC1
.CC2:	ADD	48
	LD	(.STR+7),A
	LD	A,B
	ADD	48
	LD	(.STR+6),A

.STR:	DB	$08,$1B,"[00;00R"



OrgAddress:
	DW	$00

EndAddress:
	DW	$00



VT52_UP:
	LD	A,(CursorRow)
	OR	A
	JP	Z,PrintText.RLP
	DEC	A
	LD	(CursorRow),A
	CALL	V99XX_SetCursorY
	JP	PrintText.RLP



VT52_DW:
	LD	A,(CursorRow)
	CP	23
	JP	NC,PrintText.RLP
	INC	A
	LD	(CursorRow),A
	CALL	V99XX_SetCursorY
	JP	PrintText.RLP



VT52_LE:
	LD	A,(CursorCol)
	OR	A
	JP	Z,PrintText.RLP
	DEC	A
	LD	(CursorCol),A
	CALL	V99XX_SetCursorX
	JP	PrintText.RLP



VT52_RI:
	LD	A,(CursorCol)
	CP	79
	JP	NC,PrintText.RLP
	INC	A
	LD	(CursorCol),A
	CALL	V99XX_SetCursorX
	JP	PrintText.RLP



VT52_HOME:
	XOR	A
	LD	(CursorCol),A
	LD	(CursorRow),A
	CALL	V99XX_SetCursorX
	CALL	V99XX_SetCursorY
	JP	PrintText.RLP



BellCode:
	PUSH	HL
	LD	IX,$00C0
	CALL	BIOS_C
	POP	HL
	JP	PrintText.RLP



BackSpace:
	LD	A,(CursorCol)
	OR	A
	JP	Z,PrintText.RLP
	DEC	A
	LD	(CursorCol),A
	CALL	V99XX_SetCursorX
	JP	PrintText.RLP



HorizontalTab:
	LD	A,(CursorCol)
	ADD	$08
	AND	%11111000
	LD	(CursorCol),A
	CP	80
	JP	C,.RET
	SUB	80
	LD	(CursorCol),A
	JP	LineFeed
.RET:	CALL	V99XX_SetCursorX
	CALL	V99XX_SetCursorY
	JP	PrintText.RLP



LineFeed:
	LD	A,(CursorRow)
	INC	A
	CP	24
	JR	C,.NNL
	CALL	V99XX_LineFeed
	LD	A,23
.NNL:	LD	(CursorRow),A
	CALL	V99XX_SetCursorX
	CALL	V99XX_SetCursorY
	JP	PrintText.RLP



CarriageReturn:
	XOR	A
	LD	(CursorCol),A
	CALL	V99XX_SetCursorX
	JP	PrintText.RLP



MakeASCIIZ:
	LD	A,(HL)
	INC	HL
	PUSH	HL
	LD	E,A
	LD	D,0
	ADD	HL,DE
	LD	(HL),0
	POP	HL
	RET





SavedCol:
	DB	$00

SavedRow:
	DB	$00



CursorCol:
	DB	$00

CursorRow:
	DB	$00

CursorVis:
	DB	$00



BackColor:
	DB	$00

ForeColor:
	DB	$07

FontColor:
	DB	$07

HiLighted:
	DB	$00



BIOS_C:				; BIOS_C: [IX]
	LD	IY,($FCC0)
	JP	$001C



include "ansi9938.asm"



FontData:
	INCBIN "TESTFONT.DAT"





NEWFCB:
	DB	$00
	DB	"        ANS"
	DB	$00,$00
.RSZ:	DB	$00,$00
.FSZ:	DB	$00,$00,$00,$00
	DB	$00,$00
	DB	$00,$00
	DB	$00
	DB	$00
	DB	$00,$00
	DB	$00,$00
	DB	$00,$00
	DB	$00
.RND:	DB	$00,$00,$00,$00



Message1:
	DB	"ANSIVIEW version 0.01 - the V9938 ANSI viewer, (c) 2006 t00b","$"
	DB	"$"
	DB	"Usage: ANSIVIEW filename","$"
	DB	"$"
	DB	"Please omit .ANS extension. Check readme file for more info.","$"
	DB	"$",$00

Message2:
	DB	"Please press space to start ansimation.","$"
	DB	"$",$00

TestText:
