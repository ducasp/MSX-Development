;==============================================================================
;  Dmn-Network-libs.asm  -  FLATTENED SymbOS developer libraries
;  From symbos_lib-SystemManager / DesktopManager / FileManager.asm.
;  Only the routines the Network Daemon calls (plus dependencies), guarded by
;  the use_Sy* flags from Dmn-Network-head.asm (restored).  Replaces the three
;  READs of symbos_lib.
;  Routines the daemon defines itself (SySystem_HLP*) are intentionally absent.
;==============================================================================

;### SYSTEM MANAGER ###
if use_SySystem_SendMessage
SySystem_SendMessage
        ld (App_MsgBuf+3),a
SysSMg0 ld (App_MsgBuf+1),hl
        ld (App_MsgBuf+4),de
        ld iy,App_MsgBuf
        ld (iy+0),c
        ld ix,(App_PrcID)
        db #dd:ld h,PRC_ID_SYSTEM
        rst #10
        ret
SySSMg1 ld (App_MsgBuf+6),a
        ld (App_MsgBuf+7),bc
        ld (App_MsgBuf+8),hl
SySSMg2 ld (App_MsgBuf+10),ix
        ld (App_MsgBuf+12),iy
        ret
endif
if use_SySystem_WaitMessage
SySystem_WaitMessage
        ld (App_MsgBuf+3),a
        ld a,c
        add 128
        ld (SySWMsN+1),a
        call SysSMg0
SySWMs0 ld iy,App_MsgBuf
SySWMs1 ld ix,(App_PrcID)
        db #dd:ld h,PRC_ID_SYSTEM
SySWMs2 rst #08             ;wait for a system manager message
        db #dd:dec l
        jr nz,SySWMs1
        ld hl,(App_MsgBuf+0)
SySWMsN ld a,0              ;check, if matching response
        cp l
        ld a,h              ;a=(msgbuf+1)
        ret z
        ld ix,(App_PrcID-1) ;no -> ixl=sender (system), ixh=receiver (me)
        db #dd:ld l,PRC_ID_SYSTEM
        rst #10             ;resend message to myself
        rst #30
        jr SySWMs1
;--- SySystem_LNGLOD
endif
if use_SySystem_LNGLOD
SySystem_LNGLOD
;******************************************************************************
;*** Name           Language_Load
;*** Input          IXL= application's default language ID (usually 9 for english)
;***                IXH= pack
;***                IYL= version
;***                A  = application path bank
;***                DE = application path address
;***                C  = text bank
;***                HL = text address
;*** Output         A  = Success status
;***                     0 -> service not available
;***                     1 -> OK, the required language package has either been
;***                          loaded successfully, or the application's default
;***                          language matches the required language
;***                     2 -> no LNG file found or disc error
;***                     3 -> wrong version or pack number too high
;***                     4 -> language not available
;*** Destroyed      F,BC,DE,HL,IX,IY
;*** Description    Tries to replace the default language of the application with
;***                the alternative language, set by the user in the control panel,
;***                from the application's language pack (*.LNG) file. The path
;***                does not need to contain the exact LNG filename, as the
;***                function always replaces the file extension with "LNG".
;***                Therefore, you can usually just use the application's original
;***                path, which will not change when returning from the function.
;***                The text bank and address must point to the first entry in the
;***                text pointer list, which must be located directly before the
;***                section containing the text strings. Each text pointer is 3
;***                bytes in size. A byte with the value 1, followed by a word that
;***                references the text string. The number of text pointers must
;***                correspond to the number of texts in the respective package.
;***                The package number selects the text package if multiple text
;***                locations exist, whether in different memory areas or in
;***                multiple binaries of the same application. The version number
;***                helps avoid conflicts that can arise if different versions of
;***                the application binary and its language pack file (LNG) are
;***                accidentally present. The application's default language ID is
;***                used to check whether a text exchange is even necessary.
;******************************************************************************
    call SySSMg1
    ld a,(App_BnkNum)
    db #fd:ld h,a
    ld c,MSC_SYS_EXTFNC
    ld l,FNC_DXT_LNGLOD
    jr SySystem_WaitMessage
