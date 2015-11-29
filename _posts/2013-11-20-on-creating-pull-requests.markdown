---
layout: post
location: Clermont-Fd Area, France
tldr: true
audio: false
title: "On Creating Pull Requests"
---

_2015-11-29 - added a note on PR title prefixes ([thanks to
Lukas](https://twitter.com/lsmith/status/670721764951986176))._

As a [maintainer of various Open Source
projects](https://github.com/willdurand), I use to manage quite a lot of issues
and **P**ull **R**equests (PRs). While **issues** are often **well-written**, I
must say that most of the **Pull Requests** I see are **not**.

Three years ago, I started contributing on Open Source. It took me some time to
release my own projects, and even more time to manage projects that people
actually used. I was so happy that I accepted almost all Pull Requests, often by
reworking them on my own. I thought it was a wise decision, but I was wrong.

Creating a Pull Request to fix a bug or to implement a new feature in a project
is awesome. Really. From a maintainer point of view (or maybe just mine), it is
a **gift**. **Any contribution** to an Open Source project **is a way to thank
its author**.

However, it does not mean that you, as a contributor, don't have to follow a
couple of rules to get your work merged at some point. You may think that
spending time on fixing a bug is enough, but it is actually **half the work**
you have to do while contributing to any Open Source project. You always have
to:

* work on the project;
* fit the project's philosophy.

The latest point includes coding standards, documentation, commit messages,
and any other things related to the targeted project. Thanks to
[GitHub](https://github.com), these rules may be found in a `CONTRIBUTING`
file. Mine (for PHP projects) contains the following set of rules:

> [...]
>
> You MUST follow the [PSR-1](http://www.php-fig.org/psr/1/) and
> [PSR-2](http://www.php-fig.org/psr/2/). If you don't know about any of them, you
> should really read the recommendations. Can't wait? Use the [PHP-CS-Fixer
> tool](http://cs.sensiolabs.org/).
>
> You MUST run the test suite.
>
> You MUST write (or update) unit tests.
>
> You SHOULD write documentation.
>
> Please, write [commit messages that make
> sense](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html),
> and [rebase your branch](http://git-scm.com/book/en/Git-Branching-Rebasing)
> before submitting your Pull Request.
>
> One may ask you to [squash your
> commits](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html)
> too. This is used to "clean" your Pull Request before merging it (we don't want
> commits such as `fix tests`, `fix 2`, `fix 3`, etc.).
>
> Also, while creating your Pull Request on GitHub, you MUST write a description
> which gives the context and/or explains why you are creating it.

Hopefully, it is crystal clear. If it is not, please leave a comment.

First, I describe the **C**oding **S**tandards (CS) I use in the project. Then,
I expect people to run the test suite, and to **write tests** to prove the bug's
existence, but also to prove that the fix works. Basically, **no test, no
merge**. If you can't come up with a fix, create a Pull Request with a failing
test case.

If you want your patch to be merged, you should send clean commits. Most of the
time, a **single commit** including the fix, some tests, and an update on the
documentation is enough.  Once you have hacked on the project, [squash your
commits](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html)
and send the result as a single commit.

Last sentence is about the Pull Request itself, the one you will create on
GitHub. Most of the time, people don't write any description. Please, **start
writing Pull Request descriptions, now!** Give the context such as the "why"
(you need this feature) or the "how" (you found the bug you fixed).

Also, the title of your Pull Request is important. Write a short yet clear
sentence giving the insight of your Pull Request. It is common to add a prefix
to the title, such as: `[WIP]`, which stands for _Work In Progress_; `[POC]`
(Proof Of Concept), `[WCM]` (Waiting Code Merge), etc.

If you follow these rules, then maintainers will focus on the code while
reviewing your Pull Request and will be able to quickly merge it, rather than
wasting their time on trying to get something "mergeable".

Last but not the least, you may get a lot of feedback. Please, **support your
Pull Request until it gets merged**. Don't disappear!

Thank you my heroes! &hearts;


## TL;DR

* Follow the rules of the project you are contributing to;
* Attach clean commits to your Pull Request (rebase may help);
* Write a description in your Pull Request, explaining the context.
* More information at: [Git & GitHub & OpenSource](https://speakerdeck.com/willdurand/2015)
