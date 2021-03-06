;Z POINTING TO THE LAST POSITION, R18 DIRECTION
;R21-> ROW, R20-> COL, R18 -> DIRECTION
;Z POINT TO LAST POSITION
;NEW_HEIGHT -> R23 AS RETURN
;IF REACH END, RETURN -1(WHICH MIGHT NEVER HAPPEN)
FLY_TO_NEXT_POS:    
    CPI R18, 0      ;R18 -> SET AS FLY RIGHT, CLEAR AS FLY LEFT
    BREQ GO_LEFT
    CPI R20, BORDER_X   ;CHECK IF REACHED BOARDER
    BREQ GO_DOWN        ;IF BOARDER REACHED, GO DOWN
    LCD_WRITE_DATA 'E'
    ADIW Z, 1
    INC R20

    CHECK_HEIGHT:
        LPM R23, Z
        LCD_WRITE_DATA ' '
        RET

    GO_END:
        LDI R23, -1
        RET

    GO_LEFT:
        CPI R20, 0
        BREQ GO_DOWN
        LCD_WRITE_DATA 'W'
        SBIW Z, 1
        DEC R20
        RJMP CHECK_HEIGHT
    
    GO_DOWN:
        CPI R21, BORDER_Y
        BREQ GO_END
        LCD_WRITE_DATA 'S'
        ADIW Z, BORDER_Y	    ;NEXT ROW
        COM R18                 ;DIFFERENT DIRECTION
        INC R21					;SET R21, NEXT ROW
        RJMP CHECK_HEIGHT
;FLYING BACK FROM SOME POSITION
;FLY WEST FIRST, THEN FLY NORTH TO 0,0
FLY_BACK:
	PUSH R16
	PUSH R17

	LCD_CLEAR
	FLY_CTRL HALF_MOTOR_SPEED			;SUSPEND FOR SOME TIME
	LDI R16, LOW(FLYING_BACK_STRING<<1)	;PRINT FLY BACK
	LDI R17, HIGH(FLYING_BACK_STRING<<1)
	CALL LCD_DISPLAY_STRING
	CALL WAIT_1S
	FLY_CTRL FAST_MOTOR_SPEED

	FLY_LEFT:
		CPI R20, 0						;FLY UNTIL REACH WEST BORDER
		BREQ FLY_NORTH
		LCD_CLEAR
		DEC R20
		SBIW Z, 1
		LPM R19, Z
		INC R19
		CALL LCD_DISPLAY_POS			;;DISPLAY POSITION
		MACRO_WAIT 80
		RJMP FLY_LEFT
	FLY_NORTH:
		CPI R21, 0						;FLY UNTIL REACH NORTH BORDER
		BREQ FLY_LANDING
		LCD_CLEAR
		DEC R21
		SBIW Z, 63
		LPM R19, Z
		INC R19
		CALL LCD_DISPLAY_POS			;DISPLAY POSITION
		MACRO_WAIT 80
		RJMP FLY_NORTH
	FLY_LANDING:
		LCD_CLEAR

	POP R16
	POP R17
	RET
;CURRENT POSITION: R20:R21 -> X:Y
;RETURN R23 AS SIGNAL IF R23 SET, THEN THE ACCIDENT POSITION IS FOUND
;ELSE IF R23 IS CLR, ACCIDENT POSITION IS NOT FOUND
DRONE_SEARCH:
	PUSH R16
	PUSH R17
	PUSH ZL
	PUSH ZH

	CLR R23
	FLY_CTRL HALF_MOTOR_SPEED	;SET MOTOR SPEED TO HALF
	LDI ZL, LOW(ACCIDENT)
	LDI ZH, HIGH(ACCIDENT)

	LD R16, Z+
	LD R17, Z

	CP R16, R20
	BRNE SEARCH_RETURN
	CP R17, R21
	BRNE SEARCH_RETURN
	SER R23
SEARCH_RETURN:
	POP ZH
	POP ZL
	POP R16
	POP R17
	RET

;SET ACCIDENT POSITION IN DESG, ACCIDENT(X,Y)
;WITH REGISTER R2 AS X, R3 AS Y
SET_LOCATION:
    PUSH ZL
    PUSH ZH

    LDI ZL, LOW(ACCIDENT)
    LDI ZH, HIGH(ACCIDENT)
    ST Z+, R2
    ST Z, R3

    POP ZH
    POP ZL
    RET

