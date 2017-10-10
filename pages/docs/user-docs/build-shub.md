---
title: shub bootstrap module
sidebar: user_docs
permalink: build-shub
folder: docs
toc: false
---

This module allows you to build a container from a container hosted on Singularity Hub. 

{% include toc.html %}

## Overview
You can use an existing container on Singularity Hub as your "base," and then add customization. This allows you to build multiple images from the same starting point. For example, you may want to build several containers with the same custom python installation, the same custom compiler toolchain, or the same base MPI installation. Instead of building these from scratch each time, you could create a base container on Singularity Hub and then build new containers from that existing base container adding customizations in `%post`, `%environment`, `%runscript`, etc.

## Keywords
```
Bootstrap: shub
```
The **Bootstrap** keyword is always mandatory. It describes the bootstrap module to use.
```
From: shub://username/container:branch
From: shub://2976
```
The **From** keyword is mandatory.  It specifies the local container to use as a base.  You can either use the `username/container:branch` syntax (where `branch` is optional and defaults to `latest`) or specify the commit ID number.

## Notes
When bootstrapping from a local image, all previous definition files that led to the creation of the current image will be stored in a directory within the container called `/.singularity.d/bootstrap_history`.  Singularity will also alert you if environment variables have been changed between the base image and the new image during bootstrap.
