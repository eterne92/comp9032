;
; motor.asm
;
; Created: 2017/9/30 9:19:13
; Author : shaoh
;

.include "m2560def.inc"
; Replace with your application code
.def temp = r16
.def speed = r4
.def temp2 = r18
.def counter = r2
.include "macros.asm"

.macro lcd_display_speed
	lcd_write_data 's'
	lcd_write_data 'p'
	lcd_write_data 'e'
	lcd_write_data 'e'
	lcd_write_data 'd'
	lcd_write_data ':'
.endmacro

.org 0
	 rjmp RESET
.org INT3addr
	jmp EXINT3
.org OC1Aaddr
	jmp Timer1CMP
.org 0x80
RESET:
	ldi temp, 0b11110000
	sts DDRL, temp				;PORTL, 0:3 out, 4:7 in
	clr temp
	STORE DDRD, temp

	ser temp
	STORE DDRF, temp
	STORE DDRA, temp
	ser temp
	STORE DDRC, temp
	ser temp
	STORE PORTC, temp
	ldi temp, 1
	STORE DDRB, temp
	ser temp
	STORE PORTB, temp
	rcall lcd_init
	clr temp
	
	rjmp main
main:
	;set exint3
	ldi temp, 1<<INT3
	STORE EIMSK, temp
	ldi temp, 1<<ISC31
	STORE EICRA, temp
	;set timer
	clr speed
	ldi temp, high(15625 /2 /2)
	ldi temp2, low(15625 /2 /2)
	STORE OCR1AH , temp
	STORE OCR1AL, temp2
	ldi temp, 1<<OCIE1A
	STORE TIMSK1, temp
	/*ldi temp, (1<<COM1A0)		
	STORE TCCR1A, temp*/
	ldi temp, (1<<CS12)|(1<<CS10)|(1<<WGM12)
	STORE TCCR1B, temp
	call pwm_generator
	sei
	loop:
		call key_ascii
		cpi r23, '1'
		breq slow
		cpi r23, '2'
		breq fast
		cpi r23, '3'
		breq end
		rjmp loop
	slow:
		LOAD temp, ocr3bl
		subi temp, 5
		store ocr3bl, temp
		rjmp loop
	fast:
		LOAD temp, ocr3bl
		subi temp, -5
		store ocr3bl, temp
		rjmp loop
	end:
		clr temp
		store ocr3bl, temp
		rjmp loop
.include "lcd.asm"
.include "keypad.asm"
Timer1CMP:
	push temp
	LOAD temp, SREG
	push temp
	lcd_write_com 0b00000001
	mov r16, speed
	call lcd_display_number
	clr speed
	pop temp
	STORE SREG, temp
	pop temp
	reti
	
EXINT3:
	inc speed
	reti

