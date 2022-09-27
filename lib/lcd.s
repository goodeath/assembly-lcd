@.include "gpiomem.s"
.equ MAP_SHARED, 0x01
.equ sys_read, 3
.equ sys_write, 4
.equ sys_open, 5
.equ sys_close, 6
.equ FLAG, 0x7
.equ pagelen, 4096



.global init
.global clear_display
.global writea



@ SetOutputPin
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


.macro pulse 
    TurnOn E
    nanosleep timespec0 timespec5 // 5 ms
    TurnOff E
     nanosleep timespec0 timespec5    // 5ms // 5ms   // 5ms // 5ms
.endm

.macro display_clear
    TurnOff RS
    write_4bit #0x0
    write_4bit #0x1
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
 


TurnOnp:
    PUSH {R1-R4}
    MOV R1, R0
    LDR R2, [R1,#8]

    LDR R3, =0b1
    LDR R4, [R1, #16]
    LSL R3, R4
    STR R3, [R8, R2]
    POP {R1-R4}
    BX LR


TurnOffp:
    PUSH {R1-R5}
    MOV R1, R0
    LDR R2, [R1,#12]

    LDR R3, =0b1

    MOV R5, R0
    LDR R5, [R5, #16]
    LSL R3, R5
    STR R3, [R8, R2]
    POP {R1-R5}
    BX LR


@ Change pin value
turn:
    PUSH {LR}
    CMP R1, #1
    BLGE TurnOnp
    BLLT TurnOffp
    POP {LR}
    BX LR



write_data_4bits:
    
    PUSH {R1, R2, LR}
    MOV R2, R0 @ Hex value to set D7-D4
    LDR R1, =0x8 @ Check fourth bit
    AND R1, R1, R2

    LDR R0, =DB7
    BL turn

    LDR R1, =0x4 @ Check fourth bit
    AND R1, R1, R2

    LDR R0, =DB6
    BL turn

    LDR R1, =0x2 @ Check fourth bit
    AND R1, R1, R2

    LDR R0, =DB5
    BL turn

    LDR R1, =0x1 @ Check fourth bit
    AND R1, R1, R2

    LDR R0, =DB4
    BL turn
    POP {R1, R2, LR}
   
    BX LR

.macro write_4bit value
    PUSH {LR}
    LDR R0, =\value
    BL write_data_4bits
    pulse
    POP {LR}
.endm
write_number:
    
    TurnOn RS
    write_4bit 0x3
    PUSH {LR}
        CMP R1, #10
        LDREQ R1, =0 @ BUG!! Inside remainder
        MOV R0, R1
        BL write_data_4bits
        pulse
    POP {LR}
    BX LR
@ Divide two numbers 
@ R0 Dividend
@ R1 Divisor
@ R2 Quocient
@ Return:
.syntax unified
writea:
    
    LDR R1, =5
    B write_number

.syntax unified
clear_display:
    display_clear

.syntax unified
init:
    open_file devmem
    MOVS R4, R0 @ fd for memmap
    map_memory
    MOV R8, R0 @ Address

    @ Set as out
    
    SetOutputPin E
    SetOutputPin pin6
    SetOutputPin DB4
    SetOutputPin DB5
    SetOutputPin DB6  
    SetOutputPin DB7
    SetOutputPin RS

    SetInputPin pin5
    SetInputPin pin19

    TurnOff RS
    TurnOff E
    
    @ Start   
    // Step 1
    @nanosleep timesz timenz
    
    write_4bit #0x3
    write_4bit #0x3
    write_4bit #0x3
    write_4bit #0x2
    write_4bit #0x2
    write_4bit #0x8
    write_4bit #0x0
    write_4bit #0x8

    nanosleep t1s timespecnano0 // 5ms
    nanosleep t1s timespecnano0 // 5ms
    .ltorg

    write_4bit #0x0
    write_4bit #0x1

    nanosleep ts0 tms10  // 5ms

    write_4bit #0x0
    write_4bit #0x6

    nanosleep ts0 tms10  // 5ms

    write_4bit #0x0
    write_4bit #0xF


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
@   0x8         GPIO Output Set offset
@   0xc         GPIO Output Clear offset
@   0x10        Shift quantity inside Set/Clear registers
@   0x14        GPIO Read Level Offset

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