---
layout: post
title: "Introducing srht.vim"
location: "Freiburg, Germany"
image: /images/posts/2021/03/srhtvim.webp?v=1
mastodon_id: 105814266085602375
---

[Sourcehut][1] is a free and open source platform to develop software. It
provides different services like git hosting, issue tracking, continuous
integration and mailing-lists. This platform also offers secondary services such
as a "pastebin-like" tool named _paste.sr.ht_.

As a long-time and frequent GitHub user, I use two essential vim plugins to
collaborate:

- [vim-fugitive][2]: I use the `:GBrowse` command to share a code snippet
  or an entire file, usually during a discussion (in combination with
  [fzf.vim][4] to quickly find what I am looking for).
- [vim-gist][3]: this plugin allows me to create _gists_ from within vim by
  typing `<esc>:Gi<tab><enter>`. I share git diffs, various drafts, notes, etc.
  I configured this plugin so that it creates a private gist by default and puts
  the URL into the system's clipboard. It's very effective!

When I started to use sourcehut, I couldn't use `:GBrowse` anymore and, when I
asked for help on IRC once, some folks told me about the _paste_ service (I
shared GitHub's gists as I normally do and I am not sure they liked it). Writing
a vim plugin was on my todo-list for a while. I wrote some sort of plugins in
the past but nothing really serious.

There we are. **I wrote [srht.vim][5]**, a plugin for interacting with some
sourcehut services. This plugin allows to use `:GBrowse` with sourcehut git
repositories when vim-fugitive is installed, and it provides a `:SrhtPaste`
command, similar to vim-gist. The latter is heavily inspired by the work of
Yasuhiro Matsumoto, the author of the vim-gist plugin, for two reasons: (1) I am
so used to the `:Gist` command that I wanted a similar "user interface", _i.e._
same command arguments and messages, and (2) the author writes excellent vim
plugins (I really needed some concrete examples to follow after having read
[Learn Vimscript the Hard Way][6]).

srht.vim can be installed using any package manager (I think) but I personally
use Vim's built-in package support (see [`:help packages`][7]). Both `curl` and
the [webapi-vim][8] plugin are needed, too (it might change in the future).

```
$ mkdir -p ~/.vim/pack/willdurand/start
$ cd !$
$ git clone https://git.sr.ht/~willdurand/srht.vim
$ vim -u NONE -c "helptags srht.vim/doc" -c q
```

The current state of this plugin is enough for my needs but the `:SrhtPaste`
command is way less powerful than the `:Gist` one and the `:GBrowse` integration
might not handle some edge cases very well. Get in touch if you want to use this
plugin but it doesn't work for you right now, though.

Depending on how sourcehut evolves in the future, I'd like to add
omni-completion to reference issues in commit messages, which is another feature
(from [vim-rhubarb][9]) that I use very often!

Let me know if you have ideas to further improve [my first vim plugin][5].
Cheers!

[1]: https://sourcehut.org/
[2]: https://github.com/tpope/vim-fugitive
[3]: https://github.com/mattn/vim-gist
[4]: https://github.com/junegunn/fzf.vim
[5]: https://git.sr.ht/~willdurand/srht.vim
[6]: https://learnvimscriptthehardway.stevelosh.com/
[7]: https://vimhelp.org/repeat.txt.html#packages
[8]: https://github.com/mattn/webapi-vim
[9]: https://github.com/tpope/vim-rhubarb
