---
title: yum bootstrap module
sidebar: user_docs
permalink: build-yum
folder: docs
toc: false
---

This module allows you to build a Red Hat/CentOS/Scientific Linux style container from a mirror URI. 

{% include toc.html %}

## Overview
Use the `yum` module to specify a base for a CentOS-like container.  You must also specify the URI for the mirror you would like to use.  

## Keywords
```
Bootstrap: yum
```
The **Bootstrap** keyword is always mandatory. It describes the bootstrap module to use.
```
OSVersion: 7
```
The **OSVersion** keyword is optional. It specifies the OS version you would like to use.  It is only required if you have specified a %{OSVERSION} variable in the `MirrorURL` keyword. 
```
MirrorURL: http://mirror.centos.org/centos-%{OSVERSION}/%{OSVERSION}/os/$basearch/ 
```
The **MirrorURL** keyword is mandatory.  It specifies the URL to use as a mirror to download the OS.  If you define the `OSVersion` keyword, than you can use it in the URL as in the example above.
```
Include: yum
```
The **Include** keyword is optional.  It allows you to install additional packages into the core operating system.  It is a best practice to supply only the bare essentials such that the `%post` section has what it needs to properly complete the build.  One common package you may want to install when using the `yum` build module is YUM itself. 

## Notes
There is a major limitation with using YUM to bootstrap a container. The RPM database that exists within the container will be created using the RPM library and Berkeley DB implementation that exists on the host system. If the RPM implementation inside the container is not compatible with the RPM database that was used to create the container, RPM and YUM commands inside the container may fail. This issue can be easily demonstrated by bootstrapping an older RHEL compatible image by a newer one (e.g. bootstrap a Centos 5 or 6 container from a Centos 7 host).

In order to use the `debootstrap` build module, you must have `yum` installed on your system.  It may seem counter-intuitive to install YUM on a system that uses a different package manager, but you can do so.  For instance, on Ubuntu you can install it like so:
```
$ sudo apt-get update && sudo apt-get install yum
```


