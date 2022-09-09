.include "gpiomem.s"
.global _start @ Provide program starting

_start:
    mapMem
    nanoSleep
    B _end
    GPIODirectionOut pin17
    GPIODirectionOut pin27
    GPIODirectionOut pin22
    @ set up a loop counter for 10 iterations
    mov r6, #10
loop:
    GPIOTurnOn pin17
    nanoSleep
    GPIOTurnOff pin17
    GPIOTurnOn pin27
    nanoSleep
    GPIOTurnOff pin27
    GPIOTurnOn pin22
    nanoSleep
brk1:
    GPIOTurnOff pin22
    @decrement loop counter and see if we loop
    subs r6, #1
    @ If we haven't counted down to 0 then loop
    bne loop
_end:
    mov R0, #0 @ Use 0 return code
    mov R7, #1 @ Command code 1 terms
    svc 0 @ Linux command to terminate
