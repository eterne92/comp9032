; lab_3 task_2.asm
; created by SHAOHUI z5155945
;
;
;

.include "m2560def.inc"

.def counter = r16
.def temp = r17
.equ upperbound = 61
.org INT0addr
    jmp EXT_INT0
.org INT1addr
    jmp EXT_INT1
.org OVF0addr
    jmp T0OV_INT

RESET:
    sei
    ser temp
    clr counter
    out DDRC, temp
    rjmp main
    sei

EXT_INT0:

EXT_INT1:

T0OV_INT:

main:
    ldi temp, (1<<INT0)|(1<<INT1)
    out EIMSK, temp
    ldi temp, (2<<ISC00)
    sts EICRA, temp
    