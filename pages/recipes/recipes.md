---
title: Recipes
sidebar: main_sidebar
permalink: tutorials
folder: recipes
toc: false
---

Interested in tutorials and recipes? You've come to the right place! Let's learn some cool stuff.

<div class="home">

    <div class="post-list">
    {% for post in site.categories.recipes %}

    <h2><a class="post-link" href="{{ post.url | remove: "/" }}">{{ post.title }}</a></h2>
    <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>
    <p>{{ post.content | truncatewords: 50 | strip_html }}</p>
    {% endfor %}

</div>
