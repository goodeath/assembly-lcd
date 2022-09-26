@.include "gpiomem.s"
.equ PROT_READ, 0x1
.equ PROT_WRITE, 0x2
.equ MAP_SHARED, 0x01
.equ PROT_RDWR, PROT_READ|PROT_WRITE
.equ sys_read, 3
.equ sys_write, 4
.equ sys_open, 5
.equ sys_close, 6
.equ sys_fsync, 118
.equ FLAG, 0x7
.equ pagelen, 4096
.equ GPIO_OFFSET, 0x200000
.equ PERIPH, 0x20000000
.global _start @ Provide program starting

.macro SetOutputPin pin

    LDR R2, =\pin
    LDR R2, [R2]
    LDR R1, [R8, R2] @ Address value 0-9 gpio pins

    LDR R3, =\pin
    LDR R3, [R3, #4] @ N*3 Shifts
    MOV R2, R3 

    LDR R3, =3 
    MUL R5, R2, R3 @ Pin offset * 3 bit multiply to reach point
    @ binary operations to set mask
    LDR R2, =0xFFFFFFFF @ Mask
    LDR R3, =0b111
    LSL R3, R5
    EOR R2, R2, R3
    AND R1, R1, R2

    LDR R3, =0b001  @ Set as output
    LSL R3, R5
    ORR R1, R1, R3
    LDR R2, =\pin
    LDR R2, [R2]
    STR R1, [R8, R2]
.endm

.macro TurnOn pin
    PUSH {R1-R4}
    LDR R1, =\pin
    LDR R2, [R1,#8]

    LDR R3, =0b1
    LDR R4, [R1, #16]
    LSL R3, R4
    STR R3, [R8, R2]
    POP {R1-R4}
.endm

.macro TurnOff pin
    PUSH {R1-R5}
    LDR R1, =\pin
    LDR R2, [R1,#12]

    LDR R3, =0b1

    LDR R5, =\pin
    LDR R5, [R5, #16]
    LSL R3, R5
    STR R3, [R8, R2]
    POP {R1-R5}
.endm

.macro nanosleep seconds nano
    PUSH {R0-R6}
    ldr r0, =\seconds
    ldr r1, =\nano
    mov r7, #162
    svc 0
    POP {R0-R6}
.endm

.macro open_file file
    LDR R0, =\file
    LDR R1, =mode
    LDR R1, [R1]
    MOV R7, #sys_open
    SVC 0
.endm

@ Access 0x20200 Address
.macro map_memory
    LDR R0, =0
    LDR R1, =#pagelen
    LDR R2, =#FLAG
    LDR R3, =#MAP_SHARED
    LDR R5, =gpio_base_addr
    LDR R5, [R5]
    LDR R7, =192
    SVC 0
.endm

.macro reset
    TurnOff E
    TurnOff DB4
    TurnOff DB5
    TurnOff DB6
    TurnOff DB7
    TurnOff RS
.endm

.macro set
    TurnOn E
    TurnOn DB4
    TurnOn DB5
    TurnOn DB6
    TurnOn DB7
    TurnOn RS
.endm

.macro pulse 
    TurnOn E
    nanosleep timespec0 timespec5 // 5 ms
    TurnOff E
     nanosleep timespec0 timespec5    // 5ms // 5ms   // 5ms // 5ms
.endm

.macro display_clear
    TurnOff RS
    reset
    pulse
    TurnOn DB4
    pulse
.endm

.macro SetInputPin pin

    LDR R2, =\pin
    LDR R2, [R2]
    LDR R1, [R8, R2] @ Address value 0-9 gpio pins

    LDR R3, =\pin
    LDR R3, [R3, #4] @ N*3 Shifts
    MOV R2, R3 

    LDR R3, =3 
    MUL R5, R2, R3 @ Pin offset * 3 bit multiply to reach point
    @ binary operations to set mask
    LDR R2, =0xFFFFFFFF @ Mask
    LDR R3, =0b111
    LSL R3, R5
    EOR R2, R2, R3
    AND R1, R1, R2

    @LDR R3, =0b000  @ Set as output
    @LSL R3, R5
    @ORR R1, R1, R3
    LDR R2, =\pin
    LDR R2, [R2]
    STR R1, [R8, R2]
.endm
 

.macro ReadPin pin
    PUSH {R1-R4}
    LDR R1, =\pin
    LDR R2, [R1, #0x14]
    LDR R2, [R8, R2] @ Address value 0-9 gpio pins
    LDR R4, [R1,#0x10] // Shift n times
    LSR R2, R4
    LDR R3, =0b1
    AND R0, R3, R2
    POP {R1-R4}
.endm


write_number:
    reset
    TurnOn RS
    TurnOn DB5
    TurnOn DB4
    pulse
    @CMP R1, #0
    @BEQ 1f
    CMP R1, #1
    BEQ 2f
    CMP R1, #2
    BEQ 3f
    CMP R1, #3
    BEQ 4f
    CMP R1, #4
    BEQ 5f
    CMP R1, #5
    BEQ 6f
    CMP R1, #6
    BEQ 7f
    CMP R1, #7
    BEQ 8f
    CMP R1, #8
    BEQ 9f
    CMP R1, #9
    BEQ 10f

    B 1f
1:
    reset
    .ltorg
    TurnOn RS
    pulse
    BX LR
2:
    reset
    TurnOn RS
    TurnOn DB4
    pulse
    BX LR
3:
    reset
    TurnOn RS
    TurnOn DB5
    pulse
    BX LR
4:
    reset
    TurnOn RS
    TurnOn DB4
    TurnOn DB5
    pulse
    BX LR
5:
    reset
    TurnOn RS
    TurnOn DB6
    pulse
    BX LR
6:
    reset
    TurnOn RS
    TurnOn DB6
    TurnOn DB4
    pulse
    BX LR
7:
    reset
    TurnOn RS
    TurnOn DB6
    TurnOn DB5
    pulse
    BX LR
8:
    reset
    TurnOn RS
    TurnOn DB6
    TurnOn DB5
    TurnOn DB4
    pulse
    BX LR
9:
    reset
    TurnOn RS
    TurnOn DB7
    pulse
    BX LR
10:
    reset
    TurnOn RS
    TurnOn DB7
    TurnOn DB4
    pulse
    BX LR
_start:
   

    open_file devmem
    .ltorg
    MOVS R4, R0 @ fd for memmap
    map_memory
    .ltorg
    MOV R8, R0 @ Address

    @ Set as out
    
    .ltorg
    SetOutputPin E
    .ltorg
    SetOutputPin pin6
    .ltorg
    SetOutputPin DB4
    .ltorg
    SetOutputPin DB5
    .ltorg
    SetOutputPin DB6  
    .ltorg
    SetOutputPin DB7
    .ltorg
    SetOutputPin RS
    .ltorg

    SetInputPin pin5
    SetInputPin pin19

   
    reset
    @ Start   
    // Step 1
    @nanosleep timesz timenz
    
   
    // Step 2
    TurnOn DB4
    TurnOn DB5
    pulse
    
    .ltorg
    
    // Step 3
    TurnOn DB4
    TurnOn DB5
    pulse
    .ltorg

    // Step 4
    TurnOn DB4
    TurnOn DB5
    pulse
    .ltorg
    
    // Step 5
    reset
    TurnOn DB5
    pulse

    // Step 6
    reset
    TurnOn DB5
    pulse
    .ltorg
    reset
    TurnOn DB7
    pulse
    .ltorg
    // Works beefore here


    // Step 7
    reset
    .ltorg
    pulse
    .ltorg
   
    TurnOn DB7
    .ltorg
    pulse
    .ltorg
   
    nanosleep t1s timespecnano0 // 5ms
    .ltorg
    nanosleep t1s timespecnano0 // 5ms
    .ltorg

    // Step  8
    reset
    .ltorg
    pulse
    .ltorg
    TurnOn DB4
    pulse
    nanosleep ts0 tms10  // 5ms

    // Step 9
    reset
    pulse
    TurnOn DB6
    TurnOn DB5
    pulse
    nanosleep ts0 tms10  // 5ms

    // Step 11
    reset
    pulse
    TurnOn DB4
    TurnOn DB5
    TurnOn DB6
    TurnOn DB7
    pulse
    

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
    LDR R1, =9
    display_clear
    BL write_number
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
    

    @ Checks if counter needs to be paused
    BL pause_counter
    CMP R6, #1
    BEQ system_run
    @ Check if counter needs to be reseted
    BL reset_counter
    CMP R5, #1
    BEQ system_init

    nanosleep t1s timespecnano00
    SUB R1, #1
    CMP R1, #0
    BEQ _end
    display_clear
    BL write_number
    
    B system_run


_end:
    display_clear
    BL write_number
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate


.data
ts0: .word 0
tms10: .word 10000000
times: .word 0
timen: .word 500000
timesz: .word 0
timenz: .word 100000000
t10: .word 0
@ Raspberry Pi Zero Base Address - 0x20200000 / 0x1000  = 0x20200 Page quantity  
tns10: .word 900000000
gpio_base_addr: .word 0x3F200 
@gpio_base_addr: .word 0x20200 

@@@ Pin Definitions @@@

@ Pin Pattern:  
@ Array offset              Description
@   0x0         GPIO Select offset 
@   0x4         3-Shift quantity to set ON/OFF used inside GPIO Output SET/CLEAR
@   0x8         GPIO Output Set
@   0xc         GPIO Output Clear

@ E - Enable display
E:   .word 0x0 
        .word 1
        .word 0x1c
        .word 0x28
        .word 0x1
@ Only for test purpose
pin5:   .word 0x0
        .word 5
        .word 0x1c
        .word 0x28
        .word 0x5
        .word 0x34
pin19:   .word 0x4
        .word 9
        .word 0x1c
        .word 0x28
        .word 0x13
        .word 0x34  
pin6:   .word 0x0
        .word 6 
        .word 0x1c 
        .word 0x28
        .word 0x6
@ D4    pin 12
DB4:  .word 0x4 
        .word 2
        .word 0x1c
        .word 0x28
        .word 0xc
@ D5 pin 16
DB5:  .word 0x4 
        .word 6
        .word 0x1c
        .word 0x28
        .word 0x10
@ D6 pin 20
DB6:  .word 0x8 
        .word 0
        .word 0x1c
        .word 0x28
        .word 0x14
@ D7 - pin21
DB7:  .word 0x8 
        .word 1
        .word 0x1c
        .word 0x28
        .word 0x15
@ RS
RS:  .word 0x8 
        .word 5
        .word 0x1c
        .word 0x28
        .word 0x19


t1s: .word 1
s100: .word 500000000
ms100: .word 100000000
us100: .word 60000
timespec100: .word 100000000
timespec1: .word 1000000
timespec0: .word 0
timespec5: .word 5000000  
timespecnano0: .word 0
timespecnano45: .word 50000
timespecnano00: .word 0
timespecnano_1: .word 1000
mask: .word 0xFFFFFFFF
mode: .word 2
timespec1ms: .word 1000000
@timespecnano: .word 5000000 @1000000     1
@timespecnanomc: .word 3000 @1000000     1
devmem: .asciz "/dev/mem"
@memOpnErr: .asciz "Failed to open /dev/mem\n"
@memOpnsz: .word .-memOpnErr
@memMapErr: .asciz "Failed to map memory\n"
@memMapsz: .word .-memMapErr
.align 4 @ realign after strings
@ mem address of gpio register / 4096



@0x20200000 GPFSEL0 GPIO Function Select 0
@0x2020001c GPIO Pin Output Clear 0 
@0x20200028 GPIO Pin Output Set 0 