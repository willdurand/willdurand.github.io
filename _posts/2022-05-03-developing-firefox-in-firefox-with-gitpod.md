---
layout: post
title: "Developing Firefox in Firefox with Gitpod"
location: "Freiburg, Germany"
image: /images/posts/2022/05/gitpod-firefox-social.webp?v=20220503
tags: [mozilla]
mastodon_id: 108237109619474962
---

[Gitpod][] provides Linux-based development environments on demand along with a
web editor frontend (VS Code). There is apparently no limit on what you can do
in a [Gitpod workspace][], e.g., I ran my own [toy kernel in QEMU in the
browser][tweet-gitpod-qemu].

I like Gitpod because it...

- avoids potential issues when setting up a new project, which is great for the
  maintainers (e.g., it is easier to reproduce an issue when you have access to
  the same environment) and the newcomers (e.g., no fatal error when trying to
  contribute for the first time)
- allows anyone to have access to a (somewhat) powerful machine because not
  everyone can afford a MacBook Pro. I suppose one needs a pretty reliable
  Internet connection, though

## Motivations

My main machine runs MacOS. I also have a Windows machine on my desk (useful to
debug [annoying Windows-only intermittent failures][intermittent]), which I
access with Microsoft Remote Desktop.

![](/images/posts/2022/05/remote-desktop.webp)
_It looks like Gitpod, runs like Gitpod, and quacks like Gitpod but it isn't Gitpod!_
{:.with-caption}

Except my ever growing collection of single-board computers, I don't have a
Linux-based machine at home^W work, though. I haven't used Virtual Machines on
Apple Silicon yet and I'd rather keep an eye on [Asahi Linux][] instead.

This is why I wanted to give Gitpod a try and see if it could become my Linux
environment for working on Firefox. Clearly, this is a nice to have for me (I
don't necessarily need to build Firefox on Linux) but that might be useful to
others.

Assuming a Gitpod-based setup would work for me, this could possibly become a
strong alternative for other contributors as well. Then, _mayyybe_ I could start
a conversation about it internally in the (far) future.

Note that this isn't a novel idea, Jan Keromnes was already working on a similar
tool called ["Janitor" for Mozilla needs in 2015][yt-janitor].

## Firefox development with Gitpod = ❤️

I recently put together [a proof of concept][gitpod-firefox-dev] and played
with it since then. This GitHub repository contains the Gitpod configuration
to checkout the Firefox sources as well as the tools required to build Firefox.

It takes about 7 minutes to be able to run `./mach run` in a fresh workspace
(artifact mode). It is not super fast, although I already improved the initial
load time by using a [custom Docker image][docker-gitpod-firefox-dev]. It is
also worth mentioning that re-opening an existing workspace is much faster!

![](/images/posts/2022/05/gitpod-mach-run.webp)
_`./mach run` executed in a Gitpod workspace_
{:.with-caption}

Gitpod provides a Docker image with [X11 and VNC][], which I used as the base
for my custom Docker image. This is useful to interact with Firefox as well as
observing some of the tests running.

![](/images/posts/2022/05/gitpod-mach-test.webp)
_A "mochitest" running in a Gitpod workspace_
{:.with-caption}

I don't know if _this_ is the right approach, though. My understanding is that
Gitpod works best when its configuration lives next to the sources. For Firefox,
that would mean having the configuration in the official Mozilla [Mercurial][]
repositories but then we would need _hgpod.io_ 😅

On the other hand, we develop Firefox using a [stacked diff][] workflow.
Therefore, we probably don't need most of the VCS features and [Gitpod does not
want to be seen as an online IDE][gitpod-jetbrains] anyway. I personally rely
on `git` with the excellent [`git-cinnabar` helper][cinnabar], and [moz-phab][]
to submit patches to Phabricator. Except for the latter, which can easily be
installed with `./mach install-moz-phab`, these tools are already available in
Gitpod workspaces created with [my repository][gitpod-firefox-dev].

In terms of limitations, cloning [mozilla-unified][] is the most time-consuming
task at the moment. Gitpod has a feature called [Prebuilds][] that could help
but I am not sure how that would work when the actual project repository isn't
the one that contains the Gitpod configuration.

In case you're wondering, I also started a full build (no artifact) and it took
about 40 minutes to finish 🙁 I was hoping to have better performances out of
the box even if it isn't _that_ bad. For comparison, it takes [~15min on my
MacBook Pro with M1 Max][tweet-m1-max] (and 2 hours on my previous Apple
machine).

There are other things that I'd like to poke around. For instance, I would love
to have [`rr`][rr] support in Gitpod. I gave it a quick try and it does not seem
possible so far, maybe because of [how Docker is configured][rr-docker].

```
gitpod /workspace/gitpod-firefox-dev/mozilla-unified (bookmarks/central) $ rr record -n /usr/bin/ls
[FATAL /tmp/rr/src/PerfCounters.cc:224:start_counter() errno: EPERM] Failed to initialize counter
```

After a few messages exchanged on Twitter, [Jan Keromnes][jan] (yeah, same as
above) from Gitpod filed a [feature request to support `rr`][feat-req-gitpod] 🤞

## Next steps

As I mentioned previously, this is a proof of concept but it is already
functional. I'll personally continue to evaluate this Linux-based development
environment. If it gets `rr` support, this might become my debugging
environment of choice!

Now, if you are interested, you can go ahead and [create a new
workspace][open-in-gitpod] automatically. Otherwise please reach out to me and
let's discuss!

One more thing: Mozilla employees (and many other Open Source contributors)
qualify for the [Gitpod for Open Source][gitpod-opensource] program.

[asahi linux]: https://asahilinux.org/
[cinnabar]: https://github.com/glandium/git-cinnabar
[docker-gitpod-firefox-dev]: https://hub.docker.com/r/willdurand/gitpod-firefox-dev
[feat-req-gitpod]: https://github.com/gitpod-io/gitpod/issues/9687
[gitpod workspace]: https://www.gitpod.io/docs/workspaces
[gitpod-firefox-dev]: https://github.com/willdurand/gitpod-firefox-dev
[gitpod-jetbrains]: https://www.gitpod.io/blog/gitpod-jetbrains
[gitpod-opensource]: https://www.gitpod.io/blog/gitpod-for-opensource
[gitpod]: https://gitpod.io/
[intermittent]: https://bugzilla.mozilla.org/show_bug.cgi?id=1761550
[issue-rr]: https://github.com/rr-debugger/rr/issues/2952
[mercurial]: https://www.mercurial-scm.org/
[moz-phab]: https://moz-conduit.readthedocs.io/en/latest/phabricator-user.html#setting-up-mozphab
[mozilla-unified]: https://mozilla-version-control-tools.readthedocs.io/en/latest/hgmozilla/unifiedrepo.html
[open-in-gitpod]: https://gitpod.io/#https://github.com/willdurand/gitpod-firefox-dev
[prebuilds]: https://www.gitpod.io/docs/prebuilds
[rr-docker]: https://github.com/rr-debugger/rr/wiki/Docker
[rr]: https://github.com/rr-debugger/rr
[stacked diff]: https://jg.gg/2018/09/29/stacked-diffs-versus-pull-requests/
[tweet-gitpod-qemu]: https://twitter.com/couac/status/1494807135577853954
[tweet-m1-max]: https://twitter.com/couac/status/1463582168450539541
[x11 and vnc]: https://www.gitpod.io/blog/native-ui-with-vnc
[yt-janitor]: https://www.youtube.com/watch?v=5sNDMIh-iVw
