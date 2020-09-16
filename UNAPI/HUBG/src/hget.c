/* HTTP getter Library 0.4
        Oduvaldo Pavan Junior 09/2020 v0.1 - 0.4

   Based on HGET Unapi Utility that is a work from:
        Konamiman 1/2011 v1.1
        Oduvaldo Pavan Junior 07/2019 v1.3

   HGET Library history:
   Version 0.4 -
   - Some Internet Service Providers have a heavy hand on open connections, so
     a keep-alive connection might be terminated by the ISP (not the server) if
     it is idle for a while after the last GET request was serviced. ISP's
     shouldn't be doing that, but hey, this is life, and we need to live with
     it, so if a new request comes and it fails and the connection was being
     kept alive, will just ignore keep alive and treat as a regular connection
   Version 0.3 -
   - re-organized code and changed the way code was calling Terminate a lot
   - changed a few loops for tick and sequence for TcpIpBreath, this boosts a
     little performance for OBSONET
   - as this lib do not support resuming failed transfers, added pre-allocation
     of the entire file prior to writing when file size is known. This gives
     quite a boost on performance with a few disk adapters

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
#include "hget.h"


int hgetinit (unsigned int addressforbuffer)
{
    if (!hasinitialized)
    {
        continue_using_keep_alive = 1;
        conn = 0;
        fileHandle = 0;
        hasinitialized = false;
        thereisacallback = false;
        thereisasavecallback = false;
        unsigned int bufferSize = sizeof(t_TcpConnectionParameters) + sizeof(unapi_code_block) + 0x200 + TCP_BUFFER_SIZE;
#ifdef USE_TLS
        TlsIsSupported = false;
        useHttps = false;
#endif
        tryKeepAlive = false;

        //InitializeBufferPointers - We need room for our data from the beginning of addressforbuffer
        //And that data MUST NOT be in page 1, that means, 0x4000 to 0x7FFF, as this is where UNAPI
        //device code resides and calls to UNAPI will switch that page
        if ((addressforbuffer>=0x8000)||((addressforbuffer+bufferSize)<0x4000)) {
            TcpConnectionParameters = (t_TcpConnectionParameters*)addressforbuffer;
            domainName = (char*)((unsigned int)TcpConnectionParameters + sizeof(t_TcpConnectionParameters));
            codeBlock = (unapi_code_block*)((unsigned int)domainName + 0x200);
            TcpInputData = (byte*)((unsigned int)codeBlock + sizeof(unapi_code_block));

            if (!InitializeTcpipUnapi())
                return ERR_TCPIPUNAPI_NOTFOUND;
            if (!CheckTcpipCapabilities())
                return ERR_TCPIPUNAPI_NOT_TCPIP_CAPABLE;

            hasinitialized = true;
            return ERR_TCPIPUNAPI_OK;
        } else
            return ERR_HGET_INVALID_BUFFER;
    }
    else
        return ERR_HGET_ALREADY_INITIALIZED;
}


void hgetfinish (void)
{
    if (hasinitialized) {
        thereisacallback = false;
        keepingConnectionAlive = false;
        tryKeepAlive = false;
        CloseTcpConnection();
        CloseLocalFile();
    }
}


#ifdef USE_TLS
int hget (char* url, char* filename, char* credent, int progress_callback, bool checkcertificateifssl, bool checkhostnameifssl, char *rcvbuffer, unsigned int *rcvbuffersize, int data_write_callback, int content_size_callback, bool enableKeepAlive)
#else
int hget (char* url, char* filename, char* credent, int progress_callback, char *rcvbuffer, unsigned int *rcvbuffersize, int data_write_callback, int content_size_callback, bool enableKeepAlive)
#endif
{
    int funcret;
    char* pointer;
#ifdef USE_TLS
	mustCheckCertificate = checkcertificateifssl;
	mustCheckHostName = checkhostnameifssl;
#endif
    credentials = credent;
    receivedLength = 0;

    if (!hasinitialized)
        return ERR_HGET_NOT_INITIALIZED;

    if(!url)
        return ERR_HGET_INVALID_PARAMETERS;

    if(filename)
        strcpy(localFileName, filename);
    else
        localFileName[0] = '\0';

    if (progress_callback) {
        UpdateReceivedStatus = (funcptr)progress_callback;
        thereisacallback = true;
    } else
        thereisacallback = false;

    if (data_write_callback) {
        SaveReceivedData = (funcdataptr)data_write_callback;
        thereisasavecallback = true;
    } else
        thereisasavecallback = false;

    if (content_size_callback) {
        SendContentSize = (funcsizeptr)content_size_callback;
        thereisasizecallback = true;
    } else
        thereisasizecallback = false;

    tryKeepAlive = enableKeepAlive & continue_using_keep_alive;

    //did the previous operation requested to keep connection alive?
    if (!keepingConnectionAlive) {
        *domainName = '\0';
        funcret = ProcessUrl(url, 0);
    } else //connection is alive, so treat as redirection so it checks the previous domain name
        funcret = ProcessUrl(url, 1);

    if (funcret != ERR_TCPIPUNAPI_OK)
        return funcret;

    if(localFileName[0] == '\0') {
        pointer = FindLastSlash(remoteFilePath);
        if(pointer == NULL || pointer[1] == '\0') {
            pointer = strDefaultFilename;
            strcpy(localFileName, pointer);
        } else {
            strcpy(localFileName, pointer + 1);
        }
    }

    if (!CheckNetworkConnection()) {
        if (keepingConnectionAlive)
        {
            tryKeepAlive = false;
            TerminateConnection();
        }
        return ERR_TCPIPUNAPI_NO_CONNECTION;
    }

    funcret = DoHttpWork(rcvbuffer, rcvbuffersize);

    if (funcret != ERR_TCPIPUNAPI_OK)
        tryKeepAlive = false;

    TerminateConnection();

    return funcret;
}


/****************************
 ***  FUNCTIONS are here  ***
 ****************************/
