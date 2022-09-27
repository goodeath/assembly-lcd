.include "lib/utils.s"
.include "lib/fileio.s"
.include "lib/gpio.s"

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

@ Initialize Display
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
    BX LR

.data
timespec0: .word 0
timespec5: .word 5000000  