;--- SySystem_PRGEND
endif
if use_SySystem_PRGEND
SySystem_PRGEND
;******************************************************************************
;*** Name           Program_End_Command
;*** Input          L  = Application ID
;*** Output         -
;*** Destroyed      AF,BC,DE,HL,IX,IY
;*** Description    Stops an application and releases all its used system
;***                resources. This command first stops all processes of the
;***                application. After this all open windows will be closed and the
;***                reserved memory will be released.
;***                Please note, that this command can't release memory, stop
;***                processes and timers or close windows, which are not
;***                registered for the application. Such resources first have
;***                to be released by the application itself.
;******************************************************************************
    ld c,MSC_SYS_PRGEND
    jp SySystem_SendMessage
;--- SySystem_PRGRUN
endif
if use_SySystem_PRGRUN
SySystem_PRGRUN
;******************************************************************************
;*** Name           Program_Run_Command
;*** Input          HL = File path and name address
;***                A  = [Bit0-3] File path and name ram bank (0-15)
;***                     [Bit4  ] Flag, if additional options
;***                     [Bit5  ] Flag, if alternative priority
;***                     [Bit6  ] Flag, if always start as an application
;***                              (ignore file associations)
;***                     [Bit7  ] Flag, if system error message should be
;***                              suppressed
;***                - if alternative priority -
;***                E  = priority (1[high] - 7[low])
;***                - if additional options -
;***                IXL= [Bit0]   Flag, if work directory path available
;***                IXH= Window Mode (0=unchanged, 1=normal, 2=maximized,
;***                                  3=minimized, +128=open window centered)
;***                - if work directory available -
;***                IY = work directory (up to 128bytes including
;***                     0-terminator), same ram bank like file path
;*** Output         A  = Success status
;***                     0 = OK
;***                     1 = File does not exist
;***                     2 = File is not an executable and its type is not
;***                         associated with an application
;***                     3 = Error while loading (see P8 for error code)
;***                     4 = Memory full
;***                - If success status is 0 -
;***                L  = Application ID
;***                H  = Process ID (the applications main process)
;***                - If success status is 3 -
;***                L  = File manager error code
;*** Destroyed      F,BC,DE,IX,IY
;*** Description    Loads and starts an application or opens a document with a
;***                known type by loading the associated application first.
;***                If Bit7 of A is not set, the system will open a message box,
;***                if an error occurs during the loading process.
;***                If the operation was successful, you will find the
;***                application ID and the process ID in L and H. If it failed
;***                because of loading problems L contains the file manager
;***                error code.
;******************************************************************************
    call SySSMg2
    ld c,MSC_SYS_PRGRUN
    call SySystem_WaitMessage
    ld hl,(App_MsgBuf+8)
    ret
;--- SySystem_PRGSRV
endif
if use_SySystem_PRGSRV
SySystem_PRGSRV
;******************************************************************************
;*** Name           Program_SharedService_Command
;*** Input          E  = Command type
;***                     0 = search application or shared service
;***                     1 = search, start and use shared service
;***                     2 = release shared service
;***                - if E is 0 or 1 -
;***                HL = Address of the 12byte application ID string
;***                A  = Ram bank (0-15) of the 12byte application ID string
;***                - if E is 2 -
;***                A  = Application ID of shared service
;*** Output         A  = Result status
;***                     0 = OK
;***                     5 = application or shared service not found (can only
;***                         occur on command type 0)
;***                     1-4=error while starting shared service; same codes
;***                         like in MSR_SYS_PRGRUN, please read there for a
;***                         detailed description
;***                - If command type was 0 or 1, and result status is 0 -
;***                L  = Application ID
;***                H  = Process ID (the applications main process)
;***                - If result status is 3 -
;***                L  = File manager error code
;*** Destroyed      F,BC,DE,IX,IY
;*** Description    This function can be used to find, start and release shared
;***                services or to find applications.
;***                For a detailed description please read chapter "System
;***                Manager", "Program_SharedService_Command" in the SymbOS
;***                Developer Documentation.
;******************************************************************************
    ld c,MSC_SYS_PRGSRV
    call SySystem_WaitMessage
    ld hl,(App_MsgBuf+8)
    ret
