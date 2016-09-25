---
title: Singularity
keywords: containers,
sidebar: home_sidebar
permalink: index.html
toc: false
---

Singularity enables users to have full control of their environment. This means that a non-privileged user can "swap out" the operating system on the host for one they control. So if the host system is running RHEL6 but your application runs in Ubuntu, you can create an Ubuntu image, install your applications into that image, copy the image to another host, and run your application on that host in it's native Ubuntu environment!

Singularity also allows you to leverage the resources of whatever host you are on. This includes HPC interconnects, resource managers, file systems, GPUs and/or accelerators, etc. Singularity does this by enabling several key facets:

* Encapsulation of the environment
* Containers are image based
* No user contextual changes or root escalation allowed
* No root owned daemon processes

## Getting started

Jump in and <a href="/start"><strong>get started</strong></a>.

<hr style="margin-top:20px">

<div class="row">
  {% for post in site.categories.news limit:3 %}
   <div class="col-md-3">
      <h2><a class="post-link" href="{{ post.url | remove: "/" }}">{{ post.title }}</a></h2>
      <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>
      <p>{{ post.content | truncatewords: 20 | strip_html }}</p>  
   </div>
  {% endfor %}
</div>
