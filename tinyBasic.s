/****************************************************************************
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
*****************************************************************************/

.syntax unified
  .cpu cortex-m3
  .fpu softvfp
  .thumb

  .include "stm32f103.inc"
  .include "ascii.inc"
  .include "tbi_macros.inc"
  .include "cmd_index.inc"

    .section  .text , "ax", %progbits 

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





/**********************************
   strlen 
   return length of asciz 
   input:
      r0    *asciz 
   output:
      r0   length 
   use:
      r8   counter 
      r1   temp 
*********************************/
    _GBL_FUNC strlen 
    push {r1,r8}
    eor r8,r8 
1:  ldrb r1,[r0],#1 
    cbz r1,9f  
    add r8,#1 
    b 1b 
9:  mov r0,r8 
    pop {r1,r8}
    _RET     


/******************************
   cmove 
   move n characters 
   input:
    r0      src 
    r1      dest 
    r8      count 
  output:
    none:
  use: 
    r6     temp   
******************************/
    _GBL_FUNC cmove
    push {r6} 
1:  ands r8,r8
    beq 9f 
    cmp r0,r1 
    bmi move_from_end 
move_from_low: // move from low address toward high 
    ldrb r6,[r0],#1
    strb r6,[r1],#1
    subs r8,#1
    bne move_from_low
    b 9f 
move_from_end: // move from high address toward low 
    add r0,r0,r8 
    add r1,r1,r8     
