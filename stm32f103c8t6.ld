/* memory regions */
MEMORY
{
FLASH (rx)     : ORIGIN = 0x08000000, LENGTH = 64K
RAM (xrw)      : ORIGIN = 0x20000000, LENGTH = 20K
}

ENTRY(reset_handler)

_mstack_size = 0x100; /* main stack size used by exceptions and interrupts */
_mstack = 0x20005000; /* main stack top */
_tib_size = 0x50 ; /* tib buffer size */
_tib = _mstack - _mstack_size - _tib_size ; /* transaction input buffer */
_pad_size = 0x80 ; 
_pad = _tib - _pad_size ;
_array = _tib - 4 ;


SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >FLASH

  /* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */


    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >FLASH

  .  = ALIGN(4);        

  .rodata : 
  {
    . = ALIGN(4)  ;
    KEEP(*(.data))
    _sdata = . ;
    __data_start = _sdata ;
      *(.data)      /* Data memory */
    . = ALIGN(4) ;
    _edata = . ;
    _data_size = _edata - _sdata ;
  } >FLASH  

  . = ALIGN(10);
  .fs : 
  {
    KEEP(*(.fs))   
  } > FLASH 

  .bss :
  {
      . = ALIGN(4) ;
      _sbss = . ;
      __bss_start__ = _sbss;
      *(.bss)       /* Zero-filled run time allocate data memory */
      . = ALIGN(4) ;
      _ebss = . ;
      _bss_size = _ebss - _sbss ;  
  } >RAM

}  
