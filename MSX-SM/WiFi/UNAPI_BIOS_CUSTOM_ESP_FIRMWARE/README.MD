# Wi-Fi BIOS for ESP8266 w/ Custom Firmware

This BIOS will offer the SM-X users the following TCP-IP UNAPI functionality:

	- Up to four consecutive connections (except when using TLS/SSL)
	- UDP and TCP capable
	- DNS Resolution
	- Passive and Active connections accepted
	- TLS/SSL support for one active TCP connection

It doesn't implement the following functionality:

	- PING: ESP doesn't expose the functionality as UNAPI requires
	- RAW: Raw connections aren't implemented

The functionalities not supported are barely used, to my knowledge, by any
program (except for PING that is used by the PING utility by Konamiman). It is,
also, one of the very few UNAPI that supports TLS/SSL connections.

By default, it will automatically install itself and make available an UNAPI
TCP-IP implementation for usage by any applications. Also, by default, the
connection behavior is: Wi-Fi is turned on at startup, will stay turned on for
at least 30s, if there is no connection opened. Whenever a command is received
it starts to count for inactivity, and if 30s elapses, checks whether there is
a connection opened (some program using it) or not, and if not, it will turn
the Wi-Fi radio off. Wi-Fi radio will turn on again automatically upon a DNS
request, TCP connection open request or GET IP INFO command. Some applications
might not use those commands as their first UNAPI command (i.e.: HGET check
network state first) and might error the first time you try to use a command,
but then just call the application again and it will work just fine.

Reason for this default behavior is that quite a few users have reported that
their SM-X has interference noise on the analog audio output when Wi-Fi is
set-up. So, that default behavior alleviates the issue for most users while
allowing them to keep using Wi-Fi features when needed and not having noise on
audio while not using it. The reason to not implement the wait for Wi-Fi radio
to be turned on and connected on every UNAPI command is that it could cause
unexpected behavior on applications on functions that should return pretty
quickly.

If that still doesn't work for you, you can effectively disable the UNAPI and
Wi-Fi at the configuration menu, option 4.

# Configuration Menu

While booting your computer, if you keep F1 key pressed, you will be presented
with a configuration menu. It has four options:

1 - Set Nagle Algorithm
2 - Set Wi-Fi On Period
3 - Scan/Join Access Points
4 - Wi-Fi and Clock Settings

At any point in the main configuration menu you can hit the ESC key to resume
the boot sequence of your computer.

# Set Nagle Algorithm

Nagle Algorithm is something designed to avoid network congestion due to
excessive amount of small packets. Nowadays, this is mostly not the case, and
it adds latency to small packets, causing really poor performance on protocols
that have a schema to acknowledge a package has been received and do not send
the next packet until the acknowledge from the other end is received (and 
sometimes, if this takes too much time, send a retry packet). It will increase
latency between packets and kill throughput. In my tests you are better off with
Nagle Disable, but in this menu you can turn it on if you find the need to.

Default option is to have Nagle Algorithm turned off.

# Set Wi-Fi On Period

Some users have interference from the Wi-Fi module on the SM-X analog audio
output, so, in this menu you can choose two possible behaviors: 

ALWAYS ON: by choosing 0 as period, Wi-Fi will be always on, this is my
personal preference as I do not have any audio issues in my SM-X.

TURN OFF WHEN IDLE: by choosing 1 to 999 as period, Wi-Fi will be turned on
at startup, and then after the chosen time elapses after the last command has
been received by the interface, it will check if there are any open connections
(i.e.: an application running), and if there is, schedule the time-out again.
If there are no open connections, it will shut down the Wi-Fi radio (which, for
users that have the audio interference issue, will stop the interference). The
minimum time-out period is 30s, so if you choose anything between 1 and 29 the
period will be set to 30s. Also, the maximum time-out period is 600s, so if you
choose anything between 601 and 999, the period will be set to 600s.

Periods lower than 30s are not accepted to avoid impacting applications that
wait a while between commands and ensure proper functionality once a connection
has been stablished.

NOTE: Whenever a new command is received, ESP8266 will turn on Wi-Fi again, but
it takes a few seconds to have it connected to the configure Access Point. So,
to avoid applications to return error when executed if Wi-Fi turned off, this
interface will wait for that connection to be stablished up to ten seconds
before returning an error:

	- TCPIP_GET_INFO
	- TCPIP_DNS_Q
	- TCPIP_TCP_OPEN

This wait is not implemented on all commands because it would result in bad
performance and could lead to the feeling applications are not responding while
Wi-Fi connection is being stablished. If for some reason application doesn't
use any of those functions as their first command, it is possible that the
application will return telling that there is no connection. Wait a few seconds
and try again.