;--- SySystem_SYSWRN
endif
if use_SySystem_SELOPN
SySystem_SELOPN
;******************************************************************************
;*** Name           Dialogue_FileSelector_Command
;*** Input          HL = file mask/path/name buffer (#C000-#FFFF, 260 bytes)
;***                A  = [bit0-3] buffer ram bank, [bit6] save, [bit7] directory
;***                C  = attribute filter
;***                IX = max directory entries, IY = max data buffer
;***                DE = caller window data record
;*** Output         A  = 0 selected, 1 aborted, 2 in use, 3 memory full,
;***                     4 no window
;***                - if A=0: the full path is in the buffer at offset 4
;*** Destroyed      F,BC,DE,HL,IX,IY
;******************************************************************************
        ld (SySSOp1+2),de
        call SySSMg1
        call SySSMg2
        ld c,MSC_SYS_SELOPN
        call SySystem_WaitMessage
SySSOp1 ld ix,0
        ld (ix+51),0
        ld hl,(App_MsgBuf+2)
        cp -1
        ret nz
        ld (ix+51),l
        call SySWMs0
        jr SySSOp1
;--- SySystem_SELOPN
endif
if use_SySystem_SYSWRN
SySystem_SYSWRN
;******************************************************************************
;*** Name           Dialogue_Infobox_Command
;*** Input          HL = Content data address (#C000-#FFFF)
;***                A  = Content data ram bank (0-15)
;***                B  = [Bit0-2] Number of buttons (1-3)
;***                              1 = "OK" button
;***                              2 = "Yes", "No" buttons
;***                              3 = "Yes", "No", "Cancel" buttons
;***                     [Bit3-5] Titletext
;***                              0 = default (bit7=[0]"Error!"/[1]"Info")
;***                              1 = "Error!"
;***                              2 = "Info"
;***                              3 = "Warning"
;***                              4 = "Confirmation"
;***                     [Bit6  ] Flag, if window should be modal window
;***                     [Bit7  ] Box type
;***                              0 = default (warning [!] symbol)
;***                              1 = info (own symbol will be used)
;***                DE = 0 or data record of the caller window; the dialogue
;***                     window will be a modal window of it, during its open
;*** Content data   00  1W  Address of text line 1
;***                02  1W  4 * [text line 1 pen] + 2
;***                04  1W  Address of text line 2
;***                06  1W  4 * [text line 2 pen] + 2
;***                08  1W  Address of text line 3
;***                10  1W  4 * [text line 3 pen] + 2
;***                - if B[bit7] is 1 -
;***                12  1W  Address of symbol (24x24px 4col SymbOS graphic format)
;***                        or 0
;***                - if B[bit7] is 1 and P12 is 0 -
;***                14  1W  Address of symbol (24x24px 4col SymbOS graphic format)
;***                16  1W  Address of symbol (24x24px 16col SymbOS graphic format)
;*** Output         A  = Result status
;***                     0 -> The infobox is currently used by another
;***                          application. It can only be opened once at the
;***                          same time, if it's not a pure info message (one
;***                          button, not a modal window). The user should
;***                          close the other infobox first before it can be
;***                          opened again by the application.
;***                     2 -> The user clicked "OK".
;***                     3 -> The user clicked "Yes".
;***                     4 -> The user clicked "No".
;***                     5 -> The user clicked "Cancel" or the close button.
;***                     Please note -> if the alert is no modal window and
;***                              contains only one button, it will always return 0
;*** Destroyed      F,BC,DE,HL,IX,IY
;*** Description    Opens an info, warning or confirm box and displays three line
;***                of text and up to three click buttons.
;***                If Bit7 of B is set to 1, you can specify an own symbol, which
;***                will be showed left to the text. If this bit is not set, a "!"-
;***                warning symbol will be displayed.
;***                If Bit6 of B is set to 1, the window will be opened as a modal
;***                window, and you will receive a message with its window number
;***                (see MSR_SYS_SYSWRN).
;***                Please note, that the content data must always be placed in the
;***                transfer ram area (#C000-#FFFF). The texts itself and the
;***                optional graphic must always be placed inside a 16K (data ram
;***                area).
;***                As the text line pen, you should choose 1, so 6 would be the
;***                correct value.
;***                For more information about the mentioned memory types (data,
;***                transfer) see the "applications" chapter.
;***                For more information about the SymbOS graphic format see the
;***                "desktop manager data records" chapter.
;******************************************************************************
    ld (SySWrnW+2),de
    ld e,b
    ld c,MSC_SYS_SYSWRN
    push bc
    call SySystem_SendMessage
    ld a,MSR_SYS_SYSWRN
    ld (SySWMsN+1),a
    pop af
    and 7+64
    dec a
    ret z
SySWrn1 call SySWMs0
    ld b,a
SySWrnW ld ix,0
    db #dd:ld a,l
    db #dd:or h
    ld c,0
    jr z,SySWrn2
    ld (ix+51),c
    inc c
SySWrn2 ld a,b
    dec b
    ret nz
    dec c
    jr nz,SySWrn1
    ld a,(App_MsgBuf+2)
    ld (ix+51),a
    jr SySWrn1

;### DESKTOP MANAGER ###
endif
if use_SyDesktop_SendMessage
SyDesktop_SendMessage
        ld iy,App_MsgBuf
        ld b,a
        ld (App_MsgBuf+0),bc
        ld (App_MsgBuf+2),de
        ld (App_MsgBuf+4),hl
        db #dd:ld h,PRC_ID_DESKTOP
        ld a,(App_PrcID)
        db #dd:ld l,a
        rst #10
        ret
endif
if use_SyDesktop_WaitMessage
SyDesktop_WaitMessage
        ld iy,App_MsgBuf
SyDWMs1 db #dd:ld h,PRC_ID_DESKTOP
        ld a,(App_PrcID)
        db #dd:ld l,a
        rst #08             ;wait for a desktop manager message
        db #dd:dec l
        jr nz,SyDWMs1
        ld a,(App_MsgBuf+0)
        ret
;--- SyDesktop_STIADD
endif
if use_SyDesktop_STIADD
SyDesktop_STIADD
;******************************************************************************
;*** Name           SystrayIcon_Add_Command
;*** Input          DE = Icon address
;***                A  = Icon ram bank (0-15)
;***                L  = click code
;*** Output         CF = status (0=ok, 1=no more slot available)
;***                - if CF is 0 -
;***                A  = Icon ID
;*** Destroyed      AF,BC,DE,HL,IX,IY
;*** Description    Adds a systray icon to the task bar. These can be clicked
;***                by the user, which will generate an event sent to the
;***                application by the desktop manager (see MSR_DSK_EVTCLK).
;***                The icon is a 8x8 pixel SymbOS standard graphic (see
;***                SymbOS-DesktopDataRecords.txt, Graphics, "Standard graphics").
;***                L defines the click code, which is sent to the application
;***                as the MSR_DSK_EVTCLK event, if the user clicks the systray
;***                icon.
;***                After a systray icon has been added successfully you will
;***                receive its ID in A. This ID has to be used when removing
;***                the icon later again (see use_SyDesktop_STIREM below).
;******************************************************************************
    ld c,MSC_DSK_STIADD
    ld b,a
    ld a,(App_PrcID)
    ld h,a
    ld a,b
    call SyDesktop_SendMessage
SyDTry1 call SyDesktop_WaitMessage
    cp MSR_DSK_STIADD
    jr nz,SyDTry1
    ld hl,(App_MsgBuf+1)
    push hl
    pop af
    ret
;--- SyDesktop_STIREM
endif
if use_SyDesktop_STIREM
SyDesktop_STIREM
;******************************************************************************
;*** Name           SystrayIcon_Remove_Command
;*** Input          A  = Icon ID
;*** Output         -
;*** Destroyed      AF,BC,DE,HL,IX,IY
;*** Description    Removes a systray icon from the task bar. You have to specify
;***                its ID which you received when adding the icon.
;******************************************************************************
    ld c,MSC_DSK_STIREM
    jp SyDesktop_SendMessage
;--- SyDesktop_WINCLS
endif
if use_SyDesktop_WINCLS
SyDesktop_WINCLS
;******************************************************************************
;*** Name           Window_Close_Command
;*** Input          A  = Window ID
;*** Output         -
;*** Destroyed      AF,BC,DE,HL,IX,IY
;*** Limitation     works always
;*** Description    Closes the window. The desktop manager will remove it from the
;***                screen.
;***                If the window is a modal window, this will remove the
;***                references from the parent windows as well.
;******************************************************************************
    ld c,MSC_DSK_WINCLS
    jp SyDesktop_SendMessage
;--- SyDesktop_WINDIN
endif
if use_SyDesktop_WINDIN
SyDesktop_WINDIN
;******************************************************************************
;*** Name           Window_Redraw_ContentExtended_Command
;*** Input          A  = Window ID
;***                E  = -1, control ID or negative number of controls
;***                     000 - 239 -> the control with the specified ID will be
;***                                  redrawed.
;***                     240 - 254 -> redraws -E controls, starting from
;***                                  control D. As an example, if E is -3
;***                                  (253) and D is 5, the controls 5, 6 and 7
;***                                  will be redrawed.
;***                     255       -> redraws all controls inside the window
;***                                  content.
;***                - if E is between 240 and 254 -
;***                D = ID of the first control, which should be redrawed.
;*** Output         -
;*** Destroyed      AF,BC,DE,HL,IX,IY
;*** Limitation     works always
;*** Description    Redraws one, all or a specified number of controls inside the
;***                window content. This command is identical with MSC_DSK_WININH
;***                with the exception, that it always works but with less speed.
;***                For more information see MSC_DSK_WININH.
;******************************************************************************
    ld c,MSC_DSK_WINDIN
    jp SyDesktop_SendMessage
;--- SyDesktop_WININH
endif
if use_SyDesktop_WININH
SyDesktop_WININH
;******************************************************************************
;*** Name           Window_Redraw_Content_Command
;*** Input          A  = Window ID
;***                E  = -1, control ID or negative number of controls
;***                     000 - 239 -> the control with the specified ID will be
;***                                  redrawed.
;***                     240 - 254 -> redraws -E controls, starting from
;***                                  control D. As an example, if E is -3
;***                                  (253) and D is 5, the controls 5, 6 and 7
;***                                  will be redrawed.
;***                     255       -> redraws all controls inside the window
;***                                  content.
;***                - if E is between 240 and 254 -
;***                D = ID of the first control, which should be redrawed.
;*** Output         -
;*** Destroyed      AF,BC,DE,HL,IX,IY
;*** Limitation     works only, if window has focus
;*** Description    Redraws one, all or a specified number of controls inside the
;***                window content. This command is very important, if you make
;***                changes and want to display them.
;***                This command is identical with MSC_DSK_WINDIN with the
;***                exception, that it only works, if the window has focus. Because
;***                of this, it is a little bit faster, as the desktop manager
;***                doesn't need to take care about other windows, which could hide
;***                some parts of the window.
;******************************************************************************
    ld c,MSC_DSK_WININH
    jp SyDesktop_SendMessage
;--- SyDesktop_WINOPN
endif
if use_SyDesktop_WINOPN
SyDesktop_WINOPN
;******************************************************************************
;*** Name           Window_Open_Command
;*** Input          A  = Window data record ram bank (0-15)
;***                DE = Window data record address (#C000-#FFFF)
;*** Output         A  = Window ID (only, if CF=0)
;***                CF = Success status
;***                     0 = OK
;***                     1 = window couldn't be opened, as the maximum number
;***                         of windows (32) has been reached
;*** Destroyed      BC,DE,HL,IX,IY
;*** Description    Opens a new window. Its data record must be placed in the
;***                transfer ram area (between #c000 and #ffff).
;***                For more information about the window data record see the
;***                chapter "desktop manager data records".
;***                For more information about the transfer ram memory types see
;***                the "applications" chapter.
;******************************************************************************
    ld b,a
    db #dd:ld l,e
    db #dd:ld h,d
    ld a,(App_PrcID)    ;register window for the application process
    ld (ix+3),a
    ld a,b
    ld c,MSC_DSK_WINOPN
    call SyDesktop_SendMessage
SyWOpn1 call SyDesktop_WaitMessage
    cp MSR_DSK_WOPNER
    scf
    ret z               ;return with set carry flag, if window couldn't be opened
    cp MSR_DSK_WOPNOK
    jr nz,SyWOpn1       ;different message than "open ok" -> continue waiting
    ld a,(App_MsgBuf+4) ;get window ID and return with cleared carry flag
    ret
;--- SyDesktop_WINTOP
endif
if use_SyDesktop_WINTOP
SyDesktop_WINTOP
;******************************************************************************
;*** Name           Window_Focus_Command
;*** Input          A  = Window ID
;*** Output         -
;*** Destroyed      AF,BC,DE,HL,IX,IY
;*** Limitation     works always
;*** Description    Takes the window to the front position on the screen.
;******************************************************************************
    ld c,MSC_DSK_WINTOP
    jp SyDesktop_SendMessage

;### FILE MANAGER ###
endif
if use_SySystem_CallFunction
SySystem_CallFunction
        ld (App_MsgBuf+04),bc   ;copy registers into the message buffer
        ld (App_MsgBuf+06),de
        ld (App_MsgBuf+08),hl
        ld (App_MsgBuf+10),ix
        ld (App_MsgBuf+12),iy
        push af
        pop hl
        ld (App_MsgBuf+02),hl
        pop hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
        ld (App_MsgBuf+00),de   ;module und funktion number
        ld a,e
        ld (SyCallN+1),a
        ld iy,App_MsgBuf
        ld ix,(App_PrcID)
        db #dd:ld h,PRC_ID_SYSTEM
SyCall0 rst #10                 ;send message
        ld iy,App_MsgBuf
SyCall1 ld ix,(App_PrcID)
        db #dd:ld h,PRC_ID_SYSTEM
        rst #08                 ;wait for answer
        db #dd:dec l
        jr nz,SyCall1
        ld a,(App_MsgBuf)
        sub 128
SyCallN cp 0
        jr z,SyCall2
        ld ix,(App_PrcID-1)     ;ixh=receiver (my process)
        db #dd:ld l,PRC_ID_SYSTEM    ;ixl=sender (system process)
        rst #10
        rst #30
        jr SyCall1              ;resend message again, if it's not the expected one
SyCall2 ld hl,(App_MsgBuf+02)   ;get registers out of the message buffer
        push hl
        pop af
        ld bc,(App_MsgBuf+04)
        ld de,(App_MsgBuf+06)
        ld hl,(App_MsgBuf+08)
        ld ix,(App_MsgBuf+10)
        ld iy,(App_MsgBuf+12)
        ret
;--- SyFile_FILCLO
endif
if use_SyFile_FILCLO
SyFile_FILCLO
;******************************************************************************
;*** Name           File_Close
;*** Input          A    = Filehandler ID
;*** Output         CF   = Error state (0 = ok, 1 = error; A = error code)
;*** Destroyed      AF,BC,DE,HL,IX,IY
;*** Description    Closes an opened file. If there is unwritten data in the sector
;***                cache, it will be written to disc at once.
;***                This command closes a file in any case, even if an error
;***                occured.
;***                If an error occured during file reading/writing you must close
;***                the file, too, to have the filehandler free again!
;******************************************************************************
    call SySystem_CallFunction
    db MSC_SYS_SYSFIL
    db FNC_FIL_FILCLO
    ret
;--- SyFile_FILINP
endif
if use_SyFile_FILINP
SyFile_FILINP
;******************************************************************************
;*** Name           File_Input
;*** Input          A    = Filehandler ID
;***                HL   = Destination address
;***                E    = Destination ram bank (0-15)
;***                BC   = Number of bytes
;*** Output         BC   = Number of read bytes
;***                ZF   = 1 -> All requested bytes have been read
;***                       0 -> The end of the file has been reached, and less
;***                            bytes than requested have been read (check BC)
;***                CF   = Error state (0 = ok, 1 = error; A = error code)
;*** Destroyed      AF,DE,HL,IX,IY
;*** Description    Reads a specified amount of bytes out of an opened file. After
;***                this operation the file pointer will be moved behind the last
;***                read byte. This means, that it is possible to read several
;***                blocks with different sizes out of an opened file. It doesn't
;***                matter, if you already did write operations, too.
;***                If you try to read more bytes than available, the zero flag
;***                will be reset. In any case BC contains the amount of read
;***                bytes.
;******************************************************************************
    call SySystem_CallFunction
    db MSC_SYS_SYSFIL
    db FNC_FIL_FILINP
    ret
;--- SyFile_FILNEW
endif
if use_SyFile_FILNEW
SyFile_FILNEW
;******************************************************************************
;*** Name           File_New
;*** Input          IXH  = File path and name ram bank (0-15)
;***                HL   = File path and name address
;***                A    = Attributes
;***                       Bit0 = 1 -> Read only
;***                       Bit1 = 1 -> Hidden
;***                       Bit2 = 1 -> System
;***                       Bit5 = 1 -> Archive
;*** Output         A    = Filehandler ID
;***                CF   = Error state (0 = ok, 1 = error; A = error code)
;*** Destroyed      F,BC,DE,HL,IX,IY
;*** Description    Creates a new file and opens it for read/write access. If the
;***                file was already existing, it will be emptied first. For
;***                additional information see 018 (FILOPN).
;******************************************************************************
    call SySystem_CallFunction
    db MSC_SYS_SYSFIL
    db FNC_FIL_FILNEW
    ret
;--- SyFile_FILOPN
endif
if use_SyFile_FILOPN
SyFile_FILOPN
;******************************************************************************
;*** Name           File_Open
;*** Input          IXH  = File path and name ram bank (0-15)
;***                HL   = File path and name address
;*** Output         A    = Filehandler ID
;***                CF   = Error state (0 = ok, 1 = error; A = error code)
;*** Destroyed      F,BC,DE,HL,IX,IY
;*** Description    Opens an existing file for read/write access. This means, that
;***                you can read and write in the file like you want. You can open
;***                up to 8 different files at the same time.
;***                For more information about the file path see the introduction
;***                of the DIRECTORY MANAGEMENT FUNCTIONS.
;***                The media will be reloaded first, if the device is set to
;***                "removeable media" and there is no other open file on the same
;***                device.
;******************************************************************************
    call SySystem_CallFunction
    db MSC_SYS_SYSFIL
    db FNC_FIL_FILOPN
    ret
;--- SyFile_FILOUT
endif
if use_SyFile_FILPOI
SyFile_FILPOI
;******************************************************************************
;*** Name           File_Pointer
;*** Input          A    = Filehandler ID
;***                IY,IX= Difference
;***                C    = Reference point (0=begin, 1=current, 2=end)
;*** Output         IY,IX= new absolute pointer position
;***                CF   = Error state (0 = ok, 1 = error; A = error code)
;*** Destroyed      AF,BC,DE,HL
;*** Description    Moves the file pointer; with C=2 and IY,IX=0 it returns the
;***                file length in IY,IX (exact on FAT).
;******************************************************************************
    call SySystem_CallFunction
    db MSC_SYS_SYSFIL
    db FNC_FIL_FILPOI
    ret
;--- SyFile_FILPOI
endif
if use_SyFile_FILOUT
SyFile_FILOUT
;******************************************************************************
;*** Name           File_Output
;*** Input          A    = Filehandler ID
;***                HL   = Source address
;***                E    = Source ram bank (0-15)
;***                BC   = Number of bytes
;*** Output         BC   = Number of written bytes
;***                A    = 0 -> All bytes have been written
;***                       1 -> The device is full, and less bytes have been
;***                            written (check BC)
;***                CF   = Error state (0 = ok, 1 = error; A = error code)
;*** Destroyed      AF,DE,HL,IX,IY
;*** Description    Writes a specified amount of bytes into an opened file. After
;***                this operation the file pointer will be moved behind the last
;***                written byte. If the file pointer has been somewhere in the
;***                middle of the file before this operation, the data at this
;***                place will be overwritten. If you have been at the end of the
;***                file, its length will be extended.
;***                You can write several blocks with different sizes, and it
;***                doesn't matter if you already read from the file before.
;***                It's possible, that not all bytes have been written, if the
;***                device is full. Register A will be 1 in this case. In any case
;***                BC contains the amount of written bytes.
;******************************************************************************
    call SySystem_CallFunction
    db MSC_SYS_SYSFIL
    db FNC_FIL_FILOUT
    ret

endif