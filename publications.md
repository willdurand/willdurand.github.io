---
layout: page
title: Publications
tagline: "Papers I've written."
---

I have conducted research as a PhD student for Michelin, from January 2013 to
May 2016. My two main research fields are **software testing** and (formal)
**model inference**, which I link together by developing Model-based Testing
techniques. You can find my publications below, and you may also have a look at
my [DBLP entry](http://dblp.uni-trier.de/pers/hd/d/Durand:William.html).

---

<ul class="publications">
  {% for data in site.data.publications %}
  <h2 class="title">{{ data.year }}</h2>

  <ul class="publications-by-year {{ data.year }}">
    {% for publication in data.publications %}
    <li class="publication">
      {{ publication.authors }}. <strong>{{ publication.title }}</strong>. {% if publication.booktitle %}<em>{{ publication.booktitle }}</em>, {{ publication.where_and_when }}.{% endif %}
      {% if publication.doi_url %}[<a href="{{ publication.doi_url }}">doi</a>]{% endif %}
      {% if publication.pdf %}[<a href="/papers/{{ publication.pdf }}">pdf</a>]{% endif %}
      {% if publication.url %}[<a href="{{ publication.url }}">link</a>]{% endif %}
    </li>
    {% endfor %}
  </ul>
  {% endfor %}
</ul>
