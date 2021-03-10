//---------------------------------------------------------------------  
//  Copyright Jacques Deschênes 2021
//  This file is part of stm32-tbi 
// 
//   stm32-tbi is free software: you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation, either version 3 of the License, or
//   (at your option) any later version.
// 
//   stm32-tbi is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY//  without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
// 
//   You should have received a copy of the GNU General Public License
//   along with stm32-tbi.  If not, see <http://www.gnu.org/licenses/>.
// 
// ----------------------------------------------------------------------

// ---------------------------------------
//  BASIC command and functions indexes
//  for addressing 'code_addr' table
// --------------------------------------

    .equ ABS_IDX, 0  //  absolute function
    .equ ANA_IDX,ABS_IDX+1
    .equ ADC_IDX,ANA_IDX+1
    .equ AND_IDX,ADC_IDX+1 // 
    .equ ASC_IDX,AND_IDX+1  // 
    .equ AUTORUN_IDX,ASC_IDX+1
    .equ AWU_IDX,AUTORUN_IDX+1 //
    .equ BIT_IDX,AWU_IDX+1 //
    .equ BRES_IDX,BIT_IDX+1 // 
    .equ BSET_IDX,BRES_IDX+1 // 
    .equ BTEST_IDX,BSET_IDX+1 // 
    .equ BTOGL_IDX,BTEST_IDX+1 // 
    .equ CHAR_IDX,BTOGL_IDX+1 // 
    .equ CLS_IDX,CHAR_IDX+1 //
    .equ CONST_IDX,CLS_IDX+1 //
    .equ DATA_IDX,CONST_IDX+1 // 
    .equ DEC_IDX,DATA_IDX+1 // 
    .equ DIR_IDX,DEC_IDX+1 // 
    .equ DO_IDX,DIR_IDX+1 // 
    .equ DROP_IDX,DO_IDX+1
    .equ DUMP_IDX, DROP_IDX+1 
    .equ END_IDX,DUMP_IDX+1 // 
    .equ ERASE_IDX,END_IDX+1 
    .equ FOR_IDX, ERASE_IDX+1 // 
    .equ FORGET_IDX, FOR_IDX+1 // 
    .equ FREE_IDX, FORGET_IDX+1 // 
    .equ GET_IDX,FREE_IDX+1
    .equ GOSUB_IDX, GET_IDX+1 // 
    .equ GOTO_IDX, GOSUB_IDX+1 //
    .equ HEX_IDX, GOTO_IDX+1 // 
    .equ IF_IDX, HEX_IDX+1 // 
    .equ IN_IDX,IF_IDX+1
    .equ INPUT_IDX, IN_IDX+1 // 
    .equ INVERT_IDX, INPUT_IDX+1 // 
    .equ KEY_IDX, INVERT_IDX+1 // 
    .equ LET_IDX, KEY_IDX+1 // 
    .equ LIST_IDX, LET_IDX+1 // 
    .equ LOAD_IDX, LIST_IDX+1 // 
    .equ LOCATE_IDX,LOAD_IDX+1 //
    .equ LSHIFT_IDX, LOCATE_IDX+1 // 
    .equ NEW_IDX, LSHIFT_IDX+1 // 
    .equ NEXT_IDX, NEW_IDX+1 // 
    .equ NOT_IDX, NEXT_IDX+1 // 
    .equ OR_IDX, NOT_IDX+1 // 
    .equ OUT_IDX,OR_IDX+1
    .equ PAD_IDX, OUT_IDX+1 // 
    .equ PAUSE_IDX, PAD_IDX+1 // 
    .equ PMODE_IDX, PAUSE_IDX+1 // 
    .equ PEEK8_IDX, PMODE_IDX+1 //
    .equ PEEK16_IDX,  PEEK8_IDX+1
    .equ PEEK32_IDX, PEEK16_IDX+1
    .equ POKE8_IDX, PEEK32_IDX+1 // 
    .equ POKE16_IDX,POKE8_IDX+1 
    .equ POKE32_IDX,POKE16_IDX+1
    .equ POP_IDX,POKE32_IDX+1
    .equ PRT_IDX, POP_IDX+1 //  //  PRINT commande index 
    .equ PUSH_IDX,PRT_IDX+1
    .equ PUT_IDX,PUSH_IDX+1
    .equ QKEY_IDX, PUT_IDX+1 // 
    .equ READ_IDX, QKEY_IDX+1 // 
    .equ REM_IDX, READ_IDX+1  //  REMARK command index 
    .equ REST_IDX, REM_IDX+1 //  RESTORE
    .equ RET_IDX, REST_IDX+1   //  RETURN 
    .equ RND_IDX, RET_IDX+1  //  RANDOM 
    .equ RSHIFT_IDX, RND_IDX+1 // 
    .equ RUN_IDX, RSHIFT_IDX+1 // 
    .equ SAVE_IDX, RUN_IDX+1 // 
    .equ SERVO_INIT_IDX,SAVE_IDX+1
    .equ SERVO_OFF_IDX,SERVO_INIT_IDX+1
    .equ SERVO_POS_IDX,SERVO_OFF_IDX+1
    .equ SLEEP_IDX, SERVO_POS_IDX+1 // 
    .equ SPC_IDX,SLEEP_IDX+1 //
    .equ STEP_IDX, SPC_IDX+1 // 
    .equ STOP_IDX, STEP_IDX+1 // 
    .equ STORE_IDX,STOP_IDX+1
    .equ TAB_IDX, STORE_IDX+1 //
    .equ THEN_IDX,TAB_IDX+1
    .equ TICKS_IDX, THEN_IDX+1 // 
    .equ TIMER_IDX, TICKS_IDX+1 // 
    .equ TMROUT_IDX, TIMER_IDX+1   //  TIMEOUT
    .equ TO_IDX, TMROUT_IDX+1 // 
    .equ TONE_IDX,TO_IDX+1
    .equ TONE_INIT_IDX,TONE_IDX+1 
    .equ TRACE_IDX,TONE_INIT_IDX+1
    .equ UBOUND_IDX, TRACE_IDX+1 // 
    .equ UFLASH_IDX, UBOUND_IDX+1 // 
    .equ UNTIL_IDX, UFLASH_IDX+1 // 
    .equ WAIT_IDX, UNTIL_IDX+1 // 
    .equ WORDS_IDX, WAIT_IDX+1 // 
    .equ XOR_IDX, WORDS_IDX+1 //
    .equ XPOS_IDX,XOR_IDX+1 //
    .equ YPOS_IDX,XPOS_IDX+1 // 

    