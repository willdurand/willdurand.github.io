---
layout: post
title: "Suggested changes in code reviews"
location: "Freiburg, Germany"
image: /images/posts/2020/01/suggested-changes-social.png
---

I recently wrote that [I wanted to blog more often and share how I
work](/2019/12/20/sigcont/). Today's article is about suggestions in code
reviews.

A little more than a year ago, GitHub introduced a button to [suggest
changes](https://haacked.com/archive/2019/06/03/suggested-changes/) when
reviewing Pull Requests. It's a neat but somewhat limited feature. I only use
this button as a replacement for (rather confusing) comments like `s/typo/fix/`
(which means: "please replace 'typo' with 'fix'"). The GitHub feature does not
work well when I want to suggest a larger change (that could be spread across
multiple files).

About 95% of my code reviews involves checking out the patch proposed in the
Pull Request locally. There are many reasons for doing this but I usually make
sure a bug fix actually fixes the issue, test the new feature or try to break
things (before QA). In some cases, the proposed approach does not seem optimal
and I want to see if I can make some improvements. Sometimes, the patch is a
"Work in Progress" (WIP) and their author asks for help.

I use [hub](https://github.com/github/hub) on top of `git` so that I can `git
checkout` a Pull Request using its URL (as shown below). `hub` has many more
features and it's a gem!

```
$ git checkout https://github.com/user/repo/pull/123
```

## Sharing suggestions

When I want to share the changes I made locally, I use [`git
diff`](https://git-scm.com/docs/git-diff) to get a representation of these
changes and `pbcopy` (on MacOS) to copy the `diff` output to the clipboard (I
think we can use `xsel` or `xclip` on Linux but I am not sure):

```
$ git diff | pbcopy
```

I then go back to the GitHub page and I paste the changes inside a `diff` block
after one or two lines of text describing the diff and giving some more context:

    How about this? Adding `git` again seems too much:

    ```diff
    diff --git a/some_file.txt b/some_file.txt
    index 6b0c6cf..b37e70a 100644
    --- a/some_file.txt
    +++ b/some_file.txt
    @@ -1 +1 @@
    -this is a git diff test example
    +this is a diff example
    ```

Et voilà.

![A GitHub comment with a diff](/images/posts/2020/01/diff-comment.png)

## Applying suggestions

Anyone who receives such a comment can apply the provided `diff` locally. My
current workflow is to copy the `diff` to the clipboard and use the set of
commands below to apply it (in reality, I use <kbd>ctrl</kbd> + <kbd>r</kbd> to
search through my history as it is faster).

```
$ pbpaste | patch -p1
```

`pbpaste` is used to paste content as its name suggests. If you take a closer
look at the previous `diff` example, `git` prefixes diff paths with `a` and `b`
in the output, which is why `-p1` is needed: it removes `a/` and `b/` so that
`patch` finds the right files to patch.

I have been providing suggestions like this for several years now and some folks
in my team started to do that as well (and even some contributors!). This
workflow is a nice way to share ideas and start discussions. What do you think?
