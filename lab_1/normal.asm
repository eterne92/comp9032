;created by ShaoHui z5155945
;while a!=b
;	if a>b:
;		a = a-b
;	else:
;		b = b-a
 

.include "m2560def.inc"
.def a = r16
.def b = r17
loop:
	cp a,b
	brlo lower	;if a<b
	breq end	;if a==b
	sub a,b
	rjmp loop
lower:
	sub b,a
	rjmp loop
end:
	rjmp end