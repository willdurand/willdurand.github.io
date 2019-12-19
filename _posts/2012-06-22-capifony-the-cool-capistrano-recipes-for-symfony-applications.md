---
layout: post
title: "Capifony, The Cool Capistrano Recipes For Symfony Applications"
location: Zürich, Switzerland
---

Since two years, I use [Capistrano](https://github.com/capistrano/capistrano)
to deploy my applications, even if I sometimes rely on [Git to
deploy](/2012/02/25/deploying-with-git/) some of them.

**Capistrano** is just fantastic! It's a framework to run commands over SSH, so that
you just have to configure the process to deploy your application once, and it
will work on all servers.

As a framework, Capistrano is extensible. You can write your own recipes to
avoid duplicating things. That's what I did for a long time for [my symfony 1.x
projects](http://www.willdurand.fr/deploiement-automatise-avec-capistrano-et-git-pour-symfony-et-diem/).

It works fine, and I never had any issues with this recipe. But for my Symfony2
applications, I didn't write anything, not because I'm lazy, but just because
there is a wonderful project called [capifony](http://capifony.org/).

![](http://capifony.org/images/logo.png)

**capifony** is a set of recipes for both symfony 1.x, and Symfony2
applications. This project has been created by my friend
[@everzet](https://twitter.com/everzet), and sponsored by KnpLabs.

This week, I'm really proud to announce that Konstantin gave me the keys of this
project, so that I can maintain, and improve it. I released [capifony
2.1.7](https://rubygems.org/gems/capifony) yesterday with a bunch of fixes, but
also with new features. In the next weeks, I will work on the documentation.

The project is hosted on GitHub:
[https://github.com/everzet/capifony](https://github.com/everzet/capifony), with
both the code, and the documentation. As usual, feel free to contribute. To ease
contributions on the documentation, I've added the nice "Fork & Edit" feature:

![](/images/fork_and_edit_capifony.png)

So, don't hesitate to contribute, or to report issues. Your feedback is
precious, really!
