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
; Data Segment
;---------------------------
.equ DIGITS, 0x0100    ; store digits of 25000843
.equ KA,   DIGITS + 8  ; store characters 'k' 'a'
.equ KRISH,   KA + 2   ; store characters 'k' 'r' 'i'

;---------------------------
; Code Segment
;---------------------------
.org 0x0000             ; Reset vector (program start)
rjmp main               ; Jump to main code

;|--------------------------------------------------|
;|                  Main Program                    |
;|--------------------------------------------------|
main:
    ; Clear SREG
    LDI r16, 0x00
    OUT SREG, r16

    LDI r16, 0x0F
    OUT DDRB, r16

    rcall task1
    rjmp main

;|--------------------------------------------------|
;|                   Help Methods                   |
;|--------------------------------------------------|

;|--------------------------
;|  Precise Delay
;|--------------------------
; 16MHz, takes value in r16 = factor (100 ≈ 1s)
; Uses r20, r21, r22 internally but restores original value before RETurning (via PUSH/POP)
; Delay Mechanism:
; - r20 = outer loop counter, set from r16
; - r21, r22 = middle and inner loop counters, 188 and 212 (Numbers chosen give good approx)
; Inner loop r22=212:    4 * 212 - 1 = 847 cycles
; Middle loop r21=188:   (847 + 1 + 1 + 2) * 188 - 1 = 159,987 cycles
; Outer loop:            (9 + 1 + 159,987 + 1 + 2) * 100 - 1 = 15,999,999 cycles (r20=r16=100 used as example for 1s delay)
; Final delay:           15,999,999 + (3 * 2) + 1 + (3* 2) + 4 = 16,000,016 cycles = ~1s
precise_delay:
    PUSH r20
    PUSH r21
    PUSH r22

    MOV r20, r16    ;Stores delay factor
outer_loop:
    NOP                 ; 9xNOP for precision
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP

    LDI r21, 188
middle_loop:
    LDI r22, 212
inner_loop:
    NOP
    DEC r22
    BRNE inner_loop

    DEC r21
    BRNE middle_loop

    DEC r20
    BRNE outer_loop

    POP r22
    POP r21
    POP r20

    RET
    
;|--------------------------------------------------|
;|                      TASKS                       |
;|--------------------------------------------------|

;|--------------------------
;|  TASK 1
;|--------------------------
; Displays k-number writing left-most numerical digit first (2500843: 0010-->0101-->0000-->0000-->0000-->1000-->0100-->0011)
; Each digit displayed for 1s
; No delay between digits, example, after 00010 for 1s will immediately display 0101 for 1s
task1:
    ;Load the digits of K-number seperately
    LDI r16, 2
    STS DIGITS+0, r16
    LDI r16, 5
    STS DIGITS+1, r16
    LDI r16, 0
    STS DIGITS+2, r16
    LDI r16, 0
    STS DIGITS+3, r16
    LDI r16, 0
    STS DIGITS+4, r16
    LDI r16, 8
    STS DIGITS+5, r16
    LDI r16, 4
    STS DIGITS+6, r16
    LDI r16, 3
    STS DIGITS+7, r16

    ; Loop through the digits and display each one at a time
    ; r30:r31 used as pointers
    LDI r30, lo8(DIGITS)
    LDI r31, hi8(DIGITS)

    LDI r17, 8              ; 8 digits in total

loopThroughDigits:
    LD r18, Z+             ; Load value at Z, this increments every loop
    
    ;Display
    OUT PORTB, r18
    
    ldi r16, 0x64         ;1sec delay with r16 = 100
    rcall precise_delay

    DEC r17
    BRNE loopThroughDigits  ; Repeats 8 times
    
    RET

;|--------------------------
;|  TASK 2
;|--------------------------
task2:
    RET

;|--------------------------
;|  TASK 3
;|--------------------------
task3:
    RET

;|--------------------------
;|  TASK 4
;|--------------------------
task4:
    RET
