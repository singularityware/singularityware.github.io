---
title: arch bootstrap module
sidebar: user_docs
permalink: build-arch
folder: docs
toc: false
---

This module allows you to build a Arch Linux based container.

{% include toc.html %}

## Overview
Use the `arch` module to specify a base for an Arch Linux based container. Arch Linux uses the aptly named the `pacman` package manager (all puns intended). 

## Keywords
```
Bootstrap: arch
```
The **Bootstrap** keyword is always mandatory. It describes the bootstrap module to use.

The Arch Linux bootstrap module does not name any additional keywords at this time. By defining the `arch` module, you have essentially given all of the information necessary for that particular bootstrap module to build a core operating system.

## Notes 
Arch Linux is, by design, a very stripped down, light-weight OS.  You may need to perform a fair amount of configuration to get a usable OS. Please refer to [this README.md](https://github.com/singularityware/singularity/blob/master/examples/arch/README.md) and the [Arch Linux example](https://github.com/singularityware/singularity/blob/master/examples/arch/Singularity) for more info.
