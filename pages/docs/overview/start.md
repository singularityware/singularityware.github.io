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

### Make a container

```bash
singularity create centos7.img
Initializing Singularity image subsystem
Opening image file: centos7.img
Creating 768MiB image
Binding image to loop
Creating file system within image
Image is done: centos7.img
```
Dump docker layers into it! Nope, you don't need sudo.

```bash
singularity import centos7.img docker://centos:7
Cache folder set to /home/vanessa/.singularity/docker
Importing: base Singularity environment
Importing: /home/vanessa/.singularity/docker/sha256:785fe1d06b2d42874d3e18fb0747ad8c9ed83d04e7641279a4d5ae353f27eff9.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:a90ac515821d5b70fe202c201485396ba95305348f9f7f52813e2873d3c72eee.tar.gz
```


### Shell into container

```bash
singularity shell centos7.img
Singularity: Invoking an interactive shell within container...

# I am the same user inside as outside!
Singularity centos7.img:~/Desktop> whoami
vanessa

Singularity centos7.img:~/Desktop> id
uid=1000(vanessa) gid=1000(vanessa) groups=1000(vanessa),4(adm),24,27,30(tape),46,113,128,999(input)
```

Want to keep the container's environment contained, meaning no sharing of host environment?

```
singularity shell --contain centos7.img
```

### Writing in the container
By default, containers run in read only. While we discourage making tweaks on the fly to containers (you should properly define all edits to the container in a boostrap specification file, shown later) you can add `--writable` to any command to write inside the container. Let's make a directory. This command must be done with sudo.

```bash
sudo singularity shell --writable centos7.img
Singularity centos7.img:/root> mkdir /data
Singularity centos7.img:/root> touch /data/noodles.txt
exit
```

### Executing Commands
Singularity `exec` will send a custom command for the container to run, anything that you like! Unlike docker exec, the container doesn't have to be actively running. So, to list the `/data` folder we just bound, we could do the following:

```bash
# Did the directory persist?
singularity exec centos7.img ls /data
noodles.txt
```


### Working with Files

Files on the host can be reachable from within the container

```bash
echo "Hello World" > /home/vanessa/Desktop/hello-kitty.txt
singularity exec centos7.img cat /home/vanessa/Desktop/hello-kitty.txt
Hello World
```

By default, most configurations will mount `/tmp` and the home directories by default. On a research cluster, you probably want to access locations with big datasets, and then write results too. For this, you will want to bind a folder to the container. Here, we are binding my Desktop to the data folder, and listing the contents to show it worked. We use the command `-B` or `--bind` to do this.

```bash
$ singularity exec --bind /home/vanessa/Desktop:/data centos7.img ls /data
centos7.img	     researchapps-matlab-sherlock-master.img
hello-kitty.txt      singularity-recipe-demo.mp4
party_dinosaur.gif
````

### Bootstrap Recipes
For a reproducible container, the recommended practice is to build by way of a bootstrap file. This also makes it easy to add files, environment variables, and install custom software, and still start from your bootstrap of source (e.g., Docker). Here is what a basic bootstrap file looks like for Singularity 2.3:

```bash
Bootstrap: docker
From: ubuntu:latest

%runscript

exec echo "The runscript is the containers default runtime command!"


%files
/home/vanessa/Desktop/hello-kitty.txt /data/hello-kitty.txt
/home/vanessa/Desktop/party_dinosaur.gif /tmp/the-party-dino.gif


%environment
VARIABLE MEATBALLVALUE

%labels
AUTHOR vsochat@stanford.edu

%post

apt-get update && apt-get install python3 git wget
mkdir /data
echo "The post section is where you can install, and configure your container."
```

The above bootstrap definition can then be run with singularity. Assuming that the definition was saved as `ubuntu.def` and an image file `ubuntu.img` exists, the following will build the container.

```bash
singularity bootstrap ubuntu.img ubuntu.def
```

{% include links.html %}
