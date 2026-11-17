;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@               S y m b O S   -   N e t w o r k - D a e m o n                @
;@                   (default application texts [english])                    @
;@                                                                            @
;@             (c) 2015-2025 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@  OCM Wi-Fi daemon based on the msx-picoverse-symbos-network-daemon by      @
;@  Jzzy: https://github.com/Jzzy-dev/msx-picoverse-symbos-network-daemon     @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;### DIRECT TEXT VARIANT - the 3-byte text pointer list has been removed,
;### every text label now points straight at its string










;config dialogue text data







;### TEXTS ####################################################################

prgtxtoky   db "Ok",0
prgtxtcnc   db "Cancel",0

stamentxt1  db "File",0
stamentxt2  db "?",0
stamentxt11_poi   db " Hide on startup",0
stamentxt12_poi   db " Reset all connections",0
stamentxt13_poi   db " Quit",0
stamentxt21_poi   db " Index",0
stamentxt22_poi   db " About",0

statxttit   db "Network daemon",0
statxtbta   db "Hide",0
statxtbtb   db "Network settings",0
statxtbtc   db "Apply",0
statxtbtd   db "Disconnect",0

statxttba1  db "Status",0
statxttba3  db "Driver",0

statxtfra   db "Network status",0

statxttxc   db "Status",0
statxttxd   db "Connections",0
statxttxe   db "Maximum",0
statxttxf   db "Sent",0
statxttxg   db "Received",0

statxttxh   db "Type",0
statxttxh1  db "Manually set",0

statxtfrb   db "IP settings",0
statxtfrc   db "DNS settings",0

statxtfrd   db "Status",0
statxtfre   db "OCM Wi-Fi v0.9",0
statxtfrf   db "Localhost Settings",0
statxtfrg   db "GR8NET Settings",0
statxtfrh   db "M4 Board Settings",0
statxtfri   db "Net4CPC Settings",0

;config dialogue text data
cfgtxttit   db "TCP/IP properties",0

cfgtxttba1  db "IP address",0
cfgtxttba2  db "DNS & Hostname",0

cfgtxttxa   db "You can get IP settings assigned automatically",0
cfgtxttxb   db "if your network supports this capability.",0
cfgtxttxc   db "Otherwise, you need to ask your network admin",0
cfgtxttxd   db "for the appropriate IP settings.",0

cfgtxttxf   db "IP address",0
cfgtxttxg   db "Subnet mask",0
cfgtxttxh   db "Default gateway",0

cfgtxttxi   db "Hostname",0
cfgtxttxj   db "Primary DNS",0
cfgtxttxk   db "Secondary DNS",0

cfgtxtrda   db "Obtain an IP address automatically",0
cfgtxtrdb   db "Use the following IP address ",0
cfgtxtrdc   db "Obtain DNS server addresses automatically",0
cfgtxtrdd   db "Use the following DNS server addresses ",0

cfgerrtxt0  db "Wrong IP format",0
cfgerrtxt1  db "Please enter a correct",0
cfgerrtxt2  db "number between 0 and 255.",0
cfgerrtxtnil db 0
cfgerrtxt02a db "Manual IP requires manual DNS",0
cfgerrtxt02b db "servers. Choose automatic IP as",0
cfgerrtxt02c db "well, or set the DNS manually.",0
cfgerrtxtbza db "The ESP is busy.",0
cfgerrtxtbzb db "Please try again.",0
cfgerrtxtnsa db "The ESP did not answer.",0
cfgerrtxtnsb db "Check the adapter connection.",0
cfgerrtxtrja db "The ESP rejected the network",0
cfgerrtxtrjb db "settings. Please check the",0
cfgerrtxtrjc db "addresses and try again.",0
cfgcfmtxta  db "Changing to automatic will",0
cfgcfmtxtb  db "reconnect the network and drop",0
cfgcfmtxtc  db "open connections. Continue?",0

;### Wi-Fi scan / password dialog (DRIVER 7)
statxttba4   db "Scan",0
statxtfrs    db "Wi-Fi networks",0
scantxts0    db "Scanning...",0
scantxts1    db "No networks found",0
scantxts2    db "Scan failed",0
scantxts3    db " networks found",0
scantxts4    db "Connecting to ",0
scantxts5    db "Connection failed rc=",0
scantxts6    db "Connected to ",0
scantxtres   db "Rescan",0
scancol0t    db "SSID",0
scancol1t    db "Enc",0
scanencO     db "Open",0
scanencE     db "Enc",0
scanpwnet    db "Network: ",0
pwdwintit    db "Wi-Fi password",0
pwdtxtpass   db "Password:",0
pwdtxtshow   db "Show password",0
pwdtxtcancel db "Cancel",0
scanertxt0   db "Could not connect.",0
scanertxt1   db "Check the password (if any)",0
scanertxt2   db "select another network.",0

;### RESERVE
ds 80
