; ESP8266 TCP/IP UNAPI BIOS v.1.2
; MSX-SM / SM-X UART version
; Oduvaldo Pavan Junior
; ducasp@gmail.com
;    This code implements TCP/IP UNAPI Specification for MSX-SM
;
; Pieces of this code were based on DENYOTCP.ASM (Denyonet ROM)
; made by Konamiman
;
; Note: this implementation depends upon ESP8266 having the UNAPI
; firmware flashed. This firmware has been developed by me as well.
;
; Comercial usage of this code or derivative works of this code are
; allowed ONLY upon agreement with the author.
; Non-comercial usage is free as long as you publish your code changes
;
; Design details:
; There are three instances of this ROM
;
; 1 - ESC is pressed during boot, it will skip and won't load
; 2 - F1 is pressed during boot, it will show a setup menu, ESC resume boot
; 3 - No key is pressed during boot or setup is done, EXTBIO HOOK for UNAPI
;     calls and HTIM_I hook for internal usage
;
; As a ROM, our segment is read only, so for RAM needs we need to use RAM not
; in our page. This ROM will do the following:
;
; If running the SETUP menu, we are going to "borrow" BASIC program area, that
; is saved at TXTTAB. We can't allocate memory at this point as any possible
; disk rom might be sitting on a slot that has not been initialized and results
; could be bad. The BASIC program area trick should be safe, unless some other
; cartridge runs a BASIC software for something (i.e.: wait disks be initialized
; ), in such case, that BASIC software or trick will most likely be corrupted
; after running our setup.
;
; After boot, we need RAM in the 4th page. We have the SLOT WORK AREA for
; free, it is 8 bytes reserved for our slot, and that is certainly not enough,
; just the EXTBIOS HOOK backup cost us 5 bytes, so we have three bytes 
; remaining. Of those, we use two to indicate the bottom of the memory reserved
; in the 4th page. Whenever more memory is needed, HIMEM_RESERVED_SIZE must 
; change, just remember that more memory reserved means less memory available
; to applications and BASIC, so use it wisely
;
; Slot Work Area Details
; 0000 - 0004	: EXTBIO hook backup
; 0005 - 0006	: HIMEM Allocated area (starts with 00 xx, once allocated goes
;				  to Fxxx or Exxx so checking 0006 if 00 is enough)
;
; Current HIMEM mapping offset related to the address stored in the 6th and 7th
; bytes of our slot work area:
; 
; 0000 - 0004 	: HTIM_I hook backup
; 0005 - 0006	: Counter that our HTIM_I hook updates
; 0007			: Store Single Byte some functions need
; 0008			: Stores whether DNS is ready or not
; 0009 - 000A	: Stores last DNS result
; 000B - 000C	: Stores a 16 bits value
; 000D - 0012	: Store a backup of BC / DE / HL
;	000D - 000E	: C and B
;	000F - 0010	: D and E
;	0011 - 0012	: H and L
;
; As this is sitting on a slot, there is a resoanable chance that this is initialized
; before any disk controllers. If that is the case, allocating memory at HIMEM is bad
; and might have two bad behaviors:
;
; 1 - Disk Controller is smart enough to determine HIMEM was moved and simply do not
; initialize. No disk available...
; 2 - Disk Controller doesn't care and simply wipe-out memory below original HIMEM at
; boot to create the disk interfaces static work area, thus, causing our allocated
; memory to be overwritten...
;
; So, allocating memory at cartridge startup will make MSX freeze or misbehave or not
; have the disk available if our ROM is sitting in a slot lower than the disk. There
; are a few possibilities:
;
; 1 - Hook to H_STKE, it is called once all slots have been initialized... But, using
; this hook will make ESE SCSI to not work and halt with a "No enough memory" message,
; so I do not consider it a good option as the intention is to re-use code for other
; adapters
; 2 - On any UNAPI call check the slot work area if the allocated area is other than 00
; and if it is, execute, otherwise, first execute our allocation routine. This has an
; overhead of a dozen instructions at every UNAPI function we execute, does not seem to
; impact performance compared to the UNAPI RAM driver that doesn't has it
; 3 - Try to go crazy and check for dos roms on slots above us, initialize those first
; if found... Too much trouble for a dozen instructions
;
; So, for the moment the design decision is option #2
;
; Setup Menu Design
;


;*******************
;***  CONSTANTS  ***
;*******************

;--- SM-X ROM is less verbose
SMX_ROM:				equ	1

;--- System variables and routines
KILBUF:					equ	#0156
BEEP:					equ	#00C0
SNSMAT:					equ	#0141
CHPUT:					equ	#00A2
CHGET:					equ	#009F
TXTTAB:					equ	#F676
HOKVLD:					equ	#FB20
EXPTBL:					equ	#FCC1
SLTWRK:					equ	#FD09
HIMEM:					equ	#FC4A
EXTBIO:					equ	#FFCA
ARG:					equ	#F847
H_TIMI:					equ	#FD9F
H_CLEA:					equ	#FED0
OUT_TX_PORT:			equ	#07
OUT_CMD_PORT:			equ	#06
IN_DATA_PORT:			equ	#06
IN_STS_PORT:			equ	#07

;--- API version and implementation version
API_V_P:				equ	1
API_V_S:				equ	2
ROM_V_P:				equ	1
ROM_V_S:				equ	2

;--- Size of memory to reserv in upper memory AREA
HIMEM_RESERVED_SIZE		equ	30
MEMORY_COUNTER_OFFSET	equ	5
MEMORY_SB_VAR_OFFSET	equ	7
MEMORY_DNS_READY_OFFSET	equ	8
MEMORY_DNS_RES_OFFSET	equ	9
MEMORY_DB_VAR_OFFSET	equ	#0B
MEMORY_REGBACKUP_OFFSET	equ	#0D
MEMORY_BCBACKUP_OFFSET	equ	#0D
MEMORY_DEBACKUP_OFFSET	equ	#0F
MEMORY_HLBACKUP_OFFSET	equ	#11

;--- Maximum number of available standard and implementation-specific function numbers
;Must be 0 to 127
MAX_FN:					equ	29

;Must be either zero (if no implementation-specific functions available), or 128 to 254
MAX_IMPFN:				equ	0

;--- TCP/IP UNAPI error codes

ERR_OK:					equ	0
ERR_NOT_IMP:			equ	1
ERR_NO_NETWORK:			equ	2
ERR_NO_DATA:			equ	3
ERR_INV_PARAM:			equ	4
ERR_QUERY_EXISTS:		equ	5
ERR_INV_IP:				equ	6
ERR_NO_DNS:				equ	7
ERR_DNS:				equ	8
ERR_NO_FREE_CONN:		equ	9
ERR_CONN_EXISTS:		equ	10
ERR_NO_CONN:			equ	11
ERR_CONN_STATE:			equ	12
ERR_BUFFER:				equ	13
ERR_LARGE_DGRAM:		equ	14
ERR_INV_OPER:			equ	15

;--- TCP/IP UNAPI connection Status
UNAPI_TCPIP_NS_CLOSED	equ	0
UNAPI_TCPIP_NS_OPENING	equ	1
UNAPI_TCPIP_NS_OPEN		equ	2
UNAPI_TCPIP_NS_UNKNOWN	equ	255

;************************
;***  MSX ROM HEADER  ***
;************************
	org	#4000
	db					#41,#42
	dw					INIT		; Initialize ESP, if not found, won't install hook
	dw					0			; Statement
	dw					0			; Device
	dw					0			; Text
	ds					6			; Reserved

;==================
;===  Start-up  ===
;==================

INIT:
	ld	a,h							; Let's test if we are mirrored and being executed in wrong page
	cp	#40							; is MSB 0x40?
	ret	nz							; if not, return, it is a mirror
	ld	a,6
	call	SNSMAT
	bit	5,a							; Test F1
	jp	z,ESPSETUP					; If F1 is pressed, let's execute our setup menu
	if	SMX_ROM = 0
	ld	hl,WELCOME_S
	call	PRINTHL
	endif
INIT_NEXT:
	call	RESET_ESP
	or	a
	jp	z,INIT_UNAPI				; Well, if reset succesful, initialize UNAPI
	; If here, ESP was not found, so, exit with and error message
	ld	a,b
	or	a
	ld	hl,FAIL_S					; If 0, non responsive
	jr	z,INIT_F_ERRMSG
	ld	hl,FAIL_F					; Otherwise, firmware is old
INIT_F_ERRMSG:
	call	PRINTHL
INIT_F_WAIT:
	ld	b,255
INIT_F_LOOP_WAIT:
	halt
	djnz	INIT_F_LOOP_WAIT
	ret								; And done
INIT_UNAPI:
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_QUERY_ACLK_SETTINGS
	out	(OUT_TX_PORT),a
	ld	hl,60						; Wait Up To 1s
	ld	de,(TXTTAB)					; we will borrow Basic Program memory area for now...
	ld	ixl,e
	ld	ixh,d						; address in IX
	call	WAIT_MENU_CMD_RESPONSE
	jr	z,INIT_NOCLOCKUPDATE		; if error, just skip
	; Response received, IX+0 and IX+1 has Auto Clock and GMT
	ld	a,3
	cp	(ix+0)
	ret	z							; if disabled, disabled it is, nothing to do
	ld	a,(#002D)					; Check MSX Version
	or	a
	jr	z,INIT_NOCLOCKUPDATE		; If zero, MSX 1, can't set clock
	xor	a
	or	(ix+0)
	jr	z,INIT_NOCLOCKUPDATE		; if turned off, skip
	; Ok, not zero, so we are going to simply request the time, it might take up to 10s
	inc	ix
	inc	ix							; ok, leave IX+0 and IX+1  intact
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_GET_TIME
	out	(OUT_TX_PORT),a
	ld	hl,900						; Wait Up To 15s
	call	WAIT_MENU_CMD_RESPONSE
	jr	nz,INIT_CLOCKUPDATE			; if ok, follow up
	; Leave a message that clock has not been updated
	ld	hl,STR_CLKUPDT_FAIL
	call	PRINTHL
	ld	a,240						; Wait 4 seconds with message on screen
WAIT_4S:
	halt
	dec	a
	; If not zero, our time out has not elapsed
	jr	nz,WAIT_4S
	jr	INIT_NOCLOCKUPDATE			; error, just skip to not set garbage in clock
INIT_CLOCKUPDATE:
	dec	ix
	dec	ix							; ix back where it should
	; ix + 0 -> 0 If no need to set clock, 1 if set clock, 2 if set clock and request to turn WiFi Off
	; ix + 1 -> GMT setting, well, not going to use it
	; ix + 2 -> Seconds
	; ix + 3 -> Minutes
	; ix + 4 -> Hours
	; ix + 5 -> Day
	; ix + 6 -> Month
	; ix + 7 -> Year LSB
	; ix + 8 -> Year MSB
	ld	h,(ix+4)
	ld	l,(ix+3)
	ld	d,(ix+2)
	call	SET_TIME
	jr	nz,INIT_NOCLOCKUPDATE		; if error, just skip
	ld	h,(ix+8)
	ld	l,(ix+7)
	ld	d,(ix+6)
	ld	e,(ix+5)
	call	SET_DATE
	ld	a,2
	cp	(ix+0)
	jr	nz,INIT_NOCLOCKUPDATE
	; If here, turn off Wifi Immediatelly
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_WIFI_OFF
	out	(OUT_TX_PORT),a				; Just send, no need to wait response
INIT_NOCLOCKUPDATE:
;--- Save existing EXTBIO hook if it exists
	ld	a,(HOKVLD)
	bit	0,a
	jr	nz,SAVE_HOOK2				; HOKVLD tells us if there is an extended BIOS already or not, if yes, save it
	; If here, no extended BIOS
	call	GETSLT
	call	GETWRK					; Our ROM work area address is at HL (we can use up to 8 bytes)
	ld	a,#C9						; RET, as we are the first extended BIOS
	ld	(hl),a
	jr	PATCH						; And now all we need to do is patch the EXTBIO hook :)
	
SAVE_HOOK2:
	; If here, we are not the first to extend bios, so we need to save the previous one
	call	GETSLT
	call	GETWRK					; Our ROM work area address is at HL (we can use up to 8 bytes)
	ex	de,hl						; It is the destination for....
	ld	hl,EXTBIO					; The actual EXTBIO hook
	ld	bc,5						; That is 5 bytes large
	ldir							; And move to our work area
	xor	a
	ld	(de),a						; not initialized (de is at the sixth byte) of our slot work area
	inc	de
	ld	(de),a						; not initialized (de is at the seventh byte) of our slot work area

;--- Patch EXTBIO

PATCH:
	ld	a,#F7						; RST #30
	ld	(EXTBIO),a					; In EXTBIO hook
	call	GETSLT					; Our Slot in A
	ld	(EXTBIO+1),a				; Next EXTBIO hook byte
	ld	hl,DO_EXTBIO				; Our EXTBIO routine address
	ld	(EXTBIO+2),hl				; Goes to the followingtwo bytes in the hook

	ld	hl,EXTBIO+5					; Must patch DISINT and ENAINT as well
	ld	b,5*2
PATCH2:
	ld	(hl),#C9
	inc	hl
	djnz	PATCH2					; So patch all 10 bytes with return

	ld	hl,HOKVLD
	set	0,(hl)						; And set HOKVLD properly to indicate an EXTBIOS is installed
INIT_OK:
	if	SMX_ROM = 0
	ld	hl,OK_S						; All done and set, nice exit message
	call	PRINTHL
	endif
	ret

HIMEM_ALLOC:
	; Now let's reserve memory in the 4th page for our usage
	ld hl,(HIMEM)					; Get HIMEM
	or	a							; Clear Carry
	ld	de,HIMEM_RESERVED_SIZE		; Reserve How much memory we need
	sbc	hl,de						; New HIMEM
	ld	(HIMEM),hl					; Save it
	inc	hl							; To be safe
	ex	de,hl						; now in DE
	call	GETSLT
	call	GETMEMPOINTERADDR		; This is where we are going to store our memory area address
	; GETSLT and GETMEMPOINTER do not change DE, so it still has the our memory area address
	ld	(hl),e
	inc	hl
	ld	(hl),d						; And save our memory area there
	; Ok, DE has our memory area, let's save old H_TIMI hook there
	ld	hl,H_TIMI					; The actual H_TIMI hook
	ld	bc,5						; That is 5 bytes large
	ldir							; And move to our memory area
	di								; Turn of interrupts as we are going to patch H_TIMI
PATCH_H_TIMI:
	ld	a,#F7						; RST #30
	ld	(H_TIMI),a					; In H_TIMI hook
	call	GETSLT					; Our Slot in A
	ld	(H_TIMI+1),a				; Next H_TIMI hook byte
	ld	hl,DO_HTIMI					; Our H_TIMI routine address
	ld	(H_TIMI+2),hl				; Goes to the following two bytes in the hook
	ei								; done, so re-enable interrupts

	; Set DNS_READY to zero
	xor	a
	call	SETDNSREADY
	ld	hl,0
	call	SETCOUNTER
	ret

ESPSETUP.EXIT:
	ld	a,CLS
	call	CHPUT
	jp	INIT_NEXT					; When done, resume initialization
; Pretty simple setup for the device
ESPSETUP:
	in	a,(IN_STS_PORT)
	bit	3,a							; Quick Receive Supported?
	jr	z,ESPSETUP.1NF				; If not, no fast receive
	ld	hl,WELCOME_SF
	jp	ESPSETUP.1F					; Report quick receive supported
ESPSETUP.1NF:
	ld	hl,WELCOME_S
ESPSETUP.1F:
	call	PRINTHL					; Print Welcome message
	ld	hl,MMENU_S
	call	PRINTHL					; Print Main Menu
	call	KILBUF					; Clear Keyboard Buffer
MM_WAIT_INPUT:
	call	CHGET
	cp	#1b							; ESC?
	jp	z,ESPSETUP.EXIT				; When done, resume initialization
	cp	'1'							; Setup Nagle?
	jp	z,SET_NAGLE					;
	cp	'2'							; Setup WiFiOn period?
	jp	z,SET_WIFI_TIMEOUT			;
	cp	'3'							; Scan networks?
	jp	z,START_WIFI_SCAN			;
	cp	'4'							; Automatic Setting of Clock?
	jp	z,START_CLK_AUTO			;
	call	BEEP					; Wrong Input, beep
	jp	MM_WAIT_INPUT				; And return waiting key

CLK_MSX1_GO:
	ld	hl,MMENU_CLOCK_MSX1
	call	PRINTHL
	call	ISCLKAUTO
	ld	a,(ix+0)					; Auto Clock Current setting
	cp	3							; If 3 adapter disabled
	jr	nz,CLK_MSX1_ADAPTERDIS
	ld	hl,MMENU_CLOCK_0_MSX1
	call	PRINTHL
	jr	CLK_MSX1_WAIT_OPT_INPUT
CLK_MSX1_ADAPTERDIS:
	ld	hl,MMENU_CLOCK_3_MSX1
	call	PRINTHL
CLK_MSX1_WAIT_OPT_INPUT:
	call	CHGET
	cp	#1b							; ESC?
	jp	z,ESPSETUP					; Back to main menu
	cp	'0'							;
	jp	z,CLK_MSX1_SEND_CMD			;
	cp	'3'							;
	jp	z,CLK_AUTO_WAIT_GMT			;
	call	BEEP					; Wrong Input, beep
	jp	CLK_MSX1_WAIT_OPT_INPUT		; Back to main menu
CLK_MSX1_SEND_CMD:
	call	CHPUT					; Print option
	sub	'0'							; correct format
	ld	(ix+0),a					; Save it
	ld	a,#D
	call CHPUT
	ld	a,#A
	call CHPUT
	jp	CLK_AUTO_GMT_CHK_DONE		; and sending the command will be done there

