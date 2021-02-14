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
    .equ ADCON_IDX, 1 // <<1   //   adc on 
    .equ ADCREAD_IDX, 2 // <<1
    .equ AND_IDX, 3 // <<1.equ  // 
    .equ ASC_IDX, 4 // <<1.equ  // 
    .equ AUTORUN_IDX, 5 // <<1
    .equ AWU_IDX, 6 // <<1
    .equ BIT_IDX, 7 // <<1
    .equ BRES_IDX, 8 // <<1
    .equ BSET_IDX, 9 // <<1
    .equ BTEST_IDX, 10 // <<1
    .equ BTOGL_IDX, 11 // <<1
    .equ BYE_IDX, 12 // <<1
    .equ CHAR_IDX, 13 // <<1
    .equ CRH_IDX, 14 // <<1
    .equ CRL_IDX, 15 // <<1
    .equ DATA_IDX, 16 // <<1
    .equ DATALN_IDX, 17 // <<1
    .equ DDR_IDX, 18 // <<1
    .equ DEC_IDX, 19 // <<1
    .equ DIR_IDX, 20 // <<1
    .equ DO_IDX, 21 // <<1
    .equ DREAD_IDX, 22 // <<1
    .equ DWRITE_IDX, 23 // <<1
    .equ END_IDX, 24 // <<1
    .equ EEPROM_IDX, 25 // <<1
    .equ FCPU_IDX, 26 // <<1
    .equ FOR_IDX, 27 // <<1
    .equ FORGET_IDX, 28 // <<1
    .equ GOSUB_IDX, 29 // <<1
    .equ GOTO_IDX, 30 // <<1
    .equ GPIO_IDX, 31 // <<1
    .equ HEX_IDX, 32 // <<1
    .equ IDR_IDX, 33 // <<1
    .equ IF_IDX, 34 // <<1
    .equ INPUT_IDX, 35 // <<1
    .equ INVERT_IDX, 36 // <<1
    .equ IWDGEN_IDX, 37 // <<1
    .equ IWDGREF_IDX, 38 // <<1
    .equ KEY_IDX, 39 // <<1
    .equ LET_IDX, 40 // <<1
    .equ LIST_IDX, 41 // <<1
    .equ LOAD_IDX, 42 // <<1
    .equ LOG2_IDX, 43 // <<1
    .equ LSHIFT_IDX, 44 // <<1
    .equ NEXT_IDX, 45 // <<1
    .equ NEW_IDX, 46 // <<1
    .equ NOT_IDX, 47 // <<1
    .equ ODR_IDX, 48 // <<1
    .equ OR_IDX, 49 // <<1
    .equ PAD_IDX, 50 // <<1
    .equ PAUSE_IDX, 51 // <<1
    .equ PMODE_IDX, 52 // <<1
    .equ PEEK_IDX, 53 // <<1
    .equ PINP_IDX, 54 // <<1
    .equ POKE_IDX, 55 // <<1
    .equ POUT_IDX, 56 // <<1
    .equ PRT_IDX, 57 // <<1 //  PRINT commande index 
    .equ PRTA_IDX, 58 // <<1
    .equ PRTB_IDX, 59 // <<1
    .equ PRTC_IDX, 60 // <<1
    .equ PRTD_IDX, 61 // <<1
    .equ PRTE_IDX, 62 // <<1
    .equ PRTF_IDX, 63 // <<1
    .equ PRTG_IDX, 64 // <<1
    .equ PRTH_IDX, 65 // <<1
    .equ PRTI_IDX, 66 // <<1
    .equ QKEY_IDX, 67 // <<1
    .equ READ_IDX, 68 // <<1
    .equ RBT_IDX, 69 // <<1  //  REBOOT
    .equ REM_IDX, 70 // <<1 //  REMARK command index 
    .equ REST_IDX, 71 // <<1 //  RESTORE
    .equ RET_IDX, 72 // <<1  //  RETURN 
    .equ RND_IDX, 73 // <<1 //  RANDOM 
    .equ RSHIFT_IDX, 74 // <<1
    .equ RUN_IDX, 75 // <<1
    .equ SAVE_IDX, 76 // <<1
    .equ SHOW_IDX, 77 // <<1
    .equ SIZE_IDX, 78 // <<1
    .equ SLEEP_IDX, 79 // <<1
    .equ SPIRD_IDX, 80 // <<1
    .equ SPIEN_IDX, 81 // <<1
    .equ SPISEL_IDX, 82 // <<1
    .equ SPIWR_IDX, 83 // <<1
    .equ STEP_IDX, 84 // <<1
    .equ STOP_IDX, 85 // <<1
    .equ TICKS_IDX, 86 // <<1
    .equ TIMER_IDX, 87 // <<1
    .equ TMROUT_IDX, 88 // <<1  //  TIMEOUT
    .equ TO_IDX, 89 // <<1
    .equ TONE_IDX, 90 // <<1
    .equ UBOUND_IDX, 91 // <<1
    .equ UFLASH_IDX, 92 // <<1
    .equ UNTIL_IDX, 93 // <<1
    .equ USR_IDX, 94 // <<1
    .equ WAIT_IDX, 95 // <<1
    .equ WORDS_IDX, 96 // <<1
    .equ WRITE_IDX, 97 // <<1
    .equ XOR_IDX, 98 // <<1 
    .equ XTRMT_IDX, 99 // <<1
    .equ XRCV_IDX, 100 // <<1
    .equ DUMP_IDX, 101 
    .equ THEN_IDX,102
    