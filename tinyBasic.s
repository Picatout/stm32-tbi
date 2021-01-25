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

/*********************************
   cold_init 
   initialize BASIC interpreter 
   input:
     r1    destination address 
   output:
    none 
   use:
     r0,r1,r8 
*********************************/
    _GBL_FUNC cold_init
    push {r0,r1,r8}
//copy system variables to ram 
    ldr r0,src_addr 
    mov r3,r1 // UPP  
    sub r8,r0,r1 
    push {r8} // map offset 
    mov r8,#ulast-uzero
    _CALL cmove  
    pop {r8}
    pop {r0,r1,r8}
    _RET 
src_addr:
  .word uzero


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
