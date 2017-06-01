---
title: Changing Existing Containers
sidebar: user_docs
permalink: docs-changing-containers
folder: docs
---


# Making Changes to an Existing Container
It is possible that you may need to make changes to a container after it has been bootstrapped. For that, let's repeat the Singularity mantra "*A user inside a Singularity container is the same user as outside the container*". If you want to make changes to your container, you must mount the container as `--writable` so you can change the contents. Note that standard Linux ownership and permission rules pertain to files within the container, so the `--writable` option does not guarantee you can do things like install new software. This might be a bit confusing if you copy a container from one computer to another. If your pids are different on the two computers you will lose the ability to edit files you previous had write access to. In these instances, it might be best to modify your container as root and so you would first need to become root outside of the container. Let's examine the following example:

## Installing Additional Software
We strongly recommend that you add additional software installation to your bootstrap, and re-create the image. However if you must, you can use `shell` and `exec` with `--writable` to issue additional commands.


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
---> Package which.x86_64 0:2.30-7.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

====================================================================================================
 Package               Arch                   Version                    Repository            Size
====================================================================================================
Installing:
 which                 x86_64                 2.30-7.el7                 base                  41 k

Transaction Summary
====================================================================================================
Install  1 Package

Total download size: 41 k
Installed size: 75 k
Is this ok [y/d/N]: y
Downloading packages:
which-2.30-7.el7.x86_64.rpm                                                  |  41 kB  00:00:00     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : which-2.30-7.el7.x86_64                                                          1/1 
  Verifying  : which-2.30-7.el7.x86_64                                                          1/1 

Installed:
  which.x86_64 0:2.30-7.el7                                                                         

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
u
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

## Resizing Images

You can expand your container to make it bigger after it's been created! You don't need sudo. You can specify a `--size` to expand by, or use the default of 768MiB:

```bash
 singularity expand ubuntu.img 
Initializing Singularity image subsystem
Opening image file: ubuntu.img
Expanding image by 768MiB
Binding image to loop
Checking file system
e2fsck 1.42.13 (17-May-2015)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/loop0: 11/49152 files (0.0% non-contiguous), 7387/196608 blocks
Resizing file system
resize2fs 1.42.13 (17-May-2015)
Resizing the filesystem on /dev/loop0 to 393216 (4k) blocks.
The filesystem on /dev/loop0 is now 393216 (4k) blocks long.
```
