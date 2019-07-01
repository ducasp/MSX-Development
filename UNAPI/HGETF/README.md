# HGETF v1.2f

HGETF v1.2f is based on HGET v1.1 by Nestor Soriano / Konamiman.

How HGETF is any different than the original HGET?

It adds two new options:

	- /b : It will not issue TCPIP_WAIT calls for at least a whole tick (1/50s
		   or 1/60s) after each packet like the original does. This saves some
		   time that can be spent transferring data as long as the network
		   device you use DO NOT NEED TCPIP_WAIT to work properly. I believe
		   that DENYONET and OBSONET are two examples that will not work with
		   this option as they depend on having free time on VDP interrupts.
		   
	- /n : It doesn't work when resuming a download and any download started 
		   with it won't resume. Why? Because the whole file size is allocated
		   in disk and then new data is written as it arrives. If transfer fail
		   before finishing, file size will be the same as a complete download (
		   remember, file was created with its total size at beginning). Why does
		   that? Well, it is faster... Way faster.... Way, way faster... If your
		   adapter and cpu is up to it. :-) And nowadays internet connections
		   and servers are really reliable.
		   
Using both options downloading from a local server to my MSX using an ESP8266 based network
adapter HGET performance for a 512KB file went from 5KB/s (original) to 20KB/s (no breathe)
to a whooping 34KB/s (pre allocate, no breathe, no print)!!!

HGETF (c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the source code of changes is made public as well.
