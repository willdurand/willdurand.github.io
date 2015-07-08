---
layout: page
title: Talks
tagline: "Talks I've given."
---

Most of my slides are available on [Speaker
Deck](https://speakerdeck.com/willdurand), and the sources can be found at:
[slides.williamdurand.fr](http://slides.williamdurand.fr/).

---

<ul class="talks">
  {% for data in site.data.talks %}
  <h2 class="title">{{ data.year }}</h2>

  <ul class="talks-by-year {{ data.year }}">
    {% for talk in data.talks %}
    <li class="talk">
      <a href="{{ talk.slides_url }}">{{ talk.title }}</a> - <em class="talk-at">{{ talk.at }}</em>
      {% if talk.video_url %} [<a href="{{ talk.video_url }}">video</a>]{% endif %}{% if talk.post_url %} [<a href="{{ talk.post_url }}">post</a>]{% endif %}
    </li>
    {% endfor %}
  </ul>
  {% endfor %}
</ul>
