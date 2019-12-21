; MSX-SM TCP/IP UNAPI Driver v.0.7
; Oduvaldo Pavan Junior
; ducasp@gmail.com
;    This code implements TCP/IP UNAPI Specification for MSX-SM
;
; Pieces of this code were based on DENYOTCP.ASM (Denyonet ROM)
; made by Konamiman
;


;*******************
;***  CONSTANTS  ***
;*******************

;--- System variables and routines

_TERM0: equ #00
_STROUT: equ #09
_CONOUT: equ #02

ENASLT:	equ	#0024
EXTBIO:	equ	#FFCA
ARG:	equ	#F847
H_KEYI:	equ	#FD9A
JIFFY:	equ #FC9E

macro PUTCHAR myChar
	push af
	push bc
	push de
	push hl
	push ix
	push iy
	ld c,_CONOUT
	ld e,myChar
	call 5
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
endmacro

;--- API version and implementation version

API_V_P:	equ	1
API_V_S:	equ	0
ROM_V_P:	equ	0
ROM_V_S:	equ	8

;--- Maximum number of available standard and implementation-specific function numbers

;Must be 0 to 127
MAX_FN:		equ	29

;Must be either zero (if no implementation-specific functions available), or 128 to 254
MAX_IMPFN:	equ	0

;--- TCP/IP UNAPI error codes

ERR_OK:				equ	0
ERR_NOT_IMP:		equ	1
ERR_NO_NETWORK:		equ	2
ERR_NO_DATA:		equ	3
ERR_INV_PARAM:		equ	4
ERR_QUERY_EXISTS:	equ	5
ERR_INV_IP:			equ	6
ERR_NO_DNS:			equ	7
ERR_DNS:			equ	8
ERR_NO_FREE_CONN:	equ	9
ERR_CONN_EXISTS:	equ	10
ERR_NO_CONN:		equ	11
ERR_CONN_STATE:		equ	12
ERR_BUFFER:			equ	13
ERR_LARGE_DGRAM:	equ	14
ERR_INV_OPER:		equ	15

;--- TCP/IP UNAPI connection Status
UNAPI_TCPIP_NS_CLOSED equ 0
UNAPI_TCPIP_NS_OPENING equ 1
UNAPI_TCPIP_NS_OPEN equ 2
UNAPI_TCPIP_NS_UNKNOWN equ 255


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

	ld	a,(PRIM_SLOT)
	or	%00100000	;Try primary mapper, then try others
	ld	b,a
	ld	a,1		;System segment
	call	ALL_SEG
	jr	nc,ALLOC_OK

	ld	de,NOFREE_S	;Terminate if no free segments available
	ld	c,_STROUT
	call	5
	ld	c,_TERM0
	jp	5

ALLOC_OK:
	ld	(ALLOC_SEG),a
	ld	a,b
	ld	(ALLOC_SLOT),a

	;--- Switch segment, copy code, and setup data

	call	GET_P1		;Backup current segment
	ld	(P1_SEG),a

	ld	a,(ALLOC_SLOT)	;Switch slot and segment
	ld	h,#40
	call	ENASLT
	ld	a,(ALLOC_SEG)
	call	PUT_P1

	ld	hl,#4000	;Clear the segment first
	ld	de,#4001
	ld	bc,#4000-1
	ld	(hl),0
	ldir

	ld	hl,SEG_CODE	;Copy the code to the segment
	ld	de,#4000
	ld	bc,SEG_CODE_END-SEG_CODE_START
	ldir

	ld	hl,(ALLOC_SLOT)	;Setup slot and segment information
	ld	(MY_SLOT),hl

	;* Now backup and patch the H_KEYI hook
	;  so that it calls our address for interruptions

	ld	hl,H_KEYI
	ld	de,OLD_HKEY_I
	ld	bc,5
	ldir
	; Clear FIFO, so we start clean and do not get garbage
	ld a,20
	out (6),a

	di
	ld	a,#CD	;Code for "CALL"
	ld	(H_KEYI),a
	ld	hl,(HELPER_ADD)
	ld	bc,6
	add	hl,bc	;Now HL points to segment call routine
	ld	(H_KEYI+1),hl

	ld	hl,(MAPTAB_ADD)
	ld	a,(ALLOC_SLOT)
	ld	d,a
	ld	e,0	;Index on mappers table
SRCHMAPK:
	ld	a,(hl)
	cp	d
	jr	z,MAPFNDK
	inc	hl
	inc	hl	;Next table entry
	inc	e
	jr	SRCHMAPK
MAPFNDK:
	ld	a,e	;A = Index of slot on mappers table
	rrca
	rrca
	and	%11000000	;Entry point #400f = index 5
	or %00000101
	ld	(H_KEYI+3),a

	ld	a,(ALLOC_SEG)
	ld	(H_KEYI+4),a
	ei
	
	;* Now backup and patch the EXTBIO hook
	;  so that it calls address #4000 of the allocated segment

	ld	hl,EXTBIO
	ld	de,OLD_EXTBIO
	ld	bc,5
	ldir

	di
	ld	a,#CD	;Code for "CALL"
	ld	(EXTBIO),a
	ld	hl,(HELPER_ADD)
	ld	bc,6
	add	hl,bc	;Now HL points to segment call routine
	ld	(EXTBIO+1),hl

	ld	hl,(MAPTAB_ADD)
	ld	a,(ALLOC_SLOT)
	ld	d,a
	ld	e,0	;Index on mappers table
SRCHMAP:
	ld	a,(hl)
	cp	d
	jr	z,MAPFND
	inc	hl
	inc	hl	;Next table entry
	inc	e
	jr	SRCHMAP
MAPFND:
	ld	a,e	;A = Index of slot on mappers table
	rrca
	rrca
	and	%11000000	;Entry point #4000 = index 0
	ld	(EXTBIO+3),a

	ld	a,(ALLOC_SEG)
	ld	(EXTBIO+4),a
	ei
	
	; Now turn on interrupts
	ld a,23
	out (6),a
	
	;--- Check if ESP is present 
	call CHECK_BAUD
	;--- Save return
	ld (TEMP_RET),a
	cp #ff	
	jp z,LOAD_RESTORE_SS
	;--- If could set BAUD, ESP is good, so let's initialize it
	call RESET_ESP
	cp #0
	jr z,LOAD_ESP_RST_OK
	;--- Error during reset
	ld a,#ff
	ld (TEMP_RET),a ;Indicate error so proper msg will be shown
	jr LOAD_RESTORE_SS
LOAD_ESP_RST_OK:	
	halt
	call ECHO_OFF_ESP
	cp #0
	jr z,ECHO_OFF_OK
	;--- Error during command
	ld a,#ff
	ld (TEMP_RET),a ;Indicate error so proper msg will be shown
	jr LOAD_RESTORE_SS
ECHO_OFF_OK:
	halt
	;--- Now set ESP Mode properly
	call SET_ESP_MODE
	cp #0
	jr z,LOAD_ESP_SETMODE_OK
	;--- Error during command
	ld a,#ff
	ld (TEMP_RET),a ;Indicate error so proper msg will be shown
	jr LOAD_RESTORE_SS
LOAD_ESP_SETMODE_OK:
	halt
	;--- Now do not allow ESP to sleep
	call SET_ESP_NO_SLEEP
	cp #0
	jr z,LOAD_ESP_NOSLEEP_OK
	;--- Error during command
	ld a,#ff
	ld (TEMP_RET),a ;Indicate error so proper msg will be shown
	jr LOAD_RESTORE_SS
LOAD_ESP_NOSLEEP_OK:
	halt
	;--- Now set ESP to use multiple connections
	call SET_ESP_MULTIPLE_CONN
	cp #0
	jr z,LOAD_ESP_SETMULTCONN_OK
	;--- Error during command
	ld a,#ff
	ld (TEMP_RET),a ;Indicate error so proper msg will be shown
	jr LOAD_RESTORE_SS
LOAD_ESP_SETMULTCONN_OK:	
;	halt
;	;--- Now set ESP to respond to APLIST only w/ data relevant to us
;	call SET_ESP_APLIST_MODE
;	cp #0
;	jr z,LOAD_ESP_SETAPLIST_OK
;	;--- Error during command
;	ld a,#ff
;	ld (TEMP_RET),a ;Indicate error so proper msg will be shown
;	jr LOAD_RESTORE_SS
;LOAD_ESP_SETAPLIST_OK:	
	halt
	;--- Now set ESP to respond the origin (IP and Port) of data received
	; This info is needed for UDP connections
	call SET_ESP_IPD_EXTRA_INFO
	cp #0
	jr z,LOAD_ESP_SETIPDINFO_OK
	;--- Error during command
	ld a,#ff
	ld (TEMP_RET),a ;Indicate error so proper msg will be shown
	jr LOAD_RESTORE_SS
LOAD_ESP_SETIPDINFO_OK:
	halt
	;--- Now set ESP to passive TCP receiving mode
	; This info is needed for UDP connections
	call SET_ESP_PASSIVE_RCV
	cp #0
	jr z,LOAD_ESP_SETPASSIVERCV_OK
	;--- Error during command
	ld a,#ff
	ld (TEMP_RET),a ;Indicate error so proper msg will be shown
	jr LOAD_RESTORE_SS	

LOAD_ESP_SETPASSIVERCV_OK:

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


;****************************************************
;***  DATA AND STRINGS FOR THE INSTALLATION CODE  ***
;****************************************************

	;--- Variables

PRIM_SLOT:	db	0	;Primary mapper slot number
P1_SEG:	db	0		;Segment number for TPA on page 1
ALLOC_SLOT:	db	0	;Slot for the allocated segment
ALLOC_SEG:	db	0	;Allocated segment
HELPER_ADD:	dw	0	;Address of the RAM helper jump table
MAPTAB_ADD:	dw	0	;Address of the RAM helper mappers table
IMPLEM_ENTRY:	dw	0	;Entry point for implementations
TEMP_RET:	db	0	;Store return values from the mapper page

	;--- DOS 2 mapper support routines

