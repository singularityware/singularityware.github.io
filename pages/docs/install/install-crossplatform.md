---
title: Running Singularity with Vagrant (Windows/Linux/Mac etc)
sidebar: main_sidebar
permalink: install-crossplatform
folder: docs
---


This recipe demonstrates how to run Singularity on your Windows/Linux/Mac etc environment via Vagrant. Mac is not tried due to lack of Mac computer.The idea is to run Singularity on all platforms which Vagrant supports.Provisioning is chosen "ansible_local".Cross-platform method is applicable to Docker container as well. 

## Environment

First, install the following software:
- install [VirtualBox](https://www.virtualbox.org)
- install [Vagrant for Windows](https://www.vagrantup.com/downloads.html) or Vagrant for Linux,Mac etc.
- choose any linux flavor on vagrant cloud or custom vagrant box as base.
- Vagrantfile configuration

"config.vm.provision "ansible_local" do |ansible|"




Bring up vagrant vmguest


```
vagrant up
vagrant ssh
```
On Vagrant vmguest install ubuntu singularity package.

```bash
$ sudo apt-get singularity-container
```

Verify  singularity installation

```
vagrant@vagrant:~$ which singularity
/usr/bin/singularity
vagrant@vagrant:~$ singularity --version
2.4.5-dist
```

