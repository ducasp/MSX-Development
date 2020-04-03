// Some routines are adaptations and have been re-used from original MSX-HUB
// source code by fr3nd, available at https://github.com/fr3nd/msxhub

#ifndef DOS_H
#define DOS_H

/* BIOS calls */
#define EXPTBL #0xFCC1

/* DOS calls */
#define CONIN   #0x01
#define CONOUT  #0x02
#define CURDRV  #0x19
#define FFIRST  #0x40
#define FNEXT   #0x41
#define OPEN    #0x43
#define CREATE  #0x44
#define CLOSE   #0x45
#define READ    #0x48
#define WRITE   #0x49
#define IOCTL   #0x4B
#define DELETE  #0x4D
#define GETCD   #0x59
#define PARSE   #0x5B
#define TERM    #0x62
#define EXPLAIN #0x66
#define GENV    #0x6B
#define DOSVER  #0x6F

#define DOSCALL  call 5
#define BIOSCALL ld iy,(EXPTBL-1)\
call CALSLT

/* open/create flags */
#define  DOS_O_RDWR     0x00
#define  DOS_O_RDONLY   0x01
#define  DOS_O_WRONLY   0x02
#define  DOS_O_INHERIT  0x04


typedef struct {
  char ff;
  char filename[13];
  char attributes;
  char time_of_modification[2];
  char date_of_modification[2];
  unsigned int start_cluster;
  unsigned long file_size;
  char logical_drive;
  char internal[38];
} file_info_block_t;

char get_current_drive(void);
char get_env(char* name, char* buffer, char buffer_size);
char delete_file(char *file);
void exit(int code);
int dos_open(char *fn, char mode);
int dos_create(char *fn, char mode, char attributes);
int dos_close(int fp);
int file_read(char* buf, unsigned int size, char fp);
unsigned int file_write(char* buf, unsigned int size, int fp);
#endif
