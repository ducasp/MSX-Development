# HUB v1.3

HUB v1.3 is based on HUB v1.2 by fr3nd / Carles Amigó.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

How HUB v1.3 is any different than the original?

HUB v1.3 (unofficial) intends to speed-up download speeds. A lot!

Downloading to my MSX using an ESP8266 based network adapter HUB performance for 
file transfers went from 3KB/s (original) to:

	- Whooping 20KB/s!!!

To speed up things it removes the wait for an extra-tick (1/60s or 1/50s) after 
calling TCP_WAIT after checking if there is data to receive. This is not necessary as
any adapter that need specific waiting will implement it in TCP_WAIT, and having this 
wait for a tick change on adapters that do not need it can impact transfer performance.

Also, internally it was transferring the buffer with received data from the adapter,
byte per byte, to another buffer and then writting to disk.

Last but not least, I've changed a little bit the format of the progress bar to make it
easier to quick updates, and updates only when needed:

- No longer uses float and other math that is too heavy for Z80. Just use sum and
comparison.
- No longer print the whole line every time a block is received, only when the progress 
bar has changed.
- No longer print the whole line when updating the progress bar, just update adding the
extra = and > in the new position.

This makes HUB a lot faster with fast adapters like MSX-SM ESP8266 based UNAPI, allowing
the time that was used to write those lines of text to get data and write it to the 
disk! :-)

HUB v1.3 - 2019 Oduvaldo Pavan Junior - ducasp@gmail.com

Source code is no longer here, it can be found at my copy of fr3nd repository:
https://github.com/ducasp/msxhub

All code can be re-used, re-written, derivative work can be sold, as long as the source 
code of changes is made public as well. (Unless this violates the original code owner
policies, which, in this case, the original owner rules applies!)
