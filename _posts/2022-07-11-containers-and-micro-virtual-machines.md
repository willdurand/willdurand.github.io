---
layout: post
title: "Containers and micro virtual machines"
location: "Freiburg, Germany"
image: /images/posts/2022/07/containers-and-micro-vms-social.webp
mastodon_id:
tweet_id: 1546461708306219008
credits: Photo used on social media by [Bernd Dittrich](https://unsplash.com/@hdbernd).
---

I wrote [an article about my deep dive into containers][post-containers] last
month. As part of this learning journey, I built a prototype named [Yaman][], an
extremely limited yet functional container manager.

<script id="asciicast-vdC2zxvyHSubTHuAPDt3g2T21" src="https://asciinema.org/a/vdC2zxvyHSubTHuAPDt3g2T21.js" async></script>

In today's article, I introduce a new sub-project named [microvm][]. It's an
experimental container runtime that uses short-lived Virtual Machines (VMs).

This isn't forward-thinking, I developed this new prototype for learning
purposes. [Kata Containers][], [krunvm][] and [crun][] (with the help of
[libkrun][] and [libkrunfw][]) are production-grade technologies to run
containers inside VMs for better isolation.

## Exploratory work

Similar to how others have been [running Docker containers inside QEMU
VMs][qemu-microvm-docker], I started by tinkering with QEMU's
[microvm][qemu-microvm] machine. I compiled a custom Linux kernel for it, and
wrote my own `init`[^1] program. The latter was needed to mimic what a
traditional container runtime does when creating a container from a bundle[^2].

[^1]:
    `init(1)` is the very first userspace program executed by the Linux kernel
    when it has finished its initialization.

[^2]:
    A container bundle (or "OCI bundle") is a folder that contains all the
    information needed to run containers. It is usually derived from an "image"
    (like a "Docker image"). A bundle must contain a [`config.json`][oci-config]
    file and the container's root filesystem (which is a folder usually named
    `rootfs`).

The biggest unknown at the time was about the root filesystem, which resided on
the host but needed to be used within the VM. Creating a disk image (e.g.
[qcow2][]) didn't sound too great: it's overly complicated and slow. Instead, I
used [virtiofsd][], a daemon running on the host that can share a folder with a
guest (VM) using [virtio-fs][].

For the Linux kernel, I created a _minimal_ configuration with `make
allnoconfig` and `make menuconfig` to enable some options. I spent a lot of time
on this part because I wanted to understand [what I was
configuring][config-x86_64]. I recompiled the kernel about 200 times according
to the kernel's `make` output 😅

Most kernel messages could be hidden with the kernel's `quiet` option except
when the machine rebooted. I _really_ wanted to hide all messages unrelated to
the (container) process running in the VM so I did what most people would have
done in this situation: [I patched the kernel][patch-002].

Last but not least, I wrote a simple [`init` program][init.c] to mount some
directories (similar to what I did in [Yacr][]) and read some environment
variables in order to (1) set the `hostname` and (2) execute the container
process. About the latter, the kernel doesn't expect the special `init` process
to be terminated, which happens when the container process has finished its
execution. I [patched the kernel to reboot instead][patch-001] 🙈

The `init` program reads environment variables because the Linux kernel passes
unknown [kernel parameters][] to it[^3]. This is super convenient because QEMU
lets us configure the kernel's command line using the `-append` option. This is
how the container process (defined in the [container configuration][oci-config])
is passed to the VM for instance.

[^3]:
    Only unknown kernel parameters that do not contain `.` are passed to `init`.
    Those with `=` are passed as environment variables, the others are passed as
    arguments (`argv`).

At this point, I could start a VM using my own kernel and get an interactive
shell 🎉

```
(host) $ make run BUNDLE=/tmp/alpine-bundle CID=alpine-ctr
/ # uname -a
Linux alpine-ctr 5.15.47-willdurand-microvm #1 SMP Fri Jul 9 19:08:45 UTC 2022 x86_64 Linux
/ # hostname
alpine-ctr
/ # ls
bin    etc    lib    mnt    proc   run    srv    tmp    var
dev    home   media  opt    root   sbin   sys    usr
/ #
```

The custom kernel, the `init` program and the QEMU/`virtiofsd` configs seemed to
work fine. Phew! This was _just_ QEMU running in my terminal, though.

