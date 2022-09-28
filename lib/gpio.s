.equ MAP_SHARED, 0x01
.equ sys_read, 3
.equ sys_write, 4
.equ sys_close, 6
.equ FLAG, 0x7
.equ pagelen, 4096
.section .text

@ Access 0x20200 Address
@ Map Memory
@ Return an user-space memory mapped to some low address
@
@ void *syscall(SYS_mmap2, unsigned long addr, unsigned long length, 
@        unsigned long prot, unsigned long flags, unsigned long fd,
@        unsigned long pgoffset);
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

@ Set Output Pin
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
 

.data
gpio_base_addr: .word 0x20200 
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