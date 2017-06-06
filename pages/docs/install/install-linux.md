---
title: Install on Linux
sidebar: main_sidebar
permalink: install-linux
folder: docs
toc: true
---

## Installation from Source

You can try the following two options:

### Option 1: Download latest stable release
You can always download the latest tarball release from <a href="{{ site.repo }}/releases" target="_blank">Github</a>

For example, here is how to download version `2.3` and install:

```bash
VERSION=2.3
wget https://github.com/singularityware/singularity/releases/download/$VERSION/singularity-$VERSION.tar.gz
tar xvf singularity-$VERSION.tar.gz
cd singularity-$VERSION
./configure --prefix=/usr/local
make
sudo make install
```

### Option 2: Download the latest development code
To download the most recent development code, you should use Git and do the following:

```bash
git clone {{ site.repo }}.git
cd singularity
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
```

note: The 'make install' is required to be run as root to get a properly installed Singularity implementation. If you do not run it as root, you will only be able to launch Singularity as root due to permission limitations.

{% include asciicast.html source='install-singularity.js' title='Install Singularity' author='vsochat@stanford.edu' %}


### Updating

To update your Singularity version, you might want to first delete the executables for the old version:

```bash
sudo rm -rf /usr/local/libexec/singularity
```
And then install using one of the methods above.



## Debian/Ubuntu Flavor Install
Singularity is available on Debian (and Ubuntu) systems starting with Debian stretch and the Ubuntu 16.10 yakkety releases. The package is called `singularity-container` and can be installed as follows:

```bash
sudo apt-get update
sudo apt-get install -y singularity-container
```

The current version provided is 2.2.1, and the package maintainers will release the updated 2.3 soon. If you need a backport build of the recent release of Singularity on those or older releases of Debian and Ubuntu, please enable the NeuroDebian repository following instructions on the <a href="http://neuro.debian.net" target="_blank">NeuroDebian</a> site.


## Build an RPM from source
Like the above, you can build an RPM of Singularity so it can be more easily managed, upgraded and removed. From the base Singularity source directory do the following:

```bash
./autogen.sh
./configure
make dist
rpmbuild -ta singularity-*.tar.gz
sudo yum install ~/rpmbuild/RPMS/*/singularity-[0-9]*.rpm
```

Note: if you want to have the RPM install the files to an alternative location, you should define the environment variable 'PREFIX' to suit your needs, and use the following command to build:

```bash
PREFIX=/opt/singularity
rpmbuild -ta --define="_prefix $PREFIX" --define "_sysconfdir $PREFIX/etc" --define "_defaultdocdir $PREFIX/share" singularity-*.tar.gz
```

When using `autogen.sh` If you get an error that you have packages missing, for example on Ubuntu 16.04:

```bash
 ./autogen.sh
+libtoolize -c
./autogen.sh: 13: ./autogen.sh: libtoolize: not found
+aclocal
./autogen.sh: 14: ./autogen.sh: aclocal: not found
+autoheader
./autogen.sh: 15: ./autogen.sh: autoheader: not found
+autoconf
./autogen.sh: 16: ./autogen.sh: autoconf: not found
+automake -ca -Wno-portability
./autogen.sh: 17: ./autogen.sh: automake: not found
```

then you need to install dependencies:


```bash
sudo apt-get install -y build-essential libtool autotools-dev automake autoconf
```

## Build a DEB from source

To build a deb package for Debian/Ubuntu/LinuxMint invoke the following commands:

```bash
$ fakeroot dpkg-buildpackage -b -us -uc # sudo will ask for a password to run the tests
$ sudo dpkg -i ../singularity-container_2.3_amd64.deb
```
 
Note that the tests will fail if singularity is not already installed on your system. This is the case when you run this procedure for the first time.
In that case run the following sequence:

```bash
$ echo "echo SKIPPING TESTS THEYRE BROKEN" > ./test.sh
$ fakeroot dpkg-buildpackage -nc -b -us -uc # this will continue the previous build without an initial 'make clean'
```

{% include links.html %}
