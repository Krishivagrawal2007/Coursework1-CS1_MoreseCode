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
.equ PORTD  ,  0x0A    ;Output Register for PORTD
.equ DDRB   ,  0x04    ;Data Direction Register for PORTB
.equ DDRD   ,  0x0B    ;Data Direction Register for PORTD

;---------------------------
; Data Segment
;---------------------------
.equ DIGITS, 0x0100    ; store digits of 25000843
.equ KA,   DIGITS + 8  ; store characters 'k' '.' 'a' = '11' '27' '1'
.equ KRI,   KA + 3   ; store characters morse code for 'k' 'r' 'i'

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

    ; Put first 4 bits of PORTB in output mode
    LDI r16, 0x0F
    OUT DDRB, r16

    ; Put most significant 4 bits of POTD in output mode
    LDI r16, 0xF0
    OUT DDRD, r16

    rcall task1
    rcall task2
    rcall task3
    rcall task4
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
; Used Ai to compute the values in r21 and r22 and number of NOP statements used for a much better approximate of delay
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
    OUT PORTD, r18
    
    ldi r16, 0x64         ;1sec delay with r16 = 100
    rcall precise_delay

    DEC r17
    BRNE loopThroughDigits  ; Repeats 8 times
    
    RET

;|--------------------------
;|  TASK 2
;|--------------------------
; Displays K.A writing left-most numerical letter first (K.A: 11 --> 27 --> 1 = 00001011 --> 00011011 --> 00000001)
; Each letter displayed for 1s
; No delay between letters, example, after 00001011 for 1s will immediately display 00011011 for 1s
task2:
    ;Load the digits of K-number seperately
    LDI r16, 11
    STS KA+0, r16
    LDI r16, 27
    STS KA+1, r16
    LDI r16, 1
    STS KA+2, r16

    ; Loop through the letters and display each one at a time
    ; r30:r31 used as pointers
    LDI r30, lo8(KA)
    LDI r31, hi8(KA)

    LDI r17, 3              ; 8 digits in total

loopThroughInitials:
    LD r18, Z+             ; Load value at Z, this increments every loop
    
    ;Display
    OUT PORTB, r18
    OUT PORTD, r18
    
    ldi r16, 0x64         ;1sec delay with r16 = 100
    rcall precise_delay

    DEC r17
    BRNE loopThroughInitials  ; Repeats 3 times
    
    RET

;|--------------------------
;|  TASK 3
;|--------------------------
; Loads in the morse code sequence to be displayed (hardcoded)
; Loops through the sequence and displays the dots, dashes and gaps
; Represents KRI, which is given by - . -   . - .   . .       , represented in code by 2,1,2,0,1,2,1,0,1,1
; Represents IRK, which is given by . .   . - .   - . -       , represented in code by 1,1,0,1,2,1,0,2,1,2
; 0 --> Gap between letters (400ms), 1 --> Dot (200ms on, 200ms off), 2 --> dash (600ms on, 200ms off)
; Iterates 50 times.
; Odd iteration --> display KRI
; Even iteration --> display IRK
task3:
    LDI r19, 1        ; loop counter

iterate50Times:
    ; Check odd/even
    MOV r20, r19       ; copy loop counter
    ANDI r20, 1        ; r20 = r19 & 1  (1=odd, 0=even)

    CPI r20, 1
    BREQ loadKRI       ; if odd → branch to KRI

; Loading is done as follows:
;       -Sequence stored in memory
;       -Loops through sequence and displays each part of the sequnce until end
loadIRK:
    rcall evenSequenceIRK
    rcall task3DisplaySequence
    RJMP afterLoad

loadKRI:
    rcall oddSequenceKRI
    rcall task3DisplaySequence

afterLoad:
    INC r19
    CPI r19, 11
    BRNE iterate50Times ;Continue iteration
    RET

; Repeatedly subtract 5 until number < 5, and check if remainder is 0 (=0 : divisible by 5, !=0 : not divisible by 5)
checkDivBy5:
    MOV r21, r19
div5_loop:
    CPI r21, 5
    BRLO notDivBy5
    SUBI r21, 5
    RJMP div5_loop
notDivBy5:
    CPI r21, 0
    BREQ display5
    RET
