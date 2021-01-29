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


/********************************
    HELPER FUNCTIONS 
********************************/

/**********************************
   strlen 
   return length of asciz 
   input:
      r0    *asciz 
   output:
      r0   length 
   use:
      r1   string length 
      r2   char 
*********************************/
    _GBL_FUNC strlen 
    push {r1,r2}
    eor r1,r1  // strlen 
1:  ldrb r2,[r0],#1 
    cbz r2,9f  
    add r1,#1 
    b 1b 
9:  mov r0,r1 
    pop {r1,r2}
    _RET     


/******************************
   cmove 
   move n characters 
   input:
    r0      src 
    r1      dest 
    r2      count 
  output:
    none:
  use: 
    T1    temp   
******************************/
    _GBL_FUNC cmove
    push {T1} 
    ands r2,r2
    beq 9f 
    cmp r0,r1 
    bmi move_from_end 
move_from_low: // move from low address toward high 
    ldrb T1,[r0],#1
    strb T1,[r1],#1
    subs r2,#1
    bne move_from_low
    b 9f 
move_from_end: // move from high address toward low 
    add r0,r0,r2 
    add r1,r1,r2     
1:  ldrb T1,[r0,#-1]!
    strb T1,[r1,#-1]!
    subs r2,#1
    bne 1b 
9:  pop {T1}
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
    r2   char
**********************************/
    _GBL_FUNC strcpy 
    push {r0,r1,r2}
1:  ldrb r2,[r0],#1
    cbz  r2, 9f 
    strb r2,[r1],#1
    b 1b 
9:  strb r2,[r1] 
    pop {r0,r1,r2}
    _RET 

/*********************************
  cpstr 
  compare 2  .asciz strings 
  input:
    r0  *str1 
    r1  *str2
  output:
    r0  <0 str1<str2 
        0  str1==str2 
        >0  str1>str2  
  use:
    r2  *str1
    r3 char 1 
    r4 char 2  
*********************************/
  _FUNC cpstr
    push {r2,r3,r4}
    mov r2, r0
1:
    ldrb r3,[r2],#1  
    ldrb r4,[r1],#1
    cbz r3, 2f 
    cbz r4, 2f 
    subs r0,r3,r4 
    beq 1b
2:  sub r0,r3,r4 
    pop {r2,r3,r4}
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
    _CALL uart_puts
    ldr r0,dstack_empty
    mov sp,r0 
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
       T1   arguments counter  
********************************/
     _FUNC arg_list 
     push {T1}

     pop {T1}      
     _RET 

/************************************
    func_args 
    get and stack function parameters
  input:
    none 
  output:
    r0    parameter count 
  use:

************************************/
    _FUNC func_args 

  
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
      T1   temp
      T2   temp  
*******************************/     
    _FUNC BTGL 

    _RET 




//---------------------------------
// dictionary search 
// input:
//	 r0   target name
//   r1		dictionary first name field address  
// output:
//  r0 		token attribute 
//  r1		cmd_index if r0!=TK_NONE  
// use:
//  r2   length dictionary name 
//---------------------------------
  _FUNC search_dict
  push {r2}
  push {r0,r1}
1:
  ldrb r0,[r1],#1 
  orrs r0,r0
  beq 9f // null byte  -> end of dictinary 
  ldr r0,[sp]  
  _CALL cpstr 
  beq 2f 
  ldr r1,[sp,#4]
  ldr r1,[r1,#-12]
  str r1,[sp,#4]
  b 1b   
2: // found
  ldr r1,[sp,#4]
  ldrb r0,[r1,#-4] // token attribute 
  ldr r1,[r1,#-8]  // command index 
9: add sp,#8  // drop pushed r0,r1
   pop {r2}
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
    .asciz "\nblue pill tiny BASIC, version "
version:
    .byte 0x10 
    .p2align 2 


/*********************************
   cold_start 
   initialize BASIC interpreter 
   input:
     none 
   output:
    none 
   use:
     r0,r1,r2,r3 
*********************************/
    _GBL_FUNC cold_start 
    push {r0,r1,r2,r3}
// initialise parameters stack
   ldr DSP,dstack_empty     
//copy system variables to ram 
    ldr r0,src_addr 
    ldr r1,dest_addr 
    mov UPP,r1 // system variables base address   
    mov r2,#ulast-uzero
    _CALL cmove  
    _CALL prt_version 
    pop {r0,r1,r2,r3}
    _RET
    _CALL warm_init 
    b cmd_line   
src_addr:
  .word uzero
dest_addr:
  .word (RAM_ADR /*+ (isr_end - isr_vectors)*/)
test:
  .word isr_vectors, isr_end 

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
    r0,r1,r2 
*****************************/
    _FUNC clear_vars 
    push {r0,r1,r2}
    eor r0,r0 
    add r1,UPP,#VARS
    mov r2,#26
1:  str r0,[r1],#4 
    subs r2,#1
    bne 1b  
    pop {r0,r1,r2}
    _RET 

/*****************************
   clear_basic 
   reset BASIC text pointers 
   and clear variables 
*****************************/
    _FUNC clear_basic
  	eor r0,r0 
    str r0,[UPP,#COUNT]
    str r0,[UPP,#IN_SAVED]
    add r0,UPP,#FREE_RAM
    str r0,[UPP,#TXTBGN]
    str r0,[UPP,#TXTEND]
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
	mov IN,#0 // BASIC line index 
  mov BPTR,#0 // BASIC line address 
  eor r0,r0 
  str r0,[UPP,#BASICPTR]
  str r0,[UPP,#IN_SAVED]
  str r0,[UPP,#COUNT]  
	str r0,[UPP,#FLAGS]
  str r0,[UPP,#LOOP_DEPTH] 
  mov r0, #DEFAULT_TAB_WIDTH
  str r0,[UPP,#TAB_WIDTH]
	mov r0,#10 // default base decimal 
	str r0,[UPP,#BASE]
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
    ands r0,r0 // empty line 
    beq 1b 
    _CALL compile // tokenize BASIC text
    ands r0,r0 
    beq 1b  // tokens stored in text area 
// interpret tokenized line 
interpreter:
   eor IN,#3 
   ldr BPTR,[UPP,#BASICPTR]
   ldr r0,[UPP,#COUNT]
   cmp IN,r0  
   bmi interp_loop
// end of line reached     
next_line:
  ldr r0,[UPP,#FLAGS]
  tst r0,#(1<<FRUN)
  beq cmd_line 
  ldr IN,[UPP,#IN_SAVED]
  ldr BPTR,[UPP,#BASICPTR]
  add r0,IN,BPTR  
  ldr r1,[UPP,#TXTEND]
  cmp r0,r1 
  bmi 1f 
  _CALL warm_start 
  b cmd_line
1:
  mov IN,#3 
  str IN,[UPP,#IN_SAVED] 
interp_loop:
  _CALL next_token 
  cmp r0,#TK_NONE 
  beq next_line 
  cmp r0,#TK_CMD 
  bne 2f
  BX r1
  b interp_loop 
2: 
  cmp r0,#TK_VAR 
  bne 3f 
  b let_var 
  b interp_loop
3: 
  cmp r0,#TK_ARRAY 
  bne 4f
  b let_array 
  b interp_loop
4: 
  cmp r0,#TK_COLON
  beq interp_loop
  b syntax_error

/*****************************
  next_token 
  extract next token from token list 
  input:
    none 
  output:
    r0    token attribute
    r1    token value if there is one 
  use:
    none 
****************************/
  _FUNC next_token 
  ldr r0,[UPP,#COUNT]
  cmp IN,r0 
  bmi 0f 
  eor r0,r0 
  b 9f  
0: 
  str IN,[UPP,#IN_SAVED]
  ldrb r0,[BPTR,IN] // token attribute 
  and r0,#0x3f // limit mask 
  add T1,#1
  ldr r1,=tbb_ofs 
  tbb [r1,r0]
1: // pc reference point 
2: // .byte param
  ldrb r1,[T2,T1]
  add T1,#1 
  b 9f 
3: // .hword param 
  ldrh r1,[T2,T1]
  add T1,#2 
  b 9f 
4: // .word param  
  ldr r1,[T2,T1]
  add T1,#4
  b 9f 
5: // .asciz param 
  add r1,T2,T1
  mov r0,r1  
  _CALL strlen 
  add T1,r0
  add T1,#1
  mov r0,#TK_QSTR
  b 9f  
8: // syntax error 
   b syntax_error 
9:
   str T1,[UPP,#IN_SAVED]
  _RET

  .p2align 2
tbb_ofs: // offsets table for tbb instruction 
  .byte (9b-1b)/2,(9b-1b)/2
  .byte (5b-1b)/2,(2b-1b)/2,(2b-1b)/2,(3b-1b)/2
  .byte (9b-1b)/2,(9b-1b)/2,(9b-1b)/2,(9b-1b)/2
  .byte (4b-1b)/2,(4b-1b)/2,(4b-1b)/2,(4b-1b)/2,(4b-1b)/2
  .byte (9b-1b)/2,(9b-1b)/2  
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2
  .byte (9b-1b)/2,(9b-1b)/2,(9b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2   
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2

  .p2align 2 

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
   ldr DSP,dstack_empty     

    b warm_start 

/***********************************
    get_array_element 
    return index of array element 
  input:
    none 
  output:
    r0   address of element 
  use:

************************************/
    _FUNC get_array_element 

    _RET 

    _FUNC relation 

    _RET 

/*********************************
    compile 
    tokenize source line 
  input:
    none 
  output:
    r0 
  use:

***********************************/
    _FUNC compile

    _RET 

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
  _dict_entry TK_NONE,"",0 
  _dict_entry TK_CMD,XTRMT,XTRMT_IDX // xmodem transmit
  _dict_entry TK_CMD,XRCV,XRCV_IDX // xmodem receive
  _dict_entry TK_IFUNC,XOR,XOR_IDX //bit_xor
  _dict_entry TK_CMD,WRITE,WRITE_IDX //write  
  _dict_entry TK_CMD,WORDS,WORDS_IDX //words 
  _dict_entry TK_CMD,WAIT,WAIT_IDX //wait 
  _dict_entry TK_IFUNC,USR,USR_IDX //usr
  _dict_entry TK_CMD,UNTIL,UNTIL_IDX //until 
  _dict_entry TK_IFUNC,UFLASH,UFLASH_IDX //uflash 
  _dict_entry TK_IFUNC,UBOUND,UBOUND_IDX //ubound
  _dict_entry TK_CMD,TONE,TONE_IDX //tone  
  _dict_entry TK_CMD,TO,TO_IDX //to
  _dict_entry TK_CMD,TIMER,TIMER_IDX //set_timer
  _dict_entry TK_IFUNC,TIMEOUT,TMROUT_IDX //timeout 
  _dict_entry TK_IFUNC,TICKS,TICKS_IDX //get_ticks
  _dict_entry TK_CMD,STOP,STOP_IDX //stop 
  _dict_entry TK_CMD,STEP,STEP_IDX //step 
  _dict_entry TK_CMD,SPIWR,SPIWR_IDX //spi_write
  _dict_entry TK_CMD,SPISEL,SPISEL_IDX //spi_select
  _dict_entry TK_IFUNC,SPIRD,SPIRD_IDX // spi_read 
  _dict_entry TK_CMD,SPIEN,SPIEN_IDX //spi_enable 
  _dict_entry TK_CMD,SLEEP,SLEEP_IDX //sleep 
  _dict_entry TK_IFUNC,SIZE,SIZE_IDX //size
  _dict_entry TK_CMD,SHOW,SHOW_IDX //show 
  _dict_entry TK_CMD,SAVE,SAVE_IDX //save
  _dict_entry TK_CMD,RUN,RUN_IDX //run
  _dict_entry TK_IFUNC,RSHIFT,RSHIFT_IDX //rshift
  _dict_entry TK_IFUNC,RND,RND_IDX //random 
  _dict_entry TK_CMD,RETURN,RET_IDX //return 
  _dict_entry TK_CMD,RESTORE,REST_IDX //restore 
  _dict_entry TK_CMD,REMARK,REM_IDX //remark 
  _dict_entry TK_CMD,REBOOT,RBT_IDX //cold_start
  _dict_entry TK_IFUNC,READ,READ_IDX //read  
  _dict_entry TK_IFUNC,QKEY,QKEY_IDX //qkey  
  _dict_entry TK_IFUNC,PRTI,PRTI_IDX //const_porti 
  _dict_entry TK_IFUNC,PRTH,PRTH_IDX //const_porth 
  _dict_entry TK_IFUNC,PRTG,PRTG_IDX //const_portg 
  _dict_entry TK_IFUNC,PRTF,PRTF_IDX //const_portf
  _dict_entry TK_IFUNC,PRTE,PRTE_IDX //const_porte
  _dict_entry TK_IFUNC,PRTD,PRTD_IDX //const_portd
  _dict_entry TK_IFUNC,PRTC,PRTC_IDX //const_portc
  _dict_entry TK_IFUNC,PRTB,PRTB_IDX //const_portb
  _dict_entry TK_IFUNC,PRTA,PRTA_IDX //const_porta 
  _dict_entry TK_CMD,PRINT,PRT_IDX //print 
  _dict_entry TK_IFUNC,POUT,POUT_IDX //const_output
  _dict_entry TK_CMD,POKE,POKE_IDX //poke 
  _dict_entry TK_CMD,PMODE,PMODE_IDX //pin_mode 
  _dict_entry TK_IFUNC,PINP,PINP_IDX //const_input
  _dict_entry TK_IFUNC,PEEK,PEEK_IDX //peek 
  _dict_entry TK_CMD,PAUSE,PAUSE_IDX //pause 
  _dict_entry TK_IFUNC,PAD,PAD_IDX //pad_ref 
  _dict_entry TK_IFUNC,OR,OR_IDX //bit_or
  _dict_entry TK_IFUNC,ODR,ODR_IDX //const_odr 
  _dict_entry TK_IFUNC,NOT,NOT_IDX //func_not 
  _dict_entry TK_CMD,NEXT,NEXT_IDX //next 
  _dict_entry TK_CMD,NEW,NEW_IDX //new
  _dict_entry TK_IFUNC,MULDIV,MULDIV_IDX //muldiv 
  _dict_entry TK_IFUNC,LSHIFT,LSHIFT_IDX //lshift
  _dict_entry TK_IFUNC,LOG,LOG_IDX //log2 
  _dict_entry TK_CMD,LOAD,LOAD_IDX //load 
  _dict_entry TK_CMD,LIST,LIST_IDX //list
  _dict_entry TK_CMD,LET,LET_IDX //let 
  _dict_entry TK_IFUNC,KEY,KEY_IDX //key 
  _dict_entry TK_CMD,IWDGREF,IWDGREF_IDX //refresh_iwdg
  _dict_entry TK_CMD,IWDGEN,IWDGEN_IDX //enable_iwdg
  _dict_entry TK_IFUNC,INVERT,INVERT_IDX //invert 
  _dict_entry TK_CMD,INPUT,INPUT_IDX //input_var  
  _dict_entry TK_CMD,IF,IF_IDX //if 
  _dict_entry TK_IFUNC,IDR,IDR_IDX //const_idr 
  _dict_entry TK_CMD,HEX,HEX_IDX //hex_base
  _dict_entry TK_IFUNC,GPIO,GPIO_IDX //gpio 
  _dict_entry TK_CMD,GOTO,GOTO_IDX //goto 
  _dict_entry TK_CMD,GOSUB,GOSUB_IDX //gosub 
  _dict_entry TK_CMD,FORGET,FORGET_IDX //forget 
  _dict_entry TK_CMD,FOR,FOR_IDX //for 
  _dict_entry TK_CMD,FCPU,FCPU_IDX //fcpu 
  _dict_entry TK_CMD,END,END_IDX //cmd_end  
  _dict_entry TK_IFUNC,EEPROM,EEPROM_IDX //const_eeprom_base   
  _dict_entry TK_CMD,DWRITE,DWRITE_IDX //digital_write
  _dict_entry TK_IFUNC,DREAD,DREAD_IDX //digital_read
  _dict_entry TK_CMD,DO,DO_IDX //do_loop
  _dict_entry TK_CMD,DIR,DIR_IDX //directory 
  _dict_entry TK_CMD,DEC,DEC_IDX //dec_base
  _dict_entry TK_IFUNC,DDR,DDR_IDX //const_ddr 
  _dict_entry TK_CMD,DATALN,DATALN_IDX //data_line  
  _dict_entry TK_CMD,DATA,DATA_IDX //data  
  _dict_entry TK_IFUNC,CRL,CRL_IDX //const_cr1 
  _dict_entry TK_IFUNC,CRH,CRH_IDX //const_cr2 
  _dict_entry TK_CFUNC,CHAR,CHAR_IDX //char
  _dict_entry TK_CMD,BYE,BYE_IDX //bye 
  _dict_entry TK_CMD,BTOGL,BTOGL_IDX //bit_toggle
  _dict_entry TK_IFUNC,BTEST,BTEST_IDX //bit_test 
  _dict_entry TK_CMD,BSET,BSET_IDX //bit_set 
  _dict_entry TK_CMD,BRES,BRES_IDX //bit_reset
  _dict_entry TK_IFUNC,BIT,BIT_IDX //bitmask
  _dict_entry TK_CMD,AWU,AWU_IDX //awu 
  _dict_entry TK_CMD,AUTORUN,AUTORUN_IDX //autorun
  _dict_entry TK_IFUNC,ASC,ASC_IDX //ascii
  _dict_entry TK_IFUNC,AND,AND_IDX //bit_and
  _dict_entry TK_IFUNC,ADCREAD,ADCREAD_IDX //analog_read
  _dict_entry TK_CMD,ADCON,ADCON_IDX //power_adc 
first_link: 
  .word LINK 
  .word ABS_IDX 
  .byte TK_IFUNC
kword_dict: // first name field 
  .equ LINK,. 
  .asciz "ABS" 
  .p2align 2 

//comands and fonctions address table 	
code_addr:
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
	.word 0 

/**********************************
    BASIC commands and functions 
**********************************/

/*******************************
  BASIC:  ABS expr 
  input:
    none 
  output:
    r0    token type 
    r1    abs(expr)
  use:
    none 
******************************/
    _FUNC abs 
    _CALL arg_list
    cmp r0,#1 
    beq 1f 
    b syntax_error 
1:  _POP r1 
    tst r1,#(1<<31)
    beq 9f
    rsb r1,#0 
9:  mov r0,#TK_INTGR
   _RET 

    _FUNC power_adc
    _RET

    _FUNC analog_read
    _RET

    _FUNC bit_and
    _RET

    _FUNC ascii
    _RET

    _FUNC autorun
    _RET

    _FUNC awu
    _RET

    _FUNC bitmask
    _RET 

  
  /*********************************
   BASIC: BRES adr, mask   
   reset bits [adr]= [adr] & ~mask  
   input:
     none 
    output;
      none 
    use:
      T1   temp
      T2   temp 
*******************************/     
  _FUNC bit_reset
    _CALL arg_list 
    cmp r0,#2 
    beq 1f 
    b syntax_error 
1:  _POP r1 //mask 
    _POP r0 //address 
    ldr T2,[r0] 
    eor r1,#-1 // ~mask 
    and r1,T2
    str r1,[r0]
    b interp_loop 


/*********************************
   BASIC: BSET adr, mask   
   reset bits [adr]= [adr] & ~mask  
   input:
      none 
    output;
      none 
    use:
      T1   temp
      T2   temp  
*******************************/     
    _FUNC bit_set
    _CALL arg_list 
    cmp r0,#2 
    beq 1f 
    b syntax_error 
1:  _POP r1 //mask 
    _POP r0 //address 
    ldr T2,[r0] 
    orr r1,T2
    str r1,[r0]
    b interp_loop 

  /*********************************
   BASIC: BTOGL adr, mask   
   reset bits [adr]= [adr] & ~mask  
   input:
     r0    adr 
     r1    mask 
    output;
      none 
    use:
      T1   temp
      T2   temp  
*******************************/     
  _FUNC bit_toggle
    _CALL arg_list 
    cmp r0,#2 
    beq 1f 
    b syntax_error 
1:  _POP r1 //mask 
    _POP r0 //address 
    ldr T2,[r0] 
    eor r1,T2
    str r1,[r0]
    b interp_loop 

    _FUNC bit_test
    b interp_loop

    _FUNC bye
    b interp_loop

    _FUNC char
    b interp_loop

    _FUNC const_cr2
    b interp_loop 

    _FUNC const_cr1
    b interp_loop

    _FUNC data
    b interp_loop

    _FUNC data_line
    b interp_loop

    _FUNC const_ddr
    b interp_loop

    _FUNC dec_base
    b interp_loop

    _FUNC directory
    b interp_loop

    _FUNC do_loop
    b interp_loop

    _FUNC digital_read
    b interp_loop

    _FUNC digital_write
    b interp_loop 

    _FUNC cmd_end
    b interp_loop

    _FUNC const_eeprom_base
    b interp_loop

    _FUNC fcpu
    b interp_loop

    _FUNC for
    b interp_loop

    _FUNC forget
    b interp_loop

    _FUNC gosub
    b interp_loop

    _FUNC goto
    b interp_loop

    _FUNC gpio
    b interp_loop 

    _FUNC hex_base
    b interp_loop

    _FUNC const_idr
    b interp_loop

    _FUNC if
    b interp_loop

    _FUNC input_var
    b interp_loop

    _FUNC invert
    b interp_loop

    _FUNC enable_iwdg
    b interp_loop

    _FUNC refresh_iwdg
    b interp_loop

    _FUNC key
    b interp_loop 

/******************************
  BASIC: [let] var=expr 
         [let] @(expr)=expr
  input:
    none 
  output:
    none 
  use:

****************************/         
    _FUNC let
    _CALL next_token 
    cmp r0,#TK_VAR
    beq let_var 
    cmp r0,#TK_ARRAY 
    beq let_array 
    b syntax_error 
let_var:
    _CALL get_array_element
let_array: 
    _PUSH r0 
    _CALL next_token 
    cmp r0,#TK_EQUAL 
    beq 1f 
    b syntax_error 
1:  _CALL relation  
    cmp r0,#TK_INTGR
    beq 2f 
    b syntax_error 
2:  _POP r0 
    str r1,[r0]
    mov r0,#TK_NONE 
    b interp_loop 

    _FUNC list
    b interp_loop

    _FUNC load
    b interp_loop

    _FUNC log2
    b interp_loop

    _FUNC lshift
    b interp_loop

    _FUNC muldiv
    b interp_loop

    _FUNC next
    b interp_loop

    _FUNC new
    b interp_loop 

    _FUNC func_not
    b interp_loop

    _FUNC const_odr
    b interp_loop

    _FUNC bit_or
    b interp_loop

    _FUNC pad_ref
    b interp_loop

    _FUNC pause
    b interp_loop

    _FUNC pin_mode
    b interp_loop

    _FUNC peek
    b interp_loop

    _FUNC const_input
    b interp_loop 

    _FUNC poke
    b interp_loop

    _FUNC const_output
    b interp_loop

    _FUNC print
    b interp_loop

    _FUNC const_porta
    b interp_loop

    _FUNC const_portb
    b interp_loop

    _FUNC const_portc
    b interp_loop

    _FUNC const_portd
    b interp_loop

    _FUNC const_porte
    b interp_loop 

    _FUNC const_portf
    b interp_loop

    _FUNC const_portg
    b interp_loop

    _FUNC const_porth
    b interp_loop

    _FUNC const_porti
    b interp_loop

    _FUNC qkey
    b interp_loop

    _FUNC read
    b interp_loop

    _FUNC remark
    b interp_loop 

    _FUNC restore
    b interp_loop

    _FUNC return
    b interp_loop

    _FUNC  random
    b interp_loop

    _FUNC rshift
    b interp_loop

    _FUNC run
    b interp_loop

    _FUNC save
    b interp_loop

    _FUNC show
    b interp_loop

    _FUNC size
    b interp_loop 

    _FUNC sleep
    b interp_loop

    _FUNC spi_read
    b interp_loop

    _FUNC spi_enable
    b interp_loop

    _FUNC spi_select
    b interp_loop

    _FUNC spi_write
    b interp_loop

    _FUNC step
    b interp_loop

    _FUNC stop
    b interp_loop

    _FUNC get_ticks
    b interp_loop 

    _FUNC set_timer
    b interp_loop

    _FUNC timeout
    b interp_loop

    _FUNC to
    b interp_loop

    _FUNC tone
    b interp_loop

    _FUNC ubound
    b interp_loop

    _FUNC uflash
    b interp_loop

    _FUNC until
    b interp_loop

    _FUNC usr
    b interp_loop 

    _FUNC wait
    b interp_loop

    _FUNC words
    b interp_loop

    _FUNC write
    b interp_loop

    _FUNC bit_xor
    b interp_loop

    _FUNC transmit
    b interp_loop

    _FUNC receive
    b interp_loop 


/*************************************************
   extra FLASH memory not used by Tiny BASIC
   is used to save BASIC programs.
************************************************/
  .p2align 10  // align to 1KB, smallest erasable segment 
  .section .fs
FILE_SYSTEM: // file system start here
