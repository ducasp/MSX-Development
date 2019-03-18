/*
--
-- WiFiMSXSM.h
--   Functions that allow your program to access the WiFi module
--   of your MSX-SM.
--   Revision 0.50
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2019 Oduvaldo Pavan Junior ( ducasp@ gmail.com )
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

#ifndef _WiFiMSXSM_H_

#define _WiFiMSXSM_H_

//Allow outputing some messages through Print or printf
#define log_verbose
//Allow outputing debug messages through Print or printf
//#define log_debug

#define	RET_WIFI_MSXSM_OK				0
#define	RET_WIFI_MSXSM_TX_TIMEOUT		1
#define	RET_WIFI_MSXSM_RX_TIMEOUT		2
#define RET_WIFI_MSXSM_OK_CONNECTED 	3
#define RET_WIFI_MSXSM_OK_DISCONNECTED 	4
#define	RET_WIFI_MSXSM_RX_OVERFLOW		5
#define	RET_WIFI_MSXSM_CMD_ERROR		6
#define RET_WIFI_MSXSM_MALLOCFAILURE	7
#define RET_WIFI_MSXSM_INVALIDPARAMETER 8
#define RET_WIFI_MSXSM_NOT_INITIALIZED  9
#define RET_WIFI_MSXSM_CMD_FAIL			10
#define RET_WIFI_MSXSM_DNS_FAILURE		11
#define RET_WIFI_MSXSM_ALREADY_CONN		12
#define RET_WIFI_MSXSM_WRONG_MODE		13

#define CONNECTION_TYPE_TCP				0
#define CONNECTION_TYPE_UDP				1
#define CONNECTION_TYPE_SSL				2

#define BAUD115200						0
#define BAUD57600						1
#define BAUD38400						2
#define BAUD31250						3
#define BAUD19200						4
#define BAUD9600						5
#define BAUD4800						6
#define BAUD2400						7

typedef struct AP {
   char APName[31]; //Per specs up to 30 characters
   unsigned char isEncrypted; //0 if open, 1 if encrypted // pwd needed
} AP;

typedef struct APList{
	unsigned char numOfElements;
	AP APst[1];
} APList;

/*
-- Application general use functions
-- Your program probably should only use those functions and not the ones
-- marked as internal use, but some developers might want to live on the
-- wild side anyway...
*/

/*
-- InitializeWiFi - Initialize ESP8266, reset it, configure parameters for
--                  proper use by this lib.
--
-- Input - 	speed (the desired UART speed so your program won't loose data)
--			0 - 115200
--			1 - 57600
--			2 - 38400
--			3 - 31250
--			4 - 19200
--			5 - 9600
--			6 - 4800
--			7 - 2400
--
-- ***WARNING***
--
-- ESP8266 communication to MSX-SM has no handshake, so, if MSX-SM FIFO is
-- full, ESP won't know and will keep sending data, that WILL BE LOST!
-- The way to guarantee that data is not lost and that ESP will tell the
-- server to wait until sending more data is to keep a baud rate that you
-- are sure your program can keep-up getting data from the FIFO before it
-- is full. Once it is full, it is probably too late, the time between when
-- you get a byte out of FIFO is probably more than the time a new packet
-- arrived over the Internet and ESP start transmitting it to the FIFO.
-- In my tests, using SDCC and this library, the maximum performance I could
-- get was a little more than 3000 reads per second, which means that 31250
-- baud rate is what you should be using if receiving streams of data as long
-- as you can buffer the stream until it is finished, otherwise, you will needed
-- to consider the time it takes for your program to do other tasks and adjust
-- UART speed accordingly.
--
-- Return - RET_WIFI_MSXSM_OK if successful and connected
--          RET_WIFI_MSXSM_OK_DISCONNECTED if successful but not connected to AP
--          RET_WIFI_MSXSM_CMD_FAIL if response received as FAIL
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_CMD_ERROR if response receive as ERROR
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
--          RET_WIFI_MSXSM_RX_OVERFLOW if chResponse was filled and OK or
--                                     error was not received yet (i.e there
--                                     is more data to receive and no place
--                                     to store it)
*/
unsigned char InitializeWiFi ( unsigned char speed );

