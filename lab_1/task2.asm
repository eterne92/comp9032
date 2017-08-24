;
; lab_2 task 2
;
; Created: 2017/8/9 11:18:04
; Author : shaohui z5155945
;
/*
answer = 0
for i in {1,2...n}:
	answer = a * (answer + 1)
*/

.include "m2560def.inc"

.def ans_lo = r24
.def ans_hi = r25
.def a = r18
.def n = r19

.macro multiply	;@0:@1 * @2 -> @0:@1 where @0 is the low bit  and @1 is the high bit
	/*
		@1hi		@0lo
	*				@2
		-----------------
		@0*@2hi  @0*@2lo
	+	@1*@2lo
		-----------------
	=	result_hi result_lo
	to	@1hi		@0lo
		-----------------
		final_result
	*/
	mul @1, @2				;@1 * @2 -> r0:r1 where r0 is the lo bit
	mov @1, r0				;mov lo bit r0 to @1, now @1 = @1*@2lo
	mul @0, @2				;@0 * @2 -> r0:r1 where r0 is the lo bit
	mov @0, r0				;mov lo bit r0 to @0, now @0 = @0*@2lo
	add @1, r1				;add @1 with the high bit r1, now @1 = @1*@2lo + @0*@2hi
.endmacro
mov ans_lo, a				;when n = 1, answer is a
loop:						;start loop
	dec n					;n--, n as the counter for loops
	breq end				;if n == 0 then end the machine
	adiw ans_lo, 1			;increase answer by 1, answer = answer + 1
	multiply ans_lo,ans_hi,a;answer = answer * a
	rjmp loop				;end loop

end:
	rjmp end