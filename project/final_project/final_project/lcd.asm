/*
 * LCD.ASM
 *
 *  CREATED: 2017/10/3
 *  AUTHOR: SHAOHUI Z5155945
 */ 

;--------------------------------------
;FUNCTIONS RELATED TO THE LCD DISPLAY:
;LCD_WAIT
;DATA_WRITE
;COM_WRITE
;LCD_INIT
;LCD_DISPLAY_NUMBER:
;LCD_DISPLAY_NUMBER_16BIT
;LCD_DISPLAY_STRING
;--------------------------------------
;LCD PORTS SHOULD BE CONNECTED AS BELOW
;LCD_CTRL -> LCD_CTRL_PORT
;LCD_DATA -> LCD_DATA_PORT
;WHITCH IS DEFINED IN CONSTANT.INC
;SPCIFICLY EACH BIT SHOULD BE
.EQU LCD_RS = 7
.EQU LCD_E = 6
.EQU LCD_RW = 5
;--------------------------------------
;WAITING FUNCTIONS AND GENERAL FUNCTIONS ARE USED IN SOME OF LCD FUNCTIONS
;MACROS.ASM SHOULD ALSO BE INCLUDE IN THE MAIN.ASM FILE
;--------------------------------------

;WAIT UNTILL LCD IS NOT BUSY
LCD_WAIT:
	PUSH R16
	CLR R16
	STORE DDRF, R16			;SET PORTF AS INPUT
	LDI R16, 1<<LCD_RW
	STORE LCD_CTRL_PORT, R16			;SET RS = 0 & RW = 1
	BUSY_LOOP:
		RCALL WAIT_1MS		;GET SOME DELAY
		SBI LCD_CTRL_PORT, LCD_E
		RCALL WAIT_1MS		;GET SOME DELAY
		LDI R16, PINF
		CBI LCD_CTRL_PORT, LCD_E
		SBRC R16, 7			;IF BF IS CLEAR, END BUSY LOOP
		RJMP BUSY_LOOP		;ELSE LOOP UNTIL IT'S SET
	CLR R16
	STORE LCD_CTRL_PORT, R16
	SER R16
	STORE DDRF, R16
	POP R16
	RET

;FUNCTION TO WRITE DATA TO LCD, USING REGISTER R16(DATA)
DATA_WRITE:
	STORE LCD_DATA_PORT, R16			;SEND DATA TO LCD_DATA
	SBI LCD_CTRL_PORT, LCD_RS		;SET LCD_RS = 1
	CBI LCD_CTRL_PORT, LCD_RW		;SET LCD_RW = 0
	RCALL WAIT_1MS
	SBI LCD_CTRL_PORT, LCD_E		;ENABLE
	RCALL WAIT_1MS
	CBI LCD_CTRL_PORT, LCD_E
	RCALL WAIT_1MS
	RET		

;FUNCTION TO WRITE COM TO LCD, USING REGISTER R16(DATA)
COM_WRITE:
	STORE LCD_DATA_PORT, R16			;SEND DATA TO LCD_DATA
	CBI LCD_CTRL_PORT, LCD_RS		;SET LCD_RS = 0
	CBI LCD_CTRL_PORT, LCD_RW		;SET LCD_RW = 0
	RCALL WAIT_1MS
	SBI LCD_CTRL_PORT, LCD_E		;ENABLE
	RCALL WAIT_1MS
	CBI LCD_CTRL_PORT, LCD_E
	RCALL WAIT_1MS
	RET

;INIT LCD USING SOME MACROS DEFINED IN MACROS.ASM
LCD_INIT:
	PUSH R16
	MACRO_WAIT 15				;WAIT 15MS
	;INIT LCD
	LCD_WRITE_COM 0B00111000
	MACRO_WAIT 5
	LCD_WRITE_COM 0B00111000
	MACRO_WAIT 1
	LCD_WRITE_COM 0B00111000	;WRITE FUNCTION SET 3TIMES
	LCD_WRITE_COM 0B00111000	;2*5*7

	LCD_WRITE_COM 0B00001000	;DISPLAY OFF
	LCD_WRITE_COM 0B00000001	;DISPLAY CLR
	LCD_WRITE_COM 0B00000110	;INCREMENT, NO SHIFT
	LCD_WRITE_COM 0B00001111	;CURSOR ON, BAR, BLINK
	POP R16
	RET


;DISPLAY 8BIT NUMBER ON LCD, INPUT R16 AS NUMBER, R23 R24 R25 USING FOR TAKE THE ASCII VALUE OF THE NUMBER
LCD_DISPLAY_NUMBER:
	PUSH R16
	PUSH R23
	PUSH R24
	PUSH R25

	CALL ITOA				;USING FUNCTION ITOA FROM GENERAL FUNCTIONS TO GET ASCII VALUE OF A CERTAIN INT
	MOV R16, R23			;DISPLAY ASCII SYMBLE ONE BY ONE
	RCALL LCD_WAIT
	RCALL DATA_WRITE
	MOV R16, R24			;FROM HIGH TO LOW
	RCALL LCD_WAIT
	RCALL DATA_WRITE
	MOV R16, R25
	RCALL LCD_WAIT
	RCALL DATA_WRITE

	POP R25
	POP R24
	POP R23
	POP R16
	RET

;16BIT NUMBER DISPLAY, SAME TECHNIQUE AS 8BIT VERSION
LCD_DISPLAY_NUMBER_16BIT:
	PUSH R16
	PUSH R17
	PUSH R21
	PUSH R22
	PUSH R23
	PUSH R24
	PUSH R25

	CALL ITOA_16BIT
	MOV R16, R21
	RCALL LCD_WAIT
	RCALL DATA_WRITE
	MOV R16, R22
	RCALL LCD_WAIT
	RCALL DATA_WRITE
	MOV R16, R23
	RCALL LCD_WAIT
	RCALL DATA_WRITE
	MOV R16, R24
	RCALL LCD_WAIT
	RCALL DATA_WRITE
	MOV R16, R25
	RCALL LCD_WAIT
	RCALL DATA_WRITE

	POP R25
	POP R24
	POP R23
	POP R22
	POP R21
	POP R16
	POP R17
	RET

;DISPLAY STRING, R16(LOW), R17(HIGH) AS STRING ADDR
LCD_DISPLAY_STRING:
	PUSH ZL
	PUSH ZH

	MOV ZL, R16
	MOV ZH, R17
	LCD_DISPLAY_STRING_LOOP:
		RCALL LCD_WAIT
		LPM R16, Z+
		CPI R16, 0
		BREQ LCD_DISPLAY_STRING_RETURN
		RCALL DATA_WRITE
		RJMP LCD_DISPLAY_STRING_LOOP
	
	LCD_DISPLAY_STRING_RETURN:
	POP ZH
	POP ZL
	RET
;DISPLAY POSITION
;R20 -> X, R21->Y, R19->Z
LCD_DISPLAY_POS:
	PUSH R16
	
	LCD_WRITE_DATA 'X'
	LCD_WRITE_DATA ':'
	MOV R16, R20
	RCALL LCD_DISPLAY_NUMBER
	LCD_WRITE_DATA ' '
	LCD_WRITE_DATA 'Y'
	LCD_WRITE_DATA ':'
	MOV R16, R21
	RCALL LCD_DISPLAY_NUMBER
	LCD_WRITE_COM 0B11000000
	LCD_WRITE_DATA 'Z'
	LCD_WRITE_DATA ':'
	MOV R16, R19
	RCALL LCD_DISPLAY_NUMBER
	LCD_WRITE_DATA ' '

	POP R16
	RET