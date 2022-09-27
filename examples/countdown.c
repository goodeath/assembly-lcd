#include <stdio.h>

extern void init();
extern void writea();
extern void clear_display();

int main(){
    init();
    printf("initilized\n");

    for(int i=0;i<10;i++) writea();
    clear_display();
    writea();
    printf("Writed\n");
    return 0;
}