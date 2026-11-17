# OCM Wi-Fi Network Daemon for SymbOS

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

A SymbOS network daemon for the OCM (One Chip MSX) and any of its variants (SM-X,
SX2, etc.) that have an ESP (8266 or 32) connected to it using the UNAPI firmware.
It uses the ESP UNAPI firmware through the I/O UART (**ports #06/#07**).
The daemon is shown as **OCM Wi-Fi** in the SymbOS driver tab.

> **This project is based on the
> [msx-picoverse-symbos-network-daemon](https://github.com/Jzzy-dev/msx-picoverse-symbos-network-daemon)
> by [Jzzy](https://github.com/Jzzy-dev).** The daemon core is
> Prodatron's SymbOS Network Daemon, patched for DRIVER 7 (based on Jzzy's
> historical DRIVER 6 changes).
> Jzzy's driver talks to the ESP through PicoVerse memory-mapped I/O with
> slot switching; this fork replaces the transport with the OCM I/O UART,
> which needs no slot switching at all.

**Contains AI**

If you are allergic to AI usage, please do not use this product. OpenCode with
Deepseek v4 Flash has been used and traces of it can be found in the product.
Physical author and Virtual author are not responsible if use of this product
causes side effects like bashing on people that use AI for development, thinking
that functional and good tested products are automatically slop, feeling the
need to not be polite towards someone that shared for free something did on hobby
time, trying to assert that your fun is ruined because people are having fun in a
different way. You've been warned!

## Configuration

The daemon saves its settings in `network.ini` next to the executable, the
same config block layout as every other SymbOS daemon build. Like the
localhost/M4CPC/M4EP builds, this driver does not use the two `cfg_slots`
bytes (no cartridge slot involved) - they stay in the file untouched to keep
the layout identical and old `network.ini` files fully compatible.

### IP and DNS settings

The ESP owns the network configuration. IP address, subnet mask, gateway and
both DNS servers, plus whether the IP group and/or the DNS group is obtained
automatically, are stored in the ESP's EEPROM. They are edited through the
Network settings window and are read back from the ESP; `network.ini` is
never used for them (the block is still written, but those fields are only a
copy). Moving the installation to another MSX, disk or adapter therefore uses
the configuration stored in the ESP that is actually used - not a copy from
the old system.

- The daemon reads the configuration from the ESP at startup (before the
  window is shown), when the TCP/IP tab is selected or its window reopened,
  when the Network settings window is opened, and after a link loss when the
  connection returns. There is no periodic IP polling while connected; the
  regular link check is only used to show connected/disconnected.
- The TCP/IP tab always shows the values the ESP reports (`ESP_IPINFO`); the
  DHCP/Manually set type lines come from the ESP's automatic mode flags
  (`CONFIG_AUTOIP`).
- The Network settings window shows the current ESP values. For a group set
  to automatic its input fields are prefilled with the current values but are
  read-only; selecting the manual option makes them editable.
- Supported combinations: all automatic, automatic IP + manual DNS and all
  manual. Manual IP with automatic DNS is not supported by the firmware and
  is rejected with an explanation.
- Applying settings sends them to the ESP and stores them there. Switching a
  group to automatic may reconnect the Wi-Fi link (open TCP/UDP connections
  drop); the daemon asks for confirmation first. The resulting addresses are
  read back from the ESP once the link is up again.

## UDP

- This daemon needs an ESP firmware with UDP_STATEX. Detection is on demand:
  only when a UDP connection is open and the command fails (no answer, not
  implemented, or a malformed reply) the driver tab shows:
  `UDP error: update ESP FW`
- UDP sockets are opened as transient. At daemon start and after the settings
  are applied (Settings window OK) the driver sends UDP_CLOSE 0, which closes
  all transient UDP sockets in the ESP, so a program that was killed cannot
  block the four ESP connections. The ESP has four connections for TCP and
  UDP together.
- Largest datagram is 1468 bytes data / 1500 bytes total datagram, larger ones
  are refused on send and cut on receive.

## HTTPS / TLS

The ESP firmware can do TLS itself, TCP_OPEN has a flag for it. The SymbOS network
API has no TLS flag, so the driver decides by port, the program just talks plain
data to the daemon.

- A client connection to port 443, 8443, 465, 993 or 995 is opened as a TLS
  connection. The list is `esp_tlsports` in `Dmn-Network-OcmWifi.asm`. Server
  connections stay plain.
- So `http://host:443/` style access works in any program that lets you pick
  the port, and a program that has its own https support only has to connect
  to port 443 and send its plain HTTP request.
- For SNI and the name check the ESP needs the host name, the daemon only has
  the IP at that point. The driver remembers the last four DNS answers (name
  and IP) and sends the name that belongs to the IP. A connection by IP number
  without a previous name lookup has no host name, a lot of servers refuse that.
- `TLSVERIFY` in the wrapper. 0 (default) = encrypted, but the server
  certificate is not checked. 1 = the ESP checks the certificate against its
  certificate store (certs.ar in the ESP, flashed with the firmware tools),
  a connection then fails if the store is missing or the certificate is not known.
  The switch is compile-time: the daemon always contains the TLS port list and
  SNI logic; 0 assembles the open flag 4 (TLS, no check), 1 assembles flag 12
  (TLS + check). The certificate check itself is done by the ESP, not by the daemon.
- Limits of the ESP: only one TLS connection at a time, TLS 1.2 at most, the
  handshake takes a few seconds, big pages and servers with very large
  certificate chains can fail on the little RAM. A failed TLS open shows up
  like any other refused connection.

## WiFi state and signal strength

The ESP firmware has no signal strength command. What it offers is the state
of the WiFi connection and the name of the access point it is connected to. The name
is shown in the driver tab and refreshed with the link check. A real signal
level needs a new command in the ESP firmware that returns the RSSI, the
daemon already has the six level signal graphics from the M4 Board build that
could show it.

## Wi-Fi scan and connect

The main window has a fourth tab, **Scan**. Entering it starts a Wi-Fi scan in
the ESP and lists the networks it finds (SSID and Open/Enc) in a native list
with a scrollbar; the whole list arrives in one reply from the ESP. A Rescan
button repeats the scan. Entering the tab scans silently - scanning may briefly
disturb the link on some access points. If a scan is started right after a
failed connect, the ESP can still be busy with the station reconnect; the
daemon retries the scan start/result up to three times before reporting a
failure.

- Clicking an open network connects immediately. Clicking an encrypted one
  opens a small password dialog with a masked input that already has the
  keyboard focus and a "Show password" checkbox; Ok connects, Cancel closes
  it. The Show checkbox reveals or hides the typed password and keeps its own
  tick mark in sync. Connecting to an open network always starts with an
  empty password, even if one was typed into the dialog before.
- The daemon stores up to 128 access points, the raw SSID bytes are kept for
  connecting while a sanitized copy is used for the display.
- Connecting makes the ESP disconnect and join the selected network; the
  status line shows `Connecting to <SSID>`, then `Connected to <SSID>` or
  `Connection failed rc=N`. The daemon pauses for up to about 10 seconds while
  the ESP does this (the ESP is busy anyway). In the failure code, #FE means
  the ESP was still busy with another command, #FF means it did not answer,
  and any other value is the return code the ESP itself sent (2 = the join
  failed or timed out, 4 = invalid parameters). Open TCP/UDP connections are
  lost by the reconnect. On failure an error box is shown and the ESP stays
  disconnected until another network is selected.
- After a successful connect the daemon sets the status to "no IP" and the
  normal link recovery reads the new IP/DNS configuration from the ESP.
- The Driver tab has a **Disconnect** button under the WiFi line. ESP drops
  the link and no longer reconnects to that network; the daemon shows "no IP"
  and the link state until another network is selected on the Scan tab.

## Settings tab

**Settings** tab is available, for some ESP related specific configuration and
functionality.

- **Nagle algorithm**: checkbox showing the value read from the ESP. Clicking
  it turns Nagle on or off immediately.
- **Wi-Fi on period**: slider with 11 steps - Always on, then 1 to 10 minutes
  (0, 60, ... 600 seconds). Moving the slider only updates the text; the
  **Apply** button sends the value to the ESP. 0 means the radio is never 
  switched off. For a better experience, Always on is recommended, though some
  people have devices that get interference on the audio output while Wi-Fi radio
  is on and might want to have it being turned off after a while. When it is off
  some applications might error on the first try to do any operation while ESP is
  taking its time to reconnect to the Access Point.
- **Firmware**: the version reported by the ESP.
- **Update FW** / **Update Certificates**: local firmware/certificate update
  from the MSX (see below).

The settings are read from the ESP each time the tab is entered or the window
is shown on it.

## ESP firmware and certificate update

The **Update FW** and **Update Certificates** buttons in the Settings tab update the ESP
from a file on the MSX. A small window tells you whether an ESP8266 or ESP32 was
found; for an ESP32 the board name reported by the firmware is shown so you can
choose a suitable firmware for it. Ok opens the SymbOS file selector; after choosing
a file the daemon reads it with the File Manager, sends it to the ESP and shows a small
progress window with a native progress bar. When it is finished the daemon shows
`Updated. / Daemon services will restart after closing this message.`. The progress
window is brought to the front when the update starts.

- A network connection is required before starting an update: the certificate
  index build needs the ESP clock, which is only synced when connected.
- Firmware files must start with the ESP image byte `0xE9`; the daemon refuses
  other files.
- For an ESP32 firmware update the matching `.dat` file (same name) is read
  and sent first so the ESP can validate the firmware type. If the `.dat` is
  missing, too short or rejected the update stops with a clear message before
  touching the ESP.
- The ESP is blocked during the update and the daemon does not process other
  work; there is no cancel. Do not switch off the MSX or the ESP while
  `Finishing...`/`Resetting.` is shown: after the transfer the ESP moves the
  image from the spare blocks to the firmware area and only then restarts.
- A certificate update additionally rebuilds the certificate index after the
  restart (`Indexing certs...`), which can take a while.
- If the update fails before the transfer is confirmed, the ESP may stay in
  update mode until it is power-cycled; the previously flashed firmware is
  unchanged.

## Build information

### Requirements

- **sjasmplus** (tested with **v1.24.0**). Download it from
  https://github.com/z00m128/sjasmplus/releases
  (Windows: `sjasmplus-1.24.0.win.zip`).
  Put `sjasmplus.exe` either on the `PATH` **or** into
  `tools\sjasmplus\sjasmplus.exe` (that folder is git-ignored and not
  committed - sjasmplus itself is not part of this repository).
- Optionally **WinAPE 1.0.13**, should work, though I've never tested it.

### Build with sjasmplus (command line)

```
build.bat
```

or directly:

```
sjasmplus Dmn-Network-_OcmWifi-sj.asm
```

Output: **`netd-ocm.exe`**

`Dmn-Network-_OcmWifi-sj.asm` is a small frontend which maps the WinAPE
directives (`WRITE`, `READ`, `print`, `nolist`) to their sjasmplus
counterparts (`OUTPUT`, `INCLUDE`, `DISPLAY`, `OPT listoff`) - the same
technique used by the official sjasmplus SymbOS example.

### Build with WinAPE 1.0.13

Assemble **`Dmn-Network-_OcmWifi.asm`** (it uses WinAPE syntax directly).
Note: in WinAPE 1.0.13 no colon may appear inside a comment. Building on
WinAPE has not been tested, sorry if it doesn't work.

### Assembler compatibility notes

A few lines of `Dmn-Network.asm` were adjusted so that both assemblers
produce identical code:

- `dw $+7,$+4,28` was split into `dw $+7:dw $+4,28` (WinAPE evaluates `$`
  per operand, sjasmplus once per statement)
- `cp "\"` was written as `cp 92`
- two instructions at column 0 were indented, and a label-after-colon
  (`cfgpthfil0`) was moved to its own lin

## File order in the wrapper

| File | Purpose |
|---|---|
| `Dmn-Network-_OcmWifi.asm` | wrapper with the switches below |
| `SymbOS-Constants.asm` | SymbOS constants (MSC_ MSR_ PRC_ FNC_ ...) |
| `Dmn-Network-head.asm` | application header (from the official SymbOS Network Daemon sources, symbos.de) |
| `Dmn-Network-libs.asm` | flattened SymbOS libs, no ifdef or macro |
| `Dmn-Network.asm` | daemon: DRIVER 7 branch; `else` is the official Prodatron 1.2 source for DRIVER 0-5 |
| `Dmn-Network-OcmWifi.asm` | hardware layer: I/O transport, ESP protocol, detection, DNS, TLS, link check |
| `Dmn-Network-i18n-direct.asm` | using local english texts for DRIVER 7, no localization or common text files being used for simplicity |
| `Dmn-Network-DRIVER7.diff` | DRIVER 7 changes vs the official 1.2 daemon |
| `Dmn-Network-head-DRIVER7.diff` | DRIVER 7-only head/library flags vs the official 1.2 head |

## Switches in the wrapper

| Switch | Meaning |
|---|---|
| `DRIVER equ 7` | this driver (OCM Wi-Fi, ESP UNAPI on I/O ports) |
| `LNGSKIP equ 2` | direct texts, no language pack |
| `ESPDEBUG equ 0` | 1 = compact driver version line in the status tab |
| `TLSVERIFY equ 0` | 1 = the ESP checks the server certificate (needs certs.ar in the ESP), 0 = encrypted but not checked |
| `low_sockmax equ 4` | maximum TCP connections, must be defined before the daemon |
| `low_vermaj/low_vermin` | driver version shown in the daemon (0.9) |

## Inner works / Nerdy details

- **Transport**: all ESP traffic goes through the I/O UART, which is visible
  system-wide, independent of memory banking and slots:
  - `out (#06),a` - command / UART speed / clear FIFO (20)
  - `out (#07),a` - TX data byte
  - `in a,(#06)` - RX data byte
  - `in a,(#07)` - status byte
- **No slot switching**: not needed as only accessing I/O addresses.
- **Detection** uses the ESP firmware Query command: clear the FPGA RX FIFO
  (`out (#06),20` - never reaches the ESP), send `"?"` and wait up to
  1 second for `"OK"`. The `"?"` must be the first byte the ESP sees while it
  is idle. While the OCM transport is being verified, three strategies are
  tried (clear+`"?"`, clear+1 frame+`"?"`, framed NET_STATE). On failure the
  adapter line (Status tab) shows `st=hh rD` and the driver tab info line shows
  `rA/B/C st=hh` - status byte before the last send and bytes received per
  strategy.
- **Quick receive**: status bit 3 (hardware capability) is detected and
  stored; the driver tab shows "ESP on I/O, QR supported" or "ESP on I/O".
  Even if Quick Receive is supported, this daemon doesn't use it, as it will
  assert WAIT for up to 20ms (or having data on FIFO) when reading directly
  from the UART to speed up transfer of large blocks of data (no need to poll
  before reading when you already received the command header and data size),
  which works quite nicely on MSX DOS where no one else is using the CPU while
  data is being read, but not so much on SymbOS where those CPU pauses to wait
  for data might slow down other processes that could be using the CPU.
- The ESP does DHCP, DNS and TCP. The driver follows the M4Board
  "high level" model.
- Long operations (TCP open up to 60s, DNS up to 15s) are split - the request
  is sent at once, the answer is collected by polling later (`lowtst` /
  `espdnr`).
- Link light is on while the network is online, a NET_STATE check runs about
  every 5 seconds and drops the status to "No IP" if the WiFi is gone. TX and
  RX lights hold for a short time after data moved.
- A peer close (CLOSE_WAIT) is not published while the ESP still holds buffered
  data: the socket keeps reporting "established + data received" until the
  buffer is drained, and only then the close event is sent. Applications
  therefore receive the complete transfer before they see the connection end.
  Every TCP socket is also polled with the ESP TCP_STATE command; if a query
  fails, the socket is reported closed (the daemon retries on the next pass).

## Related projects

- ESP8266 UNAPI firmware: https://github.com/ducasp/ESP8266-UNAPI-Firmware
- UNAPI BIOS sources (SM-X / MSX PICO): https://github.com/ducasp/MSX-Development
- PicoVerse memio daemon this is based on: https://github.com/Jzzy-dev/msx-picoverse-symbos-network-daemon
- SymbOS: http://www.symbos.de/

## Not done

Signal strength and language packs. The ESP-hosted IP/DNS configuration.

## License

LGPL-2.1 (see `LICENSE`). Based on Jzzy's
[msx-picoverse-symbos-network-daemon](https://github.com/Jzzy-dev/msx-picoverse-symbos-network-daemon)
and Prodatron's SymbOS Network Daemon.
