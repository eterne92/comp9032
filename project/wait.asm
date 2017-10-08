/*
 * wait.asm
 *
 *  Created: 2017/10/3
 *  Author: shaohui z5155945
 */ 
;----------------------------------
;some functions to generate delays
;wait_1ms
;wait_more
;----------------------------------

;function to wait for 1ms
wait_1ms:
	push r24
	push r25

	ldi r24, low(4100)
	ldi r25, high(4100)		;a little more than 1ms
	ms_loop:
		sbiw r24, 1
		brne ms_loop
	
	pop r25
	pop r24
	ret

;using r16 as input for wait r16ms
wait_more:
	push r16

	wait_more_loop:
		rcall wait_1ms		;each time wait for 1ms
		dec r16
		brne wait_more_loop

	pop r16
	ret
