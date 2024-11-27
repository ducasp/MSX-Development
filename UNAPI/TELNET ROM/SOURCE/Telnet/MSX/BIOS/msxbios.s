;----------------------------------------------------------
;----------------------------------------------------------
;		msxbios.s - by Danilo Angelo 2020-2023
;		Adapted from http://www.konamiman.com/msx/msx2th/th-ap.txt
;		230221: added BDOS system calls, from http://www.msxtop.msxall.com/Docs/MSXTopSecret2Continuo.pdf
;
;		Standard MSX variables and routines addresses
;----------------------------------------------------------

; --- system variables ---
BIOS_HWVER	.equ 0x002d

; --- main bios calls ---
BIOS_CHKRAM  .equ 0x0000
BIOS_SYNCHR  .equ 0x0008
BIOS_RDSLT   .equ 0x000c
BIOS_CHRGTR  .equ 0x0010
BIOS_WRSLT   .equ 0x0014
BIOS_OUTDO   .equ 0x0018
BIOS_CALSLT  .equ 0x001c
BIOS_DCOMPR  .equ 0x0020
BIOS_ENASLT  .equ 0x0024
BIOS_GETYPR  .equ 0x0028
BIOS_CALLF   .equ 0x0030
BIOS_KEYINT  .equ 0x0038

; I/O initialisation
BIOS_INITIO  .equ 0x003b
BIOS_INIFNK  .equ 0x003e

; VDP access
BIOS_VDPDR   .equ 0x0006
BIOS_VDPDW   .equ 0x0007
BIOS_DISSCR  .equ 0x0041
BIOS_ENASCR  .equ 0x0044
BIOS_WRTVDP  .equ 0x0047
BIOS_RDVRM   .equ 0x004a
BIOS_WRTVRM  .equ 0x004d
BIOS_SETRD   .equ 0x0050
BIOS_SETWRT  .equ 0x0053
BIOS_FILVRM  .equ 0x0056
BIOS_LDIRMV  .equ 0x0059
BIOS_LDIRVM  .equ 0x005c
BIOS_CHGMOD  .equ 0x005f
BIOS_CHGCLR  .equ 0x0062
BIOS_NMI     .equ 0x0066
BIOS_CLRSPR  .equ 0x0069
BIOS_INITXT  .equ 0x006c
BIOS_INIT32  .equ 0x006f
BIOS_INIGRP  .equ 0x0072
BIOS_INIMLT  .equ 0x0075
BIOS_SETTXT  .equ 0x0078
BIOS_SETT32  .equ 0x007b
BIOS_SETGRP  .equ 0x007e
BIOS_SETMLT  .equ 0x0081
BIOS_CALPAT  .equ 0x0084
BIOS_CALATR  .equ 0x0087
BIOS_GSPSIZ  .equ 0x008a
BIOS_GRPPRT  .equ 0x008d

; PSG
BIOS_GICINI  .equ 0x0090
BIOS_WRTPSG  .equ 0x0093
BIOS_RDPSG   .equ 0x0096
BIOS_STRTMS  .equ 0x0099

; Keyboard, CRT, printer input-output
BIOS_CHSNS   .equ 0x009c
BIOS_CHGET   .equ 0x009f
BIOS_CHPUT   .equ 0x00a2
BIOS_LPTOUT  .equ 0x00a5
BIOS_LPTSTT  .equ 0x00a8
BIOS_CNVCHR  .equ 0x00ab
BIOS_PINLIN  .equ 0x00ae
BIOS_INLIN   .equ 0x00b1
BIOS_QINLIN  .equ 0x00b4
BIOS_BREAKX  .equ 0x00b7
BIOS_BEEP    .equ 0x00c0
BIOS_CLS     .equ 0x00c3
BIOS_POSIT   .equ 0x00c6
BIOS_FNKSB   .equ 0x00c9
BIOS_ERAFNK  .equ 0x00cc
BIOS_DSPFNK  .equ 0x00cf
BIOS_TOTEXT  .equ 0x00d2

; Game I/O access
BIOS_GTSTCK  .equ 0x00d5
BIOS_GTTRIG  .equ 0x00d8
BIOS_GTPAD   .equ 0x00db
BIOS_GTPDL   .equ 0x00de

