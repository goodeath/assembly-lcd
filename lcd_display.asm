; LCD Display Control
.global _start

; Define start time
.equ TIMER_VALUE, 30

; R6 - 0/1 RESET Counter
; R5 - 0/1 PAUSE/START Counter

_start:
	LDR R0,=TIMER_VALUE
	BL countdown
	MOV R1, #1

countdown:
	CMP R6,#1
	BEQ _start

	CMP R5,#1
	BEQ countdown

	SUB R0,#1
	CMP R0,#0
	BGT countdown
	BX LR