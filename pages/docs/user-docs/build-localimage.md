---
title: localimage bootstrap module
sidebar: user_docs
permalink: build-localimage
folder: docs
toc: false
---

This module allows you to build a container from an existing Singularity container on your host system. The name is somewhat misleading because your container can be in either image or directory format.

{% include toc.html %}

## Overview
You can use an existing container image as your "base," and then add customization. This allows you to build multiple images from the same starting point. For example, you may want to build several containers with the same custom python installation,  the same custom compiler toolchain, or the same base MPI installation. Instead of building these from scratch each time, you could start with the appropriate local base container and then customize the new container in `%post`, `%environment`, `%runscript`, etc.

## Keywords
```
Bootstrap: localimage
```
The **Bootstrap** keyword is always mandatory. It describes the bootstrap module to use.
```
From: /path/to/container/file/or/directory
```
The **From** keyword is mandatory.  It specifies the local container to use as a base.

## Notes
When building from a local container, all previous definition files that led to the creation of the current container will be stored in a directory within the container called `/.singularity.d/bootstrap_history`.  Singularity will also alert you if environment variables have been changed between the base image and the new image during bootstrap.
