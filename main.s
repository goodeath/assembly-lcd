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

.macro SetOutputPin pinnumber
    LDR R0, =0
    LDR R1, =#pagelen
    LDR R2, =#FLAG
    LDR R3, #MAP_SHARED
    LDR R5, =gpio_base_addr
    LDR R7, =192
    SVC 0
    MOV R8, R0 @ Address
    LDR R1, [R8] @ Address value 0-9 gpio pins
    LDR R2, =pinnumber
    LDR R3, =3 
    MUL R5, R2, R3
    LDR R2, =0xFFFFFFFF @ Mask
    LDR R3, =0b111
    LSL R3, R5
    EOR R2, R2, R3
    AND R1, R1, R2

    LDR R3, =0b001  @ Set as output
    LSL R3, R5
    ORR R1, R1, R3
    STR R1, [R8]

.endm

.macro TurnOnPin pinnumber
    LDR R0, =0
    LDR R1, =#pagelen
    LDR R2, =#FLAG
    LDR R3, #MAP_SHARED
    LDR R5, =gpio_base_addr
    LDR R7, =192
    SVC 0
    MOV R8, R0 @ Address
    LDR R1, [R8, #0x28] @ Address value 0-9 gpio pins
    LDR R3, =0b1
    LDR R5, =pinnumber
    LSL R3, R5
    ORR R1, R1, R3
    STR R1, [R8, #0x28]
.endm

.macro TurnOffPin pinnumber
    LDR R0, =0
    LDR R1, =#pagelen
    LDR R2, =#FLAG
    LDR R3, #MAP_SHARED
    LDR R5, =gpio_base_addr
    LDR R7, =192
    SVC 0
    MOV R8, R0 @ Address
    LDR R1, [R8, #0x1c] @ Address value 0-9 gpio pins
    LDR R3, =0b1
    LDR R5, =pinnumber
    LSL R3, R5
    ORR R1, R1, R3
    STR R1, [R8, #0x1c]
.endm

_start:
    LDR R0, =devmem
    LDR R1, =2
    MOV R7, #sys_open
    SVC 0
    MOV R3, R0;
    movs r4, r0 @ fd for memmap
    @ldr r5, =gpioaddr @ address we want / 4096
    @ldr r5, [r5] @ load the address
    @ldr r5, =gpio_base_addr
    @mov r0, #0 @ let linux choose a
    @mov r1, #pagelen @ size of mem we want
    @LDR r2, =FLAG
    @mov r3, #MAP_SHARED @ mem share options
    @@mov r7, #192 @ mmap2 service num
    @svc 0 @ call service
    @mov r8, r0 @ keep the returned virt addr
    @LDR r1, [r8]
    LDR R0, =0
    LDR R1, =#pagelen
    LDR R2, =#FLAG
    LDR R3, =#MAP_SHARED
    LDR R5, =gpio_base_addr
    LDR R7, =192
    SVC 0
    MOV R8, R0 @ Address
    LDR R1, [R8] @ Address value 0-9 gpio pins
    LDR R2, =6
    LDR R3, =3 
    MUL R5, R2, R3
    LDR R2, =0xFFFFFFFF @ Mask
    LDR R3, =0b111
    LSL R3, R5
    EOR R2, R2, R3
    AND R1, R1, R2

    LDR R3, =0b001  @ Set as output
    LSL R3, R5
    ORR R1, R1, R3
    STR R1, [R8]

    @ RESET PIN
    LDR R0, =0
    LDR R1, =#pagelen
    LDR R2, =#FLAG
    LDR R3, =#MAP_SHARED
    LDR R5, =gpio_base_addr
    LDR R7, =192
    SVC 0
    MOV R8, R0 @ Address
    LDR R1, [R8, #0x1c] @ Address value 0-9 gpio pin out set
    LDR R3, =0b1
    LDR R5, =6
    LSL R3, R5
    ORR R1, R1, R3
    STR R1, [R8, #0x1c]

    @ SET PIN
    LDR R0, =0
    LDR R1, =#pagelen
    LDR R2, =#FLAG
    LDR R3, =#MAP_SHARED
    LDR R5, =gpio_base_addr
    LDR R7, =192
    SVC 0
    MOV R8, R0 @ Address
    LDR R1, [R8, #0x28] @ Address value 0-9 gpio pin out set
    LDR R3, =0b1
    LDR R5, =6
    LSL R3, R5
    ORR R1, R1, R3
    STR R1, [R8, #0x28]

    @ NANO
    MOV R8, R4
    ldr r0, =timespec
    ldr r1, =timespec
    ldr r2, =0
    ldr r3, =0
    ldr r4, =0
    ldr r5, =0
    ldr r6, =0
    mov r7, #162
    svc 0
    MOV R4, R8

    @ RESET PIN
    LDR R0, =0
    LDR R1, =#pagelen
    LDR R2, =#FLAG
    LDR R3, =#MAP_SHARED
    LDR R5, =gpio_base_addr
    LDR R7, =192
    SVC 0   
    MOV R8, R0 @ Address
    LDR R1, [R8, #0x1c] @ Address value 0-9 gpio pin out set
    LDR R3, =0b1
    LDR R5, =6
    LSL R3, R5
    ORR R1, R1, R3
    STR R1, [R8, #0x1c]
    @@@
    @CMP R0, #0 
    @mapMem
    @nanoSleep
    @GPIODirectionOut pin6
    @GPIOTurnOn pin6 #0
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
pin6: .word
timespec: .word 5
timespecnano: .word 100000000
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