---
title: Debootstrap Builds
sidebar: user_docs
permalink: build-debootstrap
folder: docs
toc: false
---

The Debian bootstrap module is a tool which is used specifically for bootstrapping distributions which utilize the `.deb` package format and `apt-get` repositories. This module will bootstrap any of the Debian and Ubuntu based distributions. When using the `debootstrap` module, the following keywords must also be defined:

 - **MirrorURL**: This is the location where the packages will be downloaded from. When bootstrapping different Debian based distributions of Linux, this will define which varient will be used (e.g. specifying a different URL can be the difference between Debian or Ubuntu).
 - **OSVersion**: This keyword must be defined as the alpha-character string associated with the version of the distribution you wish to use. For example, `trusty` or `stable`. 
 - **Include**: As with the `yum` module, the `Include` keyword will install additional packages into the core operating system and the best practice is to supply only the bare essentials such that the `%inside` scriptlet has what it needs to properly completely the bootstrap.
