---
layout: post
location: Clermont-Fd Area, France
tldr: false
audio: false
title: "On capifony and its Future"
---

> Hi! This is your captain speaking.
>
> **capifony** is based on *Capistrano v2.x* and will stick to this version
> (i.e. capifony is feature-frozen, and will only accept bug fixes).
>
> At the time of writing, [*Capistrano v3*](http://capistranorb.com/) is the
> current major version, and *capifony is not compatible* with it.
>
> Don't worry, there is a plugin for that! Using *Capistrano v3* +
> [*capistrano/symfony*](https://github.com/capistrano/symfony) (heavily
> inspired by *capifony*) may be the way to go for new projects!
>
> Cheers!

Dear capifony users/friends,

As of yesterday (2015-04-10), this is the message you can read on the [capifony
GitHub's page](https://github.com/everzet/capifony). Indeed, capifony is now
**officially feature-frozen**, and we will **only accept bug fixes**. **It does
not mean it is no longer active** though.

Over the years, capifony became pretty stable, especially with the addition of
[tests](https://github.com/everzet/capifony/tree/master/spec). Even if it is not
perfect, it ensures a certain confidence. Recent bug reports are mostly edge
cases that are tricky to solve, and that we should take care of.

Under the hood, capifony leverages Capistrano v2, which is not the latest
version. [Capistrano v3](http://capistranorb.com/) has been released in late
2013, and is known as the latest major version of Capistrano. But, it has been
entirely rewritten, and obviously, breaks backward compatibility.

We [discussed the creation of capifony
v3](https://github.com/everzet/capifony/pull/437) but due to various reasons, a
[symfony plugin](https://github.com/capistrano/symfony) has been created and the
work on _capifony v3_ did not get merged into capifony. The plugin has been
built from scratch and is what could have been known as _capifony v3_, [without
tests](https://github.com/capistrano/symfony/issues/27) unfortunately. That is
one of the reasons why I did not write this article earlier... But now, it is time
to move forward!

### Now What?

* If you use capifony on an existing project, **no need to upgrade**. It might be
 complicated, and you could introduce unwanted bugs. If your deployment process works
 for you, no need to change it.

* If you start a new project, you can use Capistrano v3 and its symfony plugin.
  However, since the Capistrano era, **tools and practices evolved a lot**, and
  [Capistrano might not be the right tool for
  you](https://groups.google.com/forum/#!topic/capistrano/nmMaqWR1z84). I would
  recommend to look at alternatives and/or new ways to deploy your applications.
