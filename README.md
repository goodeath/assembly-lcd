# Introdução
Assembly LCD é uma biblioteca de controle de display LCDs baseados no modelo Hitachi HD44780U, possibilitando o seu uso sem a necessidade de implementar os detalhes associados a comunicação. Baseado na Raspberry Pi Zero e sua arquitetura Arm V6, é possível limpar o display, escrever um caractere e posicionar o cursor (linha e coluna). Além disso, no diretório examples/ há um programa que demonstra seu uso.

# Dispositivos

Abaixo está presente os dispositivos utilizados, suas características e documentação utilizada para desenvolvimento do projeto

## Raspberry Pi Zero

Endereço base gpio 0x20200000

## Display LCD 16x2

# Fiação

# Sistema Operacional

## System Calls

Devido a presença de sistema operacional na Raspberry Pi Zero, para realizar um acesso aos dispositivos presentes na placa, é necessário realizar o mapeamento de memória, onde é exigido a chamada de algumas system calls para realizar esse acesso. Para outros dispositivos, como o acionamento do relógio interno, o sistema operacional oferece uma interface amigável.

.equ sys_open, 5
##### int open(const char *pathname, int flags);
Abre um arquivo e retorna seu descritor. O primeiro parâmetro é o nome do arquivo e o segundo indica a maneira que o arquivo vai ser aberto.  Seu número de chamada é 5
##### int nanosleep(const struct timespec *req, struct timespec *rem);
Utilizada para fazer o programa aguardar (\*req) segundos + (\*rem) nanossegundos. Dentro do projeto do contador, esta chamada auxilia o processo de contagem dos segundos. Seu número de chamada é 162. Segue um exemplo de uso, fazendo com o que o código espere 5,5 segundos:
```
.EQU nanosleep_sys, #162
.global _start
_start:
    LDR R0, =time_in_seconds
    LDR R1, =time_in_nano
    LDR R7, =#nanosleep_sys
    SVC 0
.data
time_in_seconds: .word 5
time_in_nano: .word 500000000
```

# Registradores

# Limitações

# Resultados
