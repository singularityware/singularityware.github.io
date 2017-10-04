---
title: Local Image Builds
sidebar: user_docs
permalink: build-localimage
folder: docs
toc: false
---

This module allows you to bootstrap a container from an existing Singularity image on your host system.  You can use an existing container image as your "base" and then customize it with a new `%post` `%environment`, `%runscript`, etc.  

This module allows you to bootstrap a container from an existing Singularity image on your host system.  You can use an existing container image as your "base," and then add customization. For example, you may have a different base image for several common operating systems, or for different versions of python, or for several different compilers. Instead of building these from scratch each time, you could start with the appropriate local base image and then customize the new image in `%post`, `%environment`, `%runscript`, etc.

When bootstrapping from a local image, all previous definition files that led to the creation of the current image will be stored in a directory within the container called `/.singularity.d/bootstrap_history`.  Singularity will also alert you if environment variables have been changed between the base image and the new image during bootstrap.
