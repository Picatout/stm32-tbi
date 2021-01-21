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

//-------------------------------------------------------
//     ASCII control  values
//     CTRL_x   are VT100 keyboard values  
// REF: https://en.wikipedia.org/wiki/ASCII    
//-------------------------------------------------------
	.equ CTRL_A ,  1
	.equ SOH, CTRL_A  // start of heading 
	.equ CTRL_B ,  2
	.equ STX, CTRL_B  // start of text 
	.equ CTRL_C ,  3
	.equ ETX, CTRL_C  // end of text 
	.equ CTRL_D ,  4
	.equ EOT, CTRL_D  // end of transmission 
	.equ CTRL_E ,  5
	.equ ENQ, CTRL_E  // enquery 
	.equ CTRL_F ,  6
	.equ ACK, CTRL_F  // acknowledge
	.equ CTRL_G ,  7
	.equ BELL ,  7    // vt100 terminal generate a sound.
	.equ CTRL_H ,  8  
	.equ BS ,  8     // back space 
	.equ CTRL_I ,  9
	.equ TAB ,  9     // horizontal tabulation
	.equ CTRL_J ,  10 
	.equ LF ,  10     // line feed
	.equ CTRL_K ,  11
	.equ VT ,  11     // vertical tabulation 
	.equ CTRL_L ,  12
	.equ FF ,  12      // new page
	.equ CTRL_M ,  13
	.equ CR ,  13      // carriage return 
	.equ CTRL_N ,  14
	.equ SO, CTRL_N    // shift out 
	.equ CTRL_O ,  15
	.equ SI, CTRL_O    // shift in 
	.equ CTRL_P ,  16
	.equ DLE, CTRL_P   // data link escape 
	.equ CTRL_Q ,  17
	.equ DC1, CTRL_Q   // device control 1 
	.equ XON, DC1 
	.equ CTRL_R ,  18
	.equ DC2, CTRL_R   // device control 2 
	.equ CTRL_S ,  19
	.equ DC3, CTRL_S   // device control 3
	.equ XOFF, DC3 
	.equ CTRL_T ,  20
	.equ DC4, CTRL_T   // device control 4 
	.equ CTRL_U ,  21
	.equ NAK, CTRL_U   // negative acknowledge
	.equ CTRL_V ,  22
	.equ SYN, CTRL_V   // synchronous idle 
	.equ CTRL_W ,  23
	.equ ETB, CTRL_W   // end of transmission block
	.equ CTRL_X ,  24
	.equ CAN, CTRL_X   // cancel 
	.equ CTRL_Y ,  25
	.equ EM, CTRL_Y    // end of medium
	.equ CTRL_Z ,  26
	.equ SUB, CTRL_Z   // substitute 
	.equ EOF, SUB      // end of text file in MSDOS 
	.equ ESC ,  27     // escape 
	.equ FS, 28        // file separator 
	.equ GS, 29        // group separator 
	.equ RS, 30  // record separator 
	.equ US, 31  // unit separator 
	.equ SPACE ,  32
	.equ COMMA ,  44 
	.equ SHARP ,  35
	.equ TICK ,  39
