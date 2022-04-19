---
layout: post
title: "First patch in the Linux Kernel"
location: "Freiburg, Germany"
image: /images/posts/2021/02/linux-kernel.webp
tweet_id: 1363764147842916353
---

Below is the [very first patch][1] that I recently landed in the Linux Kernel:

```
diff --git a/drivers/staging/rtl8192e/rtllib_wx.c b/drivers/staging/rtl8192e/rtllib_wx.c
index aa26b2fd2774..2e486ccb6432 100644
--- a/drivers/staging/rtl8192e/rtllib_wx.c
+++ b/drivers/staging/rtl8192e/rtllib_wx.c
@@ -341,8 +341,6 @@ int rtllib_wx_set_encode(struct rtllib_device *ieee,
 		goto done;
 	}

-
-
 	sec.enabled = 1;
 	sec.flags |= SEC_ENABLED;
```

If you're not familiar with the [unified format][2], this patch removed two
blank lines in a (random) C file. It took me an hour to write and test it as I
double-checked every single command I ran to avoid making silly mistakes. I was
kinda terrified but everything went well. Since then, I contributed [some more
patches][4] to the [staging][3] subsystem. Patches fixing stylistic issues are
welcomed in this subsystem and it is where newcomers should start.

## Gaining confidence

I am proud of my first patch. Let's be honest, this patch won't make the kernel
safer or anything like that, I only removed two blank lines and it's _just_ a
staging driver (but distributions like [Debian include it][9] nonetheless). I
wanted to write about it because I think it's important to be reminded that, no
matter our experience, we always have something to learn and we must learn to
walk before we can run.

Very few people make outstanding contributions on a new project on Day 1. It
takes time to get used to the contribution process, the different tools, the
people you work with, etc. This simple patch introduced me to some of the Linux
Kernel Mailing-Lists and how to use them. I learned about the staging subsystem
and the whole concept of "subsystems". Last but not least, I understood how
patches were merged into the main Linux Kernel repository by following my commit
from my local environment to [Linus Torvalds' tree][5]:

1. I submitted a patch to the [DriverDev-Devel][15] mailing-list
2. after review, the patch landed in the _staging-testing_ branch of [Greg
   Kroah-Hartman's tree][3] (Greg KH is the maintainer of the staging subsystem)
3. after testing, the patch was merged into the _staging-next_ branch
4. Greg KH prepared a (short-lived) tag for Linus and [requested][7] a `git pull`
5. Linus [pulled][8] the tag from Greg KH's tree
6. [First patch in the Linux Kernel][18]! :)

## Email-based `git` workflow

Submitting a first patch to the Linux Kernel is not super complicated but it is
_different_ because GitHub introduced a new approach to making Open Source
contributions that became extremely popular. This platform enabled many
developers, including myself, to work on Open Source projects using Pull/Merge
Requests.

The Linux Kernel uses emails and mailing-lists to distribute patches and review
code. [sourcehut][10] is a platform that leverages this process as well. I like
that approach because all the metadata around the source code is open, public
and sort of distributed. If GitHub goes down, a team cannot collaborate anymore
because they cannot exchange patches or review code, until GitHub comes back.
When [GitHub removes a repository][12] for some reasons, all the past code
reviews and patches (Pull Requests) are lost.

Other Open Source projects like Firefox have [a different workflow][11] too and
it isn't really easier than emails. That being said, most email clients are not
compatible with the email-based `git` workflow by default, and that's a huge
problem. This workflow requires [plaintext emails][13] and, for the Linux Kernel
as well as platforms like sourcehut, text should be wrapped at 72 columns and
bottom posting should be used. The majority of email clients will be configured
with HTML, no wrap (and/or no `format=flowed` support) and top posting by
default, ugh.

Therefore, email clients that run in a terminal (like [aerc][14]) are kinda
mandatory and I can see how user _unfriendly_ that is. I spend most of my time
working in a terminal, yet I do not use such clients. I started to use `aerc`
lately, though. It's the only way for me to be as efficient as I am with GitHub
because `aerc` allows me to review, test and apply patches with ease. We'll see
how that goes on the long run.

## Conclusion

As you can see here, anyone can contribute to the Linux Kernel. For me, it's a
personal achievement that makes me super happy. Then again, I do not think my
first contribution has been very useful but it's _something_. I'll continue to
land similar patches until I find some more involved problems to solve.

If you think this is stupid, well, not everyone agrees with you ;-)

> willdurand> here is an example where I sent a series to cleanup a union and
> each patch fixes a single field in a struct: [link][17]. I realize it's a lot
> of very small commits and I am not sure if that's the right approach.
>
> gregkh> willdurand: that approach was PERFECT! Exactly the correct thing to do,
> and the best example of "hey, go do it like that patch series" I have seen in a
> while.  Nice job.

If you'd like to contribute too, [Kernelnewbies][16] has a lot of information to
get started and everyone I interacted with has been very friendly.

[1]: https://lore.kernel.org/driverdev-devel/20210213034711.14823-1-will+git@drnd.me/
[2]: https://en.wikipedia.org/wiki/Diff#Unified_format
[3]: https://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git/
[4]: https://lore.kernel.org/driverdev-devel/?q=a:will+git@drnd.me
[5]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/
[7]: https://lore.kernel.org/lkml/YCqhISE0U6%2FUJoLb@kroah.com/
[8]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=5d99aa093b566d234b51b7822c67059e2bd3ed8d
[9]: https://wiki.debian.org/rtl819x
[10]: https://sourcehut.org/
[11]: https://twitter.com/couac/status/1245323812729753600
[12]: https://twitter.com/grhmc/status/1334138105738256389
[13]: https://useplaintext.email/
[14]: https://aerc-mail.org/
[15]: https://lore.kernel.org/driverdev-devel/
[16]: https://kernelnewbies.org/
[17]: https://lore.kernel.org/driverdev-devel/20210219101206.18036-1-will+git@drnd.me/T/#u
[18]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=465e8997e8543f78aac5016af018a4ceb445a21b
