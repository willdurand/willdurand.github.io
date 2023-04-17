---
layout: post
location: Clermont-Fd Area, France
tags: [PHP]
title: Taking Geocoder to the next level
updates:
  - date: 2023-04-17
    content: I proofread this article and fixed some links.
---

Almost two years ago, I pushed [the first
commits](https://github.com/geocoder-php/Geocoder/commit/a5e2ebe5a13eab1da663681e0901072b8b121d49)
of a project that was anything but useful. I started this project to ease a
friend's life – @themouette – who was playing with the Google Maps API in a PHP
app back then. I named this project [Geocoder](https://geocoder-php.org) because
I could not come up with a better name...

A few weeks later, this project got a lot more attention, I received very
positive feedback and people started to contribute. That was amazing! At the
time of writing, more than 630 commits have been made by 43 contributors.
According to [Packagist](https://packagist.org/packages/willdurand/geocoder), it
has been installed more than 40K times. Awesome for such a library!

Geocoder is an abstraction layer for most of the existing third-party geocoding
APIs. It is rather specific and that is why these numbers look even more awesome
to me! This project became my most starred library on
[GitHub](https://github.com/willdurand), and the project has been featured by
Smashing Magazine on Twitter ❤️

I believe it became relatively successful because Geocoder has been created to
answer only one need, and the scope was small enough. The library was focused on
(reverse) geocoding addresses, nothing more and certainly nothing fancy.

Earlier this week, I decided to move forward with this project. First of all, I
am glad to unveil a new website available at
[geocoder-php.org](https://geocoder-php.org). The homepage introduces Geocoder
as well as its related projects. More projects will join the family soon! Each
project has its own documentation page and a cookbook will be published soon..

In addition to that, a new GitHub organization called
[geocoder-php](https://github.com/geocoder-php) has been created to gather
all the folks interested in the project. It is critical for such a project to be
maintained, and that is why I asked key people to join the new Geocoder family.
Our goal is to make Geocoder even better and future-proof!

Last but not least, Geocoder now has its own shiny logo:

<img src="/images/posts/geocoder.png" style="width: 300px" />

We, the Geocoder core team, intend to ship new features and release often. Your
feedback is important. Please get in touch with us about missing features and so
on. Also, if you are using Geocoder, I would personally be glad to hear from
you!

Special thanks to [Antoine](https://github.com/toin0u),
[Markus](https://github.com/Baachi), and [all
contributors](https://github.com/geocoder-php/Geocoder/contributors).