/* Functions Related to HTTP Handling */
void TerminateConnection()
{
    if (!tryKeepAlive) {
        CloseTcpConnection();
        keepingConnectionAlive = false;
    }
    else
        keepingConnectionAlive = true;
}


int ProcessUrl(char* url, byte isRedirection)
{
    char* pointer;

    if(url[0] == '/') {
        if(isRedirection) {
            redirectionUrlIsNewDomainName = 0;
        } else {
            return ERR_HGET_INVALID_PARAMETERS;
        }
    } else if(StringStartsWith(url, "http://")) {
		TcpConnectionParameters->remotePort = HTTP_DEFAULT_PORT;
		TcpConnectionParameters->flags = 0 ;
        if(isRedirection) {
#ifdef USE_TLS
			if (useHttps)
				redirectionUrlIsNewDomainName = 1;
			else
#endif
			{
				pointer = strstr(url+7, "/");
				if ((pointer)&&(strncmpi(url+7, domainName, (pointer-url-7))))
					redirectionUrlIsNewDomainName = 1;
				else
					redirectionUrlIsNewDomainName = 0;
			}
        }
        strcpy(domainName, url + 7);
#ifdef USE_TLS
		useHttps = false;
#endif
    } else
#ifdef USE_TLS
    if((TlsIsSupported)&&(StringStartsWith(url, "https://"))) {
        if(isRedirection) {
			if (!useHttps)
				redirectionUrlIsNewDomainName = 1;
			else
			{
				pointer = strstr(url+8, "/");
				if ((pointer)&&(strncmpi(url+8, domainName, (pointer-url-8))))
					redirectionUrlIsNewDomainName = 1;
				else
					redirectionUrlIsNewDomainName = 0;
			}
        }
        strcpy(domainName, url + 8);
		useHttps = true;
		TcpConnectionParameters->remotePort = HTTPS_DEFAULT_PORT;
		TcpConnectionParameters->flags = TcpConnectionParameters->flags | TCPFLAGS_USE_TLS ;
    } else
#endif
    if(strstr(url, "://") != NULL) {
        if(isRedirection) {
            return ERR_TCPIPUNAPI_REDIRECT_TO_HTTPS_WHICH_IS_UNSUPPORTED;
        } else {
            return ERR_TCPIPUNAPI_HTTPS_UNSUPPORTED;
        }
    } else {
        if(isRedirection) {
            return ERR_TCPIPUNAPI_NON_ABSOLUTE_URL_ON_REDIRECT_REQUEST;
        }
        strcpy(domainName, url);
    }

    if(url[0] == '/') {
        strcpy(remoteFilePath, url);
    } else {
        remoteFilePath[0] = '/';
        remoteFilePath[1] = '\0';
        pointer = strstr(domainName, "/");
        if(pointer != NULL) {
            *pointer = '\0';
            strcpy(remoteFilePath+1, pointer+1);
        }

        ExtractPortNumberFromDomainName();
    }

    return ERR_TCPIPUNAPI_OK;
}


void ExtractPortNumberFromDomainName()
{
    char* pointer;

    pointer = strstr(domainName, ":");
    if(pointer == NULL) {
#ifdef USE_TLS
		if (!useHttps)
#endif
			TcpConnectionParameters->remotePort = HTTP_DEFAULT_PORT;
#ifdef USE_TLS
		else
			TcpConnectionParameters->remotePort = HTTPS_DEFAULT_PORT;
#endif
        return;
    }

    *pointer = '\0';
    pointer++;
    TcpConnectionParameters->remotePort = atoi(pointer);
}


