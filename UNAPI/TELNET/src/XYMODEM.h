#ifndef _XYMODEM_HEADER_INCLUDED
#define _XYMODEM_HEADER_INCLUDED

/*
 * This implementation of X/Y MODEM doesn't CRC check packets
 * Mostly for three reasons:
 *
 * 1 - A few BBSs send bad CRC's not following the right CRC approach
 * 2 - Packet won't be corrupted, TCP takes care of that
 * 3 - CRC Check can be very intensive on a z80
 *
 * Thus, this implementation is meant to be used on TCP connections and do not
 * implement CRC checks.
 *
 */

//Defines for X and YMODEM
#define SOH 0x01
#define STX 0x02
#define EOT 0x04
#define ACK 0x06
#define NAK 0x15
#define ETB 0x17
#define CAN 0x18

__at 0xFC9E unsigned int uiTickCount;

char *ultostr(unsigned long value, char *ptr, int base);
unsigned char XYModemPacketReceive (int *File, unsigned char Action, unsigned char PktNumber, unsigned char isYmodem);
void CancelTransfer(void);
void XYModemGet (unsigned char chConn);
int GetPacket(unsigned char * ucPacket, unsigned char * ucIs1K);
int ParseReceivedData(unsigned char * ucReceived, unsigned int uiIndex, unsigned int uiReceivedSize, unsigned char * ucIs1K);
#endif // _XYMODEM_HEADER_INCLUDED
