---
title: Singularity Import
sidebar: user_docs
permalink: docs-import
toc: false
folder: docs
---

Singularity import is essentially taking a dump of files and folders and adding them to your image. This works for local compressed things (e.g., tar.gz) but also for docker image layers that you don't have on your system. As of version 2.3, import of docker layers includes the environment and metadata without needing sudo. It's generally very intuitive.

As an example, here is a common use case: wanting to import a Docker image:

```
singularity import container.img docker://ubuntu:latest
```
