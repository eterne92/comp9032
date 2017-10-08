/*
 * generalfunc.asm
 *
 *  Created: 2017/9/29 22:20:30
 *   Author: shaoh
 */ 
;---------------------------------------------
;some useful functions:
;itoa
;itoa_16bit
;---------------------------------------------
itoa:	;8bit input(max 255, min 0) r16, r23:r24:r25 output ascii value
	push r16
	clr r23
	clr r24
	clr r25

	e100s:					;extract 100
		cpi r16, 100
		brlo e10s
		subi r16, 100
		inc r23
		rjmp e100s

	e10s:					;extract 10
		cpi r16, 10
		brlo e1s
		subi r16, 10
		inc r24
		rjmp e10s

	e1s:					;extract 1
		cpi r16, 1
		brlo itoa_return
		subi r16, 1
		inc r25
		rjmp e1s

	itoa_return:
		subi r23, -'0'
		subi r24, -'0'
		subi r25, -'0'
		pop r16
		ret

itoa_16bit:	;16bit input(max 65535, min 0) r17_high:r16_low, r21:r22:r23:r24:r25 output ascii value
	push r16			;low
	push r17			;high
	push r18			;temp register
	clr r21				;10000s
	clr r22				;1000s
	clr r23				;100s
	clr r24				;10s
	clr r25				;1s

	xe10000s:					;extract 10000
		ldi r18, high(10000)
		cpi r16, low(10000)
		cpc r17, r18
		brlo xe1000s
		subi r16, low(10000)
		sbc r17, r18
		inc r21
		rjmp xe10000s

	xe1000s:					;extract 1000
		ldi r18, high(1000)		;use r18 to cmp
		cpi r16, low(1000)		;cmp low first
		cpc r17, r18			;then high
		brlo xe100s
		subi r16, low(1000)		;sub low first
		sbc r17, r18			;then high
		inc r22
		rjmp xe1000s

	xe100s:					;extract 100
		ldi r18, high(100)
		cpi r16, low(100)
		cpc r17, r18
		brlo xe10s
		subi r16, low(100)
		sbc r17, r18
		inc r23
		rjmp xe100s

	xe10s:					;extract 10
		cpi r16, 10
		brlo xe1s
		subi r16, 10
		inc r24
		rjmp xe10s

	xe1s:					;extract 1
		cpi r16, 1
		brlo itoa_16bit_return
		subi r16, 1
		inc r25
		rjmp xe1s

	itoa_16bit_return:
		subi r21, -'0'
		subi r22, -'0'
		subi r23, -'0'
		subi r24, -'0'
		subi r25, -'0'

		pop r18
		pop r17
		pop r16
		ret

;using 
pwm_generator:
	push temp
	
	ser temp
	STORE DDRE, temp
	clr temp
	store ocr3Bh, temp
	ser temp
	STORE OCR3Bl, temp
	/*ldi temp, 0x4A
	STORE OCR2BL, temp*/
	
	ldi temp, (1<<WGM30)|(1<<COM3B1)
	STORE TCCR3A, temp
	ldi temp, 1<<CS30
	STORE TCCR3B, temp

	
	/*ldi temp, 1<<OCIE3A
	STORE TIMSK3, temp*/ 
	ser temp
	STORE PORTC, temp
	

	pop temp
