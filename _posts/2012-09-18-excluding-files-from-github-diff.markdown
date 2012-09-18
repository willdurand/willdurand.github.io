---
layout: post
title: Excluding Files From GitHub Diff
location: Clermont-Fd Area, France
---

This is a short post about GitHub and its [GitHub Compare
View](https://github.com/blog/612-introducing-github-compare-view). Let me
explain.

At [Nelmio](http://nelm.io), we use GitHub and each feature lives in a branch,
and then in a Pull Request, where we can comment and review the code. Most of
the time, reviewing a PR takes a lot of time and some files may pollute the diff
view.

Today I was bored to review `lock` files, so I decided to fix this problem with my
teammate [Francesco](http://twitter.com/flevour). We simply added a
`.gitattributes` file to our project with the following content:

    composer.lock -diff

It tells Git to exclude the `composer.lock` file from the diff output. As GitHub
uses Git, it worked fine and it's really cool because we can get cleaner diff
views now!

More information at: [http://www.kernel.org/pub/software/scm/git/docs/gitattributes.html](http://www.kernel.org/pub/software/scm/git/docs/gitattributes.html).
