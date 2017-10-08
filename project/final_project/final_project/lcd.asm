/*
 * lcd.asm
 *
 *  Created: 2017/10/3
 *  Author: shaohui z5155945
 */ 

;--------------------------------------
;functions related to the lcd display:
;lcd_wait
;data_write
;com_write
;lcd_init
;lcd_display_number:
;lcd_display_number_16bit:
;--------------------------------------
;LCD ports should be connected as below
;lcd_ctrl -> portA
;lcd_DATA -> portF
;spcificly each bit should be
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
;--------------------------------------
;waiting functions and general functions are used in some of lcd functions
;macros.asm should also be include in the main.asm file
.ifndef wait_1s
	.include "wait.asm"
.endif
.ifndef itoa
	.include "generalfunc.asm"
.endif
;--------------------------------------

;wait untill lcd is not busy
lcd_wait:
	push r16
	clr r16
	out DDRF, r16			;set PORTF as input
	ldi r16, 1<<LCD_RW
	out PORTA, r16			;set RS = 0 & RW = 1
	busy_loop:
		rcall wait_1ms		;get some delay
		sbi PORTA, LCD_E
		rcall wait_1ms		;get some delay
		ldi r16, PINF
		cbi PORTA, LCD_E
		sbrc r16, 7			;if BF is clear, end busy loop
		rjmp busy_loop		;else loop until it's set
	clr r16
	out PORTA, r16
	ser r16
	out DDRF, r16
	pop r16
	ret

;function to write data to lcd, using register r16(data)
data_write:
	out PORTF, r16			;send data to lcd_data
	sbi PORTA, LCD_RS		;set LCD_RS = 1
	cbi PORTA, LCD_RW		;set LCD_RW = 0
	rcall wait_1ms
	sbi PORTA, LCD_E		;enable
	rcall wait_1ms
	cbi PORTA, LCD_E
	rcall wait_1ms
	ret		

;function to write com to lcd, using register r16(data)
com_write:
	out PORTF, r16			;send data to lcd_data
	cbi PORTA, LCD_RS		;set LCD_RS = 0
	cbi PORTA, LCD_RW		;set LCD_RW = 0
	rcall wait_1ms
	sbi PORTA, LCD_E		;enable
	rcall wait_1ms
	cbi PORTA, LCD_E
	rcall wait_1ms
	ret

;init lcd using some macros defined in macros.asm
lcd_init:
	push r16
	push temp
	macro_wait 15				;wait 15ms
	;init lcd
	lcd_write_com 0b00111000
	macro_wait 5
	lcd_write_com 0b00111000
	macro_wait 1
	lcd_write_com 0b00111000	;write function set 3times
	lcd_write_com 0b00111000	;2*5*7

	lcd_write_com 0b00001000	;display off
	lcd_write_com 0b00000001	;display clr
	lcd_write_com 0b00000110	;increment, no shift
	lcd_write_com 0b00001111	;cursor on, bar, blink
	pop r16
	pop temp
	ret


;display 8bit number on lcd, input r16 as number, r23 r24 r25 using for take the ascii value of the number
lcd_display_number:
	push r16
	push r23
	push r24
	push r25

	call itoa				;using function itoa from general functions to get ascii value of a certain int
	mov r16, r23			;display ascii symble one by one
	rcall lcd_wait
	rcall data_write
	mov r16, r24			;from high to low
	rcall lcd_wait
	rcall data_write
	mov r16, r25
	rcall lcd_wait
	rcall data_write

	pop r25
	pop r24
	pop r23
	pop r16
	ret

;16bit number display, same technique as 8bit version
lcd_display_number_16bit:
	push r16
	push r17
	push r21
	push r22
	push r23
	push r24
	push r25

	call itoa_16bit
	mov r16, r21
	rcall lcd_wait
	rcall data_write
	mov r16, r22
	rcall lcd_wait
	rcall data_write
	mov r16, r23
	rcall lcd_wait
	rcall data_write
	mov r16, r24
	rcall lcd_wait
	rcall data_write
	mov r16, r25
	rcall lcd_wait
	rcall data_write

	pop r25
	pop r24
	pop r23
	pop r22
	pop r21
	pop r16
	pop r17
	ret