START_CLK_AUTO:
	ld	a,(#002D)					; Check MSX Version
	or	a
	jp	z,CLK_MSX1_GO				; If zero, MSX 1, so can just enable or disable adapter
CLK_AUTO_GO:
	ld	hl,MMENU_CLOCK_MSX2
	call	PRINTHL
	call	ISCLKAUTO
	ld	a,(ix+0)					; Auto Clock Current setting
	or	a							; If zero, off
	jr	nz,CLK_AUTO_CHK1
	ld	hl,MMENU_CLOCK_0
	call	PRINTHL
	jr	CLK_AUTO_GMT
CLK_AUTO_CHK1:
	dec	a							; if 1, on and keep wifi on
	jr	nz,CLK_AUTO_CHK2
	ld	hl,MMENU_CLOCK_1
	call	PRINTHL
	jr	CLK_AUTO_GMT
CLK_AUTO_CHK2:
	dec	a							; if 2, on and turn wifi off
	jr	nz,CLK_AUTO_3
	ld	hl,MMENU_CLOCK_2
	call	PRINTHL
	jr	CLK_AUTO_GMT
CLK_AUTO_3:
	ld	hl,MMENU_CLOCK_3
	call	PRINTHL
CLK_AUTO_GMT:
	ld	h,(ix+1)					; Save it for now
	ld	a,(ix+1)					; GMT current setting
	bit 7,a							; If set, is -
	jr	z,CLK_AUTO_GMTP
	ld	a,'-'
	call	CHPUT
	res	7,(ix+1)					; clear - indicator
CLK_AUTO_GMTP:
	ld	a,9
	cp	(ix+1)						; Greater than 9?
	jr	nc,CLK_AUTO_GMTD			; if not, just print what is in A + '0'
	ld	a,'1'						; it is 1
	call	CHPUT
	ld	a,(ix+1)
	add	'0'-10						; need to subtract 10 and add '0' to print
	call	CHPUT
	jr	CLK_AUTO_GMT_OPT
CLK_AUTO_GMTD:
	ld	a,'0'
	add	a,(ix+1)					; Our value
	call	CHPUT
	ld	(ix+1),h					; Restore original value
CLK_AUTO_GMT_OPT:
	ld	hl,MMENU_CLOCK_OPT
	call	PRINTHL
CLK_AUTO_WAIT_OPT_INPUT:
	call	CHGET
	cp	#1b							; ESC?
	jp	z,ESPSETUP					; Back to main menu
	cp	'0'							;
	jp	z,CLK_AUTO_WAIT_GMT			;
	cp	'1'							;
	jp	z,CLK_AUTO_WAIT_GMT			;
	cp	'2'							;
	jp	z,CLK_AUTO_WAIT_GMT			;
	cp	'3'							;
	jp	z,CLK_AUTO_WAIT_GMT			;
	call	BEEP					; Wrong Input, beep
	jp	CLK_AUTO_WAIT_OPT_INPUT		; Back to main menu
CLK_AUTO_WAIT_GMT:
	call	CHPUT					; Print option
	sub	'0'							; correct format
	ld	(ix+0),a					; Save it
	or	a
	jp	z,CLK_AUTO_GMT_CHK_DONE		; and sending the command if just disabling clock auto set
	cp	3
	jp	z,CLK_AUTO_GMT_CHK_DONE		; and sending the command if just disabling the adapter
	ld	hl,MMENU_GMT_OPT
	call	PRINTHL
	ld	d,0							; digits entered
	ld	e,0							; characters printed
	ld	(ix+1),0					; GMT 0
CLK_AUTO_WAIT_GMT_INPUT:
	call	CHGET
	cp	#1b							; ESC?
	jp	z,ESPSETUP					; Back to main menu
	cp	13							; Enter?
	jp	z,CLK_AUTO_GMT_CHK_INPUT	; Check if ok to send command
	cp	#08							; Backspace?
	jp	z,CLK_AUTO_GMT_CHK_BS		; Check if there is something to erase
	cp	'-'							; Negative value?
	jp	z,CLK_AUTO_GMT_CHK_INPUT	;
	cp	'0'							; >=0?
	jp	c,CLK_AUTO_GMT_BAD_INPUT	; If not, bad input
	cp	'9'+1						; <= 9
	jp	nc,CLK_AUTO_GMT_BAD_INPUT	; If not, bad input
	jp	CLK_AUTO_GMT_CHK_INPUT		; otherwise, validate digit
CLK_AUTO_GMT_CHK_BS:
	xor	a
	cp	e							; anything on screen?
	jr	z,CLK_AUTO_GMT_BAD_INPUT	; Nothing to erase
	dec	e							; one less character on the screen
	cp	d							; Any digit?
	jr	z,CLK_AUTO_GMT_CHK_BS_MIN	; if not, just erase - sign
	; There is, so it is one less digit
	dec	d
	jr	CLK_AUTO_GMT_CHK_DIGIT
CLK_AUTO_GMT_CHK_BS_MIN:
	ld	(ix+1),0					; reset sign
CLK_AUTO_GMT_CHK_DIGIT:
	ld	a,8							; backspace
	call	CHPUT					; print it
	ld	a,' '						; space
	call	CHPUT					; print it
	ld	a,8							; backspace
	call	CHPUT					; print it
	jp	CLK_AUTO_WAIT_GMT_INPUT		; return
CLK_AUTO_GMT_BAD_INPUT:
	; Beep might use sub rom, and if so, all registers will be messed up, better save
	push	bc
	push	de
	push	af
	push	hl
	call	BEEP					; Wrong Input, beep
	pop	hl
	pop	af
	pop	de
	pop bc
	jp	CLK_AUTO_WAIT_GMT_INPUT		; Continue waiting input
CLK_AUTO_GMT_CHK_INPUT:
	ld	c,a							; Save in C for printing if needed
	cp	'-'							; - sign?
	jr	nz,CLK_AUTO_GMT_CHK_CR		; If not, check if enter
	; - sign
	ld	a,0
	cp	e							; If not the first character, can't accept
	jr	nz,CLK_AUTO_GMT_BAD_INPUT
	; It is the first, so let's print it
	ld	a,c
	call	CHPUT
	ld	(ix+1),0x80					; Set the - sign bit, for now rest is zero
	inc	e							; increase characters printed
	jp	CLK_AUTO_WAIT_GMT_INPUT		; Continue waiting input
CLK_AUTO_GMT_CHK_CR:
	cp	13							; Enter?
	jr	nz,CLK_AUTO_GMT_CHK_CD		; If not, check if digit is valid
	; Enter
	ld	a,0
	cp	d							; Ok, at least one digit entered?
	jr	z,CLK_AUTO_GMT_BAD_INPUT	; No, so, enter is no good now
	; It is, so, if it had a digit entered and did not send, it was 1, so...
	ld	a,1
	or	a,(ix+1)					; adjust sign, if needed
	ld	(ix+1),a					; save
	jr	CLK_AUTO_GMT_CHK_DONE		; Ok, ready to send
CLK_AUTO_GMT_CHK_CD:
	; Ok, it is a digit
	ld	b,'0'
	sub	a,b							; A has digit value
	ld	b,a							; Save in B
	ld	a,0
	cp	d
	jr	nz,CLK_AUTO_GMT_CHK_CSD		; if not zero, it is second digit, so almost done
	; 1st digit, let's check if it is other than 1, if it is, we are almost done
	ld	a,1
	cp	b
	jr	z,CLK_AUTO_GMT_CHK_CD.1		; if it is 1, wait next digit or enter
	; not 1, so just adjust ix+1 and go
	ld	a,c
	call	CHPUT					; Print it
	ld	a,b
	or	a
	jr	z,CLK_AUTO_SKIP_SIGN
	or	a,(ix+1)					; adjust sign, if needed
CLK_AUTO_SKIP_SIGN:
	ld	(ix+1),a					; save
	jr	CLK_AUTO_GMT_CHK_DONE		; Ok, ready to send
CLK_AUTO_GMT_CHK_CD.1:
	ld	a,c
	call	CHPUT					; Print it
	inc	d							; digits entered now is 1
	inc	e							; digits printed increased
	jp	CLK_AUTO_WAIT_GMT_INPUT		; Continue waiting input
CLK_AUTO_GMT_CHK_CSD:
	; Second digit, easy... First was 1, now need to check if it is 0, 1 or 2, otherwise, bad entry
	ld	a,b
	ld	b,3
	cp	b
	jp	nc,CLK_AUTO_GMT_BAD_INPUT	; 3 or more, so, not valid
	or	a							; is it zero?
	jr	nz,CLK_AUTO_GMT_CHK_CSD1	; if not, check for 1
	; it was zero
	ld	a,10						; so, 10
	or	a,(ix+1)					; adjust sign, if needed
	ld	(ix+1),a					; save
	ld	a,c
	call	CHPUT					; print it
	jr	CLK_AUTO_GMT_CHK_DONE		; ready to
CLK_AUTO_GMT_CHK_CSD1:
	dec	a							; is it one?
	jr	nz,CLK_AUTO_GMT_CHK_CSD2
	; it was one
	ld	a,11						; so, eleven
	or	a,(ix+1)					; adjust sign, if needed
	ld	(ix+1),a					; save
	ld	a,c
	call	CHPUT					; print it
	jr	CLK_AUTO_GMT_CHK_DONE		; ready to send
CLK_AUTO_GMT_CHK_CSD2:
	; it was two
	ld	a,12						; so, twelve
	or	a,(ix+1)					; adjust sign, if needed
	ld	(ix+1),a					; save
	ld	a,c
	call	CHPUT					; print it
	; and send command
CLK_AUTO_GMT_CHK_DONE:
	ld	a,#D
	call	CHPUT
	ld	a,#A
	call	CHPUT
	ld	hl,STR_SENDING
	call	PRINTHL
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_SET_ACLK_SETTINGS
	out	(OUT_TX_PORT),a
	ld	a,0							; Size MSB is 0
	out	(OUT_TX_PORT),a
	ld	a,2							; Size LSB is 2
	out	(OUT_TX_PORT),a
	ld	a,(ix+0)					; Option
	out	(OUT_TX_PORT),a
	ld	a,(ix+1)					; GMT
	out	(OUT_TX_PORT),a
	ld	hl,60						; Wait Up To 1s
	ld	a,CMD_SET_ACLK_SETTINGS
	call	WAIT_MENU_QCMD_RESPONSE
	ld	hl,STR_SENDING_OK
	jr	nz,CLK_AUTO_GMT_CHK_RESULT
	ld	hl,STR_SENDING_FAIL
CLK_AUTO_GMT_CHK_RESULT:
	call	PRINTHL
	jp	WAIT_2S_AND_THEN_MAINMENU

START_WIFI_SCAN:
	ld hl,MMENU_SCAN
	call	PRINTHL					; Print Main Scan message
	call	STARTWIFISCAN			; Request WiFi Scan to start
	ld	de,(TXTTAB)					; we will borrow Basic Program memory area for now...
	ld	ixl,e
	ld	ixh,d						; address in IX
	ld	de,20						; at least 10s waiting scan to finish, retry 20 times waiting 0.5s between attempts
WIFI_SCAN_WAIT_END:
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_SCAN_RESULTS
	out	(OUT_TX_PORT),a
	ld	hl,60						; Wait Up To 1s
	call	WAIT_MENU_SCMD_RESPONSE
	jp	nz,WIFI_SCAN_SHOW_LIST		; if success show the list
	ld	a,b
	cp	2							; If 2, scan is done and nothing found
	jp	z,WIFI_SCAN_NONETWORKS
	ld	l,30
WIFI_SCAN_WAITHS:
	halt
	dec	l
	jr	nz,WIFI_SCAN_WAITHS
	dec	de
	ld	a,e
	or	d
	jp	z,WIFI_SCAN_TIMEOUT
	jp	WIFI_SCAN_WAIT_END
WIFI_SCAN_SHOW_LIST:
	ld	d,a							; Save access point counter here
	ld	e,0							; and here how many were printed
	ld	hl,MMENU_SCANS
	call	PRINTHL
	push	ix
	pop	hl							; IX in HL
WIFI_LIST_LOOP:
	ld	a,e
	add	a,'0'						; convert in number
	call	CHPUT
	ld	a,'-'
	call	CHPUT
	ld	a,' '
	call	CHPUT
PRT_APNAMELP:
	ld	a,(hl)
	or	a
	jp	z,PRT_APENC
	call	CHPUT
	inc	hl
	jp	PRT_APNAMELP
PRT_APENC:
	inc	hl
	ld	a,(hl)
	or	a
	jp	z,PRT_APNOTENC
	ld	bc,SCAN_TERMINATOR_ENC
	call	PRINTBC
	jp	PRT_AP_CHKLOOP
PRT_APNOTENC:
	ld	bc,SCAN_TERMINATOR_OPEN
	call	PRINTBC
PRT_AP_CHKLOOP:
	inc	hl
	inc	e
	ld	a,10
	cp	e
	jp	z,APLIST_OVERFLOW
	dec	d
	jp	nz,WIFI_LIST_LOOP
APLIST_OVERFLOW:
	; if here, whole list has been printed
	; E has the maximum allowable AP number
	; Let's ask which one to connect
	ld	hl,MMENU_SCANQ
	call	PRINTHL					; Show message which network to connect
	ld	a,'0'
	add	a,e
	ld	e,a							; To make it easy in the selection screen
WIFI_SELECT_AP:
	call	CHGET
	cp	#1b							; ESC?
	jp	z,ESPSETUP					; When done, back to main setup
	cp	'0'							; check if A is less than 0
	jp	c,INPUT_WFSAP_BAD_INPUT		; if it is, ignore
	cp	e							; check if a is greater than what is in E
	jp	nc,INPUT_WFSAP_BAD_INPUT	; if it is, ignore
	call	CHPUT					; Valid input, print it
	ld	e,'0'
	sub	a,e							; Get in decimal
	ld	e,a							; back in E
	;	IX has the AP list, A which one has been selected, now our routine will do it
	ld	hl,MMENU_CONNECTING
	call	PRINTHL
	; put IX in HL
	push	ix
	pop	hl
WIFI_CONNECT_AP_SRCH:
	ld	a,e
	or	a
WIFI_CONNECT_AP_SRCH.1:
	jp	z,WIFI_CONNECT_AP_PWDQ
	ld	a,(hl)
	inc	hl
	or	a
	jp	nz,WIFI_CONNECT_AP_SRCH.1	; Find string terminator
	; Found, jump encryption byte
	inc	hl
	dec	e							; decrement selection, if 0 we are done
	jp	nz,WIFI_CONNECT_AP_SRCH.1
WIFI_CONNECT_AP_PWDQ:
	; HL has the address of AP name string
	ld	d,h
	ld	e,l							; Save copy in D
	ld	bc,0						; BC will have the ap connection data lenght
WIFI_CONNECT_APSIZE:
	inc	bc
	ld	a,(de)
	inc	de
	or	a
	jp	nz,WIFI_CONNECT_APSIZE		; Count size, including zero terminator
	; check for encryption
	ld	a,(de)
	or	a
	jr	z,WIFI_CONNECT_SENDCMD		; If no password requested, good to go
	; Shoot, need to request password, well, let's do it
	push	hl						; Save HL
	ld	hl,MMENU_ASKPWD
	call	PRINTHL					; Inform that user need to input PWD
	pop	hl							; restore HL
	ld	iy,0						; iy will help in backspacing
	ld	ixh,0						; Start not hidden
WIFI_CONNECT_RCV_PWD:
	call	CHGET
	cp	#1b							; ESC?
	jp	z,ESPSETUP					; When done, back to main setup
	cp	#08							; Backspace?
	jp	z,WIFI_CONNECT_RCV_PWD_BS	; Check if there is something to erase
	cp	#0d							; ENTER?
	jp	z,WIFI_PWD_CHECK_INPUT		; Check if ok
	cp	#7f							; delete?
	jp	z,WIFI_CONNECT_RCV_PWDH		; Change password from clear to hidden or vice versa
	; Ok, so it is a digit and store
	ld	(de),a
	inc	bc
	inc	de
	inc	iy							; Increment counters and pointer
	push	af						; save A
	ld	a,ixh
	or	a							; if zero, print char, otherwise print *
	jr	z,WIFI_CONNECT_RCV_PWD_CHAR
	pop	af
	ld	a,'*'						; Otherwise print * and keep password hidden
	call	CHPUT					; Print an *
	jp	WIFI_CONNECT_RCV_PWD		; and back to receiving digits
WIFI_CONNECT_RCV_PWD_CHAR:
	pop	af
	call	CHPUT					; Print an *
	jp	WIFI_CONNECT_RCV_PWD		; and back to receiving digits

WIFI_CONNECT_RCV_PWDH:
	ld	a,iyl
	or	iyh
	jp	nz,WIFI_CONNECT_RCV_PWD		; if digits entered, can't change password behavior
	xor	a
	or	ixh
	ld	ixh,1
	jr	z,WIFI_CONNECT_RCV_PWD		; return if it was 0
	ld	ixh,0
	jr	z,WIFI_CONNECT_RCV_PWD		; otherwise set to 0 and return

WIFI_CONNECT_RCV_PWD_BS:
	ld	a,iyl
	or	iyh
	jp	z,WIFI_CONNECT_RCV_PWD		; if no digits entered, nothing to erase
	dec	iy							; decrement counter
	dec	bc							; decrement counter
	dec	de							; decrement pointer
	ld	a,8							; backspace
	call	CHPUT					; print it
	ld	a,' '						; space
	call	CHPUT					; print it
	ld	a,8							; backspace
	call	CHPUT					; print it
	jp	WIFI_CONNECT_RCV_PWD		; return

WIFI_PWD_CHECK_INPUT:
	ld	a,iyl
	or	iyh
	jp	z,WIFI_CONNECT_RCV_PWD		; if no digits entered, no password to send
	; otherwise done and ready to send

WIFI_CONNECT_SENDCMD:
	ld	a,#D
	call	CHPUT
	ld	a,#A
	call	CHPUT
	; HL has the address of our data, BC the data size, so it is just needed to send the command
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_WIFI_CONNECT
	out	(OUT_TX_PORT),a
	ld	a,b							; Size MSB is in B
	out	(OUT_TX_PORT),a
	ld	a,c							; Size LSB is in c
	out	(OUT_TX_PORT),a
WIFI_CONNECT_SENDCMDLP:
	ld	a,(hl)
	out	(OUT_TX_PORT),a
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jp	nz,WIFI_CONNECT_SENDCMDLP
	ld	hl,600						; Wait Up To 10s
	ld	a,CMD_WIFI_CONNECT			; Our command
	call	WAIT_MENU_QCMD_RESPONSE
	jp	z,WIFI_CONNECT_FAIL
	ld	hl,STR_SENDING_OK_JN		; Success
	call	PRINTHL
	jp	WAIT_2S_AND_THEN_MAINMENU
WIFI_CONNECT_FAIL:
	ld	hl,STR_SENDING_NOK_JN		; Failure
	call	PRINTHL
	jp	WAIT_4S_AND_THEN_MAINMENU

INPUT_WFSAP_BAD_INPUT:
	push	bc
	push	de
	push	af
	push	hl
	call	BEEP					; Wrong Input, beep
	pop	hl
	pop	af
	pop	de
	pop bc
	jp WIFI_SELECT_AP				; return

WIFI_SCAN_NONETWORKS:
	ld	hl,MMENU_SCANN
	call	PRINTHL
	jp	WAIT_4S_AND_THEN_MAINMENU

WIFI_SCAN_TIMEOUT:
	ld	hl,MMENU_SCANF
	call	PRINTHL
	jp	WAIT_4S_AND_THEN_MAINMENU

SET_WIFI_TIMEOUT:
	ld hl,MMENU_TIMEOUT
	call	PRINTHL					; Print Main Nagle message
	call	CHECKTIMEOUT			; TimeOut is on or off?
	jp	z,WIFI_SET_ALWAYS_ON		; if 0, always ON
	; otherwise there is a timeout
	push	hl
	ld hl,MMENU_TIMEOUT_NOTALWAYSON1
	call	PRINTHL
	pop	hl
	call	PRINTHL
	ld hl,MMENU_TIMEOUT_NOTALWAYSON2
	call	PRINTHL
	ld	d,0							; count digits
	jr	INPUT_TIMEOUT
WIFI_SET_ALWAYS_ON:
	ld	hl,MMENU_TIMEOUT_ALWAYSON
	call	PRINTHL
	ld	de,(TXTTAB)					; we will borrow Basic Program memory area for now...
	ld	ixl,e
	ld	ixh,d						; address in IX
	ld	d,0							; count digits
INPUT_TIMEOUT:
	call	CHGET
	cp	#1b							; ESC?
	jp	z,ESPSETUP					; When done, back to main setup
	cp	#0d							; ENTER?
	jp	z,SET_WIFI_CHECK_INPUT		; Check if ok
	cp	#08							; Backspace?
	jp	z,SET_WIFI_BS_INPUT			; Check if there is something to erase
	cp	'0'							; check if A is less than 0
	jp	c,INPUT_TIMEOUT_BAD_INPUT	; if it is, ignore
	cp	'9'+1						; check if a is greater than  9
	jp	nc,INPUT_TIMEOUT_BAD_INPUT	; if it is, ignore
	ld	(ix+0),a					; save it
	call	CHPUT					; it is valid, so print it
	inc	d							; increment digit count
	inc	ix							; increment pointer
	ld	a,3
	cp	d
	jp	z,SET_WIFI_CHECK_INPUT		; All we can do is accept up to 3 digits, check if ok
	jp	INPUT_TIMEOUT				; not done yet, so continue

INPUT_TIMEOUT_BAD_INPUT:
	call	BEEP					; Wrong Input, beep
	jp INPUT_TIMEOUT				; return

SET_WIFI_BS_INPUT:
	xor	a
	or	d							; counter has any digit?
	jp	z,INPUT_TIMEOUT				; nope, so just continue
	dec	d							; decrement counter
	dec	ix							; decrement pointer
	ld	a,8							; backspace
	call	CHPUT					; print it
	ld	a,' '						; space
	call	CHPUT					; print it
	ld	a,8							; backspace
	call	CHPUT					; print it
	jp	INPUT_TIMEOUT				; return

SET_WIFI_CHECK_INPUT:
	xor	a
	or	d							; counter has any digits
	jp	z,INPUT_TIMEOUT				; nope, so just continue
	; IX is pointing one position after last digit, so revert
	dec	ix
	ld	a,(ix+0)					; Digit in A
	sub	'0'							; convert it to decimal
	ld	h,0							; first digit, so H is 0
	ld	l,a							; and L has the digit
	dec	d							; if digits finished, just set
	jp	z,SET_WIFI_EXECUTE_SET_COMMAND
	dec	ix
	ld	a,(ix+0)					; Digit in A
	sub	'0'							; convert it to decimal
	add	a,a							; A*2
	ld	c,a							; A*2 in C
	add	a,a							; A*4
	add	a,a							; A*8
	add	a,c							; A*10
	; Up to here, we can get 90 + 9, 99, won't go to H anyway, just add to L
	add	a,l							; L has the first digit
	ld	l,a							; and now L has the two digits
	dec	d							; if digits finished, just set
	jp	z,SET_WIFI_EXECUTE_SET_COMMAND
	dec	ix
	ld	a,(ix+0)					; Digit in A
	sub	'0'							; convert it to decimal
	add	a,a							; A*2
	ld	c,a							; A*2 in C
	add	a,a							; A*4
	add	a,a							; A*8
	add	a,c							; A*10
	ex	de,hl						; get the two digits results in de
	ld	l,a
	ld	h,0							; HL = A*10
	add	hl,hl						; HL = A*20
	ld	c,l
	ld	b,h							; BC = A*20
	add	hl,hl						; HL = A*40
	add	hl,hl						; HL = A*80
	add	hl,bc						; HL = A*100
	add	hl,de						; HL = three digits result
	; This was the last digit, up to three
SET_WIFI_EXECUTE_SET_COMMAND:
	jp	SET_ESP_WIFI_TIMEOUT		; and set and done

SET_NAGLE:
	ld hl,MMENU_NAGLE
	call	PRINTHL					; Print Main Nagle message
	call	CHECKNAGLE				; Nagle is on or off?
	jr	nz,NAGLE_IS_ON				;
	ld	hl,MMENU_NAGLE_OFF			; Show the menu telling nagle is off
	call	PRINTHL					; Print options
SET_NAGLE_WI_ON:
	call	CHGET
	cp	#1b							; ESC?
	jp	z,ESPSETUP					; When done, back to main setup
	cp	'O'							; Toggle Nagle On
	jp	z,SET_NAGLE_ON				;
	cp	'o'							; Toggle Nagle On
	jp	z,SET_NAGLE_ON				;
	call	BEEP					; Wrong Input, beep
	jp	SET_NAGLE_WI_ON				; And return waiting key

NAGLE_IS_ON:
	ld	hl,MMENU_NAGLE_ON			; Show the menu telling nagle is on
	call	PRINTHL					; Print options
SET_NAGLE_WI_OFF:
	call	CHGET
	cp	#1b							; ESC?
	jp	z,ESPSETUP					; When done, back to main setup
	cp	'O'							; Toggle Nagle Off
	jp	z,SET_NAGLE_OFF				;
	cp	'o'							; Toggle Nagle Off
	jp	z,SET_NAGLE_OFF				;
	call	BEEP					; Wrong Input, beep
	jp	SET_NAGLE_WI_OFF			; And return waiting key

SET_ESP_WIFI_TIMEOUT:
	ex	de,hl
	ld	a,#0d
	call	CHPUT
	ld	a,#0a
	call	CHPUT
	ld	hl,STR_SENDING				; Indicate it is sending a command
	call	PRINTHL
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_TIMER_SET
	out	(OUT_TX_PORT),a
	xor	a							; Size MSB is 0
	out	(OUT_TX_PORT),a
	ld	a,2							; Size LSB is 2
	out	(OUT_TX_PORT),a
	ld	a,d							; Timeout MSB
	out	(OUT_TX_PORT),a
	ld	a,e							; Timeout LSB
	out	(OUT_TX_PORT),a
	ld	hl,60						; Wait Up To 1s
	ld	a,CMD_TIMER_SET				; Our command
	call	WAIT_MENU_QCMD_RESPONSE
	jp	z,MENU_BAD_END
	ld	hl,STR_SENDING_OK			; Success
	call	PRINTHL
	jp	WAIT_2S_AND_THEN_MAINMENU

SET_NAGLE_OFF:
	ld	hl,STR_SENDING				; Indicate it is sending a command
	call	PRINTHL
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_NAGLE_OFF
	out	(OUT_TX_PORT),a
	ld	hl,60						; Wait Up To 1s
	call	WAIT_MENU_QCMD_RESPONSE
	jp	z,MENU_BAD_END
	ld	hl,STR_SENDING_OK			; Success
	call	PRINTHL
	jp	WAIT_2S_AND_THEN_MAINMENU

STARTWIFISCAN:
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_SCAN_START
	out	(OUT_TX_PORT),a
	ld	hl,60						; Wait Up To 1s
	call	WAIT_MENU_QCMD_RESPONSE
	ret	nz							; if success return
	ld	a,CR
	call	CHPUT
	ld	a,LF
	call	CHPUT
	jp	MENU_SUB_BAD_END			; If error, nothing much to do, main menu

SET_NAGLE_ON:
	ld	hl,STR_SENDING				; Indicate it is sending a command
	call	PRINTHL
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_NAGLE_ON
	out	(OUT_TX_PORT),a
	ld	hl,60						; Wait Up To 1s
	call	WAIT_MENU_QCMD_RESPONSE
	jp	z,MENU_BAD_END
	ld	hl,STR_SENDING_OK			; Success
	call	PRINTHL
	jp	WAIT_2S_AND_THEN_MAINMENU

WAIT_4S_AND_THEN_MAINMENU:
	ld	a,240						; Wait 4 seconds with message on screen
	jr	WAIT_2S_AND_THEN_MAINMENU_WAIT
WAIT_2S_AND_THEN_MAINMENU:
	ld	a,120						; Wait 2 seconds with message on screen
WAIT_2S_AND_THEN_MAINMENU_WAIT:
	halt
	dec	a
	; If not zero, our time out has not elapsed
	jr	nz,WAIT_2S_AND_THEN_MAINMENU_WAIT
	jp	ESPSETUP					; When done, back to main setup

; Check Auto Clock 
ISCLKAUTO:
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_QUERY_ACLK_SETTINGS
	out	(OUT_TX_PORT),a
	ld	hl,60						; Wait Up To 1s
	ld	de,(TXTTAB)					; we will borrow Basic Program memory area for now...
	ld	ixl,e
	ld	ixh,d						; address in IX
	call	WAIT_MENU_CMD_RESPONSE
	jp	z,MENU_SUB_BAD_END
	; Response received, IX+0 and IX+1 has Auto Clock and GMT, A
	ret

; Check what is the current NAGLE setting
CHECKNAGLE:
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_QUERY_ESP_SETTINGS
	out	(OUT_TX_PORT),a
	ld	hl,60						; Wait Up To 1s
	ld	de,(TXTTAB)					; we will borrow Basic Program memory area for now...
	ld	ixl,e
	ld	ixh,d						; address in IX
	call	WAIT_MENU_CMD_RESPONSE
	jp	z,MENU_SUB_BAD_END
	; Response received, nagle is the first one, ON: or OFF:
	ld	a,'O'
	cp	(ix+0)
	jp	nz,MENU_SUB_BAD_END
	ld	a,'N'
	cp	(ix+1)
	jp	nz,CHECK_NAGLE_OFF
	ld	a,':'
	cp	(ix+2)
	jp	nz,MENU_SUB_BAD_END
	or	a							; it will make it NZ
	ret
CHECK_NAGLE_OFF:
	ld	a,'F'
	cp	(ix+1)
	jp	nz,MENU_SUB_BAD_END
	ld	a,'F'
	cp	(ix+2)
	jp	nz,MENU_SUB_BAD_END
	ld	a,':'
	cp	(ix+3)
	jp	nz,MENU_SUB_BAD_END
	; Already has zero, so just ret
	ret

; Check what is the current TIMEOUT setting, return 0 if always on, otherwise there is a timeout
; Will return a zero terminated string @ HL that can be printed
; Will return the value in DE
CHECKTIMEOUT:
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_QUERY_ESP_SETTINGS
	out	(OUT_TX_PORT),a
	ld	hl,60						; Wait Up To 1s
	ld	de,(TXTTAB)					; we will borrow Basic Program memory area for now...
	ld	ixl,e
	ld	ixh,d						; address in IX
	call	WAIT_MENU_CMD_RESPONSE
	jp	z,MENU_SUB_BAD_END
	; Response received, nagle is the first one, ON: or OFF:
	ld	a,':'
	inc	ix
	inc	ix							; Nagle response is two or three bytes long, let's check
	dec	bc
	dec	bc							; Remaining bytes
	cp	(ix+0)
	jp	z,CHECKTIMEOUT.1
	inc	ix
	dec	bc							; Remaining bytes
	cp	(ix+0)
	jp	nz,MENU_SUB_BAD_END			; If not here, sorry to say it is an error
CHECKTIMEOUT.1:
	ld	a,b
	or	c							; all data read?
	jp	z,MENU_SUB_BAD_END			; If so, sorry to say it is an error
	inc	ix							; At the first digit
	dec	bc							; Remaining bytes
	ld	a,b
	or	c							; all data read?
	jp	z,MENU_SUB_BAD_END			; If so, sorry to say it is an error
	push	ix						; This is the start of the string, save it
	ld	h,0							; no digit so far
	; it can have up to three digits
CHECKTIMEOUT.2:
	ld	a,':'
	cp	(ix+0)						; Check if it is the separator
	jp	z,CHECKTIMEOUT.3			; If it is routine will follow through
	ld	a,(ix+0)					; Get the supposed digit in A
	ld	l,'9'+1
	cp	l
	jp	nc,MENU_SUB_BAD_END_1S		; If more than '9', sorry to say it is an error
	ld	l,'0'
	cp	l
	jp	c,MENU_SUB_BAD_END_1S		; If less than '0', sorry to say it is an error
	inc	h							; It is not, so it is a digit
	ld	a,3
	cp	h
	jp	c,MENU_SUB_BAD_END_1S		; If more than three digits, sorry to say it is an error
	inc	ix							; increase pointer
	dec	bc							; decrease remaining
	ld	a,b
	or	c							; all data read?
	jp	nz,CHECKTIMEOUT.2			; not, so rinse and repeat
CHECKTIMEOUT.3:
	ld	(ix+0),0					; Null terminate string value
	dec	ix
	ld	a,(ix+0)					; 1st Digit in A
	sub	'0'							; Convert it to decimal value
	ld	e,a
	ld	d,0							; DE has first digit
	dec	h							; decrement digit counter
	jr	z,CHECKTIMEOUT.END			; If all digits, done
	; Now second digit, multiply it by 10 and add to E, even if 90 + 9, still fits E
	dec	ix
	ld	a,(ix+0)					; 2nd Digit
	sub	'0'							; Convert it to decimal value
	add	a,a							; A has *2
	ld	c,a							; C has *2
	add	a,a							; A has *4
	add	a,a							; A has *8
	add	a,c							; A has *10
	add	a,e							; A has two digits result
	ld	e,a							; back to E, DE has two digits results
	dec	h							; decrement digit counter
	jr	z,CHECKTIMEOUT.END			; If all digits, done
	; Now Third digit, multiply it by 100 and add to DE
	dec	ix
	ld	a,(ix+0)					; 3rd Digit
	sub	'0'							; Convert it to decimal value
	add	a,a							; A has *2
	ld	c,a							; C has *2
	add	a,a							; A has *4
	add	a,a							; A has *8
	add	a,c							; A has *10
	ld	h,0
	ld	l,a							; HL has *10
	add	hl,hl						; HL has *20
	ld	b,h
	ld	c,l							; BC has *20
	add	hl,hl						; HL has *40
	add	hl,hl						; HL has *80
	add	hl,bc						; HL has *100
	add	hl,de						; HL has three digit value
	ex	de,hl						; now in DE
CHECKTIMEOUT.END:
	pop	hl							; Restore address of string version of time count
	ld	a,d
	or	e							; Set zero flag according to the time out set
	ret

MENU_SUB_BAD_END_1S:
	pop	af							; 1 register was stacked, pop it
MENU_SUB_BAD_END:
	pop	af							; It was a sub, so clear stack
MENU_BAD_END:
	ld	hl,STR_SENDING_FAIL			; error message
	call	PRINTHL
	jp	WAIT_2S_AND_THEN_MAINMENU

; WAIT an ESP quick command Response
; Inputs:
; A -> Command Code
; HL -> Timeout
;
; Returns:
; Flag Z is zero if failure, non zero if success
;
; Affect:
; AF and HL
;
WAIT_MENU_QCMD_RESPONSE:
	push	de
	ld	d,a							; Command to wait in D
WAIT_MENU_QCMD_RESPONSE_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_QCMD_RESPONSE_ST1.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_QCMD_RESPONSE_ST1
	jp	WAIT_MENU_QCMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_QCMD_RESPONSE_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	d							; Is response of our command?
	jr	nz,WAIT_MENU_QCMD_RESPONSE_ST1
	; now get return code, if return code other than 0, it is failure, otherwise success
WAIT_MENU_QCMD_RESPONSE_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_QCMD_RESPONSE_RC.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_QCMD_RESPONSE_RC
	jp	WAIT_MENU_QCMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_QCMD_RESPONSE_RC.1:
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	; if not, done
	jp	nz,WAIT_MENU_QCMD_RESPONSE_END_NOK
WAIT_MENU_QCMD_RESPONSE_END_OK:
	ld	a,1
	or	a							; NZ to indicate success
WAIT_MENU_QCMD_RESPONSE_END:
	pop	de
	ret
WAIT_MENU_QCMD_RESPONSE_END_NOK:
	xor	a
	pop	de
	ret

; WAIT an ESP regular command Response
; Inputs:
; A -> Command Code
; HL -> Timeout
; IX -> Where to store response
;
; Returns:
; Flag Z is zero if failure, non zero if success
; BC is the response size
;
; Affect:
; AF , BC and HL
;
WAIT_MENU_CMD_RESPONSE:
	push	de
	push	ix
	ld	d,a							; Command to wait in D
WAIT_MENU_CMD_RESPONSE_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_CMD_RESPONSE_ST1.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_CMD_RESPONSE_ST1
	jp	WAIT_MENU_CMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_CMD_RESPONSE_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	d							; Is response of our command?
	jr	nz,WAIT_MENU_CMD_RESPONSE_ST1
	; now get return code, if return code other than 0, it is finished
WAIT_MENU_CMD_RESPONSE_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_CMD_RESPONSE_RC.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_CMD_RESPONSE_RC
	jp	WAIT_MENU_CMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_CMD_RESPONSE_RC.1:
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	; if not, done
	jp	nz,WAIT_MENU_CMD_RESPONSE_END_NOK
	; next two bytes are size bytes, save it to BC
WAIT_MENU_CMD_RESPONSE_ST2A:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_CMD_RESPONSE_ST2A.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_CMD_RESPONSE_ST2A
	jp	WAIT_MENU_CMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_CMD_RESPONSE_ST2A.1:
	in	a,(IN_DATA_PORT)
	ld	b,a
WAIT_MENU_CMD_RESPONSE_ST2B:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_CMD_RESPONSE_ST2B.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_CMD_RESPONSE_ST2B
	jp	WAIT_MENU_CMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_CMD_RESPONSE_ST2B.1:
	in	a,(IN_DATA_PORT)
	ld	c,a
	or	b							; zero size in response?
	jr	z,WAIT_MENU_CMD_RESPONSE_END_OK
	ld	d,b
	ld	e,c							; copy to de
	; now loop getting the data until received everything or time out
WAIT_MENU_CMD_RESPONSE_GET_DATA:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_CMD_RESPONSE_GET_DATA.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_CMD_RESPONSE_GET_DATA
	jp	WAIT_MENU_CMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_CMD_RESPONSE_GET_DATA.1:
	in	a,(IN_DATA_PORT)			; Get data
	ld	(ix+0),a					; put it in the buffer
	inc	ix							; increment pointer
	dec	de							; decrement counter
	ld	a,d
	or	e							; is counter 0?
	jr	nz,WAIT_MENU_CMD_RESPONSE_GET_DATA
WAIT_MENU_CMD_RESPONSE_END_OK:
	ld	a,1
	or	a							; NZ to indicate success
WAIT_MENU_CMD_RESPONSE_END:
	pop	ix
	pop	de
	ret
WAIT_MENU_CMD_RESPONSE_END_NOK:
	xor	a
	pop	ix
	pop	de
	ret

; WAIT an ESP WiFi Scan command Response
; Inputs:
; A -> Command Code
; HL -> Timeout
; IX -> Where to store response
;
; Returns:
; Flag Z is zero if failure, non zero if success
; A is the number of access points scanned
;
; Response is stored as:
; Access Point SSID zero terminated and after first 0
; 0 if Open otherwise requires a password to join
; And this repeats...
;
; Affect:
; AF , BC and HL
;
WAIT_MENU_SCMD_RESPONSE:
	push	de
	push	ix
	ld	d,a							; Command to wait in D
WAIT_MENU_SCMD_RESPONSE_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_SCMD_RESPONSE_ST1.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_SCMD_RESPONSE_ST1
	jp	WAIT_MENU_SCMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_SCMD_RESPONSE_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	d							; Is response of our command?
	jr	nz,WAIT_MENU_SCMD_RESPONSE_ST1
	; now get return code, if return code other than 0, it is finished
WAIT_MENU_SCMD_RESPONSE_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_SCMD_RESPONSE_RC.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_SCMD_RESPONSE_RC
	jp	WAIT_MENU_SCMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_SCMD_RESPONSE_RC.1:
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	; if not, done
	jp	nz,WAIT_MENU_SCMD_RESPONSE_END_NOK
	; next byte is how many access points are available
WAIT_MENU_SCMD_RESPONSE_ST2A:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_SCMD_RESPONSE_ST2A.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_SCMD_RESPONSE_ST2A
	jp	WAIT_MENU_SCMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_SCMD_RESPONSE_ST2A.1:
	in	a,(IN_DATA_PORT)
	ld	b,a							; save in B
	ld	c,a							; and C as well
	; Now should loop this until c is 0, c will control access point received count
WAIT_MENU_SCMD_RESPONSE_ST2B:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_SCMD_RESPONSE_ST2B.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_SCMD_RESPONSE_ST2B
	jp	WAIT_MENU_SCMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_SCMD_RESPONSE_ST2B.1:
	in	a,(IN_DATA_PORT)
	ld	(ix+0),a
	inc	ix							; increment pointer
	or	a							; terminator of AP Name?
	jr	nz,WAIT_MENU_SCMD_RESPONSE_ST2B
	; Get encryption
WAIT_MENU_SCMD_RESPONSE_GET_ENC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WAIT_MENU_SCMD_RESPONSE_GET_ENC.1
	call	HLTIMEOUT
	jr	nz,WAIT_MENU_SCMD_RESPONSE_GET_ENC
	jp	WAIT_MENU_CMD_RESPONSE_END	; if time out waiting, return
WAIT_MENU_SCMD_RESPONSE_GET_ENC.1:
	in	a,(IN_DATA_PORT)			; Get data
	sub	'O'							; If O, open, will be 0, otherwise, will be notzero
	ld	(ix+0),a					; put it in the buffer
	inc	ix							; increment pointer
	dec	c							; decrement counter
	xor	a
	or	c							; is counter 0?
	; if not continue getting more SSIDs
	jr	nz,WAIT_MENU_SCMD_RESPONSE_ST2B
	; it is zero, so, done
WAIT_MENU_SCMD_RESPONSE_END_OK:
	ld	a,1
	or	a							; NZ to indicate success
	ld	a,b							; Number of APs in A
WAIT_MENU_SCMD_RESPONSE_END:
	pop	ix
	pop	de
	ret
WAIT_MENU_SCMD_RESPONSE_END_NOK:
	ld	b,a							; Return code in B
	xor	a
	pop	ix
	pop	de
	ret

; This routine will check if HL is 0, if it is, will return immediatelly
; If it is not, will decrease HL value and halt (wait one interrupt)
HLTIMEOUT:
	ld	a,h
	or	l
	ret	z
	dec	hl
	halt
	ret

; Routine to print the string addressed by HL
PRINTHL:
	ld	a,(hl)
	or	a
	ret	z							; When string is finished, done!
	call	CHPUT
	inc	hl
	jp	PRINTHL

; Routine to print the string addressed by BC
PRINTBC:
	ld	a,(bc)
	or	a
	ret	z							; When string is finished, done!
	call	CHPUT
	inc	bc
	jp	PRINTBC

;===============================
;===  HTIM_I hook execution  ===
;===============================
DO_HTIMI:
	push	af						; HTIM hook -> need to keep A value
	call	GETCOUNTER				; Counter in hl
	ld	a,l
	or	h							; In this operation, check if HL is o
	jr	z,DO_HTIMI_END				; If it is, nothing to do
	dec	hl							; Otherwise decrement it
	call	SETCOUNTER				; And save it
DO_HTIMI_END:
	call	GETSLT
	; Slot in A, now get the address of our counter
	call	GETMEMPOINTER
	; HL has the address of our memory area, and there is where we should jump
	pop	af							; Restore original A value
	jp	(hl)

;===============================
;===  EXTBIO hook execution  ===
;===============================
DO_EXTBIO:
	push	hl
	push	bc
	push	af
	ld	a,d
	cp	#22
	jr	nz,JUMP_OLD
	cp	e
	jr	nz,JUMP_OLD

	; Check API ID
	ld	hl,UNAPI_ID
	ld	de,ARG
LOOP:
	ld	a,(de)
	call	TOUPPER
	cp	(hl)
	jr	nz,JUMP_OLD2
	inc	hl
	inc	de
	or	a
	jr	nz,LOOP

	; A=255: Jump to old hook

	pop	af
	push	af
	inc	a
	jr	z,JUMP_OLD2

	; A=0: B=B+1 and jump to old hook

	call	GETSLT
	call	GETWRK
	pop	af
	pop	bc
	or	a
	jr	nz,DO_EXTBIO2
	inc	b
	ex	(sp),hl
	ld	de,#2222
	ret

DO_EXTBIO2:
	; A=1: Return A=Slot, B=Segment, HL=UNAPI entry address

	dec	a
	jr	nz,DO_EXTBIO3
	pop	hl
	call	GETSLTT					; GETSLTT is GETSLT that checks if our memory area @ HIMEM has been allocated, if not, allocate it
	ld	b,#FF
	ld	hl,UNAPI_ENTRY
	ld	de,#2222
	ret

	; A>1: A=A-1, and jump to old hook

DO_EXTBIO3:							; A=A-1 already done
	ex	(sp),hl
	ld	de,#2222
	ret


;--- Jump here to execute old EXTBIO code

JUMP_OLD2:
	ld	de,#2222
JUMP_OLD:							; Assumes "push hl,bc,af" done
	push	de
	call	GETSLT
	call	GETWRK
	pop	de
	pop	af
	pop	bc
	ex	(sp),hl
	ret

;====================================
;===  Functions entry point code  ===
;====================================
UNAPI_ENTRY:
	ei
	push	hl
	push	af
	ld	hl,FN_TABLE
	bit	7,a

	if	MAX_IMPFN >= 128

	jr	z,IS_STANDARD
	ld	hl,IMPFN_TABLE
	and	%01111111
	cp	MAX_IMPFN-128
	jr	z,OK_FNUM
	jr	nc,UNDEFINED
IS_STANDARD:

	else

	jr	nz,UNDEFINED

	endif

	cp	MAX_FN
	jr	z,OK_FNUM
	jr	nc,UNDEFINED

OK_FNUM:
	add	a,a
	push	de
	ld	e,a
	ld	d,0
	add	hl,de
	pop	de

	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a

	pop	af
	ex	(sp),hl
	ret

;--- Undefined function: return with registers unmodified
UNDEFINED:
	pop	af
	pop	hl
	ret


;===================================
;===  Functions addresses table  ===
;===================================

;--- Implementation-specific routines addresses table

	if	MAX_IMPFN >= 128

IMPFN_TABLE:
FN_128:					dw	FN_DUMMY

	endif

FN_TABLE:
FN_0:					dw	UNAPI_GET_INFO
FN_1:					dw	TCPIP_GET_CAPAB
FN_2:					dw	TCPIP_GET_IPINFO
FN_3:					dw	TCPIP_NET_STATE
;TCPIP_SEND_ECHO not going to be implemented, ESP do not support ping like UNAPI specify
FN_4:					dw	FN_NOT_IMP
;TCPIP_RCV_ECHO not going to be implemented as SEND_ECHO is not implemented
FN_5:					dw	FN_NOT_IMP
FN_6:					dw	TCPIP_DNS_Q
FN_7:					dw	TCPIP_DNS_S
FN_8:					dw	TCPIP_UDP_OPEN
FN_9:					dw	TCPIP_UDP_CLOSE
FN_10:					dw	TCPIP_UDP_STATE
FN_11:					dw	TCPIP_UDP_SEND
FN_12:					dw	TCPIP_UDP_RCV
FN_13:					dw	TCPIP_TCP_OPEN
FN_14:					dw	TCPIP_TCP_CLOSE
FN_15:					dw	TCPIP_TCP_ABORT
FN_16:					dw	TCPIP_TCP_STATE
FN_17:					dw	TCPIP_TCP_SEND
FN_18:					dw	TCPIP_TCP_RCV
;TCPIP_TCP_FLUSH makes no sense as we do not use buffers to send, any buffer is internal to ESP and we can't delete
FN_19:					dw	FN_NOT_IMP
;TCPIP_RAW_OPEN not going to be implemented, ESP do not support RAW connections
FN_20:					dw	FN_NOT_IMP
;TCPIP_RAW_CLOSE not going to be implemented, ESP do not support RAW connections
FN_21:					dw	FN_NOT_IMP
;TCPIP_RAW_STATE not going to be implemented, ESP do not support RAW connections
FN_22:					dw	FN_NOT_IMP
;TCPIP_RAW_SEND not going to be implemented, ESP do not support RAW connections
FN_23:					dw	FN_NOT_IMP
;TCPIP_RAW_RCV not going to be implemented, ESP do not support RAW connections
FN_24:					dw	FN_NOT_IMP
FN_25:					dw	TCPIP_CONFIG_AUTOIP
FN_26:					dw	TCPIP_CONFIG_IP
FN_27:					dw	TCPIP_CONFIG_TTL
FN_28:					dw	TCPIP_CONFIG_PING
;TCPIP_WAIT not needed for our implementation
FN_29:					dw	END_OK


;========================
;===  Functions code  ===
;========================
FN_NOT_IMP:
	ld	a,ERR_NOT_IMP
	ret

END_OK:	
	xor a
	ret	

; Most functions do not have special handling on time out and can use this.
; If there is a need to retry sending or receiving on time-out, then a custom
; time-out function must be done, check the examples of UDP and TCP receive
TCPIP_GENERIC_CHECK_TIME_OUT:
	; Save registers other than AF
	push bc
	push de
	push hl
	call	GETCOUNTER
	ld	a,l
	or	h
	; Restore registers, we are returning
	pop	hl
	pop	de
	pop	bc
	ret	nz
	; Ok, timeout...
	pop	af							; Get return address of who called this out of the stack
	ld	a,ERR_INV_OPER
	ret								; and return the function itself

;========================
;===  UNAPI_GET_INFO  ===
;========================
;Obtain the implementation name and version.
;
;    Input:  A  = 0
;    Output: HL = Descriptive string for this implementation, on this slot, zero terminated
;            DE = API version supported, D.E
;            BC = This implementation version, B.C.
;            A  = 0 and Cy = 0
UNAPI_GET_INFO:
	ld	bc,256*ROM_V_P+ROM_V_S
	ld	de,256*API_V_P+API_V_S
	ld	hl,APIINFO
	xor	a
	ret

;=========================
;===  TCPIP_GET_CAPAB  ===
;=========================
;Get information about the TCP/IP capabilities and features.
;
;Input:  A = 1
;        B = Index of information block to retrieve:
;            1: Capabilities and features flags, link level protocol
;            2: Connection pool size and status
;            3: Maximum datagram size allowed
;            4: Second set of capabilities and features flags
;Output: A = Error code
;        When information block 1 requested:
;            HL = Capabilities flags
;            DE = Features flags
;            B  = Link level protocol used
;        When information block 2 requested:
;            B = Maximum simultaneous TCP connections supported
;            C = Maximum simultaneous UDP connections supported
;            D = Free TCP connections currently available
;            E = Free UDP connections currently available
;            H = Maximum simultaneous raw IP connections supported
;            L = Free raw IP connections currently available
;        When information block 3 requested:
;            HL = Maximum incoming datagram size supported
;            DE = Maximum outgoing datagram size supported
;        When information block 4 requested:
;            HL = Second set of capabilities flags
;            DE = Second set of features flags (currently unused, always zero)
TCPIP_GET_CAPAB:
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	inc	a
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	call	SETBYTE					; Save it, we are going to need it later
	out	(OUT_TX_PORT),a				; Send the parameter

	; Now wait up to 120 ticks to get response
	ld	hl,120
	call	SETCOUNTER
TCPIP_GET_CAPAB_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_ST1
TCPIP_GET_CAPAB_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	1							; Is response of our command?
	jr	nz,TCPIP_GET_CAPAB_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_GET_CAPAB_RC:	
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_RC
TCPIP_GET_CAPAB_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care
	ld	b,2
TCPIP_GET_CAPAB_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_ST2
TCPIP_GET_CAPAB_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_GET_CAPAB_ST2

	; now check if block 1, 2 or 3
	call	GETBYTE					; Get the parameter we saved at the start
	dec	a
	jp	z,TCPIP_GET_CAPAB_BLK1		; 1
	dec	a
	jp	z,TCPIP_GET_CAPAB_BLK2		; 2
	dec	a
	jp	z,TCPIP_GET_CAPAB_BLK3		; 3
	; else, only block four, same as block 1
	jp	TCPIP_GET_CAPAB_BLK1		; 1
	; Block 3 Handling, we will receive L, H, E and D
TCPIP_GET_CAPAB_BLK3:
TCPIP_GET_CAPAB_BLK3_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK3_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK3_ST1
TCPIP_GET_CAPAB_BLK3_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	l,a
TCPIP_GET_CAPAB_BLK3_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK3_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK3_ST2
TCPIP_GET_CAPAB_BLK3_ST2.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	h,a
TCPIP_GET_CAPAB_BLK3_ST3:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK3_ST3.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK3_ST3
TCPIP_GET_CAPAB_BLK3_ST3.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	e,a
TCPIP_GET_CAPAB_BLK3_ST4:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK3_ST4.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK3_ST4
TCPIP_GET_CAPAB_BLK3_ST4.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	d,a
	; done
	xor a
	ret

TCPIP_GET_CAPAB_BLK2:
	; Block 2 Handling, we will receive B, C, D, E, H, L
TCPIP_GET_CAPAB_BLK2_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK2_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK2_ST1
TCPIP_GET_CAPAB_BLK2_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	b,a
TCPIP_GET_CAPAB_BLK2_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK2_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK2_ST2
TCPIP_GET_CAPAB_BLK2_ST2.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	c,a
TCPIP_GET_CAPAB_BLK2_ST3:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK2_ST3.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK2_ST3
TCPIP_GET_CAPAB_BLK2_ST3.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	d,a
TCPIP_GET_CAPAB_BLK2_ST4:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK2_ST4.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK2_ST4
TCPIP_GET_CAPAB_BLK2_ST4.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	e,a
TCPIP_GET_CAPAB_BLK2_ST5:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK2_ST5.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK2_ST5
TCPIP_GET_CAPAB_BLK2_ST5.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	h,a
TCPIP_GET_CAPAB_BLK2_ST6:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK2_ST6.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK2_ST6
TCPIP_GET_CAPAB_BLK2_ST6.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	l,a
	; done
	xor	a
	ret

TCPIP_GET_CAPAB_BLK1:
	; Block 1 Handling, we will receive L, H, E, D and B
TCPIP_GET_CAPAB_BLK1_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK1_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK1_ST1
TCPIP_GET_CAPAB_BLK1_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	l,a
TCPIP_GET_CAPAB_BLK1_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK1_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK1_ST2
TCPIP_GET_CAPAB_BLK1_ST2.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	h,a
TCPIP_GET_CAPAB_BLK1_ST3:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK1_ST3.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK1_ST3
TCPIP_GET_CAPAB_BLK1_ST3.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	e,a
TCPIP_GET_CAPAB_BLK1_ST4:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK1_ST4.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK1_ST4
TCPIP_GET_CAPAB_BLK1_ST4.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	d,a
TCPIP_GET_CAPAB_BLK1_ST5:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_CAPAB_BLK1_ST5.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_CAPAB_BLK1_ST5
TCPIP_GET_CAPAB_BLK1_ST5.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	b,a
	; done
	xor	a
	ret

;==========================
;===  TCPIP_GET_IPINFO  ===
;==========================
;Get IP address.
;
;Input:  A = 2
;        B = Index of address to obtain:
;            1: Local IP address
;            2: Peer IP address
;            3: Subnet mask
;            4: Default gateway
;            5: Primary DNS server IP address
;            6: Secondary DNS server IP address
;Output: A = Error code
;        L.H.E.D = Requested address
TCPIP_GET_IPINFO:
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	inc	a
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out (OUT_TX_PORT),a				; Send the parameter
	
	; Now wait up to 600 ticks to get response
	ld	hl,600
	call	SETCOUNTER
TCPIP_GET_IPINFO_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_IPINFO_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_IPINFO_ST1
TCPIP_GET_IPINFO_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	2							; Is response of our command?
	jr	nz,TCPIP_GET_IPINFO_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_GET_IPINFO_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_IPINFO_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_IPINFO_RC
TCPIP_GET_IPINFO_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care, it is 4
	ld	b,2
TCPIP_GET_IPINFO_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_IPINFO_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_IPINFO_ST2
TCPIP_GET_IPINFO_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_GET_IPINFO_ST2

	; now just get the 4 bytes IP and order it in L, H, E and D
TCPIP_GET_IPINFO_IP_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_IPINFO_IP_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_IPINFO_IP_ST1
TCPIP_GET_IPINFO_IP_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	l,a
TCPIP_GET_IPINFO_IP_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_IPINFO_IP_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_IPINFO_IP_ST2
TCPIP_GET_IPINFO_IP_ST2.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	h,a
TCPIP_GET_IPINFO_IP_ST3:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_IPINFO_IP_ST3.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_IPINFO_IP_ST3
TCPIP_GET_IPINFO_IP_ST3.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	e,a
TCPIP_GET_IPINFO_IP_ST4:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_GET_IPINFO_IP_ST4.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_GET_IPINFO_IP_ST4
TCPIP_GET_IPINFO_IP_ST4.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	d,a
	; done
	xor	a
	ret

;=========================
;===  TCPIP_NET_STATE  ===
;=========================
;Get network state.
;
;Input:  A = 3
;Output: A = Error code
;        B = Current network state:
;            0: Closed
;            1: Opening
;            2: Open
;            3: Closing
;            255: Unknown
TCPIP_NET_STATE:
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	out	(OUT_TX_PORT),a				; Send the command size lsb

	; Now wait up to 720 ticks to get response
	ld	hl,720
	call	SETCOUNTER
TCPIP_NET_STATE_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_NET_STATE_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_NET_STATE_ST1
TCPIP_NET_STATE_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	3							; Is response of our command?
	jr	nz,TCPIP_NET_STATE_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_NET_STATE_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_NET_STATE_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_NET_STATE_RC
TCPIP_NET_STATE_RC.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care, it is 1
	ld	b,2
TCPIP_NET_STATE_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_NET_STATE_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_NET_STATE_ST2
TCPIP_NET_STATE_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_NET_STATE_ST2

	; now just get the 1 byte (NET STATE) IP and place it in B
TCPIP_NET_STATE_NS_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_NET_STATE_NS_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_NET_STATE_NS_ST1
TCPIP_NET_STATE_NS_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	b,a
	; done
	xor	a
	ret

;=====================
;===  TCPIP_DNS_Q  ===
;=====================
;Start a host name resolution query.
;
;Input:  A  = 6
;        HL = Address of the host name to be resolved, zero terminated
;        B  = Flags, when set to 1 they instruct the resolver to:
;             bit 0: Only abort the query currently in progress, if there is any
;                    (other flags and registers are then ignored)
;             bit 1: Assume that the passed name is an IP address,
;                    and return an error if this is not true
;             bit 2: If there is a query in progress already,
;                    do NOT abort it and return an error instead
;Output:  A = Error code
;         B = 0 if a query to a DNS server is in progress
;             1 if the name represented an IP address
;             2 if the name could be resolved locally
;         L.H.E.D = Resolved IP address
;                   (only if no error occurred and B=1 or 2 is returned)
;RAM Buffer to store names to be resolved (and used also to translate IPs from ASCII to 32bits number)
;Will store the result of the last DNS query
TCPIP_DNS_Q:
	push	hl						; Save HL
	xor	a
	ld	e,a
	ld	d,a							; Zero DE
TCPIP_DNS_Q_SIZE_LOOP:
	ld	a,(hl)						; so let's check the size of dns data
	or	a							; it is zero terminated
	jr	z,TCPIP_DNS_Q_SEND			; if zero, end of string
	inc	de							; ok, not zero, one more char
	inc	hl							; next
	jp	TCPIP_DNS_Q_SIZE_LOOP		; jp is a tad bit faster and we are not worried about code size
TCPIP_DNS_Q_SEND:
	; Here we send the query and wait the result
	inc	de							; add 1, we will send flag first
	ld	a,206						; DNS_Q_NEW
	out	(OUT_TX_PORT),a				; Send the command
	ld	a,d
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,e
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the flag byte

	; now otir of DNS/DNS BUFFER DATA SIZE
	ld	c,OUT_TX_PORT				; our data TX port
	pop	hl							; string to try to resolve
	dec	de							; we are sending just data addressed by HL, so revert count
	ld	a,d
	or	e							; if de zero, no string, wrong parameters, but let the ESP answer
	jp	z,TCPIP_DNS_Q_WAIT_RSP
	xor	a
	; Fast 16 bit variable size loop by GRAUW
	ld	b,e
	dec	de
	inc	d
TCPIP_DNS_Q_SENDLP:
	; send it
	outi
	jp	nz,TCPIP_DNS_Q_SENDLP
	dec	d
	jp	nz,TCPIP_DNS_Q_SENDLP
TCPIP_DNS_Q_WAIT_RSP:
	; Now wait up to 900 ticks (15s@60Hz) to get response
	ld	hl,900
	call	SETCOUNTER
TCPIP_DNSQ_SEND_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a ;if nz has data
	jr	nz,TCPIP_DNSQ_SEND_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_DNSQ_SEND_ST1
TCPIP_DNSQ_SEND_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	206							; Is response of our command?
	jr	nz,TCPIP_DNSQ_SEND_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_DNSQ_SEND_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_DNSQ_SEND_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_DNSQ_SEND_RC
TCPIP_DNSQ_SEND_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ld	b,0							; say in progress as there is no failure status
	ret	nz							; if not, done, ERROR won't return data

	; next two bytes are return code and size bytes, don't care, it is 4, resolved IP
	ld	b,2
TCPIP_DNSQ_SEND_RC_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_DNSQ_SEND_RC_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_DNSQ_SEND_RC_ST2
TCPIP_DNSQ_SEND_RC_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_DNSQ_SEND_RC_ST2

	; now just get the 4 bytes IP and place it in L H E D
TCPIP_DNSQ_IP_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_DNSQ_IP_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_DNSQ_IP_ST1
TCPIP_DNSQ_IP_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	l,a
TCPIP_DNSQ_IP_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_DNSQ_IP_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_DNSQ_IP_ST2
TCPIP_DNSQ_IP_ST2.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	h,a
TCPIP_DNSQ_IP_ST3:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_DNSQ_IP_ST3.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_DNSQ_IP_ST3
TCPIP_DNSQ_IP_ST3.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	e,a
TCPIP_DNSQ_IP_ST4:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_DNSQ_IP_ST4.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_DNSQ_IP_ST4
TCPIP_DNSQ_IP_ST4.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	d,a
	; done
	ld	a,1
	call	SETDNSREADY				; DNS done
	call	SETDNSRESULT			; DNS RESULT
	ld	b,2
	xor	a
	ret

;=====================
;===  TCPIP_DNS_S  ===
;=====================
;Obtains the host name resolution process state and result.
;
;Input:  A = 7
;        B = Flags, when set to 1 they instruct the resolver to:
;            bit 0: Clear any existing result or error condition after the execution
;                   (except if there is a query in progress)
;Output: A = Error code
;        B = DNS error code (when error is ERR_DNS)
;        B = Current query status (when error is ERR_OK):
;            0: There is no query in progress, nor any result nor error code available
;            1: There is a query in progress
;            2: Query is complete
;        C = Current query sub status (when error is ERR_OK and B=1):
;            0: Unknown
;            1: Querying the primary DNS server
;            2: Querying the secondary DNS server
;            3: Querying another DNS server
;        C = Resolution process type (when error is ERR_OK and B=2):
;            0: The name was obtained by querying a DNS server
;            1: The name was a direct representation of an IP address
;            2: The name was resolved locally
;       L.H.E.D = Resolved IP address (when error is ERR_OK and B=2)
TCPIP_DNS_S:
	;--- Is there a result?
	call	GETDNSREADY				; DNS done?
	or	a
	jr	z,TCPIP_DNS_S_NORESULT		; No DNS result
	;--- Ok, we have a result, is it success?
	dec a
	jr	z,TCPIP_DNS_S_HASRESULT		; If it is 1, it was not an error
	;--- Shoot, there is an error....
	;--- And sure thing, ESP do not tell us details, it is always failure :-P
	bit	0,b							;--- clear error after this?	
	jr	z,TCP_IP_DNS_S_NOCLR
	;--- Clear
	ld b,0							;--- Like I've said, no details
	xor	a
	call	SETDNSREADY				; DNS not done
	ld	a,ERR_DNS;
	ret
TCP_IP_DNS_S_NOCLR:
	;--- Don't clear
	ld	a,ERR_DNS
	ld	b,0							;--- Like I've said, no details
	ret
	;--- There is a result available...
TCPIP_DNS_S_HASRESULT:
	;--- Copy the result
	call	GETDNSRESULT
	xor	a
	bit	0,b							;--- clear result after this?
	jr	z,TCP_IP_DNS_S_RES_NOCLR	;--- no, just return
	;--- Yes, clear
	call	SETDNSREADY				; DNS not done
TCP_IP_DNS_S_RES_NOCLR:
	ld	b,2
	ret

TCPIP_DNS_S_NORESULT:
	xor	a							;--- OK no query in progress, no result, means nothing in progress
	ld	b,0							;--- No query in progress
	ret	

;========================
;===  TCPIP_UDP_OPEN  ===
;========================
;Open an UDP connection.
;
;Input:  A  = 8
;        HL = Local port number (#FFFF=random)
;        B  = Intended connection lifetime:
;             0: Transient
;             1: Resident
;Output: A = Error code
;        B = Connection number
TCPIP_UDP_OPEN:
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,3
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,l
	out	(OUT_TX_PORT),a				; Send the port LSB
	ld	a,h
	out	(OUT_TX_PORT),a				; Send the port MSB
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the connection transient/resident

	; Now wait up to 180 ticks to get response
	ld	hl,180
	call	SETCOUNTER
TCPIP_UDP_OPEN_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_OPEN_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_OPEN_ST1
TCPIP_UDP_OPEN_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	8							; Is response of our command?
	jr	nz,TCPIP_UDP_OPEN_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_UDP_OPEN_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_OPEN_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_OPEN_RC
TCPIP_UDP_OPEN_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care, it is 1, conn #
	ld	b,2
TCPIP_UDP_OPEN_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_OPEN_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_OPEN_ST2
TCPIP_UDP_OPEN_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_UDP_OPEN_ST2

	; now just get the 1 byte, conn#, should go to B
TCPIP_UDP_OPEN_CONN_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							;if nz has data
	jr	nz,TCPIP_UDP_OPEN_CONN_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_OPEN_CONN_ST1
TCPIP_UDP_OPEN_CONN_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	b,a
	; done
	xor	a
	ret

;=========================
;===  TCPIP_UDP_CLOSE  ===
;=========================
;Close a UDP connection.
;
;Input:  A = 9
;        B = Connection number
;            0 to close all open transient UDP connections
;Output: A = Error code
TCPIP_UDP_CLOSE:
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,1
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the connection #
	; Now wait up to 180 ticks to get response
	ld	hl,180
	call	SETCOUNTER
TCPIP_UDP_CLOSE_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_CLOSE_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_CLOSE_ST1
TCPIP_UDP_CLOSE_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	9							; Is response of our command?
	jr	nz,TCPIP_UDP_CLOSE_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_UDP_CLOSE_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_CLOSE_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_CLOSE_RC
TCPIP_UDP_CLOSE_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care, it is 1, conn #
	ld	b,2
TCPIP_UDP_CLOSE_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_CLOSE_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_CLOSE_ST2
TCPIP_UDP_CLOSE_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_UDP_CLOSE_ST2

	; done, no return data other than return code
	xor	a
	ret

;=========================
;===  TCPIP_UDP_STATE  ===
;=========================
;Get the state of a UDP connection.
;
;Input:  A = 10
;        B = Connection number
;Output: A  = Error code
;        HL = Local port number
;        B  = Number of pending incoming datagrams
;        DE = Size of oldest pending incoming datagram (data part only)
TCPIP_UDP_STATE:
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	inc	a
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the parameter

	; Now wait up to 60 ticks to get response
	ld	hl,60
	call	SETCOUNTER
TCPIP_UDP_STATE_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_STATE_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_STATE_ST1
TCPIP_UDP_STATE_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	10							; Is response of our command?
	jr	nz,TCPIP_UDP_STATE_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_UDP_STATE_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_STATE_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_STATE_RC
TCPIP_UDP_STATE_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care, it is 5
	ld	b,2
TCPIP_UDP_STATE_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_STATE_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_STATE_ST2
TCPIP_UDP_STATE_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_UDP_STATE_ST2

	; now just get the 5 bytes (Port LSB then MSB, # of packets, packet size LSB then MSB) and order it in L, H, B, E and D
TCPIP_UDP_STATE_RESP_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_STATE_RESP_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_STATE_RESP_ST1
TCPIP_UDP_STATE_RESP_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	l,a
TCPIP_UDP_STATE_RESP_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_STATE_RESP_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_STATE_RESP_ST2
TCPIP_UDP_STATE_RESP_ST2.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	h,a
TCPIP_UDP_STATE_RESP_ST3:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_STATE_RESP_ST3.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_STATE_RESP_ST3
TCPIP_UDP_STATE_RESP_ST3.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	b,a
TCPIP_UDP_STATE_RESP_ST4:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_STATE_RESP_ST4.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_STATE_RESP_ST4
TCPIP_UDP_STATE_RESP_ST4.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	e,a
TCPIP_UDP_STATE_RESP_ST5:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_STATE_RESP_ST5.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_STATE_RESP_ST5
TCPIP_UDP_STATE_RESP_ST5.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	d,a
	; done
	xor	a
	ret

;========================
;===  TCPIP_UDP_SEND  ===
;========================
;Send an UDP datagram.
;
;Input:  A = 11
;        B = Connection number
;        HL = Address of datagram data
;        DE = Address of parameters block
;Output: A = Error code
;
;Parameters block:
;
;    +0 (4): Destination IP address
;    +4 (2): Destination port
;    +6 (2): Data length
TCPIP_UDP_SEND:
	push	hl
	push	de
	out	(OUT_TX_PORT),a				; Send the command
	; prepare new data size, adding our 7 bytes overhead
	ld	ixh,d
	ld	ixl,e
	ld	de,7
	ld	l,(ix+6)
	ld	h,(ix+7)
	add	hl,de
	ld	a,h
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,l
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the connection #
	pop	de
	pop	hl
	ld	a,(de)
	out	(OUT_TX_PORT),a				; Send IP byte 1
	inc	de
	ld	a,(de)
	out	(OUT_TX_PORT),a				; Send IP byte 2
	inc	de
	ld	a,(de)
	out	(OUT_TX_PORT),a				; Send IP byte 3
	inc	de
	ld	a,(de)
	out	(OUT_TX_PORT),a				; Send IP byte 4
	inc	de
	ld	a,(de)
	out	(OUT_TX_PORT),a				; Send Port LSB
	inc	de
	ld	a,(de)
	out	(OUT_TX_PORT),a				; Send Port MSB
	; now oti the data starting at hl, size is in next DE position
	inc	de
	ld	a,(de)
	ld	b,a							; save lsb in b
	inc	de
	ld	a,(de)						; msb
	ld	d,a							; put in D, there is no ld d,(de)
	ld	e,b							; lsb
	; Grauw Optimized 16 bit loop, handy for us, mostly since we can use outi :-D
	;ld	b,e							; Number of loops originaly in DE, not needed, b already has e
	dec	de
	inc	d
	ld	c,OUT_TX_PORT
TCPIP_UDP_SEND_R:
	otir							; Send until B is 0
	dec	d							; decrement secondary counter
	jr	nz,TCPIP_UDP_SEND_R			; If still have another round, do it

	; Now wait up to 600 ticks to get response
	ld	hl,600
	call	SETCOUNTER
TCPIP_UDP_SEND_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_SEND_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_SEND_ST1
TCPIP_UDP_SEND_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	11							; Is response of our command?
	jr	nz,TCPIP_UDP_SEND_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_UDP_SEND_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_SEND_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_SEND_RC
TCPIP_UDP_SEND_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care, it is 0
	ld	b,2
TCPIP_UDP_SEND_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_SEND_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_UDP_SEND_ST2
TCPIP_UDP_SEND_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_UDP_SEND_ST2

	; done, no return data other than return code
	xor	a
	ret

;=======================
;===  TCPIP_UDP_RCV  ===
;=======================
;Retrieve an incoming UDP datagram.
;
;Input:  A = 12
;        B = Connection number
;        HL = Address for datagram data
;        DE = Maximum data size to retrieve
;Output: A = Error code
;        L.H.E.D = Source IP address
;        IX = Source port
;        BC = Actual received data size

; Customized TIME OUT routine: If time out receiving data, retry as received data 
; won't be re-sent as host is unaware of this
TCPIP_UDP_RCV_CHECK_TIME_OUT:
	; Save registers other than AF
	push bc
	push de
	push hl
	call	GETCOUNTER
	ld	a,l
	or	h
	; Restore registers, we are returning
	pop	hl
	pop	de
	pop	bc
	ret	nz
	; Ok, timeout...
	pop	af							; Get return address of who called this out of the stack, we will return from the function or re-start
TCPIP_TCP_UDP_RETRY_QRCV:
	call	GETBYTE
	or	a
	jr	z,TCPIP_UDP_RCV_CHECK_TIME_OUT.NORXRETRY
	; Ok, so let's ask ESP to re-send the data and retry receiving it
	dec	a
	call	SETBYTE					; we are retrying it
	ld	a,'r'						; retry transmission command
	out	(OUT_TX_PORT),a
	jp	TCPIP_UDP_RCV.RXRETRY		; and retry it
TCPIP_UDP_RCV_CHECK_TIME_OUT.NORXRETRY:
	ld	a,ERR_INV_OPER
	ret								; and return the function itself

TCPIP_UDP_RCV:
	call	SETWORD					; Save for later the datagram address
	ld	a,12
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,3
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the connection #
	ld	a,e
	out	(OUT_TX_PORT),a				; Send MAX rcv size LSB
	ld	a,d
	out	(OUT_TX_PORT),a				; Send MAX rcv size MSB
	ld	a,3
	call	SETBYTE					; Ok, retry up to three times
TCPIP_UDP_RCV.RXRETRY:
	; Now wait up to 600 ticks to get response
	ld	hl,600
	call	SETCOUNTER
TCPIP_UDP_RCV_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_RCV_ST1.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_ST1
TCPIP_UDP_RCV_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	12							; Is response of our command?
	jr	nz,TCPIP_UDP_RCV_ST1
	; At this point, all data is being buffered, so 30 ticks, half second, is more than enough time-out
	di
	ld	hl,30
	call	SETCOUNTER
	ei
	; now get return code, if return code other than 0, it is finished
TCPIP_UDP_RCV_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_RCV_RC.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_RC
TCPIP_UDP_RCV_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done
	; next two bytes are return code and size bytes, save it to BC
TCPIP_UDP_RCV_ST2A:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_RCV_ST2A.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_ST2A
TCPIP_UDP_RCV_ST2A.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	ld	h,a
TCPIP_UDP_RCV_ST2B:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_RCV_ST2B.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_ST2B
TCPIP_UDP_RCV_ST2B.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	ld	l,a
	ld	bc,6
	; subtract 6 (IP and PORT)
	xor	a							; zero carry
	sbc	hl,bc
	ld	c,l
	ld	b,h							; BC has effective received data size
	; now just get the 4 bytes IP and place it in L H E D
TCPIP_UDP_RCV_IP_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_RCV_IP_ST1.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_IP_ST1
TCPIP_UDP_RCV_IP_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	l,a
TCPIP_UDP_RCV_IP_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_RCV_IP_ST2.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_IP_ST2
TCPIP_UDP_RCV_IP_ST2.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	h,a
TCPIP_UDP_RCV_IP_ST3:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_RCV_IP_ST3.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_IP_ST3
TCPIP_UDP_RCV_IP_ST3.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	e,a
TCPIP_UDP_RCV_IP_ST4:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_RCV_IP_ST4.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_IP_ST4
TCPIP_UDP_RCV_IP_ST4.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	d,a
	; now get the 2 bytes port and place in IXL and IXH
TCPIP_UDP_RCV_PORT_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_RCV_PORT_ST1.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_PORT_ST1
TCPIP_UDP_RCV_PORT_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	ixl,a
TCPIP_UDP_RCV_PORT_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_UDP_RCV_PORT_ST2.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_PORT_ST2
TCPIP_UDP_RCV_PORT_ST2.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	ixh,a

	; save the received data in memory
	call	REGBACKUP				; Save the data received so far, registers will change
	; will start moving at RCV_ADDRESS that was stored in our WORD
	call	GETWORD
	; size goes to DE
	ld	d,b
	ld	e,c
	; Grauw Optimized 16 bit loop, handy for us, mostly since we can use ini :-D
	ld	b,e							; Number of loops originaly in DE
	dec	de
	inc	d
	ld	c,IN_DATA_PORT
	in	a,(IN_STS_PORT)
	bit	3,a							; Quick Receive Supported?
	jr	z,TCPIP_UDP_RCV_R_NSF		; If not, go to the old, slower route
	; Otherwise, let's speed it up baby!
TCPIP_UDP_RCV_R:
	inir
	dec	d
	jr	nz,TCPIP_UDP_RCV_R
	in	a,(IN_STS_PORT)
	bit	4,a							; Buffer underrun?
	jp	nz,TCPIP_TCP_UDP_RETRY_QRCV	; If yes, retry
	; Otherwise, done
	; done, restore return data in DE BC and HL 
	call	REGRESTORE
	xor	a
	ret
	; Slower route if Interface doesn't implement quick receive
TCPIP_UDP_RCV_R_NSF:
	in	a,(IN_STS_PORT)
	bit	0,a							; Do we have data to read?
	jr	nz,TCPIP_UDP_RCV_R_NSF.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_R_NSF
TCPIP_UDP_RCV_R_NSF.1:
	ini
	jr	nz,TCPIP_UDP_RCV_R_NSF			; We do not use INIR because we don't know if there is more data, avoiding geting a junk 0xFF
	dec	d
	jr	nz,TCPIP_UDP_RCV_R_NSF
	; done, restore return data in DE BC and HL 
	call	REGRESTORE
	xor	a
	ret

;========================
;===  TCPIP_TCP_OPEN  ===
;========================
;Open a TCP connection.
;
;Input:  A  = 13
;        HL = Address of parameters block
;Output: A = Error code
;        B = Connection number
;		 C = Connection not open reason (mostly for TLS)
;
;Parameters block format:
;
;+0 (4): Remote IP address (0.0.0.0 for unspecified remote socket)
;+4 (2): Remote port (ignored if unspecified remote socket)
;+6 (2): Local port, 0FFFFh for a random value
;+8 (2): Suggestion for user timeout value
;+10 (1): Flags:
;         bit 0: Set for passive connection
;         bit 1: Set for resident connection	
;         bit 2: Set for TLS connection	
;         bit 3: Set for TLS connection validating host certificate
;+11 (2): If 0000 no host name validation, otherwise the hostname string address (zero terminated)
;TCP_OPEN_IP1				(ix+0)
;TCP_OPEN_IP2				(ix+1)
;TCP_OPEN_IP3				(ix+2)
;TCP_OPEN_IP4				(ix+3)
;TCP_OPEN_RP				(ix+4)
;TCP_OPEN_LP				(ix+6)
;TCP_OPEN_TO				(ix+8)
;TCP_OPEN_CMD_FLAGS			(ix+10)
;TCP_OPEN_CMD_HOST_LSB		(ix+11)
;TCP_OPEN_CMD_HOST_MSB		(ix+12)

; When no connection, let's get the reason and put in register C, as agreed
; with Nestor this will be the way to go in the next UNAPI revision
TCPIP_TCP_OPEN_ERROR:
	; next two bytes are return code and size bytes, don't care, it is 1, conn close reason
	ld	b,a							; save error in b
	ld	c,2
TCPIP_TCP_OPEN_ERROR2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_OPEN_ERROR2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_OPEN_ERROR2
TCPIP_TCP_OPEN_ERROR2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	c
	jr	nz,TCPIP_TCP_OPEN_ERROR2
	ld	a,b
	cp	ERR_NO_CONN
	jr	nz,TCPIP_TCP_OPEN_ERROR4	; other errors do not have extra bytes as result
; now just get the 1 byte, close reason, should go to C
TCPIP_TCP_OPEN_ERROR3:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_OPEN_ERROR3.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_OPEN_ERROR3
TCPIP_TCP_OPEN_ERROR3.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	c,a
TCPIP_TCP_OPEN_ERROR4:
	; now return w/ error that is saved in b
	ld	a,b
	ld	b,0							; no connection, so 0
	ret

TCPIP_TCP_OPEN:
	push	hl						; save param block address
	ld	a,h
	ld	ixh,a
	ld	a,l
	ld	ixl,a
	; IX now has the parameters area
	; most times it will be non tls, so this is the first test case
	ld	hl,11
	call	SETWORD					; If it is non-TLS, send 11 bytes
	ld	a,(ix+10)					; TCP_OPEN_CMD_FLAGS
	bit	2,a
	jr	z,TCPIP_TCP_OPEN_NO_TLS

	; TLS, but, do we have host name?
	ld	hl,12
	call	SETWORD					; If it is TLS without host name, send 12 bytes, one zero as host name suffice
	ld	l,(ix+11)					; TCP_OPEN_CMD_HOST_LSB
	ld	a,(ix+12)					; TCP_OPEN_CMD_HOST_MSB
	or	l
	; if TLS and next two bytes are 00 no host to check
	jr	z,TCPIP_TCP_OPEN_NO_CHECKHOST
	; we are here, host to check
	ld	h,(ix+12)					; TCP_OPEN_CMD_HOST_MSB
	pop	de							; Retrieve parameters address
	push	hl						; Save host name address
	push	de						; Save Parameters address (so it is in the order we are going to need)
	; let's check how many bytes there are
	ld	de,11						; Start with 11, all params except host name
TCPIP_TCP_OPEN_CHECK_HOSTOF:
	ld	a,(hl)
	inc	de							; Not zero, so increase size count
	inc	hl							; And next hostname byte
	or	a							; If zero, hostname terminated
	; Loop until terminator (0) is found
	jp	nz,TCPIP_TCP_OPEN_CHECK_HOSTOF
	
TCPIP_TCP_OPEN_HOSTNAME_SENDCMDWITHHOSTNAME:
	; Ok, so, DE has the full hostname size, let's start sending from here
	ld	a,13						; Function TCP OPEN
	out	(OUT_TX_PORT),a				; Send the command
	ld	a,d
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,e
	out	(OUT_TX_PORT),a				; Send the command size lsb
	pop	hl							; Restore the memory address for the parameters
	; First send the 11 bytes parameters
	ld	c,OUT_TX_PORT
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi							; Unrolled outi is a bit faster :)
	ex	de,hl						; Size in HL
	ld	de,11
	or	a							; zero flag
	sbc	hl,de
	ex de,hl						; and adjusted size back in de
	pop	hl							; Restore the memory address for hostname
; Grauw Optimized 16 bit loop, handy for us, mostly since we can use outi :-D
	ld	b,e							; Number of loops originaly in DE
	dec	de
	inc	d
	ld	c,OUT_TX_PORT
TCPIP_TCP_OPEN_SENDHOSTNAME:
	outi
	jr	nz,TCPIP_TCP_OPEN_SENDHOSTNAME
	dec	d
	jr	nz,TCPIP_TCP_OPEN_SENDHOSTNAME
	jp	TCPIP_TCP_OPEN_WAIT_RESPONSE

TCPIP_TCP_OPEN_NO_TLS:
TCPIP_TCP_OPEN_NO_CHECKHOST:
	ld	a,13						; Function TCP OPEN
	out	(OUT_TX_PORT),a				; Send the command
	call	GETWORD
	ld	a,h
	ld	d,a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,l
	ld	e,a
	out	(OUT_TX_PORT),a				; Send the command size lsb

	ld	c,OUT_TX_PORT
	pop	hl							; Restore the memory address for the parameters
; Grauw Optimized 16 bit loop, handy for us, mostly since we can use outi :-D
	ld	b,e							; Number of loops originaly in DE
	dec	de
	inc	d
	ld	c,OUT_TX_PORT
TCPIP_TCP_OPEN_R:
	outi
	jr	nz,TCPIP_TCP_OPEN_R
	dec	d
	jr	nz,TCPIP_TCP_OPEN_R

TCPIP_TCP_OPEN_WAIT_RESPONSE:
	; Now wait up to 3600 (1 minute @ 60Hz) ticks to get response
	; TLS Connections might take SEVERAL seconds on TLS Handshake
	; Even more if certificates database is being indexed
	ld	hl,3600
	call	SETCOUNTER
TCPIP_TCP_OPEN_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_OPEN_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_OPEN_ST1
TCPIP_TCP_OPEN_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	13							; Is response of our command?
	jr	nz,TCPIP_TCP_OPEN_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_TCP_OPEN_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_OPEN_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_OPEN_RC
TCPIP_TCP_OPEN_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	jp	nz,TCPIP_TCP_OPEN_ERROR

	; next two bytes are size bytes, don't care, it is 1, conn #
	ld	b,2
TCPIP_TCP_OPEN_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_OPEN_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_OPEN_ST2
TCPIP_TCP_OPEN_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_TCP_OPEN_ST2

	; now just get the 1 byte, conn#, should go to B
TCPIP_TCP_OPEN_CONN_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_OPEN_CONN_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_OPEN_CONN_ST1
TCPIP_TCP_OPEN_CONN_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	b,a
	; done
	xor	a
	ret

;=========================
;===  TCPIP_TCP_CLOSE  ===
;=========================
;Close a TCP connection.
;
;Input:  A = 14
;        B = Connection number
;            0 to close all open transient UDP connections
;Output: A = Error code
TCPIP_TCP_CLOSE:
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,1
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the connection #
	; Now wait up to 180 ticks to get response
	ld	hl,180
	call	SETCOUNTER
TCPIP_TCP_CLOSE_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_CLOSE_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_CLOSE_ST1
TCPIP_TCP_CLOSE_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	14							; Is response of our command?
	jr	nz,TCPIP_TCP_CLOSE_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_TCP_CLOSE_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_CLOSE_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_CLOSE_RC
TCPIP_TCP_CLOSE_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care, it is 0
	ld	b,2
TCPIP_TCP_CLOSE_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_CLOSE_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_CLOSE_ST2
TCPIP_TCP_CLOSE_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_TCP_CLOSE_ST2

	; done, no return data other than return code
	xor a
	ret

;=========================
;===  TCPIP_TCP_ABORT  ===
;=========================
;Abort a TCP connection.
;Input:  A  = 15
;        B = Connection number
;            0 to abort all open transient TCP connections
;Output: A = Error code

TCPIP_TCP_ABORT:
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,1
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the connection #
	; Now wait up to 180 ticks to get response
	ld	hl,180
	call	SETCOUNTER
TCPIP_TCP_ABORT_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_ABORT_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_ABORT_ST1
TCPIP_TCP_ABORT_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	15							; Is response of our command?
	jr	nz,TCPIP_TCP_ABORT_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_TCP_ABORT_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_ABORT_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_ABORT_RC
TCPIP_TCP_ABORT_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care, it is 0
	ld	b,2
TCPIP_TCP_ABORT_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_ABORT_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_ABORT_ST2
TCPIP_TCP_ABORT_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_TCP_ABORT_ST2

	; done, no return data other than return code
	xor	a
	ret

;=========================
;===  TCPIP_TCP_STATE  ===
;=========================
;Get the state of a TCP connection.
;
;Input:  A = 16
;        B = Connection number
;        HL = Pointer in TPA for connection information block
;             (0 if not needed)
;Output: A  = Error code
;        B  = Connection state
;        C  = Close reason (only if ERR_NO_CONN is returned)
;        HL = Number of total available incoming bytes
;        DE = Number of urgent available incoming bytes
;        IX = Available free space in the output buffer
;             (0FFFFh = infinite)
;
;Connection information block consists of:
;
;    +0 (4): Remote IP address
;    +4 (2): Remote port
;    +6 (2): Local port
TCPIP_TCP_STATE_ERROR:
	; next two bytes are size bytes, don't care
	ld	b,a							; save error in b
	ld	c,2
TCPIP_TCP_STATE_ERROR2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_ERROR2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_ERROR2
TCPIP_TCP_STATE_ERROR2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	c
	jr	nz,TCPIP_TCP_STATE_ERROR2

	; now return w/ error that is saved in b
	ld	a,b
	ld	b,0
	ld	c,7
	ld	hl,0
	ld	de,0
	ld	ix,0
	ret

TCPIP_TCP_STATE:
	call	SETWORD					; Save HL pointer in our memory
	ld	a,h
	or	l							; Information block required?
	ld	a,0							; do not want to mess with flags, let's say no need
	jr	z,TCPIP_TCP_STATE_NOINFOBLOCK
	inc	a							; otherwise there is a need
TCPIP_TCP_STATE_NOINFOBLOCK:
	call	SETBYTE					; Save for later
	ld	a,16						; Our command
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	inc	a
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the parameter

	; Now wait up to 180 ticks to get response
	ld	hl,180
	call	SETCOUNTER
TCPIP_TCP_STATE_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_ST1
TCPIP_TCP_STATE_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	16							; Is response of our command?
	jr	nz,TCPIP_TCP_STATE_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_TCP_STATE_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_RC
TCPIP_TCP_STATE_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	jr	nz,TCPIP_TCP_STATE_ERROR	; if not, done

	; next two bytes are return code and size bytes, don't care, it is 16
	ld	b,2
TCPIP_TCP_STATE_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_ST2
TCPIP_TCP_STATE_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_TCP_STATE_ST2

	; now just get the 16 bytes (Port LSB then MSB, # of packets, packet size LSB then MSB) and order it in C, B, L, H, E, D, IXL and IXH. 
	; Remaining 8 bytes go to TCP_STATE_INFORMATION_BLOCK if its value is other than 0
TCPIP_TCP_STATE_RESP_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_RESP_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_RESP_ST1
TCPIP_TCP_STATE_RESP_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	c,a
TCPIP_TCP_STATE_RESP_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_RESP_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_RESP_ST2
TCPIP_TCP_STATE_RESP_ST2.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	b,a
TCPIP_TCP_STATE_RESP_ST3:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_RESP_ST3.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_RESP_ST3
TCPIP_TCP_STATE_RESP_ST3.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	l,a
TCPIP_TCP_STATE_RESP_ST4:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_RESP_ST4.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_RESP_ST4
TCPIP_TCP_STATE_RESP_ST4.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	h,a
TCPIP_TCP_STATE_RESP_ST5:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_RESP_ST5.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_RESP_ST5
TCPIP_TCP_STATE_RESP_ST5.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	e,a
TCPIP_TCP_STATE_RESP_ST6:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_RESP_ST6.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_RESP_ST6
TCPIP_TCP_STATE_RESP_ST6.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	d,a
TCPIP_TCP_STATE_RESP_ST7:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_RESP_ST7.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_RESP_ST7
TCPIP_TCP_STATE_RESP_ST7.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	ixl,a
TCPIP_TCP_STATE_RESP_ST8:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_RESP_ST8.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_RESP_ST8
TCPIP_TCP_STATE_RESP_ST8.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	ixh,a

; Check if there is an information block
	call	BCBACKUP				; Save BC, we gonna use it
	ld	b,8							; prepare in advance for 8 bytes being transferred
	call	GETBYTE					; Let's check if we have flagged need for INFOBLOCK
	or	a
	jr	nz,TCPIP_TCP_STATE_GET_IBLOCK

; If here, just discard Information Block (next 8 bytes)
TCPIP_TCP_STATE_DISCARD_IBLOCK:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_DISCARD_IBLOCK.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_DISCARD_IBLOCK
TCPIP_TCP_STATE_DISCARD_IBLOCK.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_TCP_STATE_DISCARD_IBLOCK
	; done
	call	BCRESTORE
	xor	a
	ret

; If here, save Information Block (next 8 bytes)
TCPIP_TCP_STATE_GET_IBLOCK:
	call	HLBACKUP				; Save HL
	call	GETWORD					; Restore address for IB on HL
TCPIP_TCP_STATE_SAVE_IBLOCK:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_STATE_SAVE_IBLOCK.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_STATE_SAVE_IBLOCK
TCPIP_TCP_STATE_SAVE_IBLOCK.1:
	; nz, save
	in	a,(IN_DATA_PORT)
	ld	(hl),a
	inc	hl
	dec	b
	jr	nz,TCPIP_TCP_STATE_SAVE_IBLOCK
	; done
	call	HLRESTORE
	call	BCRESTORE
	xor	a
	ret

;========================
;===  TCPIP_TCP_SEND  ===
;========================
;Send data to a TCP connection.
;
;Input:  A  = 17
;        B  = Connection number
;        DE = Address of the data to be sent
;        HL = Length of the data to be sent
;        C  = Flags:
;             bit 0: Send the data PUSHed
;             bit 1: The data is urgent
;Output: A = Error code	
TCPIP_TCP_SEND_ERROR:
	; next two bytes are size bytes, don't care
	ld	b,a							; save error in b
	ld	c,2
TCPIP_TCP_SEND_ERROR2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_SEND_ERROR2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_SEND_ERROR2
TCPIP_TCP_SEND_ERROR2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	c
	jr	nz,TCPIP_TCP_SEND_ERROR2
	; now return w/ error that is saved in b
	ld	a,b
	ret

TCPIP_TCP_SEND:
	push	hl
	push	de
	out	(OUT_TX_PORT),a				; Send the command
	; prepare new data size, adding our 2 bytes overhead
	ld	de,2
	add	hl,de
	ld	a,h
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,l
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b 
	out	(OUT_TX_PORT),a				; Send the connection #
	ld	a,c
	out	(OUT_TX_PORT),a				; Send the connection flags
	pop	hl
	pop	de
	; now oti the data starting at hl, size is in DE
	; Grauw Optimized 16 bit loop, handy for us, mostly since we can use outi :-D
	ld	b,e							;Number of loops originaly in DE
	dec	de
	inc	d
	ld	c,OUT_TX_PORT
TCPIP_TCP_SEND_R:
	outi
	jr	nz,TCPIP_TCP_SEND_R
	dec	d
	jr	nz,TCPIP_TCP_SEND_R

	; Now wait up to 600 ticks to get response
	ld	hl,600
	call	SETCOUNTER
TCPIP_TCP_SEND_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_SEND_R.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_SEND_ST1
TCPIP_TCP_SEND_R.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	17							; Is response of our command?
	jr	nz,TCPIP_TCP_SEND_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_TCP_SEND_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_SEND_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_SEND_RC
TCPIP_TCP_SEND_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care, it is 0
	ld	b,2
TCPIP_TCP_SEND_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_SEND_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_TCP_SEND_ST2
TCPIP_TCP_SEND_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_TCP_SEND_ST2

	; done, no return data other than return code
	xor	a
	ret

;=======================
;===  TCPIP_TCP_RCV  ===
;=======================
;Receive data from a TCP connection.
;
;Input:   A  = 18
;         B  = Connection number
;         DE = Address for the retrieved data
;         HL = Length of the data to be obtained
;Output:  A  = Error code
;         BC = Total number of bytes that have been actually retrieved
;         HL = Number of urgent data bytes that have been retrieved
;              (placed at the beginning of the received data block)
; Save registers other than AF
TCPIP_TCP_RCV_CHECK_TIME_OUT:
	push bc
	push de
	push hl
	call	GETCOUNTER
	ld	a,l
	or	h
	; Restore registers, we are returning
	pop	hl
	pop	de
	pop	bc
	ret	nz
	; Ok, timeout...
	pop	af							; Get return address of who called this out of the stack, we will return from the function or re-start
TCPIP_TCP_RCV_RETRY_QRCV:
	call	GETBYTE
	or	a
	jr	z,TCPIP_TCP_RCV_CHECK_TIME_OUT.NORXRETRY
	; Ok, so let's ask ESP to re-send the data and retry receiving it
	dec	a
	call	SETBYTE					; we are retrying it
	ld	a,'r'						; retry transmission command
	out	(OUT_TX_PORT),a
	jp	TCPIP_TCP_RCV.RXRETRY		; and retry it
TCPIP_TCP_RCV_CHECK_TIME_OUT.NORXRETRY:
	ld	a,ERR_INV_OPER
	ret								; and return the function itself

TCPIP_TCP_RCV_RET_ERR:
	; next two bytes are size bytes, don't care
	ld	b,a							; save error in b
	ld	c,2
TCPIP_TCP_RCV_RET_ERR2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_RCV_RET_ERR2.1
	call	TCPIP_TCP_RCV_CHECK_TIME_OUT
	jr	TCPIP_TCP_RCV_RET_ERR2
TCPIP_TCP_RCV_RET_ERR2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	c
	jr	nz,TCPIP_TCP_RCV_RET_ERR2
	; now return w/ error that is saved in b
	ld	a,b
TCPIP_TCP_RCV_RET_NODATA:
	ld	hl,0
	ld	bc,0
	ret

TCPIP_TCP_RCV:
	ex	de,hl
	call	SETWORD
	ex	de,hl
	ld	a,18
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,3
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the connection #
	ld	a,l
	out	(OUT_TX_PORT),a				; Send MAX rcv size LSB
	ld	a,h
	out	(OUT_TX_PORT),a				; Send MAX rcv size MSB
	ld	a,3
	call	SETBYTE					; Ok, retry up to three times
TCPIP_TCP_RCV.RXRETRY:
	; Now wait up to 600 ticks to get response
	ld	hl,600
	call	SETCOUNTER
TCPIP_TCP_RCV_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_RCV_ST1.1
	call	TCPIP_TCP_RCV_CHECK_TIME_OUT
	jr	TCPIP_TCP_RCV_ST1
TCPIP_TCP_RCV_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp 18							; Is response of our command?
	jr	nz,TCPIP_TCP_RCV_ST1
	; At this point, all data is being buffered, so 15 ticks, quarter second, is more than enough time-out
	di
	ld	hl,30
	call	SETCOUNTER
	ei
	; now get return code, if return code other than 0, it is finished
TCPIP_TCP_RCV_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_RCV_RC.1
	call	TCPIP_TCP_RCV_CHECK_TIME_OUT
	jr	TCPIP_TCP_RCV_RC
TCPIP_TCP_RCV_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	jr	nz,TCPIP_TCP_RCV_RET_ERR	; if not, done
	; next two bytes are response size bytes (UB count two bytes, always 0, and data read), save it -2 to BC
TCPIP_TCP_RCV_ST2A:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_RCV_ST2A.1
	call	TCPIP_TCP_RCV_CHECK_TIME_OUT
	jr	TCPIP_TCP_RCV_ST2A
TCPIP_TCP_RCV_ST2A.1:
	; nz, high byte count of bytes to receive
	in	a,(IN_DATA_PORT)
	ld h,a
TCPIP_TCP_RCV_ST2B:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_RCV_ST2B.1
	call	TCPIP_TCP_RCV_CHECK_TIME_OUT
	jr	TCPIP_TCP_RCV_ST2B
TCPIP_TCP_RCV_ST2B.1:
	; nz, low byte count of bytes to receive
	in	a,(IN_DATA_PORT)
	ld	l,a
	ld	bc,2
	; subtract 2 (Urgent data count, not used)
	xor	a							; zero carry
	sbc	hl,bc
	; if it was 0, will carry
	jr	c,TCPIP_TCP_RCV_RET_NODATA
	ld	c,l
	ld	b,h							; BC has effective received data size, as well as HL

	; now just discard 2 bytes urgent data
TCPIP_TCP_RCV_UDC_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_RCV_UDC_ST1.1
	call	TCPIP_TCP_RCV_CHECK_TIME_OUT
	jr	TCPIP_TCP_RCV_UDC_ST1
TCPIP_TCP_RCV_UDC_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
TCPIP_TCP_RCV_UDC_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_RCV_UDC_ST2.1
	call	TCPIP_TCP_RCV_CHECK_TIME_OUT
	jr	TCPIP_TCP_RCV_UDC_ST2
TCPIP_TCP_RCV_UDC_ST2.1
	; nz, get it
	in	a,(IN_DATA_PORT)

	; put effective data size in de
	ex	de,hl
	; will start moving at address in stack (we've pushed the adress in WORD)
	call	GETWORD
	call	BCBACKUP				; save count (BC)

	; Grauw Optimized 16 bit loop, handy for us, mostly since we can use ini :-D
	ld	b,e							; Number of loops originaly in DE
	dec	de
	inc	d
	ld	c,IN_DATA_PORT
	in	a,(IN_STS_PORT)
	bit	3,a							; Quick Receive Supported?
	jr	z,TCPIP_TCP_RCV_R_NSF		; If not, go to the old, slower route
	; Otherwise, let's speed it up baby!
TCPIP_TCP_RCV_R:
	inir
	dec	d
	jr nz,TCPIP_TCP_RCV_R
	in	a,(IN_STS_PORT)
	bit	4,a							; Buffer underrun?
	jp	nz,TCPIP_TCP_RCV_RETRY_QRCV	; If yes, retry
	; Otherwise, done
	call	BCRESTORE				; done, restore return data in BC
	; no urgent data support
	ld	hl,0
	xor	a
	ret
TCPIP_TCP_RCV_R_NSF:
	in	a,(IN_STS_PORT)
	bit	0,a							; Do we have data to read?
	jr	nz,TCPIP_TCP_RCV_R_NSF.1
	call	TCPIP_TCP_RCV_CHECK_TIME_OUT
	jr	TCPIP_TCP_RCV_R_NSF
TCPIP_TCP_RCV_R_NSF.1:
	ini
	jr	nz,TCPIP_TCP_RCV_R_NSF
	dec	d
	jr nz,TCPIP_TCP_RCV_R_NSF
	call	BCRESTORE				; done, restore return data in BC
	; no urgent data support
	ld	hl,0
	xor	a
	ret

;=============================
;===  TCPIP_CONFIG_AUTOIP  ===
;=============================
;Enable or disable the automatic IP addresses retrieval.
;
;Input:  A = 25
;        B = 0: Get current configuration
;            1: Set configuration
;        C = Configuration to set (only if B=1):
;            bit 0: Set to automatically retrieve
;                   local IP address, subnet mask and default gateway
;            bit 1: Set to automatically retrieve DNS servers addresses
;            bits 2-7: Unused, must be zero
;Output: A = Error code
;        C = Configuration after the routine execution
;            (same format as C at input)
TCPIP_CONFIG_AUTOIP:
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,2
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the command 
	ld	a,c
	out	(OUT_TX_PORT),a				; Send the command parameter

	; Now wait up to 180 ticks to get response
	ld hl,180
	call	SETCOUNTER
TCPIP_CONFIG_AUTOIP_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_CONFIG_AUTOIP_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_CONFIG_AUTOIP_ST1
TCPIP_CONFIG_AUTOIP_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	25							; Is response of our command?
	jr	nz,TCPIP_CONFIG_AUTOIP_ST1
	; now get return code, if return code other than 0, it is finished
TCPIP_CONFIG_AUTOIP_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_CONFIG_AUTOIP_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_CONFIG_AUTOIP_RC
TCPIP_CONFIG_AUTOIP_RC.1:
	;nz, discard
	in	a,(IN_DATA_PORT)
	or	a							; 0?
	ret	nz							; if not, done

	; next two bytes are return code and size bytes, don't care, it is 1, configuration
	ld	b,2
TCPIP_CONFIG_AUTOIP_ST2:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_CONFIG_AUTOIP_ST2.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_CONFIG_AUTOIP_ST2
TCPIP_CONFIG_AUTOIP_ST2.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	dec	b
	jr	nz,TCPIP_CONFIG_AUTOIP_ST2

	; now just get the 1 byte, configuration, should go to C
TCPIP_CONFIG_AUTOIP_CONF_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_CONFIG_AUTOIP_CONF_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_CONFIG_AUTOIP_CONF_ST1
TCPIP_CONFIG_AUTOIP_CONF_ST1.1:
	; nz, get it
	in	a,(IN_DATA_PORT)
	ld	c,a
	; done
	xor	a
	ret

;=========================
;===  TCPIP_CONFIG_IP  ===
;=========================
;Manually configure an IP address.
;
;Input:  A = 26
;        B = Index of address to set:
;            1: Local IP address
;            2: Peer IP address
;            3: Subnet mask
;            4: Default gateway
;            5: Primary DNS server IP address
;            6: Secondary DNS server IP address
;        L.H.E.D = Address value
;Output: A = Error code
TCPIP_CONFIG_IP:
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,5
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the address to set
	ld	a,l
	out	(OUT_TX_PORT),a				; Send the IP first byte
	ld	a,h
	out	(OUT_TX_PORT),a				; Send the IP second byte
	ld	a,e
	out	(OUT_TX_PORT),a				; Send the IP third byte
	ld	a,d
	out	(OUT_TX_PORT),a				; Send the IP fourth byte

	; Now wait up to 180 ticks to get response
	ld	hl,180
	call	SETCOUNTER
TCPIP_CONFIG_IP_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_CONFIG_IP_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_CONFIG_IP_ST1
TCPIP_CONFIG_IP_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	26							; Is response of our command?
	jr	nz,TCPIP_CONFIG_IP_ST1
	; now get return code, and that is it
TCPIP_CONFIG_IP_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_CONFIG_IP_RC.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_CONFIG_IP_RC
TCPIP_CONFIG_IP_RC.1:
	; nz, discard
	in	a,(IN_DATA_PORT)
	ret								; done

;==========================
;===  TCPIP_CONFIG_TTL  ===
;==========================
;Get/set the value of TTL and TOS for outgoing datagrams.
;
;Input:  A = 27
;        B = 0: Get current values (just return 255 for TTL and 0 for TOS
;				as ESP do not expose or allow configurations of it)
;            1: Set values
;        D = New value for TTL (only if B=1)
;        E = New value for ToS (only if B=1)
;Output: A = Error code
;        D = Value of TTL after the routine execution
;        E = Value of ToS after the routine execution
TCPIP_CONFIG_TTL:
	ld	a,b
	and	%11111110
	or	a
	ld	a,ERR_INV_PARAM
	ret	nz
	ld	a,b
	or	a
	; Cant set, so NOT IMP 
	ld	a,ERR_NOT_IMP
	ret	nz							; if not get, not implemented
	; get, so just return D = #FF, A = OK = 0 and E = 0
	xor	a
	ld	e,0
	ld	d,#FF
	ret

;===========================
;===  TCPIP_CONFIG_PING  ===
;===========================
;Get/set the automatic PING reply flag.
;
;Input:  A = 28
;        B = 0: Get current flag value
;            1: Set flag value (ERR_NOT_IMP)
;        C = New flag value (only if B=1):
;            0: Off 
;            1: On
;Output: A = Error code
;        C = Flag value after the routine execution
TCPIP_CONFIG_PING:
	ld	a,b
	and	%11111110
	or	a
	ld	a,ERR_INV_PARAM
	ret	nz
	ld	a,b
	or	a
	; Cant set, so NOT IMP 
	ld	a,ERR_NOT_IMP
	ret	nz							; if not get, not implemented
	; get, so just return C = 1, A = OK = 0 
	xor	a
	ld	c,1
	ret

;============================
;===  Auxiliary routines  ===
;============================

;--- Get slot connected on page 1
;    Input:  -
;    Output: A = Slot number
;    Modifies: AF, HL, E, BC

GETSLT:
	in	a,(#A8)
	rrca
	rrca
	and	3
	ld	c,a							;C = Slot
	ld	b,0
	ld	hl,EXPTBL
	add	hl,bc
	ld	a,(hl)
	and	#80
	or	c
	ld	c,a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	#0C
	or	c
	bit	7,a
	ret	nz
	and	%11
	ret

;--- Get slot connected on page 1 and test if work area has been created, if not, create it
;    Input:  -
;    Output: A = Slot number
;    Modifies: AF, HL, E, BC

GETSLTT:
	in	a,(#A8)
	rrca
	rrca
	and	3
	ld	c,a							;C = Slot
	ld	b,0
	ld	hl,EXPTBL
	add	hl,bc
	ld	a,(hl)
	and	#80
	or	c
	ld	c,a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	#0C
	or	c
	bit	7,a
	jp	nz,GETSLTT1
	and	%11
GETSLTT1:
	push	af
	push	bc
	push	hl
	call	GETWRK
	ld	bc,5
	add	hl,bc
	ld	a,(hl)
	or	a
	jp	nz,GETSLTTRET
	inc	a
	ld	(hl),a
	call	HIMEM_ALLOC
GETSLTTRET:
	pop	hl
	pop	bc
	pop	af
	ret

;--- Obtain slot work area (8 bytes) on SLTWRK
;    Input:  A  = Slot number
;    Output: HL = Work area address
;    Modifies: AF, BC

GETWRK:
	ld	b,a
	rrca
	rrca
	rrca
	and	%01100000
	ld	c,a							;C = Slot * 32
	ld	a,b
	rlca
	and	%00011000					;A = Subslot * 8
	or	c
	ld	c,a
	ld	b,0
	ld	hl,SLTWRK
	add	hl,bc
	ret

;--- Obtain the address where our memory area address in high memory is stored
;    Input:  A  = Slot number
;    Output: HL = High memory area address
;    Modifies: AF, BC

GETMEMPOINTERADDR:
	ld	b,a
	rrca
	rrca
	rrca
	and	%01100000
	ld	c,a							; C = Slot * 32
	ld	a,b
	rlca
	and	%00011000					; A = Subslot * 8
	or	c
	ld	c,a
	ld	b,0
	jp	nc,GETMEM_1
	inc b
GETMEM_1:
	ld	hl,SLTWRK
	add	hl,bc
	ld	bc,5
	add	hl,bc
	ret

;--- Obtain the address where our memory area address in high memory is stored
;    Input:  A  = Slot number
;    Output: HL = High memory area address
;    Modifies: AF, BC

GETMEMPOINTER:
	call	GETMEMPOINTERADDR
	ld	c,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,c
	ret

;--- Obtain our HTIM_I driven counter value in high memory
;    Input:  none
;    Output: HL = counter value
;    Modifies: AF, HL, DE, BC

GETCOUNTER:
	call	GETSLT
	; Slot in A, now get the address of our counter
	call	GETMEMPOINTER
	; HL has the address of our memory area, counter is 5 bytes after start
	ld	de,MEMORY_COUNTER_OFFSET
	add	hl,de
	; Ok, this is where our counter is so get it
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	; DE has the counter value
	ex	de,hl						; Counter value in HL
	ret

;--- Set our HTIM_I driven counter value in high memory
;    Input:  HL = new counter value
;    Output: noone
;    Modifies: AF, HL, DE, BC

SETCOUNTER:
	push	hl						; Save parameter
	call	GETSLT
	; Slot in A, now get the address of our counter
	call	GETMEMPOINTER
	; HL has the address of our memory area, counter is 5 bytes after start
	ld	de,MEMORY_COUNTER_OFFSET
	add	hl,de
	; Ok, this is where our counter is so get it
	; HL has the address of counter
	pop	de							; Restore parameter in DE
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ret

;--- Obtain a one byte param saved in high memory
;    Input:  none
;    Output: A = param
;    Modifies: AF

GETBYTE:
	push	bc
	push	de
	push	hl
	call	GETSLT
	; Slot in A, now get the address of our counter
	call	GETMEMPOINTER
	; HL has the address of our memory area, param is 7 bytes after start
	ld	de,MEMORY_SB_VAR_OFFSET
	add	hl,de
	; Ok, this is where our param is so get it
	ld	a,(hl)
	pop	hl
	pop	de
	pop	bc
	ret

;--- Set a one byte param value in high memory
;    Input:  A = new counter value
;    Output: none
;    Modifies: AF

SETBYTE:
	push	bc
	push	de
	push	hl
	push	af						; Save parameter
	call	GETSLT
	; Slot in A, now get the address
	call	GETMEMPOINTER
	; HL has the address of our memory area, byte param is 7 bytes after start
	ld	de,MEMORY_SB_VAR_OFFSET
	add	hl,de
	; HL has the address of param
	pop	af							; Restore parameter
	ld	(hl),a
	pop	hl
	pop	de
	pop	bc
	ret

;--- Obtain a two bytes param saved in high memory
;    Input:  none
;    Output: HL = param
;    Modifies: AF, HL

GETWORD:
	push	bc
	push	de
	call	GETSLT
	; Slot in A, now get the address of our counter
	call	GETMEMPOINTER
	; HL has the address of our memory area, param is 7 bytes after start
	ld	de,MEMORY_DB_VAR_OFFSET
	add	hl,de
	; Ok, this is where our param is so get it
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl						; Return in HL
	pop	de
	pop	bc
	ret

;--- Set a two bytes param value in high memory
;    Input:  HL = new counter value
;    Output: none
;    Modifies: AF

SETWORD:
	push	bc
	push	de
	push	hl
	call	GETSLT
	; Slot in A, now get the address
	call	GETMEMPOINTER
	; HL has the address of our memory area, byte param is 7 bytes after start
	ld	de,MEMORY_DB_VAR_OFFSET
	add	hl,de
	; HL has the address of param
	pop	de							; Restore parameter in DE
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ex	de,hl						; Restore HL original value
	pop	de
	pop	bc
	ret

;--- Restores BC / DE / HL copy saved in high memory
;    Input:  none
;    Output: BC / DE / HL
;    Modifies: AF

REGRESTORE:
	call	GETSLT
	; Slot in A, now get the address of our counter
	call	GETMEMPOINTER
	; HL has the address of our memory area, param is 7 bytes after start
	ld	de,MEMORY_REGBACKUP_OFFSET
	add	hl,de
	; Ok, this is where our param is so get it
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ret

;--- Backups BC / DE /HL in high memory
;    Input:  BC / DE / HL
;    Output: none
;    Modifies: AF

REGBACKUP:
	push	hl
	push	de
	push	bc
	call	GETSLT
	; Slot in A, now get the address
	call	GETMEMPOINTER
	; HL has the address of our memory area, byte param is 7 bytes after start
	ld	de,MEMORY_REGBACKUP_OFFSET
	add	hl,de
	; HL has the address of param
	pop	bc							; Restore BC
	ld	(hl),c
	inc	hl
	ld	(hl),b
	inc	hl
	pop	de							; Restore DE
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ex (sp),hl						; backup the address and get HL value
	ld	a,l
	ex (sp),hl						; return it to the stack and get back the pointer
	ld	(hl),a						; save l
	inc	hl
	ex (sp),hl						; backup the address and get HL value
	ld	a,h
	ex (sp),hl						; return it to the stack and get back the pointer
	ld	(hl),a						; save h
	pop	hl							; Restore HL original value
	ret

;--- Restores BC copy saved in high memory
;    Input:  none
;    Output: BC 
;    Modifies: AF

BCRESTORE:
	push	hl
	push	de
	call	GETSLT
	; Slot in A, now get the address of our counter
	call	GETMEMPOINTER
	; HL has the address of our memory area, param is 7 bytes after start
	ld	de,MEMORY_BCBACKUP_OFFSET
	add	hl,de
	; Ok, this is where our param is so get it
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	pop	de
	pop	hl
	ret

;--- Backups BC in high memory
;    Input:  BC
;    Output: none
;    Modifies: AF

BCBACKUP:
	push	de
	push	hl
	push	bc
	call	GETSLT
	; Slot in A, now get the address
	call	GETMEMPOINTER
	; HL has the address of our memory area, byte param is 7 bytes after start
	ld	de,MEMORY_BCBACKUP_OFFSET
	add	hl,de
	; HL has the address of param
	pop	bc							; Restore BC
	ld	(hl),c
	inc	hl
	ld	(hl),b
	pop	hl							; Restore HL original value
	pop	de							; Restore DE
	ret

;--- Restores HL copy saved in high memory
;    Input:  none
;    Output: HL 
;    Modifies: AF

HLRESTORE:
	push	bc
	push	de
	call	GETSLT
	; Slot in A, now get the address of our counter
	call	GETMEMPOINTER
	; HL has the address of our memory area, param is 7 bytes after start
	ld	de,MEMORY_HLBACKUP_OFFSET
	add	hl,de
	; Ok, this is where our param is so get it
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	pop	de
	pop	bc
	ret

;--- Backups HL in high memory
;    Input:  HL
;    Output: none
;    Modifies: AF

HLBACKUP:
	push	de
	push	bc
	push	hl
	call	GETSLT
	; Slot in A, now get the address
	call	GETMEMPOINTER
	; HL has the address of our memory area, byte param is 7 bytes after start
	ld	de,MEMORY_HLBACKUP_OFFSET
	add	hl,de
	; HL has the address of param
	pop	de							; Restore HL in de
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ex	de,hl						; Restore HL
	pop	bc							; Restore BC
	pop	de							; Restore DE
	ret

;--- Obtain if DNS is ready saved in high memory
;    Input:  none
;    Output: A = DNS ready value
;    Modifies: AF

GETDNSREADY:
	push	bc
	push	de
	push	hl
	call	GETSLT
	; Slot in A, now get the address 
	call	GETMEMPOINTER
	; HL has the address of our memory area, DNS ready is 8 bytes after start
	ld	de,MEMORY_DNS_READY_OFFSET
	add	hl,de
	; Ok, get it
	ld	a,(hl)
	pop	hl
	pop	de
	pop	bc
	ret

;--- Set DNS redy in high memory
;    Input:  A = new value
;    Output: none
;    Modifies: AF

SETDNSREADY:
	push	bc
	push	de
	push	hl
	push	af						; Save parameter
	call	GETSLT
	; Slot in A, now get the address
	call	GETMEMPOINTER
	; HL has the address of our memory area, DNS ready is 8 bytes after start
	ld	de,MEMORY_DNS_READY_OFFSET
	add	hl,de
	; HL has the address of DNS ready
	pop	af							; Restore parameter
	ld	(hl),a
	pop	hl
	pop	de
	pop	bc
	ret

;--- Obtain DNS result saved in high memory
;    Input:  none
;    Output: HL DE = DNS result
;    Modifies: AF

GETDNSRESULT:
	push	bc
	call	GETSLT
	; Slot in A, now get the address 
	call	GETMEMPOINTER
	; HL has the address of our memory area, DNS result is 9 bytes after start
	ld	de,MEMORY_DNS_RES_OFFSET
	add	hl,de
	; Ok, get it, first bytes are hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	de						; for now, save in stack, so we can restore to HL later
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	pop	hl							; and now restore HL value from stack
	pop	bc
	ret

;--- Set DNS result in high memory
;    Input:  HL DE = new value
;    Output: none
;    Modifies: AF

SETDNSRESULT:
	push	bc
	push	de
	push	hl
	call	GETSLT
	; Slot in A, now get the address
	call	GETMEMPOINTER
	; HL has the address of our memory area, DNS result is 9 bytes after start
	ld	de,MEMORY_DNS_RES_OFFSET
	add	hl,de
	; HL has the address of DNS result
	pop	bc							; Restore parameter HL in BC
	ld	(hl),c
	inc	hl
	ld	(hl),b
	pop	de							; Restore parameter DE in DE
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	l,c
	ld	h,b							; And HL is restored
	pop	bc							; Restore BC
	ret

;--- Convert a character to upper-case if it is a lower-case letter
TOUPPER:
	cp	"a"
	ret	c
	cp	"z"+1
	ret	nc
	and	#DF
	ret

;*********************************************
;***       WAIT_RESPONSE_FROM_ESP          ***
;*** Will wait ESP to send a response,     ***
;*** discarding all data until it is found.***
;***                                       ***
;*** Inputs:                               ***
;*** HL - Expected response string         ***
;*** A - Response Size                     ***
;*** DE - TimeOut in ticks                 ***
;***                                       ***
;*** Output:                               ***
;*** A - 0 if response received 		   ***
;*** otherwise response not received and   ***
;*** timed-out.                            ***
;***                                       ***
;*** Changes HL, BC, AF, DE, IX            ***
;*********************************************
WRFE_WAIT_DATA:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	ret	nz
	dec	de
	halt
	ret

WRFE_COMPARE:
	ld	b,a
	ld	a,(hl)
	cp	b
	ret	nz
	inc	hl
	ret

WAIT_RESPONSE_FROM_ESP:
	ld	c,a							; Response size in C
	push	hl						; Save HL
	xor a
WRFE_ST1:
	ld	ixh,a						; We start at index 0

WRFE_LOOP:
	call	WRFE_WAIT_DATA
	jr	nz,WRFE_LOOP.1
	ld	a,e
	or	d
	jp	z,WRFE_RET_ERROR
	jr	WRFE_LOOP
WRFE_LOOP.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	; Ok, now the byte is in A, let's compare
WRFE_IDXCMD:
	call WRFE_COMPARE
	; if match
	jr	z,WRFE_RSP_MATCH
	; did not match, let's zero the rsp index
	xor	a
	ld	ixh,a						; re-start at index 0
	pop	hl							; restore the response index
	push	hl						; and keep it in stack
	; back to get another byte
	jr	WRFE_LOOP
WRFE_RSP_MATCH:
	; match
	inc	ixh
	ld	a,ixh
	cp	c
	; if a = c done and response is success
	jr	z,WRFE_RET_OK
	; not done, back to get more bytes
	jr	WRFE_LOOP
WRFE_RET_OK:
	pop	hl
	xor	a
	ret
WRFE_RET_ERROR:
	pop	hl
	ld	a,1
	ret

;*********************************************
;***              RESET ESP                ***
;*** If RESET ok, A will be 0, otherwise   ***
;*** failure							   ***
;*********************************************
RESET_ESP:
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	xor	a
	out	(OUT_CMD_PORT),a			; Send the command to change the speed of interface
	halt
	halt							; Wait a little to make sure speed is adjusted
	ld	a,CMD_WRESET_ESP
	out	(OUT_TX_PORT),a
	ld	hl,RSP_CMD_RESET_ESP		; Expected response
	ld	de,180						; Up to 3s @ 60Hz
	ld	a,RSP_CMD_RESET_ESP_SIZE	; Size of response
	call	WAIT_RESPONSE_FROM_ESP
	or	a
	ret	z
	; Ok, Warm Reset did not work, is ESP installed?
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	ld	a,CMD_QUERY_ESP
	out	(OUT_TX_PORT),a
	ld	hl,RSP_CMD_QUERY_ESP		; Expected response
	ld	de,180						; Up to 1s @ 60Hz
	ld	a,RSP_CMD_QUERY_ESP_SIZE	; Size of response
	call	WAIT_RESPONSE_FROM_ESP
	or	a
	ld	a,1
	ld	b,1							; 1 if response, then it is old firmware
	ret	z
	ld	b,0							; 0 if no response
	ret

;*********************************************
;***              SET TIME                 ***
;*** H - Hour                              ***
;*** L - Minutes                           ***
;*** D - Seconds                           ***
;***                                       ***
;*** A - 0 if Ok otherwise invalid time    ***
;*********************************************
SET_TIME:
	ld	a,h							; Hour in A
	cp	24							; Compare to 24
	jr	nc,SET_TIME_ERR				; If 24 or more, invalid
	ld	a,l							; Minutes in A
	cp	60							; Compare to 60
	jr	nc,SET_TIME_ERR				; If 60 or more, invalid
	LD	a,d							; Seconds in D
	cp	60							; Compare to 60
	jr	nc,SET_TIME_ERR				; If 60 or more invalid
	ld	b,h							; Hour in B
	ld	c,l							; Minutes in C
	ld	e,d							; Seconds in E
	call	SET_RTC_TIME			; Set time in RTC
	xor	a							; 0 in A
	ret								; Return
;	Invalid parameter
SET_TIME_ERR:
	ld	a,1							; Invalid Time
	ret								; Return

SET_RTC_TIME:
	ld	l,e							; Seconds in L
	ld	h,c							; Minutes in H
	ld	d,b							; Hour in D
	call	STOP_RTC_COUNT_SET_MODE0; Select RTC Register 13, and set Mode / Page 0
	ld	a,#F						; Register F
	out	(#B4),a
	ld	a,2
	out	(#B5),a						; Timer reset seconds and on both clock pulses
	ld	e,0							; Start at register 0
	jp	SET_RTC_DATE.1				; And save L, H and D, function will return from there

;*********************************************
;***              SET DATE                 ***
;*** HL - Year from 1980 to 2079           ***
;*** D - Month from 1 to 12                ***
;*** E - Day from 1 to 31                  ***
;***                                       ***
;*** A - 0 if Ok otherwise invalid Date    ***
;*********************************************
SET_DATE:
	ld	bc,#F844
	add	hl,bc
	jr	nc,SET_DATE_ERR				; No carry -> Year is less than 1980, invalid date
	ld	a,h
	or	a
	jr	nz,SET_DATE_ERR				; If H is set, means year is greater than 2235 ,invalid
	ld	a,l
	cp	100
	jr	nc,SET_DATE_ERR				; If L >= 100 year is greater than 2079, invalid
	ld	b,a							; Year - 1980 in B
	ld	a,d							; Now test month
	dec	a
	cp	12							; If 12 or less this should carry
	jr	nc,SET_DATE_ERR				; otherwise invalid
	ld	hl,DAYS_IN_MONTH			; Days in Month table
	add	a,l							; add our month
	ld	l,a							; back in L
	jr	nc,SET_DATE1				; no carry done
	inc	h							; otherwise increase H
SET_DATE1:
	ld	a,28						; 28 days
	cp	(hl)						; If month is 28 days, February, need to check if leap and limit is 29 in this year
	jr	nz,SET_DATE2				; if not, skip below code , so probably above check is if month is february
	ld	a,b							; Year - 1980 in A again
	and	3							; if other than 0, non divisible per 4, so not a leap year
	jr	nz,SET_DATE2				; Regular year
	ld	hl,DAYS_IN_FEBRUARY_LEAP	; HL has address of 29 days, maximum number of days for february in leap year
SET_DATE2:
	ld	a,e							; Day of month in A
	dec	a							; Decrement
	cp	(hl)						; Compare with Days in month
	jr	nc,SET_DATE_ERR				; If day is greater than how many days in month, invalid
	ld	l,e							; Day of month in L
	ld	h,d							; Month in H
	ld	d,b							; Year - 1980 in D
	call	SET_RTC_DATE			; Set date in RTC
	xor	a							; A = 0
	ret								; Success
;	Invalid parameter
SET_DATE_ERR:
	ld	a,1
	ret

; Table of top day value for each month
DAYS_IN_MONTH:			db	31,28,31,30,31,30,31,31,30,31,30,31
; And top day value in February when Leap Year
DAYS_IN_FEBRUARY_LEAP:	db	29

; Will select Mode 00 (Date and Time page) and stop clock counting
; Register D value will be left in A
STOP_RTC_COUNT_SET_MODE0:
	ld	a,#D
	out	(#B4),a						; Select RTC register D (mode)
	in	a,(#B5)						; read register D
	and	4							; Save Alarm EN setting, and mode register is 00 and stop counting time
	out	(#B5),a						; And save
	ret

; Will get a non BCD value in A, convert it to BCD and then save it in
; a register pair that starts in the register indicated in E
; Register E will have the next register after that register pair
RTC_SAVE_REGISTERPAIR:
	ld	c,a							; Save A in C
	xor	a							; 0 in A
	ld	b,8							; 8 in B, number of bits for conversion
RTC_SAVE_REGISTERPAIR.1:
	rlc	c							; Leftmost bit in Carry
	adc	a,a							; A = (A * 2) + Carry
	daa								; decimal adjust A, shift = BCD x 2 + carry
	djnz	RTC_SAVE_REGISTERPAIR.1	; Repeat for 8 bits
	call	SET_RTC_REG				; Save LSB in register and increase register address
	rrca
	rrca
	rrca
	rrca							; now MSB is in LSB position
SET_RTC_REG:
	ld	b,a							; save value to set in B
	ld	a,e							; and now register address in A
	out	(#B4),a						; The register we want to set
	ld	a,b							; restore value
	out	(#B5),a						; save it
	inc	e							; increase register address, as this usually is done in pairs
	ret

; Auxiliary function for SET_DATE and SET_TIME
; SET_RTC_DATE will save date, parameters:
; L - Day
; H - Month
; D - Years since 1980
; All values are regular values, this function will properly convert them
;
; SET_RTC_DATE.1 is used by SET_TIME as well
; It will save three register pairs, starting with the register in E
; First pair is updated with value in L
; Second pair is updated with value in H
; Third pair is updated with value in D
SET_RTC_DATE:
	call	STOP_RTC_COUNT_SET_MODE0; Select RTC Register 13, and set Mode / Page 0
	or	1							; Set Bit 0, so Mode / Page 1 
	out	(#B5),a						; save it in register 13, now page 1 selected
	ld	a,#B						; Leap Year Counter Register
	out	(#B4),a						; Select it
	ld	a,d							; Load Years in leap year counter
	out	(#B5),a						; So it has count of leap years (0 is 1980, leap, and every time it is 4, leap year again)
	call	STOP_RTC_COUNT_SET_MODE0; Select RTC Register 13 and set mode / page 0
	call	STOP_RTC_COUNT_SET_MODE0; do it a second time... DOS does it, don't want to JYNX it :P
	ld	e,7							; Register 7 
SET_RTC_DATE.1:
	ld	a,l							; A has day
	call	RTC_SAVE_REGISTERPAIR	; Will convert day to BCD and save in registers 7 and 8
	ld	a,h							; A has month
	call	RTC_SAVE_REGISTERPAIR	; Will convert month to BCD and save in register 9 and A
	ld	a,d							; A has how many years since 1980
	call	RTC_SAVE_REGISTERPAIR	; Will convert to BCD and save in register B and C
	ld	a,#D						; Register D
	out	(#B4),a						; Send it
	in	a,(#B5)						; Read its value
	or	8							; Start counting time again
	out	(#B5),a						; Send
	ret

;*********************************************
;***    ESP Specific Commands/Responses    ***
;*********************************************
; Cold reset of ESP firmware
CMD_RESET_ESP			equ	'R'
; Warm reset of ESP firmware
CMD_WRESET_ESP			equ	'W'
; Get Updated time and date from internet
CMD_GET_TIME			equ	'G'
; Query Auto Clock settings
CMD_QUERY_ACLK_SETTINGS	equ	'c'
; Set Auto Clock settings
CMD_SET_ACLK_SETTINGS	equ	'C'
; Query ESP settings
CMD_QUERY_ESP_SETTINGS	equ	'Q'
; Set Timer Value
CMD_TIMER_SET			equ	'T'
; Turn Nagle On
CMD_NAGLE_ON			equ	'D'
; Turn Nagle Off
CMD_NAGLE_OFF			equ	'N'
; Turn WiFi Off
CMD_WIFI_OFF			equ	'O'
; Request to connect to a network
CMD_WIFI_CONNECT		equ	'A'
; Request to start network scan
CMD_SCAN_START			equ	'S'
; Request network scan result
CMD_SCAN_RESULTS		equ	's'
; Get ESP firmware version
CMD_GET_ESP_VER			equ	'V'
; After finishing Warm reset, ESP returns ready
RSP_CMD_RESET_ESP		db	"Ready"
RSP_CMD_RESET_ESP_SIZE	equ	5
; Query ESP Presence
CMD_QUERY_ESP			equ	'?'
; Query response
RSP_CMD_QUERY_ESP		db	"OK"
RSP_CMD_QUERY_ESP_SIZE	equ	2

;--- Strings
STTERMINATOR			equ	0
LF						equ	10
CLS						equ	12
CR						equ	13
GOLEFT					equ	29

WELCOME_S:
	db	CLS,"ESP8266 TCP/IP UNAPI 1.2",CR,LF
	db	"(c)2020 Oduvaldo Pavan Junior",GOLEFT,CR,LF,LF
	db	"ducasp@gmail.com",CR,LF,LF
	db	"Quick Rcv not supported",CR,LF
	db	"SM-X FW Update Recommended",CR,LF,LF,STTERMINATOR

WELCOME_SF:
	db	CLS,"ESP8266 TCP/IP UNAPI 1.2",CR,LF,LF
	db	"(c)2020 Oduvaldo Pavan Junior",GOLEFT,CR,LF
	db	"ducasp@gmail.com",CR,LF
	db	"Quick Rcv supported",CR,LF,LF,STTERMINATOR

MMENU_S:
	db	"1 - Change Nagle Setting",CR,LF
	db	"2 - Change WiFi On Period",CR,LF
	db	"3 - Scan/Join Access Points",CR,LF
	db	"4 - WiFi On/Off & Auto Clock",CR,LF,LF
	db	"ESC to exit setup",CR,LF,LF
	db	"Option: ",STTERMINATOR

MMENU_CLOCK_MSX2:
	db	CLS," [ WiFi and Clock Settings ]",CR,LF,LF
	db	"0 - WiFi & UNAPI are enabled",CR,LF
	db	"1 - Also wait up to 10s for",CR,LF
	db	"    internet availability and",GOLEFT,CR,LF
	db	"    get time from SNTP server",GOLEFT,CR,LF
	db	"    adjusting the timezone",CR,LF
	db	"2 - The same as option 1 but",CR,LF
	db	"    also will turn off WiFi",CR,LF
	db	"    when done",CR,LF
	db	"3 - WiFi & UNAPI are disabled",GOLEFT,CR,LF,LF
	db	"MSX boot will take longer if",CR,LF
	db	"options 1 or 2 are active.",CR,LF,LF,STTERMINATOR

MMENU_CLOCK_MSX1:
	db	CLS," [ WiFi and Clock Settings ]",CR,LF,LF
	db	"0 - WiFi & UNAPI are enabled",CR,LF
	db	"1 - Unavailable for MSX1",CR,LF
	db	"2 - Unavailable for MSX1",CR,LF
	db	"3 - WiFi & UNAPI are disabled",GOLEFT,CR,LF,LF,STTERMINATOR

MMENU_CLOCK_0_MSX1:
	db	"Currently Enabled",CR,LF,STTERMINATOR

MMENU_CLOCK_3_MSX1:
	db	"Currently Disabled",CR,LF,STTERMINATOR

MMENU_CLOCK_0:
	db	"Currently off, GMT: ",STTERMINATOR

MMENU_CLOCK_1:
	db	"Currently on, GMT: ",STTERMINATOR

MMENU_CLOCK_2:
	db	"Currently on (WiFi off after",CR,LF
	db	"boot), GMT: ",STTERMINATOR

MMENU_CLOCK_3:
	db	"Currently disabled, GMT: ",STTERMINATOR

MMENU_CLOCK_OPT:
	db	CR,LF,LF,"ESC to return to main menu",CR,LF,LF
	db	"Option: ",STTERMINATOR

MMENU_GMT_OPT:
	db	CR,LF,"Time Zone Adjustment: ",STTERMINATOR


MMENU_SCAN:
	db	CLS,"      [ Scan/Join APs ]",CR,LF,LF
	db	"Up to 10 APs will be listed",CR,LF,LF
	db	"Scanning networks...",STTERMINATOR

MMENU_SCANF:
	db	CR,"Error or no networks found!",CR,LF,STTERMINATOR

MMENU_SCANN:
	db	CR,"No networks found!         ",CR,LF,STTERMINATOR

MMENU_SCANS:
	db	CR,"Networks Available: ",CR,LF,LF,STTERMINATOR

MMENU_CONNECTING:
	db	CR,LF,"Requesting connection...",CR,LF,STTERMINATOR

MMENU_ASKPWD:
	db	CR,LF,"(Hit DEL as first character",CR,LF
	db	"to hide it) Password : ",STTERMINATOR

MMENU_SCANQ:
	db	CR,LF,"ESC to return to main menu",CR,LF,LF
	db	"Number to connect : ",STTERMINATOR

SCAN_TERMINATOR_OPEN:
	db	CR,LF,STTERMINATOR

SCAN_TERMINATOR_ENC:
	db	" *",CR,LF,STTERMINATOR

MMENU_TIMEOUT:
	db	CLS,"     [ WiFi On Period ]",CR,LF,LF
	db	"WiFi On Period allows to set",CR,LF
	db	"a given period of time of",CR,LF
	db	"inactivity to turn off WiFi",CR,LF
	db	"automatically.",CR,LF,LF
	db	"0         - ALWAYS ON",CR,LF
	db	"1 to 30   - 30s",GOLEFT,CR,LF
	db	"30 to 600 - Use given period",CR,LF
	db	"> 600     - 600s",CR,LF,LF,STTERMINATOR

MMENU_TIMEOUT_ALWAYSON:
	db	"WiFi is ALWAYS ON",CR,LF,LF
	db	"ESC to return to main menu",CR,LF,LF
	db	"Type desired period : ",STTERMINATOR

MMENU_TIMEOUT_NOTALWAYSON1:
	db	"WiFi period set to ",STTERMINATOR
MMENU_TIMEOUT_NOTALWAYSON2:
	db	"s",CR,LF,LF
	db	"ESC to return to main menu",CR,LF,LF
	db	"Type desired period : ",STTERMINATOR

MMENU_NAGLE:
	db	CLS,"     [ Nagle Algorithm ]",CR,LF,LF
	db	"Nagle Algorithm might lower",CR,LF
	db	"performance but create less",CR,LF
	db	"network congestion. Nowadays",CR,LF
	db	"it is mostly not needed and",CR,LF
	db	"is the cause of latency and",CR,LF
	db	"low performance on packet",CR,LF
	db	"driven protocols.",CR,LF,LF,STTERMINATOR

MMENU_NAGLE_ON:
	db	"Nagle Algorithm is ON.",CR,LF,LF
	db	"ESC to return to main menu",CR,LF,LF
	db	"O - Turn it off",CR,LF,STTERMINATOR

MMENU_NAGLE_OFF:
	db	"Nagle Algorithm is OFF.",CR,LF,LF
	db	"ESC to return to main menu",CR,LF,LF
	db	"O - Turn it on",CR,LF,STTERMINATOR

STR_SENDING:
	db	"Sending command, wait...",CR,LF,STTERMINATOR

STR_SENDING_OK:
	db	"Command sent Ok, done!",CR,LF,STTERMINATOR

STR_SENDING_OK_JN:
	db	"Command Ok, connected!",CR,LF,STTERMINATOR

STR_SENDING_NOK_JN:
	db	"Fail to connect, if protected",GOLEFT,CR,LF
	db	"network check password!",CR,LF,STTERMINATOR
	
STR_SENDING_FAIL:
	db	"Command failure...",CR,LF,STTERMINATOR

STR_CLKUPDT_FAIL:
	db	"Failure retrieving date and",CR,LF
	db	"time from SNTP server!",CR,LF,STTERMINATOR

OK_S:
	db	"Installed successfully.",CR,LF
	db	CR,LF,STTERMINATOR

FAIL_S:
	db	"ESP8266 Not Found! Check if",CR,LF
	db	"it is properly connected.",CR,LF,STTERMINATOR

FAIL_F:
	db	"ESP8266 Firmware needs update",GOLEFT,CR,LF,STTERMINATOR

;============================
;===  UNAPI related data  ===
;============================

;--- Specification identifier (up to 15 chars)

UNAPI_ID:				db	"TCP/IP",0
UNAPI_ID_END:

;--- Implementation name (up to 63 chars and zero terminated)

APIINFO:				db	"ESP8266 WiFi UNAPI",0


ID_END:	ds	#8000-ID_END,#FF
SEG_CODE_END:
;Final size must be 16384 bytes 