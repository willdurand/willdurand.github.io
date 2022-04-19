---
layout: post
title: "On writing a network stack (1/2)"
location: "Freiburg, Germany"
image: /images/posts/2022/02/network-stack-social.webp?v=20220411-2
tweet_id: 1494288808669503492
---

_I am writing a minimum viable network stack from scratch for [ArvernOS][] (a
UNIX-like toy kernel). This two-part story describes some protocols of the
[TCP/IP][tcp-ip] stack as well as some implementation details in the context of
ArvernOS._

There are different ways to approach a problem like "let's write a network
stack". The most sane solution is probably to not do it because there are many
great implementations already ([lwIP][] for example). On the other hand, _I_
learn a lot more by doing than by passively studying existing software or RFCs
so 🤷

The "stack" I am referring to is _everything_ that happens _after_ a program
calls functions like [`socket`(2)][socket], [`recvfrom`(2)][recvfrom], etc. and
until these functions return. In ArvernOS, but I think that would apply to Linux
as well, the network stack is part of the kernel code and (user) programs
interact with it using [system calls][].

When I started the implementation of the ArvernOS network stack (in December
2020), my plan was to write the minimal amount of code to (1) add support for a
network card in my kernel and (2) send some valid data. I designed this stack
without looking at other existing implementations. That might be a problem in
the future, we'll see.

![ArvernOS network stack in (early) 2022](/images/posts/2022/02/arvernos-network-stack-202201.webp?v=20220411)
_Figure 1: ArvernOS network stack in (early) 2022, which is divided into 5
layers (the TCP/IP model sits on top of a physical layer)_
{:.with-caption .can-invert-image-in-dark-mode}

Figure 1 depicts the 5 different layers/protocols already implemented in
ArvernOS: I chose to have a first distinct physical layer, and then we have the
4 layers of the [TCP/IP][tcp-ip] model. This makes the first 4 layers of this model
similar to the [OSI model][osi] as well.

Each implementation is far from perfect but it is "functional". In this article,
I introduce the three first layers (at the bottom), which cover three network
protocols: Ethernet (as per IEEE 802.3), ARP and IPv4.

