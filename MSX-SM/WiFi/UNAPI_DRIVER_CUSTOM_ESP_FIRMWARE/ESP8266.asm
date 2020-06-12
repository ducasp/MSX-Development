; ESP8266 TCP/IP UNAPI Driver v.1.1
; MSX-SM UART version
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

;*******************
;***  CONSTANTS  ***
;*******************

;--- System variables and routines

_TERM0:					equ	#00
_STROUT:				equ	#09
ENASLT:					equ	#0024
EXTBIO:					equ	#FFCA
ARG:					equ	#F847
H_TIMI:					equ	#FD9F
OUT_TX_PORT:			equ	#07
OUT_CMD_PORT:			equ	#06
IN_DATA_PORT:			equ	#06
IN_STS_PORT:			equ	#07

;--- API version and implementation version
API_V_P:				equ	1
API_V_S:				equ	1

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


;***************************
;***  INSTALLATION CODE  ***
;***************************

	org	#100

	;--- Show welcome message

	ld	de,WELCOME_S
	ld	c,_STROUT
	call	5

	;--- Locate the RAM helper, terminate with error if not installed

	ld	de,#2222
	ld	hl,0
	ld	a,#FF
	call	EXTBIO
	ld	a,h
	or	l
	jr	nz,HELPER_OK

	ld	de,NOHELPER_S
	ld	c,_STROUT
	call	5
	ld	c,_TERM0
	jp	5
HELPER_OK:
	ld	(HELPER_ADD),hl
	ld	(MAPTAB_ADD),bc

	;--- Check if we are already installed.
	;    Do this by searching all the TCP/IP
	;    implementations installed, and comparing
	;    the implementation name of each one with
	;    our implementation name.

	;* Copy the implementation identifier to ARG

	ld	hl,UNAPI_ID-SEG_CODE_START+SEG_CODE
	ld	de,ARG
	ld	bc,UNAPI_ID_END-UNAPI_ID
	ldir

	;* Obtain the number of installed implementations

	ld	de,#2222
	xor	a
	ld	b,0
	call	EXTBIO
	ld	a,b
	or	a
	jr	z,NOT_INST

	;>>> The loop for each installed implementations
	;    starts here, with A=implementation index

IMPL_LOOP:	push	af

	;* Obtain the slot, segment and entry point
	;  for the implementation

	ld	de,#2222
	call	EXTBIO
	ld	(ALLOC_SLOT),a
	ld	a,b
	ld	(ALLOC_SEG),a
	ld	(IMPLEM_ENTRY),hl

	;* If the implementation is in page 3
	;  or in ROM, skip it

	ld	a,h
	and	%10000000
	jr	nz,NEXT_IMP
	ld	a,b
	cp	#FF
	jr	z,NEXT_IMP

	;* Call the routine for obtaining
	;  the implementation information

	ld	a,(ALLOC_SLOT)
	ld	iyh,a
	ld	a,(ALLOC_SEG)
	ld	iyl,a
	ld	ix,(IMPLEM_ENTRY)
	ld	hl,(HELPER_ADD)
	xor	a
	call	CALL_HL	;Returns HL=name address

	;* Compare the name of the implementation
	;  against our own name

	ld	a,(ALLOC_SEG)
	ld	b,a
	ld	de,APIINFO-SEG_CODE_START+SEG_CODE
	ld	ix,(HELPER_ADD)
	inc	ix
	inc	ix
	inc	ix	;Now IX=helper routine to read from segment
NAME_LOOP:	ld	a,(ALLOC_SLOT)
	push	bc
	push	de
	push	hl
	push	ix
	call	CALL_IX
	pop	ix
	pop	hl
	pop	de
	pop	bc
	ld	c,a
	ld	a,(de)
	cp	c
	jr	nz,NEXT_IMP
	or	a
	inc	hl
	inc	de
	jr	nz,NAME_LOOP

	;* The names match: already installed

	ld	de,ALINST_S
	ld	c,_STROUT
	call	5
	ld	c,_TERM0
	jp	5

	;* Names don't match: go to the next implementation

NEXT_IMP:	pop	af
	dec	a
	jr	nz,IMPL_LOOP

	;* No more implementations:
	;  continue installation process

NOT_INST:
	;--- Obtain the mapper support routines table, if available
	xor	a
	ld	de,#0402
	call	EXTBIO
	or	a
	jr	nz,ALLOC_DOS2

	;--- DOS 1: Use the last segment on the primary mapper
	ld	a,2
	ld	(MAPTAB_ENTRY_SIZE),a

	ld	hl,(MAPTAB_ADD)
	ld	b,(hl)
	inc	hl
	ld	a,(hl)
	jr	ALLOC_OK

	;--- DOS 2: Allocate a segment using mapper support routines

ALLOC_DOS2:
	ld	a,b
	ld	(PRIM_SLOT),a
	ld	de,ALL_SEG
	ld	bc,15*3
	ldir

	ld	de,0401h
	call	EXTBIO
	ld	(MAPTAB_ADD),hl

	ld	a,8
	ld	(MAPTAB_ENTRY_SIZE),a

	ld	a,(PRIM_SLOT)
	or	%00100000					;Try primary mapper, then try others
	ld	b,a
	ld	a,1		;System segment
	call	ALL_SEG
	jr	nc,ALLOC_OK

	ld	de,NOFREE_S					;Terminate if no free segments available
	ld	c,_STROUT
	call	5
	ld	c,_TERM0
	jp	5

