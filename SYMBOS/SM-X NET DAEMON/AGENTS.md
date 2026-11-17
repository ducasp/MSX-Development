# AGENTS.md - Project Guide for AI Agents

## Project

**OCM Wi-Fi Network Daemon for SymbOS** - a SymbOS network daemon (background
service) that provides TCP/IP (TCP, UDP, DNS, DHCP via the ESP, TLS) to
SymbOS applications on the OCM (One Chip MSX) with an ESP8266 running the
ducasp UNAPI firmware, accessed through the SM-X style I/O UART on
**ports #06/#07**.

This repository is a fork of the
[msx-picoverse-symbos-network-daemon](https://github.com/Jzzy-dev/msx-picoverse-symbos-network-daemon)
by Jzzy (LGPL-2.1). Jzzy's driver targets the PicoVerse 2350 via
memory-mapped I/O (`#7F05-#7F07`) with SymbOS slot switching. This fork
replaces the transport with the OCM I/O UART and removes all slot handling.

## Architecture

The daemon is Prodatron's SymbOS Network Daemon (`Dmn-Network.asm`) compiled
for **DRIVER 7** (compile-time switch). Official driver numbers: 0=localhost,
1=DenYoNet, 2=GR8NET, 3=M4 CPC, 4=Net4CPC, 5=M4 EP/SF3. Jzzy introduced 6
(ESP8266 UNAPI/PicoVerse memio); this project uses 7 to avoid collision.

### Files and roles

| File | Role |
|---|---|
| `Dmn-Network-_OcmWifi.asm` | wrapper (WinAPE syntax), switches, includes |
| `Dmn-Network-_OcmWifi-sj.asm` | sjasmplus frontend mapping WinAPE directives |
| `Dmn-Network.asm` | daemon core: `if DRIVER=7` = OCM implementation; `else` = verbatim official Prodatron 1.2 source for DRIVER 0-5 |
| `Dmn-Network-OcmWifi.asm` | hardware layer: I/O transport, ESP protocol, detection, TCP/UDP/DNS hooks |
| `Dmn-Network-head.asm` | SymbOS EXE header; SELOPN/LNGLOD/FILPOI flags are DRIVER 7-only, official values otherwise |
| `Dmn-Network-libs.asm` | flattened SymbOS system libraries, guarded by the `use_Sy*` flags of the head |
| `Dmn-Network-i18n-direct.asm` | UI texts, no language packs (LNGSKIP=2); local to the direct-text build, not part of the upstream diff |
| `SymbOS-Constants.asm` | MSC_/MSR_/FNC_/PRC_ constants |
| `build.bat` / `build.ps1` | build scripts (sjasmplus) |
| `netd-ocm.exe` | build output (git-ignored) |
| `Dmn-Network-DRIVER7.diff` | DRIVER 7 branches/guards vs the official 1.2 daemon |
| `Dmn-Network-head-DRIVER7.diff` | DRIVER 7-only head/library flags vs the official 1.2 head |

### Common-file compatibility rule

- `Dmn-Network.asm` is shared with the official Prodatron daemon and the other
  drivers. Any change specific to the OCM Wi-Fi driver/daemon (DRIVER 7) in
  `Dmn-Network.asm` and in any future common file must be guarded with
  `if DRIVER=7` / `else`, with the `else` branch preserving the official
  source/values for DRIVER 0-5. This includes code, data records, UI layout,
  buttons, tabs, texts, head/library flags and build-time switches. Never add
  unguarded 7-only code or change the official 0-5 behavior/layout in a common
  file.
- The same rule applies to the current common files
  (`Dmn-Network-head.asm`, `Dmn-Network-libs.asm`, `SymbOS-Constants.asm`) and
  to any other common file added later. DRIVER 7-only files (the OCM low-level
  driver, the OCM wrapper/frontend and the direct i18n text table) are not
  shared files and are not part of the upstream diff.
- After changing a common file: rebuild DRIVER 7 with the same wrapper/head/libs
  and verify the binary is byte-identical (or that the change is intentional);
  static-check the DRIVER 0-5 branch against the official source (no 0-5 build
  here); refresh the DRIVER 7 diffs (`Dmn-Network-DRIVER7.diff`,
  `Dmn-Network-head-DRIVER7.diff`) and update this file.

### I/O transport (Dmn-Network-OcmWifi.asm)

- `out (#06),a`: command / UART speed / clear FIFO (write 20)
- `out (#07),a`: TX data byte
- `in a,(#06)`: RX data byte
- `in a,(#07)`: status byte (bit0=data waiting, bit3=quick receive capable,
  bit5=port not available/open bus)
- No slot switching, no `di`/`ei`. The memio `espenter`/`espleave` stubs
  were removed in Phase 1 (all 45 call sites dropped, with the dead
  `ret c`/`jp c` checks after them).
- Wire protocol (same ESP firmware): request `[fn][len MSB][len LSB][payload]`,
  response `[fn][rc][len MSB][len LSB][payload if rc=0]`; unrelated bytes are
  skipped (`esp_skipmax`). DNS query uses fn 206.
- Long operations (TCP open up to 60s, DNS up to 15s) are split: send request
  now, poll reply later (`esp_pend` model: `esppol`, `esptop`, `espdnp`).
  Byte polls spin (`esp_spin`), frame waits use `halt` with interrupts on.
- Detection (`espdetect`): uses the ESP firmware Query command - read status
  (`#FF` = open bus = "no device"), clear the FPGA RX FIFO (never reaches the
  ESP), send `"?"` and wait up to 1s for `"OK"` (byte-match with restart on
  mismatch). Three attempts in total. No slot scan, no ROM header check, no
  ESP reset (`'W'`), no bit-5 status gate (undocumented and unreliable).
  On failure the adapter line shows a diagnostic: `no answer st=xx rX` -
  last status byte + bytes received.
- Quick receive (status bit 3) is only *detected* and stored in `esp_qr`;
  it is shown in the driver tab ("ESP on I/O, QR supported" / "ESP on I/O").
  The data paths do NOT use QR yet (single-byte `espgtb` loops everywhere).
- TX/RX data is bounced through transfer-area buffers (`esp_buf`,
  `esp_utxb`, `esp_urxb`) with `jmp_bnkcop` bank copies, as in the original.

### Daemon changes for DRIVER 7 (Dmn-Network.asm)

- `netini`: no slot save/detection bookkeeping; just `lowini`.
- `staapl` (Apply): the DRIVER 7 driver tab has no Apply button anymore (it
  was a leftover from the slot/MAC drivers); the Settings window's OK
  (`cfgoky`) is the real apply/save path. `staapl`/`staapl3` stay for the
  other drivers. Removing the button also removed its broken extended redraw
  (`WINDIN` `D=23,E=-6` = controls 23..28, one past the 28-record table).
- `cfgini`: slot-combo initialization skipped for DRIVER 7.
- Scan tab (4th main window tab, DRIVER 7): `stactltba` declares 5 tabs,
  `statabadr`/`stawingrpd` select `stawindatd` (8 controls: background, tab,
  Hide, Settings, frame, status text, list, Rescan). The list is the native
  SymbOS `list_complete` control (type 43, `scandat`+`scancol`+`scanlst`);
  its click handler `scansel` reads the "last clicked line". Entering the tab
  (`statab`/`prgtry1`) starts a scan (`scanstart`), `scanpol` in the main loop
  polls the firmware `'s'` results every ~0.5 s and updates the list/status.
  The AP buffer is `scanap` in the code area, `SCANMAX=128` entries of 68
  bytes: raw SSID[33], encryption, display SSID[33], pad. The list line value
  words hold the row index (`scaninit`), so the desktop's "last clicked line"
  and highlight work. Clicking an open network connects, an encrypted one
  opens the password window (`pwdwindat`, 7 controls, text input with the
  password flag, Show checkbox, Ok/Cancel; group focus=4 input, return=6 Ok,
  escape=7 Cancel, not modal - these group fields use the raw record numbering
  with the background counted, unlike the WINDIN control IDs). `pwdshow`
  toggles the input flag itself (the
  checkbox byte only follows it) and closes/reopens the window so the text
  input re-renders the password state; a WINDIN of the input alone does not
  re-apply the mask (the control only re-reads it on open/focus). The reopen
  is deferred to the main loop (`pwdropn`). The desktop stores the current
  focus in the group record (offset 14), so both `scanpw` and `pwdropn` write
  the input object back to `pwdwingrpa+14` before WINOPN, otherwise the next
  open would focus whatever was clicked last (the Show checkbox). The status
  line sits at (10,34,190,8), the list at (2,44,200,58) and Rescan at (160,21,40,12).
  The open-space connect path clears `pwdlen` first. `scanconn` copies the raw SSID
  including its terminating NUL (the separator must be part of the counted
  payload, otherwise the ESP answers rc=4) and then exactly `pwdlen` password
  bytes (no trailing NUL - the firmware terminates ucPWD itself) and
  calls the driver's blocking `espconn`, so the daemon pauses up to ~10 s
  while the ESP reconnects. The status shows `Connecting to <SSID>`, then
  `Connected to <SSID>` or `Connection failed rc=N`; driver `espconn`
  returns #FE=busy, #FF=no answer, otherwise the ESP rc, and the error box
  selects busy/no-answer/generic. Connecting sets the status to "no IP" and
  the normal link recovery reads the new addresses. The scan start and result
  are retried up to 3 times (0.5 s apart) before `Scan failed`/`No networks
  found`, because right after a failed connect the ESP can still be busy with
  the station reconnect and the first scan can fail.
- Settings tab (5th main window tab, DRIVER 7): the main window and all tab
  contents are widened from 155 to 205 px (the tab bar control was already
  205). `stactltba` declares 5
  tabs and `statabadr`/`stawingrpe` select `stawindate` (13 controls:
  background, tab, Hide, Settings, frame "ESP settings", Nagle checkbox,
  period label, slider, Apply, period value, firmware, Update FW, Update
  Certificates).
  Entering the tab (`statab`) or showing the window on it (`prgtry1`) calls
  `setread`: `espver` (`'V'` -> two raw digits, +0x30) and `espsetq`
  (`'Q'` -> "ON:<secs>"/"OFF:<secs>") fill the firmware text, the Nagle
  checkbox (`setnagl`, checked=On) and the period slider plus the period
  text. The Nagle checkbox applies immediately on click (`'D'`/`'N'`, reverts
  on failure). The slider is type 24 with a fine range (max 255) and step
  bytes `26,230` (right +26 / left -26, ~one minute per arrow click); the
  value is rounded to whole minutes with `setvmin` for the text and the Apply
  button (`setapp`), which sends `'T'` with minutes*60. The fine range is
  needed for the desktop's track clicks to step repeatably (the sound daemon
  volume slider uses the same pattern). `setvaltab` maps minute indices to
  slider values; `setread` rounds the ESP timer to the nearest minute. After
  any change `setpol` snaps the slider value back to `setvaltab[minutes]` and
  redraws the slider (control 7) + period text (9), so only the 11 valid
  positions are used. The desktop's track click is a small page step, so the
  main-loop `setpol` infers the direction from the raw value versus the shown
  value (`setorce`) and forces at least one position; otherwise the small
  track-click step would snap back to the same position. Possible pitfall: 16-bit `ADD HL,-n` sets CF=1 when
  HL>=n (no borrow), so the division loops stop on `JR NC` (a `JR C` stops
  immediately and returns garbage minutes). The
  slider's `setsldc` callback calls `setpol`, which updates the text
  synchronously; do not defer this with a main-loop timer (an asynchronous
  WINDIN during a track click left the desktop's slider mouse state stuck and
  killed dragging).
  Control IDs exclude the background: Nagle=5, slider=7, Apply=8, period
  text=9, firmware=10. The slider/text/checkbox records are in the transfer
  area, the texts/buffers in the data area.
