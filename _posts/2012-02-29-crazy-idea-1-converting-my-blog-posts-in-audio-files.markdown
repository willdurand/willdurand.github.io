---
layout: post
title: "Crazy Idea #1: Converting My Blog Posts In Audio Files"
location: Clermont-Fd Area, France
---

Yesterday, I discovered the `say` command on my Mac. Its aim is to convert text to
audible speech, and it works really well. Then, I had the idea to create audio files
from my blog posts, because it's fun, and because it could improve accessibility.

The `say` command generates `aiff` audio files, which is not really understandable by
the `audio` html5 tag. So, I had to convert this output in a `mp3` file. I used the
well-known [ffmpeg](http://ffmpeg.org/) tool, and that's all!

Please, welcome [Speaker](https://github.com/willdurand/Speaker), my fun work of last evening.
**Speaker** aims to convert my blog posts in markdown syntax to a `mp3` file. This is a tiny
shell script I enjoyed to write.

{% highlight bash %}
USAGE:
  ./speaker [-h] [-d <output directory>] <filename>
{% endhighlight %}

I used [roundup](http://bmizerany.github.com/roundup/) to test it. I love shell scripts, but
to write them without any tests is a pain, there is often a condition which is not good, a typo,
or something else. That often makes me crazy! **roundup** helps you write strong shell scripts.
Here is my test suite output:

{% highlight bash %}
$ ./speaker-test.sh
speaker
it_shows_help_with_no_argv:                      [PASS]
it_shows_help_with_h_option:                     [PASS]
it_creates_mp3_file:                             [PASS]
it_creates_mp3_file_in_existing_directory:       [PASS]
it_creates_mp3_file_in_new_directory:            [PASS]
=========================================================
Tests:    5 | Passed:   5 | Failed:   0
{% endhighlight %}

To sanitize the text to speech, I used some regular expressions. It probably needs some improvements
but it works pretty well:

{% highlight bash %}
# Sanitize markdown content
content=`echo "$content" | sed -e 's/[\*_]//g'`
content=`echo "$content" | sed -e 's/\[\(.*\)\](\(.*\))/\1/g'`
content=`echo "$content" | sed -e 's/:[p|D]/./g'`
...
{% endhighlight %}

For the other parts, check [the code](https://github.com/willdurand/Speaker/blob/master/speaker) :)

As I wanted to provide my blog posts as audio files, I tweaked my templates to integrate an `audio` html5 tag.
And I used [html5media](https://github.com/etianen/html5media) to render this tag in all major browsers (don't know
if there is a better solution).

{% highlight html %}
<audio src="/mp3/my-blog-title.mp3" controls preload></audio>
{% endhighlight %}

And to automagically generate audio files, I wrote a [pre-commit](https://github.com/willdurand/Speaker/blob/master/hooks/pre-commit)
script to build the audio file when I commit blog posts.
That's all folks!
