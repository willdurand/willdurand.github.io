---
layout: post
title: "I got a promotion!"
location: "Freiburg, Germany"
image: /images/posts/2021/02/promotion.webp
tags: [mozilla]
credits: |
  Photo used on social media by [@ghebby](https://unsplash.com/@ag_ghebby).

---

Long story short, I have been promoted to **Staff Software Engineer**.

Julia Evans explains [what a senior engineer's job is][6] and her blog post
describes my role well enough, which is why I won't go into details here.
Instead, I chose to write a more personal "status update".

First of all, Mozilla has a great [career path for engineers][^7], which doesn't
force folks who like to code to become managers, a very common practice in
French companies (and maybe elsewhere, ugh!). It's such a relief!

Second, this new title won't change my day to day work right now: I have been
promoted because I was already doing some of the job of a staff engineer and I
likely proved that I was a good fit for this role. I still have many new things
to learn, though, and that's very exciting!

## 3615 My Life

I joined Mozilla as a frontend developer. I exclusively worked on the AMO
frontend in 2018 and eventually became [a major contributor][8]. During this
time, I started to maintain some side-projects (eslint config/plugin). After a
year, I decided to become more proficient with python so I started to contribute
to our main backend/API project. This allowed me to work on much bigger features
by myself, and I learned a lot more about add-ons and the AMO platform.

In 2019, my main focus was on hardening the AMO platform, a topic that is
unfortunately confidential. This work started as a research-y project because we
didn't really know what we could come up with. I chose to use what I learned
during [my PhD][9]: I studied the "state of the art". After that, I built several
prototypes and presented the results of my initial work to different people, got
feedback, iterated, and eventually proposed a plan to move forward. Some
prototypes became "production-ready" and are now running in production while
others have been shelved.

During this period, I also started a collaboration between a Machine Learning
(ML) team and my own team. We wanted to give ML a try but we didn't know exactly
how. I looked into that on my own first! I wanted to be able to ask good
questions and, to me, it was necessary to be more familiar with ML and have an
idea of how things should be designed. I played with scikit-learn and Jupyter to
have some preliminary results that I shared with the ML team along with a lot of
questions to ask. I don't know if that was the "right" thing to do but it worked
and the collaboration is still on-going.

In 2020, I worked on various projects between my parental leave and the rounds
of layoffs... I started to contribute to Firefox (more on that later) and I
adopted a few more projects that needed some maintenance. I also realized that I
could bridge the gap between the AMO and WebExtensions (Firefox) teams, so I
tried (and continues) to do that.

I didn't really have any goal in mind when I joined Mozilla (except not being
fired because I was a fraud, maybe). Over time, I started to look into new
topics because I needed to learn something new and things in front of me were
interesting. I feel lucky to have been assigned to this security topic back in
2019, it had a huge impact on my career because I could show what I was able to
do. I chose not to be too specialized because that's not who I am anyway (I suck
at being good at one thing so I try to be average on many things instead). I
think that works well.

I wouldn't be there without my amazing colleagues in the Add-ons team. Thanks to
all of you! A special note to my current manager (who hired me too): you were
already on my "list" of people who largely influenced my career and therefore my
life, and you continue to have an immense positive impact. I'll be forever
grateful, thank-you.

Last but not least, I couldn't end this section without mentioning my partner.
She's been very supportive and did an amazing job at taking care of our little
one while I was at work last year <3

This now sounds like an Oscar speech so let's talk about something else.

## In other news

The Firefox codebase was (and still is) kinda scary to me. This is one of those
_things_ where I thought I could never contribute to it. That's a huge project,
with a lot of users (I know what you're thinking!), and developed by many
contributors every day. Thanks to [my amazing self-confidence][1] (follow the
link if you don't get the irony), I decided to contribute to Firefox roughly [a
year ago][2], and this became my personal development goal for the rest of the
year. I landed trivial patches and made all the possible mistakes. I learned a
lot with Rob and then Luca.

In Q3 2020, I worked on [new AMO statistics][3] for add-on developers, which
involved various components[^1] and required some Firefox changes. I was able to
land some patches in Firefox in order to support the rest of my work. That was
really cool because I worked on ALL the building blocks.

Last month, I got [Commit Access Level 3][5] on Firefox! It's rewarding because
it means I earned the trust of my peers.

I am so happy!

[^1]: I was working on a project involving some frontend work and a lot of
      backend changes for AMO. I also had to prototype the ETL queries and
      implemented a feature to collect data I needed in Firefox.

[^7]: This used to be a link to a [tweet from @Gankra_](https://twitter.com/Gankra_/status/1046438955439271936):
    > i really like that mozilla has an engineer track that just tries to
    > capture the depth/responsibility of the tasks you're currently tackling,
    > and doesn't necessarily involve moving on to management roles
    >
    > [screenshot of a spreadsheet with the Mozilla's career ladder]
    {:.footnote-tweet}

[1]: {% post_url 2019-12-20-sigcont %}
[2]: {% post_url 2020-05-01-moziversary-2 %}
[3]: https://blog.mozilla.org/addons/2020/06/10/improvements-to-statistics-processing-on-amo/
[5]: https://www.mozilla.org/en-US/about/governance/policies/commit/access-policy/
[6]: https://jvns.ca/blog/senior-engineer/
[8]: https://github.com/mozilla/addons-frontend/graphs/contributors
[9]: {% post_url 2016-05-16-phd-check %}