/*
-- GetWiFiAPList - If ESP8266 is initialized, request the AP list up to
--                 stList capacity (numOfElements must contain the maximum
--                 elements supported). It is organized from the strongest
--                 to the weakest signal. Supports up to 10 APs in APList.
--
-- Input - stList where
--				- numOfElements should indicate how many AP structures were
--				  allocated in this memory buffer. When returning, it will
--				  contain the number of elements filled in the structure.
--				- APSt[?] will contain each AP that was found within
--				  numOfElements constraint.
--
-- Return - RET_WIFI_MSXSM_OK if successful and connected
--          RET_WIFI_MSXSM_INVALIDPARAMETER if APList is NULL, has no element
                                            or has more than 10 elements.
--          RET_WIFI_MSXSM_NOT_INITIALIZED if InitializeWiFi was not successful
--          RET_WIFI_MSXSM_CMD_FAIL if response received as FAIL
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_CMD_ERROR if response receive as ERROR
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
--          RET_WIFI_MSXSM_RX_OVERFLOW if chResponse was filled and OK or
--                                     error was not received yet (i.e there
--                                     is more data to receive and no place
--                                     to store it)
--          RET_WIFI_MSXSM_MALLOCFAILURE if couldn't allocate enough memory to
--                                       hold response from ESP8266 enough to
--                                       fill AP List
*/
unsigned char GetWiFiAPList (APList * stList);

/*
-- GetWiFiAPList - If ESP8266 is initialized, join an AP indicated by AP.
--
-- Input - stAP where
--				- APName should indicate the string of AP name
--				- isEncrypted 0 if open, 1 if password needed
--		 - Password - NULL for open networks or null terminated string with
--                    password needed to join network
--
-- Return - RET_WIFI_MSXSM_OK if successful and connected
--          RET_WIFI_MSXSM_INVALIDPARAMETER if Password is NULL and network
--                                          requires a password
--          RET_WIFI_MSXSM_NOT_INITIALIZED if InitializeWiFi was not successful
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_CMD_ERROR if response receive as ERROR
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
--          RET_WIFI_MSXSM_MALLOCFAILURE if couldn't allocate enough memory to
--                                       hold response from ESP8266 enough to
--                                       fill AP List
*/
unsigned char JoinWiFiAP (AP * stAP, unsigned char * Password);

/*
*******************************************************************************
* 					   Routines for Multiple Connections					  *
*																			  *
* Those routines allow up to 5 connections, but, on the other hand, due to the*
* method ESP8266 firmware work with it (command to start transfer, wait for   *
* prompt, only then send data) can be really slow for sequential small		  *
* transfers (i.e.: keyboard typing being sent)								  *
*																			  *
*******************************************************************************
*/

/*
-- OpenConnection - If ESP8266 is connected, open a connection.
--			- This function uses multiple connection mode, that is slower
--			- In this mode, to send data to ESP, you send a command, wait a
--            prompt then send data, that is slow for sending little pieces
--            of data like keyboard typing.
--
-- Input - Conn_type - TCP/UDP or SSL
--		 - Address - address of the connection, either IP or name to be resolved
--					 by DNS
--		 - Port - Port to open the connection
--		 - Number - Number of connection pipe, up to 5 connections allowed, '0'-'4'
--
-- Return - RET_WIFI_MSXSM_OK if successful and connected
--          RET_WIFI_MSXSM_INVALIDPARAMETER if Address is NULL, Conn_type > SSL or
--											pipe number > '5'
--          RET_WIFI_MSXSM_DNS_FAILURE if Address was not resolved
--          RET_WIFI_MSXSM_ALREADY_CONN if Pipe is already connected
--          RET_WIFI_MSXSM_NOT_INITIALIZED if InitializeWiFi was not successful
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_CMD_ERROR if response receive as ERROR
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
*/
unsigned char OpenConnection (unsigned char Conn_type, unsigned char * Address, unsigned char * Port, unsigned char Number);

