/*
	UART communication on Raspberry Pi using C (WiringPi Library)
	http://www.electronicwings.com
*/

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <time.h>

#include <wiringPi.h>
#include <wiringSerial.h>

extern void init();
extern void write_char(char ch);
extern void clear_display();

#define BAUD_RATE 9600

// Read message after secret code.
int FLAG_READ = 0;
char key[6] = {'u', 'n', 'l', 'o', 'c', 'k'};


int init_uart(){
    int serial_port = serialOpen("/dev/ttyS0", BAUD_RATE);
    if (serial_port < 0) {
        fprintf(stderr, "Unable to open serial device: %s\n", strerror(errno));
        return 0;
    }

    if (wiringPiSetup() == -1) {
        fprintf(stdout, "Unable to start wiringPi: %s\n", strerror(errno));
        return 0;
    }
    return serial_port;
}

int main()
{
    printf("Initializing Display...\n");
    init();
    printf("Initializing Uart...\n");
    int serial_port = init_uart();
    if(!serial_port) return 1;
    printf("Uart initialized\n");
    printf("Reading secret code\n");
    // Unlock
    int i = 0;
    while(i < 6){
        if (serialDataAvail(serial_port)){
            char byte = serialGetchar(serial_port); /* receive character serially*/
            i = byte == key[i] ? i + 1 : 0;
            fflush(stdout);
        }
    }
    printf("Secret code found\n");

    int t = 0;
    int wait = 0;
    struct timespec tim;
    while(1){
        printf("Digite um comando: ");
        int cmd;
        scanf("%d", &cmd);
        clear_display();
        char byte = cmd;
        wait = 1;
        serialPutchar(serial_port, byte);
        while(wait){
            t++;
            if(t > 1e9) {
                printf("Timeout...\n");
                wait = 0;
            }
            if(!serialDataAvail(serial_port)) continue;
            while(serialDataAvail(serial_port)){
                char byte = serialGetchar(serial_port);
                if(byte >= '0' && byte <= '9')
                    write_char(byte);
                printf("Response: %d\n", byte);
            }
            wait = 0;
        }
        t = 0;
    }
}
