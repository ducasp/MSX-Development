/*
 * MSX2ANSI ANSI V9938 Library for SDCC
 *
 * Original ANSI Rendering Engine Code by Tobias Keizer (ANSI-DRV.BIN)
 * Tobias has made this great piece of code and most of what is in it has been
 * coded by him! Big Kudos to Toby! :)
 *
 * This version of code and conversion into SDCC library by Oduvaldo Pavan Junior
 * ducasp@gmail.com
 *
 * Comercial usage of this code or derivative works of this code are
 * allowed ONLY upon agreement with the author.
 * Non-comercial usage is free as long as you publish your code changes and give
 * credits to the original authors
 *
 */


__at 0x002D unsigned char ucMSXVer;

/*
 * AnsiInit needs no parameters
 *
 * Will set the proper screen mode, clear screen, set cursor stuff
 *
 * You MUST call it, otherwise results might be unpredictable and crash
 *
 */ 
void AnsiInit() __sdcccall(0);

/*
 * AnsiFinish needs no parameters
 *
 * Will restore MSX to Screen 0 and restore original palette
 *
 * You MUST call it before returning to MSX-DOS, otherwise user will face a 
 * static screen and think it has crashed (you can type MODE 80 and restore it
 * manually). So MAKE SURE to handle CTRL+BREAK, CTRL+C, etc and call this function
 * before returning.
 *
 */
void AnsiFinish() __sdcccall(0);

/*
 * AnsiStartBuffer needs no parameters
 *
 * Will turn off sprite cursor if it is on, idea is to make rendering faster and
 * there is no need to have the cursor enabled while rendering a live buffer. For
 * some applications it is faster to use putchar than print, thus the need to indicate
 * start and end of buffer printing
 *
 */
void AnsiStartBuffer() __sdcccall(0);

/*
 * AnsiEndBuffer needs no parameters
 *
 * Will turn sprite cursor back on if it was on, idea is to make rendering faster and
 * there is no need to have the cursor enabled while rendering a live buffer. For
 * some applications it is faster to use putchar than print, thus the need to indicate
 * start and end of buffer printing
 *
 */
void AnsiEndBuffer() __sdcccall(0);

/*
 * AnsiCallBack - parameter in HL, 16 byte address to callback function
 *
 * Will call a __z88dk_fastcall function with Column/Line as a parameter 
 *
 * This is useful to handle quickly ESC[6n cursor position requests, as it is up to
 * the user program to determine how to send that information.
 *
 * Callback function prototype/example:
 void CursorPositionRequestCallBack(unsigned int uiCursorPosition) __z88dk_fastcall
 {
	unsigned char uchRow,uchColumn;

    uchColumn = uiCursorPosition & 0xff;
    uchRow = (uiCursorPosition >> 8) & 0xff;
	// do whatever processing you need to do (i.e.: send over connection the information)
 }
 *
 */
void AnsiCallBack(unsigned int uiCallBackAddress) __z88dk_fastcall;

/*
 * AnsiGetCursorPosition needs no parameters
 *
 * Will return current cursor position, Column in the LSB and Row in MSB
 *
 */
unsigned int AnsiGetCursorPosition() __sdcccall(0);

/*
 * AnsiPutChar will put ucChar on screen of in ANSI / VT command buffer
 *
 */
void AnsiPutChar(unsigned char ucChar) __z88dk_fastcall;

/*
 * AnsiPrint will proccess ucString and execute commands/put characters on
 * screen properly. There is no need to worry about split buffers where ANSI
 * commands are partially in one buffer and then the rest in the next buffer
 *
 */
void AnsiPrint(unsigned char * ucString) __z88dk_fastcall;