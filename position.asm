.set pwm_counter_compare = OCR2A
.equ border_width = 64
.equ border_lenth = 64
;Z pointing to the last position, r18 direction
fly_to_next_pos:    ;r16-> row, r17-> col, r18 -> direction
                    ;Z point to last position
                    ;new_height -> r23, return as
    sbc r18, 0      ;r18 -> set as fly right, clear as fly left
    rjmp go_left
    cpi r17, border_width
    breq go_down
    adiw Z, 1
    subi r17, -1

    check_height:
        lpm r23, Z
        ret

    go_ends:
        ldi r23, -1
        ret

    go_left:
        cpi r17, 0
        breq go_down
        sbiw Z, 1
        subi r17, 1
        rjmp check_height
    
    go_down:
        cpi r16, border_lenth
        breq fly_ends
        adiw, Z, border_width   ;next row
        com r18                 ;different direction
        subi r16, -1            ;set r16, next row

fly_high:
    push r16

    ser r16
    sts OCR2A, r16

    pop r16
    ret

fly_suspending:
    push r16

    ldi r16, 120
    sts OCR2A, r17

    pop r16
    ret

fly_stop:
    push r16

    clr r16
    sts pwm_counter_compare, r16

    pop r16
    set
