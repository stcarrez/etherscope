# Helper makefile to build etherscope, make the image and flash it.

all:  etherscope

ada-enet/anet_stm32fxxx.gpr:
	cd ada-enet && ./configure --with-board=stm32f746

etherscope: ada-enet/anet_stm32fxxx.gpr
	arm-eabi-gnatmake -Petherscope -p -cargs -mno-unaligned-access
	arm-eabi-objcopy -O binary obj/stm32f746disco/etheroscope etherscope.bin

flash:		all
	st-flash write etherscope.bin 0x8000000

checkout:
	git submodule init
	git submodule update
	cd ada-enet/Ada_Drivers_Library && git submodule init && git submodule update
	cd ada-enet/Ada_Drivers_Library/embedded-runtimes && git submodule init && git submodule update
