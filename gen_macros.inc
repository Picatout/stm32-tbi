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

    // reserve space on stack
    // for local variables
    .macro _vars n 
    sub sp,sp,#n 
    .endm 
    
    // free space on stack
    .macro _drop n 
    add sp,sp,#n 
    .endm

    // declare ARG_OFS for arguments 
    // displacement on stack. This 
    // value depend on local variables 
    // size.
    .macro _argofs n 
    ARG_OFS=4+n 
    .endm 

    // declare a function argument 
    // position relative to stack pointer 
    // _argofs must be called before it.
    .macro _arg name ofs 
    name=ARG_OFS+ofs 
    .endm 