; Cassette input-output routine
BIOS_TAPION  .equ 0x00e1
BIOS_TAPIN   .equ 0x00e4
BIOS_TAPIOF  .equ 0x00e7
BIOS_TAPOON  .equ 0x00ea
BIOS_TAPOUT  .equ 0x00ed
BIOS_TAPOOF  .equ 0x00f0
BIOS_STMOTR  .equ 0x00f3

; Miscellaneous
BIOS_CHGCAP  .equ 0x0132
BIOS_CHGSND  .equ 0x0135
BIOS_RSLREG  .equ 0x0138
BIOS_WSLREG  .equ 0x013b
BIOS_RDVDP   .equ 0x013e
BIOS_SNSMAT  .equ 0x0141
BIOS_PHYDIO  .equ 0x0144
BIOS_ISFLIO  .equ 0x014a
BIOS_OUTDLP  .equ 0x014d
BIOS_KILBUF  .equ 0x0156
BIOS_CALBAS  .equ 0x0159

; Entries appended for MSX2
BIOS_SUBROM  .equ 0x015c
BIOS_EXTROM  .equ 0x015f
BIOS_EOL     .equ 0x0168
BIOS_NSETRD  .equ 0x016e
BIOS_NSTWRT  .equ 0x0171
BIOS_NRDVRM  .equ 0x0174
BIOS_NWRVRM  .equ 0x0177

; --- subrom bios calls ---
BIOS_GRPRT   .equ 0x0089
BIOS_NVBXLN  .equ 0x00c9
BIOS_NVBXFL  .equ 0x00cd
BIOS_CLSSUB  .equ 0x0115
BIOS_VDPSTA  .equ 0x0131
BIOS_SETPAG  .equ 0x013d
BIOS_INIPLT  .equ 0x0141
BIOS_RSTPLT  .equ 0x0145
BIOS_GETPLT  .equ 0x0149
BIOS_SETPLT  .equ 0x014d
BIOS_PROMPT  .equ 0x0181
BIOS_NEWPAD  .equ 0x01ad
BIOS_CHGMDP  .equ 0x01b5
BIOS_KNJPRT  .equ 0x01bd
BIOS_REDCLK  .equ 0x01f5
BIOS_WRTCLK  .equ 0x01f9

; --- work area ---
BIOS_RDPRIM  .equ 0xf380
BIOS_WRPRIM  .equ 0xf385
BIOS_CLPRIM  .equ 0xf38c

; Starting address of assembly language program of USR function, text screen
BIOS_USRTAB  .equ 0xf39a
BIOS_LINL40  .equ 0xf3ae
BIOS_LINL32  .equ 0xf3af
BIOS_LINLEN  .equ 0xf3b0
BIOS_CRTCNT  .equ 0xf3b1
BIOS_CLMLST  .equ 0xf3b2

; SCREEN 0
BIOS_TXTNAM  .equ 0xf3b3
BIOS_TXTCOL  .equ 0xf3b5
BIOS_TXTCGP  .equ 0xf3b7
BIOS_TXTATR  .equ 0xf3b9
BIOS_TXTPAT  .equ 0xf3bb

; SCREEN 1
BIOS_T32NAM  .equ 0xf3bd
BIOS_T32COL  .equ 0xf3bf
BIOS_T32CGP  .equ 0xf3c1
BIOS_T32ATR  .equ 0xf3c3
BIOS_T32PAT  .equ 0xf3c5

; SCREEN 2
BIOS_GRPNAM  .equ 0xf3c7
BIOS_GRPCOL  .equ 0xf3c9
BIOS_GRPCGP  .equ 0xf3cb
BIOS_GRPATR  .equ 0xf3cd
BIOS_GRPPAT  .equ 0xf3cf

; SCREEN 3
BIOS_MLTNAM  .equ 0xf3d1
BIOS_MLTCOL  .equ 0xf3d3
BIOS_MLTCGP  .equ 0xf3d5
BIOS_MLTATR  .equ 0xf3d7
BIOS_MLTPAT  .equ 0xf3d9

; Other screen settings
BIOS_CLIKSW  .equ 0xf3db
BIOS_CSRY    .equ 0xf3dc
BIOS_CSRX    .equ 0xf3dd
BIOS_CNSDFG  .equ 0xf3de