display5:
    rcall displayFiveDots
    RET
displayFiveDots:
    LDI r22, 5          ; counter for five dots
disp5_loop:
    RCALL dot
    DEC r22
    BRNE disp5_loop
    RET

task3DisplaySequence:
    ; Loop through the sequence and display each one at a time
    ; r30:r31 used as pointers
    LDI r30, lo8(KRI)
    LDI r31, hi8(KRI)

    LDI r17, 10              ; 10 in total

loopThroughSequence:
    LD r18, Z+             ; Load value at Z, this increments every loop
    
    ;Display
    rcall displayMorseCode

    DEC r17
    BRNE loopThroughSequence  ; Repeats

    rcall checkDivBy5   ;Add 5 at the end if iteration is a multiple of 5

    ; Word KRI/IRK/5 has been written and so a gap for 6 units is displayed, 1200ms (1unit already taken when last dot/dash was called) 
    LDI r16, 0x00
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x78
    rcall precise_delay
    
    RET

oddSequenceKRI:
    LDI r16, 2
    STS KRI+0, r16
    LDI r16, 1
    STS KRI+1, r16
    LDI r16, 2
    STS KRI+2, r16
    LDI r16, 0
    STS KRI+3, r16
    LDI r16, 1
    STS KRI+4, r16
    LDI r16, 2
    STS KRI+5, r16
    LDI r16, 1
    STS KRI+6, r16
    LDI r16, 0
    STS KRI+7, r16
    LDI r16, 1
    STS KRI+8, r16
    LDI r16, 1
    STS KRI+9, r16
    RET

evenSequenceIRK:
    LDI r16, 1
    STS KRI+0, r16
    LDI r16, 1
    STS KRI+1, r16
    LDI r16, 0
    STS KRI+2, r16
    LDI r16, 1
    STS KRI+3, r16
    LDI r16, 2
    STS KRI+4, r16
    LDI r16, 1
    STS KRI+5, r16
    LDI r16, 0
    STS KRI+6, r16
    LDI r16, 2
    STS KRI+7, r16
    LDI r16, 1
    STS KRI+8, r16
    LDI r16, 2
    STS KRI+9, r16
    RET

# Compares current value being proccesed to check if it is a dot, dash or a gap between letters of same word
displayMorseCode:
    CPI r18, 0
    BREQ letterGap

    CPI r18, 1
    BREQ dot

    CPI r18, 2
    BREQ dash

    RET

; Dot turns ON LED for 1 unit then turns off for 1 unit
dot:
    ;LED's on for 200ms
    LDI r16, 0xFF
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x14
    rcall precise_delay

    ;LED's off for 200 ms
    LDI r16, 0x00
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x14
    rcall precise_delay
    RET

; Dash turns ON LED for 3 units and OFF for 1 unit
dash:
    ;LED's on for 600ms
    LDI r16, 0xFF
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x3C
    rcall precise_delay
    
    ;LED's off for 200 ms
    LDI r16, 0x00
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x14
    rcall precise_delay
    RET

; letterGap turns OFF LED for 2 units only, gap between letters of the same word
letterGap:
    ;LED's off for 2 units, 400ms (1 unit already done when dot/dash is called)
    LDI r16, 0x00
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x28
    rcall precise_delay
    RET

;|--------------------------
;|  TASK 4
;|--------------------------
; Start at 10000000 and then using LSR the bit is shifted right giving 01000000
; Repeat till you reach 00000001 and then start doing LSL to shift bit left resulting in 00000010
; The process repeats till 10000000 and then it resets and loops forever
task4:
    LDI r17, 0x80

pingPongLoopRight:
    rcall displayPingPong
    LSR r17
    CPI r17, 0x01           ; 00000001
    BREQ pingPongLoopLeft
    rjmp pingPongLoopRight
    
pingPongLoopLeft:
    rcall displayPingPong
    LSL r17
    CPI r17, 0x80           ; 10000000
    BREQ pingPongLoopRight
    rjmp pingPongLoopLeft

displayPingPong:
    OUT PORTB, r17
    OUT PORTD, r17
    LDI r16, 0x14
    rcall precise_delay
    RET


