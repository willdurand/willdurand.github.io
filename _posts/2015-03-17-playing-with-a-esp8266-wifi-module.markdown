---
layout: post
location: Clermont-Fd Area, France
tldr: false
audio: false
tags: [ "arduino", "coffuino" ]
title: "Playing With a ESP8266 WiFi Module"
---

**2015-03-26: I open-sourced [EspWiFi](https://github.com/willdurand/EspWiFi),
a Arduino driver for the ESP8266 WiFi Module.**

---

Lately, I started to play with some [Arduino](http://arduino.cc/)-based
technologies after having made my very own [Arduino
DIY](http://redmine.acolab.fr/projects/yabbas-v1/wiki/YABBAS) at
[AcoLab](http://acolab.fr/), a hackerspace based in Clermont-Fd.  My new world
domination plan, named **coffuino**, is to put a coffee machine over the
Internets. I will write more on this project in the coming weeks, but as you may
imagine for now, this project requires an Internet connection, hence the aim of
this article. Let me introduce the **ESP8266 WiFi Module**, courtesy of
[Paul](https://twitter.com/disk_91).

![](/images/posts/2015/esp/esp8266.jpg)

This is a serial module with a built-in TCP/IP stack, so you can use it
standalone but you will be likely limited. You need a
[FTDI](https://en.wikipedia.org/wiki/FTDI) to connect this module to your
computer, and start communicating with it. _FTDI_ is a common name for
**USB-to-TTL** (or serial) converter, FTDI being the company making and selling
these products.

## Wiring

I got a _ESP-01_ version of this module, which has 8 pins: `VCC`, `GND`,
`CH_PD`, `TX`, `RX`, `RST`, `GPIO0`, and `GPIO1`. Wiring the module is not
complicated and should be the same for all versions of this module:

* `VCC` needs **3.3V**
* `CH_PD` has to be pulled-up (meaning it has to be connected to 3.3V as well)
* `GND` is connected to FTDI's `GND` pin
* `RX` is connected to FTDI's `TX` pin, because you want to create a loop: `RX` -> `TX` => `RX` -> `TX`
* `TX` is connected to FTDI's `RX` pin
* other pins are left floating

![](/images/posts/2015/esp/sketch.png)

The important detail here is that this module needs 3.3V, not 5V which is what
most FTDIs supply. Mine has a jumper to supply either 3.3V or 5V. In case yours
only supplies 5V, you need a [voltage
devider](https://en.wikipedia.org/wiki/Voltage_divider). Talking about power,
this module requires more than 200mA, so use a dedicated power supplier for it.
**This is really important** because a lack of intensity causes various issues!

I read that `CH_PD` should be pulled-up with a resistor (from _3k_ to _10k_
Ohms), however it did not work for me, so I connected this pin to `VCC`.

## Connecting the Module

Now you can plug your USB cable to your laptop and try to reach your module
using `screen` or any tool that can talk to a serial interface:

    screen /dev/tty.usbserial-A50285BI 9600

Depending on the firmware version, baud rate is different: `9600`, `57600` or
`115200`. This is another thing that can cause communication issues. Try
different baud rates, it will either work, display gibberish, or simply fail...
`115200` seems to be the default value, however most FTDIs are not able to work
well at such a rate.

Once you find a decent baud rate, you can send a first **AT** comand to the
module. The following `AT` command asks the module whether it is up:

    AT

It should respond with `OK`. The [AT command
set](https://github.com/espressif/esp8266_at/wiki/AT_Description) is quite
large, I cover a few commands in this post but feel free to try them all.
Before having dug more with these commands, I chose to flash the module first,
and then set `57600` as baud rate. It allowed me to communicate with the module
in a reliable manner.

## Upgrading the Firmware

Look at the
[espressif/esp8266_at](https://github.com/espressif/esp8266_at/tree/master/bin)
repository to find recent (official) firmwares. In order to flash the module,
you have to pull-down `GPIO0` by wiring its pin to `GND`, then run
[esptool](https://github.com/themadinventor/esptool):

    ./esptool.py -p /dev/tty.usbserial-A50285BI write_flash 0x0000 boot_v1.1.bin \
        0x01000 user1.bin 0x7C000 esp_init_data_default.bin 0x7E000 blank.bin

`boot_v1.1.bin`, `esp_init_data_default.bin`, and `blank.bin` don't really
change, however choose the right `user1.bin` (see `newest/` folder for
instance). Recent firmwares obviously support [cloud
updates](http://blog.electrodragon.com/cloud-updating-your-wi07c-esp8266-now/),
but I did not try yet.

In order to change the baud rate, you have to connect to your module, then send
the `AT+CIOBAUD` command with a value (`57600` in this case):

    AT+CIOBAUD=57600

If you want to use the module in a standalone mode, you will probably be
interested in [nodemcu](https://github.com/nodemcu/nodemcu-firmware), a lua
based interactive firmware for mcu like ESP8266.
Now that the communication with the module is ok, let's join an access point.


## Joining an Access Point

I chose [pyesp8266](https://github.com/guyz/pyesp8266), a Python script to tell
the module to connect to an Access Point and ensure everything works:

    python esp8266test.py <serial_port> <ssid> <password>

A few hints in case something is wrong with your setup:

* Is the red LED on the module lit? If it is not, the board is not getting
  power
* When trying to issue commands, do you see the blue LED on the module blinking?
  If not, check the RX/TX connections. If the LED is constantly lit, then one of
  the connections is wrong - probably RX/TX or one of the other pins
* Are you seeing gibberish? You are probably doing well, but try a different
  baud rate. In one of the provided scripts, run the `AT+CIOBAUD` command first
  (you have to modify the script)
* The script gets stuck on the `AT+CWJAP` command? Increase the timeout in the
  script (default is: `5` seconds, mine works with `10`)


## Running a TCP Server

As I said previously, this module embeds a TCP/IP stack, so you can tell the
module to open a socket and listen at a given port. This is doable by manually
sending `AT` commands or by using the `esp8266server.py` script, bundled with the
`pyesp8266` tool:

![](/images/posts/2015/esp/screen.png)

The script runs a simple TCP server on port `80` by sending the following `AT`
commands:

    # allow multiple connections
    AT+CIPMUX=1

    # run a TCP server on port 80
    AT+CIPSERVER=1,80

In case you did not notice, it also send the `AT+CIFSR` to retrieve the IP
address. Browsing it will give you a message starting wit `GOT IT!`


## Coffuino, You Said?

**coffuino** is the project I am working on during my spare time, and it needs
an Internet connection. I used this WiFi module and implemented a library to
manage it in C++, which should be opensourced soon.
There are a few libraries for Arduino, but I did not find any simple library
that worked with my setup (my Arduino only has one hardware serial for instance).

The picture below is the prototype of **coffuino** (PS: you will find more
teasers on [Twitter](https://twitter.com/couac)):

![](/images/posts/2015/esp/wiring.jpg)

The Arduino is powered by a former Apple USB cable (\o/) whereas the WiFi module
uses the 3.3V output of my FTDI.  Note that I set the baud rate to `115200` in
order to connect the module to my Arduino (which perfectly handles such a rate).

I will give more details on the software part in another article.


## Links

Because it would not have been possible without these articles and useful
resources, thanks!

* [Getting started with the esp8266 and Arduino](http://www.madebymarket.com/blog/dev/getting-started-with-esp8266.html)
* [noob's guide to ESP8266 with Arduino Mega 2560 or Uno](http://shin-ajaran.blogspot.fr/2014/12/noobs-guide-to-esp8266-with-arduino.html)
* [ESP8266 Teensy Time](http://www.cse.dmu.ac.uk/~sexton/ESP8266/)
* [ESP8266 WiFi module](http://tomeko.net/other/ESP8266/)
* [ESP8266 - Upgrading the Firmware](https://www.ukhas.net/wiki/esp8266/firmware_update)
* [ESP8266 Community Forum](http://www.esp8266.com/)
* [ESP8266 Electrodragon](http://www.electrodragon.com/w/ESP8266)
* [esp8266/esp8266-wiki - Toolchain @ GitHub](https://github.com/esp8266/esp8266-wiki)
* [ESP8266 WiFi Module Quick Start Guide](http://www.labradoc.com/i/follower/p/notes-esp8266)
* [ESP8266 Offical AT+ Command @ GitHub](https://github.com/espressif/esp8266_at)
