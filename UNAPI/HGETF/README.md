# HGETF v1.2f

HGETF v1.2f is based on HGET v1.1 by Nestor Soriano / Konamiman.

How HGETF is any different than the original HGET?

It adds a new options:

	- /b : It will not issue TCPIP_WAIT calls for at least a whole tick (1/50s
	       or 1/60s) after each packet like the original does. This saves some
	       time that can be spent transferring data as long as the network
	       device you use DO NOT NEED TCPIP_WAIT to work properly. I believe
	       that DENYONET and OBSONET are two examples that will not work with
	       this option as they depend on having free time on VDP interrupts.
		   
Downloading from a local server to my MSX using an ESP8266 based network adapter HGET 
performance for a 512KB file went from 5KB/s (original) to:
	- 9,5KB/s (no extra options)
	- Whooping 24KB/s (no breathe, no print)!!!

Just a side note, if discounting the time creating the file, actual transfer rate
would be 34KB/s (no breathe, no print), yes, large FAT16 partitions are slow... :(

HGETF (c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the source 
code of changes is made public as well. (Unless this violates the original code owner
policies, which, in this case, the original owner rules applies!)
