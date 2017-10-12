---
title:  "Announcement: Problem downloading from Docker Hub to be resolved soon"
category: news
permalink: 2017-docker-problem
---

To all Singularity users,
 
On Tuesday September 12, Docker released a new version of Docker image metadata.  This means that any new images built on Docker Hub cannot currently be downloaded using a singularity `pull` or other commands like `shell`, `exec`, and `bootstrap` when updated Docker registries are queried.
 
Vanessa (`@v`) has created an interim fix for the problem and we have merged it into the development branch.  Pending further testing we plan to merge this fix into master and create a new minor release (2.3.2).  We will make another announcement as soon as it is ready to install. 
 
Thanks for your patience! 
 
The Singularity team

{% include links.html %}
