/*
--
-- UnapiHelper.h
--   UNAPI Abstraction functions for SSH.
--   Revision 1.00
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2026 Oduvaldo Pavan Junior ( ducasp@gmail.com )
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

#ifndef _UNAPIHELPER_HEADER_INCLUDED
#define _UNAPIHELPER_HEADER_INCLUDED
//Comment the define bellow if you do not want messages printed by this code
#define UNAPIHELPER_VERBOSE

enum SSHUnapiFunctions {
    UNAPI_GET_INFO = 0,
    SSH_GET_CAPAB = 1,
    SSH_OPEN = 2,
    SSH_CLOSE = 3,
    SSH_STATE = 4,
    SSH_SEND = 5,
    SSH_RCV = 6,
    SSH_TERM_TYPE = 7,
    SSH_WIN_SIZE = 8,
    SSH_AUTH_GET_CHALLENGE = 9,
    SSH_AUTH_RESPOND = 10,
    SSH_ADD_KNOWN_HOST = 11,
    SSH_KEY_INFO = 15
};

enum TcpipUnapiFunctions {
    TCPIP_GET_CAPAB = 1,
    TCPIP_NET_STATE = 3,
    TCPIP_DNS_Q = 6,
    TCPIP_DNS_S = 7,
    TCPIP_TCP_OPEN = 13,
    TCPIP_TCP_CLOSE = 14,
    TCPIP_TCP_ABORT = 15,
    TCPIP_TCP_STATE = 16,
    TCPIP_TCP_SEND = 17,
    TCPIP_TCP_RCV = 18,
    TCPIP_WAIT = 29
};

enum CommonErrorCodes {
    ERR_OK = 0,
    ERR_NOT_IMP,
    ERR_NO_NETWORK,
    ERR_NO_DATA,
    ERR_INV_PARAM,
    ERR_QUERY_EXISTS,
    ERR_INV_IP,
    ERR_NO_DNS,
    ERR_DNS,
    ERR_NO_FREE_CONN,
    ERR_CONN_EXISTS,
    ERR_NO_CONN,
    ERR_CONN_STATE,
    ERR_BUFFER,
    ERR_LARGE_DGRAM,
    ERR_INV_OPER,
    SSH_ERR_NO_RSS = 127,
    SSH_ERR_INV_KEY,
    SSH_ERR_PWD,
    SSH_ERR_PTY_REQ,
    SSH_ERR_AUTH_TRY_OTHER,
    SSH_ERR_UNKNOWN_HOST
};

__at 0x9000 unsigned char ucUnsafeDataTXBuffer[];

void Breath();

// InitializeSSH
//
// Check if there are any SSH Unapi Implementations available, and if there
// are, use the first available
//
// Return 0 if no SSH Unapi or TCP/IP implementation found
// Return 1 if SSH AND TCP/IP Unapi implementation has been found
unsigned char InitializeUNAPIS (unsigned char * ucInteractiveAuth, unsigned char * ucFilter, unsigned char * ucHostKeyVerification, unsigned char * ucPubKeyAuth);

// OpenSingleConnection
//
// Will try do DNS resolve ucHost, if found, will try to open a SSH PTY
// connection with the resolved IP using port uchPort (host and Port are ASCII)
//
// If connection is successful will return connection number in uchConn and
// return ERR_OK
unsigned char OpenSingleConnection (unsigned char * username, unsigned char * password, unsigned char * uchHost, unsigned char * uchPort, unsigned char * uchConn, unsigned char ucAnonymous, unsigned char ucInteractive, unsigned char ucFilter, unsigned char ucHostKeyVerification, unsigned char ucPubKey);

// CloseConnection
//
// Will request connection ucConnNumber to be closed
//
// Will return ERR_OK if success
unsigned char CloseConnection (unsigned char ucConnNumber);

// IsConnected
//
// Return 1 if ucConnNumber connection state is connected
// Return 0 otherwise
unsigned char IsConnected (unsigned char ucConnNumber, unsigned int *uiSize);

// RXData
//
// Will try to retrieve up to uiSize bytes from ucConnNumber and place in ucBuffer
//
// Return 0 and uiSize = 0 if no data
// Return 1 and uiSize = bytes read if data was available
unsigned char RXData (unsigned char ucConnNumber, unsigned char * ucBuffer, unsigned int * uiSize);

// TXByte
//
// Will try to send uchByte in ucConnNumber
//
// Return ERR_OK if success
unsigned char TxByte (unsigned char ucConnNumber, unsigned char uchByte);

// TXData
//
// Will try to send uiDataSize bytes from lpucData in ucConnNumber
//
// Return ERR_OK if success
unsigned char TxData (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize);

// TXUnsafeData
//
// Will try to send uiDataSize bytes from lpucData in ucConnNumber
// But will move data to high memory before doing so
// Up to 128 bytes can be sent here
//
// Return ERR_OK if success
unsigned char TxUnsafeData (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize);

// ResolveDNS
//
// Used by OpenSingleConnection
//
// If success return ERR_OK and resolved IP in ucIP[0]...[3]
unsigned char ResolveDNS(unsigned char * uchHostString, unsigned char * ucIP);

// SetTermType
//
// Return 1 ok
// Return 0 otherwise
unsigned char SetTermType (unsigned char ucTermType);

// SetTermWindow
//
// Return 1 ok
// Return 0 otherwise
unsigned char SetTermWindow (unsigned char Rows, unsigned char Columns);

unsigned char GetChallenge (unsigned char ucConnNumber, unsigned char * ucBuffer, unsigned int * uiSize, unsigned char * ucPrompts, unsigned char * ucEco);

unsigned char ConnState (unsigned char ucConnNumber, unsigned char *ucState);

unsigned char Respond (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize);

#endif //#ifndef _UNAPIHELPER_HEADER_INCLUDED
