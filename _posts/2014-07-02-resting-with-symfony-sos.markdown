---
layout: post
location: Clermont-Fd Area, France
tldr: false
tags: [ PHP, Symfony ]
title: "RESTing with Symfony: SOS"
---

_2014-07-08 - I created a [Symfony REST Working Group](https://groups.google.com/forum/#!forum/resting-with-symfony). More information on the [symfony.com blog](http://symfony.com/blog/improving-rest-in-symfony)!_
<br>

Two years ago, I wrote [REST APIs with Symfony2: The Right
Way](/2012/08/02/rest-apis-with-symfony2-the-right-way/), one of my most popular
blog posts, but also one of the most well-known blog post about Symfony and
REST. At first glance, I could enjoy this situation, but it actually makes me
sad, and that is what I am going to explain here.

[Lukas](https://twitter.com/lsmith) and I give talks to spread the word about
RESTing with Symfony for the last year now. Sure thing is that we have a nice
set of components (libraries and bundles) that work well together, and provide a
lot of interesting features.  For those who are not aware of this, checkout
[our](http://friendsofsymfony.github.io/slides/rest-dans-le-monde-symfony.html)
[slides](http://friendsofsymfony.github.io/slides/build-awesome-rest-apis-with-symfony2.html)!
The Symfony developers behind all of this even contributed to the PHP ecosystem
at large as most of the features are provided as standalone PHP libraries.
Fantastic!

Not really. Last year, Lukas wrote a [blog post explaining what was needed to
REST in Symfony](http://pooteeweet.org/blog/2221), and there was still a lot of
work left. Did things change? Not really, again. That was in 2013, and remember
that my blog post has been written in 2012.

Come on we are in 2014, and to me, **nothing has changed!** Sure we have a
couple of "recent" blog posts such as the [Symfony2 REST API: the best
way](http://welcometothebundle.com/symfony2-rest-api-the-best-2013-way/) series.
It is a nice series, not only `s/right/best`, but it covers pretty much the same
things I covered two years ago. I didn't see any other interesting blog post
about REST with Symfony recently unfortunately... Lately,
[Ryan](https://twitter.com/weaverryan),
[Leanna](https://twitter.com/leannapelham) and I created a screencast named
[RESTful APIs in the Real World](https://knpuniversity.com/screencast/rest).
I came across a few new bundles, mainly focused on authentication such as
[ApiKeyBundle](https://github.com/uecode/api-key-bundle) and
[LexikJWTAuthenticationBundle](https://github.com/lexik/LexikJWTAuthenticationBundle).
That is it!

I think that we, the Symfony folks interested in APIs and REST stuff, have **two
problems**:

* a clear **lack of contributions** (not only in term of code, documentation
  matters too);
* **too few new big features**.

For instance, we could probably leverage the
[GeneratorBundle](https://github.com/sensiolabs/SensioGeneratorBundle) to
scaffold an API. We probably need more integration with client-side applications
(AngularJS, Backbone.js, whatever). People could write **blog posts** explaining
how they built their API, because I am pretty sure there are people here who
already built an API with Symfony. Existing bundles and libraries also **need
regular contributors**, but this is obvious. Also, if you have other ideas or
comments, you can leverage the new [Developer
eXperience](http://symfony.com/blog/making-the-symfony-experience-exceptional)
(**DX**) system.

Please, help!
