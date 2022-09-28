.section .text

.equ sys_open, 5
@ File IO
@ This module opens a file. 
@ Its used to open /dev/mem
.macro open_file file
    LDR R0, =\file
    LDR R1, =mode
    LDR R1, [R1]
    MOV R7, #sys_open
    SVC 0
.endm

.data
mode: .word 2