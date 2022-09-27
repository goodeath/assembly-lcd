# Introdução
Assembly LCD é uma biblioteca de controle de display LCDs baseados no modelo Hitachi HD44780U, possibilitando o seu uso sem a necessidade de implementar os detalhes associados a comunicação. Baseado na Raspberry Pi Zero e sua arquitetura Arm V6, é possível limpar o display, escrever um caractere e posicionar o cursor (linha e coluna). Além disso, no diretório examples/ há um programa que demonstra seu uso.

# Dispositivos

Abaixo está presente os dispositivos utilizados, suas características e documentação utilizada para desenvolvimento do projeto

## Raspberry Pi Zero
Baseada no processador [BCM 2385](https://datasheets.raspberrypi.com/bcm2835/bcm2835-peripherals.pdf), possui 54 I/O de propósito geral (GPIO), onde atualmente se faz uso de apenas 6. É importante notar que, o GPIO 1 não está posicionado no PINO 1. As informações da placa são mostradas na tabela abaixo, junto da descrição sobre o uso de cada GPIO.

| Pino | GPIO | Descrição |
| - | - | - |
| 28 | 1 | Sinal de Enable |
| 29 | 5 | Push Button 1 |
| 35 | 19 | Push Button 2 |
| 32 | 12 | D4 |
| 36 | 16 | D5 |
| 38 | 20 | D6 |
| 40 | 21 | D7 |
| 22 | 25 | Sinal RS |
### Endereços de Memória
Endereço base gpio 0x20200000

## Display LCD 16x2
Dentro de um espaço de 16 colunas e 2 linhas, baseado no controlador [HD44780](https://www.sparkfun.com/datasheets/LCD/HD44780.pdf), o display lcd permite a criação de uma interface amigável, possibilitando a exibição de vários tipos de informações. Este display possui dois modos de ação: 4 bits ou 8 bits. Atualmente, esta biblioteca usa apenas o modo de quatro bits.

### Rotina de Inicialização

# Wiring

# Arquitetura

## Instruções Arm V6


# Sistema Operacional
O sistema operacional utilizado é o Raspberry Pi OS, derivado do Debian. Desta maneira, possui as mesmas chamadas de sistema que o linux.
## System Calls

Devido a presença de sistema operacional na Raspberry Pi Zero, para realizar um acesso aos dispositivos presentes na placa, é necessário realizar o mapeamento de memória, onde é exigido a chamada de algumas system calls para realizar esse acesso. Para outros dispositivos, como o acionamento do relógio interno, o sistema operacional oferece uma interface amigável.

##### void _exit(int status);
Finaliza o programa com um código de status. Caso o status seja 0, o programa foi encerrado com sucesso. Seu código é 1.
```
.EQU sys_exit, #0x1
.global _start
_start:
    LDR R0, =0x0
    LDR R7, =#sys_exit
    SVC 0
.data
```

##### int open(const char *pathname, int flags);
Abre um arquivo e retorna seu descritor. O primeiro parâmetro é o nome do arquivo e o segundo indica a maneira que o arquivo vai ser aberto. Esta chamada é feita para abertura do arquivo /dev/mem onde é o responsável por receber entradas para realização do mapeamento de memória.  Seu número de chamada é 5.

```
.EQU sys_open, #0x5
.global _start
_start:
    LDR R0, =file
    LDR R1, =mode
    LDR R1, [R1]
    LDR R7, =#sys_open
    SVC 0
.data
mode: .word 2
```

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
 
##### void *syscall(SYS_mmap2, unsigned long addr, unsigned long length, unsigned long prot, unsigned long flags, unsigned long fd, unsigned long pgoffset);
Utilizada para mapear um endereço físico para memória virtual, retornando seu endereço para uso do programa.
```
.EQU mmap2_sys, #192
.EQU pagelen, 4096
.global _start
    LDR R0, =0
    LDR R1, =#pagelen
    LDR R2, =#FLAG
    LDR R3, =#MAP_SHARED
    LDR R5, =gpio_base_addr
    LDR R5, [R5]
    LDR R7, =#mmap2_sys
    SVC 0
.data
gpio_base_addr: .word 0x20200
```


# Interface 
A interface da biblioteca gerada...
# Resultados

![contagem ocorrendo](result.gif)

O protótipo construído é um contador de 2 digitos, onde é possível configurar seu valor diretamente no código, possibilitando diferentes tempos. Ainda, é possível utilizar dois botões de controle. Um botão para pausar/iniciar a contagem, onde sua função alterna a cada pressionamento. E um botão para reiniciar a contagem, onde é acionado apenas uma vez após o pressionamento, necessitando assim soltar o botão antes de realizar um novo reinício.

## Limitações

### Quantidade de dígitos
Não é possível escrever um número maior que dois digitos. Foi implementado um algoritmo de divisão por subtrações sucessívas, para realizar a separação dos dígitos decimais a partir do valor binário. Para a separação de múltiplos dígitos, seria necessário realizar uma abstração maior. Uma maneira de alcançar esse resultado, é dividir por 10, pegar o resto que é nosso último dígito, e subtrair do número original. Em seguida, dividir por 100, pegar o resto que é o penúltimo digito, e subtrair do original. Seguindo esses passos até o número se tornar zero. Pode-se empilhar os valores de forma, que sejam exibidos na ordem correta.

### Acionamento dos botões
Os botões só são reconhecidos entre a contagem de dois números. Como foi utilizado um nanosleep de 1 segundo, enquanto há espera, os botões não reagem. Uma forma de solucionar este problema é realizar n = 1000/t  chamadas de t milissegundos, de forma que entre cada espera menor, os botões sejam checados

### Precisão
O tempo de espera não é preciso. Pois, é feito utilizando uma chamada ao sistema operacional que, vai aguardar no mínimo o tempo solicitado, mas, devido a processos internos, pode não retornar ao processo no tempo exato, adicionando assim, alguns atrasos que dentro do projeto não causam impactos maiores,mas, em diversas outras situações pode ser significativo