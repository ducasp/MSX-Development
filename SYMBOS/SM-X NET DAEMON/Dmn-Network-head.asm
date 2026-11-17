relocate_start

App_BegCode

;### APPLICATION HEADER #######################################################

;header structure
prgdatcod       equ 0           ;Length of the code area (OS will place this area everywhere)
prgdatdat       equ 2           ;Length of the data area (screen manager data; OS will place this area inside a 16k block of one 64K bank)
prgdattra       equ 4           ;Length of the transfer area (stack, message buffer, desktop manager data; placed between #c000 and #ffff of a 64K bank)
prgdatorg       equ 6           ;Original origin of the assembler code
prgdatrel       equ 8           ;Number of entries in the relocator table
prgdatstk       equ 10          ;Length of the stack in bytes
prgdati16       equ 12          ;Fileoffset of the included 16 colour icon
prgdatflg       equ 14          ;Flags (+1=16colour icon included)
prgdatnam       equ 15          ;Application name. The end of the string must be filled with 0.
prgdatidn       equ 48          ;"SymExe10" SymbOS executable file identification
prgdatcex       equ 56          ;additional memory for code area (will be reserved directly behind the loaded code area)
prgdatdex       equ 58          ;additional memory for data area (see above)
prgdattex       equ 60          ;additional memory for transfer area (see above)
prgdatres       equ 62          ;*reserved* (26 bytes)
prgdatver       equ 88          ;required OS version (3.0)
prgdatism       equ 90          ;Application icon (small version), 8x8 pixel, SymbOS graphic format
prgdatibg       equ 109         ;Application icon (big version), 24x24 pixel, SymbOS graphic format
prgdatlen       equ 256         ;length of header

prgpstdat       equ 6           ;start address of the data area
prgpsttra       equ 8           ;start address of the transfer area
prgpstspz       equ 10          ;additional sub process or timer IDs (4*1)
prgpstbnk       equ 14          ;64K ram bank (1-15), where the application is located
prgpstmem       equ 48          ;additional memory areas; 8 memory areas can be registered here, each entry consists of 5 bytes
                                ;00  1B  Ram bank number (1-8; if 0, the entry will be ignored)
                                ;01  1W  Address
                                ;03  1W  Length
prgpstnum       equ 88          ;Application ID
prgpstprz       equ 89          ;Main process ID

            dw App_BegData-App_BegCode  ;length of code area
            dw App_BegTrns-App_BegData  ;length of data area
            dw App_EndTrns-App_BegTrns  ;length of transfer area
prgdatadr   dw #1000                ;original origin                    POST address data area
prgtrnadr   dw relocate_count       ;number of relocator table entries  POST address transfer area
prgprztab   dw prgstk-App_BegTrns   ;stack length                       POST table processes
            dw 0                    ;*reserved*
App_BnkNum  db 0                    ;*reserved*                         POST bank number
            db "Network Daemon":ds 10:db 0  ;name
            db 1                    ;flags (+1=16c icon)
            dw App_BegData-App_BegCode  ;16 colour icon offset
            ds 5                    ;*reserved*
prgmemtab   db "SymExe10"           ;SymbOS-EXE-identifier              POST table reserved memory areas
            dw low_buflen           ;additional code memory
            dw 0                    ;additional data memory
            dw 0                    ;additional transfer memory
            ds 26                   ;*reserved*
            db 0,2                  ;required OS version (3.0) ##!!##
prgicnsml   db 2,8,8
            db #f0,#0f,#f6,#0f,#f0,#5d,#4f,#af,#5f,#2f,#ab,#f0,#0f,#f6,#0f,#f0
prgicnbig   db 6,24,24
            db #3f,#ff,#ff,#ef,#0f,#0f,#4f,#0f,#0f,#3a,#7f,#ed,#88,#00,#00,#76,#ce,#7d,#9a,#f0,#f0,#7e,#46,#6c,#9a,#ff,#ee,#7e,#c6,#7c,#9a,#ff,#ee,#7e,#78,#e1,#9a,#ff,#ee,#7e,#1f,#43,#9a,#ff,#ff,#ff,#ff,#ef
            db #9a,#00,#47,#0f,#0f,#3a,#8b,#0f,#88,#00,#00,#76,#ff,#ff,#9a,#f0,#f0,#7e,#f0,#f0,#9a,#ff,#ee,#7e,#88,#00,#9a,#ff,#ee,#7e,#8b,#3c,#9a,#ff,#ee,#7e,#8a,#0f,#9a,#ff,#ee,#7e,#ff,#ff,#9a,#00,#00,#7e
            db #f0,#f0,#8b,#0f,#0f,#7e,#1f,#43,#ff,#ff,#ff,#fd,#7f,#ed,#f0,#f0,#f0,#f2,#ce,#7d,#88,#00,#00,#76,#46,#6c,#8b,#1e,#f0,#7e,#c6,#7c,#8a,#0f,#4f,#7e,#78,#e1,#ff,#ff,#ff,#ed,#0f,#0f,#f0,#f0,#f0,#c3


;*** SYSTEM MANAGER LIBRARY USAGE
use_SySystem_PRGRUN     equ 1   ;Starts an application or opens a document
use_SySystem_PRGEND     equ 1   ;Stops an application and frees its resources
use_SySystem_PRGSRV     equ 1   ;Manages shared services or finds applications
use_SySystem_SYSWRN     equ 1   ;Opens an info, warning or confirm box
use_SySystem_SendMessage equ 1  ;private: sends a system manager message
use_SySystem_WaitMessage equ 1  ;private: waits for a system manager answer
use_SySystem_CallFunction equ 1 ;private: cross-bank function call
if DRIVER=7
use_SySystem_SELOPN     equ 1   ;Opens the file selection dialogue
else
use_SySystem_SELOPN     equ 0   ;Opens the file selection dialogue
endif
use_SySystem_HLPOPN     equ 0   ;HLP file handling
if DRIVER=7
use_SySystem_LNGLOD     equ 0   ;Loads a text pack from a language file (0: LNGSKIP=2 build)
else
use_SySystem_LNGLOD     equ 1   ;Loads a text pack from a language file
endif

;*** DESKTOP MANAGER LIBRARY USAGE
use_SyDesktop_WINOPN    equ 1   ;Opens a new window
use_SyDesktop_WINMEN    equ 0   ;Redraws the menu bar of a window
use_SyDesktop_WININH    equ 1   ;Redraws the content of a window
use_SyDesktop_WINTOL    equ 0   ;Redraws the content of the window toolbar
use_SyDesktop_WINTIT    equ 0   ;Redraws the title bar of a window
use_SyDesktop_WINSTA    equ 0   ;Redraws the status bar of a window
use_SyDesktop_WINMVX    equ 0   ;Sets the X offset of a window content
use_SyDesktop_WINMVY    equ 0   ;Sets the Y offset of a window content
use_SyDesktop_WINTOP    equ 1   ;Takes a window to the front position
use_SyDesktop_WINMAX    equ 0   ;Maximizes a window
use_SyDesktop_WINMIN    equ 0   ;Minimizes a window
use_SyDesktop_WINMID    equ 0   ;Restores a window or the size of a window
use_SyDesktop_WINMOV    equ 0   ;Moves a window to another position
use_SyDesktop_WINSIZ    equ 0   ;Resizes a window
use_SyDesktop_WINCLS    equ 1   ;Closes a window
use_SyDesktop_WINDIN    equ 1   ;Redraws the content of a window (always)
use_SyDesktop_WINSLD    equ 0   ;Redraws the two slider of a window
use_SyDesktop_WINPIN    equ 0   ;Redraws the content of a window (clipped)
use_SyDesktop_WINSIN    equ 0   ;Redraws the content of a control collection
use_SyDesktop_MENCTX    equ 0   ;Opens a context menu
use_SyDesktop_SendMessage equ 1 ;private: sends a desktop manager message
use_SyDesktop_WaitMessage equ 1 ;private: waits for a desktop manager answer
use_SyDesktop_STIADD    equ 1   ;Adds an icon to the systray
use_SyDesktop_STIREM    equ 1   ;Removes an icon from the systray
use_SyDesktop_Service   equ 0   ;[REQUIRED FOR THE FOLLOWING FUNCTIONS]
use_SyDesktop_MODGET    equ 0   ;Returns the current screen mode
use_SyDesktop_MODSET    equ 0   ;Sets the current screen 
use_SyDesktop_COLGET    equ 0   ;Returns the definition of a colours
use_SyDesktop_COLSET    equ 0   ;Defines one colours
use_SyDesktop_DSKSTP    equ 0   ;Stops the Desktop Manager
use_SyDesktop_DSKCNT    equ 0   ;Continues the Desktop Manager
use_SyDesktop_DSKPNT    equ 0   ;Fills the screen
use_SyDesktop_DSKBGR    equ 0   ;Redraws the desktop background
use_SyDesktop_DSKPLT    equ 0   ;Redraws the complete screen

;*** FILEMANAGER LIBRARY USAGE
use_SyFile_STOTRN       equ 0   ;Reads or writes a number of sectors
use_SyFile_FILNEW       equ 1   ;Creates a new file and opens it
use_SyFile_FILOPN       equ 1   ;Opens an existing file
use_SyFile_FILCLO       equ 1   ;Closes an opened file
use_SyFile_FILINP       equ 1   ;Reads an amount of bytes out of an opened file
use_SyFile_FILOUT       equ 1   ;Writes an amount of bytes into an opened file
if DRIVER=7
use_SyFile_FILPOI       equ 1   ;Moves the file pointer to another position
else
use_SyFile_FILPOI       equ 0   ;Moves the file pointer to another position
endif
use_SyFile_FILF2T       equ 0   ;Decodes the file timestamp
use_SyFile_FILT2F       equ 0   ;Encodes the file timestamp
use_SyFile_FILLIN       equ 0   ;Reads one text line out of an opened file
use_SyFile_DIRDEV       equ 0   ;Sets the current drive
use_SyFile_DIRPTH       equ 0   ;Sets the current path
use_SyFile_DIRPRS       equ 0   ;Changes a property of a file or a directory
use_SyFile_DIRPRR       equ 0   ;Reads a property of a file or a directory
use_SyFile_DIRREN       equ 0   ;Renames a file or a directory
use_SyFile_DIRNEW       equ 0   ;Creates a new directory
use_SyFile_DIRINP       equ 0   ;Reads the content of a directory
use_SyFile_DIRDEL       equ 0   ;Deletes one or more files
use_SyFile_DIRRMD       equ 0   ;Deletes a sub directory
use_SyFile_DIRMOV       equ 0   ;Moves a file or sub directory
use_SyFile_DIRINF       equ 0   ;Returns information about one drive
use_SyFile_DEVDIR       equ 0   ;Reads the content of a directory (extended)