int DoHttpWork(char *rcvbuffer, unsigned int *rcvbuffersize)
{
    int funcret;
    byte must_continue;

    do {
        must_continue = 0;
        authenticationRequested = 0;
        redirectionRequests = 0;
        keepingConnectionAlive &= continue_using_keep_alive;

        ResetTcpBuffer();

        if ((!keepingConnectionAlive)||((keepingConnectionAlive)&&(redirectionUrlIsNewDomainName))) {
            funcret = ResolveServerName();
            if (funcret != ERR_TCPIPUNAPI_OK)
                return funcret;

            funcret = OpenTcpConnection();
            if (funcret != ERR_TCPIPUNAPI_OK)
                return funcret;
        }

        do {
            // Initialize HTTP Variables
            redirectionRequested = 0;
            authenticationSent = 0;
            continueReceived = 0;
            isChunkedTransfer = 0;
            contentLength = 0;
            newLocationReceived = 0;
            indicateblockprogress = 0;

            funcret = SendHttpRequest();
            if (funcret != ERR_TCPIPUNAPI_OK) {
                if ((keepingConnectionAlive)&&(continue_using_keep_alive)) {
                    keepingConnectionAlive = 0;
                    continue_using_keep_alive = 0;
                    must_continue = 1;
                    break;
                }
                else
                    return funcret;
            }

            funcret = ReadResponseHeaders();
            if (funcret != ERR_TCPIPUNAPI_OK) {
                if ((keepingConnectionAlive)&&(continue_using_keep_alive)) {
                    keepingConnectionAlive = 0;
                    continue_using_keep_alive = 0;
                    must_continue = 1;
                    break;
                }
                else
                    return funcret;
            }

            funcret = CheckHeaderErrors();
            if (funcret != ERR_TCPIPUNAPI_OK) {
                if ((keepingConnectionAlive)&&(continue_using_keep_alive)) {
                    keepingConnectionAlive = 0;
                    continue_using_keep_alive = 0;
                    must_continue = 1;
                    break;
                }
                else
                    return funcret;
            }

            if(redirectionRequested) {
                if(redirectionUrlIsNewDomainName) {
                    CloseTcpConnection();
                    funcret = ResolveServerName();
                    if (funcret != ERR_TCPIPUNAPI_OK)
                        return funcret;
                    funcret = OpenTcpConnection();
                    if (funcret != ERR_TCPIPUNAPI_OK)
                        return funcret;
                }
                ResetTcpBuffer();
            } else if(continueReceived || authenticationRequested) {
                funcret = DiscardBogusHttpContent();
                if (funcret != ERR_TCPIPUNAPI_OK) {
                    if ((keepingConnectionAlive)&&(continue_using_keep_alive)) {
                        keepingConnectionAlive = 0;
                        continue_using_keep_alive = 0;
                        must_continue = 1;
                        break;
                    }
                    else
                        return funcret;
                }
            }
        } while(continueReceived || redirectionRequested || authenticationRequested);

        if (must_continue)
            continue;
        funcret = DownloadHttpContents(rcvbuffer, rcvbuffersize);
        break;
    } while (1);

    return funcret;
}


int DiscardBogusHttpContent()
{
    int funcret = ERR_TCPIPUNAPI_OK;
    while(remainingInputData > 0) {
        funcret = GetInputByte(NULL);
        if (funcret!=ERR_TCPIPUNAPI_OK)
            return funcret;
    }
    return funcret;
}


int SendHttpRequest()
{
    int funcret;
    sprintf(TcpOutputData, "%s %s HTTP/1.1\r\n", "GET", remoteFilePath);
    funcret = SendLineToTcp(TcpOutputData);
    if (funcret!=ERR_TCPIPUNAPI_OK)
        return funcret;
    sprintf(TcpOutputData, "Host: %s\r\n", domainName);
    funcret = SendLineToTcp(TcpOutputData);
    if (funcret!=ERR_TCPIPUNAPI_OK)
        return funcret;
    sprintf(TcpOutputData, HGET_AGENT);
    funcret = SendLineToTcp(TcpOutputData);
    if (funcret!=ERR_TCPIPUNAPI_OK)
        return funcret;
    if (tryKeepAlive) {
        sprintf(TcpOutputData, "Connection: Keep-Alive\r\n");
        funcret = SendLineToTcp(TcpOutputData);
        if (funcret!=ERR_TCPIPUNAPI_OK)
            return funcret;
    }
    funcret = SendCredentialsIfNecessary();
    if (funcret!=ERR_TCPIPUNAPI_OK)
        return funcret;
    sprintf(TcpOutputData,"\r\n");
    funcret = SendLineToTcp(TcpOutputData);
    return funcret;
}


int SendCredentialsIfNecessary()
{
    int encodedLength;
    int funcret;

    if(authenticationRequested) {
        Base64Init(0);
        encodedLength = Base64EncodeChunk(credentials, TcpOutputData, strlen(credentials),1);
        TcpOutputData[encodedLength] = '\0';
        encodedLength++;
        sprintf(&TcpOutputData[encodedLength], "Authorization: Basic %s\r\n", TcpOutputData);
        funcret = SendLineToTcp(&TcpOutputData[encodedLength]);
        if (funcret!=ERR_TCPIPUNAPI_OK)
            authenticationSent = 0;
        else
            authenticationSent = 1;
        return funcret;
    }

    return ERR_TCPIPUNAPI_OK;
}


int ReadResponseHeaders()
{
    int funcret;

    emptyLineReaded = 0;
    zeroContentLengthAnnounced = false;

    funcret = ReadResponseStatus();
    if (funcret == ERR_TCPIPUNAPI_OK)
    {
        while(!emptyLineReaded) {
            funcret = ReadNextHeader();
            if (funcret == ERR_TCPIPUNAPI_OK)
                funcret = ProcessNextHeader();
        }
        if (funcret == ERR_TCPIPUNAPI_OK)
            funcret = ProcessResponseStatus();
    }

    return funcret;
}


int ReadResponseStatus()
{
    int funcret;
    char* pointer;
    funcret = ReadNextHeader();
    if (funcret != ERR_TCPIPUNAPI_OK)
        return funcret;
    strcpy(statusLine, headerLine);
    pointer = statusLine;
    SkipCharsUntil(pointer, ' ');
    SkipCharsWhile(pointer, ' ');
    responseStatusCode = atoi(pointer);
    responseStatusCodeFirstDigit = (byte)*pointer - (byte)'0';
    return ERR_TCPIPUNAPI_OK;
}


