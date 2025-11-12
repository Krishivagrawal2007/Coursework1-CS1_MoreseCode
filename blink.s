; led_on.s : switches on the Arduino Nano built-in LED (D13 / PORTB5)

;--------------------------------------
; Define registers
;--------------------------------------
.equ SREG  , 0x3F   ; Status Register
.equ DDRB  , 0x04   ; Data Direction Register for PORTB
.equ PORTB , 0x05   ; Output Register for PORTB
.equ LED   , 5      ; Pin 5 on PORTB = D13

;--------------------------------------
; Reset vector / start address
;--------------------------------------
.org 0x0000
rjmp main

;--------------------------------------
; Main program
;--------------------------------------
main:
    ; Clear SREG (disable interrupts)
    ldi r16, 0
    out SREG, r16

    ; Set LED pin as output
    ldi r16, (1 << LED)
    out DDRB, r16

    ; Turn LED on
    sbi PORTB, LED

mainloop:
    rjmp mainloop    ; infinite loop to keep program running
