---
title: docker bootstrap module
sidebar: user_docs
permalink: build-docker-module
folder: docs
toc: false
---

This module allows you to build a container from image layers hosted on Docker Hub or another Docker registry. 

{% include toc.html %}

## Overview
Docker images are comprised of layers that are assembled at runtime to create an image. You can use Docker layers to create a base image, and then add your own custom software. For example, you might use Docker's Ubuntu image layers to create an Ubuntu Singularity container. You could do the same with CentOS, Debian, Arch, Suse, Alpine, BusyBox, etc.  

Or maybe you want a container that already has software installed.  For instance, maybe you want to build a container that uses CUDA and cuDNN to leverage the GPU, but you don't want to install from scratch.  You can start with one of the `nvidia/cuda` containers and install your software on top of that.  

Or perhaps you have already invested in Docker and created your own Docker containers.  If so, you can seamlessly convert them to Singularity with the `docker` bootstrap module.

## Keywords
```
Bootstrap: docker
```
The **Bootstrap** keyword is always mandatory. It describes the bootstrap module to use.
```
From: <registry>/<namespace>/<container>:<tag>@<digest>
```
The **From** keyword is mandatory.  It specifies the container to use as a base. `registry` is optional and defaults to `index.docker.io`.  `namespace` is optional and defaults to `library`.  This is the correct namespace to use for some official containers (ubuntu for example). `tag` is also optional and will default to `latest`

See [Singularity and Docker](docs-docker#how-do-i-specify-my-docker-image) for more detailed info on using Docker registries.  
```
Registry: http://custom_registry
```
The **Registry** keyword is optional.  It will default to `index.docker.io`.
```
IncludeCmd: yes
```
The **IncludeCmd** keyword is optional.  If included, and if a `%runscript` is not specified, a Docker `CMD` will take precedence over `ENTRYPOINT` and will be used as a runscript.  Note that the `IncludeCmd` keyword is considered valid if it is _not empty_!  This means that `IncludeCmd: yes` and `IncludeCmd: no` are identical.  In both cases the `IncludeCmd` keyword is not empty, so the Docker `CMD` will take precedence over an `ENTRYPOINT`.  

See [Singularity and Docker](docs-docker#what-gets-used-as-the-runscript) for more info on order of operations for determining a runscript. 

## Notes
Docker containers are stored as a collection of tarballs called layers. When building from a Docker container the layers must be downloaded and then assembled in the proper order to produce a viable file system.  Then the file system must be converted to squashfs or ext3 format.  

Building from Docker Hub is not considered reproducible because if any of the layers of the image are changed, the container will change.  If reproducibility is important to you, consider hosting a base container on Singularity Hub and building from it instead.  

For detailed information about setting your build environment see  [Build Customization](build-environment).
