;
; motor.asm
;
; Created: 2017/9/30 9:19:13
; Author : shaoh
;

.include "m2560def.inc"
.include "constant.inc"
.DEF TEMP = R16
.DEF TEMP2 = R17
.DEF DIRECTION = R18
.DEF CURRENT_HEIGHT = R19
.DEF CURRENT_X = R20
.DEF CURRENT_Y = R21


.include "macros.asm"

.org 0	;set interrupt vertex
	rjmp RESET
.org INT0addr
	jmp SEARCH_START
.org INT1addr
	jmp search_abort
.org 0x80
main:
	input_x_loop:
		lcd_clear
		ldi temp, low(input_x<<1)
		ldi temp2, high(input_x<<1)
		rcall lcd_display_string
		call KEY_VALUE
		cpi R23, -1
		breq input_x_loop
		cpi R23, 64
		brsh input_x_loop
		mov r2, r23

	input_y_loop:
		lcd_clear
		ldi temp, low(input_y<<1)
		ldi temp2, high(input_y<<1)
		rcall lcd_display_string
		call KEY_VALUE
		cpi R23, -1
		breq input_y_loop
		cpi R23, 64
		brsh input_y_loop
		mov r3, r23

	call set_location

	ser temp
	wait_for_interrupt:			;in search start interrupt, set temp to 0
		brne wait_for_interrupt
	
search_start:
	ldi temp, 1<<INT1
	STORE EIMSK, temp			;disable the ex_int0
	ldi current_x, -1			;set start position
	ldi current_y, 0
	ldi zl, low(mountain<<1)
	ldi zh, high(mountain<<1)
	sbiw z, 1
	ser direction
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
		subi r23, -1
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
		lcd_write_com 0b11000000
		lcd_write_data 'z'
		lcd_write_data ':'
		mov temp, current_height
		rcall lcd_display_number
		lcd_write_data ' '
		ldi temp, low(string_search<<1)
		ldi temp2, high(string_search<<1)
		rcall lcd_display_string
		rcall drone_search
		macro_wait 15

		cpi r23, 0
		breq fly_loop	;if not found, keep flying
		rjmp search_found
	
	fly_high:
		fly_ctrl fast_motor_speed
		rjmp search

	search_abort:
		lcd_clear
		ldi temp, low(string_abort<<1)
		ldi temp2, high(string_abort<<1)
		rcall lcd_display_string
		fly_ctrl stop_motor_speed
		rjmp end
	search_not_found:
		lcd_clear
		ldi temp, low(string_not_found<<1)
		ldi temp2, high(string_not_found<<1)
		rcall lcd_display_string
		fly_ctrl stop_motor_speed
		rjmp end

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

		

end:
	rjmp end





RESET:
	clr temp
	clr temp2
	clr direction
	clr current_height
	clr current_x
	clr current_y
	clr r23
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
	ldi temp, (1<<ISC01)|(1<<ISC11)
	sts EICRA, temp
	ldi temp, (1<<INT0)
	out EIMSK, temp
	ser temp
	out DDRE, temp
	call pwm_generate
	
	rjmp main

.include "keypad.asm"
.include "lcd.asm"
.include "wait.asm"
.include "drone.asm"
.include "generalfunc.asm"
.include "mountain.asm"
input_x:	.db "INPUT X:",0
input_y: .db "INPUT Y:"
string_search: .db "SEARCHING", 0
string_found: .db "FOUND  ", 0
string_not_found: .db "NOT FOUND", 0
string_abort: .db "ABORT", 0


.dseg
	accident: .byte 2