; LCD Display Control
.global _start

; Define start time
.equ timer_default, 30
.equ sys_nanosleep, 162
; R6 - 0/1 RESET Counter
; R5 - 0/1 PAUSE/START Counter

.macro delay time
	LDR R0,=\time
	LDR R1,=\time
	MOV R7, #sys_nanosleep
	SVC 0
.endm

_start:
	MOV R4, #timer_default
	BL countdown
	MOV R0,0
	MOV R7,1
	SVC 0

countdown:
	CMP R6,#1
	BEQ _start

	CMP R5,#1
	BEQ countdown

	delay cycle_delay

	SUB R4,#1
	CMP R4,#0
	BGT countdown
	BX LR

.data
cycle_delay: .word 1