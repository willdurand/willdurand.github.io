---
layout: page
title: Talks
tagline: "Talks I've given."
---

_Most of my slides are available on [Speaker
Deck](https://speakerdeck.com/willdurand). The sources can be found at:
[slides.williamdurand.fr](https://slides.williamdurand.fr/)._

<ul class="talks">
  {% for data in site.data.talks %}
  <h2 class="title">{{ data.year }}</h2>

  <ul class="talks-by-year {{ data.year }}">
    {% for talk in data.talks %}
    <li class="talk">
      <a href="{{ talk.slides_url }}">{{ talk.title }}</a>

      {% if talk.video_url %}
      [<a href="{{ talk.video_url }}">video</a>]
      {% endif %}

      {% if talk.post_url %}
      [<a href="{{ talk.post_url }}">post</a>]
      {% endif %}

      <span class="talk-at"> // {{ talk.at }}</span>
    </li>
    {% endfor %}
  </ul>
  {% endfor %}
</ul>
