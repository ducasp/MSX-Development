# WiFi Driver for ESP8266 w/ Custom Firmware

This driver is a simple tunnel for a Custom ESP8266 firmware that implements
UNAPI internally. This results on a high performance as Z80 processing time
is not wasted buffering data or converting parameters/responses.

It does not need interrupts, so, it is blocking waiting ESP to respond, which
usually is immediate, so we might loose a few CPU cycles waiting the data
coming but on the other hand we do not need to move memory/data that is really
expensive.

I've made a customized ESP8266 firmware that is distributed for free for SM-X /
MSX-SM owners, but, if you want to use it on your own device, contact me so we
can talk about it, that firmware is not Open Source and can't be copied / used
without my agreement.

# Release Notes v1.1

Those are the changes:

- If for some reason an ESP response byte is lost due to error or somehow ESP
  was unplugged, misbehave, driver would freeze waiting data. Now ALL driver
  functions have time-outs not only to receive the header of the command but
  also for the whole response
- Changed the way to work with time-outs to be more reasonable as the old way
  of polling JIFFY and comparing and checking if it was leaping would not be
  efficient to use for all bytes, now the driver hooks to HTIM_I interrupt, 
  so it decreases its own counter and just checking if it is not zero is way
  faster and allow us to adjust the timeout value we want at any time
- Added support to retry receiving data from ESP on TCP_RCV and UDP_RCV, it
  will retry up to three times if all data is not received. Communications
  should be pretty reliable and UNAPI has return errors for all functions,
  but you can't retry receiving data, once it is cleared from buffer it is
  gone, thus why those two functions received extra care on this department
- General code clean-up of unused functions: this driver was largely based on
  my attempt of having an UNAPI driver that used ESP8266 AT Firmware, and thus
  some leftover code and variables and comments where all over the place
- More consistence in structure and comments, mostly helpful for those that
  will look at the source code :)

# Release Notes v1.0

Initial release for SM-X launch. This driver is a full TCP IP UNAPI 1.1
implementation, but doesn't support the following UNAPI features:

- PING: the way UNAPI works with PING is different than what ESP8266 api's
  offer, probably could do it directly through UDP but didn't think it is
  worth the trouble
- TLS: it supports TLS over a single active TCP IP connection, due to memory
  constraints within ESP and a default requirement of large buffers of TLS,
  it is not possible to have more than one TLS connection. Also, it doesn't
  support passive TLS connections, still need to think how this would work
  as a passive connection requires host certificates
- RAW: no RAW networking support, only TCP and UDP, this should not pose an
  issue for any current MSX TCP UNAPI application

# Technical Details

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
(c)2019-2020 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
