.include "MSX/BIOS/msxbios.s"
.include "applicationsettings.s"
.include "targetconfig.s"

	.area	_CODE

;------------------------------------------------
;	Inkey
;   Test Key hit without waiting. Return Key Number or 0 if no key was hitten
; 	
;	Eric Boez 2019
;   Oduvaldo Pavan 2024 version for rom / lightweight
;
;-----------------------------------------------
;--- proc   Inkey
;
;   unsigned char   Inkey (void);
;
_Inkey::
   call 0x009c       ; CHSNS Tests the status of the keyboard buffer
.ifeq __SDCCCALL
   ld l,#0
.else
   ld a,#0
.endif
   ret z
   call 0x009f       ; chget bios function. Buffer is not empty thus no wait. 
.ifeq __SDCCCALL
   ld   l,a			 ; Return to register L
.endif
   ret

   	.area	_ROMDATA