Default option is to have a 30s period set-up.

# Scan/Join Access Points

Use this option to configure which Access Point your SM-X will connect to. Once
set-up, whenever Wi-Fi is on, the adapter will automatically try to connect to
the configured access point. It will list up to eight Access Points and you can
choose to connect to any of the listed access points by hitting the number key
related to it on the screen. If more than eight access points are available, a
message on screen will tell you about that and hitting SPACE will jump to the
next page. To enter the network name manually you can hit the ENTER key. In
that case, after entering the SSID manually, you will be asked whether that AP
needs a password, Y or y will allow you to enter the password, any other key
will mean no password is needed.

If the Access Point needs a password, the default behavior is that what you
type is not printed on the screen, but you can hit the DELETE key before
entering the password to show it while you type.

P.s.: Some Access Points allow non-standard characters to be used for the pass
phrase. This ROM will accept any keyboard key and get its input code and use
it, except for NULL (code 0x00), BACK SPACE (code 0x08), ESC (code 0x1B) or
ENTER (code 0x13), which are used to indicate end of string, erase a wrong
entry, abort entering password and end of entry. As many keyboard entries are
not printable on screen, a '?' character will be printed if that is the case.
Also notice as DELETE is used to toggle between hiding or showing what is typed
as pass phrase, 0x7F is not possible as first character in a pass phrase, but
can be used for any other position.
Non-standard characters in the pass phrase should be avoided, if you must have
those, at least avoid having 0x00, 0x08, 0x13 and 0x1B, and it is up to you to
figure out which keys translate to a given hex code. :)
The same applies to SSID, in that case 0x07 can be used as first character in
a SSID, but again, non-standard characters should be avoided. 

# Wi-Fi and Clock Settings

This option allows you to:

	- Have the adapter and Wi-Fi enabled (option 0)
	- Same as above, but will update date and time during boot (option 1)
	- Same as above, but turn Wi-Fi off immediately after setting clock
	- Disable the adapter and Wi-Fi (option 3)

Options 1 and 2 are a great way to have clock and date properly set-up at
boot time, automatically. It is faster than having WAITWIFI and SNTP programs
loaded in your AUTOEXEC.BAT, and for those that have interference on the audio
output of their SM-X, option 2 is perfect as if you don't have any application
that uses TCP-IP UNAPI commands on your AUTOEXEC.BAT, Wi-Fi is turned off as
soon as clock is adjusted. For those that do not have this issue or that are
not bothered by it, option 1 allows for faster operation at start-up of UNAPI
applications if the Wi-Fi On Period is set to ALWAYS ON. If you just do not
want to have anything Wi-Fi related enabled, option 3 will make sure that noise
interference do not occur even at boot time.

Default options is adapter and WiFi enabled but do not update clock.

# ESP8266 Firmware Update

To have this BIOS properly working, your ESP8266 must have at least version 1.2
of firmware installed. If an older firmware is not installed, the BIOS will not
initialize and print an error message, but you can still use UNAPI with the
RAM / Memory Mapper driver (ESP8266.COM) and update the firmware to version 1.2
using CFG8266. Please remember to update certificates after updating firmware,
otherwise TLS/SSL connections will fail.

Once you do that, please remove RAMHELPR.COM, ESP8266.COM, WAITWIFI.COM,
SNTP.COM and CFG8266.COM from your autoexec routine, those are no longer needed
for your AUTOEXEC.BAT if you just use it to set up time and date and
ESP8266.COM is not needed when BIOS is running.

WAITWIFI.COM and CFG8266.COM can still be used with the BIOS version, and if
you have other TCP-IP applications than SNTP on your AUTOEXEC.BAT you might
want to keep then on it. CFG8266.COM is the only way to update ESP8266 firmware
as well. SNTP.COM works nicely with this BIOS, it just makes more sense to
use the BIOS functionality to set date and time as it is faster.

# ESP8266.COM, CFG8266.COM and WAITWIFI.COM

Once you have the BIOS properly setup and running, ESP8266.COM is no longer
needed. CFG8266.COM still is needed to update firmware and certificates of
ESP8266. WAITWIFI.COM can be used if you want to make sure ESP8266 is online
before executing any program.

# Quick Receive

Quick Receive allows the BIOS / UNAPI to be faster and more efficient when
receiving large blocks of data over TCP or UDP connections. It is specially
effective when you run your SM-X with regular 3.58MHz z80 speeds, even though
the raw network performance gain in this scenario is over 60%, notice that
applications performance will not increase that much as applications use CPU
time to write to screen, write to disk, etc... I.e.: HGET is 17% faster when
quick receive is enabled and CPU speed is 3.58MHz. For turbo CPU speed, it
might be difficult to find out some difference in performance.

