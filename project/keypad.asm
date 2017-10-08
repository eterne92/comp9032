/*
 * keypad.asm
 *
 *  Created: 2017/10/3
 *  Author: shaohui z5155945
 */ 
;----------------------------------
;functions related to keypad
;get_key
;key_ascii
;----------------------------------
;KEYPAD should be connected as below
;KEYPAD -> PORTL
;colums -> 4:7
;rows -> 0:3
;port directions should be set on RESET
;----------------------------------
.equ ROWMASK = 0x0F
.equ COLMASK = 0b11101111	;start from c0

;function to get keyvalue from keypad, return row:col on r24:r25
get_key:
	push r16				;r16 as rmask
	push r17				;r17 as row
	push r18				;r18 as col
	push r19				;r19 as temp1
	push r20				;r20 as temp2
	push r21				;r21 as cmask
	set_cmask:
		ldi r21, COLMASK
		STORE PORTL, r21	;set colmask to 0x11101111
		clr r18				;set col to 0
	cloop:
		ldi r16, 0x01		;start from row 0
		clr r17				;set row to 0
	rloop:
		LOAD r19, PINL		;get value from KEYPAD
		mov r20, r19
		andi r20, ROWMASK	;clr col input
		and r20, r16
		brne next_row
		rjmp debouncing_loop
	next_row:
		lsl r16				;leftshift rmask
		inc r17				;row = row + 1
		cpi r17, 4			;if row == 4
		breq next_col		;goto next col
		rjmp rloop			;else goto next row
	next_col:
		lsl r21				;leftshift cmask
		inc r18				;col = col + 1
		cpi r18, 4			;if col == 4
		breq set_cmask		;startover again
		inc r21
		STORE PORTL, r21		;set cmask
		rjmp cloop			;goto next col

	debouncing_loop:		;solve debouncing
		LOAD r19, PINL
		andi r19, ROWMASK
		cpi r19, 0x0F
		brne debouncing_loop
	mov r24, r17			;r24 as row
	mov r25, r18			;r25 as col

	pop r21
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	ret

;get key_ascii value from input as r24->row, r25->col, return ascii value as r23
key_ascii:
	push r24				;r24 as row
	push r25				;r25 as col
	push r16				;r16 as temp
	push r0
	push r1					;mul will be used

	rcall get_key
	cpi r25, 3				;if col == 3
	breq ascii_letter
	cpi r24, 3				;if row == 3
	breq ascii_symbol
	ldi r16, 3				;temp = 3 * row + col
	mul r24, r16			;
	mov r16, r0
	add r16, r25 
	subi r16, -'1'			;get ascii value
	mov r23, r16
	rjmp return_key_ascii

	ascii_letter:
		ldi r16, 'A'			;temp = 'A'
		add r16, r24			;temp += row
		mov r23, r16
		rjmp return_key_ascii

	ascii_symbol:
		cpi r25, 0				;'*'
		breq ascii_star
		cpi r25, 1				;'0'
		breq ascii_zero
		ldi r23, '#'			;'#'
		rjmp return_key_ascii

	ascii_star:
		ldi r23, '*'
		rjmp return_key_ascii

	ascii_zero:
		ldi r23, '0'
		rjmp return_key_ascii

return_key_ascii:
	pop r1
	pop r0
	pop r16
	pop r25
	pop r24
	ret