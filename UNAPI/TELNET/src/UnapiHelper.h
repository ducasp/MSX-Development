#ifndef _UNAPIHELPER_HEADER_INCLUDED
#define _UNAPIHELPER_HEADER_INCLUDED
#define UNAPIHELPER_VERBOSE

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

void UnapiBreath();
unsigned char InitializeTCPIPUnapi ();
unsigned char OpenSingleConnection (unsigned char * uchHost, unsigned char * uchPort, unsigned char * uchConn);
unsigned char CloseConnection (unsigned char ucConnNumber);
unsigned char RXData (unsigned char ucConnNumber, unsigned char * ucBuffer, unsigned int * uiSize);
unsigned char TxByte (unsigned char ucConnNumber, unsigned char uchByte);
unsigned char TxData (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize);
unsigned char ResolveDNS(unsigned char * uchHostString, unsigned char * ucIP);
unsigned char IsConnected (unsigned char ucConnNumber);
#endif //#ifndef _UNAPIHELPER_HEADER_INCLUDED
