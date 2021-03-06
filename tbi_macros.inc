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
  .equ  RX_QUEUE_SIZE,16
  .equ  DSTACK_TOP,0x20004f00 
  .equ  RSTACK_TOP,0x20005000
  

.equ DEFAULT_TAB_WIDTH,4 // default tabulation width 
.equ EOF,0xff // end of file marker 

//--------------------------------------
//       token attribute
//--------------------------------------
// tokens without attributes 
  .equ TK_NONE,0       // not a token mark end of line 
  .equ TK_COLON,1      // ':' command separator 
  .equ TK_COMMA,2      // ',' list separator
  .equ TK_SEMIC,3      // ';' print command column align 
  .equ TK_SHARP,4      // '#' print command set column width 
  .equ TK_LPAREN,5     // '(' 
  .equ TK_RPAREN,6     // ')'
  .equ TK_PLUS,7       // '+'
  .equ TK_MINUS,8      // '-'
  .equ TK_MULT,9       // '*'
  .equ TK_DIV,10       // '/'
  .equ TK_MOD,11       // '%'   arithmetic modulo
  .equ TK_ARRAY,12     // '@'   array variable  
  .equ TK_EQUAL,13     // '='   assignment and relop 
  .equ TK_GT,14        // '>'   relop 
  .equ TK_LT,15        // '<'   relop 
  .equ TK_GE,16        // '>='  relop 
  .equ TK_LE,17        // '<='  relop
  .equ TK_NE,18        // '<>'  relop 
// tokens with .byte attribute 
  .equ TK_CHAR,19      // ASCII character 
  .equ TK_VAR,20       // variable index 
  .equ TK_IFUNC,21     // BASIC integer function
  .equ TK_CFUNC,22     // BASIC character function
  .equ TK_CMD,23       // BASIC command
// token with .word attribute 
  .equ TK_SCONST,24    // SYSTEM constant    
  .equ TK_CONST,25    // BASIC constant 
  .equ TK_LABEL,26
  .equ TK_INTGR,27    // 32 bits integer 
  .equ TK_QSTR,28    // quoted string  
  .equ TK_INVALID,29  // value >=27 are invalid 

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
  .equ ERR_CANT_PROG,16
  

//--------------------------------------
//   assembler flags 
//-------------------------------------
.equ MATH_OVF,0 // if 1 then stop on math overflow 

.equ CELL_SIZE,4 


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
  .equ FSFREE,FSPTR+4 // flash free address // file system free space pointer
  .equ TXTBGN,FSFREE+4 // tokenized BASIC text beginning address 
  .equ TXTEND,TXTBGN+4 // tokenized BASIC text end address 
  .equ LOOP_DEPTH,TXTEND+4  // level of nested loop. Conformity check   
  .equ ARRAY_SIZE,LOOP_DEPTH+4 // array size, free RAM left after BASIC code.  
  .equ FLAGS,ARRAY_SIZE+4 // various boolean flags
  .equ TAB_WIDTH,FLAGS+4 // print colon width (default 4)
  .equ RX_HEAD,TAB_WIDTH+4 // rx_queue head pointer
  .equ RX_TAIL,RX_HEAD+4 // rx1_queue tail pointer  
  .equ RX_QUEUE,RX_TAIL+4 // UART1 receive circular queue 
  .equ U2_RX_QUEUE,RX_QUEUE+RX_QUEUE_SIZE
  .equ U2_COUNT,U2_RX_QUEUE+4 
  .equ U3_RX_QUEUE,U2_COUNT+4
  .equ U3_COUNT,U3_RX_QUEUE+4 
  .equ VARS,U3_COUNT+4 // BASIC variables 
  .equ VARS_SIZE, 4*26 // space used by 26 BASIC variables (A-Z)
  .equ ARRAY_ADR,VARS+VARS_SIZE // array address at bottom of pad  
  .equ TRACE_LEVEL,ARRAY_ADR+4  // debugging level 
  .equ HERE,TRACE_LEVEL+4 // constants pointer position 
  .equ BASIC_START,TRACE_LEVEL+4 // BASIC area start after variables 

/* flags used by BASIC interpreter */ 
	.equ FRUN,(1<<0) // programm running
	.equ FTRAP,(1<<1) // inside trap handler 
	.equ FLOOP,(1<<2) // FOR loop in preparation 
	.equ FSTOP,(1<<3) // program stopped  
	.equ FBREAK,(1<<4) // break point flag 
	.equ FCOMP,(1<<5)  // compiling flags 
	.equ FAUTORUN,(1<<6) // auto start program running 
  .equ FPRINT,(1<<7) // inside print command 

  .equ FIRST_DATA_ITEM,6 // first DATA item offset on line.
	.equ MAX_LINENO,0xffff// BASIC maximum line number 

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
*********************************/
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

  // drop n parameters on dstack 
  .macro _DROP n
  mov r0,#4*\n
  add DP,R0 
  .endm 

  // back to previous token in list 
  .macro _UNGET_TOKEN 
  ldr IN,[UPP,#IN_SAVED]
  ldr BPTR,[UPP,#BASICPTR] 
  .endm 

 // create a text data 
 .macro _TEXT label,text
 \label: .asciz "\text"
 .p2align 2 
 .endm 

// command line only 
  .macro _CLO 
  ldr r0,[UPP,#FLAGS]
  tst r0,#FRUN 
  beq 1f 
  mov r0,#ERR_CMD_ONLY
  b tb_error
1: 
  .endm 

// run time only 
  .macro _RTO 
  ldr r0,[UPP,#FLAGS]
  tst r0,#FRUN 
  bne 1f 
  mov r0,#ERR_CMD_ONLY
  b tb_error
1:
  .endm 

