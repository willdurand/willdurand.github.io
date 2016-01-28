---
layout: post
location: Clermont-Fd Area, France
tldr: false
audio: false
tags: [ PHP, DDD ]
title: "DDD with Symfony2: Making Things Clear"
---

[Domain Driven Design](http://en.wikipedia.org/wiki/Domain-driven_design) also
known as **DDD** is an approach to develop software for complex needs by
connecting the implementation to an evolving model. [It is a way of thinking and
a set of priorities, aimed at accelerating software projects that have to deal
with complicated domains](http://dddcommunity.org/learning-ddd/what_is_ddd/).

It is possible to use this approach in a Symfony2 project, and that is what I am
going to introduce in a series of blog posts. You will learn how to build an
[application that manages users through a REST
API](/2012/08/02/rest-apis-with-symfony2-the-right-way/) using **D**omain
**D**riven **D**esign.

This is the second article of this series! You should read [Folder Structure
And Code First](/2013/08/07/ddd-with-symfony2-folder-structure-and-code-first/)
before digging into that one. This blog post is an attempt to fix a few
misunderstandings coming from the [first
post](/2013/08/07/ddd-with-symfony2-folder-structure-and-code-first/). I
recommend you to quickly jump to all links, they are valuable!


## DDD Is Not RAD

Domain Driven Design is **not** a **fast** way to build a software. It is not
[RAD](http://en.wikipedia.org/wiki/Rapid_application_development) at all! It
implies a lot of boilerplate code, tons of classes, and so on. No, really. It
is not the fastest way to write an application. No one ever said that DDD was
simple or easy.

However, it is able to **ease your life when you have to deal with complex
business expectations**. _How?_ By considering your domain (also known as your
business) as the heart of your application. Honestly, DDD should be used in a
rather **large application**, with complex business rules and scenarios. Don't
use it if you are building a blog, it does not make much sense (even if it is
probably the best way to learn the hard way). So question is [when to use
DDD?](http://shishkin.wordpress.com/2008/10/10/when-to-use-domain-driven-design/)
I would say when your domain is very complex, or when the business requirements
change fast.


## There Is No Database

In DDD, we **don't consider any databases**. [DDD is all about the domain, not
about the database, and Persistence Ignorance (PI) is a very important aspect of
DDD](http://devlicio.us/blogs/casey/archive/2009/02/12/ddd-there-is-no-database.aspx).

With **Persistence Ignorance**, we try and eliminate all knowledge from our
business objects of how, where, why or even if they will be stored somewhere.
Persistence Ignorance means that [the business logic itself doesn't know about
persistence](http://stackoverflow.com/questions/905498/what-are-the-benefits-of-persistence-ignorance).
In other words, **your Entities should not be tied to any persistence layer or
framework**.

So, don't expect me to make choices because it works better with Doctrine, Propel
or whatever. This is not how we should use DDD. We, as [developers, need to
become part of our business users domains, we need to stop thinking in technical
terms and constructs, and need to immerse ourselves in the world our business
users inhabit](http://devlicio.us/blogs/casey/archive/2008/09/10/the-tao-of-domain-driven-design.aspx).


## DDD And REST

By now, I use a REST API as **Presentation Layer**. It is **perfectly doable**
and, even if [both concepts seem opposites, they play nice
together](http://dontpanic.42.nl/2012/04/rest-and-ddd-incompatible.html). Remember that
one of the **strengths** of DDD is the **separation of concerns** thanks to
[distinct
layers](/2013/08/07/ddd-with-symfony2-folder-structure-and-code-first/#conclusion).
I am afraid that people think that it is not possible to play with both at the same
time because [nobody understands REST or
HTTP](http://blog.steveklabnik.com/posts/2011-07-03-nobody-understands-rest-or-http).

Basically, [you should not expose your Domain Model as-is over a public
interface](http://stackoverflow.com/questions/10943758/is-it-good-to-return-domain-model-from-rest-api-over-a-ddd-application)
such as a REST API. That is why you should [use
Data Transfer Objects](http://neverstopbuilding.net/the-dto-pattern-how-to-generate-php-dtos-quickly-with-dtox/)
([DTOs](http://en.wikipedia.org/wiki/Data_transfer_object)). DTOs are **simple
objects** that **should not contain any business logic** that would require
testing by the way. A DTO could be seen as a PHP `array` actually.

What you should do here is to write a REST API that **exposes resources that
make sense for the clients** (the clients that consume your API), and that are
not always 1-1 with your Domain Model. See these resources as DTOs. For
instance, if you deal with _Orders_ and _Payments_, you could **create** a
_transaction_ resource to perform the business operation
`payOrder(Order $order, Payment $payment)` as proposed by Jonathan Bensaid in
[the comments of the previous
article](http://williamdurand.fr/2013/08/07/ddd-with-symfony2-folder-structure-and-code-first/#comment-1006445621):

    POST /transactions
    orderId=123&paymentId=456&...

The **Application Layer** will receive the data from the **Presentation Layer**
and call the **Domain Layer**. This `transaction` is a DTO. It is not part of
the domain but it is useful to exchange information between the Presentation and
the Application layers.

However, in the previous article I was able to directly map my `User` Entity to
resources of type _users_. But if you look at the whole thing, I used a
Serializer component to only expose some properties. That is actually another
sort of DTO. The Entity is transformed to only expose data that are relevant for
the clients (the clients that consume your API). So it is ok(-ish)!

Also, note that HTTP methods explicitly delineate commands and
queries. That means **Command Query Responsibility Separation**
[CQRS](http://martinfowler.com/bliki/CQRS.html) **maps directly to HTTP**. Hurray!


## So, What's Next?

In this series, I will introduce a more complex business, don't worry! Hopefully
I was clear enough to explain my choices regarding this series, and I fixed some
misconceptions about DDD, RAD, and REST.

In the next blog post, I will introduce the **Presentation Layer**, new Value
Objects such as the `Name` one, and more on **DDD**! At the end of the next
post, you will basically get a CRUD-ish application. Yes, I know... [CRUD is an
anti-pattern](http://verraes.net/2013/04/crud-is-an-anti-pattern/), but it does
not mean you should avoid it all the time. Creating new _users_ make sense
afterall.

The third post will allow you to create almost everything you need in the
different DDD layers to build a strong and powerful domain, with complex logic,
and so on. You may not get why DDD is great until that, so don't panic and stay
tuned!
