---
layout: post
title: "Propel and Symfony: a year ago"
location: Zürich, Switzerland
tags: [PHP]
redirect_from:
  - /2012/04/25/propel-and-symfony2-a-year-ago/
updates:
  - date: 2022-04-18
    content: I proofread this article and updated some links.
---

Did you know that the [PropelBundle][] was part of the Symfony core? Yes, at the
very beginning. It was moved out some time after. Basically, I didn't create the
_PropelBundle_ but I started to learn Symfony by using it.

> Hi,
>
> You seem to work on the PropelBundle actively, and that's great news. This
> bundle is under my account right now because it is orphan. But if you want
> to take care of the maintenance of it, then I think it's time for your fork
> to become the official repository for the bundle. What do you think?
>
> Fabien

To be honest, this bundle didn't really work and I spent a fair amount of time
to learn Symfony internals, learn Propel 1.6 internals and find ways to make
this bundle work 😅 It was fun! After a few weeks, the bundle became useful and,
at the same time, I joined [e-TF1][] where I had the opportunity to work with
both Symfony and Propel. I could use this bundle in production!

A few months later, I accepted to take the lead of the Propel project and I
added the PropelBundle as an official Propel project. It was the best choice
because people helped me a lot to improve this bundle, and now it is fully
compatible with Symfony (kudos to [Toni](https://github.com/havvg) who is the
PropelBundle manager). To spread the word, I also wrote exhaustive [documentation
about Propel and Symfony](http://www.propelorm.org/documentation/#working_with_symfony2).

Making this bundle reliable and trustful was the hardest part of the work. Even
if the bundle worked great and even if we were there to answer questions or to
fix issues, it was tricky to get more users. That's why I asked Fabien to create
a [Propel Bridge](https://github.com/symfony/propel1-bridge) in Symfony. It was
the first step to avoid comments like "it's not the default ORM, lalala". At
the same time, Symfony took the decision to be a _View Controller_ framework
without any _Model_ layer bundled by default.

**Today**, I'm proud to announce that the last step has been unlocked thanks to
[Joseph](https://github.com/rouffj). **Propel has its own chapter in the official
Symfony book**, which means you have to think about which _Model_ layer to use
now. There is no more excuse to not try Propel in Symfony or to use Doctrine by
default and not by choice.

Try Propel, seriously! It could fit your needs depending on what you expect. Some
great bundles already support Propel (like the FOSUserBundle). Also please avoid
comments like "Doctrine is much nicer", which make little sense. Why is it much
nicer? I never got any good arguments in favor of Doctrine I didn't already know.
I can hear everything that is constructive. I used Doctrine for more than six
months, both ORM and ODM (MongoDB). I have strong arguments against it but I also
like some parts of it. Who can say the same thing about Propel?

Now, you have the choice. It's up to you. Thanks!

[PropelBundle]: https://github.com/propelorm/PropelBundle
[e-TF1]: https://en.wikipedia.org/wiki/TF1