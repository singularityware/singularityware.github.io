---
title: Running Singularity with Vagrant (Windows)
sidebar: main_sidebar
permalink: install-windows
folder: docs
---


This recipe demonstrates how to run Singularity on your Windows computer via Vagrant and Ubuntu. This recipe may take anywhere from 5-20 minutes to complete.

## Setup

First, install the following software:
- install [Git for Windows](https://git-for-windows.github.io/)
- install [VirtualBox for Windows](https://www.virtualbox.org/wiki/Downloads)
- install [Vagrant for Windows](https://www.vagrantup.com/downloads.html)
- install [Vagrant Manager for Windows](http://vagrantmanager.com/downloads/)

## Singularityware Vagrant Box

We are maintaining a set of Vagrant Boxes via <a href="https://atlas.hashicorp.com/" target="_blank">Atlas</a>, one of <a href="https://www.hashicorp.com/#open-source-tools" target="_blank">Hashicorp</a> many tools that likely you've used and haven't known it. We currently have boxes for the following versions of Singularity:

 - [singularityware/singularity-2.2.99](https://atlas.hashicorp.com/singularityware/boxes/singularity-2.2.99)
 - [singularityware/singularity-2.3](https://atlas.hashicorp.com/singularityware/boxes/singularity-2.3)
 - [singularityware/singularity-2.3.1](https://atlas.hashicorp.com/singularityware/boxes/singularity-2.3.1)

Run GitBash. The default home directory will be C:\Users\your_username

```bash
mkdir singularity-vm
cd singularity-vm
vagrant init singularityware/singularity-2.3.1
vagrant up
vagrant ssh
```

You are then ready to go with Singularity 2.3.1!

```
vagrant@vagrant:~$ which singularity
/usr/local/bin/singularity
vagrant@vagrant:~$ singularity --version
2.3-master.gadf5259
vagrant@vagrant:~$ singularity create test.img
Initializing Singularity image subsystem
Opening image file: test.img
Creating 768MiB image
Binding image to loop
Creating file system within image
Image is done: test.img
```

Note that when you do `vagrant up` you can also select the provider, if you use vagrant for multiple providers. For example:

```
vagrant up --provider virtualbox
```

although this isn't entirely necessary if you only have it configured for virtualbox.
