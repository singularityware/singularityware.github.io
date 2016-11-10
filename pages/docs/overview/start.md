---
title: Quick Start
sidebar: main_sidebar
permalink: quickstart
folder: docs
toc: false
---

## Installation Quick Start

```bash
git clone {{ site.repo }}.git
cd singularity
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
```

## Command Quick Start

### Shell into container
```bash
singularity shell --contain /tmp/Centos7.img 
Singularity.Centos7.img> ps aux
USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
gmk           1  0.0  0.3 115372  1768 pts/6    S    12:23   0:00 /bin/bash --norc --noprofile
gmk           2  0.0  0.3 151024  1800 pts/6    R+   12:23   0:00 ps aux
Singularity.Centos7.img> exit
````

### I am the same user inside the container as outside the container

```bash
id
uid=1000(gmk) gid=1000(gmk) groups=1000(gmk),10(wheel),2222(testgroup)
singularity exec /tmp/Centos7.img id
uid=1000(gmk) gid=1000(gmk) groups=1000(gmk),10(wheel),2222(testgroup)
````

### Files on the host can be reachable from within the container
```bash
echo "Hello World" > /home/gmk/testfile
singularity exec /tmp/Centos7.img cat /home/gmk/testfile 
Hello World
````

### Switching operating systems is as easy as pointing to a different image!
```bash
singularity exec /tmp/Centos7.img cat /etc/redhat-release 
CentOS Linux release 7.2.1511 (Core) 

singularity exec /tmp/SL6.img cat /etc/redhat-release 
Scientific Linux release 6.8 (Carbon)

singularity exec /tmp/Debian-stable.img cat /etc/debian_version
8.5

singularity exec /tmp/Ubuntu-trusty.img cat /etc/lsb-release 
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=14.04
DISTRIB_CODENAME=trusty
DISTRIB_DESCRIPTION="Ubuntu 14.04 LTS"
````

{% include links.html %}
