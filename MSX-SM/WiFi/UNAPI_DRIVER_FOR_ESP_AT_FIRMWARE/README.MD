# WiFi Driver for ESP8266 w/ standard AT Firmware

This driver is a work that no longer is in progress. When starting to get 
MSX-SM on the Internet, idea was to take advantage of ESP8266 built-in AT
firmware. Development went all the way until I've figured out that relying
on controlling the TCP/IP Window by the serial communication speed would not be
a reliable/good solution.

But, this code might help some people:

- Figure out how a Mapper UNAPI works
- Figure out how to have a hook calling your UNAPI driver code (in this case,
  the interrupt hook)
- Figure out a crazy state machine for the not efficient AT protocol of 
  Espressif AT Firmware
  
Important:

This code relies on a feature present only on the most recent AT firmware. That
firmware was not release for 1MB flash memory modules by Espressif, but Loboris
was kind enough to generate a firmware with all the latest features that fits
into a 1MB module, use that firmware in your ESP module to work with this code.

https://github.com/loboris/ESP8266_AT_LoBo

Known issues:

- It works pretty good, even though not highly efficient due to protocol 
  overhead (too much characters for some commands) as well protocol sometimes
  being plain stupid (I want to send xxx bytes... Wait ok from the other end,
  and only then send)
- For some reason it is not reliable with OBSOSMB (slow, hangs, etc) and also
  OBSOSMB doesn't indicate the correct IPs that connect on the passive
  connections
- Not all UNAPI commands are implemented, but the most important ones are
  
Possible paths to enhance:

- Memory is critical, everything, including buffers, must fit a 16KB memory
  segment. Lowering the number of connections might give room for more code
- The state machine relies heavily on interruptions from the device, if you are
  porting this code for a different interface that doesn't generate interrupts,
  you will want to change the logic on the state machine
- MSX-SM serial interface was working this way when this code was implemented:

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
-- 21 - Turn On Interrupt every received byte
-- 22 - Turn Off Interrupt
-- 23 - Turn On Intelligent Interrupt
-- 255 - Acknowledge Interrupt
--
-- Intelligent interrupt rules: send interrupt when FIFO contains at least 128 bytes
-- OR when more than 1ms occurred since last byte was pushed to FIFO
--
--
-- 0x07 Address Uart Status bits:
--
-- bit 0 - does fifo rx buffer have data?
-- bit 1 - is data transmission in progress?
-- bit 2 - is fifo rx buffer full?
-- bit 6 - 0 if in interrupt with 128 bytes of data or more, 1 if free (avoid open bus confusion)
-- bit 7 - 0 if in interrupt, 1 if free (avoid open bus confusion)

All source code and binaries: 
(c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.
