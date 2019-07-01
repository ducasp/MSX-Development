# TFTPF v1.1f

TFTPF v1.1f is based on TFTP v1.0 by Nestor Soriano / Konamiman.

How TFTPF is any different than the original TFTP?

You have /R or /G to get files, and /S or /P to send files. If using G or P it
will not issue TCPIP_WAIT calls for at least a whole tick (1/50s or 1/60s) 
after each packet like the original does. This saves some time that can be 
spent transferring data as long as the network device you use DO NOT NEED 
TCPIP_WAIT to work properly. I believe that DENYONET and OBSONET are two 
examples that will not work with this option as they depend on having free time 
on VDP interrupts. It also won't print actual transferred data as MSX VDP
is not exactly fast doing this.
		   
Using /R or /G options using a local TFTP server to my MSX using an ESP8266
based network adapter HGET performance went from 12KB/s (original) to a whooping
22KB/s (no breathe, no print)!!!

TFTPF (c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the source code of changes is made public as well.
