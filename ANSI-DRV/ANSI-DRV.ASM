; ANSI-DRV ANSI V9938/V9990 Driver v.1.0
;
; Original Code by Tobias Keizer
; Tobias has made this great piece of code and most of what is in it
; has been coded by him
;
; This version of Code by Oduvaldo Pavan Junior
; ducasp@gmail.com
; I want to make clear that I've made only the changes where you find a
; comment line starting with OPJ and commented the code based on my own
; research. Comments could be wrong (sorry, I'm no VDP Jedi Master) and
; if so that is entirely my fault. :-)
;
; Comercial usage of this code or derivative works of this code are
; allowed ONLY upon agreement with the author.
; Non-comercial usage is free as long as you publish your code changes
;

FNAME	"ANSI-DRV.BIN"

	ORG	$B000

; Calling INIT needs no parameters
INI_DR:	JP	INITRT
; Calling EXIT needs no parameters
STP_DR:	JP	EXITRT
; Calling PUT_CHAR, char is in register A
PRT_BC:	JP	BufferChar
; Calling PUT_STR, string is in register HL
PRT_PS:	JP	BufferText
; OPJ - Add possibility to get current cursor position
; Calling GET_CSR, Cursor row is H and Cursor column is L
PRT_GC:	JP	GetCursorInfo
; OPJ - Add possibility to receive current cursor position
; HL should hold the address of the callback funtion
; Call back function will receive cursor row in H and Column in L
; Whenever [6n is received
PRT_CB:	JP	SetCursorInfoCallBack	

; Calling INIT needs no parameters
INITRT:
	CALL	V99XX_InitScreen
	RET


; Calling EXIT needs no parameters
EXITRT:
	CALL	V99XX_RestScreen
	RET

; OPJ - Add possibility to current cursor position be sent to a callback function
SetCursorInfoCallBack:
	LD	(ANSI_CGP.CALL_VEC + 1),HL
	LD	A,1
	LD	(ANSI_CB),A
	RET


; OPJ - Add possibility to get current cursor position
GetCursorInfo:
	LD	A,(CursorCol)	; Get Current Cursor Column Position
	INC	A				; Increment it
	LD	L,A				; Place row in L
	LD	A,(CursorRow)	; Get Current Cursor Row (line) Position
	INC	A				; Increment it
	LD	H,A				; Place row in H
	RET

; Calling PUT_CHAR, char is in register A
BufferChar:
	OR	A
	RET	Z				; If 0, no need to print or ANSI parameter
	LD	C,A				; Save char in C
	LD	A,(ANSI_M)
	OR	A
	JR	NZ,.CNT			; Esc processing going on
	LD	A,C
	CP	27				; Is character ESC?
	JR	NZ,.PRT			; Nope, so print it
	; It is
.ESC:	LD	(ANSI_M),A	; Indicate ESC is in progress
	LD	HL,ANSI_S
	LD	(HL),A			; Save in first buffer position
	INC	HL				; Next buffer position
	LD	(ANSI_P),HL		; Save in the pointer 
	RET					; Done for now
.CNT:	LD	HL,(ANSI_P)	; Current buffer free position
	CP	27				; was ESC last byte?
	JR	Z,.CH2			; Yes, check position 2
	; No
	LD	A,C				; Restore character
	LD	(HL),A			; Store in buffer
	INC	HL
	LD	(ANSI_P),HL		; new buffer position
	CP	48
	JR	C,.END			; Character is less than '0', not a parameter I understand, so print on the screen
	; No, '0' or greater
	CP	60				
	JR	NC,.END			; If A > ';' not a parameter I understand, so print on the screen
	;Otherwise it is between 0 and ; so ESC command has not finished yet
	RET
.END:	XOR	A
	LD	(HL),A
	LD	(ANSI_M),A		; No longer processing
.RET:	LD	HL,ANSI_S
	JP	PrintText.RLP	; Ok, print the buffer we did not process
.CH2:	LD	A,C			; Restore char
	LD	(HL),A			; Store it
	INC	HL				; Increment pointer
	CP	"["				; Just deal with ESC[ commands, other commands not supported at this moment
	JR	NZ,.END			; So if the second character is not [, print the ESC sequence and life goes on
	LD	(ANSI_M),A		; Ok, now we are gathering parameters for the command
	LD	(ANSI_P),HL		; Save pointer
	RET					; Done
.PRT:	LD	(ANSI_S+0),A; Put the char in our buffer
	XOR	A				
	LD	(ANSI_S+1),A	; Now the terminator
	JR	.RET			; And print it :-)
	
ANSI_M:	DB	$00			; If ESC was the previous character will hold ESC, if processing ESC command, will hold [, otherwise 00
ANSI_P:	DW	ANSI_S		; Point the next free position in buffer
ANSI_S:	DS	$10			; Buffer to hold the ANSI command or data received to print
ANSI_CB:	DB	$00		; Wheter we have a callback for cursor position requests or not


; Calling PUT_STR, string is in register HL
; OPJ - 2019/08/21 - Changed to support C strings
BufferText:
	LD	A,(HL)			; Load the character
	INC	HL				; Increment pointer
	OR 	A				; 0?
	RET	Z				; Yes, end of string
	PUSH	HL			; Save pointer
	CALL	BufferChar	; Process or print it
	POP	HL				; Restore pointer
	JP	BufferText		; Continue



PrintText:
; OPJ - 2019/08/21 - Changed to support C strings
;	CALL	MakeASCIIZ
.RLP:	LD	A,(HL)		; Load the character
	INC	HL				; Increment the pointer
	CP	$20				
	JP	C,ControlCode	; If less than 0x20 (space), a control character
	PUSH	HL			; Save Pointer
	CALL	V99XX_PrintChar	; Call the print routine for our chip
	POP	HL				; Restore Pointer
	LD	A,(CursorCol)	; Get Current Cursor Position
	INC	A				; Increment it
	LD	(CursorCol),A	; Save
	PUSH	AF			; Save register
	CALL	V99XX_SetCursorX	; Set cursor on screen
	POP	AF				; Restore
	CP	80				
	JP	C,PrintText.RLP	; If up to position 80, done
	XOR	A				
	LD	(CursorCol),A	; Otherwise cursor is back to position 0
	JP	LineFeed		; And feed the lined



ControlCode:
	OR	A
	RET	Z				; If 0, done
	CP	8
	JP	Z,BackSpace		
	CP	10
	JP	Z,LineFeed
	CP	13
	JP	Z,CarriageReturn
	CP	27
	JP	Z,EscapeCode	; If an Escape code, let's check it	
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
	CP	"n"
	JP	Z,ANSI_CGP

	JP	.ERR

.PST:	DB	"0123456789ABCDEF0123456789ABCDEF"
.TRM:	DB	$00
.PCT:	DB	$00
.PPT:	DW	.PRM
.PRM:	DB	$00,$00,$00,$00,$00,$00,$00,$00

; OPJ - Add possibility to current cursor position be sent to a callback function
ANSI_CGP:				; ANSI Cursor Get Position
	LD	A,B
	CP	1				
	JR	NZ,.END			; Not only 1 parameter, not 6n, done
	LD	A,(Parameters.PRM+0)
	CP	6				; Is it 6?
	JR	NZ,.END			; Not 6, so it is not 6N
	; Ok, ESC[6n, do we have a callback to report cursor position?
	LD	A,(ANSI_CB)		; Is there a callback programmed?
	OR	A
	JR	Z,.END			; Nope, sorry, nothing to do
	; So, lets report the position
	LD	A,(CursorCol)	
	INC	A
	LD	L,A				; Column goes in L
	LD	A,(CursorRow)
	INC	A
	LD	H,A				; Row goes in H
.CALL_VEC:
	CALL	0			; This address will change when someone wants to receive callbacks
.END:	
	LD	HL,(EndAddress)
	JP	PrintText.RLP



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
;OPJ - Fix for 255 so cursor row won't overlap and have a low value when it should be > 24
	CP	26
	JR	C,.SAV
	LD	A,25
.SAV:
	LD	B,A
.SET:	LD	A,(CursorRow)
	ADD	A,B
; OPJ changes to allow 25 lines	
;	CP	24
	CP	25
	JR	C,.SCP
;	LD	A,23
	LD	A,24
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
;OPJ - Fix for 255 so cursor column won't overlap and have a low value when it should be > 24
	CP	81
	JR	C,.SAV
	LD	A,80
.SAV:
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
	;OPJ - Change to support 25 lines
	CP	24
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
	;OPJ - Change to support 25 lines
	CP	25
	JR	C,.NNL
	CALL	V99XX_LineFeed
	;OPJ - Change to support 25 lines
	LD	A,24
.NNL:	LD	(CursorRow),A
	CALL	V99XX_SetCursorX
	CALL	V99XX_SetCursorY
	JP	PrintText.RLP



CarriageReturn:
	XOR	A
	LD	(CursorCol),A
	CALL	V99XX_SetCursorX
	JP	PrintText.RLP


; OPJ - Changing to use C strings, zero terminated, not PASCAL strings
; So this is not needed
;MakeASCIIZ:
;	LD	A,(HL)
;	INC	HL
;	PUSH	HL
;	LD	E,A
;	LD	D,0
;	ADD	HL,DE
;	LD	(HL),0
;	POP	HL
;	RET





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
