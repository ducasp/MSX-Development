# TFTP v1.1

TFTP v1.1 is based on TFTP v1.0 by Nestor Soriano / Konamiman.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

This version removes the wait for a whole tick after TCPIP_WAIT calls
for at least a whole tick (1/50s or 1/60s) that were not needed. This 
saves some time that can be spent transferring data . 
It also changes the way actual transferred data is printed to print less
as MSX VDP and DOS routines are not exactly fast doing this.

Source code is no longer here, it can be found at my copy of Konamiman repository: https://github.com/ducasp/MSX
		   
TFTP v1.1 by 2019 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the source code of changes is made public as well.
