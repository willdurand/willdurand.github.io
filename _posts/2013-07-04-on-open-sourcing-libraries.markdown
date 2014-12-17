---
layout: post
location: Clermont-Fd Area, France
tldr: true
title: On Open Sourcing Libraries
---

_2014-12-17 — Your project should have a Contributor Code of Conduct._

Open sourcing a library is easy, it is just a matter of seconds. All you need is
a public repository hosted somewhere ([GitHub](https://github.com/),
[Bitbucket](https://bitbucket.org/), etc.) right? _Nope!_ Actually, it would be
better for everyone if you would **add some love to your new shiny library** you
just made publicly available. Let's see how to do that.


## README

The `README` file is a **first-class citizen** in your project. You MUST have
it! This file MUST contain the **name**, and a (short) **description** of your
library. See this description section as an **elevator pitch**.

Then comes the **Usage** section. Describe how to use your library, with both
words and code snippets. Add screenshots or GIFs. Be as exhaustive as you can.
This is your project's **documentation**, and most of the time for libraries,
this will be the only documentation you will provide.

Writing the **Usage** part first is not a random choice. Your `README` file
should blow your reader's mind, so that they will use your library and
contribute back (or not).

The third section you MUST include is the **Installation** one. This section
explains how to quickly install your library, from a _user_ point of view. If
you have more than one way to install your project, describe the one you
consider the best first, and then explain the alternatives.

You can add an optional **Requirements** section like _Depends on X version Y_.

The fourth required section is **Contributing**. This can be replaced by the use
of a `CONTRIBUTING` file though. Explain **how to hack your library**, how to
report bugs or how to submit feature requests. It is important to be exhaustive
here.
**Explain the rules** to avoid commenting every single line in Pull Requests you
receive. Point contributors to the right tools such as linters or compilers. For
instance, here is [my standard `CONTRIBUTING` file for PHP projects](https://github.com/willdurand/Hateoas/blob/master/CONTRIBUTING.md).

You MUST add a **Testing** section too. Explain **how to set up the test suite**,
how to run the functional tests, and the tools that people may have to install.

Optionally, add a **Credits** section if you use third-party things or if you
want to list your contributors (that could be an **Authors** section though).

You MUST add a [Contributor Code of Conduct](http://contributor-covenant.org/)
because the lack of diversity in Open Source is not acceptable, and this is an
easy way to begin addressing this problem. Unacceptable behaviors have to be
banned and unfortunately, we have to make this statement **really** explicit,
for instance by adding a `CODE_OF_CONDUCT.md` file.

Last but not the least, add a **License** section!

Here is a template:

    project-x
    =========

    project-x is a better way to achieve this and that, by leveraging the new API,
    blablabla.

    ## Usage

    ...

    ## Installation

    ...

    ## Requirements

    ...

    ## Contributing

    See CONTRIBUTING file.

    ## Running the Tests

    ...

    ## Credits

    ...

    ## Contributor Code of Conduct

    Please note that this project is released with a [Contributor Code of
    Conduct](http://contributor-covenant.org/). By participating in this project
    you agree to abide by its terms. See CODE_OF_CONDUCT file.

    ## License

    project-x is released under the MIT License. See the bundled LICENSE file for
    details.

As you can see, I introduced two files in this template: `LICENSE`, and
`CONTRIBUTING`. I already covered the `CONTRIBUTING` file while describing
the **Contributing** section. The `LICENSE` file contains the license you will
choose for your project, but which license?


## License

I won't compare all licenses, browse [tl;drLegal](http://www.tldrlegal.com/)
instead. It provides useful information related to Open Source licenses, with
simple words.

I tend to use the [MIT license](http://www.tldrlegal.com/license/mit-license) as
it is very liberal. My advice here is to **look at your community**, and choose
the most appropriate one. For example, in the Symfony2 (a PHP Framework)
community, most of the related projects (bundles) are released under the MIT
license. However, Java projects are often released under the [Apache License
2.0](http://www.tldrlegal.com/license/apache-license-2.0).

According to recent reports, [most GitHub projects
don't have an Open Source
license](http://www.theregister.co.uk/2013/04/18/github_licensing_study/). That
is bad! You MUST have a license, even if it is the [Beerware
license](http://en.wikipedia.org/wiki/Beerware).

As mentioned on [Hacker News](https://news.ycombinator.com/item?id=5990836),
[choose your license carefully](https://news.ycombinator.com/item?id=5992270).
Also, [don't make up your own or just state that it's public domain. Public domain
is actually not a well-defined concept internationally, and means different things
in different countries](https://news.ycombinator.com/item?id=5992428).

Even if you now have a well-documented library and a license, you can't dominate
the world yet. In the following, I give an overview of what I consider important
in Open Source projects.


## Write Tests & Automate

Open Source projects are a way to write beautiful code as there are no deadlines,
and no "customers". Keep in mind that your projects show what you are able to do.
As a developer, **your library is your business card**.

**Write tests**, a lot! How do you expect people to contribute to your library if
you don't provide a test suite? So, write tests, and use [Travis
CI](https://travis-ci.org/). It is all about adding a `.travis.yml` file
describing how to run your tests. It is another way to document how to run the
tests.

Add a [status image](http://about.travis-ci.org/docs/user/status-images/) to your
`README` file too.

Take a look at online tools such as [Scrutinizer](https://scrutinizer-ci.com) for
PHP and JavaScript, or [Puppet Linter](http://www.puppetlinter.com/). Automate
as much as you can.


## Be Standard

It is important to **use the right tools** for your library. Look at your
community again, and choose the tools people tend to use. In PHP, we use
[Composer](http://getcomposer.org/) as dependency manager. Don't waste your time
with PEAR or anything else, use Composer. If you write a Node.js library,
register it on [npm](https://npmjs.org/). For Ruby developers, distribute your
library as a [gem](http://guides.rubygems.org/make-your-own-gem/). For C#
developers, use [NuGet](http://nuget.org/).

Another example, in Symfony2 it is considered good practice to add documentation
in `Resources/doc`. It is a convention. **Don't duplicate your documentation**.
Add a link to quickly jump to this folder on your `README` file instead.


## Managing Issues & Releases

[GitHub](https://github.com/),
[CodePlex](http://www.codeplex.com/), or whatever you want, they all provide an
issue tracker. Use it!

If you use GitHub, don't waste your time with the Wiki. I never found a decent
workflow. Either use the `README` file for your documentation, or use [Read The
Docs](https://readthedocs.org/) to host it in case you have extensive
documentation. Use GitHub Issues to manage milestones, and rely on labels to
sort your issues.

Also, try to reply to all issues, as soon as possible... But [be
careful, and manage your time](/2013/02/20/burnout/). Be nice with everyone, and
take time to help newcomers. It is worth learning [how to maintain a successful
open source project](https://medium.com/p/aaa2a5437d3a).

Another advice would be to release often by tagging versions periodically.
Talking about versions, please follow the [Semantic Versioning
Specification](http://semver.org/).

Then, maintain a `CHANGELOG` file to help your users identify changes. If you
break backward compatibility, write an `UPGRADE` file in order to explain how
to upgrade.


## You Need Feedback!

The main reason why [I open source a lot of
projects](https://github.com/willdurand?tab=repositories) is that I can learn a
lot thanks to user feedback. So you need feedback, I need feedback, everyone
needs feedback! Share your project on Twitter, Hacker News, and so on. Spread
the word! People must know about your project, not because it is awesome, but
because people can comment on it.

Use GitHub pages to create a website for your library, buy a domain if you want.

Remember the world domination plan? That is pretty much all you need to achieve
this goal. We never know!


## Hire People

Once you dominate the world, it is important to enroll new people to help you.
That is a terrific experience! And it will give you more time for your other
Open Source projects (also known as your new world domination plans) :-)


## Conclusion

Open sourcing a library is not just about publishing the source code. You need
to add a few things to make it usable, and enjoyable. Documenting your projects
shows that you are able to teach, and that you are able to find the right words
to explain something. Also, it shows that you care about what you do.

Don't forget to add tests in your library, if you don't do that at work, do it
at home. And don't forget the license too, no excuse!

It is really cool to open source projects, but avoid the [NIH
syndrome](http://en.wikipedia.org/wiki/Not_invented_here). Contribute as much as
you can, open source things that don't exist.


## TL;DR

Your library/project:

* MUST have a `README` file including a name, a description, and the following
  sections: **Usage**, **Installation**, **Contributing**, **Testing** and
  **License**;
* MUST add a Contributor Code of Conduct;
* MUST have a **license** that is visible;
* MUST be tested;
* MUST be standard or MUST fit your community habits;

You:

* NEED feedback;
* MUST be nice;
* SHOULD enroll people.
