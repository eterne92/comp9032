;USEFUL MACROS CREATED TO MAKE PROJECT EASIER TO READ
;STORE
.MACRO STORE
	.IF @0 > 0X40
		STS @0, @1
	.ELSE
		OUT @0, @1
	.ENDIF
.ENDMACRO
;LOAD
.MACRO LOAD
	.IF @1 > 0X40
		LDS @0, @1
	.ELSE
		IN @0, @1
	.ENDIF
.ENDMACRO

;WRITE DATA INTO LCD, USING SOME CONSTANT VALUE
.MACRO LCD_WRITE_DATA
	LDI R16, @0
	RCALL DATA_WRITE
	RCALL LCD_WAIT
.ENDMACRO

;WRITE DATA INTO LCD_COM, USING SOME CONSTANT VALUE
.MACRO LCD_WRITE_COM
	LDI R16, @0
	RCALL COM_WRITE
	RCALL LCD_WAIT
.ENDMACRO

;WAIT FOR MORE THAN 1MS USING SOME CONSTANT VALUE
.MACRO MACRO_WAIT
	LDI R16, @0
	CALL WAIT_MORE
.ENDMACRO

;FLY CONTROL
.MACRO FLY_CTRL
	LDI R16, @0
	CALL PWM_DUTY
.ENDMACRO