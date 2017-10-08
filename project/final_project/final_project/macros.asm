;useful macros created to make project easier to read
;STORE
.macro STORE
	.if @0 > 0x40
		sts @0, @1
	.else
		out @0, @1
	.endif
.endmacro
;LOAD
.macro LOAD
	.if @1 > 0x40
		lds @0, @1
	.else
		in @0, @1
	.endif
.endmacro

;write data into lcd, using some constant value
.macro lcd_write_data
	ldi r16, @0
	rcall data_write
	rcall lcd_wait
.endmacro

;write data into lcd_com, using some constant value
.macro lcd_write_com
	ldi r16, @0
	rcall com_write
	rcall lcd_wait
.endmacro

;wait for more than 1ms using some constant value
.macro macro_wait
	ldi r16, @0
	call wait_more
.endmacro