; Area to save VDP registers
BIOS_RG0SAV  .equ 0xf3df
BIOS_RG1SAV  .equ 0xf3e0
BIOS_RG2SAV  .equ 0xf3e1
BIOS_RG3SAV  .equ 0xf3e2
BIOS_RG4SAV  .equ 0xf3e3
BIOS_RG5SAV  .equ 0xf3e4
BIOS_RG6SAV  .equ 0xf3e5
BIOS_RG7SAV  .equ 0xf3e6
BIOS_RG8SAV  .equ 0xffe7
BIOS_RG9SAV  .equ 0xffe8
BIOS_STATFL  .equ 0xf3e7
BIOS_TRGFLG  .equ 0xf3e8
BIOS_FORCLR  .equ 0xf3e9
BIOS_BAKCLR  .equ 0xf3ea
BIOS_BDRCLR  .equ 0xf3eb
BIOS_MAXUPD  .equ 0xf3ec
BIOS_MINUPD  .equ 0xf3ef
BIOS_ATRBYT  .equ 0xf3f2

; Work area for PLAY statement
BIOS_QUEUES  .equ 0xf3f3
BIOS_FRCNEW  .equ 0xf3f5

; Work area for key input
BIOS_SCNCNT  .equ 0xf3f6
BIOS_REPCNT  .equ 0xf3f7
BIOS_PUTPNT  .equ 0xf3f8
BIOS_GETPNT  .equ 0xf3fa

; Parameters for Cassette
BIOS_CS120   .equ 0xf3fc
BIOS_LOW     .equ 0xf406
BIOS_HIGH    .equ 0xf408
BIOS_HEADER  .equ 0xf40a
BIOS_ASPCT1  .equ 0xf40b
BIOS_ASPCT2  .equ 0xf40d
BIOS_ENDPRG  .equ 0xf40f

; Work used by BASIC internally
BIOS_ERRFLG  .equ 0xf414
BIOS_LPTPOS  .equ 0xf415
BIOS_PRTFLG  .equ 0xf416
BIOS_NTMSXP  .equ 0xf417
BIOS_RAWPRT  .equ 0xf418
BIOS_VLZADR  .equ 0xf419
BIOS_VLZDAT  .equ 0xf41b
BIOS_CURLIN  .equ 0xf41c
BIOS_KBUF    .equ 0xf41f
BIOS_BUFMIN  .equ 0xf55d
BIOS_BUF     .equ 0xf55e
BIOS_ENDBUF  .equ 0xf660
BIOS_TTYPOS  .equ 0xf661
BIOS_DIMFLG  .equ 0xf662
BIOS_VALTYP  .equ 0xf663
BIOS_DORES   .equ 0xf664
BIOS_DONUM   .equ 0xf665
BIOS_CONTXT  .equ 0xf666
BIOS_CONSAV  .equ 0xf668
BIOS_CONTYP  .equ 0xf669
BIOS_CONLO   .equ 0xf66a
BIOS_MEMSIZ  .equ 0xf672
BIOS_STKTOP  .equ 0xf674
BIOS_TXTTAB  .equ 0xf676
BIOS_TEMPPT  .equ 0xf768
BIOS_TEMPST  .equ 0xf67a
BIOS_DSCTMP  .equ 0xf698
BIOS_FRETOP  .equ 0xf69b
BIOS_TEMP3   .equ 0xf69d
BIOS_TEMP8   .equ 0xf69f
BIOS_ENDFOR  .equ 0xf6a1
BIOS_SUBFLG  .equ 0xf6a5
BIOS_FLGINP  .equ 0xf6a6
BIOS_TEMP    .equ 0xf6a7
BIOS_PTRFLG  .equ 0xf6a9
BIOS_AUTFLG  .equ 0xf6aa
BIOS_AUTLIN  .equ 0xf6ab
BIOS_AUTINC  .equ 0xf6ad
BIOS_SAVTXT  .equ 0xf6af
BIOS_ERRLIN  .equ 0xf6b3
BIOS_DOT     .equ 0xf6b5
BIOS_ERRTXT  .equ 0xf6b7
BIOS_ONELIN  .equ 0xf6b9
BIOS_ONEFLG  .equ 0xf6bb
BIOS_TEMP2   .equ 0xf6bc
BIOS_OLDLIN  .equ 0xf6be
BIOS_OLDTXT  .equ 0xf6c0
BIOS_VARTAB  .equ 0xf6c2
BIOS_ARYTAB  .equ 0xf6c4
BIOS_STREND  .equ 0xf6c6
BIOS_DATPTR  .equ 0xf6c8
BIOS_DEFTBL  .equ 0xf6ca
BIOS_PRMSTK  .equ 0xf6e4
BIOS_PRMLEN  .equ 0xf6e6
BIOS_PARM1   .equ 0xf6e8
BIOS_PRMPRV  .equ 0xf74c
BIOS_PRMLN2  .equ 0xf74e
BIOS_PARM2   .equ 0xf750
BIOS_PRMFLG  .equ 0xf7b4
BIOS_ARYTA2  .equ 0xf7b5
BIOS_NOFUNS  .equ 0xf7b7
BIOS_TEMP9   .equ 0xf7b8
BIOS_FUNACT  .equ 0xf7ba
BIOS_SWPTMP  .equ 0xf7bc
BIOS_TRCFLG  .equ 0xf7c4

