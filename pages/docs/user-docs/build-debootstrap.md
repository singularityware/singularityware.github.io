---
title: debootstrap bootstrap module
sidebar: user_docs
permalink: build-debootstrap
folder: docs
toc: false
---

This module allows you to build a Debian/Ubuntu style container from a mirror URI. 

{% include toc.html %}

## Overview
Use the `debootstrap` module to specify a base for a Debian-like container.  You must also specify the OS version and a URI for the mirror you would like to use.  

## Keywords
```
Bootstrap: debootstrap
```
The **Bootstrap** keyword is always mandatory. It describes the bootstrap module to use.
```
OSVersion: xenial
```
The **OSVersion** keyword is mandatory. It specifies the OS version you would like to use.  For Ubuntu you can use code words like `trusty` (14.04), `xenial` (16.04), and `yakkety` (17.04).  For Debian you can use values like `stable`, `oldstable`, `testing`, and `unstable` or code words like `wheezy` (7), `jesse` (8), and `stretch` (9).
```
MirrorURL:  http://us.archive.ubuntu.com/ubuntu/
```
The **MirrorURL** keyword is mandatory.  It specifies a URL to use as a mirror when downloading the OS.
```
Include: somepackage
```
The **Include** keyword is optional.  It allows you to install additional packages into the core operating system.  It is a best practice to supply only the bare essentials such that the `%post` section has what it needs to properly complete the build.

## Notes
In order to use the `debootstrap` build module, you must have `debootstrap` installed on your system.  On Ubuntu you can install it like so:
```
$ sudo apt-get update && sudo apt-get install debootstrap
```
On CentOS you can install it from the epel repos like so:
```
$ sudo yum update && sudo yum install epel-release && sudo yum install debootstrap.noarch
```

