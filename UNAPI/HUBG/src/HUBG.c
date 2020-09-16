/*
--
-- HUBG.c
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
#include "HUBG.h"
#include "io.h"
#include "ctype.h"
#include "msx2ansi.h"
#include "dos.h"

void die(const char *s)
{
    AnsiPrint(s);
    AnsiPrint("\r\nHit a key to finish.\r\n");
    while (!Inkey());
    AnsiFinish();
    //restore cursor status
    ucCursorDisplayed = ucCursorSave;
    exit(1);
}

const char* get_config(char* filename)
{
    int n;
    buffer[0] = '\0';

    // Env variables take precedence over config files
    get_env(filename, buffer, 0xff);
    if (buffer[0] != '\0')
    return buffer;

    strcpy(buffer, configpath);
    strcat(buffer, "\\");
    strcat(buffer, filename);
    fp = dos_open(buffer, DOS_O_RDONLY);

    // Error is in the least significant byte of p
    if (fp < 0)
    {
        n = (fp >> 0) & 0xff;
        buffer[0] = 0;
        return buffer;
    }

    n = file_read(buffer, BUFFER_SIZE, fp);
    dos_close(fp);
    buffer[n-1] = '\0';

    return buffer;
}

void read_config(void)
{
    strcpy(progsdir, get_config("PROGSDIR"));
    strcpy(baseurl, get_config("BASEURL"));
}

void save_config(char* filename, char* value)
{
    int n;
    buffer[0] = '\0';

    strcpy(buffer, configpath);
    strcat(buffer, "\\");
    strcat(buffer, filename);

    fp = dos_create(buffer, DOS_O_RDWR, 0x00);

    // Error is in the least significative byte of p
    if (fp < 0)
    {
        n = (fp >> 0) & 0xff;
        die("Error saving configuration.\r\n");
    }

    n = file_write(value, strlen(value), fp);
    buffer[0] = 0x1a;
    file_write(buffer, 1, fp);
    dos_close(fp);
}

void info(char *package)
{
    int iRet, iLeft,iIndex;
    char chLine,chColumn;

    strcpy(chTextLine,baseurl);
    strcat(chTextLine,package);
    strcat(chTextLine,"/info");
    AnsiPrint(chClearBothStatusWindows);
    AnsiPrint("\x1b[21;3H\x1b[1;37mDownloading information from package ");
    AnsiPrint(package);

    iRet = hget(chTextLine,"info.tmp",NULL,(int)HTTPStatusUpdate,NULL,NULL,0,0,false);
    if (iRet != ERR_TCPIPUNAPI_OK)
    {
        AnsiPrint("\x1b[21;3H\x1b[1;37mError getting package information...\x1b[K\x1b[21;80H\x1b[0;31m\xba");
        return;
    }

    fp = dos_open("info.tmp", DOS_O_RDONLY);

    // Error is in the least significant byte of p
    if (fp < 0)
    {
        AnsiPrint("\x1b[21;3H\x1b[1;37mError opening package information file...\x1b[K\x1b[21;80H\x1b[0;31m\xba");
        return;
    }

    AnsiPrint("\x1b[2J\x1b[1;37;40m");
    chLine=1;
    chColumn=1;
    do
    {
        iRet = file_read(buffer, BUFFER_SIZE, fp);
        if (iRet>0)
        {
            iLeft = iRet;
            iIndex = 0;
            while (iLeft)
            {
                for (;((iLeft>0)&&(chLine<25));++iIndex,--iLeft)
                {
                    switch (buffer[iIndex])
                    {
                        case 0x0d:
                            chColumn=1;
                            break;
                        case 0x0a:
                            chColumn=1;
                            ++chLine;
                            break;
                        default:
                            ++chColumn;
                            break;

                    }
                    AnsiPutChar(buffer[iIndex]);
                    if (chColumn>80)
                    {
                        chColumn=0;
                        ++chLine;
                    }
                }
                if (iLeft)
                {
                    AnsiPrint("\x1b[0;31;40mPress any key to continue reading...");
                    while(!Inkey());
                    AnsiPrint("\x1b[2J\x1b[1;37;40m");
                    chLine=1;
                    chColumn=1;
                }
            }
        }
    }
    while (iRet == BUFFER_SIZE);
    AnsiPrint("\r\n");
    AnsiPrint("\x1b[0;31;40mPress any key to return...");
    while(!Inkey());

    dos_close(fp);
    //delete_file("info.tmp");
}

void uninstall(char *package)
{
    int n, m;
    char c;
    int bytes_read;
    char undeleted_directories[5][MAX_PATH_SIZE];
    char undeleted_directories_count = 0;

    //Delete status Windows
    AnsiPrint(chClearBothStatusWindows);
    AnsiPrint("\x1b[21;3H\x1b[1;37mUninstalling package ");
    AnsiPrint(package);

    strcpy(buffer, configpath);
    strcat(buffer, "\\IDB\\");
    strcat(buffer, package);
    fp = dos_open(buffer, DOS_O_RDONLY);

    if (fp < 0)
    {
        n = (fp >> 0) & 0xff;
        if (n == 0xD7)
        {
            AnsiPrint("\x1b[1;37m\x1b[23;4HPackage ");
            AnsiPrint(package);
            AnsiPrint(" is not installed!");
        }
        else
            AnsiPrint("\x1b[1;37m\x1b[23;4HError reading package information file");
        return;
    }

    // Get list of files and deleting them

    chTextLine[0] = '\0';
    m = 0;
    while(1)
    {
        bytes_read = file_read(buffer, BUFFER_SIZE, fp);

        for (n=0; n<bytes_read ;n++)
        {
            if (buffer[n] != '\n' && buffer[n] != '\r')
            {
                chTextLine[m] = buffer[n];
                m++;
            }
            else if (buffer[n] == '\n')
            {
                chTextLine[m] = '\0';
                AnsiPrint("\x1b[1;37m\x1b[23;4HDeleting ");
                AnsiPrint(chTextLine);
                AnsiPrint("\x1b[K\x1b[23;80H\x1b[0;31m\xba");
                c = delete_file(chTextLine);
                if (c != 0)
                {
                    if (c == 0xD0)
                    {
                        // Directory not empty. Continue
                        AnsiPrint("\x1b[1;37m\x1b[23;4HWARNING: Directory ");
                        AnsiPrint(chTextLine);
                        AnsiPrint(" not empty. Will retry later.\x1b[K\x1b[23;80H\x1b[0;31m\xba");
                        if (undeleted_directories_count<5)
                        {
                            strcpy(undeleted_directories[undeleted_directories_count], chTextLine);
                            ++undeleted_directories_count;
                        }
                    }
                    else
                    {
                        // Another error
                        AnsiPrint("\x1b[1;37m\x1b[23;4HError deleting file ");
                        AnsiPrint(chTextLine);
                        AnsiPrint("\x1b[K\x1b[23;80H\x1b[0;31m\xba");
                    }
                }
                m = 0;
            }
        }

        if (bytes_read < BUFFER_SIZE)
            break;
    }

    dos_close(fp);

    if (undeleted_directories_count)
    {
        for (n=0;n<undeleted_directories_count;++n)
        {
            c = delete_file(undeleted_directories[n]);
            if (c == 0xD0)
            { // Directory not empty yet
                printf("WARNING: Directory %s not empty. Not deleting it...\r\n", undeleted_directories[n]);
            }
        }
    }

    // Remove file in idb
    strcpy(buffer, configpath);
    strcat(buffer, "\\IDB\\");
    strcat(buffer, package);
    c = delete_file(buffer);
    if (c != 0)
    {
        AnsiPrint("\x1b[1;37m\x1b[23;4HError deleting file ");
        AnsiPrint(buffer);
        AnsiPrint("\x1b[K\x1b[23;80H\x1b[0;31m\xba");
    }
    else
    {
        AnsiPrint("\x1b[21;3H\x1b[1;37mPackage ");
        AnsiPrint(package);
        AnsiPrint(" uninstalled!\x1b[K\x1b[21;80H\x1b[0;31m\xba");
    }

    AnsiPrint(chClearBarWindow);
}

void configure(void)
{
    char c;
    int n;

    AnsiPrint("Welcome to MSXHubG!\r\n\n");
    AnsiPrint("It looks like it's the first time you run MSXHubG. It's going to be automatically configured.\r\n\n");

    AnsiPrint("- Main directory: ");
    AnsiPrint(hubpath);
    AnsiPrint("\r\n");

    // Create main dir if it doesn't exist
    fp = dos_create(hubpath, DOS_O_RDWR, ATTR_DIRECTORY);
    // Error is in the least significant byte of fp
    if (fp < 0)
    {
        n = (fp >> 0) & 0xff;
        if (n != DIRX)
            die("Error creating main directory\r\n");
    }

    AnsiPrint("- Configuration directory: ");
    AnsiPrint(configpath);
    AnsiPrint("\r\n");

    // Create config dir if it doesn't exist
    fp = dos_create(configpath, DOS_O_RDWR, ATTR_DIRECTORY);
    // Error is in the least significative byte of fp
    if (fp < 0)
    {
        n = (fp >> 0) & 0xff;
        if (n == DIRX)
        {
            AnsiPrint("Configuration directory already exists.\r\nContinue? (y/N) ");
            c = tolower(getchar());
            AnsiPrint("\r\n");
            if (c != 'y')
                die("Aborted");
        }
        else
            die("Error creating configuration directory...\r\n");
    }

    // Create installed dir if it doesn't exist
    strcpy(buffer, configpath);
    strcat(buffer, "\\IDB");
    fp = dos_create(buffer, DOS_O_RDWR, ATTR_DIRECTORY);
    // Error is in the least significant byte of fp
    if (fp < 0)
    {
        n = (fp >> 0) & 0xff;
        if (n != DIRX)
            die("Error creating installed directory...\r\n");
    }

    progsdir[0] = hubdrive;
    progsdir[1] = ':';
    progsdir[2] = '\0';
    AnsiPrint("- Programs are going to be installed in ");
    AnsiPrint(progsdir);
    AnsiPrint("\r\n");
    save_config("PROGSDIR", progsdir);

    save_config("BASEURL", "http://api.msxhub.com/api/");

    AnsiPrint("Done! MSXHubG configured properly. Hit a key to continue...\r\n");
    while (!Inkey());
}

void installed(void)
{
    file_info_block_t fib;

    hubInstalledPackages.ucPackages = 0;

    strcpy(chTextLine, configpath);
    strcat(chTextLine, "\\IDB\\");
    regs.Words.DE = (int)&chTextLine;
    regs.Bytes.B = 0x00;
    regs.Words.IX = (int)&fib;
    DosCall(FFIRST, &regs, REGS_ALL, REGS_AF);

    while ((regs.Bytes.A == 0)&&(hubInstalledPackages.ucPackages!=MAX_LOCAL_PACKAGES))
    {
        strcpy(hubInstalledPackages.chPackageName[hubInstalledPackages.ucPackages],fib.filename);
        DosCall(FNEXT, &regs, REGS_ALL, REGS_AF);
        ++hubInstalledPackages.ucPackages;
    }

    if (hubInstalledPackages.ucPackages)
        ucLocalPages = (hubInstalledPackages.ucPackages - 1) / 10;
    else
        ucLocalPages = 0;
}

void categories (void)
{
    unsigned int bufferSize = BUFFER_SIZE;
    unsigned int bufferIndex;
    int iRet;
    unsigned char currentCategorySize = 0;

    //Delete status Windows
    AnsiPrint(chClearBothStatusWindows);
    AnsiPrint("\x1b[21;3H\x1b[1;37mConnecting to MSXHUB to get current categories\x1b[K\x1b[21;80H\x1b[0;31m\xba");
    ucGroupPages = 0;

    if (hubCategories.ucGroups==0)
    {
        strcpy(chTextLine,baseurl);
        strcat(chTextLine,"categories");
        iRet = hget(chTextLine,NULL,NULL,(int)HTTPStatusUpdate,buffer,&bufferSize,0,0,false);
    }
    else //load once, no need to keep reloading every time
        return;

    if ((iRet == ERR_TCPIPUNAPI_OK) && (bufferSize))
    {
        for (bufferIndex=0; bufferIndex<bufferSize;++bufferIndex)
        {
            if (buffer[bufferIndex]>=0x20) //readable
            {
                if (currentCategorySize<17)
                {
                    hubCategories.chGroupName[hubCategories.ucGroups][currentCategorySize]=buffer[bufferIndex];
                    ++currentCategorySize;
                }
            }
            else if (currentCategorySize)
            {
                //Ok, end of this category
                hubCategories.chGroupName[hubCategories.ucGroups][currentCategorySize]=0; //NULL terminate string
                hubCategories.ucGroups++;
                currentCategorySize = 0;
                if (hubCategories.ucGroups==MAX_REMOTE_GROUPS)
                    break;
            }
        }
        sprintf(chTextLine,"\x1b[21;3H\x1b[1;37mMSX HUB currently offers %u categories.\x1b[K\x1b[21;80H\x1b[0;31m\xba", hubCategories.ucGroups);
        AnsiPrint(chTextLine);
        if (hubCategories.ucGroups)
            ucGroupPages = (hubCategories.ucGroups - 1) / MAX_REMOTE_GROUP_ITENS;
    }
    else
        AnsiPrint("\x1b[21;3H\x1b[1;37mError getting all categories from MSX HUB\x1b[K\x1b[21;80H\x1b[0;31m\xba");
}

unsigned char is_installed(unsigned char *ucPackage)
{
    if (!hubInstalledPackages.ucPackages)
        return false;

    for (ucTmp2=0;ucTmp2<hubInstalledPackages.ucPackages;++ucTmp2)
    {
        if (strstr(hubInstalledPackages.chPackageName[ucTmp2],ucPackage))
            return true;
    }
    return false;
}

void upgrade(unsigned char ucPage, unsigned char ucItem)
{
    if ((hubGroupPackages.ucPackages) && (ucPage<=ucRemotePages))
    {
        ucTmp1 = (MAX_REMOTE_PACK_LIST_ITENS*ucPage) + ucItem;
        if (is_installed(hubGroupPackages.ucPackageName[ucTmp1]))
        {
            uninstall(hubGroupPackages.ucPackageName[ucTmp1]);
            installed();
        }
        install(ucPage, ucItem, NULL);
    }
}

void install(unsigned char ucPage, unsigned char ucItem, char *chPackage)
{
    int iRet;
    int m,n,tp,cp;
    char c;
    unsigned int bufferSize;
    char installdir[68];
    char local_path[MAX_PATH_SIZE];
    char created_dirs[MAX_PATH_SIZE*16];
    char *line;
    char *next_line;
    char *packagetoinstall;
    unsigned char askForInstallPath = 0;

    //Is shift pressed?
    if ((*((unsigned char*)0xFBEB) & 1) == 0)
        askForInstallPath = 1; //Yep! Ask where to install it!

    if ((chPackage)||((hubGroupPackages.ucPackages) && (ucPage<=ucRemotePages)))
    {
        if (chPackage)
            packagetoinstall = chPackage;
        else
        {
            ucTmp1 = (MAX_REMOTE_PACK_LIST_ITENS*ucPage) + ucItem;
            packagetoinstall = hubGroupPackages.ucPackageName[ucTmp1];
        }

        if (is_installed(packagetoinstall))
        {
            AnsiPrint("\x1b[21;3H\x1b[1;37mPackage ");
            AnsiPrint(packagetoinstall);
            AnsiPrint(" is already installed!\x1b[K\x1b[21;80H\x1b[0;31m\xba");
        }
        else
        {
            AnsiPrint("\x1b[21;3H\x1b[1;37mInstalling ");
            AnsiPrint(packagetoinstall);
            AnsiPrint("...\x1b[K\x1b[21;80H\x1b[0;31m\xba");

            if (askForInstallPath)
            {
                AnsiPrint("\x1b[21;3H\x1b[K\x1b[21;80H\x1b[0;31;40m\xba\x1b[1;37m\x1b[21;3HInstall path: ");
                n = 0;
                do
                {
                    c = Inkey();
                    if ((c==8)&&(n))
                    {
                        --n;
                        installdir[n]='\0';
                        AnsiPutChar(c);
                        AnsiPutChar(' ');
                        AnsiPutChar(c);
                    }
                    else if (c>0x20)
                    {
                        installdir[n]=c;
                        ++n;
                        installdir[n]='\0';
                        AnsiPutChar(c);
                    }
                    else if ((c=='\r')&&(n))
                        break;
                }
                while (n<67);
            }
            else
            {
                //Get the installation folder for this application
                strcpy(chTextLine,baseurl);
                strcat(chTextLine,packagetoinstall);
                strcat(chTextLine,"/latest/installdir");
                bufferSize = sizeof (installdir);
                iRet = hget(chTextLine,NULL,NULL,(int)HTTPStatusUpdate,installdir,&bufferSize,0,0,true);
                if (iRet != ERR_TCPIPUNAPI_OK)
                {
                    AnsiPrint("\x1b[21;3H\x1b[1;37mError getting installation folder...\x1b[K\x1b[21;80H\x1b[0;31m\xba");
                    return;
                }
                //Ok, now let's update our internal variables with the installation folder
                installdir[bufferSize]=0; //terminate string
                strcpy(local_path, progsdir);
                strcat(local_path, installdir);
                strcpy(installdir, local_path);
            }

            sprintf(chTextLine,"\x1b[21;3H\x1b[1;37mCreating %s...\x1b[K\x1b[21;80H\x1b[0;31m\xba",installdir);

            //Now create the folder
            fp2 = dos_create(installdir, DOS_O_RDWR, ATTR_DIRECTORY);
            if (fp < 0)
            {
                n = (fp2 >> 0) & 0xff;
                if (n == DIRX)
                {
                    AnsiPrint("\x1b[21;3H\x1b[1;37mDestination folder already exists, continue? (Y/n)\x1b[K\x1b[21;80H\x1b[0;31m\xba");
                    do
                    {
                        ucTmp2 = Inkey ();
                    }
                    while (!ucTmp2);
                    if ((ucTmp2 == 'n') || (ucTmp2 == 'N'))
                    {
                        AnsiPrint("\x1b[21;3H\x1b[1;37mAborted installation...\x1b[K\x1b[21;80H\x1b[0;31m\xba");
                        hgetfinish();
                        return;
                    }
                }
                else
                {
                    AnsiPrint("\x1b[21;3H\x1b[1;37mError creating destination directory!\x1b[K\x1b[21;80H\x1b[0;31m\xba");
                    hgetfinish();
                    return;
                }
            }

            //Now get the  number of pages of files to install
            strcpy(chTextLine,baseurl);
            strcat(chTextLine,packagetoinstall);
            strcat(chTextLine,"/latest/pages");
            bufferSize = BUFFER_SIZE;
            iRet = hget(chTextLine,NULL,NULL,(int)HTTPStatusUpdate,buffer,&bufferSize,0,0,true);
            if (iRet != ERR_TCPIPUNAPI_OK)
            {
                AnsiPrint("\x1b[21;3H\x1b[1;37mError getting number of file pages...\x1b[K\x1b[21;80H\x1b[0;31m\xba");
                hgetfinish();
                return;
            }
            buffer[bufferSize]=0;
            tp = atoi(buffer);

            strcpy(local_path, configpath);
            strcat(local_path, "\\IDB\\");
            strcat(local_path, packagetoinstall);
            fp = dos_create(local_path, DOS_O_RDWR, 0x00);

            created_dirs[0] = '\0';
            // Iterate pages
            for (cp = 0; cp<tp; ++cp)
            {
                //Get the current page list of files....
                strcpy(chTextLine,baseurl);
                strcat(chTextLine,packagetoinstall);
                strcat(chTextLine,"/latest/files/");
                sprintf(buffer, "%d", cp+1); // using variable files as temp variable
                strcat(chTextLine, buffer);
                bufferSize = BUFFER_SIZE;
                iRet = hget(chTextLine,NULL,NULL,(int)HTTPStatusUpdate,buffer,&bufferSize,0,0,true);
                if (iRet != ERR_TCPIPUNAPI_OK)
                {
                    AnsiPrint("\x1b[21;3H\x1b[1;37mError getting list of files for this page...\x1b[K\x1b[21;80H\x1b[0;31m\xba");
                    hgetfinish();
                    return;
                }
                buffer[bufferSize]=0; //null terminate buffer

                line = buffer;

                while (line)
                {
                    for(next_line=NULL,n=0;line[n]!=0;++n)
                        if (line[n]=='\n')
                        {
                            line[n-1]= '\0'; //terminate at \r
                            next_line = &line[n+1]; //next line after \n
                            break;
                        }
                    //If line is null terminated, strlen = 0, n will be 0
                    if(n)
                    {
                        // Create subdirectories if required
                        for (m=0; line[m] != '\0'; ++m)
                        {
                            if (line[m] == '\\')
                            {
                                strcpy(chTextLine, installdir);
                                strcat(chTextLine, "\\");
                                c = line[m];
                                line[m] = '\0';
                                strcat(chTextLine, line);
                                line[m] = c;

                                fp2 = dos_create(chTextLine, DOS_O_RDWR, ATTR_DIRECTORY);
                                if (fp2 < 0)
                                {
                                    n = (fp2 >> 0) & 0xff;
                                    if (n != DIRX)
                                    {
                                        AnsiPrint("\x1b[21;3H\x1b[1;37mError creating destination directory.\x1b[K\x1b[21;80H\x1b[0;31m\xba");
                                        hgetfinish();
                                        return;
                                    }
                                }
                                else
                                {
                                    if (strstr(created_dirs, chTextLine) == '\0')
                                    {
                                        strcat(chTextLine, "\n");
                                        strcat(created_dirs, chTextLine);
                                    }
                                }
                            }
                        }

                        strcpy(local_path, installdir);
                        strcat(local_path, "\\");
                        strcat(local_path, line);

                        for(n=0;line[n]!=0;++n)
                            if (line[n]=='\\')
                                line[n]= '/';

                        strcpy(chTextLine, baseurl);
                        strcat(chTextLine, packagetoinstall);
                        strcat(chTextLine, "/latest/get/");
                        strcat(chTextLine, packagetoinstall);
                        strcat(chTextLine, "/");
                        strcat(chTextLine, line);

                        AnsiPrint("\x1b[21;3H\x1b[1;37mGetting ");
                        AnsiPrint(local_path);
                        AnsiPrint("\x1b[K\x1b[21;80H\x1b[0;31m\xba");
                        FileTransferInProgress = true;
                        FirstStatusUpdate = true;
                        FileSize = 0;
                        iRet = hget(chTextLine,local_path,NULL,(int)HTTPStatusUpdate,NULL,NULL,0,(int)HTTPFileSizeUpdate,true);
                        FileTransferInProgress = false;
                        if (iRet != ERR_TCPIPUNAPI_OK)
                        {
                            AnsiPrint("\x1b[21;3H\x1b[1;37mError while downloading files...\x1b[K\x1b[21;80H\x1b[0;31m\xba");
                            hgetfinish();
                            dos_close(fp);
                            return;
                        }

                        strcat(local_path, "\r\n");
                        file_write(local_path, strlen(local_path), fp);
                    }
                    line = next_line;
                }
            }

            // After the files, store created directories in IDB
            // TODO iterate in reverse order to allow subdirectories
            line = created_dirs;
            while (line)
            {
                for(next_line=NULL,n=0;line[n]!=0;++n)
                    if (line[n]=='\n')
                    {
                        line[n]= '\0'; //terminate at \n
                        next_line = &line[n+1]; //next line
                        break;
                    }
                //If line is null terminated, strlen = 0, n will be 0
                if(n)
                {
                    strcpy(local_path, line);
                    strcat(local_path, "\r\n");
                    file_write(local_path, strlen(local_path), fp);
                }

                line = next_line;
            }

            // Save the destination dir to IDB too
            strcpy(local_path, installdir);
            strcat(local_path, "\r\n");
            file_write(local_path, strlen(local_path), fp);

            dos_close(fp);
            sprintf(chTextLine,"\x1b[21;3H\x1b[1;37mInstalled %s!\x1b[K\x1b[21;80H\x1b[0;31m\xba",packagetoinstall);
            AnsiPrint(chTextLine);
            AnsiPrint(chClearBarWindow);
            hgetfinish();
        }
    }
}

void GroupListRcvCallBack(char *rcv_buffer, int bytes_read)
{
    static int m;
    int n;

    if(GGLLState == STATE_GGL_STARTUP)
    {
        hubGroupPackages.ucPackages = 0;
        m = 0;
        GGLLState = STATE_LOOKING_PACKET_NAME;
    }

    for (n=0; (n<bytes_read) && (hubGroupPackages.ucPackages<MAX_REMOTE_PACKAGES); ++n)
    {
        switch (GGLLState)
        {

            case STATE_LOOKING_PACKET_NAME:
                if (rcv_buffer[n] > ' ')
                {
                    hubGroupPackages.ucPackageName[hubGroupPackages.ucPackages][0] = rcv_buffer[n];
                    m = 1;
                    GGLLState = STATE_GETTING_PACKET_NAME;
                }
                break;
            case STATE_GETTING_PACKET_NAME:
                if (rcv_buffer[n] != ' ')
                {
                    hubGroupPackages.ucPackageName[hubGroupPackages.ucPackages][m] = rcv_buffer[n];
                    ++m;
                }
                else
                {
                    hubGroupPackages.ucPackageName[hubGroupPackages.ucPackages][m] = 0;
                    GGLLState = STATE_LOOKING_PACKET_INFO;
                }
                break;
            case STATE_LOOKING_PACKET_INFO:
                if (rcv_buffer[n] > ' ')
                {
                    hubGroupPackages.ucPackageDetail[hubGroupPackages.ucPackages][0] = rcv_buffer[n];
                    m = 1;
                    GGLLState = STATE_GETTING_PACKET_INFO;
                }
                break;
            case STATE_GETTING_PACKET_INFO:
                if ((rcv_buffer[n] != '\r')&&(rcv_buffer[n] != '\n'))
                {
                    if (m<76)
                    {
                        hubGroupPackages.ucPackageDetail[hubGroupPackages.ucPackages][m] = rcv_buffer[n];
                        ++m;
                    }
                }
                else if (rcv_buffer[n] == '\n')
                {
                    hubGroupPackages.ucPackageDetail[hubGroupPackages.ucPackages][m] = 0;
                    ++hubGroupPackages.ucPackages;
                    if (hubGroupPackages.ucPackages==MAX_REMOTE_PACKAGES)
                        break;
                    GGLLState = STATE_LOOKING_PACKET_NAME;
                }
                break;
        }
    }
}

void GetGroupList(char *GroupName)
{
    //Delete status Windows
    AnsiPrint(chClearBothStatusWindows);
    AnsiPrint("\x1b[21;3H\x1b[1;37mConnecting to MSXHUB to list ");
    AnsiPrint(GroupName);
    AnsiPrint(" packages\x1b[K\x1b[21;80H\x1b[0;31m\xba");
    AnsiPrint(chTextLine);

    strcpy(chTextLine,baseurl);
    strcat(chTextLine,"list?category=");
    strcat(chTextLine, GroupName);
    GGLLState = STATE_GGL_STARTUP;
    if(hget(chTextLine,NULL,NULL,(int)HTTPStatusUpdate,NULL,NULL,(int)GroupListRcvCallBack,0,false)!=ERR_TCPIPUNAPI_OK)
    {
        AnsiPrint("\x1b[21;3H\x1b[1;37mFailure trying to get the list of group ");
        AnsiPrint(GroupName);
        AnsiPrint("\x1b[K\x1b[21;80H\x1b[0;31m\xba");
        hubGroupPackages.ucPackages = 0;
        return;
    }
    else
    {
        if (hubGroupPackages.ucPackages)
            ucRemotePages = (hubGroupPackages.ucPackages - 1) / MAX_REMOTE_PACK_LIST_ITENS;
        else
            ucRemotePages = 0;
    }
}

void RefreshMenu (unsigned char ucPage, unsigned char ucSelectedItem)
{
    chCol = 24;

    if ((hubInstalledPackages.ucPackages) && (ucPage<=ucLocalPages))
    {
        if (hubInstalledPackages.ucPackages<=MAX_LOCAL_PACK_LIST_ITENS)
            sprintf(chTextLine,"\x1b[5;23H\x1b[1;40;37m%u PACKAGES ALREADY INSTALLED:",hubInstalledPackages.ucPackages);
        else
            sprintf(chTextLine,"\x1b[5;23H\x1b[1;40;37m(%u/%u)\x1e\x1f -%u PACKAGES ALREADY INSTALLED:",(ucPage+1),(ucLocalPages+1),hubInstalledPackages.ucPackages);

        AnsiPrint(chTextLine);

        ucTmp1 = MAX_LOCAL_PACK_LIST_ITENS*ucPage;
        if (hubInstalledPackages.ucPackages>=(ucTmp1 + MAX_LOCAL_PACK_LIST_ITENS))
            ucItensDisplayed = MAX_LOCAL_PACK_LIST_ITENS;
        else
            ucItensDisplayed = hubInstalledPackages.ucPackages - ucTmp1;

        ucTmp2 = ucItensDisplayed + ucTmp1;

        for (ucRet=ucTmp1; ucRet<ucTmp2; ++ucRet)
        {
            ucTmp3 = ucRet - ucTmp1;
            chRow = 7 + ucTmp3;

            if (ucTmp3 == ucSelectedItem)
                sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;30;47m%u - %s",chRow,chCol,ucTmp3,hubInstalledPackages.chPackageName[ucRet]);
            else
                sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;37;40m%u - %s",chRow,chCol,ucTmp3,hubInstalledPackages.chPackageName[ucRet]);

            AnsiPrint(chTextLine);
        }
        ucItemSelected = ucSelectedItem;
    }
}

void RefreshRemoteList(unsigned char ucPage, unsigned char ucSelectedItem)
{
    chCol = 24;
    unsigned char ucHelper;

    if ((hubGroupPackages.ucPackages) && (ucPage<=ucRemotePages))
    {
        if (hubGroupPackages.ucPackages<=MAX_REMOTE_PACK_LIST_ITENS)
            sprintf(chTextLine,"\x1b[5;23H\x1b[1;40;37m%u PACKAGES AVAILABLE:",hubGroupPackages.ucPackages);
        else
            sprintf(chTextLine,"\x1b[5;23H\x1b[1;40;37m(%u/%u)\x1e\x1f -%u PACKAGES AVAILABLE:",(ucPage+1),(ucRemotePages+1),hubGroupPackages.ucPackages);
        AnsiPrint(chTextLine);

        ucTmp1 = MAX_REMOTE_PACK_LIST_ITENS*ucPage;
        if (hubGroupPackages.ucPackages>=(ucTmp1 + MAX_REMOTE_PACK_LIST_ITENS))
            ucPackageItensDisplayed = MAX_REMOTE_PACK_LIST_ITENS;
        else
            ucPackageItensDisplayed = hubGroupPackages.ucPackages - ucTmp1;

        ucTmp2 = ucPackageItensDisplayed + ucTmp1;

        for (ucRet=ucTmp1; ucRet<ucTmp2; ++ucRet)
        {
            ucTmp3 = ucRet - ucTmp1;
            ucHelper = ucSelectedItem + 'A';
            chRow = 7 + ucTmp3;
            ucTmp3 += 'A';
            if (ucTmp3 == ucHelper)
            {
                sprintf(chTextLine,"\x1b[21;3H\x1b[1;33;40m%s\x1b[0;31;40m\x1b[K\x1b[21;80H\xba",hubGroupPackages.ucPackageDetail[ucRet]);
                AnsiPrint(chTextLine);
                sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;30;47m%c - %s",chRow,chCol,ucTmp3,hubGroupPackages.ucPackageName[ucRet]);
            }
            else
                sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;37;40m%c - %s",chRow,chCol,ucTmp3,hubGroupPackages.ucPackageName[ucRet]);
            AnsiPrint(chTextLine);
        }
        ucPackageItemSelected = ucSelectedItem;

    }
}

void RefreshRemoteMenu (unsigned char ucPage, unsigned char ucSelectedItem)
{
    chCol = 2;

    if ((hubCategories.ucGroups) && (ucPage<=ucGroupPages))
    {
        if (hubCategories.ucGroups<=MAX_REMOTE_GROUP_ITENS)
            sprintf(chTextLine,"\x1b[10;2H\x1b[1;40;37m%u GROUPS:",hubCategories.ucGroups);
        else
            sprintf(chTextLine,"\x1b[10;2H\x1b[1;40;37m(%u/%u)\x11\x10 %u GROUPS:",(ucPage+1),(ucGroupPages+1),hubCategories.ucGroups);

        AnsiPrint(chTextLine);

        ucTmp1 = MAX_REMOTE_GROUP_ITENS*ucPage;
        if (hubCategories.ucGroups>=(ucTmp1 + MAX_REMOTE_GROUP_ITENS))
            ucItensDisplayed = MAX_REMOTE_GROUP_ITENS;
        else
            ucItensDisplayed = hubCategories.ucGroups - ucTmp1;

        ucTmp2 = ucItensDisplayed + ucTmp1;

        for (ucRet=ucTmp1; ucRet<ucTmp2; ++ucRet)
        {
            ucTmp3 = ucRet - ucTmp1;
            chRow = 11 + ucTmp3;
            if (ucTmp3 != ucSelectedItem)
                sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;37;40m%u- %s",chRow,chCol,ucTmp3,hubCategories.chGroupName[ucRet]);
            else
                sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;37;47m%u- %s",chRow,chCol,ucTmp3,hubCategories.chGroupName[ucRet]);

            ucTmp4 = 16 - strlen(hubCategories.chGroupName[ucRet]);
            for (;ucTmp4;--ucTmp4)
                strcat(chTextLine," ");
            AnsiPrint(chTextLine);
        }
        ucItemSelected = ucSelectedItem;
    }
}

void SelectMenu(unsigned char ucPage, unsigned char ucItem)
{
    chCol = 24;

    if ((hubInstalledPackages.ucPackages) && (ucPage<=ucLocalPages))
    {
        ucTmp1 = MAX_LOCAL_PACK_LIST_ITENS*ucPage;
        chRow = 7 + ucItemSelected;
        sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;37;40m%u - %s\x1b[0;31m\x1b[K\x1b[%u;80H\xba",chRow,chCol,ucItemSelected,hubInstalledPackages.chPackageName[ucTmp1 + ucItemSelected],chRow);
        AnsiPrint(chTextLine);
        chRow = 7 + ucItem;
        sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;30;47m%u - %s\x1b[0;31;40m\x1b[K\x1b[%u;80H\xba",chRow,chCol,ucItem,hubInstalledPackages.chPackageName[ucTmp1 + ucItem],chRow);
        AnsiPrint(chTextLine);
    }
    ucItemSelected = ucItem;
}

void SelectListMenu(unsigned char ucPage, unsigned char ucItem)
{
    chCol = 24;

    if ((hubGroupPackages.ucPackages) && (ucPage<=ucRemotePages))
    {
        ucTmp1 = MAX_REMOTE_PACK_LIST_ITENS*ucPage;
        chRow = 7 + ucPackageItemSelected;
        sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;37;40m%c - %s\x1b[0;31m\x1b[K\x1b[%u;80H\xba",chRow,chCol,ucPackageItemSelected+'A',hubGroupPackages.ucPackageName[ucTmp1 + ucPackageItemSelected],chRow);
        AnsiPrint(chTextLine);
        chRow = 7 + ucItem;
        sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;30;47m%c - %s\x1b[0;31;40m\x1b[K\x1b[%u;80H\xba",chRow,chCol,ucItem+'A',hubGroupPackages.ucPackageName[ucTmp1 + ucItem],chRow);
        AnsiPrint(chTextLine);
        sprintf(chTextLine,"\x1b[21;3H\x1b[1;33;40m%s\x1b[0;31;40m\x1b[K\x1b[21;80H\xba",hubGroupPackages.ucPackageDetail[ucTmp1 + ucItem]);
        AnsiPrint(chTextLine);
    }
    ucPackageItemSelected = ucItem;
}

void SelectRemoteMenu(unsigned char ucPage, unsigned char ucItem)
{
    chCol = 2;

    if ((hubCategories.ucGroups) && (ucPage<=ucGroupPages))
    {
        ucTmp1 = MAX_REMOTE_GROUP_ITENS*ucPage;
        if (ucItemSelected<MAX_REMOTE_GROUP_ITENS) //Is there an item selected?
        {
            chRow = 11 + ucItemSelected;
            sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;37;40m%u- %s",chRow,chCol,ucItemSelected,hubCategories.chGroupName[ucTmp1 + ucItemSelected]);
            AnsiPrint(chTextLine);
        }
        chRow = 11 + ucItem;
        sprintf(chTextLine,"\x1b[%u;%uH\x1b[1;37;47m%u- %s",chRow,chCol,ucItem,hubCategories.chGroupName[ucTmp1 + ucItem]);
        AnsiPrint(chTextLine);
        ucItemSelected = ucItem;
        GetGroupList(hubCategories.chGroupName[ucTmp1 + ucItem]);
    }
}

void HTTPFileSizeUpdate (long ContentSize)
{
    FileSize = ContentSize;
}

void HTTPStatusUpdate (bool isChunked)
{
    static unsigned char BarPosition = 21;
    char strBarUpdate[60];
    char sizeASCII[14];

    if ((FileTransferInProgress) && (!isChunked))
    {
        if (FirstStatusUpdate)
        {
            FirstStatusUpdate = false;
            AnsiPrint("\x1b[23;20H\x1b[1;32;40m\x1b[K[\x1b[23;46H]\x1b[0;31;40m\x1b[23;80H\xba");
            if (FileSize)
            {
                if (FileSize>1024)
                {
                    FileSize /= 1024;
                    sprintf (strBarUpdate,"\x1b[1;32;40m\x1b[23;48H%s KB",ltoa(FileSize,sizeASCII));
                }
                else
                    sprintf (strBarUpdate,"\x1b[1;32;40m\x1b[23;48H%s B",ltoa(FileSize,sizeASCII));

                AnsiPrint(strBarUpdate);
            }
            BarPosition = 21;
        }
        if (BarPosition<46)
        {
            sprintf(strBarUpdate,"\x1b[23;%uH\x1b[1;32;40m\xfe",BarPosition);
            AnsiPrint(strBarUpdate);
            ++BarPosition;
        }
    }

    if (!ucConnectionIcon)
        AnsiPrint(chIconOn);
    else
        AnsiPrint(chIconOff);

    ucConnectionIcon = !ucConnectionIcon;
}

// That is where our program goes
int main(char** argv, int argc)
{
	char ucKeybData = 0; //where our key inputs go
    unsigned char ucPage = 0;
    unsigned char ucState = STATE_REDRAW_LOCAL_PAGE;
    char chUpdatePackage[12];

    ucLocalPages = 0;
    ucRemotePages = 0;
    ucItensDisplayed = 0;
    ucItemSelected = 0;
    ucListPage = 0;
    ucPackageItensDisplayed = 0;
    ucPackageItemSelected = 0;
    ucConnectionIcon = false;
    FileTransferInProgress = false;
    //save cursor status
	ucCursorSave = ucCursorDisplayed;

	hubInstalledPackages.ucPackages = 0;
	hubCategories.ucGroups = 0;
	hubGroupPackages.ucPackages = 0;

	//What type of MSX?
    if(ReadMSXtype()==0) //>MSX-1?
    {
        printf ("Sorry, HUBG requires at least a MSX2...\r\n");
        //restore cursor status
        ucCursorDisplayed = ucCursorSave;
		return 0;
    }

    //What type of MSX-DOS?
    if(GetOSVersion()<2)
    {
        printf ("Sorry, HUBG requires at least MSX DOS 2...\r\n");
        //restore cursor status
        ucCursorDisplayed = ucCursorSave;
		return 0;
    }

    // Allocate memory for HGET on page 2 so it won't conflict with memory page swapping
    if (hgetinit(HI_MEMBLOCK_START) != ERR_TCPIPUNAPI_OK)
    {
        printf ("Sorry, HUBG requires an working TCP-IP UNAPI interface...\r\n");
        //restore cursor status
        ucCursorDisplayed = ucCursorSave;
        return 0;
    }
    AnsiInit();
    AnsiPrint(ucSWInfoANSI);

    // Get the full path of the program
    get_env("PROGRAM", hubpath, MAX_PATH_SIZE);
    hubdrive = hubpath[0];
    hubpath[1] = '\0';
    strcat(hubpath, ":\\HUB");

    strcpy(configpath, hubpath);
    strcat(configpath, "\\CONFIG");

    strcpy(progsdir, get_config("PROGSDIR"));
    strcpy(baseurl, get_config("BASEURL"));

    if ((progsdir[0]==0)||(baseurl[0]==0))
    {
        configure();
        strcpy(progsdir, get_config("PROGSDIR"));
        strcpy(baseurl, get_config("BASEURL"));
        if ((progsdir[0]==0)||(baseurl[0]==0))
            die("Error configuring MSX HUBG...\r\n");
    }

    do
    {
        switch (ucState)
        {
            case STATE_IDLE_LOCAL:
                if(ucConnectionIcon)
                {
                    AnsiPrint(chIconOff);
                    ucConnectionIcon = false;
                }
                break;
            case STATE_IDLE_REMOTE:
                if(ucConnectionIcon)
                {
                    AnsiPrint(chIconOff);
                    ucConnectionIcon = false;
                }
                break;
            // Generally should be called once after install/uninstall or at startup
            case STATE_REDRAW_LOCAL_PAGE:
                ucPage = 0;
                installed();
                AnsiPrint(chHubGMenu);
                AnsiPrint(chLocalSelected);
                RefreshMenu(ucPage,0);
                ucState = STATE_IDLE_LOCAL;
                break;
            // Whenever up/down is pressed and we are in LOCAL menu
            case STATE_REFRESH_LOCAL_PAGE:
                AnsiPrint(chClearInfoWindow);
                RefreshMenu(ucPage,0);
                ucState = STATE_IDLE_LOCAL;
                break;
            // Whenever up/down is pressed and we are in REMOTE menu
            case STATE_REFRESH_REMOTE_PAGE:
                AnsiPrint(chClearInfoWindow);
                RefreshRemoteMenu(ucPage,0xff);
                ucState = STATE_IDLE_REMOTE;
                break;
            case STATE_REFRESH_REMOTE_LIST:
                AnsiPrint(chClearInfoWindow);
                AnsiPrint(chIconOff);
                RefreshRemoteList(ucListPage,0);
                ucState = STATE_IDLE_REMOTE;
                break;
            case STATE_SWITCH_LOCAL_PAGE:
                ucPackageItemSelected = 0xFF;
                AnsiPrint(chLocalSelected);
                AnsiPrint(chClearInfoWindow);
                AnsiPrint(chClearCategoriesWindow);
                AnsiPrint(chClearBothStatusWindows);
                ucPage = 0;
                ucState = STATE_REFRESH_LOCAL_PAGE;
                break;
            case STATE_SWITCH_REMOTE_PAGE:
                if (!hubCategories.ucGroups)
                    categories();
                ucPage = 0;
                AnsiPrint(chRemoteSelected);
                AnsiPrint(chClearInfoWindow);
                ucState = STATE_REFRESH_REMOTE_PAGE;
                break;
        }
        ucKeybData = Inkey ();
        if ((ucKeybData>0x60)&&(ucKeybData<0x7a))
            ucKeybData-=0x20; //To Upper Case
        switch (ucKeybData)
        {
            case 'L':
                if (ucState==STATE_IDLE_REMOTE)
                    ucState = STATE_SWITCH_LOCAL_PAGE;
                break;
            case 'R':
                if (ucState==STATE_IDLE_LOCAL)
                    ucState = STATE_SWITCH_REMOTE_PAGE;
                break;
            case 28: //right
                if (ucState==STATE_IDLE_REMOTE)
                {
                    if (ucPage<ucGroupPages)
                    {
                        ++ucPage;
                        ucState = STATE_REFRESH_REMOTE_PAGE;
                    }
                }
                break;
            case 29: //left
                if (ucState==STATE_IDLE_REMOTE)
                {
                    if (ucPage)
                    {
                        --ucPage;
                        ucState = STATE_REFRESH_REMOTE_PAGE;
                    }
                }
                break;
            case 30: //up
                if (ucState==STATE_IDLE_LOCAL)
                {
                    if (ucPage)
                    {
                        --ucPage;
                        ucState = STATE_REFRESH_LOCAL_PAGE;
                    }
                }
                else if (ucState==STATE_IDLE_REMOTE)
                {
                    if (ucListPage)
                    {
                        --ucListPage;
                        ucState = STATE_REFRESH_REMOTE_LIST;
                    }
                }
                break;
            case 31: //down
                if (ucState==STATE_IDLE_LOCAL)
                {
                    if (ucPage<ucLocalPages)
                    {
                        ++ucPage;
                        ucState = STATE_REFRESH_LOCAL_PAGE;
                    }
                }
                else if (ucState==STATE_IDLE_REMOTE)
                {
                    if (ucListPage<ucRemotePages)
                    {
                        ++ucListPage;
                        ucState = STATE_REFRESH_REMOTE_LIST;
                    }
                }
                break;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                ucKeybData-='0';
                if (ucItemSelected!=ucKeybData)
                {
                    if (ucKeybData < ucItensDisplayed)
                    {
                        if (ucState==STATE_IDLE_LOCAL)
                            SelectMenu(ucPage, ucKeybData);
                        else if (ucState==STATE_IDLE_REMOTE)
                        {
                            SelectRemoteMenu(ucListPage, ucKeybData);
                            ucState = STATE_REFRESH_REMOTE_LIST;
                            ucListPage = 0;
                        }
                    }
                }
                break;
            case 'A':
            case 'B':
            case 'C':
            case 'D':
            case 'E':
            case 'F':
            case 'G':
            case 'H':
            case 'I':
            case 'J':
                if (ucState==STATE_IDLE_REMOTE)
                {
                    ucKeybData-='A';
                    if (ucPackageItemSelected!=ucKeybData)
                    {
                        if (ucKeybData < ucPackageItensDisplayed)
                        {
                            SelectListMenu(ucListPage, ucKeybData);
                        }
                    }
                }
                break;
            case 'S':
                if ((ucState==STATE_IDLE_REMOTE)&&(ucPackageItemSelected!=0xff))
                {
                    install(ucListPage, ucPackageItemSelected, NULL);
                    installed();
                }
                break;
            case 'X':
                if ((ucState==STATE_IDLE_LOCAL)&&(hubInstalledPackages.ucPackages)) //local, so it is exclude / uninstall
                {
                    uninstall(hubInstalledPackages.chPackageName[ucItemSelected + 10*ucPage]);
                    ucState = STATE_REFRESH_LOCAL_PAGE;
                    ucPage = 0;
                    installed();
                }
            case 'U':
                if ((ucState==STATE_IDLE_LOCAL)&&(hubInstalledPackages.ucPackages)) //local list upgrade
                {
                    strcpy(chUpdatePackage,hubInstalledPackages.chPackageName[ucItemSelected + 10*ucPage]);
                    uninstall(chUpdatePackage);
                    installed();
                    install(0, 0, chUpdatePackage);
                    installed();
                }
                else if ((ucState==STATE_IDLE_REMOTE)&&(ucPackageItemSelected!=0xff)) //remote list upgrade
                {
                    upgrade(ucListPage, ucPackageItemSelected);
                    installed();
                }
                break;
            case 'N':
                if ((ucState==STATE_IDLE_LOCAL)&&(hubInstalledPackages.ucPackages))
                {
                    info(hubInstalledPackages.chPackageName[ucItemSelected + 10*ucPage]);
                    AnsiPrint(chHubGMenu);
                    AnsiPrint(chLocalSelected);
                    RefreshMenu(ucPage,ucItemSelected);
                }
                else if (ucState==STATE_IDLE_REMOTE)
                {
                    if ((ucItemSelected != 0xff) && (hubGroupPackages.ucPackages) && (ucPage<=ucRemotePages))
                    {
                        ucTmp1 = (MAX_REMOTE_PACK_LIST_ITENS*ucListPage) + ucPackageItemSelected;
                        info(hubGroupPackages.ucPackageName[ucTmp1]);
                        AnsiPrint(chHubGMenu);
                        AnsiPrint(chRemoteSelected);
                        RefreshRemoteMenu(ucPage,ucItemSelected);
                        RefreshRemoteList(ucListPage,ucPackageItemSelected);
                    }
                }
                break;
        }

    }
    while(ucKeybData != 0x1b);


    hgetfinish(); //makes sure pending connection / file is closed, if there is one
    AnsiFinish();
    //restore cursor status
    ucCursorDisplayed = ucCursorSave;

	return 0;
}
