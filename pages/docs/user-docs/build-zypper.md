---
title: zypper bootstrap module
sidebar: user_docs
permalink: build-zypper
folder: docs
toc: false
---

This module allows you to build a Suse style container from a mirror URI. 

{% include toc.html %}

## Overview
Use the `zypper` module to specify a base for a Suse-like container.  You must also specify a URI for the mirror you would like to use.  

## Keywords
```
Bootstrap: zypper
```
The **Bootstrap** keyword is always mandatory. It describes the bootstrap module to use.
```
OSVersion: 42.2
```
The **OSVersion** keyword is optional. It specifies the OS version you would like to use.  It is only required if you have specified a %{OSVERSION} variable in the `MirrorURL` keyword. 
```
MirrorURL: http://download.opensuse.org/distribution/leap/%{OSVERSION}/repo/oss/
```
The **MirrorURL** keyword is mandatory.  It specifies a URL to use as a mirror when downloading the OS.
```
Include: somepackage
```
The **Include** keyword is optional.  It allows you to install additional packages into the core operating system.  It is a best practice to supply only the bare essentials such that the `%post` section has what it needs to properly complete the build.  One common package you may want to install when using the `zypper` build module is zypper itself. 

