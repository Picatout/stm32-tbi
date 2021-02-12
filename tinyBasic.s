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
    mov r0,#CR 
    _CALL uart_putc  
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
    mov r0,#3
    _CALL spaces  
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
    mov r0,#CR 
    _CALL uart_putc 
    mov r0,r2
    pop {r2,r3}      
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
    _FUNC search_lineno
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
    mov r0,#ERR_BAD_VALUE 
    b tb_error  
1:  // write line # to pad 
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
    mov r0,r3 
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
    .macro _case c, next  
    cmp r0,#\c 
    bne \next
    .endm 

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
    _CALL upper 
    _CALL is_special
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
    beq 1f 
    strb r0,[T2],#1 
    str r1,[T2],#4
    b token_exit 
1:  _CALL parse_keyword 
    cmp r0,#TK_VAR 
    beq 2f 
    cmp r1,#REM_IDX 
    beq tick
2:  strb r0,[T2],#1 
    strb r1,[T2],#1
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
  .asciz " ,@():#-+*/%=<>\\?'\""

tok_single:
  .byte TK_NONE,TK_COMMA,TK_ARRAY,TK_LPAREN,TK_RPAREN,TK_COLON,TK_SHARP
  .byte TK_MINUS,TK_PLUS,TK_MULT,TK_DIV,TK_MOD,TK_EQUAL 
  
  .p2align 2
