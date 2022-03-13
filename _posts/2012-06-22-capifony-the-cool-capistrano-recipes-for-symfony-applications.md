---
layout: post
title: "Capifony, the cool Capistrano recipes for Symfony applications"
location: Zürich, Switzerland
updates:
  - date: 2022-03-13
    content: I proofread this article and removed dead links.
---

For the past two years, I have been using [Capistrano][] to deploy my
applications, even if I sometimes rely on [Git to deploy][] some of them.

Capistrano is fantastic! It's a framework to run commands over SSH. You
configure the process to deploy your application once and it will work for all
servers.

Capistrano is extensible. You can write your own recipes to avoid repeating
yourself. That's what I did for a long time for my symfony 1.x projects. I never
had any issues with this recipe.

For my Symfony (2.x) applications, I didn't have to write anything, though. Not
because I'm lazy but because a wonderful project called _capifony_ already
exists!

Capifony is a set of recipes for both symfony 1.x and Symfony (2.x)
applications. This project has been created by my friend
[@everzet](https://twitter.com/everzet) and sponsored by KnpLabs.

This week, I'm really proud to announce that Konstantin gave me the keys of this
project so that I can maintain and improve it. I released [capifony
2.1.7](https://rubygems.org/gems/capifony) yesterday with a bunch of fixes as
well as new features. In the next weeks, I will work on updating the
documentation.

The project is hosted on GitHub:
[https://github.com/everzet/capifony](https://github.com/everzet/capifony). As
usual, feel free to contribute :-) To ease contributions on the documentation,
I've added the nice "Fork & Edit" feature:

![](/images/posts/2012/06/fork_and_edit_capifony.webp)

Don't hesitate to contribute or report issues. Your feedback is precious!
Thanks!

[Git to deploy]: {% post_url 2012-02-25-deploying-with-git %}
[capistrano]: https://github.com/capistrano/capistrano
