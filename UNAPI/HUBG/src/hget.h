/*
--
-- HGET.h
--   Header for HGET.c
--   Revision 0.4
--
--        Oduvaldo Pavan Junior 09/2020 v0.1 - 0.4
--
--   Based on HGET Unapi Utility that is a work from:
--        Konamiman 1/2011 v1.1
--        Oduvaldo Pavan Junior 07/2019 v1.3
--
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "hgetlib.h"
//These are available at www.konamiman.com
#include "asm.h"
#include "base64.h"


#ifndef HGET_H
#define HGET_H
#define _TERM0 0
#define _CONIN 1
#define _INNOE 8
#define _BUFIN 0x0A
#define _CONST 0x0B
#define _GDATE 0x2A
#define _GTIME 0x2C
#define _FFIRST 0x40
#define _OPEN 0x43
#define _CREATE 0x44
#define _CLOSE 0x45
#define _ENSURE 0x46
#define _SEEK 0x4A
#define _READ 0x48
#define _WRITE 0x49
#define _IOCTL 0x4B
#define _PARSE 0x5B
#define _TERM 0x62
#define _DEFAB 0x63
#define _DEFER 0x64
#define _EXPLAIN 0x66
#define _GENV 0x6B
#define _DOSVER 0x6F
#define _REDIR 0x70

#define _CTRLC 0x9E
#define _STOP 0x9F
#define _NOFIL 0x0D7
#define _EOF 0x0C7

#define TICKS_TO_WAIT (20*60)
#define SYSTIMER ((uint*)0xFC9E)

#define TCP_BUFFER_SIZE (1024)
#define TCPOUT_STEP_SIZE (512)

#define HTTP_DEFAULT_PORT (80)
#define HTTPS_DEFAULT_PORT (443)

#define TCPIP_CAPAB_VERIFY_CERTIFICATE 16
#define TCPFLAGS_USE_TLS 4
#define TCPFLAGS_VERIFY_CERTIFICATE 8

#define MAX_REDIRECTIONS 10

typedef void (*funcptr)(bool);
typedef void (*funcdataptr)(char *, int);
typedef void (*funcsizeptr)(long);

enum TcpipUnapiFunctions {
    UNAPI_GET_INFO = 0,
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

enum TcpipErrorCodes {
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
    ERR_INV_OPER
};

/* Strings */
#define strDefaultFilename "index.htm";

/* Global Variables */
byte continue_using_keep_alive = 0;
byte fileHandle = 0;
byte conn = 0;
char* credentials;
char* domainName;
char localFileName[128];
byte continueReceived;
byte redirectionRequested = 0;
byte authenticationRequested;
byte authenticationSent;
int remainingInputData = 0;
byte* inputDataPointer;
byte emptyLineReaded;
long contentLength,blockSize,currentBlock;
int isChunkedTransfer;
long currentChunkSize = 0;
int newLocationReceived;
long receivedLength = 0;
byte* TcpInputData;
#define TcpOutputData TcpInputData
byte remoteFilePath[256];
byte headerLine[256];
char statusLine[256];
char redirectionFullLocation[256];
int responseStatusCode;
int responseStatusCodeFirstDigit;
char* headerTitle;
char* headerContents;
Z80_registers reg;
unapi_code_block* codeBlock;
int ticksWaited;
int sysTimerHold;
byte redirectionUrlIsNewDomainName;
bool zeroContentLengthAnnounced;
typedef struct {
    byte remoteIP[4];
    uint remotePort;
    uint localPort;
    int userTimeout;
    byte flags;
	int hostName;
} t_TcpConnectionParameters;

t_TcpConnectionParameters* TcpConnectionParameters;
#ifdef USE_TLS
bool useHttps = false;
bool mustCheckCertificate = true;
bool mustCheckHostName = true;
bool safeTlsIsSupported = true;
bool TlsIsSupported = false;
byte tcpIpSpecificationVersionMain;
byte tcpIpSpecificationVersionSecondary;
#endif
bool tryKeepAlive = false;
bool keepingConnectionAlive = false;
byte redirectionRequests = 0;
static funcptr UpdateReceivedStatus;
static funcdataptr SaveReceivedData;
static funcsizeptr SendContentSize;
bool thereisacallback = false;
bool thereisasavecallback = false;
bool thereisasizecallback = false;
bool hasinitialized = false;
bool indicateblockprogress = false;

/* Some handy defines */

#define LetTcpipBreathe() UnapiCall(codeBlock, TCPIP_WAIT, &reg, REGS_NONE, REGS_NONE)
#define SkipCharsWhile(pointer, ch) {while(*pointer == ch) pointer++;}
#define SkipCharsUntil(pointer, ch) {while(*pointer != ch) pointer++;}
#define SkipLF() GetInputByte(NULL)
#define ToLowerCase(ch) {ch |= 32;}
#define ResetTcpBuffer() {remainingInputData = 0; inputDataPointer = TcpInputData;}
#define AbortIfEscIsPressed() ((*((byte*)0xFBEC) & 4) == 0)

/* Internal Function prototypes */
/* Functions Related to HTTP Handling */
void TerminateConnection();
int ProcessUrl(char* url, byte isRedirection);
void ExtractPortNumberFromDomainName();
int DoHttpWork(char *rcvbuffer, unsigned int *rcvbuffersize);
int SendHttpRequest();
int ReadResponseHeaders();
int SendLineToTcp(char* string);
int CheckHeaderErrors();
int DownloadHttpContents(char *rcvbuffer, unsigned int *rcvbuffersize);
int SendCredentialsIfNecessary();
int ReadResponseStatus();
int ProcessResponseStatus();
int ReadNextHeader();
int ProcessNextHeader();
void ExtractHeaderTitleAndContents();
int HeaderTitleIs(char* string);
int HeaderContentsIs(char* string);
int DiscardBogusHttpContent();
int DoDirectDatatransfer(char *rcvbuffer, unsigned int *rcvbuffersize);
int DoChunkedDataTransfer(char *rcvbuffer, unsigned int *rcvbuffersize);
long GetNextChunkSize();
/* Functions Related to Callbacks Handling  */
void UpdateReceivingMessage();
/* Functions Related to Network I/O  */
bool InitializeTcpipUnapi();
bool CheckTcpipCapabilities();
int EnsureThereIsTcpDataAvailable();
bool EnsureTcpConnectionIsStillOpen();
int ReadAsMuchTcpDataAsPossible();
int GetInputByte(byte *data);
bool CheckNetworkConnection();
int OpenTcpConnection();
int ResolveServerName();
void CloseTcpConnection();
int SendTcpData(byte* data, int dataSize);
/* Functions Related to File I/O  */
bool CreateLocalFile();
bool WriteContentsToFile(byte* dataPointer, int size);
void CloseFile(byte fileHandle);
void CloseLocalFile();
/* Functions Related to Strings  */
int StringStartsWith(const char* stringToCheck, const char* startingToken);
char* FindLastSlash(char* string);
int strcmpi(const char *a1, const char *a2);
int strncmpi(const char *a1, const char *a2, unsigned size);
#endif
