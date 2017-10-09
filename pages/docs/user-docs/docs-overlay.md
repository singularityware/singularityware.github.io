---
title: Working with Persistent Overlays
sidebar: user_docs
permalink: docs-overlay
folder: docs
toc: false
---

Persistent overlay images are new to version 2.4! This feature allows you to overlay a writable file system on an immutable read-only container for the illusion of read-write access.  

{% include toc.html %}

## Overview
A persistent overlay is an image that "sits on top" of your compressed, immutable squashfs container. When you install new software or create and modify files the overlay image stores the changes.

In Singularity versions 2.4 and later an overlay file system is automatically added to your squashfs or sandbox container when it is mounted.  This means you can install new software and create and modify files even though your container is read-only.  But your changes will disappear as soon as you exit the container.  

If you want your changes to persist in your container across uses, you can create a writable image to use as a persistent overlay.  Then you can specify that you want to use the image as an overlay at runtime with the `--overlay` option.

You can use a persistent overlays with the following commands:

- `run`
- `exec`
- `shell`
- `instance.start`

## Usage
To use a persistent overlay, you must first have a container.

```
$ singularity build ubuntu.simg shub://GodloveD/ubuntu
```

Then you must create a writable, ext3 image.  We can do so with the `image.create` command:

```
$ singularity image.create my-overlay.img
```

Now you can use this overlay image with your container.  Note that it is not necessary to be root to use an overlay partition, but this will ensure that we have write privileges where we want them.

```
$ sudo singularity shell --overlay my-overlay.img ubuntu.simg
Singularity ubuntu.simg:~> touch /foo
Singularity ubuntu.simg:~> apt-get install -y vim
Singularity ubuntu.simg:~> which vim
/usr/bin/vim
Singularity ubuntu.simg:~> exit
```

You will find that your changes persist across sessions as though you were using a writable container.

```
$ sudo singularity shell --overlay my-overlay.img ubuntu.simg
Singularity ubuntu.simg:~> ls /foo
/foo
Singularity ubuntu.simg:~> which vim
/usr/bin/vim
Singularity ubuntu.simg:~> exit
```

If you mount your container without the `--overlay` option, your changes will be gone.

```
$ sudo singularity shell ubuntu.simg
Singularity ubuntu.simg:~> ls foo
ls: cannot access 'foo': No such file or directory
Singularity ubuntu.simg:~> which vim
Singularity ubuntu.simg:~> exit
```