; Work for Math-Pack
BIOS_FBUFFR  .equ 0xf7c5
BIOS_DECTMP  .equ 0xf7f0
BIOS_DECTM2  .equ 0xf7f2
BIOS_DECCNT  .equ 0xf7f4
BIOS_DAC     .equ 0xf7f6
BIOS_HOLD8   .equ 0xf806
BIOS_HOLD2   .equ 0xf836
BIOS_HOLD    .equ 0xf83e
BIOS_ARG     .equ 0xf847
BIOS_RNDX    .equ 0xf857

; Interface with BASIC USR Command
BIOS_USRDATA .equ 0xf7f8

; Data area used by BASIC interpreter
BIOS_MAXFIL  .equ 0xf85f
BIOS_FILTAB  .equ 0xf860
BIOS_NULBUF  .equ 0xf862
BIOS_PTRFIL  .equ 0xf864
BIOS_RUNFLG  .equ 0xf866
BIOS_FILNAM  .equ 0xf866
BIOS_FILNM2  .equ 0xf871
BIOS_NLONLY  .equ 0xf87c
BIOS_SAVEND  .equ 0xf87d
BIOS_FNKSTR  .equ 0xf87f
BIOS_CGPNT   .equ 0xf91f
BIOS_NAMBAS  .equ 0xf922
BIOS_CGPBAS  .equ 0xf924
BIOS_PATBAS  .equ 0xf926
BIOS_ATRBAS  .equ 0xf928
BIOS_CLOC    .equ 0xf92a
BIOS_CMASK   .equ 0xf92c
BIOS_MINDEL  .equ 0xf92d
BIOS_MAXDEL  .equ 0xf92f

; Data area used by CIRCLE statement
BIOS_ASPECT  .equ 0xf931
BIOS_CENCNT  .equ 0xf933
BIOS_CLINEF  .equ 0xf935
BIOS_CNPNTS  .equ 0xf936
BIOS_CPLOTF  .equ 0xf938
BIOS_CPCNT   .equ 0xf939
BIOS_CPNCNT8 .equ 0xf93b
BIOS_CPCSUM  .equ 0xf93d
BIOS_CSTCNT  .equ 0xf93f
BIOS_CSCLXY  .equ 0xf941
BIOS_CSAVEA  .equ 0xf942
BIOS_CSAVEM  .equ 0xf944
BIOS_CXOFF   .equ 0xf945
BIOS_CYOFF   .equ 0xf947

; Data area used in PAINT statement
BIOS_LOHMSK  .equ 0xf949
BIOS_LOHDIR  .equ 0xf94a
BIOS_LOHADR  .equ 0xf94b
BIOS_LOHCNT  .equ 0xf94d
BIOS_SKPCNT  .equ 0xf94f
BIOS_MIVCNT  .equ 0xf951
BIOS_PDIREC  .equ 0xf953
BIOS_LFPROG  .equ 0xf954
BIOS_RTPROG  .equ 0xf955

