---
layout: post
title: "Deep dive into containers"
location: "Freiburg, Germany"
image: /images/posts/2022/06/containers-social.webp
mastodon_id:
tweet_id:
credits: Photo used on social media by [ines mills](https://unsplash.com/@inesmills).
---

It (almost) all started with [this talk from Liz Rice][containers-go] that I
found in my Pocket list. I spent some time on a Sunday afternoon to write the
same code and decided to study more in-depth. I wanted to better understand what
was behind containers and how the different technologies interacted with each
other.

That was [a month ago][] or so and things got out of control pretty quickly 😅
Given there are many talks and articles about containers already, this article
is more of a "Show and Tell" in which I describe what I've poked around.

## Yacr: Yet another container runtime

At this level, there is no concept of images, registries, volumes, etc. An [Open
Container Initiative][] (OCI)-compliant runtime takes an identifier and a
"bundle" as input. A bundle is a folder that contains a `config.json` file and a
root filesystem ("rootfs").

I started by updating the code I had initially written to build a minimal (and
insecure[^1]) runtime named [Yacr][]. I learned a lot of low-level information
and I was super happy when [Docker was able to use my very own
runtime][yacr-docker]. Yacr works [with containerd][yacr-containerd], too!

As for the implementation, I followed the [runtime spec][], which is a rather
high-level description of a runtime and not really a specification _per se_. In
fact, the runtime I wrote had to be "[runc][]-compliant" in order to be used by
other tools ([runc][] is the reference implementation of the runtime spec).

I then looked into [container shims][].

[^1]: For instance, `cgroups`, capabilities and seccomp are not supported.

## Yacs: Yet another container shim

When a runtime starts a container, it often uses [`exec(3)`][exec] to replace
itself with the actual container process. This is a problem because (1) standard
input/output are no longer (easily) available, and (2) it is difficult to know
when the process exits and why.

While it might be possible to poll `/proc` to solve (2), that wouldn't solve
(1). We could make the runtime a long-running process but that does not seem
ideal either. The [concept of container shims][] has been introduced to solve
these two problems (and more) in an elegant manner.

Shims sit between a container manager and a container runtime. In principle, a
shim invokes an OCI runtime to create/start containers. In addition, shims solve
the two problems stated above by:

1. becoming a [subreaper][prctl], which allows them to reap (adopt) any child
   processes created by their own child processes (e.g. the runtime). This, in
   turns, allows shims to be notified when child processes exit
2. keeping open the container's input/output. For instance, my implementation
   creates FIFOs (named pipes) so that it is possible to interact with the
   container process at any time

The prototype I implemented is named [Yacs][] and it uses the [Yacr][] runtime
by default. Yacs _should_ work with any OCI runtime but I only tried with `yacr`
and `runc`.

### Example

Yacs provides an HTTP API _via_ a unix socket because that was easy to
implement. In the example below, we create a new container with `yacs`, which
will invoke the runtime (`yacr`) to create the container.

As per the [runtime spec][], the container is only created, not started yet,
which is why we see the `yacr create container` process under the `yacs` process
in the `ps` output. The `yacr` process waits for the "start" command.

```console
$ yacs --bundle=/tmp/alpine-bundle --container-id=alpine
/home/gitpod/.run/yacs/alpine/shim.sock

$ ps auxf
USER    PID    STAT  START  COMMAND
[...]
gitpod  44458  Ssl   22:01  yacs --bundle=/tmp/alpine-bundle --container-id=alpine
gitpod  44488  Sl    22:01   \_ yacr --log-format json --log /home/gitpod/.run/yacs/alpine/yacr.log create container alpine --root /home/gitpod/.run/yacr --bundle /tmp/alpine-bundle
```

When we ask the shim to start the container using the HTTP API, it invokes the
runtime again to start the container. At this point, the container process (`sh /hello-loop.sh` in this example) should be running under the `yacs` (subreaper)
process (see `ps` output below).

```console
$ curl -X POST -d 'cmd=start' --unix-socket /home/gitpod/.run/yacs/alpine/shim.sock http://shim/
{
  "id": "alpine",
  "runtime": "yacr",
  "state": {
    "ociVersion": "1.0.2",
    "id": "alpine",
    "status": "running",
    "pid": 44488,
    "bundle": "/tmp/alpine-bundle"
  },
  "status": {}
}

$ ps auxf
USER    PID    STAT  START  COMMAND
[...]
gitpod  44458  Ssl   22:01  yacs --bundle=/tmp/alpine-bundle --container-id=alpine
gitpod  44488  S     22:01   \_ sh /hello-loop.sh
gitpod  55758  S     22:02       \_ sleep 1
```

Yacs saves the output of the container process in a JSON file (called a "log
file") to read the output after the container process has died (useful for
container managers). We can use the HTTP API to fetch these logs:

```console
$ curl --unix-socket /home/gitpod/.run/yacs/alpine/shim.sock http://shim/logs
[...]
{"m":"Hello!","s":"stdout","t":"2022-06-12T11:51:44.947554491Z"}
{"m":"Hello!","s":"stdout","t":"2022-06-12T11:51:45.948493454Z"}
```

Each line in a log file is a JSON object with the output message (`m`), the
stream (`s`) and the timestamp (`t`). Container managers can then implement a
`logs` command that can read this log file and print each message to the right
stream (`stdout` or `stderr`), with or without a timestamp appended 😎

Yacs also supports [console sockets][]. In which case, logs are not available.
The HTTP API supports [other commands to send signals to a container, delete it
and even terminate the shim itself][yacs].

## Yaman: Yet another (container) manager

With a somewhat functional runtime and a shim that could do a few things
correctly, I decided to look into container managers (like [Docker][] and
[Podman][]).

My initial idea was to write the minimum amount of code to use an existing
Docker image with the two tools I had written and without Docker. Ha, ha.

I ended up writing a [daemon-less container manager that creates and manages
rootless containers][yaman]. These containers can even reach the Internet (which
isn't a given)! I tried to make container IOs work correctly as well, with
support for interactive mode and [pseudo-terminal][pty].

It was actually "simpler" to implement a daemon-less manager than implementing a
daemon with an API and a client CLI to talk to it. I also find this approach
more elegant in general but that's my personal opinion.

### Examples

The first example pipes `wttr.in` to a first container that reads from its
standard input (`stdin`) in order to call `wget`, which will print its output to
`stdout` (workaround for not having `curl` in the container). This first
container should be automatically removed when it is done because the `--rm`
option is specified).

The output of the first container is piped into a second container (running an
"alpine" image from a different registry), which will only take the first 7
lines of the input it receives. We then get the final output of these commands
into our terminal 🎉

```console
$ echo 'wttr.in' \
  | yaman c run --rm --interactive docker.io/library/alpine -- xargs wget -qO /dev/stdout \
  | yaman c run --interactive quay.io/aptible/alpine -- head -n 7
Weather report: Freiburg im Breisgau, Germany

   _`/"".-.     Thundery outbreaks possible
    ,\_(   ).   17 °C
     /(___(__)  ↘ 4 km/h
      ⚡‘‘⚡‘‘  9 km
      ‘ ‘ ‘ ‘   0.0 mm

$ yaman c ls -a
CONTAINER ID                       IMAGE                            COMMAND       CREATED          STATUS                      NAME
10bddbfd480c46ffbbc8a5005134e1d7    quay.io/aptible/alpine:latest   head -n 7     35 seconds ago   Exited (0) 35 seconds ago   bold_zhukovsky

$ yaman c logs --timestamps 10bddbfd480c46ffbbc8a5005134e1d7
2022-06-21T07:04:06Z - Weather report: Freiburg im Breisgau, Germany
2022-06-21T07:04:06Z -
2022-06-21T07:04:06Z -    _`/"".-.     Thundery outbreaks possible
2022-06-21T07:04:06Z -     ,\_(   ).   17 °C
2022-06-21T07:04:06Z -      /(___(__)  ↘ 4 km/h
2022-06-21T07:04:06Z -       ⚡‘‘⚡‘‘  9 km
2022-06-21T07:04:06Z -       ‘ ‘ ‘ ‘   0.0 mm
```

The second example below shows that we can re-attach a container started in
detached mode. In addition to that, the container is created by [runc][] and we
specify a custom `hostname`:

```console
$  yaman c run --rm --runtime runc --hostname ubuntu-demo -it -d docker.io/library/ubuntu
47988b8c7bde4f3d8e84568faea3e3f4

$ yaman c attach 47988b8c7bde4f3d8e84568faea3e3f4
root@ubuntu-demo:/# tty
/dev/pts/0
root@ubuntu-demo:/# ls
bin   dev  home  lib32  libx32  mnt  proc  run   srv  tmp  var
boot  etc  lib   lib64  media   opt  root  sbin  sys  usr
root@ubuntu-demo:/# cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=22.04
DISTRIB_CODENAME=jammy
DISTRIB_DESCRIPTION="Ubuntu 22.04 LTS"
```

### Internals

Under the hood, this container manager, named [Yaman][], relies on
[fuse-overlayfs][] in rootless mode, native OverlayFS in rootfull mode (e.g.
when Yaman is executed with `sudo`) and [slirp4netns][] for the network layer.

That has been a lot of work[^2] and I took many shortcuts and introduced a few
[hacks][] to have a functional tool in the end. For example, images and layers
management isn't great to say the least. Yaman is full of limitations and
probably bugs as well. Some of the known limitations have been documented. The
other ones are yet to be found 🙈

Thanks to the power of abstractions and specifications, it is possible to use
any OCI-compliant runtime with Yaman. That should make the whole thing a bit
more reliable and secure[^3] 😬

[^2]: Both the [distribution spec][] and [image spec][] have been helpful while implementing Yaman.
[^3]: No.

## Conclusion

I learned so much recently! If you want to know more about _my_ work, you can
find [Yacr][], [Yacs][] and [Yaman][] on [GitHub][repo]. Feel free to try them
out on [Gitpod][] or locally using [Vagrant][].

I have been using Docker for many years without necessarily questioning why
things were what they were or how this whole thing was actually working under
the hood.

Now when I have a more specific question about Docker (or [containerd][] or
Podman), I can follow the source code and usually think "oh, _that_ makes sense"
or "ha, yeah, clever!". This happened a few times lately and that put a smile on
my face every time.

And that's enough to consider this deep dive a good investment of my free time! ❤️

---

[containers-go]: https://www.youtube.com/watch?v=Utf-A4rODH8
[a month ago]: https://twitter.com/couac/status/1528476035024568322
[yacr]: https://github.com/willdurand/containers/blob/main/cmd/yacr/README.md
[yacr-docker]: https://github.com/willdurand/containers/blob/11aa764816f040b8dd1306edc1c20cee257d7961/cmd/yacr/README.md#getting-started-with-docker
[yacr-containerd]: https://github.com/willdurand/containers/tree/11aa764816f040b8dd1306edc1c20cee257d7961/cmd/yacr#getting-started-with-containerd
[runtime spec]: https://github.com/opencontainers/runtime-spec/
[runc]: https://github.com/opencontainers/runc/
[yacs]: https://github.com/willdurand/containers/blob/main/cmd/yacs/README.md
[concept of container shims]: https://groups.google.com/g/docker-dev/c/zaZFlvIx1_k
[exec]: https://man7.org/linux/man-pages/man3/exec.3.html
[open container initiative]: https://opencontainers.org/
[prctl]: https://man7.org/linux/man-pages/man2/prctl.2.html
[console sockets]: https://github.com/containerd/containerd/discussions/5789
[docker]: https://docs.docker.com/
[podman]: https://docs.podman.io/en/latest/
[container shims]: https://container42.com/2022/01/10/shim-shiminey-shim-shiminey/
[fuse-overlayfs]: https://github.com/containers/fuse-overlayfs
[slirp4netns]: https://github.com/rootless-containers/slirp4netns
[yaman]: https://github.com/willdurand/containers/blob/main/cmd/yaman/README.md
[pty]: https://man7.org/linux/man-pages/man7/pty.7.html
[containerd]: https://containerd.io/
[distribution spec]: https://github.com/opencontainers/distribution-spec
[image spec]: https://github.com/opencontainers/image-spec
[repo]: https://github.com/willdurand/containers
[gitpod]: gitpod.io/
[vagrant]: https://www.vagrantup.com/
[hacks]: https://github.com/willdurand/containers/pull/81