int ProcessResponseStatus()
{
    if(responseStatusCode == 401) {
        if(authenticationSent) {
            return ERR_HGET_AUTH_FAILED;
        } else {
            authenticationRequested = 1;
        }
        return ERR_TCPIPUNAPI_OK;
    }

    authenticationRequested = 0;

    if(responseStatusCodeFirstDigit == 1) {
        continueReceived = 1;
    } else if(responseStatusCodeFirstDigit == 3) {
        redirectionRequested = 1;
		++redirectionRequests;
		if (redirectionRequests>MAX_REDIRECTIONS)
			return ERR_HGET_TOO_MANY_REDIRECTS;
    } else if(responseStatusCodeFirstDigit != 2) {
        return ERR_HGET_HTTP_ERROR;
    }

    return ERR_TCPIPUNAPI_OK;
}


int ReadNextHeader()
{
    char* pointer;
    byte data;
    int funcret;
    pointer = headerLine;

    funcret = GetInputByte(&data);
    if (funcret != ERR_TCPIPUNAPI_OK)
        return funcret;
    if(data == 13) {
        funcret = SkipLF();
        if (funcret != ERR_TCPIPUNAPI_OK)
            return funcret;
        emptyLineReaded = 1;
        return ERR_TCPIPUNAPI_OK;
    }
    *pointer = data;
    pointer++;

    do {
        funcret = GetInputByte(&data);
        if (funcret != ERR_TCPIPUNAPI_OK)
            return funcret;
        if(data == 13) {
            *pointer = '\0';
            funcret = SkipLF();
            if (funcret != ERR_TCPIPUNAPI_OK)
                return funcret;
        } else {
            *pointer = data;
            pointer++;
        }
    } while(data != 13);

    return ERR_TCPIPUNAPI_OK;
}


int ProcessNextHeader()
{
    char* pointer;

    if(emptyLineReaded) {
        return ERR_TCPIPUNAPI_OK;
    }

    if(continueReceived) {
        return ERR_TCPIPUNAPI_OK;
    }

    ExtractHeaderTitleAndContents();

    if(HeaderTitleIs("Content-Length")) {
        contentLength = atol(headerContents);
        if (thereisasizecallback)
            SendContentSize(contentLength);
        if(contentLength == 0)
            zeroContentLengthAnnounced = true;
    }

    if(HeaderTitleIs("Transfer-Encoding")) {
        if(HeaderContentsIs("Chunked")) {
            isChunkedTransfer = 1;
        }
    }

    if(HeaderTitleIs("WWW-Authenticate") && !StringStartsWith(headerContents, "Basic")) {
        pointer = headerContents;
        SkipCharsUntil(pointer, ' ');
        *pointer = '\0';
        return ERR_HGET_UNK_AUTH_METHOD_REQUEST;
    }

    if(HeaderTitleIs("Location")) {
        strcpy(redirectionFullLocation, headerContents);
        newLocationReceived = 1;
        ProcessUrl(headerContents, 1);
    }

    if(HeaderTitleIs("Connection") && HeaderContentsIs("close") && (tryKeepAlive)) {
        tryKeepAlive = false;
    }

    return ERR_TCPIPUNAPI_OK;
}


void ExtractHeaderTitleAndContents()
{
    char* pointer;
    pointer = headerLine;

    SkipCharsWhile(pointer, ' ');
    headerTitle = headerLine;
    SkipCharsUntil(pointer, ':');

    *pointer = '\0';
    pointer++;
    SkipCharsWhile(pointer, ' ');

    headerContents = pointer;

}

int CheckHeaderErrors()
{
    if(contentLength == 0 && !zeroContentLengthAnnounced && !isChunkedTransfer)
        return ERR_TCPIPUNAPI_OK;
    else if(redirectionRequested && !newLocationReceived)
        return ERR_HGET_REDIRECT_BUT_NO_NEW_LOCATION_PROVIDED;
    else if(authenticationRequested && credentials == NULL)
        return ERR_HGET_AUTH_REQUESTED_BUT_NO_CREDENTIALS_PROVIDED;
    else
        return ERR_TCPIPUNAPI_OK;
}


int HeaderTitleIs(char* string)
{
    return strcmpi(headerTitle, string) == 0;
}


int HeaderContentsIs(char* string)
{
    return strcmpi(headerContents, string) == 0;
}


int SendLineToTcp(char* string)
{
    int len;

    len = strlen(string);
    return SendTcpData(string, len);
}


int DownloadHttpContents(char *rcvbuffer, unsigned int *rcvbuffersize)
{
    int funcret;

    if ((!rcvbuffersize)||(!*rcvbuffersize)) {
        if (!CreateLocalFile())
            return ERR_HGET_CANT_CREATE_FILE;
    }

    if(isChunkedTransfer) {
        funcret = DoChunkedDataTransfer(rcvbuffer, rcvbuffersize);
    } else
        funcret = DoDirectDatatransfer(rcvbuffer, rcvbuffersize);

    CloseLocalFile();

    return funcret;
}

