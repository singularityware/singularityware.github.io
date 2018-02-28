---
title: Releases
sidebar: main_sidebar
permalink: all-releases
keywords: news, blog, updates, release notes, announcements
folder: releases
toc: false
---

<p>For all releases, please go to Singularity's <a href="https://github.com/singularityware/singularity/releases" target="_blank">GitHub page</a>.</p>

### Downloads

<div class="home">

    <div class="post-list">
    {% for post in site.categories.releases %}

    <h2><a class="post-link" href="{{ post.url | remove: "/" }}">{{ post.title }}</a></h2>
    <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }} 
      {% if post.targz %}
      <a class="no-after" href="{{ site.repo }}/archive/{{ post.targz }}" target="_blank">
       <i class="fa fa-download no-after"></i></a>
      {% else %}
      <a class="no-after" href="{{ site.repo }}/releases/download/{{ post.version }}/singularity-{{ post.version }}.tar.gz" target="_blank">
       <i class="fa fa-download no-after"></i></a>
      {% endif %}
     </span>
    {% endfor %}

</div>