; Data area used in PLAY statement
BIOS_MCLTAB  .equ 0xf956
BIOS_MCLFLG  .equ 0xf958
BIOS_QUETAB  .equ 0xf959
BIOS_QUEBAK  .equ 0xf971
BIOS_VOICAQ  .equ 0xf975
BIOS_VOICBQ  .equ 0xf9f5
BIOS_VOICCQ  .equ 0xfa75

; Work area added in MSX2
BIOS_DPPAGE  .equ 0xfaf5
BIOS_ACPAGE  .equ 0xfaf6
BIOS_AVCSAV  .equ 0xfaf7
BIOS_EXBRSA  .equ 0xfaf8
BIOS_CHRCNT  .equ 0xfaf9
BIOS_ROMA    .equ 0xfafa
BIOS_MODE    .equ 0xfafc
BIOS_NORUSE  .equ 0xfafd
BIOS_XSAVE   .equ 0xfafe
BIOS_YSAVE   .equ 0xfb00
BIOS_LOGOPR  .equ 0xfb02

; Data area used by RS-232C
BIOS_RSTMP   .equ 0xfb03
BIOS_TOCNT   .equ 0xfb03
BIOS_RSFCB   .equ 0xfb04
BIOS_RSIQLN  .equ 0xfb06
BIOS_MEXBIH  .equ 0xfb07
BIOS_OLDSTT  .equ 0xfb0c
BIOS_OLDINT  .equ 0xfb12
BIOS_DEVNUM  .equ 0xfb17
BIOS_DATCNT  .equ 0xfb18
BIOS_ERRORS  .equ 0xfb1b
BIOS_FLAGS   .equ 0xfb1c
BIOS_ESTBLS  .equ 0xfb1d
BIOS_COMMSK  .equ 0xfb1e
BIOS_LSTCOM  .equ 0xfb1f
BIOS_LSTMOD  .equ 0xfb20

; Data area used by PLAY statement
BIOS_PRSCNT  .equ 0xfb35
BIOS_SAVSP   .equ 0xfb36
BIOS_VOICEN  .equ 0xfb38
BIOS_SAVVOL  .equ 0xfb39
BIOS_MCLLEN  .equ 0xfb3b
BIOS_MCLPTR  .equ 0xfb3c
BIOS_QUEUEN  .equ 0xfb3e
BIOS_MUSICF  .equ 0xfc3f
BIOS_PLYCNT  .equ 0xfb40

; Voice static data area
BIOS_VCBA    .equ 0xfb41
BIOS_VCBB    .equ 0xfb66
BIOS_VCBC    .equ 0xfb8b

; Data area
BIOS_ENSTOP  .equ 0xfbb0
BIOS_BASROM  .equ 0xfbb1
BIOS_LINTTB  .equ 0xfbb2
BIOS_FSTPOS  .equ 0xfbca
BIOS_CODSAV  .equ 0xfbcc
BIOS_FNKSW1  .equ 0xfbcd
BIOS_FNKFLG  .equ 0xfbce
BIOS_ONGSBF  .equ 0xfbd8
BIOS_CLIKFL  .equ 0xfbd9
BIOS_OLDKEY  .equ 0xfbda
BIOS_NEWKEY  .equ 0xfbe5
BIOS_KEYBUF  .equ 0xfbf0
BIOS_LINWRK  .equ 0xfc18
BIOS_PATWRK  .equ 0xfc40
BIOS_BOTTOM  .equ 0xfc48
BIOS_HIMEM   .equ 0xfc4a
BIOS_TRAPTBL .equ 0xfc4c
BIOS_RTYCNT  .equ 0xfc9a
BIOS_INTFLG  .equ 0xfc9b
BIOS_PADY    .equ 0xfc9c
BIOS_PADX    .equ 0xfc9d
BIOS_JIFFY   .equ 0xfc9e
BIOS_INTVAL  .equ 0xfca0
BIOS_INTCNT  .equ 0xfca2
BIOS_LOWLIM  .equ 0xfca4
BIOS_WINWID  .equ 0xfca5
BIOS_GRPHED  .equ 0xfca6
BIOS_ESCCNT  .equ 0xfca7
BIOS_INSFLG  .equ 0xfca8
BIOS_CSRSW   .equ 0xfca9
BIOS_CSTYLE  .equ 0xfcaa
BIOS_CAPST   .equ 0xfcab
BIOS_KANAST  .equ 0xfcac
BIOS_KANAMD  .equ 0xfcad
BIOS_FLBMEM  .equ 0xfcae
BIOS_SCRMOD  .equ 0xfcaf
BIOS_OLDSCR  .equ 0xfcb0
BIOS_CASPRV  .equ 0xfcb1
BIOS_BRDATR  .equ 0xfcb2
BIOS_GXPOS   .equ 0xfcb3
BIOS_GYPOS   .equ 0xfcb5
BIOS_GRPACX  .equ 0xfcb7
BIOS_GRPACY  .equ 0xfcb9
BIOS_DRWFLG  .equ 0xfcbb
BIOS_DRWSCL  .equ 0xfcbc
BIOS_DRWANG  .equ 0xfcbd
BIOS_RUNBNF  .equ 0xfcbe
BIOS_SAVENT  .equ 0xfcbf
BIOS_ROMSLT  .equ 0xfcc0
BIOS_EXPTBL  .equ 0xfcc1
BIOS_SLTTBL  .equ 0xfcc5
BIOS_SLTATR  .equ 0xfcc9
BIOS_SLTWRK  .equ 0xfd09
BIOS_PROCNM  .equ 0xfd89
BIOS_DEVICE  .equ 0xfd99