ALLOC_OK:
	ld	(ALLOC_SEG),a
	ld	a,b
	ld	(ALLOC_SLOT),a

	;--- Switch segment, copy code, and setup data

	call	GET_P1					;Backup current segment
	ld	(P1_SEG),a

	ld	a,(ALLOC_SLOT)				;Switch slot and segment
	ld	h,#40
	call	ENASLT
	ld	a,(ALLOC_SEG)
	call	PUT_P1

	ld	hl,#4000					;Clear the segment first
	ld	de,#4001
	ld	bc,#4000-1
	ld	(hl),0
	ldir

	ld	hl,SEG_CODE					;Copy the code to the segment
	ld	de,#4000
	ld	bc,SEG_CODE_END-SEG_CODE_START
	ldir

	ld	hl,(ALLOC_SLOT)				;Setup slot and segment information
	ld	(MY_SLOT),hl

	; Clear FIFO, so we start clean and do not get garbage
	ld a,20
	out (OUT_CMD_PORT),a

	;* Now backup and patch the EXTBIO and H_TIMI hooks

	di
	ld	hl,EXTBIO
	ld	de,OLD_EXTBIO
	ld	bc,5
	ldir

	ld	hl,H_TIMI
	ld	de,OLD_HTIM_I
	ld	bc,5
	ldir

	; First the EXTBIO Hook at index 6 / 4012
	ld	a,6							;Index 6 or 4012
	ld	ix,EXTBIO					;EXTBIO hook
	call	PATCH_HOOK

	xor	a							; Index 0 or 4000
	ld	ix,H_TIMI					; VDP Interrupt Hook
	call	PATCH_HOOK
	ei

	;--- Check if ESP is present 
	call CHECK_BAUD
	;--- Save return
	ld	(TEMP_RET),a
	cp	#ff
	jp	z,LOAD_RESTORE_SS
	;--- If could set BAUD, ESP is good, so let's initialize it
	call	RESET_ESP
	cp	#0
	jr	z,LOAD_RESTORE_SS
	;--- Error during reset
	ld	a,#ff
	ld	(TEMP_RET),a ;Indicate error so proper msg will be shown
LOAD_RESTORE_SS:
	;--- Restore slot and segment, and terminate

	ld	a,(PRIM_SLOT)
	ld	h,#40
	call	ENASLT
	ld	a,(P1_SEG)
	call	PUT_P1

	ld a,(TEMP_RET)
	cp #FF
	jr nz,LOAD_ESP_INIT_OK
	ld	de,FAIL_S
	ld	c,_STROUT
	call	5
	jr LOAD_EXIT
LOAD_ESP_INIT_OK:
	ld	de,OK_S
	ld	c,_STROUT
	call	5
LOAD_EXIT:
	ld	c,_TERM0
	jp	5

	;>>> Other auxiliary code
CALL_IX:	jp	(ix)
CALL_HL:	jp	(hl)

;--- This routine patches a hook so that
;    it calls the routine with the specified index
;    in the allocated segment.
;    Input: A  = Routine index, 0 to 63
;           IX = Hook address
;           ALLOC_SEG and ALLOC_SLOT set
PATCH_HOOK:
	push	af
	ld	a,0CDh						;Code for "CALL"
	ld	(ix),a
	ld	hl,(HELPER_ADD)
	ld	bc,6
	add	hl,bc						;Now HL points to segment call routine
	ld	(ix+1),l
	ld	(ix+2),h

	ld	hl,(MAPTAB_ADD)
	ld	a,(ALLOC_SLOT)
	ld	bc,(MAPTAB_ENTRY_SIZE)
	ld	b,0
	ld	d,a
	ld	e,0							;Index on mappers table
SRCHMAP:
	ld	a,(hl)
	cp	d
	jr	z,MAPFND
	add	hl,bc						;Next table entry
	inc	e
	jr	SRCHMAP
MAPFND:
	ld	a,e							;A = Index of slot on mappers table
	rrca
	rrca
	and	11000000b
	pop	de							;Retrieve routine index
	or	d
	ld	(ix+3),a

	ld	a,(ALLOC_SEG)
	ld	(ix+4),a
	ret


;****************************************************
;***  DATA AND STRINGS FOR THE INSTALLATION CODE  ***
;****************************************************

;--- Variables
PRIM_SLOT:				db	0		;Primary mapper slot number
P1_SEG:					db	0		;Segment number for TPA on page 1
ALLOC_SLOT:				db	0		;Slot for the allocated segment
ALLOC_SEG:				db	0		;Allocated segment
HELPER_ADD:				dw	0		;Address of the RAM helper jump table
MAPTAB_ADD:				dw	0		;Address of the RAM helper mappers table
MAPTAB_ENTRY_SIZE:		db	0		;Size of an entry in the mappers table:
									;- 8 in DOS 2 (mappers table provided by standard mapper support routines),
									;- 2 in DOS 1 (mappers table provided by the RAM helper)
IMPLEM_ENTRY:			dw	0		;Entry point for implementations
TEMP_RET:				db	0		;Store return values from the mapper page

