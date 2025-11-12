;|==================================================|
;|*               CS1 - KCL - Year 1               *|
;|*           4CCS1CS1 Computer Systems            *|
;|*                 Coursework 1                   *|
;|*     Property off: Krishiv Agrawal              *|
;|*     Student ID: K25000843                      *|
;|*     Weighting: 15% of Final Module Grade       *|
;|==================================================|   


;|--------------------------------------------------|
;|                Define Registers                  |
;|--------------------------------------------------|
.equ SREG   ,  0x3f    ;Status Register
.equ PORTB  ,  0x05    ;Output Register for PORTB
.equ DDRB   ,  0x04    ;Data Direction Register for PORTB

;---------------------------
; Data Segment (.dseg)
;---------------------------
.dseg
DIGITS: .byte 8         ; store digits of 25000843
KA:     .byte 2         ; store characters 'k' 'a'
KRISH:  .byte 5         ; store characters 'k' 'r' 'i'

;---------------------------
; Code Segment (.cseg)
;---------------------------
.cseg
.org 0x0000             ; Reset vector (program start)
rjmp main               ; Jump to main code

;|--------------------------------------------------|
;|                  Main Program                    |
;|--------------------------------------------------|
main:
    ; Clear SREG
    ldi r16, 0
    out SREG, r16


    rcall task1

;|--------------------------------------------------|
;|                   Help Methods                   |
;|--------------------------------------------------|

;|--------------------------
;|  Precise Delay
;|--------------------------
; 16MHz, takes value in r16 = factor (100 ≈ 1s)
; Uses r20, r21, r22 internally but restores original value before returning (via push/pop)
; Delay Mechanism:
; - r20 = outer loop counter, set from r16
; - r21, r22 = middle and inner loop counters, 188 and 212 (Numbers chosen give good approx)
; Inner loop r22=212:    4 * 212 - 1 = 847 cycles
; Middle loop r21=188:   (847 + 1 + 1 + 2) * 188 - 1 = 159,987 cycles
; Outer loop:            (9 + 1 + 159,987 + 1 + 2) * 100 - 1 = 15,999,999 cycles (r20=r16=100 used as example for 1s delay)
; Final delay:           15,999,999 + (3 * 2) + 1 + (3* 2) + 4 = 16,000,016 cycles = ~1s
precise_delay:
    push r20
    push r21
    push r22

    mov r20, r16    ;Stores delay factor
outer_loop:
    nop                 ; 9xnop for precision
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    
    ldi r21, 188
middle_loop:
    ldi r22, 212
inner_loop:
    nop
    dec r22
    brne inner_loop

    dec r21
    brne middle_loop

    dec r20
    brne outer_loop

    pop r22
    pop r21
    pop r20

    ret


    
;|--------------------------------------------------|
;|                      TASKS                       |
;|--------------------------------------------------|
; Displays k-number writing left-most numerical digit first
; Each digit displayed for 1s
; No delay between digits, example, after 00010 for 1s will immediately display 0101 for 1s
task1:

    ret
task2:
    ret
task3:
    ret
task4:
    ret
