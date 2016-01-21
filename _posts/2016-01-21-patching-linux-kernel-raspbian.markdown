---
layout: post
location: Clermont-Fd, France
tldr: false
audio: false
title: "Patching Linux Kernel (Raspbian &amp; CVE-2016-0728)"
---

[CVE-2016-0728](https://security-tracker.debian.org/tracker/CVE-2016-0728) has
been disclosed earlier this week, and it is a [security
issue](https://threatpost.com/serious-linux-kernel-vulnerability-patched/115923/)
that affects most of the Linux kernel versions (3.8 and upper). While the
bundled exploit seems tricky to successfully use, it is still a flaw that has to
be fixed.

I use to play with some Raspberry Pi for a while now, and they all run
[raspbian](https://www.raspbian.org/), a Debian-based distribution for Raspberry
Pi. I tried to `apt-get update && apt-get upgrade` one of them, but nothing new,
_i.e._ no patched version available. At the time of writing, there was only [a
single unanswered issue](https://github.com/raspberrypi/linux/issues/1264) on
the Raspberry Pi kernel GitHub repository. I jumped to the [source
code](https://github.com/raspberrypi/linux/blob/d51c7d840b002a6b26089d8b45679d9331880060/security/keys/process_keys.c#L796-L799),
and it seemed the code was vulnerable, at least according to the patch and what
I understood from the
[report](http://perception-point.io/2016/01/14/analysis-and-exploitation-of-a-linux-kernel-vulnerability-cve-2016-0728/).

Yet, I wanted to run a patched kernel version, hence I gave [kernel
compilation](https://www.raspberrypi.org/documentation/linux/kernel/) a try.
Below, you will find the different steps I followed to build, install, and run a
patched Linux kernel:

1. First, the `bc` package is needed (`apt-get install bc`), then linux kernel
sources have to be cloned:

        git clone --depth=1 https://github.com/raspberrypi/linux

    Longest git checkout ever!

2. In order to compile a new kernel version, we have to slighty update its name. I
edited the `EXTRAVERSION` variable in the `Makefile`:

    ```
    head Makefile -n 4
    ```

    ```
    VERSION = 4
    PATCHLEVEL = 1
    SUBLEVEL = 15
    EXTRAVERSION = +will
    ```

3. Now let's fetch the
[patch](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/patch/?id=23567fd052a9abb6d67fe8e7a9ccdd9800a540f2)
for this vulnerability, and apply it:

        curl https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/patch/?id=23567fd052a9abb6d67fe8e7a9ccdd9800a540f2 | patch -p1

4. So far so good. Before compiling the kernel, we have to instruct which kernel
we wish to build, then we can build the related configuration:

        export KERNEL=kernel7
        make bcm2709_defconfig

5. Time to compile the kernel and its modules:

        make -j4 zImage modules dtbs

6. It was taking ages, so I started to write this blog post... At some point,
compilation successfully ended. Let's install this brand new kernel:

        sudo make modules_install
        sudo cp arch/arm/boot/dts/*.dtb /boot/
        sudo cp arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/
        sudo cp arch/arm/boot/dts/overlays/README /boot/overlays/
        sudo scripts/mkknlimg arch/arm/boot/zImage /boot/$KERNEL.img

7. And now, time to try it for real (fingers crossed):

    ```
    uname -a
    Linux raspberrypi 4.1.15-v7+ #831 SMP Tue Jan 19 18:39:46 GMT 2016 armv7l GNU/Linux
    ```

    ```
    sudo reboot
    ```

    ```
    uname -a
    Linux raspberrypi 4.1.15+will-v7+ #1 SMP Thu Jan 21 02:09:58 CET 2016 armv7l GNU/Linux
    ```

Achievement unlocked \o/

---

_PS: First time I compiled a kernel, so I might skip important steps (comments
are open, thanks!)._