;--- DOS 2 mapper support routines
ALL_SEG:				ds	3
FRE_SEG:				ds	3
RD_SEG:					ds	3
WR_SEG:					ds	3
CAL_SEG:				ds	3
CALLS:					ds	3
PUT_PH:					ds	3
GET_PH:					ds	3
PUT_P0:					ds	3
GET_P0:					ds	3
PUT_P1:
	out	(#FD),a
	ret
GET_P1:
	in	a,(#FD)
	ret
PUT_P2:					ds	3
GET_P2:					ds	3
PUT_P3:					ds	3

;--- Strings
WELCOME_S:
	db	"ESP8266 TCP/IP UNAPI Driver v1.1",13,10
	db	"(c)2020 Oduvaldo Pavan Junior - ducasp@gmail.com",13,10
	db	10
	db	"$"

NOHELPER_S:
	db	"*** ERROR: No UNAPI RAM helper is installed",13,10,"$"

NOMAPPER_S:
	db	"*** ERROR: No mapped RAM found",13,10,"$"

NOFREE_S:
	db	"*** ERROR: Could not allocate any RAM segment",13,10,"$"

OK_S:
	db	"Installed successfully.",13,10
	db	"ESP8266 FW v0.0",13,10
	db	13,10,"$"

FAIL_S:
	db	"ESP Not Found.",13,10,"$"

ALINST_S:
	db	"*** Already installed.",13,10,"$"

;*********************************************
;***  CODE TO BE INSTALLED ON RAM SEGMENT  ***
;*********************************************

SEG_CODE:
	org	#4000
SEG_CODE_START:

;===============================
;===  HTIM_I hook execution  ===
;===============================
DO_HTIMI:
	push	af						; HTIM hook -> need to keep A value
	ld	hl,(TIMEOUT_COUNTER)
	ld	a,l
	or	h							; In this operation, check if HL is o
	jr	z,DO_HTIMI_END				; If it is, nothing to do
	dec	hl							; Otherwise decrement it
	ld	(TIMEOUT_COUNTER),hl		; And save it
DO_HTIMI_END:
	pop	af							; Restore original A value
	jp	OLD_HTIM_I					; And do whatever was in the hook before
	nop
	nop								; place holders to have DO_EXTBIO in 4012

;>>> Note that this code starts exactly at address #4012 / Index 6
; If HTIM function changes, might need to adjust index for this
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

	pop	af
	pop	bc
	or	a
	jr	nz,DO_EXTBIO2
	inc	b
	pop	hl
	ld	de,#2222
	jp	OLD_EXTBIO
DO_EXTBIO2:

	; A=1: Return A=Slot, B=Segment, HL=UNAPI entry address

	dec	a
	jr	nz,DO_EXTBIO3
	pop	hl
	ld	a,(MY_SEG)
	ld	b,a
	ld	a,(MY_SLOT)
	ld	hl,UNAPI_ENTRY
	ld	de,#2222
	ret

	; A>1: A=A-1, and jump to old hook

DO_EXTBIO3:							; A=A-1 already done
	pop	hl
	ld	de,#2222
	jp	OLD_EXTBIO


;--- Jump here to execute old EXTBIO code

JUMP_OLD2:
	ld	de,#2222
JUMP_OLD:							; Assumes "push hl,bc,af" done
	pop	af
	pop	bc
	pop	hl
; Old EXTBIO hook contents is here
; (it is setup at installation time)
OLD_EXTBIO:				ds	5
;Old HTIM_I hook contents is here
;(it is setup at installation time)
OLD_HTIM_I:				ds	5

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
	ld	a,(TIMEOUT_COUNTER)
	or	a
	ret	nz
	ld	a,(TIMEOUT_COUNTER+1)
	or	a
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
	ld	a,(ROM_V_P)
	ld	b,a
	ld	a,(ROM_V_S)
	ld	c,a
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
	ld	(UNAPI_FIRST_BYTE_PARAM),a
	out	(OUT_TX_PORT),a				; Send the parameter

	; Now wait up to 120 ticks to get response
	ld	hl,120
	ld	(TIMEOUT_COUNTER),hl
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
	ld	a,(UNAPI_FIRST_BYTE_PARAM)
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
	
	; Now wait up to 120 ticks to get response
	ld	hl,120
	ld	(TIMEOUT_COUNTER),hl
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
	ld	(TIMEOUT_COUNTER),hl
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
DNS_BUFFER:				ds	256
;Indicates how much of Buffer has been used (no need to be zero terminated)
DNS_BUFFER_DATA_SIZE:	db	0
;Will store the result of the last DNS query
DNS_RESULT:				ds	4
ESP_DNS_INPROGRESS:		db	0
DNS_READY:				db	0
TCPIP_DNS_Q:
	ld	a,b
	and	%11111000
	ld	a,ERR_INV_PARAM
	ret	nz

	bit	0,b
	jr	z,DNS_Q_NO_CANCEL

;--- Only cancel the query in progress
;--- ESP won't allow canceling, so just sit here until it finishes...
DNS_Q_CANCEL_WAIT:
	ld	a,(ESP_DNS_INPROGRESS)
	or	a							;--- DNS Query In progress?
	jr	nz,DNS_Q_CANCEL_WAIT
	;--- Not anymore, good to go
	xor	a
	ld	(DNS_READY),a				; discard dns information, if any
	ret

DNS_Q_NO_CANCEL:
	;--- If there is a query in progress and
	;    B:2 is set, return an error
	bit	2,b
	jr	z,DNS_Q_NO_EXISTING	
	ld	a,(ESP_DNS_INPROGRESS)
	or	a							;--- DNS Query In progress?
	jr	z,DNS_Q_NO_EXISTING
	ld	a,ERR_QUERY_EXISTS
	ret

DNS_Q_NO_EXISTING:
	;--- We can't cancel DNS request, so just clear DNS data
	xor	a
	ld	(DNS_READY),a				; discard dns information, if any
	;--- Ok, start from scratch
	push	bc
	;--- Copy the host name to our internal buffer
	;--- The origin is in HL
	ld	de,DNS_BUFFER
	ld	b,255						; this is the limit, can use up to 255 bytes long
	ld	c,0							; Our counter of how many bytes host information has
DNS_Q_COPYSTART:
	; Why the heck do this instead of LDIR? 
	; We will need to know how much bytes to send to ESP anyway
	; Also, this way we can limit how much will be transferred,
	; if byte is terminator, and count while transferring...
	; LDI / LDIR might save some cycles but would add complexity
	ld	a,(hl)						; HL -> host name to resolve, get from it
	ld	(de),a						; DE -> DNS_BUFFER, transfer to it
	or	a							; is it a zero? (string termination)
	jr	z,DNS_Q_COPYEND				; if so, done copying
	inc	de							; increment destination pointer
	inc	hl							; increment source pointer
	inc	c							; increment counter
	dec	b							; decrement limiter
	jr	z,DNS_Q_COPYEND				; if hit our limit, end
	jr	DNS_Q_COPYSTART				; continue copying
	; Hostname in DNS_BUFFER, it's size in C
DNS_Q_COPYEND:
	xor	a							; a = 0
	inc	de							; increment destination pointer
	ld	(de),a						; terminate the string so PARSE_IP work fine
	ld	a,c							; size
	ld	(DNS_BUFFER_DATA_SIZE),a	; save the count of bytes copied
	ld	de,DNS_RESULT				; Want to store results in DNS_RESULT

	;--- Try to parse the host name as an IP address
	call	PARSE_IP
	pop	bc							; restore b, it contains the flags commanding our operation
	jr	c,DNSQ_NO_IP				; if carry, it is not an IP, so need to resolve
	;--- It was an IP address
	ld	a,1
	ld	(DNS_READY),a				; DNS done
	ld	hl,(DNS_RESULT)
	ld	de,(DNS_RESULT+2)
	ld	b,1
	xor	a
	ret

;--- The host name was not an IP address
DNSQ_NO_IP:
	bit	1,b							; Was "assume IP address" flag set?
	ld	a,ERR_INV_IP				; if it was and it is not IP address, error
	ret	nz							; bit 1 is set? If so, address should have been an IP not host name, error
	;--- No problem, no assumption that it is an IP address
	jr	DNSQ_NO_IP_STT

DNSQ_NO_IP_STT:
	; Here we send the query and wait the result
	ld	a,6							; DNS_Q
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,(DNS_BUFFER_DATA_SIZE)	; size of host string
	out	(OUT_TX_PORT),a				; Send the command size lsb

	; now otir of DNS/DNS BUFFER DATA SIZE
	ld	c,OUT_TX_PORT				; our data TX port
	ld	hl,DNS_BUFFER				; string to try to resolve
	; Port in C, command in HL, move size to B
	ld	b,a
	; send it
	otir

	; Now wait up to 900 ticks (15s@60Hz) to get response
	ld	hl,900
	ld	(TIMEOUT_COUNTER),hl
TCPIP_DNSQ_SEND_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a ;if nz has data
	jr	nz,TCPIP_DNSQ_SEND_ST1.1
	call	TCPIP_GENERIC_CHECK_TIME_OUT
	jr	TCPIP_DNSQ_SEND_ST1
TCPIP_DNSQ_SEND_ST1.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	6							; Is response of our command?
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
	ld	(DNS_READY),a				; DNS done
	ld	(DNS_RESULT),hl
	ld	(DNS_RESULT+2),de
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
	ld	a,(ESP_DNS_INPROGRESS)
	or	a							;--- DNS Query In progress?
	jr z,TCPIP_DNS_S_NOQIP			; No
	; Yes
	xor a
	ld b,1							;--- query in progress
	ld c,a							;--- we don't know what goes on ESP, it is automatic
	ret

TCPIP_DNS_S_NOQIP:
	;--- It is not in progress, but, is there a result?
	ld	a,(DNS_READY)				; DNS done?
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
	ld	(DNS_READY),a				; DNS not done
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
	ld	hl,(DNS_RESULT)
	ld	de,(DNS_RESULT+2)
	xor	a
	bit	0,b							;--- clear result after this?
	jr	z,TCP_IP_DNS_S_RES_NOCLR	;--- no, just return
	;--- Yes, clear
	ld	(DNS_READY),a				; DNS not done
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
	ld	(TIMEOUT_COUNTER),hl
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
	ld	(TIMEOUT_COUNTER),hl
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
	ld	(TIMEOUT_COUNTER),hl
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
	ld	a,(de)
	ld	e,b							; lsb
	ld d,a							; msb
	; Grauw Optimized 16 bit loop, handy for us, mostly since we can use outi :-D
	ld	b,e							; Number of loops originaly in DE
	dec	de
	inc	d
	ld	c,OUT_TX_PORT
TCPIP_UDP_SEND_R:
	outi
	jr	nz,TCPIP_UDP_SEND_R
	dec	d
	jr	nz,TCPIP_UDP_SEND_R

	; Now wait up to 600 ticks to get response
	ld	hl,600
	ld	(TIMEOUT_COUNTER),hl
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
TCPIP_UDP_BC_BACKUP:	dw	0
TCPIP_UDP_DE_BACKUP:	dw	0
TCPIP_UDP_HL_BACKUP:	dw	0
TCPIP_UDP_RCV_CHECK_TIME_OUT:
	ld	a,(TIMEOUT_COUNTER)
	or	a
	ret	nz
	ld	a,(TIMEOUT_COUNTER+1)
	or	a
	ret	nz
	; Ok, timeout...
	pop	af							; Get return address of who called this out of the stack, we will return from the function or re-start
	ld	a,(RX_RETRY_SUPPORTED)
	or	a
	jr	z,TCPIP_UDP_RCV_CHECK_TIME_OUT.NORXRETRY
	ld	a,(RX_RETRY_COUNTER)
	or	a
	jr	z,TCPIP_UDP_RCV_CHECK_TIME_OUT.NORXRETRY
	; Ok, so let's ask ESP to re-send the data and retry receiving it
	dec	a
	ld	(RX_RETRY_COUNTER),a		; we are retrying it
	ld	a,'r'						; retry transmission command
	out	(OUT_TX_PORT),a
	jp	TCPIP_UDP_RCV.RXRETRY		; and retry it
TCPIP_UDP_RCV_CHECK_TIME_OUT.NORXRETRY:
	ld	a,ERR_INV_OPER
	ret								; and return the function itself

TCPIP_UDP_RCV:
	ld (TCPIP_UDP_RCV_ADDRESS),hl
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
	ld	(RX_RETRY_COUNTER),a		; Ok, retry up to three times
TCPIP_UDP_RCV.RXRETRY:
	; Now wait up to 600 ticks to get response
	ld	hl,600
	ld	(TIMEOUT_COUNTER),hl
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
	; At this point, all data is being buffered, so 15 ticks, quarter second, is more than enough time-out
	di
	ld	hl,30
	ld	(TIMEOUT_COUNTER),hl
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
	ld	(TCPIP_UDP_HL_BACKUP),hl
	ld	(TCPIP_UDP_BC_BACKUP),bc
	ld	(TCPIP_UDP_DE_BACKUP),de
	; will start moving at TCPIP_UDP_RCV_ADDRESS
	ld	hl,(TCPIP_UDP_RCV_ADDRESS)
	; size goes to DE
	ld	d,b
	ld	e,c
	; Grauw Optimized 16 bit loop, handy for us, mostly since we can use ini :-D
	ld	b,e							; Number of loops originaly in DE
	dec	de
	inc	d
	ld	c,IN_DATA_PORT
TCPIP_UDP_RCV_R:
	in	a,(IN_STS_PORT)
	bit	0,a							; Do we have data to read?
	jr	nz,TCPIP_UDP_RCV_R.1
	call	TCPIP_UDP_RCV_CHECK_TIME_OUT
	jr	TCPIP_UDP_RCV_R
TCPIP_UDP_RCV_R.1:
	ini
	jr	nz,TCPIP_UDP_RCV_R
	dec	d
	jr	nz,TCPIP_UDP_RCV_R
	; done, restore return data in DE BC and HL 
	ld	de,(TCPIP_UDP_DE_BACKUP)
	ld	bc,(TCPIP_UDP_BC_BACKUP)
	ld	hl,(TCPIP_UDP_HL_BACKUP)
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
TCP_OPEN_ERRNOCONN		db	0
TCP_OPEN_CMD_SIZE		dw	0
TCP_OPEN_IP1			db	0
TCP_OPEN_IP2			db	0
TCP_OPEN_IP3			db	0
TCP_OPEN_IP4			db	0
TCP_OPEN_RP				dw	0
TCP_OPEN_LP				dw	0
TCP_OPEN_TO				dw	0
TCP_OPEN_CMD_FLAGS		db	0
TCP_OPEN_CMD_HOST		ds	256

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
	push	af
	ld	de,TCP_OPEN_IP1
	ld	bc,13
	ldir							; parameters copied to our address

	; most times it will be non tls, so this is the first test case
	ld	a,11
	ld	(TCP_OPEN_CMD_SIZE),a
	xor	a
	ld	(TCP_OPEN_CMD_SIZE+1),a
	ld	a,(TCP_OPEN_CMD_FLAGS)
	bit	2,a
	jr	z,TCPIP_TCP_OPEN_NO_TLS

	; TLS, but, do we have host name?
	ld	a,12
	ld	(TCP_OPEN_CMD_SIZE),a
	xor	a
	ld	(TCP_OPEN_CMD_SIZE+1),a
	ld	a,(TCP_OPEN_CMD_HOST)
	ld	l,a
	ld	a,(TCP_OPEN_CMD_HOST+1)
	or	l
	; if TLS and next two bytes are 00 no host to check
	jr	z,TCPIP_TCP_OPEN_NO_CHECKHOST
	; we are here, host to check
	ld	h,a
	; let's check how many bytes there are
	ld	de,TCP_OPEN_CMD_HOST
	ld	bc,11
TCPIP_TCP_OPEN_CHECK_HOSTOF:
	; avoid overflow of host, this would kill us and our code :-D
	ld	a,1
	cp	b
	jr	nz,TCPIP_TCP_OPEN_HOSTNAME_SIZE
	ld	a,10
	cp	c
	jr	nz,TCPIP_TCP_OPEN_HOSTNAME_SIZE
	; if here BC = 10A = #FF + 11, so, terminate string and life goes on, sorry
	xor	a
	ld	(de),a
	inc	bc
	jr	TCPIP_TCP_OPEN_HOSTNAME_COPYNEWCMDSIZE
TCPIP_TCP_OPEN_HOSTNAME_SIZE:
	ld	a,(hl)
	ld	(de),a
	inc	bc
	inc	hl
	inc	de
	cp	0
	jr	nz,TCPIP_TCP_OPEN_HOSTNAME_SIZE
TCPIP_TCP_OPEN_HOSTNAME_COPYNEWCMDSIZE
	ld	(TCP_OPEN_CMD_SIZE),bc

TCPIP_TCP_OPEN_NO_TLS:
TCPIP_TCP_OPEN_NO_CHECKHOST:
	pop	af
	out	(OUT_TX_PORT),a				; Send the command
	ld	a,(TCP_OPEN_CMD_SIZE+1)
	ld	d,a
	out	(OUT_TX_PORT),a				; Send the command size msb
	ld	a,(TCP_OPEN_CMD_SIZE)
	ld	e,a
	out	(OUT_TX_PORT),a				; Send the command size lsb

	ld	c,OUT_TX_PORT
	ld	hl,TCP_OPEN_IP1
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

	; Now wait up to 3600 (1 minute @ 60Hz) ticks to get response
	; TLS Connections might take SEVERAL seconds on TLS Handshake
	ld	hl,3600
	ld	(TIMEOUT_COUNTER),hl
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
	ld	(TIMEOUT_COUNTER),hl
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
	ld	(TIMEOUT_COUNTER),hl
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
TCPIP_TCP_STATE_BC_BACKUP:	dw	0
TCPIP_TCP_STATE_HL_BACKUP:	dw	0

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

TCP_STATE_INFORMATION_BLOCK	dw	0
TCPIP_TCP_STATE:
	ld	(TCP_STATE_INFORMATION_BLOCK),hl
	out	(OUT_TX_PORT),a				; Send the command
	xor	a
	out	(OUT_TX_PORT),a				; Send the command size msb
	inc	a
	out	(OUT_TX_PORT),a				; Send the command size lsb
	ld	a,b
	out	(OUT_TX_PORT),a				; Send the parameter

	; Now wait up to 180 ticks to get response
	ld	hl,180
	ld	(TIMEOUT_COUNTER),hl
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
	ld	(TCPIP_TCP_STATE_BC_BACKUP),bc
	ld	b,8
	ld	a,(TCP_STATE_INFORMATION_BLOCK)
	or	a
	jr	nz,TCPIP_TCP_STATE_GET_IBLOCK
	ld	a,(TCP_STATE_INFORMATION_BLOCK+1)
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
	ld	bc,(TCPIP_TCP_STATE_BC_BACKUP)
	xor	a
	ret

; If here, save Information Block (next 8 bytes)
TCPIP_TCP_STATE_GET_IBLOCK:
	ld	(TCPIP_TCP_STATE_HL_BACKUP),hl
	ld	hl,(TCP_STATE_INFORMATION_BLOCK)
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
	ld	hl,(TCPIP_TCP_STATE_HL_BACKUP)
	ld	bc,(TCPIP_TCP_STATE_BC_BACKUP)
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
	ld	(TIMEOUT_COUNTER),hl
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
TCPIP_TCP_RCV_DATA_ADDRESS:	dw	0
TCPIP_RCV_COUNT:			dw	0
TCPIP_TCP_RCV_CHECK_TIME_OUT:
	ld	a,(TIMEOUT_COUNTER)
	or	a
	ret	nz
	ld	a,(TIMEOUT_COUNTER+1)
	or	a
	ret	nz
	; Ok, timeout...
	pop	af							; Get return address of who called this out of the stack, we will return from the function or re-start
	ld	a,(RX_RETRY_SUPPORTED)
	or	a
	jr	z,TCPIP_TCP_RCV_CHECK_TIME_OUT.NORXRETRY
	ld	a,(RX_RETRY_COUNTER)
	or	a
	jr	z,TCPIP_TCP_RCV_CHECK_TIME_OUT.NORXRETRY
	; Ok, so let's ask ESP to re-send the data and retry receiving it
	dec	a
	ld	(RX_RETRY_COUNTER),a		; we are retrying it
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
	ld	(TCPIP_TCP_RCV_DATA_ADDRESS),de
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
	ld	(RX_RETRY_COUNTER),a		; Ok, retry up to three times
TCPIP_TCP_RCV.RXRETRY:
	; Now wait up to 600 ticks to get response
	ld	hl,600
	ld	(TIMEOUT_COUNTER),hl
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
	ld	(TIMEOUT_COUNTER),hl
	ei
	; now get return code, if return code other than 0, it is finished
TCPIP_TCP_RCV_RC:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,TCPIP_TCP_RCV_RC.1
	call	TCPIP_TCP_RCV_CHECK_TIME_OUT
2	jr	TCPIP_TCP_RCV_RC
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
	; will start moving at address in stack (we've pushed DE into it)
	ld	hl,(TCPIP_TCP_RCV_DATA_ADDRESS)
	ld	(TCPIP_RCV_COUNT),bc		; save count (BC)

	; Grauw Optimized 16 bit loop, handy for us, mostly since we can use ini :-D
	ld	b,e							; Number of loops originaly in DE
	dec	de
	inc	d
	ld	c,IN_DATA_PORT
TCPIP_TCP_RCV_R:
	in	a,(IN_STS_PORT)
	bit	0,a							; Do we have data to read?
	jr	nz,TCPIP_TCP_RCV_R.1
	call	TCPIP_TCP_RCV_CHECK_TIME_OUT
	jr	TCPIP_TCP_RCV_R
TCPIP_TCP_RCV_R.1:
	ini
	jr	nz,TCPIP_TCP_RCV_R
	dec	d
	jr nz,TCPIP_TCP_RCV_R
	ld	bc,(TCPIP_RCV_COUNT)		; done, restore return data in BC
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
	ld (TIMEOUT_COUNTER),hl
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
	ld	(TIMEOUT_COUNTER),hl
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

;--- PARSE_IP: Extracts an IP address from a string
;    Input:  String at DNS_BUFFER, zero terminated
;    Output: Cy=0 and IP at address in DE, or Cy=1 if not a valid IP
;    Modifies: AF, BC, DE, HL, IX
PARSE_IP:
	ld	hl,DNS_BUFFER
PARSE_IPL:
	ld	a,(hl)
	or	a
	jr	z,PARSE_IP2					; Appends a dot to ease parsing process
	inc	hl
	jr	PARSE_IPL
PARSE_IP2:
	ld	(hl),"."
	push	hl
	pop	ix							; IX = Address of the last dot

	ld	hl,DNS_BUFFER
	ld	b,4

IPLOOP:
	push	bc
	push	de
	call	EXTNUM
	jp	c,ERRIP						; Checks that it is a number in the range 0-255
	or a							; and that it is zero terminated
	jp	nz,ERRIP
	ld	a,b
	or	a
	jp	nz,ERRIP
	ld	a,e
	cp	"."
	jp	nz,ERRIP

	ld	a,c
	ld	c,d
	ld	b,0
	pop	de
	ld	(de),a
	add	hl,bc
	inc	hl
	inc	de
	pop	bc
	djnz	IPLOOP

	or	a
	jr	PARSE_IPEND

ERRIP:
	pop	de
	pop	bc
	scf

PARSE_IPEND:
	ld	(ix),0
	ret

;--- Compare HL and DE
;    Input:  HL, DE = values to compare
;    Output: Cy set if HL<DE
;            Z  set if H=DE
;    Modifies: AF
COMP16:
	ld	a,h
	sub	d
	ret	nz
	ld	a,l
	sub	e
	ret

;--- Convert a character to upper-case if it is a lower-case letter
TOUPPER:
	cp	"a"
	ret	c
	cp	"z"+1
	ret	nc
	and	#DF
	ret

;--- NAME: EXTNUM
;      Extracts a 5 digit number from a string
;    INPUT:    HL = ASCII string address
;    OUTPUT:   CY-BC = 17 bit number
;              D  = Count of digits of the number.
;		The number is considered to be extracted
;                   when a non-numeric character is found,
;                   or when five digits have been extracted.
;              E  = First non-numeric character (o 6th digit)
;              A  = error code:
;                   0 => Success
;                   1 => The number has more than 5 digits.
;                        CY-BC contains then the number built from
;                        the first 5 digits.
;    MODIFIES:  -
EXTNUM:
	push	hl
	push	ix
	ld	ix,ACA
	res	0,(ix)
	set	1,(ix)
	ld	bc,0
	ld	de,0
BUSNUM:
	ld	a,(hl)						; Jump to FINEXT if not a digit, or is the 6th digit
	ld	e,a
	cp	"0"
	jr	c,FINEXT
	cp	"9"+1
	jr	nc,FINEXT
	ld	a,d
	cp	5
	jr	z,FINEXT
	call	POR10

SUMA:
	push	hl						; BC = BC + A
	push	bc
	pop	hl
	ld	bc,0
	ld	a,e
	sub	"0"
	ld	c,a
	add	hl,bc
	call	c,BIT17
	push	hl
	pop	bc
	pop	hl

	inc	d
	inc	hl
	jr	BUSNUM

BIT17:
	set	0,(ix)
	ret
ACA:					db	0		; b0: num>65535. b1: more than 5 digits

FINEXT:
	ld	a,e
	cp	"0"
	call	c,NODESB
	cp	"9"+1
	call	nc,NODESB
	ld	a,(ix)
	pop	ix
	pop	hl
	srl	a
	ret

NODESB:
	res	1,(ix)
	ret

POR10:
	push	de
	push	hl						; BC = BC * 10
	push	bc
	push	bc
	pop	hl
	pop	de
	ld	b,3
ROTA:
	sla	l
	rl	h
	djnz	ROTA
	call	c,BIT17
	add	hl,de
	call	c,BIT17
	add	hl,de
	call	c,BIT17
	push	hl
	pop	bc
	pop	hl
	pop	de
	ret

;*********************************************
;***       WAIT_RESPONSE_FROM_ESP          ***
;*** Will wait ESP to send a response,     ***
;*** discarding all data until it is found.***
;***                                       ***
;*** Inputs:                               ***
;*** IX - Expected response string         ***
;*** A - Response Size                     ***
;*** BC - TimeOut in ticks                 ***
;***                                       ***
;*** Output:                               ***
;*** A - 0 if response received 		   ***
;*** otherwise response not received and   ***
;*** timed-out.                            ***
;***                                       ***
;*** Changes HL, BC, AF, DE                ***
;*********************************************
WR_CMD_RSP_INDEX		db	0
WAIT_RESPONSE_FROM_ESP:
	ld	(TIMEOUT_COUNTER),bc
	ld	c,a							;Response size in C
	xor a
WRFE_ST1:
	ld	(WR_CMD_RSP_INDEX),a

WRFE_LOOP:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	nz,WRFE_LOOP.1
	call	WRFE_CHECK_TIME_OUT
	jr	WRFE_LOOP
WRFE_LOOP.1:
	; nz, check the data
	in	a,(IN_DATA_PORT)
	ld	b,a
	ld	a,(WR_CMD_RSP_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld	(WRFE_IDXCMD+2),a
	; move data back to A
	ld	a,b
	; Ok, now the byte is in A, let's compare
WRFE_IDXCMD:
	cp	(ix+0)
	; if match
	jr	z,WRFE_RSP_MATCH
	; did not match, let's zero the rsp index
	xor	a
	ld	(WR_CMD_RSP_INDEX),a
	; back to get another byte
	jr	WRFE_LOOP
WRFE_RSP_MATCH:
	; match
	ld	a,(WR_CMD_RSP_INDEX)
	inc	a
	cp	c
	; if a = c done and response is success
	jr	z,WRFE_RET_OK
	; not done, save new index
	ld	(WR_CMD_RSP_INDEX),a
	; back to get more bytes
	jr	WRFE_LOOP
WRFE_RET_OK:
	xor	a
	ret

WRFE_CHECK_TIME_OUT:
	ld	a,(TIMEOUT_COUNTER)
	or	a
	ret	nz
	ld	a,(TIMEOUT_COUNTER+1)
	or	a
	ret	nz
	; Ok, timeout...
	pop	af							; Get return address of who called this out of the stack
	ld	a,#1						; Ensure A is not zero
	ret								; and return the function itself

;*********************************************
;***           CHECK BAUDRATE              ***
;*** Current BaudRate will be stored in	   ***
;*** ESP_UART_SPEED, from 0 to 9, or #FF if***
;*** couldn't find ESP...				   ***
;*********************************************
CHECK_BAUD:
	ld	a,20
	out	(OUT_CMD_PORT),a			; Clear UART
	xor	a
	; Start testing speed 0
	ld	(ESP_UART_SPEED),a
SET_BAUD:
	out	(OUT_CMD_PORT),a			; Send the command to change the speed of interface
	ld	a,CMD_QUERY_ESP
	; Wait until next interrupt
	halt
	out	(OUT_TX_PORT),a				; Send the query command
	ld	ix,RSP_CMD_QUERY_ESP		; Command used
	ld	a,RSP_CMD_QUERY_ESP_SIZE	; Size
	ld	bc,60						; Response Expected in up to 60 ticks
	call	WAIT_RESPONSE_FROM_ESP
	; If A = 0 success, else, failure
	or	a
	; If found, done
	ret	z
	; Not found, get the current speed
	ld	a,(ESP_UART_SPEED)
	; Increase
	inc	a
	; Save back to memory
	ld	(ESP_UART_SPEED),a
	; Let's check if it is past 7
	ld	c,10
	cp	c
	; No, so try again the new speed
	jr	nz,SET_BAUD
	; It is, so mark in speed that no good speed was found
	ld	a,#FF
	ld	(ESP_UART_SPEED),a
	; DONE
	ret

;*********************************************
;***              RESET ESP                ***
;*** If RESET ok, A will be 0, otherwise   ***
;*** failure							   ***
;*********************************************
RESET_ESP:
	ld	a,CMD_RESET_ESP
	out	(OUT_TX_PORT),a
	ld	ix,RSP_CMD_RESET_ESP		; Expected response
	ld	bc,180						; Up to 3s @ 60Hz
	ld	a,RSP_CMD_RESET_ESP_SIZE	; Size of response
	call	WAIT_RESPONSE_FROM_ESP
	ret	nz
VER_ESP:
	halt
	ld	a,CMD_GET_ESP_VER
	out	(OUT_TX_PORT),a				; Send the command
VER_ESP_ST1:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	z,VER_ESP_ST1
	; nz, check the data
	in	a,(IN_DATA_PORT)
	cp	CMD_GET_ESP_VER				; Is response of our command?
	jr	nz,VER_ESP_ST1
	; now get version, 2 bytes
VER_ESP_GET_VP:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	z,VER_ESP_GET_VP
	; nz, discard
	in	a,(IN_DATA_PORT)
	ld	(ROM_V_P),a
	ld	(RX_RETRY_SUPPORTED),a		; if version is greater than 0.?, supports it
	add	a,'0'
	ld	(OK_S+37),a
VER_ESP_GET_VS:
	in	a,(IN_STS_PORT)
	bit	0,a							; if nz has data
	jr	z,VER_ESP_GET_VS
	; nz, discard
	in	a,(IN_DATA_PORT)
	ld	(ROM_V_S),a
	add	a,'0'
	ld	(OK_S+39),a
	xor	a
	ret

;*********************************************
;***    ESP Specific Commands/Responses    ***
;*********************************************
; Warm reset of ESP firmware
CMD_RESET_ESP			equ	'R'
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

;*********************************************
;***         Auxiliary variables           ***
;*********************************************
; Store the SPEED uart is working
ESP_UART_SPEED			db	0
TIMEOUT_COUNTER			dw	0
RX_RETRY_COUNTER		db	3
RX_RETRY_SUPPORTED		db	0
UNAPI_FIRST_BYTE_PARAM	db	0
TCPIP_UDP_RCV_ADDRESS	dw	0

;============================
;===  UNAPI related data  ===
;============================

; This data is setup at installation time

MY_SLOT:				db	0
MY_SEG:					db	0
;--- Specification identifier (up to 15 chars)

UNAPI_ID:				db	"TCP/IP",0
UNAPI_ID_END:

;--- Implementation name (up to 63 chars and zero terminated)

APIINFO:				db	"ESP8266 WiFi UNAPI",0

ROM_V_P					db	0
ROM_V_S					db	0

SEG_CODE_END:
; We will be in a segment of our own, running from 0x4000 to 0x7FFF
; Use this to check, if this is beyond #7FFF, code is too fat and won't fit
; 16K segment, so need to re-design it to fit into the segment
LAST_RAM_BYTE_USED		equ	SEG_CODE_END