int DoDirectDatatransfer(char *rcvbuffer, unsigned int *rcvbuffersize)
{
    int funcret = ERR_TCPIPUNAPI_OK;
    unsigned int bufferAvailable = 0;

    if (rcvbuffersize) {
        bufferAvailable = *rcvbuffersize;
        *rcvbuffersize = 0;
    }

    if(zeroContentLengthAnnounced) {
        return funcret;
    }

	if (contentLength) {
		blockSize = contentLength/25;
		currentBlock = 0;
		if (blockSize)
            indicateblockprogress = 1;
	}

	if (bufferAvailable)
    while(contentLength == 0 || receivedLength < contentLength) {
        funcret = EnsureThereIsTcpDataAvailable();
        if (funcret != ERR_TCPIPUNAPI_OK)
                return funcret;
        receivedLength += remainingInputData;
		currentBlock += remainingInputData;
        UpdateReceivingMessage();
        if (bufferAvailable>=remainingInputData) {
            memcpy(&rcvbuffer[*rcvbuffersize],inputDataPointer,remainingInputData);
            bufferAvailable-=remainingInputData;
            *rcvbuffersize+=remainingInputData;
        } else if (bufferAvailable) {
            memcpy(&rcvbuffer[*rcvbuffersize],inputDataPointer,bufferAvailable);
            *rcvbuffersize+=bufferAvailable;
            bufferAvailable=0;
        }
        ResetTcpBuffer();
    }
    else
        while(contentLength == 0 || receivedLength < contentLength) {
            funcret = EnsureThereIsTcpDataAvailable();
            if (funcret != ERR_TCPIPUNAPI_OK)
                    return funcret;
            receivedLength += remainingInputData;
            currentBlock += remainingInputData;
            UpdateReceivingMessage();
            if (!WriteContentsToFile(inputDataPointer, remainingInputData))
                return ERR_HGET_DISK_WRITE_ERROR;
            ResetTcpBuffer();
        }
    return funcret;
}


int DoChunkedDataTransfer(char *rcvbuffer, unsigned int *rcvbuffersize)
{
    int chunkSizeInBuffer;
    int funcret = ERR_TCPIPUNAPI_OK;
    unsigned int bufferAvailable = 0;

    if (rcvbuffersize) {
        bufferAvailable = *rcvbuffersize;
        *rcvbuffersize = 0;
    }

    currentChunkSize = GetNextChunkSize();

	if (contentLength) {
		blockSize = contentLength/25;
		currentBlock = 0;
	}

	if (bufferAvailable)
        while(1) {
            if(currentChunkSize == 0) {
                funcret = GetInputByte(NULL); //Chunk data is followed by an extra CRLF
                if (funcret != ERR_TCPIPUNAPI_OK)
                    return funcret;
                funcret = GetInputByte(NULL);
                if (funcret != ERR_TCPIPUNAPI_OK)
                    return funcret;
                currentChunkSize = GetNextChunkSize();
                if(currentChunkSize == 0) {
                    break;
                }
            }

            if(remainingInputData == 0) {
                funcret = EnsureThereIsTcpDataAvailable();
                if (funcret != ERR_TCPIPUNAPI_OK)
                    return funcret;
            }

            chunkSizeInBuffer = currentChunkSize > remainingInputData ? remainingInputData : currentChunkSize;
            receivedLength += chunkSizeInBuffer;
            UpdateReceivingMessage();

            if (bufferAvailable>=chunkSizeInBuffer) {
                memcpy(&rcvbuffer[*rcvbuffersize],inputDataPointer,chunkSizeInBuffer);
                bufferAvailable-=chunkSizeInBuffer;
                *rcvbuffersize+=chunkSizeInBuffer;
            } else if (bufferAvailable) {
                memcpy(&rcvbuffer[*rcvbuffersize],inputDataPointer,bufferAvailable);
                *rcvbuffersize+=bufferAvailable;
                bufferAvailable=0;
            }

            inputDataPointer += chunkSizeInBuffer;
            currentChunkSize -= chunkSizeInBuffer;
            remainingInputData -= chunkSizeInBuffer;
        }
    else
        while(1) {
            if(currentChunkSize == 0) {
                funcret = GetInputByte(NULL); //Chunk data is followed by an extra CRLF
                if (funcret != ERR_TCPIPUNAPI_OK)
                    return funcret;
                funcret = GetInputByte(NULL);
                if (funcret != ERR_TCPIPUNAPI_OK)
                    return funcret;
                currentChunkSize = GetNextChunkSize();
                if(currentChunkSize == 0) {
                    break;
                }
            }

            if(remainingInputData == 0) {
                funcret = EnsureThereIsTcpDataAvailable();
                if (funcret != ERR_TCPIPUNAPI_OK)
                    return funcret;
            }

            chunkSizeInBuffer = currentChunkSize > remainingInputData ? remainingInputData : currentChunkSize;
            receivedLength += chunkSizeInBuffer;
            UpdateReceivingMessage();
            if (!WriteContentsToFile(inputDataPointer, chunkSizeInBuffer))
                return ERR_HGET_DISK_WRITE_ERROR;
            inputDataPointer += chunkSizeInBuffer;
            currentChunkSize -= chunkSizeInBuffer;
            remainingInputData -= chunkSizeInBuffer;
        }
    return funcret;
}


