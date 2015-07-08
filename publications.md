---
layout: page
title: Publications
tagline: "Papers I've written."
---

Since January 2013, I am a PhD student at Michelin. I am conducting my research
work in the software testing field, and I focus on Model-based Testing but also
on formal model inference. You can find my publications below, and you may also
have a look at my [DBLP
entry](http://dblp.uni-trier.de/pers/hd/d/Durand:William.html).

---

<ul class="publications">
  {% for data in site.data.publications %}
  <h2 class="title">{{ data.year }}</h2>

  <ul class="publications-by-year {{ data.year }}">
    {% for publication in data.publications %}
    <li class="publication">
      {{ publication.authors }}. <strong>{{ publication.title }}</strong>. <em>{{ publication.booktitle }}</em>, {{ publication.where_and_when }}.
      {% if publication.doi_url %}[<a href="{{ publication.doi_url }}">doi</a>]{% endif %}
      {% if publication.pdf %}[<a href="/papers/{{ publication.pdf }}">pdf</a>]{% endif %}
    </li>
    {% endfor %}
  </ul>
  {% endfor %}
</ul>
