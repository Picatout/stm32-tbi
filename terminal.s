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
//------------------------------
// This file is for functions 
// interfacing with VT100 terminal
// emulator.
// except for uart_getc and uart_putc which
// are in stm32-tbi.s 
// exported functions:
//   uart_puts 
//   readln 
//   spaces 
//   digit_to_char 
//------------------------------

  .syntax unified
  .cpu cortex-m3
  .fpu softvfp
  .thumb

  .include "stm32f103.inc"
  .include "ascii.inc"
  .include "tbi_macros.inc"


    .section .text, "ax", %progbits 


/*********************************
// receive ANSI ESC 
// sequence and convert it
// to a single character code 
// in range {128..255}
// This is called after receiving 
// ESC character. 
// ignored sequence return 0 
  input:
    none
  output:
    r0    converted character 
  use: 
    r2
***********************************/
    _FUNC get_escape
    push {r2}
    _CALL uart_getc 
    cmp r0,#'[ // this character is expected after ESC 
    beq 1f
0:  eor r0,r0
    pop {r2}
    _RET
1: _CALL  uart_getc 
    ldr r2,=convert_table
2:
    ldrb r1,[r2]
    ands r1,r1 
    beq 0b 
    cmp r0,r1 
    beq 4f
    add r2,#2
    b 2b
4:  add r2,#1  
    ldrb r0,[r2]
    cmp r0,#SUP
    bne 5f
    push {r0}  
    _CALL  uart_getc
    pop {r0}
5:
    pop {r2}
    _RET 

//-----------------------------
//  constants replacing 
//  ANSI sequence received 
//  from terminal.
//  These are the ANSI sequences
//  accepted by function readln
//------------------------------
    .equ ARROW_LEFT,128
    .equ ARROW_RIGHT,129
    .equ HOME,130
    .equ END,131
    .equ SUP,132 

convert_table: .byte 'C',ARROW_RIGHT,'D',ARROW_LEFT,'H',HOME,'F',END,'3',SUP,0,0

/******************************
    uart_puts 
    print zero terminate string 
 
  input:
    r0  *asciz 
  output:
    none 
  use:
    r0  char to send 
    T1  *asciz 
******************************/
    _GBL_FUNC uart_puts 
    push {T1}
    mov T1,r0 
1:  ldrb r0,[T1],#1
    cbz r0,9f 
    _CALL uart_putc 
    b 1b 
9:  pop {T1}
    _RET 

/***********************************
   digit  
   convert least digit of uint32 to ASCII 
    input:
        r0    uint32
        r1    base   
    output:
        r0    r0%base+'0'  
        r1    quotient 
    use:
        T1 
***********************************/
    _FUNC digit
    push {T1}
    push {r0}
    mov T1,r1  
    udiv r0,T1
    mov r1,r0  
    mul  r0,T1 
    pop {T1}
    sub r0,T1,r0
    cmp r0,#10  
    bmi 1f 
    add r0,#7
1:  add r0,#'0'  
    pop {T1}
    _RET 