ALL_SEG:	ds	3
FRE_SEG:	ds	3
RD_SEG:	ds	3
WR_SEG:	ds	3
CAL_SEG:	ds	3
CALLS:	ds	3
PUT_PH:	ds	3
GET_PH:	ds	3
PUT_P0:	ds	3
GET_P0:	ds	3
PUT_P1:	out	(#FD),a
	ret
GET_P1:	in	a,(#FD)
	ret
PUT_P2:	ds	3
GET_P2:	ds	3
PUT_P3:	ds	3

	;--- Strings

WELCOME_S:
	db	"MSX-SM TCP/IP UNAPI Driver v",'0'+ROM_V_P,".",'0'+ROM_V_S,13,10
	db	"(c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com",13,10
	db	13,10
	db	"$"

NOHELPER_S:
	db	"*** ERROR: No UNAPI RAM helper is installed",13,10,"$"

NOMAPPER_S:
	db	"*** ERROR: No mapped RAM found",13,10,"$"

NOFREE_S:
	db	"*** ERROR: Could not allocate any RAM segment",13,10,"$"

OK_S:	db	"Installed successfully.",13,10,"$"

FAIL_S:	db	"ESP Not Found.",13,10,"$"

ALINST_S:	db	"*** Already installed.",13,10,"$"

;*********************************************
;***  CODE TO BE INSTALLED ON RAM SEGMENT  ***
;*********************************************

SEG_CODE:
	org	#4000
SEG_CODE_START:


	;===============================
	;===  EXTBIO hook execution  ===
	;===============================

	;>>> Note that this code starts exactly at address #4000

DO_EXTBIO:
	push	hl
	push	bc
	push	af
	ld	a,d
	cp	#22
	jr	nz,JUMP_OLD
	cp	e
	jr	nz,JUMP_OLD
	jr	UNAPI_GO
	;place holder so DO_HKEY_I starts at 0x400F, 
	;ram helper can call it at fifth jump table position
	nop
	nop

DO_HKEY_I:
	jp MY_INTERRUPT_HANDLER
	
UNAPI_GO:
	;Check API ID

	ld	hl,UNAPI_ID
	ld	de,ARG
LOOP:	ld	a,(de)
	call	TOUPPER
	cp	(hl)
	jr	nz,JUMP_OLD2
	inc	hl
	inc	de
	or	a
	jr	nz,LOOP

	;A=255: Jump to old hook

	pop	af
	push	af
	inc	a
	jr	z,JUMP_OLD2

	;A=0: B=B+1 and jump to old hook

	pop	af
	pop	bc
	or	a
	jr	nz,DO_EXTBIO2
	inc	b
	pop	hl
	ld	de,#2222
	jp	OLD_EXTBIO
DO_EXTBIO2:

	;A=1: Return A=Slot, B=Segment, HL=UNAPI entry address

	dec	a
	jr	nz,DO_EXTBIO3
	pop	hl
	ld	a,(MY_SEG)
	ld	b,a
	ld	a,(MY_SLOT)
	ld	hl,UNAPI_ENTRY
	ld	de,#2222
	ret

	;A>1: A=A-1, and jump to old hook

DO_EXTBIO3:	;A=A-1 already done
	pop	hl
	ld	de,#2222
	jp	OLD_EXTBIO


	;--- Jump here to execute old EXTBIO code

JUMP_OLD2:
	ld	de,#2222
JUMP_OLD:	;Assumes "push hl,bc,af" done
	pop	af
	pop	bc
	pop	hl

	;Old EXTBIO hook contents is here
	;(it is setup at installation time)

OLD_EXTBIO:
	ds	5

	;Old HKEY_I hook contents is here
	;(it is setup at installation time)	
OLD_HKEY_I:
	ds	5

	;====================================
	;===  Functions entry point code  ===
	;====================================

UNAPI_ENTRY:
	push	hl
	push	af
	; EXTBIO disables interrupts, we need those, re-enable so we won't get stuck
	; waiting for JIFFY or other interrupt driven stuff
	ei
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
FN_128:	dw	FN_DUMMY

	endif

FN_TABLE:
FN_0:	dw	UNAPI_GET_INFO
FN_1:	dw	TCPIP_GET_CAPAB
FN_2:	dw	TCPIP_GET_IPINFO
FN_3:	dw	TCPIP_NET_STATE
FN_4:	dw	FN_NOT_IMP ;TCPIP_SEND_ECHO not going to be implemented, ESP do not support ping like UNAPI specify
FN_5:	dw	FN_NOT_IMP ;TCPIP_RCV_ECHO not going to be implemented as SEND_ECHO is not implemented
FN_6:	dw	TCPIP_DNS_Q
FN_7:	dw	TCPIP_DNS_S
FN_8:	dw	TCPIP_UDP_OPEN
FN_9:	dw	TCPIP_UDP_CLOSE
FN_10:	dw	TCPIP_UDP_STATE
FN_11:	dw	TCPIP_UDP_SEND
FN_12:	dw	TCPIP_UDP_RCV
FN_13:	dw	TCPIP_TCP_OPEN
FN_14:	dw	TCPIP_TCP_CLOSE
FN_15:	dw	TCPIP_TCP_ABORT
FN_16:	dw	TCPIP_TCP_STATE
FN_17:	dw	TCPIP_TCP_SEND
FN_18:	dw	TCPIP_TCP_RCV
FN_19:	dw	FN_NOT_IMP	;TCPIP_TCP_FLUSH makes no sense as we do not use buffers to send, any buffer is internal to ESP and we can't delete
FN_20:	dw	FN_NOT_IMP	;TCPIP_RAW_OPEN not going to be implemented, ESP do not support RAW connections
FN_21:	dw	FN_NOT_IMP	;TCPIP_RAW_CLOSE not going to be implemented, ESP do not support RAW connections
FN_22:	dw	FN_NOT_IMP	;TCPIP_RAW_STATE not going to be implemented, ESP do not support RAW connections
FN_23:	dw	FN_NOT_IMP	;TCPIP_RAW_SEND not going to be implemented, ESP do not support RAW connections
FN_24:	dw	FN_NOT_IMP	;TCPIP_RAW_RCV not going to be implemented, ESP do not support RAW connections
FN_25:	dw	FN_NOT_IMP	;TCPIP_CONFIG_AUTOIP
FN_26:	dw	FN_NOT_IMP	;TCPIP_CONFIG_IP
FN_27:	dw	TCPIP_CONFIG_TTL
FN_28:	dw	TCPIP_CONFIG_PING
FN_29:	dw	END_OK	;TCPIP_WAIT not needed for our implementation, it lives on interrupts generated by hardware


	;========================
	;===  Functions code  ===
	;========================

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


TCPIP_GET_CAPAB:
	ld	a,b
	or	a
	jp	z,END_INV_PAR
	cp	3+1
	jp	nc,END_INV_PAR

	dec	a
	jr	z,GETCAP_1
	dec	a
	jr	z,GETCAP_2

	;--- Info block 3

GETCAP_3:
	ld	hl,1500	;MSX-SM FIFO Size less some protocol stuff
	ld	de,2048	;ESP AT+CIPSEND supports up to 2048 bytes, it will fragment as needed
	xor	a
	ret

	;--- Info block 2

GETCAP_2:
	ld	bc,#0404
	ld  a,(ESP_FREE_CONNECTIONS)
	ld	d,a
	ld	e,a
	ld	hl,0
	xor a
	ret

	;--- Info block 1

GETCAP_1:

	; Capability flags ENABLED:	
	; 2 - Resolve host names by querying a DNS server
	; 3 - Open TCP connections in active mode
	; 5 - Open TCP connections in passive mode w/o specified remote socket
	;10 - Open UDP connections	
	;14 - Automatically obtain the IP addresses, by using DHCP or an equivalent protocol
	
	; Capability flags DISABLED:
	; 0 - Send ICMP echo messages (PINGs) and retrieve the answers
	; 1 - Resolve host names by querying local host file or database
	; 4 - Open TCP connections in passive mode with specified remote socket	
	; 6 - Send and receive TCP urgent data
	; 7 - Explicitly set the PUSH bit when sending TCP data
	; 8 - Send data to a TCP connection before the ESTABLISHED state is reached
	; 9 - Flush the output buffers of a TCP connection
	;11 - Open RAW IP connections
	;12 - Explicitly set the TTL and TOS for outgoing datagrams
	;13 - Explicitly set the TTL and TOS for outgoing datagrams	
	;15 - Unused by current TCP/IP UNAPI specification

	ld	hl,%0100010000101100

	; Features flags ENABLED:
	; 1 - Physical link is wireless
	; 2 - Connection pool is shared by TCP, UDP and raw IP
	; 4 - The TCP/IP handling code is assisted by external hardware

	ld	de,%0000000010010110

	ld	b,3	;Ethernet protocol
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
	;First check if we have current LOCAL IP info and LOCAL PDNS/SDNS info
	push bc
	ld a,(LOCAL_CURRENT)
	or a
	; If Info not current, so let's update it	
	call z,GET_ESP_IP_CONF
	halt ;just give some time so ESP will not error the next command
	ld a,(LOCAL_D_CURRENT)
	or a
	; If DNS Info not current, so let's update it
	call z,GET_ESP_DNS_CONF	

TCPIP_GET_IPINFO2:	
	pop bc
	ld	a,b
	or	a
	jp	z,END_INV_PAR	

	dec	a	
	jr	nz,GETIP_NO1
	;--- Local IP address
	ld	hl,(LOCAL_IP)
	ld	de,(LOCAL_IP+2)
	xor	a
	ret
	
GETIP_NO1:	

	dec	a
	;--- Peer IP address
	jp	z,END_INV_PAR
	
	dec	a
	jr	nz,GETIP_NO3
	;--- Subnet mask
	ld	hl,(LOCAL_NETMASK)
	ld	de,(LOCAL_NETMASK+2)
	xor	a
	ret
GETIP_NO3:
	
	dec	a
	jr	nz,GETIP_NO4
	;--- Default gateway
	ld	hl,(LOCAL_GATEWAY)
	ld	de,(LOCAL_GATEWAY+2)
	xor	a
	ret
GETIP_NO4:

	dec	a
	jr	nz,GETIP_NO5
	;--- Primary DNS
	ld	hl,(LOCAL_PDNS)
	ld	de,(LOCAL_PDNS+2)
	xor	a
	ret
GETIP_NO5:
	
	dec	a
	;--- Secondary DNS
	ld	hl,(LOCAL_SDNS)
	ld	de,(LOCAL_SDNS+2)
	xor	a
	ret

END_NO_CONN:
	ld	a,ERR_NO_CONN
	ret

END_ERR_NO_DATA:
	ld	a,ERR_NO_DATA
	ret

END_NO_NETWORK:
	ld	a,ERR_NO_NETWORK
	ret

END_INV_PAR:
	ld	a,ERR_INV_PARAM
	ret
	
END_OK:
	xor a
	ret

FN_NOT_IMP:
	ld	a,ERR_NOT_IMP
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

	ld	a,(ESP_CONNECTION_STATE)
	ld b,a
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
	or a ;--- DNS Query In progress?
	jr nz,DNS_Q_CANCEL_WAIT
	;--- Not anymore, good to go
	xor a
	ld (DNS_READY),a ;discard dns information, if any
	ret
	
DNS_Q_NO_CANCEL:
	;--- If there is a query in progress and
	;    B:2 is set, return an error
	bit	2,b
	jr	z,DNS_Q_NO_EXISTING	
	ld	a,(ESP_DNS_INPROGRESS)
	or	a ;--- DNS Query In progress?
	jr	z,DNS_Q_NO_EXISTING
	ld	a,ERR_QUERY_EXISTS
	ret
	
DNS_Q_NO_EXISTING:
	;--- We can't cancel DNS request, so if in progress need to wait
	ld	a,(ESP_DNS_INPROGRESS)
	or a ;--- DNS Query In progress?
	jr nz,DNS_Q_NO_EXISTING
	xor a
	ld (DNS_READY),a ;discard dns information, if any
	;--- Ok, start from scratch
	push bc
	;--- Copy the host name to our internal buffer
	;--- The origin is in HL
	ld de,DNS_BUFFER
	ld b,255 ; this is the limit, can use up to 255 bytes long
	ld c,0 ; Our counter of how many bytes host information has
DNS_Q_COPYSTART:		
	; Why the heck do this instead of LDIR? 
	; We will need to know how much bytes to send to ESP anyway
	; Also, this way we can limit how much will be transferred,
	; if byte is terminator, and count while transferring...
	; LDI / LDIR might save some cycles but would add complexity
	ld a,(hl) ;HL -> host name to resolve, get from it
	ld (de),a ;DE -> DNS_BUFFER, transfer to it
	or a ;is it a zero? (string termination)
	jr z,DNS_Q_COPYEND ; if so, done copying
	inc de ;increment destination pointer
	inc hl ;increment source pointer
	inc c ; increment counter
	dec b ; decrement limiter
	jr z,DNS_Q_COPYEND ; if hit our limit, end
	jr DNS_Q_COPYSTART ;continue copying
	; Hostname in DNS_BUFFER, it's size in C
DNS_Q_COPYEND:	
	xor a ; a = 0
	inc de ;increment destination pointer
	ld (de),a ;terminate the string so PARSE_IP work fine
	ld a,c ;size
	ld (DNS_BUFFER_DATA_SIZE),a ;save the count of bytes copied
	ld de,DNS_RESULT ;Want to store results in DNS_RESULT
	
	;--- Try to parse the host name as an IP address
	call PARSE_IP
	pop bc ; restore b, it contains the flags commanding our operation
	jr c,DNSQ_NO_IP ;if carry, it is not an IP, so need to resolve
	;--- It was an IP address
	ld a,1
	ld (DNS_READY),a ; DNS done
	ld	hl,(DNS_RESULT)
	ld	de,(DNS_RESULT+2)
	ld	b,1
	xor	a
	ret

	;--- The host name was not an IP address
DNSQ_NO_IP:
	bit	1,b	;Was "assume IP address" flag set?
	ld	a,ERR_INV_IP ;if it was and it is not IP address, error
	ret	nz ;bit 1 is set? If so, address should have been an IP not host name, error
	;--- No problem, no assumption that it is an IP address
	;--- Check network connection, no connection, no DNS...
	ld a,(ESP_CONNECTION_STATE)
	ld b,UNAPI_TCPIP_NS_OPEN
	cp b
	ld	a,ERR_NO_NETWORK
	;--- If state is not open, no network
	ret	nz

	;Here we send the query and set the proper status so
	;our interrupt handler will catch the result 
	; otir will output in the port in C
	ld c,7 ;our data TX port
	ld hl,CMD_ESP_DNS_RESOLVE ;command to request DNS resolving
	; Port in C, command in HL, move size to B	
	ld b,CMD_ESP_DNS_RESOLVE_SIZE
	; send it
	;otir
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
DNSQ_NO_IP_WT_SND:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,DNSQ_NO_IP_WT_SND
	outi
	jr nz,DNSQ_NO_IP_WT_SND
	
	;Now send the host that is saved in DNS_BUFFER
	ld hl,DNS_BUFFER ;hostname
	ld a,(DNS_BUFFER_DATA_SIZE);get size of hostname
	ld b,a ;size of transfer in B
	;send it
	;otir	
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
DNSQ_NO_IP_WT_SND2:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,DNSQ_NO_IP_WT_SND2
	outi
	jr nz,DNSQ_NO_IP_WT_SND2
	;and now send the last three bytes, '"', 13 and 10
	ld a,'"'
	out (c),a
	ld a,13
	out (c),a
	; Just before we send the last byte that will trigger the query,
	; flag that a DNS query is in progress
	ld	a,1
	ld (ESP_DNS_INPROGRESS),a
	;and send the last byte
	ld a,10
	out (c),a	
	;DNS query sent, our job is done!
	xor a
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
	or	a ;--- DNS Query In progress?
	jr z,TCPIP_DNS_S_NOQIP ; No
	; Yes
	xor a
	ld b,1 ;--- query in progress
	ld c,a ;--- we don't know what goes on ESP, it is automatic
	ret

TCPIP_DNS_S_NOQIP:
	;--- It is not in progress, but, is there a result?
	ld a,(DNS_READY) ; DNS done?
	or a
	jr z,TCPIP_DNS_S_NORESULT ; No DNS result
	;--- Ok, we have a result, is it success?
	dec a
	jr z,TCPIP_DNS_S_HASRESULT ; If it is 1, it was not an error
	;--- Shoot, there is an error....
	;--- And sure thing, ESP do not tell us details, it is always failure :-P
	bit 0,b ;--- clear error after this?	
	jr z,TCP_IP_DNS_S_NOCLR
	;--- Clear
	ld b,0 ;--- Like I've said, no details
	xor a
	ld (DNS_READY),a ; DNS not done
	ld a,ERR_DNS;
	ret
TCP_IP_DNS_S_NOCLR:	
	;--- Don't clear
	ld a,ERR_DNS	
	ld b,0 ;--- Like I've said, no details
	ret
	;--- There is a result available...
TCPIP_DNS_S_HASRESULT:
	;--- Copy the result
	ld	hl,(DNS_RESULT)
	ld	de,(DNS_RESULT+2)
	xor a
	bit 0,b ;--- clear result after this?
	jr z,TCP_IP_DNS_S_RES_NOCLR ;--- no, just return
	;--- Yes, clear
	ld (DNS_READY),a ; DNS not done
TCP_IP_DNS_S_RES_NOCLR:
	ld b,2
	ret

TCPIP_DNS_S_NORESULT:	
	xor a ;--- OK no query in progress, no result, means nothing in progress
	ld b,0 ;--- No query in progress
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
	;Available free connections?
	ld a,(ESP_FREE_CONNECTIONS)
	or a
	ld a,ERR_NO_FREE_CONN
	ret z ;if zero free connections, can't do it
	
	;Check network connection
	ld a,(ESP_CONNECTION_STATE)
	ld c,UNAPI_TCPIP_NS_OPEN
	cp c
	ld a,ERR_NO_NETWORK
	ret nz;if not zero, no network connection

	;Check port number
	ld a,h
	or l
	ld a,ERR_INV_PARAM
	ret z ;if 0, not ok
	ld a,b
	and %11111110
	ld a,ERR_INV_PARAM ;if not 0 or 1, not ok for transient
	ret nz
	
	push bc ;save B
	ld a,h
	and l
	cp #FF 
	call z,GET_RANDOM_PORT ;if FFFF, means we should generate a random port number
	pop bc ;restore B

	ld	a,h
	inc	a
	jr	nz,OK_UDPOP_PORT ;if MSB not FF, can continue
	ld	a,l
	and	#F0
	cp	#F0
	ld	a,ERR_INV_PARAM 
	ret	z ;MSB is FF, then LSB can't be F0-FF
	
;Port # is valid	
OK_UDPOP_PORT:
	call CHECK_PORT_IN_USE
	or a
	ret nz
	
	;Open UDP connection
	;HL has the port number
	;B tells whether it is transient or not
	call OPEN_UDP	
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
	ld a,1
	ld (CC_TYPE_IS_UDP),a
	call CLOSE_CONN
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
	ld	a,b
	or	a
	ld	a,ERR_NO_CONN
	ret	z

	ld	a,b
	cp	4+1
	ld	a,ERR_NO_CONN
	ret	nc
	
	ld	a,b
	ld ix,CONN1_BUFFER_VARS
	ld de,CONN1_BUFF
	dec a ; Conn 1?
	jr z,TCPIP_UDP_STATE_C ; Yes
	
	ld ix,CONN2_BUFFER_VARS
	ld de,CONN2_BUFF
	dec a ; Conn 2?
	jr z,TCPIP_UDP_STATE_C ; Yes
	
	ld ix,CONN3_BUFFER_VARS
	ld de,CONN3_BUFF
	dec a ; Conn 3?
	jr z,TCPIP_UDP_STATE_C ; Yes
	
	; Otherwise is 4	
	ld ix,CONN4_BUFFER_VARS
	ld de,CONN4_BUFF
	
TCPIP_UDP_STATE_C:	
	; Check if connection is UDP
	xor a
	cp (ix+6) ;UDP?
	ld a,ERR_NO_CONN
	ret z ;if 0, not udp, so no connection to close	

	; Check if connection is Opened
	xor a
	cp (ix+11) ;Opened?
	ld a,ERR_NO_CONN
	ret z ;if 0, not opened, so no connection to close
	
	ld l,(ix+4) ; Bottom, contains the oldest datagram size in its 2 bytes
	ld h,(ix+5) ; Bottom, contains the oldest datagram size in its 2 bytes
	add hl,de ; Now HL is pointing to buffer bottom, 2 first bytes are size of oldest datagram
	ld e,(hl)
	inc hl
	ld d,(hl) ; Ok, now DE has the size of oldest datagram

	ld b,(ix+7) ; Pending Datagram Count		
	ld l,(ix+9) ; Local Port #
	ld h,(ix+10) ; Local Port #
	xor a
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
	ld	a,b
	or	a
	ld	a,ERR_NO_CONN
	ret	z

	ld	a,b
	cp	4+1
	ld	a,ERR_NO_CONN
	ret	nc

	ld	a,b
	ld ix,CONN1_BUFFER_VARS
	dec a ; Conn 1?
	jr z,TCPIP_UDP_SEND_C ; Yes
	
	ld ix,CONN2_BUFFER_VARS
	dec a ; Conn 2?
	jr z,TCPIP_UDP_SEND_C ; Yes
	
	ld ix,CONN3_BUFFER_VARS
	dec a ; Conn 3?
	jr z,TCPIP_UDP_SEND_C ; Yes
	
	; Otherwise is 4	
	ld ix,CONN4_BUFFER_VARS
	
TCPIP_UDP_SEND_C:	
	; Check if connection is UDP
	xor a
	cp (ix+6) ;UDP?
	ld a,ERR_NO_CONN
	ret z ;if 0, not udp, so no connection to send data

	; Check if connection is Opened
	xor a
	cp (ix+11) ;Opened?
	ld a,ERR_NO_CONN
	ret z ;if 0, not opened, so no connection to close

	; Here is our strategy: First, send AT+CIPSEND=C,
	; Then send the data size in ASCII and a comma and a quote
	; Then send IP in ASCII, and a quote and a comma
	; Then send Port Number in ASCII, CR LF and wait for >
	; If > is received, just otir as many times as needed to send data	
	push hl ;save data address
	ld iyh,d ;Param blocks in iy
	ld iyl,e	
	ld e,(iy+6)
	ld d,(iy+7)
	ld hl,2048
	or a
	sbc hl,de
	jr nc,TCPIP_UDP_SEND_D
	; Carry means size > 2048, can't send, too large
	pop hl ; restore HL and fix stack
	ld a,ERR_LARGE_DGRAM
	ret
TCPIP_UDP_SEND_D:	
	push de ;save data size
	
	;STEP 1, start with connection # on command string
	ld a,'0'
	add a,b
	ld (CMD_ESP_SEND_CONN+11),a
	;Now send it using otir
	ld b,CMD_ESP_SEND_CONN_SIZE
	ld c,7 ;our data TX port
	ld hl,CMD_ESP_SEND_CONN
	;otir
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
TCPIP_UDP_SEND_D_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,TCPIP_UDP_SEND_D_WT
	outi
	jr nz,TCPIP_UDP_SEND_D_WT
	
	; STEP 2, send data size, comma and quote
	; Now "Print" size on memory (it won't be used while we are here anyway and can hold it fine)
	ld de,CMD_ESP_OPEN_UDP_CONN+33
	ld l,(iy+6) ;data size
	ld h,(iy+7)
	call NUM2DEC ;will output 5 ASCII characters starting at DE, representing value in HL (Port)
	; Done, so now let's discard 0's at the left
	ld hl,CMD_ESP_OPEN_UDP_CONN+33
	ld b,5 ;5 digits
	ld a,'0' ;looking for leading 0's
TCPIP_UDP_DISCARD_0:	
	cp (hl)
	jr nz,TCPIP_UDP_SEND_1 ;if not '0', done
	;it is, so discard
	inc hl
	dec b
	jr TCPIP_UDP_DISCARD_0	
TCPIP_UDP_SEND_1:	
	ld c,7
	; B contains number of digits and HL the first non 0, so, ready to send
	;otir
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
TCPIP_UDP_SEND_1_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,TCPIP_UDP_SEND_1_WT
	outi
	jr nz,TCPIP_UDP_SEND_1_WT
	
	ld a,','
	out (7),a
	ld a,'"'
	out (7),a
	
	;STEP 3, IP address in ASCII...
	call SEND_IP_ADDRESS ;IY points to start of IP address, routine will send it in ASCII form over ESP connection
	ld a,'"'
	out (7),a
	ld a,','
	out (7),a
	
	;STEP 4, Port in ASCII... ESP understand 00023, so this simplifies a lot
	ld de,CMD_ESP_OPEN_UDP_CONN+33
	ld l,(iy+4) ;port
	ld h,(iy+5)
	call NUM2DEC ;will output 5 ASCII characters starting at DE, representing value in HL (Port)		
	ld hl,CMD_ESP_OPEN_UDP_CONN+33
	ld c,7
	ld b,5
	;otir
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
TCPIP_UDP_SEND_2_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,TCPIP_UDP_SEND_2_WT
	outi
	jr nz,TCPIP_UDP_SEND_2_WT	
	
	;STEP 5, send CR LF and wait for '>'
	ld hl,CMD_ESP_SND ; CR LF
	ld d,CMD_ESP_SND_SIZE
	ld ix,CMD_ESP_SEND_CONN_RSP ;Response Expected
	ld e,CMD_ESP_SEND_CONN_RSP_SIZE
	ld c,10 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	or a
	ld a,ERR_NO_NETWORK
	pop de ;restore data size
	pop hl ;restore address of data to send
	ret nz ;if not 0, prompt did not show up
	call SEND_DATA ;send DE bytes starting at HL
	; data sent, return success
	xor a
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
TCPIP_UDP_RCV:
	ld	a,b
	or	a
	ld	a,ERR_NO_CONN
	ret	z

	ld	a,b
	cp	4+1
	ld	a,ERR_NO_CONN
	ret	nc

	ld	a,b
	ld ix,CONN1_BUFFER_VARS
	dec a ; Conn 1?
	jr z,TCPIP_UDP_RCV_C ; Yes
	
	ld ix,CONN2_BUFFER_VARS
	dec a ; Conn 2?
	jr z,TCPIP_UDP_RCV_C ; Yes
	
	ld ix,CONN3_BUFFER_VARS
	dec a ; Conn 3?
	jr z,TCPIP_UDP_RCV_C ; Yes
	
	; Otherwise is 4	
	ld ix,CONN4_BUFFER_VARS
	
TCPIP_UDP_RCV_C:	
	; Check if connection is UDP
	xor a
	cp (ix+6) ;UDP?
	ld a,ERR_NO_CONN
	ret z ;if 0, not udp, so no connection to get data
	ld a,(ix+7) ; Pending Datagram Count
	or a
	ld a,ERR_NO_DATA
	ret z
	; Ok, conn is or was UDP... And has at least one datagram, let's continue	
	; IX has the Buffer Variables, HL has address and DE the limit to save data, now save to buffer and done deal
	call GET_UDP_DATAGRAM_FROM_CONNECTION_BUFFER
	xor a
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
TCPOP_IP:	equ	TEMP
TCPOP_RPORT:	equ	TEMP+4
TCPOP_LPORT:	equ	TEMP+6
TCPOP_TOUT:	equ	TEMP+8	;Not used
TCPOP_FLAGS:	equ	TEMP+10
TCPIP_TCP_OPEN:
	;Check network connection
	ld a,(ESP_CONNECTION_STATE)
	ld b,UNAPI_TCPIP_NS_OPEN
	cp b
	ld a,ERR_NO_NETWORK
	ret nz;if not zero, no network connection
	
	;Available free connections?
	ld a,(ESP_FREE_CONNECTIONS)
	or a
	ld a,ERR_NO_FREE_CONN
	ret z ;if zero free connections, can't do it
	
	ld de,TCPOP_IP
	ld bc,11
	ldir ;move parameter block to our internal vars
	
	;--- Check flags

	ld	a,(TCPOP_FLAGS)
	ld	b,a
	and	%11111100 ;bits 7-2 not defined,
	ld	a,ERR_INV_PARAM
	ret	nz
	
	ld	a,b
	and 1
	; If nz, passive, else, active
	;--- Check IP address
	ld	hl,(TCPOP_IP)
	ld	de,(TCPOP_IP+2)
	ld	a,h
	; ok, if passive, flag expectation is different
	jr nz, CHECK_IP_PASSIVE
	; nope, active, so address CANT be 0.0.0.0	
	or	l
	or	d
	or	e
	ld	a,ERR_INV_PARAM	
	ret	z ; 0.0.0.0 is only for passive, other IP end can be anyone
	jr CHECK_IP_CHECKED
	; Passive check, MUST be 0.0.0.0
CHECK_IP_PASSIVE:
	or	l
	or	d
	or	e
	ld	a,ERR_INV_PARAM	
	ret	nz ; 0.0.0.0 must be the address for passive

CHECK_IP_CHECKED:
	;--- Generate random local port if necessary
	ld	hl,(TCPOP_LPORT)
	ld	a,h
	and	l
	cp	#FF
	jr	nz,TCPOP_NO_RANDPORT
	;ESP AT firmware won't allow setting local port, sorry, it is going to be random... :-)
	call	GET_RANDOM_PORT ;NEEDED for passive conn w/o local port declared
	ld	(TCPOP_LPORT),hl
	
TCPOP_NO_RANDPORT:
	; Check if same connection exists for active, for passive it has to be the same so do not care anyway
	ld	a,(TCPOP_FLAGS)
	and 1
	; If nz, passive, else, active
	jr nz,TCP_OP_JUST_OPEN
	; Load Remote Port in HL
	; Load IP in C.B E.D
	ld hl,(TCPOP_RPORT)
	ld bc,(TCPOP_IP)
	ld de,(TCPOP_IP+2)
	call CHECK_TCP_CONN_EXISTS
	or a
	; Return if not zero meaning not available
	ret nz
TCP_OP_JUST_OPEN:	
	; If here, all set to open connection
	call OPEN_TCP
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
	ld a,'0'
	ld (CC_CLOSE_TYPE),a
	xor a
	ld (CC_TYPE_IS_UDP),a
	call CLOSE_CONN
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
	ld a,'1'
	ld (CC_CLOSE_TYPE),a
	xor a
	ld (CC_TYPE_IS_UDP),a
	call CLOSE_CONN
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

TCPST_IP:		equ	TEMP
TCPST_RPORT:	equ	TEMP+4
TCPST_LPORT:	equ	TEMP+6
TCPST_STATE:	equ	TEMP+8
TCPST_BUFF_AVAILABLE dw 0
TCPST_CONN db 0
TCPST_PASSIVE db 0
TCPST_PASSIVE_CONNECTED db 0
TCPIP_TCP_STATE:	
	ld	a,b	
	ld (TCPST_CONN),a
	or	a
	ld	a,ERR_NO_CONN
	jp	z,TCPIP_TCPST_ERR_EX
	

	ld	a,b
	cp	4+1
	ld	a,ERR_NO_CONN
	jp	nc,TCPIP_TCPST_ERR_EX	

	ld	a,b
	ld ix,CONN1_BUFFER_VARS
	dec a ; Conn 1?
	jr z,TCPIP_TCPST_S ; Yes
	
	ld ix,CONN2_BUFFER_VARS
	dec a ; Conn 2?
	jr z,TCPIP_TCPST_S ; Yes
	
	ld ix,CONN3_BUFFER_VARS
	dec a ; Conn 3?
	jr z,TCPIP_TCPST_S ; Yes
	
	; Otherwise is 4	
	ld ix,CONN4_BUFFER_VARS

TCPIP_TCPST_S:		
	; Check if connection is TCP
	xor a
	cp (ix+6) ;UDP?
	ld a,ERR_NO_CONN
	jp nz,TCPIP_TCPST_ERR_EX ;if not 0, udp, so no connection to get data
	
	;First save some interesting stuff for later
	ld a,(ix+7)
	ld (TCPST_PASSIVE),a
	ld a,(ix+4)
	ld (TCPST_PASSIVE_CONNECTED),a
	
	; Get buffer available
	ld bc,2048 ;ESP allows up to 2048 per call
	; If in the future use the ESP send buffer...
	;
	;xor a
	;cp (ix+11) ;Open?
	;jr z,TCPIP_TCPST_NOT_OPEN
	; it is open, so let's get the buffer size
	;ld a,(TCPST_CONN)
	;push ix
	;push hl
	;call TCP_CONN_BUFFER_FREE ;BC will contain buffer free	
	;pop hl
	;pop ix
;TCPIP_TCPST_NOT_OPEN:
	ld (TCPST_BUFF_AVAILABLE),bc

	
	; check if HL is 0, if not, need to fulfill information block
	ld a,l
	or h
	jr z,TCPIP_TCPST_R
TCPIP_TCPST_G:
	; HL not zero, so move fill-in the data 
	;    +0 (4): Remote IP address
	;    +4 (2): Remote port
	;    +6 (2): Local port
	ld a,(ix+14)
	ld (hl),a
	inc hl
	ld a,(ix+15)
	ld (hl),a
	inc hl
	ld a,(ix+16)
	ld (hl),a
	inc hl
	ld a,(ix+17)
	ld (hl),a
	inc hl
	ld a,(ix+9)
	ld (hl),a
	inc hl
	ld a,(ix+10)
	ld (hl),a
	inc hl
	ld a,(ix+18)
	ld (hl),a
	inc hl
	ld a,(ix+19)
	ld (hl),a

TCPIP_TCPST_R:	
	; Ok, can get status...
	; Buffer Top hold the current # of bytes (we won't use internal buffers for TCP)
	ld l,(ix+2)
	ld h,(ix+3)	
	; no support for urgent data
	ld de,0
	ld b,(ix+5)
	; Unknown close reason state if closed		
	ld c,0	
	xor a	
	cp (ix+11) ;Open?
	ld a,ERR_NO_CONN
	ld ix,(TCPST_BUFF_AVAILABLE) ; 
	ret z; if 0, not open, bye	
	; Ok, open
	; Life Hack for apps that did not get other device quickly connecting and sending data
	; Check if there is data for our open passive connection, and even if it is no longer
	; Established , says so until it is closed or pending data is 0 
	; Now check if there is data (TOP = IX+2)
	ld a,h
	or l
	ret z ; if zero, return real connection status	
	; If here, has data, so, force established, many UNAPI apps do not read data of non-established connections
	xor a ;return 0
	ld b,4 ;connected / established

	ret

TCPIP_TCPST_ERR_EX:
	ld hl,0
	ld de,0
	ld b,0
	ld c,1
	;ld ix,2920 ;if using ESP send buffer
	ld ix,#ffff ;infinite, our usage guarantees ESP buffer is never full
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
TCPIP_TCP_SEND_DATA_ADDR dw 0
TCPIP_TCP_SEND_DATA_SIZE dw 0
TCPIP_TCP_SEND:
	; Copy connection #  just in case we are going to send
	ld a,b
	add a,'0'
	ld (CMD_ESP_SEND_CONN+11),a 
	;ld (CMD_ESP_SENDBUFF_CONN+14),a 
	; Ok, continue
	ld	a,b	
	or	a
	ld	a,ERR_NO_CONN
	ret	z

	ld	a,b
	cp	4+1
	ld	a,ERR_NO_CONN
	ret	nc

	ld	a,b
	ld ix,CONN1_BUFFER_VARS
	dec a ; Conn 1?
	jr z,TCPIP_TCPS_S ; Yes
	
	ld ix,CONN2_BUFFER_VARS
	dec a ; Conn 2?
	jr z,TCPIP_TCPS_S ; Yes
	
	ld ix,CONN3_BUFFER_VARS
	dec a ; Conn 3?
	jr z,TCPIP_TCPS_S ; Yes
	
	; Otherwise is 4	
	ld ix,CONN4_BUFFER_VARS
	
TCPIP_TCPS_S:
	xor a
	cp (ix+11) ;Open?
	ld	a,ERR_NO_CONN
	ret z ;nope
	; Yes.... First Save vars
	ld (TCPIP_TCP_SEND_DATA_ADDR),de
	ld (TCPIP_TCP_SEND_DATA_SIZE),hl
	; check if there is room in buffer for our data
	;push ix
	;call TCP_CONN_BUFFER_FREE ;BC will contain buffer free	
	;pop ix
	;ld h,b
	;ld l,c
	;ld de,(TCPIP_TCP_SEND_DATA_SIZE)
	;or a ;clr carry
	;sbc hl,de
	;ld a,ERR_BUFFER
	;ret c ;if carry, Buffer Free < Data to send
	
	; There is room, so move to ESP Buffer
	; Here is our strategy: First, send AT+CIPSEND=C,
	; Then send the data size in ASCII, CR LF and wait for >
	; If > is received, just oti as many times as needed to send data	

	;Step 1, send first part of command
	;Now send it using oti
	ld b,CMD_ESP_SEND_CONN_SIZE
	;ld b,CMD_ESP_SENDBUFF_CONN_SIZE
	ld c,7 ;our data TX port
	ld hl,CMD_ESP_SEND_CONN
	;ld hl,CMD_ESP_SENDBUFF_CONN
	;oti
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
TCPIP_TCPS_D_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,TCPIP_TCPS_D_WT
	outi
	jr nz,TCPIP_TCPS_D_WT
	
	; STEP 2, send data size
	; Now "Print" size on memory (it won't be used while we are here anyway and can hold it fine)
	ld de,CMD_ESP_OPEN_UDP_CONN+33
	ld hl,(TCPIP_TCP_SEND_DATA_SIZE);data size
	call NUM2DEC ;will output 5 ASCII characters starting at DE, representing value in HL (Data Size)
	; Done, so now let's discard 0's at the left
	ld hl,CMD_ESP_OPEN_UDP_CONN+33
	ld b,5 ;5 digits
	ld a,'0' ;looking for leading 0's
TCPIP_TCPS_DISCARD_0:	
	cp (hl)
	jr nz,TCPIP_TCPS_SEND_1 ;if not '0', done
	;it is, so discard
	inc hl
	dec b
	jr TCPIP_TCPS_DISCARD_0	
TCPIP_TCPS_SEND_1:	
	ld c,7
	; B contains number of digits and HL the first non 0, so, ready to send
	;oti
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
TCPIP_TCPS_SEND_1_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,TCPIP_TCPS_SEND_1_WT
	outi
	jr nz,TCPIP_TCPS_SEND_1_WT
	
	;STEP 3, send CR LF and wait for '>'
	ld hl,CMD_ESP_SND ; CR LF
	ld d,CMD_ESP_SND_SIZE
	ld ix,CMD_ESP_SEND_CONN_RSP ;Response Expected
	ld e,CMD_ESP_SEND_CONN_RSP_SIZE
	ld c,10 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	or a
	ld a,ERR_CONN_STATE;
	ld hl,(TCPIP_TCP_SEND_DATA_ADDR)
	ld de,(TCPIP_TCP_SEND_DATA_SIZE)
	call SEND_DATA ;send DE bytes starting at HL
	; data sent, return success
	xor a
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
TCPIP_TCP_RCV:
	ld	a,b
	add a,'0'
	ld	(CMD_GET_ESP_DATA_FROM_TCP_BUFFER+15),a ;just in case we are going to transfer, indicate connection
	
	ld	a,b
	or	a
	ld	a,ERR_NO_CONN
	ret	z

	ld	a,b
	cp	4+1
	ld	a,ERR_NO_CONN
	ret	nc

	ld	a,b
	ld ix,CONN1_BUFFER_VARS
	dec a ; Conn 1?
	jr z,TCPIP_TCPRCV_S ; Yes
	
	ld ix,CONN2_BUFFER_VARS
	dec a ; Conn 2?
	jr z,TCPIP_TCPRCV_S ; Yes
	
	ld ix,CONN3_BUFFER_VARS
	dec a ; Conn 3?
	jr z,TCPIP_TCPRCV_S ; Yes
	
	; Otherwise is 4	
	ld ix,CONN4_BUFFER_VARS
	
TCPIP_TCPRCV_S:	
	; Check if connection is TCP
	xor a
	cp (ix+6) ;UDP?
	ld a,ERR_NO_CONN
	ret nz
	; Just in case receiving buffer is larger than what we can get
	push de
	ld de,2049
	call COMP16
	pop de
	jr c,TCPIP_RCV_NO_ADJUST ;if up to 2048, good to go!
	ld hl,2048;otherwise, retrieve up to 2048
TCPIP_RCV_NO_ADJUST:	
	call TCPIP_RCV_DATA
	ret
	
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
	ret	nz ; if not get, not implemented
	; get, so just return D = #FF, A = OK = 0 and E = 0
	; if here A is already 0
	ld e,0
	ld d,#FF
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
;            0: Off (Do not matter as we can't set, always off)
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
	ret	nz ; if not get, not implemented
	; get, so just return C = 0, A = OK = 0
	; if here A is already 0
	ld c,1
	ret
	

	;============================
	;===  Auxiliary routines  ===
	;============================

; Indicate connection type being closed, used by CLOSE_CONN
CC_TYPE_IS_UDP db 0	
; Indicate whether it is normal close ('0') or abort ('1')
CC_CLOSE_TYPE db '0'
; Indicate last passive connection being closed
CC_CLOSE_PASSIVE db 0
; Indicate if there is someone connected to a passive conn if conn is passive
CC_PASSIVE_HAS_CLIENT db 0
; Indicate Connection State
CC_CONNECTION_STATE db 0

;*********************************************
;***            CLOSE_CONN                 ***
;***									   ***
;*** Inputs:							   ***
;***  B conn # or 0 to close all transient ***
;***  CC_TYPE_IS_UDP: 0 -> TCP or 1 -> UDP ***
;***                                       ***
;*** Output:                               ***
;***  A: 0 UNAPI error code                ***
;*** Affects:                              ***
;*** AF, BC, DE, HL, IX					   ***
;*********************************************
CLOSE_CONN:	
	xor a
	ld (CC_CLOSE_PASSIVE),a
	ld (CC_PASSIVE_HAS_CLIENT),a
	; Up to 4 is accepted as Conn#
	ld	a,b
	cp	4+1
	ld	a,ERR_NO_CONN
	ret	nc
	
	; If 0, close ALL transient
	ld	a,b
	or	a
	jp	z,CC_CLOSE_ALL

	;--- Close one connection
	ld ix,CONN1_BUFFER_VARS
	dec a ; Conn 1?
	jr z,CC_CLOSE_SINGLE ; Yes
	ld ix,CONN2_BUFFER_VARS
	dec a ; Conn 2?
	jr z,CC_CLOSE_SINGLE ; Yes
	ld ix,CONN3_BUFFER_VARS
	dec a ; Conn 3?
	jr z,CC_CLOSE_SINGLE ; Yes
	; Otherwise is 4
	ld ix,CONN4_BUFFER_VARS
	
CC_CLOSE_SINGLE:	
	; Check if connection is Opened
	xor a
	cp (ix+11) ;Opened?
	ld a,ERR_NO_CONN
	ret z ;if 0, not opened, so no connection to close	
		
	; Check if connection is the right type
	ld a,(CC_TYPE_IS_UDP)
	cp (ix+6) ; Match Type?
	ld a,ERR_NO_CONN
	ret nz ;if not 0, no connection to close
	
	;If calling close on a connection, we increase FREE_CONNECTIONS ONLY HERE
	;Now update connections free
	ld a,(ESP_FREE_CONNECTIONS)
	inc a
	ld (ESP_FREE_CONNECTIONS),a ;Ok, saved the new number of free connections
	
	;No longer open, also update ONLY HERE
	xor a
	ld (ix+11),a	
	
	; Check if TCP conn
	ld a,(CC_TYPE_IS_UDP)
	or a
	jr nz,CC_SING_CALL ; UDP is simpler, just close
	
	;copy TCP connection state
	ld a,(ix+5)
	ld (CC_CONNECTION_STATE),a	
	;passive? 
	xor a
	cp (ix+7)
	jr z,CC_SING_CALL ;if active, done adjusting vars, go to cip close	
	ld a,1
	ld (CC_CLOSE_PASSIVE),a ;indicate it is passive
	ld a,(ix+4) ;in passive, indicate if someone connected
	ld (CC_PASSIVE_HAS_CLIENT),a
	; all relevant info loaded, go close that connection, either our side, or if remotely closed, do the logical close
CC_SING_CALL:
	call CLOSE_CONNECTION ;ok, opened and UDP, so go ahead and close it
	xor a
	ret 
	
	;--- Close all transient connections
CC_CLOSE_ALL:
	xor a
	ld ix,CONN1_BUFFER_VARS
	cp (ix+8) ;Transient?
	jr nz,CC_CLOSE_ALL2 ;0, no
	cp (ix+11) ;Opened?
	jr z,CC_CLOSE_ALL2 ;0, no
	ld a,(CC_TYPE_IS_UDP)
	cp (ix+6) ; right type?
	jr nz,CC_CLOSE_ALL2 ;not 0, no	
	;If calling close on a connection, we increase FREE_CONNECTIONS ONLY HERE
	;Now update connections free
	ld a,(ESP_FREE_CONNECTIONS)
	inc a
	ld (ESP_FREE_CONNECTIONS),a ;Ok, saved the new number of free connections	
	;No longer open, also update ONLY HERE
	xor a
	ld (ix+11),a	
	; Check if TCP conn
	ld a,(CC_TYPE_IS_UDP)
	or a
	jr nz,CC_CALL1_CALL ;UDP is simpler, just close
	;copy TCP connection state
	ld a,(ix+5)
	ld (CC_CONNECTION_STATE),a
	;passive? 
	xor a
	cp (ix+7)
	jr z,CC_CALL1_CALL
	ld a,1
	ld (CC_CLOSE_PASSIVE),a ;indicate it is passive
	ld a,(ix+4) ;in passive, indicate if someone connected
	ld (CC_PASSIVE_HAS_CLIENT),a
CC_CALL1_CALL:	
	ld b,1
	call CLOSE_CONNECTION ;ok, close
	
CC_CLOSE_ALL2:		
	xor a
	ld ix,CONN2_BUFFER_VARS
	cp (ix+8) ;Transient?
	jr nz,CC_CLOSE_ALL3 ;0, no
	cp (ix+11) ;Opened?
	jr z,CC_CLOSE_ALL3 ;0, no
	ld a,(CC_TYPE_IS_UDP)
	cp (ix+6) ; right type?
	jr nz,CC_CLOSE_ALL3 ;not 0, no	
	;If calling close on a connection, we increase FREE_CONNECTIONS ONLY HERE
	;Now update connections free
	ld a,(ESP_FREE_CONNECTIONS)
	inc a
	ld (ESP_FREE_CONNECTIONS),a ;Ok, saved the new number of free connections	
	;No longer open, also update ONLY HERE
	xor a
	ld (ix+11),a	
	; Check if TCP conn
	ld a,(CC_TYPE_IS_UDP)
	or a
	jr nz,CC_CALL2_CALL ;UDP is simpler, just close
	;copy TCP connection state
	ld a,(ix+5)
	ld (CC_CONNECTION_STATE),a
	;passive? 
	xor a
	cp (ix+7)
	jr z,CC_CALL2_CALL
	ld a,1
	ld (CC_CLOSE_PASSIVE),a ;indicate it is passive
	ld a,(ix+4) ;in passive, indicate if someone connected
	ld (CC_PASSIVE_HAS_CLIENT),a
CC_CALL2_CALL:	
	ld b,2
	call CLOSE_CONNECTION ;ok, close
	
CC_CLOSE_ALL3:		
	xor a
	ld ix,CONN3_BUFFER_VARS
	cp (ix+8) ;Transient?
	jr nz,CC_CLOSE_ALL4 ;0, no
	cp (ix+11) ;Opened?
	jr z,CC_CLOSE_ALL4 ;0, no
	ld a,(CC_TYPE_IS_UDP)
	cp (ix+6) ; right type?
	jr nz,CC_CLOSE_ALL4 ;not 0, no	
	;If calling close on a connection, we increase FREE_CONNECTIONS ONLY HERE
	;Now update connections free
	ld a,(ESP_FREE_CONNECTIONS)
	inc a
	ld (ESP_FREE_CONNECTIONS),a ;Ok, saved the new number of free connections	
	;No longer open, also update ONLY HERE
	xor a
	ld (ix+11),a	
	; Check if TCP conn
	ld a,(CC_TYPE_IS_UDP)
	or a
	jr nz,CC_CALL3_CALL ;UDP is simpler, just close
	;copy TCP connection state
	ld a,(ix+5)
	ld (CC_CONNECTION_STATE),a
	;passive? 
	xor a
	cp (ix+7)
	jr z,CC_CALL3_CALL
	ld a,1
	ld (CC_CLOSE_PASSIVE),a ;indicate it is passive
	ld a,(ix+4) ;in passive, indicate if someone connected
	ld (CC_PASSIVE_HAS_CLIENT),a
CC_CALL3_CALL:	
	ld b,3
	call CLOSE_CONNECTION ;ok, close
	
CC_CLOSE_ALL4:
	xor a
	ld ix,CONN4_BUFFER_VARS
	cp (ix+8) ;Transient?
	jr nz,CC_CLOSE_ALLR ;0, no
	cp (ix+11) ;Opened?
	jr z,CC_CLOSE_ALLR ;0, no
	ld a,(CC_TYPE_IS_UDP)
	cp (ix+6) ; right type?
	jr nz,CC_CLOSE_ALLR ;not 0, no	
	;If calling close on a connection, we increase FREE_CONNECTIONS ONLY HERE
	;Now update connections free
	ld a,(ESP_FREE_CONNECTIONS)
	inc a
	ld (ESP_FREE_CONNECTIONS),a ;Ok, saved the new number of free connections	
	;No longer open, also update ONLY HERE
	xor a
	ld (ix+11),a	
	; Check if TCP conn
	ld a,(CC_TYPE_IS_UDP)
	or a
	jr nz,CC_CALL4_CALL ;UDP is simpler, just close
	;copy TCP connection state
	ld a,(ix+5)
	ld (CC_CONNECTION_STATE),a
	;passive? 
	xor a
	cp (ix+7)
	jr z,CC_CALL4_CALL
	ld a,1
	ld (CC_CLOSE_PASSIVE),a ;indicate it is passive
	ld a,(ix+4) ;in passive, indicate if someone connected
	ld (CC_PASSIVE_HAS_CLIENT),a
CC_CALL4_CALL:	
	ld b,4
	call CLOSE_CONNECTION ;ok, close

CC_CLOSE_ALLR:
	xor	a
	ret	
	
;*********************************************
;***         CLOSE_CONNECTION              ***
;***									   ***
;*** Inputs:							   ***
;***  B conn #                             ***
;***                                       ***
;*** Output:                               ***
;***  A: 0 ok, otherwise error             ***
;*** Affects:                              ***
;*** AF, C, DE, HL, IX					   ***
;*********************************************	
CLOSE_CONNECTION:
	ld a,'0'
	add a,b
	ld (CMD_ESP_CLOSE_CONN+12),a ;update the string with conn number
	ld (CMD_SET_ESP_CLOSEMODE+16),a ;update the conn # just in case we need to set CLOSEMODE
	ld a,(CC_TYPE_IS_UDP)
	or a
	jr nz,CC_JUST_CLOSE_UDP
	; If here, TCP	
	
	; Check if passive and if there is a client connected (if not, no CIPCLOSE)
	ld a,(CC_CLOSE_PASSIVE)
	or a
	jr z,CC_JUST_CLOSE_TCP ;not passive, just send CIPCLOSE			
	;check if client connected to this connection
	ld a,(CC_PASSIVE_HAS_CLIENT)
	or a
	jr nz,CC_JUST_CLOSE_TCP ;has client, so close it
	; If here, passive, but, no client, so we won't received X,CLOSED... then update conn. count here	
	; Ok, it is passive, so let's decrease passive conn counter
CC_CHECK_LAST_PASSIVE:	
	;If here, closing a passive connection
	; Decrease total # of passive connections open
	ld a,(ESP_PASSIVE_CONNECTIONS_OPEN)
	dec a
	ld (ESP_PASSIVE_CONNECTIONS_OPEN),a
	ret nz ;not zero, so still there is a connection listening
	;zero, so now send a CIPSERVER=0 to stop listening and done	
	call ESP_CLOSE_LAST_PASSIVE
	ret	


CC_JUST_CLOSE_TCP:	
	ld a,(CC_CONNECTION_STATE)
	cp 7 ;CLOSE-WAIT / Remote end requested to close
	jr z,CC_ALREADY_CLOSED_REMOTELY ;of conn state close wait, means no need for cipclose as it has been closed remotely
CC_JUST_CLOSE_UDP:	
	; set close mode
	ld a,(CC_CLOSE_TYPE)
	ld (CMD_SET_ESP_CLOSEMODE+18),a
	; Send the command
	ld hl,CMD_SET_ESP_CLOSEMODE ;Command used
	ld d,CMD_SET_ESP_CLOSEMODE_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,2 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	
	; Junk will get the port being closed and will update the number of free connections
	; Now send the command
	; Our command should be ready
	ld hl,CMD_ESP_CLOSE_CONN ;Command used
	ld d,CMD_ESP_CLOSE_CONN_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,5 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
CC_ALREADY_CLOSED_REMOTELY:	
	ld a,(CC_CLOSE_PASSIVE)
	or a
	ret z ;not passive if 0, then done
	jr CC_CHECK_LAST_PASSIVE; passive, so check if it is last
	
;*********************************************
;***          GET_FREE_CONNECTION          ***
;***									   ***
;*** Inputs:							   ***
;***  None						           ***
;***                                       ***
;*** Output:                               ***
;***  C: Connection Number		           ***
;*** Affects:                              ***
;*** AF, C         						   ***
;*********************************************	
GET_FREE_CONNECTION:
	ld c,1
	ld a,(ESP_CONNECTION1_OPENED)
	or a
	ret z
	inc c
	ld a,(ESP_CONNECTION2_OPENED)
	or a
	ret z
	inc c
	ld a,(ESP_CONNECTION3_OPENED)
	or a
	ret z
	inc c
	ld a,(ESP_CONNECTION4_OPENED)
	or a
	ret z
	inc c
	ret
	
;*********************************************
;***        CLOSE_ALL_CONNECTIONS          ***
;***									   ***
;*** Inputs:							   ***
;***  None						           ***
;***                                       ***
;*** Output:                               ***
;***  None						           ***
;*** Affects:                              ***
;*** A                					   ***
;*********************************************	
CLOSE_ALL_CONNECTIONS:
	xor a
	; No longer open
	ld (ESP_CONNECTION1_OPENED),a
	ld (ESP_CONNECTION2_OPENED),a
	ld (ESP_CONNECTION3_OPENED),a
	ld (ESP_CONNECTION4_OPENED),a
	ld (ESP_PASSIVE_CONNECTIONS_OPEN),a
	ld a,4
	ld (ESP_FREE_CONNECTIONS),a	
	ret	

;OPEN_PREPARE_CONNECTION_VARS
;Reset connection variables
;
;Inputs:
; IX - buffer variables start
; C - 1 -> UDP or 0 -> TCP
; B - Transient or not
; HL - local port for UDP, remote port for TCP
;
; Change AF
OPEN_PREPARE_CONNECTION_VARS:		
	; IX has the beginning of our connection vars
	ld (ix+0),EACH_CONNECTION_BUFFER_SIZE_LSB ;Free - all bytes free
	ld (ix+1),EACH_CONNECTION_BUFFER_SIZE_MSB
	ld (ix+2),0 ;zero TOP and BOTTOM
	ld (ix+3),0 
	ld (ix+4),0 
	ld (ix+5),0 
	ld (ix+6),c ;indicate connection is UDP or not
	ld (ix+7),0 ;indicate 0 datagrams in buffer or active tcp
	ld (ix+8),b ;save if it is transient or not	
	ld (ix+9),l ;our connection local port
	ld (ix+10),h 
	;Check if TCP
	xor a
	cp c 
	ret nz ; If UDP, done
	;Not UDP, let's copy remote IP
	push hl
	ld hl,(TCPOP_IP)
	ld (ix+14),l
	ld (ix+15),h
	ld hl,(TCPOP_IP+2)
	ld (ix+16),l
	ld (ix+17),h
	ld hl,(TCPOP_LPORT)
	ld (ix+18),l
	ld (ix+19),h
	ld a,(TCPOP_FLAGS)
	and 1
	ld (ix+7),a ;passive or not	
	pop hl
	ret

;*********************************************
;***             OPEN_UDP                  ***
;***									   ***
;*** Inputs:							   ***
;***  HL has the port number			   ***
;***  B transient (0) resident (1)         ***
;***  C connection #                       ***
;***                                       ***
;*** Output:                               ***
;***  A: TCP/IP UNAPI return code          ***
;***  B: Number of connection			   ***
;*** Affects:                              ***
;*** AF, BC, IX, HL, DE					   ***
;*********************************************	
OPEN_UDP:
	call GET_FREE_CONNECTION
	;Conn # in C, Transient in B
	push bc ;save BC		
	ld a,'0'
	add a,c
	ld (CMD_ESP_OPEN_UDP_CONN+12),a ;update the connection string w/ our conn number
	
	ld ix,CONN1_BUFFER_VARS
	dec c
	jr z,OPEN_UDP_PREPARE_CONNECTION_VARS	
	
	ld ix,CONN2_BUFFER_VARS
	dec c
	jr z,OPEN_UDP_PREPARE_CONNECTION_VARS	
	
	ld ix,CONN3_BUFFER_VARS
	dec c
	jr z,OPEN_UDP_PREPARE_CONNECTION_VARS
	
	ld ix,CONN4_BUFFER_VARS	

OPEN_UDP_PREPARE_CONNECTION_VARS:	
	; HL already has the port number
	; B has transient
	ld c,1 ;Connection is UDP
	call OPEN_PREPARE_CONNECTION_VARS
	
	; Save conn vars
	push ix
	
	; Now "Print" local port number on command to send
	ld de,CMD_ESP_OPEN_UDP_CONN+33
	call NUM2DEC ;will output 5 ASCII characters starting at DE, representing value in HL (Port)
	; Our command should be ready
	ld hl,CMD_ESP_OPEN_UDP_CONN ;Command used
	ld d,CMD_ESP_OPEN_UDP_CONN_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,5 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	pop ix
	pop bc
	or a ;Success?
	ld a,ERR_CONN_EXISTS
	ret nz ;if error, well, error
	ld b,c ;connection number in B
	ld (ix+11),1 ; Connection Opened
	ld a,(ESP_FREE_CONNECTIONS) ;Update # of free connections
	dec a
	ld (ESP_FREE_CONNECTIONS),a
	xor a ; return ok
	ret	

;*********************************************
;***       CHECK_PASSIVE_CONNECTION        ***
;***									   ***
;*** Inputs:							   ***
;*** CONN_BEING_CLOSED has the conn #	   ***
;***                                       ***
;*** Output:                               ***
;***  None						           ***
;*** Affects:                              ***
;*** AF, BC, IX, HL, DE					   ***
;*********************************************	
CHECK_PASSIVE_CONNECTION:
	ld a,(CONN_BEING_CLOSED)
	;check if 1
	dec a	
	ld ix,CONN1_BUFFER_VARS
	jr z,CPC_CHECK_TCP
	;check if 2
	dec a
	ld ix,CONN2_BUFFER_VARS
	jr z,CPC_CHECK_TCP
	;check if 3
	dec a
	ld ix,CONN3_BUFFER_VARS
	jr z,CPC_CHECK_TCP
	;check if 4
	dec a
	ld ix,CONN4_BUFFER_VARS
	ret nz ;none, so just skip it

CPC_CHECK_TCP:
	ld a,(ix+11) ;connection opened?
	or a
	ret z ;if not opened, done
	ld a,(ix+6)
	or a
	ret nz ;if not zero, IS UDP
	;Check if passive
	ld a,(ix+7)
	or a
	ret z ;if zero, is active
	; Ok, opened, not UDP, and passive so send the command to get conn status
	ld a,1
	ld (CHECK_CONN_STS_ON_INTERRUPT_NOT_OURS),a ; this will request next interrupt with RX buffer clear to send the command
	;call SEND_CIPSTATUS_CMD
	ret

;*********************************************
;***             OPEN_TCP                  ***
;***									   ***
;*** Inputs:							   ***
;*** TCPOP_IP has the remote IP			   ***
;*** TCPOP_RPORT has the remote PORT       ***
;*** TCPOP_LPORT has the local PORT		   ***
;*** TCPOP_FLAGS bit 1 indicate resident   ***
;***             bit 0 indicate passive    ***
;***                                       ***
;*** Output:                               ***
;***  A: TCP/IP UNAPI return code          ***
;***  B: Number of connection			   ***
;*** Affects:                              ***
;*** AF, BC, IX, HL, DE					   ***
;*********************************************	
OP_IS_PASSIVE db 0
OP_CONN0_RESERVED db 0
OPEN_TCP:
	ld a,(TCPOP_FLAGS)
	ld b,1 ;usually resident
	bit 1,a
	jr nz,OPEN_TCP_RESIDENT
	;if here, transient
	ld b,0
OPEN_TCP_RESIDENT:	
	;B has transient connection
	call GET_FREE_CONNECTION
	;Conn # in C, Transient in B
	push bc ;save BC		
	ld a,'0'
	add a,c
	ld (CMD_ESP_OPEN_TCP_CONN+12),a ;update the connection string w/ our conn number
	
	ld ix,CONN1_BUFFER_VARS
	dec c
	jr z,OPEN_TCP_PREPARE_CONNECTION_VARS	
	
	ld ix,CONN2_BUFFER_VARS
	dec c
	jr z,OPEN_TCP_PREPARE_CONNECTION_VARS	
	
	ld ix,CONN3_BUFFER_VARS
	dec c
	jr z,OPEN_TCP_PREPARE_CONNECTION_VARS
	
	ld ix,CONN4_BUFFER_VARS	

OPEN_TCP_PREPARE_CONNECTION_VARS:	
	ld c,0 ;Connection is TCP
	ld hl,(TCPOP_RPORT) ; Remote port
	; B has transient
	call OPEN_PREPARE_CONNECTION_VARS	
	push ix ;save conn vars
	xor a
	ld (OP_IS_PASSIVE),a
	or (ix+7) ;passive?
	jr z,OPEN_TCP_ACTIVE	
	;Ok, passive
	ld a,(ESP_PASSIVE_CONNECTIONS_OPEN)
	or a
	jr z,OPEN_TCP_PASSIVE_FIRST
	;If here, just a soft opening
	;TODO: maybe in the future limit connections to # of open passive connections
	inc a
	ld (ESP_PASSIVE_CONNECTIONS_OPEN),a
	pop ix
	pop bc
	ld b,c ;connection number in B
	ld (ix+11),1 ; Connection Opened
	ld (ix+5),1 ; Listening
	ld a,(ESP_FREE_CONNECTIONS) ;Update # of free connections
	dec a
	ld (ESP_FREE_CONNECTIONS),a	
	xor a ; return ok
	ret
	
OPEN_TCP_PASSIVE_FIRST:	
	;if the first passive, let's send command to start to listen our own step 1, no step 2 jumping to step 3
	ld a,(OP_CONN0_RESERVED)
	or a
	jr nz,OT_CONN0_RESERVED
	call ESP_RESERVE_CONN0 ;If conn 0 was not reserved, reserve it, we do not want it being used by passive connections
OT_CONN0_RESERVED:	
	ld a,1
	ld (OP_IS_PASSIVE),a
	;Send AT+CIPSERVER=1,	
	;Now send it using oti
	ld b,CMD_GET_ESP_START_TCP_LISTEN_SIZE
	ld c,7 ;our data TX port
	ld hl,CMD_GET_ESP_START_TCP_LISTEN
	;otir
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
OT_SEND_0_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,OT_SEND_0_WT
	outi
	jr nz,OT_SEND_0_WT
	;step 3, send port and CR LF and done, just wait incoming connections :-D
	jr OPEN_TCP_STEP3
	
OPEN_TCP_ACTIVE:	
	; Not passive
	; Here is our strategy: First, send AT+CIPSTART=C,"TCP","
	; Then send IP in ASCII, and a quote and a comma
	; Then send Port Number in ASCII, CR LF
	;Now send it using oti
	ld b,CMD_ESP_OPEN_TCP_CONN_SIZE
	ld c,7 ;our data TX port
	ld hl,CMD_ESP_OPEN_TCP_CONN
	;otir
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
OT_SEND_1_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,OT_SEND_1_WT
	outi
	jr nz,OT_SEND_1_WT
	
	;STEP 2, IP address in ASCII...
	ld iy,TCPOP_IP
	call SEND_IP_ADDRESS ;IY points to start of IP address, routine will send it in ASCII form over ESP connection
	ld a,'"'
	out (7),a
	ld a,','
	out (7),a	

OPEN_TCP_STEP3:	
	;STEP 3, Port in ASCII... ESP understand 00023, so this simplifies a lot
	ld de,CMD_ESP_OPEN_UDP_CONN+33
	ld hl,(TCPOP_RPORT) ;port is remote for active
	ld a,(OP_IS_PASSIVE)
	or a
	jr z,OPEN_TCP_STEP3_ACT ; ip active, HL is right
	;passive
	ld hl,(TCPOP_LPORT) ;port to listen is the one in local port vars
OPEN_TCP_STEP3_ACT:	
	call NUM2DEC ;will output 5 ASCII characters starting at DE, representing value in HL (Port)		
	ld hl,CMD_ESP_OPEN_UDP_CONN+33
	ld c,7
	ld b,5
	;oti
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
OT_SEND_2_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,OT_SEND_2_WT
	outi
	jr nz,OT_SEND_2_WT	
	
	;STEP 4, send CR LF and wait for OK
	ld hl,CMD_ESP_SND ; CR LF
	ld d,CMD_ESP_SND_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,10 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	or a
	ld a,ERR_NO_NETWORK	
	pop ix ; restore conn vars
	pop bc ; restore conn# in C
	ret nz
	; Ok, could open
	; If active, send command to get connection status, so get the remote IP and port
	ld a,(TCPOP_FLAGS)
	and 1 ;if 1st bit set passive, for passive only get conn status after X,connected message
;	jr z,OT_NO_PASSIVE_OPEN	
	jr nz,OT_NO_CIPSTATUS
	; ok, send cipstatus cmd affects A, BC and HL, we need BC intact	
	push bc
	call SEND_CIPSTATUS_CMD
OT_WAIT_CIPSTATUS:	
	xor a
	cp (ix+4) ; Did we get the connection information (local port, etc)?
	jr z,OT_WAIT_CIPSTATUS
	pop bc
	ld (ix+5),4 ; simulate an established, as expected for an active connection
	jr OT_NO_PASSIVE_OPEN
OT_NO_CIPSTATUS:
	;TODO: Program 1 incoming connections on listening
	ld (ix+5),1 ; simulate a listen, as expected for a passive connection
	ld a,(ESP_PASSIVE_CONNECTIONS_OPEN)
	inc a
	ld (ESP_PASSIVE_CONNECTIONS_OPEN),a
OT_NO_PASSIVE_OPEN:	
	ld b,c ;connection number in B
	ld (ix+11),1 ; Connection Opened
	ld a,(ESP_FREE_CONNECTIONS) ;Update # of free connections
	dec a
	ld (ESP_FREE_CONNECTIONS),a	
	xor a ; return ok
	ret

; This function might be needed/used if we use ESP Send buffer
; At this point it doesn't seem good, as performance is not good
; for small transfers (i.e.: Telnet) and gains for not waiting 
; ESP to send data are negligible for MSX applications.
;
; Input:
; A - Connection #
;
; Returns:	
; BC Reported Size or 2920 if not possible to retrieve
; Mess w/ all registers
;TCP_CONN_BUFFER_FREE:
;	ld h,'0'
;	add a,h
;	;move connection # to command
;	ld (CMD_GET_ESP_TCP_BUFF_STATUS+16),a
;	; ok, send command
;	ld hl,CMD_GET_ESP_TCP_BUFF_STATUS ;Command used
;	ld d,CMD_GET_ESP_TCP_BUFF_STATUS_SIZE
;	ld ix,RSP_OK_ESP ;Response Expected
;	ld e,RSP_OK_SIZE
;	ld c,3 ;TimeOut	
;	;Now Send the command
;	call SEND_COMMAND
;	or a
;	jp nz,TCP_CONN_BUFFER_FREE_RET_ERR
;	; now, we can do search, need to find the third comma
;	ld b,','
;	ld c,0
;	ld hl,CMD_RAM_BUFFER
;TCP_CONN_BUFFER_FREE_FIND_SIZE:		
;	ld a,(hl)
;	cp b
;	inc hl
;	jr nz,TCP_CONN_BUFFER_FREE_FIND_SIZE
;	inc c	
;	ld a,3
;	cp c
;	jr nz,TCP_CONN_BUFFER_FREE_FIND_SIZE
;	;HL pointing to buffer size, convert
;	call EXTNUM
;	ret ;
;TCP_CONN_BUFFER_FREE_RET_ERR:
;	ld bc,2920
;	ret

; IX Buffer Variables
; DE Address to Copy Data
; HL Maximum Length to copy
;
; Returns:
; A = 0 even if no data
; BC = number of bytes retrieved
; HL = 0 (no support for Urgent Data)
TCPIP_RCV_BUFF_ADDRESS dw 0
TCPIP_CMD_SNT db 0
TCPIP_TOP dw 0
TCPIP_RCV_DATA:	
	ld (TCPIP_RCV_BUFF_ADDRESS),de	
	push hl ;save it, will be used for command
	; Now check if there is data (TOP = IX+2)
	ld l,(ix+2)
	ld h,(ix+3)
	ld a,h
	or l
	jr nz,TCPIP_RCV_DATA_S
	; If here, sorry, no data
	pop hl ;just discarding
	xor a ; OK
	ld hl,0 ; 0 urgent bytes
	ld bc,0 ; 0 bytes retrievd
	ret
TCPIP_RCV_DATA_S:
	; Ok, have data to transfer, first step, request to receive the data
	; First send CMD_GET_ESP_DATA_FROM_TCP_BUFFER
	; oti will output in the port in C
	ld c,7 ;our data TX port
	ld hl,CMD_GET_ESP_DATA_FROM_TCP_BUFFER	
	; Port in C, command is already at HL, move size to B	
	ld a,CMD_GET_ESP_DATA_FROM_TCP_BUFFER_SIZE
	ld b,a
	otir
;	; oti 
;TCPIP_RCV_DATA_SEND_COMMAND_1:	
;	in d,(c)
;	bit 1,d ;TX free?
;	jr nz,TCPIP_RCV_DATA_SEND_COMMAND_1
;	outi
;	jr nz,TCPIP_RCV_DATA_SEND_COMMAND_1

	; Ok, now need to send the maximum size to retrieve 
	pop hl ; restore maximum size to retrieve from stack
	; STEP 2, send data size
	; Now "Print" size on memory (it won't be used while we are here anyway and can hold it fine)
	ld de,CMD_ESP_OPEN_UDP_CONN+33
	;data size already in HL
	call NUM2DEC ;will output 5 ASCII characters starting at DE, representing value in HL (Port)
	; Done, so now let's discard 0's at the left
	ld hl,CMD_ESP_OPEN_UDP_CONN+33
	ld b,5 ;5 digits
	ld a,'0' ;looking for leading 0's
TCPIP_RCV_DATA_DISCARD_0:	
	cp (hl)
	jr nz,TCPIP_RCV_DATA_SEND_1 ;if not '0', done
	;it is, so discard
	inc hl
	dec b
	jr TCPIP_RCV_DATA_DISCARD_0	
TCPIP_RCV_DATA_SEND_1:	
	ld c,7
	; B contains number of digits and HL the first non 0, so, ready to send
	otir
;	;oti
;	;otir will cause wait, that will stop processing while previous byte is sent
;	;which in turn stop interrupts, the world and everything else
;TCPIP_RCV_DATA_SEND_1_WT:	
;	in a,(c)
;	bit 1,a ;TX free?
;	jr nz,TCPIP_RCV_DATA_SEND_1_WT
;	outi
;	jr nz,TCPIP_RCV_DATA_SEND_1_WT
		
	; Ok, now, we will send CR, let the junk thread know that there is an IP receive and wait it to finish
	ld a,13
	out (7),a			
	ld a,1
	ld (TCPIP_CMD_SNT),a
	ld hl,0
	ld (ESP_TRANSFER_REMAINING),hl		
	; Ok, send it
	ld a,10
	out (7),a
	; Now, wait junk thread tell it is done and transfer size is in ESP_TRANSFER_REMAINING
TCPIP_RCV_DATA_RCV_1_WT:	
	ld a,(TCPIP_CMD_SNT)
	or a
	jr nz,TCPIP_RCV_DATA_RCV_1_WT
	; Done, so let's get data from ESP and return
	
	; Ok, so what we have here?
	; ESP_TRANSFER_REMAINING indicate how many bytes we are receiving
	; DE will indicate how many bytes were gathered
	
;	ld hl,(TCPIP_RCV_BUFF_ADDRESS)
;	ld de,0
;	ld bc,(ESP_TRANSFER_REMAINING)
;CONN_TCP_TRANSFER_R:	
;	in a,(7)
;	bit 0,a ; Do we have data to read?
;	jr z,CONN_TCP_TRANSFER_R ; No, wait for data	
;	; Has data, it and save it
;	; Get data in A
;    in a,(6)
;	ld (hl),a
;	inc de
;	inc hl
;	dec bc ;dec wont affect flags, so check manually if zero
;	ld a,b
;	or c
;	jr nz,CONN_TCP_TRANSFER_R
;
;	; Ok, got ESP_TRANSFER_REMAINING bytes, DE has how many bytes were got, 
;	;Adjust top	
;	; Ok, done, so decrease DATA RETRIEVED from TOP
;	ld l,(ix+2)
;	ld h,(ix+3) ;TOP	
;	or a;clear carry
;	sbc hl,de
;	ld (ix+2),0
;	ld (ix+3),0
;	jr c,TCPIP_RCV_DATA_RCV_END ;underflow, so leave it at 0
;	; Move new buffer left size to top
;	ld (ix+2),l
;	ld (ix+3),h


	ld hl,(TCPIP_RCV_BUFF_ADDRESS)
	ld de,(ESP_TRANSFER_REMAINING)
	; Grauw Optimized 16 bit loop, handy for us, mostly since we can use inir :-D
	ld b,e ;Number of loops originaly in DE
	dec de
	inc d
	ld c,6
CONN_TCP_TRANSFER_R:
	in a,(7)
	bit 0,a ; Do we have data to read?
	jr z,CONN_TCP_TRANSFER_R ; No, wait for data	
	ini
	jr nz,CONN_TCP_TRANSFER_R
	dec d
	jr nz,CONN_TCP_TRANSFER_R
	
	; Ok, got ESP_TRANSFER_REMAINING bytes, decrease it from top	
	ld l,(ix+2)
	ld h,(ix+3) ; TOP
	; carry already clear from dec d = 0
	ld de,(ESP_TRANSFER_REMAINING)
	sbc hl,de
	jr nc,TCPIP_RCV_DATA_RCV_END ;no underflow, so just move on
	; If here something went bad, so just 0 top (remaining rcv data)
	ld hl,0	
TCPIP_RCV_DATA_RCV_END:	
	; Move new buffer left size to top
	ld (ix+2),l
	ld (ix+3),h
	;re-enable ESP interruptions
	ld a,23
	out (6),a ;enable intelligent interrupts from ESP
	
	ld b,d
	ld c,e
	ld hl,0 ; no urgent data
	;Return
	xor a
	ret

;Num2Hex:	ld	a,d
;	call	Num1
;	ld	a,d
;	call	Num2
;	ld	a,e
;	call	Num1
;	ld	a,e
;	jr	Num2
;
;Num1:	rra
;	rra
;	rra
;	rra
;Num2:	or	#F0
;	daa
;	add	a,#A0
;	adc	a,#40
;
;	PUTCHAR a
;	ret
	
; IX Buffer Variables
; HL Address to Copy Datagram
; DE the limit to save datagram Data (what is not saved, will be discarded)
;
; Will copy up to DE bytes in HL from the oldest UDP Datagram in Buffer
; L H E D will have sender's IP address
; IX will have sender's Port
; BC will contain how many bytes were actually received
DATAGRAM_IP db 0,0,0,0
DATAGRAM_PORT dw 0
DATAGRAM_SIZE dw 0
GET_UDP_DATAGRAM_FROM_CONNECTION_BUFFER:
	call POP_BUFFER_BYTE
	ld c,a
	call POP_BUFFER_BYTE
	ld b,a
	ld (DATAGRAM_SIZE),bc
	call POP_BUFFER_BYTE
	ld (DATAGRAM_IP),a
	call POP_BUFFER_BYTE
	ld (DATAGRAM_IP+1),a
	call POP_BUFFER_BYTE
	ld (DATAGRAM_IP+2),a
	call POP_BUFFER_BYTE
	ld (DATAGRAM_IP+3),a
	call POP_BUFFER_BYTE
	ld (DATAGRAM_PORT),a
	call POP_BUFFER_BYTE
	ld (DATAGRAM_PORT+1),a	
	;Now we have HL address of transfer, DE buffer size, BC # of bytes in buffer to transfer or discard
	call BUFFER_TRANSFER_TO_MEMORY
	ld a,(ix+7) ; Pending Datagram Count
	dec a
	ld (ix+7),a ; Save new count
	ld ix,(DATAGRAM_PORT)
	ld bc,(DATAGRAM_SIZE)
	ld hl,(DATAGRAM_IP)
	ld de,(DATAGRAM_IP+2)
	ret
	
; HL address to transfer
; IX connection buffer vars
; DE transfer buffer size
; BC # of bytes in buffer to transfer or discard, #FFFF means grab untill it fills the app buffer
;
BTM_TRANSFER_ADDR dw 0
BTM_TRANSFER_SIZE dw 0
BTM_SEQUENTIAL_SIZE dw 0
BTM_BUFFER_DATA_TO_READ dw 0
;BTM_NEED_TO_CLR_BUFF_AFTER_READ db 0
BUFFER_TRANSFER_TO_MEMORY:
;
; Bellow you have a byte per byte version that do not try LDIR transfers
; LDIR is faster as it works with ring buffer pointers and IX registers less times.
;
;	call POP_BUFFER_BYTE
;	ret c
;	ld (hl),a
;	inc hl
;	dec de
;	dec bc
;	; Check if app buffer received all data it can receive
;	xor a
;	xor e
;	jr nz,BTM_CHK_DG ;nope, it can receive more, but have we got all we need?
;	xor d
;	jr nz,BTM_CHK_DG;nope, it can receive more, but have we got all we need?
;	jr BTM_CLR_CHK;ok, app buffer full, check if BC is 0 or not
;BTM_CHK_DG:
;	xor a
;	xor c
;	jr nz,BUFFER_TRANSFER_TO_MEMORY;still have to discard datagram remaining bytes
;	xor b
;	jr nz,BUFFER_TRANSFER_TO_MEMORY;still have to discard datagram remaining bytes
;	;If here done reading as BC (datagram size) is 0
;	ret
;	
;BTM_CLR_CHK:	
;	xor c
;	jr nz,BTM_CLR
;	xor b
;	jr nz,BTM_CLR
;	ret ;BC = 0, popped entire datagram
;BTM_CLR:	
;	call POP_BUFFER_BYTE
;	ret c
;	xor a
;	jr BTM_CLR_CHK	
	di ;let's do it quick, and not be interrupted
	xor a 
	;ld (BTM_NEED_TO_CLR_BUFF_AFTER_READ),a
	ld (BTM_TRANSFER_ADDR),hl	
	ld (BTM_BUFFER_DATA_TO_READ),bc
	; First check how much data goes to buffer
	ld l,e
	ld h,d
	; carry clear from previous xor
	sbc hl,bc
	; If carry, buffer won't allow to transfer all data, if no carry, can transfer BC bytes to Address
	jr nc,BTM_TRANSFER_DATA
	; if here , will transfer just buffer size
	;ld a,1
	;ld (BTM_NEED_TO_CLR_BUFF_AFTER_READ),a
	ld c,e
	ld b,d
BTM_TRANSFER_DATA:
	; BC is the size of LDIR(s)
	ld (BTM_TRANSFER_SIZE),bc
	
	; Now check if it is an 1 step or a 2 step move operation
	ld hl,EACH_CONNECTION_BUFFER_SIZE
	ld e,(ix+4) ;Bottom
	ld d,(ix+5)
	push de ; save bottom
	or a ; zero carry
	sbc hl,de 
	ld (BTM_SEQUENTIAL_SIZE),hl ; hl now contains how many bytes we can read just incrementing bottom, let's check if we can do at once or not
	; BUFFER_SIZE is always greater or than bottom, so it won't carry
	sbc hl,bc ; SEQUENTIAL MAX - DATA TO TRANSFER TO MEMORY, if carry or zero, will be a two step transfer, otherwise, just a single transfer
	jr nc,BTM_LAST_TRANSFER ; transfer in a single ldir
	jr z,BTM_LAST_TRANSFER ; transfer in a single ldir
	
	; Two Step Transfer, first step (remember, bottom is in stack)
	or a; clear carry
	; This is part 1 of 2 parts transfer
	; First update new TRANSFER SIZE after part 1 is done
	ld hl,(BTM_TRANSFER_SIZE)
	ld de,(BTM_SEQUENTIAL_SIZE)
	sbc hl,de ; hl has new transfer size after this partial transfer 	
	ld (BTM_TRANSFER_SIZE),hl ;store it
	
	; Now update Buffer Data to Read
	ld hl,(BTM_BUFFER_DATA_TO_READ)
	sbc hl,de ; hl has new buffer data to read size after this partial transfer 
	ld (BTM_BUFFER_DATA_TO_READ),hl	;store it
	; Now update Buffer FREE
	;Adjust buffer free
	ld l,(ix+0)
	ld h,(ix+1)
	add hl,de 
	ld (ix+0),l
	ld (ix+1),h
	; Ok, two parts transfer, let's do the first part, transfer SEQUENTIAL_SIZE bytes
	; First the source
	ld l,(ix+12) ; Buff start
	ld h,(ix+13)
	pop de ; restore bottom	
	add hl,de ; HL pointing to buff bottom, source
	ld de,(BTM_TRANSFER_ADDR) ;destination
	ld bc,(BTM_SEQUENTIAL_SIZE) ;size
	ldir 
	;now save new transfer "start" address
	ld (BTM_TRANSFER_ADDR),de ;new destination
	;bottom is 0
	ld hl,0
	push hl
	
BTM_LAST_TRANSFER:	
	; At this point we can just transfer BTM_TRANSFER_SIZE to BTM_TRANSFER_ADDR
	; Bottom is in the stack and need to be retrieved
	; First the source
	ld l,(ix+12) ; Buff start
	ld h,(ix+13)
	pop de ; restore bottom
	push de; save bottom
	add hl,de ; HL pointing to buff bottom
	ld de,(BTM_TRANSFER_ADDR)
	ld bc,(BTM_TRANSFER_SIZE)
	;Transfer
	ldir

	;Adjust buffer bottom (need to check as bottom might overlap if app buffer < buffer size to be cleared)	
	pop hl ; restore bottom in HL
	ld de,(BTM_BUFFER_DATA_TO_READ) ;we will clear the data to read, not data tramsferred (as app buffer can be less than buffer to clear)
	add hl,de
	; "new" bottom in HL, now need to check if bottom has passed buffer boundaries
	ld de,EACH_CONNECTION_BUFFER_SIZE
	call COMP16
	jr z,BTM_BOTTOM_ZERO
	jr c,BTM_BOTTOM_OK
	;If here C is clear, and HL has BOTTOM + EACH_CONNECTION_BUFFER_SIZE, so just decrement BUFF_SIZE and done
	sbc hl,de ; now HL has bottom right (only what passed BUFFER SIZE)
BTM_BOTTOM_ZERO:
	ld hl,0
BTM_BOTTOM_OK:	
	ld (ix+4),l
	ld (ix+5),h
	;Adjust buffer free
	ld l,(ix+0)
	ld h,(ix+1)
	ld de,(BTM_BUFFER_DATA_TO_READ)
	add hl,de 
	ld (ix+0),l
	ld (ix+1),h
	ei ; interrupts free to go again
	ret
	
;send DE bytes starting at HL, the last block of data is send using SEND_COMMAND 
;to wait for OK	
SEND_DATA: 
	push hl
	push de
	ld hl,#FF
	or a ;set carry to 0
	sbc hl,de
	jr nc,SEND_DATA_LAST_BLOCK ;if de <= FF carry won't be set and we can send the last block
	;if here, DE>#FF, so send block, decrement, and next block	
	pop hl ; old de in hl
	ld de,#FF
	or a
	sbc hl,de
	ld d,h
	ld e,l ; DE = DE - #FF
	pop hl ; restore address
	ld b,#FF
	ld c,7	
	; B contains number of digits and HL the first byte not sent, so, ready to send
	;otir
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
SEND_DATA_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,SEND_DATA_WT
	outi
	jr nz,SEND_DATA_WT	
	; HL already at HL + 255, DE already decremented 255, data sent, continue
	jr SEND_DATA ; back to next block (be it last or not)
	
SEND_DATA_LAST_BLOCK:
	; Here we use send command and wait for an OK
	pop de
	ld d,e ; DE has size, which is up to FF, so E has the effective size	
	pop hl ;HL contains "Command"	
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,10 ;TimeOut	
	;Now Send the "command"
	call SEND_COMMAND
	ret
	
IPDIGIT db 0
; IY points to where the first IP address byte is
; Will send an IP address in a format ESP understands
SEND_IP_ADDRESS:
	xor a
	ld (IPDIGIT),a
SIPADD_LOOP:			
	or a
	jr z,SIPADD_LOOP1 ;no need to send .
	cp 4 ; if 4, sent all four digits, done
	ret z
	;If here, send a point
	ld a,'.'
	out (7),a
	ld a,(IPDIGIT)
SIPADD_LOOP1:	
	; LD L,(IY+*) is FD 6E *, so we are going to change * to the actual digit
	ld (SIPADD_IYCMD+2),a
	ld h,0
SIPADD_IYCMD:	
	ld l,(iy+0)
	ld de,CMD_ESP_OPEN_UDP_CONN+33
	call NUM2DEC ;will output 5 ASCII characters starting at DE, representing value in HL (Port)
	; Done, so now let's discard 0's at the left
	ld hl,CMD_ESP_OPEN_UDP_CONN+33
	ld b,5 ;5 digits
	ld a,'0' ;looking for leading 0's
SIPADD_IYCMD_DISCARD:	
	cp (hl)
	jr nz,SIPADD_IYCMD_SEND ;if not '0', done
	;it is, so discard
	inc hl
	dec b
	jr SIPADD_IYCMD_DISCARD
SIPADD_IYCMD_SEND:
	ld c,7
	; B contains number of digits and HL the first non 0, so, ready to send
	;otir
SIPADD_IYCMD_SEND_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,SIPADD_IYCMD_SEND_WT
	outi
	jr nz,SIPADD_IYCMD_SEND_WT		
	ld a,(IPDIGIT)
	inc a
	ld (IPDIGIT),a
	jr SIPADD_LOOP
	
	
;Check if the port is in use
;Port to check in HL
;Changes A, F, DE
;If not in use, A = 0, otherwise A = ERR_CONN_EXISTS
CHECK_PORT_IN_USE:
	ld a,(ESP_CONNECTION1_OPENED)
	or a
	jr z,(CPIU_CHKPORT2)
	ld de,(CONN1_PORT)
	call COMP16
	jr z,CPIU_ERR_CONN_E

CPIU_CHKPORT2:	
	ld a,(ESP_CONNECTION2_OPENED)
	or a
	jr z,(CPIU_CHKPORT3)
	ld de,(CONN2_PORT)
	call COMP16
	jr z,CPIU_ERR_CONN_E
	
CPIU_CHKPORT3:	
	ld a,(ESP_CONNECTION3_OPENED)
	or a
	jr z,(CPIU_CHKPORT4)	
	ld de,(CONN3_PORT)
	call COMP16
	jr z,CPIU_ERR_CONN_E
	
CPIU_CHKPORT4:	
	ld a,(ESP_CONNECTION4_OPENED)
	or a
	jr z,(CPIU_CHKPORTOK)	
	ld de,(CONN4_PORT)
	call COMP16
	jr z,CPIU_ERR_CONN_E
	
CPIU_CHKPORTOK:
	xor a
	ret
	
CPIU_ERR_CONN_E:	
	ld a,ERR_CONN_EXISTS
	ret		
	
;Check if the remote ip / port is ok to use
;Port to check in HL
;IP in C.B E.D
;Changes A, F, DE, HL
;If ok to use, A = 0, otherwise A = ERR_CONN_EXISTS
;TODO: passive conn., check only if none open, then ok, or, if one open, port has to be the same
;TODO: as ESP AT firmware only supports listening to 1 port at a time
CHECK_REMOTE_IP: ds 4
CHECK_REMOTE_PORT: dw 0
CHECK_TCP_CONN_EXISTS:
	ld (CHECK_REMOTE_PORT),hl
	ld (CHECK_REMOTE_IP),bc
	ld (CHECK_REMOTE_IP+2),de
	
	ld a,(ESP_CONNECTION1_OPENED)
	or a
	jr z,(CTCE_CHK2)
	ld a,(CONN1_IS_UDP)
	or a
	jr nz,(CTCE_CHK2) ;UDP, not TCP
	;HL still has port
	ld de,(CONN1_PORT)
	call COMP16
	jr nz,CTCE_CHK2 ; port not the same, so move on
	; Now compare the first two bytes of IP
	ld hl,(CHECK_REMOTE_IP)
	ld de,(CONN1_REMOTE_IP)
	call COMP16
	jr nz,CTCE_CHK2 ; IF some part of IP not the same move on
	; Now compare the last two bytes of IP
	ld hl,(CHECK_REMOTE_IP+2)
	ld de,(CONN1_REMOTE_IP+2)
	call COMP16
	jp z,CTCE_CHK_CONN_E ; Ok, same IP, so connection already exists

CTCE_CHK2:	
	ld a,(ESP_CONNECTION2_OPENED)
	or a
	jr z,(CTCE_CHK3)
	ld a,(CONN2_IS_UDP)
	or a
	jr nz,(CTCE_CHK3) ;UDP, not TCP
	ld hl,(CHECK_REMOTE_PORT)
	ld de,(CONN2_PORT)
	call COMP16
	jr nz,CTCE_CHK3 ; port not the same, so move on
	; Now compare the first two bytes of IP
	ld hl,(CHECK_REMOTE_IP)
	ld de,(CONN2_REMOTE_IP)
	call COMP16
	jr nz,CTCE_CHK3 ; IF some part of IP not the same move on
	; Now compare the last two bytes of IP
	ld hl,(CHECK_REMOTE_IP+2)
	ld de,(CONN2_REMOTE_IP+2)
	call COMP16
	jr z,CTCE_CHK_CONN_E ; Ok, same IP, so connection already exists
	
CTCE_CHK3:	
	ld a,(ESP_CONNECTION3_OPENED)
	or a
	jr z,(CTCE_CHK4)
	ld a,(CONN3_IS_UDP)
	or a
	jr nz,(CTCE_CHK4) ;UDP, not TCP
	ld hl,(CHECK_REMOTE_PORT)
	ld de,(CONN3_PORT)
	call COMP16
	jr nz,CTCE_CHK4 ; port not the same, so move on
	; Now compare the first two bytes of IP
	ld hl,(CHECK_REMOTE_IP)
	ld de,(CONN3_REMOTE_IP)
	call COMP16
	jr nz,CTCE_CHK4 ; IF some part of IP not the same move on
	; Now compare the last two bytes of IP
	ld hl,(CHECK_REMOTE_IP+2)
	ld de,(CONN3_REMOTE_IP+2)
	call COMP16
	jr z,CTCE_CHK_CONN_E ; Ok, same IP, so connection already exists
	
CTCE_CHK4:	
	ld a,(ESP_CONNECTION4_OPENED)
	or a
	jr z,(CTCE_CHK_OK)
	ld a,(CONN4_IS_UDP)
	or a
	jr nz,(CTCE_CHK_OK) ;UDP, not TCP
	ld hl,(CHECK_REMOTE_PORT)
	ld de,(CONN4_PORT)
	call COMP16
	jr nz,CTCE_CHK_OK ; port not the same, so move on
	; Now compare the first two bytes of IP
	ld hl,(CHECK_REMOTE_IP)
	ld de,(CONN4_REMOTE_IP)
	call COMP16
	jr nz,CTCE_CHK_OK ; IF some part of IP not the same move on
	; Now compare the last two bytes of IP
	ld hl,(CHECK_REMOTE_IP+2)
	ld de,(CONN4_REMOTE_IP+2)
	call COMP16	
	jr z,CTCE_CHK_CONN_E ; Ok, same IP, so connection already exists
	; IP not the same move on
CTCE_CHK_OK:
	xor a
	ret
	
CTCE_CHK_CONN_E:	
	ld a,ERR_CONN_EXISTS
	ret			
	
; Close message for (CONN_BEING_CLOSED) received, deal with it	
CONNECTION_CLOSE:	
	ld a,(CONN_BEING_CLOSED)
	ld ix,CONN1_BUFFER_VARS
	dec a
	jr z,CC_CHECK_PORT_TYPE ;1
	ld ix,CONN2_BUFFER_VARS
	dec a
	jr z,CC_CHECK_PORT_TYPE ;2
	ld ix,CONN3_BUFFER_VARS
	dec a
	jr z,CC_CHECK_PORT_TYPE ;3
	dec a
	ret nz ;if not 4, something crazy is going on, done
	;If here, 4
	ld ix,CONN4_BUFFER_VARS 
	
CC_CHECK_PORT_TYPE:	
	ld a,(ix+11) ;Opened?
	or a
	ret z ;if already marked as closed, nothing else to do :-D
	ld a,(ix+6) ;UDP?
	or a ; if zero, TCP, not zero, UDP
	ret nz ;UDP closes only per our request, so we should be fine
	; It is TCP, what is the currrent state? If ESTABLISHED, means remotely closed
	ld a,4 ; ESTABLISHED
	cp (ix+5) ; IS this the conn status?
	jr nz,CC_OUR_CLOSE
	;done remotely
	;so now simulate the state CLOSE-WAIT, as it was closed by the client side, not our side
	ld (ix+5),7
	ld (ix+4),0 ;no longer has client if passive
	;TODO: Program max incoming connections on listening to actual # -1 if a passive connection
	;Done
	ret
CC_OUR_CLOSE:
	;It is not, so we've requested close through TCP/UDP CLOSE, and connection is now closed, update status
	; Ok, is it passive?
	ld a,(ix+7) ;Passive?
	or a ; if zero, active
	ret z ;if active, ok, nothing to do
	; Ok, it is passive and it has been closed, need to update PASSIVE_TCP_HAS_CLIENT
	; THIS is the routine to deal with a passive connection being closed
	; UNAPI in general treat a remote client disconnection as a connection closure, so let's do it
	ld (ix+4),0 ;no longer has client if passive	
	;TODO: Program max incoming connections on listening to actual # -1
	ret nz ; if not the last, we are done
	; Now, if it was the last passive listening connection, send a command to stop listening
	ld b,CMD_GET_ESP_STOP_TCP_LISTEN_SIZE
	ld c,7 ;our data TX port
	ld hl,CMD_GET_ESP_STOP_TCP_LISTEN
	;oti
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
CC_STOPLISTEN_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,CC_STOPLISTEN_WT
	outi
	jr nz,CC_STOPLISTEN_WT

; HL contains the number to be converted
; DE contains the destination of ASCII string
; Mess with A, BC, DE, HL
NUM2DEC:
	ld	bc,-10000
	call	NUM1
	ld	bc,-1000
	call	NUM1
	ld	bc,-100
	call	NUM1
	ld	c,-10
	call	NUM1
	ld	c,b

NUM1:
	ld	a,'0'-1
NUM2:
	inc	a
	add	hl,bc
	jr	c,NUM2
	sbc	hl,bc

	ld	(de),a
	inc	de
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
	
;--- Get a random local port not in use
;    Input:    -
;    Output:   HL = Port number
;    Modifies: AF, DE, HL

GET_RANDOM_PORT:
	ld	hl,(JIFFY)
RAND_PORT_LOOP:
	inc	hl
	res	7,h	;Ensure random port
	set	6,h	;is in the range 16384-32767

	ld	de,(CONN1_PORT)
	call	COMP16
	jr	z,RAND_PORT_LOOP
	ld	de,(CONN2_PORT)
	call	COMP16
	jr	z,RAND_PORT_LOOP
	ld	de,(CONN3_PORT)
	call	COMP16
	jr	z,RAND_PORT_LOOP
	ld	de,(CONN4_PORT)
	call	COMP16

	ret


;--- Convert a character to upper-case if it is a lower-case letter

TOUPPER:
	cp	"a"
	ret	c
	cp	"z"+1
	ret	nc
	and	#DF
	ret
	
;--- PARSE_IP: Extracts an IP address from a string
;    Input:  String at DNS_BUFFER, zero terminated
;    Output: Cy=0 and IP at address in DE, or Cy=1 if not a valid IP
;    Modifies: AF, BC, DE, HL, IX

PARSE_IP:
	ld hl,DNS_BUFFER
PARSE_IPL:
	ld a,(hl)
	or a
	jr z,PARSE_IP2	;Appends a dot to ease parsing process
	inc hl
	jr PARSE_IPL
PARSE_IP2:	
	ld (hl),"."
	push hl
	pop ix	;IX = Address of the last dot

	;ld de,DNS_RESULT
	ld hl,DNS_BUFFER
	ld b,4

IPLOOP:	
	push bc
	push de
	call EXTNUM
	jp c,ERRIP	;Checks that it is a number in the range 0-255
	or a	;and that it is zero terminated
	jp nz,ERRIP
	ld a,b
	or a
	jp nz,ERRIP
	ld a,e
	cp "."
	jp nz,ERRIP

	ld a,c
	ld c,d
	ld b,0
	pop de
	ld (de),a
	add hl,bc
	inc hl
	inc de
	pop bc
	djnz IPLOOP

	or a
	jr PARSE_IPEND

ERRIP:	
	pop de
	pop bc
	scf

PARSE_IPEND:
	ld (ix),0
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
	push hl
	push ix
	ld ix,ACA
	res 0,(ix)
	set 1,(ix)
	ld bc,0
	ld de,0
BUSNUM:	
	ld a,(hl)	;Jump to FINEXT if not a digit, or is the 6th digit
	ld e,a
	cp "0"
	jr c,FINEXT
	cp "9"+1
	jr nc,FINEXT
	ld a,d
	cp 5
	jr z,FINEXT
	call POR10

SUMA:	
	push hl	;BC = BC + A
	push bc
	pop hl
	ld bc,0
	ld a,e
	sub "0"
	ld c,a
	add hl,bc
	call c,BIT17
	push hl
	pop bc
	pop hl

	inc d
	inc hl
	jr BUSNUM

BIT17:	
	set 0,(ix)
	ret
ACA:	db	0	;b0: num>65535. b1: more than 5 digits

FINEXT:	
	ld a,e
	cp "0"
	call c,NODESB
	cp "9"+1
	call nc,NODESB
	ld a,(ix)
	pop ix
	pop hl
	srl a
	ret

NODESB:	
	res 1,(ix)
	ret

POR10:
	push de
	push hl	;BC = BC * 10
	push bc
	push bc
	pop	hl
	pop	de
	ld b,3
ROTA:
	sla l
	rl h
	djnz ROTA
	call c,BIT17
	add hl,de
	call c,BIT17
	add hl,de
	call c,BIT17
	push hl
	pop bc
	pop hl
	pop de
	ret
	
;*********************************************
;***           PUSH_BYTE_IN_BUFFER         ***
;***									   ***
;*** Inputs:							   ***
;***  Buffer Start in ESP_TRANSFER_BUFF    ***
;***  Buff Vars in ESP_TRANSFER_BUFF_VARS  ***
;***  A - Byte to Push                     ***
;***                                       ***
;*** Output:                               ***
;***  A: 0 If Ok otherwise failure         ***
;***                                       ***
;*** Affects:                              ***
;*** AF, BC, HL, IX						   ***
;*********************************************
PUSH_BYTE_IN_BUFFER:
	; Get Variables Address
	ld ix,(ESP_TRANSFER_BUFF_VARS)
	; save data in B
	ld b,a
    ; check if there is free space
	ld c,1
	ld a,(ix+0) ;+0 and +1 is Buffer Free
	sub c
	ld (ix+0),a
	jr nc,PBIB_MOVE ;if no carry, we are fine and no need to sub MSB
	;Carry, work with MSB	
	ld a,(ix+1) ;+0 and +1 is Buffer Free
	sbc a,0
	ld (ix+1),a
	jr nc,PBIB_MOVE ;if no carry, we are fine and no need to sub MSB	
	; carry, so set 0 to free (otherwise it will stay -1, FFFF)
	ld (ix+0),0
	ld (ix+1),0
	; If here, buffer full, nothing to do
    ret

PBIB_MOVE:		
    ; ok, we can push it
    ; So HL will hold the first available memory address of RAM
	; Get Buffer Address
	ld hl,(ESP_TRANSFER_BUFF)
	; Top is in +2
	ld a,(ix+2)
	add a,l
	ld l,a
	ld a,(ix+3)
	adc a,h
	ld h,a
    ; Copy the data we got to memory (Start Addr + Top Value)
    ld (hl),b
    ; Now deal with FIFO variables
    ; Now check if Top (+2 and +3) = top RAM position
    ; Start with LSB
    ld bc,EACH_CONNECTION_BUFFER_SIZE
	ld l,(ix+2)
	ld h,(ix+3)
	inc hl
    or a ; clear carry
	push hl
	sbc hl,bc
	pop hl
	jr nz,PBIB_BUFFER_NO_LEAP ;if not zero, no leap    
    ; Equal, so we will leap here and Top goes back to index 0
    xor a
	; Save 0 to Top
	ld (ix+2),a
	ld (ix+3),a
	; A is already zero, so just return
    ret
PBIB_BUFFER_NO_LEAP:
    ; New top in HL so just add 1 to current Top value
	ld (ix+2),l
	ld (ix+3),h ;carry, means add 1 to msb
	ret

;*********************************************
;***     CONN_CHUNK_TRANSFER_HANDLER       ***
;***									   ***
;*** Inputs:							   ***
;***  None								   ***
;***                                       ***
;*** Output:                               ***
;***  A: 0 If Ok otherwise failure         ***
;***                                       ***
;*** Affects:                              ***
;*** AF, BC, DE, HL, IX					   ***
;*********************************************	
CONN_CHUNK_TRANSFER_HANDLER:
    ; Ok, big chunk of data, check if we have 128 bytes free	
	ld ix,(ESP_TRANSFER_BUFF_VARS)
    ld l,(ix+0) ; Buffer Free in 0 and 1
	ld h,(ix+1)
    ld de,128
	ld a,1
	or a ; Clear the Carry flag
    sbc hl,de	
    ; if carry, not enough space, done
    ret c
	; Can do, save buffer free
    ld (ix+0),l ; Buffer Free in 0 and 1
	ld (ix+1),h
    ; ok, fifo w/ at least 128 bytes available, we can push it
    ; So HL will hold the first available memory address of RAM
	ld hl,(ESP_TRANSFER_BUFF)
	ld e,(ix+2) ; Buffer Top in 2 and 3
	ld d,(ix+3)
    add hl,de
	; B register is the transfer size
    ld b,128
	; C register will hold the address to get data from UART FIFO
    ld c,6;
    ; Transfer all those bytes
    inir

    ; DE still has Top, check if we have overshoot the circular buffer
    ld h,d
    ld l,e
    ld bc,128
    add hl,bc
    ; DE has Top, HL has Top + 128
    ; 2K buffers, TOP is #7FF, if reached #800 overshoot
    ld bc,EACH_CONNECTION_BUFFER_SIZE
	; Clear Carry
	or a
	; Save HL
    push hl
	sbc hl,bc
	; If C means no overshoot (Top is less than #800)
	jr c,CONN_TR_CHUNK_DONE_NOOVERSHOOT
	; If Z means no overshoot, but Top Must go to 0 (since we are saving HL in Top, win)
	jr z,CONN_TR_CHUNK_DONE_NOOVERSHOOT_DONT_RESTORE_HL
    ;if here, overshoot    
	; Throw away saved HL
	pop bc
    ;this overshoot will be up to 128, so only LSB counts (l) (this works as buffer capacity LSB is 00)
	ld (ix+2),l ; push new top value
	ld (ix+3),0 ; push new top value	
	; Beginning of buffer, where we copy the remaining data
    ld de,(ESP_TRANSFER_BUFF)
	; overshoot bytes
    ld b,h
	ld c,l
    ; This is the address of overshoot area
    ld hl,(ESP_TRANSFER_BUFF_OVERSHOOT_AREA)
    ; copy it
    ldir
	;DONE w/ chunk
	xor a	
	ret
CONN_TR_CHUNK_DONE_NOOVERSHOOT_DONT_RESTORE_HL:	
	pop bc ; throw away HL = #800
	ld (ix+2),l ; push new top value
	ld (ix+3),h ; push new top value
    ;DONE w/ chunk, no error
	xor a
	ret
CONN_TR_CHUNK_DONE_NOOVERSHOOT:
	pop hl ;TOP Value
    ld (ix+2),l ; push new top value
	ld (ix+3),h ; push new top value
    ;DONE w/ chunk, no error
	xor a
	ret

;*********************************************
;***      CONN_TRANSFER_INFO_HANDLER       ***
;***									   ***
;*** Inputs:							   ***
;***  A - Content of Transfer State Var    ***
;***  B - bit set indicate connection #    ***
;***                                       ***
;*** Output:                               ***
;***  A: 0 If Ok otherwise failure         ***
;***                                       ***
;*** Affects:                              ***
;*** AF, BC, DE, HL, IX					   ***
;*********************************************
CONN_TRANSFER_IH_IS_UDP db 0
CONN_TRANSFER_IH_TOP_ADDR dw 0
CONN_TRANSFER_INFO_HANDLER:
	dec a
	;if 1, waiting to discard comma separating connection # from size
	jr z,CONN_IH_C
	dec a
	;if 2, getting data size 
	jr z,CONN_IH_GDS
	dec a
	;if 3, getting IP 
	jp z,CONN_IH_GIP
	;else getting PORT
	jp CONN_IH_GP
	
; Ok, so let's confirm, next byte should be a comma....
CONN_IH_C:	
	in a,(6)
	cp ','
	;If not comma, need to end, if comma, next state
	jr nz,CONN_IH_ERR
	;Ok, comma, ready to get data size
	ld a,2
	ld (ESP_TRANSFER_REMAINING_STATE),a
	xor a
	ld (ESP_TRANSFER_REMAINING_INDEX),a
	; OK and A has 0, so return
	ret	
CONN_IH_ERR:
	; Error, so just set A and return
	ld a,1
	ret
	
; Ok, so let's keep getting data size
CONN_IH_GDS:	
	ld d,0
	ld a,(ESP_TRANSFER_REMAINING_INDEX)
	ld e,a
	ld hl,ESP_TRANSFER_REMAINING_ASCII_BUFFER
	add hl,de
	;Ok, HL has the address to put the byte, read it
	in a,(6)
	;Save it
	ld (hl),a
	;Ok, byte pushed, was it a comma?
	cp ','
	;If not comma, one more digit, if comma, convert and if success next state
	jr z,CONN_IH_GDS_CONVERT
	;TCP size info do not have a comma, but CR
	cp 13
	;If not CR, one more digit, if CR, convert and if success next state
	jr z,CONN_IH_GDS_CONVERT
	;increment index
	inc e
	ld a,4
	cp e
	;if index > 4, we can't handle such transfer (ESP buffer is 2000 and something anyway, shouldn't happen)
	; A has 4, so just need to ret and error is set
	ret c
	;index up to 4, save it
	ld a,e
	ld (ESP_TRANSFER_REMAINING_INDEX),a
	;done for now, A = 0 meaning Ok and ret
	xor a
	ret
; Convert the received size in ASCII to a number	
CONN_IH_GDS_CONVERT:
	; Our buffer address in HL
	ld hl,ESP_TRANSFER_REMAINING_ASCII_BUFFER
	; So, convert it 
	call EXTNUM
	;if A = 0 success, size is in BC
	or a
	; != 0, return, A already other than 0
	ret nz
	; If TCP, end here, if UDP, still has things to do
	ld a,(CONN_TRANSFER_IH_IS_UDP)
	or a
	jr nz,CONN_IH_GDS_CONVERT_UDP
	;ok, so move size in buffer to connection top
	ld hl,(CONN_TRANSFER_IH_TOP_ADDR)
	ld (hl),c
	inc hl
	ld (hl),b ;ok, top has new size
	; done, but return 1 so it will exit transfer loop, after all, data is not being transferred now
	ld a,1
	ret
	
CONN_IH_GDS_CONVERT_UDP:
	xor a
	; Ok, move the data from BC
	ld (ESP_TRANSFER_REMAINING),bc
	; Let's zero our index so GIP can use it
	ld (ESP_TRANSFER_REMAINING_INDEX),a
	;Ok, ready to get IP information
	ld a,3
	ld (ESP_TRANSFER_REMAINING_STATE),a
	; Done for now, A=0 meaning ok, ret
	xor a
	ret
		
; Ok, so now get IP	
CONN_IH_GIP:
	ld d,0
	ld a,(ESP_TRANSFER_REMAINING_INDEX)
	ld e,a
	ld hl,DNS_BUFFER
	add hl,de
	;Ok, HL has the address to put the byte, read it
	in a,(6)
	;Save it
	ld (hl),a
	;Ok, byte pushed, was it a comma?
	cp ','
	;If not comma, one more digit, if comma, convert and if success next state
	jr z,CONN_IH_GIP_CONVERT
	;increment index
	inc e		
	ld a,e
	ld (ESP_TRANSFER_REMAINING_INDEX),a
	;done for now, A = 0 meaning Ok and ret
	xor a
	ret
; Convert the received IP in 4 bytes number
CONN_IH_GIP_CONVERT:
	xor a
	ld (hl),a ;String termination, instead of ','
	ld de,ESP_TRANSFER_SENDER_IP
	; Convert it
	call PARSE_IP
	; Let's zero our index so GIP can use it
	xor a
	ld (ESP_TRANSFER_REMAINING_INDEX),a
	;Ok, ready to get PORT information
	ld a,4
	ld (ESP_TRANSFER_REMAINING_STATE),a
	;done for now, A = 0 meaning Ok and ret
	xor a
	ret
	
; Ok, so now get Port
CONN_IH_GP:
	ld d,0
	ld a,(ESP_TRANSFER_REMAINING_INDEX)
	ld e,a
	ld hl,DNS_BUFFER
	add hl,de
	;Ok, HL has the address to put the byte, read it
	in a,(6)
	;Save it
	ld (hl),a
	;Ok, byte pushed, was it ':'?
	cp ':'
	;If not ':', one more digit, if ':', convert and if success next state
	jr z,CONN_IH_GP_CONVERT
	;increment index
	inc e
	ld a,e
	ld (ESP_TRANSFER_REMAINING_INDEX),a
	;done for now, A = 0 meaning Ok and ret
	xor a
	ret
; Convert the received Port Number in ASCII to a number	
CONN_IH_GP_CONVERT:
	; Our buffer address in HL
	ld hl,DNS_BUFFER
	; Save B (and C), as B contains the connection #
	push bc
	; So, convert it 
	call EXTNUM
	;this is non-essential information, so if failure, do not care, move on
	; Ok, move the data from BC
	ld (ESP_TRANSFER_SENDER_PORT),bc
	; Now let's check if connection is UDP, if it is, push Data Size / IP / Port
	; Restore B (bit set indicates connection)
	pop bc
	; Now, load IX with the variable indicator of the connection
	bit 1,b
	jr z,CONN_IH_TEST2
	; It is one
	ld ix,CONN1_BUFFER_VARS
	ld (ESP_TRANSFER_BUFF_VARS),ix
	ld hl,CONN1_BUFFER_OVERSHOOT_AREA
	ld (ESP_TRANSFER_BUFF_OVERSHOOT_AREA),hl
	ld hl,CONN1_BUFF
	ld (ESP_TRANSFER_BUFF),hl	
	jr CONN_IH_VAR_OK
CONN_IH_TEST2:
	bit 2,b
	jr z,CONN_IH_TEST3
	; It is two
	ld ix,CONN2_BUFFER_VARS
	ld (ESP_TRANSFER_BUFF_VARS),ix
	ld hl,CONN2_BUFFER_OVERSHOOT_AREA
	ld (ESP_TRANSFER_BUFF_OVERSHOOT_AREA),hl
	ld hl,CONN2_BUFF
	ld (ESP_TRANSFER_BUFF),hl	
	jr CONN_IH_VAR_OK
CONN_IH_TEST3:	
	bit 3,b
	jr z,CONN_IH_IS4
	; It is three
	ld ix,CONN3_BUFFER_VARS
	ld (ESP_TRANSFER_BUFF_VARS),ix
	ld hl,CONN3_BUFFER_OVERSHOOT_AREA
	ld (ESP_TRANSFER_BUFF_OVERSHOOT_AREA),hl
	ld hl,CONN3_BUFF
	ld (ESP_TRANSFER_BUFF),hl	
	jr CONN_IH_VAR_OK	
CONN_IH_IS4: ;otherwise 4
	ld ix,CONN4_BUFFER_VARS	
	ld (ESP_TRANSFER_BUFF_VARS),ix
	ld hl,CONN4_BUFFER_OVERSHOOT_AREA
	ld (ESP_TRANSFER_BUFF_OVERSHOOT_AREA),hl
	ld hl,CONN4_BUFF
	ld (ESP_TRANSFER_BUFF),hl	
	
CONN_IH_VAR_OK:	
	ld a,(ix+6) ;Get IS_UDP
	or a
	jp z,CONN_IH_GP_RET ;If not UDP, buffer just holds data
	; Ok, UDP, save datagram info
    ld a,(ESP_TRANSFER_REMAINING)
	call PUSH_BYTE_IN_BUFFER
	ld a,(ESP_TRANSFER_REMAINING+1)
	call PUSH_BYTE_IN_BUFFER
	ld a,(ESP_TRANSFER_SENDER_IP)
	call PUSH_BYTE_IN_BUFFER
	ld a,(ESP_TRANSFER_SENDER_IP+1)
	call PUSH_BYTE_IN_BUFFER
	ld a,(ESP_TRANSFER_SENDER_IP+2)
	call PUSH_BYTE_IN_BUFFER
	ld a,(ESP_TRANSFER_SENDER_IP+3)
	call PUSH_BYTE_IN_BUFFER
	ld a,(ESP_TRANSFER_SENDER_PORT)
	call PUSH_BYTE_IN_BUFFER
	ld a,(ESP_TRANSFER_SENDER_PORT+1)
	call PUSH_BYTE_IN_BUFFER	
CONN_IH_GP_RET:	
	;Ok, ready to get data 
	xor a
	ld (ESP_TRANSFER_REMAINING_STATE),a
	;done for now, A = 0 meaning Ok and ret
	ret
	
;*********************************************
;***           INTERRUPT ROUTINE           ***
;*********************************************
CONN_STS_HELPER:
	; A has status, check if bit 1 is 0, if it is, FIFO empty, good time to send pending status command
	bit 0,a
	jp nz,OLD_HKEY_I ;if not zero, has data, not going to risk...
	;if we are here, fifo is empty, let's send the sts command if needed
	ld a,(CHECK_CONN_STS_ON_INTERRUPT_NOT_OURS)
	or a
	jp z,OLD_HKEY_I ;if zero, no need to check...
	;not zero, so, why not send our command now?
	;call CHECK_PASSIVE_CONNECTION	
	call SEND_CIPSTATUS_CMD
	jp OLD_HKEY_I ;aaaaand done.... CHECK_CONN_STS_ON_INTERRUPT_NOT_OURS will be cleared on first +CIPSTATUS received

MY_INTERRUPT_HANDLER:
;Check if it is our interrupt
    in a,(7)
    bit 7,a
;    ;If 8th bit is set, UART did not interrupt
;	jp nz,OLD_HKEY_I ;if not zero, not our interrupt...
	; check if need to send cipstatus
	jp nz,CONN_STS_HELPER
	; Check if we are pushing data into a CMD response buffer, a connection buffer or idle
	ld a,(ESP_TRANSFER_INPROGRESS)
	or a
	jp z,JUNK_TRANSFER	
	bit 1,a
	jr nz,CONN_1_TRANSFER
	bit 2,a
	jp nz,CONN_2_TRANSFER
	bit 3,a
	jp nz,CONN_3_TRANSFER
	bit 4,a
	jp nz,CONN_4_TRANSFER
	; If bit 0, 5 or 6 set, something wrong, clean junk anyway
	; bit 7 is just an indication if +CIPRECVDATA will be gathered or discarded :-D
	jp z,JUNK_TRANSFER
	
CONN_1_TRANSFER:	
	in a,(7)
	bit 0,a
	jp z,OLD_HKEY_I	
	ld a,(ESP_TRANSFER_REMAINING_STATE)
	or a
	; 0, transfer data, otherwise we will let the handler function take care
	; of gathering transfer information	
	jp z,CONN_1_TR_R	
	ld b,a
	ld hl,CONN1_BUFFER_TOP
	ld (CONN_TRANSFER_IH_TOP_ADDR),hl
	ld a,(CONN1_IS_UDP)
	ld (CONN_TRANSFER_IH_IS_UDP),a
	ld a,b
	ld b,0
	set 1,b ;indicate connection 1
	call CONN_TRANSFER_INFO_HANDLER
	; Ok? (A = 0)
	or a
	jr z,CONN_1_TRANSFER ; OK, check if there are more bytes
	; Nope, error
	ld a,(ESP_TRANSFER_INPROGRESS)
	res 1,a
	ld (ESP_TRANSFER_INPROGRESS),a ; Abort, rest of data go to junk or whatever	
	jr MY_INTERRUPT_HANDLER ; Let interrupt handler decide what has to be done
	
;Already received the # of bytes to receive, so just pushing in the buffer
CONN_1_TR_R:
	ld a,(ESP_TRANSFER_REMAINING)
	or a
	jr nz,CONN_1_TR_R_STT ;lsb not 0, so we are fine
	ld a,(ESP_TRANSFER_REMAINING+1)
	or a
	jr nz,CONN_1_TR_R_STT ;msb not 0, so we are fine
	; If here, done!	
	; Transfer not in progress
	ld a,(ESP_TRANSFER_INPROGRESS)
	res 1,a
	ld (ESP_TRANSFER_INPROGRESS),a
	ld ix,(ESP_TRANSFER_BUFF_VARS)
	; Check if connection is UDP
	xor a
	cp (ix+6) ;UDP?
	jr z,MY_INTERRUPT_HANDLER ;if 0, not udp, so no datagram count update
	ld a,(ix+7) ;Get UDP_DATAGRAM_COUNT
	inc a
	ld (ix+7),a ;Save UDP_DATAGRAM_COUNT
	jr MY_INTERRUPT_HANDLER
	
CONN_1_TR_R_STT:	
	in a,(7)
	bit 0,a ; Do we have data to read?
	jp z,OLD_HKEY_I ; No, interrupt done    
    bit 6,a ; There is data, if 7th bit is set, it is not 128 bytes or more, usual bit per bit stuff
    jr nz,CONN_1_TR_R_BYTE ; less than 128 bytes, go byte per byte
	; 128 bytes or more, check if transfer remaining is at least 128, otherwise we might end-up getting data is not ours
	ld hl,(ESP_TRANSFER_REMAINING)	
	ld de,128
	or a ; clear carry
	sbc hl,de
	; if carry, less than 128 bytes remaining, so byte per byte
	jr c,CONN_1_TR_R_BYTE	
	; no carry, so push  save HL (Transfer Remaining - 128) and try Chunk Transfer
	push hl	
	; Ok, so now let's try to transfer our big chunk
	call CONN_CHUNK_TRANSFER_HANDLER
	pop hl ;restore transfer remaining - 128
	; Success?
	or a
	jr nz,CONN_1_TR_R_BYTE ;Failure, probably no space for 128 bytes in buffer, try byte per byte
	; Success!	
    ld (ESP_TRANSFER_REMAINING),hl ;save the new remaining	
	jr CONN_1_TR_R	
	
; Here we are on a different routine where we move byte per byte
CONN_1_TR_R_BYTE:    	
	; Get data in A
    in a,(6)
	call PUSH_BYTE_IN_BUFFER
	; We really don't care if it worked or not
	ld hl,(ESP_TRANSFER_REMAINING)
	dec hl
	ld (ESP_TRANSFER_REMAINING),hl
	jr CONN_1_TR_R	

CONN_2_TRANSFER:
	in a,(7)
	bit 0,a
	jp z,OLD_HKEY_I	
	ld a,(ESP_TRANSFER_REMAINING_STATE)
	or a
	; 0, transfer data, otherwise we will let the handler function take care
	; of gathering transfer information	
	jp z,CONN_2_TR_R	
	ld b,a
	ld hl,CONN2_BUFFER_TOP
	ld (CONN_TRANSFER_IH_TOP_ADDR),hl
	ld a,(CONN2_IS_UDP)
	ld (CONN_TRANSFER_IH_IS_UDP),a
	ld a,b
	ld b,0
	set 2,b ;indicate connection 2
	call CONN_TRANSFER_INFO_HANDLER
	; Ok? (A = 0)
	or a
	jr z,CONN_2_TRANSFER ; OK, check if there are more bytes
	; Nope, error
	ld a,(ESP_TRANSFER_INPROGRESS)
	res 2,a
	ld (ESP_TRANSFER_INPROGRESS),a ; Abort, rest of data go to junk or whatever	
	jp MY_INTERRUPT_HANDLER ; Let interrupt handler decide what has to be done
	
;Already received the # of bytes to receive, so just pushing in the buffer
CONN_2_TR_R:
	ld a,(ESP_TRANSFER_REMAINING)
	or a
	jr nz,CONN_2_TR_R_STT ;lsb not 0, so we are fine
	ld a,(ESP_TRANSFER_REMAINING+1)
	or a
	jr nz,CONN_2_TR_R_STT ;msb not 0, so we are fine
	; If here, done!	
	; Transfer not in progress
	ld a,(ESP_TRANSFER_INPROGRESS)
	res 2,a
	ld (ESP_TRANSFER_INPROGRESS),a
	ld ix,(ESP_TRANSFER_BUFF_VARS)
	; Check if connection is UDP
	xor a
	cp (ix+6) ;UDP?
	jp z,MY_INTERRUPT_HANDLER ;if 0, not udp, so no datagram count update
	ld a,(ix+7) ;Get UDP_DATAGRAM_COUNT
	inc a
	ld (ix+7),a ;Save UDP_DATAGRAM_COUNT
	jp MY_INTERRUPT_HANDLER
	
CONN_2_TR_R_STT:	
	in a,(7)
	bit 0,a ; Do we have data to read?
	jp z,OLD_HKEY_I ; No, interrupt done    
    bit 6,a ; There is data, if 7th bit is set, it is not 128 bytes or more, usual bit per bit stuff
    jr nz,CONN_2_TR_R_BYTE ; less than 128 bytes, go byte per byte
	; 128 bytes or more, check if transfer remaining is at least 128, otherwise we might end-up getting data is not ours
	ld hl,(ESP_TRANSFER_REMAINING)	
	ld de,128
	or a ; clear carry
	sbc hl,de
	; if carry, less than 128 bytes remaining, so byte per byte
	jr c,CONN_2_TR_R_BYTE	
	; no carry, so push  save HL (Transfer Remaining - 128) and try Chunk Transfer
	push hl	
	; Ok, so now let's try to transfer our big chunk
	call CONN_CHUNK_TRANSFER_HANDLER
	pop hl ;restore transfer remaining - 128
	; Success?
	or a
	jr nz,CONN_2_TR_R_BYTE ;Failure, probably no space for 128 bytes in buffer, try byte per byte
	; Success!	
    ld (ESP_TRANSFER_REMAINING),hl ;save the new remaining	
	jr CONN_2_TR_R	
	
; Here we are on a different routine where we move byte per byte
CONN_2_TR_R_BYTE:    	
	; Get data in A
    in a,(6)
	call PUSH_BYTE_IN_BUFFER
	; We really don't care if it worked or not
	ld hl,(ESP_TRANSFER_REMAINING)
	dec hl
	ld (ESP_TRANSFER_REMAINING),hl
	jr CONN_2_TR_R	
	
CONN_3_TRANSFER:
	in a,(7)
	bit 0,a
	jp z,OLD_HKEY_I	
	ld a,(ESP_TRANSFER_REMAINING_STATE)
	or a
	; 0, transfer data, otherwise we will let the handler function take care
	; of gathering transfer information	
	jp z,CONN_3_TR_R	
	ld b,a
	ld hl,CONN3_BUFFER_TOP
	ld (CONN_TRANSFER_IH_TOP_ADDR),hl
	ld a,(CONN3_IS_UDP)
	ld (CONN_TRANSFER_IH_IS_UDP),a
	ld a,b
	ld b,0
	set 3,b ;indicate connection 3
	call CONN_TRANSFER_INFO_HANDLER
	; Ok? (A = 0)
	or a
	jr z,CONN_3_TRANSFER ; OK, check if there are more bytes
	; Nope, error
	ld a,(ESP_TRANSFER_INPROGRESS)
	res 3,a
	ld (ESP_TRANSFER_INPROGRESS),a ; Abort, rest of data go to junk or whatever	
	jp MY_INTERRUPT_HANDLER ; Let interrupt handler decide what has to be done
	
;Already received the # of bytes to receive, so just pushing in the buffer
CONN_3_TR_R:
	ld a,(ESP_TRANSFER_REMAINING)
	or a
	jr nz,CONN_3_TR_R_STT ;lsb not 0, so we are fine
	ld a,(ESP_TRANSFER_REMAINING+1)
	or a
	jr nz,CONN_3_TR_R_STT ;msb not 0, so we are fine
	; If here, done!	
	; Transfer not in progress
	ld a,(ESP_TRANSFER_INPROGRESS)
	res 3,a
	ld (ESP_TRANSFER_INPROGRESS),a
	ld ix,(ESP_TRANSFER_BUFF_VARS)
	; Check if connection is UDP
	xor a
	cp (ix+6) ;UDP?
	jp z,MY_INTERRUPT_HANDLER ;if 0, not udp, so no datagram count update
	ld a,(ix+7) ;Get UDP_DATAGRAM_COUNT
	inc a
	ld (ix+7),a ;Save UDP_DATAGRAM_COUNT
	jp MY_INTERRUPT_HANDLER
	
CONN_3_TR_R_STT:	
	in a,(7)
	bit 0,a ; Do we have data to read?
	jp z,OLD_HKEY_I ; No, interrupt done    
    bit 6,a ; There is data, if 7th bit is set, it is not 128 bytes or more, usual bit per bit stuff
    jr nz,CONN_3_TR_R_BYTE ; less than 128 bytes, go byte per byte
	; 128 bytes or more, check if transfer remaining is at least 128, otherwise we might end-up getting data is not ours
	ld hl,(ESP_TRANSFER_REMAINING)	
	ld de,128
	or a ; clear carry
	sbc hl,de
	; if carry, less than 128 bytes remaining, so byte per byte
	jr c,CONN_3_TR_R_BYTE	
	; no carry, so push  save HL (Transfer Remaining - 128) and try Chunk Transfer
	push hl	
	; Ok, so now let's try to transfer our big chunk
	call CONN_CHUNK_TRANSFER_HANDLER
	pop hl ;restore transfer remaining - 128
	; Success?
	or a
	jr nz,CONN_3_TR_R_BYTE ;Failure, probably no space for 128 bytes in buffer, try byte per byte
	; Success!	
    ld (ESP_TRANSFER_REMAINING),hl ;save the new remaining	
	jr CONN_3_TR_R	
	
; Here we are on a different routine where we move byte per byte
CONN_3_TR_R_BYTE:    	
	; Get data in A
    in a,(6)
	call PUSH_BYTE_IN_BUFFER
	; We really don't care if it worked or not
	ld hl,(ESP_TRANSFER_REMAINING)
	dec hl
	ld (ESP_TRANSFER_REMAINING),hl
	jr CONN_3_TR_R
	
CONN_4_TRANSFER:
	in a,(7)
	bit 0,a
	jp z,OLD_HKEY_I	
	ld a,(ESP_TRANSFER_REMAINING_STATE)
	or a
	; 0, transfer data, otherwise we will let the handler function take care
	; of gathering transfer information	
	jp z,CONN_4_TR_R	
	ld b,a
	ld hl,CONN4_BUFFER_TOP
	ld (CONN_TRANSFER_IH_TOP_ADDR),hl
	ld a,(CONN4_IS_UDP)
	ld (CONN_TRANSFER_IH_IS_UDP),a
	ld a,b
	ld b,0
	set 4,b ;indicate connection 1
	call CONN_TRANSFER_INFO_HANDLER
	; Ok? (A = 0)
	or a
	jr z,CONN_4_TRANSFER ; OK, check if there are more bytes
	; Nope, error
	ld a,(ESP_TRANSFER_INPROGRESS)
	res 4,a
	ld (ESP_TRANSFER_INPROGRESS),a ; Abort, rest of data go to junk or whatever	
	jp MY_INTERRUPT_HANDLER ; Let interrupt handler decide what has to be done
	
;Already received the # of bytes to receive, so just pushing in the buffer
CONN_4_TR_R:
	ld a,(ESP_TRANSFER_REMAINING)
	or a
	jr nz,CONN_4_TR_R_STT ;lsb not 0, so we are fine
	ld a,(ESP_TRANSFER_REMAINING+1)
	or a
	jr nz,CONN_4_TR_R_STT ;msb not 0, so we are fine
	; If here, done!	
	; Transfer not in progress
	ld a,(ESP_TRANSFER_INPROGRESS)
	res 4,a
	ld (ESP_TRANSFER_INPROGRESS),a
	ld ix,(ESP_TRANSFER_BUFF_VARS)
	; Check if connection is UDP
	xor a
	cp (ix+6) ;UDP?
	jp z,MY_INTERRUPT_HANDLER ;if 0, not udp, so no datagram count update
	ld a,(ix+7) ;Get UDP_DATAGRAM_COUNT
	inc a
	ld (ix+7),a ;Save UDP_DATAGRAM_COUNT
	jp MY_INTERRUPT_HANDLER
	
CONN_4_TR_R_STT:	
	in a,(7)
	bit 0,a ; Do we have data to read?
	jp z,OLD_HKEY_I ; No, interrupt done    
    bit 6,a ; There is data, if 7th bit is set, it is not 128 bytes or more, usual bit per bit stuff
    jr nz,CONN_4_TR_R_BYTE ; less than 128 bytes, go byte per byte
	; 128 bytes or more, check if transfer remaining is at least 128, otherwise we might end-up getting data is not ours
	ld hl,(ESP_TRANSFER_REMAINING)	
	ld de,128
	or a ; clear carry
	sbc hl,de
	; if carry, less than 128 bytes remaining, so byte per byte
	jr c,CONN_4_TR_R_BYTE	
	; no carry, so push  save HL (Transfer Remaining - 128) and try Chunk Transfer
	push hl	
	; Ok, so now let's try to transfer our big chunk
	call CONN_CHUNK_TRANSFER_HANDLER
	pop hl ;restore transfer remaining - 128
	; Success?
	or a
	jr nz,CONN_4_TR_R_BYTE ;Failure, probably no space for 128 bytes in buffer, try byte per byte
	; Success!	
    ld (ESP_TRANSFER_REMAINING),hl ;save the new remaining	
	jr CONN_4_TR_R	
	
; Here we are on a different routine where we move byte per byte
CONN_4_TR_R_BYTE:    	
	; Get data in A
    in a,(6)
	call PUSH_BYTE_IN_BUFFER
	; We really don't care if it worked or not
	ld hl,(ESP_TRANSFER_REMAINING)
	dec hl
	ld (ESP_TRANSFER_REMAINING),hl
	jr CONN_4_TR_R


RESTART_BUFFER:
	ld de,0
	jr BUFFER_OK
	
; Routine that handle interrupts when no data is being expected
JUNK_TRANSFER_CHECK_DONE:
	; Now let's check if still clearing junk
	ld a,(ESP_TRANSFER_INPROGRESS)
	; any other bit set?
	or a
	;0
	jp nz,MY_INTERRUPT_HANDLER;ret	z
JTCD_C:	
	; Still clearing junk or waiting DNS resolve on interrupts
	; Check if there are more bytes in UART FIFO
    in a,(7)
    and 1
    ;If 1st bit is not set, no more data in UART FIFO, so we are done
    jp z,OLD_HKEY_I;ret	z
; Here we handle data that is not being expected (transfer data of a transfer in progress)
; Basically, what we can get here is:
; - Garbage
; - Status Messages from ESP ( ready / WIFI CONNECTED / WIFI GOT IP / WIFI DISCONNECT / X,CLOSED / +IPD	
; - Command response (as indicated by ESP_CMD_INPROGRESS, we copy responses to CMD BUFFER)
; - DNS query responses (as indicated by ESP_DNS_INPROGRESS, we can copy the result or not)
; We should receive small pieces of data, so byte per byte transfer is best and easier on memory and to parse "JUNK"
;
; This routine will also handle DNS Queries... Why?
; - WiFi disconnection could occur during it
; - We won't receive lot's of data so no need to receive chunk data
DNS_QUERY_IN_PROGRESS:
JUNK_TRANSFER:
	;
    ; C register will hold the address to get data from UART FIFO
    ld c,6;
	;Ok, move data to register b
    in b,(c)
	; Check 
	ld a,(ESP_CMD_INPROGRESS)
	or a
	jr z, JT_ST ;if no command in progress, no need to copy received data to command response buffer
	; Command in progress, so copy it...
	or a ; Clear Carry
	ld hl,CMD_BUFFER_SIZE	
	ld de,(CMD_RAM_BUFFER_DATA_SIZE)
	inc de
	sbc hl,de
	jr c,RESTART_BUFFER ;If carry, RAM Buffer Full
BUFFER_OK:	
	;Not carry, so save new size
	ld (CMD_RAM_BUFFER_DATA_SIZE),de
	ld hl,CMD_RAM_BUFFER ;address of buffer
	dec de ; adjust DE back so it points to the relative position to write data
	add hl,de ;hl has the position where to write data
	ld (hl),b ;push it
JT_ST:	
	; Now let's check our working status and parse accordingly
	ld a,(JUNK_STATE)
	or a
	;0
	jr z,JUNK_TRANSFER_NO_STS
	dec a
	;1
	jp z,JUNK_TRANSFER_STS_WIFI_H
	dec a
	;2
	jp z,JUNK_TRANSFER_STS_WIFI_D
	dec a
	;3
	jp z,JUNK_TRANSFER_STS_WIFI_C
	dec a
	;4
	jp z,JUNK_TRANSFER_STS_WIFI_G
	dec a
	;5
	jp z,JUNK_TRANSFER_STS_CONN_C
	dec a
	;6	
	jp z,JUNK_TRANSFER_STS_CONN_R
	dec a
	;7
	jp z,JUNK_TRANSFER_DNS_R
	dec a
	;8
	jp z,JUNK_TRANSFER_DNS_E
	dec a
	;9
	jp z,JUNK_TRANSFER_DNS_F
	dec a
	;10
	jp z,JUNK_TRANSFER_NO_STS_CHECKP2
	dec a
	;11
	jp z,JUNK_TRANSFER_DNS_C
	dec a
	;12
	jp z,JUNK_TRANSFER_STS_CONN_N	
	dec a
	;13
	jp z,JUNK_TRANSFER_RECVDATA
	dec a
	;14
	jp z,JUNK_TRANSFER_RECVDATA_SIZE
	dec a
	;15
	jp z,JUNK_TRANSFER_RECVCONNSTS
	dec a
	;16
	jp z,JUNK_TRANSFER_RECVCONNSTS_CONN
	
JUNK_TRANSFER_NO_STS:	
	ld a,b
	ld c,'W'
	cp c
	jr nz,JUNK_TRANSFER_NO_STS_CHECK1
	ld a,JUNK_STS_WIFI_H
	ld (JUNK_STATE),a
	ld a,1
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_NO_STS_CHECK1:	
	ld a,b
	ld c,'1'
	cp c
	jr nz,JUNK_TRANSFER_NO_STS_CHECK2
	ld a,JUNK_STS_CONN_C
	ld (JUNK_STATE),a
	ld a,1
	ld (JUNK_INDEX),a
	ld (CONN_BEING_CLOSED),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_NO_STS_CHECK2:	
	ld a,b
	ld c,'2'
	cp c
	jr nz,JUNK_TRANSFER_NO_STS_CHECK3
	ld a,JUNK_STS_CONN_C
	ld (JUNK_STATE),a
	ld a,1	
	ld (JUNK_INDEX),a
	inc a
	ld (CONN_BEING_CLOSED),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_NO_STS_CHECK3:	
	ld a,b
	ld c,'3'
	cp c
	jr nz,JUNK_TRANSFER_NO_STS_CHECK4
	ld a,JUNK_STS_CONN_C
	ld (JUNK_STATE),a
	ld a,1
	ld (JUNK_INDEX),a
	ld a,3
	ld (CONN_BEING_CLOSED),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_NO_STS_CHECK4:	
	ld a,b
	ld c,'4'
	cp c
	jr nz,JUNK_TRANSFER_NO_STS_CHECKP
	ld a,JUNK_STS_CONN_C
	ld (JUNK_STATE),a
	ld a,1
	ld (JUNK_INDEX),a
	ld a,4
	ld (CONN_BEING_CLOSED),a
	jp JUNK_TRANSFER_CHECK_DONE	
JUNK_TRANSFER_NO_STS_CHECKP:	
	ld a,b
	ld c,'+'
	cp c
	jr nz,JUNK_TRANSFER_NO_STS_CHECKD
	ld a,JUNK_STS_P
	ld (JUNK_STATE),a
	ld a,1
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE		
JUNK_TRANSFER_NO_STS_CHECKD:	
	ld a,b
	ld c,'D'
	cp c
	jr nz,JUNK_TRANSFER_NO_STS_CHECKE
	ld a,JUNK_STS_DNS_F
	ld (JUNK_STATE),a
	ld a,1
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE		
JUNK_TRANSFER_NO_STS_CHECKE:	
	ld a,b
	ld c,'E'
	cp c
	jr nz,JUNK_TRANSFER_NO_STS_NOTOKEN
	ld a,JUNK_STS_ERROR
	ld (JUNK_STATE),a
	ld a,1
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_NO_STS_NOTOKEN:	
	xor a
	ld (JUNK_STATE),a
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE	
	
; Check if + is I (data) or C (dns or passive TCP rcv data or conn information)
JUNK_TRANSFER_NO_STS_CHECKP2:
	ld a,b
	ld c,'C'
	cp c
	jr nz,JUNK_TRANSFER_NO_STS_CHECKP3
	ld a,JUNK_STS_DNS_R
	ld (JUNK_STATE),a
	ld a,2
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE			
JUNK_TRANSFER_NO_STS_CHECKP3:
	ld a,b
	ld c,'I'
	cp c
	jr nz,JUNK_TRANSFER_NO_STS_NOTOKEN
	ld a,JUNK_STS_CONN_R
	ld (JUNK_STATE),a
	ld a,2
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
	
; Check for WIFI Header
JUNK_TRANSFER_STS_WIFI_H:
	ld a,(JUNK_INDEX)
	ld c,a
	ld a,STS_ESP_WIFI_HEADER_SIZE
	cp c
	; If we reached maximum characters, time to figure out which wifi message it is
	jr z,JUNK_TRANSFER_STS_WIFI_H_NEXT_STATE
	; Otherwise, check if it is our header
	ld a,(JUNK_INDEX)
	ld ix,STS_ESP_WIFI_HEADER	
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_STS_WIFI_H_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_STS_WIFI_H_CP:	
	cp (ix+0)	
	jr z,JUNK_TRANSFER_STS_WIFI_H_MATCH
	; Did not match, sorry
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_WIFI_H_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_WIFI_H_NEXT_STATE:	
	ld a,b
	ld c,'D'
	cp c
	jr nz,JUNK_TRANSFER_STS_WIFI_H_CHECKG
	ld a,JUNK_STS_WIFI_D
	ld (JUNK_STATE),a
	ld a,1
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_WIFI_H_CHECKG:	
	ld a,b
	ld c,'G'
	cp c
	jr nz,JUNK_TRANSFER_STS_WIFI_H_CHECKC
	ld a,JUNK_STS_WIFI_G
	ld (JUNK_STATE),a
	ld a,1
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_WIFI_H_CHECKC:	
	ld a,b
	ld c,'C'
	cp c
	jr z,JUNK_TRANSFER_STS_WIFI_H_CHECKC_OK
	xor a
	ld (JUNK_STATE),a
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE	
JUNK_TRANSFER_STS_WIFI_H_CHECKC_OK:	
	ld a,JUNK_STS_WIFI_C
	ld (JUNK_STATE),a
	ld a,1
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE	

; Check for WIFI DISCONNECTED
JUNK_TRANSFER_STS_WIFI_D:
	ld ix,STS_ESP_WIFI_DISCONNECTED
	ld a,(JUNK_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_STS_WIFI_D_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_STS_WIFI_D_CP:	
	cp (ix+0)	
	jr z,JUNK_TRANSFER_STS_WIFI_D_MATCH
	; Did not match, sorry
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_WIFI_D_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	ld b,a
	ld a,STS_ESP_WIFI_DISCONNECTED_SIZE
	cp b
	jr z,JUNK_TRANSFER_STS_WIFI_D_DONE
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_WIFI_D_DONE:
	; Update Status Connection to Disconnected
	; ESP will send messages of any connections closed as consequence
	; no need to take care here
	ld a,UNAPI_TCPIP_NS_CLOSED
	ld (ESP_CONNECTION_STATE),a
	call CLOSE_ALL_CONNECTIONS ;all connections are now officially dead, sorry
	ld hl,0
	ld (LOCAL_IP),hl
	ld (LOCAL_IP+2),hl
	ld (LOCAL_GATEWAY),hl
	ld (LOCAL_GATEWAY+2),hl
	ld (LOCAL_NETMASK),hl
	ld (LOCAL_NETMASK+2),hl
	ld (LOCAL_PDNS),hl
	ld (LOCAL_PDNS+2),hl
	ld (LOCAL_SDNS),hl
	ld (LOCAL_SDNS+2),hl
	ld a,1
	ld (LOCAL_CURRENT),a
	ld (LOCAL_D_CURRENT),a
	xor a	
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE

; Check for WIFI CONNECTED	
JUNK_TRANSFER_STS_WIFI_C:
	ld ix,STS_ESP_WIFI_CONNECTED
	ld a,(JUNK_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_STS_WIFI_C_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_STS_WIFI_C_CP:	
	cp (ix+0)	
	jr z,JUNK_TRANSFER_STS_WIFI_C_MATCH
	; Did not match, sorry
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_WIFI_C_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	ld b,a
	ld a,STS_ESP_WIFI_CONNECTED_SIZE
	cp b
	jr z,JUNK_TRANSFER_STS_WIFI_C_DONE
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_WIFI_C_DONE:
	; Update Status Connection to Opening
	ld a,UNAPI_TCPIP_NS_OPENING
	ld (ESP_CONNECTION_STATE),a
	ld hl,0
	ld (LOCAL_IP),hl
	ld (LOCAL_IP+2),hl
	ld (LOCAL_GATEWAY),hl
	ld (LOCAL_GATEWAY+2),hl
	ld (LOCAL_NETMASK),hl
	ld (LOCAL_NETMASK+2),hl
	ld (LOCAL_PDNS),hl
	ld (LOCAL_PDNS+2),hl
	ld (LOCAL_SDNS),hl
	ld (LOCAL_SDNS+2),hl	
	ld a,1
	ld (LOCAL_CURRENT),a
	ld (LOCAL_D_CURRENT),a
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
	
; Check for WIFI GOT IP	
JUNK_TRANSFER_STS_WIFI_G:
	ld ix,STS_ESP_WIFI_GOTIP
	ld a,(JUNK_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_STS_WIFI_G_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_STS_WIFI_G_CP:	
	cp (ix+0)	
	jr z,JUNK_TRANSFER_STS_WIFI_G_MATCH
	; Did not match, sorry
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_WIFI_G_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	ld b,a
	ld a,STS_ESP_WIFI_GOTIP_SIZE
	cp b
	jr z,JUNK_TRANSFER_STS_WIFI_G_DONE
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_WIFI_G_DONE:
	; Update Status Connection to Connected
	ld a,UNAPI_TCPIP_NS_OPEN
	ld (ESP_CONNECTION_STATE),a
	xor a	
	ld (LOCAL_CURRENT),a
	ld (LOCAL_D_CURRENT),a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE

; Receiving IP from DNS
JUNK_TRANSFER_DNS_R:
	ld ix,STS_ESP_WIFI_DNS_RESOLVED
	ld a,(JUNK_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_DNS_R_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_DNS_R_CP:	
	cp (ix+0)
	jr z,JUNK_TRANSFER_DNS_R_MATCH
	; Did not match, check if 4 (+CIPR insted of +CIPD, so if it is R, we go to JUNK_TRANSFER_RECVDATA next)
	ld b,a ;restore byte in B
	ld a,(JUNK_INDEX)
	cp 4
	jr nz,JUNK_TRANSFER_DNS_R_CP_E
	;If here, let's check possible +CIPD 
	ld a,JUNK_STS_RCV_R
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_RECVDATA ;ok, it is at 5th position, let's check if it is RECVDATA
JUNK_TRANSFER_DNS_R_CP_E:	
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_DNS_R_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	ld b,a
	ld a,STS_ESP_WIFI_DNS_RESOLVED_SIZE
	cp b
	jr z,JUNK_TRANSFER_DNS_R_DONE
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_DNS_R_DONE:
	; DNS Resolved, are we in a DNS request?
	ld	a,(ESP_DNS_INPROGRESS)
	or	a ;--- DNS Query In progress?
	jp z,JUNK_TRANSFER_CHECK_DONE ; No, so nothing to do
	;Yes, so now we get a new state/status
	ld a,JUNK_STS_DNS_C
	ld (JUNK_STATE),a
	xor a
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
	
; Copy IP from DNS
JUNK_TRANSFER_DNS_C:
	ld a,13 ;check if CR, end of IP
	cp b
	jr nz,JUNK_TRANSFER_DNS_C2
	;end, so let's terminate
	ld b,0 ;string terminator
JUNK_TRANSFER_DNS_C2:
	ld a,(JUNK_INDEX)
	ld e,a
	ld d,0
	ld hl,DNS_BUFFER
	add hl,de
	ld (hl),b
	xor a
	cp b ;end?
	jr z,JUNK_TRANSFER_DNS_C_END
	;nope, increment index and back waiting
	inc e
	ld a,e
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_DNS_C_END:
	xor a
	ld (ESP_DNS_INPROGRESS),a
	; Ready to change from ASCII to 4 bytes
	ld de,DNS_RESULT
	call PARSE_IP
	jr nc,JUNK_TRANSFER_DNS_C_END_OK ; Carry? Error No Carry? Ok	
	; Error
	ld a,2
	ld (DNS_READY),a ; 2 means error	
	jr JUNK_TRANSFER_DNS_C_END_OK_R	
JUNK_TRANSFER_DNS_C_END_OK:	
	; Ok
	ld a,1
	ld (DNS_READY),a ; 1 means IP received OK
JUNK_TRANSFER_DNS_C_END_OK_R:	
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE

; Error, relevant only if DNS resolving
JUNK_TRANSFER_DNS_E:
	ld ix,STS_ESP_WIFI_ERROR
	ld a,(JUNK_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_DNS_E_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_DNS_E_CP:	
	cp (ix+0)
	jr z,JUNK_TRANSFER_DNS_E_MATCH
	; Did not match, sorry
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_DNS_E_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	ld b,a
	ld a,STS_ESP_WIFI_ERROR_SIZE
	cp b
	jr z,JUNK_TRANSFER_DNS_E_DONE
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_DNS_E_DONE:
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	; Error, are we in a DNS request?
	ld	a,(ESP_DNS_INPROGRESS)
	or	a ;--- DNS Query In progress?
	jp z,JUNK_TRANSFER_CHECK_DONE ; No, so nothing to do
	;Yes, so need to update status as error	
	xor a ;--- DNS Query not in progress...
	ld (ESP_DNS_INPROGRESS),a
	ld a,2
	ld (DNS_READY),a ; 2 means error	
	jp JUNK_TRANSFER_CHECK_DONE

; DNS Failure
JUNK_TRANSFER_DNS_F:
	ld ix,STS_ESP_WIFI_DNS_FAIL
	ld a,(JUNK_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_DNS_F_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_DNS_F_CP:	
	cp (ix+0)
	jr z,JUNK_TRANSFER_DNS_F_MATCH
	; Did not match, sorry
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_DNS_F_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	ld b,a
	ld a,STS_ESP_WIFI_DNS_FAIL_SIZE
	cp b
	jr z,JUNK_TRANSFER_DNS_F_DONE
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_DNS_F_DONE:
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	; Error, are we in a DNS request?
	ld	a,(ESP_DNS_INPROGRESS)
	or	a ;--- DNS Query In progress?
	jp z,JUNK_TRANSFER_CHECK_DONE ; No, so nothing to do
	;Yes, so need to update status as error
	xor a ;--- DNS Query not in progress...
	ld (ESP_DNS_INPROGRESS),a
	ld a,2
	ld (DNS_READY),a ; 2 means error	
	jp JUNK_TRANSFER_CHECK_DONE		
	
;Ok, possibly receiving passive TCP data, let's keep checking
JUNK_TRANSFER_RECVDATA:
	ld ix,STS_ESP_WIFI_TCP_DATA_RCV
	ld a,(JUNK_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_RECVDATA_R_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_RECVDATA_R_CP:	
	cp (ix+0)
	jr z,JUNK_TRANSFER_RECVDATA_R_MATCH
	; Did not match, check if 4 (+CIPS instead of +CIPR, so if it is S, we go to JUNK_TRANSFER_RECVCONNSTS next)
	ld b,a ;restore byte in B
	ld a,(JUNK_INDEX)
	cp 4
	jr nz,JUNK_TRANSFER_RECVDATA_R_CP_E
	;If here, let's check possible +CIPS
	ld a,JUNK_STS_RCV_CIPSTST
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_RECVCONNSTS ;ok, it is at 5th position, let's check if it is CONN STATUS
JUNK_TRANSFER_RECVDATA_R_CP_E:	
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_RECVDATA_R_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	ld b,a
	ld a,STS_ESP_WIFI_TCP_DATA_RCV_SIZE
	cp b
	jr z,JUNK_TRANSFER_RECVDATA_R_DONE
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_RECVDATA_R_DONE:
	; +CIPRECVDATA, received, next should be the size of incoming data
	ld	a,JUNK_STS_RCV_DS
	ld (JUNK_STATE),a	
	xor a
	ld (ESP_TRANSFER_REMAINING_INDEX),a
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE

;+CIPRECVDATA, received, now we gather the size, compose size until : is received	
JUNK_TRANSFER_RECVDATA_SIZE:	
	ld d,0
	ld a,(ESP_TRANSFER_REMAINING_INDEX)
	ld e,a
	ld hl,ESP_TRANSFER_REMAINING_ASCII_BUFFER
	add hl,de
	;Ok, HL has the address to put the byte
	ld a,b ;data is in B
	;Save it
	ld (hl),a
	;Ok, byte pushed, was it ':'?
	cp ':'
	;If not, one more digit, otherise convert and if success next state
	jr z,JUNK_TRANSFER_RECVDATA_SIZE_CONVERT
	;increment index
	inc e
	;save it
	ld a,e
	ld (ESP_TRANSFER_REMAINING_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
	
; Convert the received size in ASCII to a number	
JUNK_TRANSFER_RECVDATA_SIZE_CONVERT:
	; Our buffer address in HL
	ld hl,ESP_TRANSFER_REMAINING_ASCII_BUFFER
	; So, convert it 
	call EXTNUM
	; Ok, size is in BC, move it to ESP_TRANSFER_REMAINING
	ld (ESP_TRANSFER_REMAINING),bc ;so transfer knows how much to transfer
	; now signal transfer and let the transfer handler deal with the rest as it is able to transfer chunks of data :-)
	;No more junk, we are receiving data from a connection
	xor a
	ld (JUNK_STATE),a		
	ld (JUNK_INDEX),a
	;Now reset the RECVDATA bit and let the command take care
	xor a
	ld (TCPIP_CMD_SNT),a
	;disable interruptions, data reception will be done by command
	;our interrupt is not able to access app page 0, only 3 and 4
	ld a,22
	out (6),a ;disable interrupts from ESP
	jp OLD_HKEY_I
	
;Ok, possibly receiving connection information data, let's keep checking
JUNK_TRANSFER_RECVCONNSTS:
	ld ix,STS_ESP_WIFI_TCP_DATA_CONN
	ld a,(JUNK_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_RECVCONNSTS_R_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_RECVCONNSTS_R_CP:	
	cp (ix+0)
	jr z,JUNK_TRANSFER_RECVCONNSTS_R_MATCH
	; Did not match, sorry
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_RECVCONNSTS_R_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	ld b,a
	ld a,STS_ESP_WIFI_TCP_DATA_CONN_SIZE
	cp b
	jr z,JUNK_TRANSFER_RECVCONNSTS_R_DONE
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_RECVCONNSTS_R_DONE:
	; +CIPSTATUS: received, next should be the connection #
	ld a,JUNK_STS_RCV_CONN_INFO
	ld (JUNK_STATE),a	
	xor a
	ld (CHECK_CONN_STS_ON_INTERRUPT_NOT_OURS),a ;if it was pending, no longer pending
	ld (JUNK_INDEX),a
	ld (RCS_DQUOTE_COUNT),a
	jp JUNK_TRANSFER_CHECK_DONE

; JUNK_INDEX is our state indicator
; If 0, waiting conn#, if other number, number of commas retrieved, want to work on TCP connections
; If 1, waiting comma
; If 2, waiting the third double quote ( "TCP"," )
; If 3, next is the remote IP address, quoted
; If 4, waiting comma
; If 5, receiving remote port #
; If 6, receiving local port #
;+CIPSTATUS: received, now we gather the conn#, check if it is open, if it is, continue parsing	
RCS_BUFFER_VARS dw 0
RCS_DQUOTE_COUNT dw 0
JUNK_TRANSFER_RECVCONNSTS_CONN:	
	ld a,(JUNK_INDEX)
	or a	
	;0
	jr z,JUNK_TRANSFER_RECVCONNSTS_CONN_NUMBER
	dec a
	;1
	jr z,JUNK_TRANSFER_RECVCONNSTS_CONN_COMMA
	dec a
	;2
	jr z,JUNK_TRANSFER_RECVCONNSTS_CONN_DOUBLEQUOTE
	dec a
	;3
	jr z,JUNK_TRANSFER_RECVCONNSTS_CONN_REMOTE_IP
	dec a
	;4
	jr z,JUNK_TRANSFER_RECVCONNSTS_CONN_COMMA
	dec a
	;5 , remote
	jp z,JUNK_TRANSFER_RECVCONNSTS_CONN_PORT
	dec a
	;6 , now local
	jp z,JUNK_TRANSFER_RECVCONNSTS_CONN_PORT

JUNK_TRANSFER_RECVCONNSTS_CONN_UNHAPPY_ENDING	
	;If here, well, too bad
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
	
	
JUNK_TRANSFER_RECVCONNSTS_CONN_NUMBER:	
	ld a,b ;data is in B
	sub '0' 
	jr z,JUNK_TRANSFER_RECVCONNSTS_CONN_UNHAPPY_ENDING ;Conn 0 is not used/observed
	;Not 0, 1?
	dec a
	ld ix,CONN1_BUFFER_VARS
	jr z,JUNK_TRANSFER_RECVCONNSTS_IS_CONN_TCP
	;Not 1, 2?
	dec a
	ld ix,CONN2_BUFFER_VARS
	jr z,JUNK_TRANSFER_RECVCONNSTS_IS_CONN_TCP
	;Not 2, 3?
	dec a
	ld ix,CONN3_BUFFER_VARS
	jr z,JUNK_TRANSFER_RECVCONNSTS_IS_CONN_TCP
	;Not 3, 4?
	dec a
	ld ix,CONN4_BUFFER_VARS
	jr nz,JUNK_TRANSFER_RECVCONNSTS_CONN_UNHAPPY_ENDING ; If not 0 here, weird stuff, conn is not 0 to 4

JUNK_TRANSFER_RECVCONNSTS_IS_CONN_TCP:	
	ld (RCS_BUFFER_VARS),ix ;save conn vars for other parts of this processing
	; Now check if it is a TCP conn, if it is, cool, continue, otherwise, just don't care
	xor a
	cp (ix+6) ;if 0, not udp, so can go on, otherwise,UDP and don't care
	jr nz,JUNK_TRANSFER_RECVCONNSTS_CONN_UNHAPPY_ENDING ; UDP, don't care
	ld a,1
	ld (JUNK_INDEX),a ; ok, wait for comma next
	jp JUNK_TRANSFER_CHECK_DONE
	
JUNK_TRANSFER_RECVCONNSTS_CONN_COMMA:
	ld a,','
	cp b
	jr nz,JUNK_TRANSFER_RECVCONNSTS_CONN_UNHAPPY_ENDING ; should be comma!
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a ; ok, next state
	jp JUNK_TRANSFER_CHECK_DONE
	
JUNK_TRANSFER_RECVCONNSTS_CONN_DOUBLEQUOTE:
	ld a,'"'
	cp b
	jp nz,JUNK_TRANSFER_CHECK_DONE ; wait until double quote is received
	; received, increase count of DQUOTE
	ld a,(RCS_DQUOTE_COUNT)
	inc a
	ld (RCS_DQUOTE_COUNT),a
	cp 3	
	jp nz,JUNK_TRANSFER_CHECK_DONE ; wait until third double quote is received
	; Third was received
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a ; ok, next state
	xor a
	ld (IP_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE	
	
IP_INDEX db 0
JUNK_TRANSFER_RECVCONNSTS_CONN_REMOTE_IP:
; Copy IP from DNS
	ld a,'"' ;check if double quote, end of IP
	cp b
	jr nz,JUNK_TRANSFER_RECVCONNSTS_CONN_REMOTE_IP_C2
	;end, so let's terminate
	ld b,0 ;string terminator
JUNK_TRANSFER_RECVCONNSTS_CONN_REMOTE_IP_C2:
	ld a,(IP_INDEX)
	ld e,a
	ld d,0
	ld hl,DNS_BUFFER
	add hl,de
	ld (hl),b
	xor a
	cp b ;end?
	jr z,JUNK_TRANSFER_RECVCONNSTS_CONN_REMOTE_IP_END
	;nope, increment index and back waiting
	inc e
	ld a,e
	ld (IP_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_RECVCONNSTS_CONN_REMOTE_IP_END:
	; Ready to change from ASCII to 4 bytes
	ld de,(RCS_BUFFER_VARS)
	ld a,e
	add a,14 ;(+14 Remote IP for TCP conn)
	ld e,a
	jr nc,JUNK_TRANSFER_RECVCONNSTS_CONN_REMOTE_IP_END2 ;if no carry, no need to touch d
	; carry, add 1 to MSB
	inc d
JUNK_TRANSFER_RECVCONNSTS_CONN_REMOTE_IP_END2:	
	call PARSE_IP ; Remote IP will be updated there
	; Update state
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	xor a
	ld (IP_INDEX),a
	ld (GET_CONN_PORT_REMOTE),a ;First time, 0, indicating get remote, later will change to 1 to get local
	jp JUNK_TRANSFER_CHECK_DONE

; Get remote, and then local port
GET_CONN_PORT_REMOTE db 0
JUNK_TRANSFER_RECVCONNSTS_CONN_PORT:
; Ok, so now get Port
	ld d,0
	ld a,(IP_INDEX)
	ld e,a
	ld hl,DNS_BUFFER
	add hl,de
	;Ok, HL has the address to put the byte
	ld (hl),b
	;Ok, byte pushed, was it ','?
	ld a,b
	cp ','
	;If not ',', one more digit, if ',', convert
	jr z,JUNK_TRANSFER_RECVCONNSTS_CONN_CONVERT
	;increment index
	inc e
	ld a,e
	ld (IP_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
	
; Convert the received Port Number in ASCII to a number	
JUNK_TRANSFER_RECVCONNSTS_CONN_CONVERT:	
	; Our buffer address in HL
	ld hl,DNS_BUFFER
	; Convert it 
	call EXTNUM		
	; Ready to change from ASCII to 4 bytes
	ld hl,(RCS_BUFFER_VARS)
	; Check if remote or local
	ld a,(GET_CONN_PORT_REMOTE)
	or a
	;If 0, remote, otherwise, local
	jr nz,JUNK_TRANSFER_RECVCONNSTS_CONN_CONVERT_SAVE_LOCAL
	;Remote	
	ld a,l
	add a,9 ;(+9 and +10 Remote Port for TCP conn)
	jr JUNK_TRANSFER_RECVCONNSTS_CONN_CONVERT_FINAL
JUNK_TRANSFER_RECVCONNSTS_CONN_CONVERT_SAVE_LOCAL:	
	;Local
	ld a,l
	add a,18 ;(+18 and +19 Local Port for TCP conn)
JUNK_TRANSFER_RECVCONNSTS_CONN_CONVERT_FINAL:	
	ld l,a
	jr nc,JUNK_TRANSFER_RECVCONNSTS_CONN_CONVERT2
	; carry, add 1 to MSB
	inc h
JUNK_TRANSFER_RECVCONNSTS_CONN_CONVERT2:
	; Ok, move the data from BC
	ld (hl),c
	inc hl
	ld (hl),b
	; Now check if going to convert again or done
	; Check if remote or local
	ld a,(GET_CONN_PORT_REMOTE)
	or a
	;If 0, remote, otherwise, local, if we got local, done
	jr nz,JUNK_TRANSFER_RECVCONNSTS_CONN_DONE
	; Ok, no go to local
	inc a
	ld (GET_CONN_PORT_REMOTE),a ;indicate next is local
	xor a
	ld (IP_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE

JUNK_TRANSFER_RECVCONNSTS_CONN_DONE:	
	; Check if it is from a passive connection, and if it is, update it has a client connected
	ld ix,(RCS_BUFFER_VARS)
	;xor a
	;cp (ix+7) ;is passive?
	;jr z,JUNK_TRANSFER_RECVCONNSTS_CONN_DONE_E ; not, so do not care
	;it is, so let's update HAS CLIENT
	ld (ix+4),1
	;update connection state to ESTABLISHED
	ld (ix+5),4
	
JUNK_TRANSFER_RECVCONNSTS_CONN_DONE_E:	
	; Update state
	xor a
	ld (JUNK_INDEX),a	
	ld (IP_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
		
;Ok, possibly receiving connection data, let's keep checking
JUNK_TRANSFER_STS_CONN_R:	
	ld ix,STS_CONN_RCVD
	ld a,(JUNK_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_CONN_R_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_CONN_R_CP:	
	cp (ix+0)
	jr z,JUNK_TRANSFER_CONN_R_MATCH
	; Did not match, sorry
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_CONN_R_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	ld b,a
	ld a,STS_CONN_RCVD_SIZE
	cp b
	jr z,JUNK_TRANSFER_CONN_R_DONE
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_CONN_R_DONE:
	; +IPD, received, next should be the connection number
	ld	a,JUNK_STS_CONN_N
	ld (JUNK_STATE),a	
	xor a
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE

;Ok, now check if it is one of our connections
JUNK_TRANSFER_STS_CONN_N:
	ld a,b ;data received
	cp '1'
	;A should be >='1', so carry must not be set
	jr nc,JUNK_TRANSFER_STS_CONN_N1
	;it is '0' or less, so we don't care
JUNK_TRANSFER_STS_CONN_NE:	
	xor a
	ld (JUNK_STATE),a		
	ld (JUNK_INDEX),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_CONN_N1:	
	cp '5'
	;A should be < '5', so carry must be set
	jr nc,JUNK_TRANSFER_STS_CONN_NE
	sub '1'
	;Now A contains 0 to 3, let's figure out which one....	
	;1 ?
	jr nz,JUNK_TRANSFER_STS_CONN_NOT1
	;Yes
	xor a
	;No more junk, we are receiving data from a connection
	ld (JUNK_STATE),a		
	ld (JUNK_INDEX),a
	;Transfer remaining state 1, the transfer receiving routine will discard first comma and then continue
	ld a,1
	ld (ESP_TRANSFER_REMAINING_STATE),a
	;Now signal that a transfer is in progress for this connection
	ld a,(ESP_TRANSFER_INPROGRESS)
	set 1,a
	ld (ESP_TRANSFER_INPROGRESS),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_CONN_NOT1:
	dec a
	;2 ?
	jr nz,JUNK_TRANSFER_STS_CONN_NOT2
	;Yes
	xor a
	;No more junk, we are receiving data from a connection
	ld (JUNK_STATE),a		
	ld (JUNK_INDEX),a
	;Transfer remaining state 1, the transfer receiving routine will discard first comma and then continue
	ld a,1
	ld (ESP_TRANSFER_REMAINING_STATE),a
	;Now signal that a transfer is in progress for this connection
	ld a,(ESP_TRANSFER_INPROGRESS)
	set 2,a
	ld (ESP_TRANSFER_INPROGRESS),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_CONN_NOT2:
	dec a
	;3 ?
	jr z,JUNK_TRANSFER_STS_CONN_IS3
	;No, so it is 4
	xor a
	;No more junk, we are receiving data from a connection
	ld (JUNK_STATE),a		
	ld (JUNK_INDEX),a
	;Transfer remaining state 1, the transfer receiving routine will discard first comma and then continue
	ld a,1
	ld (ESP_TRANSFER_REMAINING_STATE),a
	;Now signal that a transfer is in progress for this connection
	ld a,(ESP_TRANSFER_INPROGRESS)
	set 4,a
	ld (ESP_TRANSFER_INPROGRESS),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_CONN_IS3:
	;Ok, 3 it is
	xor a
	;No more junk, we are receiving data from a connection
	ld (JUNK_STATE),a		
	ld (JUNK_INDEX),a
	;Transfer remaining state 1, the transfer receiving routine will discard first comma and then continue
	ld a,1
	ld (ESP_TRANSFER_REMAINING_STATE),a
	;Now signal that a transfer is in progress for this connection
	ld a,(ESP_TRANSFER_INPROGRESS)
	set 3,a
	ld (ESP_TRANSFER_INPROGRESS),a
	jp JUNK_TRANSFER_CHECK_DONE
	
CHECK_CONN_STS_ON_INTERRUPT_NOT_OURS db 0	
;Connection closing?	
JUNK_TRANSFER_STS_CONN_C:
	ld ix,STS_CONN_CLOSED
	ld a,(JUNK_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (JUNK_TRANSFER_STS_CONN_C_CP+2),a
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
	ld a,b
JUNK_TRANSFER_STS_CONN_C_CP:	
	cp (ix+0)	
	jr z,JUNK_TRANSFER_STS_CONN_C_MATCH
	; Did not match, sorry
	; X,CLOSED it is not... But is it X,CONNECT?
	ld a,(JUNK_INDEX)
	cp 3 ;if did not match in third index, chance it is a connect
	jr nz,JUNK_TRANSFER_STS_CONN_C_CP_NOMATCH ; not index 3, so really no match
	;It is, just check if it is O, if it is, let's assume it is connect and check if
	;this is a connection needing to receive data (I.e.:passive, get status to know)
	;which is remote IP and remote PORT connecting
	ld a,'O'
	cp b
	jr nz,JUNK_TRANSFER_STS_CONN_C_CP_NOMATCH ; not O either, so really no match
	;it is O, so just mark that next interrupt not by ESP and with fifo clear we will check conn sts
	;ld a,1
	;ld (CHECK_CONN_STS_ON_INTERRUPT_NOT_OURS),a
	call CHECK_PASSIVE_CONNECTION	
JUNK_TRANSFER_STS_CONN_C_CP_NOMATCH:		
	xor a
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_CONN_C_MATCH:	
	ld a,(JUNK_INDEX)
	inc a
	ld (JUNK_INDEX),a
	ld b,a
	ld a,STS_CONN_CLOSED_SIZE
	cp b
	jr z,JUNK_TRANSFER_STS_CONN_C_DONE
	jp JUNK_TRANSFER_CHECK_DONE
JUNK_TRANSFER_STS_CONN_C_DONE:
	; Update Status Connection to Closed	
	call CONNECTION_CLOSE	
	xor a	
	ld (JUNK_INDEX),a
	ld (JUNK_STATE),a
	jp JUNK_TRANSFER_CHECK_DONE
	
DE_Times_A:
;Inputs:
;     DE and A are factors
;Outputs:
;     A is not changed
;     B is 0
;     C is not changed
;     DE is not changed
;     HL is the product
;Time:
;     342+6x
;
     ld b,8          ;7           7
     ld hl,0         ;10         10
       add hl,hl     ;11*8       88
       rlca          ;4*8        32
       jr nc,$+3     ;(12|18)*8  96+6x
         add hl,de   ;--         --
       djnz $-5      ;13*7+8     99
     ret             ;10         10

;*********************************************
;***          CLEAR_CMD_BUFFER             ***
;*** Once done, discard remaining bytes and***
;*** return.                               ***
;***                                       ***
;*** Inputs:                               ***
;***                                       ***
;*** Output:                               ***
;***                                       ***
;*** Changes A                             ***
;*********************************************
CLEAR_CMD_BUFFER:
	xor a
	ld (CMD_RAM_BUFFER_DATA_SIZE),a
	ld (CMD_RAM_BUFFER_DATA_SIZE+1),a
	ret

;*********************************************
;***           POP_BUFFER_BYTE             ***
;*** Will get a byte from buffer and return***
;*** it in A.                              ***
;***                                       ***
;*** Inputs:                               ***
;***                                       ***
;*** IX: Variables of Buffer to Pop        ***
;***                                       ***
;*** Output:                               ***
;*** A - data from buffer                  ***
;*** Carry - Clear if Data, Set if no Data ***
;***                                       ***
;*** Changes A, Carry Flag.                ***
;*********************************************
POP_BUFFER_BYTE:
	push hl ; save HL
	push de ; save DE
	ld l,(ix+0)
	ld h,(ix+1) ; free in HL
	inc hl
	ld de,EACH_CONNECTION_BUFFER_SIZE + 1
	; DE has buffer size + 1, if HL equal, means FREE = BUFFERSIZE, no data	
	ld a,l
	xor e 
	jr nz,PBB_HAS_DATA	;if not equal, has data
	ld a,h
	xor d 
	jr nz,PBB_HAS_DATA	;if not equal, has data		
	;BUFFER FREE = BUFFER SIZE, no data, sorry
	scf ; set carry
	pop de
	pop hl ; restore HL
	ret
PBB_HAS_DATA:	
	; Save new Free
    ld (ix+0),l
	ld (ix+1),h
	; Now get the byte from buffer to A, and update buffer variables
	ld e,(ix+4)
	ld d,(ix+5) ; Bottom in de
	ld l,(ix+12)
	ld h,(ix+13) ; Buffer start address in hl
	add hl,de
	;HL pointing to buffer bottom address
	ld l,(hl)
	;Byte read from buffer, now update bottom
	inc de
	; Now check if Bottom = top RAM position (Bottom is in DE)
    ; Start with LSB
    ld a,EACH_CONNECTION_BUFFER_SIZE_LSB
    xor e
    ; if LSB not equal, no need to check MSB
    jr nz,PBB_BUFFER_NO_LEAP
    ; LSB equal, and MSB?
    ld a,EACH_CONNECTION_BUFFER_SIZE_MSB
    xor d
    ; if MSB not equal, just keep going
    jr nz,PBB_BUFFER_NO_LEAP
    ; Equal, so we will leap here and Bottom goes back to index 0
    ld de,0
PBB_BUFFER_NO_LEAP:
	ld (ix+4),e
	ld (ix+5),d ; save new bottom
	; data return is A
	ld a,l
	;Clear Carry Flag
	or a; will not change a and  will clear carry	
	pop de
	pop hl ; restore HL
	; Done
	ret	
	
;*********************************************
;***         POP_CMD_BUFFER_BYTE           ***
;*** Will get a byte from CMD buffer and   ***
;*** return it in A.                       ***
;***                                       ***
;*** Inputs:                               ***
;***                                       ***
;*** Output:                               ***
;*** A - data from buffer                  ***
;*** Carry - Clear if Data, Set if no Data ***
;***                                       ***
;*** Changes A, DE, Carry Flag.            ***
;*********************************************
POP_CMD_BUFFER_BYTE:
	push hl
	xor a
	ld hl,(CMD_RAM_BUFFER_DATA_SIZE)	
	or l
	jr nz,PCBB_HAS_DATA
	or h
	jr nz,PCBB_HAS_DATA
	; CMD BUFFER DATA SIZE is 0, nothing to pop
PCBB_RET_NO_DATA:
	pop hl
	scf ; set carry
	ret
PCBB_HAS_DATA:	
	ld de,(CMD_BUFFER_POINTER)
	or a; clear carry
	sbc hl,de ; (DATA_SIZE) - POINTER, 
	jr z,PCBB_RET_NO_DATA ; pointer read all
	; If here, data to read
	ld hl,CMD_RAM_BUFFER
	add hl,de ; HL has CMD BUFFER address relative to pointer
	ld a,(hl) ; get buffer byte
	inc de 
	ld (CMD_BUFFER_POINTER),de
	or a ; clear carry
	pop hl
	ret

;*********************************************
;***         FIND_TOKEN_IN_BUFFER          ***
;*** Will leave buffer right after token,  ***
;*** discarding all data until token found.***
;***                                       ***
;*** Inputs:                               ***
;*** CMD_BUFFER_POINTER holds current pos  ***
;*** IX - Where token is stored            ***
;*** C - Token Size                        ***
;***                                       ***
;*** Output:                               ***
;*** A - 0 if token found, buffer is after ***
;*** token; otherwise token not found and  ***
;*** buffer is now empty.                  ***
;*** CMD_BUFFER_POINTER if found, buffer   ***
;*** position just after it                ***
;***                                       ***
;*** IX and C won't change, B, DE, HL, A,  ***
;*** and CMD_BUFFER_POINTER will change.   ***
;*********************************************
FIND_TOKEN_IN_BUFFER:
	xor a
	ld (CMD_RSP_INDEX),a
FTIB_RETURN:	
	call POP_CMD_BUFFER_BYTE	
	ld b,a ;save data in A
	jr nc,FTIB_CONTINUE ;if carry clear has data	
	ld a,1 ;carry set, end
	ret
FTIB_CONTINUE:		
	ld a,(CMD_RSP_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (FTIB_IDXCMD+2),a
	; move data back to A
	ld a,b
	; Ok, now the byte is in A, let's compare
FTIB_IDXCMD:	
	cp (ix+0)
	;if match
	jr z,FTIB_RSP_MATCH
	;did not match, let's zero the rsp index
	xor a
	ld (CMD_RSP_INDEX),a
	;back to get another byte
	jr FTIB_RETURN
FTIB_RSP_MATCH:	
	;match
	ld a,(CMD_RSP_INDEX)
	inc a	
	cp c
	;if a = c done and response is success
	jr z,FTIB_RET_OK
	;not done, save new index
	ld (CMD_RSP_INDEX),a
	;back to get more bytes
	jr FTIB_RETURN
FTIB_RET_OK:
	xor a
	ret	

;**********************************************
;***           SEND COMMAND                 ***
;*** Inputs:							    ***
;*** HL - Address of Command String         ***
;*** D - Size of Command				    ***
;*** IX -Response Expected					***
;*** E - Size of Response				    ***
;*** C - Timeout in Seconds					***
;***										***
;*** Output:								***
;*** A - 0 OK / 1 TIMEOUT					***
;***										***
;*** Will mess with all registers!			***
;**********************************************
SEND_COMMAND:		
	ld a,(ESP_TRANSFER_INPROGRESS)
	or a
	jr nz,SEND_COMMAND ; Avoid executing a command while receiving transfer
	; Ok, doing nothing, let's send our command
	ld a,1
	ld (ESP_CMD_INPROGRESS),a
	xor a
	; New command, so let's zero the cmd buffer vars
	ld (CMD_RAM_BUFFER_DATA_SIZE),a
	ld (CMD_RAM_BUFFER_DATA_SIZE+1),a
	ld (CMD_BUFFER_POINTER),a
	ld (CMD_BUFFER_POINTER+1),a
	; Set CMD_RSP_INDEX to 0, A is already 0
	ld (CMD_RSP_INDEX),a
	; Save Timeout in A
	ld a,c 	
	; otir will output in the port in C
	ld c,7 ;our data TX port
	; Port in C, command is already at HL, move size to B	
	ld b,d
	; otir 
SEND_COMMAND_WT:	
	in d,(c)
	bit 1,d ;TX free?
	jr nz,SEND_COMMAND_WT
	outi
	jr nz,SEND_COMMAND_WT
	; move response size to B
	ld b,e	
	; Save response size (B), as it is going to be used later in DE_Times_A
	push bc
	; Command sent,let's start looking for the response
	; Let's calculate timeout in 1/60s (multiply it times 60)		
	ld de,60		
	call DE_Times_A ; HL = A (Timeout) * DE (60)
	; Restore response size (B)
	pop bc	
	ld de,(JIFFY)
	add hl,de	
	;if HL+DE did not carry, will not leap
	ld c,0
	jr nc,SND_CMD_NO_LEAP
	;otherwise, overlap, so JIFFY needs to leap before we compare
	ld c,1	

SND_CMD_NO_LEAP:	
	; At this point we have our timeout in HL
	; C is 0 if no leap, 1 if leap (wait JIFFY go to 0 first)
	; B contains the response size
	; IX contains the desired response	
	; We can use A, DE and IY	
SND_CMD_WAIT_RSP:
	call POP_CMD_BUFFER_BYTE	
	; If carry clear, there is data and it is in A
	jr nc,SND_CMD_CHK_RX
	; no byte to check, check for time out
	ld a,c
	or a
	jr z,SND_CMD_CHK_TIMEOUT
	;If we are here, we are waiting jiffy to leap, so check if MSB is zero
	ld a,(JIFFY+1)
	or a
	;If not zero, no leap, so keep waiting and no time out for sure
	jr nz,SND_CMD_WAIT_RSP
	;It is zero, so let's clear the leap flag and check time-out comparing HL to JIFFY
	ld c,0
SND_CMD_CHK_TIMEOUT:
	;Ok, compare HL to JIFFY, first save it
	ld a,l
	ld de,(JIFFY)
	sub e
	ld a,h
	sbc a,d	
	jr nc,SND_CMD_WAIT_RSP	
	xor a
	ld (ESP_CMD_INPROGRESS),a
	; TIMEOUT - JIFFY, if carry, TIMEOUT < JIFFY, so time expired
	; If TIMEOUT, won't restore buffer, just discard it as it was no good
	; but need to pop the stack if it was pushed	
	ld a,1
	ret

SND_CMD_CHK_RX:		
	; Save Byte Read (A)
	push af
	ld a,(CMD_RSP_INDEX)
	; CP (IX+*) is DD BE *, so we are going to change * to the actual count
	ld (SND_CMD_CHK_RX_IDXCMD+2),a
	; Restore A with the byte from buffer
	pop af
	; Ok, now the byte is in A, we've updated buffer variables, let's check for response
SND_CMD_CHK_RX_IDXCMD:	
	cp (ix+0)
	;if match
	jr z,SND_CMD_CHK_RSP_MATCH
	;did not match, let's zero the rsp index	
	xor a
	ld (CMD_RSP_INDEX),a
	;back to waiting
	jp SND_CMD_WAIT_RSP
SND_CMD_CHK_RSP_MATCH:	
	;match
	ld a,(CMD_RSP_INDEX)
	inc a
	cp b
	;if a = b done and response is success
	jr z,SND_CMD_CHK_RX_RET_OK
	;not equal, save new index
	ld (CMD_RSP_INDEX),a
	;back to waiting for more bytes
	jp SND_CMD_WAIT_RSP
SND_CMD_CHK_RX_RET_OK:	
	xor a
	ld (ESP_CMD_INPROGRESS),a
	xor a
	ret

	
;*********************************************
;***           CHECK BAUDRATE              ***
;*** Current BaudRate will be stored in	   ***
;*** ESP_UART_SPEED, from 0 to 9, or #FF if***
;*** couldn't find ESP...				   ***
;*********************************************
CHECK_BAUD:
	ld a,20
	out (6),a ;Clear UART
	xor a
	;Start testing speed 0
	ld (ESP_UART_SPEED),a
SET_BAUD:	
	ld hl,CMD_ECHO_OFF_ESP ;Command used
	ld d,CMD_ECHO_OFF_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,1 ;TimeOut	
	;Send the command to set the speed
	out (6),a
	;Wait until next interrupt
	halt
	;Now Send the Echo Off command
	call SEND_COMMAND
	;If A = 0 success, else, failure
	or a
	;If found, done
	ret z
	;Not found, get the current speed
	ld a,(ESP_UART_SPEED)
	;Increase
	inc a
	;Save back to memory
	ld (ESP_UART_SPEED),a
	;Let's check if it is past 7
	ld c,10
	cp c
	;No, so try again the new speed
	jr nz,SET_BAUD
	;It is, so mark in speed that no good speed was found
	ld a,#FF
	ld (ESP_UART_SPEED),a
	;DONE
	ret

;*********************************************
;***            ECHO_OFF_ESP               ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
ECHO_OFF_ESP:
	ld hl,CMD_ECHO_OFF_ESP ;Command used
	ld d,CMD_ECHO_OFF_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,1 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	ret
	
;*********************************************
;***              RESET ESP                ***
;*** If RESET ok, A will be 0, otherwise   ***
;*** failure							   ***
;*********************************************
RESET_ESP:
	ld hl,CMD_RESET_ESP ;Command used
	ld d,CMD_RESET_ESP_SIZE
	ld ix,RSP_CMD_RESET_ESP ;Response Expected
	ld e,RSP_CMD_RESET_ESP_SIZE
	ld c,10 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	ret
	
;*********************************************
;***             SET ESP_MODE              ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
SET_ESP_MODE:
	ld hl,CMD_SET_ESP_MODE ;Command used
	ld d,CMD_SET_ESP_MODE_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,2 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	ret	
	
;*********************************************
;***        SET ESP_NO_SLEEP               ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
SET_ESP_NO_SLEEP:
	ld hl,CMD_SET_ESP_NOSLEEP ;Command used
	ld d,CMD_SET_ESP_NOSLEEP_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,2 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	ret	

;*********************************************
;***       SET ESP_APLIST_MODE             ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
;SET_ESP_APLIST_MODE:
;	ld hl,CMD_SET_ESP_APLISTMODE ;Command used
;	ld d,CMD_SET_ESP_APLISTMODE_SIZE
;	ld ix,RSP_OK_ESP ;Response Expected
;	ld e,RSP_OK_SIZE
;	ld c,2 ;TimeOut	
;	;Now Send the command
;	call SEND_COMMAND
;	ret	

;*********************************************
;***       SET_ESP_PASSIVE_RCV             ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
SET_ESP_PASSIVE_RCV:
	ld hl,CMD_SET_ESP_PASSIVE_RCV_MODE ;Command used
	ld d,CMD_SET_ESP_PASSIVE_RCV_MODE_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,2 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	ret		
	
;*********************************************
;***       SET ESP_MULTIPLE_CONN           ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
SET_ESP_MULTIPLE_CONN:
	ld hl,CMD_SET_ESP_MULTIPLE_CONN ;Command used
	ld d,CMD_SET_ESP_MULTIPLE_CONN_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,2 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	ret		
	
;*********************************************
;***       SET_ESP_IPD_EXTRA_INFO          ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
SET_ESP_IPD_EXTRA_INFO:
	ld hl,CMD_SET_ESP_IPD_INFO ;Command used
	ld d,CMD_SET_ESP_IPD_INFO_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,2 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	ret			

;*********************************************
;***          ESP_RESERVE_CONN0            ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
ESP_RESERVE_CONN0:
	ld hl,CMD_ESP_RESERVE_CONN0 ;Command used
	ld d,CMD_ESP_RESERVE_CONN0_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,2 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	ret		

;*********************************************
;***       ESP_CLOSE_LAST_PASSIVE          ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
ESP_CLOSE_LAST_PASSIVE:
	ld hl,CMD_GET_ESP_STOP_TCP_LISTEN ;Command used
	ld d,CMD_GET_ESP_STOP_TCP_LISTEN_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,2 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	ret		

;*********************************************
;***         SEND_CIPSTATUS_CMD            ***
;*** Just send the command, no wait resp.  ***
;*********************************************	
SEND_CIPSTATUS_CMD:	
;	ld hl,CMD_GET_ESP_CONN_STS ;Command used
;	ld d,CMD_GET_ESP_CONN_STS_SIZE
;	ld ix,RSP_OK_ESP ;Response Expected
;	ld e,RSP_OK_SIZE
;	ld c,2 ;TimeOut	
;	;Now Send the command
;	call SEND_COMMAND
;	ret
	ld a,(ESP_TRANSFER_INPROGRESS)
	or a
	jr nz,SEND_CIPSTATUS_CMD ; Avoid executing a command while receiving transfer to not get "busy"
	;Now send it using otir
	ld b,CMD_GET_ESP_CONN_STS_SIZE
	ld c,7 ;our data TX port
	ld hl,CMD_GET_ESP_CONN_STS
	;oti
	;otir will cause wait, that will stop processing while previous byte is sent
	;which in turn stop interrupts, the world and everything else
SEND_CIPSTATUS_CMD_WT:	
	in a,(c)
	bit 1,a ;TX free?
	jr nz,SEND_CIPSTATUS_CMD_WT
	outi
	jr nz,SEND_CIPSTATUS_CMD_WT
	; done sending, ret
	ret
	
;*********************************************
;***        GET_ESP_DNS_CONF               ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
GET_ESP_DNS_CONF:
	ld hl,CMD_GET_ESP_DNS_CONF ;Command used
	ld d,CMD_GET_ESP_DNS_CONF_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,3 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	or a
	jr nz,GET_ESP_DNS_CONF_RET_ERR	
	;If here, response is in buffer, let's parse it 	
	;a = 0
	ld (CMD_BUFFER_POINTER),a ;so we can parse the response
	ld (CMD_BUFFER_POINTER+1),a
	ld (CMD_RSP_INDEX),a ; zero index as well
	;First information will be our Primary DNS IP address
	ld ix,RSP_ESP_IP_CONF_DNS
	ld c,RSP_ESP_IP_CONF_DNS_SIZE
	call FIND_TOKEN_IN_BUFFER
	or a	
	;a is not zero, did not find information, done
	jr nz,GET_ESP_DNS_CONF_RET_ERR
	;ok, IP found, let's copy it and then transform it
	ld ix,DNS_BUFFER
	ld c,0
GEDC_FOUND_PDNS_GET_DATA:			
	call POP_CMD_BUFFER_BYTE
	jr nc,GEDC_FOUND_PDNS_GET_DATA_CONTINUE
	;if no more data (carry set) and still did not get it, error
	jr GET_ESP_DNS_CONF_RET_ERR	
GEDC_FOUND_PDNS_GET_DATA_CONTINUE:		
	ld b,13 ; (DNS IP ends with \r\n)
	cp b
	jr z,GEDC_PDNS_DONE
	; Not finished, so move data to buffer
	ld (ix+0),a ;Copy data
	inc ix	
	jr GEDC_FOUND_PDNS_GET_DATA
GEDC_PDNS_DONE:
	xor a
	ld (ix+0),a ;terminate string with 0
	ld de,LOCAL_PDNS
	call PARSE_IP ; Now parse the string
	jr nc,GEDC_FIND_SDNS	
	;Carry set, error
	jr GET_ESP_DNS_CONF_RET_ERR
	
;Second information will be our Secondary DNS IP address
GEDC_FIND_SDNS:	
	ld ix,RSP_ESP_IP_CONF_DNS
	ld c,RSP_ESP_IP_CONF_DNS_SIZE
	call FIND_TOKEN_IN_BUFFER
	or a	
	;a is not zero, did not find information, done
	jr nz,GET_ESP_DNS_CONF_RET_ERR
	;ok, IP found, let's copy it and then transform it
	ld ix,DNS_BUFFER
	ld c,0
GEDC_FOUND_SDNS_GET_DATA:			
	call POP_CMD_BUFFER_BYTE
	jr nc,GEDC_FOUND_SDNS_GET_DATA_CONTINUE
	;if no more data (carry set) and still did not get it, error
	jr GET_ESP_DNS_CONF_RET_ERR	
GEDC_FOUND_SDNS_GET_DATA_CONTINUE:		
	ld b,13 ; (DNS IP ends with \r\n)
	cp b
	jr z,GEDC_SDNS_DONE
	; Not finished, so move data to buffer
	ld (ix+0),a ;Copy data
	inc ix	
	jr GEDC_FOUND_SDNS_GET_DATA
GEDC_SDNS_DONE:
	xor a
	ld (ix+0),a ;terminate string with 0
	ld de,LOCAL_SDNS
	call PARSE_IP ; Now parse the string
	jr nc,GEDC_FOUND_SDNS_DONE
	;Carry set, error
GET_ESP_DNS_CONF_RET_ERR:
	call CLEAR_CMD_BUFFER	
	ld a,1
	ret	
	
GEDC_FOUND_SDNS_DONE:	
	; DONE!	
	ld a,1
	ld (LOCAL_D_CURRENT),a
	call CLEAR_CMD_BUFFER
	xor a
	ret		
	
	
;*********************************************
;***          GET_ESP_IP_CONF              ***
;*** If ok, A will be 0, otherwise failure ***
;*********************************************
GET_ESP_IP_CONF:	
	ld hl,CMD_GET_ESP_IP_CONF ;Command used
	ld d,CMD_GET_ESP_IP_CONF_SIZE
	ld ix,RSP_OK_ESP ;Response Expected
	ld e,RSP_OK_SIZE
	ld c,3 ;TimeOut	
	;Now Send the command
	call SEND_COMMAND
	or a
	jp nz,GET_ESP_IP_CONF_RET_ERR	
	;If here, response is in buffer, let's parse it 	
	;a = 0
	ld (CMD_BUFFER_POINTER),a ;so we can parse the response
	ld (CMD_BUFFER_POINTER+1),a
	ld (CMD_RSP_INDEX),a ; zero index as well
	;First information will be our current IP address
	ld ix,RSP_ESP_IP_CONF_IP
	ld c,RSP_ESP_IP_CONF_IP_SIZE
	call FIND_TOKEN_IN_BUFFER
	or a	
	;a is not zero, did not find information, done
	jp nz,GET_ESP_IP_CONF_RET_ERR
	;ok, IP found, let's copy it and then transform it
	ld ix,DNS_BUFFER
	ld c,0
GEIC_FOUND_IP_GET_DATA:			
	call POP_CMD_BUFFER_BYTE
	jr nc,GEIC_FOUND_IP_GET_DATA_CONTINUE
	;if no more data (carry set) and still did not get it, error
	jp GET_ESP_IP_CONF_RET_ERR	
GEIC_FOUND_IP_GET_DATA_CONTINUE:		
	ld b,'"'
	cp b
	jr z,GEIC_IP_DONE
	; Not finished, so move data to buffer
	ld (ix+0),a ;Copy data
	inc ix	
	jr GEIC_FOUND_IP_GET_DATA
GEIC_IP_DONE:
	xor a
	ld (ix+0),a ;terminate string with 0
	ld de,LOCAL_IP
	call PARSE_IP ; Now parse the string
	jr nc,GEIC_FIND_GATEWAY
	;Carry set, error
	jp GET_ESP_IP_CONF_RET_ERR
GEIC_FIND_GATEWAY:		
	;Now let's work on gateway
	ld ix,RSP_ESP_IP_CONF_GATEWAY
	ld c,RSP_ESP_IP_CONF_GATEWAY_SIZE
	call FIND_TOKEN_IN_BUFFER
	or a
	;a is not zero, did not find information, done
	jp nz,GET_ESP_IP_CONF_RET_ERR
	;ok, GATEWAY found, let's copy it and then transform it
	ld ix,DNS_BUFFER
	ld c,0
GEIC_FOUND_GATEWAY_GET_DATA:			
	call POP_CMD_BUFFER_BYTE
	jr nc,GEIC_FOUND_GATEWAY_GET_DATA_CONTINUE
	;if no more data (carry set) and still did not get it, error
	jp GET_ESP_IP_CONF_RET_ERR	
GEIC_FOUND_GATEWAY_GET_DATA_CONTINUE:		
	ld b,'"'
	cp b
	jr z,GEIC_GATEWAY_DONE
	; Not finished, so move data to buffer
	ld (ix+0),a ;Copy data
	inc ix	
	jr GEIC_FOUND_GATEWAY_GET_DATA
GEIC_GATEWAY_DONE:
	xor a
	ld (ix+0),a ;terminate string with 0
	ld de,LOCAL_GATEWAY
	call PARSE_IP ; Now parse the string
	jr nc,GEIC_FIND_NETMASK
	;Carry set, error
	jp GET_ESP_IP_CONF_RET_ERR	
GEIC_FIND_NETMASK:	
	;Now let's work on netmask
	ld ix,RSP_ESP_IP_CONF_NETMASK
	ld c,RSP_ESP_IP_CONF_NETMASK_SIZE
	call FIND_TOKEN_IN_BUFFER
	or a
	;a is not zero, did not find information, done
	jp nz,GET_ESP_IP_CONF_RET_ERR	
	;ok, NETMASK found, let's copy it and then transform it
	ld ix,DNS_BUFFER
	ld c,0
GEIC_FOUND_NETMASK_GET_DATA:			
	call POP_CMD_BUFFER_BYTE
	jr nc,GEIC_FOUND_NETMASK_GET_DATA_CONTINUE
	;if no more data (carry set) and still did not get it, error
	jp GET_ESP_IP_CONF_RET_ERR	
GEIC_FOUND_NETMASK_GET_DATA_CONTINUE:		
	ld b,'"'
	cp b
	jr z,GEIC_NETMASK_DONE
	; Not finished, so move data to buffer
	ld (ix+0),a ;Copy data
	inc ix	
	jp GEIC_FOUND_NETMASK_GET_DATA
GEIC_NETMASK_DONE:
	xor a
	ld (ix+0),a ;terminate string with 0
	ld de,LOCAL_NETMASK	
	call PARSE_IP ; Now parse the string
	jr nc,GEIC_FOUND_NETMASK_DONE
	;Carry set, error
	jp GET_ESP_IP_CONF_RET_ERR	
GEIC_FOUND_NETMASK_DONE:	
	; DONE!	
	ld a,1
	ld (LOCAL_CURRENT),a
	call CLEAR_CMD_BUFFER
	xor a
	ret
GET_ESP_IP_CONF_RET_ERR:
	call CLEAR_CMD_BUFFER	
	ld a,1
	ret
	
;DEBUG1_S:	db	"{1}",13,10,"$"
;DEBUG2_S:	db	"{2}",13,10,"$"
;DEBUG3_S:	db	"{3}",13,10,"$"
;DEBUG4_S:	db	"{4}",13,10,"$"
;DEBUG5_S:	db	"{5}",13,10,"$"
;DEBUG6_S:	db	"{6}",13,10,"$"
;DEBUG7_S:	db	"{7}",13,10,"$"

;	push af
;	push hl
;	push bc
;	ld hl,CMD_ESP_CLOSE_CONN
;	ld a,CMD_ESP_CLOSE_CONN_SIZE
;LOOPCMD1:	
;	ld b,(hl)
;	PUTCHAR b
;	inc hl
;	dec a
;	jr nz,LOOPCMD1
;	pop bc
;	pop hl
;	pop af


;*********************************************
;***     Interrupt Junk Transfer States    ***
;*** Determine if receiving an unsolicited ***
;*** message, DNS data or just throw away  ***
;*********************************************
JUNK_NO_STS equ 0 ; Just throwing away
JUNK_STS_WIFI_H equ 1 ;Evaluating a possible "WIFI " header 
JUNK_STS_WIFI_D equ 2 ;Evaluating a possible "WIFI DISCONNECT" message
JUNK_STS_WIFI_C equ 3 ;Evaluating a possible "WIFI CONNECTED" message
JUNK_STS_WIFI_G equ 4 ;Evaluating a possible "WIFI GOT IP" message
JUNK_STS_CONN_C equ 5 ;Evaluating a possible connection closed message
JUNK_STS_CONN_R equ 6 ;Evaluating a possible message containing received data
JUNK_STS_DNS_R equ 7 ;Evaluating a possible DNS resolution message
JUNK_STS_ERROR equ 8 ;Evaluating a possible error message
JUNK_STS_DNS_F equ 9 ;Evaluating a possible DNS resolution failure message
JUNK_STS_P equ 10  ;Evaluating a possible message that could be +C (DNS)... +I(Receive data)...
JUNK_STS_DNS_C equ 11 ;DNS resolved, move to the desired address
JUNK_STS_CONN_N equ 12 ;+IPD, get connection number and information of transfer
JUNK_STS_RCV_R equ 13 ;Evaluating a possible TCP Passive Receiving data message
JUNK_STS_RCV_DS equ 14 ;Getting size of TCP Passive Receiving data message
JUNK_STS_RCV_CIPSTST equ 15 ;Evaluating a possible Connection Information message
JUNK_STS_RCV_CONN_INFO equ 16 ;Getting connection #, Remote IP, Remote Port of TCP connection information
JUNK_STATE db JUNK_NO_STS ;Default throwing away

;*********************************************
;***       ESP Unsolicited messages        ***
;*** Messages that junk collector can rcv  ***
;*** and translate into actions/status     ***
;*********************************************
STS_ESP_WIFI_HEADER db "WIFI " ;Common header for the three msgs below
STS_ESP_WIFI_HEADER_SIZE equ 5
STS_ESP_WIFI_DISCONNECTED db "DISCONNECT" ;Wifi Connection Lost
STS_ESP_WIFI_DISCONNECTED_SIZE equ 10
STS_ESP_WIFI_CONNECTED db "CONNECTED" ;Connected to AP, but did not configure IPs
STS_ESP_WIFI_CONNECTED_SIZE equ 9
STS_ESP_WIFI_GOTIP db "GOT IP" ;Connected to AP and IP's are ok, good to go
STS_ESP_WIFI_GOTIP_SIZE equ 6
STS_ESP_WIFI_ERROR db "ERROR" ;Invalid commands or error executing a command (i.e.: DNS)
STS_ESP_WIFI_ERROR_SIZE equ 5
STS_ESP_WIFI_BUSY db "busy p..." ;ESP is busy and ignoring commands
STS_ESP_WIFI_BUSY_SIZE equ 9
STS_ESP_WIFI_DNS_FAIL db "DNS Fail" ;DNS query has failed
STS_ESP_WIFI_DNS_FAIL_SIZE equ 8
STS_ESP_WIFI_DNS_RESOLVED db "+CIPDOMAIN:" ;DNS query has resolved to:
STS_ESP_WIFI_DNS_RESOLVED_SIZE equ 11
STS_ESP_WIFI_TCP_DATA_RCV db "+CIPRECVDATA," ;passive TCP data receiving
STS_ESP_WIFI_TCP_DATA_RCV_SIZE equ 13
STS_ESP_WIFI_TCP_DATA_CONN db "+CIPSTATUS:" ;connection information receiving
STS_ESP_WIFI_TCP_DATA_CONN_SIZE equ 11
STS_CONN_CLOSED db "0,CLOSED" ;Connection 0 closed (Int routine check conn number)
STS_CONN_CLOSED_SIZE equ 8
STS_CONN_RCVD db "+IPD," ;Data received from a connection
STS_CONN_RCVD_SIZE equ 5
STS_CONN_OPENED db "0,CONNECT" ;Connection 0 closed (Int routine check conn number)
STS_CONN_OPENED_SIZE equ 9
	
;*********************************************
;***      ESP Commands and responses       ***
;*** Commands used by our implementation   ***
;*** and expected responses                ***
;*********************************************
;Turn Off Echo
CMD_ECHO_OFF_ESP db "ATE0",13,10 
CMD_ECHO_OFF_SIZE equ 6
; Most commands return "OK" when done
RSP_OK_ESP db "OK",13,10
RSP_OK_SIZE equ 4
;Warm reset of ESP firmware
CMD_RESET_ESP db "AT+RST",13,10
CMD_RESET_ESP_SIZE equ 8
;After finishing Warm reset, ESP returns ready
RSP_CMD_RESET_ESP db "ready",13,10
RSP_CMD_RESET_ESP_SIZE equ 7
;ESP as client, we are not using the AP role
CMD_SET_ESP_MODE db "AT+CWMODE_CUR=1",13,10
CMD_SET_ESP_MODE_SIZE equ 17
;Do not allow ESP to sleep, no need, not battery powered
CMD_SET_ESP_NOSLEEP db "AT+SLEEP=0",13,10
CMD_SET_ESP_NOSLEEP_SIZE equ 12
;When listing available AP's, strongest signal first, we just care about encryption and SSID information
;CMD_SET_ESP_APLISTMODE db "AT+CWLAPOPT=0,3",13,10
;CMD_SET_ESP_APLISTMODE_SIZE equ 17
;Allow multiple (up to 5) connections, our implementation use up to 4
CMD_SET_ESP_MULTIPLE_CONN db "AT+CIPMUX=1",13,10
CMD_SET_ESP_MULTIPLE_CONN_SIZE equ 13
;TCP comm will be buffered by ESP and data received will be sent to us only when we request
CMD_SET_ESP_PASSIVE_RCV_MODE db "AT+CIPRECVMODE=1",13,10
CMD_SET_ESP_PASSIVE_RCV_MODE_SIZE equ 18
;Request that the received information include also sender's IP and Port
CMD_SET_ESP_IPD_INFO db "AT+CIPDINFO=1",13,10
CMD_SET_ESP_IPD_INFO_SIZE equ 15
;Obtain IP/Gateway/Netmask being used
CMD_GET_ESP_IP_CONF db "AT+CIPSTA_CUR?",13,10
CMD_GET_ESP_IP_CONF_SIZE equ 16
;Obtain DNS being used
CMD_GET_ESP_DNS_CONF db "AT+CIPDNS_CUR?",13,10
CMD_GET_ESP_DNS_CONF_SIZE equ 16
;Tag indicating next string is IP
RSP_ESP_IP_CONF_IP db "ip:",34
RSP_ESP_IP_CONF_IP_SIZE equ 4
;Tag indicating next string is Gateway
RSP_ESP_IP_CONF_GATEWAY db "gateway:",34
RSP_ESP_IP_CONF_GATEWAY_SIZE equ 9
;Tag indicating next string is netmask
RSP_ESP_IP_CONF_NETMASK db "netmask:",34
RSP_ESP_IP_CONF_NETMASK_SIZE equ 9
;Tag indicating next string is DNS server
RSP_ESP_IP_CONF_DNS db "DNS_CUR:"
RSP_ESP_IP_CONF_DNS_SIZE equ 8
;Request to resolve a name to an IP
CMD_ESP_DNS_RESOLVE db "AT+CIPDOMAIN=",34
CMD_ESP_DNS_RESOLVE_SIZE equ 14
;Request to open an UDP connection
CMD_ESP_OPEN_UDP_CONN db "AT+CIPSTART=1,",34,"UDP",34,",",34,"1.1.1.1",34,",99,54321,2",13,10
;position 33 is where we add our local port, and 38 we add ,2
CMD_ESP_OPEN_UDP_CONN_SIZE equ 42 
;Reserve CONN0 so it is not used by server
CMD_ESP_RESERVE_CONN0 db "AT+CIPSTART=0,",34,"UDP",34,",",34,"1.1.1.1",34,",99",13,10
CMD_ESP_RESERVE_CONN0_SIZE equ 34
;Request to open an UDP connection
CMD_ESP_OPEN_TCP_CONN db "AT+CIPSTART=1,",34,"TCP",34,",",34
CMD_ESP_OPEN_TCP_CONN_SIZE equ 21
;Request to close a connection
CMD_ESP_CLOSE_CONN db "AT+CIPCLOSE=1",13,10
CMD_ESP_CLOSE_CONN_SIZE equ 15
;Sending data directly to an open connection
CMD_ESP_SEND_CONN db "AT+CIPSEND=1,"
CMD_ESP_SEND_CONN_SIZE equ 13
;;Sending data to an open (TCP Only) connection buffer
;CMD_ESP_SENDBUFF_CONN db "AT+CIPSENDBUF=1,"
;;+14 is conn #
;CMD_ESP_SENDBUFF_CONN_SIZE equ 16
;Prompt for SEND data
CMD_ESP_SEND_CONN_RSP db '>'
CMD_ESP_SEND_CONN_RSP_SIZE equ 1
;CMD SND (finish a command for ESP processing)
CMD_ESP_SND db 13,10
CMD_ESP_SND_SIZE equ 2
;Allow to change close from normal to abort or vice versa
CMD_SET_ESP_CLOSEMODE db "AT+CIPCLOSEMODE=1,0",13,10
;+16 set connection and +18 set mode
CMD_SET_ESP_CLOSEMODE_SIZE equ 21
;Retrieve data from ESP Buffer
CMD_GET_ESP_DATA_FROM_TCP_BUFFER db "AT+CIPRECVDATA=1,"
; +15 changes connection
CMD_GET_ESP_DATA_FROM_TCP_BUFFER_SIZE equ 17
;;Retrieve buffer information from IP connection
;CMD_GET_ESP_TCP_BUFF_STATUS db "AT+CIPBUFSTATUS=1",13,10
;; +16 changes connection
;CMD_GET_ESP_TCP_BUFF_STATUS_SIZE equ 19
;Retrieve connections information from ESP
CMD_GET_ESP_CONN_STS db "AT+CIPSTATUS",13,10
CMD_GET_ESP_CONN_STS_SIZE equ 14
;Start listening for TCP connections on a given port
CMD_GET_ESP_START_TCP_LISTEN db "AT+CIPSERVER=1,"
CMD_GET_ESP_START_TCP_LISTEN_SIZE equ 15
;Stop listening
CMD_GET_ESP_STOP_TCP_LISTEN db "AT+CIPSERVER=0",13,10
CMD_GET_ESP_STOP_TCP_LISTEN_SIZE equ 16

;*********************************************
;***         Auxiliary variables           ***
;*********************************************
;Index of Junk Interrupt handler when parsing a possible status
JUNK_INDEX db 0
;Index of Command Sending function when parsing command response
CMD_RSP_INDEX db 0
;Store the SPEED uart is working
ESP_UART_SPEED db 0
;When receiving a connection being closed message, save the conn. #
CONN_BEING_CLOSED db 0
;Primary DNS
LOCAL_PDNS: ds 4
;Secondary DNS
LOCAL_SDNS: ds 4
;Our local IP
LOCAL_IP: ds 4
;Our local Gateway
LOCAL_GATEWAY: ds 4
;Our local Netmask
LOCAL_NETMASK: ds 4
;Local IP/GW/NM info is current? (i.e.: received a WiFi Disconnected msg)
LOCAL_CURRENT db 1
;Local PDNS/SDNS info is current? (i.e.: received a WiFi Disconnected msg)
LOCAL_D_CURRENT db 1
;RAM Buffer to store names to be resolved (and used also to translate IPs from ASCII to 32bits number)
DNS_BUFFER: ds 256
;Will store the result of the last DNS query
DNS_RESULT: ds 4
;Indicates whether DNS_RESULT is valid to be used or not
DNS_READY db 0
;Indicates how much of Buffer has been used (no need to be zero terminated)
DNS_BUFFER_DATA_SIZE db 0
;Holds the current connection state
ESP_CONNECTION_STATE db UNAPI_TCPIP_NS_UNKNOWN
;Auxiliary buffer for some functions
TEMP: ds 16

;*********************************************
;*** Connection Variables and Buffers      ***
;*********************************************

;*********************************************
;*** ESP_TRANSFER_INPROGRESS indicates int ***
;*** handler if connection receiving is in ***
;*** progress, command is being executed or***
;*** DNS query is in progress. If none, it ***
;*** will gladly "Junk Collect", meaning it***
;*** will check for unsolicited messages   ***
;*** and discard anything else.            ***
;***									   ***
;*** Bit Map:							   ***
;*** Bit 0 - Receiving TCP data   		   ***
;*** Bit 1 - Receiving from Conn.1		   ***
;*** Bit 2 - Receiving from Conn.2		   ***
;*** Bit 3 - Receiving from Conn.3		   ***
;*** Bit 4 - Receiving from Conn.4		   ***
;*** Bit 5 - *********************		   ***
;*** Bit 6 - *********************		   ***
;*** Bit 7 - Receiving Passive TCP Info    ***
;*********************************************
ESP_TRANSFER_INPROGRESS db 0
ESP_CMD_INPROGRESS db 0 ;indication for the general junk gatherer to copy received data to CMD BUFFER
ESP_DNS_INPROGRESS db 0 ;indication for the general junk gatherer that DNS resolving is in progres
; Remaining bytes until connection transfer is done
ESP_TRANSFER_REMAINING dw 0
;*********************************************
;*** ESP_TRANSFER_REMAINING_STATE indicates***
;*** a transfer (+IPD) header is being     ***
;*** processed, or, has processing is done ***
;*** it is ok to push data in connection   ***
;*** buffer.							   ***
;***									   ***
;*** 0 - Ready, push data to buffer		   ***
;*** 1 - Waiting a comma		   		   ***
;*** 2 - Receiving transfer size		   ***
;*** 3 - Receiving IP that sent the data   ***
;*** 4 - Receiving Port from sender        ***
;*********************************************
ESP_TRANSFER_REMAINING_STATE db 1
;Index of Transfer Interrupt handler when parsing a possible rcv packet
ESP_TRANSFER_REMAINING_INDEX db 0
;RAM buffer to hold the ASCII value of the transfer size
ESP_TRANSFER_REMAINING_ASCII_BUFFER db "0000$"
;RAM buffer to hold the sender's IP
ESP_TRANSFER_SENDER_IP db 0,0,0,0
;RAM buffer to hold the sender's Port
ESP_TRANSFER_SENDER_PORT dw 0
;Indicates the address of ring buffer to hold data
ESP_TRANSFER_BUFF dw CONN1_BUFF_START
;Indicates the address of ring buffer control variables
ESP_TRANSFER_BUFF_VARS dw CONN1_BUFFER_VARS
;Indicates the address of ring buffer overshoot area (chunk transfers that overlap ring)
ESP_TRANSFER_BUFF_OVERSHOOT_AREA dw CONN1_BUFFER_OVERSHOOT_AREA
;Hold the number of free connections
ESP_FREE_CONNECTIONS db 4
; Indicate the count of actual passive connections listening or open
ESP_PASSIVE_CONNECTIONS_OPEN db 0
; Defines the size of each circular buffer
EACH_CONNECTION_BUFFER_SIZE equ #600 ;1536
EACH_CONNECTION_BUFFER_SIZE_LSB equ 0;#00
EACH_CONNECTION_BUFFER_SIZE_MSB equ 6;#6
;Connection 1 buffer control
CONN1_BUFFER_VARS:
CONN1_BUFFER_FREE dw EACH_CONNECTION_BUFFER_SIZE ;+0
CONN1_TCP_INPUT_BUFFER_DATA_SIZE: ;for TCP connections hold the incoming data size
CONN1_BUFFER_TOP dw 0 ;+2
CONN1_PASSIVE_TCP_HAS_CLIENT: ;+4 when not UDP connection, indicate if there is someone connected to a passive connection
CONN1_CONN_STATE equ CONN1_PASSIVE_TCP_HAS_CLIENT + 1 ;+5 when not UDP, indicate TCP connection state
CONN1_BUFFER_BOTTOM dw 0 ;+4
CONN1_IS_UDP db 0 ;+6
CONN1_IS_PASSIVE_TCP: ;+7 when not UDP connection, indicate whether this connection is passive or not
CONN1_UDP_DATAGRAM_COUNT db 0 ;+7
CONN1_UDP_TRANSIENT db 0 ;+8
CONN1_PORT dw 0 ;+9
ESP_CONNECTION1_OPENED db 0 ;+11
CONN1_BUFF_START dw CONN1_BUFF ;+12
CONN1_REMOTE_IP: ds 4 ;+14
CONN1_LOCAL_TCP_PORT: dw 0 ;+18
;Connection 2 buffer control
CONN2_BUFFER_VARS:
CONN2_BUFFER_FREE dw EACH_CONNECTION_BUFFER_SIZE ;+0
CONN2_TCP_INPUT_BUFFER_DATA_SIZE: ;for TCP connections hold the incoming data size
CONN2_BUFFER_TOP dw 0 ;+2
CONN2_PASSIVE_TCP_HAS_CLIENT: ;+4 when not UDP connection, indicate if there is someone connected to a passive connection
CONN2_CONN_STATE equ CONN2_PASSIVE_TCP_HAS_CLIENT + 1 ;+5 when not UDP, indicate TCP connection state
CONN2_BUFFER_BOTTOM dw 0 ;+4		
CONN2_IS_UDP db 0 ;+6
CONN2_IS_PASSIVE_TCP: ;+7 when not UDP connection, indicate whether this connection is passive or not
CONN2_UDP_DATAGRAM_COUNT db 0 ;+7
CONN2_UDP_TRANSIENT db 0 ;+8
CONN2_PORT dw 0 ;+9
ESP_CONNECTION2_OPENED db 0 ;+11
CONN2_BUFF_START dw CONN2_BUFF ;+12
CONN2_REMOTE_IP: ds 4 ;+14
CONN2_LOCAL_TCP_PORT: dw 0 ;+18
;Connection 3 buffer control
CONN3_BUFFER_VARS:
CONN3_BUFFER_FREE dw EACH_CONNECTION_BUFFER_SIZE ;+0
CONN3_TCP_INPUT_BUFFER_DATA_SIZE: ;for TCP connections hold the incoming data size
CONN3_BUFFER_TOP dw 0 ;+2
CONN3_PASSIVE_TCP_HAS_CLIENT: ;+4 when not UDP connection, indicate if there is someone connected to a passive connection
CONN3_CONN_STATE equ CONN3_PASSIVE_TCP_HAS_CLIENT + 1 ;+5 when not UDP, indicate TCP connection state
CONN3_BUFFER_BOTTOM dw 0 ;+4
CONN3_IS_UDP db 0 ;+6
CONN3_IS_PASSIVE_TCP: ;+7 when not UDP connection, indicate whether this connection is passive or not
CONN3_UDP_DATAGRAM_COUNT db 0 ;+7
CONN3_UDP_TRANSIENT db 0 ;+8
CONN3_PORT dw 0 ;+9
ESP_CONNECTION3_OPENED db 0 ;+11
CONN3_BUFF_START dw CONN3_BUFF ;+12
CONN3_REMOTE_IP: ds 4 ;+14
CONN3_LOCAL_TCP_PORT: dw 0 ;+18
;Connection 4 buffer control
CONN4_BUFFER_VARS:
CONN4_BUFFER_FREE dw EACH_CONNECTION_BUFFER_SIZE ;+0
CONN4_TCP_INPUT_BUFFER_DATA_SIZE: ;for TCP connections hold the incoming data size
CONN4_BUFFER_TOP dw 0 ;+2
CONN4_PASSIVE_TCP_HAS_CLIENT: ;+4 when not UDP connection, indicate if there is someone connected to a passive connection or that ipconfig has been loaded
CONN4_CONN_STATE equ CONN4_PASSIVE_TCP_HAS_CLIENT + 1 ;+5 when not UDP, indicate TCP connection state
CONN4_BUFFER_BOTTOM dw 0 ;+4	
CONN4_IS_UDP db 0 ;+6
CONN4_IS_PASSIVE_TCP: ;+7 when not UDP connection, indicate whether this connection is passive or not
CONN4_UDP_DATAGRAM_COUNT db 0 ;+7
CONN4_UDP_TRANSIENT db 0 ;+8
CONN4_PORT dw 0 ;+9
ESP_CONNECTION4_OPENED db 0 ;+11
CONN4_BUFF_START dw CONN4_BUFF ;+12
CONN4_REMOTE_IP: ds 4 ;+14
CONN4_LOCAL_TCP_PORT: dw 0 ;+18
;Command buffer control (it is a linear buffer)
BUFFER_FREE_VARS:
CMD_RAM_BUFFER_DATA_SIZE dw 0
CMD_BUFFER_SIZE equ 512
CMD_BUFFER_POINTER dw 0
	
	;============================
	;===  UNAPI related data  ===
	;============================

;This data is setup at installation time

MY_SLOT:	db	0
MY_SEG:	db	0
	;--- Specification identifier (up to 15 chars)

UNAPI_ID:
	db	"TCP/IP",0
UNAPI_ID_END:

	;--- Implementation name (up to 63 chars and zero terminated)

APIINFO:
	db	"MSX-SM WiFi UNAPI",0

SEG_CODE_END:
;We will be in a segment of our own, running from 0x4000 to 0x7FFF
;Each buffer will occupy its own BUFFER_SIZE + 128 (OVERSHOOT)
;So the next buffer start at that BUFFERSIZE + 128 (OVERSHOOT)
;Make sure  that everything fits up to 0x7FFF
CONN1_BUFF:	
CONN1_BUFFER_OVERSHOOT_AREA equ CONN1_BUFF + EACH_CONNECTION_BUFFER_SIZE
CONN2_BUFF equ CONN1_BUFFER_OVERSHOOT_AREA + 128
CONN2_BUFFER_OVERSHOOT_AREA equ CONN2_BUFF + EACH_CONNECTION_BUFFER_SIZE
CONN3_BUFF equ CONN2_BUFFER_OVERSHOOT_AREA + 128
CONN3_BUFFER_OVERSHOOT_AREA equ CONN3_BUFF + EACH_CONNECTION_BUFFER_SIZE
CONN4_BUFF equ CONN3_BUFFER_OVERSHOOT_AREA + 128
CONN4_BUFFER_OVERSHOOT_AREA equ CONN4_BUFF + EACH_CONNECTION_BUFFER_SIZE
CMD_RAM_BUFFER equ CONN4_BUFFER_OVERSHOOT_AREA + 128
BUFFER_END_AREA equ CMD_RAM_BUFFER + CMD_BUFFER_SIZE
;Use this to check, if this is beyond #7FFF, code is too fat and won't fit
;16K segment, so need to re-design it to fit into the segment
LAST_RAM_BYTE_USED equ BUFFER_END_AREA