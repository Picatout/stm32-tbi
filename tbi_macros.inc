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
.equ TAB_WIDTH,4 // default tabulation width 
.equ EOF,0xff // end of file marker 
// keyword types 
.equ F_CMD,0x20     // command keyword
.equ F_IFUNC,0x40 // integer function keyword
.equ F_CFUNC,0x80 // character function keyword
.equ F_CONST,0xC0 // function keyword that return a constant

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
.equ TK_CMD,128      // BASIC command   
.equ TK_IFUNC,129    // BASIC integer function
.equ TK_CFUNC,130    // BASIC character function
.equ TK_CONST,131    // BASIC constant 
.equ TK_INTGR,132
.equ TK_VAR,133
.equ TK_NONE,0       // not a token 
.equ TK_COLON,1      // command separator ':' 
.equ TK_QSTR,2     // quoted string  
.equ TK_CHAR,3       // ASCII character 
.equ TK_ARRAY,6     // array variable '@' 
.equ TK_LPAREN,7     // left parenthesis '('
.equ TK_RPAREN,8     // right parenthesis ')'
.equ TK_COMMA,9     // item separator ',' 
.equ TK_SHARP,0xa     // print colon width '#' 
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
.equ TK_EQUAL,0x32   // assignment or relation operator ','
.equ TK_GE,0x33      // relation operator '>,'
.equ TK_LT,0x34      // relation operator '<'
.equ TK_LE,0x36      // relation operator '<,'
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

