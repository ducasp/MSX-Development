# WAITWIFI v0.14

Minor change to the waiting animation, so it is the same on all machines, not
using '\' as it is a different character on non-international BIOS machines.

# WAITWIFI v0.13

KdL was very kind by improving animation to not look jerky
Forgot to document the TERSE option implemented by KDL in v0.12:

	- If you use WAITWIFI /T it will use TERSE mode, so it won't output text
	  unless there is an error or when connection is made

# WAITWIFI v0.12

KdL was very kind by improving the text output of the tool

# WAITWIFI v0.11

Changed the routines that print to screen from the ones in fusion-c to the one
based on Konamiman print routine in HGET. Fusion-C printf and Print uses BIOS
calls that do not allow redirection of output. This version now allows to be 
used in silent mode by redirecting its output to NUL: WAITWIFI > NUL

# WAITWIFI v0.1

This is a small utility. I've found a need for it while developing an UNAPI 
driver, where at startup the driver would reset the ESP8266 in order to get it
to a known state, but then it would take a few seconds to connect to a WiFi 
access point, if any configured. Instead of making the driver lock waiting for
such connection that might occur or not, I've created this utility so you can
place it in your AUTOEXEC.BAT after loading the UNAPI driver and before calling
any other UNAPI (i.e.: I have SNTP.COM to update my MSX clock every boot).

It will wait up to 10 seconds until the installed TCP/IP UNAPI implementation
state goes to CLOSED. Once it goes to closed or time-out occurs, it will quit.

WAITWIFI (c)2019-2020 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as 
the source code of changes is made public as well.
