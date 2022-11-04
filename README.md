# Introdução
Assembly LCD é uma biblioteca de controle de display LCDs baseados no modelo Hitachi HD44780U, possibilitando o seu uso sem a necessidade de implementar os detalhes associados a comunicação. Baseado na Raspberry Pi Zero e sua arquitetura Arm V6, é possível limpar o display, escrever um caractere e posicionar o cursor (linha e coluna). Além disso, no diretório examples/ há um programa que demonstra seu uso.


# Estrutura do projeto
Segue abaixo a estrutura de diretórios do projeto
```
├── display.s
├── examples
│   └── countdown.c
├── lib
│   ├── fileio.s
│   ├── gpio.s
│   ├── lcd.s
│   └── utils.s
├── LICENSE
├── makefile
└── README.md
```
##### examples/ - Possui um programa C utilizando as bibliotecas exportadas

##### lib/ - Pasta com os módulos utilizados na solução

## Bibliotecas
#### lib/fileio.s
Possui a macro open_file para abertura de arquivos. Recebe no R0, o descritor do arquivo aberto, no R1, o modo de abertura do arquivo.

#### lib/utils.s
Possui a macro nanosleep para fazer o programa parar durante o tempo específicado. R0 é um ponteiro para quantidade de segundos e R1 é um ponteiro para quantidade de nanossegundos.
#### lib/gpio.s
Possui macros para configurar pinos como entrada e saída, alterar o nível lógico no modo de saída e ler o nível lógico em determinado pino. A sessão de pinos tem seu array configurado da seguinte maneira:


- **Endereço 0x0**: GPIO Select offset. Indica em qual offset o gpio está para configurar como entrada e saída;
- **Endereço 0x4**: A quantidade de shifts é necessário no GPIO Select para configurar o GPIO. Este valor é multiplicado por 3, pois cada GPIO tem 3 bits de modo;
- **Endereço 0x8**: Offset a partir do enedereço base para o GPIO Output Set;
- **Endereço 0xc**: Offset a partir do enedereço base para o GPIO Output Clear; 
- **Endereço 0x10**:  Quantidade de shifts para set/clear do GPIO. É necessário, pois a quantidade de shifts anterior diferente entre a seleção de função e a configuração de nível lógico;
- **Endereço 0x14**: Offset para o GPIO Read Level. Utilizado apenas com pinos que serão configurados como input

#### lib/lcd.s
Biblioteca principal para o controle do LCD
##### Procedimentos
- **void init()**: Inicializa o display;
- **void clear_display**: Limpa display;
- **void write_char(char ch)**: Escreve um caractere, entre [a-z] ou espaço. Utiliza aritmética para mapear sem a utilização de muitas comparações. Como é um char, é preciso passar o código ascii.;
- **void write_number (int n)**: Escreve um número 0-9 passado como inteiro;
- **void write_data_4bits(int mask)**: É um procedimento que, passado um valor, avalia cada um dos dígitos binários para configurar DB4-DB7. Se quisermos ativar DB4, DB5, basta chamarmos write_data_4bits(0x3).
##### Macros
- **pulse**: Gera um pulso utilizando o enable, pra concluir a transferência de dados pro LCD;
- **write_4bit**: Uma macro para write_data_4bits.

#### display.s

Programa principal para execução do contador. O valor do contador fica registrado em R1, e as flags para pausar/continuar e reiniciar contagem, estão nos registradores R6 e R5, respectivamente
##### Procedimentos
- **void main()**: Inicializa o programa;
- **void system_init()**: Faz primeiros procedimentos para iniciar a contagem;
- **void system_run()**: Inicia o processo de contagem caso não esteja pausado;
- **void pause_counter()**: Faz leitura dos botões para checar se é necessário pausar/iniciar o contador;
- **void reset_counter()**: Faz leitura dos botões para checar se é necessário reiniciar o contador;
- **int divide(int dividend, int divisor)**: Algoritmo de divisão por subtrações sucessivas, retorna quociente;
- **int reminder(int dividend, int divisor)**: Algoritmo de divisão por subtrações sucessivas, retorna resto.

# Makefile

Para organizar as diretivas do projeto, foi utilizado um arquivo makefile contendo um conjunto de diretivas usadas pela ferramenta de automação make para gerar um alvo/meta, e simplificar e agilizar a montagem do programa.

No nosso Makefile, temos comandos desde "fileio" que gerencia as entradas e saídas até comandos do display lcd como descritos abaixo:
```
counter: display.o
	gcc -o display display.o

display.o: display.s lib/lcd.o
	as -o display.o display.s

lib/lcd.o: lib/utils.o lib/gpio.o lib/fileio.o
	as -o lib/lcd.o lib/lcd.s

lib/fileio.o: lib/fileio.s
	as -o lib/fileio.o lib/fileio.s

lib/gpio.o: lib/gpio.s
	as -o lib/gpio.o lib/gpio.s

lib/utils.o: lib/utils.s
	as -o lib/utils.o lib/utils.s

cexample: examples/countdown.c lib/lcd.s
	gcc -o countdown examples/countdown.c lib/lcd.s
```
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
| 36 | 16 | DB5 |
| 38 | 20 | DB6 |
| 40 | 21 | DB7 |
| 22 | 25 | Sinal RS |
### Endereços de Memória

