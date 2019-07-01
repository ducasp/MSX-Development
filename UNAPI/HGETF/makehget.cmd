sdcc --code-loc 0x180 --data-loc 0 -mz80 --disable-warning 196 --no-std-crt0 crt0_msxdos_advanced.rel fusion.lib base64.lib asm.lib hgetf.c
hex2bin -e com hgetf.ihx