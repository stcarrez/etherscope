# Helper makefile to build etherscope, make the image and flash it.

all:  etherscope

etherscope:
	arm-eabi-gnatmake -Petherscope -p -cargs -mno-unaligned-access
	arm-eabi-objcopy -O binary obj/stm32f746disco/etheroscope etherscope.bin

flash:		all
	st-flash write etherscope.bin 0x8000000

checkout:
	git submodule init
	git submodule update
	cd Ada_Drivers_Library && git submodule init && git submodule update
