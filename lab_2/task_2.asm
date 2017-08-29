;lab_2 task 2
;create by ShaoHui z5155945
;
.def one = r21
.dseg
number:    .byte 2

.cseg
rjmp main
s:    .db "12345", 0

.macro mul_10
    mul r19, r17
    cp r1, r21
    brsh done
    mov r19, r0
    mul r18, r17
    mov r18, r0
    add r19, r1
.endmacro
main:
    ldi ZH, high(s<<1)  ;set z as the addr to char[s]
    ldi ZL, low(s<<1)   ;
    rcall atoi
end:
	rjmp end

atoi:
    ;prologue
                ;r29:r28 will be used as the frame pointer
    push YL     ;Save Y in the stack
    push YH
    push ZL
    push ZH
    push r16    ;save registers used in the function body
    push r17
    push r18
    push r19
    push r20
	push r21
    push r0
    push r1
    in YL,SPL   ;initialize the stack frame pointer value
    in YH,SPH
    sbiw Y,4    ;reserve space for local variables(zl,zh)
    out SPH, YH ;update the stack pointer to point to the new
    out SPL, YL ;stack top
    ;pass the actual parameters
    std Y+1, ZL
    std Y+2, ZH
    ;prologue end
    ;function body
	ldi r21, 1
    clr ZH
    clr ZL
    clr r16
    clr r20        ;r20 as 0
    ldi r17, 10     ;r17 as 10
    clr r18     ;n_lo
    clr r19     ;n_hi
    ;clear lots of things
    ldd ZH, Y+2
    ldd ZL, Y+1
loop:
    lpm r16, Z+         ;load char c into r19
    cpi r16, 0x3A       ;if c > '9'
    brsh done           ;
    cpi r16, 0x30       ;if c < '0'
    brlo done           ;
    mul_10              ;multiply n with 10 if n*10 > 65535 goto done
    subi r16, 0x30       ;c = c - '0'
    add r18, r16        ;n = n + c
    adc r19, r20        ;
    rjmp loop           ;

done:
    ldi ZH, high(number);store number into data
    ldi ZL, low(number)
    st Z+, r18
    st Z+, r19
    adiw Y,4                ;prologue
    out SPH, YH
    out SPL, YL
    pop r1
    pop r0
	pop r21
    pop r20
    pop r19
    pop r18
    pop r17
    pop r16
	pop ZH
	pop ZL
    pop YH
    pop YL
    ret