Quick Receive needs support in the interface between ESP8266 and z80, that
means, FPGA firmware need to support it. Make sure to have your SM-X updated
with the latest revision of FPGA firmware to benefit from this feature, but
if you still don't have the FPGA firmware that supports it, it will work just
fine and as fast as the RAM driver option does nowadays.

# Technical details

This is a 16KB ROM, designed to not need any RAM in the interface, but it
does reserve 30 bytes of TPA memory for itself.

It can be used on any slot on MSX2 and better, and it seems it doesn't
always work on slot 0 on MSX1 (but then, this is not a big deal). Slot 0
is mostly for built-in roms, like for SM-X.

This BIOS is a simple tunnel for a Custom ESP8266 firmware that implements
UNAPI internally. This results on a high performance as Z80 processing time
is not wasted buffering data or converting parameters/responses.

It does not need interrupt, so, it is blocking waiting ESP to respond, which
usually is immediate, so we might lose a few CPU cycles waiting the data
coming but on the other hand we do not need to move memory/data that is really
expensive, and UNAPI functions are blocking anyway.

I've made a customized ESP8266 firmware that is distributed for free for SM-X /
MSX-SM owners, but, if you want to use it on your own device, contact me so we
can talk about, that firmware is not free for commercial usage and can't be
copied / used without my agreement.

This BIOS assumes the use of an ESP8266 with a custom firmware in a MSX-SM 
serial interface. That is the interface specification:

-- Address 0x07 send to tx uart buffer or read to get uart status
--
-- Address 0x06 send to set UART speed or read to get uart rx buffer
--
-- 0x06 Address Write commands:
--
-- 0 - UART 859372 bps
-- 1 - UART 346520 bps
-- 2 - UART 231014 bps
-- 3 - UART 115200 bps
-- 4 - UART 57600 bps
-- 5 - UART 38400 bps
-- 6 - UART 31250 bps
-- 7 - UART 19200 bps
-- 8 - UART 9600 bps
-- 9 - UART 4800 bps
-- 20 - Clear FIFO buffer
--
-- 0x07 Address Uart Status bits:
--
-- bit 0 - does fifo rx buffer have data?
-- bit 1 - is data transmission in progress?
-- bit 2 - is fifo rx buffer full?
-- bit 3 - is uart quick receive capable?
-- bit 4 - did buffer underrun occur? Reset automatically once read
-- bit 6 - 0 if in interrupt with 128 bytes of data or more, 1 if free (avoid 
   open bus confusion)
-- bit 7 - 0 if in interrupt, 1 if free (avoid open bus confusion)

# NOTE

Yeah, I know, it is not the leanest, cutest piece of z80 code you are going to
find. But, since the 16KB of memory is already allocated and won't be used for
anything else, I've tried to make the code faster at expense of size and 
perhaps legibility... It might get better, probably it can even be a little
faster, who knows? :)

# SPECIAL THANKS TO...

KdL - He has a very keen eye to details and has been really helpful, both by
suggesting different approaches / design choices and testing this BIOS with
extensive care. It wouldn't be nearly as good as it is now without his help,
and working with him also is bringing my attention to details and to a better
level. ESPSETUP.COM was designed by him as well :) 

Konamiman - SM-X Network support is something that has started in early 2019,
by then I had the idea that making a BIOS for a device or even fully coding in
z80 ASM was something out of my league. And, perhaps, it was, but thanks to
starting slow and getting things to work, the desire to get it to an even
better state drove me to push beyond my limits, and, I surely wouldn't be able
to do it without the kind help of Konamiman. Whenever I asked what probably
were silly questions for him, he was kind enough to take time and answer me,
also, by leaving all UNAPI Drivers, BIOS and Network applications source code
available. Source code is a huge classroom, with lots and lots of useful
information and approaches. Also, he was very kind to work along with me on all
my suggestions that lead to improvements in the current stack of NETWORK
software like TFTP and HGET, which, most of us that are programmers know is
not the usual in software development. :) 

Victor Trucco - Once I've volunteered to work on SM-X Wi-Fi features, he also
was really kind offering help and examples, teaching me quite a lot about FPGA
and how to work with it, best practices, etc. Accepting to ship every SM-X sold
with the Custom ESP firmware I've developed was something unexpected and that
I'm really grateful.

# BORING COPYRIGHT STUFF

All source code and binaries: 
(c)2020 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
