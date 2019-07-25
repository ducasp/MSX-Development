# SNTP v1.1

SNTP v1.1 is based on SNTP v1.0 by Nestor Soriano / Konamiman.

This is a small fix...

If the count of seconds elapsed received by SNTP Server is a multiple of 60,
the original version would try to set the time as HH:MM-1:60 instead of setting
HH:MM:00.

Source code is no longer here, it can be found at my copy of Konamiman repository: https://github.com/ducasp/MSX

SNTP v1.1 (c)2019 Oduvaldo Pavan Junior - ducasp@gmail.com

All code can be re-used, re-written, derivative work can be sold, as long as the source code of changes is made public as well.
