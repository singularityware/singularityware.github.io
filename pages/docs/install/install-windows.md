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

We are maintaining a set of Vagrant Boxes via <a href="https://www.vagrantup.com" target="_blank">Vagrant Cloud</a>, one of <a href="https://www.hashicorp.com/#open-source-tools" target="_blank">Hashicorp</a> many tools that likely you've used and haven't known it. The current stable version of Singularity is available here:
 - [singularityware/singularity-2.3.1](https://app.vagrantup.com/singularityware/boxes/singularity-2.3.1/versions/2.3.1)
 
For other versions of Singularity see [our Vagrant Cloud repository](https://app.vagrantup.com/singularityware)

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
2.3.1-dist
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
