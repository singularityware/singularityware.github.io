---
title: busybox bootstrap module
sidebar: user_docs
permalink: build-busybox
folder: docs
toc: false
---

This module allows you to build a container based on BusyBox. 

{% include toc.html %}

## Overview
Use the `busybox` module to specify a BusyBox base for container.  You must also specify a URI for the mirror you would like to use.  

## Keywords
```
Bootstrap: busybox
```
The **Bootstrap** keyword is always mandatory. It describes the bootstrap module to use.
```
MirrorURL: https://www.busybox.net/downloads/binaries/1.26.1-defconfig-multiarch/busybox-x86_64
```
The **MirrorURL** keyword is mandatory.  It specifies a URL to use as a mirror when downloading the OS.

## Notes
You can build a fully functional BusyBox container that only takes up ~600kB of disk space!
