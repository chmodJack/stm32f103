TARGET=led

CROSS=arm-none-eabi-
CC=$(CROSS)gcc
OBJCOPY=$(CROSS)objcopy
OBJDUMP=$(CROSS)objdump
SIZE=$(CROSS)size

OBJS+=$(SOBJS)
OBJS+=$(COBJS)

SOBJS=$(SSRC:%.s=%.o)
COBJS=$(CSRC:%.c=%.o)
SSRC=$(shell find . -name *.s)
CSRC=$(shell find . -name *.c)

ALLDIRS=$(shell ls -R|grep ./)
INCPATH=$(ALLDIRS:%:=-I%)
LIBPATH=$(ALLDIRS:%:=-L%)

CFLAGS+=-c -W -Wall -Wextra -Werror -Os
CFLAGS+=-ffunction-sections -fdata-sections
CFLAGS+=-DUSE_STDPERIPH_DRIVER -DSTM32F10X_MD
CFLAGS+=-mcpu=cortex-m3 -mthumb

CCFLAGS+=$(CFLAGS)
CCFLAGS+=-std=gnu11
CCFLAGS+=$(INCPATH)

LDFLAGS+=-static -lc -lm -Tf103gcc.ld
LDFLAGS+=-mcpu=cortex-m3 -mthumb
LDFLAGS+=-specs=nano.specs
LDFLAGS+=-specs=nosys.specs
LDFLAGS+=-Wl,--start-group
LDFLAGS+=-Wl,--end-group
LDFLAGS+=-Wl,-cref,-u,Reset_Handler
LDFLAGS+=-Wl,--defsym=malloc_getpagesize_P=0x80
LDFLAGS+=-Wl,-Map=project.map
LDFLAGS+=-Wl,--gc-sections
LDFLAGS+=$(LIBPATH)

.PHONY:all clean flash $(TARGET)

all:$(TARGET)
install:flash
$(TARGET):$(OBJS)
	@echo '[LD] $@'
	@$(CC) $(LDFLAGS) -o $@ $^
	@echo '[OC] $@.bin'
	@$(OBJCOPY) $@ $@.bin -Obinary
	@echo '[OC] $@.hex'
	@$(OBJCOPY) $@ $@.hex -Oihex
	@echo '[OD] $@.dis'
	@$(OBJDUMP) $@ -D > $@.dis
	@echo '[SZ] $@'
	@$(SIZE) $@
%.o:%.s
	@echo '[AS] $@'
	$(CC) $(SCFLAGS) -o $@ $<
%.o:%.c
	@echo '[CC] $@'
	@$(CC) $(CCFLAGS) -o $@ $<
clean:
	@rm -f $(shell find . -name '*.o')
	@rm -f $(shell find . -name '*.d')
	@rm -f $(shell find . -name '*.map')
	@rm -f $(shell find . -name '*.elf')
	@rm -f $(shell find . -name '*.bin')
	@rm -f $(shell find . -name '*.hex')
	@rm -f $(shell find . -name '*.dis')
	@rm -f $(TARGET)
flash:
	st-flash write $(TARGET).bin 0x8000000
