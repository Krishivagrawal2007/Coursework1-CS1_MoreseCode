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
.equ KRI,   KA + 3   ; store characters morse code for 'k' 'r' 'i'/ 'i' 'r' 'k'

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

    ; Start task execution
    RCALL task4

    rjmp main   ; Loop forever

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
    ; Add to stack
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

    ; Remove from stack
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
    RCALL precise_delay

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
    RCALL precise_delay

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
    RCALL evenSequenceIRK
    RCALL task3DisplaySequence
    RJMP afterLoad

loadKRI:
    RCALL oddSequenceKRI
    RCALL task3DisplaySequence

afterLoad:
    INC r19
    CPI r19, 51
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
    RCALL displayFiveDots
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
    RCALL displayMorseCode

    DEC r17
    BRNE loopThroughSequence  ; Repeats

    RCALL checkDivBy5   ;Add 5 at the end if iteration is a multiple of 5

    ; Word KRI/IRK/5 has been written and so a gap for 6 units is displayed, 1200ms (1unit already taken when last dot/dash was called)
    LDI r16, 0x00
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x78
    RCALL precise_delay
   
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
    RCALL precise_delay

    ;LED's off for 200 ms
    LDI r16, 0x00
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x14
    RCALL precise_delay
    RET

; Dash turns ON LED for 3 units and OFF for 1 unit
dash:
    ;LED's on for 600ms
    LDI r16, 0xFF
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x3C
    RCALL precise_delay
   
    ;LED's off for 200 ms
    LDI r16, 0x00
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x14
    RCALL precise_delay
    RET

; letterGap turns OFF LED for 2 units only, gap between letters of the same word
letterGap:
    ;LED's off for 2 units, 400ms (1 unit already done when dot/dash is called)
    LDI r16, 0x00
    OUT PORTB, r16
    OUT PORTD, r16
    LDI r16, 0x28
    RCALL precise_delay
    RET

;|--------------------------
;|  TASK 4
;|--------------------------
; Implements ping-pong LED movement across the 8-bit output.
; Movement begins at 10000000 and shifts right until 00000001,
; then shifts left again. This repeats indefinitely.
;
; Special moves:
;  - Every 5 hits a special move is executed (controlled by r20).
;         Smash
;  - WHENEVER any special move completes, SCORE (r23) is incremented
;    and displayed by blinking the full 8-bit pattern 3 times
;    (200 ms ON, 200 ms OFF). Score is kept in register r23.
;
; Registers used locally in this task:
;  r17 = current LED bit position
;  r18 = delay factor (speed)
;  r19 = speed direction flag (0 = accelerate/increase delay, 1 = decelerate/decrease delay)
;  r20 = special move countdown / temporary blink counter
;  r23 = SCORE
;  r16, r18 are used as scratch for precise_delay (precise_delay expects r16)
task4:
    ; Initialise ping-pong state
    LDI r17, 0x80      ; r17 = LED position (1000 0000)
    RCALL resetPingPongLoop
    LDI r23, 0         ; r23 = SCORE stored in register (start at 1)

pingPongLoopRight:
    RCALL displayPingPong
    CPI r17, 0x01           ; reached right end?
    BREQ updateSpeedRight
    LSR r17                 ; shift right
    RJMP pingPongLoopRight

pingPongLoopLeft:
    RCALL displayPingPong
    CPI r17, 0x80           ; reached left end?
    BREQ updateSpeedLeft
    LSL r17                 ; shift left
    RJMP pingPongLoopLeft

;------------------------------------------------------
; Display one frame of the ping-pong LED motion using
; current position in r17 and speed delay in r18.
;------------------------------------------------------
displayPingPong:
    OUT PORTB, r17
    OUT PORTD, r17
    MOV r16, r18
    RCALL precise_delay
    RET

;------------------------------------------------------
; Reached left boundary: decrement special counter and
; either handle special move or update speed and reverse.
;------------------------------------------------------
updateSpeedLeft:
    DEC r20
    BREQ handleSpecialMoveLeft
    RCALL handleSpeed
    RJMP pingPongLoopRight

