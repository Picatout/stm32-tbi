////
// Copyright Jacques Deschênes 2021 
// This file is part of stm32-tbi 
//
//     stm32-tbi is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.
//
//     stm32-tbi is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY// without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU General Public License for more details.
//
//     You should have received a copy of the GNU General Public License
//     along with stm32-tbi.  If not, see <http://www.gnu.org/licenses/>.
////
//--------------------------------------
/*****************************************
    REGISTERS USAGE 

 R0   ACCA  //  arithmetic operator A 
 R1   ACCB  //  arithmetic operator B 
 R2   VPC   //  virtual machine program counter  
 R3   UPP   //  system variables base address 
 R4   VPP   //  BASIC variables base address 
 R5         //  FOR loop counter 
 R6         //  FOR loop limit 
 R7         //  FOR loop increment 
 R8-R11     //  temporary registers
*****************************************/

  .syntax unified
  .cpu cortex-m3
  .fpu softvfp
  .thumb

  .include "stm32f103.inc"
  .include "ascii.inc"
  .include "gen_macros.inc"
  .include "tbi_macros.inc"
  .include "cmd_index.inc"

/* blue pill specific constants */ 
  .equ LED_GPIO, GPIOC_BASE_ADR
  .equ LED_PIN, 13
  .equ UART, USART1_BASE_ADR 

	.equ STACK_SIZE,256
	.equ STACK_EMPTY,RAM_END-1
  .equ TIB_SIZE,80 
  .equ PAD_SIZE,80   
/* flags used by BASIC interpreter */ 
	.equ FRUN,0 // flags run code in variable flags
	.equ FTRAP,1 // inside trap handler 
	.equ FLOOP,2 // FOR loop in preparation 
	.equ FSLEEP,3 // halt produit par la commande SLEEP 
	.equ FBREAK,4 // break point flag 
	.equ FCOMP,5  // compiling flags 

	.equ FAUTORUN,6// auto start program running 
	.equ AUTORUN_NAME,0x8001C00  // address in FLASH  where auto run file name is saved 
  
  .equ FIRST_DATA_ITEM,6 // first DATA item offset on line.
	.equ MAX_LINENO,0x7fff// BASIC maximum line number 

	.equ RX_QUEUE_SIZE,16




/*************************************
*   interrupt service vectors table 
**************************************/
   .section  .isr_vector,"a",%progbits
  .type  isr_vectors, %object

isr_vectors:
  .word    _mstack          /* main return stack address */
  .word    reset_handler    /* startup address */
