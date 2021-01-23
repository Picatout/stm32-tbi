NAME=stm32-tbi
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
SRC=$(NAME).s terminal.s tinyBasic.s 
OBJ=$(BUILD_DIR)$(NAME).o $(BUILD_DIR)terminal.o $(BUILD_DIR)tinyBasic.o 
# programmer
VERSION=STLINKV2 
STV2_DUNGLE_SN=483f6e066772574857351967
STV3_PROG_SN=
SERIAL=$(STV2_DUNGLE_SN)

.PHONY: all 

all: clean build dasm


build:  $(SRC) *.inc Makefile $(LD_FILE)
	$(AS) -a=$(BUILD_DIR)$(NAME).lst $(NAME).s -g -o$(BUILD_DIR)$(NAME).o 
	$(AS) -a=$(BUILD_DIR)terminal.lst terminal.s -g -o$(BUILD_DIR)terminal.o 
	$(AS) -a=$(BUILD_DIR)tinyBasic.lst tinyBasic.s -g -o$(BUILD_DIR)tinyBasic.o 
	$(LD) -T $(LD_FILE) -g $(OBJ) -o $(BUILD_DIR)$(NAME).elf
	$(OBJCOPY) -O binary $(BUILD_DIR)$(NAME).elf $(BUILD_DIR)$(NAME).bin 
#	$(OBJCOPY) -O ihex $(BUILD_DIR)$(NAME).elf $(BUILD_DIR)$(NAME).hex  
	$(OBJDUMP) -D $(BUILD_DIR)$(NAME).elf > $(BUILD_DIR)$(NAME).dasm

flash: $(BUILD_DIR)$(NAME).bin 
	st-flash --serial=$(SERIAL) erase 
	st-flash  --serial=$(SERIAL)  write $(BUILD_DIR)$(NAME).bin 0x8000000

debug: 
	cd $(BUILD_DIR) &&\
	$(DBG) -tui --eval-command="target remote localhost:4242" $(NAME).elf

.PHONY: clean 

clean:
	$(RM) build/*
