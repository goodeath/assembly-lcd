.equ sys_nanosleep, 162
.section .text
@ Nanosleep
@ seconds - Time in Seconds
@ nano - Time in nanoseconds
.macro nanosleep seconds nano
    PUSH {R0, R1}
    LDR r0, =\seconds
    LDR r1, =\nano
    MOV r7, #sys_nanosleep
    SVC 0
    POP {R0, R1}
.endm