/* core interrupts || exceptions */
  .word    default_handler  /*  -14 NMI */
  .word    default_handler  /*  -13 HardFault */
  .word    default_handler  /*  -12 Memory Management */
  .word    default_handler  /* -11 Bus fault */
  .word    default_handler  /* -10 Usage fault */
  .word    0 /* -9 */
  .word    0 /* -8 */ 
  .word    0 /* -7 */
  .word    0	/* -6 */
  .word    default_handler  /* -5 SWI instruction */
  .word    default_handler  /* -4 Debug monitor */
  .word    0 /* -3 */
  .word    default_handler  /* -2 PendSV */
  .word    systick_handler  /* -1 Systick */
 irq0:  
  /* External Interrupts */
  .word      default_handler /* IRQ0, Window WatchDog  */                                        
  .word      default_handler /* IRQ1, PVD_VDM */                        
  .word      default_handler /* IRQ2, TAMPER */            
  .word      default_handler /* IRQ3, RTC  */                      
  .word      default_handler /* IRQ4, FLASH */                                          
  .word      default_handler /* IRQ5, RCC */                                            
  .word      default_handler /* IRQ6, EXTI Line0 */                        
  .word      default_handler /* IRQ7, EXTI Line1  */                          
  .word      default_handler /* IRQ8, EXTI Line2 */                          
  .word      default_handler /* IRQ9, EXTI Line3 */                          
  .word      default_handler /* IRQ10, EXTI Line4 */                          
  .word      default_handler /* IRQ11, DMA1 CH1 */                  
  .word      default_handler /* IRQ12, DMA1 CH2 */                   
  .word      default_handler /* IRQ13, DMA1 CH3 */                   
  .word      default_handler /* IRQ14, DMA1 CH4  */                   
  .word      default_handler /* IRQ15, DMA1 CH5 */                   
  .word      default_handler /* IRQ16, DMA1 CH6 */                   
  .word      default_handler /* IRQ17, DMA1 CH7 */                   
  .word      default_handler /* IRQ18, ADC1, ADC2 global interrupt */                   
  .word      default_handler /* IRQ19, USB High priority */                         
  .word      default_handler /* IRQ20, USB low priority */                          
  .word      default_handler /* IRQ21, CAN_RX1 */                          
  .word      default_handler /* IRQ22, CAN1_SCE */                          
  .word      default_handler /* IRQ23, External Line[9:5]s */                          
  .word      default_handler /* IRQ24, TIM1 Break and TIM15 global */         
  .word      default_handler /* IRQ25, TIM1 Update and TIM16 global */         
  .word      default_handler /* IRQ26, TIM1 Trigger and Commutation and TIM17 */
  .word      default_handler /* IRQ27, TIM1 Capture Compare */                          
  .word      default_handler /* IRQ28, TIM2 */                   
  .word      default_handler /* IRQ29, TIM3 */                   
  .word      default_handler /* IRQ30, TIM4 */                   
  .word      default_handler /* IRQ31, I2C1 Event and exti line 23 */                          
  .word      default_handler /* IRQ32, I2C1 Error */                          
  .word      default_handler /* IRQ33, I2C2 Event and exti line 24 */                          
  .word      default_handler /* IRQ34, I2C2 Error */                            
  .word      default_handler /* IRQ35, SPI1 */                   
  .word      default_handler /* IRQ36, SPI2 */                   
  .word      uart_rx_handler /* IRQ37, USART1 */                   
  .word      default_handler /* IRQ38, USART2 */                   
  .word      default_handler /* IRQ39, USART3 */                   
  .word      default_handler /* IRQ40, External Line[15:10]s */                          
  .word      default_handler /* IRQ41, RTC Alarm */                 
  .word      default_handler /* IRQ42, USB Wakeup*/                       
  .word      default_handler /* IRQ43, TIM8 Break */         
  .word      default_handler /* IRQ44, TIM8 Update*/         
  .word      default_handler /* IRQ45, TIM8 Trigger and Commutation */
  .word      default_handler /* IRQ46, TIM8 Capture Compare */                          
  .word      default_handler /* IRQ47, ADC3 global */                          
  .word      default_handler /* IRQ48, FSMC */                   
  .word      default_handler /* IRQ49, SDIO */                   
  .word      default_handler /* IRQ50, TIM5 */                   
  .word      default_handler /* IRQ51, SPI3 */                   
  .word      default_handler /* IRQ52, UART4 */                   
  .word      default_handler /* IRQ53, UART5 */                   
  .word      default_handler /* IRQ54, TIM6 */                   
  .word      default_handler /* IRQ55, TIM7 */
  .word      default_handler /* IRQ56, DMA2 CH1 */                   
  .word      default_handler /* IRQ57, DMA2 CH2 */                   
  .word      default_handler /* IRQ58, DMA2 CH3 */                   
  .word      default_handler /* IRQ59, DMA2 CH4 & CH5 */                   
isr_end:
  .size  isr_vectors, .-isr_vectors
upp:

/*************************************
    EXCEPTIONS & INTERRUPTS HANDLERS 
*************************************/

/*****************************************************
  default isr handler called on unexpected interrupt
*****************************************************/
   .section  .text , "ax", %progbits 
   
  .type default_handler, %function
  .p2align 2 
  .global default_handler
default_handler:
	ldr r0,exception_msg 
	_CALL uart_puts 
  mov r0,#0x8000
1: subs r0,#1 
  bne 1b 
	b reset_mcu    
  .p2align 2 
exception_msg:
	.word .+4 
	.byte 18
	.ascii "\nexeption reboot!\n"

