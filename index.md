---
title: Singularity
keywords: containers,
sidebar: main_sidebar
permalink: index.html
toc: false
---

Singularity enables users to have full control of their environment. Singularity containers can be used to package entire scientific workflows, software and libraries, and even data. This means that you don't have to ask your cluster admin to install anything for you - you can put it in a Singularity container and run. Did you already invest in Docker? The Singularity software can import your Docker images without having Docker installed or being a superuser. Need to share your code? Put it in a Singularity container and your collaborator won't have to go through the pain of installing missing dependencies. Do you need to run a different operating system entirely? You can "swap out" the operating system on your host for a different one within a Singularity container. As the user, you are in control of the extent to which your container interacts with its host. There can be seamless integration, or little to no communication at all. What does your workflow look like?


<a href="/assets/img/diagram/singularity-2.4-flow.png" target="_blank" class="no-after">
   <img style="max-width:900px" src="/assets/img/diagram/singularity-2.4-flow.png">
</a>

It's pretty simple. You can make and customize containers locally, and then run them on your shared resource. As of version 2.3, you can even pull Docker image layers into a new Singularity image without sudo permissions. Singularity also allows you to leverage the resources of whatever host you are on. This includes HPC interconnects, resource managers, file systems, GPUs and/or accelerators, etc. Singularity does this by enabling several key facets:

* Encapsulation of the environment
* Containers are image based
* No user contextual changes or root escalation allowed
* No root owned daemon processes

## Getting started

Jump in and <a href="/quickstart"><strong>get started</strong></a>. Have a publication or recently installed or updated Singularity on your cluster? Please tell us about it!

<a target="_blank" class="btn btn-primary navbar-btn cursorNorm" role="button" href="https://goo.gl/forms/D7ed1dfLeNvml6no1">Register your Cluster</a> <a target="_blank" href="https://goo.gl/forms/tGBKnKwplNyRZRSm2" class="btn btn-primary navbar-btn cursorNorm" role="button">Add a Publication</a>


<hr style="margin-top:20px">

<div class="row">
  {% assign loopcount = 1 %}
  {% for post in site.posts %}

   {% if loopcount < 4 %}

   <!-- Parse news-->
   {% if post.category == "news" %}
   {% assign loopcount = loopcount | plus: 1 %}
   <div class="col-md-4">
      <h2><a class="post-link" href="{{ post.url | remove: "/" }}">{{ post.title }}</a></h2>
      <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>
      <p>{{ post.content | truncatewords: 20 | strip_html }}</p>  
   </div>
   {% endif %}

   {% if post.category == "releases" %}
   {% assign loopcount = loopcount | plus: 1 %}
   <div class="col-md-4">
      <h2><a class="post-link" href="{{ post.url | remove: "/" }}">{{ post.title }}</a></h2>
      <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>
      <p>{{ post.content | truncatewords: 20 | strip_html }}</p>  
   </div>
   {% endif %}
   {% endif %}

  {% endfor %}
</div>
