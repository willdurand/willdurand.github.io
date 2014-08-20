---
layout: default
title: Bookshelf
---

<h1>Books I have read.</h1>

<ul class="books">
{% for data in site.data.books %}
    <h2 class="title">{{ data.year }}</h2>

    <ul class="books-by-year {{ data.year }}">
    {% for book in data.books %}
        <li>
            <a href="{{ book.url }}">
                <span class="book-title">{{ book.title }}</span> - <em class="book-authors">{{ book.authors }}</em>
            </a>
        </li>
    {% endfor %}
    </ul>
{% endfor %}
</ul>