; Hooks
BIOS_H_KEYI  .equ 0xfd9a
BIOS_H_TIMI  .equ 0xfd9f
BIOS_H_CHPH  .equ 0xfda4
BIOS_H_DSPC  .equ 0xfda9
BIOS_H_ERAC  .equ 0xfdae
BIOS_H_DSPF  .equ 0xfdb3
BIOS_H_ERAF  .equ 0xfdb8
BIOS_H_TOTE  .equ 0xfdbd
BIOS_H_CHGE  .equ 0xfdc2
BIOS_H_INIP  .equ 0xfdc7
BIOS_H_KEYC  .equ 0xfdcc
BIOS_H_KYEA  .equ 0xfdd1
BIOS_H_NMI   .equ 0xfdd6
BIOS_H_PINL  .equ 0xfddb
BIOS_H_QINL  .equ 0xfde0
BIOS_H_INLI  .equ 0xfde5
BIOS_H_ONGO  .equ 0xfdea
BIOS_H_DSKO  .equ 0xfdef
BIOS_H_SETS  .equ 0xfdf4
BIOS_H_NAME  .equ 0xfdf9
BIOS_H_KILL  .equ 0xfdfe
BIOS_H_IPL   .equ 0xfe03
BIOS_H_COPY  .equ 0xfe08
BIOS_H_CMD   .equ 0xfe0d
BIOS_H_DSKF  .equ 0xfe12
BIOS_H_DSKI  .equ 0xfe17
BIOS_H_ATTR  .equ 0xfe1c
BIOS_H_LSET  .equ 0xfe21
BIOS_H_RSET  .equ 0xfe26
BIOS_H_FIEL  .equ 0xfe2b
BIOS_H_MKI   .equ 0xfe30
BIOS_H_MKS   .equ 0xfe35
BIOS_H_MKD   .equ 0xfe3a
BIOS_H_CVI   .equ 0xfe3f
BIOS_H_CVS   .equ 0xfe44
BIOS_H_CVD   .equ 0xfe49
BIOS_H_GETP  .equ 0xfe4e
BIOS_H_SETF  .equ 0xfe53
BIOS_H_NOFO  .equ 0xfe58
BIOS_H_NULO  .equ 0xfe5d
BIOS_H_NTFL  .equ 0xfe62
BIOS_H_MERG  .equ 0xfe67
BIOS_H_SAVE  .equ 0xfe6c
BIOS_H_BINS  .equ 0xfe71
BIOS_H_BINL  .equ 0xfe76
BIOS_H_FILE  .equ 0xfd7b
BIOS_H_DGET  .equ 0xfe80
BIOS_H_FILO  .equ 0xfe85
BIOS_H_INDS  .equ 0xfe8a
BIOS_H_RSLF  .equ 0xfe8f
BIOS_H_SAVD  .equ 0xfe94
BIOS_H_LOC   .equ 0xfe99
BIOS_H_LOF   .equ 0xfe9e
BIOS_H_EOF   .equ 0xfea3
BIOS_H_FPOS  .equ 0xfea8
BIOS_H_BAKU  .equ 0xfead
BIOS_H_PARD  .equ 0xfeb2
BIOS_H_NODE  .equ 0xfeb7
BIOS_H_POSD  .equ 0xfebc
BIOS_H_DEVN  .equ 0xfec1
BIOS_H_GEND  .equ 0xfec6
BIOS_H_RUNC  .equ 0xfecb
BIOS_H_CLEAR .equ 0xfed0
BIOS_H_LOPD  .equ 0xfed5
BIOS_H_STKE  .equ 0xfeda
BIOS_H_ISFL  .equ 0xfedf
BIOS_H_OUTD  .equ 0xfee4
BIOS_H_CRDO  .equ 0xfee9
BIOS_H_DSKC  .equ 0xfeee
BIOS_H_DOGR  .equ 0xfef3
BIOS_H_PRGE  .equ 0xfef8
BIOS_H_ERRP  .equ 0xfefd
BIOS_H_ERRF  .equ 0xff02
BIOS_H_READ  .equ 0xff07
BIOS_H_MAIN  .equ 0xff0c
BIOS_H_DIRD  .equ 0xff11
BIOS_H_FINI  .equ 0xff16
BIOS_H_FINE  .equ 0xff1b
BIOS_H_CRUN  .equ 0xff20
BIOS_H_CRUS  .equ 0xff25
BIOS_H_ISRE  .equ 0xff2a
BIOS_H_NTFN  .equ 0xff2f
BIOS_H_NOTR  .equ 0xff34
BIOS_H_SNGF  .equ 0xff39
BIOS_H_NEWS  .equ 0xff3e
BIOS_H_GONE  .equ 0xff43
BIOS_H_CHRG  .equ 0xff48
BIOS_H_RETU  .equ 0xff4d
BIOS_H_PRTF  .equ 0xff52
BIOS_H_COMP  .equ 0xff57
BIOS_H_FINP  .equ 0xff5c
BIOS_H_TRMN  .equ 0xff61
BIOS_H_FRME  .equ 0xff66
BIOS_H_NTPL  .equ 0xff6b
BIOS_H_EVAL  .equ 0xff70
BIOS_H_OKNO  .equ 0xff75
BIOS_H_FING  .equ 0xff7a
BIOS_H_ISMI  .equ 0xff7f
BIOS_H_WIDT  .equ 0xff84
BIOS_H_LIST  .equ 0xff89
BIOS_H_BUFL  .equ 0xff8e
BIOS_H_FRQI  .equ 0xff93
BIOS_H_SCNE  .equ 0xff98
BIOS_H_FRET  .equ 0xff9d
BIOS_H_PTRG  .equ 0xffa2
BIOS_H_PHYD  .equ 0xffa7
BIOS_H_FORM  .equ 0xffac
BIOS_H_ERRO  .equ 0xffb1
BIOS_H_LPTO  .equ 0xffb6
BIOS_H_LPTS  .equ 0xffbb
BIOS_H_SCRE  .equ 0xffc0
BIOS_H_PLAY  .equ 0xffc5