3:  ldrb r6,[r0,#-1]!
    strb r6,[r1,#-1]!
    subs r8,#1
    bne 3b 
9:  pop {r6}
    _RET

/*********************************
  strcpy 
  copy .asciz string 
  input:
    r0   *string
    r1   *dest_buffer
  output:
    r0   *string
    r1   *dest_buffer 
  use:
    r7   temp
**********************************/
    _GBL_FUNC strcpy 
    push {r0,r1,r7}
1:  ldrb r7,[r0],#1
    cbz  r7, 9f 
    strb r7,[r1],#1
    b 1b 
9:  strb r7,[r1] 
    pop {r0,r1,r7}
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

/**********************************
      BASIC commands 
**********************************/

/*********************************
    syntax_error 
    display error message and 
    abort program 
  input:
    none  
  output: 
    none 
  use:
*********************************/
    _FUNC syntax_error 
    mov r0,#ERR_SYNTAX
    b tb_error 

/*********************************
    tb_error 
    display BASIC error and 
    abort program. 
  input:
    r0    error code   
  output: 
    none 
  use:
    r1    temp 
*********************************/
    _FUNC tb_error 
    ldr r1,=err_msg 
    lsl r0,#2 
    add r0,r1 
    ldr r0,[r0]
    _CALL uart_putsz
    b  warm_start  
    _RET 
err_msg:
	.word 0,err_mem_full, err_syntax, err_math_ovf, err_div0,err_no_line    
	.word err_run_only,err_cmd_only,err_duplicate,err_not_file,err_bad_value
	.word err_no_access,err_no_data,err_no_prog,err_no_fspace,err_buf_full    

    .section .rodata.tb_error 

err_mem_full: .asciz "Memory full\n" 
err_syntax: .asciz "syntax error\n" 
err_math_ovf: .asciz "math operation overflow\n"
err_div0: .asciz "division by 0\n" 
err_no_line: .asciz "invalid line number.\n"
err_run_only: .asciz "run time only usage.\n" 
err_cmd_only: .asciz "command line only usage.\n"
err_duplicate: .asciz "duplicate name.\n"
err_not_file: .asciz "File not found.\n"
err_bad_value: .asciz "bad value.\n"
err_no_access: .asciz "File in extended memory, can't be run from there.\n" 
err_no_data: .asciz "No data found.\n"
err_no_prog: .asciz "No program in RAM!\n"
err_no_fspace: .asciz "File system full.\n" 
err_buf_full: .asciz "Buffer full\n"

rt_msg: .asciz "\nrun time error, "
comp_msg: .asciz "\ncompile error, "
tk_id: .asciz "last token id: "


    .section  .text , "ax", %progbits 

/*********************************
     arg_list 
     extract command arguments
     and push them on parameter stack 
    input:
       none 
    output:
       r0  arguments count found
       args on dstack in order left to right 
    use:
       r8   arguments counter  
********************************/
     _FUNC arg_list 
     push {r8}

     pop {r8}      
     _RET 


/*********************************
   BASIC: BSET adr, mask   
   set bits [adr]=[adr] | mask  
   input:
     r0    adr 
     r1    mask 
    output;
      none 
    use:
      r8   temp
*******************************/     
    _FUNC BSET 
    push {r8,r9}
    sub sp,#8 
    _CALL arg_list 
    cmp r0,#2 
    beq 1f 
    mov r0,#ERR_SYNTAX
    b syntax_error 
1:  pop {r0,r1}
    ldr r8,[r0]
    mov r9,#1 
    lsl r9,r1 
    orr r8,r9,r8 
    str r8,[r0]
    pop {r8,r9}
    _RET 


/*********************************
   BASIC: BRES adr, mask   
   reset bits [adr]= [adr] & ~mask  
   input:
     r0    adr 
     r1    mask 
    output;
      none 
    use:
      r8   temp
      r9   temp  
*******************************/     
    _FUNC BRES 

    _RET 

/*********************************
   BASIC: BTGL adr, mask   
   toggle bits [adr]=[adr]^mask  
   input:
     r0    adr 
     r1    mask 
    output;
      none 
    use:
      r8   temp
      r9   temp  
*******************************/     
    _FUNC BTGL 

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

/************************************
    print firmware version 
    input: 
      none 
    output:
      none 
    use:
      r0 
***********************************/
    _FUNC prt_version 
    ldr r0,=version_msg 
    _CALL uart_putsz 
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
    .asciz "\nblue pill tiny BASIC, version "
version:
    .byte 0x10 
    .p2align 2 


/*********************************
   cold_start 
   initialize BASIC interpreter 
   input:
     r1    destination address 
   output:
    none 
   use:
     r0,r1,r8 
*********************************/
    _GBL_FUNC cold_start 
    push {r0,r1,r8}
// initialise parameters stack
   ldr r12,dstack_empty     
//copy system variables to ram 
    ldr r0,src_addr 
    mov r3,r1 // UPP  
    sub r8,r0,r1 
    push {r8} // map offset 
    mov r8,#ulast-uzero
    _CALL cmove  
    pop {r8}
    _CALL prt_version 
    pop {r0,r1,r8}
    _RET
    _CALL warm_init 
    b cmd_line   
src_addr:
  .word uzero
dstack_empty:
   .word _dstack 

/*****************************
    clear_vars 
    initialize variables to 0
  input:
    none 
  output:
    none 
  use:
    r8   counter 
*****************************/
    _FUNC clear_vars 
    push {r0,r1,r8}
    eor r0,r0 
    add r1,r3,#VARS
    mov r8,#26
1:  str r0,[r1],#4 
    subs r8,#1
    bne 1b  
    pop {r0,r1,r8}
    _RET 

/*****************************
   clear_basic 
   reset BASIC text pointers 
   and clear variables 
*****************************/
    _FUNC clear_basic
	eor r0,r0 
  str r0,[r3,#COUNT]
  str r0,[r3,#IN]
  add r0,r3,#FREE_RAM
  str r0,[r3,#TXTBGN]
  str r0,[r3,#TXTEND]
	_CALL clear_vars 
	_RET  

/***********************************
   warm_init 
   initialize interpreter context 
  input:
    none
  output:
    none 
  use:
    r0 
***********************************/
warm_init:
  eor r0,r0 
	str r0,[r3,FLAGS]
  str r0,[r3,LOOP_DEPTH] 
  mov r0, #DEFAULT_TAB_WIDTH
  str r0,[r3,#TAB_WIDTH]
	mov r0,#10 // default base decimal 
	str r0,[r3,#BASE]
  str r0,[r3,#BASICPTR]
  str r0,[r3,#IN]
  str r0,[r3,COUNT]  
	_RET  

/**********************************
   cmd_line 
   shell command line 
   input:
      none 
   output:
      none 
   use:

***********************************/
    _FUNC cmd_line 
    mov r0,#CR 
    _CALL uart_putc 
1:  ldr r0,tib
    _CALL readln 
    ands r0,r0 
    beq 1b 
    _CALL compile 
    ands r0,r0 
    beq 1b  
// interpret 
interpreter:
   ldr r0,[r3,#IN]
   ldr r1,[r3,#COUNT]
   cmp r0,r1 
   bmi interp_loop 
next_line:
  ldr r0,[r3,#FLAGS]
  tst r0,#(1<<FRUN)
  beq cmd_line 
  ldr r0,[r3,#BASICPTR]
  ldr r1,[r3,#IN]
  add r0,r1 
  ldr r1,[r3,#TXTEND]
  cmp r0,r1 
  bmi 1f 
  _CALL warm_start 
  b cmd_line
1:
  mov r0,#3 
  str r0,[r3,IN] 
interp_loop:
  _CALL next_token 
  cmp r0,#TK_NONE 
  beq next_line 
  cmp r0,#TK_CMD 
  bne 2f
  BLX r1
  b interp_loop 
2: 
  cmp r0,#TK_VAR 
  bne 3f 
  BLX let_var 
  b interp_loop
3: 
  cmp r0,#TK_ARRAY 
  bne 4f
  BLX let_array 
  b interp_loop
4: 
  cmp r0,#TK_COLON
  beq interp_loop
  b syntax_error

/*****************************
  next_token 
  extract next token 
  input:
    none 
  output:
    r0    token type 
    r1    token value 
  use:

****************************/
  _FUNC next_token 

  _RET 


tib: .word _tib 


/**********************************
    warm_start 
    start BASIC interpreter without 
    reset variables and code space 
  input:
    none 
  output:
    none 
  use:

**********************************/
    _FUNC warm_start 
// initialise parameters stack
   ldr r12,dstack_empty     

    b warm_start 

compile:


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
  .word RAM_ADR+1024 // TXTBGN
  .word RAM_ADR+1024 // TXTEND
  .word 0 //LOOP_DEPTH
  .word 0 // ARRAY_SIZE
  .word 0 // FLAGS
  .word 4 // TAB_WIDTH
  .word 0 // RX_HEAD
  .word 0 // RX_TAIL
  .space RX_QUEUE_SIZE,0 // RX_QUEUE
  .space VARS_SIZE,0 // VARS
  .space 4, 0 // padding 
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
