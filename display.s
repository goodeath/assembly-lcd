.include "lib/lcd.s"

.global main @ Provide program starting
.section .text
@ Divide two numbers 
@ R0 Dividend
@ R1 Divisor
@ R2 Quocient
@ Return:
@ R0 is quocient
divide:
    PUSH {R1-R2}
    LDR R2, =0
    CMP R0, R1
    LDRLT R0, =0
    BLT 2f
    B 1f
1:
    SUB R0, R1
    ADD R2, #1
    CMP R0, R1
    BGE 1b
    MOV R0, R2
    B 2f
2:
    POP {R1-R2}
    BX LR

remainder:
    PUSH {R1}
    CMP R0, R1
    @MOVLT R0, R1
    BLE 2f
    B 1f
1:
    SUB R0, R1
    CMP R0, R1
    BGT 1b
    B 2f
2:
    POP {R1}
    BX LR


    
main:
    BL init
    LDR R2, =1
    B system_init

@ This shit will ruin if not put in stack
@ R1 - Counter
@ R2 - Flag - Need for debounce button
@ R5 - Reset (0/1)
@ R6 - Pause/Start (0/1)

@ 0 - Active State
@ 1 - Inactive State
@ Reset Counter
@ Logic to reset counter
@ R2 - Last read value from R4
@ R4 - Last value read from reset button
@ R5 - Current reset state
reset_counter:
    LDR R5, =0x0 @ Reset should be executed only once. 
    @ Use R1 for Pause/Start Debounce, reading R4 before value
    MOV R2, R4
    @ Read pause button value
    ReadPin pin19
    MOV R4, R0
    CMP R4, R2
    BNE 1f
    BX LR
1:
    CMP R4, #1
    BXEQ LR
    LDR R5, =0x1
    BX LR


@ Pause Counter 
@ Logic to make the button toggle. Press one time, it goes from 0 to 1 and vice versa
@ R2 - Last read value from R3 
@ R3 - Last value read from pause button
@ R6 - Current pause/start state 
pause_counter:
    @ Use R1 for Pause/Start Debounce, reading R4 before value
    MOV R2, R3
    nanosleep timespec0 timespec5 // 5 ms
    
    @ Read pause button value
    ReadPin pin5
    MOV R3, R0
    CMP R3, R2
    BNE 1f
    BX LR
1:
    CMP R3, #1
    BXEQ LR
    
    CMP R6,#1
    LDREQ R6, =0
    LDRNE R6, =1
    BX LR

system_init:
    @ Initial value
    LDR R1, =90
   
    display_clear
    @BL write_number
    PUSH { R1  }
    MOV R0, R1
    LDR R1, =0xA
    BL divide
    MOV R1, R0
    BL write_number
    POP {R1}

    PUSH { R1  }
    MOV R0, R1
    LDR R1, =0xA
    BL remainder
    MOV R1, R0
    BL write_number
    POP {R1}

    B 1f
1:
    @ Checks if counter needs to be paused
    BL pause_counter
    CMP R6, #1
    BEQ 1b
    @ Check if counter needs to be reseted
    BL reset_counter
    CMP R5, #1
    BEQ system_init    

    B system_run

system_run:
    
    @ Check if counter needs to be reseted
    BL reset_counter
    CMP R5, #1
    BEQ system_init
    @ Checks if counter needs to be paused
    BL pause_counter
    CMP R6, #1
    BEQ system_run
    

    nanosleep t1s timespecnano00
    SUB R1, #1
    CMP R1, #-1
    BEQ _end
    display_clear
    @BL write_number
    PUSH { R1  }
    MOV R0, R1
    LDR R1, =0xA
    BL divide
    MOV R1, R0
    BL write_number
    POP {R1}

    PUSH { R1  }
    MOV R0, R1
    LDR R1, =0xA
    BL remainder
    MOV R1, R0
    BL write_number
    POP {R1}
    
    
    B system_run


_end:
    @display_clear
    @BL write_number
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate



.data

times: .word 0
timen: .word 500000
timesz: .word 0
timenz: .word 100000000

timespecnano00: .word 0

