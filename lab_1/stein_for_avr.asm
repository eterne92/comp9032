;created by ShaoHui z5155945
/*This is basicly avr version of stein's algorithm
if a != b:
	if a and b ar both even:
		gcd(a,b) = gcd(a/2,b/2) * 2
	else if a is even b is odd:
		gcd(a,b) = gcd(a/2,b)
	else if b is even a is odd:
		gcd(a,b) = gcd(a,b/2)
	...the rest is the same with normal version
	if a > b:
		gcd(a,b) = gcd(a,a-b)
	else:
		gcd(a,b) = gcd(b,b-a)
*/

.include "m2560def.inc"
.def a = r16
.def b = r17
.def temp1 = r3
.def temp2 = r4
.def c = r18
ldi c, 1
loop:
	mov temp1, a
	mov temp2, b
	lsr temp1
	brcs aisodd	;if a is odd
	lsr temp2
	brcs bisodd	;if b is odd
	lsl c		;if a and b are both even, c = c*2 and,
	lsr a		;a = a/2
	lsr b		;b = b/2
	rjmp main
aisodd:
	lsr temp2
	brcs main	;if b is odd do nothing
	lsr b		;if b is even b = b/2
	rjmp main
bisodd:
	lsr a
main:			;this is the same with normal version
	cp a,b
	breq end
	brlo lower
	sub a,b
	rjmp loop
lower:
	sub b,a
	rjmp loop
end:
	mul a,c		;gcd = a * c
	mov a,r1
halt:
	rjmp halt