;------------------------------------------------------
; Reached right boundary: decrement special counter and
; either handle special move or update speed and reverse.
;------------------------------------------------------
updateSpeedRight:
    DEC r20
    BREQ handleSpecialMoveRight
    RCALL handleSpeed
    RJMP pingPongLoopLeft

;------------------------------------------------------
; Checkontrol helpers
;------------------------------------------------------
resetPingPongLoop:
    LDI r18, 0x0A      ; r18 = speed (delay factor)
    LDI r19, 0         ; r19 = speed mode (0 = accelerate)
    LDI r20, 10        ; r20 = special move counter (every 5 hits)
    RET

resetScore:
    LDI r23, 0
    RET

handleSpeed:
    CPI r18, 1
    BREQ setDecelerate
    CPI r18, 0x0A
    BREQ setAccelerate
    RCALL handlePingPongSpeed
    RET

setDecelerate:
    LDI r19, 0
    RCALL handlePingPongSpeed
    RET

setAccelerate:
    LDI r19, 1
    RCALL handlePingPongSpeed
    RET

handlePingPongSpeed:
    CPI r19, 0
    BREQ incSpeed
    DEC r18
    RET

incSpeed:
    INC r18
    RET

;------------------------------------------------------
; Special-move dispatchers
; reset r20 to 5 (countdown), branch to smash
;------------------------------------------------------
handleSpecialMoveLeft:
    ; brief pre-burst delay
    LDI r16, 0x1E
    RCALL precise_delay
    RJMP smashLeft

handleSpecialMoveRight:
    ; brief pre-burst delay
    LDI r16, 0x1E
    RCALL precise_delay
    RJMP smashRight

;------------------------------------------------------
; Smash Left:
;  - quick burst (fast movement) shifting right until 0x01
;  - uses r18 = 1 for very small delay (fast)
;  - upon completion: increment score (r23), blink score,
;    toggle r21, and resume ping-pong (moving left->right)
;------------------------------------------------------
smashLeft:
    ; perform fast shifts to the right until we reach 0x01
    LSR r17
    LDI r18, 1          ; make movement very fast
    RCALL displayPingPong
    CPI r17, 0x01
    BRNE smashLeft

    ; Special move completed -> score & blink
    INC r23             ; r23 = r23 + 1
    CPI r23, 255
    BREQ resetScore

    RCALL display_score_blink3
    LDI r17, 0x01
    RCALL resetPingPongLoop
    RJMP pingPongLoopLeft

;------------------------------------------------------
; Smash Right:
;  - quick burst shifting left until 0x80
;  - upon completion: increment score, blink score,
;    toggle r21, and resume ping-pong (moving right->left)
;------------------------------------------------------
smashRight:
    ; perform fast shifts to the left until we reach 0x80
    LSL r17
    LDI r18, 1
    RCALL displayPingPong
    CPI r17, 0x80
    BRNE smashRight

    ; Special move completed -> score & blink
    INC r23
    CPI r23, 255
    BREQ resetScore
    
    RCALL display_score_blink3
    LDI r17, 0x80
    RCALL resetPingPongLoop
    RJMP pingPongLoopRight

;======================================================
; display_score_blink3
; Displays r23 on LEDs and blinks 3 times (200 ms ON / 200 ms OFF)
; Uses r22 as blink counter and r16/r18 temporarily for delays.
;======================================================
display_score_blink3:
    LDI r22, 3          ; blink counter = 3

blink3_loop:
    ; ON 200ms
    OUT PORTB, r23
    OUT PORTD, r23
    LDI r16, 0x14
    RCALL precise_delay

    ; OFF 200ms
    LDI r24, 0x00
    OUT PORTB, r24
    OUT PORTD, r24
    LDI r16, 0x14
    RCALL precise_delay

    DEC r22
    BRNE blink3_loop
    RET
