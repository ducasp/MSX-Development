; SWAPEIDI.COM v1.0 by KdL (2017.09.18)
; =====================================
; This is a useful trick that helps to speedup the execution of any batch file.
; --- 1st execution permits to disable the interrupt used by input peripherals.
; - 2nd execution permits to re-enable the interrupt used by input peripherals.
;
; ---------------------------------
; Coded in TWZ'CA3 w/ TASM80 v3.2ud
; ---------------------------------
;
    .org  $0100

startProgram:
    ld    a, ($f3e0)
    xor   $20
    ld    b, a
    ld    c, $01
    ld    ix, $012d
    ld    iy, ($faf7)
    call  $001c
    xor   a
    ld    ($fca9), a
    ret
    
endProgram:
    .dw   $ffff,$ffff,$ffff,$ffff
    .db   "[ SWAPEIDI.COM ]"

.end

