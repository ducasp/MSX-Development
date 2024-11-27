;----------------------------------------------------------
;		print.s - by Danilo Angelo, 2023
;
;		Simple _print and _printchar implementation
;----------------------------------------------------------

MSXDOSPRINT = 0

.include "MSX/BIOS/msxbios.s"
.include "applicationsettings.s"
.include "targetconfig.s"

	.area	_CODE

; ----------------------------------------------------------------
; - Print message
; ----------------------------------------------------------------
; INPUTS:
;	- [__SDCCCALL(0)] SP+2: pMessage
;	- [__SDCCCALL(1)] HL:	pMessage
; OUTPUTS:
;   - None.
; CHANGES:
;   - All registers
; ----------------------------------------------------------------
_print::
.ifeq __SDCCCALL
	ld      hl, #2; retrieve address from stack
	add     hl, sp
	ld		b, (hl)
	inc		hl
	ld		h, (hl)
	ld		l, b
.endif
__print::
    ld		a,(hl)
    or		a
    ret z
	push	hl
	call	printchar
	pop		hl
    inc		hl
    jr		__print

; ----------------------------------------------------------------
; - Print char
; ----------------------------------------------------------------
; INPUTS:
;	- A: character
; OUTPUTS:
;   - None.
; CHANGES:
;   - All registers
; ----------------------------------------------------------------
printchar::
	push	iy
	push	ix
.ifne MSXDOSPRINT
	ld		e, a
	ld		c, #BDOS_CONOUT
	call	BDOS_SYSCAL
.else
	ld		iy, (#BIOS_ROMSLT)
	ld		ix, #BIOS_CHPUT
	call	BIOS_CALSLT
.endif
	pop		ix
	pop		iy
	ret

	.area	_ROMDATA
; ----------------------------------------------------------
;	Debug Prefix
.if DEBUG
_msgdbg::
.asciz		"[DEBUG] "
.endif
_linefeed::
.asciz		"\r\n"

