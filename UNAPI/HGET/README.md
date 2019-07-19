# HGET v1.3

HGETF v1.3 is based on HGET v1.1 by Nestor Soriano / Konamiman.

How HGET v1.3 is any different than the original HGET?

It adds TCP-IP UNAPI v1.1 support, that means, if TLS over TCP is supported it is 
used to make it possible to download files from HTTPS servers. This works ONLY if 
your device UNAPI is v1.1 and it implements TLS (at this moment MSX-SM UNAPI is the 
only one that do that). TLS handshake and the crypto processing involved is too much
for a z80, even running at 10MHz).

Due to TLS/HTTPS support, two new options were added:

	- /u : Unsafe TLS connection. If the UNAPI device allows to check host name
	       and host certificate, HGET will request this to be done. This option 
	       allow the user to download from an HTTPS server if HGET tells it is 
	       not safe (i.e.: user really want to do it anyway, or, user adapter
	       might not have the certificates to validate that server and user do
	       want to download anyway).
	- /n : Do not validate host name, but still validate the certificate. It is
	       not unusual to find web servers that have a valid certificate for a  
	       certain domain (i.e.: mail.company.com) and not of a subdomain (i.e.:
	       owa.company.com). So, this will allow to connect if certificate is ok
	       but hostname is not. (I would say this is unsafe unless you know the
	       site is good)
		   
Also it removes the wait for an extra-tick (1/60s or 1/50s) after calling TCP_WAIT
after checking if there is data to receive. This is not necessary as any adapter that
need specific waiting will implement it in TCP_WAIT, and having this wait for a tick
change on adapters that do not need it can impact transfer performance.

Last but not least, instead of showing how much KB of data has been transferred, I've
done a different approachs:

- When file size is known, a progress bar with 4% increments is shown. Every 4% 
transferred, the bar will update.
- When file size is unknown, a star like moving animation is shown to indicate it is
not stuck.

This makes HGET a lot faster with fast adapters like MSX-SM ESP8266 based UNAPI. The
old approach prints a full line every block received, this one will just print ONE 
character every block received (unknown file size) or ONE character every time 4% of
file is received (known file size), allowing the time that was used to write those
lines of text to get data and write it to the disk! :-)

Downloading from a local server to my MSX using an ESP8266 based network adapter HGET 
performance for a 512KB file went from 5KB/s (original) to:

	- Whooping 34KB/s (no extra tick, not printing every block received)!!!

HGET v1.3 - 2019 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the source 
code of changes is made public as well. (Unless this violates the original code owner
policies, which, in this case, the original owner rules applies!)
