;
; motor.asm
;
; Created: 2017/9/30 9:19:13
; Author : shaoh
;

.include "m2560def.inc"
.include "constant.inc"
.def temp = r16
.def temp2 = r17
.def direction = r18
.def current_height = r19
.def current_x = r20
.def current_y = r21


.include "macros.asm"

.org 0	;set interrupt vertex
rjmp RESET

.org 0x80
main:
	ldi temp, low(input_x_y)
	ldi temp2, high(input_x_y)
	rcall lcd_display_string
	ser temp
	wait_for_interrupt:			;in search start interrupt, set temp to 0
		cpi temp, 0
		brne wait_for_interrupt
	
	ldi current_x, -1			;set start position
	ldi current_y, 0
	ldi current_height, 10
	fly_ctrl fast_motor_speed
	fly_loop:
		lcd_clear
		cpi r23, -2
		breq search_abort
		;find next position
		rcall fly_to_next_pos
		cpi r23, -1
		breq search_not_found
		add r23, 5
		cp current_height, r23
		brlo fly_high
	search:
		mov current_height, r23
		;display now pos
		lcd_write_data 'x'
		lcd_write_data ':'
		mov temp, current_x
		rcall lcd_display_number
		lcd_write_data ' '
		lcd_write_data 'y'
		lcd_write_data ':'
		mov temp, current_y
		rcall lcd_display_number
		lcd_write_data ' '
		lcd_write_data 'z'
		lcd_write_data ':'
		mov temp, current_height
		rcall lcd_display_number
		lcd_write_data ' '

		ldi temp, low(string_search)
		ldi temp2, high(string_search)
		rcall lcd_display_string
		rcall drone_search
		macro_wait 100
		cpi r23, 0
		breq fly_loop	;if not found, keep flying
		rjmp search_found
	
	fly_high:
		fly_ctrl fast_motor_speed
		rjmp search
	
	search_found:
		lcd_clear
		ldi temp, low(string_found)
		ldi temp2, high(string_found)
		rcall lcd_display_string
		lcd_write_data 'x'
		lcd_write_data ':'
		mov temp, current_x
		rcall lcd_display_number
		lcd_write_data ' '
		lcd_write_data 'y'
		lcd_write_data ':'
		mov temp, current_y
		rcall lcd_display_number
		fly_ctrl stop_motor_speed
		rjmp end
	search_not_found:
		lcd_clear
		ldi temp, low(string_not_found)
		ldi temp2, high(string_not_found)
		rcall lcd_display_string
		fly_ctrl stop_motor_speed
		rjmp end
	search_abort:
		lcd_clear
		ldi temp, low(string_abort)
		ldi temp2, high(string_abort)
		rcall lcd_display_string
		rjmp end
		

end:
	rjmp end





SEARCH_START:
	
ext_abort:

RESET:
	clr temp
	clr temp2
	clr direction
	clr current_height
	clr current_x
	clr current_y
	;clear all registers being used

	;setup lcd
	ser temp
	store lcd_data_ddr, temp
	store lcd_ctrl_ddr, temp
	rcall lcd_init

	;setup led
	ser temp	
	store led_ddr, temp
	
	;setup keypad
	ldi temp, 0b00001111	
	store key_ddr, temp
	rjmp main

.include "keypad.asm"
.include "lcd.asm"
.include "wait.asm"
.include "drone.asm"
.include "generalfunc.asm"
.include "mountain.asm"
input_x_y:	.db "Input X,Y:",0
string_search: .db "SEARCHING", 0
string_found: .db "FOUND  ", 0
string_not_found: .db "NOT FOUND", 0
string_abort: .db "ABORT", 0


.dseg
	accident: .byte 2