token_ofs:
  .hword  0 // not found
  // TK_COMMA...TK_EQUAL , 12 
  .hword  (single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2
  .hword  (single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2
  .hword  (single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2,(single-tok_idx0)/2     
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
    r0   char 
    r1   save r3 
    r2   int
    r6   base 
    r7   digit count 
    r3   tib index   
    T1   *tib 
    T2   *pad  
*****************************/
    _FUNC parse_int 
    push {r6,r7}
    eor r2,r2 // int 
    mov r1,r3 
    mov r6,#10 // default base 
    eor r7,r7 // digit count 
    ldrb r0,[T1,r3]
    add r3,#1 
    cmp r0,'$' 
    bne 2f 
    mov r6,#16 // hexadecimal number 
    b 3f  
2:  cmp r0,#'&' 
    bne 4f
    mov r6,#2 //binary number  
3:  ldrb r0,[T1,r3]
    add r3,#1
4:  _CALL upper 
    cmp r0,#'A'
    bmi 5f
    subs r0,#7  
5:  subs r0,#'0' 
    bmi 6f // not digit   
    cmp r0,r6 
    bpl 6f // not digit 
    mul r2,r6 
    add r2,r0
    add r7,#1  
    b 3b
6:  sub r3,#1  // unget last char
    cbz r7, 7f 
    mov r0,#TK_INTGR  
    mov r1,r2 
    b 9f 
7: // not a number 
    mov r3,r1 // restore r3 
    eor r0,r0 // TK_NONE 
9:  ands r0,r0 // to set zero flag 
    pop {r6,r7}
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
      r0    if !Z then converted digit 
      Z     0 true | 1 false  
***************************************/
    _GBL_FUNC is_digit 
    push {r1} 
    eor r1,r1 
    cmp r0,#'0' 
    blt 9f
    cmp r0,'9'+1
    bpl 9f 
    mov r1,#-1
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
      r0     if !Z then converted digit 
      Z      0 true | 1 false         
***************************************/
    _FUNC is_hex 
    push {r1}
    mov r1,#-1 
    cmp r0,#'A' 
    bmi 1f 
    sub r0,#7 
1:  sub r0,#'0'
    bmi 2f 
    cmp r0,#16
    bmi 9f 
2:  eor r1,r1  
9:  ands r1,r1 
    pop {r1}
    _RET 

/***************************************
    is_bit 
    check if char is '0'|'1' 
    convert to binary digit. 
    input:
      r0    
    output:
      r0     if !Z then converted digit 
      Z      0 true | 1 false         
***************************************/
    _FUNC is_bit
    push  {r1}
    mov r1,#-1 
    sub r0,#'0' 
    bmi 2f 
    cmp r1,#2
    bmi 9f 
2:  eor r1,r1 
9:  ands r1,r1 
    pop {r1}
    _RET 

/***************************************
    is_alpha 
    check if character is {A..Z} 
  input:
    r0   character 
  output: 
    r0    same character 
    Z    0 true | 1 false  
****************************************/
    _FUNC is_alpha
    push {r1} 
    mov r1,#-1 
    cmp r0,#'A' 
    blt 8f 
    cmp r0,#'Z'+1 
    bmi 9f 
8:  eor r1,r1  
9:  ands r1,r1 
    pop {r1}
    _RET 

/***************************************
    is_num 
    check if character is {0..9} 
  input:
    r0   character 
  output: 
    r0    same character 
    Z    0 true | 1 false  
****************************************/
    _FUNC is_num 
    push {r1} 
    mov r1,#-1 
    cmp r0,#'0' 
    blt 8f 
    cmp r0,#'9'+1 
    bmi 9f 
8:  eor r1,r1  
9:  ands r1,r1 
    pop {r1}
    _RET 

/*****************************************
    is_alnum 
    check if character is alphanumeric 
    input:
      r0 
    output:
      r0     same 
      Z      1 false | 0 true 
*****************************************/
    _FUNC is_alnum 
    _CALL is_alpha 
    bne 9f 
    _CALL is_num 
9:  _RET 


/*****************************************
    parse_keyword 
    parse work and ckeck if in dictionary 
    input:
      r0    first character 
      r3    tib index 
      t1    tib 
      t2    pad 
    output:
      r3    updated 
      t1    updated 
      t2    updated   
    use:
    
*****************************************/
    _FUNC parse_keyword 
    push {T2}
    ldrb r0,[T1,r3]
    add r3,#1
    cbz r0,2f 
    _CALL upper 
    _CALL is_alpha 
    beq syntax_error 
    strb r0,[T2],#1
1:  ldrb r0,[T1,r3]
    add r3,#1 
    cbz r0,2f 
    _CALL upper 
    _CALL is_alnum
    beq 2f 
    strb r0,[T2],#1
    b 1b 
2:  sub r3,#1
    eor r0,r0
    strb r0,[T2] 
    ldr r0,[sp]
    ldrb r1,[r0,#1] 
    cbnz r1,3f
    ldrb r1,[r0]
    sub r1,#'A'
    mov r0,#TK_VAR
    b 9f 
3:  ldr r1,=kword_dict  
    _CALL search_dict 
    cbnz r0,9f 
    b syntax_error 
9:  pop {T2}
    _RET 


/*******************
    DECOMPILER 
*******************/

/********************************************
    cmd_name 
    search bytecode in dictionary and 
    return its name 
  input:
    r0    keyword bytecode 
  ouput:
    r0    name string 
  use:
    T1    link 
    T2    tmp 
*********************************************/
    _FUNC cmd_name 
    push {T1,T2}
    ldr T1,=kword_dict 
1:  ldr T2,[T1,#-8]
    cmp T2,r0 
    beq 2f 
    ldr T1,[T1,#-12]
    cmp T1,#0
    bne 1b  
2:  mov r0,T1 
    pop {T1,T2}
    _RET

/****************************
  detokenize and print line 
  input:
    BPTR   line address 
  output:
    none:
  use:
    r0,r1 
****************************/
    _FUNC print_basic_line 
    push {r0,r1}
    mov IN,#0
    ldrh r0,[BPTR,IN]
    add IN,#2
    mov r1,#10 
    _CALL print_int
    ldrb r0, [BPTR,IN]
    add IN,#1 
    str r0,[UPP,#COUNT]
token_loop:  
    _CALL next_token
    cmp r0,#TK_NONE 
    beq 9f  
    cmp r0,#TK_INTGR 
    bne 2f 
    mov r0,r1 
    ldr r1,[UPP,#BASE]
    _CALL print_int 
    b token_loop 
2:  cmp r0,#TK_CHAR 
    bne 3f 
    add r0,r1,#'A' 
    _CALL uart_putc
    mov r0,#SPACE 
    _CALL uart_putc
    b token_loop 
3:  cmp r0,#TK_QSTR 
    bne 4f 
    mov r0,#'"'
    _CALL uart_putc 
    mov r0,r1 
    _CALL uart_puts
    mov r0,#'"'
    _CALL uart_putc 
    b token_loop
4:  cmp r0,#TK_CMD
    bmi 5f 
    cmp r0,#TK_INTGR 
    bpl 5f
    mov r0,#SPACE 
    _CALL uart_putc  
    mov r0,r1
    cmp r0,#PRT_IDX 
    bne 1f  
    mov r0,#'?'
    _CALL uart_putc 
    b 3f 
1:  cmp r0,#REM_IDX
    bne 1f
    mov r0,#'\''
    _CALL uart_putc 
    add r0,BPTR,IN  
    _CALL uart_puts 
    ldr IN,[UPP,#COUNT]
    b 9f 
1:  _CALL cmd_name
2:  _CALL uart_puts
3:  mov r0,#SPACE 
    _CALL uart_putc 
    b token_loop
5:  push {r0}
    ldr r1,=single_char 
    ldrb r0,[r1,r0]
    pop {r1}
    cbz r0,6f 
    _CALL uart_putc
    b token_loop
6:  cmp r1,#TK_GE 
    bne 7f 
    ldr r0,=ge_str
    b 2b 
7:  cmp r1,#TK_LE 
    bne 8f
    ldr r0,=le_str
    b 2b
8:  cmp r1,#TK_NE 
    bne 9f 
    ldr r0,=ne_str 
    b 2b 
9:  mov r0,#CR 
    _CALL uart_putc 
    pop {r0,r1}
    _RET 

ge_str: .asciz ">="
le_str: .asciz "<="
ne_str: .asciz "<>"

single_char:
  .byte 0,':',0,0,0,'@','(',')',',','#' // 0..9
  .space 6
  .byte '+','-'
  .space 14
  .byte '*','/','%'
  .space 14
  .byte '>','=',0,'<',0,0


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
    push {r0}
    ldr r0,=rt_error_msg 
    _CALL uart_puts 
    pop {r0}
    ldr r1,=err_msg  
    lsl r0,#2 
    ldr r0,[r1,r0]
    _CALL uart_puts
    ldr BPTR,[UPP,#BASICPTR]
    ldrh r0,[BPTR]
    mov r1,#10
    _CALL print_int 
    mov r0,#',' 
    _CALL uart_putc 
    ldr IN,[UPP,#IN_SAVED]
    _CALL next_token
    push {r1}
    mov r1,#10 
    _CALL print_int 
    mov r0,#',' 
    _CALL uart_putc 
    pop {r0}
    mov r1,#10 
    _CALL print_int 
    b warm_start 
compile_error:
    ldr r1,=err_msg 
    lsl r0,#2 
    ldr r0,[r1,r0]
    _CALL uart_puts
    ldr r0,[UPP,#BASICPTR]
    _CALL uart_puts
    mov r0,#CR 
    _CALL uart_putc  
    ldr r0,[UPP,#IN_SAVED]
    _CALL spaces 
    mov r0,#'^' 
    _CALL uart_putc
    mov r0,#CR 
    _CALL uart_putc   
    b  warm_start  
    
rt_error_msg:
  .asciz "\nRuntime error\n"

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
    mov r0,#CR 
    _CALL uart_putc 
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
    _FUNC warm_start 
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
    mov r0,#CR 
    _CALL uart_putc 
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
  cmp r0,#TK_NONE 
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
  cmp r0,#TK_COLON
  beq interpreter
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
    push {T1}
    eor T1,T1 // TK_NONE 
    ldr r0,[UPP,#COUNT]
    cmp IN,r0 
    bmi 0f
new_line:
    ldrh r1,[BPTR] // line #
    cbnz r1, end_of_line  // command line
    b warm_start
end_of_line:        
    add BPTR,r0 // next line 
    ldr r0,[UPP,#TXTEND]
    cmp BPTR,r0 
    bpl warm_start // end of program
    ldrb r0,[BPTR,#2]
    str r0,[UPP,#COUNT] 
    mov IN,#3
    mov r0,#TK_COLON 
    b 9f    
0: 
    str IN,[UPP,#IN_SAVED]
    str BPTR,[UPP,#BASICPTR]
    ldrb r0,[BPTR,IN] // token attribute
    add IN,#1  
    mov T1,r0 
    and r0,#0x3f // limit mask 
    ldr r1,=tok_jmp 
    tbb [r1,r0]
1: // pc reference point 
    b 9f 
2: // .byte param
    ldrb r1,[BPTR,IN]
    add IN,#1 
    b 9f 
3: // .hword param 
    ldrh r1,[BPTR,IN]
    add IN,#2 
    b 9f 
4: // .word param  
    ldr r1,[BPTR,IN]
    add IN,#4
    b 9f 
5: // .asciz param 
    add r1,BPTR,IN 
    mov r0,r1  
    _CALL strlen 
    add IN,r0
    add IN,#1
    b 9f  
8: // syntax error 
    b syntax_error 
9:  mov r0,T1  
    pop {T1}
    _RET

  .p2align 2
tok_jmp: // token id  tbb offset 
  .byte (9b-1b)/2,(9b-1b)/2   // 0x0..0x1  TK_NONE, TK_COLON
  .byte (5b-1b)/2,(2b-1b)/2,(2b-1b)/2,(9b-1b)/2 // 0x2..0x5 TK_QSTR,TK_CHAR,TK_VAR,TK_ARRAY
  .byte (9b-1b)/2,(9b-1b)/2,(9b-1b)/2,(9b-1b)/2 // 0x6..0x9 TK_LPAREN,TK_RPAREN,TK_COMMA,TK_SHARP 
  .byte (2b-1b)/2,(2b-1b)/2,(2b-1b)/2,(2b-1b)/2 // 0xa..0xd TK_CMD,TK_IFUNC,TK_CHAR,TK_CONST 
  .byte (4b-1b)/2,(8b-1b)/2,(9b-1b)/2,(9b-1b)/2 // 0xe..0x11 TK_INTGR,TK_BAD,TK_PLUS,TK_MINUS  
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2 // 0x12..0x16
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2 //0x17..0x1c
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2 // 0x1d..0x1f
  .byte (9b-1b)/2,(9b-1b)/2,(9b-1b)/2 // 0x20..0x22  TK_MULT,TK_DIV,TK_MOD 
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2 // 0x23..0x2a
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2 // 0x2b..0x30 
  .byte (9b-1b)/2,(9b-1b)/2,(9b-1b)/2,(9b-1b)/2,(9b-1b)/2,(9b-1b)/2 // 0x31..0x36  TK_GT..TK_LE    
  .byte (8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2,(8b-1b)/2 // 0x37..0x3f

  .p2align 2 

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
    cmp R0,#TK_NONE 
    beq 9f 
    cmp r0,#TK_INTGR
    bne 9f 
    _PUSH r1 
    add T1,#1 
    _CALL next_token 
    cmp r0,#TK_COMMA 
    beq 1b 
    _UNGET_TOKEN 
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
    T1   sign 
    T2   exit token attribute 
***********************************/
    _FUNC factor 
    push {r2,T1,T2}
    mov T2,#TK_INTGR 
    mov T1,#1 // default sign +  
    _CALL next_token
    mov r2,r0 
    and r0,#TK_GRP_MASK 
    cmp r0,#TK_GRP_ADD
    mov r0,r2
    bne 1f 
    cmp r0,#TK_PLUS 
    beq 0f 
    mov T1,#-1 // minus sign 
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
    mov T2,r0
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
    mov T2,r0
    mov r2,r1   
    mov r0,#TK_RPAREN
    _CALL expect 
    mov r1,r2 
    b 8f       
3:  cmp r0,#TK_VAR 
    bne 4f
    mov r0,r1  
    _CALL get_var 
    b 8f 
4:  cmp r0,#TK_IFUNC 
    beq 5f 
    cmp r0,#TK_CFUNC 
    bne 6f 
5:  mov r0,r1  
    _CALL execute
    b 8f 
6:  _UNGET_TOKEN      
    mov r0,#TK_NONE
    b 9f  
8:  mul r1,T1 
    movs r0,T2 
9:  pop {r2,T1,T2}   
    _RET 


/*****************************************
    term 
    term parser 
    term ::= factor [['*'|'/'|'%'] factor]* 
    output:
      r0  	token attribute 
      r1		integer
    use:
      r2    first operand 
      r3    temp 
      T1    operator 
      T2    exit token attribute 
******************************************/
     _FUNC term 
    push {r2,r3,T1,T2}
    mov T2,#TK_NONE 
    _CALL factor
    cbz r0, 9f  // no factor   
    mov T2,r0  // TK_INTGR 
    mov r2,r1 // first factor    
0:  _CALL next_token
    mov r3,r0   
    and r0,#TK_GRP_MASK 
    cmp r0,#TK_GRP_MULT
    beq 1f
    _UNGET_TOKEN
    b 9f 
1:  mov T1,r3 
    _CALL factor  
    beq syntax_error 
    cmp T1,#TK_MULT
    bne 2f 
// multiplication
    mul r2,r1
    b 0b  
2:  cmp T1,#TK_DIV 
    bne 3f
// division
    sdiv r2,r2,r1
    b 0b  
3: // modulo
    mov r0,r2 
    sdiv r2,r2,r1 
    mul  r2,r1 
    sub  r2,r0,r2
    b 0b  
9:  mov r1,r2 
    movs r0,T2 
    pop {r2,r3,T1,T2}
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
      r2  left operand 
      T1  operator 
      T2  exit token attribute
******************************************/
    _FUNC expression 
    push {r2,t1,t2}
    mov T2,#TK_NONE
    eor r2,r2 // zero 
    _CALL term 
    beq 9f  // no term  
    mov r2,r1 // first term
    mov T2,#TK_INTGR    
1:  _CALL next_token 
    mov T1,r0 // token attribute 
    and r0,#TK_GRP_MASK 
    cmp r0,#TK_GRP_ADD 
    beq 3f 
    _UNGET_TOKEN
    b 9f  
3:  _CALL term 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    cmp T1,#TK_PLUS 
    beq 4f 
    sub r2,r2,r1 // N1-N2  
    b 1b 
4:  add r2,r2,r1 // N1+N2
    b 1b
9:  mov r0,T2 
    mov r1,r2 
    pop {r2,t1,t2}
    _RET 


/**********************************************
    relation parser 
    rel ::= expr1 rel_op expr2
    rel_op ::=  '=','<','>','>=','<=','<>','><'
    relation return  integer , zero is false 
    output:
        r0	TK_INTGR  
        r1	integer 
    use:
        r2   first operand 
        T1   relop   
**********************************************/
    _FUNC relation 
    push {r2,T1}
    _CALL expression 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    mov r2,r1  // first operand  
    _CALL next_token 
    mov T1,r0  // relop  
    and r0,#TK_GRP_MASK 
    cmp r0,#TK_GRP_RELOP 
    bne 8f  // single operand 
    _CALL expression 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    cmp r2,r1 // compare operands  
    mov r1,#-1 
    ldr r2,=relop_jmp
    and T1,#7 // {1..6}
    tbb [r2,T1]    
rel_idx0:
rel_eq:
    beq 9f 
    b rel_false
rel_lt: 
    blt 9f   
    b rel_false 
rel_le:
    ble 9f  
    b rel_false 
rel_gt:
    bgt 9f  
    b rel_false  
rel_ge:
    bge 9f  
    b rel_false  
rel_diff:
    bne 9f 
rel_false:    
    eor r1,r1  // false
    b 9f  
8:  _UNGET_TOKEN 
    mov r1,r2    
9:  mov r0,#TK_INTGR
    pop {r2,T1}
    _RET 


relop_jmp: 
  .byte 0 
  .byte (rel_gt-rel_idx0)/2 // > 
  .byte 0 // =
  .byte (rel_ge-rel_idx0)/2 // >= 
  .byte (rel_lt-rel_idx0)/2 // <
  .byte (rel_diff-rel_idx0)/2 // <>
  .byte (rel_le-rel_idx0)/2  // <=


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
    ldr r2,[UPP,#VARS]
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
  .word 0 // FFREE
  .word ulast-uzero // TXTBGN
  .word ulast-uzero // TXTEND
  .word 0 //LOOP_DEPTH
  .word 0 // ARRAY_SIZE
  .word 0 // FLAGS
  .word 4 // TAB_WIDTH
  .word 0 // RX_HEAD
  .word 0 // RX_TAIL
  .space RX_QUEUE_SIZE,0 // RX_QUEUE
  .space VARS_SIZE,0 // VARS
  .word _pad  // ARRAY_ADR 
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
  _dict_entry TK_CMD,DUMP,DUMP_IDX // dump 
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
  .word TK_IFUNC
kword_dict: // first name field 
  .equ LINK,. 
  .asciz "ABS" 
  .p2align 2 

    .section .rodata.fn_tabld 

//comands and fonctions address table 	
fn_table:
	.word abs,power_adc,analog_read,bit_and,ascii,autorun,awu,bitmask // 0..7
	.word bit_reset,bit_set,bit_test,bit_toggle,bye,char,const_cr2  // 8..15
	.word const_cr1,skip_line,data_line,const_ddr,dec_base,directory,do_loop,digital_read,digital_write //16..23 
	.word cmd_end,const_eeprom_base,fcpu,for,forget,gosub,goto,gpio // 24..31 
	.word hex_base,const_idr,if,input_var,invert,enable_iwdg,refresh_iwdg,key // 32..39 
	.word let,list,load,log2,lshift,muldiv,next,new // 40..47
	.word func_not,const_odr,bit_or,pad_ref,pause,pin_mode,peek,const_input // 48..55
	.word poke,const_output,print,const_porta,const_portb,const_portc,const_portd,const_porte // 56..63
	.word const_portf,const_portg,const_porth,const_porti,qkey,read,cold_start,skip_line // 64..71 
	.word restore,return, random,rshift,run,save,show,size // 72..79
	.word sleep,spi_read,spi_enable,spi_select,spi_write,step,stop,get_ticks  // 80..87
	.word set_timer,timeout,to,tone,ubound,uflash,until,usr // 88..95
	.word wait,words,write,bit_xor,transmit,receive,dump // 96..102 
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

    _FUNC analog_read
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
    bne syntax_error 
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

    _FUNC bye
    _RET 

    _FUNC char
    _RET 

    _FUNC const_cr2
    _RET  

    _FUNC const_cr1
    _RET 


/**************************
  BASIC: DATALN expr 
  set data pointer to line#
  specified by expr. 
  if line# not valid program 
  end with error.
  use:

**************************/
    _FUNC data_line
    _RTO // run time only 
    _CALL expression 
    cmp r0,#TK_INTGR
    bne syntax_error
    mov r0,r1 
    _CALL search_lineno
    cmp r1,#0
    beq 1f 
0:  mov r0,#ERR_BAD_VALUE
    b syntax_error 
1:  ldrb r1,[r0,#3]
    cmp r1,#TK_CMD 
    bne 0b
    ldrb r1,[r0,#4]
    cmp r1,#DATA_IDX 
    bne 0b  
    str r0,[UPP,#DATAPTR]
    ldrb r1,[r0,#2]
    str r1,[UPP,#DATALEN]
    mov r1,#5 // position of first data item  
    str r1,[UPP,#DATA]
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
1:  ldrb r0,[r1,r2]
    add r2,#1
    cmp r0,#TK_NONE
    beq seek_next
    cmp r0,#TK_COMMA
    beq 1b  
    cmp r0,#TK_INTGR 
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
  BASIC: RESTORE 
  seek first data line 
********************************/
    _FUNC restore
    _RTO 
    ldr r1,[UPP,#TXTBGN]
1:  ldr r0,[UPP,#TXTEND]
    beq no_data_line 
    ldrb r0,[r1,#4]
    cmp r0,#DATA_IDX
    bne try_next_line
    ldrb r0,[r1,#3]
    cmp r0,#TK_CMD
    bne try_next_line
// this a the first data line 
    str r1,[UPP,#DATAPTR]
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

    _FUNC const_ddr
    _RET 

    _FUNC dec_base
    _RET 

    _FUNC directory
    _RET 

    _FUNC do_loop
    _RET 

    _FUNC digital_read
    _RET 

    _FUNC digital_write
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
    push {r2}
    ldr r2,[UPP,#FLAGS]
    tst r2,#FRUN 
    beq 0f
    mov r0,#ERR_CMD_ONLY 
    b tb_error  
0:  _CALL arg_list 
    cmp r0,#2
    bne syntax_error 
    _POP r2   // count 
    _POP  r0  // adr 
1:  mov r1,#16
    _CALL prt_row 
    subs r2,#16 
    bpl 1b 
2:  pop {r2}
    _RET 


/*******************************
  BASIC: END 
  exit program 
******************************/ 
    _FUNC cmd_end
    b warm_start 
    _RET 

    _FUNC const_eeprom_base
    _RET 

    _FUNC fcpu
    _RET 

    _FUNC forget
    _RET 

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
    ldr r0,[UPP,#COUNT]
    stmdb r12!,{r0,IN,BPTR}
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
    ldr r0,[UPP,#COUNT]
    stmia r12, {r0,IN,BPTR}
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
    _DROP 3
  // restore outer loop parameters
    ldmia r12!,{VADR,LIMIT,INCR}
    _RET 
9:  ldmia r12,{r0,IN,BPTR}
    str r0,[UPP,#COUNT]
    _RET 

/*********************************
  BASIC: GOSUB expr 
  call a subroutine at line# 
*********************************/
    _FUNC gosub
    _CALL expression
    cmp r0,#TK_INTGR 
    bne syntax_error 
    mov r0,r1 
    _CALL search_lineno  
    cbz r1,1f 
    mov r0,#ERR_BAD_VALUE 
    b tb_error 
1:  ldr r1,[UPP,#COUNT]
    stmdb r12!,{r1,IN,BPTR}
    mov BPTR,r0 
    mov IN,#3 
    ldrb r0,[BPTR,#2]
    str r0,[UPP,#COUNT]
    _RET 

/**********************************
  BASIC: RETURN 
  leave a subroutine 
*********************************/
    _FUNC return 
    ldmia r12!,{r0,IN,BPTR}
    str r0,[UPP,#COUNT]
    _RET 

/**********************************
  BASIC: GOTO expr 
  go to line # 
  use:

**********************************/
    _FUNC goto
    _CALL expression 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    cbz r1,9f 
1:  mov r0,r1 
    _CALL search_lineno 
    cbz r1,2f 
    mov r0,#ERR_NO_LINE 
    b tb_error 
2:  mov BPTR,r0 
9:  mov IN,#3 
    _RET 

    _FUNC gpio
    _RET  

    _FUNC hex_base
    _RET 

    _FUNC const_idr
    _RET 

/**********************************************
  BASIC: IF relation : statement
  execute statement only if relation is true
*********************************************/
    _FUNC if
    _CALL relation 
    cbnz r1,9f 
    ldr IN,[UPP,#COUNT]
9:  _RET 

    _FUNC input_var
    _RET 

    _FUNC invert
    _RET 

    _FUNC enable_iwdg
    _RET 

    _FUNC refresh_iwdg
    _RET 

    _FUNC key
    _RET  

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
  BASIC: LIST [[first,]last]
  use:
    T1 
**************************************/  
    _FUNC list
    _CLO
    push {T1} 
//  _CALL arg_list 
    ldr BPTR,[UPP,#TXTBGN]
    ldr T1,[UPP,#TXTEND]
1:  cmp BPTR,T1 
    bpl 9f
    mov r0,BPTR  
    _CALL print_basic_line
    ldrb r0,[BPTR,#2]
    add BPTR,r0 
    b 1b
9:  b warm_start 

    _FUNC load
    _RET 

    _FUNC log2
    _RET 

    _FUNC lshift
    _RET 

    _FUNC muldiv
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

    _FUNC const_odr
    _RET 

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

    _FUNC pad_ref
    _RET 

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

    _FUNC pin_mode
    _RET 

    _FUNC peek
    _RET 

    _FUNC const_input
    _RET  

    _FUNC poke
    _RET 

    _FUNC const_output
    _RET 

/****************************
  BASIC: PRINT|? arg_list 
  print list of arguments 
****************************/
    _FUNC print
0:  mov T1,#-1
    _CALL expression
    cmp r0,#TK_INTGR
    bne 1f 
    mov r0,r1
    ldr r1,[UPP,#BASE]
    _CALL print_int
    b 6f 
1:  _CALL next_token
    cmp r0,#TK_COLON 
    bgt 2f
    _UNGET_TOKEN 
    b print_exit
2:  eor T1, T1 
    cmp r0,#TK_QSTR 
    bne 4f
    mov r0,r1 
    _CALL uart_puts  
    b 6f 
4:  cmp r0,#TK_CHAR 
    bne 5f 
    mov r0,r1 
    _CALL uart_putc 
    b 6f 
5:  cmp r0,#TK_SHARP
    bne syntax_error 
    _CALL next_token 
    cmp r0,#TK_INTGR 
    bne syntax_error 
    str r1,[UPP,#TAB_WIDTH]
6:  eor T1,T1 
    _CALL next_token 
    cmp r0,#TK_COMMA 
    beq 0b
    _UNGET_TOKEN 
print_exit:
      ands T1,T1 
      bne 9f
      mov r0,#CR 
      _CALL uart_putc 
  9:  _RET 

    _FUNC const_porta
    _RET 

    _FUNC const_portb
    _RET 

    _FUNC const_portc
    _RET 

    _FUNC const_portd
    _RET 

    _FUNC const_porte
    _RET  

    _FUNC const_portf
    _RET 

    _FUNC const_portg
    _RET 

    _FUNC const_porth
    _RET 

    _FUNC const_porti
    _RET 

    _FUNC qkey
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

    _FUNC rshift
    _RET 

/****************************
  BASIC: RUN 
  execute program in memory
****************************/
    _FUNC run
    _CLO 
    ldr r0,[UPP,#TXTBGN]
    ldr r1,[UPP,#TXTEND]
    cmp r0,r1
    beq 9f 
    ldrb r1,[r0,#2]
    str r1,[UPP,#COUNT]
    mov BPTR,r0 
    mov IN,#3
    // reset dataline pointers 
    eor r0,r0 
    str r0,[UPP,#DATAPTR]
    str r0,[UPP,#DATA]
    str r0,[UPP,#DATALEN] 
    ldr r0,[UPP,#FLAGS]
    orr r0,#FRUN 
    str r0,[UPP,#FLAGS]
9:  _RET 

    _FUNC save
    _RET 

    _FUNC show
    _RET 

    _FUNC size
    _RET  

    _FUNC sleep
    _RET 

    _FUNC spi_read
    _RET 

    _FUNC spi_enable
    _RET 

    _FUNC spi_select
    _RET 

    _FUNC spi_write
    _RET 

    _FUNC stop
    _RET 

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

    _FUNC tone
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
    ldr r0,[UPP,#TXTEND]
    sub r1,r0 
    lsr r1,#2
    mov r0,#TK_INTGR 
    _RET 

    _FUNC uflash
    _RET 

    _FUNC until
    _RET 

    _FUNC usr
    _RET  

    _FUNC wait
    _RET 

/*********************************************
  BASIC: WORDS 
  print list of BASIC WORDS in dictionary 
  use:
    r0,r1,T1,T2  
********************************************/
    _FUNC words
    _CLO 
    ldr T1,=kword_dict
    eor T2,T2 
1:  
    mov r0,T1
    _CALL strlen
    cbz r0,9f 
    add T2,r0 
    cmp T2,#80 
    bmi 2f
    eor T2,T2  
    mov r0,#CR 
    _CALL uart_putc 
2:  mov r0,T1 
    _CALL uart_puts 
    mov r0,#SPACE
    add T2,#1  
    _CALL uart_putc 
    ldr T1,[T1,#-12]
    b 1b 
9:  _RET 

    _FUNC write
    _RET 

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

    _FUNC transmit
    _RET 

    _FUNC receive
    _RET  


/*************************************************
   extra FLASH memory not used by Tiny BASIC
   is used to save BASIC programs.
************************************************/
  .p2align 10  // align to 1KB, smallest erasable segment 
  .section .fs
FILE_SYSTEM: // file system start here