Obviously, I couldn't stop there...

## The MicroVM runtime

I moved [the few commands I had in a `Makefile`][make-run] to a new Go CLI
application named [microvm][], which partially implements the OCI runtime
specification. This highly experimental container runtime is fully integrated
with [my own container manager][yaman].

Let's consider the following example, which prints a short [weather
report][wttr.in] using two containers:

```console
$ echo 'wttr.in' \
  | sudo yaman c run --rm --interactive docker.io/library/bash -- xargs wget -qO /dev/stdout \
  | sudo yaman c run --interactive --runtime microvm quay.io/aptible/alpine -- head -n 7
Weather report: Brussels, Belgium

     \  /       Partly cloudy
   _ /"".-.     17 °C
     \_(   ).   ↘ 24 km/h
     /(___(__)  10 km
                0.0 mm
```

From a user perspective, the fact that the second container has been created
with a virtual machine is an implementation detail, and that's what I wanted to
achieve with this work.

Under the hood, the following steps are performed:

1. A first _interactive_ container is created with the default runtime
   ([Yacr][]). This container uses the [official Bash Docker
   image][bash-docker-image]. It reads the value `wttr.in` from `stdin` (that's
   why it has to be interactive) and executes `wget -qO /dev/stdout wttr.in`
   (which behaves like `curl wttr.in` but `curl` wasn't installed in the Docker
   image).
2. The output of the first container is redirected to the second container. The
   first container exits and gets automatically removed because `--rm` was
   specified.
3. The second container is also interactive but it uses the microvm runtime and
   an [Alpine image from Quay.io][alpine-image]. When the microvm runtime is
   invoked to create the container, it creates a virtual machine using QEMU and
   spawns a `virtiofsd` process to share the root filesystem with this VM.
4. In the VM, the `init` process executes `head -n 7`, which returns the first 7
   lines of data received on `stdin`. The result is printed on the host's
   standard output (`stdout`) and the second container exits.

The `--rm` option was not specified when we ran the second container, meaning we
can still retrieve it by listing all the containers. From there, we can fetch
the container's logs (or inspect it) until we delete it:

```console
$ sudo yaman c ls -a
CONTAINER ID                       IMAGE                           COMMAND     CREATED          STATUS                      PORTS
26127b728da94fd7a184549f2c0f586c   quay.io/aptible/alpine:latest   head -n 7   15 seconds ago   Exited (0) 12 seconds ago

$ sudo yaman c logs 26127b728da94fd7a184549f2c0f586c
Weather report: Brussels, Belgium

     \  /       Partly cloudy
   _ /"".-.     +22(24) °C
     \_(   ).   ↓ 7 km/h
     /(___(__)  10 km
                0.0 mm

$ sudo yaman c inspect 26127b728da94fd7a184549f2c0f586c | jq '.Shim.Runtime'
"microvm"
```

Of course the example above was using [Yaman][] but we could also reproduce the
same example[^4] with our good ol' Docker friend 😉

[^4]: It is possible to fully reproduce the example with [these scripts][docker-scripts].

```console
$ echo 'wttr.in' \
  | docker run --interactive bash xargs wget -qO /dev/stdout \
  | docker run --runtime=microvm --interactive alpine head -n 7
Unable to find image 'bash:latest' locally
Unable to find image 'alpine:latest' locally
Digest: sha256:686d8c9dfa6f3ccfc8230bc3178d23f84eeaf7e457f36f271ab1acc53015037c
Status: Downloaded newer image for alpine:latest
Digest: sha256:b3abe4255706618c550e8db5ec0875328333a14dbf663e6f1e2b6875f45521e5
Status: Downloaded newer image for bash:latest
Weather report: Freiburg im Breisgau, Germany

      \   /     Sunny
       .-.      15 °C
    ― (   ) ―   ↙ 4 km/h
       `-’      10 km
      /   \     0.0 mm

$ docker ps -a
CONTAINER ID   IMAGE     COMMAND       CREATED             STATUS                          PORTS     NAMES
5976d2c7fe86   alpine    "head -n 7"   About a minute ago  Exited (0) About a minute ago             jolly_shannon

