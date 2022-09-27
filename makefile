countdown: counter

counter: display.o
	gcc -o display display.o

display.o: display.s
	as -o display.o display.s