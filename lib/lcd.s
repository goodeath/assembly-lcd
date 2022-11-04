.include "lib/utils.s"
.include "lib/fileio.s"
.include "lib/gpio.s"
.section .text
@ Export lib
.global init
.global clear_display
.global write_char

.macro pulse 
    TurnOn E
    nanosleep timespec0 timespec5 // 5 ms
    TurnOff E
    nanosleep timespec0 timespec5    // 5ms // 5ms   // 5ms // 5ms
.endm



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

write_4bit2:
    PUSH {LR}
    BL write_data_4bits
    pulse
    POP {LR}
    BX LR


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
    



@.syntax unified
write_char:
    PUSH {R0-R2, LR}
    TurnOn RS
    CMP R0, #32
    BEQ 1f
    MOV R1, R0
    LDR R0, =97
    SUB R1, R1, R0

    CMP R1, #0xE
    LDRLE R0, =0x6
    LDRGT R0, =0x7
    BL write_4bit2

    LDR R0, =0x1
    ADD R0, R1
    BL write_4bit2
   
    POP {R0-R2, LR}
    BX LR
1:
    write_4bit 0x8
    write_4bit 0x0
    POP {R0, R1, R2, PC}
 
.macro display_clear
    TurnOff RS
    write_4bit #0x0
    write_4bit #0x1
.endm

display_clear2:
    PUSH {LR}
    TurnOff RS
    LDR R0, =0x0
    BL write_4bit2
    LDR R0, =0x1
    BL write_4bit2
    POP {LR}
    BX LR


@.syntax unified
clear_display:
    PUSH {LR}
    BL display_clear2
    POP {LR}
    BX LR

@ Initialize Display
@.syntax unified
init:
    PUSH {LR}
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
    TurnOff DB4
    TurnOff DB5
    TurnOff DB6
    TurnOff DB7
    TurnOn pin6

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
    POP {PC}

.data
timespec0: .word 0
timespec5: .word 5000000  
t1s: .word 1
timespecnano0: .word 0
ts0: .word 0
tms10: .word 10000000

devmem: .asciz "/dev/mem"
@memOpnErr: .asciz "Failed to open /dev/mem\n"
@memOpnsz: .word .-memOpnErr
@memMapErr: .asciz "Failed to map memory\n"
@memMapsz: .word .-memMapErr
.align 4 @ realign after strings