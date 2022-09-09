.equ O_RDONLY, 0
.equ O_WRONLY, 1
.equ O_CREAT, 0100

@.equ sys_read, 3
@.equ sys_write, 4
@.equ sys_open, 5
@.equ sys_close, 6
@.equ sys_fsync, 118

.equ O_RDWR,  00000002
.equ O_DSYNC, 00010000
.equ __O_SYNC,04000000
.equ O_SYNC, __O_SYNC|O_DSYNC
.equ O_FLAGS, O_RDWR|O_SYNC

@.equ FLAG, 0x02

.macro fopen name, flags

    LDR R0, =\name
    LDR R1, =\flags
    MOV R7, #sys_open
    SVC 0
.endm


.macro fread fd, buffer, length
    MOV R0, \fd
    LDR R1, =\buffer
    MOV R2, #\length
    MOV R7, #sys_read
    SVC 0
.endm

.macro fwrite fd, buffer ,length
    MOV R0, \fd
    LDR R1, =\buffer
    MOV R2, \length
    MOV R7, #sys_write
    SVC 0
.endm

.macro fclose fd
    MOV R0, \fd
    MOV R7, #sys_fsync
    SVC 0
    MOV R0, \fd
    MOV R7, #sys_close
    SVC 0
.endm

.data
S_RDWR: .word 0666
openMode: .word O_FLAGS
