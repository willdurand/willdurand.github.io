---
layout: post
title: My Git Branching Model
location: Clermont-Fd Area, France
---

<br>
_2015-09-11 - I like (and also use) this [simple yet powerful Git branching model by Juan Benet](https://gist.github.com/willdurand/eec15f945d55ea80d62a)._ 

We all probably know [a successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/) which
is a very interesting model for teams who want to use Git. However, this model is a bit too complex for common needs.
So here is my lightweight model.

I use two main branches:

* `master` : the code in a _production-ready_ state;
* `develop` : the _integration branch_.

![](/images/bm002.png)

I also use **feature branches**. A feature branch contains a work in progress. Keep in mind that a feature branch
should reflect a feature in your backlog. I use a convention for these branches, I always prefix them with `feat-`.

    > git branch
    feat-my-feature
    * master

A feature branch has two constraints:

* the code must come from the `develop` branch;
* the code must be merged in the `develop` branch.

![](/images/fb.png)

To create a feature branch, I use the following command:

    > git checkout -b feat-my-feature develop

To merge a feature branch into `develop`, I use the following set of commands:

    # Go back to the develop branch
    > git checkout develop

    # Get last commits
    > git pull --ff-only origin develop

    # Switch to the feature branch
    > git checkout feat-my-feature

    # Time to rebase
    > git rebase develop

    # Then, switch to the develop branch in order to merge the feature branch
    > git checkout develop

    > git merge --no-ff feat-my-feature

    # Push
    > git push origin develop

    # Finally, delete your branch
    > git branch -d feat-my-feature

I always merge a feature branch into `develop` using `--no-ff` to keep a clean log:

![](/images/merge-without-ff.png)

The `--no--ff` option allows to keep track of a feature branch name which is quite useful.
The following `git log` output shows you a feature branch merged with this option:

    commit 481771556824c4ae2e6da73ef14d6ce757fb5870
    Merge: 6abdd70 8cfe5a7
    Author: William DURAND <william.durand1@gmail.com>
    Date:   Tue Jan 17 11:31:56 2012 +0100

    Merge branch 'feat-my-feature' into develop

    commit 8cfe5a7da159663cc09a850bee49a59ce046c67e
    Author: William DURAND <william.durand1@gmail.com>
    Date:   Tue Jan 17 11:31:19 2012 +0100

    Added a new feature

    commit 6abdd707aace50ee5aad72a3c6fcff2f36cdea7f
    Author: William DURAND <william.durand1@gmail.com>
    Date:   Sun May 15 14:07:19 2011 +0200

    Initial commit

Without the `--no-ff` option, you'll get the following output:

    commit 0d5805d52e55e4941ce23585a4cd559e5e643207
    Author: William DURAND <william.durand1@gmail.com>
    Date:   Tue Jan 17 11:35:43 2012 +0100

    Added yet another feature

    commit 6abdd707aace50ee5aad72a3c6fcff2f36cdea7f
    Author: William DURAND <william.durand1@gmail.com>
    Date:   Sun May 15 14:07:19 2011 +0200

    Initial commit

In a team, you will probably have more than one feature branch, and you could have a dependency between
two branches (this should be avoided).
In this case, I use another branch in which I merge two or more feature branches.

    > git checkout -b feat-my-feature-with-another-feature develop

Then, I can merge the two feature branches, and solve possible conflicts:

    > git merge feat-my-feature

    > git merge feat-another-feature

I don't use any other branches. The last part of the model is to merge `develop` into `master`.
To avoid conflicts, there should be only one person who owns this responsability: the **release manager**.

I experimented this model with different teams in terms of number of people and skills, and I never had more needs.
I know some people use **releases** but it can be handled in another way.

All credits go to Vincent Driessen and his [Git model](http://nvie.com/posts/a-successful-git-branching-model/).
