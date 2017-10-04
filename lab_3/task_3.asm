.include "m2560def.inc"

.def rmask = r16
.def cmask = r17
.def temp = r18

RESET:
    ser temp
    out PORTF, temp
    ldi temp, 0b00001111
    out DDRF, temp     ;set portF 00:03 in, 04:07 out
    rjmp main

main:
    ldi rmask, 0b10000000

