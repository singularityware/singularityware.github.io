---
title: Changing Existing Containers
sidebar: user_docs
permalink: docs-changing-containers
folder: docs
---

## Making Changes to an Existing Container
It is possible that you may need to make changes to a container after it has been bootstrapped. For that, let's repeat the Singularity mantra "*A user inside a Singularity container is the same user as outside the container*". This means if you want to make changes to your container, you must be root inside your container, which means you must first become root outside your container. Additionally you will need to tell Singularity that you wish to mount the container as `--writable` so you can change the contents. Let's examine the following example:

```bash
$ singularity shell /tmp/Centos7-ompi.img 
Singularity: Invoking an interactive shell within container...

Singularity.Centos7-ompi.img> which ls
sh: which: command not found
```

Let's use this opportunity to install an additional package into this container:

```bash
$ sudo singularity exec --writable /tmp/Centos7-ompi.img yum install which
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.hostduplex.com
 * extras: mirrors.centos.webair.com
 * updates: linux.mirrors.es.net
Resolving Dependencies
--> Running transaction check
---> Package which.x86_64 0:2.20-7.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

====================================================================================================
 Package               Arch                   Version                    Repository            Size
====================================================================================================
Installing:
 which                 x86_64                 2.20-7.el7                 base                  41 k

Transaction Summary
====================================================================================================
Install  1 Package

Total download size: 41 k
Installed size: 75 k
Is this ok [y/d/N]: y
Downloading packages:
which-2.20-7.el7.x86_64.rpm                                                  |  41 kB  00:00:00     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : which-2.20-7.el7.x86_64                                                          1/1 
  Verifying  : which-2.20-7.el7.x86_64                                                          1/1 

Installed:
  which.x86_64 0:2.20-7.el7                                                                         

Complete!
```

We could have also used the `shell` container interface command to do this.

```bash
$ sudo singularity shell --writable /tmp/Centos7-ompi.img
Singularity: Invoking an interactive shell within container...

Singularity.Centos7-ompi.img> yum install vi
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.hostduplex.com
 * extras: mirrors.centos.webair.com
 * updates: linux.mirrors.es.net
Resolving Dependencies
--> Running transaction check
---> Package vim-minimal.x86_64 2:7.4.160-1.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

====================================================================================================
 Package                  Arch                Version                       Repository         Size
====================================================================================================
Installing:
 vim-minimal              x86_64              2:7.4.160-1.el7               base              436 k

Transaction Summary
====================================================================================================
Install  1 Package

Total download size: 436 k
Installed size: 896 k
Is this ok [y/d/N]: y
Downloading packages:
vim-minimal-7.4.160-1.el7.x86_64.rpm                                         | 436 kB  00:00:00     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : 2:vim-minimal-7.4.160-1.el7.x86_64                                               1/1 
  Verifying  : 2:vim-minimal-7.4.160-1.el7.x86_64                                               1/1 

Installed:
  vim-minimal.x86_64 2:7.4.160-1.el7                                                                

Complete!
Singularity.Centos7-ompi.img> exit
```

