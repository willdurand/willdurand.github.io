---
layout: post
title: "Rebasing without `git rebase`"
location: "Freiburg, Germany"
image: /images/posts/2021/02/git-rebase.webp
credits: |
  Photo used on social media by [Yancy Min](https://unsplash.com/@yancymin).
tags: [git]
---

My `git` workflow involves creating a lot of short-lived branches (a.k.a.
feature branches), switching between them and, sometimes, I need to _rebase_ one
of these branches. [git rebase](https://git-scm.com/docs/git-rebase) is a super
useful git command and I recommend everyone to get more familiar with it (take a
look at [git rebase in depth](https://git-rebase.io) for instance).

My feature branches usually contain a single commit (of interest) and when there
are more commits, my team at $WORK uses the [squash and
merge](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-request-merges#squash-and-merge-your-pull-request-commits)
button anyway. In other words, I do not care much about the history of a
short-lived git branch. Using this approach, executing `git rebase` is
straightforward and there is usually little to no _conflict_ to handle.

That being said, it can be tricky to perform a rebase sometimes (for example,
when the main branch has changed a lot after someone ran a code formatter on the
entire codebase).  Such a situation could also occur when one merges the main
branch into the feature branch, resulting in a _merge commit_ like `Merge branch
'main' into feature-branch`.

Attempting a rebase in these situations will convince a lot of people that git
rebase is awful but we can achieve pretty much the same result using a different
git command: `git merge` with the `--squash` option. Here is how I proceed to
rebase a branch named `feature-branch` without `git rebase`:

1. make sure the main branch is up to date locally first:

    ```text
    $ git checkout main
    $ git pull origin main
    ```

2. "rename" the branch to rebase to `feature-branch-2`:

    ```text
    $ git checkout feature-branch
    $ git branch --move feature-branch-2
    ```

3. recreate the branch `feature-branch` based on the main branch:

    ```text
    $ git checkout main
    $ git checkout -b feature-branch
    ```

4. `git merge` the temporary branch **with squash**:

    ```text
    $ git merge --squash feature-branch-2
    ```

5. Now, commit and force push `feature-branch` to update the Pull/Merge Request
   🎉 The temporary branch can be safely deleted at this point.

That's it! Note that some of the commands above could be combined to be more
efficient but I do not use this procedure a lot so I do not mind.

---

Bonus: a few years ago I learned about `git commit --fixup` so I often pass
`--autosquash` to `git rebase` (and sometimes `--autostash` too). Take a look at
these options if you do not know about them already :)
