---
layout: post
title: "Why You Should Love Code Generation"
location: Clermont-Fd Area, France
---

What a nice title, _right?_ I often see people complain about **code generation**, and I would like
to explain my point of view in a pragmatic approach. As you may know, I'm the lead developer of [Propel](http://propelorm.org/),
a great PHP5 [ORM](http://en.wikipedia.org/wiki/Object-relational_mapping) which uses code generation
a lot.

**Code generation** is about to use **code to write code**. Pretty easy, _isn't it?_ In [Propel2](http://github.com/propelorm/Propel2),
we will use [Twig](http://twig.sensiolabs.org/) to generate PHP code for instance. The golden rule is to **never use
the same programming language you want to generate**, otherwise it will be a pain to maintain
(try to read Propel 1.6 builders).
But in order to generate code, we need to know information that describe the code we want to generate.
The term **metadata** defines these information. A _metadata_ is a data about data, that's exactly what
we need!

In Propel, the `schema.xml` (a _XML_ file) contains all metadata we need to generate both _PHP_ and _SQL_ code.
As Propel is an ORM, data will be a database name, tables, columns, primary keys, etc. This is **your business model**!
We can call it a **Platform Independent Model** (PIM) because this schema is database vendor **agnostic**.
It doesn't know anything about _MySQL_, _Oracle_, or whatever you want. It just describes your model with its own
notation.

To generate code, Propel relies on **builders** and **platforms**. **Builders** own the logic to write _PHP_
code, and **Platforms** contain the logic for each database vendor (whether to quote table names or not for instance).
This is specific, _right?_ So let's call this layer a **Platform Specific Model** (PSM).

Propel uses both a **PIM** and a **PSM** to generate code. Actually, it uses the **PIM** to drive
the **PSM** which depends on configuration parameters also known as _build properties_ in Propel terminology.
That's all, here is how Propel works at buildtime :-)

_But wait, what?_ It's all about [**Model Driven Architecture**](http://www.ibm.com/developerworks/rational/library/3100.html)!
Did you ever hear about that? It's the state of the art in research in Computer Science (at least in France).
This is a software design approach for the development of applications.

![](http://www.leonardi-free.org/wp-content/uploads/2011/02/model-driven-engineering-schema-en.jpg)

But this is a formal approach, and I would like to keep a pragmatic mind here through Propel.
Then, what I love in **code generation** is that your code is **easily debuggable**, you can read it, and learn from it.
Few years ago, generated code was a mess, especially in _symfony 1.x_, but today we are able to generate clean code,
as you could write yourself. And, as you write code to generate code, you can test both, and avoid more errors.
To generate code **speeds up your application**, and you can **pre-calculate** some parts of your code. In Propel (again),
we are able to **pre-generate** _SQL_ statements at buildtime. That way, we by-pass the need to generate _SQL_ code at runtime.
It's really really faster than to use the whole Propel stack.

In Propel, we also have _behaviors_. This is a self-contained logic which extends the current implementation by using hooks at buildtime.
A behavior is reusable, testable, and easy to write. Then, you can adopt a
[behavior driven development](http://propel.posterous.com/behavior-driven-development): write behaviors you will reuse in
order to avoid code duplication.

![](http://4.bp.blogspot.com/_Ln5yflq9tNw/STU5TRYvU9I/AAAAAAAAABo/lujbozAii1E/s320/software_management_2.jpg)

I know there are drawbacks to use code generation, especially the need to generate code before to deploy your application
in production, or the lack of implementation details. But, for the most part of an application, to generate code helps
a lot, and it helps you to get what you really want to get too.

Tu sum up, **code generation** is not a crazy idea. It's close to MDA, it has pros and cons but in my opinion,
code generation is definitely **not** a bad practice, and you should use it instead of relying on _in memory_ code
or complex architectures just to avoid generation.
