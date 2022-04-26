---
layout: post
title: "An introduction to `git worktree`"
location: "Freiburg, Germany"
image: /images/posts/2021/05/trees.webp
tweet_id: 1389904489977683972
mastodon_id: 106182350048923017
credits: |
  Photo used on social media by [Markus Spiske](https://unsplash.com/@markusspiske)
---

This is a quick introduction to a `git` feature I use quite often because I find
it better than simple branches in some cases.

`git worktree` can help ["manage multiple working trees attached to the same
repository"][git-worktree]. Instead of having different branches within the same
folder, you have distinct folders (working trees) bound to the same git
repository. In other words, this feature allows you to work on different
branches at the same time.

Why do I like this feature? Let's find out!

## Spikes and code reviews

I do code reviews every day and I like to [checkout the code
locally][code-reviews] pretty much every time. When I am working on a [spike][]
for `$PROJECT` (in parallel), which usually takes several days, I use `git
worktree` to avoid "WIP" (Work In Progress) commits or stashes. My current spike
lives in a different folder than the main local repository for `$PROJECT`, and I
can use the latter to checkout Pull Requests and do the reviews.

One might think that I could use `git stash` or a different branch and do `git
commit -am "wip"`. I've done that. I even have [custom git
commands][git-commands] and [git aliases][git-aliases] to simplify repetitive
tasks. Yet, it's far from ideal: I have to commit everything to "save" the state
of my spike, make sure that I don't have a local (git-ignored) configuration
when I switch to a different branch, update the project's dependencies, and,
when I'm done with the review, "undo" everything to restore the state of the
spike. It isn't very efficient.

## Benchmarks and other comparisons

This isn't a very common use case but I sometimes need to run the same
application with two different configurations and check the differences.

In the past, I did that sequentially and it was error-prone because I couldn't
check the differences with the two application flavors running side-by-side. In
order to achieve that, I had to clone the same repository a second time.

`git worktree` gives the same experience except that there is no need to clone
the repository again. The "copies" (= working trees) created with `git worktree`
point to the git history and configuration of the main repository. Indeed, there
is no `.git/` folder in a "copy" created with `git worktree`. Instead, there is
a simple `.git` file with the following content:

```
gitdir: /path/to/main/git/repo/.git/worktrees/some-worktree
```

Each working tree is a git repository and has access to the full git history,
remotes, etc. but everything is stored in the main repository. This is the
reason why `git branch` shows the local branches as well as the different
_worktrees_ for instance:

```
$ git branch
  some-local-branch-in-main-repo
+ some-worktree
* main
```

Like any other git repository, it's possible to create new branches, push
to/pull from a remote, etc. in a working tree created with `git worktree`.

## How to use `git worktree`?

I don't use `git worktree` on all projects. For those where it will likely be
used, I have my own convention. I clone the main repository in a folder whose
name is the project's name:

```
$ tree -L 1 ~/projects/mozilla/addons-frontend
/Users/william/projects/mozilla/addons-frontend
└── addons-frontend
```

You might want to name the main repository folder `main` or `master` instead. I
reuse the project's name because [my tmux config automatically sets the window
names based on the current paths][tmux]. It wouldn't be very useful to have
several "main" windows...

From the main repository, I can create a new working tree with the following
command:

```
$ git worktree add ../some-worktree
```

This will result in a new folder created next to the "main" one:

```
$ tree -L 1 ~/projects/mozilla/addons-frontend
/Users/william/projects/mozilla/addons-frontend
├── addons-frontend
└── some-worktree
```

As a side note, my tmux session with the two working trees opened (+ another
project) would look like:

```
moz ⧉ 1:addons-frontend   2:some-worktree   3:other-project
```

There are other commands to manage _worktrees_ like `git worktree remove` and
`git worktree prune`. I let interested readers browse the [git
documentation][git-worktree].

Hopefully this introduction has been useful to you. I'd be happy to discuss with
you about this git feature or how you approach some of the use cases described
above in a different way, _ciao!_

[code-reviews]: {% post_url 2020-01-27-suggested-changes-in-code-reviews %}
[git-aliases]: https://github.com/willdurand/dotfiles/blob/17d9b2643abcbac07347270589e142b0fe944172/git/gitconfig#L52
[git-commands]: https://github.com/willdurand/dotfiles/tree/17d9b2643abcbac07347270589e142b0fe944172/git/commands
[git-worktree]: https://git-scm.com/docs/git-worktree
[spike]: https://en.wikipedia.org/wiki/Spike_(software_development)
[tmux]: https://github.com/willdurand/dotfiles/blob/17d9b2643abcbac07347270589e142b0fe944172/tmux/tmux.conf#L42
