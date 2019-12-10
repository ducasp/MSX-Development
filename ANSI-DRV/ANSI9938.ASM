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
VDP_01:	EQU	  $F3E0
VDP_06:	EQU	  $F3E5
VDP_05:	EQU	  $F3E4
VDP_11:	EQU	  $FFEA
VDP_14:	EQU	  $FFED


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
	OR	%00100010			; Set bit so color 0 is 0 in palette and disable sprites	
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
	LD	HL,ANSI_PAL			; Address of our palette
	LD	BC,$209A			; 32 bytes to move to port 0x9a which will auto-increment palette registers
	OTIR					; Send it
	CALL V9XX_InitCursor	; Initialize sprite cursor and return 
	JP	V99XX_ClearScreen	; clear screen
	
;OPJ - Sprite Cursor initialization		
V9XX_InitCursor:
	DI
	; First Set Pattern Table Address
	LD	A,%00111111			; sprite pattern table = #1F800-#1FFFF
	LD	(VDP_06),A			; Save our value
	OUT	($99),A				; Send value
	LD	A,$80+6	
	OUT	($99),A				; Write in register
	
	; Now Set Sprite Attribute Table Address
	LD	A,%11101111			; sprite attribute table = #1F600 / So Color Table will be #1F400 (14 - 10 and 3 1s)
	LD	(VDP_05),A			; Save our value
	OUT	($99),A				; Send value
	LD	A,$80+5	
	OUT	($99),A				; Write in register
	LD	A,%00000011			; A16 - 1 And A15 - 1
	LD	(VDP_11),A			; Save our value
	OUT	($99),A				; Send value
	LD	A,$80+11	
	OUT	($99),A				; Write in register
	
	;SET VDP TO WRITE @ Color Table starting at Sprite 0 (#1F400)
	LD	A,%00000111			; A16, A15 and A14 set to 1
	LD	(VDP_14),A			; Save our value	
	OUT	($99),A				; Send value	
	LD	A,$80+14
	OUT	($99),A				; Write in register
	LD	A,%00000000			; Now A7 to A0, all 0's
	OUT	($99),A				; Low Address
	LD	A,%01110100			; Write (bit 6), A13/A12 to 1(1F) / A11 to 0 and A10 to 1 and A9-A8 to 0 (4)
	OUT	($99),A				; High Address	
	
	;Colors for 2 sprites is 32 bytes long
	LD	HL,SPRITE_COLORS
	LD	BC,$2098
.COLRLOOP:	
	OUTI
	NOP
	NOP
	JR	NZ,.COLRLOOP		
	
	;SET VDP TO WRITE @ Pattern Table starting at Sprite 0 (#1F800)
	LD	A,%00000111			; A16/15/14 set to 1
	LD	(VDP_14),A			; Save our value
	OUT	($99),A				; Send value	
	LD	A,$80+14
	OUT	($99),A				; Write in register
	LD	A,%00000000			; Now A7 to A0, all 0's
	OUT	($99),A				; Low Address
	LD	A,%01111000			; Write (bit 6),  A12 1 
	OUT	($99),A				; High Address	
	
	;Patterns for 2 sprites is 16 bytes long
	LD	HL,PATTERN_CURSOR
	LD	BC,$1098
.PATRNLOOP:	
	OUTI
	NOP
	NOP
	JR	NZ,.PATRNLOOP
	
	;SET VDP TO WRITE @ Attribute Table starting at Sprite 0 (#1F600)
	LD	A,%00000111			; A16, A15 and A14 set to 1
	LD	(VDP_14),A			; Save our value
	OUT	($99),A				; Send value	
	LD	A,$80+14
	OUT	($99),A				; Write in register
	LD	A,%00000000			; Now A7 to A0, all 0's
	OUT	($99),A				; Low Address
	LD	A,%01110110			; Write (bit 6), A13/A12 to 1(1F) / A11 to 0 and A10/A9 to 1 and A8 to 0 (6)
	OUT	($99),A				; High Address	
	
	;Attributes for 2 sprites is 8 bytes long
	LD	HL,SPRITE_TABLE
	LD	BC,$0898
.ATTRLOOP:	
	OUTI
	NOP
	NOP
	JR	NZ,.ATTRLOOP
		
	; Done with setting
	;CALL	V9XX_MoveCursor	; Position our sprite....
	DI
	LD	A,(VDP_08)			; Get a copy of register 8
	AND %11111101			; Enable Sprites (cursor)
	LD	(VDP_08),A			; Save our value
	OUT	($99),A				; Send value to VDP
	LD	A,$80+8				
	OUT	($99),A				; Write to register 8
	EI
	RET

V9XX_CursorColor:
	;SET VDP TO WRITE @ Color Table starting at Sprite 0 Line 6 (#1F405)
	LD	A,%00000111			; A16, A15 and A14 set to 1
	DI
	LD	(VDP_14),A			; Save our value	
	OUT	($99),A				; Send value	
	LD	A,$80+14
	OUT	($99),A				; Write in register
	LD	A,%00000101			; Now A7 to A0
	OUT	($99),A				; Low Address
	LD	A,%01110100			; Write (bit 6), A13/A12 to 1(1F) / A11 to 0 and A10 to 1 and A9-A8 to 0 (4)
	OUT	($99),A				; High Address	

	LD	A,(HiLighted)
	OR	A
	LD	A,(ForeColor)
	JR	Z,.NHA
	ADD	$08
.NHA:	
	OR	$20					; Color attribute
	LD	B,2
CCLRLOOP:	
	;Update 1st line
	OUT	($98),A
	NOP
	NOP
	DJNZ	CCLRLOOP
	EI
	RET

V9XX_MoveCursorY:		
	;SET VDP TO WRITE @ $1F600 - Attribute Table
	LD	A,%00000111			; A16, A15 and A14 set to 1
	LD	(VDP_14),A			; Save our value
	DI
	OUT	($99),A				; Send value	
	LD	A,$80+14
	OUT	($99),A				; Write in register
	LD	A,%00000000			; Now A7 to A0, all 0's
	OUT	($99),A				; Low Address
	LD	A,%01110110			; Write (bit 6), A13/A12 to 1(1F) / A11 to 0 and A10/A9 to 1 and A8 to 0 (6)
	OUT	($99),A				; High Address		
	; Y Position
	LD	A,(HMMC_CMD.DYL)
	LD	B,A					; Copy IYL to B
	LD	A,(VDP_23)			; Get current vertical offset
	ADD	A,B					; Add our IYL to it
	OUT	($98),A				; Set Y
	EI
	RET

V9XX_MoveCursorX:		
	;SET VDP TO WRITE @ $1F601 - Attribute Table
	LD	A,%00000111			; A16, A15 and A14 set to 1
	LD	(VDP_14),A			; Save our value
	DI
	OUT	($99),A				; Send value	
	LD	A,$80+14
	OUT	($99),A				; Write in register
	LD	A,%00000001			; Now A7 to A0, all 0's
	OUT	($99),A				; Low Address
	LD	A,%01110110			; Write (bit 6), A13/A12 to 1(1F) / A11 to 0 and A10/A9 to 1 and A8 to 0 (6)
	OUT	($99),A				; High Address		
	; X Position	
	LD	A,(HMMC_CMD.DXL)
	ADD	A,8
	OUT	($98),A				; Set X
	EI
	RET	
;END OPJ Changes Sprite	
	

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
	;OPJ - Update Cursor Position
	JP	V9XX_MoveCursorX
	;RET



V99XX_SetCursorY:
	LD	A,(CursorRow)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	(HMMC_CMD.DYL),A
	;OPJ - Update Cursor Position
	JP	V9XX_MoveCursorY
	;RET



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
	;OPJ - Sprite Cursor added
	JP	V9XX_CursorColor
	;RET



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
	CALL	V99XX_WaitCmd	; Wait if any command is pending
	DI
	LD	A,$24				; Register 36 as value for...
	OUT	($99),A
	LD	A,$91				; Register #17 (indirect register access auto increment)
	OUT	($99),A
	LD	HL,HMMC_CMD			; The HMMC buffer
	LD	C,$9B				; And port for indirect access
	LD	A,(HL)				; LD DXL in A
	INC	HL
	INC	HL					; HL pointing to DYL
	ADD	$08					; Add 8 to DXL (A) - Border of 16 pixels
	ADD	A,A					; Multiply by 2
	OUT	(C),A				; And send DXL to #36
	LD	A,$00				; DXH could be 0
	JR	NC,.DXH				; If no carry, it is 0
	INC	A					; Otherwise it is 1
.DXH:	OUT	(C),A			; And send DXH to #37
	LD	A,(HL)				; Load IYL in A
	INC	HL					
	INC	HL					; HL pointing @ NXL
	LD	B,A					; Copy IYL to B
	LD	A,(VDP_23)			; Get current vertical offset
	ADD	A,B					; Add our IYL to it
	OUT	(C),A				; Send it to #38
	XOR	A					; IYH always 0
	OUT	(C),A				; Send it
	OUTI					; And now send the rest of buffer
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

SPRITE_TABLE:
	DB	$00,$00,$00,$00 ; Cursor is first, start at line 0, colum 0, uses pattern 0 reserved byte whatever
	DB	$D8,$00,$01,$00 ; Next line D8 to make invisible, use pattern 1 (all 0)
	
PATTERN_CURSOR:
	DB	$00,$00,$00,$00,$00,$E0,$E0,$00
	
PATTERN_INVISIBLE:
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	
SPRITE_COLORS:
	DB	$20,$20,$20,$20,$20,$27,$27,$20,$20,$20,$20,$20,$20,$20,$20,$20
	DB	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20