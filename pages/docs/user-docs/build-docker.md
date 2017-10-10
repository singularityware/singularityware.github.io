---
title: docker bootstrap module
sidebar: user_docs
permalink: build-docker
folder: docs
toc: false
---

This module allows you to build a container from an existing container hosted on Docker Hub or another Docker registry. 

{% include toc.html %}

## Overview
You can use an existing container image as your "base," and then add customization. For example, instead of using the `debootstrap` module to start an Ubuntu container, you might use the official Ubuntu container from Docker Hub as a base.  You could do the same with CentOS, Debian, Arch, Suse, Alpine, BusyBox, etc.  Or maybe you want to build a container that uses CUDA and cuDNN to leverage the GPU, but ou don't want to install from scratch.  You can start with one of the `nvidia/cuda` containers and install your software on top of that.

## Keywords
```
Bootstrap: docker
```
The **Bootstrap** keyword is always mandatory. It describes the bootstrap module to use.
```
From: /username/container:tag
```
The **From** keyword is mandatory.  It specifies the local container to use as a base. In the case of some official registries (ubuntu for example) the `username` is optional.  The `tag` is also optional and will default to `latest`
```
Registry: http://custom_registry
```
The **Registry** keyword is optional.  It will default to `docker://index.docker.io`.
```
Token: yes
```
The **Token** keyword is optional.  It defaults to `no`.  In some cases the Docker API will request an authentication token which can be generated on the fly by using this keyword.  
```
IncludeCmd: yes
```
The **IncludeCmd** keyword is optional.  If included the Docker `ENTRYPOINT` or `CMD` will be used as a runscript.  Note that the IncludeCmd keyword is considered valid if it is _not empty_!  This means that `IncludeCmd: yes` and `IncludeCmd: no` are identical.  In both cases the IncludeCmd keyword is not empty, so the Docker `ENTRYPOINT` or `CMD` will be used for the runscript.  

If no `%runscript` section is provided in the Singularity recipe file, Singularity will default to using the Docker defined action as a runscript.  If a `%runscript` section is defined, Singularity will default to using it.  So the IncludeCmd keyword is actually only useful if you have defined a `%runscript` in your Singularity Recipe but you want to ignore it.  

## Notes
Docker containers are stored as a collection of tarballs called layers. When building from a Docker container the layers must be downloaded and then assembled in the proper order to produce a viable file system.  Then the file system must be converted to squashfs or ext3 format.  

Building from Docker Hub is not considered reproducible because if any of the layers of the image are changed, the container will change.  If reproducibility is important to you, consider hosting a base container on Singularity Hub and building from it instead.  
