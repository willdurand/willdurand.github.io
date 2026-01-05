---
layout: post
title: "Moziversary #5"
location: Clermont-Fd Area, France
image: /images/posts/2023/05/moziversary-social.webp
tags: [mozilla, career]
mastodon_id: 110299467683731011
credits: |
  Photo used on social media by [Deva Williamson](https://unsplash.com/@biglaughkitchen).
---

_Today is my fifth[^1] Moziversary 🎂 I joined Mozilla as a full-time employee
on May 1st, 2018. I previously blogged in ~~2019,~~ [2020][], [2021][], and
[2022][]._

[^1]: 5 years or… 5 months? I moved back to France and my current employment
    contract started on January 1st, heh. Still better than nothing, though.

I spent a good chunk of last year working on [Manifest Version 3][] (MV3) with
the rest of my team (WebExtensions / Add-ons team). My most notable "H1 2022"
contributions were probably the [`scripting`][scripting] namespace and a
[simpler versioning format][].

![](/images/posts/2023/05/extensions-button.webp)
_The extensions button and its panel (with 3 extensions listed) in Firefox._
{:.with-caption}

Next, I worked on a new primary User Interface (UI) for Firefox Desktop: the
[extensions button][extensions-button]. This feature wasn't unanimously
well-received[^2] [^3] (like many other changes to the Firefox UI). Anyway, I
addressed different (usability) issues since then, and I will continue to do so!

[^2]: In case you didn't know, many engineers read Reddit and/or other social
    platforms. I've shared actionable feedback from public comments internally
    more than once. That said, writing that the extensions button is the "worst
    Mozilla idea of the decade" isn't helpful.

[^3]: If I may, I would add that reaching out to me personally to say that you
    hate the button is probably not OK.

I also...

- took over more [web-ext][] maintenance (in addition to [addons-linter][])
- contributed content to [support.mozilla.org](https://support.mozilla.org)
  (SUMO)
- added [WebMIDI support to `navigator.permissions.query()`][bug-1437171]
- wrote my [first Web platform test][bug-1805783]. Pretty cool!
- committed to new repositories such as [scriptworker-scripts][],
  [xpi-template][], [MDN][], [browser-compat-data][], and [firefox-android][]
  lately
- found myself involved in various incidents...
- stopped hating Jira

But wait, there is more!

When I was on the AMO team, we had to maintain a feature named "Return to AMO"
(RTAMO). In short, this feature allows new users interested in an add-on on
addons.mozilla.org (AMO) to download Firefox and install the add-on when Firefox
starts for the first time (without having to go back to AMO). RTAMO was extended
to more add-ons at the beginning of 2022 (and I was involved). I became very
knowledgeable about how attribution worked and documented all of that.

This is one of the reasons why I became the main owner[^4] of the [stub
attribution service][stubattribution], an HTTP server that encodes attribution
data in Firefox (for Windows) installers and – incidentally – one of the few
critical services involved when users download Firefox. Coincidentally, this
project is now at the center of different 2023 projects. Good thing I took the
time to put this project back on track 😛

[^4]: I am (still) trying to build a small team around this project and [another
    one][go-bouncer]. If you want to join the fun, please let me know!

Phew. That was a good year! I am now involved in many cross-functional projects
and I really enjoy it. Speaking of which, I am currently working on bringing
more add-ons to Firefox for Android 🚀

That's all for now. Many thanks to everyone I worked with over the last 12
months, it’s been great working with all of you!

[2020]: /2020/05/01/moziversary-2/
[2021]: /2021/05/01/moziversary-3/
[2022]: /2022/05/01/moziversary-4/
[Manifest Version 3]: https://blog.mozilla.org/addons/2022/11/17/manifest-v3-signing-available-november-21-on-firefox-nightly/
[addons-linter]: https://github.com/mozilla/addons-linter
[browser-compat-data]: https://github.com/mdn/browser-compat-data/
[bug-1437171]: https://bugzilla.mozilla.org/show_bug.cgi?id=1437171
[bug-1805783]: https://bugzilla.mozilla.org/show_bug.cgi?id=1805783
[extension-workshop]: https://extensionworkshop.com/
[extensions-button]: https://support.mozilla.org/en-US/kb/extensions-button
[firefox-android]: https://github.com/mozilla-mobile/firefox-android
[go-bouncer]: https://github.com/mozilla-services/go-bouncer
[mdn]: https://developer.mozilla.org/
[scripting]: https://developer.mozilla.org/docs/Mozilla/Add-ons/WebExtensions/API/scripting
[scriptworker-scripts]: https://github.com/mozilla-releng/scriptworker-scripts
[simpler versioning format]: https://bugzilla.mozilla.org/show_bug.cgi?id=1793925
[stubattribution]: https://github.com/mozilla-services/stubattribution
[web-ext]: https://github.com/mozilla/web-ext
[xpi-manifest]: https://github.com/mozilla-extensions/xpi-manifest
[xpi-template]: https://github.com/mozilla-extensions/xpi-template
