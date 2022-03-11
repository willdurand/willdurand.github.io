---
layout: post
title: Designing software by naming things
location: Clermont-Fd Area, France
audio: false
redirect_from:
  - /2012/01/24/designing-a-software-by-naming-things/
---

> There are only two hard things in Computer Science: cache invalidation and
> naming things.
>
> _Phil Karlton_

**Naming things** is hard, that's right, but finding the **right names** is even
harder!

When I start the process of creating a new application, the first step is often
to rely on some sort of specifications, e.g., [UML][] diagrams. This forces me
to think before to code, what a nice idea!

A _class diagram_ is probably the most useful UML diagram. A first step could be
to find package names and see how I can connect them. This will give me the main
components of the application like the _controllers_, _services_ or _models_ for
example. At this level, separating concerns is usually straightforward. The
_Model-View-Controller_ (MVC) design pattern is a great example.

Once the main packages have been defined, I need to find class names. To help me
find the right names, I tend to identify **interfaces** first. An interface
describes a contract between two components. Thinking in terms of interfaces
forces me to think about the interactions between components. Interface-based
programming is a nice way to design an application.

My rule of thumb is: when I am not able to find a name for a class, I ask myself
whether this class makes sense, or if I can decouple things a bit more. A
"wrong" or "obscure" name often leads to errors. When I am not satisfied with
some naming, it is usually because something is not quite right and I try to
understand why.

To get better at naming things, I take inspiration by reading good code. Thanks
to [GitHub][], it's easy to find and read code written by talented folks. As a
PHP developer, I often use [Symfony][] naming in my own projects.

This is how I design software by naming things :)

[github]: http://www.github.com
[symfony]: http://www.github.com/symfony/symfony
[uml]: http://en.wikipedia.org/wiki/Unified_Modeling_Language