- [Layer 1: RTL8139 Network Chip](#layer-1-rtl8139-network-chip)
- [Layer 2: Ethernet](#layer-2-ethernet)
- [Layer 2.5: Address Resolution Protocol (ARP)](#layer-25-address-resolution-protocol-arp)
- [Layer 3: Internet Protocol v4 (IPv4)](#layer-3-internet-protocol-v4-ipv4)
- [One more thing for today...](#one-more-thing-for-today) (surprise, yay!)

## Layer 1: RTL8139 Network Chip

_Disclaimer: This section is specific to ArvernOS but a network stack needs some
hardware eventually, and that is often fairly specific to the kernel/OS
(although it should be possible to have an abstraction layer for the hardware
devices in the network stack itself)._

The first step was implementing a driver for an old Ethernet network card
([RTL8139][]). Why this specific one? Mainly because I knew nothing about
network cards or drivers, the OSDev wiki had good resources on that matter, and
this card was available in QEMU. If I had to chose a driver to write again, I'd
probably write a [virtio-net][] driver because that'd allow me to use it on many
virtual machines (and on some cloud providers, potentially).

![ArvernOS "Layer 1"](/images/posts/2022/02/arvernos-layer1.webp)
_Figure 2: ArvernOS "Layer 1" is basically a driver to send/receive data_
{:.with-caption .can-invert-image-in-dark-mode}

Implementing the _RTL8139_ driver wasn't too complex (see these source files:
[`drivers/rtl8139.h`][rtl8139.h] and [`drivers/rtl8139.c`][rtl8139.c]). The
driver transmits data to the hardware by putting it at the right location in
memory and it receives data using hardware interrupts, which are handled with a
simple function that copies the data from one memory location to another. These
two functions are depicted in Figure 2. Under the hood, the hardware does the
conversion from bytes to an analog signal on the actual physical support (i.e.
an Ethernet cable).

I chose to represent an Ethernet card as a _network interface_ (defined in this
header file: [`kernel/net/net.h`][net.h]). It is a thin abstraction layer on top
of some configuration (like the MAC/IP addresses of the interface itself as well
as the gateway and a DNS server), and the driver itself.

With that, it was time to write some more code to send and receive data.

## Layer 2: Ethernet

One thing to understand about Ethernet cards like the one above is that they
exchange data with other machines **within the same LAN** (a "home" or "office"
network for instance). Machines are connected to each other with **physical**
cables.

At this level (or layer in [OSI model][osi] parlance), we send and receive
frames using [MAC addresses][mac address]. A MAC address looks like this:
`52:55:0a:00:02:03`. It's possible to target a specific machine but only if we
know its MAC address. Otherwise we have to use the broadcast MAC address, which
target all machines configured to accept broadcasted frames (network cards can
be configured to ignore such frames).

### 💡 Layer 2 in ArvernOS

![ArvernOS Layer 1 + 2](/images/posts/2022/02/arvernos-layer2.webp)
_Figure 3: ArvernOS Layer 1 + 2_
{:.with-caption .can-invert-image-in-dark-mode}

In ArvernOS, most protocol implementations provide two functions to receive and
send data, which is what Figure 3 shows. The Ethernet implementation is defined
in [`kernel/net/ethernet.h`][ethernet.h]. With this network stack, when we send
data, the upper layers call the lower ones. It is the opposite when we receive
data, which is why `rtl8139_receive()` calls
[`ethernet_receive_frame()`][ethernet_receive_frame] in Figure 3.

This "glue" between the driver code (`rtl8139_receive()` in this example) and
the Ethernet layer (`ethernet_receive_frame()`) is currently implemented in
`net_interface_init()` (see [this line][net_interface_init]). Depending on the
driver _type_, we configure the right callback function on the interface. The
driver has access to this interface so, when it receives data, it can forward
the data to the upper layer (which is unknown from its perspective) _via_ the
interface:

```c
// drivers/rtl8139.c

static net_driver_t driver = {
  .type = 1, // ARP_HTYPE_ETHERNET
  .name = "RealTek RTL8139",
  .get_mac_address = rtl8139_get_mac_address,
  .transmit = rtl8139_transmit,
  .interface = NULL, // will be set in `net_interface_init()`.
};

void rtl8139_receive()
{
  // ... some code to read the frame/len from a buffer ...

  driver.interface->receive_frame_callback(driver.interface, frame, len);

  // ...
}
```

I am still wondering if this is the right approach. Sure, it works but there is
no buffering so every single frame will be sent to the upper layers in the
network stack, one by one. In Linux, network device drivers seem to use the
[`netif_receive_skb()`][netif_receive_skb] function to pass data up the stack
(_via_ `napi_gro_receive()`), and that definitely involves some buffers.

Anyway, given Ethernet required MAC addresses and broadcasting all frames didn't
sound to appealing, the next logical step was to find a way to discover MAC
addresses. My "long-term" goal was to write an IP-oriented network stack so I
looked into ARP first.

## Layer 2.5: Address Resolution Protocol (ARP)

[ARP][] is a popular protocol to find the recipient MAC address when we know its
IP address (or another internet layer address).

It works like this: machine _A_ wants to know the MAC address of machine _B_. If
_A_ knows the IP address of _B_, it can send an ARP request, i.e. a frame
broadcasted on the LAN asking `who has <ip address>?`. If machine _B_ receives
broadcasted frames, it will sends an ARP reply to _A_ and that's how _A_ will
know the MAC address of _B_.

### 💡 Layer 2.5 in ArvernOS

![ArvernOS Layer 1 + 2 + ARP](/images/posts/2022/02/arvernos-layer2-5.webp)
_Figure 4: ArvernOS Layer 1 + 2 + ARP (Layer 2.5)_
{:.with-caption .can-invert-image-in-dark-mode}

Currently, the network stack contains a naive ARP implementation (defined in
this header file: [`kernel/net/arp.h`][arp.h]). No ARP cache. No Reverse ARP. As
depicted in Figure 4, when receiving data, the Ethernet code has to decode the
frame header and read the [EtherType][] value to know what to do next.

The ARP implementation conveniently provides a function to handle ARP packets
([`arp_receive_packet()`][arp_receive_packet]), which receives the data
contained in the Ethernet frame. If the _EtherType_ is not supported, the frame
is dropped.

Sending an ARP request (`who has <ip address>?`) is less involved because the
ARP layer only has to construct the ARP packet and ask the Ethernet layer to
send the packet.

At this point, I could visualize frames being sent and received between my
kernel and the emulated gateway in QEMU using Wireshark.

![Screenshot of Wireshark](/images/posts/2022/02/wireshark.webp?v=2)

### But, what if...?

What if _A_ does not know the IP address of _B_? As mentioned previously, it is
possible to broadcast frames. Another option if _A_ knows _B_'s (host) name
could be to use [DNS][] to find the IP address, and then ARP.

What if _A_ knows nothing about _B_? For example, it isn't uncommon to plug an
Ethernet cable to a new machine and get LAN or even Internet access almost
instantaneously. This is very likely happening thanks to [DHCP][].

Both DNS and DHCP are high level IP protocols. In order to add support for these
protocols, I had to implement a couple new layers: IPv4 and [UDP][].

## Layer 3: Internet Protocol v4 (IPv4)

[IP][] is the Internet Protocol and v4 is the "old" version, which I like
because I can remember IP addresses (I know, right?). There is also IPv6 but I
don't know much about it. I'd recommend this [IPv4 vs. IPv6 FAQ][tailscale-faq]
for more information.

IP allows to reach machines on a different LAN using a gateway (a.k.a. a
router). When a machine wants to send an IP packet (sometimes called datagram)
to a non-local machine, it has to create an Ethernet frame that encapsulates the
IP packet and asks the network card to transmit it. We've seen that before. The
thing is that we need the data to get out of the LAN so the Ethernet frame's
destination address should be the MAC address of the gateway (even though the
packet is for a different machine).

When the gateway receives the frame, it reads the [EtherType][]. Given that the
frame encapsulates an IPv4 packet, the gateway determines whether the
destination IP address is local. If it is not local, it modifies the frame's
destination MAC address to set the MAC address of its own gateway and forwards
it. When the packet arrives to a gateway that knows the recipient, the
destination MAC address is set to the one of the recipient machine. The
recipient reads the _EtherType_ as well, and then parses the IPv4 packet.

Each IPv4 packet has a `protocol` field that indicates the type of data
encapsulated in the packet. Common types include [ICMP][] ("ping"), [UDP][] and
[TCP][].

### 💡 Layer 3 in ArvernOS

![ArvernOS Layers 1 + 2 + IPv4](/images/posts/2022/02/arvernos-layer3.webp)
_Figure 5: ArvernOS Layer 1 + 2 + IPv4_
{:.with-caption .can-invert-image-in-dark-mode}

Figure 5 shows how the IPv4 implementation is integrated in the network stack
for ArvernOS. It is very similar to what has been described previously. When
receiving a frame, the Ethernet layer reads the _EtherType_ and calls
[`ipv4_receive_packet()`][ipv4_receive_packet] when its value is IPv4. A
not-so-fun but still interesting part of the IPv4 implementation has been to
compute correct checksums as specified in the [RFC 1071][rfc1071].

When I implemented IPv4, I also implemented ICMPv4 so that I could verify my
network stack implementation by ping-ing another machine. Interested readers can
find the code in [`kernel/net/icmpv4.c`][icmpv4.c].

## One more thing for today...

Lately, I started to work on a completely unrelated feature for ArvernOS: a
Linux compatibility layer (see [this draft PR][pr-linux-compat]), which would
allow unmodified Linux binaries to run on ArvernOS. This involved learning a lot
about the [System V ABI][] and other low-level Linux and "libc" stuff but I made
good progress. I was able to run a custom [BusyBox][] build statically compiled
with [musl][] on (and for) Linux.

_Why_ would I mention that in an article about network protocols, though? Well,
I compiled BusyBox with `ping` and I was able to execute it on ArvernOS (and
yeah, the time seems incorrect):

![BusyBox's ping executed on ArvernOS](/images/posts/2022/02/arvernos-busybox-ping.webp)

`traceroute` kinda works, too. It is cool to see that well-known existing tools
can somehow leverage this little network stack. As I said before, it isn't
perfect but it is functional.

## The End.

That's it for today. Let me know if you have questions or comments (email or
Twitter). In [part 2][part-2], we'll cover [UDP][], [DHCP][] and [DNS][].

[arvernos]: https://github.com/willdurand/ArvernOS/
[osi]: https://en.wikipedia.org/wiki/OSI_model
[tcp-ip]: https://en.m.wikipedia.org/wiki/Internet_protocol_suite
[rtl8139]: https://wiki.osdev.org/RTL8139
[rtl8139.h]: https://github.com/willdurand/ArvernOS/blob/8b183a51311591158fd4f20c5a08a73c69dd1b03/src/kernel/arch/x86_64/drivers/rtl8139.h
[rtl8139.c]: https://github.com/willdurand/ArvernOS/blob/8b183a51311591158fd4f20c5a08a73c69dd1b03/src/kernel/arch/x86_64/drivers/rtl8139.c
[net.h]: https://github.com/willdurand/ArvernOS/blob/8b183a51311591158fd4f20c5a08a73c69dd1b03/include/kernel/net/net.h#L44-L84
[ethernet.h]: https://github.com/willdurand/ArvernOS/blob/8b183a51311591158fd4f20c5a08a73c69dd1b03/include/kernel/net/ethernet.h
[arp]: https://en.m.wikipedia.org/wiki/Address_Resolution_Protocol
[arp.h]: https://github.com/willdurand/ArvernOS/blob/8b183a51311591158fd4f20c5a08a73c69dd1b03/include/kernel/net/arp.h
[net_interface_init]: https://github.com/willdurand/ArvernOS/blob/8b183a51311591158fd4f20c5a08a73c69dd1b03/src/kernel/net/net.c#L40
[ethertype]: https://en.wikipedia.org/wiki/EtherType
[ip]: https://en.wikipedia.org/wiki/Internet_Protocol
[rfc1071]: https://datatracker.ietf.org/doc/html/rfc1071
[tailscale-faq]: https://tailscale.com/kb/1134/ipv6-faq/
[system v abi]: https://wiki.osdev.org/System_V_ABI
[musl]: https://www.musl-libc.org/
[busybox]: https://busybox.net/
[lwip]: https://savannah.nongnu.org/projects/lwip/
[udp]: https://en.wikipedia.org/wiki/User_Datagram_Protocol
[dhcp]: https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol
[dns]: https://en.wikipedia.org/wiki/Domain_Name_System
[icmp]: https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol
[tcp]: https://en.wikipedia.org/wiki/Transmission_Control_Protocol
[socket]: https://man7.org/linux/man-pages/man2/socket.2.html
[recvfrom]: https://man7.org/linux/man-pages/man2/recvfrom.2.html
[system calls]: https://en.wikipedia.org/wiki/System_call
[virtio-net]: https://www.redhat.com/en/blog/introduction-virtio-networking-and-vhost-net
[mac address]: https://en.wikipedia.org/wiki/MAC_address
[netif_receive_skb]: https://www.kernel.org/doc/htmldocs/networking/API-netif-receive-skb.html
[ipv4_receive_packet]: https://github.com/willdurand/ArvernOS/blob/8b183a51311591158fd4f20c5a08a73c69dd1b03/src/kernel/net/ipv4.c#L21-L49
[icmpv4.c]: https://github.com/willdurand/ArvernOS/blob/8b183a51311591158fd4f20c5a08a73c69dd1b03/src/kernel/net/icmpv4.c
[arp_receive_packet]: https://github.com/willdurand/ArvernOS/blob/8b183a51311591158fd4f20c5a08a73c69dd1b03/src/kernel/net/arp.c#L58-L99
[ethernet_receive_frame]: https://github.com/willdurand/ArvernOS/blob/8b183a51311591158fd4f20c5a08a73c69dd1b03/src/kernel/net/ethernet.c#L10-L42
[pr-linux-compat]: https://github.com/willdurand/ArvernOS/pull/552
[part-2]: {% post_url 2022-04-11-on-writing-a-network-stack-part-2 %}
