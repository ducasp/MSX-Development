# WiFi Driver for ESP8266 w/ standard AT Firmware

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

This driver is a work that no longer is in progress. When starting to get 
MSX-SM on the Internet, the idea was to take advantage of ESP8266 built-in AT
firmware. Development went all the way until I've figured out that relying
on controlling the TCP/IP Window by the serial communication speed would not be
a reliable/good solution. MSX-SM comes with an ESP8266 module with 1MB of flash
memory, and ESPRESSIF unfortunately no longer supports that configuration. Just
on the first firmware release by them, that do not support 1MB modules, they 
have implemented TCP/IP passive mode (AT+CIPRECVMODE=1), that solves this. Well
, Loboris has ported those changes making it fit 1MB modules and getting rid of
features that do not generally matter, so this code benefits heavily on Loboris
AT firmware and having TCP/IP passive mode... So, you need to install Loboris
firmware if you plan to use ESP8266 and not lose packets and this code won't 
even work without it.

But, and there is always a but, even with Loboris firmware I was not satisfied,
look at the code to manage PASSIVE TCP/IP connections (ESP acting as a server
waiting for incoming connections), CLOSE_CONN and CLOSE_CONNECTION allong with
OPEN_TCP allong with MY_INTERRUPT_HANDLER are really intertwinned and complex,
to the point that I don't even remember if this version of code has all the
quircks of passive connection/disconnection solved or not. :) This is due to
the AT Firmware being made to be "human friendly", that means, it is not an
efficient implementation for a computer (i.e.: hey ESP, I want to send X bytes
of data.... ESP: Hmmm, ok, send it... And now I'm sending... What the heck, 
just have SEND X (X bytes) and receive an Ok or error in the end... Not to 
mention large and complex messages that we need to convert hexadecimal to 
ASCII strings and vice versa...)

Also, using AT firmware you would need to buffer data in your own memory and 
then move that data to the application buffer when it requests the data. (On a
custom firmware, I just keep the buffer in the ESP and the data goes from ESP
to MSX only when we know the address we want to have the data for the RCV 
request)

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

This code relies on MSX-SM serial port that had an useful inteligent interrupt
that helped it move on. That means, it would generate an interrupt whenever 
1ms elapsed since last byte was received OR at least 128 bytes was received. 
Without this kind of interrupt, this code might suffer. You would depend on 
VDP interrupts to get the receiving interrupt to handle data, that means, one
each 1/60 or 1/50s, and you won't be able to known if you can transfere a big
chunk of data. It is very possible to adapt and have it working on an interrupt
less serial port, but I would expect receiving data rates to suffer as it would
need to be done byte per byte (which, depending on the serial port speed might
not matter at all, we've used > 850Kbps on MSX-SM, so byte per byte wouldn't be
fast enough to get 40/50KBps).

Known issues:

- It works pretty good, even though not highly efficient due to ESP protocol 
  overhead (too much characters for some commands) as well protocol sometimes
  being plain stupid (I want to send xxx bytes... Wait ok from the other end,
  and only then send)
- For some reason it is not reliable with OBSOSMB (slow, hangs, etc) and also
  OBSOSMB doesn't indicate the correct IPs that connect on the passive
  connections
- Not all UNAPI commands are implemented, but the most important ones are
  
Possible paths to enhance:

- Memory is critical, everything, including buffers, must fit a 16KB memory
  segment. Lowering the number of connections might give room for more code or
  larger buffers
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