/*
-- SendData - If ESP8266 is connected, try to send data over a connection.
--			- This function uses multiple connection mode, that is slower
--			- In this mode, to send data to ESP, you send a command, wait a
--            prompt then send data, that is slow for sending little pieces
--            of data like keyboard typing.
--
-- Input - Data - data to be sent
--       - DataSize - size of Data
--		 - Number - Number of connection pipe, up to 5 connections allowed, '0'-'4'
--
-- Return - RET_WIFI_MSXSM_OK if successful and connected
--          RET_WIFI_MSXSM_INVALIDPARAMETER if Address is NULL, Conn_type > SSL or
--											pipe number > '5'
--          RET_WIFI_MSXSM_DNS_FAILURE if Address was not resolved
--          RET_WIFI_MSXSM_NOT_INITIALIZED if InitializeWiFi was not successful
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_CMD_ERROR if response receive as ERROR
*/
unsigned char SendData (unsigned char * Data, unsigned int DataSize, unsigned char Number);

/*
-- ReceiveData - If ESP8266 is connected, try to receive data of a connection.
--
-- ***WARNING***
-- Careful, it is easy to kill your FIFO and lose data. ESP will wait a full
-- packet that can be up to MTU size (usually 1400 and something bytes). If
-- the other side is sending large packets, by the time you receive a signal
-- that FIFO has data, it already is receiving almost enough data to fill it.
-- When using this mode you need to check quickly and get data out of FIFO
-- ASAP.
--
-- Input - Data - data buffer to store data
--       - DataSize - size of data buffer in entry and size of data received in exit
--		 - Number - Number of connection pipe, up to 5 connections allowed, '0'-'4'
--
-- Return - RET_WIFI_MSXSM_OK if successful and connected
--          RET_WIFI_MSXSM_INVALIDPARAMETER if Address is NULL, Conn_type > SSL or
--											pipe number > '5'
--          RET_WIFI_MSXSM_DNS_FAILURE if Address was not resolved
--          RET_WIFI_MSXSM_NOT_INITIALIZED if InitializeWiFi was not successful
--          RET_WIFI_MSXSM_RX_TIMEOUT if it could not receive data
--          RET_WIFI_MSXSM_CMD_ERROR if response receive as ERROR
--			RET_WIFI_MSXSM_RX_OVERFLOW if buffer size can't hold the data
--
-- Note:
--
--      In case of RET_WIFI_MSXSM_RX_OVERFLOW, FIFO will be left exactly at the start of
--      data. So, we return the data size in FIFO in DataSize, so APP should be able to
--      re-allocate memory or do something to get data on the fly without losing it
--
*/
unsigned char ReceiveData (unsigned char * Data, unsigned int * DataSize, unsigned char Number);

/*
-- CloseConnection - Close an open a connection.
--			- This function uses multiple connection mode, that is slower
--			- In this mode, to send data to ESP, you send a command, wait a
--            prompt then send data, that is slow for sending little pieces
--            of data like keyboard typing.
--
-- Input - Number - Number of connection pipe, up to 5 connections allowed, '0'-'4'
--
-- Return - RET_WIFI_MSXSM_OK if successful and disconnected
--          RET_WIFI_MSXSM_INVALIDPARAMETER pipe number > '5'
--          RET_WIFI_MSXSM_NOT_INITIALIZED if InitializeWiFi was not successful
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_CMD_ERROR if response receive as ERROR
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
*/
unsigned char CloseConnection (unsigned char Number);

/*
*******************************************************************************
* 					     Routines for Single Connection					      *
*																			  *
* Those routines use ESP transparent mode, that allows only one connection,   *
* the advantage is that as this mode is transparent, it has no overhead and   *
* is also faster for smaller sequential transfers. On the other hand, you are *
* dealing with direct TX and RX. Good luck! :)								  *
*																			  *
*******************************************************************************
*/

/*
-- OpenSingleConnection - If ESP8266 is connected, open a connection.
--
-- Note: For single connection we use transparent mode, where data put in the
-- ESP goes directly to the other end, and data sent by the other end is received
-- directly. This reduces overhead, but, it is possible that there is a slight
-- delay when we send data so ESP determine we are done, to avoid sending one
-- byte packages.
--
-- It will be faster for some scenarios, slower for others. If slower, you can
-- just use multiple connections for your scenario.
--
-- Input - Conn_type - TCP/UDP or SSL
--		 - Address - address of the connection, either IP or name to be resolved
--					 by DNS
--		 - Port - Port to open the connection
--
-- Return - RET_WIFI_MSXSM_OK if successful and connected
--          RET_WIFI_MSXSM_INVALIDPARAMETER if Address is NULL, Conn_type > SSL or
--											pipe number > '5'
--          RET_WIFI_MSXSM_DNS_FAILURE if Address was not resolved
--          RET_WIFI_MSXSM_ALREADY_CONN if Pipe is already connected
--          RET_WIFI_MSXSM_NOT_INITIALIZED if InitializeWiFi was not successful
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_CMD_ERROR if response receive as ERROR
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
*/
unsigned char OpenSingleConnection (unsigned char Conn_type, unsigned char * Address, unsigned char * Port);