long GetNextChunkSize()
{
    byte validHexDigit = 1;
    char data;
    long value = 0;

    while(validHexDigit) {
        if (GetInputByte(&data)!=ERR_TCPIPUNAPI_OK)
            return 0; //bad hack, should not happen a lot anyway, and most servers do not used chunked transfers anyway
        ToLowerCase(data);
        if(data >= '0' && data <= '9') {
            value = value*16 + data - '0';
        } else if(data >= 'a' && data <= 'f') {
            value = value*16 + data - 'a' + 10;
        } else {
            validHexDigit = 0;
        }
    }

    do {
        if (GetInputByte(&data)!=ERR_TCPIPUNAPI_OK)
            return 0; //bad hack, should not happen a lot anyway, and most servers do not used chunked transfers anyway
    } while(data != 10);

    return value;
}


/* Functions Related to Callbacks Handling */


void UpdateReceivingMessage()
{
    if(thereisacallback) {
		if (indicateblockprogress) {
			while (currentBlock>=blockSize)
			{
				currentBlock-=blockSize;
				UpdateReceivedStatus(false);
			}
		} else
			UpdateReceivedStatus(true);
    }
}


/* Functions Related to Console I/O */


bool InitializeTcpipUnapi()
{
    int i;
    i = UnapiGetCount("TCP/IP");
    if(i==0)
        return false;
    UnapiBuildCodeBlock(NULL, 1, codeBlock);
    reg.Bytes.B = 0;
    UnapiCall(codeBlock, TCPIP_TCP_ABORT, &reg, REGS_MAIN, REGS_MAIN);
    TcpConnectionParameters->remotePort = HTTP_DEFAULT_PORT;
    TcpConnectionParameters->localPort = 0xFFFF;
    TcpConnectionParameters->userTimeout = 0;
    TcpConnectionParameters->flags = 0;
    return true;
}


bool CheckTcpipCapabilities()
{
    reg.Bytes.B = 1;
    UnapiCall(codeBlock, TCPIP_GET_CAPAB, &reg, REGS_MAIN, REGS_MAIN);
    if((reg.Bytes.L & (1 << 3)) == 0)
        return false;

#ifdef USE_TLS
    TlsIsSupported = false;
    safeTlsIsSupported = false;

    if(tcpIpSpecificationVersionMain == 0 || (tcpIpSpecificationVersionMain == 1 && tcpIpSpecificationVersionSecondary == 0))
        return true; //TCP/IP UNAPI <1.1 has no TLS support at all

    if(reg.Bytes.D & TCPIP_CAPAB_VERIFY_CERTIFICATE)
		safeTlsIsSupported = true;

    reg.Bytes.B = 4;
    UnapiCall(codeBlock, TCPIP_GET_CAPAB, &reg, REGS_MAIN, REGS_MAIN);
    if(reg.Bytes.H & 1)
        TlsIsSupported = true;
#endif
    return true;
}


/* Functions Related to Network I/O */


int EnsureThereIsTcpDataAvailable()
{
    int funcret;
    ticksWaited = 0;

	sysTimerHold = *SYSTIMER;
	while(remainingInputData == 0) {
		if (sysTimerHold != *SYSTIMER) {
			++ticksWaited;
			if(ticksWaited >= TICKS_TO_WAIT)
                return ERR_HGET_TRANSFER_TIMEOUT;
			sysTimerHold = *SYSTIMER;
		}

		funcret = ReadAsMuchTcpDataAsPossible();
		if (funcret!=ERR_TCPIPUNAPI_OK)
            return funcret;
		if(remainingInputData == 0) {
			if (!EnsureTcpConnectionIsStillOpen())
                return ERR_HGET_CONN_LOST;
            LetTcpipBreathe();
		}
	}
	return ERR_TCPIPUNAPI_OK;
}


bool EnsureTcpConnectionIsStillOpen()
{
    reg.Bytes.B = conn;
    reg.Words.HL = 0;
    UnapiCall(codeBlock, TCPIP_TCP_STATE, &reg, REGS_MAIN, REGS_MAIN);
    if(reg.Bytes.A != 0 || reg.Bytes.B != 4)
        return false;
    else
        return true;
}


int ReadAsMuchTcpDataAsPossible()
{
    if(AbortIfEscIsPressed())
        return ERR_HGET_ESC_CANCELLED;
    reg.Bytes.B = conn;
    reg.Words.DE = (int)(TcpInputData);
    reg.Words.HL = TCP_BUFFER_SIZE;
    UnapiCall(codeBlock, TCPIP_TCP_RCV, &reg, REGS_MAIN, REGS_MAIN);
    if(reg.Bytes.A != 0)
        return ERR_TCPIPUNAPI_RECEIVE_ERROR;

    remainingInputData = reg.UWords.BC;
    inputDataPointer = TcpInputData;

    return ERR_TCPIPUNAPI_OK;
}


int GetInputByte(byte *data)
{
    int funcret;
    funcret = EnsureThereIsTcpDataAvailable();
    if (funcret == ERR_TCPIPUNAPI_OK) {
        if (data)
            *data = *inputDataPointer;
        inputDataPointer++;
        remainingInputData--;
    }
    return funcret;
}


bool CheckNetworkConnection()
{
    UnapiCall(codeBlock, TCPIP_NET_STATE, &reg, REGS_NONE, REGS_MAIN);
    if(reg.Bytes.B == 0 || reg.Bytes.B == 3) {
        return false;
    }
    return true;
}