| Endereço | Descrição |
| - | - | 
| 0x20200000 | Endereço base da GPIO / Modo de seleção I/O GPIO 0-9 |
| 0x20200004 | Modo de seleção I/O GPIO 10-19 |
| 0x20200008 | Modo de seleção I/O GPIO 20-29 |
| 0x2020001c | Escrita HIGH GPIO 0-31 |
| 0x20200028 | Escrita LOW GPIO 0-31 |
| 0x20200034 | Leitura GPIO 0-31 |

No caso da utilização do mmap2, o último parâmetro é o offset da memória em número de paginas. Se o tamanho da página for 0x1000, o endereço base acima vai ser: 0x20200.

## Display LCD 16x2
Dentro de um espaço de 16 colunas e 2 linhas, baseado no controlador [HD44780](https://www.sparkfun.com/datasheets/LCD/HD44780.pdf), o display lcd permite a criação de uma interface amigável, possibilitando a exibição de vários tipos de informações. Este display possui dois modos de ação: 4 bits ou 8 bits. Atualmente, esta biblioteca usa apenas o modo de quatro bits.

### Rotina de Inicialização

Para realizar a inicialização completa do display, é preciso executar os seguintes passos:

| E | DB7 | DB6 | DB5 | D4 |
| - | - | - | - | - |
|  ⎍  | 0 | 0 | 1 | 1 |
|  ⎍  | 0 | 0 | 1 | 1 |
|  ⎍  | 0 | 0 | 1 | 1 |
|  ⎍  | 0 | 0 | 1 | 0 |
|  ⎍  | 0 | 0 | 1 | 0 |
|  ⎍  | 1 | 0 | 0 | 0 |
|  ⎍  | 0 | 0 | 0 | 0 |
|  ⎍  | 1 | 0 | 0 | 0 |
|  ⎍  | wait | 5 | m | s |
|  ⎍  | 0 | 0 | 0 | 0 |
|  ⎍  | 0 | 0 | 0 | 1 |
|  ⎍  | wait | 5 | m | s |
|  ⎍  | 0 | 0 | 0 | 0 |
|  ⎍  | 0 | 1 | 1 | 0 |
|  ⎍  | wait | 5 | m | s |
|  ⎍  | 0 | 0 | 0 | 0 |
|  ⎍  | 1 | 1 | 1 | 1 |

As transições são reconhecidas nas bordas de descida.

### Comandos

#### Clear Display
| E | RS | RW | DB7 | DB6 | DB5 | D4 | DB3 | DB2 | DB1 | DB0 |
| - | - | - | - | - | - | - | - | - | - | - |
| ⎍ | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |

#### Return Home
| E | RS | RW | DB7 | DB6 | DB5 | D4 | DB3 | DB2 | DB1 | DB0 |
| - | - | - | - | - | - | - | - | - | - | - |
| ⎍ | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | - |

#### Cursor Shift

| E | RS | RW | DB7 | DB6 | DB5 | D4 | DB3 | DB2 | DB1 | DB0 |
| - | - | - | - | - | - | - | - | - | - | - |
| ⎍ | 0 | 0 | 0 | 0 | 0 | 1 | S/C | R/L | - | - |

S/C = 1 - Desloca Display
S/C = 0 - Move Cursor
R/L = 1 - Desloca a direita
R/L = 0 - Desloca a esquerda


# Arquitetura
A arquitetura utilizada é a ArmV6 presente na Raspberry Pi Zero, pertencente a família de processadores RISC. A Raspberry Pi Zero utiliza o processador BCM 2835, que é um processador de 32 bits e seu programa pode ser executado em versões mais recentes, pois o ArmV7 e ArmV8 possui retrocompatibilidade com o ArmV6.

Os registradores da arquitetura Arm é composta por:
- 13 registradores (R0-R12) de uso geral;
- 1 Stack Pointer (SP);
- 1 Link Register (LR);
- 1 Program Counter (PC);
- 1 Application Program Status Register APSR

Se tratando do sistema operacional, registradores podem ter usos específicos, cuidado! Por exemplo, no Raspberry Pi OS, a função de sistema é escolhida colocando seu identificador no R7, e seu retorno está presente no R0 após a chamada da função.


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
.equ MAP_SHARED, 0x01
.equ FLAG, 0x7
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
API da biblioteca para manipulação do LCD
##### void init();
Inicializa o display para que possa ser escrito

##### void clear_display();
Faz com que o display inteiro seja limpo

##### void write_char(char ch);
Escreve caracteres alfa numéricos (0-9a-zA-Z)

##### void move_cursor(int x, int y);
Posiciona o cursor na linha x (0-1) e na coluna y (0-15)

# Como executar

### Contador
1. Na pasta execute:

`$ make countdown`

2. Em seguida execute o programa

`$ sudo ./display`

### Exemplo
1. Na pasta execute:

`$ make example`

2. Em seguida execute o programa

`$ sudo ./countdown`

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
