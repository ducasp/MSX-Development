/*
--
-- HUBG.h
--   MSX HUB client using UNAPI for MSX2.
--   Revision 0.80
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2020 Oduvaldo Pavan Junior ( ducasp@gmail.com )
-- All rights reserved.
-- Some routines are adaptations and have been re-used from original MSX-HUB
-- source code by fr3nd, available at https://github.com/fr3nd/msxhub
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--    product or activity without specific prior written permission.
-- 4. Source code of derivative works MUST be published to the public.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
*/

#ifndef _HUBG_HEADER_INCLUDED
#define _HUBG_HEADER_INCLUDED
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../../fusion-c/header/msx_fusion.h"
#include "../../fusion-c/header/asm.h"
#include "HUBGmenus.h"
#include "hgetlib.h"

#define MAX_PATH_SIZE (64)
#define MAX_URLPATH_SIZE (128)
#define MAX_URL_SIZE (256)
/* file attributes */
#define ATTR_READ_ONLY (1)
#define ATTR_DIRECTORY (1 << 4)
#define ATTR_ARCHIVE   (1 << 5)
/* DOS errors */
#define NOFIL   0xD7
#define IATTR   0xCF
#define DIRX    0xCC

#define BUFFER_SIZE 1024
#define MAX_LOCAL_PACKAGES 100
#define MAX_REMOTE_GROUPS 25
#define MAX_REMOTE_PACKAGES 70

//Define how many can be displayed at once
#define MAX_REMOTE_PACK_LIST_ITENS 10
#define MAX_LOCAL_PACK_LIST_ITENS 10
#define MAX_REMOTE_GROUP_ITENS 9

//Where we will allocate memory for hget and other processes
#define HI_MEMBLOCK_START 0xC000

// Main menu is driven by a state-machine, those are the states
enum HubGStates {
    STATE_IDLE_LOCAL = 0,
    STATE_REDRAW_LOCAL_PAGE,
    STATE_REFRESH_LOCAL_PAGE,
    STATE_SWITCH_LOCAL_PAGE,
    STATE_IDLE_REMOTE,
    STATE_REDRAW_REMOTE_PAGE,
    STATE_REFRESH_REMOTE_PAGE,
    STATE_SWITCH_REMOTE_PAGE,
    STATE_REFRESH_REMOTE_LIST
};

//HGET will access a callback returning group list information
//and that callback is also driven by a state-machine
enum GetGroupListLoopStates {
    STATE_LOOKING_PACKET_NAME = 0,
    STATE_GETTING_PACKET_NAME,
    STATE_LOOKING_PACKET_INFO,
    STATE_GETTING_PACKET_INFO,
    STATE_GGL_STARTUP,
};

typedef struct {
  unsigned char ucPackages;
  char chPackageName[MAX_LOCAL_PACKAGES][13];
} packages_installed_info;

typedef struct {
  unsigned char ucGroups;
  char chGroupName[MAX_REMOTE_GROUPS][21];
} groups_info;

typedef struct {
  unsigned char ucPackages;
  char ucPackageName[MAX_REMOTE_PACKAGES][9];
  char ucPackageDetail[MAX_REMOTE_PACKAGES][77];
} groups_package;

//Title when installing the first time
const char ucSWInfoANSI[] = "\x1b[31m> MSX HUB Client v0.80 <\r\n (c) 2020 Oduvaldo Pavan Junior - ducasp@gmail.com\x1b[0m\r\n";

//Those are not re-usable, they carry configuration for the whole time program is running
char hubdrive; //Drive HUB is running
char hubpath[MAX_PATH_SIZE]; //path HUB is installed
char configpath[MAX_PATH_SIZE]; //path for HUB configuration files
char baseurl[MAX_PATH_SIZE]; //hold the base url to access MSX HUB
char progsdir[MAX_PATH_SIZE]; //hold the root dir where packages are installed
unsigned char ucCursorSave; // Just in case somehow cursor is messed-up, restore it when exiting

//Those are used for menus / presentation
unsigned char ucLocalPages; //The page selected of currently installed programs
unsigned char ucRemotePages; //The page of currently listed packages in the selected group
unsigned char ucGroupPages; //The page of currently listed available groups
unsigned char ucItensDisplayed; //This holds how many items are presented in group list or locally installed list
unsigned char ucItemSelected; //The item chosen in group or locally installed list
unsigned char ucConnectionIcon; //Our beautiful blinking icon state
unsigned char ucListPage; //The page displaying the group or locally installed list
unsigned char ucPackageItensDisplayed; //How many items are shown when displaying available packages in a certain group
unsigned char ucPackageItemSelected; //The current item selected from the available packages shown on screen
unsigned char FileTransferInProgress; //Indicates the callback that a file is being transferred
unsigned char FirstStatusUpdate; //And indicates the callback that it is the first time, so build the progress bar
long FileSize; //Where the content size callback stores the size of the content being transferred
packages_installed_info hubInstalledPackages; //Hold the currently installed packages
groups_info hubCategories; //Hold the currently available categories
groups_package hubGroupPackages; //Hold the currently available packages on the selected category

//General temp variables mostly used in menu building routines, be careful not nesting the usage of those
unsigned char ucRet;
char chCol,chRow;
unsigned char ucTmp1,ucTmp2,ucTmp3,ucTmp4;

//Variables used everywhere, be careful not nesting the usage of those
char chTextLine[128]; //Used generally to build strings and url's
char buffer[BUFFER_SIZE];//General buffer used for several routines, it is big, must be re-used
unsigned char GGLLState;//When receiving the group data, hget will call a function and this function is based on a state machine
int fp,fp2; //to hold the handle for dos operations
Z80_registers regs; //auxiliary structure for asm function calling

//MSX Variables that we will access
__at 0xFCA9 unsigned char ucCursorDisplayed;

//Functions prototypes
void die(const char *s);
const char* get_config(char* filename);
void save_config(char* filename, char* value);
void configure(void);
void categories(void);
void installed(void);
void uninstall(char *package);
void RefreshMenu (unsigned char ucPage, unsigned char ucSelectedItem);
void RefreshRemoteMenu (unsigned char ucPage, unsigned char ucSelectedItem);
void RefreshRemoteList(unsigned char ucPage, unsigned char ucSelectedItem);
void SelectMenu(unsigned char ucPage, unsigned char ucItem);
void SelectListMenu(unsigned char ucPage, unsigned char ucItem);
void SelectRemoteMenu(unsigned char ucPage, unsigned char ucItem);
void HTTPStatusUpdate (bool isChunked);
void HTTPFileSizeUpdate (long ContentSize);
void GetGroupList(char *GroupName);
void GroupListRcvCallBack(char *rcv_buffer, int bytes_read);
void install(unsigned char ucPage, unsigned char ucItem, char *chPackage);
void upgrade(unsigned char ucPage, unsigned char ucItem);
void info(char *package);
unsigned char is_installed(unsigned char *ucPackage);
#endif // _HUBG_HEADER_INCLUDED
