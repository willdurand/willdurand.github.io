---
layout: post
title: "Moziversary #4"
location: "Freiburg, Germany"
image: /images/posts/2022/05/moziversary-4-social.webp
tags: [mozilla]
mastodon_id: 108225742381978909
---

_Today is my fourth Moziversary 🎂 I have been working at Mozilla as a full-time
employee for 4 years. I blogged two times before: in [2020][] and [2021][]. What
happened in 2019? I. Don't. Know._

I was hired as a Senior Web Developer on [addons.mozilla.org][] (AMO). I am now
a [Staff Software Engineer][promotion] in the Firefox WebExtensions team. I
officially [joined this team][new-team] in January. Since then, I became a
[peer][] of the [Add-ons Manager][] and [WebExtensions][] modules.

## Farewell AMO!

As mentioned above, I moved to another team after many years in the AMO team.
If I had to summarize my time in this team, I would probably say: "I did my
part".

Earlier this year, I transferred ownership of more than 10 projects that I
either created or took over to my former (AMO) colleagues 😬 I was maintaining
these projects in addition to the bulk of my work, which has been extremely
diverse. As far as I can remember, I...

- worked on countless user-facing features on AMO, quickly becoming the [top
  committer on addons-frontend][frontend-contribs] (for what it's worth)
- contributed many improvements to the AMO backend (Django/Python). For
  example, I drastically improved the reliability of the Git extraction system
  that we use for signed add-ons
- developed a set of anti-malware scanning and code search tools that have
  been "a game changer to secure the add-ons ecosystem for Firefox"
- introduced [AWS Lambda][] to our infrastructure for some (micro) services
- created prototypes, e.g., I wrote a CLI tool leveraging [SpiderMonkey][]
  to dynamically analyze browser extension behaviors
- [almost][promoted-addons] integrated Stripe with AMO 🙃
- shipped entire features spanning many components end-to-end like the [AMO
  Statistics][] (AMO frontend + backend, BigQuery/ETL with Airflow, and some
  patches in Firefox)
- created [various dev/QA tools][nonprod-tools]

Last but not least, I started and developed a collaboration with Mozilla's Data
Science team on a Machine Learning (security-oriented) project. This has been
one of my best contributions to Mozilla to date.

## What did I do over the last 12 months?

I built the "new" [AMO blog][]. I played with [Eleventy][] for the first time
and wrote some PHP to tweak the WordPress backend for our needs. I also
"hijacked" our addons-frontend project a bit to [reuse some logic and
components][addons-frontend] for the "enhanced add-on cards" used on the blog
(screenshot below).

![](/images/posts/2022/05/amo-blog.webp)
_The AMO blog with an add-on card for the "OneTab" extension. The "Add to
Firefox" button is dynamic like the install buttons on the main AMO website._
{:.with-caption}

Next, I co-specified and implemented a Firefox feature to detect search
hijacking at scale. After that, I started to work on some of the new [Manifest
V3 APIs in Firefox][mv3] and eventually joined the WebExtensions team full-time.

I also...

- wrote a [blog post about the add-ons linter][linter-blogpost] on the Community
  Blog
- interviewed candidates (if you want to discuss, [we're hiring][hiring] 😉)
- took the time to meet new colleagues in a few [donut chats][donut]
- accidentally prevented huge unnecessary storage costs 😅

This period has been complicated, though. The manager who hired me and helped
me grow as an engineer left last year 😭 Some other folks I used to work with
are no longer at Mozilla either. That got me thinking about my career and my
recent choices. I firmly believe that moving to the WebExtensions team was the
right call. Yet, most of the key people who could have helped me grow further
are gone. Building trustful relationships takes time and so does having
opportunities to demonstrate capabilities.

Sure, I still have plenty of things to learn in my current role but I hardly
see what the next milestone will be in my career at the moment. That being
said, I love what I am doing at Mozilla and my team is fabulous ❤️

Thank you to everyone in the Add-ons team as well as to all the folks I had the
pleasure to work with so far!

[2020]: {% post_url 2020-05-01-moziversary-2 %}
[2021]: {% post_url 2021-05-01-moziversary-3 %}
[AMO Statistics]: https://blog.mozilla.org/addons/2020/06/10/improvements-to-statistics-processing-on-amo/
[AMO blog]: https://addons.mozilla.org/blog/
[AWS Lambda]: https://aws.amazon.com/lambda/
[Add-ons Manager]: https://wiki.mozilla.org/Modules/All#Add-ons_Manager
[SpiderMonkey]: https://spidermonkey.dev/
[WebExtensions]: https://wiki.mozilla.org/Modules/All#Webextensions
[addons-frontend]: https://github.com/mozilla/addons-frontend/tree/5518fc1091241849f1f90634fe5d8f5d3cce2688#addons-frontend-blog-utils
[addons.mozilla.org]: https://addons.mozilla.org/
[donut]: https://www.donut.com/
[eleventy]: https://www.11ty.dev/
[frontend-contribs]: https://github.com/mozilla/addons-frontend/graphs/contributors
[hiring]: https://www.mozilla.org/en-US/careers/
[linter-blogpost]: https://blog.mozilla.org/addons/2021/12/07/new-javascript-syntax-support-in-add-on-developer-tools/
[mv3]: https://blog.mozilla.org/addons/2021/05/27/manifest-v3-update/
[new-team]: {% post_url 2022-01-25-new-team-mozilla %}
[nonprod-tools]: {% post_url 2022-03-29-some-non-production-tools-i-wrote %}
[peer]: https://www.mozilla.org/en-US/about/governance/policies/module-ownership/
[promoted-addons]: https://blog.mozilla.org/addons/2021/01/21/promoted-add-ons-pilot-wrap-up/
[promotion]: {% post_url 2021-02-26-i-got-a-promotion %}
