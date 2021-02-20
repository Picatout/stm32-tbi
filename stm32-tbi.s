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

 R0-R3      // function parameters 
 R4         //  system variables base address 
 R5         //  FOR loop variable address 
 R6         //  FOR loop limit 
 R7         //  FOR loop increment 
 T1-T2      //  temporary registers
 R10        //  interpreter line index 
 R11        //  interpreter BASIC line address 
 R12        //  parameters stack pointer 
*****************************************/

  .syntax unified
  .cpu cortex-m3
  .fpu softvfp
  .thumb

  .include "stm32f103.inc"
  .include "ascii.inc"
  .include "tbi_macros.inc"
  .include "cmd_index.inc"

/* blue pill specific constants */ 
  .equ LED_GPIO, GPIOC_BASE_ADR
  .equ LED_PIN, 13
  .equ UART, USART1_BASE_ADR 


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
  .global vectors_size 
vectors_size: .word isr_end - isr_vectors 


/*************************************
    EXCEPTIONS & INTERRUPTS HANDLERS 
*************************************/

/*****************************************************
  default isr handler called on unexpected interrupt
*****************************************************/
   .section  .text , "ax", %progbits 
    _GBL_FUNC default_handler 
    ldr r0,=exception_msg 
    _CALL uart_puts 
// delay
    mov r0,#0x8000
    1: subs r0,#1 
    bne 1b 
    b reset_mcu    
    .p2align 2 
exception_msg:
  	.asciz "\nexeption reboot!\n"

