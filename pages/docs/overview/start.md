---
title: Quick Start
sidebar: main_sidebar
permalink: quickstart
folder: docs
toc: false
---

## Installation Quick Start

```bash
$ git clone {{ site.repo }}.git
$ cd singularity
$ ./autogen.sh
$ ./configure --prefix=/usr/local
$ make
$ sudo make install
```

## Command Quick Start

### Import a Centos7 image from Docker Hub

The quickest way to get an image is to import it from Docker Hub.
Here's an example that creates an empty image, imports the current
CentOS 7 Docker image and proves that we got what we wanted.

```terminal
$ singularity create /tmp/Centos7.img
Creating a new image with a maximum size of 768MiB...
Executing image create helper
Formatting image with ext3 file system
Done.
$ singularity import /tmp/Centos7.img docker://centos:7
Cache folder set to /root/.singularity/docker
Extracting /root/.singularity/docker/sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4.tar.gz
Extracting /root/.singularity/docker/sha256:45a2e645736c4c66ef34acce2407ded21f7a9b231199d3b92d6c9776df264729.tar.gz
Bootstrap initialization
No bootstrap definition passed, updating container
Executing Prebootstrap module
Executing Postbootstrap module
Done.
$ singularity shell --contain /tmp/Centos7.img
Singularity: Invoking an interactive shell within container...

Singularity.Centos7.img> cat /etc/redhat-release
CentOS Linux release 7.3.1611 (Core)
Singularity.Centos7.img> exit
exit
$
```

This approach works with Docker's basic Alpine Linux
(`docker://alpine`), Debian (`docker://debian`), Ubuntu
(`docker://ubuntu`) and more.  You'll find the details on
the [Singularity and Docker][docs-docker] page.

### Shell into container
```bash
$ singularity shell --contain /tmp/Centos7.img 
Singularity.Centos7.img> ps aux
USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
gmk           1  0.0  0.3 115372  1768 pts/6    S    12:23   0:00 /bin/bash --norc --noprofile
gmk           2  0.0  0.3 151024  1800 pts/6    R+   12:23   0:00 ps aux
Singularity.Centos7.img> exit
````

### I am the same user inside the container as outside the container

```bash
$ id
uid=1000(gmk) gid=1000(gmk) groups=1000(gmk),10(wheel),2222(testgroup)
$ singularity exec /tmp/Centos7.img id
uid=1000(gmk) gid=1000(gmk) groups=1000(gmk),10(wheel),2222(testgroup)
````

### Files on the host can be reachable from within the container
```bash
$ echo "Hello World" > /home/gmk/testfile
$ singularity exec /tmp/Centos7.img cat /home/gmk/testfile 
Hello World
````

### Switching operating systems is as easy as pointing to a different image!
```bash
$ singularity exec /tmp/Centos7.img cat /etc/redhat-release 
CentOS Linux release 7.2.1511 (Core) 

$ singularity exec /tmp/SL6.img cat /etc/redhat-release 
Scientific Linux release 6.8 (Carbon)

$ singularity exec /tmp/Debian-stable.img cat /etc/debian_version
8.5

$ singularity exec /tmp/Ubuntu-trusty.img cat /etc/lsb-release 
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=14.04
DISTRIB_CODENAME=trusty
DISTRIB_DESCRIPTION="Ubuntu 14.04 LTS"
````

{% include links.html %}

[docs-docker]: /docs-docker
[readme-bootstrapping]: https://github.com/singularityware/singularity/blob/master/README.md#bootstrapping-new-images
