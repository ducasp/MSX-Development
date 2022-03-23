# UNAPI
UNAPI software made by myself and others.
Generally, if the software was made by others, my revision is in order to have
better performance. Unfortunatelly MSX is dead-slow writting text to screen...

As such, avoiding to write to screen will speed-up performance, specially when
software updates how many bytes have been transferred writing the same line over
and over and over... Print less, print just what is needed, gives great results!

Another common pitfall on some tools is to add an extra wait for a VDP interrupt
(or tick, or 1/60-1/50ms period) after calling TCPIP_WAIT. This waste time, the
whole idea is that if the adapter need any pauses/time not receiving request for
optimum performance, it should implement it in TCPIP_WAIT, and if not needing,
just return immediatelly. Thus, an extra wait after returning from TCPIP_WAIT 
will just make it slower for adapters/connections fast enough.

All source code and binaries: 
Original work (c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com
For reworked software, the original copyright will be left intact.

All code can be re-used, re-written, derivative work can be sold, as long as the source code of changes is made public as well.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)
