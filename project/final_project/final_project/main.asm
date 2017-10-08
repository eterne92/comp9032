;
; motor.asm
;
; Created: 2017/9/30 9:19:13
; Author : shaoh
;

.include "m2560def.inc"
.include "constant.inc"
.def temp = r16
.def direction = r18
.def current_x = r20
.def current_y = r21


.include "macros.asm"

.org 0	;set interrupt vertex


.include "keypad.asm"
.include "lcd.asm"
.include "wait.asm"
.include "drone.asm"
.include "generalfunc.asm"
.include "mountain.asm"

SEARCH_START:
	


.dseg
	accident: .byte 2