/*
   STM32F103 registers
*/
    /* RAM */
    .equ RAM_ADR, 0x20000000 
    .equ RAM_SIZE, 0x5000
    .equ RAM_END, RAM_ADR+RAM_SIZE

   /* RAM bit band alias */
      .equ RAM_BIT_ALIAS, 0x22000000

    /* FLASH MEMORY */
    /* memory reported by MCU */
    .equ FLASH_ADR, 0x8000000 
    .equ FLASH_SIZE, 0x10000
    .equ FLASH_END, FLASH_ADR+FLASH_SIZE
    /* the MCU as 64K flash not reported by MCU */
    .equ FLASH_HIDDEN_ADR, 0x8010000
    .equ FLASH_HIDDEN_SIZE, 0x10000
    .equ FLASH_HIDDEN_END, FLASH_HIDDEN_ADR+FLASH_HIDDEN_SIZE
    .equ PAGE_SIZE, 1024 // erase block size 

   /* system memory */
      .equ SYS_MEM, 0x1FFFF000
      .equ SYS_MEM_SIZE, 0x800

   /* option memory */
      .equ OPTION, 0x1FFFF800   
      .equ OPT_SIZE, 16


   /* peripherals base address */
      .equ PER_BASE_ADR,  0x40000000
   /* PERIPHERALS bit band alias */
      .equ PER_BIT_ALIAS, 0x42000000 


    /* RCC registers address */
    .equ RCC_BASE_ADR, 0x40021000
    /* RCC registers offset */
    .equ RCC_CR, 0
    .equ RCC_CFGR, 4
    .equ RCC_CIR, 8
    .equ RCC_APB2RSTR, 12
    .equ RCC_APB1RSTR, 16
    .equ RCC_AHBENR, 20
    .equ RCC_APB2ENR, 24
    .equ RCC_APB1ENR, 28
    .equ RCC_BDCR, 32 
    .equ RCC_CSR, 36

    /* FLASH registers address */
    .equ FLASH_BASE_ADR, 0x40022000
    /* FLASH registers offset */
    .equ FLASH_ACR, 0
    .equ FLASH_KEYR, 4
    .equ FLASH_OPTKEYR, 8
    .equ FLASH_SR, 12
    .equ FLASH_CR, 16
    .equ FLASH_AR, 20
    .equ FLASH_OBR, 28
    .equ FLASH_WRPR,32
    .equ RDPRT_KEY, 0x00A5
    .equ FLASH_KEY1, 0x45670123
    .equ FLASH_KEY2, 0xCDEF89AB

    /* GPIOx base address */
    .equ GPIOA_BASE_ADR, 0x40010800
    .equ GPIOB_BASE_ADR, 0x40010C00
    .equ GPIOC_BASE_ADR, 0x40011000
    .equ GPIOD_BASE_ADR, 0x40011400
    .equ GPIOE_BASE_ADR, 0x40011800
    .equ GPIOF_BASE_ADR, 0x40018C00
    .equ GPIOG_BASE_ADR, 0x40012000

    /* gpiox registers offset from base address */
    .equ GPIO_CRL, 0
    .equ GPIO_CRH, 4
    .equ GPIO_IDR, 8
    .equ GPIO_ODR, 12
    .equ GPIO_BSRR, 16
    .equ GPIO_BRR, 20
    .equ GPIO_LCKR, 24 
    
   /* GPIO input|output CNF|MODE values */
   .equ OUTPUT_PP,1
   .equ OUTPUT_OD,6
   .equ OUTPUT_AFPP,0xa 
   .equ OUTPUT_AFOD,0xe
   .equ INPUT_ANA,0
   .equ INPUT_FLOAT,4
   .equ INPUT_PD,16 
   .equ INPUT_PU,17   

   /* AFIO base address */
   .equ AFIO_BASE_ADR, 0x40010000
   
   /* AFIO registers offset */
   .equ AFIO_EVCR,0
   .equ AFIO_MAPR,4
   .equ AFIO_EXTICR1,8
   .equ AFIO_EXTICR2,12 
   .equ AFIO_EXTICR3,16
   .equ AFIO_EXTICR4,20
   .equ AFIO_MAPR2,28
   
    /* USART1 registers */
    .equ USART1_BASE_ADR, 0x40013800
    /* USARTx registers offset */
    .equ USART_SR, 0
    .equ USART_DR,4
    .equ USART_BRR,8
    .equ USART_CR1,12
    .equ USART_CR2,16
    .equ USART_CR3,20
    .equ USART_GTPR,24

   /* systick */
    .equ STK_BASE_ADR, 0xE000E010
    /* registers offset */
    .equ STK_CTL, 0
    .equ STK_LOAD, 4
    .equ STK_VAL, 8
    .equ STK_CALIB, 12

   /* system control block */
   .equ SCB_BASE_ADR, 0xE000ED00
   /* registers offset */
   .equ SCB_CPUID, 0
   .equ SCB_ICSR, 4 
   .equ SCB_VTOR, 8
   .equ SCB_AIRCR, 12
   .equ SCB_SCR, 16
   .equ SCB_CCR, 20
   .equ SCB_SHPR1,24
   .equ SCB_SHPR2,28
   .equ SCB_SHPR3,32
   .equ SCB_SHCRS,36
   .equ SCB_CFSR,40
   .equ SCB_HFSR,44
   .equ SCB_MMAR,52
   .equ SCB_BFAR,56
   // key to to write in SCB_AIRCR 
   .equ SCB_VECTKEY,0x5fa 
   
   /* NVIC block */
   .equ NVIC_BASE_ADR, 0xE000E100
   .equ NVIC_ISER0, 0
   .equ NVIC_ISER1, 4
   .equ NVIC_ISER2, 8
   .equ NVIC_ICER0, 0x80
   .equ NVIC_ICER1, 0x84 
   .equ NVIC_ICER2, 0x88 
   .equ NVIC_ISPR0, 0x100
   .equ NVIC_ISPR1, 0x104
   .equ NVIC_ISPR2, 0x108 
   .equ NVIC_ICPR0, 0x180
   .equ NVIC_ICPR1, 0x184
   .equ NVIC_ICPR2, 0x188
   .equ NVIC_IABR0, 0x200
   .equ NVIC_IABR1, 0x204
   .equ NVIC_IABR2, 0x208
   .equ NVIC_IPR_BASE, 0x300 

