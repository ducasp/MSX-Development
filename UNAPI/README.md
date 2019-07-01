# UNAPI
UNAPI software made by myself and others.
Generally, if the software was made by others, my revision is in order to have
better performance. Unfortunatelly MSX is dead-slow writting text to screen...

As such, avoiding to write to screen will speed-up performance, specially when
software updates how many bytes have been transferred...

Another general performance enhancement is an idea from Louthrax (SofaRun and
other great stuff), pre-allocate the whole file when file size is known. MSX is
not exactly fast dealing with FAT16 partitions, specially bigger ones. In order
to calculate free space (which it does every time it flushes disk buffer to the
file and has to allocate more space) it will spend a few seconds, seconds no 
other task will run. Pre-allocating file with its whole size will have this time
consuming task ocurring only once, instead of once every time buffer is flushed.

All source code and binaries: 
Original work (c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com
For reworked software, the original copyright will be left intact.

All code can be re-used, re-written, derivative work can be sold, as long as the source code of changes is made public as well.
