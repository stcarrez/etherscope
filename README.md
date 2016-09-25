# Ethernet Traffic Monitor on a STM32F746

[![License](http://img.shields.io/badge/license-APACHE2-blue.svg)](LICENSE)

EtherScope is a monitoring tool that analyzes the Ethernet traffic.
It runs on a STM32F746 board, reads the Ethernet packets, do some
realtime analysis and displays the results on the 480x272 touch panel.

The EtherScope interface allows to filter the results at different
levels:

* Get and display statistics at the Ethernet level,
* Display information at some protocol levels: IPv4, TCP, UDP, ICMP

The EtherScope uses the following two GitHub projects:

* Ada_Drivers_Library   https://github.com/AdaCore/Ada_Drivers_Library.git

* Ada Embedded Network  https://github.com/stcarrez/ada-enet.git

You need the source of these two projects to buid EtherScope.
Sources must be available in the parent directory (that is '..').

You will also need the GNAT Ada compiler for ARM available at http://libre.adacore.com/

# Build

Run the command:

  make

to build the application and get the EtherScope image 'etherscope.bin'.
Then, flash the image with:

  st-flash write etherscope.bin 0x8000000