/* system control register */
.equ SCR_BASE_ADR,0xE000ED10
.equ SCR_SLEEPONEXIT,(1<<1)
.equ SCR_SLEEPDEEP,(1<<2)
.equ SCR_SEVONPEND,(1<<4)

/* power control register */
.equ PWR_CR_ADR,0x40007000
.equ PWR_CR_LPDS,(1<<0)
.equ PWR_CR_PDDS,(1<<1)
.equ PWR_CR_CWUF,(1<<2)
.equ PWR_CR_CSBF,(1<<3)
.equ PWR_CR_PVDE,(1<<4)
.equ PWR_CR_PLS,(1<<5)
.equ PWR_CR_DBP,(1<<8)

/* power control and statut register */
.equ PWR_CSR_ADR,0x40007004 
.equ PWR_CSR_WUF,(1<<0)
.equ PWR_CSR_SBF,(1<<1)
.equ PWR_CSR_PVDO,(1<<2)
.equ PWR_CSR_EWUP,(1<<8)

/* Window watchdog (WWDG) */
.equ WWDG_BASE_ADR,0x40002C00
.equ WWDG_CR,0
.equ WWDG_CFR,4
.equ WWDG_SR,8

/* Independent watchdog (IWDG) */
.equ IWDG_BASE_ADR,0x40003000
.equ IWDG_KR,0 
.equ IWDG_PR,4
.equ IWDG_RLR,8
.equ IWDG_SR,12

/*   ADC1 registers */
.equ ADC1_BASE_ADR, 0x40012400
.equ ADC_SR,0
.equ ADC_CR1,0X4
.equ ADC_CR2,0X8
.equ ADC_SMPR1,0XC
.equ ADC_SMPR2,0X10
.equ ADC_JOFR1,0X14
.equ ADC_JOFR2,0X18
.equ ADC_JOFR3,0X1C
.equ ADC_JOFR4,0X20
.equ ADC_HTR,0X24
.equ ADC_LTR,0X28
.equ ADC_SQR1,0X2C
.equ ADC_SQR2,0X30
.equ ADC_SQR3,0X34
.equ ADC_JSQR,0X38
.equ ADC_JDR1,0X3C
.equ ADC_JDR2,0X40
.equ ADC_JDR3,0X44
.equ ADC_JDR4,0X48
.equ ADC_DR,0X4C

/* timer registers */
.equ TIMER1_BASE_ADR,0X40012C00
.equ TIMER2_BASE_ADR,0x40000000
.equ TIMER3_BASE_ADR,0x40000400
.equ TIMER4_BASE_ADR,0x40000800

.equ TIM_CR1,0
.equ TIM_CR2,4
.equ TIM_SMCR,8
.equ TIM_DIER,0xc
.equ TIM_SR,0X10
.equ TIM_EGR,0X14
.equ TIM_CCMR1,0X18
.equ TIM_CCMR2,0X1C
.equ TIM_CCER,0X20
.equ TIM_CNT,0X24
.equ TIM_PSC,0X28
.equ TIM_ARR,0X2C
.equ TIM_CCR1,0X34
.equ TIM_CCR2,0X38
.equ TIM_DCR,0X48
.equ TIM_DMAR,0X4C

/* SPI registers */
.equ SPI1_BASE_ADR, 0x40013000
.equ SPI2_BASE_ADR, 0x40003800

.equ SPI_CR1, 0
.equ SPI_CR2, 4
.equ SPI_SR,  8
.equ SPI_DR,  12
.equ SPI_CRCPR, 16
.equ SPI_RXCRCR, 20
.equ SPI_TXCRCR, 24
