---
layout: post
title: "Converting my blog posts to audio files"
location: Clermont-Fd Area, France
redirect_from:
  - /2012/02/29/crazy-idea-1-converting-my-blog-posts-in-audio-files/
updates:
  - date: 2022-03-22
    content: |
      I proofread this article and fixed some links. I also recently removed the
      audio files on this website because I stopped generating audio files a
      while ago. It was cool and probably useful 10 years ago but I expect
      screen readers to be a lot more efficient nowadays.
---

Yesterday, I discovered the `say` command on my Mac. Its aim is to convert text
to audible speech and that works really well. Then, I had the idea of creating
audio files from my blog posts because (1) it's fun and (2) it could possibly
improve accessibility on this website.

The `say` command generates `aiff` audio files but that isn't supported by the
`audio` HTM5 tag. I converted the `aiff` files to `mp3` using the well-known
[ffmpeg](https://ffmpeg.org/) tool.

Please welcome [Speaker](https://github.com/willdurand/Speaker), my fun work
from last evening! **Speaker** aims to convert my blog posts written in markdown
to `mp3` files. It is a tiny shell script I enjoyed writing.

```bash
USAGE:
  ./speaker [-h] [-d <output directory>] <filename>
```

I used [roundup](https://github.com/bmizerany/roundup) to test it. I love shell
scripts but writing them without any tests is a pain, there is often a condition
that is not good, a typo, or something else. That often makes me crazy... Well,
problem solved with **roundup**!  Here is my test suite output:

```bash
$ ./speaker-test.sh
speaker
it_shows_help_with_no_argv:                      [PASS]
it_shows_help_with_h_option:                     [PASS]
it_creates_mp3_file:                             [PASS]
it_creates_mp3_file_in_existing_directory:       [PASS]
it_creates_mp3_file_in_new_directory:            [PASS]
=========================================================
Tests:    5 | Passed:   5 | Failed:   0
```

To sanitize the text to speech, I used some regular expressions. It probably
needs some improvements but it works pretty well:

```bash
# Sanitize markdown content
content=`echo "$content" | sed -e 's/[\*_]//g'`
content=`echo "$content" | sed -e 's/\[\(.*\)\](\(.*\))/\1/g'`
content=`echo "$content" | sed -e 's/:[p|D]/./g'`
...
```

For the other parts, you can take a look at [the
code](https://github.com/willdurand/Speaker/blob/master/speaker) :)

Because I wanted to expose these audio files on this website, I tweaked the
template to integrate an `audio` tag. I also used
[html5media](https://github.com/etianen/html5media) to render this tag in all
major browsers (I don't know if there is a better solution).

```html
<audio src="/mp3/my-blog-title.mp3" controls preload></audio>
```

Last, to automagically generate audio files, I wrote a
[pre-commit](https://github.com/willdurand/Speaker/blob/master/hooks/pre-commit)
script to build the audio file when I commit blog posts.

That's all folks!
