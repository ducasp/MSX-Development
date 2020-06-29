/*
--
-- fossil_interface.h
--   Erik Maas Fossil Driver interface for Fusion-C.
--   Revision 1.0
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2020 - Andres Ortiz

-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--    product or activity without specific prior written permission.
-- 4. Source code of derivative works MUST be published to the public.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
*/

#include <stdio.h>
#include <string.h>
#include "../header/msx_fusion.h"

// Jump Table address
// Driver routines jump addresses
#define JumpTable_ADDR 	#0xF3FE
#define F_Init  		#3
#define F_DeInit        #6
#define F_SetBaud       #9
#define F_Protocol      #12
#define F_Channel       #15
#define F_RS_In         #18
#define F_RS_Out        #21
#define F_RS_In_Stat    #24
#define F_RS_Out_Stat   #27
#define F_DTR           #30
#define F_RTS           #33
#define F_Carrier       #36
#define F_Chars_In_Buf  #39
#define F_Size_Of_Buf   #42
#define F_Flush_Buf     #45
#define F_Fastint       #48
#define F_Hook38Stat    #51
#define F_Chput_Hook    #54
#define F_Keyb_Hook     #57
#define F_Get_Info      #60


//This routine check whether Fossil Driver is installed in RAM or not
// Returns: 1 -> Driver found in memory
//			0 -> Driver not installed
int FossilTest(void)__naked
{
		__asm
GetFossil:
			LD      A,(#0xf3fc)     ; get first mark of fossil
			LD		HL,#0			; HL=0
			CP      #82             ; is it the right one?
			JR		Z,.nxt
			RET                     ; return if not with NZ flags
.nxt:		LD      A,(#0xf3fd)     ; get second mark of fossil
			CP      #83             ; is it the right one?
			JR		NZ,.nok
			LD		HL,#1
.nok:		RET                     ; return if not with NZ flags
			__endasm;
}

// This routine returns the version of the currently installed Driver
// Version is packed BCD 
int Fossil_GetVersion(void)__naked
{
		__asm
		LD		HL,(#JumpTable_ADDR)    ; HL = 0xF3FE

		LD		IY,#.cc0
		LD		1(IY),L
		LD		2(IY),H

.cc0:	CALL	#0x00
		RET
		__endasm;
}

// Initializes RS232 - Ready to transmit and receive bytes
// FIFO RX/TX buffers are enabled by default
int Fossil_Init(void)__naked
{
		__asm
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Init   			; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc1
		LD		1(IY),L
		LD		2(IY),H

.cc1:	CALL	#0x00
		RET
		__endasm;
}

// RS232 DEinit
int Fossil_DeInit(void)__naked
{
		__asm
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_DeInit   			; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc2
		LD		1(IY),L
		LD		2(IY),H

.cc2:	CALL	#0x00
		RET
		__endasm;

}

// This routing set the baudrate according to parameter x:
// 0  = 75	 	 1  = 300	  2  = 600
// 3  = 1200	 4  = 2400	  5  = 4800
// 6  = 9600	 7  = 19200	  8  = 38400
// 9  = 57600	 11 = 115200
void Fossil_SetBaud(char x)__naked
{
	__asm
		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function
		LD		B,(IY)		; Save the value

		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_SetBaud  			; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc3
		LD		1(IY),L
		LD		2(IY),H

		LD		H,B
.cc3:	CALL	#0x00
	__endasm;
}

// This routine set the protocol parameters by setting/clearing bits in x
// 0-1 data bits
// 		00 5 bits or less
// 		01 6 bits
//		10 7 bits
//		11 8 bits
// 2-3 stop bits
//		01 1 stopbit
//		10 1.5 stopbits
//		11 2 stopbits
//4-5 parity
//		00 none
//		01 even
//		11 odd
// 6-7 0
void Fossil_SetProtocol(char x)__naked
{
	__asm
		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function
		LD		B,(IY)		; Save the value

		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Protocol 			; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc4
		LD		1(IY),L
		LD		2(IY),H

		LD		H,B
.cc4:	CALL	#0x00
	__endasm;
}

// Set the RS232 channel (only for NMS native interfaces)
int Fossil_SetChannel(char x)__naked
{
	__asm
		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function
		LD		B,(IY)		; Save the value

		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Channel  			; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc5
		LD		1(IY),L
		LD		2(IY),H

		LD		H,B
.cc5:	CALL	#0x00
		RET
	__endasm;
}

// This routine return a received byte from the FIFO buffer
char Fossil_RsIn(void)__naked
{
 __asm
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_RS_In  			; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc6
		LD		1(IY),L
		LD		2(IY),H

.cc6:	CALL	#0x00
		LD		L,A
		RET
	__endasm;
}

// This routine sends a byte (x)
void Fossil_RsOut(char x)__naked
{
	__asm
		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function
;		LD		B,(IY)		; Save the value

		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_RS_Out  			; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc7
		LD		1(IY),L
		LD		2(IY),H

;tl:	IN 		A,(#0x85)
;		AND     #32
;		JP      Z,tl
;		LD		A,B

.cc7:	CALL	#0x00
	__endasm;
}

// This rotuine returns 0 if no data in the RX buffer, otherwise a value!=0 is returned
// This routine has to be mandatory executed before RsIn
unsigned char Fossil_RsIn_Stat(void)__naked
{
	__asm
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_RS_In_Stat		; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc8
		LD		1(IY),L
		LD		2(IY),H

.cc8:	CALL	#0x00
		LD		L,A
		RET
	__endasm;
}

// Not implemented in the last version of Fossil Driver
char Fossil_RsOut_Stat(void)__naked
{
	__asm
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_RS_Out_Stat		; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc9
		LD		1(IY),L
		LD		2(IY),H

.cc9:	CALL	#0x00
		RET
	__endasm;
}

// x=0 drop DTR, x=255 raise DTR
void Fossil_DTR(char x)__naked
{
	__asm
		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function
		LD		B,(IY)		; Save the value
		
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_DTR				; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc10
		LD		1(IY),L
		LD		2(IY),H
		LD		H,B
.cc10:	CALL	#0x00
		RET
	__endasm;
}

// x=0 drop DTR, x=255 raise DTR
void Fossil_RTS(char x)__naked
{
	__asm
		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function
		LD		B,(IY)		; Save the value

		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_RTS				; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc11
		LD		1(IY),L
		LD		2(IY),H
		
		LD		H,B		; Recover value to pass to function 
.cc11:  CALL	#0x00
		RET
	__endasm;
}

// DCD: Returns 0 if no carrier, returns 1 if carrier detect
int Fossil_carrier(void)__naked
{
	__asm
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Carrier			; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc12
		LD		1(IY),L
		LD		2(IY),H

.cc12:  CALL	#0x00
		RET
	__endasm;
}


// This routine returns the number of bytes waiting in the RX buffer to be read
int Fossil_chars_in_buf(void)__naked
{
	__asm
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Chars_In_Buf		; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc13
		LD		1(IY),L
		LD		2(IY),H

.cc13:  CALL	#0x00
		RET
	__endasm;
}


// This routine returns the size of the RX buffer
int Fossil_size_of_buf(void)__naked
{
	__asm
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Size_Of_Buf		; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc14
		LD		1(IY),L
		LD		2(IY),H

.cc14:  CALL	#0x00
		RET
	__endasm;
}

// This routine flush the buffers
void Fossil_FlushBuf(void)__naked
{
	__asm
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Flush_Buf			; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc15
		LD		1(IY),L
		LD		2(IY),H

.cc15:  CALL	#0x00
		
	__endasm;
}

// This routine enables the use of 0x0038 hook for RX speedup
// Installing the driver at the 0x38 hook requires having enough memory at &H0000-&H3FFF
// x=0 -> Enable 0x038 hook
// x=1 -> Release 0x38 hook
void Fossil_FastInt(char x)__naked
{
	__asm

		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function
		LD		B,(IY)		; Save the value

		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Fastint			; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc16
		LD		1(IY),L
		LD		2(IY),H

		LD		H,B
.cc16:  CALL	#0x00
		
	__endasm;
}


// This routine set status for 0x38 hook
//set status for 0038 hook
// x  = 0, every interrupt is supported
// x != 0, only RS232 interrupt (and VDP) 
void Fossil_hookstat(char x)__naked
// Status for 0038 hook
{
		__asm

		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function
		LD		B,(IY)		; Save the value

		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Hook38Stat		; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc17
		LD		1(IY),L
		LD		2(IY),H

		LD		H,B
.cc17:  CALL	#0x00
		
	__endasm;
}

//This routine  redirect CHPUT data to RS232
// x=0 no redirection
// x=1 redirect with echo
// x=3 redirect without echo (faster)
void Fossil_chput_hook(char x)__naked
{
			__asm

		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function
		LD		B,(IY)		; Save the value

		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Chput_Hook		; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc18
		LD		1(IY),L
		LD		2(IY),H

		LD		H,B
.cc18:  CALL	#0x00
		
	__endasm;
}


// This routine ; redirect RS232 to keyboard buffer
// x=0 release hook, x!=0 bend hook
void Fossil_keyb_hook(char x)__naked
{
		__asm

		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function
		LD		B,(IY)		; Save the value

		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Keyb_Hook	 		; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc19
		LD		1(IY),L
		LD		2(IY),H

		LD		H,B
.cc19:  CALL	#0x00
		
	__endasm;
}



// This routine returns a pointer to a driver info block that describes
// current situation about the driver.
int Fossil_GetInfo(void)__naked
{
	__asm
		
		LD		HL,(#JumpTable_ADDR)    ; IY = 0xF3FE
		LD		DE,#F_Get_Info	 		; DE = OFFSET
		ADD     HL,DE   				; IY = 0xF3FE + OFFSET

		LD		IY,#.cc20
		LD		1(IY),L
		LD		2(IY),H

		
.cc20:  CALL	#0x00
		RET
	__endasm;
}

// Test function that return the jump address of a routine
int Fossil_getadr(char x)__naked
{
	__asm
		LD      IY,#2
		ADD     IY,SP     	; Bypass the return address of the function

		LD		A,(IY)
		LD		B,A
		ADD     A,A
		ADD     A,B
		
		LD		E,A
		XOR		A
		LD		D,A
		LD 		IY,(#JumpTable_ADDR)
		ADD     IY,DE
		PUSH 	IY
		POP		HL
		RET
	__endasm;
}


// A simple delay function
void Fossil_Delay(void)
{
	__asm
		LD		B,#10000
.dl:	NOP
		DJNZ	.dl
	__endasm;
}


// This function checks the THR empty flag in the LSR register (base + 0x05)
// ONLY for the 16550 UART
char Fossil_TXReady(void)
{
	__asm
	IN 		A,(#0x85)
	AND 	#32
	LD		L,A
	RET
	__endasm;
}

// BCD to decimal conversion for BCD packed numbers
int bcd_to_decimal(unsigned char x) 
{
    return x - 6 * (x >> 4);
}    


// Show info contained in the info block returned by Fossil_getInfo
void show_info(void)
{
	long	rec,info_base;
	info_base=Fossil_GetInfo();
	// Version number
	rec=Peek(info_base+1);
	printf("Driver Version: %d.",bcd_to_decimal(rec));
	rec=Peek(info_base);
	printf("%d\r\n",bcd_to_decimal(rec));
	// Current Receive Speed
	printf("RX Speed: %d\r\n",Peek(info_base+2));
	// Current Send Speed
    printf("TX Speed: %d\r\n",Peek(info_base+3));
    // Current Protocol
    printf("Protocol: %d\r\n",Peek(info_base+4));
    // ChPut_hook redirection status
    printf("ChPut_hook: %d\r\n",Peek(info_base+5));
    // keyboard_hook redirection status
    printf("Keyboard_hook: %d\r\n",Peek(info_base+6));
    // Cuurent RTS status
    printf("RTS Status: %d\r\n",Peek(info_base+7));
    // Current DTR Status
    printf("DTR Status: %d\r\n",Peek(info_base+8));
    // Current Channel
    printf("Current Channel: %d\r\n",Peek(info_base+9));
    // Hardware info
    printf("Hardware info: %d\r\n",Peek(info_base+10));
}

 
