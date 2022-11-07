---
layout: post
title: Teaching is the best way to learn
location: Clermont-Fd Area, France
updates:
  - date: 2022-05-01
    content: I proofread this article and fixed some links.
---

Earlier this year, I gave lectures to undergraduate students at IUT de
Clermont-Fd (France) for the first time. I taught **web development** (using
PHP) ([slides](https://edu.williamdurand.fr/php-slides/) &
[sources](https://github.com/willdurand-edu/php-slides)), and **security**,
mainly focused on Web/APIs security
([slides](https://edu.williamdurand.fr/security-slides/) &
[sources](https://github.com/willdurand-edu/security-slides)).

I introduced not only general concepts and best practices in web development but
also tools such as [Git][], [Vim][], [Vagrant][], [Puppet][], and [GitHub][].
Each student worked with a [Virtual
Machine](https://github.com/willdurand-edu/php-vm) so that they could do
whatever they wanted to. Except a few issues, it was really interesting because
pushing updates to all students at once was rather easy for me. The workflow was
pretty straightforward. All students had to do was running `git pull && vagrant
up`.

Students wrote their own micro-framework in PHP, relying on components such as
the [Symfony][] ones and managed with [Composer][]. They wrote unit tests as
well as functional tests. Some students even published their own code on GitHub.
Most of them did a great job by building a web application combined to a "true"
REST API with content negotiation.

As for the [security lectures](https://edu.williamdurand.fr/security-slides/), I
tried to give an overview of well-known security topics, including
**authorization**, **authentication**, some **authentication mechanisms**, and
how to **secure the web**.

Overall, teaching was a really great experience! I learned quite a few tips on
how to be better at teaching. I am used to talk to people at conferences so my
vocabulary was a bit too technical. This was the first thing I had to change
while explaining something to my students. They never did web development
before. Introducing high-level concepts using simple words is not
straightforward but it is a really good exercise for those who want to improve
their communication skills. Also, as I needed to be able to answer various
questions, I had to know my topics "by heart", including how things worked under
the hood. To be perfectly honest, I studied for hours to be better while
performing in front of the students.

I got positive feedback from students and that felt great given that it was my
first year as a teacher. I enjoyed teaching things that took me years to learn.

[composer]: https://getcomposer.org
[git]: https://git-scm.com
[github]: https://github.com
[puppet]: https://puppetlabs.com
[symfony]: https://symfony.com
[vagrant]: https://www.vagrantup.com
[vim]: https://www.vim.org/
