---
layout: post
title: "Component Driven Development: it's like Lego!"
location: Clermont-Fd Area, France
tags: [ PHP ]
---

Did you ever hear about **Component-Based Development**? Maybe about **Component Driven Development**?
Both concepts are the same, and if you're involved in _Symfony2_, _Spring_, or something similar, then you do
**Component Driven Development** (**CDD**).

![](http://williamdurand.fr/images/posts/lego.jpg)

It's all about **separation of concerns**. You design components with their own logic, each component does
**one thing well**, and **only one thing**.
To separate business logic in self-contained components requires to focus on interactions between components.
In other words, you have to think about right interfaces. To help you, UML provides a **component diagram** which
allows you to easily show components, interfaces, and relations.

In a component diagram, a provided interface is modeled using the lollipop notation, and a required interface is
modeled using the socket notation. Small squares represent _ports_, which are features with distinct interaction
points. So, a _port_ is an internal component of a classifier.

![](http://www.agilemodeling.com/images/models/componentInterfaces.JPG)

Most of the time, you won't use this kind of diagram because you don't like to draw UML diagrams :-).
But, as I said previously, you probably know **Component Driven Development** if you know _Symfony2_ or _Spring_. These two
frameworks use the [**Inversion of Control**](http://martinfowler.com/bliki/InversionOfControl.html) architectural
pattern through the **Dependency Injection** design pattern (I consider IoC as an architectural pattern because
it's not a design pattern you can implement).

A well-known issue when you use **Component Driven Development** is how to manage dependencies between components,
and how to instantiate all your components. Dependency Injection Container to the rescue!
By describing component's dependencies, and thanks to a container, you'll write an highly decoupled application,
with components you can reuse.

The main drawbacks are the time you'll spend to think about your architecture, and to know how your components will interact
(don't forget UML in that case). So, try to find a component before to write your own. In the PHP world, we have magic
things:

* [The Symfony2 components](http://fabien.potencier.org/article/49/what-is-symfony2): a reusable set of standalone PHP components;
* [Composer](http://packagist.org/about-composer): the package manager you need;
* [Packagist](http://packagist.org/): to discover awesome PHP components.

Since few months, I work on a project for a French startup, and it's my first **Component Driven Development**
experience. I started by listing all my needs (an _OAuth_ client, a _iCalendar_ parser, ...). Then, I tried to find one component
per point. And, as a glue, I decided to use **Composer**. After the end of the first sprint, I was a bit confused because
I wrote two hundred lines of code (including some test classes), and the project was ever ready to use.
I focused on the only important thing: **the aim of the application**.

Thanks to tools like _npm_, _gem_, _composer_, it's like [Lego](http://www.lego.com)!