/*
-- CloseSingleConnection - Close an open single connection.
--
-- Input - None
--
-- Return - RET_WIFI_MSXSM_OK if successful and disconnected
--          RET_WIFI_MSXSM_INVALIDPARAMETER pipe number > '5'
--          RET_WIFI_MSXSM_NOT_INITIALIZED if InitializeWiFi was not successful
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_CMD_ERROR if response receive as ERROR
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
*/
unsigned char CloseSingleConnection (void);


/*
-- Internal use functions
-- Your program can use those functions, but little to no safeguards are
-- applied, so errors can crash the MSX-SM. If using transparent mode/Single
-- connection you will have to use at least UartTXInprogress, TxByte, UartRXData
-- and GetUARTData. TxData could be nice to use to in transparent mode. Other
-- functions shouldn't really be used outside WiFiMSXSM code
*/

/*
-- UartTXInprogress - Check if UART is transmitting data
--
-- Input - none
-- Return - 0 if UART is not transmitting data
--          1 if UART is transmitting data
*/
unsigned char UartTXInprogress(void );

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
unsigned char TxByte(char chTxByte);

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
unsigned char TxData(char * chData, unsigned char Size);

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
unsigned char GetUARTData (void);

/*
-- UartRXData - Check if UART FIFO has data available
--
-- Input - none
-- Return - 0 if UART FIFO is empty
--          1 if UART FIFO has data
--
*/
unsigned char UartRXData(void );

/*
-- ClearUARTData - will reset the FIFO buffer
--
-- Input - none
-- Return - none
--
-- This function will reset the FIFO buffer, clearing any data still there.
*/
void ClearUartData(void );


/*
-- WaitResponse - Wait until a given sequence of bytes is received OR until
-- timeout expires
--
-- Input - chResponse - pointer to the sequence of bytes being expected
--       - ResponseSize - size of the sequence of bytes being expected
--       - TimeOut - time in seconds to wait for the response
-- Return - RET_WIFI_MSXSM_OK if response received
--          RET_WIFI_MSXSM_RX_TIMEOUT if response was not received
--
-- TimeOut is in seconds for 60Hz machines and 1.2*TimeOut seconds for 50 Hz
-- This function will block for the whole timeout period if no response is
-- received, or, it will block until response was received (whichever occur
-- first).
--
-- This is useful if you don't care about parsing response data and just
-- expect an OK or ready (i.e.: ready after AT+RST)
*/
unsigned char WaitResponse (char *chResponse, unsigned char ResponseSize, unsigned char TimeOut);

/*
-- GetResponse - Wait until OK or ERROR is received and return the whole data
-- that was received (i.e.: AT command response) or until timeout expires
--
-- Input - chResponse - pointer to where to store the bytes received
--       - ResponseSize - pointer to the size of chResponse, when function
--                        returns contains bytes written to chResponse
--       - TimeOut - time in seconds to wait for the response
-- Return - RET_WIFI_MSXSM_OK if response received
--          RET_WIFI_MSXSM_CMD_ERROR if response received as ERROR
--          RET_WIFI_MSXSM_CMD_FAIL if response received as FAIL
--			RET_WIFI_MSXSM_DNS_FAILURE if DNS failed
--			RET_WIFI_MSXSM_ALREADY_CONN if connection already opened
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
--          RET_WIFI_MSXSM_RX_OVERFLOW if chResponse was filled and OK or
--                                     error was not received yet (i.e there
--                                     is more data to receive and no place
--                                     to store it)
--
-- TimeOut is in seconds for 60Hz machines and 1.2*TimeOut seconds for 50 Hz
-- This function will block for the whole timeout period if no response is
-- received, or, it will block until response was received (whichever occur
-- first).
-- If other devices interrupt the MSX, the timeout could occur faster than
-- requested.
*/
unsigned char GetResponse (char *chResponse, unsigned int * ResponseSize, unsigned char TimeOut);

