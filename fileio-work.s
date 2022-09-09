; Funciona com /dev/mem
.global _start

_start:
    LDR R0, =name
    MOV R1, #0100
    LDR R2, =0666
    MOV R7, #5
    SVC 0
    CMP R0, #0
    blt error
    B exit

error:
    MOV R0,#1
    LDR R1,=msg
    LDR R2, =msgsz
    LDR R2,[R2]
    MOV R7, #4
    SVC 0
    B exit

exit:
    MOV R0,#0
    MOV R7,#1
    SVC 0

.data
    name: .asciz "/dev/mem"
    msg: .asciz "DEu ruim"
    msgsz: .word .-msg