/**********************************
    itoa 
    convert integer to string
    input:
      r0   integer 
      r1   base 
    output:
      r0   *string 
    use: 
      r7   integer 
      T1   base 
      T2   *pad 
*********************************/ 
    _GBL_FUNC itoa
    push {r7,T1,T2}
    mov r7,r0
    mov T1,r1  
    ldr T2,pad 
    add T2,#PAD_SIZE 
    eor r0,r0 
    strb r0,[T2,#-1]!
    add r0,#SPACE 
    strb r0,[T2,#-1]!
    eor r0,r0 
    cmp T1,#10 
    bne 0f 
    ands r0,r7,#(1<<31)
    beq 0f 
    rsb r7,#0 
0:  push {r0}
1:  mov r0,r7 
    mov r1,T1 
    _CALL digit 
    strb r0,[T2,#-1]!
    ands r1,r1 
    beq  2f   
    mov r7,r1 
    b 1b 
2:  pop {r0} 
    ands r0,r0 
    beq 3f 
    mov r0,#'-'
    strb r0,[T2,#-1]!
3:  cmp T1,#16 
    bne 4f 
    mov r0,#'$' 
    strb r0,[T2,#-1]!
    b 9f 
4:  cmp T1,#2 
    bne 9f 
    mov r0,#'&'
    strb r0,[T1,#-1]!
9:  mov r0,T2 
    pop {r7,T1,T2} 
    _RET  
pad: .word _pad 

/*****************************
    print_int 
  input:
    r0   integer to print 
    r1   conversion base 
  output:
    none 
  use:
    none 
*****************************/
    _GBL_FUNC print_int 
    _CALL itoa
    _CALL uart_puts
    _RET 

/********************************
// print byte  in hexadecimal 
// on console
// input:
//   r0		byte to print
// output:
     none 
   use:
     none 
******************************/
    _GBL_FUNC print_hex
	push {r0} 
  lsr r0,#4  
	_CALL  digit_to_char 
	_CALL  uart_putc 
    pop {r0} 
	_CALL  digit_to_char
	_CALL  uart_putc
	mov r0,#SPACE 
	_CALL  uart_putc  
	_RET 

/***********************************
// convert digit to character  
// input:
//   r0       digit to convert 
// output:
//   r0      hexdecimal character 
   use:
     none 
***********************************/
    _GBL_FUNC digit_to_char 
	and r0,#15 
	cmp r0,#10 
	bmi 1f  
	add r0,#7
1:  add r0,#'0'  
	_RET 


/*****************************
    cursor_shape 
    change cursor shape 

  input:
    r0      shape {0..6}
  output:
    none 
  use:
    T1    shape
*******************************/
    _GBL_FUNC cursor_shape
    push {T1}
    _CALL send_escape
    _CALL send_parameter 
    mov r0,#SPACE 
    _CALL uart_putc 
    mov r0,#'q' 
    _CALL uart_putc 
    pop {T1}
    _RET 


//---------------------------
// delete character at left 
// of cursor on terminal 
// input:
//   none 
// output:
//	none 
//---------------------------
    _FUNC bksp
	mov r0,#BS 
	_CALL  uart_putc 
	mov r0,#SPACE 
	_CALL  uart_putc 
	mov r0,#BS 
	_CALL  uart_putc 
	_RET 

//---------------------------
// delete n character left of cursor 
// at terminal.
// input: 
//   r0   number of characters to delete.
// output:
//    none
// use:
//   r2   count  
//--------------------------	
    _FUNC delete_nchar
	cbz r0,2f 
    push {r2}
    mov r2,r0  
1:	
    _CALL  bksp 
    subs r2,#1 
	bne 1b 
    pop {r2}
2:	_RET


//--------------------------
// send ANSI escape sequence
// ANSI: ESC[
// note: ESC is ASCII 27
//       [   is ASCII 91 
// input:
//      none 
// output:
//      none 
// use:
//      r0 
//-------------------------- 
    _FUNC send_escape
	push {r0}
    mov r0,#ESC 
	_CALL  uart_putc 
	mov r0,#'['
	_CALL  uart_putc 
	pop {r0}
    _RET 


/*****************************
 send ANSI parameter value
 ANSI parameter values are 
 sent as ASCII charater 
 not as binary number.
 this routine 
 convert binary number to 
 ASCII send it.
 input: 
 	r0   parameter  
 output:
   none 
 use:
    T1   digit counter 
***************************/
    _FUNC send_parameter
    push {T1}
    mov T1,#0
1:  mov r1,#10  
    _CALL digit 
    add T1,#1 
    push {r0}
    mov r0,r1 
    ands r0,r0
    bne 1b 
2:  pop {r0}
    _CALL uart_putc  
    subs T1,#1
    bne 2b 
	pop {T1}
    _RET 

/**********************************
// move cursor left n character
// ANSI: ESC[PnD 
// 'Pn' est a numerical parameter
// specifying number of characters 
// displacement.
// input:
//   r0     character count
// output:
//   none
*********************************/
    _FUNC move_left
    cbz r0,9f   
	  _CALL  send_escape
	  _CALL  send_parameter 
	  mov r0,#'D' 
	  _CALL  uart_putc 
9:	_RET	


/***********************************
// move cursor right n character 
// ANSI: ESC[PnC 
// input:
//   r0     character count
// output:
//   none
***********************************/
    _FUNC move_right
    cbz r0,9f 
    _CALL  send_escape
    _CALL  send_parameter 
    mov r0,#'C' 
    _CALL  uart_putc 
9:  _RET 

/*********************************
// print n spaces on terminal
// input:
//  r0 		number of spaces 
// output:
//	none
// use:
     T1    counter  
********************************/
    _GBL_FUNC spaces
	  push {T1}
    cbz r0,9f 
    mov T1,r0 
1:	mov r0,#SPACE 
    _CALL  uart_putc 
    subs T1,#1
    bne 1b 
9:  pop {T1}
  	_RET 


/*********************************
    insert_char 
// insert character in tib  

// input:
//   r0      character to insert 
//   r1      line length
//   T1      insert position 
//   T2      line pointer 
// output:
//   r0       updated insertion point  
**********************************/
   _FUNC insert_char 
/*   
    ld (CHAR,sp),a 
    ld a,xh 
	ld (IPOS,sp),a
    ld a,xl 
    ld (LLEN,sp),a  
    ldw x,y
    incw x 
    ld a,(LLEN,sp)
    sub a,(IPOS,sp)
    inc a 
    ld acc8,a 
    clr acc16
    _CALL  move
    ldw y,#tib 
    ld a,(IPOS,sp)
    ld acc8,a 
    addw y,acc16 
    ld a,(CHAR,sp)
    ld (y),a
    incw y  
    ld a,(IPOS,sp)
    _CALL  move_left
    _MOV32 r0,tib 
    _CALL  uart_puts
    ld a,(LLEN,sp)
    sub a,(IPOS,sp) 
    _CALL  move_left 
*/
	_RET 


/***************************************
// delete character under cursor
// input:
//   R0       line length   
//   R1      delete position
//   T1       line pointer 
**************************************/
    _FUNC delete_under
/*
    ld (LLEN,sp),a 
    ld a,xl 
    ld (CPOS,sp),a 
    ldw x,y // move destination
    incw y  // move source 
    ld a,(LLEN,sp)
    sub a,(CPOS,sp)
    inc a // move including zero at end.
    ld acc8,a 
    clr acc16 
	_CALL  move 
    ldw y,#tib 
    ld a,(CPOS,sp)
    ld acc8,a 
    addw y,acc16 
    ldw x,y 
    _CALL  uart_puts 
    ld a,#SPACE  
    _CALL  uart_putc
    ld a,(LLEN,sp)
    sub a,(CPOS,sp)
    _CALL  move_left 
    dec (LLEN,sp)
*/
	_RET 

/********************************
// send ANSI sequence to delete
// whole line. Cursor position
// is not updated.
// ANSI: ESC[2K
// input:
//   none
// output:
//   none 
   use:
     r0 
********************************/
    _FUNC delete_line
    push {r0}
    _CALL  send_escape
	mov r0,#'2'
	_CALL  uart_putc 
	mov r0,#'K' 
	_CALL  uart_putc
    _CALL  cursor_home 
	pop {r0}
    _RET 

/*************************************
   cursor_x  
   send cursor at column n 
    input: 
        r0  n 
    output:
        none 
    use:
        none 
*************************************/
    _GBL_FUNC cursor_x 
    _CALL send_escape
    _CALL send_parameter
    mov r0,#'G' 
    _CALL uart_putc 
    _RET 

/*************************************
    cursor_home 
    send cursor at left position
  input:
    none 
  output:
    none 
  use:
    r0
*************************************/
    _GBL_FUNC cursor_home 
    push {r0}
    _CALL send_escape
    mov r0,#'G' 
    _CALL uart_putc 
    pop {r0}
    _RET 

/************************************
    delete_right 
    send ANSI code to delete from 
    cursor to end of line 
************************************/
    _FUNC delete_right 
    _CALL send_escape 
    mov r0,#'0'
    _CALL uart_putc 
    mov r0,#'K'
    _CALL uart_putc 
    _RET 

/************************************
   update_line 
   update edited line on display 
   input:
     r0    *line 
   output:
     none 
   use:
      none 
*************************************/
    _FUNC update_line 
    push {r0}
    mov r0,r3 
    _CALL cursor_x
    _CALL delete_right
    pop {r0} 
    _CALL uart_puts
    _RET 

/*************************************
  readln 
  read a line of text from terminal
  CTRL_D delete line
  CTRL_E edit line#  
  CTRL_R edit last entered line
  CTRL_O toggle between overwrite|insert   
  LEFT_ARROW move cursor left 
  RIGHT_ARROW move cursor right
  HOME cursor at start of line 
  END  cursor at end of line  
  BS  delete character left of cursor
  DEL delete character at cursor    
  input:
    r0  *buffer
    r1  buffer size 
  output:
    r0  *buffer (asciz)  
    r1  line length  
  use:
    r2  cmove count
    r3  line start colon  
    r5 line length 
    r6 *buffer   
    r7  cursor position 
    T1  ovwr|insert flag 
    T2  buffer size -1 
*************************************/
  _GBL_FUNC readln
  push {r2,r3,r5,r6,r7,T1,T2}
  eor r7,r7  // cursor position 
  eor T1,T1 // overwrite mode 
  mov r6,r0 // *buffer 
  sub T2,r1,#1  // buffer size -1
  eor r5,r5  // line length 
  eor r0,r0 // blinking block shape
  _CALL cursor_shape
  _CALL get_curpos
  mov r3,r1 
readln_loop:
  eor r0,r0
  strb r0,[r6,r5]  
  _CALL uart_getc 
  cmp r0,#CR
  bne 0f
  b readln_exit 
0:
  cmp r0,#BS 
  bne 2f 
//delete char. left  
  ands r7,r7 
  beq readln_loop 
  cmp r7,r5 
  beq 1f
// in middle of line 
  add r0,r6,r7 
  sub r1,r0,#1 
  sub r2,r5,r7 
  _CALL cmove
  sub r5,#1 //line length 
  sub r7,#1 // cursor position
  eor r0,r0
  strb r0,[r6,r5] 
  mov r0,r6
  _CALL update_line 
  add r0,r7,r3
  _CALL cursor_x 
  b readln_loop       
1: // at end of line 
  _CALL bksp 
  sub r7,#1
  sub r5,#1
  b readln_loop 
2: cmp r0,#CTRL_D 
   bne 3f 
// delete whole line  
  _CALL delete_line  
  eor r7,r7   
  eor r5,r5
  b readln_loop 
3: cmp r0,#CTRL_E 
  bne 3f 
  mov r0,r6 // buffer 
  mov r1,#10  
  _CALL atoi
  cmp r0,#0 
  beq readln_loop 
  mov r0,r1 // line# 
  _CALL search_lineno 
  cmp r1,#0 // not found 
  bne readln_loop 
  mov r1,r6 
  _CALL decompile_line
  _CALL strlen 
  mov r7,r0 
  mov r5,r0
  mov r0,r6
  _CALL update_line
  add r0,r3,r7 
  add r0,#1  
  b readln_loop   
3: cmp r0,#CTRL_R    
  bne 4f 
// edit last entered line if  available 
  ands r5,r5 
  bne readln_loop
  mov r0,r6 
  _CALL strlen
  mov r5,r0
  mov r7,r0 
  mov r0,r6  
  _CALL uart_puts
  b readln_loop     
4: cmp r0,#CTRL_O 
   bne 5f 
   rsb T1,#5  
   mov r0,T1 
   _CALL cursor_shape
   b readln_loop 
5: cmp r0,#ESC 
   bne character  
   _CALL get_escape
   cmp r0,#HOME 
   bne try_end
   mov r0,r7 
   _call move_left 
   eor r7,r7  
   b readln_loop 
try_end:
   cmp r0,#END 
   bne try_left 
   sub r0,r5,r7  
   _CALL move_right  
   mov r7,r5 
   b readln_loop 
try_left: 
   cmp r0,#ARROW_LEFT
   bne try_right 
   ands r7,r7 
   beq readln_loop
   mov r0,#1 
   _CALL move_left 
   sub r7,#1
   b readln_loop
try_right:
   cmp r0,#ARROW_RIGHT 
   bne try_suprim 
   cmp r7,r5
   beq readln_loop
   add r7,#1
   mov r0,#1  
   _CALL move_right  
   b readln_loop 
try_suprim:
   cmp r0,#SUP
   bne readln_loop 
// delete character at cursor 
   cmp r7,r5
   beq readln_loop 
   add r1,r7,r6 
   add r0,r1,#1 
   sub r2,r5,r7
   _CALL cmove 
   sub r5,#1 
   eor r0,r0 
   strb r0,[r6,r5]
   mov r0,r6 
   _CALL update_line
   add  r0,r7,r3 
   _CALL cursor_x 
   b readln_loop      
character:
   cmp r7,r5 
   beq 5f // cursor at eol 
// cursor in middle of line 
// action depend on edit mode 
  ands T1,T1  //check edit mode 
  beq 2f 
// insert mode
  cmp T2,r5 
  beq readln_loop // buffer full  
  push {r0,r2}
  add r0,r6,r7  // src 
  add r1,r0,#1   // dest 
  sub r2,r5,r7  // move count 
  _CALL cmove   
  pop {r0,r2}
  strb r0,[r6,r7] 
  add r5,#1 
  eor r0,r0 
  strb r0,[r6,r5]
  mov r0,r6   
  _CALL update_line
  add r7,#1
  add r0,r7,r3 
  _CALL cursor_x  
  b readln_loop   
2: // overwrite mode 
  strb r0,[r6,r7]
  mov r0,r6 
  _CALL update_line 
  add r7,#1
  add r0,r7,r3
  _CALL cursor_x 
  b readln_loop 
5: // cursor at eol, mode doesn't matter 
   cmp r10,T2 
   bmi 6f 
   b readln_loop  // buffer full
6: // only accept char>=32  
   cmp r0,#SPACE 
   bmi readln_loop 
   strb r0,[r6,r7] 
   _CALL uart_putc
   add r7,#1
   mov r5,r7
   b readln_loop  
readln_exit:
  _CALL uart_putc 
  eor r0,r0 
  strb r0,[r6,r5]
  mov r1,r5  // line length
  mov r0,r6  // *buffer  
  pop {r2,r3,r5,r6,r7,T1,T2}
  _RET 


/*******************************
    get_param 
    read ANSI parameter 
    input:
      none 
    output:
      r0   value 
    use:
      T1   temp
      T2   base 10  
*******************************/
    _FUNC get_param
    push {T1,T2}
    eor T1,T1 
    mov T2,#10 
1:  _CALL uart_getc
    _CALL is_digit 
    bne 9f 
    mul T1,T2 
    add T1,r0 
    b 1b
9: 
    mov r0,T1     
    pop {T1,T2}
    _RET 

/*******************************
    get_curpos 
    report cursor position 
  input:
    none 
  output:
    r0    row 
    r1    column
  use:
    r2
    r3 
*******************************/
    _GBL_FUNC get_curpos 
    push {r2,r3}   
    _CALL uart_flush_queue 
    _CALL send_escape 
    mov r0,#'6'
    _CALL uart_putc
    mov r0,#'n'
    _CALL uart_putc  
    _CALL uart_getc 
    cmp r0,#ESC 
    bne 9f 
    _CALL uart_getc 
    cmp r0,#'[' 
    bne 9f 
    _CALL get_param 
    mov r2,r0 
    _CALL get_param 
    mov r1,r0 
    mov r0,r2 
9:  pop {r2,r3}
    _RET 

/***********************************
    tabulation 
    set cursor column to next 
    tabulation stop    
**********************************/
    _GBL_FUNC tabulation 
    push {r0,r1,r2}
    _CALL get_curpos 
    sub r0,r1,#1
    push {r1} 
    ldr r1,[UPP,#TAB_WIDTH]
    _CALL modulo
    ldr r0,[UPP,#TAB_WIDTH]
    sub r0,r1
    pop {r1}
    add r1,r0
    cmp r1,#80
    bge 2f  
    _CALL spaces
    b 9f 
2: _CALL cr 
9:  pop {r0,r1,r2}
    _RET 

/********************************
    cr 
    send a carriage return 
    to terminal 
********************************/ 
    _GBL_FUNC cr 
    mov r0,#CR 
    _CALL uart_putc 
    _RET