int ResolveServerName()
{
    reg.Words.HL = (int)domainName;
    reg.Bytes.B = 0;
    UnapiCall(codeBlock, TCPIP_DNS_Q, &reg, REGS_MAIN, REGS_MAIN);
    if(reg.Bytes.A == ERR_NO_NETWORK)
        return ERR_TCPIPUNAPI_NO_CONNECTION;
    else if(reg.Bytes.A == ERR_NO_DNS)
        return ERR_TCPIPUNAPI_NO_DNS_CONFIGURED;
    else if(reg.Bytes.A == ERR_NOT_IMP)
        return ERR_TCPIPUNAPI_NOT_DNS_CAPABLE;
    else if(reg.Bytes.A != (byte)ERR_OK)
        return ERR_TCPIPUNAPI_UNKNOWN_ERROR;

    do {
        if (AbortIfEscIsPressed())
            return ERR_HGET_ESC_CANCELLED;
        LetTcpipBreathe();
        reg.Bytes.B = 0;
        UnapiCall(codeBlock, TCPIP_DNS_S, &reg, REGS_MAIN, REGS_MAIN);
    } while (reg.Bytes.A == 0 && reg.Bytes.B == 1);

    if(reg.Bytes.A != 0) {
        if(reg.Bytes.B == 2)
            return ERR_TCPIPUNAPI_DNS_FAILURE;
        else if(reg.Bytes.B == 3)
            return ERR_TCPIPUNAPI_DNS_UNKNWON_HOSTNAME;
        else if(reg.Bytes.B == 5)
            return ERR_TCPIPUNAPI_DNS_REFUSED;
        else if(reg.Bytes.B == 16 || reg.Bytes.B == 17)
            return ERR_TCPIPUNAPI_DNS_NO_RESPONSE;
        else if(reg.Bytes.B == 19)
            return ERR_TCPIPUNAPI_NO_CONNECTION;
        else if(reg.Bytes.B == 0)
            return ERR_TCPIPUNAPI_DNS_QUERY_FAILED;
        else
            return ERR_TCPIPUNAPI_DNS_UNKNWON_ERROR;
    }

    TcpConnectionParameters->remoteIP[0] = reg.Bytes.L;
    TcpConnectionParameters->remoteIP[1] = reg.Bytes.H;
    TcpConnectionParameters->remoteIP[2] = reg.Bytes.E;
    TcpConnectionParameters->remoteIP[3] = reg.Bytes.D;
#ifdef USE_TLS
	if (useHttps) {
		if (mustCheckCertificate)
			TcpConnectionParameters->flags = TcpConnectionParameters->flags | TCPFLAGS_VERIFY_CERTIFICATE ;
		if (mustCheckHostName)
			TcpConnectionParameters->hostName =  (int)domainName;
		else
			TcpConnectionParameters->hostName =  0;
	} else
#endif
	{
		TcpConnectionParameters->flags = 0 ;
		TcpConnectionParameters->hostName =  0;
	}

    return ERR_TCPIPUNAPI_OK;
}


int OpenTcpConnection()
{
    reg.Words.HL = (int)TcpConnectionParameters;
    UnapiCall(codeBlock, TCPIP_TCP_OPEN, &reg, REGS_MAIN, REGS_MAIN);
    if(reg.Bytes.A == (byte)ERR_NO_FREE_CONN) {
        reg.Bytes.B = 0;
        UnapiCall(codeBlock, TCPIP_TCP_ABORT, &reg, REGS_MAIN, REGS_NONE);
        reg.Words.HL = (int)TcpConnectionParameters;
        UnapiCall(codeBlock, TCPIP_TCP_OPEN, &reg, REGS_MAIN, REGS_MAIN);
    }

    if(reg.Bytes.A == (byte)ERR_NO_NETWORK)
        return ERR_TCPIPUNAPI_NO_CONNECTION;
    else if(reg.Bytes.A != 0)
        return ERR_TCPIPUNAPI_CONNECTION_FAILED;

    conn = reg.Bytes.B;

    ticksWaited = 0;
    sysTimerHold = *SYSTIMER;
    do {
        if (AbortIfEscIsPressed())
            return ERR_HGET_ESC_CANCELLED;

        if (*SYSTIMER != sysTimerHold)
        {
            ticksWaited++;
            if(ticksWaited >= TICKS_TO_WAIT)
                return ERR_TCPIPUNAPI_CONNECTION_TIMEOUT;
            sysTimerHold = *SYSTIMER;
        }

        reg.Bytes.B = conn;
        reg.Words.HL = 0;
        UnapiCall(codeBlock, TCPIP_TCP_STATE, &reg, REGS_MAIN, REGS_MAIN);
        if ((reg.Bytes.A) == 0 && (reg.Bytes.B != 4))
            LetTcpipBreathe();
        else
            break;
    } while(1);

    if(reg.Bytes.A != 0)
		return ERR_TCPIPUNAPI_CONNECTION_FAILED;

    return ERR_TCPIPUNAPI_OK;
}


void CloseTcpConnection()
{
    if(conn != 0) {
        reg.Bytes.B = conn;
        UnapiCall(codeBlock, TCPIP_TCP_CLOSE, &reg, REGS_MAIN, REGS_NONE);
        conn = 0;
    }
}


