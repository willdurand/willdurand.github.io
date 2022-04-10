---
layout: post
title: "Some non-production tools I wrote"
location: "Freiburg, Germany"
image: /images/posts/2022/03/some-non-production-tools-i-wrote.webp?v=1
tags: mozilla
tweet_id: 1508748161686327302
---

This is a short article about 3 different tools I authored for my needs at
Mozilla.

I worked on [AMO][] for almost 4 years and created various libraries like
[pino-mozlog][], [pino-devtools][] or an [ESLint plugin][eslint-plugin-amo] to
name a few. These libraries have been created either to improve our developer
experience or to fulfill some production requirements.

This isn't the kind of projects I want to focus on in the rest of this article,
though. Indeed, I also wrote "non-production" tools, i.e. some side projects to
improve my day-to-day work. These tools have been extremely useful to me and,
possibly, other individuals as well. I use most of them on a weekly basis and I
maintain them on my own.

## amo-info

I wrote a browser extension named [amo-info][]. This extension adds a page
action button when we open the web applications maintained by the AMO/Add-ons
team. Clicking on this button reveals a pop-up with relevant information like
the environment, git tag, feature flags, etc.

![](/images/posts/2022/03/amo-info.webp)
_The amo-info extension displaying information about addons.mozilla.org._
{:.with-caption}

If this sounds familiar to you, it might be because I already mentioned this
project in my [article about feature flags][feature flags]. Anyway, knowing what
is currently deployed in any environment at any given time is super valuable,
and this extension makes it easy to find out!

I recently added support for Firefox for Android but it [only works in
Nightly][android-extensions].

## `git npm-release`

A different tool I use every week is the [git npm-release][npm-release] command,
which automates my process to release new versions of our JavaScript packages.

```
$ git npm-release -h
usage: git npm-release [help|major|minor|patch]

git npm-release help
        print this help message.
git npm-release major
        create a major version.
git npm-release minor
        create a minor version.
git npm-release patch
        create a patch version.
```

For most of our JavaScript projects, we leverage a Continuous Integration (CI)
platform (e.g., CircleCI) to automatically publish new versions on the [npm
registry][] when a git tag is pushed to a GitHub repository.

The `git npm-release` command is built on top of [`hub`][hub], [`npm
version`][npm version] and a homemade [script to format release
notes][format-release-notes]. Running this command will (1) update the
`package.json` file with the right version, (2) make a git tag, (3) prepare the
release notes and open an editor, (4) push the commit/tag to GitHub, and (5)
create a GitHub release.

This process isn't fully automated because (3) opens an editor with the
pre-formatted release notes. I usually provide some more high level information
in the notes, which is why this step requires manual intervention.

## fx-attribution-data-reader

This is a tool I created not too long ago after telling a QA engineer that "he
could simply open the binary in an hex editor" 😅 I can find my way in hex dumps
because [my hobbies are weird][fw-reconstruction] but I get that it isn't
everyone else's cup of tea.

The [fx-attribution-data-reader][fx-reader] web application takes a Firefox for
Windows binary and displays the attribution data that may be contained in it.
Everything is performed locally (in the browser) but the results can also be
shared (URLs are "shareable").

![](/images/posts/2022/03/fx-reader.webp)
_The fx-attribution-data-reader tool with a binary loaded and parsed._
{:.with-caption}

Currently, this is mainly useful to debug some add-ons related features and it
is very niche. As such, this tool isn't used very often but this is a good
example of a very simple UI built to hide some (unnecessary) complexity.

## Conclusion

I introduced three different tools that I am happy to use and maintain. [Is it
worth the time?](https://xkcd.com/1205/) I think so because it isn't so much
about the time shaved off in this case.

It is more about the simplicity and ease of use. Also, writing new tools is fun!
I often use these ideas as excuses to learn more about new topics, be it
programming languages, frameworks, libraries, or some internals.

[amo-info]: https://addons.mozilla.org/en-US/firefox/addon/amo-info/
[amo]: https://addons.mozilla.org/
[android-extensions]: https://blog.mozilla.org/addons/2020/09/29/expanded-extension-support-in-firefox-for-android-nightly/
[eslint-plugin-amo]: https://github.com/mozilla/eslint-plugin-amo
[feature flags]: {% post_url 2020-09-22-feature-flags-in-real-life %}
[format-release-notes]: https://github.com/willdurand/dotfiles/blob/8abc8da3ca5f9f7a3d8e0d629552a15a819ad2d5/scripts/format-release-notes
[fw-reconstruction]: {% post_url 2022-03-10-spi-flash-content-analysis-and-firmware-reconstruction %}
[fx-reader]: https://williamdurand.fr/fx-attribution-data-reader/
[hub]: https://hub.github.com/
[npm registry]: https://www.npmjs.com/
[npm version]: https://docs.npmjs.com/cli/version
[npm-release]: https://github.com/willdurand/dotfiles/blob/8abc8da3ca5f9f7a3d8e0d629552a15a819ad2d5/git/commands/npm-release
[pino-devtools]: https://github.com/willdurand/pino-devtools
[pino-mozlog]: https://github.com/mozilla/pino-mozlog