$ docker inspect 5976d2c7fe86 | jq '.[0].HostConfig.Runtime'
"microvm"
```

Now, what if we want to spawn an interactive shell? Well, that's possible too!

<script id="asciicast-hJM4rCpJqZiKparZNh9CyDpZs" src="https://asciinema.org/a/hJM4rCpJqZiKparZNh9CyDpZs.js" async></script>

Unfortunately, this terminal mode does not fully work with Docker (yet) 😞

It turns out that handling IOs isn't trivial, especially when a virtual machine
is involved. The microvm runtime uses some tricks to redirect IOs correctly
(e.g. it spawns a [special process][redirect-stdio] and uses [named pipes][] on
the QEMU side) but the terminal mode is handled differently[^5].

[^5]: The terminal mode works fine with Yaman and I only noticed the problem
    with Docker when I wrote this blog post, sigh.

In terms of limitations, the virtual machines created by the microvm runtime
don't have any network access at the moment. In fact, the kernel is built
without its network stack. This is probably something I'll add in the future.

As for the next steps, I'd like to play with [KVM][], which none of my "Linux
environments" give me access to at the moment. I suppose that would be better
performance-wise although I haven't considered performances at all (good thing
it's an educational project, hehe).

Overall, I am pretty happy with the results and I learned a few things. It was
especially fun to play with the Linux kernel again!

[alpine-image]: https://quay.io/repository/aptible/alpine
[bash-docker-image]: https://hub.docker.com/_/bash
[config-x86_64]: https://github.com/willdurand/containers/blob/ac6e8c93bec1d6188814049306c7cbad889297f9/extras/microvm/config-x86_64
[crun]: https://github.com/containers/crun
[docker-scripts]: https://github.com/willdurand/containers/tree/ac6e8c93bec1d6188814049306c7cbad889297f9/extras/docker/scripts
[init.c]: https://github.com/willdurand/containers/blob/ac6e8c93bec1d6188814049306c7cbad889297f9/extras/microvm/init.c
[kata containers]: https://katacontainers.io/
[kernel parameters]: https://www.kernel.org/doc/html/v4.14/admin-guide/kernel-parameters.html
[krunvm]: https://github.com/containers/krunvm
[kvm]: https://www.redhat.com/en/topics/virtualization/what-is-KVM
[libkrun]: https://github.com/containers/libkrun
[libkrunfw]: https://github.com/containers/libkrunfw
[make-run]: https://github.com/willdurand/containers/blob/ac6e8c93bec1d6188814049306c7cbad889297f9/extras/microvm/Makefile#L89-L113
[microvm]: https://github.com/willdurand/containers/blob/main/cmd/microvm/README.md
[named pipes]: https://man7.org/linux/man-pages/man7/fifo.7.html
[oci-config]: https://github.com/opencontainers/runtime-spec/blob/v1.0.2/config.md
[patch-001]: https://github.com/willdurand/containers/blob/ac6e8c93bec1d6188814049306c7cbad889297f9/extras/microvm/patches/001-poweroff-when-init-is-killed.patch
[patch-002]: https://github.com/willdurand/containers/blob/ac6e8c93bec1d6188814049306c7cbad889297f9/extras/microvm/patches/002-downgrade-reboot-messages.patch
[post-containers]: {% post_url 2022-06-21-deep-dive-into-containers %}
[qcow2]: https://en.wikipedia.org/wiki/Qcow
[qemu-microvm-docker]: https://mergeboard.com/blog/2-qemu-microvm-docker/
[qemu-microvm]: https://qemu.readthedocs.io/en/latest/system/i386/microvm.html
[qemu]: https://www.qemu.org/
[redirect-stdio]: https://github.com/willdurand/containers/blob/ac6e8c93bec1d6188814049306c7cbad889297f9/cmd/microvm/redirect_stdio.go
[virtio-fs]: https://virtio-fs.gitlab.io/
[virtiofsd]: https://gitlab.com/virtio-fs/virtiofsd
[wttr.in]: https://wttr.in
[yacr]: https://github.com/willdurand/containers/blob/main/cmd/yacr/README.md
[yacs]: https://github.com/willdurand/containers/blob/main/cmd/yacs/README.md
[yaman]: https://github.com/willdurand/containers/blob/main/cmd/yaman/README.md
