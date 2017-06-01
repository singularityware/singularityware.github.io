---
title: Singularity Administration Guide
sidebar: admin_docs
permalink: admin-guide
folder: docs
toc: false
---

This document will cover installation and administration points of Singularity for multi-tenant HPC resources and will not cover usage of the command line tools, container usage, or example use cases.

{% include toc.html %}

## Installation
There are two common ways to install Singularity, from source code and via binary packages. This document will explain the process of installation from source, and it will depend on your build host to have the appropriate development tools and packages installed. For Red Hat and derivitives, you should install the following `yum` group to ensure you have an appropriately setup build server:

```bash
$ sudo yum groupinstall "Development Tools"
```

### Downloading the Source
You can download the source code either from the latest stable tarball release or via the GitHub master repository. Here is an example downloading and preparing the latest development code from GitHub:

```bash
$ mkdir ~/git
$ cd ~/git
$ git clone https://github.com/singularityware/singularity.git
$ cd singularity
$ ./autogen.sh
```

Once you have downloaded the source, the following installation procedures will assume you are running from the root of the source directory.

### Source Installation
The following example demonstrates how to install Singularity into `/usr/local`. You can install Singularity into any directory of your choosing, but you must ensure that the location you select supports programs running as `SUID`. It is common for people to disable `SUID` with the mount option `nosuid` for various network mounted file systems. To ensure proper support, it is easiest to make sure you install Singularity to a local file system.

Assuming that `/usr/local` is a local file system:

```bash
$ ./configure --prefix=/usr/local --sysconfdir=/etc
$ make
$ sudo make install
```

***NOTE: The `make install` above must be run as root to have Singularity properly installed. Failure to install as root will cause Singularity to not function properly or have limited functionality when run by a non-root user.***

### Building an RPM directly from the source
Singularity includes all of the necessary bits to properly create an RPM package directly from the source tree, and you can create an RPM by doing the following:

```bash
$ ./configure
$ make dist
$ rpmbuild -ta singularity-*.tar.gz
```

Near the bottom of the build output you will see several lines like:

```
...
Wrote: /home/gmk/rpmbuild/SRPMS/singularity-2.3.el7.centos.src.rpm
Wrote: /home/gmk/rpmbuild/RPMS/x86_64/singularity-2.3.el7.centos.x86_64.rpm
Wrote: /home/gmk/rpmbuild/RPMS/x86_64/singularity-devel-2.3.el7.centos.x86_64.rpm
Wrote: /home/gmk/rpmbuild/RPMS/x86_64/singularity-debuginfo-2.3.el7.centos.x86_64.rpm
...
```

You will want to identify the appropriate path to the binary RPM that you wish to install, in the above example the package we want to install is `singularity-2.3.el7.centos.x86_64.rpm`, and you should install it with the following command:

```bash
$ sudo yum install /home/gmk/rpmbuild/RPMS/x86_64/singularity-2.3.el7.centos.x86_64.rpm
```

*Note: If you want to have the binary RPM install the files to an alternative location, you should define the environment variable 'PREFIX' (below) to suit your needs, and use the following command to build:*

```bash
$ PREFIX=/opt/singularity
$ rpmbuild -ta --define="_prefix $PREFIX" --define "_sysconfdir $PREFIX/etc" --define "_defaultdocdir $PREFIX/share" singularity-*.tar.gz
```

We recommend you look at our <a href="/docs-security">security admin guide</a> to get further information about container priviledges and mounting.

