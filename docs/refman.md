<!-- 
Copyright Jacques Deschênes, 2021
Ce document fait parti du projet stm32-tbi
https://github.com/picatout/stm32-tbi
-->
[-&gt;version française](tbi_reference.md)
# Blue pill Tiny BASIC reference manual
<a id="index-princ"></a>
## main index

* [data types](#data-types)

* [Variables](#variables)

* [user Constants](#userconst)

* [Arithmetic expressions](#expressions)

* [Syntax](#syntaxe)

* [numerical bases](#bases)

* [Command line interface](#cli)

* [Files](#fichiers)

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
### user Constants
The keyword [CONST](#const) is use to defines symbolics constants. A constant name must have at least 2 characters and at most 6. The name is limited to letters plus *'_'** character. Below an exemple of its usage. 

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

There 5 arithmetic operators by precedence order:
1. **'-'**  unary minus, highest precedence.
1.  __'*'__ mulitiplication, **'/'** division, **'%'** modulo 
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
The character code used is [ASCII](https://en.wikipedia.org/wiki/ASCII) set {0..127.

A program is a list of numbered lines. Valid Line number range is {1..65535}. If a line without number is entered it is taken as an immediate command and executed. A line with a number is compiled to tokens list and store un RAM as part of a program.

Blue pill Tiny BASIC authorize *labels* as [GOSUB](#gosub) and [GOTO](#goto) target instead of a line number. It is faster at execution to use a *label* instead of a line number. 

*Label* name obey the same form as constants names, minimum 2 characters and maximum 6. Only letters plus **'_'**. character. 

The *label* must follow immediately the line number. 

### statement 

A *statement* is a command which may be followed by one or more arguments separated by a comma **','**. 

There may be more than one statement per line separated by **':'** character. This statement separator is optional in most case as the interpreter knows where a command end in most cases. 

Statement can be entered in any case but the compiler convert all letters to uppercase. 

*keyword* can be shortened at least 2 characters provide there is no confusion between to commands. Using short form for *keyword* doesn't doesn't save memory space or improve execution speed as source code is compile in tokens before beeing store in program space. 

[PRINT](#print) can use **'?'**  as a remplacement for its name. 

[REM](#remark) can use tick character **'\''** as a replacement for ist name. 

An end of line mark the end of a statement except for control structures [FOR..NEXT](#for) and [DO..UNTIL](#do) which can expand many lines up to their associated closing *keyword*.

[main index](#index-princ)
<a id="bases"></a>
## Numerical bases
Integer can be entered in 3 differents bases, decimal, hexadecimal and binary.
The [PRINT](#print) command only output integer in decimal or hexadecimal.

Here de lexical form of integers. In the following what is between **'['** and **']'** is optional. The **'+'** character means the charater must appear at least one time. A character between single quote is *literal*. **::=** introduce a definition.

*  digit ::= '0','1','2','3','4','5','6','7','8','9'
*  hex_digit ::= digit,'A','B','C','D','E','F' 
*  decimal integer ::=  ['+'|'-']digit+
*  hexadecimal integer ::= ['+'|'-']'$'hex_digit+
*  binary integer ::= ['+'|'-']'&'('0'|'1')+   

som examples:
```
-13534 ' negative decimal integer 
$ff0f  ' hexadecimal integer  
-&101   ' binary integer for -5 decimal. 
```
[main index](#index-princ)
<a id="cli"></a>
## Command line interface 
The communication between **blue pill** and the terminal emulator on the PC is done via a serial port. The terminal emulator must VT100 compatible. There is no application to install on the PC other than this terminal emulator. 

At power up or reset of **blue pill** the software name and version is displayed on the terminal followed on the next line by the word **READY**. From then commands and be entered on the terminal. 
```
blue pill tiny BASIC, version 1.0
READY
```
A command line is ended when the &lt;ENTER&gt; key is pressed. Then the text line is compiled to tokens list. If the first token is a line number the compiler insert this line in the program area. 

* The line is inserted in increasing line number. 
* An empty line remove an aldready existing one with the same number.
* If a line with the same number already exist it is replace by the new version.

If there is no line number this is executed immediately.

Some commands are valid only in programs others only in immediate mode. Using a statement in wrong context in an error report and end of execution.

Programs stored in RAM are lost at power cycle or reset. 

* **&lt;CTRL-C&gt; result in such a reboot, *cold start*.
* **&lt;CTLR-B&gt; result in program interruption but no reboot, *warm start*.

[main index](#index-princ)
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
## Vocubulary index 
name|short form
-|-
[ABS](#abs)|AB
[ANA](#adcread)|AN
[ADC](#adcon)|ADCO
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

