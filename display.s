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

/*
timespec100
 */

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

.macro TurnOnPin pin
    LDR R1, =\pin
    LDR R2, [R1,#8]
    LDR R1, [R8, R2] @ Address value 0-9 gpio pin out set

    LDR R3, =0b1
    
    LDR R5, =\pin
    LDR R5, [R5, #4]

    LSL R3, R5
    ORR R1, R1, R3
    STR R1, [R8, R2]
.endm

.macro TurnOffPin pin
    LDR R1, =\pin
    LDR R2, [R1,#12]
    LDR R1, [R8, R2] @ Address value 0-9 gpio pin out set

    LDR R3, =0b1

    LDR R5, =\pin
    LDR R5, [R5, #4]
    LSL R3, R5
    ORR R1, R1, R3
    STR R1, [R8, R2]
.endm

.macro nanosleep seconds nano
    ldr r0, =\seconds
    ldr r1, =\nano
    ldr r2, =0
    ldr r3, =0
    ldr r4, =0
    ldr r5, =0
    ldr r6, =0
    mov r7, #162
    svc 0
.endm

.macro open_file file
    LDR R0, =\file
    LDR R1, =2
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

.macro reset_pins
    TurnOffPin pin1
    TurnOffPin pin12
    TurnOffPin pin16
    TurnOffPin pin20
    TurnOffPin pin21
    TurnOffPin pin25
.endm

_start:
    open_file devmem
    MOVS R4, R0 @ fd for memmap
    map_memory
    MOV R8, R0 @ Address

    @ Set as out
    reset_pins
    SetOutputPin pin1
    SetOutputPin pin6
    SetOutputPin pin12
    SetOutputPin pin16
    SetOutputPin pin20  
    SetOutputPin pin21
    SetOutputPin pin25
    
    TurnOnPin pin12
    TurnOnPin pin1
    
    TurnOffPin pin1
    /* 
        MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    
    

    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9

    TurnOffPin pin12
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    reset_pins*/

   
    /*TurnOnPin pin1
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    reset_pins
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    TurnOffPin pin1
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    TurnOnPin pin1
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    TurnOnPin pin16
    TurnOnPin pin20
    TurnOnPin pin21
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    TurnOffPin pin1
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9*/
    


    @ Initialization

    @ Function to work as 4bit

    @MOV R9, R4
    @nanosleep timespec timespecnano
    @MOV R4, R9
    

    
 

    @ CLEAR
    

    /*TurnOnPin pin1
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    TurnOnPin pin12
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    TurnOffPin pin1
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9*/



    @ First data
    /*TurnOnPin pin25
    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9  
    TurnOnPin pin1

    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9

    TurnOffPin pin12 @d4
    TurnOffPin pin16 @D5
    TurnOnPin pin20 @D6 
    TurnOffPin pin21 @D7

    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9

    TurnOffPin pin1

    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    
    @ Second data
    TurnOnPin pin1

    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9

    TurnOnPin pin12 @d4
    TurnOffPin pin16 @D5
    TurnOffPin pin20 @D6 
    TurnOffPin pin21 @D7

    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9

    TurnOffPin pin1

    MOV R9, R4
    nanosleep timespec timespecnanomc
    MOV R4, R9
    */

/* 
    @ Entry mode set
    TurnOnPin pin16
    TurnOnPin pin20

    MOV R9, R4
    nanosleep timespec
    MOV R4, R9
    @ Write H
    TurnOnPin pin25
    TurnOffPin pin16
    MOV R9, R4
    nanosleep timespec
    MOV R4, R9
    TurnOffPin pin20
    TurnOnPin pin21
    @ RESET PIN
    TurnOffPin pin6
    @ SET PIN
    TurnOnPin pin6

    @ NANO
    MOV R9, R4
    timespec
    MOV R4, R9*/
 
    BPL _turnon
    MOV R0, #1 @ stdout
    LDR R1, =memMapErr
    LDR R2, =memMapsz @ Error msg
    LDR R2, [R2]
    LDR R7, =sys_write
    SVC 0
    B _end
_turnon:

    B _end

_end:
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate


.data
@ Raspberry Pi Zero Base Address - 0x20200000 / 0x1000  = 0x20200 Page quantity  
gpio_base_addr: .word 0x20200 

@@@ Pin Definitions @@@

@ Pin Pattern:  
@ Array offset              Description
@   0x0         GPIO Select offset 
@   0x4         3-Shift quantity to set ON/OFF used inside GPIO Output SET/CLEAR
@   0x8         GPIO Output Set
@   0xc         GPIO Output Clear

@ E - Enable display
pin1:   .word 0x0 
        .word 1
        .word 0x1c
        .word 0x28
@ Only for test purpose
pin6:   .word 0x0
        .word 6 
        .word 0x1c 
        .word 0x28
@ D4    
pin12:  .word 0x4 
        .word 2
        .word 0x1c
        .word 0x28
@ D5
pin16:  .word 0x4 
        .word 6
        .word 0x1c
        .word 0x28
@ D6
pin20:  .word 0x8 
        .word 0
        .word 0x1c
        .word 0x28
@ D7
pin21:  .word 0x8 
        .word 1
        .word 0x1c
        .word 0x28
@ RS
pin25:  .word 0x8 
        .word 5
        .word 0x1c
        .word 0x28

timespec: .word 0
timespecnano: .word 5000000 @1000000     1
timespecnanomc: .word 3000 @1000000     1
devmem: .asciz "/dev/mem"
memOpnErr: .asciz "Failed to open /dev/mem\n"
memOpnsz: .word .-memOpnErr
memMapErr: .asciz "Failed to map memory\n"
memMapsz: .word .-memMapErr
 .align 4 @ realign after strings
@ mem address of gpio register / 4096



@0x20200000 GPFSEL0 GPIO Function Select 0
@0x2020001c GPIO Pin Output Clear 0 
@0x20200028 GPIO Pin Output Set 0 