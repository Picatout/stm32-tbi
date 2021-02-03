//---------------------------------------------------------------------------
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
//
//---------------------------------------------------------------------------

  .equ  STACK_SIZE,0x100
  .equ  STACK_EMPTY,RAM_END
  .equ  STACK_FULL, (RAM_END - STACK_SIZE)
  .equ  TIB_SIZE,80 
  .equ  PAD_SIZE,128 
  .equ RX_QUEUE_SIZE,16

.equ DEFAULT_TAB_WIDTH,4 // default tabulation width 
.equ EOF,0xff // end of file marker 

//--------------------------------------
//   constantes related to Arduino 
//   API mapping 
//-------------------------------------
  .equ INP,0
  .equ OUTP,1 

//--------------------------------------
//       token attribute
//--------------------------------------
// bits 4:5 identify token group 
// 0x0n -> miscelinous 
// 0x1n -> +|- operators 
// 0x2n -> *|/|% operators
// 0x3n -> relational operators 
  .equ TK_NONE,0       // not a token 
  .equ TK_COLON,1      // command separator ':' 
  .equ TK_QSTR,2     // quoted string  
  .equ TK_CHAR,3       // ASCII character 
  .equ TK_VAR,5      // variable index 
  .equ TK_ARRAY,6     // array variable '@' 
  .equ TK_LPAREN,7     // left parenthesis '('
  .equ TK_RPAREN,8     // right parenthesis ')'
  .equ TK_COMMA,9     // item separator ',' 
  .equ TK_SHARP,0xa     // print colon width '#' 
  .equ TK_CMD,0xb      // BASIC command   
  .equ TK_IFUNC,0xc    // BASIC integer function
  .equ TK_CFUNC,0xd    // BASIC character function
  .equ TK_CONST,0xe    // BASIC constant 
  .equ TK_INTGR,0xf    // 32 bits integer 
  .equ TK_PLUS,0x10    // addition operator '+'
  .equ TK_MINUS,0x11   // subtraction operator '-'
  .equ TK_MULT,0x20    // multiplication operator '*'
  .equ TK_DIV,0x21     // division operator '/'
  .equ TK_MOD,0x22     // modulo operator '%'

// don't change these token values 
// values chosen to be used as a mask.
// bit 7   1 for dictionary words else 0 
// bits 6  always 0 
// bits 5:4 identify group 
// bits 3:0 token identifier inside group  
  .equ TK_GT,0x31      // relation operator '>'
  .equ TK_EQUAL,0x32   // assignment or relation operator '='
  .equ TK_GE,0x33      // relation operator '>='
  .equ TK_LT,0x34      // relation operator '<'
  .equ TK_LE,0x36      // relation operator '<='
  .equ TK_NE,0x35      // relation operator '<>' not equal 
// token groups 
  .equ TK_GRP_MASK,0x30 // groups bits selector 
  .equ TK_GRP_MISC,0x00 // miscelinous group 
  .equ TK_GRP_ADD,0x10  // additive operators
  .equ TK_GRP_MULT,0x20 // multiplicative operators
  .equ TK_GRP_RELOP,0x30 //relational operators. 
  .equ CMD_END,2 

//--------------------------------------
//   error codes 
//--------------------------------------
  .equ ERR_NONE,0
  .equ ERR_MEM_FULL,1 
  .equ ERR_SYNTAX,2
  .equ ERR_MATH_OVF,3
  .equ ERR_DIV0,4 
  .equ ERR_NO_LINE,5
  .equ ERR_RUN_ONLY,6
  .equ ERR_CMD_ONLY,7
  .equ ERR_DUPLICATE,8
  .equ ERR_NOT_FILE,9
  .equ ERR_BAD_VALUE,10
  .equ ERR_NO_ACCESS,11
  .equ ERR_NO_DATA,12 
  .equ ERR_NO_PROG,13
  .equ ERR_NO_FSPACE,14
  .equ ERR_BUF_FULL,15

//--------------------------------------
//   assembler flags 
//-------------------------------------
.equ MATH_OVF,0 // if 1 then stop on math overflow 

.equ CELL_SIZE,4 


//-------------------------------
//  macros used to help debugging
//-------------------------------
  .equ DEBUG,0

    UPP .req r4  // base address system variables 
    VADR .req r5  // address FOR loop variable 
    LIMIT .req r6   // LOOP limit 
    INCR  .req  r7  // LOOP increment 
    T1  .req r8     // temporary register 
    T2  .req r9     // temporary register 
    IN  .req r10    //  index in text line or token list 
    BPTR .req r11   //  buffer address or BASIC line address 
    DP   .req r12   //  parameter stack pointer 

