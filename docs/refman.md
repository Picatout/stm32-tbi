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
[GPIOA](#gpio)|GPIOA
[GPIOB](#gpio)|GPIOB
[GPIOC](#gpio)|GPIOC
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
[LOCATE](#locate)|LO
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
[SPIEN](#spien)|SPIE
[SPIRD](#spird)|SPIR
[SPISEL](#spisel)|SPIS
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
