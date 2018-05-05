---
title: Installation
sidebar: user_docs
permalink: docs-installation
folder: docs
toc: false
---

This document will guide you through the process of installing Singularity from source with the version and location of your choice.  

{% include toc.html %}

## Before you begin
If you have an earlier version of Singularity installed, you should [remove it](#remove-an-old-version) before executing the installation commands.

These instructions will build Singularity from source on your system.  So you will need to have some development tools installed.  If you run into missing dependencies, try installing them like so:

**Ubuntu**

```
$ sudo apt-get update && \
    sudo apt-get install \
    python \
    dh-autoreconf \
    build-essential \
    libarchive-dev
```

**Centos**

```
$ sudo yum update && \
    sudo yum groupinstall 'Development Tools' && \
    sudo yum install libarchive-devel
```
{% include asciicast.html source='install_dependencies.js' uid='how-to-install-dependencies' title='How to install dependencies' author='davidgodlove@gmail.com'%}

## Install the master branch
The following commands will install the latest version of the [GitHub repo](https://github.com/singularityware/singularity)  master branch to `/usr/local`. 

```
$ git clone https://github.com/singularityware/singularity.git
$ cd singularity
$ ./autogen.sh
$ ./configure --prefix=/usr/local --sysconfdir=/etc
$ make
$ sudo make install
```

Note that the installation prefix is `/usr/local` but the configuration directory is `/etc`. This ensures that the configuration file `singularity.conf` is placed in the standard location. 

If you omit the `--sysconfdir` option , the configuration file will be installed in `/usr/local/etc`.  If you omit the `--prefix` option, Singularity will be installed in the `/usr/local` directory hierarchy by default.  And if you specify a custom directory with the `--prefix` option, all of Singularity's binaries and the configuration file will be installed within that directory.  This last option can be useful if you want to install multiple versions of Singularity, install Singularity on a shared system, or if you want to remove Singularity easily after installing it.  

{% include asciicast.html source='install_master.js' uid='how-to-install-the-master-branch' title='How to install the master branch' author='davidgodlove@gmail.com'%}


## Install a specific release
The following commands will install a specific release from [GitHub releases page](https://github.com/singularityware/singularity/releases) to `/usr/local`.  
 
```
$ VER=2.2.1
$ VER={{ site.singularity_version }}
$ wget https://github.com/singularityware/singularity/releases/download/$VER/singularity-$VER.tar.gz
$ tar xvf singularity-$VER.tar.gz
$ cd singularity-$VER
$ ./configure --prefix=/usr/local --sysconfdir=/etc
$ make
$ sudo make install
```


## Install the development branch
If you want to test a development branch the routine above should be tweaked slightly:


```
$ git clone https://github.com/singularityware/singularity.git
$ cd singularity
$ git fetch
$ git checkout development
$ ./autogen.sh
$ ./configure --prefix=/usr/local --sysconfdir=/etc
$ make
$ sudo make install
```


## Remove an old version
Let's say that we installed Singularity to `/usr/local`. To remove it completely, you need to hit all of the following:

```bash
$ sudo rm -rf /usr/local/libexec/singularity
$ sudo rm -rf /usr/local/etc/singularity
$ sudo rm -rf /usr/local/include/singularity
$ sudo rm -rf /usr/local/lib/singularity
$ sudo rm -rf /usr/local/var/lib/singularity/
$ sudo rm /usr/local/bin/singularity
$ sudo rm /usr/local/bin/run-singularity
$ sudo rm /usr/local/etc/bash_completion.d/singularity 
$ sudo rm /usr/local/man/man1/singularity.1
```

If you modified the system configuration directory, remove the `singularity.conf` file there as well.

If you installed Singularity in a custom directory, you need only remove that directory to uninstall Singularity.  For instance if you installed singularity with the `--prefix=/some/temp/dir` option argument pair, you can remove Singularity like so:

```bash
$ sudo rm -rf /some/temp/dir
```

What should you do next? You can check out the <a href="/quickstart">quickstart</a> guide, or learn how to interact with your container via the [shell](/docs-shell), [exec](/docs-exec), or [run](/docs-run) commands.  Or click **next** below to continue reading. 
