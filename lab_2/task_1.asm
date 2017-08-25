;
; lab_2_task1
; division between two 16 bit unsign ints
; 
; Author : z515594
.def dividend_lo = r16
.def dividend_hi = r17
.def divisor_lo = r18
.def divisor_hi = r19
.def bit_p_lo = r20
.def bit_p_hi = r21
.def quotien_lo = r4
.def quotien_hi = r5
.def n = r22
.macro shift_left	;shift_left @0:@1
	lsl @0			;shift @1 first bit(7) gose to carry
	rol @1			;shift @0 with carry gose to bit(0)
.endmacro

.macro shift_right	;shift_right @0:@1
	lsr @1			;shift @0 first bit(0) gose to carry
	ror @0			;shift @1 with carry gose to bit(7)
.endmacro
.dseg
	quotient: .byte 2
.cseg
rjmp start
	data:	.dw 60000
			.dw 5000

start:
clr r2
clr n
;load_mem
ldi bit_p_lo, 0x1
ldi ZH, high(data<<1)
ldi ZL, low(data<<1)
lpm dividend_lo, Z+
lpm dividend_hi, Z+
lpm divisor_lo, Z+
lpm divisor_hi, Z+
;shift divisor to left
check_shift:
	cp divisor_lo, dividend_lo		;check low part of dividend and divisor first  
	cpc divisor_hi, dividend_hi		;then the higherpart
	brsh minus						;if divisor is bigger, goto minus part
left_shift:
	subi divisor_hi, 0				;if the last bit
	brmi minus						;of divisor_hi is 1,then goto the minus part
	shift_left divisor_lo,divisor_hi;left shift divisor
	shift_left bit_p_lo,bit_p_hi	;along with bit_position
	inc n							;n++
	rjmp check_shift				;check again after divisor is shift
;minus part
minus:
	cpi n, -1						;if n(indicate where is the bit position) == -1
	breq store						;means divisor now is smaller than original ,end the machine
	cp dividend_lo, divisor_lo		;if dividend is bigger,go make_minus
	cpc dividend_hi, divisor_hi
	brsh make_minus
right_shift:							
	shift_right divisor_lo,divisor_hi	;right shift divisor
	shift_right bit_p_lo,bit_p_hi		;along with bit_position
	dec n								;n -- (indicate the bit_position)
	rjmp minus						;if dividend is smaller right shift divisor
make_minus:							;this is for dividend - divisor
	sub dividend_lo,divisor_lo		;
	sbc dividend_hi,divisor_hi		;
	add quotien_lo, bit_p_lo		;after minus, quotien = quotien + bit_position
	add quotien_hi, bit_p_hi
	rjmp minus						;goto minus loop
store:
	ldi ZH, high(quotient)		;store the quotient into the datamem
	ldi ZL, low(quotient)
	st Z+, quotien_lo
	st Z, quotien_hi
	rjmp end
end:
	rjmp end
