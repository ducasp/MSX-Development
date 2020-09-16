# HUBG v0.80

(c)2020 Oduvaldo Pavan Junior - ducasp@gmail.com

# CHANGELOG v0.80

	- A bit faster menus: menus were optimized to lessen characters sent to
	  MSX2ANSI library, making then a bit faster
	- A fix for packages that might leave some files on a folder before HUBG
	  interprets it should delete a folder, this should fix the few packages
	  that left a folder/directory empty after uninstallation
	- HGET Lib updated to v0.4
	- As a consequence of new HGET Lib, pre-allocate entire file if size is
	  known: On a large FAT16 partition that is nearly full this can save a lot
	  of time, this avoids Nextor having to calculate clusters every few blocks
	  written, it will do just once... That is useful until Nestor release a
	  new version of Nextor that uses a different cluster approach
	- As a consequence of new HGET Lib, if keep-alive connection is available,
	  if there is a failure when trying a new operation on a kept-alive
	  connection, disable retry the operation re-opening the connection and
	  also disable keep-alive connections while HUBG still is open. Some
	  internet providers do not like how much time a MSX can take from the last
	  packet of GET transfer until it send again a new information on the
	  opened connection (it takes some time to get the last package, parse and
	  save to the disk) and the ISP will close the connection, this was causing
	  failures for some people

# CHANGELOG v0.72

	- Keep-Alive fix: faster installations, specially on packs that have many
	  files

# CHANGELOG v0.71

	- Renaming it to HUBG
	- There is an attempt to have keep-alive support in hget lib

# CHANGELOG v0.70

	- First release of HUBG, a MSX HUB Client for MSX2 that has a friendly user
	  interface

# DESCRIPTION

This is a MSX HUB client that has a few advantages over the command line client
version of MSX HUB by fr3nd:

	- It has an intuitive user interface, so you do not need to keep calling
	  HUB several times (one to list groups, another to list packages in that
	  group, another to install)
	  
	- It is fully compatible with HUB (but it doesn't use HUB.COM, it is a
	  stand-alone application), so, if you install it in the same folder you
	  have HUB.COM installed, you are good to go from where you left, no need
	  to uninstall or re-install anything :) You can use HUB at any time, all
	  information is compatible between both clients, so using HUBG do not
	  require you to abandon HUB
	  
	- It won't scroll over lines and lines of text over the screen when you
	  request info from a package. It will show the information page by page,
	  waiting your input when you want to continue reading (if the information
	  spans over more than one screen)
	  
	- You don't have to input any command line option, just HUBG.COM
	
There are a few trade-offs:

	- Search functionality of HUB command line client is not implemented
	
	- It supports up to 100 packages locally installed. If you have more than
	  100 packages it won't list anything over 100 in the Local Operations menu
	  
	- It supports up to 25 groups being listed by MSX HUB. Anything over 25 
	  will not be listed (currently MSX HUB has 9 groups available), each group
	  name should not be over 16 characters long (currently the longest group
	  name is Programming, 11 characters long)
	  
	- It supports up to 70 packages in each category, any package over 70 in a
	  given group won't be listed
	  
	- A MSX2 or better is required
	  
	- Hey, it is a brand new program, I've tested it, but HUB has been tested
	  way longer than this, so HUBG might have bugs... Report them at my github
	  ( www.github.com/ducasp )

# USAGE

If you haven't used MSX HUB before, create a folder named HUB in the drive you
intend to use it (i.e.: C:\HUB). Copy HUBG.COM there. If you already have HUB
installed, copy HUBG.COM in the same folder and it will pick-up from where you
have left with HUB.COM.

Command line:

	HUBG

If you have never used HUB, HUBG will automatically create a few folders and
configuration files. If you have used HUB, HUBG will understand that and
recognize all you have done with HUB.COM

The user interface is pretty much straight forward. Any option you have will be
usable by a keyboard key, and that keyboard key is highlited by being shown in 
magenta/purple color. You have two tabs to work with, the first one is shown as
soon as HUBG is loaded, is the LOCAL OPERATIONS tab. In this tab, HUBG will
list up to the 100th package that you have installed using HUB or HUBG. Those
packages will have a number assigned to each one, from 0 up to 9, and hitting 
0 to 9 in your keyboard will select that package. If you have more than 10
packages installed, it will span over as much pages needed (up to 10) to show
up to 100 packages. By hitting the UP and DOWN keys you navigate through those
pages.

