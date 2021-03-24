<!-- 
Copyright Jacques Deschênes, 2021
Ce document fait parti du projet stm32-tbi
https://github.com/picatout/stm32-tbi
-->
<a id="top"></a>
[-&gt;français](manuel_util_tb.md)
# Blue pill Tiny BASIC user manual

<a id="index"></a>
## index

* [Introduction](#intro)

* [Installation](#installation)

* [Use](#utilisation)

* [Command line](#cli)

* [Editor](#editeur)

* [Files](#fichiers)

* [File transfer](#send)

* [Programs examples](#exemples)

<a id="intro"></a>
### Introduction 
Blue pill Tiny BASIC is a simple language nevertheless it can be used to configure any peripherals and progam interrupt service routines in BASIC. The tiny BASIC system istelf use 4 interrupts that can't modified by user.

* systick is used to count milliseconds. This count is available to programs trough **TICKS** function. The same interrupt operate a count down timer. This timer is initialize by progrom with **TIMER** command.
* The system communicate with user via a serial port on the PC. The MCU USART1 device is used for this purpose. The system use at 16 bytes circular queue with an interrupt IRQ37 triggered each time the USART receive a character.
* USART2 and USART3 if initialized in program use also an interrupt triggered on character received.

* All others IRQ {0..59} are available to programs.

L'Objectif de ce manuel est de présenter l'installation et l'utilisation de *blue pill Tiny BASIC. 

For information on language itself one must read the [tiny BASIC reference manual](refman.md).

### commands short form 
In the [tiny BASIC reference manual](refman.md), in the table listing commands the right column give command abreviate form. This save typing but not memory as the source code is compiled to token list before being store in memory.

### Progam execution 
A list of statement entered on the command line is immediately executed if there is no line number given. Otherwise the line is considered as part of the program and store in program space. 
```
PRINT 3*4 REM immediate command
12 
READY
10 RPINT 3*4 REM STORED 
``` 

[index](#index)

<a id="installation"></a>
## Installing on blue pill
Installing the [pre-compiled binary](../build/stm32-tbi.bin) is quite simple. 

### required 

* **stlink-tools**  This is avaible in Ubuntu 20.04 and can be installed with<br>
__sudo apt install stlink-tools.__<br>
* **STLINK-V2** programmer is required, cheap clone are available from onlin stores.

Before flashing the firware the *STV2_DUNGLE_SN** in [Makefile](../Makefile) must be set with the serial number of your programmer. The get this serial number use the following command:<br>
**st-info --probe**<br>
```
picatout:~/github/stm32-tbi$ st-info --probe
Found 1 stlink programmers
 serial: 483f6e066772574857351967
openocd: "\x48\x3f\x6e\x06\x67\x72\x57\x48\x57\x35\x19\x67"
  flash: 65536 (pagesize: 1024)
   sram: 20480
 chipid: 0x0410
  descr: F1 Medium-density device
```
### flashing the blue pill
From root directory type command:<br>
**make flash**<br>
```
picatout:~/github/stm32-tbi$ make flash
st-flash --serial=483f6e066772574857351967 erase 
st-flash 1.6.0
2021-03-24T10:16:41 INFO common.c: Loading device parameters....
2021-03-24T10:16:41 INFO common.c: Device connected is: F1 Medium-density device, id 0x20036410
2021-03-24T10:16:41 INFO common.c: SRAM size: 0x5000 bytes (20 KiB), Flash: 0x10000 bytes (64 KiB) in pages of 1024 bytes
Mass erasing
st-flash  --serial=483f6e066772574857351967  write build/stm32-tbi.bin 0x8000000
st-flash 1.6.0
2021-03-24T10:16:41 INFO common.c: Loading device parameters....
2021-03-24T10:16:41 INFO common.c: Device connected is: F1 Medium-density device, id 0x20036410
2021-03-24T10:16:41 INFO common.c: SRAM size: 0x5000 bytes (20 KiB), Flash: 0x10000 bytes (64 KiB) in pages of 1024 bytes
2021-03-24T10:16:41 INFO common.c: Ignoring 1024 bytes of 0xff at end of file
2021-03-24T10:16:41 INFO common.c: Attempting to write 19456 (0x4c00) bytes to stm32 address: 134217728 (0x8000000)
Flash page at addr: 0x08004800 erased
2021-03-24T10:16:41 INFO common.c: Finished erasing 19 pages of 1024 (0x400) bytes
2021-03-24T10:16:41 INFO common.c: Starting Flash write for VL/F0/F3/F1_XL core id
2021-03-24T10:16:41 INFO flash_loader.c: Successfully loaded flash loader in sram
 19/19 pages written
2021-03-24T10:16:42 INFO common.c: Starting verification of write complete
2021-03-24T10:16:43 INFO common.c: Flash written and verified! jolly good!
```
The binary in build directory will be flashed in blue pill. If the last line display **jolly good!**  The pill is ready to be used. 

[index](#index)

<a id="utilisation"></a>
## Use
The blue communicate with the PC using pins **A9 for TX** and **A10 for RX**. This is USART1 configured as 115200 BAUD 8 bits no parity 1 stop bit. 
![connection](montage.jpg)<br>
Once the tiny BASIC is flashed on the pill the STLINK-V2 is not needed anymore except if you want to use it as a power supply. An external more powerfull power supply is preferable if you want to use devices that draw musch current like servo-motors. An external 5 volt power supply must be connected to a pin labelled **5v**. A voltage regulator on the pill will lower it to 3.3 volt for the MCU. 

[index](#index)

<a id="cli"></a>
## Command line 
The command line as an editing facility an enable user to enter programs and edit them as well as enter direct command. A VT100 terminal emulator is required on the PC. **GTKterm** or **minicom** on linux will do the job. Here is what one see on the therminal at pill power up or reset.
![terminal](gtkterm-capture.png)<br>
From there the user can enter direct commands or edit a program. Program lines start with a line number.  

* A line number is in the range **{1..65535}**.
* If a line with an already existing number is entered it replace the previous one. 
* Lines are inserted in numeric order. 
* A line containing only its number delete an existing one with the same number.

Some command are only valid in direct command mode, others only in programs. Using a command in bad context result in error message an fall back to command line. 

A Program in memory is lost at power down or reset unless it is saved in a file. There is a small file system available for that. see [reference manual](refman.md) for more information.

[index](#index)

<a id="editeur"></a>
## Editor
**Blue pill tiny BASIC** is designed for minimum requirement on PC side. No application to install on the PC except for the terminal emulator used as user interface with the **blue pill tiny BASIC.** 

A line of text entered on terminal is considered completed a &lt;ENTER&gt; key press. The text is then compiled. If the line begin with a line number the compiled source is store in program space otherwise it is executed immediately.

The **LIST** command print the program in memory to terminal.

### Editor facility 
* An already entered line can be modified by entering is line number followed by &lt;CTRL-E&gt;<br>The text is displayed for edition.
* An already entered line can be deleted by entering is number followed by &lt;ENTER&gt;.
* New line are inserted in line number order.
### hot keys
* **&lt;CTRL-D&gt;** Delete line in editor.
* **&lt;CTRL-E&gt;** After a number display the line for edtion.
* **&lt;CTRL-I&gt;** Switch editor mode to **insert**. In this mode the cursor is a vertal blinking line.
* **&lt;CTRL-O&gt;** Switch editor mode ot **overwrite**. In this mode the cursor is a blinking block. This mode is the default one.
* **&lt;CTRL-R&gt;** Display last entered line for edition. Fast way to repeat the last entered command.
* **&lt;HOME&gt;** Move cursor to start of line.
* **&lt;END&gt;** Move cursor to end of line.
* **&lt;BS&gt;** Delete character left of cursor.
* **&lt;DEL&gt;** Delete character at cursor.
* **&lt;LEFT-ARROW&gt;** Move cursor 1 character left.
* **&lt;RIGHT-ARROW&gt;** Move cursor 1 character right. 
* **&lt;ENTER&gt;** end line edition.     

[index](#index)

<a id="fichiers"></a>
## Files
The **STM32F103C8T6** of **blue pill* has 64KB of flash memory (if not 128KB) The TinyBASIC version 1.0 use about 20KB. Of the unused FLASH 1KB is reserved for program persistant data storage because the MCU as no EEPROM. The left out is used for a simple file system. There is a **AUTORUN** command that can be used to load and execute a program saved in this file system  at power up or reset. See [reference manual](refman.md) for more information.

[index](#index)

<a id="send"></a>
## File transfer
There is a small command line utility in the [sendFile](../sendFile) to transfert a BASIC program from the PC to the blue pill. A small script shell in the root directory simplify the operation suffice to type from project root directory:<br>
**./send file_name** <br>
Where *file_name* is any file in the **tb_progs** directory. 

[index](#index)

<a id="exemples"></a>
## Programs examples

### [blink.bas](../tb_progs/blink.bas)  
The green LED on the pill is connected to PC13 GPIO. This example blink this LED 5 times/second. No need to configure the GPIO as it is already by the tiny BASIC system. 
```
5 ' Blink blue pill green LED 
10 BLINK
20 OUT GPIOC,13,0
30 PAUSE 100 
40 OUT GPIOC,13,1
50 PAUSE 100 
60 GOTO BLINK 
```
Note that commands can be entered indifferently in lower case or upper case. The commpiler convert to upper case. 
```
list
5 REM  CLIGNOTE LED VERTE DE LA CARTE BLUE PILL 
10 BLINK 
20 OUT GPIOC ,13 ,0 
30 PAUSE 100 
40 OUT GPIOC ,13 ,1 
50 PAUSE 100 
60 GOTO BLINK 
READY
```


[index](#index)

### [pwm-soft.bas](../tb_progs/pwm-soft.bas)

In this example LED intensity is controlled by sofware PWM.
```
5 'Software PWM, green LED intensity control  
7 CLS :PRINT #6 ,
10 R =511 :PRINT R ,
20 LOOP K =0 
30 IF R THEN OUT GPIOC ,13 ,0 
40 FOR A =0 TO R :NEXT A 
50 OUT GPIOC ,13 ,1 
60 FOR A =A TO 1023 :NEXT A 
70 IF QKEY THEN K=ASC (KEY ) GOSUB UPPER 
74 IF K=0 GOTO 30 
80 IF K =ASC (\U)THEN GOTO 200 
84 IF K =ASC (\F)THEN R =1023 :GOTO 600 REM  pleine intensite 
90 IF K =ASC (\D)THEN GOTO 400 
94 IF K =ASC (\O)THEN R =0 :GOTO 600 REM  eteindre
100 IF K =ASC (\Q)THEN END 
110 GOTO LOOP
200 IF R <1023 THEN R =R +1 :GOTO 600 
210 GOTO LOOP
400 IF R >0 THEN R =R -1 :GOTO 600 
410 GOTO LOOP
600 CLS :PRINT R ,
610 GOTO LOOP 
1000 UPPER 
1010 IF K<ASC(\a) THEN RETURN
1020 IF K>ASC(\z) THEN RETURN 
1030 K=K-32 
1040 RETURN 
```
From the terminal LED intensity is controlled by the following keys:
* **u** increase 
* **d** decrease 
* **o** off 
* **f** full intensity
* **q** quit 

The *labels* are use for **GOTO** and **GOSUB** commands. At line **1000** there is **UPPER** sub-routine that convert entered command to upper case. See [reference manual](refman.md) for more information about **labels** usage. 

[index](#index)

### [adc-test.bas](../tb_progs/adc-test.bas)
In this example the analog digital converter is enabled and used to read the internal *temperature sensor* on channel 16 and *ADC0* on pin **PA0**.  
Press a key to go from temperature reading to ADC0 reading. A second key press end program. 
```
5 REM TEST CONVERTISSEUR ANALOG/DIGITAL 
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

For more example see [tb_progs](../tb_progs) directory.<br/>

[top](#top)
