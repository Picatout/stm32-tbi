<!-- 
Copyright Jacques Deschênes, 2021
Ce document fait parti du projet stm32-tbi
https://github.com/picatout/stm32-tbi
-->
[-&gt;français](tbi_reference.md)
# Blue pill Tiny BASIC reference manual
<a id="index-princ"></a>
## main index

* [data types](#data-types)

* [Variables](#variables)

* [user Constants](#user-constants)

* [Arithmetic expressions](#expressions)

* [Syntax](#syntax)

* [numerical bases](#bases)

* [Command line interface](#cli)

* [Files](#files)

* [Commands and functions reference](#index)

* [Installation](#install)

* [Using it](#utilisation)

* [file transfert](#xmodem)

* [source files](#sources)

<a id="data-types"></a>
### Data types  

The only numeric type is the 32 bits signed integer in the range **{-2147483650...2147483649}**.  

For printing purpose there is also a **string** type and a **character** type. These are only used by [PRINT](#print) and [INPUT](#input) commands. 

The character type  take the form **\c** i.e. a *backslash* followed by a single ASCII character. A character type can be assign to a variable using the [ASC](#asc) function to convert it to integer. 

[main index](#index-princ)
### Variables 

Variables are limited to 26 and are named by the alphabets letters {A..Z}. 

[main index](#index-princ)

<a id="tableau"></a>
### array 

A single dimension array is available with name **@**. As it used the RAM left out by the program loaded in memory its size varies. The function [UBOUND](#ubound) enable the application to know this size. The array indice range is {1..UBOUND}.

[main index](#index-princ)
<a id="#user-constants"></a>
### user Constants
The keyword [CONST](#const) is use to defines symbolics constants. A constant name must have at least 2 characters and at most 6. The name is limited to letters and *'_'** character. Below an exemple of its usage. 

```
HEX LIST
5 REM  Adresse de base des UART2 et 3
10 CONST UART_B =$40000400 ,UART_C =$40000800 
15 PRINT UART_B ,UART_C 
READY
RUN
1073742848 1073743872 
```
[main index](#index-princ)
<a id="expressions"></a>
### Arithmetic expressions 

Expression are evaluated from left to right but operators priority is respected.

The arithmetic operators by precedence order, items on same line have same priority and are evaluated left to right.

1. **'-'**  unary minus, highest precedence.
1. **(_expr_)** expression in parenthesis.
1.  __'*'__ mulitiplication, **'/'** division, **'%'** modulo, function 
1. **'+'** addition, **'-'** substraction.

**NOTE:** The division quotient is not rounded. 

### Relational operators.

Relational operators are used only by [IF..THEN](#if) and [DO..UNTIL](#do) controls structures. Any non zero value is considered TRUE.

1. **'&gt;'**   True if Left expression is greater than right one.
1. **'&lt;'** True if left expression is smaller than right one.
1. **'&gt;='** True if left expression is greater or equeal to right one.
1. **'&lt;='** True if left expression is smaller or equal to right one.
1. **'='** True if both are equal.
1. **'&lt;&gt;'** ou **'&gt;&lt;'** True if both are not equal.

[main index](#index-princ)
## Syntax
<a id="syntax"></a>
For a formal syntax description see [syntax](syntax-en.md) document.

The character set used is [ASCII](https://en.wikipedia.org/wiki/ASCII) code {0..127}.

A program is a list of numbered lines. Valid Line number range is {1..65535}. If a line without number is entered it is taken as an immediate command and executed. Otherwise the the compiled line is stored in RAM as part of a program.

Blue pill Tiny BASIC authorize *labels* as [GOSUB](#gosub) and [GOTO](#goto) target instead of a line number. It is faster at execution to use a *label* instead of a line number. 

*Label* name obey the same form as user constants names, minimum 2 characters and maximum 6. Only letters and **'_'**. character. 

The *label* must follow immediately the line number. 

### statement 

A *statement* is a command which may be followed by one or more arguments separated by a comma **','**. 

There may be more than one statement per line separated by **':'** character. This statement separator is optional. In most cases the interpreter knows where a command end. 

Statement can be entered in any letter case but the compiler convert all letters to uppercase. 

A command *keyword* can be shortened to at least 2 characters provide there is no confusion between to commands. Using short form for *keyword* doesn't doesn't save memory space or improve execution speed as source code is compiled in tokens before beeing store in program space. 

[PRINT](#print) can use **'?'**  as a remplacement for its name. 

[REM](#remark) can use tick character **(')** as a replacement for ist name. 

An end of line mark the end of a statement except for control structures [FOR..NEXT](#for) and [DO..UNTIL](#do) which can expand many lines up to their associated closing *keyword*.

[main index](#index-princ)
<a id="bases"></a>
## Numerical bases
Integer can be entered in 3 differents bases, decimal, hexadecimal and binary.
The [PRINT](#print) command only output integer in decimal or hexadecimal. The system variable **BASE** determine the output format of numbers, see [HEX](#hex) and [DEC](#dec) commands that set this variable.

Here de lexical form of integers. In the following what is between **'['** and **']'** is optional. The **'+'** character means the charater must appear at least one time. A character between single quote is *literal*. **::=** introduce a definition.
**&epsi;** stand for *no character*.
*  digit ::= '0','1','2','3','4','5','6','7','8','9'
*  hex_digit ::= digit,'A','B','C','D','E','F' 
*  decimal integer ::=  ['+'|'-'|&epsi;]digit+
*  hexadecimal integer ::= ['+'|'-'|&epsi;]'$'hex_digit+
*  binary integer ::= ['+'|'-'|&epsi;]'&'('0'|'1')+   

some examples:
```
-13534 ' negative decimal integer 
$ff0f  ' hexadecimal integer  
-&101   ' decimal -5 entered in binary. 
```
[main index](#index-princ)
<a id="cli"></a>
## Command line interface 
The communication between **blue pill** and the terminal emulator on the PC is done via a serial port. The terminal emulator must be VT100 compatible. There is no application to install on the PC other than this terminal emulator. This **blue pill BASIC stamp** is designed to be usable with any operating system on the PC.

At power up or reset of **blue pill** the software name and version is displayed on the terminal followed on the next line by the word **READY**. From then commands can be entered on the terminal. 
```
blue pill tiny BASIC, version 1.0
READY
```
A command line is ended when the **&lt;ENTER&gt;** key is pressed. Then the text line is compiled. If the first token is a line number the compiler insert this line in the program area. 

* The line is inserted in increasing line number. 
* An empty line remove an aldready existing one with the same number.
* If a line with the same number already exist it is replace by the new version.

If there is no line number this is executed immediately.

Some commands are valid only in programs others only in immediate mode. Using a statement in wrong context result in an error report and end of execution.

Programs stored in RAM are lost at power cycle or reset. 

* **&lt;CTRL-C&gt;** Result in such a reboot, *cold start*.
* **&lt;CTLR-B&gt;** Result in program END but no reboot, *warm start*.

[main index](#index-princ)
<a id="files"></a>
## File system
The stm32f103c8 MCU used on the **blue pill** has 64Ko of RAM. Tiny BASIC use only a fraction of that flash memory. From the unused flash 1KB is reserved for programs persistant data and the rest for a simple file system used to save BASIC programs.
See [SAVE](#save) and other file system commands in the next section for more information.

[main index](#index-princ)
<a id="reference"></a>
## Commands, functions and system constants reference
The {C,P} comment that follow a command name specify the context in which this command can be used. 

* **C** This command can be used in immediate mode.
* **P** This command can be used in program.

<a id="index"></a>
## Vocabulary index 
name|short form
-|-
[ABS](#abs)|AB
[ADC](#adcon)|ADC
[ANA](#adcread)|AN
[AND](#and)|AN
[ASC](#asc)|AS
[AUTORUN](#autorun)|AU
[AWU](#awu)|AW 
[BIT](#bit)|BI
[BRES](#bres)|BR
[BSET](#bset)|BS
[BTEST](#btest)|BTE
[BTOGL](#btogl)|BTO
[CHAR](#char)|CH
[CLS](#cls)|CL
[CONST](#const)|CO 
[DATA](#data)|DA
[DEC](#dec)|DE
[DIR](#dir)|DI
[DO](#do)|DO
[DROP](#drop)|DR
[DUMP](#dump)|DU 
[END](#end)|EN
[ERASE](#erase)|ER
[FOR](#for)|FO
[FORGET](#forget)|FORG
[FREE](#free)|FR
[GET](#get)|GE
[GOSUB](#gosub)|GOS
[GOTO](#goto)|GOT
[GPIOA](#gpiox)|GPIOA
[GPIOB](#gpiox)|GPIOB
[GPIOC](#gpiox)|GPIOC
[HEX](#hex)|HE
[IF](#if)|IF
[IN](#in)|IN
[INPUT](#input)|INP
[INPUT_ANA](#input-xxx)|INPUT_A
[INPUT_FLOAT](#input-xxx)|INPUT_F
[INPUT_PD](#input-xxx)|INPUT_PD
[INPUT_PU](#input-xxx)|INPUT_PU
[INVERT](#invert)|INV
[KEY](#key)|KE
[LET](#let)|LE
[LIST](#list)|LI
[LOAD](#load)|LO
[LOCATE](#locate)|LOA
[LSHIFT](#lshift)|LS
[NEW](#new)|NEW
[NEXT](#next)|NE
[NOT](#not)|NO
[OR](#or)|OR
[OUT](#out)|OU
[OUTPUT_AFOD](#output-xxx)|OUTPUT_AF
[OUTPUT_AFPP](#output-xxx)|OUTPUT_AFP
[OUTPUT_OD](#output-xxx)|OUTPUT_O
[OUTPUT_PP](#output-xxx)|OUTPUT_P
[PAD](#pad)|PA
[PAUSE](#pause)|PA
[PEEKB](#peekx)|PE
[PEEKH](#peekx)|PEEKH 
[PEEKW](#peekx)|PEEKW
[PMODE](#pmode)|PM
[POKEB](#pokex)|PO
[POKEH](#pokex)|POKEH
[POKEW](#pokex)|POKEW
[POP](#pop)|POP
[PRINT](#print)|?
[PUSH](#push)|PU
[PUT](#put)|PUT
[QKEY](#qkey)|QK
[RANDOMIZE](#randomize)|RA 
[READ](#read)|REA
[REM](#remark)|'
[RESTORE](#restore)|RES
[RETURN](#return)|RET
[RND](#rnd)|RN
[RSHIFT](#rshift)|RS
[RUN](#run)|RU
[SAVE](#save)|SA
[SERVO_INIT](#servo-init)|SE
[SERVO_OFF](#servo-off)|SERVO_O
[SERVO_POS](#servo-pos)|SERVO_P
[SLEEP](#sleep)|SL
[SPC](#space)|SP
[SPI_DSEL](#spi-dsel)|SPI_D
[SPI_INIT](#spi-init)|SPI_I
[SPI_READ](#spi-read)|SPI_R
[SPI_SEL](#spi-sel)|SPI_S
[SPI_WRITE](#spi-write)|SPI_W 
[STEP](#step)|STE
[STOP](#stop)|ST
[STORE](#store)|STO
[TAB](#tab)|TA
[THEN](#then)|TH
[TICKS](#ticks)|TI
[TIMEOUT](#timeout)|TIMEO
[TIMER](#timer)|TIMER
[TO](#to)|TO
[TONE](#tone)|TON
[TONE_INIT](#toneinit)|TONE_
[TRACE](#trace)|TR
[UBOUND](#ubound)|UB
[UFLASH](#uflash)|UF
[UNTIL](#until)|UN
[WAIT](#wait)|WA
[WORDS](#words)|WO
[XOR](#xor)|XO
[XPOS](#xpos)|XP
[YPOS](#ypos)|YP 

<hr>
<a id="abs"></a>
### ABS(*expr*)  {C,P}

Return the absolute value of argument. 
```
? abs(-45)
 45
READY
```
[index](#index)
<a id="adcon"></a>
### ADC 0|1 {C,P}
Enable **1** or disable **0** the analog/digital converter.
```
pmode gpioa,0,input_ana 'set pin mode GPIOA:0       
READY
adc 1 ' enable ADC 
READY
? ana(0)
2291 
READY
? ana(16) ' read internal MCU temp. sensor.
1619 
READY
adc 0
READY
```
Disabling the ADC reduce power comsumption.

[index](#index)
<a id="adcread"></a>
### ANA(*expr*) {C,P}
Read ADC channel specified by *expr*. There is 18 channels {0..17}. Channel 16 is internal temperature sensor and 17 an internal voltage reference. For this version of *blue pill tiny BASIC* external analog channels are limited to pins {A0:A7,B0:B1}. 
```
5 REM ADC TEST 
10 CLS 
20 ADC 1 
30 T=0 B=ANA(16) PAUSE 100 
40 D=B
50 T=ANA(16) LOCATE 1,1 ? "TEMP:", T ;"DELTA:",D,"    "
60 D=ABS(T-B)
70 B=T 
80 PAUSE 500 
90 IF NOT QKEY THEN GOTO 50 
100 K=ASC(KEY)
110 CLS 
120 B=ANA(0)  D=0 PAUSE 100   
130 A=ANA(0) LOCATE 1,1 ? "ANA0:",A,"   DELTA: ",D,"   "
140 D=ABS(A-B) B=A 
150 PAUSE 500
160 IF NOT QKEY THEN GOTO 130 
170 K=ASC(KEY)
180 ADC 0 
190 END 
```
[index](#index)
<a id="and"></a>
### AND(*expr1*,*expr2*) {C,P}
This function return binary AND operation between *expr1* and *expr2*.  
```
? and(4,6)
   4
READY 
? and(255,127)
 127
READY
```
[index](#index)
<a id="asc"></a>
### ASC(*string*|*char*) {C,P}
This function the  **ASCII** of its argument. If the argument is a string it return the first character code.
```
? ASC("hello")
104 
READY
? ASC(\Z)
90 
READY
```
[index](#index)
<a id="autorun"></a>
### AUTORUN *"file"*  {C}
This command select a file to be auto executed a power up or reset. The program must be save in de flash file system with command [SAVE](#save).
```
LIST
5 REM  BLINK GREEN LED ON BLUE PILL 
10 BLINK 
20 OUT GPIOC ,13 ,0 
30 PAUSE 200 
40 OUT GPIOC ,13 ,1 
50 PAUSE 200 
60 GOTO BLINK 
READY
SAVE "blink"
file size: 137 bytes

READY
autorun "blink" 
READY

user reboot!

blue pill tiny BASIC, version 1.0
file size: 137 bytes

```
The blink program has been save then define as the autorun program. Pressing the reset button on the card load an execute this program. The program can be stopped pressing **&lt;CTRL-B&gt;** at terminal.

[index](#index)
<a id="awu"></a>
### AWU *expr*  {C,P}
*Auto Wake Up* command is used to place the MCU in deep sleep. This commande use the internal **LSI** oscillator and the **IWDG** timer. When the **IWDG** timer expire the MCU is resetted. This command is used to reduce power consumtion to minimum. *expr* must be in {0..26214}. This number is delay in milliseconds. 
```
awu 0  ' minimum delay 

blue pill tiny BASIC, version 1.0
READY
awu 26214 ' maximum delay 

blue pill tiny BASIC, version 1.0
READY
```
 See also [SLEEP](#sleep)

 [index](#index)
<a id="bit"></a>
### BIT(*expr*) {C,P}
This function return 2^*expr*  (2 power n). *expr* in range {0..31}.  
```
for i=0 to 31 : ? bit(i), next i
1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216 33554432 67108864 134217728 268435456 536870912 1073741824 -2147483648 
READY
```
[index](#index)

<a id="bres"></a>
### BRES addr,mask {C,P}
This command set bits that are at **1** in the *mask*. 
```
bres gpioc+$c,bit(13)
READY
```
The above command light the green LED on blue pill.

[index](#index)
<a id="bset"></a>
### BSET addr,mask  {C,P}
This command reset bits that are at **1** in the *mask*. 
```
bset gpioc+$c,bit(13)
READY
```
The above command turn off the green LED on blue pill.

[index](#index)
<a id="btest"></a>
### BTEST(addr,bit) {C,P}
This function return the state of a *bit* in a special function register or RAM address. 
```
? btest(gpioc+$c,13)
0 
READY
bset gpioc+$c,bit(13) ? btest(gpioc+$c,13)
1 
READY
```

[index](#index)
<a id="btogl"></a>
### BTOGL addr,mask  {C,P}
This command invert the state of all bits that are at **1** in the *mask*. 
```
btogl gpioc+$c,bit(13) ? btest(gpioc+$c,13)
1 
READY
btogl gpioc+$c,bit(13) ? btest(gpioc+$c,13)
0 
READY
```
The above command invert the state of green LED on blue pill.

[index](#index)

<a id="char"></a>
### CHAR(*expr*) {C,P}
This function return the ASCII character corresponding to the value of *expr*. The value of *expr* is masked to keep only the 7 least significant bits. The token type returned by this function is **TK_CHAR**  which can't be affected to a variable it can only be use as [PRINT](#print) output. See also [ASC](#asc).
```
for a=32 to 126:? char(a),:next a
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
READY
```
[index](#index)
<a id="cls"></a>
### CLS {C,P}
This commande clear terminal screen an move cursor to top-left corner.

[index](#index)
<a id="const"></a>
### CONST name=value [, name=value] {P}
This command is used to define symbolic constants that can be refered by their name in the program. Constants names are *letters* and *'_'* character only. The name must be at least 2 characters and at most 6. Theses constants are created at run time and stored in space not used by the program. So their number is limited by free space. This free space is also shared by **@** array variable.
```
hex list
5 REM   BASE ADDRESS OF USART2 AND 3
10 CONST UART_B =$40004400 ,UART_C =$40004800 
20 HEX PRINT "usart2 status register value: ",PEEKH (UART_B )
30 PRINT "usart2 data register: ",PEEKB (UART_B +$4 )
READY
run
usart2 status register value: $0 
usart2 data register: $0 
READY
```
After line 10 **UART_B** and **UART_C** can be used to access usart registers.

[index](#index)
<a id="data"></a>
### DATA number [,number]  {P}
The keyword **DATA** is used to embed data in program. This information is accessed by [READ](#read) function. The interpreter skip those lines. See also [READ](#read) and [RESTORE](#restore).

[index](#index)
<a id="dec"></a>
### DEC {C,P}
This set **BASE** system variable to decimal. This variable define how numerical value are formatted by [PRINT](#print). See also [HEX](#hex)
```
a=25  hex ? a, dec ? a
$19 25 
READY
```
[index](#index)
<a id="dir"></a>
### DIR {C}
This command display list of programs saved in flash memory. See also [SAVE](#save), [LOAD](#load),[FORGET](#forget) and [AUTORUN](#autorun).
```
list
10 REM  servo test
12 REM  channel 1 on A15, channel 2 on B3
14 REM  channel 3 on B4, channel 4 on B5 
15 REM  channel 5 on B8, channel 6 on B9
20 PRINT "select channel 1,2,3,4,5,6"
30 INPUT S 
40 IF S <1 THEN GOTO 20 
50 IF S >6 THEN GOTO 20 
80 SERVO_INIT S 
90 PRINT "set position 1000-2000"
100 INPUT P 
110 IF P =ASC (\N)THEN SERVO_OFF S GOTO 20 
120 IF P =ASC (\Q)THEN GOTO 150 
130 SERVO_POS S ,P 
140 GOTO 90 
150 SERVO_OFF S 
160 END 
READY
save "servo-test"
file size: 362 bytes

READY
dir
servo-test     362 

               1 files

READY

```
[index](#index)
<a id="do"></a>
### DO {C,P}
This keyword introduce **DO...UNTIL _relation_** control structure. See also [UNTIL](#until).
```
LIST
10 REM  DO ... LOOP demo 
15 A =1 
20 DO 
30 A =A *2 
40 PRINT A ,
50 UNTIL A >1024 
READY
RUN
2 4 8 16 32 64 128 256 512 1024 2048 
READY
``` 
[index](#index)
<a id="drop"></a>
### DROP *n*  {C,P} 
This command is to discard *n* elements from the arguments stack. The virtual machine use an arguments stack. There is a few words that enable to manipulate this stack. See also [PUSH](#push),[POP](#pop),[GET](#get) and [PUT](#put).
```
list
10 INPUT A ,B 
20 PUSH A ,B GOSUB PROD 
30 PRINT POP 
40 GOTO 10
48 ' compute product of 2 top elements on stack
59 ' return product on stack. 
50 PROD PUSH POP *POP RETURN 
READY
run
A=23
B=56
1288 
A=
READY
```
[index](#index)
<a id="dump"></a>
### DUMP adr,count {C}
This is a debuging to examine the containt of memory. The dump start at *adr* and a multiple of 16 bytes are displayed &gt;=*count*.
```
DUMP $20000210,48
           00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 
===============================================================================
$20000210  0A 00 0B 17 20 14 00 02 14 01 00 14 00 12 17 38   ____ __________8
$20000220  14 00 02 14 01 17 1B 1A E4 49 08 00 00 1E 00 08   _________I______
$20000230  17 37 15 36 00 28 00 0B 17 1C 1B 0A 00 00 00 00   _7_6_(__________
$20000240  32 00 12 1A E4 49 08 00 17 38 15 36 09 15 36 17   2____I___8_6__6_
READY
``` 
[index](#index)
<a id="end"></a>
### END {C,P}
 This command terminate a program. It can be place anywhere in a program.See also [STOP](#stop).

[index](#index)
<a id="erase"></a>
### ERASE {C,P}
This command erase the 1KB of user flash memory. All data store there is lost included [AUTORUN](#autorun) information. 

[index](#index)
<a id="for"></a>
### FOR {C,P}
This keyword introduce a **FOR _var=expr_ TO _expr_ [STEP _expr_]** control structure. This is a loop with counter. The loop execute at least once and terminate when _var_ cross the limit.
```
LLIST
5 PRINT #5 
10 FOR A =1 TO 12 
20 FOR B =1 TO 12 
30 PRINT A *B ;
40 NEXT B PRINT 
50 NEXT A 
READY
RUN

1    2    3    4    5    6    7    8    9    10   11   12   
2    4    6    8    10   12   14   16   18   20   22   24   
3    6    9    12   15   18   21   24   27   30   33   36   
4    8    12   16   20   24   28   32   36   40   44   48   
5    10   15   20   25   30   35   40   45   50   55   60   
6    12   18   24   30   36   42   48   54   60   66   72   
7    14   21   28   35   42   49   56   63   70   77   84   
8    16   24   32   40   48   56   64   72   80   88   96   
9    18   27   36   45   54   63   72   81   90   99   108  
10   20   30   40   50   60   70   80   90   100  110  120  
11   22   33   44   55   66   77   88   99   110  121  132  
12   24   36   48   60   72   84   96   108  120  132  144  
READY
```
 
[index](#index)
<a id="forget"></a>
###  FORGET ["name"] {C}
This command is used to delete one or more files saved in flash. Without the optional *"name"* argument all files are delete. With given name this file is deleted and all the following ones. See also [SAVE](#save),[LOAD](#load),[DIR](#dir).

[index](#index)
<a id="free"></a>
### FREE {C,P}
This function return number of bytes free in program space.
```
blue pill tiny BASIC, version 1.0
READY
? free
19360 
READY
load "servo-test"
file size: 362 bytes

READY
? free
18998 
READY
```
[index](#index)
<a id="get"></a>
### GET *n* {C,P}
This function return the value of *n*th element on arguments stack. *n* is the position, the top element being indice by **0**.
```
READY
push 128,256 ? get(0),get(1) drop 2
256 128 
READY
```
See also [DROP](#drop), [POP](#pop), [PUSH](#push), [PUT](#put).

[index](#index)
<a id="gosub"></a>
### GOSUB *expr*|*label*  {P}
This keyword is used to call a subroutine. A subroutine can be called by a line number *expr* or a name *label*.  Calling by name is slightly faster at execution. 
Search for target line number is done from start of program. Hence the farther the target the longer the search. It may be advantagous to place subroutines at the begining. 

See also keyword [RETURN](#return)
<a id="branch"></a>
```
list
5 REM  Label test 
10 A =0 T =TICKS 
14 REM  GOSUB and GOTO by line # 
20 GOSUB 1000 
30 IF A >10000 GOTO 50 
40 GOTO 20 
50 PRINT CHAR (13 ),TICKS -T ,"MSEC"
54 REM  GOSUB and GOTO by label 
60 A =0 :T =TICKS 
70 LOOP GOSUB CNTR 
80 IF A >10000 PRINT CHAR (13 ),TICKS -T ,"MSEC":END 
90 GOTO LOOP 
1000 CNTR 
1010 A =A +1 
1020 RETURN 
READY
run

414 MSEC

366 MSEC
READY
```
[index](#index)
<a id="goto"></a>
### GOTO *expr*|*label* {P}
This keyword is use to jump to a specified line number *expr* or *label*. Labels are symbolic name given to GOTO target in replacement of a line number. See the following [example](#branch) for usage of GOTO with line number and label. A label name must follow immediately the line number and is limited 6 characters in letters and **'_'**. 

[index](#index)
<a id="gpiox"></a>
### GPIOx  {C,P}
There is 3 system constants that identify the general purpose input/output port. **GPIOA**, **GPIOB** and **GPIOC**. These constantes are used as arguments to [IN](#in), [OUT](#out) and [PMODE](#pmode) commands. These constants are the register set base address that control GPIO port. 

[index](#index)
<a id="hex"></a>
### HEX {C,P}
This commande set system variable **BASE** to 16. This system variable is use to format numeric output by [PRINT](#print). See also [DEC](#dec).
```
a=25  hex ? a, dec ? a
$19 25 
READY
```
[index](#index)
<a id="if"></a>
### IF *relation*  {C,P}
This keyword is used for conditionnal **IF...THEN** structure. The commands that follows the [THEN](#then) keyword are only executed if the *relation* is true. Anything that is not **zero** is considered **true**.
```
input "input 'F' or 'T'"v: if v=asc(\T) then ? "This is 'T'" 
input 'F' or 'T'=t
This is 'T'
READY
input "input 'F' or 'T'"v: if v=asc(\T) then ? "This is 'T'"
input 'F' or 'T'=f
READY
```
In the second try 'f' was entered so the relation **v=asc(\T)** was false hence the statement following **THEN** was not executed.

[index](#index)
<a id="in"></a>
### IN(*gpiox*,*pin*)
This function is used to read the state of a digital input pin. *gpiox* is one of the [GPIOx](#gpiox) system constant that identify the PORT and *pin* is the pin number as identify on the **blue pill** {0.15}. For example if GPIOB:0 is configured as a digital the to read it use **GPIOB** as first parameter and **0** as second.
See also [PMODE](#pmode) and [OUT](#out).
```
? in(gpioa,0)
1 
READY
``` 

[index](#index)
<a id="input"></a>
### INPUT ["string"]var [,["string"]var]
This commande is use to read a value entered by user. The value is stored in *var*. The optional *"string"* argument is printed as a prompt when given. More than one value can be entered by command. Each stored in a different variable. 
```
input "age"a,"gender (M|W)"s
age=45
gender (M|W)=M
READY
? A,CHAR(S)
45 M
READY
```
If a letter is entered by user the letter is uppercased and the ASCII value stored in the variable. 

[index](#index)
<a id="input-xxx"></a>
### INPUT_xxx {C,P}
There is 4 system constants used to define GPIO pin configuration. These constants are used as parameter for [PMODE](#pmode) commande. 

* **INPUT_ANA** The pin is configured as analog input pin. 
* **INPUT_FLOAT** The pin is configured as digital input an left floating. 
* **INPUT_PD** The pin is configured as digital input with a pull down resistor.
* **INPUT_PU** The pin is configured as digital input with a pull up resistor.

See also [PMODE](#pmode) and [OUTPUT_xxx](#output-xxx) .

[index](#index)
<a id="invert"></a>
### INVERT(*expr*) {C,P}
This fonction bit complement also named *one's complement* of *expr*.
```
? INVERT(-1)
0 
READY
? INVERT(-6)
5 
READY
hex ? invert($aa)
$FFFFFF55 
READY
``` 

[index](#index)
<a id="key"></a>
### KEY 
This command wait for a key from terminal and return it as **TK_CHAR** token type. The [ASC](#asc) function must be used to assign this character to a variable else a syntax error is displayed. 
```
a=key
Runtime error: syntax error

READY
a=asc(key)
READY
? char(a)
b
READY
? key
z
READY
```
The [PRINT](#print) command accept **TK_CHAR** type as argument.

[index](#index)
<a id="let"></a>
### LET var=*expr* [, var=*expr]*  {C,P}
The keyword **LET** is used to assign a value to a variable. Is usage is optional.
```
LET A=45 
READY
B=2
READY
? A*B
90 
READY
```

[index](#index)
<a id="list"></a>
### LIST [[line] [- [line]]]
This command is use to display the program in RAM on terminal. Without argument it list all lines. 

* **LIST - line** Display from first line to line number given in argument. 
* **LIST line**  Display only the given line. 
* **LIST line - ** Display from given line to last one. 
* **LIST line - line** Display start at first line and end at last line.   

The program is stored in tokenized form. To list it must be decompiled. The output may differ from what was typed by the user. Among difference **?** is listed as **PRINT** and **'** is listed as **REM**. Some system constants may also bear the wrong name if 2 system constants have the same value the first one found see its name displayed. This is so because the decompiler search dictionary by token type and token attribute (i.e. value). All system constants have the **TK_SCONST** type and their attribute is their value. Hence the first entry that match **TK_SCONST** and **value** is a good match. 

[index](#index)
<a id="load"></a>
### LOAD "file-name" {C}
This command is to load in RAM a program saved in flash file system. 
```
new
READY
list
READY
load "data-test"
file size: 95 bytes

READY
list
10 RESTORE 40 
20 PRINT READ 
22 RESTORE 
24 PRINT READ ,READ ,READ ,READ 
28 DATA -1 ,-2 
30 DATA 1 ,2 
40 DATA 3 ,4 
READY
```
See also [DIR](#dir),[FORGET](#forget) and [SAVE](#save).

[index](#index)
<a id="locate"></a>
### LOCATE *line*,*column*
This command is used to move the terminal cursor at a specified position at *line*, *column* coordinates. The following program use this command (line 600) to display LED intensity a top left corner on terminal.
```
5 REM  random display
10 RANDOM 
20 CLS 
30 LOCATE RND (25 ),RND (80 )
40 PRINT CHAR (RND (97 )+32 )
50 GOTO 30 
READY
```
[index](#index)
<a id="lshift"></a>
###  LSHIFT(*expr1*,*expr2*) {C,P}
This function left shift *expr1* value of *expr2* bits. This is equialent to a multiplication by a power of 2. 
```
? lshift(1,2), lshift (64,3)
4 512 
READY
```
[index](#index)
<a id="new"></a>
### NEW  {C}
This command is used to clear program space before writing a new program.

[index](#index)
<a id=""></a>
### NEXT 
Keyword that close [FOR...NEXT](#for) loop. 

[index](#index)
<a id="not"></a>
### NOT *relation* 
Keyword use to negate de result of a releation after a [IF](#if) or an [UNTIL](#until).  This is a logical negation not a binary negation. For a binary negation see [INVERT](#invert).

[index](#index)
<a id="or"></a>
### OR(*expr1*,*expr2*) {C,P}
This function do a binary **OR** between the 2 *expr* given as arguments. 
```
hex ? or(&101,&10), or(-&101,&10)
$7 $FFFFFFFB 
READY
```
[index](#index)
<a id="out"></a>
### OUT *gpiox*,*pin*,*0|1*  {C,P}
This command set the state of a digital output pin to **0** or **1**. [gpiox](#gpiox) is one of the system constant that identify the port. *pin* is one of the board pin {0..15}.
```
PMODE GPIOC,13,OUTPUT_OD : GREEN LED PIN
READY
OUT GPIOC,13,0 : REM LED ON 
READY
OUT GPIOC,13,1 : REM LED OFF
READY
``` 
[index](#index)
<a id="output-xxx"></a>
### OUTPUT_xxx {C,P}
There is 4 system constants that define digital pin output mode:

* **OUTPUT_OD**  Open drain digital output mode. 
* **OUTPUT_PP**  Push pull digital output mode. 
* **OUTPUT_AFOD** Alternate function open drain digital output.
* **OUTPUT_AFPP** Alternate function push pull digital output.

This constants are to be used with [PMODE](#pmode) command.

[index](#index)
<a id="pad"></a>
### PAD {C,P}
The pad is a 128 bytes memory buffer used by the interpreter but can also be used by application program as a transaction buffer, for example see [spi example](#spi-example). This keyword return the address of this memory buffer.

[index](#index)
<a id="pause"></a>
### PAUSE *expr* {C,P}
This command is to suspend execution for *expr* milliseconds. 
```
DO OUT GPIOC,13,1 PAUSE 50 OUT GPIOC,13,0 PAUSE 50 UNTIL QKEY K=ASC(KEY)
READY
```
This command line example blink the board LED 10/sec until a key is pressed.

[index](#index)
<a id="peekx"></a>
### PEEKx(*adr*) {C,P}
These functions group is to read values from memory or peripheral registers. 
* **PEEKB(*adr*)** Read byte at address *adr*.
* **PEEKH(*adr*)** Read a 16 bits word at *adr*.
* **PEEKW(*adr*)** Read a 32 bits word at *adr*. 
```
HEX ? PEEKB($8000000), PEEKH($8000000), PEEKW($8000000)
$0 $5000 $20005000 
READY
```
This command line example read address 0x800000 which containt the initialisation value of **SP** register. As integer are store in little indian format, the first byte contain 0x0, the 16 bits word contain 0x5000 and the 32 bits value is 0x20005000. This is the address after end of RAM. The first value pushed on stack is stored at 0x20004fffc as **SP** is decremented before the value is pushed.

See also [POKEx](#pokex).

[index](#index)
<a id="pmode"></a>
### PMODE *gpiox*,*pin*,*mode*  
This command is used to configure a digital pin.
* **gpiox** Is one of [GPIOx](#gpiox) system constant identifying the port.
* **pin** Is board pin number {0..15}.
* **mode** Is one of [OUTPUT_xxx](output-xxx) or [INPUT_xxx](#input-xxx) system constant identifying pin configuration mode.
```
5 REM  GPIO test 
10 INPUT "gpio:a,b,c?"G ,"pin"P 
20 G =GPIOA +(G -65 )*1024 :P =AND (P ,15 )
30 PMODE G ,P ,OUTPUT_PP 
40 OUT G ,P ,1 
50 PAUSE 100 
60 OUT G ,P ,0 
70 PAUSE 100 
80 IF NOT QKEY THEN GOTO 30 
90 GOTO 10 
READY
run
gpio:a,b,c?=a
pin=5
READY
```
The program about configure a pin selected by the user and configure it in **OUTPUT_PP** mode and swith its state between **0** and **1** 5 times/sec.

[index](#index)
<a id="pokex"></a>
### POKEx *adr*,*expr* {C,P}
This command is use to set a memory address or peripheral register to specified value *expr*. There 3 such command. 
* **POKEB** To set a byte value.
* **POKEH** To set a 16 bits word value. 
* **POKEW** To set a 32 bits value. 

See also [PEEKx](#peekx).

[index](#index)
<a id="pop"></a>
### POP {C,P}
This function remove to top value from argument stack and return it. This part of commands and functions used to manipulate argument stack.
```
push 1,2,3 : ? pop,pop,pop
3 2 1 
READY
```
As seen above arguments are pop'd in reverse order they where push'd. A stack is a last in, first out data structure. 

[index](#index)
<a id="print"></a>
### PRINT|?  *arg_list* {C,P} 
This command is the most complex of all. It is used to send information to be displayed on terminal. *arg_list* is list of items to be print to terminal. These items are separated by *,* or *;*. The comma separator does nothing special except if it is the last item of the command. In that case it disable the print of a carriabe return. The semi-colon separator on the contrary send the cursor to next colon. Column width may be set anywhere in a print statement by using the **#n** format where *n* is column width in characters. This setting persist until another **#n** is used or to the next warm_start. Other elements of **PRINT** are:
* Numerical expression.
* String. 
* Character or character function. 
* TAB(n) command to move cursor to specified column. 
* SPC(n) command to move cursor right a specified number of spaces.
```
5 REM  PRINT command test
10 REM  set colum width to 6 
20 PRINT #6 
30 REM  PRINT 5 INTEGER aligned to column.
40 FOR I =1 TO 10 :PRINT RND (1000 );:NEXT I 
50 REM  move cursor to column 20 before printing 
60 PRINT CHAR (13 ),TAB (20 ),"Hello world!"
70 REM  move cursor right 5 spaces
80 PRINT "hello",SPC (5 ),"world!"
90 REM  characters argument 
100 PRINT \A,\ ,\B,\ ,\C
READY
run

882   658   514   991   927   32    41    999   876   704   
                   Hello world!
hello     world!
A B C
READY
```
The number formating is dependant for the value of system variable **BASE** see [HEX](#hex) and [DEC](#dec) for more information. 

[index](#index)
<a id="push"></a>
### PUSH *expr* *[,expr]* {C,P}
This is a command to push a list of integers on arguments stack. 
```
10 INPUT A ,B 
20 PUSH A ,B GOSUB PROD 
30 PRINT POP 
40 GOTO 10 
50 PROD PUSH POP *POP RETURN 
READY
run
A=10
B=20
200 
A=
READY
```
This program compute the product of 2 user entered integers.

**CTRL-B** can be used to exit this program. 

See also [POP](#pop).

[index](#index)
<a id="put"></a>
### PUT *slot*,*expr* {C,P}
This is another command to manipulate argument stack. It is used when some values have already been [PUSH](#push)ed on stack. These previously pushed values can be replaced by new values using this command. *slot* is the position where to put the new value. Top of stack is slot **0** and this increment by one going down stack.
```
PUSH 1,2,3 : PUT 0,4 : PUT 1,5 : ? POP,POP,POP
4 5 1 
READY
```
Here **3** as been replaced by **4** and **2** by **5**. 
The result is unpredictable if values are put in slots not previously loaded by [PUSH](#push). See also [GET](#get).

[index](#index)
<a id="qkey"></a>
### QKEY {C,P}
This function is used to check if there is a character available from terminal. 
It return **true** if so.
```
DO ? "press a key when you have enough of it." UNTIL QKEY K=ASC(KEY)
press a key when you have enough of it.
press a key when you have enough of it.
press a key when you have enough of it.
press a key when you have enough of it.
READY 
```

[index](#index)
<a id="randomize"></a>
### RANDOMIZE {C,P}
This command is used to give a new seed to the pseudo random number generator. It is a good practice to use **RANDOMIZE** at the beginning of a program that use [RND](#rnd) function.

[index](#index)
<a id="read"></a>
### READ {P}
This function return the next [DATA](#data) element. It is a fatal error to read past the last element. 
<a id="data-example"></a>
```
10 RESTORE 40 
20 PRINT READ 
22 RESTORE 
24 PRINT READ ,READ ,READ ,READ 
28 DATA -1 ,-2 
30 DATA 1 ,2 
40 DATA 3 ,4 
READY
run
3 
-1 -2 1 2 
READY
```
See also [DATA](#data) and [RESTORE](#restore).

[index](#index)
<a id="remark"></a>
### REM|' {C,P}
This keyword introduce a comment. Comment end with end of line and are skipped by the interpreter. The tick character can be used in place of keyword **REM**.

[index](#index)
<a id="restore"></a>
### RESTORE *[line]*
This command is used to reset [DATA](#data) pointer to first data element if there is no argument or to specified line number if one given. [example](#data-example).
See also [DATA](#data) and [READ](#read).

[index](#index)
<a id="return"></a>
### RETURN {P}
This keyword is used to exit from a sub-routine invoked with [GOSUB](#gosub).

[index](#index)
<a id="rnd"></a>
### RND(*expr*)  {C,P}
This function return a pseudo random integer between **0** and the value of *expr*-1.
```
for i=1 to 10 ? rnd(100), : next i
82 58 14 91 27 32 41 99 76 4 
READY
```

[index](#index)
<a id="rshift"></a>
### RSHIFT(*expr1*,*expr2*) {C,P}
This function shift *expr1* *expr2* bits right. This is a logical shift not an arithmetic one. Bit 31 is replaced by **0**. 
```
a=4096 for i=10 to 1 step -1 a=rshift(a,1) ? a, next i
2048 1024 512 256 128 64 32 16 8 4 
READY
hex a=$ffffffff for i=10to 1 step -1 a=rshift(a,1) ?a, next i
$7FFFFFFF $3FFFFFFF $1FFFFFFF $FFFFFFF $7FFFFFF $3FFFFFF $1FFFFFF $FFFFFF $7FFFFF $3FFFFF 
READY
```

[index](#index)
<a id="run"></a>
### RUN {C}
This command launch the execution of a program already in memory. 

[index](#index)
<a id="save"></a>
### SAVE "file-name" {C}
This command is used to save program in memory to flash file system. 
```
list
10 RESTORE 40 
20 PRINT READ 
22 RESTORE 
24 PRINT READ ,READ ,READ ,READ 
28 DATA -1 ,-2 
30 DATA 1 ,2 
40 DATA 3 ,4 
READY
dir

               0 files

READY
save "data-test"
file size: 95 bytes

READY
dir
data-test      95 

               1 files

READY
```
See also [LOAD](#load), [DIR](#dir) and [FORGET](#forget).

[index](#index)
<a id="servo-init"></a>
### SERVO_INIT *n* {C,P}
 This command is to initialize one of the 6 servo-motor output.
 Output are on A15,B3,B4,B5,B8 and B9. These output are configured in *open drain* and require an external *pull up* connector to same power as the servo-motor. Usual voltage used by small servo-motor is 5 volt. 

 * **NOTE:** [TONE](#tone) can be used at the same time as servo-motor channels 5 and 6. This is because they both use **TIMER4**. 

 See also [SERVO_POS](#servo-pos) and [SERVO_OFF](#servo-off)
```
list
10 REM  servo test
12 REM  channel 1 on A15, channel 2 on B3
14 REM  channel 3 on B4, channel 4 on B5 
15 REM  channel 5 on B8, channel 6 on B9 
20 PRINT "select channel 1,2,3,4,5,6"
30 INPUT S 
40 IF S <1 THEN GOTO 20 
50 IF S >4 THEN GOTO 20 
80 SERVO_INIT S 
90 PRINT "set position 1000-2000"
100 INPUT P 
110 IF P =ASC (\N)THEN SERVO_OFF S GOTO 20 
120 IF P =ASC (\Q)THEN GOTO 150 
130 SERVO_POS S ,P 
140 GOTO 90 
150 SERVO_OFF S 
160 END 
READY
```
[index](#index)
<a id="servo-off"></a>
### SERVO_OFF *n* {C,P}
This command is to turn off a servo-motor channel. See also [SERVO_INIT](#servo-init)

[index](#index)
<a id="servo-pos"></a>
### SERVO_POS *channel, position* {C,P}
Thi command is to control servo-motor position. Usual values for small servo-motors is in {1000...2000} range. See also [SERVO_INIT](#servo-init).

[index](#index)
<a id="sleep"></a>
### SLEEP  {C,P}
This command place the MCU in stop mode. In this mode consumtion is at minimum. A reset must be used to restart the MCU.

[index](#index)
<a id="space"></a>
### SPC(*n*)  {C,P}
This command is used inside [PRINT](#print) to move terminal cursor right *n* spaces.

[index](#index)
<a id="spi-init></a>
### SPI_INIT *channel* {C,P}
