OCM-PLD Pack v3.9.2plus
=======================

Author:  KdL (3.9.2 for 1st Gen and 2nd Gen) Ducasp (3.9.2plus 2nd Gen only)
Update:  2024.XX.YY

This package includes a set of custom firmware to update the following machines.

1st Gen  =>  Please download KdL pack, not found here.
2nd Gen  =>  SM-X (regular), SM-X (mini), SM-X HB (all types), MC2P and SX-2.

Ducasp extra support:

1.8 Gen  =>  SM-X HB and its variants, FPGA is a little bit smaller than the one in second generation
             devices and most have 8MB SDRAM
MC2P     =>  MC2P is a multicore system with a huge 55k LE FPGA, extra SRAM, etc

All firmware are self-made and not provided by the respective manufacturers.
However, manufacturers are allowed to use these firmware as long as no surcharge is applied.
The common base firmware is that of the first generation, which originated with 1chipMSX.
Second generation machines have additional functions as they are more capacious.

The MSX++ logo was officially granted to the OCM-PLD firmware by 西 和彦 [Mr. Kazuhiko Nishi] on 2022/Jul/21st.

Here is how to recognize an MSX++ system and how it is classified:
- the 1chipMSX machine upgraded with OCM-PLD is for all intents and purposes an MSX++ computer;
- while homebrew machines that receive the same type of upgrade are considered MSX++ compatible;
- individual components do not identify MSX++, so all unofficial firmware derived from OCM-PLD
  (those not maintained by KdL) can be considered MSX++ compatibles as long as they correcly support
  the switched I/O ports extension with ID 0xD4 (212=OCM ID, now MSX++ ID).

For more details, refer to the 'history.txt' and the other texts included in the folders of this package.


______
Enjoy!