; For expanded BIOS
BIOS_FCALL   .equ 0xffca
BIOS_DISINT  .equ 0xffcf
BIOS_ENAINT  .equ 0xffd4

; --- bdos calls ---
BDOS_SYSCAL  .equ 0x0005

; --- bdos variables ---
BDOS_ABORTH	 .equ 0xf1e6
BDOS_DTA     .equ 0xf23d		; MSX TOP SECRET states this as 0xf23c
								; but by my experiences it's 0xf23d
BDOS_DSKERR  .equ 0xf323
BDOS_DPBBAS	 .equ 0xf353
BDOS		 .equ 0xf37d


; I/O
BDOS_CONIN   .equ 0x01
BDOS_CONOUT  .equ 0x02
BDOS_AUXIN   .equ 0x03
BDOS_AUXOUT  .equ 0x04
BDOS_LSTOUT  .equ 0x05
BDOS_DIRIO   .equ 0x06
BDOS_DIRIN   .equ 0x07
BDOS_INNOE   .equ 0x08
BDOS_STROUT  .equ 0x09
BDOS_BUFIN   .equ 0x0a
BDOS_CONST   .equ 0x0b

; system
BDOS_TERM0   .equ 0x00
BDOS_CPMVER  .equ 0x0c
BDOS_DSKRST  .equ 0x0d
BDOS_SELDSK  .equ 0x0e
BDOS_LOGIN   .equ 0x18
BDOS_CURDRV  .equ 0x19
BDOS_SETDTA  .equ 0x1a
BDOS_ALLOC   .equ 0x1b
BDOS_GDATE   .equ 0x2a
BDOS_SDATE   .equ 0x2b
BDOS_GTIME   .equ 0x2c
BDOS_STIME   .equ 0x2d
BDOS_VERIFY  .equ 0x2e