When a package is selected it is highlited and you have the following options:

	- iNfo: if you hit the N key, HUBG will retrieve the full, detailed 
	  information available for that package at MSX HUB and show it on the 
	  screen. If the information do not fit in a single screen, it will wait 
	  you to hit a key to continue showing the remaining information
	  
	- eXclude: if you hit the X key, HUBG will exclude/remove/delete that 
	  package from your computer
	
	- Upgrade: if you hit the U key, HUBG will re-install the package with
	  the current version available at MSX HUB
	  
At any time when in the LOCAL OPERATIONS tab, you can hit the R key and switch
to the REMOTE OPERATIONS tab. At first, HUBG will grab a list of the currently
available groups at MSX HUB and  list up to 9 groups in the same screen, that
can be selected by hitting the keys 0 to 8. If there are more than 9 groups
available, it will span over as much pages needed to show up to 25 groups. By
hitting the LEFT and RIGHT keys you can navigate through those pages.

Once a group is selected it is highlited and HUBG will automatically retrieves
the list of packages available in that group at MSX HUB and their description.
Those packages will have a letter assigned to each one, from A to J, and 
hitting A to J in your keyboard will select that package and the description
of it will be shown in the screen. If MSX HUB has more than 10 packages listed
in that group, it will span over as much pages needed (up to 7) to show up to
70 packages. By hitting the UP and DOWN keys you navigate through those pages.

When a package is selected it is highlited and you have the following options:

	- iNfo: if you hit the N key, HUBG will retrieve the full, detailed 
	  information available for that package at MSX HUB and show it on the 
	  screen. If the information do not fit in a single screen, it will wait 
	  you to hit a key to continue showing the remaining information
	  
	- inStall: if you hit the S key, HUBG will install that package in your 
	  computer
	
	- Upgrade: if you hit the U key, HUBG will re-install the package with
	  the current version available at MSX HUB, if the package was not already
	  installed, it will just install it
	  
At any time when in the REMOTE OPERATIONS tab, you can hit the L key and switch
back to the LOCAL OPERATIONS tab.

During any network operation (including installs) you can hit the ESC key to
stop the operation. If you stop during an install, it will most likely end-up
half installed and you will need to exclude it or upgrade it.

***ADVANCED USAGE OF HUBG***

By default HUBG, like HUB, installs programs in the root folder of the drive it
is installed, creating a folder with the package name and installing it there.

There are two ways of overriding this behavior:

	- If you just want a given package to install in a different folder, keep 
	  SHIFT pressed while you press S or U, HUBG will ask you where you want to
	  install that package, just type it and hit enter. IMPORTANT: notice that
	  HUBG is, at this moment, able to create only ONE folder, so, let's say 
	  you want to install VI in C:\EDITORS\VI folder, if C:\EDITORS already
	  exists, it will work fine, if not, it won't work at all
	  
	- If you want to have a folder as a default place to install all packages,
	  you can set an environment variable with the name PROGSDIR, i.e.: at the
	  MSX-DOS2 prompt (or you can have this included in your autoexec.bat) you
	  type SET PROGSDIR=C:\HUBPACKS. When you install VI, for example, HUBG 
	  will install it in C:\HUBPACKS\VI. IMPORTANT: that folder MUST already
	  exists, otherwise it won't work at all
	  
And the coolest thing of all, don't worry if you install some packages at a non
default location and have others installed at default location. HUB and HUBG 
are smart enough to be able to uninstall or upgrade it at any time (just remind
that when upgrading, if PROGSDIR is not set or SHIFT is not pressed, it will
uninstall from the current location but then re-install it in the default 
location).

***WARNING***

I just have an OCM like MSX ( SM-X by Victor Trucco ) and I'm using its built
in WiFi capabilities with a customized ESP8266 firmware and an UNAPI driver 
made by me. My other option to test this is using BlueMSX OBSONET emulation. So
I've not tested it with other UNAPI adapters, but it should work fine. :)

***KNOWN ISSUES***

	- When entering the installation location manually, HUBG will work only if
	  it has to create the last folder of that location (i.e.: install at 
	  B:\GAMES\HOMEBREW\BRUNILDA, it will work if B:\GAMES\HOMEBREW exists, if
	  it doesn't, it won't work)
	  
	- When using the environment variable PROGSDIR, the folder indicated there
	  must exist before trying to install anything

***IMPORTANT***

I want to say THANK YOU to fr3nd, the creator of MSX HUB and also the author of
HUB.COM, the command line MSX HUB client. I really love his idea and this is my
contribution / love letter to MSX HUB. :) Also, thanks for making the source 
code of HUB.COM available, parts of HUBG code are based (some derived, some are
mostly equal) on HUB.COM source code.

Redistribution and use of this source code or any derivative works, are
permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Redistributions may not be sold, nor may they be used in a commercial
   product or activity without specific prior written permission.
4. Source code of derivative works MUST be published to the public.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
