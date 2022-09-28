#include <stdio.h>

extern void init();
extern void write_char(char ch);
extern void clear_display();

int main(){
    init();
    printf("Initialized\n");
    char str[] = "ola mundo";
    for(int i=0;i<10;i++) write_char(str[i]);
    printf("Written\n");
    return 0;
}