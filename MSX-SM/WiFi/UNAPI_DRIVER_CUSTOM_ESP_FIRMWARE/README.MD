# WiFi Driver for ESP8266 w/ Custom Firmware

This driver is a simple tunnel for a Custom ESP8266 firmware that implements
UNAPI internally. This results on a high performance as Z80 processing time
is not wasted buffering data or converting parameters/responses.

It do not need interrupt, so, it is blocking waiting ESP to respond, which
usually is immediate, so we might loose a few CPU cycles waiting the data
coming but on the other hand we do not need to move memory/data that is really
expensive.

I've made a customized ESP8266 firmware that is distributed for free for SM-X / 
MSX-SM owners, but, if you want to use it on your own device, contact me so we
can talk about, that firmware is not Open Source and can't be copied / used 
without my agreement.

This driver assumes the use of an ESP8266 with a custom firmware in a MSX-SM 
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
-- bit 6 - 0 if in interrupt with 128 bytes of data or more, 1 if free (avoid 
   open bus confusion)
-- bit 7 - 0 if in interrupt, 1 if free (avoid open bus confusion)

# NOTE

Yeah, I know, it is not the leanest, cutest piece of z80 code you are going to 
find. But, since the 16KB of memory is already allocated and won't be used for
anything else, I tried to make the code faster at expense of size and perhaps
legibility... It might get better, probably it can even be a little faster, who
knows? :)

All source code and binaries: 
(c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
