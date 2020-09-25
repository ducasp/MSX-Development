/*
--
-- 16C550CZiModem.h
--   Quick Access to 16C550 on 0x80 - 0x86.
--   Revision 0.10
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2020 Oduvaldo Pavan Junior ( ducasp@ gmail.com )
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

#ifndef _16C550CZiModem_H_

#define _16C550CZiModem_H_

//I/O made simple...
__sfr __at 0x80 myRBR_THR;
__sfr __at 0x81 myIER;
__sfr __at 0x82 myIIR_FCR;
__sfr __at 0x83 myLCR;
__sfr __at 0x84 myMCR;
__sfr __at 0x85 myLSR;
__sfr __at 0x86 myMSR;
__sfr __at 0x87 mySR;

//This variable will hold JIFFY value, that is increased every VDP interrupt,
//that means usually it will be increased 60 (NTSC/PAL-M) or 50 (PAL) times
//every second
__at 0xFC9E unsigned int TickCount;


enum U16C550Types {
    U16C550C = 0,
    U16C550 = 1,
    NOUART = 3
};

//Allow outputing some messages through Print or printf
//#define log_verbose
//Allow outputing debug messages through Print or printf
//#define log_debug

/*
-- enterIntMode - Will configure the UART to work in INTERRUPT mode. It
--                should be called ONLY AFTER SUCCESFUL initialization.
--
--                If interrupt is configured and we can't clear the FIFO
--                data, Z80 will be in an ALWAYS interrupted mode, not
--                executing anything. If ESP8266/UART hardware is non
--                existing, we will most likely read 0xFF in status (open
--                I/O) thinking there is interrupt and that there is
--                data in FIFO.
--
-- ***WARNING***
--
--                Before exiting the program, it is MANDATORY to call
--                exitIntMode, otherwise interrupt handler will indicate
--                an area without program, again, it will not execute
--                anything after exiting the program.
--
*/
void enterIntMode(void);

/*
-- exitIntMode - Will configure the UART to not work in INTERRUPT mode. It
--               should be called ONLY AFTER SUCCESFUL initialization and
--               if interrupt mode was turned on, otherwise it will corrupt
--               the interrupt handler.
--
-- ***WARNING***
--
--               A corrupt interrupt handler will indicate an area without
--               proper interrupt handling and MSX will not execute anything
--               after such corruption.
--
*/
void exitIntMode(void);



/*
-- UartFIFOFull - Check if UART Fifo is full
--
-- Input - none
-- Return - 0 if FIFO not full
--          any other value means full
--
*/
unsigned char UartFIFOFull(void);

/*
-- UartTXInprogress - Check if UART is transmitting data
--
-- Input - none
-- Return - 0 if UART is not transmitting data
--          1 if UART is transmitting data
*/
unsigned char UartTXInprogress(void);

/*
-- TxByte - Transmit a byte over serial to the ESP8266
--
-- Input - chTxByte - Byte to be transmitted
-- Return - RET_WIFI_MSXSM_OK if successful
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--
-- This function will output the byte and leave if UART is not sending data
-- If UART is sending data, it will block waiting UART to transmit byte for
-- up to 3 VDP interrupts (this generally means up to 50ms in 60Hz or up to
-- 60ms in 50Hz). A TX transfer at 2400bps (slowest ESP speed) won't take
-- more than 5ms, so it should be safe.
--
-- If using this function, your application should use UartTXInprogress to
-- check if a transmission is in progress, if it is, do another stuff and
-- come back later. This way your application won't be blocked or have to
-- wait until next interrupt.
--
*/
unsigned char U16550CTxByte(char chTxByte);

/*
-- TxData - Transmit sequential data that is zero terminated if Size is 0
--          Transmit Size bytes of data if Size is other than 0
--
-- This function uses TxByte, and as such, timeout for each byte is 50-60ms.
-- Total time-out will depend exclusively on how much time it takes for each
-- byte to be transmitted, if used on a MSX without the same interface MSX-SM
-- has for WiFi, it will most likely take 50-60ms and exit.
--
-- Input - chData - pointer to a zero terminated sequence to be transmitted
-- Return - RET_WIFI_MSXSM_OK if successful
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--
-- This function will not return until the last byte has been sent.
*/
unsigned char U16550CTxData(char * chData, unsigned char Size);

/*
-- GetUARTData - Receive a byte from ESP8266
--
-- Input - none
-- Return - one byte from the FIFO
--
-- This function should only be used after checking that there is data in
-- the FIFO with UartRXData. Otherwise, you will get junk if the FIFO is
-- empty.
*/
unsigned char GetUARTData(void);

/*
-- UartRXData - Check if UART FIFO has data available
--
-- Input - none
-- Return - 0 if UART FIFO is empty
--          1 if UART FIFO has data
--
*/
unsigned char UartRXData(void);


/*
-- programInt - Will change the interrupt handler to call our internal
--              interrupt handling routine (myIntHandler), and our
--              routine will call the original interrupt handler once done or
--              if the interrupt was not from our UART.
--
*/
void programInt(void);

/*
-- restoreInt - Will change the interrupt handler to the original interrupt
--              handling routine saved by programInt.
--
*/
void restoreInt(void);

/*
-- myIntHandler - Internal function that upon interruption will check if it was
--                from our FIFO, and if it was, will dump all FIFO data to our
--                internal RAM FIFO, if our internal RAM FIFO is FULL, will just
--                discard data.
--
*/

void myIntHandler(void) __naked;
void myAFEIntHandler(void) __naked;

unsigned int GetReceivedBytes(void);

unsigned char check16C550C(void);

void GetBulkData(unsigned char * ucBuffer,unsigned int * uiSize);

void StopReceivingData(void);

void ResumeReceivingData(void);

#endif
