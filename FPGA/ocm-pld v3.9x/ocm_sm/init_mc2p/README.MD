NOT ALL FEATURES WORKING

The new IPL requires a ROM in FLASH memory, SM-X/SX2 has it, but
systems like MC2+, MiSTER, MiST, etc do not have it and just
load the RBF and need to use SD BIOS. But, to load SD BIOS now
you need the new IPL that is in flash, that for multi core FPGA
systems is non-existent.

So for MC2P I've backported the previous IPL rom that doesn't have
any parts in EPCS FLASH. So, this allows MC2P to have 3.9.1, but,
unfortunately the new IPL features (load OCM-BIOS.DAT even if not
the first file and allow to re-load OCM-BIOS without a power cycle)
will not be present. Seems like MiST version of 3.9.1 has chosen this
route as well.

Also I've decided to not use the new PS2 controller as it might cause
issues on currently working keyboards if no hardware changes are made,
as everyone should have a keyboard working now, I think the risks
outweight the benefits.

NEM TUDO DA 3.9.1 FUNCIONA

O novo IPL requer uma ROM carregada em FLASH, SM-X/SX2 tem, mas os
sistemas como MC2+, MiSTER, MiST, etc não tem essa FLASH e o RBF é
carregado e o resto vem da SD BIOS. Mas, para carregar a SD-BIOS é
necessária uma extensão da IPL na flash, que não existe nos sistemas
FPGA multi core.

Então no MC2P eu retornei pro IPL antigo que não tem qualquer parte
na FLASH EPCS. Isso permite que o MC2P tenha a 3.9.1, mas infelizmente
as novidades do IPL (carregar OCM-BIOS.DAT mesmo não sendo o primeiro
arquivo / permitir re-carregar a OCM-BIOS sem desligar e religar) não
estão presentes. Parece que a versão 3.9.1 do MiST escolheu esse mesmo
caminho também.

Também decidi não utilizar o novo controlador PS2 já que pode causar
problemas em teclados que já funcionam se não aplicar algumas mudanças
no hardware. Como todos já tem seu teclado funcionando agora, creio que
os riscos são maiores que os benefícios.