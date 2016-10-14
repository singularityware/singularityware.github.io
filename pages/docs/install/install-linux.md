---
title: Install on Linux
sidebar: main_sidebar
permalink: install-linux
folder: docs
toc: false
---

## Installation from Source

You can try the following two options:

### Option 1: Download latest stable release
You can always download the latest tarball release from <a href="{{ site.repo }}/releases" target="_blank">Github</a>

Once downloaded do the following:

```bash
$ tar xvf singularity-*.tar.gz
$ cd singularity
$ ./autogen.sh
$ ./configure --prefix=/usr/local
$ make
$ sudo make install
```

### Option 2: Download the latest development code
To download the most recent development code, you should use Git and do the following:

```bash
$ git clone {{ site.repo }}.git
$ cd singularity
$ ./autogen.sh
$ ./configure --prefix=/usr/local
$ make
$ sudo make install
```

note: The 'make install' is required to be run as root to get a properly installed Singularity implementation. If you do not run it as root, you will only be able to launch Singularity as root due to permission limitations.

### Updating

To update your Singularity version, you might want to first delete the executables for the old version:

```bash
sudo rm -rf /usr/local/libexec/singularity
```
Then clone the repo fresh, or go into your Singularity repo folder, and pull the latest from master:

```bash
$ cd /path/to/singularity
$ ./autogen.sh
$ ./configure --prefix=/usr/local
$ make clean
$ make
$ sudo make install
```

## Build an RPM from source
Like the above, you can build an RPM of Singularity so it can be more easily managed, upgraded and removed. From the base Singularity source directory do the following:

```bash
$ ./autogen.sh
$ ./configure
$ make dist
$ rpmbuild -ta singularity-*.tar.gz
$ sudo yum install ~/rpmbuild/RPMS/*/singularity-[0-9]*.rpm
```

Note: if you want to have the RPM install the files to an alternative location, you should define the environment variable 'PREFIX' to suit your needs, and use the following command to build:

```bash
$ PREFIX=/opt/singularity
$ rpmbuild -ta --define="_prefix $PREFIX" --define "_sysconfdir $PREFIX/etc" --define "_defaultdocdir $PREFIX/share" singularity-*.tar.gz
```

{% include links.html %}
