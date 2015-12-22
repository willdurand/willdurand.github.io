---
layout: post
title: Designing A Software By Naming Things
location: Clermont-Fd Area, France
---

> There are only two hard things in Computer Science: cache invalidation and naming things.
>
> _Phil Karlton_

**Naming things** is hard, that's right, but **naming things** by their **right names** is even harder!

When you start writing a new application, the first step is often to rely on some
[UML](http://en.wikipedia.org/wiki/Unified_Modeling_Language) diagrams. It allows you
to think before to code, what a nice idea!

Even if use cases or user stories are essential, a **class diagram** is probably the most useful UML diagram.
A first step can be to find packages names (more or less _sub-namespaces_), and to connect them.
It will give you the main components of your application like the _controllers_, the _services_,
the _model_, or the _configuration_ part for instance. It's quite easy to separate concerns at this level.
If you use the well-known _Model View Controller_ design pattern, you almost ever know your packages.

Once you've defined your packages, you have to find names for your classes.
To help you finding the right names, you can write **interfaces** first. An interface describes a contract
between two entities. This is not related to naming, but if you start by writing interfaces, you start
by thinking about interactions between your components. Program to interface is a nice way to design
an application, and reduces coupling but it's not the purpose of this post.

My Golden Rule is: **if you're not able to find a name for a class, then ask yourself if this class makes sense**,
or if you can decouple things a bit more.

A wrong name or a non-explicit name often leads to errors. If you're not satisfied with your naming,
then think again because you probably missed something. Inspire yourself by reading good code, thanks to
[GitHub](http://www.github.com), it's easy to browse awesome code. As a PHP developer, I often use
[Symfony2](http://www.github.com/symfony/symfony) naming in my own projects.

By following these advices, you'll build a software with a **better separation of concerns**, and
each component will be decoupled, and will own its own logic, nothing more. That way, you'll be able
to unit test your application without any effort. And, as you have a good separation of concerns, each
unit test can cover a use case.

This is my last point, always write unit tests that make sense, and think them as use cases. Take a look
at the [Propel2 test suite](http://www.github.com/propelorm/Propel2/tree/master/tests/Propel/Tests), each test
method has a readable name which explains a use case: `testIsValidReturnsFalseIfNoUserFound()` is really
explicit for instance. Don't forget, **the best documentation you can write is tests**.
