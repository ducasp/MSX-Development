/*

 HGETLIB.h
   Header for HGET.c application interface
   Revision 0.4

        Oduvaldo Pavan Junior 09/2020 v0.1 - 0.4

   Based on HGET Unapi Utility that is a work from:
        Konamiman 1/2011 v1.1
        Oduvaldo Pavan Junior 07/2019 v1.3

   HGET Library history:
   Version 0.4 - some Internet Service Providers have a heavy hand on open
     connections, so a keep-alive connection might be terminated by the ISP
     (not the server) if it is idle for a while after the last GET request was
     serviced. ISP's shouldn't be doing that, but hey, this is life, and we
     need to live with it, so if a new request comes and it fails and the
     connection was being kept alive, will just ignore keep alive and treat as
     a regular connection

   Version 0.3 - re-organized code and changed the way code was calling
   Terminate a lot

   Version 0.2 - making code cleaner and trying to keep Konamiman style, also
   adding basic support to keep-alive connections, also, agent is defined in
   hgetlib.h so each application can define it own by changing it.

   Version 0.1 - it is a simplification of HGET so it can be used as a library
   inside a project. It doesn't intend to have the exact same features, but has
   different objectives:

   - Allow to be called multiple times without searching UNAPI for every access
   - It can be compiled with SSL/TLS support if you define USE_TLS
   - It allows several means of handling the received data:
    * If no buffer, no data write callback and no filename is provided, try to
      use the same name from the access URL
    * If no buffer, no data write callback is provided, will use the filename /
      path to store the file
    * If data write callback is provided, will call it every time there is data
      received.
   - It allows registering an progress update callback:
    * If registered it is called every 4% of data is received, if size is known,
      parameter is false
    * If registered and size is unknown, it is called every time data is received,
      parameter is true
   - It allows registering a content size update callback that will receive the
     content length if available, or 0 if not available.

   History from HGET:
   Version 1.3 should be TCP-IP v1.1 compliant, that means, TLS support, so you
   can download files from https sites if your device is compliant.
   It also removes an extra tick wait after calling TCPIP_WAIT, as there seems
   to have no reason for it and it can lower the performance. Any needed WAIT
   should be already done by adapter UNAPI when calling TCPIP_WAIT.
   Also I've changed the download progress to a bar, it changes every 4%
   increment of file size of known file size or there is a moving character if
   file size is unknown. This is way easier on VDP / CALLs and allow better
   performance on fast adapters that can use the extra CPU time.
*/
#ifndef HGETLIB_H
#define HGETLIB_H

#define HGET_AGENT "User-Agent: MSXHUBG (MSX-DOS)\r\n"

#ifndef bool
typedef unsigned char bool;
#endif
#ifndef false
#define false (0)
#endif
#ifndef true
#define true (!false)
#endif

enum HgetReturnCodes {
    ERR_TCPIPUNAPI_OK = 0,
    ERR_TCPIPUNAPI_NOTFOUND, //1
    ERR_TCPIPUNAPI_NOT_TCPIP_CAPABLE, //2
    ERR_TCPIPUNAPI_REDIRECT_TO_HTTPS_WHICH_IS_UNSUPPORTED, //3
    ERR_TCPIPUNAPI_HTTPS_UNSUPPORTED, //4
    ERR_TCPIPUNAPI_NON_ABSOLUTE_URL_ON_REDIRECT_REQUEST, //5
    ERR_TCPIPUNAPI_NO_CONNECTION, //6
    ERR_TCPIPUNAPI_CONNECTION_FAILED, //7
    ERR_TCPIPUNAPI_CONNECTION_TIMEOUT, //8
    ERR_TCPIPUNAPI_NO_DNS_CONFIGURED, //9
    ERR_TCPIPUNAPI_NOT_DNS_CAPABLE, //10
    ERR_TCPIPUNAPI_DNS_FAILURE, //11
    ERR_TCPIPUNAPI_DNS_UNKNWON_HOSTNAME, //12
    ERR_TCPIPUNAPI_DNS_REFUSED, //13
    ERR_TCPIPUNAPI_DNS_NO_RESPONSE, //14
    ERR_TCPIPUNAPI_DNS_QUERY_FAILED, //15
    ERR_TCPIPUNAPI_DNS_UNKNWON_ERROR, //16
    ERR_TCPIPUNAPI_UNKNOWN_ERROR, //17
    ERR_TCPIPUNAPI_RECEIVE_ERROR, //18
    ERR_TCPIPUNAPI_SEND_ERROR, //19
    ERR_HGET_NOT_INITIALIZED, //20
    ERR_HGET_ALREADY_INITIALIZED, //21
    ERR_HGET_ESC_CANCELLED, //22
    ERR_HGET_DISK_WRITE_ERROR, //23
    ERR_HGET_CANT_CREATE_FILE, //24
    ERR_HGET_INVALID_PARAMETERS, //25
    ERR_HGET_AUTH_FAILED, //26
    ERR_HGET_TOO_MANY_REDIRECTS, //27
    ERR_HGET_HTTP_ERROR, //28
    ERR_HGET_UNK_AUTH_METHOD_REQUEST, //29
    ERR_HGET_REDIRECT_BUT_NO_NEW_LOCATION_PROVIDED, //30
    ERR_HGET_AUTH_REQUESTED_BUT_NO_CREDENTIALS_PROVIDED, //31
    ERR_HGET_TRANSFER_TIMEOUT, //32
    ERR_HGET_CONN_LOST, //33
    ERR_HGET_INVALID_BUFFER //34
};

// Functions Related to Strings
char* ltoa(unsigned long num, char *string);
// Functions Related to HTTP
int hgetinit (unsigned int addressforbuffer);
void hgetfinish (void);
#ifdef USE_TLS
int hget (char* url, char* filename, char* credent, int progress_callback, bool checkcertificateifssl, bool checkhostnameifssl, char *rcvbuffer, unsigned int *rcvbuffersize, int data_write_callback, int content_size_callback, bool enableKeepAlive);
#else
int hget (char* url, char* filename, char* credent, int progress_callback, char *rcvbuffer, unsigned int *rcvbuffersize, int data_write_callback, int content_size_callback, bool enableKeepAlive);
#endif

#endif
