NAME=tinyBasic
# tools
PREFIX=arm-none-eabi-
CC=$(PREFIX)gcc
AS=$(PREFIX)as 
LD=$(PREFIX)ld
DBG=gdb-multiarch
OBJDUMP=$(PREFIX)objdump
OBJCOPY=$(PREFIX)objcopy

#build directory
BUILD_DIR=build/
#Link file
LD_FILE=stm32f103c8t6.ld 
LD_FLAGS=-mmcu=stm32f103
#sources
SRC=stm32-tbi.s 
# programmer
VERSION=STLINKV2 
STV2_DUNGLE_SN=483f6e066772574857351967
STV3_PROG_SN=
SERIAL=$(STV2_DUNGLE_SN)

.PHONY: all 

all: clean build dasm

build:  *.inc *.s Makefile $(LD_FILE)
	$(AS) -a=$(BUILD_DIR)$(NAME).lst $(SRC) -g -o$(BUILD_DIR)$(NAME).o
	$(LD) -T $(LD_FILE) -g $(BUILD_DIR)$(NAME).o -o $(BUILD_DIR)$(NAME).elf
	$(OBJCOPY) -O binary $(BUILD_DIR)$(NAME).elf $(BUILD_DIR)$(NAME).bin 
#	$(OBJCOPY) -O ihex $(BUILD_DIR)$(NAME).elf $(BUILD_DIR)$(NAME).hex  
	$(OBJDUMP) -D $(BUILD_DIR)$(NAME).elf > $(BUILD_DIR)$(NAME).dasm

flash: $(BUILD_DIR)$(NAME).bin 
	st-flash --serial=$(SERIAL) erase 
	st-flash  --serial=$(SERIAL)  write $(BUILD_DIR)$(NAME).bin 0x8000000

dasm:
	$(OBJDUMP) -D $(BUILD_DIR)$(NAME).elf > $(BUILD_DIR)$(NAME).dasm

debug: 
	cd $(BUILD_DIR) &&\
	$(DBG) -tui --eval-command="target remote localhost:4242" $(NAME).elf

.PHONY: clean 

clean:
	$(RM) build/*