/*********************************
	system milliseconds counter
*********************************/	
  .p2align 2 
  .type systick_handler, %function
  .global systick_handler
systick_handler:
  ldr r0,[r3,#TICKS]  
  add r0,#1
  str r0,[r3,#TICKS]
  ldr r0,[r3,#TIMER]
  cbz r0, systick_exit
  sub r0,#1
  str r0,[r3,#TIMER]
systick_exit:
  _RET 


/**************************
	UART RX handler
**************************/
	.p2align 2
	.type uart_rx_handler, %function
  .global uart_rx_handler 
uart_rx_handler:
	_MOV32 r0,UART 
	ldr r1,[r0,#USART_SR]
	ldrh r2,[r0,#USART_DR]
	tst r1,#(1<<5) // RXNE 
	beq 2f // no char received 
	cmp r2,#3
	beq user_reboot // received CTRL-C then reboot MCU 
	add r0,r3,#RX_QUEUE
  ldr r1,[r3,#RX_TAIL]
	strb r2,[r0,r1]
	add r1,#1 
	and r1,#(RX_QUEUE_SIZE-1)
	str r1,[r3,#RX_TAIL]
2:	
	_RET 

user_reboot:
	ldr r0,user_reboot_msg
	_CALL uart_puts
// delay 
  mov r0,#0x8000
1: subs r0,#1  
   bne 1b 
reset_mcu: 
	ldr r0,scb_adr 
	ldr r1,[r0,#SCB_AIRCR]
	orr r1,#(1<<2)
	movt r1,#SCB_VECTKEY
	str r1,[r0,#SCB_AIRCR]
	b . 
	.p2align 2 
scb_adr:
	.word SCB_BASE_ADR 
user_reboot_msg:
	.word .+4
	.byte  14 
	.ascii "\nuser reboot!\n"
	.p2align 2 

/**************************************
  reset_handler execute at MCU reset
***************************************/
  .p2align 2
  .type  reset_handler, %function 
  .global reset_handler 
reset_handler:   
  _MOV32 r0,RAM_END 
  mov sp,r0 
  bl remap  
	bl	init_devices	 	/* RCC, GPIOs */
	bl  uart_init
	bl  cold_init  /* initialize BASIC SYSTEM */ 
  bl  prt_version 
  bl  test 
  b .  

    _FUNC test
    ldr r0,tib_addr  
    mov r1,#80
    _CALL readln
    _CALL uart_putsz
    mov r0,#CR 
    _CALL uart_putc 
    b test   
    _RET 
  tib_addr: 
    .word _tib

    _FUNC prt_version 
    ldr r0,version_msg 
    _CALL uart_puts 
    ldrb r0,version 
    lsr r0,#4 
    add r0,#'0' 
    cmp r0,#'9'+1 
    bmi 1f 
    add r0,#7 
  1:
    _CALL uart_putc 
    mov r0,#'. 
    _CALL uart_putc 
    ldrb r0,version 
    and r0,#15 
    add r0,'0' 
    cmp r0,#'9'+1 
    bmi 1f 
    add r0,#7
  1: 
    _CALL uart_putc 
    mov r0,#CR 
    _CALL uart_putc 
    _RET  
version_msg:
    .word .+4 
    .byte 30
    .ascii "blue pill tiny BASIC, version "
version:
    .byte 0x10 
    .p2align 2 

// tranfert isr_vector to RAM at 0x20000000
    _FUNC remap 
	_MOV32 r0,RAM_ADR
	eor r1,r1
	mov r2,#(isr_end-isr_vectors) 
1:	ldr r3,[r1],#4
	str r3,[r0],#4
	subs r2,#4
	bne 1b
// set new vector table address
	_MOV32 r0,SCB_BASE_ADR
	_MOV32 r1,RAM_ADR 
	str r1,[r0,#SCB_VTOR]
  bx lr 

// initialize hardware devices 
  _FUNC init_devices
/* init clock to HSE 72 Mhz */
/* set 2 wait states in FLASH_ACR_LATENCY */
  _MOV32 R0,FLASH_BASE_ADR 
  mov r2,#0x12
  str r2,[r0,#FLASH_ACR]
/* configure clock for HSE, 8 Mhz crystal */
/* enable HSE in RCC_CR */
  _MOV32 R0,RCC_BASE_ADR 
  ldr r1,[r0,#RCC_CR]
  orr r1,r1,#(1<<16) /* HSEON bit */
  str r1,[r0,#RCC_CR] /* enable HSE */
/* wait HSERDY loop */
wait_hserdy:
  ldr r1,[r0,#RCC_CR]
  tst r1,#(1<<17)
  beq wait_hserdy

/************************************************* 
   configure PLL mul factor and source 
   SYSCLOCK,72 Mhz
   select HSE as  PLL source clock
   multiply frequency by 9 
   APB1 clock is limited to 36 Mhz so divide by 2 
****************************************************/
  mov r1,#(4<<8) /* PLLMUL,7|PLLSCR,HSE|PPRE1,HCLK/2| */
  movt r1,#(7<<2)|1
  str r1,[r0,#RCC_CFGR]
  /* enable PLL */
  ldr r1,[r0,#RCC_CR]
  orr r1, #1<<24 
  str r1,[r0,#RCC_CR]
/* wait for PLLRDY */
wait_pllrdy:
  ldr r1,[r0,#RCC_CR]
  tst r1,#(1<<25)
  beq wait_pllrdy 
/* select PLL as sysclock */
  ldr r1,[r0,#RCC_CFGR]
  _MOV32 r2,0xfffffffc
  and r1,r1,r2 
  mov r2,#2
  orr r1,r1,r2
  str r1,[r0,#RCC_CFGR] /* PLL selected as sysclock */
/* wait for SWS,,2 */
wait_sws:
  ldr r1,[r0,#RCC_CFGR]
  tst r1,#(2<<2)
  beq wait_sws
/* now sysclock is 72 Mhz */

/* enable peripheral clock for GPIOA, GPIOC and USART1 */
  _MOV32 r0,RCC_BASE_ADR
  mov	r1, #(1<<2)|(1<<4)|(1<<14)		/* GPIOAEN|GPIOCEN|USART1EN */
  str	r1, [r0, #RCC_APB2ENR]

/* configure GPIOC:13 as output for user LED */
  _MOV32 r0,GPIOC_BASE_ADR 
  ldr r1,[r0,#GPIO_CRH]
  mvn r2,#(15<<20)
  and r1,r1,r2
  mov r2,#(6<<20)
  orr r1,r1,r2
  str r1,[r0,#GPIO_CRH]

/* configure systicks for 1msec ticks */
  _MOV32 r0,STK_BASE_ADR 
  mov r1,#9000 /* reload value for 1msec */
  str r1,[r0,#STK_LOAD]
  mov r1,#3
  str r1,[r0,STK_CTL]
  _RET  

/*******************************
  initialize UART peripheral 
********************************/
	_FUNC uart_init
/* set GPIOA PIN 9, uart TX  */
  _MOV32 r0,GPIOA_BASE_ADR
  ldr r1,[r0,#GPIO_CRH]
  mvn r2,#(15<<4)
  and r1,r1,r2
  mov r2,#(0xA<<4)
  orr r1,r1,r2 
  str r1,[r0,#GPIO_CRH]
  _MOV32 r0,UART 
/* BAUD rate */
  mov r1,#(39<<4)+1  /* (72Mhz/16)/115200,39,0625, quotient,39, reste,0,0625*16,1 */
  str r1,[r0,#USART_BRR]
  mov r1,#(3<<2)+(1<<13)+(1<<5) // TE+RE+UE+RXNEIE
  str r1,[r0,#USART_CR1] /*enable usart*/
/* enable interrupt in NVIC */
  _MOV32 r0,NVIC_BASE_ADR
  ldr r1,[r0,#NVIC_ISER1]
  orr r1,#32   
  str r1,[r0,#NVIC_ISER1]
  bx lr 

/****************************
    UART_PUTC
  send character to uart
  input: 
    R0 character to send 
  use:
    R8 status  
    R9 UART address
*****************************/
  _GBL_FUNC uart_putc
  push {r8,r9}
  _MOV32 R9,UART
1: 
  ldr r8,[r9,#USART_SR]
  ands r8,#0x80
  beq 1b // UART_DR full,wait  
  strb r0,[r9,#USART_DR]
  pop {r8,r9}
  _RET  


/**********************************
  UART_QKEY
  check if character available in 
  rx1_qeue
  input:
    none
  output:
    r0 flag = RX_HEAD^REX_TAIL 
  use:
    r8  RX_HEAD  
    r9  RX_TAIL   
***********************************/
  _GBL_FUNC uart_qkey
  push {r8,r9}
  ldr r8,[r3,#RX_HEAD]
  ldr r9,[r3,#RX_TAIL]
  eor r0,r8,r9 
  pop {r8,r9}
  _RET 

/**********************************
  UART_GETC 
  wait a character from uart 
  input:
    none
  output:
    r0  character 
  use:
    r8  rx_queue 
    r9  rx_head  
**********************************/
  _GBL_FUNC uart_getc
  push {r8,r9}
1:
  _CALL uart_qkey 
  orrs r0,r0
  beq 1b  
  add r8,r3,#RX_QUEUE
  ldr r9, [r3,#RX_HEAD]
  ldrb r0,[r8,r9]
  add r9,#1
  and r9,#(RX_QUEUE_SIZE-1)
  str r9,[r3,#RX_HEAD]
  pop {r8,r9}
  _RET  



/*********************************
  cp_cstr 
  compare 2 counted strings 
  input:
    r0  *str1 
    r1  *str2
    r8  length 
  output:
    r0  <0 str1<str2 
        0  str1==str2 
        >0  str1>str2  
  use:
    r9  *str1
    r10 temp
    r11 temp    
*********************************/
  _FUNC cp_cstr
  push {r9,r10,r11}
  mov r9, r0 
  ldrb r10,[r9],#1 // length 
  subs r0,r8,r10 
  bne 2f 
1:
  ldrb r10,[r9],#1
  ldrb r11,[r1],#1 
  subs r0,r10,r11  
  bne 2f // not same length       
  subs r8,#1 
  bne 1b 
2: 
  pop {r9,r10,r11}
  _RET 

//---------------------------------
// dictionary search 
// input:
//	 r0   target name
//   r1		dictionary first link address  
// output:
//  r0 		TK_CMD|TK_IFUNC|TK_CONST|TK_NONE 
//  r1		cmd_index if r0!=TK_NONE  
// use:
//  r8   length dictionary name 
//---------------------------------
  _FUNC search_dict
  push {r8}
  push {r0,r1}
1:
  ldrb r0,[r1],#1 
  orrs r0,r0
  beq 9f // end of dictinary 
  and r8,r0,#0x1f 
  ldr r0,[sp]  
  _CALL cp_cstr 
  beq 2f 
  ldr r1,[sp,#4]
  ldr r1,[r1,#-8]
  str r1,[sp,#4]
  b 1b   
2: // found
  ldr r1,[sp,#4]
  ldrb r0,[r1]
  lsr r0,#5    // token type 
  ldr r1,[r1,#-4]  // command index 
9: add sp,#8  // drop pushed r0,r1
   pop {r8}
   _RET 

  _FUNC cold_init
//copy system variables to ram 
  ldr r8,src_addr 
  ldr r9,dest_addr 
  mov r10,#ulast-uzero 
1:
  ldr r11,[r8],#4 
  str r11,[r9],#4 
  subs r10,#4 
  bne 1b
// set UPP 
  _MOV32 r3,RAM_ADR
  ldr r8,isr_table_size 
  add r3,r3,r8
  _RET 
src_addr:
  .word uzero
dest_addr:
  .word RAM_ADR+isr_end-isr_vectors  
isr_table_size:
  .word isr_end-isr_vectors 


  .section .rodata 

// system variables initial value 
uzero:
  .word 0 // IN
  .word 0 // IN_SAVED
  .word 0 // COUNT
  .word 0 // BASICPTR
  .word 0 // DATAPTR
  .word 0 // DATA
  .word 0 // DATALEN
  .word 10 // BASE
  .word 0 // TICKS
  .word 0 // TIMER
  .word 0xaa5555aa // SEED
  .word FILE_SYSTEM // FSPTR
  .word 0 // FFREE
  .word RAM_ADR+(isr_end-isr_vectors)+(ulast-uzero) // TXTBGN
  .word RAM_ADR+(isr_end-isr_vectors)+(ulast-uzero) // TXTEND
  .word 0 //LOOP_DEPTH
  .word 0 // ARRAY_SIZE
  .word 0 // FLAGS
  .word 4 // TAB_WIDTH
  .word 0 // RX_HEAD
  .word 0 // RX_TAIL
  .space RX_QUEUE_SIZE,0 // RX_QUEUE
  .space VARS_SIZE,0 // VARS
  .space 4, 0 // filling 
ulast:

  .section .rodata.dictionary 

// keep alphabetic order for BASIC names from Z-A
// this sort order is for for WORDS cmd output. 	

	.equ link, 0
kword_end:
  .word link,0
  .equ LINK, .
  .word 0
  .p2align 2  
  _dict_entry 5+F_CMD,XTRMT,XTRMT_IDX // xmodem transmit
  _dict_entry 4+F_CMD,XRCV,XRCV_IDX // xmodem receive
  _dict_entry 3+F_IFUNC,XOR,XOR_IDX //bit_xor
  _dict_entry 5+F_CMD,WRITE,WRITE_IDX //write  
  _dict_entry 5+F_CMD,WORDS,WORDS_IDX //words 
  _dict_entry 4+F_CMD,WAIT,WAIT_IDX //wait 
  _dict_entry 3+F_IFUNC,USR,USR_IDX //usr
  _dict_entry 5+F_CMD,UNTIL,UNTIL_IDX //until 
  _dict_entry 6+F_IFUNC,UFLASH,UFLASH_IDX //uflash 
  _dict_entry 6+F_IFUNC,UBOUND,UBOUND_IDX //ubound
  _dict_entry 4+F_CMD,TONE,TONE_IDX //tone  
  _dict_entry 2+F_CMD,TO,TO_IDX //to
  _dict_entry 5+F_CMD,TIMER,TIMER_IDX //set_timer
  _dict_entry 7+F_IFUNC,TIMEOUT,TMROUT_IDX //timeout 
  _dict_entry 5+F_IFUNC,TICKS,TICKS_IDX //get_ticks
  _dict_entry 4+F_CMD,STOP,STOP_IDX //stop 
  _dict_entry 4+F_CMD,STEP,STEP_IDX //step 
  _dict_entry 5+F_CMD,SPIWR,SPIWR_IDX //spi_write
  _dict_entry 6+F_CMD,SPISEL,SPISEL_IDX //spi_select
  _dict_entry 5+F_IFUNC,SPIRD,SPIRD_IDX // spi_read 
  _dict_entry 5+F_CMD,SPIEN,SPIEN_IDX //spi_enable 
  _dict_entry 5+F_CMD,SLEEP,SLEEP_IDX //sleep 
  _dict_entry 4+F_IFUNC,SIZE,SIZE_IDX //size
  _dict_entry 4+F_CMD,SHOW,SHOW_IDX //show 
  _dict_entry 4+F_CMD,SAVE,SAVE_IDX //save
  _dict_entry 3+F_CMD,RUN,RUN_IDX //run
  _dict_entry 6+F_IFUNC,RSHIFT,RSHIFT_IDX //rshift
  _dict_entry 3+F_IFUNC,RND,RND_IDX //random 
  _dict_entry 6+F_CMD,RETURN,RET_IDX //return 
  _dict_entry 7+F_CMD,RESTORE,REST_IDX //restore 
  _dict_entry 6+F_CMD,REMARK,REM_IDX //remark 
  _dict_entry 6+F_CMD,REBOOT,RBT_IDX //cold_start
  _dict_entry 4+F_IFUNC,READ,READ_IDX //read  
  _dict_entry 4+F_IFUNC,QKEY,QKEY_IDX //qkey  
  _dict_entry 4+F_IFUNC,PRTI,PRTI_IDX //const_porti 
  _dict_entry 4+F_IFUNC,PRTH,PRTH_IDX //const_porth 
  _dict_entry 4+F_IFUNC,PRTG,PRTG_IDX //const_portg 
  _dict_entry 4+F_IFUNC,PRTF,PRTF_IDX //const_portf
  _dict_entry 4+F_IFUNC,PRTE,PRTE_IDX //const_porte
  _dict_entry 4+F_IFUNC,PRTD,PRTD_IDX //const_portd
  _dict_entry 4+F_IFUNC,PRTC,PRTC_IDX //const_portc
  _dict_entry 4+F_IFUNC,PRTB,PRTB_IDX //const_portb
  _dict_entry 4+F_IFUNC,PRTA,PRTA_IDX //const_porta 
  _dict_entry 5+F_CMD,PRINT,PRT_IDX //print 
  _dict_entry 4+F_IFUNC,POUT,POUT_IDX //const_output
  _dict_entry 4+F_CMD,POKE,POKE_IDX //poke 
  _dict_entry 5+F_CMD,PMODE,PMODE_IDX //pin_mode 
  _dict_entry 4+F_IFUNC,PINP,PINP_IDX //const_input
  _dict_entry 4+F_IFUNC,PEEK,PEEK_IDX //peek 
  _dict_entry 5+F_CMD,PAUSE,PAUSE_IDX //pause 
  _dict_entry 3+F_IFUNC,PAD,PAD_IDX //pad_ref 
  _dict_entry 2+F_IFUNC,OR,OR_IDX //bit_or
  _dict_entry 3+F_IFUNC,ODR,ODR_IDX //const_odr 
  _dict_entry 3+F_IFUNC,NOT,NOT_IDX //func_not 
  _dict_entry 4+F_CMD,NEXT,NEXT_IDX //next 
  _dict_entry 3+F_CMD,NEW,NEW_IDX //new
  _dict_entry 6+F_IFUNC,MULDIV,MULDIV_IDX //muldiv 
  _dict_entry 6+F_IFUNC,LSHIFT,LSHIFT_IDX //lshift
  _dict_entry 3+F_IFUNC,LOG,LOG_IDX //log2 
  _dict_entry 4+F_CMD,LOAD,LOAD_IDX //load 
  _dict_entry 4+F_CMD,LIST,LIST_IDX //list
  _dict_entry 3+F_CMD,LET,LET_IDX //let 
  _dict_entry 3+F_IFUNC,KEY,KEY_IDX //key 
  _dict_entry 7+F_CMD,IWDGREF,IWDGREF_IDX //refresh_iwdg
  _dict_entry 6+F_CMD,IWDGEN,IWDGEN_IDX //enable_iwdg
  _dict_entry 6+F_IFUNC,INVERT,INVERT_IDX //invert 
  _dict_entry 5+F_CMD,INPUT,INPUT_IDX //input_var  
  _dict_entry 2+F_CMD,IF,IF_IDX //if 
  _dict_entry 3+F_IFUNC,IDR,IDR_IDX //const_idr 
  _dict_entry 3+F_CMD,HEX,HEX_IDX //hex_base
  _dict_entry 4+F_IFUNC,GPIO,GPIO_IDX //gpio 
  _dict_entry 4+F_CMD,GOTO,GOTO_IDX //goto 
  _dict_entry 5+F_CMD,GOSUB,GOSUB_IDX //gosub 
  _dict_entry 6+F_CMD,FORGET,FORGET_IDX //forget 
  _dict_entry 3+F_CMD,FOR,FOR_IDX //for 
  _dict_entry 4+F_CMD,FCPU,FCPU_IDX //fcpu 
  _dict_entry 3+F_CMD,END,END_IDX //cmd_end  
  _dict_entry 6+F_IFUNC,EEPROM,EEPROM_IDX //const_eeprom_base   
  _dict_entry 6+F_CMD,DWRITE,DWRITE_IDX //digital_write
  _dict_entry 5+F_IFUNC,DREAD,DREAD_IDX //digital_read
  _dict_entry 2+F_CMD,DO,DO_IDX //do_loop
  _dict_entry 3+F_CMD,DIR,DIR_IDX //directory 
  _dict_entry 3+F_CMD,DEC,DEC_IDX //dec_base
  _dict_entry 3+F_IFUNC,DDR,DDR_IDX //const_ddr 
  _dict_entry 6+F_CMD,DATALN,DATALN_IDX //data_line  
  _dict_entry 4+F_CMD,DATA,DATA_IDX //data  
  _dict_entry 3+F_IFUNC,CRL,CRL_IDX //const_cr1 
  _dict_entry 3+F_IFUNC,CRH,CRH_IDX //const_cr2 
  _dict_entry 4+F_CFUNC,CHAR,CHAR_IDX //char
  _dict_entry 3+F_CMD,BYE,BYE_IDX //bye 
  _dict_entry 5+F_CMD,BTOGL,BTOGL_IDX //bit_toggle
  _dict_entry 5+F_IFUNC,BTEST,BTEST_IDX //bit_test 
  _dict_entry 4+F_CMD,BSET,BSET_IDX //bit_set 
  _dict_entry 4+F_CMD,BRES,BRES_IDX //bit_reset
  _dict_entry 3+F_IFUNC,BIT,BIT_IDX //bitmask
  _dict_entry 3+F_CMD,AWU,AWU_IDX //awu 
  _dict_entry 7+F_CMD,AUTORUN,AUTORUN_IDX //autorun
  _dict_entry 3+F_IFUNC,ASC,ASC_IDX //ascii
  _dict_entry 3+F_IFUNC,AND,AND_IDX //bit_and
  _dict_entry 7+F_IFUNC,ADCREAD,ADCREAD_IDX //analog_read
  _dict_entry 5+F_CMD,ADCON,ADCON_IDX //power_adc 
first_link: 
  .word LINK 
  .word ABS_IDX 
  .equ LINK,. 
kword_dict: // first name field 
  .byte 3+F_IFUNC
  .ascii "ABS" 
  .p2align 2 

//comands and fonctions address table 	
code_addr:
/*
	.word abs,power_adc,analog_read,bit_and,ascii,autorun,awu,bitmask // 0..7
	.word bit_reset,bit_set,bit_test,bit_toggle,bye,char,const_cr2  // 8..15
	.word const_cr1,data,data_line,const_ddr,dec_base,directory,do_loop,digital_read,digital_write //16..23 
	.word cmd_end,const_eeprom_base,fcpu,for,forget,gosub,goto,gpio // 24..31 
	.word hex_base,const_idr,if,input_var,invert,enable_iwdg,refresh_iwdg,key // 32..39 
	.word let,list,load,log2,lshift,muldiv,next,new // 40..47
	.word func_not,const_odr,bit_or,pad_ref,pause,pin_mode,peek,const_input // 48..55
	.word poke,const_output,print,const_porta,const_portb,const_portc,const_portd,const_porte // 56..63
	.word const_portf,const_portg,const_porth,const_porti,qkey,read,cold_start,remark // 64..71 
	.word restore,return, random,rshift,run,save,show,size // 72..79
	.word sleep,spi_read,spi_enable,spi_select,spi_write,step,stop,get_ticks  // 80..87
	.word set_timer,timeout,to,tone,ubound,uflash,until,usr // 88..95
	.word wait,words,write,bit_xor,transmit,receive // 96..103 
*/ 
	.word 0 



/*************************************************
   extra FLASH memory not used by Tiny BASIC
   is used to save BASIC programs.
************************************************/
  .p2align 10  // align to 1KB, smallest erasable segment 
  .section .fs
FILE_SYSTEM: // file system start here


