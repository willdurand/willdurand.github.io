---
layout: post
title: "Component Driven Development: it's like Lego!"
location: Clermont-Fd Area, France
tags: [PHP]
updates:
  - date: 2022-03-15
    content: I proofread this article, fixed some links and redrew the figure.
---

Did you ever hear about **Component-Based Development**? Maybe about **Component
Driven Development**? Both concepts are the same, and if you've worked with
_Symfony_, _Spring_ or similar frameworks, then chances are you've already done
**Component Driven Development** (**CDD**).

It's all about **separation of concerns**. You design components with their own
logic. Each component does **one thing well** and **only one thing** (that is
also the Unix philosophy). Separating business logic in self-contained
components requires to focus on interactions between components. In other words,
you have to think in terms of interfaces and boundaries.

[UML][] provides a **component diagram** that allows you to easily identify the
components, interfaces and their relations. This could be a useful tool. In a
UML component diagram, a provided interface is modeled using the lollipop
notation and a required interface is modeled using the socket notation.

![A simplified example of a component diagram](/images/posts/2012/02/compoent-diagram.webp)
_Simplified example of a UML component diagram_
{:.with-caption .can-invert-image-in-dark-mode}

As I wrote previously, you are most likely already familiar with Component
Driven Development if you know _Symfony_ or _Spring_. Why? Because these two
frameworks use the [**Inversion of Control**][ioc] (IoC) architectural pattern
_via_ the **Dependency Injection** design pattern (I consider IoC an
architectural pattern because it's not a design pattern you can implement).

There are two known issues with IoC, though. First, you need a way to manage
dependencies between components. Second, how do you instantiate all these
components (in which order for instance)? **Dependency Injection Container**
(DIC) to the rescue! A (service) container requires some configuration that
essentially describes the dependencies between components. Checkout the [Symfony
docs about Dependency Injection][symfony-dic] for more technical information.

With that, the two issues I just mentioned are solved and you can now write
highly decoupled code. The main drawback is the time you'll have to spend
thinking about your architecture and component interactions. This is where the
UML component diagram can be helpful ;-)

Thanks to a framework that provides abstractions such as a DIC, you can start
"assembling" an app by reusing existing components (i.e. libraries) to avoid
writing everything from scratch. See why it is like Lego now?

In the PHP world, we have magic tools like:

- [The Symfony components][]: a reusable set of standalone PHP components
- [Composer](https://getcomposer.org/): the awesome package manager for PHP
- [Packagist](https://packagist.org/): the official registry to discover great PHP libraries

Less time wasted writing "framework code", more time spent writing
business-oriented code and "glue code" for the existing components you use
directly "as-is", yay!

[ioc]: https://martinfowler.com/bliki/InversionOfControl.html
[symfony-dic]: https://symfony.com/doc/current/components/dependency_injection.html
[the symfony components]: http://fabien.potencier.org/what-is-symfony2.html
[uml]: https://en.wikipedia.org/wiki/Unified_Modeling_Language
