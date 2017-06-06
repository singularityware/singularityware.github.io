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
Singularity is available on Debian (and Ubuntu) systems starting with Debian stretch and the Ubuntu 16.10 yakkety releases. The package is called `singularity-container`. You should first enable the NeuroDebian repository following instructions on the <a href="http://neuro.debian.net" target="_blank">NeuroDebian</a> site. This means using the dropdown menus to find the correct mirror for your operating system and location. For example, after selecting Ubuntu 16.04 and selecting a mirror in CA, I am instructed to add these lists:

```
sudo wget -O- http://neuro.debian.net/lists/xenial.us-ca.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9
```

and then update

```
sudo apt-get update
```

then singularity can be installed as follows:

```bash
sudo apt-get install -y singularity-container
```

During the above, if you have a previously installed configuration, you might be asked if you want to define a custom configuration/init, or just use the default provided by the package, eg:

```
Configuration file '/etc/singularity/init'
 ==> File on system created by you or by a script.
 ==> File also in package provided by package maintainer.
   What would you like to do about it ?  Your options are:
    Y or I  : install the package maintainer's version
    N or O  : keep your currently-installed version
      D     : show the differences between the versions
      Z     : start a shell to examine the situation
 The default action is to keep your current version.
*** init (Y/I/N/O/D/Z) [default=N] ? Y

Configuration file '/etc/singularity/singularity.conf'
 ==> File on system created by you or by a script.
 ==> File also in package provided by package maintainer.
   What would you like to do about it ?  Your options are:
    Y or I  : install the package maintainer's version
    N or O  : keep your currently-installed version
      D     : show the differences between the versions
      Z     : start a shell to examine the situation
 The default action is to keep your current version.
*** singularity.conf (Y/I/N/O/D/Z) [default=N] ? Y
```

And for a user, it's probably well suited to use the defaults. For a cluster admin, we recommend that you read the <a href="/admin-docs">admin docs</a> to get a better understanding of the configuration file options available to you. Remember that you can always tweak the files at `/etc/singularity/singularity.conf` and `etc/singularity/init` if you want to make changes.

After this install, you should confirm that `2.3-dist` is the version installed:

```bash
$ singularity --version
  2.3-dist
```

Note that if you don't add the NeuroDebian lists, the version provided will be old (e.g., 2.2.1). If you need a backport build of the recent release of Singularity on those or older releases of Debian and Ubuntu, you can <a href="http://neuro.debian.net/pkgs/singularity-container.html" target="_blank">see all the various builds and other information here</a>.


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
