#include <stdio.h>

extern void init();
extern void write_char(char ch);
extern void clear_display();

int main(){
    init();
    printf("Initialized\n");
    char str[] = "iniciando";
    for(int i=0;i<21;i++) write_char(str[i]);
    printf("Written\n");
    return 0;
}