/***************************
  SYSTEM variables offset 
  from UPP  
***************************/ 

  .equ IN_SAVED,0 // set by get_token before parsing next token, used by unget_token
  .equ COUNT, IN_SAVED+4  // current BASIC line length and tib text length  
  .equ BASICPTR,COUNT+4 // point to current BASIC line address.
  .equ DATAPTR, BASICPTR+4 // point to DATA address
  .equ DATA,DATAPTR+4 // index to next data item 
  .equ DATALEN, DATA+4 // length of data line 
  .equ BASE,DATALEN+4 // nemeric base used to print integer 
  .equ TICKS,BASE+4 // milliseconds ticks counter (see Timer4UpdateHandler)
  .equ TIMER,TICKS+4 //  milliseconds count down timer 
  .equ SEED,TIMER+4  // xorshift 16 seed x  used by RND() function 
  .equ FSPTR,SEED+4 //  pointer used by file system
  .equ FFREE,FSPTR+4 // flash free address // file system free space pointer
  .equ TXTBGN,FFREE+4 // tokenized BASIC text beginning address 
  .equ TXTEND,TXTBGN+4 // tokenized BASIC text end address 
  .equ LOOP_DEPTH,TXTEND+4  // level of nested loop. Conformity check   
  .equ ARRAY_SIZE,LOOP_DEPTH+4 // array size, free RAM left after BASIC code.  
  .equ FLAGS,ARRAY_SIZE+4 // various boolean flags
  .equ TAB_WIDTH,FLAGS+4 // print colon width (default 4)
  .equ RX_HEAD,TAB_WIDTH+4 // rx_queue head pointer
  .equ RX_TAIL,RX_HEAD+4 // rx1_queue tail pointer  
  .equ RX_QUEUE,RX_TAIL+4 // UART1 receive circular queue 
  .equ VARS,RX_QUEUE+RX_QUEUE_SIZE // BASIC variables 
  .equ CELLL,4 // size of integer 
  .equ VARS_SIZE, CELLL*26 // space used by 26 BASIC variables (A-Z)
  .equ FREE_RAM,VARS+VARS_SIZE // basic programs start here 
  .equ ARRAY_ADR,FREE_RAM+4 // array address at bottom of pad  

/* flags used by BASIC interpreter */ 
	.equ FRUN,(1<<0) // programm running
	.equ FTRAP,(1<<1) // inside trap handler 
	.equ FLOOP,(1<<2) // FOR loop in preparation 
	.equ FSLEEP,(1<<3) // in halt mode SLEEP 
	.equ FBREAK,(1<<4) // break point flag 
	.equ FCOMP,(1<<5)  // compiling flags 
	.equ FAUTORUN,(1<<6) // auto start program running 

	.equ AUTORUN_NAME,0x8001C00  // address in FLASH  where auto run file name is saved 
  
  .equ FIRST_DATA_ITEM,6 // first DATA item offset on line.
	.equ MAX_LINENO,0x7fff// BASIC maximum line number 

/***********************************************
*       MACROS
***********************************************/
	.macro _CALL fn /* low level routine call */ 
 	PUSH {LR}
	BL \fn  
  POP {LR}
	.endm
	
	.macro	_RET /* return from subroutine */
	BX	LR
	.endm

	.macro _MOV32 REG LITERAL   /* load register with 32 bits literal */
	MOV \REG, #\LITERAL&0xffff
	MOVT \REG, #\LITERAL>>16
	.endm

// local function header 
  .macro _FUNC label 
  .p2align 2 
  .type \label, %function  
\label:
  .endm 

// global function header 
  .macro _GBL_FUNC label 
  .global \label 
  _FUNC \label 
  .endm 


/********************************
    dictionary structure
------------------------------
 format:
   link:    
   name_length+flags:  1 byte, bits 0:4 lenght,5:8 flags  
   cmd_name: 31 characters max 
   cmd_index: 2 bytes 
**********************************/
	.macro _dict_entry tok_type,name,cmd_idx 
  .word LINK 
  .word \cmd_idx 
	.word \tok_type  	
	.equ LINK,.
	.asciz "\name"
	.p2align 2 
	.endm 

  // pop parameter in register 
  .macro _POP  reg 
  ldmia  DP!,{\reg}
  .endm 

  // push register on parameter stack 
  .macro _PUSH reg 
  stmdb DP!,{\reg}
  .endm 

  .macro _UNGET_TOKEN 
  ldr IN,[UPP,#IN_SAVED]
  ldr BPTR,[UPP,#BASICPTR] 
  .endm 

 // create a text data 
 .macro _TEXT label,text
 \label: .asciz "\text"
 .p2align 2 
 .endm 
