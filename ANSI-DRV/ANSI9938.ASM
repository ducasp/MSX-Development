; ANSI-DRV ANSI V9938 Driver v.1.0
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

VDP_08: EQU   $FFE7
VDP_09: EQU   $FFE8
VDP_23: EQU   $FFF6



V99XX_InitScreen:
	LD	A,$07
	LD	IX,$005F
	CALL	BIOS_C			; Interslot call to set screen 7
	LD	A,$00
	LD	(VDP_23),A			; R#23, first line to draw is 0
	DI
	LD	A,$F0				; Text1 and Text2 color 15, Border and Background color 0
	OUT	($99),A
	LD	A,$80+7
	OUT	($99),A				; Write to register 7
	LD	A,(VDP_08)			; Get a copy of register 8
	;OPJ - Changed to use black from palette, not borders
	OR	%00100010			; Set bit to disable sprites as well color 0 is 0 in palette
	LD	(VDP_08),A			; Save our value
	OUT	($99),A				; Send value to VDP
	LD	A,$80+8				
	OUT	($99),A				; Write to register 8
	LD	A,(VDP_09)			; Get a copy of register 9
	;OPJ - Changed to use 212 lines to allow 25 lines :)
	OR	%10000000			; 212 Lines by seting 8th bit
;	AND	%01111111			; 192 Lines by clearing 8th bit
	LD	(VDP_09),A			; Save our new value
	OUT	($99),A				; Send value to VDP
	LD	A,$80+9
	OUT	($99),A				; Write to register 9
	LD	A,$00				; Palette register pointer set to 0
	OUT	($99),A				; Send value to VDP
	LD	A,$80+16			; 
	OUT	($99),A				; Write to register 16, new palette pointer
	EI
	LD	HL,ANSI_PAL			; Address of our palette
	LD	BC,$209A			; 32 bytes to move to port 0x9a which will auto-increment palette registers
	OTIR					; Send it
	JP	V99XX_ClearScreen	; And clear screen and return



V99XX_RestScreen:
	DI
	LD	A,$00
	OUT	($99),A
	LD	A,$80+23
	OUT	($99),A				; Register 23 goes to 0 to reset vertical offset
	LD	A,$00
	OUT	($99),A
	LD	A,$80+16			
	OUT	($99),A				; Palette register (16) pointer set to 0
	EI
	LD	HL,NORM_PAL			; Address of restore palette
	LD	BC,$209A			; 32 bytes to move to port 0x9a (send palette)
	OTIR					; Send it
	LD	A,$00
	LD	IX,$005F
	JP	BIOS_C				; Interslot call to set screen 0



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
	; OPJ - changed to 25 lines
	LD	A,25
	CALL	V99XX_ClearLine
	; OPJ - To avoid previous lines to show in the bottom when rolling multiple lines
	CALL	V99XX_ClearTop
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
	LD	(HMMV_CMD.DYL),A ; Number of lines * 8 = position of the last line
	LD	A,$08
	LD	(HMMV_CMD.NYL),A ; Will paint a rectangle with 8 pixels on the Y axys
	XOR	A
	LD	(HMMV_CMD.NYH),A
	LD	(HMMV_CMD.DXL),A ; 
	LD	A,$E0
	LD	(HMMV_CMD.NXL),A
	LD	A,$01
	LD	(HMMV_CMD.NXH),A ; The rectangle is 480 pixels on the X axis
	LD	A,(BackColor)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	B,A
	LD	A,(BackColor)
	OR	B				; Adjust color in the right format
	LD	(HMMV_CMD.CLR),A; Color to paint the rectangle
	JP	DO_HMMV

; OPJ - To avoid previous lines to show in the bottom when rolling multiple lines
V99XX_ClearTop:
	XOR	A
	LD	(HMMV_CMD.DYL),A ; position of the first line
	LD	A,$08
	LD	(HMMV_CMD.NYL),A ; Will paint a rectangle with 8 pixels on the Y axys
	XOR	A
	LD	(HMMV_CMD.NYH),A
	LD	(HMMV_CMD.DXL),A ; 
	LD	A,$E0
	LD	(HMMV_CMD.NXL),A
	LD	A,$01
	LD	(HMMV_CMD.NXH),A ; The rectangle is 480 pixels on the X axis
	LD	A,(BackColor)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	B,A
	LD	A,(BackColor)
	OR	B				; Adjust color in the right format
	LD	(HMMV_CMD.CLR),A; Color to paint the rectangle
	JP	DO_HMMV


V99XX_ClearScreen:
	CALL	V99XX_WaitCmd	; Make sure VDP is not processing any command
	DI
	;OPJ - Set border color same as back color
	LD	A,(BackColor)		; Text1 and Text2 color 15, Border and Background color 0
	OUT	($99),A
	LD	A,$80+7
	OUT	($99),A				; Write to register 7
	;OPJ - End
	LD	A,$24				;
	OUT	($99),A
	LD	A,$91
	OUT	($99),A				; Indirect access to registers, starting at #36
	EI
	LD	C,$9B				;Now indirect writes starting at register 36
	XOR	A
	OUT	(C),A	; DXL = 0
	NOP
	OUT	(C),A	; DXH = 0
	NOP
	OUT	(C),A	; DYL = 0
	NOP
	OUT	(C),A	; DYH = 0
	NOP
	OUT	(C),A	; NXL  = 0
	LD	A,$02
	OUT	(C),A	; NXH = 2 (512 dots)
	XOR	A
	OUT	(C),A	; NYL = 0
	INC	A
	OUT	(C),A	; NYH = 1 (256 dots)
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