int SendTcpData(byte* data, int dataSize)
{
    do {
        do {
            reg.Bytes.B = conn;
            reg.Words.DE = (int)data;
            reg.Words.HL = dataSize > TCPOUT_STEP_SIZE ? TCPOUT_STEP_SIZE : dataSize;
            reg.Bytes.C = 1;
            UnapiCall(codeBlock, TCPIP_TCP_SEND, &reg, REGS_MAIN, REGS_AF);
            if(reg.Bytes.A == ERR_BUFFER) {
                LetTcpipBreathe();
                reg.Bytes.A = ERR_BUFFER;
            }
        } while(reg.Bytes.A == ERR_BUFFER);
        dataSize -= TCPOUT_STEP_SIZE;
        data += reg.Words.HL;   //Unmodified since REGS_AF was used for output
    } while(dataSize > 0 && reg.Bytes.A == 0);

    if(reg.Bytes.A == ERR_NO_CONN)
        return ERR_TCPIPUNAPI_NO_CONNECTION;
    else if(reg.Bytes.A != 0)
        return ERR_TCPIPUNAPI_SEND_ERROR;
    else
        return ERR_TCPIPUNAPI_OK;
}


/* Functions Related to File I/O */


bool CreateLocalFile()
{
    long preallocseek;
    if (thereisasavecallback)
        return true;
    reg.Bytes.A = 0;
    reg.Bytes.B = 0;
    reg.Words.DE = (int)localFileName;
    DosCall(_CREATE, &reg, REGS_MAIN, REGS_MAIN);
    if(reg.Bytes.A != 0)
        return false;
    fileHandle = reg.Bytes.B;

    if (contentLength)
    {
        //Set file to file size - 1
        preallocseek = contentLength - 1;
        reg.Bytes.A = 0;
        reg.Words.HL = (preallocseek&0xffff);
        reg.Words.DE = (preallocseek>>16)&0xffff;
        DosCall(_SEEK, &reg, REGS_MAIN, REGS_NONE);

        //Write a single byte
        reg.Words.DE = 0x3000;
        reg.Words.HL = 1;
        DosCall(_WRITE, &reg, REGS_MAIN, REGS_AF);
        if(reg.Bytes.A != 0)
            return false;

        //Back to beginning of file
        reg.Bytes.A = 0;
        reg.Words.HL = 0;
        reg.Words.DE = 0;
        DosCall(_SEEK, &reg, REGS_MAIN, REGS_NONE);

        //Ensure - flush to disk, writes should be smoother after this
        DosCall(_ENSURE, &reg, REGS_MAIN, REGS_NONE);
    }
    return true;
}


bool WriteContentsToFile(byte* dataPointer, int size)
{
    if (thereisasavecallback) {
        SaveReceivedData(dataPointer, size);
        return true;
    }

    reg.Bytes.B = fileHandle;
    reg.Words.DE = (int)dataPointer;
    reg.Words.HL = size;
    DosCall(_WRITE, &reg, REGS_MAIN, REGS_AF);
    if(reg.Bytes.A != 0) {
        return false;
    } else
        return true;
}


void CloseLocalFile()
{
    if(fileHandle != 0) {
        CloseFile(fileHandle);
        fileHandle = 0;
    }
}


void CloseFile(byte fileHandle)
{
    if (thereisasavecallback)
        return;
    reg.Bytes.B = fileHandle;
    DosCall(_CLOSE, &reg, REGS_MAIN, REGS_NONE);
}


/* Functions Related to Strings */


int StringStartsWith(const char* stringToCheck, const char* startingToken)
{
    int len;
    len = strlen(startingToken);
    return strncmpi(stringToCheck, startingToken, len) == 0;
}


char* FindLastSlash(char* string)
{
    char* pointer;

    pointer = string + strlen(string);
    while(pointer >= string) {
        if(*pointer == '/') {
            return pointer;
        }
        pointer--;
    }

    return NULL;
}


char* ltoa(unsigned long num, char *string)
{
    char* pointer = string;
    int nonZeroProcessed = 0;
    unsigned long power = 1000000000;
    unsigned char digit = 0;

    while(power > 0) {
        digit = num / power;
        num = num % power;
        if(digit == 0 && nonZeroProcessed) {
            *pointer++ = '0';
        } else if(digit !=0) {
            nonZeroProcessed = 1;
            *pointer++ = (char)digit + '0';
        }
        power /= 10;
    }

    if(!nonZeroProcessed) {
        *pointer++ = '0';
    }

    *pointer = '\0';

    return string;
}


int strcmpi(const char *a1, const char *a2) {
	char c1, c2;
	/* Want both assignments to happen but a 0 in both to quit, so it's | not || */
	while((c1=*a1) | (c2=*a2)) {
		if (!c1 || !c2 || /* Unneccesary? */
			(islower(c1) ? toupper(c1) : c1) != (islower(c2) ? toupper(c2) : c2))
			return (c1 - c2);
		a1++;
		a2++;
	}
	return 0;
}


int strncmpi(const char *a1, const char *a2, unsigned size) {
	char c1, c2;
	/* Want both assignments to happen but a 0 in both to quit, so it's | not || */
	while((size > 0) && (c1=*a1) | (c2=*a2)) {
		if (!c1 || !c2 || /* Unneccesary? */
			(islower(c1) ? toupper(c1) : c1) != (islower(c2) ? toupper(c2) : c2))
			return (c1 - c2);
		a1++;
		a2++;
		size--;
	}
	return 0;
}
