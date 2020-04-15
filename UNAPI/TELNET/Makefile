CC = sdcc

INCDIR = ../fusion-c/header
LIBDIR = ../fusion-c/lib
BUILDDIR = build
IHXFILE = $(BUILDDIR)/TELNET.IHX

SRC = $(wildcard src/*.c)
OBJ = $(SRC:.c=.rel)
TMPFILES =	$(SRC:.c=.asm) \
		$(SRC:.c=.sym) \
		$(SRC:.c=.lst) \
		$(BUILDDIR)/TELNET.lk \
		$(BUILDDIR)/TELNET.map \
		$(BUILDDIR)/TELNET.noi \
		$(IHXFILE)

CRT0 = ../fusion-c/include/crt0_msxdos_advanced.rel

CFLAGS = --out-fmt-ihx --no-std-crt0 -mz80 --opt-code-speed \
	 --verbose --code-loc 0x180 --data-loc 0x0 --disable-warning 196 \
	 --allow-unsafe-read

LIBS = $(LIBDIR)/msx2ansi.lib \
       $(LIBDIR)/asm.lib \
       $(LIBDIR)/fusion.lib

%.rel:  %.c
	@echo
	@echo Compiling $@...
	@echo
	$(CC) $(CFLAGS) -I$(INCDIR) -o $@ -c $<

all:	$(OBJ)
	mkdir -p $(BUILDDIR)
	@echo
	@echo Compiling $(IHXFILE)
	@echo
	$(CC) -o $(IHXFILE) $(CFLAGS) $(CRT0) $(LIBS) $(OBJ)
	@echo
	@echo Converting IHX file to COM
	@echo
	hex2bin -e COM $(IHXFILE)
	@echo
	@echo =========================================================
	@echo
	@echo Done. Check for TELNET.COM in \"$(BUILDDIR)\" directory
	@echo

.PHONY: clean
clean:
	rm -f $(OBJ) $(TMPFILES) $(BUILDDIR)/TELNET.COM