/*
-- SendCommand - Send chCmd (NULL terminated) if Size is 0 or Size bytes, and
-- wait until the expected response is received or Timeout expires. This
-- function is good when you do not care about received data, just RESULT.
--
-- Input - chCmd - pointer to a zero terminated sequence to be transmitted
--       - chExpectedResponse - pointer to where expected response is stored
--       - ExpectedResponseSize - size of response, when function
--       - TimeOut - time in seconds to wait for the response
-- Return - RET_WIFI_MSXSM_OK if response received
--          RET_WIFI_MSXSM_CMD_ERROR if response received as ERROR
--          RET_WIFI_MSXSM_CMD_FAIL if response received as FAIL
--			RET_WIFI_MSXSM_DNS_FAILURE if DNS failed
--			RET_WIFI_MSXSM_ALREADY_CONN if connection already opened
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
--
-- TimeOut is in seconds for 60Hz machines and 1.2*TimeOut seconds for 50 Hz
-- This function will block for the whole timeout period if no response is
-- received, or, it will block until response was received (whichever occur
-- first).
*/
unsigned char SendCommand (char *chCmd, unsigned int Size, char *chExpectedResponse, unsigned char ExpectedResponseSize, unsigned char TimeOut);

/*
-- SendCommand2 - Send chCmd (NULL terminated) and wait until a response ending
-- with OK or ERROR is received or Timeout expires. Return the whole received
-- data including OK or ERROR token. This function is for when the response
-- contents matter (i.e.: getting AP List, receiving data, etc)
--
-- Input - chCmd - pointer to a zero terminated sequence to be transmitted
--       - chResponse - pointer to where to store the bytes received
--       - MaxResponseSize - pointer to the size of chResponse, when function
--                           returns contains bytes written to chResponse
--       - TimeOut - time in seconds to wait for the response
-- Return - RET_WIFI_MSXSM_OK if response received
--          RET_WIFI_MSXSM_CMD_ERROR if response received as ERROR
--          RET_WIFI_MSXSM_CMD_FAIL if response received as FAIL
--			RET_WIFI_MSXSM_DNS_FAILURE if DNS failed
--			RET_WIFI_MSXSM_ALREADY_CONN if connection already opened
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
--          RET_WIFI_MSXSM_RX_OVERFLOW if chResponse was filled and OK or
--                                     error was not received yet (i.e there
--                                     is more data to receive and no place
--                                     to store it)
--
-- TimeOut is in seconds for 60Hz machines and 1.2*TimeOut seconds for 50 Hz
-- This function will block for the whole timeout period if no response is
-- received, or, it will block until response was received (whichever occur
-- first).
*/
unsigned char SendCommand2 (char *chCmd, char *chResponse, unsigned int * MaxResponseSize, unsigned char TimeOut);

/*
-- GetTickCount - MSX BIOS will update a 16 bit unsigned integer every VDP
--                interrupt cycle (60Hz or 50Hz). Get this tick counter.
--
-- Input - none
-- Return - VDP Tick Counter
*/
unsigned int GetTickCount(void );

/*
-- FindBaudRateWiFi - Find the Baudrate Wifi is working on.
--
-- Input - none
-- Return - 0xFF if failure / ESP not found in any speed
--          0 if 115200, 1 if 57600, 2 if 38400, 3 if 31250, 4 if 19200
--          5 if 9600, 6 if 4800 and 7 if 2400
*/
unsigned char FindBaudRateWiFi (void);


/*
-- SetBaudRateWiFi - Set the Baudrate Wifi is working on.
--
-- Input - speed where:
--          0 if 115200, 1 if 57600, 2 if 38400, 3 if 31250, 4 if 19200
--          5 if 9600, 6 if 4800 and 7 if 2400
--
-- Return - RET_WIFI_MSXSM_OK
--          RET_WIFI_MSXSM_CMD_ERROR if response received as ERROR
--          RET_WIFI_MSXSM_CMD_FAIL if response received as FAIL
--          RET_WIFI_MSXSM_TX_TIMEOUT if it could not send data
--          RET_WIFI_MSXSM_RX_TIMEOUT if OK or ERROR was not received until
--                                    timeout expired
*/
unsigned char SetBaudRateWiFi (unsigned char speed);

#endif
