---
layout: post
title: "Propel, And Symfony2 A Year Ago"
location: Zürich, Switzerland
tags: [ PHP ]
---

Did you know that the [PropelBundle](http://github.com/propelorm/PropelBundle) was part of the
Symfony2 core? Yes, at the very beginning, and it has been dropped after. So basically, I didn't
create the PropelBundle but started to learn Symfony2 by using it.

> Hi,
>
> You seem to work on the PropelBundle actively, and that's great news. This bundle is under my account right now because it is orphan. But if you want to take care of the maintenance of it, then I think it's time for your fork to become the official repository for the bundle. What do you think?
>
> Fabien

To be honest, this bundle didn't really work, and I spent a lot of time to both learn Symfony2 internals,
Propel 1.6 internals, and how to fix this bundle. It was fun. After few weeks, the bundle became interesting
to use, and in the same time, I joined e-TF1 where I had the opportunity to work with both Symfony2, and Propel,
for real.

Few months later, I decided to take the lead of the Propel project, and I added the PropelBundle as an official
Propel project. It was the best choice because people helped me a lot to improve this bundle, and now it is
fully compatible with Symfony2 (kudos to [Toni](https://github.com/havvg), the PropelBundle manager).
To spread the word, I also wrote quite complete [documentation about Propel, and Symfony2](http://www.propelorm.org/documentation/#working_with_symfony2).

To be reliable was the hardest part of the work, even if the bundle worked great, and even if we were there
to answer questions, or to fix issues. That's why I asked Fabien to create a [Propel Bridge](https://github.com/symfony/Propel1Bridge) in Symfony2. It was the first step to avoid comments like "it's not the default ORM, lalala".
In the same time, Symfony2 took the decision to be a _View Controller_ Framework, without any _Model_ layer bundled
by default.

**Today**, I'm proud to announce that the last step has been unlocked thanks to [Joseph](https://github.com/rouffj).
**Propel has its own [chapter in the official Symfony2 book](http://symfony.com/doc/master/book/propel.html)** which means you have to think about which _Model_ layer to use now.
No more excuse to not try Propel in Symfony2, or to use Doctrine2 by default, and not by choice.

Try Propel, really! It could fit your needs depending on what you expect. Some great bundles already support Propel
(like the FOSUserBundle). And please, avoid comments like "Doctrine2 is much nicer" which make no sense. Why is it much nicer?
I never got any good arguments in favor of Doctrine2 I didn't already know by myself. I can hear everything which is constructive.
I used Doctrine2 for more than six months, both ORM, and ODM (MongoDB). I have strong arguments against it, but I also
like some parts of it. Who can say the same thing about Propel?

Now, you have the choice, it's up to you! But, give Propel a chance before to complain about it, or to comment it.
