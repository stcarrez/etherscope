# Ethernet Traffic Monitor on a STM32F746

[![Build Status](https://img.shields.io/jenkins/s/http/jenkins.vacs.fr/etherscope.svg)](http://jenkins.vacs.fr/job/etherscope/)
[![License](http://img.shields.io/badge/license-APACHE2-blue.svg)](LICENSE)
![Commits](https://img.shields.io/github/commits-since/stcarrez/etherscope/1.0.0.svg)

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
To help, these GitHub projects are registered as Git submodules and
the Makefile provides a target to perform the checkout.  Just run:

  make checkout

You will also need the GNAT Ada compiler for ARM available at http://libre.adacore.com/

# Build

Run the command:

  make

to build the application and get the EtherScope image 'etherscope.bin'.
Then, flash the image with:

  st-flash write etherscope.bin 0x8000000

or just

  make flash

# Using EtherScope

To look at the network traffic, it is recommended to have a switch that supports
port monitoring.  The switch is configured to monitor all the traffic to a given
port.  The EtherScope is then connected to that port and it will receive all the
traffic, including the packets not destined to the board.

You can still use EtherScope without a switch and port mirroring but the EtherScope
will not be able to see all the network packets.  Without port mirroring, we can
only see multicast and broadcast traffic, which means: ARP, ICMP, IGMP and UDP
packets on multicast groups.

Once powered up, the EtherScope starts the analysis and offers 4 buttons to
switch to different display modes:

* <b>Ether</b> displays the list of devices found on the network.
* <b>Proto</b> displays the different IPv4 protocols found on the network.
* <b>IGMP</b> displays the UDP multicast groups which are subscribed on the network.
* <b>TCP</b> displays the list of high level application protocols (http, https, ssh, ...).


The following screenshot shows the TCP panel with 3 recognized TCP protocols and a running
SCP that uses almost all the bandwidth.

![](https://github.com/stcarrez/etherscope/wiki/images/etherscope-v1.png)

# Publication

* The EtherScope project was submitted to the [Make with Ada](http://www.makewithada.org/) competition.

* Article: [Ethernet Traffic Monitor on a STM32F746](http://blog.vacs.fr/vacs/blogs/post.html?post=2016/09/30/Ethernet-Traffic-Monitor-on-a-STM32F746)

* Article: [Using the Ada Embedded Network STM32 Ethernet Driver](http://blog.vacs.fr/vacs/blogs/post.html?post=2016/09/29/Using-the-Ada-Embedded-Network-STM32-Ethernet-Driver)

* Video: [EtherScope an Ethernet Traffic Monitor](https://youtu.be/zEtA-S5jvfY)
