.section .text

.macro nanosleep seconds nano
    PUSH {R0-R6}
    ldr r0, =\seconds
    ldr r1, =\nano
    mov r7, #162
    svc 0
    POP {R0-R6}
.endm