/*********************************
	system milliseconds counter
*********************************/	
    _GBL_FUNC systick_handler
  ldr r0,[UPP,#TICKS]  
  add r0,#1
  str r0,[UPP,#TICKS]
  ldr r0,[UPP,#TIMER]
  cbz r0, 9f
  sub r0,#1
  str r0,[UPP,#TIMER]
9: 
  _RET 

/**************************
	UART RX handler
**************************/
    _GBL_FUNC uart_rx_handler
    _MOV32 r0,UART 
    ldr r1,[r0,#USART_SR]
    ldrh r2,[r0,#USART_DR]
    tst r1,#(1<<5) // RXNE 
    beq 2f // no char received 
    cmp r2,#3 // CTRL_C // cold restart
    beq user_reboot // received CTRL-C then reboot MCU 
    cmp r2,#2 // CTRL_B  break program
    beq 3f   
    add r0,UPP,#RX_QUEUE
    ldr r1,[UPP,#RX_TAIL]
    strb r2,[r0,r1]
    add r1,#1 
    and r1,#(RX_QUEUE_SIZE-1)
    str r1,[UPP,#RX_TAIL]
2:
  	_RET 
3:  _CALL uart_flush_queue
    ldr IN,[UPP,#COUNT]
    ldr r0,[UPP,#FLAGS]
    mvn r1,#FRUN 
    and r0,r1
    str r0,[UPP,#FLAGS]
    _RET 
     

    _GBL_FUNC user_reboot   
    ldr r0,=user_reboot_msg
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
	  .asciz "\nuser reboot!\n"
	  .p2align 2 

/**************************************
  reset_handler execute at MCU reset
***************************************/
    _GBL_FUNC reset_handler
    _MOV32 r0,RAM_END 
    mov sp,r0 
    bl remap  
    bl	init_devices	 	/* RCC, GPIOs */
    bl  uart_init
    bl  cold_start  /* initialize BASIC SYSTEM */ 
    bl  test 
    b .  

    _FUNC test
  _MOV32 UPP,RAM_ADR
  add UPP,#0x130
  _CALL get_curpos 
  push {r1} 
  mov r1,#10 
  _CALL print_int 
  mov r0,#','
  _CALL uart_putc 
  pop {r0}
  mov r1,#10  
  _CALL print_int 
  _RET 

  tib_addr: 
    .word _tib


// tranfert isr_vector to RAM at 0x20000000
    _FUNC remap 
	eor r0,r0 // src 
	_MOV32 r1,RAM_ADR // dest 
	mov r2,#(isr_end-isr_vectors) // count 
  _CALL cmove  
// set new vector table address
	_MOV32 r0,SCB_BASE_ADR
	_MOV32 r1,RAM_ADR 
	str r1,[r0,#SCB_VTOR]
  _RET 

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

/* enable peripheral clock for GPIOs and USART1 */
  _MOV32 r0,RCC_BASE_ADR
  mov	r1, #0x41fd		/* all GPIO and USART1 */
  str	r1, [r0, #RCC_APB2ENR]

/* configure GPIOC:13 as output for user LED */
  _MOV32 r0,GPIOC_BASE_ADR 
  ldr r1,[r0,#GPIO_CRH]
  mvn r2,#(15<<20)
  and r1,r1,r2
  mov r2,#(6<<20)
  orr r1,r1,r2
  str r1,[r0,#GPIO_CRH]
/* turn off user LED */ 
  mov r1,#(1<<13)
  str r1,[r0,#GPIO_ODR]

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

/***************************
    uart_flush_queue
    flush rx queue
  input:
    none
  output:
    none 
  use:
    T1 temp
***************************/
    _GBL_FUNC uart_flush_queue
    push {T1}
    eor T1,T1 
    str T1,[UPP,#RX_HEAD]
    str T1,[UPP,#RX_TAIL]
    pop {T1}
    _RET 

/****************************
    UART_PUTC
  send character to uart
  input: 
    R0 character to send 
  use:
    T1 status  
    T2 UART address
*****************************/
    _GBL_FUNC uart_putc
    push {T1,T2}
    _MOV32 T2,UART
1: 
    ldr T1,[T2,#USART_SR]
    ands T1,#0x80
    beq 1b // UART_DR full,wait  
    strb r0,[T2,#USART_DR]
    pop {T1,T2}
    _RET  


/**********************************
  UART_QKEY
  check if character available in 
  rx1_qeue
  input:
    none
  output:
    r0 flag = RX_HEAD^REX_TAIL 
    flags 
  use:
    r0  RX_HEAD  
    r1  RX_TAIL   
***********************************/
    _GBL_FUNC uart_qkey
    push {r1}
    ldr r0,[UPP,#RX_HEAD]
    ldr r1,[UPP,#RX_TAIL]
    eors r0,r1
    pop {r1} 
    _RET 

/**********************************
  UART_GETC 
  wait a character from uart 
  input:
    none
  output:
    r0  character 
  use:
    T1  rx_queue 
    T2  rx_head  
**********************************/
    _GBL_FUNC uart_getc
    push {T1,T2}
1:
    _CALL uart_qkey 
    beq 1b  
    add T1,UPP,#RX_QUEUE
    ldr T2, [UPP,#RX_HEAD]
    ldrb r0,[T1,T2]
    add T2,#1
    and T2,#(RX_QUEUE_SIZE-1)
    str T2,[UPP,#RX_HEAD]
    pop {T1,T2}
    _RET  


/***************************
  Flash memory interface
***************************/

/***********************************
  unlock 
  unlock flash memory for writing
  input:
    r0    0 lock, 1 unlock 
  output:
    none
  use: 
    r6     temp  
***********************************/
    _GBL_FUNC unlock  
    push {r6}
    ands r0,r0 
    beq lock 
    _MOV32 r0,FLASH_BASE_ADR
    mov r6,#(0xD<<2) // clear EOP|WRPRTERR|PGERR bits 
    str r6,[r0,#FLASH_SR]
    ldr r6,[r0,#FLASH_CR]
    tst r6,#(1<<7)
    beq 9f
    _MOV32 r6,FLASH_KEY1  
    str	r6, [r0, #FLASH_KEYR]
    _MOV32 r6,FLASH_KEY2
    str	r6, [r0, #FLASH_KEYR]
    b 9f 
// lock flash memory
lock: 
    _MOV32 r0,FLASH_BASE_ADR
    mov r6,#(1<<7)
    str r6,[r0,#FLASH_CR]
9:  pop {r6}
  	_RET  


/*********************************
   wait_busy 
   wait until busy flag is cleared 
   input:
    none
   output:
    none 
   use:
     r0    flash registers address 
     r1    temp 
***********************************/
    _FUNC wait_busy 
    push {r0,r1}
    _MOV32	r0,FLASH_BASE_ADR
1:
    ldr	r1, [r0, #FLASH_SR]	//  FLASH_SR
    ands r1, #0x1	//  BSY
    bne	1b 
    pop {r0,r1}
    _RET

/***************************************
   hword_write
   write 16 bits value to flash memory 
   input:
    r0  data 
    r1  address 
   output:
     none 
   use: 
     r6    flash control regs base address 
     r7    temp  
***************************************/
    _GBL_FUNC hword_write 
    push {r6,r7}
    _MOV32 r6,FLASH_BASE_ADR
    mov r7,#1 // set PG 
    str r7,[r6,#FLASH_CR]
    strh r0,[r1] 
    _CALL wait_busy  
    ldr r7,[r6,#FLASH_SR]
    ands r7,r7,#(5<<2) 
    beq 9f
    ldr r0,=write_error
    _CALL uart_puts   
9:	pop {r6,r7}
    _RET  
write_error:	
    .asciz " write error!"
    .p2align 2

/****************************************
    flash_store
    Write one word into flash memory
    address must even
    input:
      r0    data 
      r1    adr 
    output: 
      none 
    use:
      T1 data 
      T2 adr 
*****************************************/ 
    _GBL_FUNC flash_store 
    push {T1,T2}
    mov T1,r0
    mov T2,r1  
    mov r0,#1
    _CALL unlock 
    mov r0,T1 
    mov r1,T2 
    _CALL hword_write
    mov r0,T1,lsr #16 
    add r1,T2,#2
    _CALL hword_write
    eor r0,r0 
    _CALL unlock  
    pop {T1,T2}
    _RET 

/********************************************
    erase_page 
    erase 1024 bytes flash page 
    input:
       r0    adr 
    output:
       None 
    use:
      T1    adr
      T2    temp   
**********************************************/
    _GBL_FUNC erase_page 
    push {T1,T2}
    mov T1,r0 
    mov r0,#1 
    _CALL unlock 
    _MOV32 r0,FLASH_BASE_ADR
    mov T2,#2 // PER bit in FLASH_CR 
    str T2,[r0,#FLASH_CR]
    str T1,[r0,#FLASH_AR]
    orr T2,#0x40 
    str T2,[r0,#FLASH_CR]
    ldr T2,[r0,#FLASH_SR]
    ands T2,#(5<<2)
    beq 9f
    ldr r0,erase_error
    _CALL uart_puts 
9:  eor r0,r0 
    _CALL unlock 
    pop {T1,T2}
    _RET 
erase_error:
    .asciz " erase error!\r"
    .p2align 2

/**********************************************
   page_align 
   align address to FLASH page boundary 
   input:
     r0    address 
   output:
     r0    aligned 
   use: 
     r1  
**********************************************/
    _GBL_FUNC page_align 
    push {r1}
    mov r1,#PAGE_SIZE-1
    add r0,r1
    mvn r1,r1 
    and r0,r1 
    pop {r1}
    _RET 

