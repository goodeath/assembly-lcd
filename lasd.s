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
    LDR R1, =\pin
    LDR R2, [R1,#8]

    LDR R3, =0b1
    LDR R4, [R1, #16]
    LSL R3, R4
    STR R3, [R8, R2]
.endm

.macro TurnOff pin
    LDR R1, =\pin
    LDR R2, [R1,#12]

    LDR R3, =0b1

    LDR R5, =\pin
    LDR R5, [R5, #16]
    LSL R3, R5
    STR R3, [R8, R2]
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
    TurnOff E
    nanosleep timespecnano00 timespecnano_1 // 1 us
    TurnOn E
    nanosleep timespecnano0 timespecnano45 // 5 ms
    TurnOff E
    nanosleep timespecnano0 timespecnano45 // 5ms
.endm
 

 
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
   

    @ Start   
    // Step 1
    nanosleep timesz timenz

    // Step 2
    TurnOn DB4
    TurnOn DB5
    pulse
    reset
    pulse
    nanosleep times timen
    .ltorg
    
    // Step 3
    TurnOn DB4
    TurnOn DB5
    pulse
    reset
    pulse
    .ltorg

    // Step 4
    TurnOn DB4
    TurnOn DB5
    pulse
    reset
    pulse
    .ltorg
    
    // Step 5
    TurnOn DB4
    TurnOn DB5
    pulse
    reset
    pulse

    // Step 6
    reset
    pulse
    .ltorg
    TurnOn DB7
    pulse
    .ltorg

    // Step 7
    reset
    pulse
    TurnOn DB4
    pulse
    nanosleep times timen

    // Step8

    reset
    pulse
    TurnOn DB5
    TurnOn DB6
    pulse

    // step 9
   // finished

   //step10
    reset
    pulse
    TurnOn DB7
    TurnOn DB6
    pulse
    /* 
    //step 11
    reset
    pulse
    TurnOn DB4
    TurnOn DB5
    TurnOn DB6
    TurnOn DB7
    pulse

    reset
    TurnOn DB4
    TurnOn DB5
    TurnOn RS
    pulse
    pulse
    TurnOff RS
    nanosleep times timespec1

    reset
    TurnOff RS
    TurnOn DB4
    TurnOn DB5
    pulse
    reset
    pulse
    TurnOff RS
    nanosleep times timespec1/* */
   

    B _end

_end:
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate


.data
times: .word 0
timen: .word 5000000
timesz: .word 0
timenz: .word 100000000
t10: .word 0
@ Raspberry Pi Zero Base Address - 0x20200000 / 0x1000  = 0x20200 Page quantity  
tns10: .word 900000000
gpio_base_addr: .word 0x3F200 

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
pin6:   .word 0x0
        .word 6 
        .word 0x1c 
        .word 0x28
        .word 0x6
@ D4    
DB4:  .word 0x4 
        .word 2
        .word 0x1c
        .word 0x28
        .word 0xc
@ D5
DB5:  .word 0x4 
        .word 6
        .word 0x1c
        .word 0x28
        .word 0x10
@ D6
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