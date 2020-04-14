// Some routines are adaptations and have been re-used from original MSX-HUB
// source code by fr3nd, available at https://github.com/fr3nd/msxhub


#include "dos.h"

char get_current_drive(void) __naked {
  __asm
    push ix

    ld c, CURDRV
    DOSCALL

    ld h, #0x00
    ld l, a

    pop ix
    ret
  __endasm;
}

int dos_create(char *fn, char mode, char attributes) __naked {
  fn;
  mode;
  attributes;
  __asm
    push ix
    ld ix,#4
    add ix,sp

    ld e,0(ix)
    ld d,1(ix)
    ld a,2(ix)
    ld b,3(ix)
    ld c, CREATE
    DOSCALL

    cp #0
    jr z, create_noerror$
    ld h, #0xff
    ld l, a
    jp create_error$
  create_noerror$:
    ld h, #0x00
    ld l, b
  create_error$:
    pop ix
    ret
  __endasm;
}

int dos_open(char *fn, char mode) __naked {
  fn;
  mode;
  __asm
    push ix
    ld ix,#4
    add ix,sp

    ld e,0(ix)
    ld d,1(ix)
    ld a,2(ix)
    ld c, OPEN
    DOSCALL

    cp #0
    jr z, open_noerror$
    ld h, #0xff
    ld l, a
    jp open_error$
  open_noerror$:
    ld h, #0x00
    ld l, b
  open_error$:
    pop ix
    ret
  __endasm;
}

int dos_close(int fp) __naked {
  fp;
  __asm
    push ix
    ld ix,#4
    add ix,sp

    ld b,(ix)
    ld c, CLOSE
    DOSCALL

    ld h, #0x00
    ld l,a

    pop ix
    ret
  __endasm;
}

int file_read(char* buf, unsigned int size, char fp) __naked {
  buf;
  size;
  fp;
  __asm
    push ix
    ld ix,#4
    add ix,sp

    ld e,0(ix)
    ld d,1(ix)
    ld l,2(ix)
    ld h,3(ix)
    ld b,4(ix)
    ld c, READ
    DOSCALL

    cp #0
    jr z, read_noerror$
    ld h, #0xFF
    ld l, #0xFF
  read_noerror$:
    pop ix
    ret
  __endasm;
}

unsigned int file_write(char* buf, unsigned int size, int fp) __naked {
  buf;
  size;
  fp;
  __asm
    push ix
    ld ix,#4
    add ix,sp

    ld e,0(ix)
    ld d,1(ix)
    ld l,2(ix)
    ld h,3(ix)
    ld b,4(ix)
    ld c, WRITE
    DOSCALL

    cp #0
    jr z, write_noerror$
    ld h, #0xFF
    ld l, #0xFF
  write_noerror$:
    pop ix
    ret
  __endasm;
}

char get_env(char* name, char* buffer, char buffer_size) __naked {
  name;
  buffer;
  buffer_size;
  __asm
    push ix
    ld ix,#4
    add ix,sp

    ld l,0(ix)
    ld h,1(ix)
    ld e,2(ix)
    ld d,3(ix)
    ld b,4(ix)

    ld c, GENV
    DOSCALL

    ld 0(ix),l
    ld 1(ix),h
    ld 2(ix),d
    ld 3(ix),e
    ld 4(ix),a

    pop ix
    ret
  __endasm;
}


char delete_file(char *file) __naked {
  file;
  __asm
    push ix
    ld ix,#4
    add ix,sp

    ld e,0(ix)
    ld d,1(ix)

    ld c, DELETE
    DOSCALL

    ld h, #0xff
    ld l, a

    pop ix
    ret
  __endasm;
}

void exit(int code) __naked {
  code;
  __asm
    push ix
    ld ix,#4
    add ix,sp

    ld b,(ix)
    ld c, TERM
    DOSCALL

    pop ix
    ret
  __endasm;
}
