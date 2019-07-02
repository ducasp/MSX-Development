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

WAITWIFI (c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as 
the source code of changes is made public as well.
