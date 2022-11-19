---
layout: post
location: Clermont-Fd Area, France
title: "Playing with a ESP8266 WiFi module"
image: /images/posts/2015/esp/wiring.jpg
updates:
  - date: 2015-03-26
    content: >-
      ~~I open-sourced EspWiFi, a Arduino driver for the ESP8266 WiFi Module.~~
  - date: 2022-07-25
    content: I proofread this article and fixed some links.
---

I started to play with some [Arduino][]-based technologies after having built my
very own [Arduino board][arduino diy] at [AcoLab](https://acolab.fr/)[^1] a few
weeks ago. I've been working on a project to connect a coffee machine to the
Internets. In this article, I introduce the ESP8266 WiFi module, courtesy of
@disk_91, from a "user perspective".

[^1]: AcoLab is a hackerspace based in Clermont-Fd, France.

![](/images/posts/2015/03/esp8266.jpg)

I have a ESP-01 module (ESP8266 being a microchip with its own built-in TCP/IP
stack). It is possible to program and use this module without any other board
but the module isn't super powerful. In case you're interested, [nodemcu][] is a
lua-based interactive firmware worth taking a look! The alternative approach is
to pair this module with another micro-controller like an Arduino. That's how I
want to use this WiFi module in the future.

We can get started with just a computer, though. A [FTDI][] is needed to connect
the module to it. _FTDI_ is a common name for **USB-to-TTL** (or serial)
converter, FTDI being the company making and selling these products.

## Wiring

As mentioned previously, I have a ESP-01, which has 8 pins: `VCC`, `GND`,
`CH_PD`, `TX`, `RX`, `RST`, `GPIO0`, and `GPIO1`. Wiring the module is not
super complicated:

- `VCC` needs **3.3V**
- `CH_PD` has to be pulled-up (meaning it has to be connected to 3.3V as well)
- `GND` is connected to FTDI's `GND` pin
- `RX` is connected to FTDI's `TX` pin, because we want to create a loop: `RX`
  -> `TX` => `RX` -> `TX`
- `TX` is connected to FTDI's `RX` pin
- other pins are left floating

![](/images/posts/2015/03/sketch.png)

It's important to use a 3.3V power supply and not 5V. In terms of power
consumption, this module requires more than 200mA. This is also rather important
because a lack of intensity causes various issues (the module gets unstable and
it's annoying to debug).

I read that `CH_PD` should be pulled-up with a resistor (from _3k_ to _10k_
Ohms), however it did not work for me so I connected this pin to `VCC` 🙈

## Talking to the module

We can use `screen` or any tool that can talk to a serial interface to connect
to the module using an FTDI. This is how I did it:

```
screen /dev/tty.usbserial-A50285BI 9600
```

Depending on the firmware version, baud rate is different: `9600`, `57600` or
`115200`. This is another thing that can cause communication issues. You should
try different baud rates, it will either work, display gibberish, or simply
fail... `115200` seems to be the default value.

Once you find the right baud rate, you can send a first `AT` comand to the
module. The following command asks the module whether it is up:

```
AT
```

It should respond with `OK`. The [AT command set][] is quite large, I cover a
few commands in this post but feel free to try them all.

At this point, I could communicate with the module but it wasn't super stable. I
read that it could be an issue with old firmware (related to the default baud
rate) so I looked into flashing my ESP-01 with a more recent firmware.

## Upgrading the firmware

I downloaded the most recent official firmware from [espressif/esp8266_at][]. In
order to flash the module, `GPIO0` must be pulled-down by wiring its pin to
`GND`. After that, [esptool](https://github.com/themadinventor/esptool) can be
used:

``` console
$ esptool.py -p /dev/tty.usbserial-A50285BI write_flash 0x0000 boot_v1.1.bin \
    0x01000 user1.bin 0x7C000 esp_init_data_default.bin 0x7E000 blank.bin
```

`boot_v1.1.bin`, `esp_init_data_default.bin`, and `blank.bin` don't really
change between versions but `user1.bin` does! Recent firmware apparently support
[cloud updates][], but I haven't tried that yet.

In order to change the baud rate, connect to your module and send the
`AT+CIOBAUD` command with a value (`57600` in this case):

```
AT+CIOBAUD=57600
```

Now that the communication with the module is OK, let's join an access point.

## Joining an access point

I used [pyesp8266](https://github.com/guyz/pyesp8266) to talk to the module and
connect to an Access Point. This tool offers a thin abstraction layer on top of
some more AT commands:

```console
$ python esp8266test.py <serial_port> <ssid> <password>
```

A few hints in case something goes wrong:

- Is the red LED on the module lit? If it is not, the board is not getting
  power.
- When trying to issue commands, do you see the blue LED on the module blinking?
  If not, check the RX/TX connections. If the LED is constantly lit, then one of
  the connections is wrong (probably RX/TX).
- Are you seeing gibberish? Try a different baud rate. In one of the provided
  scripts, run the `AT+CIOBAUD` command first (modify the script).
- The script gets stuck on the `AT+CWJAP` command? Increase the timeout in the
  script (default is: `5` seconds, mine works better with `10`).

## Running a TCP server

As I wrote previously, this module embeds a TCP/IP stack, which allows the
module to open a socket and listen to a given port (among other things). This is
doable by manually sending `AT` commands or by using the `esp8266server.py`
script (bundled with the `pyesp8266` tool).

![](/images/posts/2015/03/screen.png)

This script runs a simple TCP server on port `80` by sending the following `AT`
commands:

```
# allow multiple connections
AT+CIPMUX=1

# run a TCP server on port 80
AT+CIPSERVER=1,80
```

The script also sends the `AT+CIFSR` to retrieve the IP address. We can use this
IP to connect to the server. In a web browser, we would see the message `GOT
IT!` as depicted in the screenshot above.

## Links

Because nothing would have been possible without these articles and useful
resources, thanks!

- [Getting started with the esp8266 and Arduino](http://www.madebymarket.com/blog/dev/getting-started-with-esp8266.html)
- [noob's guide to ESP8266 with Arduino Mega 2560 or Uno](http://shin-ajaran.blogspot.fr/2014/12/noobs-guide-to-esp8266-with-arduino.html)
- [ESP8266 Teensy Time](http://www.cse.dmu.ac.uk/~sexton/ESP8266/)
- [ESP8266 WiFi module](http://tomeko.net/other/ESP8266/)
- [ESP8266 - Upgrading the Firmware](https://www.ukhas.net/wiki/esp8266/firmware_update)
- [ESP8266 Community Forum](http://www.esp8266.com/)
- [ESP8266 Electrodragon](http://www.electrodragon.com/w/ESP8266)
- [esp8266/esp8266-wiki - Toolchain @ GitHub](https://github.com/esp8266/esp8266-wiki)
- [ESP8266 WiFi Module Quick Start Guide](http://www.labradoc.com/i/follower/p/notes-esp8266)
- [ESP8266 Offical AT+ Command @ GitHub](https://github.com/espressif/esp8266_at)

[arduino]: https://www.arduino.cc/
[arduino diy]: https://redmine.acolab.fr/projects/yabbas-v1/wiki/YABBAS
[ftdi]: https://en.wikipedia.org/wiki/FTDI
[at command set]: https://github.com/espressif/esp8266_at/wiki/AT_Description
[espressif/esp8266_at]: https://github.com/espressif/esp8266_at/tree/master/bin
[cloud updates]: https://www.electrodragon.com/cloud-updating-your-wi07c-esp8266-now/
[nodemcu]: https://github.com/nodemcu/nodemcu-firmware
