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
/************************************************************************
REF: https://en.wikipedia.org/wiki/Tiny_BASIC
************************************************************************/

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
    r3    temp   
******************************/
    _GBL_FUNC cmove
    push {r3} 
    ands r2,r2
    beq 9f 
    cmp r0,r1 
    bmi move_from_end 
move_from_low: // move from low address toward high 
    ldrb r3,[r0],#1
    strb r3,[r1],#1
    subs r2,#1
    bne move_from_low
    b 9f 
move_from_end: // move from high address toward low 
    add r0,r0,r2 
    add r1,r1,r2     
1:  ldrb r3,[r0,#-1]!
    strb r3,[r1,#-1]!
    subs r2,#1
    bne 1b 
9:  pop {r3}
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
  strcmp 
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
    r7 char 2  
*********************************/
  _FUNC strcmp
    push {r2,r3,r7}
    mov r2, r0
1:
    ldrb r3,[r2],#1  
    ldrb r7,[r1],#1
    cbz r3, 2f 
    cbz r7, 2f 
    subs r0,r3,r7 
    beq 1b
2:  sub r0,r3,r7 
    pop {r2,r3,r7}
    _RET 

/**********************************
    prt_tok 
    print token id and value 
  input:
    r0    id 
    r1    value 
  output:
    none
  use:

***********************************/
    _FUNC prt_tok 
    push {r0,r1}
    ldr r0,tok_msg 
    _CALL uart_puts 
    pop {r0}
    mov r1,#16 
    _CALL print_int 
    mov r0,#SPACE 
    _CALL uart_putc 
    pop {r0}
    mov r1,#16 
    _CALL print_int
    _CALL cr   
    _RET 
    _TEXT tok_msg,"token: " 

/******************************************
    prt_row 
    print memory content in byte format 
    input:
      r0    address 
      r1    count 
    output:
      r0    address+count 
    use:
      r2    address 
      r3    count
****************************************/
    _FUNC prt_row 
    push {r0,r1,r2,r3}
    mov r2,r0 
    mov r3,r1  
    mov r1,#16 
    _CALL print_int 
    mov r0,#12 
    _CALL cursor_x 
// print bytes values in hexadecimal 
1:  ldrb r0,[r2],#1 
    _CALL print_hex
    subs r3,#1 
    bne 1b 
    mov r0,#2 
    _CALL spaces
// print characters      
    pop {r0,r1}
    _CALL prt_chars 
    _CALL cr  
    mov r0,r2
    pop {r2,r3}      
    _RET 


/************************************
  show current line number 
***********************************/
    _FUNC show_line_nbr 
    push {r0,r1}
    ldrh r0,[BPTR]
    mov r1,#10
    _CALL print_int
    _CALL cr 
    pop  {r0,r1}
    _RET 

/************************************
  show data stack 
************************************/
    _FUNC show_data_stack 
    push {r0,r1,T1,T2}
    ldr r0,data_stack 
    _CALL uart_puts 
    mov T1,DP 
    _MOV32 T2,DSTACK_TOP
1:  cmp T2,T1 
    beq 9f 
    ldmdb T2!,{r0} 
    ldr r1,[UPP,#BASE] 
    _CALL print_int 
    b 1b 
9:  _CALL cr 
    pop {r0,r1,T1,T2}
    _RET 
data_stack:
  .word .+4 
  .asciz "dstack: "

/************************************
  show main stack 
***********************************/
    _FUNC show_main_stack
    stmdb DP!,{r0,r1,T1,T2}
    ldr r0,main_stack 
    _CALL uart_puts 
    _MOV32 T2,RSTACK_TOP
    add T1,sp,#4
1:  cmp T2,T1
    beq 9f 
    ldmdb T2!,{r0} 
    ldr r1,[UPP,#BASE]
    _CALL print_int
    b 1b
9:  _CALL cr 
    ldmia DP!,{r0,r1,T1,T2}     
    _RET  
main_stack:
   .word .+4 
   .asciz "rstack: " 

/************************************
    show execution trace 
************************************/
    _FUNC show_trace
    push {r2}
    ldr r2,[UPP,#TRACE_LEVEL]
    cbz r2,9f  
    _CALL cr 
    _CALL show_line_nbr
    cmp r2,#2 
    bmi 9f 
    _CALL show_data_stack 
    cmp r2,#3 
    bmi 9f 
    _CALL show_main_stack 
9:  pop {r2}
    _RET 


/************************************
    prt_chars 
    print n ascii character starting 
    at address 
    input: 
      r0    address 
      r1    count 
    output:
      r0    address + count
    use:
      r2    address 
***********************************/
    _FUNC prt_chars 
    push {r2}
    mov r2,r0
1:  ldrb r0,[r2],#1 
    cmp r0,#SPACE 
    bpl 2f 
    mov r0,#'_' 
2:  _CALL uart_putc
    subs r1,#1 
    bne 1b 
    mov r0,r2 
    pop {r2}
    _RET 


/*********************************
    search_target 
    search for goto, gosub target
    target is line number | label  
*********************************/
    _FUNC search_target
    _CALL next_token 
    cmp r0,TK_LABEL 
    bne 2f 
    _CALL search_label
    cbz r0,8f  
    b 9f 
2:  _UNGET_TOKEN
    _CALL expression 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    cbz r0,9f 
    mov r0,r1 
    _CALL search_lineno 
    cbz r1,9f 
8:  mov r0,#ERR_BAD_VALUE 
    b tb_error 
9:  _RET 


/***************************************
  search_const 
  search for constant 
  input:
    r0  constant label 
  output:
    r0  TK_INTGR 
    r1  constant value  
  use:
    r2   *list 
    r3   BOUND 
***************************************/
    _FUNC search_const
    push {r2,r3} 
    ldr r2,[UPP,#TXTEND]
    ldr r3,[UPP,#HERE] 
1:  cmp r2,r3 
    bpl 8f 
    ldr r1,[r2],#4
    cmp r0,r1 
    beq 2f 
    add r2,#4
    b 1b 
2:  // found 
    ldr r1,[r2]
    mov r0,#TK_INTGR 
    pop {r2,r3}
    _RET
8:  // that constant doesn't exist 
    mov r0,#ERR_BAD_VALUE 
    b tb_error      


/***************************************
    search_label 
    search target label 
    input:
      r1    target label 
    output:
      r0    address or 0 
    use:
      r2    line address link 
      r3    search limit 
****************************************/
    _FUNC search_label 
    push {r2,r3}
    ldr r2,[UPP,#TXTBGN]
    ldr r3,[UPP,#TXTEND]
1:  cmp r2,r3
    beq 8f 
    ldrb r0,[r2,#3]
    cmp  r0,#TK_LABEL 
    beq 4f 
2:  ldrb r0,[r2,#2]
    add r2,r0 
    b 1b 
4:  // compare label 
    ldr r0,[R2,#4]
    cmp r1,r0 
    bne 2b 
    // found label 
    mov r0,r2 
    b 9f
8:  eor r0,r0 
9:  pop {r2,r3}
    _RET 


/***************************************
    search_lineno 
    localize BASIC line from its number 
    input:
      r0   line# 
    output: 
      r0   adr where found || adr new to be inserted 
      r1   0 found || !0 not found  
    use:
      r0   scan address 
      r1   temp   
      r2   address end of text
      r3   target line#
****************************************/    
    _GBL_FUNC search_lineno
    push {r2,r3} 
    mov r3,r0 // target 
    ldr r0,[UPP,#TXTBGN] // search start adr 
    ldr r2,[UPP,#TXTEND] // search area end adr
1:  cmp r0,r2 
    beq  8f
    ldrh r1,[r0]
    subs r1,r3 
    bpl 9f 
    ldrb r1,[r0,#2]
    add r0,r1
    b 1b 
8:  mov r1,#-1 
9:  pop {r2,r3}
    _RET 


/********************************************
    delete_line 
    delete BASIC line at addr 
    input:
      r0    address line to delete 
    output:
      r0    same as input 
    use: 
      r1    dest adr
      r2    bytes to move 
      T1    length line to delete 
      T2    txtend 
********************************************/
    _FUNC delete_line 
    push {r0,r1,r2,T1,T2}
    mov r1,r0 // dest 
    ldrb T1,[r1,#2] // line length 
    add r0,T1  // src
    ldr T2,[UPP,#TXTEND]
    sub r2,T2,r0 // bytes to move 
    _CALL cmove
    sub T2,T1 // txtend-count 
    str T2,[UPP,#TXTEND] 
    pop {r0,r1,r2,T1,T2}
    _RET 

/******************************************
    create_gap 
    create a gap in text area to insert new line 
    input:
      r0    adr 
      r1    length 
    output:
      r0    adr 
    use:
      T1    length 
      T2    txtend 
************************************************/
    _FUNC create_gap 
    push {r0,r2,T1,T2}
    mov T1,R1
    add r1,r0  // dest 
    ldr T2,[UPP,#TXTEND]
    sub r2,T2,r0 
    _CALL cmove
    add T2,T1 
    str T2,[UPP,#TXTEND]
    pop {r0,r2,T1,T2}
    _RET 

/************************************************
    insert_line 
    insert BASIC line in text area 
    first search if line with same number exist 
    replace if so. 
    input:
      r0    *buffer to insert 
    output:
      none 
    use: 
      T1     *buffer
      T2     temp  
************************************************/ 
    _FUNC insert_line 
    push {r1,T1,T2}
    mov T1,r0 
    ldrh r0,[T1]
    _CALL search_lineno 
    cbnz  r1, 1f // line# doesn't exist
// already exist 
    _CALL delete_line // delete old one 
    ldrb T2,[T1,#2] // buffer line length 
    cmp T2,#4 // empty line length==4  
    beq 9f
1: //insert new line 
    ldrb r1,[T1,#2]
    _CALL create_gap 
    mov r1,r0
    mov r0,T1 
    ldrb r2,[r0,#2]
    _CALL cmove 
9:  pop {r1,T1,T2}
    _RET 

/*********************************
    compile 
    tokenize source line save it 
    in pas buffer.
    compiled line format: 
      line_no  2 bytes {0...32767}
      count    1 byte  
      tokens   variable length 
  input:
     r0   *text buffer 
     r1   *text length   
  output:
    r0    0 stored | -1 immediate 
  use:
    r3    tib index   
    T1    tib
    T2    pad
***********************************/
    _FUNC compile
    mov T1, r0  // source text buffer 
    str r1,[UPP,#COUNT] // save line length 
    ldr T2,pad // tokens buffer
    eor r3,r3 // source index  
    ldr r0,[UPP,#FLAGS]
    orr r0,#FCOMP
    str r0,[UPP,#FLAGS] // compiling flag 
    eor r0,r0     
    strh r0,[T2],#2   // line no 
    strb r0,[T2],#1 // length 
    str  r0,[UPP,#IN_SAVED]  // save index 
    str  T1,[UPP,#BASICPTR] // save text line 
    _CALL parse_int 
    beq 2f 
// this is a line number     
    cmp r1,#1 
    bpl 1f 
0:  mov r0,#ERR_BAD_VALUE 
    b tb_error  
1:  cmp r1,#65536
    bpl 0b 
    // write line # to pad 
    strh r1,[T2,#-3]
    str r3,[UPP,#IN_SAVED]
2:  // check for pad full 
    cmp T2,T1
    blt 3f 
    mov r0,#ERR_BUF_FULL 
    b tb_error 
3:  _CALL comp_token 
    cmp r0,#TK_NONE 
    beq 4f 
    str r3,[UPP,#IN_SAVED]
    b 2b 
4: // compilation completed 
    ldr r3,pad 
    sub r0,T2,r3 // line length 
    strb r0,[r3,#2]
    str r0,[UPP,#COUNT] // lenght of tokens line 
    ldrh r0,[r3] // line number 
    cbz r0,8f  
// insert line in text buffer 
    ldr r0,[UPP,#FLAGS]
    tst r0,#FSTOP
    beq 7f 
    mov r0,#ERR_CANT_PROG 
    b tb_error 
7:  mov r0,r3 
    _CALL insert_line 
    eors r0,r0 
    b 9f 
8:  mov BPTR,r3 // *token_list 
    mov IN,#3
    ldr r0,[UPP,#FLAGS]
    sub r0,#FCOMP
    str r0,[UPP,#FLAGS]
    movs r0,#-1 
9:  _RET 

/*********************************************
    compile next token from source 
    input: 
      r3 		tib index  
      T1    tib adr
      T2    insert point in pad  
    output:
      r0     token attribute 
      r1 		token value
      r3     tib index updated    
      T2     updated 
      use:
**********************************************/
    _FUNC comp_token 
    push {r6}
    ldrb r0,[T1,r3]
    ands r0,r0 
    beq store_r0  // reached end of text  
    mov r0,#SPACE 
    _CALL skip  // skip spaces 
    ldrb r0,[T1,r3]
    ands r0,r0 
    beq store_r0  // reached end of text 
    add r3,#1
    _CALL is_letter 
    bne 1f
    sub r3,#1 
    _CALL comp_label // parse and compile label 
    cmp r0,#TK_CMD 
    bne token_exit 
    cmp r1,#REM_IDX 
    beq tick2 
    b token_exit 
1:  _CALL is_special
    ldr r6,=token_ofs
    tbh [r6,r1] 
tok_idx0:     
//  not special char.  
    b try_number 
// single char token with no value 
single: 
    ldr r6,=tok_single
    ldrb r0,[r6,r1] 
    b store_r0
lt:
    mov r0,#TK_LT
    ldrb r1,[T1,r3]
    cmp r1,#'>' 
    beq 1f
    b 2f 
gt:
    mov r0,#TK_GT 
    ldrb r1,[T1,r3]
    cmp r1,#'<'
    bne 2f  
1:  add r3,#1
    mov r0,#TK_NE  
    b store_r0
2:  cmp r1,#'=' 
    bne store_r0  
    add r3,#1
    add r0,#2
    b store_r0       
bkslash:
    ldrb r1,[T1,r3]
    add r3,#1
    mov r0,#TK_CHAR 
    strb r0,[T2],#1
    strb r1,[T2],#1
    b token_exit 
prt_cmd: 
    mov r0,#TK_CMD 
    mov r1,#PRT_IDX
    strb r0,[T2],#1
    strb r1,[T2],#1
    b token_exit 
quote:
    mov r0,#TK_QSTR 
    strb r0,[T2],#1
    _CALL parse_quote
    b token_exit
tick: 
// copy comment in pad 
    mov r0,#TK_CMD 
    mov r1,#REM_IDX 
    strb r0,[T2],#1 
    strb r1,[T2],#1
tick2:
    add r0,T1,r3 
    mov r1,T2 
    _CALL strcpy 
    _CALL strlen 
    add T2,r0
    add T2,#1
    ldr r3,[UPP,#COUNT]
    b token_exit
store_r0: 
    strb r0,[T2],#1
    b token_exit 
try_number:
    sub r3,#1
    _CALL parse_int  
    beq syntax_error  
    strb r0,[T2],#1 
    str r1,[T2],#4
token_exit:
    pop {r6}
    _RET 


/****************************
    is_special  
    check for non alphanum
    input:
      r0    character to scan 
    output:
      r0    character 
      r1    0 || index 
    use: 
      r1    scan index 
      r2    temp 
      r3    char_list 
*****************************/
    _FUNC is_special 
    push {r2,r3}
    mov r1,#1
    ldr r3,=char_list 
1:  ldrb r2,[r3,r1]
    cbz r2,8f 
    cmp r2,r0 
    beq 9f 
    add r1,#1 
    b 1b
8:  eor r1,r1     
9:  pop {r2,r3}
    _RET 

char_list:
  .asciz " ,;@():#-+*/%=<>\\?'\""

tok_single:
  .byte TK_NONE,TK_COMMA,TK_SEMIC,TK_ARRAY,TK_LPAREN,TK_RPAREN,TK_COLON
  .byte TK_SHARP,TK_MINUS,TK_PLUS,TK_MULT,TK_DIV,TK_MOD,TK_EQUAL 

  .p2align 2
token_ofs:
  .hword  0 // not found
  // TK_COMMA...TK_EQUAL , 13 
  .hword  (single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2
  .hword  (single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2
  .hword  (single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2
  .hword  (single-tok_idx0)/2    
  // '<','>'
  .hword  (lt-tok_idx0)/2,(gt-tok_idx0)/2
  // '\'
  .hword  (bkslash-tok_idx0)/2
  // '?' 
  .hword  (prt_cmd-tok_idx0)/2 
  // "'"  
  .hword  (tick-tok_idx0)/2 
  // '"' quote 
  .hword (quote-tok_idx0)/2

  .p2align 2

/****************************
    comp_label
    compile a label 
    it can be a target|keyword|
    variable| user constant  
    label form: [A..Z]+
    input:
      *buffer 
    output:
      r0  token type 
      r1  token value 
      T2  updated 
      R3  updated
    use:
****************************/
    _FUNC comp_label
    push {r2,r5}
    push {T2}
    eor r2,r2
    mov r5,#6 
0:  ldrb r0,[T1,r3]
    cmp r0,#'_'
    beq 2f
1:  _CALL is_letter 
    bne 3f // not letter 
    _CALL upper 
2:  strb r0,[T2],#1
    add r3,#1
    b 0b 
3:  eor r0,r0 
    strb r0,[T2]
// is this a variable ?
    pop {T2}
    ldrb r0,[T2,#1]
    cbnz r0,3f // length >1 not variable 
    ldrb r1,[T2]
    sub r1,#'A' 
    mov r0,#TK_VAR
    b 8f 
3:  // try keyword 
    mov r0,T2 
    ldr r1,=kword_dict  
    _CALL search_dict 
    cbz r0,4f
    cmp r0,TK_SCONST  
    bne 8f
    //system constant  
    strb r0,[T2],#1
    str r1,[T2],#4
    b 9f 
4: // must be a label 
    mov r0,T2 
    _CALL compress_label
    mov r0,#TK_LABEL
    strb r0,[T2],#1
    str r1,[T2],#4
    b 9f 
8:  strb r0,[T2],#1
    strb r1,[T2],#1          
9:  pop {r2,r5}
    _RET 

/********************************
    compress_label 
    compress label in integer 
    maximum 6 character, 
    ignore extras characters 
    input:
      r0  *label 
    output:
      r1   compressed label 
********************************/
    _FUNC compress_label
    push {r2,r3}
    eor r2,r2 // compress value
    mov r3,#6 // max characters 
1:  ldrb r1,[r0],#1 
    cbz r1,3f
    cmp r1,#'_'
    bne 2f 
    sub r1,#4  
2:  sub r1,#'@'
    lsl r2,#5
    add r2,r1
    subs r3,#1 
    bne 1b 
3:  mov r1,r2     
    pop {r2,r3}
    _RET 


/****************************
    parse_int 
    parse an integer from text
    if not valid integer 
    r1 return *buffer else 
    *buffer is incremented after integer 
  input:
    r0   *buffer 
  output:
    r0   TK_INTGR|TK_NONE
    r1   int|0   
  use:
    r3   tib index updated     
*****************************/
    _FUNC parse_int 
    mov r1,#10 // default base 
    ldrb r0,[T1,r3]
    cmp r0,'$' 
    bne 2f 
    mov r1,#16 // hexadecimal number 
    b 3f  
2:  cmp r0,#'&' 
    bne 4f
    mov r1,#2 //binary number  
3:  add r3,#1
4:  add r0,r3,T1 
    _CALL atoi 
    cbz r0,9f
    add r3,r0
    mov r0,#TK_INTGR
9:  ands r0,r0   
    _RET 

/*********************************************
    parse_quote 
    parse quoted string 
    input: 
      r3 		tib index  
      T1    tib adr
      T2    insert point in pad  
    output:
      r0     token attribute 
      r1 		*str 
      r3     tib index updated    
      T2     updated 
      use:
*********************************************/
    _FUNC parse_quote
    push {T2} 
1:  ldrb r0,[T1,r3]
    add r3,#1 
    cmp r0,#'"'
    beq 9f 
    cmp r0,#'\\'
    bne 2f 
    _CALL get_escaped_char 
2:  strb r0,[T2],#1
    b 1b 
9:  eor  r0,r0
    strb r0,[T2],#1
    mov r0,#TK_QSTR
    pop {r1}
    _RET 

/**********************************************
    get_escaped_char 
    convert "\c" in quoted string 
    input:
      r0 
      r3   index 
      T1   tib 
    output:
      r0   replacement char
      r3   updated 
    use:
      r1   *table 
      r2   temp 
**********************************************/
    _FUNC get_escaped_char 
    push {r1,r2}
    ldrb r0,[T1,r3]
    add r3,#1
    cmp r0,#'"' 
    beq 9f 
1:  ldr r1,=escaped 
2:  ldrb r2,[r1],#1
    cbz r2,6f 
    cmp r2,r0 
    beq 7f 
    b 2b
6:  sub r2,r0,#7     
7:  add r0,r2,#7
9:  pop {r1,r2}   
    _RET

escaped: .asciz "abtnvfr"

/*********************************************
   skip character in TIB 
   input:
      r0    character to skip 
      r3    tib index 
      T1    tib adr
    output: 
      r3    updated
    use:
      r1     
**********************************************/   
    _FUNC skip
    push {r1} 
1:  ldrb r1,[T1,r3]
    cmp r1,r0
    bne 2f
    add r3,#1 
    b 1b 
2:  str r3,[UPP,#IN_SAVED]
    pop {r1}
    _RET

/********************************************
    upper
    convert character in upper case 
    input: 
      r0   character 
    output:
      r0   upper case character 
*********************************************/
    _FUNC upper 
    cmp r0,#'a' 
    blt 9f 
    cmp r0,#'z' 
    bgt 9f 
    and r0,#0x5f 
9:  _RET 

/***************************************
   is_digit 
   check if char is decimal digit.
   convert to decimal digit.
   input:
      r0    char 
   output:
      r0        if Z then converted digit else not changed
      Z flag    1 true | 0 false  
***************************************/
    _GBL_FUNC is_digit 
    push {r1} 
    mov r1,#-1   
    cmp r0,#'0' 
    blt 9f
    cmp r0,'9'+1
    bpl 9f 
    eor r1,r1 
    sub r0,#'0'  
9:   
    ands r1,r1
    pop {r1} 
    _RET 

/***************************************
    is_hex 
    check for hexadecimal digit 
    convert to hex digit.
    input:
      r0    
    output:
      r0         if Z then converted digit 
      Z  flag    1 true | 0 false         
***************************************/
    _FUNC is_hex 
    push {r1}
    eor r0,r0 
    cmp r0,#'A' 
    bmi 1f 
    sub r0,#7 
1:  sub r0,#'0'
    bmi 2f 
    cmp r0,#16
    bmi 9f 
2:  mvn r1,r1  
9:  ands r1,r1 
    pop {r1}
    _RET 

/***************************************
    is_letter 
    check if character is {a..z,A..Z,_} 
  input:
    r0   character 
  output: 
    r0       same character 
    Z flag   1 true | 0 false  
****************************************/
    _FUNC is_letter
    push {r1} 
    eor r1,r1 
    cmp r0,#'A' 
    bmi 8f 
    cmp r0,#'Z'+1 
    bmi 9f
    cmp r0,#'a' 
    bmi 8f 
    cmp r0,#'z'+1
    bmi 9f  
8:  mvn r1,r1  
9:  ands r1,r1 
    pop {r1}
    _RET 


/******************************************
    atoi 
    convert ascii to integer 
    input:
      r0   *buffer 
      r1   base 
    output:
      r0   0 no integer found 
      r1   integer
    use:
      r2   base  
      T1   *buffer 
      T2   digit count  
******************************************/
    _GBL_FUNC atoi 
    push {r2,T1,T2}
    mov T1,r0  // *buffer 
    mov r2,r1  // base  
    eor r1,r1  // converted integer 
    eor T2,T2  // digit count 
1:  ldrb r0,[T1],#1
    _CALL upper 
    cmp r0,#'0'
    bmi 8f
    cmp r0,#'9'+1 
    bmi 2f 
    cmp r0,#'A'
    bmi 8f 
    sub r0,#7 
2:  sub r0,#'0' 
    cmp r0,r2
    bpl 8f  
    mul r1,r2 
    add r1,r0
    add T2,#1
    b 1b 
8:  mov r0,T2  
    pop {r2,T1,T2}
    _RET 



/*******************
    DECOMPILER 
*******************/

/********************************************
    cmd_name 
    search bytecode in dictionary and 
    return its name 
  input:
    r0    token type 
    r1    keyword bytecode 
  ouput:
    r0    name string 
  use:
    T1    link 
    T2    tmp 
*********************************************/
    _FUNC cmd_name 
    push {T1,T2}
    ldr T1,=kword_dict 
1:  ldr T2,[T1,#-4]
    cmp T2,r0 
    bne 3f 
    ldr T2,[T1,#-8]
    cmp T2,r1 
    beq 2f 
3:  ldr T1,[T1,#-12]
    cmp T1,#0
    bne 1b  
2:  mov r0,T1 
    pop {T1,T2}
    _RET

/*****************************
  decompile_line 
  detokenize BASIC line 
  input:
    r0  *token list 
    r1  *output buffer 
  output:
    r0  *output buffer (.asciz) 
  use:
    T1  *output buffer
    BPTR  *token list
    IN  offset in token list  
******************************/
    _GBL_FUNC decompile_line
    push {r1,r2,r3,T1} 
    mov BPTR,r0 
    mov IN,#0
    mov T1,r1 
    ldrh r0,[BPTR,IN]
    add IN,#2 
    mov r1,#10 
    _CALL itoa
    mov r1,T1
    _CALL strcpy
    mov r0,T1 
    _CALL strlen
    add T1,r0 
    ldrb r0,[BPTR,IN]    
    add IN,#1 
    str r0,[UPP,#COUNT]
decomp_loop:
    _CALL next_token
    cmp r0,#TK_NONE 
    beq 9f
    cmp r0,#TK_GE 
    bpl 1f 
    ldr r1,=single_char 
    ldrb r0,[r1,r0]
    strb r0,[T1],#1 
    b decomp_loop
1: 
    cmp r0,#TK_CHAR  
    bpl 2f 
    sub r0,#TK_GE
    lsl r0,#2 
    ldr r1,=relop_str 
    ldr r0,[r1,r0]
    mov r1,T1 
    _CALL strcpy 
    mov r0,T1 
    _CALL strlen 
    add T1,r0 
    b decomp_loop
2:  cmp r0,#TK_CHAR 
    bne 3f 
    mov r0,#'\\'
    strb r0,[T1],#1
    strb r1,[T1],#1
//    mov r0,#SPACE 
//    strb r0,[T1],#1
    b decomp_loop 
3:  cmp r0,#TK_VAR 
    bne 4f 
    add r0,r1,'A'
    strb r0,[T1],#1 
    mov r0,#SPACE 
    strb r0,[T1],#1
    b decomp_loop 
4:  cmp r0,#TK_LABEL 
    bpl 5f   
    push {r0,r1}
//    mov r0,r1 
    _CALL cmd_name
    mov r1,T1 
    _CALL strcpy 
    mov r0,T1 
    _CALL strlen 
    add T1,r0
    pop {r0,r1}
    mov r0,#SPACE 
    strb r0,[T1],#1 
    cmp r1,#REM_IDX
    bne decomp_loop 
    add r0,BPTR,IN
    mov r1,T1   
    _CALL strcpy
    mov r0,T1 
    _CALL strlen
    add T1,r0
    ldr IN,[UPP,#COUNT]
    b 9f 
5:  cmp r0,#TK_INTGR
    bne 6f  
    mov r0,r1 
    ldr r1,[UPP,#BASE]
    _CALL itoa
    mov r1,T1 
    _CALL strcpy
    mov r0,T1 
    _CALL strlen
    add T1,r0 
    b decomp_loop 
6:  cmp r0,#TK_LABEL
    bne 7f
    mov r2,#25
    mov r3,#0xffff 
    movt r3,#0x3fff 
0:  and r1,r3 
    lsr r3,#5 
    lsrs r0,r1,r2 
    beq 2f
    add r0,#'@'
    cmp r0,#'['
    bne 1f
    add r0,#4 
1:  strb r0,[T1],#1
2:  subs r2,#5 
    bge 0b
    mov r0,#SPACE 
    strb r0,[T1],#1  
    b decomp_loop
7:  mov r0,#'"'
    strb r0,[T1],#1 
    mov r0,r1
    mov r1,T1  
    _CALL strcpy
    mov r0,T1 
    _CALL strlen 
    add T1,r0 
    mov r0,#'"'
    strb r0,[T1],#1 
    b decomp_loop
9:  eor r0,r0 
    strb r0,[T1]
    pop {r1,r2,r3,T1}
    mov r0,r1 
    _RET 

relop_str: .word ge_str,le_str,ne_str 
ge_str: .asciz ">="
le_str: .asciz "<="
ne_str: .asciz "<>"

single_char:
  .byte 0, ':', ',', ';', '#', '(', ')', '+' , '-', '*', '/', '%'
  .byte '@','=', '>', '<' 




/**********************************
  modulo 
  compute r0 mod r1
  input:
    r0   dividend
    r1   divisor 
  output:
    r0   TK_INTGR 
    r1   r0 mod r1 
*********************************/
    _GBL_FUNC modulo 
    push {r0}
    udiv r0,r1 
    mul  r0,r1 
    pop {r1}
    sub r1,r0
    mov r0,#TK_INTGR
    _RET 

/**********************************
      BASIC commands 
**********************************/

/*********************************
    syntax_error 
    display syntax error message and 
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
    ldr r1,[UPP,#FLAGS]
    tst r1,#FCOMP
    bne compile_error
rt_error:
    mov r2,IN 
    push {r0}
    ldr r0,=rt_error_msg 
    _CALL uart_puts 
    pop {r0}
    ldr r1,=err_msg  
    lsl r0,#2 
    ldr r0,[r1,r0]
    _CALL uart_puts
// decompile and print faulty line      
    mov r0,BPTR
    mov r2,IN  
    ldr r1,pad 
    _CALL decompile_line
    _CALL uart_puts 
    _CALL cr 
// print error offset on line      
    ldr r0,=token_at_msg 
    _CALL uart_puts 
    mov r0,r2 
    mov r1,#16 
    _CALL print_int
    _CALL cr
// dump tokenize line 
    mov r0,BPTR
    ldrb r2,[r0,#2]
    _CALL dump01 
    b warm_start 
compile_error:
    ldr r1,=err_msg 
    lsl r0,#2 
    ldr r0,[r1,r0]
    _CALL uart_puts
    ldr r0,[UPP,#BASICPTR]
    _CALL uart_puts
    _CALL cr
    ldr r0,[UPP,#IN_SAVED]
    _CALL spaces 
    mov r0,#'^' 
    _CALL uart_putc
    _CALL cr
    b  warm_start  
    
rt_error_msg: .asciz "\nRuntime error: "
token_at_msg: .asciz "token offset: "


err_msg:
	.word 0,err_mem_full, err_syntax, err_math_ovf, err_div0,err_no_line    
	.word err_run_only,err_cmd_only,err_duplicate,err_not_file,err_bad_value
	.word err_no_access,err_no_data,err_no_prog,err_no_fspace,err_buf_full    
   .word err_cant_prog 

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
err_cant_prog: .asciz "Can't modify program in STOP mode. Use END command before.\n" 

rt_msg: .asciz "\nrun time error, "
comp_msg: .asciz "\ncompile error, "
tk_id: .asciz "last token id: "


    .section  .text , "ax", %progbits 

/*********************************
   skip_line 
   data and remark line are skipped
   by the interpreter 
***********************************/
    _FUNC skip_line 
    ldr IN,[UPP,#COUNT]
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

/***************************************
   kword_cmp
   compare keyword to dict entry
  input:
    r0  keyword 
    r1  dict entry 
    r2  character count 
  output:
    r0  0 not same | -1 same 
  use:
    r6   result  
    T1   char 1
    T2   char 2
**************************************/   
    _FUNC kword_cmp 
    push {r6,T1,T2}
    mov r6,#-1 
1:  cbz r2,9f       
    ldrb T1,[r0],#1
    ldrb T2,[r1],#1
    sub r2,#1
    cmp T1,T2
    beq 1b 
    eor r6,r6  
9:  mov r0,r6
    pop {r6,T1,T2}
    _RET 

/***********************************************
    search_dict 
    search keyword in dictionary
   input:
  	 r0   keyword 
     r1		dictionary first name field address  
   output:
     r0 		token attribute 
     r1		  cmd_index if r0!=TK_NONE  
   use:
     r3   length keyword 
     T1   keyword
     T2   link  
**********************************************/
  _FUNC search_dict
  push {r2,r3,T1,T2}
  mov T1,r0 
  _CALL strlen 
  mov r3,r0  
1:  
   mov T2,r1  // keep for linking   
   ldrb r0,[r1] 
   cbz r0,9f // null byte, end of dictionary
   mov r0,T1
   mov r2,r3   
   _CALL kword_cmp  
   cbnz r0,2f 
   mov r1,T2
   ldr r1,[r1,#-12]
   b 1b   
2: // found
   ldr r0,[T2,#-4] // token attribute 
   ldr r1,[T2,#-8]  // command index 
9: pop {r2,r3,T1,T2}
   _RET 


/**************************
    INTERPRETER 
*************************/

/*********************************
   cold_start 
   initialize BASIC interpreter 
   never leave 
   input:
     none 
   output:
    none 
*********************************/
  .type cold_start, %function 
  .global cold_start 
cold_start: 
    _MOV32 UPP,RAM_ADR 
    ldr r0,src_addr 
    ldr r1,dest_addr
    ldr r1,[r1] 
    add UPP,r1 // system variables base address   
// clear RAM
    mov r0,UPP  
    ldr r1,tib 
    eor r2,r2 
1:  str r2,[r0],#4 
    cmp r0,r1 
    bmi 1b 
//copy initialized system variables to ram 
    ldr r0,src_addr 
    mov r1,UPP 
    ldr r2,sysvar_size
    _CALL cmove
    _CALL prt_version
    _CALL clear_basic 
    _CALL search_free 
    str r0,[UPP,#FSFREE] 
    b warm_start    
src_addr:
  .word uzero
dest_addr:
  .word vectors_size
sysvar_size: .word ulast-uzero 

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
    _CALL cr
    _RET  
version_msg:
    .asciz "\nblue pill tiny BASIC, version "
version:
    .byte 0x10 
    .p2align 2 


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
   reset BASIC system variables 
   and clear variables and RAM 
*****************************/
    _FUNC clear_basic
  	eor r0,r0
    str r0,[UPP,#FLAGS] 
    str r0,[UPP,#COUNT]
    str r0,[UPP,#IN_SAVED]
    str r0,[UPP,#BASICPTR]
    str r0,[UPP,#DATAPTR]
    str r0,[UPP,#DATA]
    str r0,[UPP,#DATALEN]
    add r0,UPP,#BASIC_START 
    add r0,#16 
    mvn r1,#15
    and r0,r1 
    str r0,[UPP,#TXTBGN]
    str r0,[UPP,#TXTEND]
    str r0,[UPP,#HERE]
    _CALL clear_vars
    ldr r0,[UPP,#TXTBGN]
    ldr r1,tib 
    eor r2,r2 
1:  str r2,[r0],#4
    cmp r0,r1 
    bmi 1b 
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
// reset data stack       
    ldr DP,dstack 
    mov IN,#0 // BASIC line index 
    mov BPTR,#0 // BASIC line address 
    eor r0,r0 
    str r0,[UPP,#COUNT]  
    str r0,[UPP,#FLAGS]
    str r0,[UPP,#LOOP_DEPTH] 
    mov r0, #DEFAULT_TAB_WIDTH
    str r0,[UPP,#TAB_WIDTH]
    mov r0,#10 // default base decimal 
    str r0,[UPP,#BASE]
    _RET  

mstack: .word _mstack 
dstack: .word _dstack 
tib: .word _tib 
pad: .word _pad 
array: .word _pad - 4 
ready: .asciz "\nREADY" 

/**********************************
    warm_start 
    start BASIC interpreter doesn't  
    reset variables and code space 
  input:
    none 
  output:
    none 
**********************************/
    _GBL_FUNC warm_start 
// initialise parameters stack
    bl warm_init
// reset main stack 
    ldr r0,mstack
    mov sp,r0 
    ldr r0,=ready 
    _CALL uart_puts 
// fall in cmd_line 

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
    _CALL cr
    eor r0,r0 
    str r0,[UPP,#TRACE_LEVEL] 
1:  ldr r0,tib
    mov r1,#TIB_SIZE 
    _CALL readln 
    ands r1,r1 // empty line 
    beq 1b 
    _CALL compile // tokenize BASIC text
    beq 1b  // tokens stored in text area 
// interpret tokenized line 
interpreter:
  _CALL next_token 
  cmp r0,#2
  bmi interpreter    
  cmp r0,#TK_LABEL 
  beq interpreter 
  cmp r0,#TK_CMD 
  bne 2f
  mov r0,r1 
  bl execute  
  b interpreter   
2: 
  cmp r0,#TK_VAR 
  bne 3f 
  _CALL let_var 
  b interpreter 
3: 
  cmp r0,#TK_ARRAY 
  bne 4f
  _CALL let_array 
  b interpreter
4: 
  b syntax_error

/*****************************
    execute 
    execute a BASIC routine from 
    its token value 
  input:
    r0  BASIC SUB|FUNC token  
  output: 
    depend on SUB|FUNc
*****************************/
    _FUNC execute 
    ldr r1,=fn_table 
    ldr r0,[r1,r0,lsl #2]
    bx r0 

/*************************************
  next_token 
  extract next token from token list 
  input:
    none 
  output:
    r0    token attribute
    r1    token value if there is one 
  use:
    T1    exit token type  
****************************/
    _FUNC next_token 
    ldr r0,[UPP,#COUNT]
    cmp IN,r0 
    bmi 0f
// reached end of line skip to next one 
    add BPTR,r0 // next line 
    ldr r0,[UPP,#TXTEND]
    cmp BPTR,r0 
    bpl warm_start // end of program
    ldrb r0,[BPTR,#2] // line length 
    str r0,[UPP,#COUNT] 
    mov IN,#3
    _CALL show_trace
    eor r0,r0
    _RET 
0: 
    str IN,[UPP,#IN_SAVED]
    str BPTR,[UPP,#BASICPTR]
    ldrb r0,[BPTR,IN] // token id 
    add IN,#1  
    cmp r0,#TK_CHAR 
    bmi 9f // these tokens have no value  
    cmp r0,#TK_SCONST 
    bpl 1f
    // tokens with .byte value 
    ldrb r1,[BPTR,IN] 
    add IN,#1 
    _RET  
1:  cmp r0,#TK_QSTR 
    bne 2f 
    add r1,BPTR,IN
    mov r0,r1 
    _CALL strlen 
    add IN,r0 
    add IN,#1
    mov r0,#TK_QSTR 
    _RET  
2:  // .word value 
    ldr r1,[BPTR,IN] 
    add IN,#4 
9:  _RET


/*********************************
    expect 
    check if next token is of 
    expected type. If not 
    call syntax_error  
  input:
      r0   token attribute
  output:
      r0  token attribute 
      r1  token value
  use:
      T1   
**********************************/
    _FUNC expect 
    push {T1}
    mov T1,r0 
    _CALL next_token 
    cmp r0,T1  
    bne syntax_error 
    pop {T1}
    _RET 

/***********************************
    func_args 
    get function arguments list 
  input:
    none 
  output:
    r0    arg. count 
  use:

************************************/
    _FUNC func_args 
    mov r0,#TK_LPAREN 
    _CALL expect 
    _CALL arg_list 
    push {r0}
    mov r0,#TK_RPAREN 
    _CALL expect 
    pop {r0}
    _RET 

/**********************************
    arg_list 
    get arguments list on dstack 
  input:
    none 
  output:
    r0    arg count
  use:
    T1    tmp count  
***********************************/
    _FUNC arg_list 
    push {T1}
    eor T1,T1 
1:  _CALL expression 
    cmp R0,#TK_INTGR  
    bne 2f
    _PUSH r1 
    add T1,#1 
    _CALL next_token 
    cmp r0,#TK_COMMA 
    beq 1b 
2:  _UNGET_TOKEN 
9:  mov r0,T1 
    pop {T1}
    _RET 


/***********************************
 factor
 arithmetick factor parser 
 factor ::= ['+'|'-'|e]  var | @ |
			 integer | function |
			 '('expression')' 
  input: 
    none 
  output:
    r0   token attribute 
    r1   token value 
  use:
    r2   temp 
    r3   sign 
***********************************/
    _FUNC factor 
    push {r2,r3}
    _CALL next_token
    mov r3,#1 // default sign +  
    cmp r0,#TK_MINUS  
    bne 1f 
    mov r3,#-1 // minus sign 
0:  _CALL next_token
1:  cmp r0,#TK_INTGR 
    beq 8f 
    cmp r0,#TK_ARRAY 
    bne 2f 
    mov r0,#TK_LPAREN 
    _CALL expect 
    _CALL expression
    cmp r0,#TK_INTGR
    bne syntax_error
    mov r2,r1  
    mov r0,#TK_RPAREN
    _CALL expect 
    mov r0,r2 
    _CALL get_array_element 
    b 8f
2:  cmp r0,#TK_LPAREN 
    bne 3f 
    _CALL expression 
    cmp r0,#TK_INTGR 
    bne syntax_error
    mov r2,r1   
    mov r0,#TK_RPAREN
    _CALL expect 
    mov r1,r2 
    mov r0,#TK_INTGR
    b 8f       
3:  cmp r0,#TK_VAR 
    bne 4f
    mov r0,r1  
    _CALL get_var 
    b 8f 
4:  cmp r0,#TK_IFUNC 
    bne 6f 
5:  mov r0,r1  
    _CALL execute
    b 8f 
6:  cmp r0,#TK_LABEL
    bne 7f 
    orr r0,r1,#(1<<31) 
    _CALL search_const
    b 8f 
7:  cmp r0,#TK_SCONST 
    bne 9f 
    mov r0,#TK_INTGR
8:  mul r1,r3 
9:  pop {r2,r3}   
    _RET 


/*****************************************
    term 
    term parser 
    term ::= factor [['*'|'/'|'%'] factor]* 
    output:
      r0  	token attribute 
      r1		integer
    use:
      r2    first factor 
      r3    operator *|/|%
******************************************/
    _FUNC term 
    _CALL factor
    cmp r0,#TK_INTGR
    beq 0f 
    _RET // not a factor    
0:  push {r2,r3}
    mov r2,r1 // first factor    
0:  _CALL next_token
    mov r3,r0  // operator 
    cmp r0,TK_MULT
    bmi 1f 
    cmp r0,#TK_MOD+1
    bmi 2f
1:  _UNGET_TOKEN
    mov r0,#TK_INTGR
    b 9f 
2:  _CALL factor
    cmp r0,#TK_INTGR
    bne syntax_error 
    cmp r3,#TK_MULT
    bne 3f 
// multiplication
    mul r2,r1
    b 0b  
3:  cmp T1,#TK_DIV 
    bne 4f
// division
    sdiv r2,r2,r1
    b 0b  
4: // modulo
    mov r0,r2 
    sdiv r2,r2,r1 
    mul  r2,r1 
    sub  r2,r0,r2
    b 0b  
9:  mov r1,r2 
    pop {r2,r3}
    _RET 


/*****************************************
    expression 
    arithmetic expression parser 
    expression ::= term [['+'|'-'] term]*
    result range {-32768..32767}
    output:
      r0    TK_NONE || TK_INTGR 
      r1 	  integer
    use:
      r2  left term 
      r3  operator +|-
******************************************/
    _FUNC expression 
    _CALL term 
    cmp r0,#TK_INTGR 
    beq 0f 
    _RET   
0:  push {r2,r3}
    mov r2,r1 // first term
1:  _CALL next_token 
    mov r3,r0 //  +|-
    cmp r0,#TK_PLUS 
    beq 3f 
    cmp r0,#TK_MINUS  
    beq 3f
    _UNGET_TOKEN 
    mov r0,#TK_INTGR
    b 9f 
3:  _CALL term 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    cmp r3,#TK_PLUS 
    beq 4f 
    sub r2,r1 // term1-term2  
    b 1b 
4:  add r2,r1 // term1+term2
    b 1b
9:  mov r1,r2 
    pop {r2,r3}
    _RET 


/**********************************************
    relation
    rel ::= expr1 rel_op expr2
    rel_op ::=  '=','<','>','>=','<=','<>','><'
    relation return  integer , zero is false 
    output:
        r0	TK_INTGR  
        r1	integer 
    use:
        r2   first operand 
        r3   relop   
**********************************************/
    _FUNC relation 
    push {r2,r3}
    _CALL expression 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    mov r2,r1  // first operand  
    _CALL next_token 
    sub r3,r0,#TK_EQUAL  // relop  
    cmp r0,#TK_EQUAL 
    bmi 8f 
    cmp r0,#TK_NE+1
    bpl 8f 
    _CALL expression 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    cmp r2,r1 // compare operands  
    mov r1,#-1 
    ldr r2,=relop_jmp
    tbb [r2,r3]    
rel_idx0:
rel_eq:
    beq 9f 
    b rel_false
rel_gt:
    bgt 9f  
    b rel_false  
rel_ge:
    bge 9f  
    b rel_false  
rel_lt: 
    blt 9f   
    b rel_false 
rel_le:
    ble 9f  
    b rel_false 
rel_ne:
    bne 9f 
rel_false:    
    eor r1,r1  // false
    b 9f  
8:  _UNGET_TOKEN 
    mov r1,r2    
9:  mov r0,#TK_INTGR
    pop {r2,r3}
    _RET 


relop_jmp: 
  .byte 0 // =  
  .byte (rel_gt-rel_idx0)/2 // > 
  .byte (rel_lt-rel_idx0)/2 // <
  .byte (rel_ge-rel_idx0)/2 // >=
  .byte (rel_le-rel_idx0)/2 // <=
  .byte (rel_ne-rel_idx0)/2 // <> 


/***********************************
    get_array_element
    return value of @(n)
  input:
    r0    indice 
  output:
    r0   TK_INTGR
    r1   value  
************************************/
    _FUNC get_array_element 
    ldr r1,[UPP,#ARRAY_ADR]
    lsl r0,#2 
    rsb r0,r1 
    ldr r1,[r0]
    mov r0,#TK_INTGR 
    _RET 


/***********************************
    set_array_element 
    set value of array element 
  input:
    r0   index 
    r1   new value 
  output:
    none
  use:
    r2    array pointer 
**********************************/
    _FUNC set_array_element 
    push {r2}
    ldr r1,[UPP,#ARRAY_ADR]
    lsl r0,#2 
    sub r1,r0 
    str r1,[r1]
    pop {r2}
    _RET 

/***********************************
   get_var 
   get variable value 
  input:
     r0    variable index {0..25}
  output:
     r0    TK_INTGR
     r1    value 
**********************************/
    _FUNC get_var 
    add r1,UPP,#VARS
    lsl r0,#2 
    ldr r1,[r1,r0]
    mov r0,#TK_INTGR
    _RET 

/*********************************
    set_var 
    set variable value 
  input:
     r0    variable index {0..25}
     r1    new value 
  output:
    none 
  use:
    r2   vars pointer 
*********************************/
    _FUNC set_var 
    push {r2}
    add r2,UPP,#VARS
    lsl r0,#2
    str r1,[r2,r0]
    pop {r2}
    _RET 

/******************************
    CONSTANTS data
******************************/

  .section .rodata 

// system variables initial value 
uzero:
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
  .word 0 // FSFREE
  .word 0 // TXTBGN
  .word 0 // TXTEND
  .word 0 //LOOP_DEPTH
  .word 0 // ARRAY_SIZE
  .word 0 // FLAGS
  .word 4 // TAB_WIDTH
  .word 0 // RX_HEAD
  .word 0 // RX_TAIL
  .space RX_QUEUE_SIZE,0 // RX_QUEUE
  .space VARS_SIZE,0 // VARS
  .word _pad  // ARRAY_ADR 
  .word 0 // TRACE_LEVEL 
  .word 0 // HERE 
ulast:

  .section .rodata.dictionary 

// keep alphabetic order for BASIC names from Z-A
// this sort order is for for WORDS cmd output. 	
  .type kword_end, %object
	.equ link, 0
kword_end:
  _dict_entry TK_NONE,"",0 
  _dict_entry TK_IFUNC,YPOS,YPOS_IDX // ypos 
  _dict_entry TK_IFUNC,XPOS,XPOS_IDX // xpos
  _dict_entry TK_IFUNC,XOR,XOR_IDX //bit_xor
  _dict_entry TK_CMD,WORDS,WORDS_IDX //words 
  _dict_entry TK_CMD,WAIT,WAIT_IDX //wait 
  _dict_entry TK_CMD,UNTIL,UNTIL_IDX //until 
  _dict_entry TK_IFUNC,UFLASH,UFLASH_IDX //uflash 
  _dict_entry TK_IFUNC,UBOUND,UBOUND_IDX //ubound
  _dict_entry TK_CMD,TRACE,TRACE_IDX // trace 
  _dict_entry TK_CMD,TO,TO_IDX //to
  _dict_entry TK_CMD,TIMER,TIMER_IDX //set_timer
  _dict_entry TK_IFUNC,TIMEOUT,TMROUT_IDX //timeout 
  _dict_entry TK_IFUNC,TICKS,TICKS_IDX //get_ticks
  _dict_entry TK_CMD,THEN,THEN_IDX // then 
  _dict_entry TK_CMD,TAB,TAB_IDX //tab 
  _dict_entry TK_CMD,STORE,STORE_IDX // store  
  _dict_entry TK_CMD,STOP,STOP_IDX //stop 
  _dict_entry TK_CMD,STEP,STEP_IDX //step 
  _dict_entry TK_CMD,SPC,SPC_IDX // spc 
  _dict_entry TK_CMD,SLEEP,SLEEP_IDX //sleep 
  _dict_entry TK_CMD,SAVE,SAVE_IDX //save
  _dict_entry TK_CMD,RUN,RUN_IDX //run
  _dict_entry TK_IFUNC,RSHIFT,RSHIFT_IDX //rshift
  _dict_entry TK_IFUNC,RND,RND_IDX //random 
  _dict_entry TK_CMD,RETURN,RET_IDX //return 
  _dict_entry TK_CMD,RESTORE,REST_IDX //restore 
  _dict_entry TK_CMD,REM,REM_IDX //remark 
  _dict_entry TK_IFUNC,READ,READ_IDX //read  
  _dict_entry TK_IFUNC,QKEY,QKEY_IDX //qkey 
  _dict_entry TK_CMD,PUT,PUT_IDX // put 
  _dict_entry TK_CMD,PUSH,PUSH_IDX //cmd_push  
  _dict_entry TK_CMD,PRINT,PRT_IDX //print 
  _dict_entry TK_IFUNC,POP,POP_IDX // fn_pop 
  _dict_entry TK_CMD,POKEW,POKE32_IDX //poke32
  _dict_entry TK_CMD,POKEH,POKE16_IDX // poke16
  _dict_entry TK_CMD,POKEB,POKE8_IDX // poke8 
  _dict_entry TK_CMD,PMODE,PMODE_IDX // pin_mode 
  _dict_entry TK_IFUNC,PEEKW,PEEK32_IDX //peek32
  _dict_entry TK_IFUNC,PEEKH,PEEK16_IDX //peek16
  _dict_entry TK_IFUNC,PEEKB,PEEK8_IDX //peek8
  _dict_entry TK_CMD,PAUSE,PAUSE_IDX //pause 
  _dict_entry TK_IFUNC,PAD,PAD_IDX //pad_ref
  _dict_entry TK_SCONST,OUTPUT_PP,1
  _dict_entry TK_SCONST,OUTPUT_OD,6
  _dict_entry TK_SCONST,OUTPUT_AFPP,12
  _dict_entry TK_SCONST,OUTPUT_AFOD,15 
  _dict_entry TK_CMD,OUT,OUT_IDX //out 
  _dict_entry TK_IFUNC,OR,OR_IDX //bit_or
  _dict_entry TK_SCONST,ON,1
  _dict_entry TK_SCONST,OFF,0 
  _dict_entry TK_IFUNC,NOT,NOT_IDX //func_not 
  _dict_entry TK_CMD,NEXT,NEXT_IDX //next 
  _dict_entry TK_CMD,NEW,NEW_IDX //new
  _dict_entry TK_IFUNC,LSHIFT,LSHIFT_IDX //lshift
  _dict_entry TK_CMD,LOCATE,LOCATE_IDX // locate 
  _dict_entry TK_CMD,LOAD,LOAD_IDX //load 
  _dict_entry TK_CMD,LIST,LIST_IDX //list
  _dict_entry TK_CMD,LET,LET_IDX //let 
  _dict_entry TK_CFUNC,KEY,KEY_IDX //key 
  _dict_entry TK_IFUNC,INVERT,INVERT_IDX //invert 
  _dict_entry TK_SCONST,INPUT_PU, 17 
  _dict_entry TK_SCONST,INPUT_PD, 16
  _dict_entry TK_SCONST,INPUT_FLOAT,4
  _dict_entry TK_SCONST,INPUT_ANA,0 
  _dict_entry TK_CMD,INPUT,INPUT_IDX //input_var
  _dict_entry TK_IFUNC,IN,IN_IDX // pin_input   
  _dict_entry TK_CMD,IF,IF_IDX //if 
  _dict_entry TK_CMD,HEX,HEX_IDX //hex_base
  _dict_entry TK_SCONST,GPIOC,GPIOC_BASE_ADR //  
  _dict_entry TK_SCONST,GPIOB,GPIOB_BASE_ADR //  
  _dict_entry TK_SCONST,GPIOA,GPIOA_BASE_ADR //  
  _dict_entry TK_CMD,GOTO,GOTO_IDX //goto 
  _dict_entry TK_CMD,GOSUB,GOSUB_IDX //gosub 
  _dict_entry TK_IFUNC,GET,GET_IDX // get 
  _dict_entry TK_IFUNC,FREE,FREE_IDX //free  
  _dict_entry TK_CMD,FORGET,FORGET_IDX //forget 
  _dict_entry TK_CMD,FOR,FOR_IDX //for 
  _dict_entry TK_CMD,ERASE,ERASE_IDX // erase 
  _dict_entry TK_CMD,END,END_IDX //cmd_end  
  _dict_entry TK_CMD,DUMP,DUMP_IDX // dump 
  _dict_entry TK_CMD,DROP,DROP_IDX // drop 
  _dict_entry TK_CMD,DO,DO_IDX //do_loop
  _dict_entry TK_CMD,DIR,DIR_IDX //directory 
  _dict_entry TK_CMD,DEC,DEC_IDX //dec_base
  _dict_entry TK_CMD,DATA,DATA_IDX //data  
  _dict_entry TK_CMD,CONST,CONST_IDX // const 
  _dict_entry TK_CMD,CLS,CLS_IDX // cls 
  _dict_entry TK_CFUNC,CHAR,CHAR_IDX //char
  _dict_entry TK_CMD,BTOGL,BTOGL_IDX //bit_toggle
  _dict_entry TK_IFUNC,BTEST,BTEST_IDX //bit_test 
  _dict_entry TK_CMD,BSET,BSET_IDX //bit_set 
  _dict_entry TK_CMD,BRES,BRES_IDX //bit_reset
  _dict_entry TK_IFUNC,BIT,BIT_IDX //bitmask
  _dict_entry TK_CMD,AWU,AWU_IDX //awu 
  _dict_entry TK_IFUNC,ASC,ASC_IDX //ascii
  _dict_entry TK_IFUNC,AND,AND_IDX //bit_and
  _dict_entry TK_CMD,ADC,ADC_IDX // adc 
  _dict_entry TK_IFUNC,ANA,ANA_IDX // analog_read 
first_link: 
  .word LINK 
  .word ABS_IDX 
  .word TK_IFUNC
kword_dict: // first name field 
  .equ LINK,. 
  .asciz "ABS" 
  .p2align 2 

    .section .rodata.fn_tabld 

//comands and fonctions address table
  .type fn_table, %object
fn_table:
	.word abs,analog_read,adc,bit_and,ascii,awu,bitmask 
	.word bit_reset,bit_set,bit_test,bit_toggle,char,cls,const   
	.word skip_line,dec_base,directory,do_loop,drop,dump
	.word cmd_end,erase,for,forget,free,get,gosub,goto
	.word hex_base,if,pin_input,input_var,invert,key
	.word let,list,load,locate,lshift,new,next
	.word func_not,bit_or,out,pad_ref,pause,pin_mode,peek8,peek16,peek32
	.word poke8,poke16,poke32,fn_pop,print,cmd_push,put  
	.word qkey,read,skip_line
	.word restore,return, random,rshift,run,save
	.word sleep,spc,step,stop,store,tab
	.word then,get_ticks,set_timer,timeout,to,trace,ubound,uflash,until
	.word wait,words,bit_xor,xpos,ypos 
	.word 0 


/**********************************
    BASIC commands and functions 
**********************************/

    .section .text.basic , "ax", %progbits 


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

/*************************************
  BASIC: ANA(pin)
  read analog input 
*************************************/
    _FUNC analog_read
    _CALL func_args
    cmp r0,#1 
    bne syntax_error 
    _MOV32 R1,ADC1_BASE_ADR
    _POP r2 // channel
    and r2,#31
    str r2,[r1,#ADC_SQR3]
// start conversion 
    ldr r0,[r1,#ADC_CR2]
    str r0,[r1,#ADC_CR2]
adc_loop:
    ldr r0,[R1,#ADC_SR]
    tst r0,#2 // EOC bit test 
    beq adc_loop
    ldr r1,[r1,#ADC_DR]
    mov r0,#TK_INTGR    
    _RET

/***********************************
  BASIC: ADC ON|OFF
  enable|disable analog digital converter 
  freq -> of conversion
*****************************************/
    _FUNC adc 
    _CALL arg_list 
    cmp r0,#1 
    bne syntax_error 
    _POP r1 
1:  cbz r1,adc_off 
adc_on:
    _MOV32 r1,RCC_BASE_ADR
    ldr r0,[r1,RCC_APB2ENR]
    orr r0,#(1<<9) //ADC1ON clock gating 
    str r0,[r1,RCC_APB2ENR]
    _MOV32 r1,ADC1_BASE_ADR
    _MOV32 r0,1+(1<<23)
    str r0,[r1,ADC_CR2]
    _RET 
adc_off:
    _MOV32 r1,ADC1_BASE_ADR 
    eor r0,r0 
    str r0,[r1,ADC_CR2]
    _MOV32 r1,RCC_BASE_ADR 
    ldr r0,[r1,RCC_APB2ENR]
    mvn r2,#9 
    and r0,r2 //reset ADC1ON clock gating 
    str r0,[r1,RCC_APB2ENR]
    _RET 


/************************************
  BASIC: AND(expr1,expr2)
  logical ANND bit to between expr1,expr2
************************************/
    _FUNC bit_and
    _CALL func_args 
    cmp r0,#2 
    bne syntax_error 
    _POP r0 
    _POP r1 
    and r1,r0 
    mov r0,#TK_INTGR
    _RET

/*******************************************
  BASIC: ASC(string|char)
  return ASCII code of char of first char 
  of string 
*******************************************/
    _FUNC ascii
    mov r0,#TK_LPAREN 
    _CALL expect 
    _CALL next_token 
    cmp r0,#TK_QSTR
    beq 2f 
    cmp r0,#TK_CHAR 
    bne 1f  
    b 9f
1:  cmp r0,#TK_CFUNC 
    mov r0,r1 
    _CALL execute
    b 9f      
2:  ldrb r1,[r1]
9:  _PUSH r1 
    mov r0,#TK_RPAREN 
    _CALL expect 
    mov r0,#TK_INTGR 
    _POP r1 
    _RET

    _FUNC autorun
    _RET

/*******************************************
  BASIC: AWU time_sleep  
  enable LSI and IWDG and place MCU in 
  deep sleep. IDWG wakeup MCU 
******************************************/
    _FUNC awu
    _CALL arg_list
    cmp r0,#1 
    bne syntax_error 
    _MOV32 r1,RCC_BASE_ADR
    ldr r0,[r1,#RCC_CSR]
// enable LSI 
    eor r0,#1
    str r0,[r1,#RCC_CSR]
// wait for LSIRDY 
1:  ldr r0,[r1,#RCC_CSR]
    tst r0,#2 // LSIRDY bit 
    beq 1b 
// configure IWDG
// compute values for IWDG_PR and IWDG_RLR 
    _POP r2 // time_sleep in msec. 
    mov r3,#10 // Flsi=40Khz but smallest divisor is 4 
    mul r2,r3 
    eor r3,r3
2:  cmp r2,#8192 
    bmi 3f 
    lsr r2,#1 
    add r3,#1
    b 2b
// initialize IWDG      
3:  _MOV32 r1,IWDG_BASE_ADR
    mov r0,0x5555 // enable register writing
    str r0,[r1,#IWDG_KR]
    str r3,[r1,#IWDG_PR]
    str r2,[r1,#IWDG_RLR]
    mov r0,#0xcccc // start IWDG 
    str r0,[r1,#IWDG_KR]
    b sleep // place MCU in deep sleep
    _RET

/********************************************
  BASIC: BIT(expr)
  expr must be between 0..31 and is used 
  to create 1 bit mask at that position
*******************************************/
    _FUNC bitmask
    _CALL func_args
    cmp r0,#1 
    bne syntax_error 
    _POP r0
    mov r1,#1
    lsl r1,r0 
9:  mov r0,#TK_INTGR
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
    _RET  


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
    _RET 

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
    _RET  

/********************************
  BASIC: BTEST(addr,bit)
  return bit state at address
********************************/
    _FUNC bit_test
    _CALL func_args
    cmp r0,#2 
    bne syntax_error 
    _POP r1
    mov r0,#1
    and r1,#31  
1:  cbz r1, 2f
    lsl r0,#1
    sub r1,#1
    b 1b 
2:  _POP r1
    ldr r1,[r1]
    and r1,r0 
    cbz r1,9f 
    mov r1,#1
9:  mov r0,#TK_INTGR    
    _RET 

/********************************
  BASIC: CLS 
  clear terminal screen move cursor 
  home 
************************************/
    _FUNC cls 
    _CALL clear_screen
    _RET 

/*********************************
  BASIC: CHAR(expr)
  convert expr in character 
********************************/
    _FUNC char
    _CALL func_args
    cmp r0,#1
    bne syntax_error 
    _POP r1 
    and r1,#127 
    mov r0,#TK_CHAR
    _RET 

/**********************************
  BASIC: CONST label=expr [,!label=expr]
  define constants constants are 
  store at end of BASIC code.
  use:
    T1   *location 
    T2   *bound 
*********************************/
    _FUNC const
    _RTO 
    ldr T1,[UPP,#HERE]
    ldr T2,pad_adr  
1:  cmp T1,T2 
    bmi 2f 
    mov r0,#ERR_MEM_FULL 
    b tb_error 
2:  _CALL next_token 
    cmp r0,#TK_LABEL 
    bne syntax_error 
    orr r1,#(1<<31) // this label identify a constant 
    _PUSH r1 
    mov r0,#TK_EQUAL
    _CALL expect
    _CALL expression  
    cmp r0,#TK_INTGR
    bne syntax_error
    _POP r0 
    str r0,[T1],#4
    str r1,[T1],#4 
    str T1,[UPP,#HERE]
    _CALL next_token
    cmp r0,#TK_COMMA 
    beq 1b 
    _UNGET_TOKEN
9:  
    _RET 

/*****************************
  BASIC: READ 
  read next data item 
  the value can be assigned to
  variable or used in expression
*****************************/
    _FUNC read
    _RTO
    ldr r0,[UPP,#DATALEN] // line length 
    ldr r1,[UPP,#DATAPTR] // line address 
    ldr r2,[UPP,#DATA] // item on line  
    cmp r2,r0
    beq seek_next
1:  mov r3,#1 
    ldrb r0,[r1,r2]
    add r2,#1
    cmp r0,#TK_NONE
    beq seek_next
    cmp r0,#TK_MINUS 
    bne 2f 
    mov r3,#-1
    ldrb r0,[r1,r2]
    add r2,#1
    b 3f  
2:  cmp r0,#TK_COMMA
    beq 1b  
3:  cmp r0,#TK_INTGR 
    bne syntax_error  
    ldr r1,[r1,r2]
    add r2,#4
    str r2,[UPP,#DATA]
    b 9f  
seek_next: // is next line data ?
    ldrb r0,[R1,#2]
    add r1,r0 
    ldrb r0,[R1,#3]
    cmp r0,#TK_CMD
    bne 2f 
    ldrb r0,[r1,#4]
    cmp r0,#DATA_IDX 
    bne 2f 
    str r1,[UPP,#DATAPTR]
    ldrb r0,[r1,#2]
    str  r0,[UPP,#DATALEN]
    mov r2,#5 
    str r2,[UPP,#DATA]
    b 1b 
2:  mov r0,#ERR_NO_DATA
    b tb_error 
9:  _RET 

/********************************
  BASIC: RESTORE [line#]
  set data pointer to first data line 
  or a specified line number 
********************************/
    _FUNC restore
    _RTO 
    _CALL next_token 
    cmp r0,#TK_INTGR 
    beq 0f 
    _UNGET_TOKEN
    mov r1,#0 
0:  mov r3,#(TK_CMD+(DATA_IDX<<8))
    mov r2,r1 
    ldr r1,[UPP,#TXTBGN]
    ldr T1,[UPP,#TXTEND]
1:  cmp r1,T1 
    bpl no_data_line 
    ldrh r0,[r1,#3]
    cmp r0,r3 
    bne try_next_line
// this is a data line
    cbz r2,2f 
    ldrh r0,[r1]
    cmp r0,r2 
    bne try_next_line
2:  str r1,[UPP,#DATAPTR]
    ldrb r0,[r1,#2]
    str r0,[UPP,#DATALEN]
    mov r0,#5 
    str r0,[UPP,#DATA]
    b 9f
try_next_line:
    ldrb r0,[r1,#2]
    add r1,r0 
    b 1b 
no_data_line:
    eor r0,r0 
    str r0,[UPP,#DATAPTR]
    str r0,[UPP,#DATA]
    str r0,[UPP,#DATALEN]
9:  _RET 

/***********************************
  BASIC: DEC 
  switch base to decimal 
***********************************/
    _FUNC dec_base
    mov r0,#10
    str r0,[UPP,#BASE]
    _RET 

/***************************************
  BASIC: DO 
  initialize a DO..UNTIL loop 
***************************************/
    _FUNC do_loop
    stmdb DP!,{IN,BPTR}
    _RET 


/****************************************
  BASIC: DUMP adr, count 
    command line only  
    print memory content in hexadecimal 
    16 bytes per row 
    ouput:
      none 
    use:
      r2   byte counter  
****************************************/
    _FUNC dump 
    _CLO 
    _CALL arg_list 
    cmp r0,#2
    bne syntax_error 
    _POP r2   // count 
    _POP  r0  // adr
dump01:
    _CALL print_dump_header 
1:  mov r1,#16
    _CALL prt_row 
    subs r2,#16 
    bpl 1b 
    _RET 

/********************************
   print_dump_header
********************************/
    _FUNC print_dump_header
    push {r0,T1,T2}
    mov r0,#12 
    _CALL cursor_x 
    mov r0,#0
    mov T2,#16
1:  mov T1,r0 
    _CALL print_hex 
    add r0,T1,#1  
    cmp r0,T2 
    bmi 1b 
    _CALL cr
    mov r0,#'='
    mov T1,#79
2:  _CALL uart_putc
    subs T1,#1 
    bne 2b     
    _CALL cr
    pop {r0,T1,T2}
    _RET 


/*******************************
  BASIC: END 
  exit program 
******************************/ 
    _FUNC cmd_end
    b warm_start 
    _RET 

/*******************************************
  BASIC: STORE adr, value 
  write value to user space in flash memory 
*********************************************/
    _FUNC store 
    _CALL arg_list 
    cmp r0,#2 
    bne syntax_error 
    ldmia DP!,{r0,r1}
    ldr r2,user_space
    cmp r1,r2 
    bpl 1f 
0:  mov r0,#ERR_BAD_VALUE
    b tb_error 
1:  add r2,#1024 
    cmp r1,r2 
    bpl 0b 
    _CALL flash_store 
    _RET 

/**************************************************
  BASIC: ERASE 
  erase user space page 
*************************************************/
    _FUNC erase 
    ldr r0,user_space 
    _CALL erase_page 
    _RET 
user_space: .word user 


/**************************************************
  BASIC: FOR var=expr TO expr [STEP exp] ... NEXT 
  introdure FOR...NEXT loop 
**************************************************/
    _FUNC for
    stmdb r12!,{VADR,LIMIT,INCR}
    mov INCR,#1
    _CALL next_token
    cmp r0,#TK_VAR
    bne syntax_error
    push {r1} 
    _CALL let_var 
    pop {VADR}
    lsl VADR,#2
    add VADR,UPP 
    add VADR,#VARS 
    _RET 

/***************************************
  BASIC: TO expr 
  set limit of FOR...NEXT loop 
**************************************/
    _FUNC to
    _CALL expression 
    cmp r0,#TK_INTGR
    bne syntax_error 
    mov LIMIT,r1
    // save loop back parameters 
    stmdb DP!,{IN,BPTR}
    _RET 

/********************************************
  BASIC: STEP expr 
  set increment for FOR...NEXT loop 
********************************************/
    _FUNC step
    _CALL expression 
    cmp r0,#TK_INTGR
    bne syntax_error 
    mov INCR,r1
    // replace parameters left by TO
    stmia DP, {IN,BPTR}
    _RET 

/********************************************
  BASIC: NEXT var 
  incrment FOR...NEXT loop variable
  exit if variable cross LIMIT 
********************************************/
    _FUNC next
    _CALL next_token 
    cmp r0,#TK_VAR 
    bne syntax_error 
    lsl r1,#2 
    add r1,UPP 
    add r1,#VARS 
    cmp r1,VADR
    bne syntax_error 
    ldr r0,[VADR]
    add r0,INCR 
    str r0,[VADR]
    cmp INCR,#0
    bmi 2f
    cmp r0,LIMIT 
    bgt 8f  
    b 9f  
2:  cmp r0,LIMIT 
    bge 9f  
8: // exit for...next
  //  drop branch parameters
    _DROP 2
  // restore outer loop parameters
    ldmia DP!,{VADR,LIMIT,INCR}
    _RET 
9:  ldmia DP,{IN,BPTR}
    ldrb r0,[BPTR,#2]
    str r0,[UPP,#COUNT]
    _CALL show_trace 
    _RET 


/*********************************
  BASIC: GOSUB expr 
  call a subroutine at line# 
*********************************/
    _FUNC gosub
    _CALL search_target 
    push {IN,BPTR}
target:
    mov BPTR,r0 
    mov IN,#3 
    ldrb r0,[BPTR,#2]
    str r0,[UPP,#COUNT]
    _CALL show_trace 
    _RET 

/**********************************
  BASIC: RETURN 
  leave a subroutine 
*********************************/
    _FUNC return 
    pop {IN,BPTR}
    ldrb r0,[BPTR,#2]
    str r0,[UPP,#COUNT]
    _CALL show_trace 
    _RET 

/**********************************
  BASIC: GOTO expr 
  go to line # | label 
**********************************/
    _FUNC goto
    _CALL search_target 
    b target  

/***************************************
  BASIC: HEX 
  set numeric base to hexadecimal 
***************************************/
    _FUNC hex_base
    mov r0,#16 
    str r0,[UPP,#BASE]
    _RET 

/**********************************************
  BASIC: IF relation THEN statement
  execute statement only if relation is true
*********************************************/
    _FUNC if
    _CALL relation 
    cbnz r1,9f 
    ldr IN,[UPP,#COUNT]
9:  _RET 

/*******************************************************
  BASIC: THEN statement
  statements following THEN are executed if relation is !=0
  optional, retained for compatibility.
******************************************************/
    _FUNC then 
// do nothing 
    _RET

/****************************************
  BASIC: INPUT [string]var [,[string]var]+
  prompt user for variable value
  use:
    r2   
    T1   variable indice 
***************************************/
     _FUNC input_var
    push {r2,T1}
1:  _CALL next_token 
    cmp r0,#2
    bmi 8f 
    cmp r0,#TK_QSTR 
    bne 2f 
    mov r0,r1
    ldr r1,str_buffer
    _CALL strcpy
    mov r0,#TK_VAR   
    _CALL expect 
    mov T1,r1 
    ldr r0,str_buffer 
    b 3f 
2:  cmp r0,#TK_VAR 
    bne syntax_error     
    mov T1,r1 
    add r0,r1,#'A' 
    ldr r1,str_buffer
    strh r0,[r1]
    mov r0,r1 
3:  _CALL uart_puts  
    mov r0,#'='
    _CALL uart_putc
    ldr r0,input_buffer
    mov r1,#34 
    _CALL readln
    cbz r1,6f
    ldrb r1,[r0]
    push {r0}
    mov r0,r1
    _CALL is_letter 
    pop {r0}
    bne 3f 
    and r1,#0x5f // uppercase  
    b 7f 
3:  mov r2,#1
    cmp r1,#'-'
    bne 3f 
    mov r2,#-1 
    add r0,#1 
    b 4f  
3:  cmp r1,#'$'
    bne 3f 
    mov r1,#16
    add r0,#1  
    b 5f 
3:  cmp r1,#'&' 
    bne 4f 
    mov r1,#2
    add r0,#1 
    b 5f 
4:  mov r1,#10 
5:  _CALL atoi 
    cbnz r0,6f
    mov r0,#ERR_BAD_VALUE
    b tb_error
6:  mul r1,r2 
7:  mov r0,T1 
    _CALL set_var
    _CALL next_token
    cmp r0,#TK_COMMA 
    beq 1b 
8:  _UNGET_TOKEN          
9:  pop {r2,T1}       
    _RET 
input_buffer: .word _tib 
str_buffer: .word _pad 


/*****************************************
  BASIC: INVERT(expr)
  return 1's complement of expr
****************************************/
    _FUNC invert
    _CALL func_args
    cmp r0,#1 
    bne syntax_error
    _POP r1  
    mvn r1,r1
    mov r0,#TK_INTGR
    _RET 

/*************************************
  BASIC: KEY 
  wait for a character from console
*************************************/
    _FUNC key
    _CALL uart_getc
    mov r1,r0
    mov r0,#TK_CHAR 
    _RET  

/******************************
  BASIC: [LET] var=expr 
         [LET] @(expr)=expr
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
    lsl r1,#2
    add r0,UPP,#VARS
    add r0,r1
    b 1f 
let_array: 
    mov r0,#TK_LPAREN
    _CALL expect 
    _CALL expression
    cmp r0,#TK_INTGR 
    bne syntax_error
    _PUSH r1 
    mov r0,#TK_RPAREN
    _CALL expect 
    _POP r1 
    ldr r0,[UPP,#ARRAY_ADR]
    lsl r1,#2 
    sub r0,r1 
1:  _PUSH r0 
    mov r0,#TK_EQUAL 
    _CALL expect 
    _CALL expression   
    cmp r0,#TK_INTGR
    bne syntax_error   
2:  _POP r0 
    str r1,[r0]
    _RET  

/***************************************
  BASIC: LIST [[first]-last]
  use:
    r2   first line# 
    r3   last line#
    T1   *line 
    T2   TXTEND 
**************************************/  
    _FUNC list
    _CLO
    ldr T1,[UPP,#TXTBGN]
    ldr T2,[UPP,#TXTEND]
    ldrh r2,[T1]
    mov r3,#65535 
    _CALL next_token 
    cbz r0,6f 
    cmp r0,#TK_INTGR
    bne 1f 
    mov r2,r1 // first line
    _CALL next_token
    cmp r0,#TK_NONE 
    bne 1f 
    mov r3,r2 
    b 4f 
1:  cmp r0,#TK_MINUS 
    bne syntax_error 
    _CALL next_token 
    cbz r0,4f 
    cmp r0,#TK_INTGR
    bne syntax_error  
    mov r3,r1 
4:  // skip lines below r2 
    ldrh r0,[T1]
    cmp r0,r2 
    bpl 6f 
    ldrb r0,[T1,#2]
    add T1,r0
    cmp T1,T2 
    bmi 4b
    b 9f 
6:  cmp T1,T2  
    bpl 9f
    mov r0,T1   
    ldr r1,out_buff 
    _CALL decompile_line 
    _CALL uart_puts 
    _CALL cr 
    ldrb r0,[T1,#2]
    add T1,r0
    ldrh r0,[T1]
    cmp r0,r3 
    ble 6b 
9:  b warm_start 
out_buff: .word _tib 

/********************************
  BASIC: LOCATE line,col
  return log base 2 of expr 
********************************/
    _FUNC locate
    _CALL arg_list 
    cmp r0,#2 
    bne syntax_error
    _POP r1
    _POP r0  
    _CALL set_curpos 
    _RET 


/****************************************
  BASIC: LSHIFT(expr1,expr2)
  shift right expr1 of expr2 bits 
****************************************/
    _FUNC lshift
    _CALL func_args
    cmp r0,#2
    bne syntax_error 
    ldmia DP!,{r0,r1}
    lsl r1,r0 
    mov r0,#TK_INTGR
    _RET 

/***********************************
  BASIC: NEW 
  delete existing program in memory
  and clear variables and RAM 
***********************************/
    _FUNC new
    _CLO 
    _CALL clear_basic 
    b warm_start   

/************************************
  BASIC: NOT relation  
  invert logical value or relation
************************************/
      _FUNC func_not
      _CALL relation 
      cbz r1,8f 
      eor r1,r1
      b 9f 
  8:  mov r1,#-1
  9:  _RET 

/******************************************
  BASIC: OR(expr1,expr2)
  binary OR between 2 expressions
******************************************/
    _FUNC bit_or
    _CALL func_args
    cmp r0,#2
    bne syntax_error
    _POP r0 
    _POP r1
    orr r1,r0 
    mov r0,#TK_INTGR
    _RET 

/****************************************
  BASIC: IN(gpio,pin) 
  read gpio_idr selected pin  
***************************************/
    _FUNC pin_input 
    _CALL func_args 
    cmp r0,#2 
    bne syntax_error  
    ldmia DP!,{r0,r1}
    mov r2,#GPIO_IDR 
    ldr r2,[r1,r2]
    and r0,#15 
    lsr r2,r0 
    and r1,r2,#1 
    mov r0,#TK_INTGR
    _RET 


/****************************************
  BASIC: OUT gpio,pin,value 
   output to gpio_odr
***************************************/
    _FUNC out
    _CALL arg_list 
    cmp r0,#3 
    bne syntax_error 
    ldmia DP!,{r0,r1,r2} // value,pin,gpio 
    mov r3,#GPIO_BSRR
    cbnz r0,1f 
    add r1,#16 
1:  mov r0,#1 
    lsl r0,r1 
    str r0,[r2,r3]    
    _RET 


/****************************************
  BASIC: PAD 
  return pad buffer address 
****************************************/
    _FUNC pad_ref
    ldr r1,pad_adr  
    mov r0,#TK_INTGR 
    _RET 
pad_adr: .word _pad 

/***********************
  BASIC: PAUSE expr 
  suspend execution for 
  expr milliseconds 
************************/
    _FUNC pause
    _CALL expression 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    ldr r0,[UPP,#TICKS]
    add r0,r1 
1:  ldr r1,[UPP,#TICKS]
    cmp r0,r1 
    bne 1b     
    _RET 

/***************************************************
  BASIC: PMODE GPIOx,pin,mode
  configure a digital pin for input|output
  paramters:
    GPIOx    port selector: GPIOA,GPIOB,GPIOC
    pin      pin {0..15} 
    mode 
    for input mode:
      INPUT_FLOAT,INPUT_PD,INPUT_PU,INPUT_ANA    
    for output mode:
      OUTPUT_AFOD,OUTPUT_AFPP,OUTPUT_OD,OUTPUT_PP 
  use:
    r0  tmp 
    r1  mode  
    r2  pin  
    r3  gpio
    T1  mask
***************************************************/
    _FUNC pin_mode
    _CALL arg_list
    cmp r0,#3 
    bne syntax_error 
    ldmia DP!,{r1,r2,r3} // mode,pin,gpio 
    mov r0,#1
    lsl r0,r2 // pin mask in GPIO_ODR 
    cmp r1,#16 
    bmi 1f 
    rors r1,#1
    and r1,#15  
    bcs 1f  
    lsl r0,#16 // reset pin  
1:  str r0,[r3,#GPIO_BSRR]
    cmp r2,#8 
    bmi 2f 
    add r3,#4 // GPIO_CRH 
    sub r2,#8 
2:  lsl r2,#2 // pin*4  
    ldr r0,[r3] // actual CNF:MODE value in GPIO_CRx  
    mvn T1,#15
    lsl T1,r2
    and r0,T1 //clear bit field  
    lsl r1,r2 
    orr r0,r1 
    str r0,[r3]
    _RET 


/*****************************************
  BASIC: PEEK8 (expr)  
  return byte value at address 
*****************************************/
    _FUNC peek8
    _CALL func_args  
    cmp r0,#1
    bmi syntax_error
    _POP r1 
    ldrb r1,[r1]
    mov r0,#TK_INTGR     
    _RET 

/*****************************************
  BASIC: PEEK16 (expr)  
  return byte value at address 
*****************************************/
    _FUNC peek16
    _CALL func_args  
    cmp r0,#1
    bmi syntax_error
    _POP r1 
    ldrh r1,[r1]
    mov r0,#TK_INTGR     
    _RET 

/*****************************************
  BASIC: PEEK32 (expr)  
  return byte value at address 
*****************************************/
    _FUNC peek32
    _CALL func_args  
    cmp r0,#1
    bmi syntax_error
    _POP r1 
    ldr r1,[r1]
    mov r0,#TK_INTGR     
    _RET 


/**********************************
  BASIC: POKE8 addr,byte
  store byte at addr   
**********************************/
    _FUNC poke8
    _CALL arg_list
    cmp r0,#2 
    bne syntax_error
    ldmia DP!,{r0,r1} 
    strb r0,[r1]
    _RET 

/**********************************
  BASIC: POKE16 addr,hword
  store hword at addr   
**********************************/
    _FUNC poke16
    _CALL arg_list
    cmp r0,#2 
    bne syntax_error
    ldmia DP!,{r0,r1} 
    strh r0,[r1]
    _RET 

/**********************************
  BASIC: POKE32 addr,word
  store word at addr   
**********************************/
    _FUNC poke32
    _CALL arg_list 
    cmp r0,#2 
    bne syntax_error
    ldmia DP!,{r0,r1} 
    str r0,[r1]
    _RET 



/****************************
  BASIC: PRINT|? arg_list 
  print list of arguments 
****************************/
    _FUNC print
    ldr r0,[UPP,#FLAGS]
    orr r0,#FPRINT 
    str r0,[UPP,#FLAGS]
    eor T1,T1 
0:  _CALL expression
    cmp r0,#TK_INTGR
    bne 1f 
    mov r0,r1
    ldr r1,[UPP,#BASE]
    _CALL print_int
    b 8f  
1:  cmp r0,#TK_COLON 
    bgt 2f
    b unget_exit 
2:  cmp r0,#TK_QSTR 
    bne 3f
    mov r0,r1 
    _CALL uart_puts  
    b 8f 
3:  cmp r0,#TK_CFUNC
    bne 4f
    mov r0,r1
    _CALL execute 
4:  cmp r0,#TK_CHAR 
    bne 5f 
    mov r0,r1 
    _CALL uart_putc 
    b 8f 
5:  cmp r0,#TK_SHARP
    bne 6f 
   _CALL next_token
    cmp r0,#TK_INTGR  
    bne syntax_error 
    str r1,[UPP,#TAB_WIDTH]
    b 8f 
6:  cmp r0,#TK_CMD 
    bne unget_exit  
    cmp r1,#TAB_IDX 
    bne 6f
    _CALL tab 
    b 8f 
6:  cmp r1,#SPC_IDX  
    bne unget_exit
    _CALL spc   
8:  eor T1,T1  
    _CALL next_token
    cbz r0, print_exit  
    cmp r0,#TK_COMMA 
    bne 8f 
    mov T1,#-1
    b 0b
8:  cmp r0,#TK_SEMIC 
    bne unget_exit 
    _CALL tabulation 
    mov T1,#-1
    b 0b
unget_exit:         
   _UNGET_TOKEN 
print_exit:
    ands T1,T1 
    bne 9f
    _CALL cr
    ldr r0,[UPP,#FLAGS]
    eor r0,#FPRINT 
    str r0,[UPP,#FLAGS] 
9:  _RET 

/**************************************
  BASIC: QKEY
  check if key pressed 
**************************************/ 
    _FUNC qkey
    mov r1,#0
    _CALL uart_qkey
    beq 9f 
    mov r1,#-1 
9:  mov r0,#TK_INTGR
    _RET 

/******************************************
  BASIC RANDOM(expr)
  generate random number between 0..expr-1
******************************************/
    _FUNC random
    _CALL func_args 
    cmp r0,#1
    bne syntax_error 
    ldr r0,[UPP,#SEED]
    lsl r1,r0,#13
    eor r1,r0
    lsr r0,r1,#17
    eor r1,r0
    lsl r0,r1,#5
    eor r1,r0
    str r1,[UPP,#SEED]
    _POP r0 
    udiv r2,r1,r0  
    mul r2,r0 
    sub r1,r2 
    mov r0,#TK_INTGR
    _RET 

/****************************************
  BASIC: RSHIFT(expr1,expr2)
  shift left expr1 de expr2 bits 
****************************************/
    _FUNC rshift
    _CALL func_args
    cmp r0,#2 
    bne syntax_error
    ldmia DP!,{r0,r1}
    lsr r1,r0  
    mov r0,#TK_INTGR
    _RET 

/****************************
  BASIC: RUN 
  execute program in memory
****************************/
    _FUNC run
    _CLO 
    ldr r0,[UPP,#TXTBGN]
    ldr r1,[UPP,#TXTEND]
    str r1,[UPP,#HERE]
    cmp r0,r1
    beq 9f
    ldr r1,[UPP,#FLAGS]
    tst r1,#FSTOP
    beq 1f
    ldmia DP!,{r0,IN,BPTR}
    str r0,[UPP,#COUNT]
    ldr r0,[UPP,#FLAGS]
    mov r1,#FRUN+FSTOP
    eor r0,r1
    str r0,[UPP,#FLAGS] 
    b 9f  
1:  ldrb r1,[r0,#2]
    str r1,[UPP,#COUNT]
    mov BPTR,r0 
    mov IN,#3
    ldr r0,[UPP,#TXTEND]
    // reset dataline pointers 
    eor r0,r0 
    str r0,[UPP,#DATAPTR]
    str r0,[UPP,#DATA]
    str r0,[UPP,#DATALEN] 
    ldr r0,[UPP,#FLAGS]
    orr r0,#FRUN 
    str r0,[UPP,#FLAGS]
    _CALL show_trace 
9:  _RET 

/**********************************
        FILE SYSTEM 
**********************************/

/*********************************
  search_free 
  search first free PAGE in fs
  a PAGE is free if first word is
  -1
  input:
    none 
  output:
    r0    addr|0
  use:
*********************************/
    _FUNC search_free 
    push {r1,r2}
    ldr r1,fs_addr 
    _MOV32 r2,FLASH_HIDDEN_END
1:  ldr r0,[r1]
    cmp r0,#-1
    beq 8f 
    add r1,#PAGE_SIZE
    cmp r1,r2 
    bmi 1b 
8:  mov r0,r1 
    pop {r1,r2}   
    _RET 

/*********************************
  search_file 
  search for a file name 
  in file system.
  input: 
    r0   .asciz target name
  output:
    r0    0 || address found 
  use:
   r0     temp 
   r1     *file_name 
   r2     *fs  
   r3     target   
**********************************/
    _FUNC search_file 
    push {r1,r2,r3}
    ldr r2,fs_addr
    mov r3,r0  
cmp_loop:
    ldr r0,[r2]
    cmp r0,#-1
    eor r0,r0
    beq 9f // reached end of fs 
1:  mov r0,r3
    add r1,r2,#2
    _CALL strcmp
    cbnz r0,2f
    mov r0,r2 
    b 9f   
2:  ldrh r0,[r2] // name length
    add r2,r0 
    ldrh r0,[r2]
    add r0,r2
    _CALL page_align 
    mov r2,r0   
    b cmp_loop 
9:  pop {r1,r2,r3}
    _RET 

fs_addr: .word FILE_SYSTEM

/*************************************
  BASIC: DIR 
  list files stored in fs 
  use:
    r0  temp 
    r1  temp
    r2  file count
    r3  data size
    T1  *fs  
*************************************/
    _FUNC directory
    _CLO 
    eor r2,r2 
    ldr T1,fs_addr 
1:  ldr r0,[T1] // name length 
    cmp r0,#-1
    beq no_more_file
    and r3,r0,#15
    add r0,T1,#2
    _CALL uart_puts 
    mov r0,#16 
    _CALL cursor_x 
    add T1,r3 
    ldrh r3,[T1]
    mov r0,r3 
    mov r1,#10 
    _CALL print_int
    _CALL cr  
    add r0,T1,r3 
    _CALL page_align
    mov T1,r0 
    add r2,#1 
    b 1b  
no_more_file:
    _CALL cr
    mov r0,#16
    _CALL cursor_x  
    mov r0,r2 
    mov r1,#10 
    _CALL print_int 
    ldr r0,=fcount 
    _CALL uart_puts 
    _RET 
fcount:  .asciz "files\n"

/*************************************
  BASIC: FORGET ["name"]
  delete file and all following 
  if no name given delete all files 
************************************/
    _FUNC forget
    push {r3,T2}
    ldr T2,fs_addr 
    ldr r3,[UPP,#FSFREE]
    _CALL next_token
    cbz r0,1f // no name 
    mov r0,r1
    _CALL search_file
    cbz r0,9f 
    mov T2,r0 
1:  cmp T2,r3 
    bpl 9f 
    mov r0,T2 
    _CALL erase_page
    add T2,#PAGE_SIZE
    b 1b 
9:  _CALL search_free
    pop {r3,T2} 
    _RET 

/**********************************
  BASIC LOAD "name" 
  load file in RAM for execution
  use:
    r0   temp
    r1   src
    r2   dest 
    r3   count 
**********************************/
    _FUNC load
    _CLO 
    _CALL next_token 
    cmp r0,#TK_QSTR 
    bne syntax_error 
    mov r0,r1 
    _CALL search_file 
    cbnz r0, 1f 
    mov r0,#ERR_NOT_FILE
    b tb_error 
1:  mov r1,r0 
    ldrh r0,[r1]
    add r1,r0 // data size field  
    ldrh r3,[r1],#2 // data size 
    ldr r2,[UPP,#TXTBGN]
    add r0,r2,r3  
    str r0,[UPP,#TXTEND]
    add r3,#1
    lsr r3,#1
2:  // load file data 
    ldrh r0,[r1],#2
    strh r0,[r2],#2 
    subs r3,#1 
    bne 2b 
// report file size 
    ldr r0,=fsize 
    _CALL uart_puts
    ldr r0,[UPP,#TXTEND]
    ldr r3,[UPP,#TXTBGN]
    sub r0,r3 
    mov r1,#10 
    _CALL print_int 
    ldr r0,=data_bytes 
    _CALL uart_puts      
    _RET 


/*********************************
  BASIC: SAVE "name" 
  save program in flash memory
  file structure:
    .hword name_length 
    .asciz name
    .palign 1  
    .hword data_length 
    .byte  file data (variable length)  
  use:
    r0  temp 
    r1  temp
    r2  *flash 
    r3  *ram  
    T1  temp   
********************************/
    _FUNC save
    _CLO 
    ldr r0,[UPP,#TXTEND]
    ldr r1,[UPP,#TXTBGN]
    cmp r0,r1
    bne 0f 
    mov r0,#ERR_NO_PROG
    b tb_error 
0:  _CALL next_token 
    cmp r0,#TK_QSTR
    bne syntax_error 
// check for existing 
    mov r3,r1 // save name 
    mov r0,r3  
    _CALL search_file
    cbz r0,new_file 
    mov r0,#ERR_DUPLICATE
    b tb_error 
new_file:
    mov r0,#1 
    _CALL unlock 
    ldr r2,[UPP,#FSFREE] //*flash 
    mov r0,r3 // *name 
    _CALL strlen 
    add r0,#4  
    and r0,#-2 //even size
    sub T1,r0,#2  // name length counter   
1:  mov r1,r2  
    _CALL hword_write   
    add r2,#2  
// write file name      
2:  ldrh r0,[r3],#2 
    mov r1,r2 
    _CALL hword_write
    add r2,#2
    subs T1,#2
    bne 2b
// write data size 
    ldr r0,[UPP,#TXTEND]
    ldr r3,[UPP,#TXTBGN]
    sub r0,r3
    mov T1,r0
    mov r1,r2 
    _CALL hword_write
    add r2,#2 
// write data 
    add T1,#1 
    lsr T1,#1 // .hword to write 
3:  ldrh r0,[r3],#2
    mov r1,r2
    _CALL hword_write 
    add r2,#2 
    subs T1,#1 
    bne 3b
    mov r0,#0 
    _CALL unlock
// update FSFREE     
    ldr r0,[UPP,#TXTEND]
    ldr r1,[UPP,#TXTBGN]
    sub r0,r1 
    mov T1,r0 
    ldr r1,[UPP,#FSFREE]
    add r0,r1 
    _CALL page_align
    str r0,[UPP,#FSFREE]
    ldr r0,=fsize
    _CALL uart_puts
    mov r0,T1 
    mov r1,#10 
    _CALL print_int 
    ldr r0,=data_bytes 
    _CALL uart_puts  
    _RET 
fsize: .asciz "file size: "
data_bytes: .asciz "bytes"


/*******************************
  BASIC: FREE 
  return RAM free bytes 
*******************************/
    _FUNC free
    ldr r0,[UPP,#HERE]
    ldr r1,[UPP,#ARRAY_ADR]
    sub r1,r0
    mov r0,#TK_INTGR
    _RET  

/*********************************
  BASIC: SLEEP 
  place MCU lowest power mode 
  wait for external interrpt or
  reset.
*********************************/
    _FUNC sleep
    _MOV32 r0,SCR_BASE_ADR
    mov r1,#SCR_SLEEPDEEP
    str r1,[r0]
    _MOV32 r0,PWR_CR_ADR
    mov r1,#PWR_CR_PDDS+PWR_CR_CWUF
    str r1,[r0]
    wfe 
    _RET 

/************************************
  BASIC: SPC(expr)
  mov cursor right expr spaces 
***********************************/
    _FUNC spc 
    _CALL func_args 
    cmp r0,#1
    bne syntax_error 
    ldr r0,[UPP,#FLAGS]
    tst r0,#FPRINT 
    _POP r0 
    beq 9f 
    _CALL spaces 
9:  _RET 

    _FUNC spi_read
    _RET 

    _FUNC spi_enable
    _RET 

    _FUNC spi_select
    _RET 

    _FUNC spi_write
    _RET 

/******************************
  BASIC: STOP 
  stop program executre but 
  keep execution state for 
  resume 
******************************/
    _FUNC stop
    _RTO 
    ldr r0,[UPP,#COUNT]
    stmdb DP!,{r0,IN,BPTR}
    ldr r0,[UPP,#FLAGS]
    mov r1,#FRUN+FSTOP
    eor r0,r1
    str r0,[UPP,#FLAGS]
    eor IN,IN 
    eor BPTR,BPTR 
    str IN,[UPP,#COUNT]
    str IN,[UPP,#IN_SAVED]
    str IN,[UPP,#BASICPTR]
    _MOV32 r0,RAM_END
    mov sp,r0
    b cmd_line 


/**************************
  BASIC: TAB(expr)
  move cursor column expr 
**************************/
    _FUNC tab 
    _CALL func_args  
    cmp r0,#1 
    bne syntax_error 
    ldr r0,[UPP,#FLAGS]
    tst r0,#FPRINT
    _POP r0 
    beq 9f 
    _CALL cursor_x 
9:  _RET 


/**************************
  BASIC: TICKS 
  return msec counter
**************************/  
    _FUNC get_ticks
    ldr r1,[UPP,#TICKS]
    mov r0,#TK_INTGR
    _RET  

/*************************
  BASIC: TIMER expr 
  set countdown timer 
************************/
    _FUNC set_timer
    _CALL expression 
    cmp r0,#TK_INTGR
    bne syntax_error 
    str r1,[UPP,#TIMER]
    _RET 

/***************************
  BASIC: TIMEOUT
  check for timer expiration 
  return -1 true || 0 false
****************************/
    _FUNC timeout
    eor r1,r1 
    ldr r0,[UPP,#TIMER]
    cbnz r0,9f 
    mvn r1,r1 
9:  mov r0,#TK_INTGR    
    _RET 

/****************************************
  BASIC:  TONE freq, duration 
  play a tone with frequency freq and duration
  in milliseconds
***********************************************/
    _FUNC tone
    _CALL arg_list 
    cmp r0,#2 
    bne syntax_error
    ldmia DP!,{T1,T2}
    
    _RET 

/****************************************
  BASIC: TRACE n 
  enable execution trace 
  0   ddisable
  1   show current line#
  2  show line#+data_stack
  3  show line#+data_stack+main_stack 
***************************************/
    _FUNC trace 
    _CALL next_token 
    cmp r0,#TK_INTGR  
    bne syntax_error 
    and r1,#3 
    str r1,[UPP,#TRACE_LEVEL]
    _RET 


/***************************
  BASIC: UBOUND 
  return last indice of @
  output:
    r0  TK_INTGR 
    r1  +int 
**************************/
    _FUNC ubound
    ldr r1,[UPP,#ARRAY_ADR]
    ldr r0,[UPP,#HERE]
    sub r1,r0 
    lsr r1,#2
    mov r0,#TK_INTGR 
    _RET 

/****************************
  BASIC: UFLASH 
  return user flash address
*****************************/
    _FUNC uflash
    ldr r1,=user
    mov r0,#TK_INTGR 
    _RET 


/************************************
  BASIC: UNTIL relation 
  close a DO..UNTIL loop 
  loop until relation come true 
************************************/
    _FUNC until
    _CALL relation 
    cbz r1,9f
    add DP,#8
    _RET  
9:  ldmia DP,{IN,BPTR}
    ldrb r0,[BPTR,#2]
    str r0,[UPP,#COUNT]
    _RET 

/*************************************
  BASIC: WAIT addr,expr1[,expr2] 
  wait until *addr&expr1 is not null 
  or until (*addr&expr1)^expr2 is null 
***************************************/
    _FUNC wait
    _CALL arg_list 
    cmp r0,#2
    beq 2f 
    cmp r0,#3
    beq 4f
    b syntax_error 
2:  ldmia DP!,{r0,r1}
3:  ldrh r2,[r1]
    ands r2,r0 
    beq 3b 
    b 9f 
4:  ldmia DP!,{r0,r1,r2}
5:  ldrh r3,[r2]
    eor r3,r0
    ands r3,r1 
    beq 5b 
9:  _RET 

/*********************************************
  BASIC: WORDS 
  print list of BASIC WORDS in dictionary 
  use:
    r0,r1,r2,T1,T2  
********************************************/
    _FUNC words
    _CLO 
    ldr T1,=kword_dict
    eor T2,T2
    eor r2,r2  
1:  
    mov r0,T1
    _CALL strlen
    cbz r0,4f 
    add T2,r0 
    cmp T2,#80 
    bmi 2f
    eor T2,T2  
    _CALL cr 
2:  mov r0,T1 
    _CALL uart_puts 
    mov r0,#SPACE
    add T2,#1  
    _CALL uart_putc
    add r2,#1 
    ldr T1,[T1,#-12]
    b 1b 
4:  ands T2,T2
    beq 5f 
    _CALL cr 
5:  mov r0,r2 
    mov r1,#10
    _CALL print_int 
    ldr r0,=dict_words
    _CALL uart_puts  
9:  _RET 

dict_words: .asciz "words in dictionary" 


/**************************************
  BASIC: XOR(expr1,expr2)
  binary exclusive or between 2 expressions
**************************************/
    _FUNC bit_xor
    _CALL func_args
    cmp r0,#2
    bne syntax_error
    _POP r0
    _POP r1 
    eor r1,r0 
    mov r0,#TK_INTGR
    _RET 

/***************************************
    BASIC: XPOS 
    report cursor column on terminal 
***************************************/
    _FUNC xpos 
    _CALL get_curpos
    mov r0,#TK_INTGR
    _RET 

/***********************************
    BASIC: YPOS 
    report cursor line on terminal 
***********************************/
    _FUNC ypos 
    _CALL get_curpos 
    mov r1,r0 
    mov r0,#TK_INTGR
    _RET 


/**********************************
     argument stack manipulation
**********************************/

/**********************************
  BASIC PUSH expr[,expr] 
  push integers on stack 
*********************************/
    _FUNC cmd_push 
    _CALL arg_list
    _RET 

/********************************
  BASIC: POP 
  pop an integer out of stack 
********************************/    
    _FUNC fn_pop 
    _POP r1 
    mov r0,#TK_INTGR 
    _RET 

/*******************************
  BASIC: DROP n 
  discard n integer from stack
*******************************/
    _FUNC drop 
    _CALL expression 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    mov r0,#4 
    mul r0,r1 
    add DP,r0 
    _RET 

/********************************
  BASIC: GET(expr) 
  retreive nth element from stack 
********************************/
    _FUNC get 
    _CALL func_args
    cmp r0,#1 
    bne syntax_error 
    _POP r0
    mov r1,#4 
    mul r0,r1 
    ldr r1,[DP,r0]
    mov r0,#TK_INTGR
    _RET 

/*************************************
  BASIC: PUT value,n  
  store value at nth position on stack
**************************************/
    _FUNC put
    _CALL arg_list 
    cmp r0,#2 
    bne syntax_error 
    _POP r0 
    mov r1,#4 
    mul r0,r1 
    _POP r1
    str r1,[DP,r0]
    _RET 


  .section .rodata.user
  .p2align 10 
user:
  .space 1024,255

/*************************************************
   extra FLASH memory not used by Tiny BASIC
   is used to save BASIC programs.
************************************************/
  .p2align 10  // align to 1KB, smallest erasable segment 
  .section .rodata.fs
FILE_SYSTEM: // file system start here
