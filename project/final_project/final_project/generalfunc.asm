/*
 * generalfunc.asm
 *
 *  Created: 2017/9/29 22:20:30
 *   Author: shaoh
 */ 
;---------------------------------------------
;SOME USEFUL FUNCTIONS:
;ITOA
;ITOA_16BIT
;PWM_GENERATE
;---------------------------------------------
ITOA:	;8BIT INPUT(MAX 255, MIN 0) R16, R23:R24:R25 OUTPUT ASCII VALUE
	PUSH R16
	CLR R23
	CLR R24
	CLR R25

	E100S:					;EXTRACT 100
		CPI R16, 100
		BRLO E10S
		SUBI R16, 100
		INC R23
		RJMP E100S

	E10S:					;EXTRACT 10
		CPI R16, 10
		BRLO E1S
		SUBI R16, 10
		INC R24
		RJMP E10S

	E1S:					;EXTRACT 1
		CPI R16, 1
		BRLO ITOA_RETURN
		SUBI R16, 1
		INC R25
		RJMP E1S

	ITOA_RETURN:
		SUBI R23, -'0'		;GET ASCII VALUE FOR EACH
		SUBI R24, -'0'
		SUBI R25, -'0'
		POP R16
		RET

ITOA_16BIT:	;16BIT INPUT(MAX 65535, MIN 0) R17_HIGH:R16_LOW, R21:R22:R23:R24:R25 OUTPUT ASCII VALUE
	PUSH R16			;LOW
	PUSH R17			;HIGH
	PUSH R18			;TEMP REGISTER
	CLR R21				;10000S
	CLR R22				;1000S
	CLR R23				;100S
	CLR R24				;10S
	CLR R25				;1S

	XE10000S:					;EXTRACT 10000
		LDI R18, HIGH(10000)
		CPI R16, LOW(10000)
		CPC R17, R18
		BRLO XE1000S
		SUBI R16, LOW(10000)
		SBC R17, R18
		INC R21
		RJMP XE10000S

	XE1000S:					;EXTRACT 1000
		LDI R18, HIGH(1000)		;USE R18 TO CMP
		CPI R16, LOW(1000)		;CMP LOW FIRST
		CPC R17, R18			;THEN HIGH
		BRLO XE100S
		SUBI R16, LOW(1000)		;SUB LOW FIRST
		SBC R17, R18			;THEN HIGH
		INC R22
		RJMP XE1000S

	XE100S:					;EXTRACT 100
		LDI R18, HIGH(100)
		CPI R16, LOW(100)
		CPC R17, R18
		BRLO XE10S
		SUBI R16, LOW(100)
		SBC R17, R18
		INC R23
		RJMP XE100S

	XE10S:					;EXTRACT 10
		CPI R16, 10
		BRLO XE1S
		SUBI R16, 10
		INC R24
		RJMP XE10S

	XE1S:					;EXTRACT 1
		CPI R16, 1
		BRLO ITOA_16BIT_RETURN
		SUBI R16, 1
		INC R25
		RJMP XE1S

	ITOA_16BIT_RETURN:
		SUBI R21, -'0'		;GET ASCII VALUE FOR EACH
		SUBI R22, -'0'
		SUBI R23, -'0'
		SUBI R24, -'0'
		SUBI R25, -'0'

		POP R18
		POP R17
		POP R16
		RET

;USING TIMER3 AND OCR3B TO GENERATE PWM

PWM_GENERATE:
	PUSH r16
	
	ser TEMP
	STORE DDRE, r16					;SET UP PORTE BIT4 AS PWM OUTPUT
	clr TEMP
	STORE OCR3CH, r16
	clr temp
	STORE OCR3CL, r16					;ONLY OCR3BL MATTERS(8BIT PWM)
	LDI TEMP, (1<<WGM30)|(1<<COM3C1)	;8BIT PHASE CORRECT PWM MODE
	STORE TCCR3A, r16		
	LDI TEMP, 1<<CS30					
	STORE TCCR3B, r16
	ser temp
	out portc, temp
	
	POP r16
	ret

;Change pwm duty
.set PWM_CMP_REG = OCR3CL		;use OCR3BL as pwm compare regis
pwm_duty:
	push r16

	STORE PWM_CMP_REG, r16

	pop r16
	ret

LEDFLASH:
	push r16

	ser r16
	out portc, r16
	macro_wait 50
	clr r16
	out portc, r16
	macro_wait 50
	ser r16
	out portc, r16
	macro_wait 50
	clr r16
	out portc, r16
	macro_wait 50
	ser r16
	out portc, r16
	macro_wait 50
	clr r16
	out portc, r16
	macro_wait 50

	pop r16
	ret