; sectors
BDOS_RDABS   .equ 0x2f
BDOS_WRABS   .equ 0x30

; fcb
BDOS_FOPEN   .equ 0x0f
BDOS_FCLOSE  .equ 0x10
BDOS_SFIRST  .equ 0x11
BDOS_SNEXT   .equ 0x12
BDOS_FDEL    .equ 0x13
BDOS_RDSEQ   .equ 0x14
BDOS_WRSEQ   .equ 0x15
BDOS_FMAKE   .equ 0x16
BDOS_FREN    .equ 0x17
BDOS_RDRND   .equ 0x21
BDOS_WRRND   .equ 0x22
BDOS_FSIZE   .equ 0x23
BDOS_SETRND  .equ 0x24
BDOS_WRBLK   .equ 0x26
BDOS_RDBLK   .equ 0x27
BDOS_WRZER   .equ 0x28

; msxdos2
BDOS_DPARM   .equ 0x31
BDOS_FFIRST  .equ 0x40
BDOS_FNEXT   .equ 0x41
BDOS_FNEW    .equ 0x42
BDOS_OPEN    .equ 0x43
BDOS_CREATE  .equ 0x44
BDOS_CLOSE   .equ 0x45
BDOS_ENSURE  .equ 0x46
BDOS_DUP     .equ 0x47
BDOS_READ    .equ 0x48
BDOS_WRITE   .equ 0x49
BDOS_SEEK    .equ 0x4a
BDOS_IOCTL   .equ 0x4b
BDOS_HTEST   .equ 0x4c
BDOS_DELETE  .equ 0x4d
BDOS_RENAME  .equ 0x4e
BDOS_MOVE    .equ 0x4f
BDOS_ATTR    .equ 0x50
BDOS_FTIME   .equ 0x51
BDOS_HDELET  .equ 0x52
BDOS_HRENAM  .equ 0x53
BDOS_HMOVE   .equ 0x54
BDOS_HATTR   .equ 0x55
BDOS_HFTIME  .equ 0x56
BDOS_GETDTA  .equ 0x57
BDOS_GETVFY  .equ 0x58
BDOS_GETCD   .equ 0x59
BDOS_CHDIR   .equ 0x5a
BDOS_PARSE   .equ 0x5b
BDOS_PFILE   .equ 0x5c
BDOS_CHKCHR  .equ 0x5d
BDOS_WPATH   .equ 0x5e
BDOS_FLUSH   .equ 0x5f
BDOS_FORK    .equ 0x60
BDOS_JOIN    .equ 0x61
BDOS_TERM    .equ 0x62
BDOS_DEFAB   .equ 0x63
BDOS_DEFER   .equ 0x64
BDOS_ERROR   .equ 0x65
BDOS_EXPLN   .equ 0x66
BDOS_FORMAT  .equ 0x67
BDOS_RAMD    .equ 0x68
BDOS_BUFFER  .equ 0x69
BDOS_ASSIGN  .equ 0x6a
BDOS_GENV    .equ 0x6b
BDOS_SENV    .equ 0x6c
BDOS_FENV    .equ 0x6d
BDOS_DSKCHK  .equ 0x6e
BDOS_DOSVER  .equ 0x6f
BDOS_REDIR   .equ 0x70