- ESP firmware/certificate update (Settings tab, Update FW / Update Certificates): the
  buttons open a small "ESP chip" window after probing `espchip` (`'b'`,
  ESP32 only; no answer = ESP8266). Ok closes it, opens the SymbOS file
  selector (`SySystem_SELOPN`, enabled in the libs; buffer `updmsk` "BIN",0 +
  `updpath` in the transfer area, 100 entries / 5000 dir buffer) and then a
  progress window ("Sending NN%" with a native progress bar, then
  "Finishing..."/"Resetting."/"Indexing certs..."). A connected network is
  required (`net_status`=0xFF) because the certificate index needs SNTP time.
  Local files only (no OTA). The file size comes from
  `SyFile_FILPOI` (seek to end; enabled in the libs); 256-byte blocks via
  `SyFile_FILINP`. Protocol (driver): `espupstart` `'Z'`/`'Y'` + length 12
  (size 8 LE + first 4 bytes; FW needs first byte 0xE9), `espupblk` `'z'` +
  length + data, `espupend` `'E'` (then the ESP flashes and restarts),
  `espupready` `'R'` + wait "Ready\r\n", `espupidx` `'I'` for the certificate
  index. ESP32 firmware additionally reads the `.dat` file (same name) and
  sends it with `espupdat` (`'B'`) before the start. A missing/short `.dat`
  or a rejected `.dat` aborts with its own error (the real ESP code is shown
  for a rejection); a rejected start resets the ESP (`espupready`) before the
  error box so the daemon link/IP recovery resumes, while block/end errors do
  not reset (the ESP may be flashing). The progress line shows `Starting...`
  until the `Z`/`Y` start is accepted, then `Sending`; the error box says
  whether the start or a data block was rejected. The block sender must NOT
  poll the TX status (`in a,(#07)`) before writing a byte - the OCM UART
  paces the TX itself; reading the status destroyed the data byte. No cancel;
  the daemon is
  busy during the transfer. After a successful update the link state is reset
  (`netini0`) and the normal link recovery reconnects. On an error the ESP may
  stay in update mode until a power cycle (the flashed image is unchanged).
  Window groups: chip 5 controls (type, ESP32 board name from `'b'`, hint,
  Ok), progress 4 controls.
  Live progress redraws use `SyDesktop_WININH` (focus-only), one range
  redraw of controls 2..3 every 32 blocks; `updmsg` drains pending desktop
  messages (`RST #18`, sender desktop) before each redraw and in the 60-frame
  finish wait, and tracks `MSR_DSK_WFOCUS` for the progress window. The window
  is brought to the front with `SyDesktop_WINTOP` after opening; the redraw is
  skipped while it is unfocused. The update loop yields to SymbOS with
  `RST #30` (MTSOFT) every 8 blocks, before/after each redraw and in the
  finish wait; `espqr`/`espgtw` also yield after every `halt`. Without these
  yields the desktop was starved (the blocking update handler bypasses the
  main loop's `prgprz0 rst #30`), its message queue filled, the `WININH` send
  blocked, and only a mouse/keyboard interrupt unblocked it (a few percent
  per click); `HALT` alone does not release CPU to lower-priority tasks.
  A `WINDIN` ("works always") redraw of an unfocused progress window is slow
  and can overrun the queue; keep the focus-only redraw. The progress display
  pauses while the window is unfocused; the transfer continues and the next
  redraw after focusing it updates it.
- Driver tab (`stawindatc` DRIVER 7): TX/LINK/RX lights, Settings frame with
  the QR info line (`statxttxqa`/`stactltxqa`, patched at detection), the
  WiFi/AP name line (`statxttxr`, flat control index 21 - `staupd6` redraws
  it), the Disconnect button (`stadisc`, flat 22, at (10,84,60,12), sends the
  firmware `'a'` forget-AP command) and the UDP state line (`statxtudp`, flat
  control index 27, moved to y=97 - `staupd6` redraws it). Control IDs exclude
  the background record: the 4 common header controls (tab bar, Hide, Network
  settings, Status frame) come first, then the per-driver table. `staupd6`
  first checks that the Driver tab is active (`stactltba0`=2); on the Scan tab
  those IDs do not exist and redrawing them crashed the desktop. The button
  replaced one of the spacer records, so the group stays at 28.
- Config block (`cfg_beg..cfg_end`): DRIVER 7 leaves the two `cfg_slots`
  bytes alone (no slot handling); an earlier state-poll option (Phase 2) was
  evaluated and reverted, the block layout is the original one.
- IP/DNS configuration (DRIVER 7): the ESP's EEPROM is authoritative. The
  daemon reads IP/mask/gateway/DNS and the automatic/manual mode from the ESP
  (`CONFIG_AUTOIP` get + `GET_IPINFO`) at startup (before the window opens),
  when the TCP/IP tab is selected or its window reopened (`statab`,
  `prgtry1`), when the Network settings window opens (`stacfg`) and after a
  link recovery (the offline `netips` loop, which also checks `NET_STATE`).
  No periodic IP/mode polling while connected; only the existing 5 s link
  check for connected/disconnected. `network.ini` is never used for these
  fields (the block is still written; the fields are a copy). The settings
  window applies via `CONFIG_IP` items followed by `CONFIG_AUTOIP` set
  (`lowini` A=2 hook, `espnet`); A=3 reads the mode (`espnetq`). Mode 02
  (manual IP + automatic DNS) is rejected; switching a group to automatic
  shows a Yes/No reconnect confirmation (`cfgokycf`). Input fields of
  automatic groups are made read-only via bit1 of the `cfgctli*` input data
  record (`cfgrdonly`, tracked live by `cfgrdchk` while the window is open).
- TCP close handling: a peer FIN (ESP state 7 CLOSE_WAIT) while data is still
  buffered keeps `lowtst` reporting "established + data" until the buffer is
  drained; only then the close/close-wait status is published. Without this
  the daemon sent the close event early and apps stopped mid-transfer.
- UDP: state-driven, no cache. The daemon stubs
  (udpopn/udpsta/udprcv/udpsnd/udpskp/netudp) are implemented for this
  driver (from the Jzzy patch). `lowust` peeks with the firmware extension
  UDP_STATEX (fn 210) for pending count, oldest size and sender without
  consuming the datagram; `lowurx` calls UDP_RCV only when the application
  receives, `lowusk` receives and throws away. `UDP_Status` returns the
  pending count in H (fallback 1 if the transport cannot count); the daemon
  caches it in `sckdatrsv` on every poll and returns it in H and in the
  event H byte. The app loops Status + Receive while H>0; UDPEVT is sent only
  on empty-to-non-empty. `UDP_Status` also refreshes the socket record with an
  on-demand `lowust` call, so polling apps do not depend on the periodic
  `netpol` scan; `netpol` still updates the record and sends UDPEVT. The UDP
  helpers must reload the socket from `esp_usck` before `call espuslt`:
  without it `lowust`, `lowusk` and `lowucl` always looked up
  `esp_uconn[0]`. That was the actual `U03` cause when the UDP socket was not
  socket 0. No-data stays error 24.
  `UDP_Receive` uses BC as the
  caller's maximum: BC=0 or BC greater than the datagram length copies the
  complete datagram, BC smaller truncates it and discards the remainder. The
  datagram is consumed either way; the copied length is returned in BC.
  `UDP_Status` keeps reporting the complete announced length. The daemon
  supports 1468 payload bytes / 1500 bytes total (shared UDP buffer).
  Needs a firmware with fn 210: on the first failed query while a
  UDP socket is open the driver tab UDP line shows `UDP error: update ESP FW`
  (blank while it works) and the driver backs off ~50 polls between retries.
  Only a real timeout is followed by a resync burst (`0x00` + conn*256
  zeros) so an old firmware that parsed the fn-210 length byte as GET_CAPAB
  returns to idle instead of eating the following traffic. Error return codes
  other than 1/15 are treated as "no data", not as failure.
- TLS: fully explicit in TCP_Open. A bits: 0=server, 1 reserved (must be 0),
  2=TLS, 3=verify certificate, 4-7=bank of the hostname; BC points at the
  zero-terminated hostname (copied to `tcphost`, max 255 including NUL).
  A=0/1 is plain TCP on any port. There is no port table (443/8443/465/993/
  995) and no last-4 DNS `esp_hn` cache anymore; `TLSVERIFY` was removed.
  The daemon rejects reserved/passive TLS with 003, bad/over-long/unterminated
  host names with 026; `scknew`/ESP session exhaustion is 008; an asynchronous
  TLS open failure is 025. The driver stores the reason per socket and the
  daemon returns it in the TCP event H byte (`TCP_OpenWait` maps 8/25/26;
  other closes stay 24). Passive TLS is not supported. The ESP firmware still
  performs BearSSL and the certificate check (`certs.ar`, needs SNTP time);
  the daemon does not hard-code a one-TLS limit, so the ESP decides whether
  another TLS session is possible (ESP8266 typically one, ESP32 several).

## Build

```
build.bat          (uses tools\sjasmplus\sjasmplus.exe or sjasmplus on PATH)
```
or `sjasmplus Dmn-Network-_OcmWifi-sj.asm` - output `netd-ocm.exe`.

sjasmplus is NOT committed (git-ignored `tools/`). Download from
https://github.com/z00m128/sjasmplus/releases (tested v1.24.0). The wrapper
also assembles with WinAPE 1.0.13 (no colons allowed inside comments).

## Source encoding and assembler constraints

- **Do NOT rewrite these files with tools that change encoding**: the original
  sources are ASCII + cp1252 umlauts in German comments. Re-encoding corrupts
  the umlauts. After any whole-file edit, verify with a byte scan
  (no `EF BF BD` sequences) and repair by restoring the original bytes:
  F6(o), DF(ss), FC(u), 96(en-dash), E4(a) in order of appearance.
- sjasmplus syntax constraints applied to the sources:
  - `dw $+7,$+4,28` must be split into `dw $+7:dw $+4,28` ($ is per-statement
    in sjasmplus, per-operand in WinAPE)
  - `cp "\"` is invalid in sjasmplus (use `cp 92`)
  - column-0 instructions with forward labels fail (indent them)
  - labels cannot follow a `:` on the same line (own line instead)
  - `<>` is not a valid IF operator in sjasmplus (restructure with if/else)
  - DEFINE for WinAPE directives is case-sensitive; map both spellings
- These constraints keep the source valid for BOTH WinAPE and sjasmplus.

## Design decisions (agreed with the user)

1. DRIVER = 7 (6 is Jzzy's memio driver; distinct number avoids collisions).
2. I/O transport only; the PicoVerse memio variant is not kept in this repo.
3. Detection: `"?"` -> `"OK"` (the firmware Query command, confirmed on real
   OCM hardware from MSX BASIC); clear-FIFO first (FPGA-side only, never
   reaches the ESP); three attempts; no bit-5 gate; no slot scan; no ESP
   reset at daemon start (reuse Jzzy's logic - the daemon lives long on
   SymbOS); no `SET_SPEED` (noted as a possible future tweak). Failure shows
   `no answer st=xx rX` in the adapter line (last status byte + bytes
   received) for on-device diagnostics.
4. Quick Receive: detect + display only for now (Jzzy never implemented the
   fast path). Future work: `inir`-based receive + config toggle.
5. DRIVER 7 leaves the two `cfg_slots` bytes of the ini layout alone (no
   slot handling); the Phase 2 state-poll option was evaluated and reverted.
6. Driver version 0.9 (`low_vermaj=0`, `low_vermin=9`).
7. No openMSX usage without explicit user permission; hardware testing is
   done by the user on the OCM.
8. UDP is state-driven and needs a firmware with the UDP_STATEX extension
   (ESP command 210, peek of count/size/sender, non-destructive). No cache:
   UDP_RCV is called on demand, UDP_SKIP receives and discards. Detection is
   on demand too: on the first failed UDP_STATEX while a UDP socket is open
   the driver tab UDP line shows `UDP error: update ESP FW`; it is cleared
   again as soon as a query succeeds. The driver backs off ~50 polls between
   retries, and a timeout is followed by a `0x00` + conn*256 zero resync
   burst for firmwares that do not know the command.
9. DRIVER 7 network configuration (IP/mask/gateway/DNS and the IP/DNS
   automatic flags) is owned and persisted by the ESP EEPROM; `network.ini`
   is not used for it. The daemon reads it from the ESP before showing the
   window and on demand (TCP/IP tab shown, settings window opened, link
   recovery); there is no periodic IP/mode polling while online. The settings
   window writes through the existing ESP commands `CONFIG_IP` (fn 26) and
   `CONFIG_AUTOIP` (fn 25). Configuration mode 02 (manual IP + automatic DNS)
   is invalid and rejected; switching a group to automatic reconnects the
   Wi-Fi link, so a Yes/No confirmation is shown first. Input fields of
   automatic groups are read-only (text input data record bit1). The
   configuration travels with the ESP, not with the MSX/disk.
10. Wi-Fi scan/connect: the Scan tab uses the firmware custom commands
    `'S'` (start scan, quick response), `'s'` (results: `'s', rc, count`,
    per AP `SSID\0` + `'O'`/`'E'`) and `'A'` (connect, framed request
    `SSID\0[password]`, quick response). The whole scan list arrives in one
    `'s'` reply; the daemon stores up to `SCANMAX=128` APs (raw bytes for
    connecting, sanitized copy for the list; 64 is plenty, reduce
    if memory is tight). The native list control is used. Entering the tab
    scans silently; scanning may briefly disturb the link. `scanconn` blocks
    the daemon for up to ~10 s while the ESP reconnects (the ESP is blocked
    anyway); on failure the status shows `Connection failed rc=N` (driver
    `espconn`: #FE busy, #FF no answer, else the ESP rc) and an error box is
    shown; the ESP stays disconnected. The list line values are row indices,
    and the password window uses group focus=4/return=6/escape=7 and a
    self-toggling Show checkbox. The driver routines refuse to run while
    `esp_pend` is set.

## Verification checklist

- `build.bat` must finish with 0 errors / 0 warnings.
- Binary checks: size ~40KB, contains `SymExe10`, `OCM Wi-Fi v0.9`,
  `ESP on I/O, QR supported`, `UDP error: update ESP FW`, `Manual IP requires
  manual DNS`, `Scanning...`, `Show password`, `Could not connect.`,
  `Connecting to `, `Connection failed rc=`, `Nagle algorithm`,
  `Wi-Fi on period:`, `Update FW`, `Update Certificates`, `Firmware: `, `ESP chip`,
  `Select the matching file.`, `Firmware update`, `Sending`, `Finishing...`,
  `Resetting.`, `Indexing certs.`, the
  diagnostic fragments `st=` / ` r` / `r`; contains `in/out #06/#07`
  sequences; contains NO `#7F06/#7F07` accesses, NO `#0202` slot helper
  access, NO `out (#A8)`, NO `bit 5` status checks (`CB 6F`).
- The driver-tab control-group record must declare exactly **28** controls
  (`db 28,0` in `stawingrpc` = 5 common header + 23 driver-tab records; the
  status/TCP-IP config groups declare 19/20/35/25, the scan group declares 8,
  the settings group declares 13, the password window group 7 and the update
  windows declare 4 controls each; the main tab bar declares 5 tabs. All must match their tables exactly).
- **Control data records (`stactl*`, `cfgctl*`) MUST live in the transfer
  area** (above the transfer start). The desktop manager only maps the app
  bank's block 3 (#C000-#FEFF) while drawing window content, so a record in
  the data area is read as garbage (symptom: a WRONG line shows sequential
  characters like `! "#$%...` with a stray background colour). Texts and
  graphics are the only items allowed in the data area (the desktop reads
  them via bank switching). Known data-area items: all `*txt*` strings and
  the light graphics `stactllg0`/`stactllg1`. Checkbox/radio state bytes are
  also read and written by the desktop directly, so they must live in the
  transfer area too (`pwdshowb` is next to `pwdchk` for this reason, otherwise the checkbox opens in the wrong state).
- **Text controls (type 1) point to a text data record** (`stactltx*`,
  `dw string,2+4`), never directly to the string. Pointing at the string
  makes the desktop read the first word of the text as a pointer and the
  next byte as colours (symptom: a garbage line/bar, often text read from
  address 0 like a stray `a:\SYMBOS\...` path). The data record belongs in
  the transfer area, the string in the data area.
- The 256-byte shortfall between file size and `relocate_count*2` is normal
  (present in the original working builds).

## Debugging on openMSX (permission needed - see decision 7)

- `build.ps1` also writes `netd-ocm.sym` (sjasmplus symbol file).
- Best breakpoint for I/O bring-up: an I/O watchpoint, independent of the
  SymbOS relocation:
  `debug set_watchpoint write_io 0x07 0x07 {[reg A] == 0x63}` - hits when
  the daemon sends `"?"` (63). Without the condition it hits on every TX
  byte. Use `read_io 0x06 0x07` to watch any UART access.
- All driver code lives in the transfer area. The loaders place the transfer
  section between #C000 and #FFFF of the app bank; earlier layouts were
  measured at runtime **#DE00**, so `runtime = base + (symbol - App_BegTrns)`
  with `App_BegTrns` from the .sym (current build: 0x6753). The transfer
  section grew past 8 KB with the scan tab, so re-measure the base with the
  I/O watchpoint after such layout changes: `write_io 0x07 0x07` with
  `[reg A] == 0x0D` (TCP_OPEN) hits at the instruction after the out, in
  `lowtop` (`App_BegTrns+0x1F61`, linked 0x86B4; the `ld a,h` is a few bytes
  later).
- PC breakpoints at #C000+ are ambiguous: other SymbOS processes also run code
  in that window (a false hit showed a different bank's bytes). Guard them
  with `[reg SP]` inside the daemon stack (base..base+0x100, e.g.
  0xDE00-0xDF00) or with `[peek addr]` opcode checks.
- Detection diagnostics (on failure): adapter line in the Status tab shows
  `st=hh rD` (status before the last send / bytes received by the last
  strategy); the driver tab info line shows `rA/B/C st=hh` (bytes received
  per strategy). Strategies: 0 = clear+`"?"`, 1 = clear+1 frame+`"?"`,
  2 = framed NET_STATE. These fallbacks are temporary and will be removed
  once strategy 0 is confirmed on hardware.

## Status

Phase 1 performance work is applied (driver only, no behavior change):
`espenter`/`espleave` removed, `espsnd`/`espcmd` inlined (macro style,
30/14 sites), `espgtb` inlined in the two bulk receive loops (`lowtrx3`,
`espurc2`). Phase 2 (state-poll cfg/UI) and Phase 3 (espstq/lowtrx) were
evaluated and skipped. Phase 4+5 (library guards + dead-state cleanup) are
restored. The early-download truncation was NOT caused by Phase 4+5: the
driver published a peer close (CLOSE_WAIT) while data was still buffered.
`lowtst` now keeps reporting "established + data" until the ESP buffer is
drained and only then publishes the close (state 7 = close-wait, no longer
closed). The UDP cache was replaced by the state-driven design (UDP_STATEX
fn 210, on-demand UDP_RCV/UDP_SKIP, error text in the driver tab UDP line,
old Apply button replaced by that line). The DRIVER 7 network configuration
now lives in the ESP (read at startup/tab/settings/link recovery, edited via
CONFIG_IP/CONFIG_AUTOIP; network.ini is not used for it). The Wi-Fi Scan tab
(4th main tab) was added: native list control, firmware scan `'S'`/`'s'`,
password window for encrypted networks, blocking `'A'` connect. The shared
`Dmn-Network.asm` now starts with `if DRIVER=7` (the complete OCM branch) and
`else` (the verbatim official Prodatron 1.2 daemon source for DRIVER 0-5).
`Dmn-Network-head.asm` guards the SELOPN/LNGLOD/FILPOI flags the same way. The
DRIVER 7 rebuild is byte-identical to the pre-guard reference (SHA256
`43E76EEE...029C3A`, 40,004 B; sym `810B988F...B69B66`). The 0-5 branch was
static-checked against the official source, not built (no 0-5 hardware here).
The upstream diffs are `Dmn-Network-DRIVER7.diff` and
`Dmn-Network-head-DRIVER7.diff`; the direct i18n file is intentionally not
part of the diff. Current binary 40,800 B, SHA256
`B27CF74ECB9400F7C2693F4FDECBF188822D4991611BE4E6EB181EA390EAEC0E`
(pre-Phase-1: 18,982; TLS+plain
candidate: driver pending gates on lowtst/lowtrx/lowttx/lowtcl/lowtdc/UDP,
transactional TCP/UDP close, DNS start precheck; UDP payload limit 1468 bytes
/ 1500 bytes total with a shared send/receive buffer; no trace text). Benchmark with
tools\\wget2, same URL/file/mode across phases. The explicit TLS (A/BC, 025/
026/003/008, event-H reason) and UDP pending-count/H changes are implemented;
they still need the user's hardware test. For synchronous ESP8266 opens/DNS,
the earlier diagnostic guard (`netpol` early return + main-loop message hold
while `esp_pend`) was removed because TLS+plain still failed with it. The
current candidate defers `lowtst`, `lowtrx`, `lowttx`, `lowtcl`, `lowtdc`,
UDP open/close/send/status/receive/skip and DNS starts in the driver while a
long ESP request is pending, so no command can interleave with `TCP_OPEN`.
TCP and UDP close/disconnect call the driver before freeing the daemon socket
and keep it when the driver reports busy. The
loop-count watchdog was removed: it counted `esppol` calls rather than time
and timed out normal DNS/open requests after the main loop stopped consuming
messages. A future timeout needs a real timer and a safe ESP reset/resync. The SCC libnet package is in
`tools/scc/OCM-TLS-UDP/` (patched `libnet.a`, rebuilt Teletekst), and
`tools/NetTest` uses the explicit TLS mode with a Verify checkbox; its UDP
receive now passes BC=64 and the rebuilt binary is 11,915 B. The JZZY source
patch is `tools/NetTest/NetTest-OCM-DRIVER7.patch`. The DRIVER 7 network API
reference is `tools/OCM-WiFi-Network-Functions.txt`. The JZZY PicoVerse
porting guide is `tools/JZZY-PICOVERSE-PORTING-GUIDE.txt`. SCC and Teletekst are
not changed for the UDP BC work. Teletekst's
streaming receive loop filters TCP events on `_netmsg[3]` (A), matching the
daemon; `_netmsg[2]` is F. `tcpopn`
keeps the `scknew` socket in A through the client/server branch before
`lowtop`; `TCP_Status` returns the close reason in H (`sckdatrsv`), and
Teletekst logs the close status/reason for TLS diagnosis. TCP/UDP/DNS event
and request sockets are taken from the actual socket record (`nettcpsck`,
`netudpsck`, `netdnssck`) instead of the self-modifying `netpols+1`; `tcpopn`
sets `netscknum` immediately after `scknew`.

The transport rewrite is complete and verified on real OCM hardware:
detection, TCP downloads and UDP (with a firmware that provides UDP_STATEX)
work. Firmwares without the extension are detected on demand and reported in
the driver tab UDP line when UDP is used. The old Apply button was removed
(no function for this driver, its redraw corrupted the screen). The ESP-hosted
IP/DNS configuration is implemented (startup read, settings window, modes 00/
01/03, read-only automatic fields, reconnect confirmation); it needs its
hardware test. The Wi-Fi Scan tab (scan list, password dialog, connect) is
implemented and needs its hardware test; a first hardware round added the
status/list layout split, password input focus (4/6/7), self-toggling Show
checkbox (status byte moved to the transfer area, where the desktop reads it),
row-index line values, pwdlen reset for open networks, the target SSID in the
connect status, the ESP rc in the failure status and scan retries after a
failed connect left the ESP busy. The Driver tab got a Disconnect button
(firmware `'a'` forget-AP command); it also clears the shown IP/mask/gateway/
DNS. The WiFi/UDP line control indices are 21/27 (control IDs exclude the
background) and `staupd6` only redraws them while the Driver tab is active.
The Settings tab (5th tab) was added: ESP Nagle on/off, Wi-Fi-on period
slider + Apply, firmware version (`'V'` + raw digits) and the working Update
FW/Update Certificates updater; the main window was widened to 205 px for the
5th tab.
The daemon core behavior is unchanged
from the PicoVerse build that was verified working (wget, SymTel, Net Test
SNTP). The DRIVER 7 `UDP_Status` now calls `lowust` on demand and updates
`sckdat*`; the missing socket reload before `espuslt` in `lowust`, `lowusk`
and `lowucl` was fixed. This removes the `U03` timeout seen when the UDP
socket was not socket 0 while SymChat held socket 0. It still needs the
user's hardware test.
