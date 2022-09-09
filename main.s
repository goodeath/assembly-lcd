.include "gpiomem.s"

.equ sys_read, 3
.equ sys_write, 4
.equ sys_open, 5
.equ sys_close, 6
.equ sys_fsync, 118
.equ FLAG, 0x02
.global _start @ Provide program starting

_start:
    LDR R0, =devmem
    LDR R1, =FLAG
    MOV R7, #sys_open
    SVC 0
    MOV R3, R0;
    @mapMem
    @nanoSleep
    @GPIODirectionOut pin6
    @GPIOTurnOn pin6 #0
    B _end

_end:
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate

.data
timespecsec: .word 0
timespecnano: .word 100000000
devmem: .asciz "/dev/gpiomem"