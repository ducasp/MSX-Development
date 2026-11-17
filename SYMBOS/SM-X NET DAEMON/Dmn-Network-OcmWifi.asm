;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@   SymbOS Network Daemon - OCM Wi-Fi driver                                 @
;@   hardware layer for the ESP8266 UNAPI firmware (ducasp) behind the        @
;@   SM-X style I/O UART of the OCM (One Chip MSX).  DRIVER=7                 @
;@                                                                            @
;@   Based on the msx-picoverse-symbos-network-daemon by Jzzy:                @
;@   https://github.com/Jzzy-dev/msx-picoverse-symbos-network-daemon          @
;@                                                                            @
;@   This daemon is presented to you by the works of DucaSP and OpenCode with @
;@   Deepseek v4 Flash (v0.9), so if you A.I. allergies, please don't use it. @
;@   You can reach the author on:                                             @
;@   https://github.com/ducasp                                                @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;
; Sources this was derived from -
;  - ESP8266_memio.asm (ducasp, UNAPI BIOS v1.3 MSX PICO UART version) and
;    ESPUNAPI.asm (ducasp, UNAPI BIOS for the SM-X / OCM I/O UART) -
;      wire protocol, command numbers, response layout, I/O ports
;  - msx-picoverse-symbos-network-daemon (Jzzy) - daemon driver structure
;  - Dmn-Network.asm (Prodatron) - the hooks the daemon calls (low*, dns*)
;
; WIRE PROTOCOL (from ESP8266_memio.asm / ESPUNAPI.asm)
;   request - [fn] [len MSB] [len LSB] [payload...]
;   response - [fn] [rc] [len MSB] [len LSB] [payload... only if rc=0]
;   fn is the UNAPI function number, except DNS query = 206.
;   Unrelated bytes may precede the response; skip until fn is seen.
;
; I/O PORTS (SM-X / OCM UART interface, no slot or memory bank involved)
;   out (#06),a   write command / set UART speed / clear FIFO (20)
;   out (#07),a   write a TX data byte
;   in  a,(#06)   read an RX data byte
;   in  a,(#07)   read the UART status byte
;
; UART STATUS BITS (as documented by the BIOS; note that bits 6/7 read 0 on
; some FPGAs although the doc says 1 - do not rely on them)
;   bit 0 - RX FIFO has data
;   bit 1 - TX in progress
;   bit 2 - RX FIFO full
;   bit 3 - quick receive supported by the hardware (FPGA)
;   bit 4 - buffer underrun (reset on read)
;   bit 5 - undocumented, not used by this driver
;   bits 6/7 - interrupt/open bus confusion flags
;
; DESIGN
;   * The I/O UART is visible system-wide, independent of slots and memory
;     banking, so no slot switching is ever needed and interrupts stay on.
;   * Long operations (TCP open up to 60s, DNS up to 15s) are split - the
;     request is sent at once, the answer is collected by polling later
;     (lowtst / espdnr), exactly like the original memio driver.
;   * The ESP does DHCP, DNS and TCP itself, so this layer plugs into the
;     daemon the same way the M4Board "high level" build does - no DHCP, no
;     UDP-based DNS.
;   * Detection uses the ESP firmware Query command: clear the FPGA RX FIFO,
;     send "?" and expect "OK". The "?" must be the first byte the ESP sees
;     while it is idle, the clear command never reaches the ESP. While the OCM
;     transport is being verified the probe is tried with three strategies
;     (clear+send, clear+frame+send, framed NET_STATE). On failure the
;     adapter line shows "st=hh rD" (status before the last send, bytes
;     received by the last strategy) and the driver tab info line shows
;     "rA/B/C st=hh" (bytes received per strategy).
;   * Quick receive (status bit 3) is detected and shown in the driver tab,
;     the data paths do not use it yet. I don't think Quick receive makes
;     sense on SymbOS, on MSX DOS it makes receiving large portions of data
;     faster by not needing to check the UART status bits before reading a long
;     chain of data (i.e.: TCP_RCV results), the trade-off is that it will assert
;     WAIT (halting the CPU) for up to 20ms or so if trying to read an empty FIFO.
;     On MSX DOS we are running alone and not sharing CPU time, so that is ok, as
;     nothing else would be using the CPU anyway (and not needing to read UART status
;     1024 times before getting 1024 bytes of data saves some time on slower CPUs),
;     but on SymbOS the time waiting for a byte can be used for something else.
;
; low_sockmax / low_vermaj / low_vermin are defined in the WRAPPER (Dmn-Network-_OcmWifi.asm),
; before Dmn-Network.asm is read, because the daemon uses low_sockmax in a "ds" at line 148.

esp_io_cmd      equ #06         ;write=command/speed/clear, read=RX data
esp_io_tx       equ #07         ;write=TX data, read=status

esp_cmd_clrfifo equ 20          ;clear FIFO command
esp_fn_ipinfo   equ 2
esp_fn_netstate equ 3
esp_fn_autoip   equ 25          ;get/set IP+DNS automatic mode
esp_fn_configip equ 26          ;set one IP address item
esp_fn_tcpopen  equ 13
esp_fn_tcpclose equ 14
esp_fn_tcpabort equ 15
esp_fn_tcpstate equ 16
esp_fn_tcpsend  equ 17
esp_fn_tcprcv   equ 18
esp_fn_dnsq     equ 206         ;DNS_Q_NEW (not 6!)
esp_cmd_scan    equ "S"         ;start Wi-Fi scan (quick response)
esp_cmd_scanr   equ "s"         ;read scan results (raw response)
esp_cmd_conn    equ "A"         ;connect to an access point (quick response)
esp_cmd_disc    equ "a"         ;forget the current access point (quick response)
esp_cmd_setq    equ "Q"         ;query ESP settings (framed string ON:/OFF:)
esp_cmd_nagle   equ "D"         ;Nagle on (quick response)
esp_cmd_nagle0  equ "N"         ;Nagle off (quick response)
esp_cmd_timer   equ "T"         ;Wi-Fi on timer (2 byte payload, quick response)
esp_cmd_ver     equ "V"         ;firmware version (raw 'V' + two digits)
esp_cmd_gettype equ "b"         ;chip type query (ESP32 only)
esp_cmd_settype equ "B"         ;ESP32 firmware type validation (data command)
esp_cmd_upstart equ "Z"         ;start RS232 firmware update (data command)
esp_cmd_upcert  equ "Y"         ;start RS232 certificate update (data command)
esp_cmd_upblk   equ "z"         ;RS232 update block (data command, quick response)
esp_cmd_upend   equ "E"         ;end RS232 update (the ESP flashes and restarts)
esp_cmd_upidx   equ "I"         ;build the certificate index

esp_spin        equ 1500        ;poll iterations per espgtb attempt (tune!)


;==============================================================================
;### STATE ####################################################################
;==============================================================================

esp_pend        db 0            ;0=idle, else fn of an outstanding request
esp_pendsck     db 0            ;socket that owns the outstanding request
esp_conn        ds low_sockmax  ;ESP connection number per daemon socket (0=none)
esp_stat        ds low_sockmax  ;cached daemon status (for pending open result)
esp_reason      ds low_sockmax  ;open failure reason per socket (8/25)
esp_tlsreq      ds low_sockmax  ;TLS request flag per socket (bit 2)
esp_lastreason  db 0            ;reason of the socket last checked by lowtst
esptoprc        db 0            ;temporary ESP TCP_OPEN return code
esp_dnsres      ds 4            ;last DNS result
esp_dnsst       db 0            ;0=idle,1=pending,2=ok,3=failed
esp_sta_tx      db 0            ;TX and RX hold counters for the lights in the driver tab,
esp_sta_rx      db 0            ;the daemon counts them down, they are set whenever data moves
esp_sta_delay   equ 3
esp_qr          db 0            ;1 = quick receive supported (status bit 3), shown in the driver tab
esp_strat       db 0            ;detection strategy in use (temporary, OCM bring-up)
esp_st0         db 0            ;status byte before the last send (diagnostic)
esp_rxn         db 0            ;bytes received during the current strategy (diagnostic)
esp_rxs         ds 3            ;bytes received per strategy (diagnostic)

; All ESP state lives here in the transfer area (page 3), always reachable.
esp_tmp         ds 11           ;copy of the TCP open parameter block
esp_ip4         ds 4            ;IP info answer
esp_dnsb        ds 64           ;copy of the domain name for a DNS request
esp_dnsl        dw 0            ;its length
esp_blen        equ 128
esp_buf         ds esp_blen     ;bounce buffer (own bank) for bank copies


;==============================================================================
;### LOW LEVEL TRANSPORT (I/O ports, no window) ###############################
;==============================================================================

;### ESPGTB -> try to read one byte (preserves BC,DE,HL)
;### Output     CF=0 A=byte, CF=1 nothing arrived within esp_spin polls
espgtb  push bc
        ld bc,esp_spin
espgtb1 in a,(esp_io_tx)        ;status
        bit 0,a                 ;RX FIFO has data?
        jr nz,espgtb2
        dec bc
        ld a,b
        or c
        jr nz,espgtb1
        pop bc
        scf
        ret
espgtb2 in a,(esp_io_cmd)       ;RX data
        pop bc
        or a
        ret

;### ESPGTW -> like ESPGTB, but if nothing arrives it waits one video frame
;### Input      (esp_wcnt)=frames to wait at most
;### Output     CF=0 A=byte, CF=1 timeout
;### Destroyed  F,BC,DE,HL
esp_wcnt        db 0
espgtw  call espgtb
        ret nc
espgtw1 ld a,(esp_wcnt)
        or a
        jr z,espgtw9
        dec a
        ld (esp_wcnt),a
        halt                    ;one frame, interrupts stay on
        rst #30
        call espgtb
        ret nc
        jr espgtw1
espgtw9 scf
        ret

;### ESPRSP -> wait for a response header
;### Input      A=expected fn, (esp_wdef) = frames to wait for it (ESPRSP0 does not wait)
;### Output     CF=0 - A=return code, HL=payload length
;###            CF=1 - no (complete) response
;### Destroyed  BC,DE
;  At most esp_skipmax unrelated bytes are skipped, so a floating bus can never
;  keep this loop alive forever.
esp_skipmax     equ 1200
esp_skipn       dw 0
esp_wdef        db 20           ;default wait in frames for a response

esprsp0 ld d,a
        xor a
        jr esprsp3
esprsp  ld d,a
        ld a,(esp_wdef)
esprsp3 ld (esp_wcnt),a
        ld hl,esp_skipmax
        ld (esp_skipn),hl
esprsp1 call espgtw
        ret c
        cp d
        jr z,esprsp2
        ld hl,(esp_skipn)
        dec hl
        ld (esp_skipn),hl
        ld a,h
        or l
        jr nz,esprsp1
        scf
        ret
esprsp2 call espgtb             ;return code
        ret c
        ld e,a
        call espgtb             ;length MSB
        ret c
        ld h,a
        call espgtb             ;length LSB
        ret c
        ld l,a
        ld a,e
        or a                    ;CF=0
        ret

;### ESPSKP -> discard HL payload bytes
;### Output     CF=1 on timeout or if the length is not plausible
espskp  ld a,h
        cp 8                    ;more than 2047 bytes can not be right here
        jr c,espskp0
        scf
        ret
espskp0 or l
        ret z
espskp1 push hl
        call espgtb
        pop hl
        ret c
        dec hl
        ld a,h
        or l
        jr nz,espskp1
        ret


;==============================================================================
;### DAEMON HOOKS #############################################################
;==============================================================================

;### LOWINI -> hardware init / configuration
;### Input      A=0 init hardware, 1 set MAC (HL), 2 set IP data,
;###            3 read the IP/DNS configuration, 5,6,7 = M4Board only (ignored)
;### Output     CF=1 -> hardware not found (A=0 only); A=3: A=config, CF=1 failed
;### Destroyed  AF,BC,DE,HL,IX,IY
lowini  or a
        jr z,lowini0
        cp 2
        jp z,espnet             ;apply the daemon's IP/DNS configuration
        cp 3
        jp z,espnetq            ;read the ESP's IP/DNS configuration
        or a
        ret                     ;the MAC is owned by the ESP, nothing to do
lowini0 xor a
        ld (esp_pend),a
        ld (esp_dnsst),a
        ld hl,esp_conn
        ld de,esp_conn+1
        ld bc,low_sockmax*2-1
        ld (hl),0
        ldir
        ld hl,esp_uconn
        ld de,esp_uconn+1
        ld bc,low_sockmax-1
        ld (hl),0
        ldir
        xor a
        ld (esp_udw),a
        ld (esp_udps),a
        ld (esp_udpchg),a
        call espdetect          ;CF=1 when no ESP was found
        ret c
        call espucl0            ;close UDP connections left behind by earlier runs
        call espap              ;read the access point name
        or a
        ret

;### ESPDETECT -> find the ESP on the I/O ports
;### Sends "?" and expects "OK" - the Query command of the ESP firmware. The
;### "?" must be the first byte the ESP sees while it is idle, the clear FIFO
;### command only resets the FPGA RX buffer and never reaches the ESP.
;### The probe is tried with three strategies (temporary while the OCM
;### transport is being verified, the fallbacks go away once this works):
;###   0: clear FIFO, send "?"
;###   1: clear FIFO, wait one frame, send "?"
;###   2: clear FIFO, wait one frame, framed NET_STATE (fn 3) request
;### Output     CF=0 found (esp_qr updated, driver tab text patched),
;###            CF=1 no hardware / no answer (diagnostic texts updated)
;### Destroyed  AF,BC,DE,HL
espdetect
        xor a
        ld (esp_strat),a
espdtlp xor a
        ld (esp_rxn),a          ;bytes received during this strategy
        ld a,(esp_strat)
        call espdatt
        jr nc,espdtok
        ld a,(esp_strat)        ;remember what this strategy received
        ld e,a
        ld d,0
        ld hl,esp_rxs
        add hl,de
        ld a,(esp_rxn)
        ld (hl),a
        ld a,(esp_strat)
        inc a
        ld (esp_strat),a
        cp 3
        jr c,espdtlp
        call espdgr             ;all failed - diagnostics into the texts
        scf
        ret
espdtok in a,(esp_io_tx)        ;quick receive capability
        bit 3,a
        ld a,0
        jr z,espdtq
        inc a
espdtq  ld (esp_qr),a
        call espqrinf           ;driver tab info line
        ld hl,esptxt2           ;adapter line
        call esptext
        or a                    ;CF=0
        ret

;### ESPDATT -> one detection attempt
;### Input      (esp_strat) = 0..2
;### Output     CF=0 found, CF=1 nothing
;### Destroyed  AF,BC,DE,HL
espdatt ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a      ;clear the FPGA RX FIFO
        ld a,(esp_strat)
        or a
        jr z,espdat0
        call espdfr             ;let the FPGA settle for a frame
espdat0 in a,(esp_io_tx)
        ld (esp_st0),a          ;status before sending, for the diagnostic
        ld a,(esp_strat)
        cp 2
        jr z,espdat2
        ld a,63                 ;"?"
        out (esp_io_tx),a
        ld a,60                 ;wait up to 1 second
        ld (esp_wcnt),a
        ld hl,esptxok           ;expected response
        xor a
espdat1 push af                 ;match index
espdat3 call espgtw             ;one byte, CF=1 on timeout
        jr c,espdatn
        push af                 ;received byte
        push hl
        ld hl,esp_rxn
        inc (hl)                ;count it for the diagnostic
        pop hl
        pop af                  ;A=received byte
        pop af                  ;A=match index
        push af
        push hl
        ld e,a
        ld d,0
        add hl,de
        ld c,(hl)               ;expected byte
        pop hl
        cp c
        jr nz,espdatm           ;mismatch, restart the match
        pop af
        inc a                   ;one more byte matched
        cp 2                    ;both "O" and "K"?
        jr z,espdaty
        push af
        jr espdat3
espdatm pop af
        xor a                   ;restart the match at index 0
        jr espdat1
espdaty or a                    ;found
        ret
espdatn pop af                  ;drop the match index
        scf
        ret

;--- strategy 2: framed NET_STATE request
espdat2 ld a,60
        ld (esp_wdef),a
        ld a,esp_fn_netstate
        ld hl,0
        out (esp_io_tx),a             ;[3][0][0]
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,esp_fn_netstate
        call esprsp             ;any response frame means the ESP is there
        push af
        ld a,20
        ld (esp_wdef),a         ;restore the default
        pop af
        jr c,espdatn2
        call espskp             ;discard the payload
        or a
        ret
espdatn2 scf
        ret

;### ESPDFR -> wait one video frame
espdfr  halt
        ret

;### ESPDGR -> build the failure diagnostic texts
;### Adapter line (Status tab): "st=hh rD" - status before the last send and
;### the bytes received by the last strategy
;### Driver tab line: "rA/B/C st=hh" - bytes received per strategy
espdgr  ld de,esp_dbgtxt
        ld hl,espdst            ;"st="
        ld bc,3
        ldir
        ld a,(esp_st0)
        call esphex2
        ld hl,espdr             ;" r"
        ld bc,2
        ldir
        ld a,(esp_rxs+2)
        call espdgd
        xor a
        ld (de),a
        ld de,statxttxqa
        ld a,"r"
        ld (de),a
        inc de
        ld hl,esp_rxs
        ld b,3
espdgl  ld a,(hl)
        inc hl
        call espdgd
        dec b
        jr z,espdge
        ld a,"/"
        ld (de),a
        inc de
        jr espdgl
espdge  ld hl,espdst            ;" st="
        ld bc,4
        ldir
        ld a,(esp_st0)
        call esphex2
        xor a
        ld (de),a
        ret
espdst  db "st="
espdr   db " r"

;### ESPDGD -> A as one decimal digit (clamped to 9) at DE, DE advances
espdgd  cp 9
        jr c,espdgd1
        ld a,9
espdgd1 add 48
        ld (de),a
        inc de
        ret

;### ESPHEX2 -> byte A as two ASCII hex digits at DE
esphex2 push af
        rrca
        rrca
        rrca
        rrca
        call esphexn
        pop af
esphexn and 15
        add 48
        cp 58
        jr c,esphexn1
        add 7
esphexn1 ld (de),a
        inc de
        ret

;### ESPQRINF -> build the transport info line of the driver tab from esp_qr
espqrinf ld hl,esptxq0
        ld a,(esp_qr)
        or a
        jr z,espqri1
        ld hl,esptxq1
espqri1 ld de,statxttxqa
        ld bc,25
        ldir
        ret

esptxok db "OK"
esptxq0 db "ESP on I/O",0
        ds 14
esptxq1 db "ESP on I/O, QR supported",0

;### ESPTEXT -> copy the 0 terminated text in HL to the adapter text line
esptext ld de,esp_dbgtxt
        ld bc,15
        ldir
        ret
esptxt2 db "ESP",0
        ds 12

;### ESPUDPT -> set the driver tab UDP line (A=0 clear, A=1 error)
;### Only rewrites it when the state changes, so the line is not redrawn again and again.
espudpt ld c,a
        ld a,(esp_udps)
        cp c
        ret z
        ld a,c
        ld (esp_udps),a
        ld hl,esptxu0
        or a
        jr z,espudp1
        ld hl,esptxu1
espudp1 ld de,statxtudp
        ld bc,25
        ldir
        ld a,1
        ld (esp_udpchg),a
        ret

;### ESPIPS -> read IP / mask / gateway / DNS from the ESP into net_ipaadr/net_dnspri
;### Output     CF=1 on failure
;### Destroyed  AF,BC,DE,HL,IX
espips  ld ix,net_ipaadr        ;ip, mask, gateway (3 x 4 byte)
        ld b,1:call espips1     ;local IP
        ret c
        ld ix,net_ipaadr+4
        ld b,3:call espips1     ;subnet mask
        ret c
        ld ix,net_ipaadr+8
        ld b,4:call espips1     ;default gateway
        ret c
        ld ix,net_dnspri
        ld b,5:call espips1     ;primary DNS
        ret c
        ld ix,net_dnspri+4
        ld b,6                  ;secondary DNS
espips1
        ld a,esp_fn_ipinfo
        ld hl,1
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,b
        out (esp_io_tx),a
        ld a,esp_fn_ipinfo
        call esprsp
        jr c,espips9
        or a
        jr nz,espips8
        call espgtb:jr c,espips9:ld (esp_ip4+0),a
        call espgtb:jr c,espips9:ld (esp_ip4+1),a
        call espgtb:jr c,espips9:ld (esp_ip4+2),a
        call espgtb:jr c,espips9:ld (esp_ip4+3),a
        ld hl,(esp_ip4+0)       ;copy to the daemon data
        ld (ix+0),l
        ld (ix+1),h
        ld hl,(esp_ip4+2)
        ld (ix+2),l
        ld (ix+3),h
        or a
        ret
espips8 call espskp
espips9
        scf
        ret

;--- ESP configuration (UNAPI 25/26, used only by DRIVER 7) -------------------
esp_utmp        db 0            ;temporary state / config byte
esp_ntgt        db 0            ;target config byte during a set

;### ESPNST -> read the Wi-Fi link state
;### Output     CF=0 A=state (0 closed, 1 opening, 2 open, 3 closing, 255 unknown)
;###            CF=1 no answer / malformed reply
espnst  ld a,esp_fn_netstate
        out (esp_io_tx),a
        xor a
        out (esp_io_tx),a
        out (esp_io_tx),a
        ld a,esp_fn_netstate
        call esprsp
        jr c,espnst9
        or a
        jr nz,espnst9
        ld a,h
        or l
        jr z,espnst9
        push hl
        call espgtb
        pop hl
        jr c,espnst9
        ld (esp_utmp),a
        dec hl
        call espskp
        ret c
        ld a,(esp_utmp)
        or a
        ret
espnst9 scf
        ret

;### ESPNETQ -> read the ESP's automatic IP/DNS configuration
;### Output     CF=0 A=config byte (bit0 IP automatic, bit1 DNS automatic)
;###            CF=1 failed
espnetq ld a,esp_fn_autoip
        out (esp_io_tx),a
        xor a
        out (esp_io_tx),a
        ld a,2
        out (esp_io_tx),a
        xor a
        out (esp_io_tx),a       ;B=0 get
        out (esp_io_tx),a       ;C (ignored by the firmware)
        ld a,esp_fn_autoip
        call esprsp
        jr c,espnetq9
        or a
        jr nz,espnetq9
        ld a,h
        or l
        jr z,espnetq9
        push hl
        call espgtb
        pop hl
        jr c,espnetq9
        ld (esp_utmp),a
        dec hl
        call espskp
        ret c
        ld a,(esp_utmp)
        or a
        ret
espnetq9 scf
        ret

;### ESPNETI -> set one IP address item in the ESP
;### Input      B=item (1 IP, 3 mask, 4 gateway, 5 DNS1, 6 DNS2), HL=4 bytes
;### Output     CF=0 ok, CF=1 A=2 no answer / 3 refused
;### Destroyed  AF,BC,DE,HL
espneti push hl
        ld a,esp_fn_configip
        out (esp_io_tx),a
        xor a
        out (esp_io_tx),a
        ld a,5
        out (esp_io_tx),a
        ld a,b
        out (esp_io_tx),a
        pop hl
        ld b,4
espneti1 ld a,(hl)
        out (esp_io_tx),a
        inc hl
        djnz espneti1
        ld a,esp_fn_configip
        call esprsp
        jr c,espneti2
        or a
        jr nz,espneti3
        call espskp
        jr c,espneti2
        or a
        ret
espneti2 ld a,2
        scf
        ret
espneti3 ld a,3
        scf
        ret

;### ESPNET -> apply the daemon's IP/DNS configuration to the ESP
;### Input      none (cfg_ipatyp, cfg_dnstyp, cfg_ipaadr..cfg_dnssec)
;### Output     CF=0 ok, CF=1 A=1 busy / 2 no answer / 3 refused
;### Destroyed  AF,BC,DE,HL
espnet  ld a,(esp_pend)
        or a
        jr z,espnet0
        ld a,1
        scf
        ret                     ;a long request is outstanding
espnet0 xor a
        ld b,a
        ld a,(cfg_ipatyp)
        or a
        jr nz,espnet1
        set 0,b                 ;IP automatic
espnet1 ld a,(cfg_dnstyp)
        or a
        jr nz,espnet2
        set 1,b                 ;DNS automatic
espnet2 ld a,b
        cp 2
        jr nz,espnet3
        ld a,3
        scf
        ret                     ;manual IP + automatic DNS is not supported
espnet3 ld (esp_ntgt),a
        ld a,(cfg_ipatyp)
        or a
        jr z,espnet6
        ld hl,cfg_ipaadr
        ld b,1
        call espneti
        jp c,espnete
        ld hl,cfg_ipasbn
        ld b,3
        call espneti
        jp c,espnete
        ld hl,cfg_ipagat
        ld b,4
        call espneti
        jp c,espnete
espnet6 ld a,(cfg_dnstyp)
        or a
        jr z,espnet9
        ld hl,cfg_dnspri
        ld b,5
        call espneti
        jp c,espnete
        ld hl,cfg_dnssec
        ld b,6
        call espneti
        jp c,espnete
espnet9 ld a,esp_fn_autoip
        out (esp_io_tx),a
        xor a
        out (esp_io_tx),a
        ld a,2
        out (esp_io_tx),a
        ld a,1
        out (esp_io_tx),a       ;B=1 set
        ld a,(esp_ntgt)
        out (esp_io_tx),a       ;C=configuration
        ld a,esp_fn_autoip
        call esprsp
        jr c,espnete2
        or a
        jr nz,espnete3
        ld a,h
        or l
        jr z,espnete3
        call espgtb
        jr c,espnete2
        ld c,a
        dec hl
        call espskp
        jr c,espnete2
        ld a,(esp_ntgt)
        cp c
        jr nz,espnete3
        or a
        ret
espnete scf
        ret
espnete2 ld a,2
        scf
        ret
espnete3 ld a,3
        scf
        ret

;### ESPPOL -> hook for netpol (replaces m4cpol); completes pending replies
;### Destroyed  AF,BC,DE,HL,IX,IY
esppol  ld a,(esp_pend)
        or a
        jr z,esppoli
        cp esp_fn_dnsq
        jp z,espdnp
        cp esp_fn_tcpopen
        jp z,esptop
        ret

;--- nothing is pending, while online check the link now and then
esp_chkcnt      db 250
esp_state       db 0
esppoli ld a,(net_status)
        inc a                   ;255 = online
        ret nz
        ld hl,esp_chkcnt
        dec (hl)
        ret nz
        ld (hl),250             ;about every 5 seconds
        call espnst
        ret c                   ;no answer, leave the state as it is
        ld (esp_state),a
        call espap              ;refresh the access point name now and then
        ld a,(esp_state)
        cp 2                    ;2 = open
        ret z
        ld a,1                  ;the link is gone, back to "no IP", NETIPS brings it back
        jp netini0

;------------------------------------------------------------------------------
;--- TCP ----------------------------------------------------------------------
;------------------------------------------------------------------------------

;### LOWTOP -> open TCP socket
;### Input      A=socket, E=0 client / 1 server, IX=param block
;###            (IX+0)=local port, (IX+2..5)=remote IP (octet order), (IX+6)=remote port
;### Output     CF=0 request started (result arrives via lowtst), CF=1 A=error
;### Destroyed  AF,BC,DE,HL,IX,IY
lowtop  ld c,a
        ld a,(esp_pend)
        or a
        ld a,neterrcon          ;another long request is outstanding
        scf
        ret nz
        push bc                 ;c=socket
        push de                 ;e=mode
        push ix
        pop hl                  ;copy the parameter block into the transfer area
        ld de,esp_tmp
        ld bc,11
        ldir
        pop de                  ;e=mode, still needed below
        push de
        call esptlsd            ;flags and host name come from the daemon
        ld hl,(esp_tlsl)        ;0 = plain TCP, else the host name block follows the flags
        ld de,11
        add hl,de
        ld a,esp_fn_tcpopen
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,(esp_tmp+2):out (esp_io_tx),a    ;remote IP
        ld a,(esp_tmp+3):out (esp_io_tx),a
        ld a,(esp_tmp+4):out (esp_io_tx),a
        ld a,(esp_tmp+5):out (esp_io_tx),a
        ld a,(esp_tmp+6):out (esp_io_tx),a    ;remote port, little endian as UNAPI wants
        ld a,(esp_tmp+7):out (esp_io_tx),a
        ld a,(esp_tmp+0):out (esp_io_tx),a    ;local port
        ld a,(esp_tmp+1):out (esp_io_tx),a
        xor a:out (esp_io_tx),a       ;timeout suggestion 0 = default
        xor a:out (esp_io_tx),a
        pop de
        ld a,(esp_tlsf)         ;flags, bit0 = passive, bit2 = TLS, bit3 = verify
        out (esp_io_tx),a
        ld hl,(esp_tlsp)        ;host name for TLS (SNI), 0 terminated, nothing for plain TCP
        ld bc,(esp_tlsl)
lowtop6 ld a,b
        or c
        jr z,lowtop7
        ld a,(hl)
        out (esp_io_tx),a
        inc hl
        dec bc
        jr lowtop6
lowtop7
        pop bc
        ld a,c
        ld (esp_pendsck),a
        ld a,esp_fn_tcpopen
        ld (esp_pend),a
        ld hl,esp_conn
        ld b,0
        add hl,bc
        ld (hl),0
        ld hl,esp_stat
        add hl,bc
        ld (hl),0               ;0 = still opening
        ld hl,esp_reason
        add hl,bc
        ld (hl),0
        ld hl,esp_tlsreq
        add hl,bc
        ld a,(esp_tmp+8)
        and 4
        ld (hl),a
        or a
        ret

;### ESPTLSD -> take the explicit TLS flags and host name from the daemon
;### Input      esp_tmp = parameter block, (esp_tmp+8)=flags, (esp_tmp+9)=host length
;### Output     esp_tlsf = flags for the ESP, esp_tlsl = host length (0 = plain TCP),
;###            esp_tlsp = host name in the daemon transfer area
;### There is no port-based TLS detection and no DNS-name cache. The caller
;### requests TLS in the TCP_Open mode and supplies the SNI/verification name.
esp_tlsf        db 0
esp_tlsl        dw 0
esp_tlsp        dw 0

esptlsd ld a,(esp_tmp+8)
        ld (esp_tlsf),a
        ld a,(esp_tmp+9)
        ld (esp_tlsl+0),a
        xor a
        ld (esp_tlsl+1),a
        ld hl,tcphost
        ld (esp_tlsp),hl
        ret

;### ESPTOP -> poll the outstanding TCP open
esptop
        ld a,esp_fn_tcpopen
        call esprsp0
        jp c,esptop9            ;not there yet, try again on the next poll
        or a
        jr nz,esptop5
        call espgtb             ;payload = 1 byte - the ESP connection number
        jr c,esptop9
        ld d,a
        ld a,(esp_pendsck)
        call espslot
        ld (hl),d
        ld a,sckstates
        jr esptop7
esptop5 ld (esptoprc),a
        ld a,(esp_pendsck)
        ld c,a
        ld b,0
        ld hl,esp_tlsreq
        add hl,bc
        ld a,(hl)
        or a
        jr z,esptop3            ;plain TCP: keep the generic close reason
        ld a,(esptoprc)
        cp 1
        jr z,esptop4            ;ESP has no free connection / TLS session
        ld a,neterrtls          ;TLS handshake, certificate or host name
        jr esptop6
esptop4 ld a,neterrsfr
        jr esptop6
esptop3 ld a,(esptoprc)
        cp 1
        jr z,esptop4
        xor a
esptop6 ld (esptoprc),a
        ld a,(esp_pendsck)
        ld c,a
        ld b,0
        ld hl,esp_reason
        add hl,bc
        ld a,(esptoprc)
        ld (hl),a
        call espskp             ;failed - drain payload, mark closed
        ld a,sckstatcl
esptop7 push af
        ld a,(esp_pendsck)
        ld c,a
        ld b,0
        ld hl,esp_stat
        add hl,bc
        pop af
        ld (hl),a
        xor a
        ld (esp_pend),a
        ret
esptop9
        ret

;### ESPSLT -> HL=address of esp_conn entry for socket A
espslot ld c,a
        ld b,0
        ld hl,esp_conn
        add hl,bc
        ret

;### ESPSTQ -> query ESP TCP state of one daemon socket
;### Input      A=socket
;### Output     CF=0 - esp_st_* filled in; CF=1 - ESP did not answer / no conn
;###            ZF... (rc<>0 from ESP is reported as CF=0, esp_st_state=0)
;### Destroyed  AF,BC,DE,HL
esp_st_state    db 0            ;UNAPI TCP state
esp_st_avail    dw 0            ;bytes available to read
esp_st_ip       ds 4
esp_st_port     dw 0

espstq  call espslot
        ld a,(hl)
        or a
        scf
        ret z                   ;socket has no ESP connection
        ld d,a                  ;d=conn number
        xor a
        ld (esp_st_state),a
        ld hl,0
        ld (esp_st_avail),hl
        ld hl,1
        ld a,esp_fn_tcpstate
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,d
        out (esp_io_tx),a
        ld a,esp_fn_tcpstate
        call esprsp
        jp c,espstq9
        or a
        jr nz,espstq8           ;ESP - no such connection -> state 0 (closed)
        call espgtb:jr c,espstq9        ;byte0 = close reason (ignored)
        call espgtb:jr c,espstq9
        ld (esp_st_state),a             ;byte1 = state
        call espgtb:jr c,espstq9
        ld (esp_st_avail+0),a           ;bytes2-3 = bytes available
        call espgtb:jr c,espstq9
        ld (esp_st_avail+1),a
        ld b,4                          ;bytes4-7 = urgent + free space - skip
espstq1 call espgtb:jr c,espstq9
        djnz espstq1
        ld hl,esp_st_ip                 ;8 byte info block - IP(4), rport(2), lport(2)
        ld b,6
espstq2 call espgtb:jr c,espstq9
        ld (hl),a
        inc hl
        djnz espstq2
        call espgtb:jr c,espstq9        ;local port, ignored
        call espgtb:jr c,espstq9
        or a
        ret
espstq8 call espskp
        or a
        ret
espstq9
        scf
        ret

;### LOWTST -> TCP status of a socket
;### Input      A=socket
;### Output     A=status (0=in process -> daemon skips), +128=data received,
;###            BC=received bytes available, IX,IY=remote IP, DE=remote port
;### Destroyed  F,HL
;!!VERIFY  daemon status numbers (Dmn-Network.asm) - 0 listen, 1 opening,
;          2 established, 3 close waiting, 4 closed.
;!!VERIFY  UNAPI TCP states assumed - 0 closed,1 listen,2 syn-sent,3 syn-rcvd,
;          4 established,9 close-wait (check TCP/IP UNAPI spec 4.5.x).
lowtst  ld (lowtsts),a
        ld c,a
        xor a
        ld (esp_lastreason),a
        ld a,(esp_pend)
        cp esp_fn_tcpopen
        jr nz,lowtst1
        ld a,(esp_pendsck)
        cp c
        jr nz,lowtst1
        call esppol             ;try to finish the pending open
lowtst1 ld a,(esp_pend)
        or a
        jr z,lowtst1a
        cp esp_fn_tcpopen
        jr nz,lowtst1b
        ld a,(esp_pendsck)
        ld hl,lowtsts
        cp (hl)
        jr z,lowtst1a
lowtst1b
        xor a                   ;do not send TCP_STATE while another request is pending
        ret
lowtst1a ld a,(lowtsts)
        call espslot
        ld a,(hl)
        or a
        jr nz,lowtst2
        ld c,a                  ;no ESP conn yet - cached result of the open
        ld a,(lowtsts)
        ld c,a
        ld b,0
        ld hl,esp_stat
        add hl,bc
        ld a,(hl)
        or a
        jp z,lowtstz            ;still opening -> A=0 -> daemon skips
        jp lowtstc
lowtst2 ld a,(lowtsts)
        call espstq
        jp c,lowtstc            ;ESP silent - report closed
        ld a,(esp_st_state)
        ld b,sckstatcl
        or a:jr z,lowtst3       ;0 closed
        ld b,sckstatli
        cp 1:jr z,lowtst3       ;1 listen
        ld b,sckstatop
        cp 2:jr z,lowtst3       ;2 syn sent
        cp 3:jr z,lowtst3       ;3 syn rcvd
        ld b,sckstates
        cp 4:jr z,lowtst3       ;4 established
        ;--- closing/teardown states: while data is still buffered keep
        ;--- reporting "established" so the daemon can not publish the close
        ;--- before the application has drained the buffer (peer FIN = state 7)
        ld b,sckstatcw
        cp 7:jr z,lowtst4       ;7 close wait (peer sent FIN)
        cp 9:jr z,lowtst4       ;9 last ack
        ld b,sckstatcl          ;anything else = closing/unknown
lowtst4 ld a,(esp_st_avail)
        or a:jr nz,lowtst5
        ld a,(esp_st_avail+1)
        or a:jr z,lowtst3       ;nothing buffered -> report the closing state
lowtst5 ld b,sckstates          ;data buffered -> established (+data bit below)
        jr lowtst3
lowtst3 ld a,b
        ld bc,(esp_st_avail)
        ld ix,(esp_st_ip+0)
        ld iy,(esp_st_ip+2)
        ld de,(esp_st_port)
        ld l,a
        ld a,b
        or c
        ld a,l
        ret z
        set 7,a                 ;data waiting
        ret
lowtstc ld a,(lowtsts)
        ld c,a
        ld b,0
        ld hl,esp_reason
        add hl,bc
        ld a,(hl)
        ld (esp_lastreason),a
        ld a,sckstatcl
        ld bc,0
        ld ix,0
        ld iy,0
        ld de,0
        ret
lowtstz xor a
        ret
lowtsts db 0

;### LOWTTX -> TCP send
;### Input      A=socket, BC=length, E,HL=source (E=bank)
;### Output     BC=sent bytes, HL=remaining bytes (ZF=1 -> all sent)
;### Destroyed  AF,DE,IX,IY
;  Data is bounced through esp_buf in chunks; it is copied OUT of the caller's
;  bank with jmp_bnkcop before it is sent.
lowttx  ld (lowttxs),a
        ld a,(esp_pend)
        or a
        jr z,lowttx0
        ld h,b
        ld l,c
        ld bc,0                 ;defer the send until the pending request is done
        ret
lowttx0 ld a,(lowttxs)
        ld (lowttxb),de         ;e=bank
        ld (lowttxl),bc
        ld (lowttxa),hl
        ld bc,0
        ld (lowttxd),bc         ;sent so far
lowttx1 ld bc,(lowttxl)
        ld a,b
        or c
        jp z,lowttx8
        ld hl,esp_blen
        or a
        sbc hl,bc
        jr nc,lowttx2           ;remaining <= chunk
        ld bc,esp_blen
lowttx2 ld (lowttxc),bc
        ld a,(App_BnkNum)       ;bank copy - A=(dest<<4)+src, HL=src, DE=dest
        add a:add a:add a:add a
        ld hl,lowttxb
        add (hl)
        ld hl,(lowttxa)
        ld de,esp_buf
        rst #20:dw jmp_bnkcop
        ld a,(lowttxs)
        call espslot
        ld a,(hl)
        or a
        jp z,lowttx8            ;no ESP connection
        ld (lowttxn),a
        ld bc,(lowttxc)
        ld hl,2
        add hl,bc
        ld a,esp_fn_tcpsend
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,(lowttxn):out (esp_io_tx),a
        ld a,1:out (esp_io_tx),a      ;flags - PUSH
        ld hl,esp_buf
        ld bc,(lowttxc)
lowttx3 ld a,(hl):out (esp_io_tx),a
        inc hl
        dec bc
        ld a,b:or c
        jr nz,lowttx3
        ld a,esp_fn_tcpsend
        call esprsp
        push af
        call nc,espskp
        pop af
        jr c,lowttx8            ;no answer
        or a
        jr nz,lowttx8           ;ESP refused (buffer full/closed) -> report partial
        ld a,esp_sta_delay
        ld (esp_sta_tx),a       ;TX light
        ld bc,(lowttxc)
        ld hl,(lowttxd):add hl,bc:ld (lowttxd),hl
        ld hl,(lowttxa):add hl,bc:ld (lowttxa),hl
        ld hl,(lowttxl):or a:sbc hl,bc:ld (lowttxl),hl
        jp lowttx1
lowttx8 ld bc,(lowttxd)
        ld hl,(lowttxl)
        ld a,h
        or l
        ret
lowttxs db 0
lowttxn db 0
lowttxb dw 0
lowttxl dw 0
lowttxa dw 0
lowttxd dw 0
lowttxc dw 0

;### LOWTRX -> TCP receive          LOWTSK -> TCP skip (discard)
;### Input      A=socket, BC=length, E,HL=destination (E=bank)
;### Output     BC=bytes REMAINING in the socket afterwards
;### Destroyed  AF,DE,HL,IX,IY
;  ESP TCP_RCV (18) returns up to the requested size.  Data goes into esp_buf,
;  then is copied to the caller's bank with jmp_bnkcop.
;!!VERIFY  the daemon treats BC after lowtrx as "bytes remaining" (tcprcv in
;          Dmn-Network.asm stores it into sckdatrcv).
lowtsk  ld d,1
        jr lowtrx0
lowtrx  ld d,0
lowtrx0 ld (lowtrxm),de         ;d=mode(1=skip) e=bank
        ld (lowtrxs),a
        ld (lowtrxl),bc
        ld (lowtrxa),hl
        ld a,(esp_pend)
        or a
        jr z,lowtrx1
        ld bc,0                 ;defer the receive until the pending request is done
        ret
lowtrx1 ld bc,(lowtrxl)
        ld a,b
        or c
        jp z,lowtrx9
        ld hl,esp_blen
        or a
        sbc hl,bc
        jr nc,lowtrx2
        ld bc,esp_blen
lowtrx2 ld (lowtrxc),bc         ;chunk size requested
        ld a,(lowtrxs)
        call espslot
        ld a,(hl)
        or a
        jp z,lowtrx9
        ld d,a                  ;d=conn
        ld hl,3
        ld a,esp_fn_tcprcv
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,d:out (esp_io_tx),a
        ld a,(lowtrxc+0):out (esp_io_tx),a
        ld a,(lowtrxc+1):out (esp_io_tx),a
        ld a,esp_fn_tcprcv
        call esprsp
        jp c,lowtrxw
        or a
        jp nz,lowtrxe
        ld a,h
        or l
        jp z,lowtrxw            ;nothing delivered
        dec hl:dec hl           ;minus the 2 urgent-count bytes
        ld (lowtrxn),hl
        call espgtb:jp c,lowtrxw
        call espgtb:jp c,lowtrxw
        ld hl,esp_buf
        ld bc,(lowtrxn)
lowtrx3 ld a,b:or c
        jr z,lowtrx4
        push bc
        ld bc,esp_spin
lowtrx3a in a,(esp_io_tx)
        bit 0,a
        jr nz,lowtrx3b
        dec bc
        ld a,b
        or c
        jr nz,lowtrx3a
        pop bc
        jp lowtrxw
lowtrx3b in a,(esp_io_cmd)
        pop bc
        ld (hl),a
        inc hl
        dec bc
        jr lowtrx3
lowtrx4
        ld a,esp_sta_delay
        ld (esp_sta_rx),a       ;RX light
        ld a,(lowtrxm+1)        ;mode (1=skip)
        or a
        jr nz,lowtrx5           ;skip mode - discard, no copy
        ld a,(App_BnkNum)
        ld e,a                  ;e=own bank (source)
        ld a,(lowtrxm+0)        ;a=caller bank (destination)
        add a:add a:add a:add a
        add e                   ;A=(dest<<4)+src
        ld hl,esp_buf
        ld de,(lowtrxa)         ;caller destination address
        ld bc,(lowtrxn)
        rst #20:dw jmp_bnkcop
lowtrx5 ld bc,(lowtrxn)
        ld hl,(lowtrxa):add hl,bc:ld (lowtrxa),hl
        ld hl,(lowtrxl):or a:sbc hl,bc:ld (lowtrxl),hl
        ld hl,(lowtrxc)
        or a
        sbc hl,bc
        jp z,lowtrx1            ;full chunk delivered -> maybe more
        jr lowtrx9              ;short chunk = ESP has nothing more
lowtrxe call espskp
lowtrxw
lowtrx9 ld a,(lowtrxs)          ;remaining bytes = ask the ESP
        call espstq
        ld bc,0
        ret c
        ld bc,(esp_st_avail)
        ret
lowtrxm dw 0                    ;low=bank (E), high=mode (D)
lowtrxs db 0
lowtrxl dw 0
lowtrxa dw 0
lowtrxc dw 0
lowtrxn dw 0

;### LOWTCL -> close (graceful)      LOWTDC -> disconnect (abort)
;### Input      A=socket
;### Output     A=0
lowtdc  ld c,esp_fn_tcpabort
        jr lowtcl0
lowtcl  ld c,esp_fn_tcpclose
lowtcl0 push bc
        push af
        ld a,(esp_pend)
        or a
        jr z,lowtclg
        pop af
        pop bc
        ld a,neterrcon          ;defer the close until the pending request is done
        scf
        ret
lowtclg pop af
        call espslot
        ld a,(hl)
        ld b,a
        ld (hl),0
        pop de                  ;e=fn
        or a
        ret z                   ;nothing open on the ESP side
        ld a,e
        ld hl,1
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,b
        out (esp_io_tx),a
        ld a,e
        call esprsp
        call nc,espskp
        xor a
        ret

;### LOWTFL -> flush - the ESP has no send buffer to flush
lowtfl  or a
        ret


;------------------------------------------------------------------------------
;--- ACCESS POINT STATE AND NAME ---------------------------------------------
;------------------------------------------------------------------------------
; The ESP firmware has no signal strength command. What it can tell us is the state of
; the WiFi connection and the name of the access point (command g), that is shown in
; the driver tab. State, 0 idle, 1 connecting, 2 wrong password, 3 not found,
; 4 connection failed, 5 connected with an IP.

esp_apst        db 0
esp_ssidn       ds 34           ;access point name as read
esp_ssidt       ds 40           ;the text for the driver tab
esp_ssidchg     db 0            ;set when the text changed, the daemon redraws it
esptxw1         db "WiFi: "
esptxw2         db "WiFi: not connected",0

;### ESPAP -> read access point state and name, update the text of the driver tab
;### Output     CF=0
;### Destroyed  AF,BC,DE,HL
espap
        ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,103                ;g = request access point status
        out (esp_io_tx),a
        ld a,103
        call esprsp
        jp c,espap9
        or a
        jp nz,espap8
        ld a,h
        or l
        jp z,espap8
        call espgtb             ;the state
        jp c,espap9
        ld (esp_apst),a
        dec hl
        ld de,esp_ssidn
        ld b,32
espap1  ld a,h
        or l
        jr z,espap3
        ld a,b
        or a
        jr z,espap2
        call espgtb
        jp c,espap9
        dec hl
        ld (de),a
        inc de
        dec b
        jr espap1
espap2  call espskp             ;name longer than the buffer
espap3  xor a
        ld (de),a
        call espssid
        or a
        ret
espap8  call espskp
espap9
        or a
        ret

;### ESPSSID -> build the driver tab text from state and name, tell the daemon if it changed
espssid ld de,esp_ssidt
        ld a,(esp_apst)
        cp 5
        jr z,espss0
        ld hl,esptxw2           ;not connected
        ld bc,20
        ldir
        jr espss3
espss0  ld hl,esptxw1           ;the text WiFi and then the name
        ld bc,6
        ldir
        ld hl,esp_ssidn
espss1  ld a,(hl)
        ld (de),a
        or a
        jr z,espss3
        inc hl
        inc de
        jr espss1
espss3  nop
        ld hl,esp_ssidt         ;compare with what the tab shows now
        ld de,statxttxr
        ld b,38
espss4  ld a,(de)
        cp (hl)
        jr nz,espss5
        or a
        ret z                   ;same text
        inc hl
        inc de
        djnz espss4
        ret
espss5  ld hl,esp_ssidt
        ld de,statxttxr
        ld bc,39
        ldir
        ld a,1
        ld (esp_ssidchg),a
        ret


;------------------------------------------------------------------------------
;--- UDP ----------------------------------------------------------------------
;------------------------------------------------------------------------------
; UDP is handled state-driven. UDP_STATEX (fn 210, firmware extension) peeks at the oldest
; pending datagram of a connection: count, size and sender, without consuming it, and the
; next UDP_RCV returns exactly that datagram. So the status can be answered without a cache
; and UDP_RCV is only called when the application receives or skips. Firmwares without the
; extension make the status fail: the adapter line then shows "UDP state err" and the driver
; backs off for a while before it tries again.

esp_fn_udpopen  equ 8
esp_fn_udpclose equ 9
esp_fn_udpsend  equ 11
esp_fn_udprcv   equ 12
esp_fn_udpstatex equ 210        ;UDP_STATEX, firmware extension
esp_udpmax      equ 1468        ;largest UDP payload handled (1500 bytes total with IP/UDP headers)
esp_udpmaxl     equ #BC         ;1468 = #05BC
esp_udpmaxh     equ #05

esp_uconn       ds low_sockmax  ;ESP connection number per daemon socket, 0 = none
esp_ucnt        db 0            ;UDP_STATEX: pending datagrams
esp_usiz        dw 0            ;size of the oldest one
esp_usnd        ds 6            ;its sender: IP (4), port (2)
esp_ul2         dw 0            ;temporary payload length
esp_udw         db 0            ;polls to wait after a UDP_STATEX failure
esp_udps        db 0            ;UDP line state, 0 = clear, 1 = error
esp_udpchg      db 0            ;1 = driver tab UDP line needs a redraw
esp_usck        db 0
esp_ucn         db 0
esp_utxs        db 0
esp_utxl        dw 0            ;length of the datagram to send
esp_utxh        ds 6            ;destination IP (4) and port (2)
lowutxb         db 0
lowutxa         dw 0
lowurxb         db 0
lowurxa         dw 0
lowurxl         dw 0            ;receive: largest length the caller accepts
esp_urxn        dw 0            ;receive: data length of the datagram just fetched
esp_udpbuf      ds esp_udpmax  ;UDP send/receive are serialized, so one buffer is enough
esp_utxb        equ esp_udpbuf
esp_urxb        equ esp_udpbuf
esptxu0         db 0            ;blank UDP line (25 bytes, copied as is)
                ds 24
esptxu1         db "UDP error: update ESP FW",0

;### ESPUSLT -> HL=address of the esp_uconn entry of socket A
espuslt ld c,a
        ld b,0
        ld hl,esp_uconn
        add hl,bc
        ret

;### LOWUOP -> open UDP socket
;### Input      A=socket, IX=parameter block, (IX+0)=local port
;### Output     CF=0 ok, CF=1 A=error
;### Destroyed  AF,BC,DE,HL,IX
lowuop  push af
        ld a,(esp_pend)
        or a
        jr z,lowuopg
        pop af
        ld a,neterrcon          ;defer the open until the pending request is done
        scf
        ret
lowuopg ld a,(ix+0)             ;read the parameter into the transfer area
        ld (esp_tmp+0),a
        ld a,(ix+1)
        ld (esp_tmp+1),a
        pop af
        ld (esp_usck),a
        ld hl,3
        ld a,esp_fn_udpopen
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,(esp_tmp+0):out (esp_io_tx),a
        ld a,(esp_tmp+1):out (esp_io_tx),a
        xor a:out (esp_io_tx),a       ;transient connection, UDP_CLOSE 0 can clean up after a crash
        ld a,esp_fn_udpopen
        call esprsp
        jp c,lowuop8
        or a
        jp nz,lowuop7
        call espgtb             ;the connection number
        jp c,lowuop8
        ld (esp_ucn),a
        ld a,(esp_usck)
        call espuslt
        ld a,(esp_ucn)
        ld (hl),a
        or a
        ret
lowuop7 call espskp
        ld a,neterrsfr          ;the ESP has no free connection
        scf
        ret
lowuop8
lowuop9 ld a,neterrcon
        scf
        ret
lowuop0 equ lowuop

;### LOWUCL -> close UDP socket
;### Input      A=socket
;### Output     A=0
lowucl  ld (esp_usck),a
        ld a,(esp_pend)
        or a
        jr z,lowuclg
        ld a,neterrcon          ;defer the close until the pending request is done
        scf
        ret
lowuclg ld a,(esp_usck)
        call espuslt
        ld a,(hl)
        ld (esp_ucn),a
        ld (hl),0
        ld a,(esp_ucn)
        or a
        ret z
        ld hl,1
        ld a,esp_fn_udpclose
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,(esp_ucn)
        out (esp_io_tx),a
        ld a,esp_fn_udpclose
        call esprsp
        call nc,espskp
        xor a
        ret

;### ESPUCL0 -> UDP_CLOSE with connection 0 = close all transient UDP connections of the ESP
espucl0
        ld hl,1
        ld a,esp_fn_udpclose
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        xor a
        out (esp_io_tx),a
        ld a,esp_fn_udpclose
        call esprsp
        call nc,espskp
        ret

;### LOWUTX -> send a datagram
;### Input      A=socket, HL=data, E=data bank, BC=length, IX=destination (IP 4 bytes, port 2 bytes)
;### Output     CF=0 sent, CF=1 A=error
;### Destroyed  AF,BC,DE,HL,IX,IY
lowutx  ld (esp_utxs),a
        ld a,(esp_pend)
        or a
        jr z,lowutxg
        ld a,neterrcon          ;defer the datagram until the pending request is done
        scf
        ret
lowutxg ld a,e
        ld (lowutxb),a
        ld (esp_utxl),bc
        ld (lowutxa),hl
        ld hl,esp_udpmax
        or a
        sbc hl,bc
        ld a,neterrdln          ;datagram too large
        jp c,lowutxe
        push ix
        pop hl
        ld de,esp_utxh          ;destination into the transfer area
        ld bc,6
        ldir
        ld bc,(esp_utxl)
        ld a,b
        or c
        jr z,lowutx0
        ld a,(App_BnkNum)       ;data from the caller's bank, A=(dest<<4)+src
        add a:add a:add a:add a
        ld hl,lowutxb
        add (hl)
        ld hl,(lowutxa)
        ld de,esp_utxb
        rst #20:dw jmp_bnkcop
lowutx0 ld a,(esp_utxs)
        call espuslt
        ld a,(hl)
        or a
        jp z,lowutxc            ;no ESP connection
        ld (esp_ucn),a
        ld hl,(esp_utxl)
        ld de,7                 ;connection, IP and port come before the data
        add hl,de
        ld a,esp_fn_udpsend
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,(esp_ucn):out (esp_io_tx),a
        ld hl,esp_utxh
        ld b,6
lowutx1 ld a,(hl):out (esp_io_tx),a
        inc hl
        djnz lowutx1
        ld hl,esp_utxb
        ld bc,(esp_utxl)
lowutx2 ld a,b
        or c
        jr z,lowutx3
        ld a,(hl):out (esp_io_tx),a
        inc hl
        dec bc
        jr lowutx2
lowutx3 ld a,150                ;the ESP may need a while to send (the BIOS waits 600 ticks)
        ld (esp_wdef),a
        ld a,esp_fn_udpsend
        call esprsp
        push af
        ld a,20
        ld (esp_wdef),a
        pop af
        push af
        call nc,espskp
        pop af
        jr c,lowutxc
        or a
        jr nz,lowutxc
        ld a,esp_sta_delay
        ld (esp_sta_tx),a       ;TX light
        or a
        ret
lowutxc ld a,neterrcon
lowutxe scf
        ret

;### ESPUST -> UDP_STATEX: peek at the oldest datagram of connection (esp_ucn)
;### Output     CF=0 ok - (esp_ucnt)=count, (esp_usiz)=size, (esp_usnd)=sender
;###            CF=1 no answer / error return code / malformed payload
espust  ld a,esp_fn_udpstatex
        out (esp_io_tx),a
        xor a
        out (esp_io_tx),a       ;length MSB
        ld a,1
        out (esp_io_tx),a       ;length LSB
        ld a,(esp_ucn)
        out (esp_io_tx),a
        ld a,4
        ld (esp_wdef),a         ;a status poll must not wait long
        ld a,esp_fn_udpstatex
        call esprsp
        push af
        ld a,20
        ld (esp_wdef),a         ;restore the default
        pop af
        jr c,espustt           ;no response
        cp 1
        jr z,espust9            ;command not implemented
        cp 15
        jr z,espust9            ;invalid operation
        or a
        jr nz,espustn           ;another error code, treat as no data
        ld a,h
        or a
        jr nz,espust8           ;more than 255 bytes can not be right here
        ld a,l
        cp 9
        jr c,espust8            ;shorter than UDP_STATEX defines
        ld (esp_ul2),hl
        call espgtb:jr c,espust9:ld (esp_ucnt),a
        call espgtb:jr c,espust9:ld (esp_usiz+0),a
        call espgtb:jr c,espust9:ld (esp_usiz+1),a
        ld b,6                  ;sender IP and port
        ld hl,esp_usnd
espust1 call espgtb
        jr c,espust9
        ld (hl),a
        inc hl
        djnz espust1
        ld hl,(esp_ul2)
        ld de,9
        or a
        sbc hl,de
        jr z,espust2
        call espskp             ;drop an unexpected tail
        ret c
espust2 xor a
        ret
espust8 call espskp             ;drop the implausible payload
espust9 scf
        ret
espustn xor a                   ;the ESP answered, it just has no data
        ld (esp_ucnt),a
        or a
        ret
espustt                         ;timeout: resync a firmware that does not know fn 210
        xor a                   ;it took the 0x01 length byte as a command (GET_CAPAB)
        out (esp_io_tx),a       ;and waits for length LSB 0 ...
        ld a,(esp_ucn)
        or a
        jr z,espust9
espustt1 push af                ;... plus conn*256 payload bytes
        ld b,0
        xor a
espustt2 out (esp_io_tx),a
        djnz espustt2
        pop af
        dec a
        jr nz,espustt1
        jr espust9

;### ESPURCV -> fetch the oldest datagram of connection (esp_ucn) into esp_urxb
;### Output     CF=0 ok ((esp_urxn)=data length), CF=1 failed
espurcv
        ld hl,3
        ld a,esp_fn_udprcv
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld a,(esp_ucn):out (esp_io_tx),a
        ld a,esp_udpmaxl:out (esp_io_tx),a
        ld a,esp_udpmaxh:out (esp_io_tx),a
        ld a,esp_fn_udprcv
        call esprsp
        jp c,espurc9
        or a
        jp nz,espurc8
        push hl
        ld de,esp_udpmax+7      ;6 bytes of address plus the data, must fit
        or a
        sbc hl,de
        pop hl
        jp nc,espurc8
        push hl
        ld de,6
        or a
        sbc hl,de
        pop hl
        jp c,espurc8            ;shorter than the address part, not valid
        ld (esp_ul2),hl
        ld b,6                  ;sender, already known from the status
espurc1 call espgtb
        jp c,espurc9
        djnz espurc1
        ld hl,(esp_ul2)
        ld de,6
        or a
        sbc hl,de
        ld (esp_urxn),hl        ;data length
        ld de,esp_urxb
espurc2 ld a,h
        or l
        jr z,espurc3
        ld bc,esp_spin
espurc2a in a,(esp_io_tx)
        bit 0,a
        jr nz,espurc2b
        dec bc
        ld a,b
        or c
        jr nz,espurc2a
        jp espurc9
espurc2b in a,(esp_io_cmd)
        ld (de),a
        inc de
        dec hl
        jr espurc2
espurc3 nop
        or a
        ret
espurc8 call espskp
espurc9
        scf
        ret

;### LOWUST -> status of a UDP socket (non-destructive peek at the ESP)
;### Input      A=socket
;### Output     A=status, 0 in process, 3 idle, +128 datagram waiting
;###            BC=its length, IX,IY=sender IP, DE=sender port
;### Destroyed  F,HL
lowust  ld (esp_usck),a
        ld a,(esp_pend)
        or a
        jr z,lowustg
        xor a                   ;in process - do not touch the ESP while another request is pending
        ld bc,0
        ld hl,0
        ld ix,0
        ld iy,0
        ld de,0
        ret
lowustg ld a,(esp_usck)
        call espuslt
        ld a,(hl)
        or a
        jr z,lowusti            ;no ESP connection -> idle
        ld (esp_ucn),a
        ld a,(esp_udw)
        or a
        jr nz,lowustw           ;back-off after a UDP_STATEX failure
        call espust
        jr c,lowuste
        xor a
        call espudpt            ;the ESP answered, clear the UDP line
        ld a,(esp_ucnt)
        or a
        jr z,lowusti            ;nothing is waiting
        ld bc,(esp_usiz)        ;the application gets at most esp_udpmax bytes
        ld hl,esp_udpmax
        or a
        sbc hl,bc
        jr nc,lowust5
        ld bc,esp_udpmax
lowust5 ld ix,(esp_usnd+0)
        ld iy,(esp_usnd+2)
        ld de,(esp_usnd+4)
        ld a,(esp_ucnt)
        ld h,a
        ld a,131                ;idle plus data waiting
        ret
lowustw dec a
        ld (esp_udw),a
        jr lowusti
lowuste ld a,50                 ;about a second at the normal poll rate
        ld (esp_udw),a
        ld a,1
        call espudpt            ;"UDP error: update ESP FW"
lowusti ld bc,0
        ld hl,0
        ld ix,0
        ld iy,0
        ld de,0
        ld a,3                  ;idle
        ret

;### LOWURX -> receive the waiting datagram from the ESP into the caller's memory
;### Input      A=socket, BC=maximum length (0 = whole datagram), E=destination bank, HL=destination
;### Output     CF=0 ok, BC=bytes copied, CF=1 nothing there / transfer failed
;### Destroyed  AF,BC,DE,HL
lowurx  ld (esp_usck),a
        ld a,(esp_pend)
        or a
        jr z,lowurxg
        scf                     ;defer the receive until the pending request is done
        ret
lowurxg ld a,e
        ld (lowurxb),a
        ld (lowurxa),hl
        ld (lowurxl),bc
        ld a,(esp_usck)
        call espuslt
        ld a,(hl)
        or a
        jr z,lowurxe            ;no ESP connection
        ld (esp_ucn),a
        call espurcv
        jr c,lowurxe
        ld bc,(esp_urxn)        ;the complete datagram length
        ld hl,(lowurxl)         ;requested maximum (0 = whole datagram)
        ld a,h
        or l
        jr z,lowurx1            ;BC=0: copy everything
        or a
        sbc hl,bc
        jr nc,lowurx1           ;request >= datagram: copy everything
        ld bc,(lowurxl)         ;request smaller: truncate and discard the rest
lowurx1 ld a,b
        or c
        jr z,lowurx2
        ld a,(lowurxb)          ;A=(dest<<4)+src
        add a:add a:add a:add a
        ld hl,App_BnkNum
        add (hl)
        ld hl,esp_urxb
        ld de,(lowurxa)
        rst #20:dw jmp_bnkcop
lowurx2 ld a,esp_sta_delay
        ld (esp_sta_rx),a       ;RX light
        or a
        ret
lowurxe scf
        ret

;### LOWUSK -> throw the waiting datagram away (receives and discards it)
;### Input      A=socket
;### Destroyed  AF,BC,DE,HL
lowusk  ld (esp_usck),a
        ld a,(esp_pend)
        or a
        jr z,lowuskg
        scf                     ;defer the skip until the pending request is done
        ret
lowuskg ld a,(esp_usck)
        call espuslt
        ld a,(hl)
        or a
        ret z                   ;no ESP connection
        ld (esp_ucn),a
        call espurcv            ;consume it, the data is not needed
        ret


;------------------------------------------------------------------------------
;--- DNS (replaces m4cdns / m4cdnr in the M4Board high-level path) ------------
;------------------------------------------------------------------------------

;### ESPDNS -> start DNS request (blocking on the wire, so - send now, poll later)
;### Input      HL=domain string (0-terminated, in own bank)
;### Output     CF=1 on error
espdns  ld a,(esp_pend)
        or a
        scf
        ret nz
        ld de,esp_dnsb          ;copy the name into the transfer area, max 63 chars
        ld bc,0
espdns1 ld a,(hl)
        ld (de),a
        or a
        jr z,espdns2
        inc hl
        inc de
        inc bc
        ld a,c
        cp 63
        jr c,espdns1
        xor a                   ;too long, cut and terminate
        ld (de),a
espdns2 ld (esp_dnsl),bc        ;length without the terminator
        ld hl,(esp_dnsl)
        inc hl                  ;plus the flag byte
        ld a,esp_fn_dnsq
        out (esp_io_tx),a
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        xor a
        out (esp_io_tx),a             ;flags = 0
        ld hl,esp_dnsb
        ld bc,(esp_dnsl)
espdns3 ld a,b
        or c
        jr z,espdns4
        ld a,(hl)
        out (esp_io_tx),a
        inc hl
        dec bc
        jr espdns3
espdns4
        ld a,esp_fn_dnsq
        ld (esp_pend),a
        ld a,1
        ld (esp_dnsst),a
        or a
        ret

;### ESPDNP -> poll outstanding DNS reply (called from esppol)
espdnp
        ld a,esp_fn_dnsq
        call esprsp0
        jr c,espdnp9
        or a
        jr nz,espdnp5
        call espgtb:jr c,espdnp9:ld (esp_dnsres+0),a
        call espgtb:jr c,espdnp9:ld (esp_dnsres+1),a
        call espgtb:jr c,espdnp9:ld (esp_dnsres+2),a
        call espgtb:jr c,espdnp9:ld (esp_dnsres+3),a
        ld a,2
        jr espdnp7
espdnp5 call espskp
        ld a,3
espdnp7 ld (esp_dnsst),a
        xor a
        ld (esp_pend),a
        ret
espdnp9
        ret

;### ESPDNR -> DNSRQR equivalent
;### Output     CF=0 -> IP in IX,IY ; CF=1 -> A=0 still in progress, >0 error
espdnr  call esppol
        ld a,(esp_dnsst)
        cp 2
        jr z,espdnr1
        cp 3
        jr z,espdnr2
        xor a                   ;still in progress
        scf
        ret
espdnr1 xor a
        ld (esp_dnsst),a
        ld ix,(esp_dnsres+0)
        ld iy,(esp_dnsres+2)
        or a
        ret
espdnr2 xor a
        ld (esp_dnsst),a
        ld a,neterrdto          ;ESP gives no detail on DNS failure
        scf
        ret
;------------------------------------------------------------------------------
;--- Wi-Fi scan / connect (custom firmware commands) --------------------------
;------------------------------------------------------------------------------
esp_pay         dw 0            ;payload address for ESPCONN
esp_pyl         dw 0            ;payload length
scanptr         dw 0            ;current entry during the scan parse

;### ESPQR -> wait for a quick response [fn][rc]
;### Input      A=expected fn, B=frames to wait (0 = only the byte spin)
;### Output     CF=0 A=rc, CF=1 timeout
;### Destroyed  AF,BC,DE,HL
espqr   ld d,a
        ld a,b
        ld (esp_wcnt),a
espqr1  call espgtb
        jr nc,espqr2
        ld a,(esp_wcnt)
        or a
        jr z,espqr9
        dec a
        ld (esp_wcnt),a
        halt
        rst #30
        jr espqr1
espqr2  cp d
        jr z,espqr3
        ld a,(esp_wcnt)         ;unrelated byte, costs one frame too
        or a
        jr z,espqr9
        dec a
        ld (esp_wcnt),a
        jr espqr1
espqr3  call espgtb             ;the return code
        ret c
        or a                    ;CF=0
        ret
espqr9  scf
        ret

;### ESPSCAN -> start a Wi-Fi scan
;### Output     CF=0 ok, CF=1 failed (busy / no answer / error code)
espscan ld a,(esp_pend)
        or a
        scf
        ret nz
        ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_scan
        out (esp_io_tx),a
        ld b,100                ;wait up to about two seconds
        ld a,esp_cmd_scan
        call espqr
        ret c
        or a
        ret z
        scf
        ret

;### ESPSCANR -> read the scan results
;### Output     CF=0 A=status (0=done, 2=none/failed, 3=running, else error)
;###            on done: (scantot)=found, (scancnt)=stored, scanap filled
;###            CF=1 no answer
;### The entries are 68 bytes: raw SSID (33), encryption (1), display SSID (33), pad
espscanr
        ld a,(esp_pend)
        or a
        scf
        ret nz
        ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_scanr
        out (esp_io_tx),a
        ld b,50
        ld a,esp_cmd_scanr
        call espqr
        jp c,espscr9
        or a
        jp nz,espscr8           ;running / failed / other
        call espgtb             ;number of access points
        jp c,espscr9
        ld (scantot),a
        ld c,a
        xor a
        ld (scancnt),a
        ld hl,scanap
        ld (scanptr),hl
espscr1 ld a,c
        or a
        jp z,espscr7
        ld a,(scancnt)
        cp SCANMAX
        jr nc,espscrd
        ld ix,(scanptr)
        push ix
        pop hl
        ld de,34
        add hl,de
        push hl
        pop iy                  ;IY=display string
        ld b,32
espscr2 call espgtb
        jr c,espscr9
        or a
        jr z,espscr4
        ld (ix+0),a             ;raw byte
        inc ix
        cp 32
        jr c,espscr3
        cp 130
        jr c,espscr3b
espscr3 ld a,"?"
espscr3b ld (iy+0),a            ;display byte
        inc iy
        dec b
        jr nz,espscr2
espscr3c call espgtb            ;too long, discard the rest
        jr c,espscr9
        or a
        jr nz,espscr3c
espscr4 ld (ix+0),0
        ld (iy+0),0
        call espgtb             ;encryption byte
        jr c,espscr9
        ld hl,(scanptr)
        ld de,33
        add hl,de
        cp "O"
        jr z,espscr5
        ld (hl),1
        jr espscr6
espscr5 ld (hl),0
espscr6 ld hl,(scanptr)
        ld de,68
        add hl,de
        ld (scanptr),hl
        ld hl,scancnt
        inc (hl)
        dec c
        jp nz,espscr1
        jr espscr7
espscrd call espgtb             ;more than SCANMAX, read and drop
        jr c,espscr9
        or a
        jr nz,espscrd
        call espgtb
        jr c,espscr9
        dec c
        jp nz,espscr1
espscr7 xor a
        ret
espscr8 or a
        ret
espscr9 ld a,esp_cmd_clrfifo  ;drop a partial list
        out (esp_io_cmd),a
        scf
        ret

;### ESPCONN -> connect to an access point (blocking, the ESP needs up to 10s)
;### Input      HL=payload (SSID, 0, optional password), BC=length
;### Output     CF=0 ok, CF=1 A=#FE busy / #FF no answer / else the ESP rc
espconn ld a,(esp_pend)
        or a
        jr z,espcon1
        ld a,#FE
        scf
        ret
espcon1 ld (esp_pay),hl
        ld (esp_pyl),bc
        ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_conn
        out (esp_io_tx),a
        ld a,b
        out (esp_io_tx),a
        ld a,c
        out (esp_io_tx),a
        ld hl,(esp_pay)
        ld bc,(esp_pyl)
espcon2 ld a,(hl)
        out (esp_io_tx),a
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,espcon2
        ld e,3
espcon3 ld b,255
        ld a,esp_cmd_conn
        call espqr
        jr nc,espcon4
        dec e
        jr nz,espcon3
        ld a,esp_cmd_clrfifo    ;drop a late reply
        out (esp_io_cmd),a
        ld a,#FF
        scf
        ret
espcon4 or a
        ret z
        scf                     ;A=the ESP return code
        ret

;### ESPDISC -> forget the current access point (quick response 'a')
;### Output     CF=0 ok, CF=1 A=#FE busy / #FF no answer / else the ESP rc
espdisc ld a,(esp_pend)
        or a
        jr z,espdi1
        ld a,#FE
        scf
        ret
espdi1  ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_disc
        out (esp_io_tx),a
        ld b,100                ;wait up to about two seconds
        ld a,esp_cmd_disc
        call espqr
        jr c,espdi9
        or a
        ret z
        scf
        ret
espdi9  ld a,#FF
        scf
        ret

;### ESPSETQ -> read Nagle and the Wi-Fi-on timer (command Q, "ON:<secs>"/"OFF:<secs>")
;### Output     CF=0, (esp_nagle)=0/1, (esp_timer)=seconds; CF=1 on failure
espsetq ld a,(esp_pend)
        or a
        scf
        ret nz
        ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_setq
        out (esp_io_tx),a
        ld a,esp_cmd_setq
        call esprsp
        ret c
        or a
        scf
        ret nz
        ld de,esp_setq
        ld b,15
esetq1  ld a,h
        or l
        jr z,esetq2
        push hl
        push de
        call espgtb
        pop de
        pop hl
        jr c,esetq9
        ld (de),a
        inc de
        dec hl
        djnz esetq1
esetq2  xor a
        ld (de),a
        ld hl,esp_setq
        ld a,(hl)
        cp "O"
        scf
        ret nz
        inc hl
        ld a,(hl)
        cp "N"
        jr z,esetq4
        cp "F"
        scf
        ret nz
        inc hl
        ld a,(hl)
        cp "F"
        scf
        ret nz
        xor a
        jr esetq5
esetq4  ld a,1
esetq5  ld (esp_nagle),a
esetq6  ld a,(hl)
        inc hl
        or a
        scf
        ret z
        cp ":"
        jr nz,esetq6
        ld de,0
esetq7  ld a,(hl)
        inc hl
        sub "0"
        jr c,esetq8
        cp 10
        jr nc,esetq8
        ld b,a
        push hl
        ex de,hl
        add hl,hl
        ld d,h
        ld e,l
        add hl,hl
        add hl,hl
        add hl,de
        ex de,hl
        ld l,b
        ld h,0
        add hl,de
        ex de,hl
        pop hl
        jr esetq7
esetq8  ld (esp_timer),de
        or a
        ret
esetq9  scf
        ret

;### ESPNAG -> set Nagle on/off (quick response)
;### Input      A=0 off, 1 on
;### Output     CF=0 ok, CF=1 A=#FE busy / #FF no answer / else the ESP rc
espnag  ld (esp_nagt),a
        ld a,(esp_pend)
        or a
        jr z,esnag1
        ld a,#FE
        scf
        ret
esnag1  ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_nagle0
        ld hl,esp_nagt
        bit 0,(hl)
        jr z,esnag2
        ld a,esp_cmd_nagle
esnag2  out (esp_io_tx),a
        ld b,100
        ld a,esp_cmd_nagle0
        bit 0,(hl)
        jr z,esnag3
        ld a,esp_cmd_nagle
esnag3  call espqr
        jr c,esnag9
        or a
        ret z
        scf
        ret
esnag9  ld a,#FF
        scf
        ret

;### ESPTIM -> set the Wi-Fi-on timer (quick response)
;### Input      HL=seconds (0=always on)
;### Output     CF=0 ok, CF=1 A=#FE busy / #FF no answer / else the ESP rc
esptim  ld (esp_timv),hl
        ld a,(esp_pend)
        or a
        jr z,estm1
        ld a,#FE
        scf
        ret
estm1   ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_timer
        out (esp_io_tx),a
        xor a
        out (esp_io_tx),a
        ld a,2
        out (esp_io_tx),a
        ld hl,(esp_timv)
        ld a,h
        out (esp_io_tx),a
        ld a,l
        out (esp_io_tx),a
        ld b,100
        ld a,esp_cmd_timer
        call espqr
        jr c,estm9
        or a
        ret z
        scf
        ret
estm9   ld a,#FF
        scf
        ret

;### ESPVER -> read the firmware version ('V' + two raw digits)
;### Output     CF=0, (esp_vermaj/min)=raw digits; CF=1 no answer
espver  ld a,(esp_pend)
        or a
        scf
        ret nz
        ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_ver
        out (esp_io_tx),a
        ld a,100
        ld (esp_wcnt),a
esver1  call espgtw
        jr c,esver9
        cp esp_cmd_ver
        jr z,esver2
        jr esver1
esver2  call espgtb
        jr c,esver9
        cp 10
        jr nc,esver9
        ld (esp_vermaj),a
        call espgtb
        jr c,esver9
        cp 10
        jr nc,esver9
        ld (esp_vermin),a
        or a
        ret
esver9  ld a,#FF
        scf
        ret

esp_nagle       db 0            ;0=off, 1=on as read by Q
esp_timer       dw 0            ;radio off timer in seconds (0=always on)
esp_vermaj      db 0            ;firmware version digits, raw values
esp_vermin      db 0
esp_nagt        db 0            ;Nagle set request
esp_timv        dw 0            ;timer set request
esp_setq        ds 16           ;settings string buffer
esp_board       ds 40           ;ESP32 board name from command b


;### ESPCHIP -> detect an ESP32 (command b, ESP32 only)
;### Output     A=1 ESP32, A=0 ESP8266 (no answer)
espchip ld a,(esp_pend)
        or a
        jr nz,espch8
        ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_gettype
        out (esp_io_tx),a
        ld a,20                 ;about 0.4s, the ESP8266 does not answer
        ld (esp_wcnt),a
espch1  call espgtw
        jr c,espch8
        cp esp_cmd_gettype
        jr nz,espch1
        call espgtb
        jr c,espch8
        or a
        jr nz,espch8
        call espgtb
        jr c,espch8
        or a
        jr nz,espch8
        ;ESP32 answers with a length byte and the board name
        ld hl,esp_board
        ld (hl),0
        ld a,100
        ld (esp_wcnt),a
        call espgtw
        jr c,espchb
        ld c,a
        ld b,39
espch2  ld a,c
        or a
        jr z,espch4
        call espgtb
        jr c,espchb
        ld e,a
        ld a,b
        or a
        jr z,espch3
        ld a,e
        ld (hl),a
        inc hl
        dec b
espch3  dec c
        jr espch2
espch4  xor a
        ld (hl),0
        ld a,1
        ret
espchb  xor a
        ld (hl),0
        ld a,1
        ret
espch8  xor a
        ret

;### ESPUPSTART -> start an RS232 update (Z firmware / Y certificates)
;### Input      A=0 certificates, 1 firmware; HL=12 byte payload (size 8 LE + first 4)
;### Output     CF=0 ok, CF=1 A=#FE busy / #FF no answer / else the ESP rc
espupstart
        ld (esp_upcmd),a
        ld (esp_uppay),hl
        ld a,(esp_pend)
        or a
        jr z,esups1
        ld a,#FE
        scf
        ret
esups1  ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_upcert
        ld hl,esp_upcmd
        bit 0,(hl)
        jr z,esups2
        ld a,esp_cmd_upstart
esups2  out (esp_io_tx),a
        xor a
        out (esp_io_tx),a
        ld a,12
        out (esp_io_tx),a
        ld hl,(esp_uppay)
        ld b,12
esups3  ld a,(hl)
        out (esp_io_tx),a
        inc hl
        djnz esups3
        ld b,250                ;about 5 seconds for Update.begin
        ld a,esp_cmd_upcert
        ld hl,esp_upcmd
        bit 0,(hl)
        jr z,esups4
        ld a,esp_cmd_upstart
esups4  call espqr
        jr c,esups9
        or a
        ret z
        scf
        ret
esups9  ld a,#FF
        scf
        ret

;### ESPUPDAT -> ESP32 firmware type validation (command B)
;### Input      HL=buffer, BC=length
;### Output     CF=0 ok, CF=1 A=#FE busy / #FF no answer / else the ESP rc
espupdat
        ld (esp_uppay),hl
        ld (esp_uppyl),bc
        ld a,(esp_pend)
        or a
        jr z,esupd1
        ld a,#FE
        scf
        ret
esupd1  ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_settype
        out (esp_io_tx),a
        ld a,b
        out (esp_io_tx),a
        ld a,c
        out (esp_io_tx),a
        ld hl,(esp_uppay)
        ld bc,(esp_uppyl)
esupd2  ld a,(hl)
        out (esp_io_tx),a
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,esupd2
        ld b,100
        ld a,esp_cmd_settype
        call espqr
        jr c,esupd9
        or a
        ret z
        scf
        ret
esupd9  ld a,#FF
        scf
        ret

;### ESPUPBLK -> send one RS232 update block (command z)
;### Input      HL=buffer, BC=length
;### Output     CF=0 ok, CF=1 A=#FE busy / #FF no answer / else the ESP rc
espupblk
        ld (esp_uppay),hl
        ld (esp_uppyl),bc
        ld a,(esp_pend)
        or a
        jr z,esupb1
        ld a,#FE
        scf
        ret
esupb1  ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_upblk
        out (esp_io_tx),a
        ld a,b
        out (esp_io_tx),a
        ld a,c
        out (esp_io_tx),a
        ld hl,(esp_uppay)
        ld bc,(esp_uppyl)
esupb2  ld a,(hl)
        out (esp_io_tx),a
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,esupb2
        ld e,3                  ;up to about 15 seconds
esupb3  ld b,255
        ld a,esp_cmd_upblk
        call espqr
        jr nc,esupb4
        dec e
        jr nz,esupb3
        ld a,#FF
        scf
        ret
esupb4  or a
        ret z
        scf
        ret

;### ESPUPEND -> finish the RS232 update (command E; the ESP flashes and restarts)
;### Output     CF=0 ok, CF=1 A=#FE busy / #FF no answer / else the ESP rc
espupend
        ld a,(esp_pend)
        or a
        jr z,esupe1
        ld a,#FE
        scf
        ret
esupe1  ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_upend
        out (esp_io_tx),a
        ld e,8                  ;up to about 40 seconds
esupe2  ld b,255
        ld a,esp_cmd_upend
        call espqr
        jr nc,esupe3
        dec e
        jr nz,esupe2
        ld a,#FF
        scf
        ret
esupe3  or a
        ret z
        scf
        ret

;### ESPUPREADY -> reset, wait for the ESP "Ready" boot message
;### Output     CF=0 ok, CF=1 no answer
espupready
        ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,"R"
        out (esp_io_tx),a
        ld e,30                 ;about 60 seconds
        ld b,0
        ld hl,esptxready
espur1  ld a,100
        ld (esp_wcnt),a
        push de
        push hl
        push bc
        call espgtw
        pop bc
        pop hl
        pop de
        jr c,espur8
        cp (hl)
        jr z,espur2
        ld b,0
        ld hl,esptxready
        cp (hl)
        jr nz,espur1
espur2  inc hl
        inc b
        ld a,b
        cp 7
        jr nz,espur1
        or a
        ret
espur8  dec e
        jr nz,espur1
        scf
        ret
esptxready db "Ready",13,10

;### ESPUPIDX -> build the certificate index (command I)
;### Output     CF=0 ok, CF=1 no answer / error
espupidx
        ld a,esp_cmd_clrfifo
        out (esp_io_cmd),a
        ld a,esp_cmd_upidx
        out (esp_io_tx),a
        ld e,12                 ;up to about 60 seconds
espui1  ld b,200
        ld a,esp_cmd_upidx
        call espqr
        jr nc,espui2
        dec e
        jr nz,espui1
        scf
        ret
espui2  or a
        ret z
        scf
        ret

esp_upcmd       db 0
esp_uppay       dw 0
esp_uppyl       dw 0