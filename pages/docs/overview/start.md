---
title: Quick Start
sidebar: main_sidebar
permalink: quickstart
folder: docs
toc: true
---

## Installation Quick Start
Note that this quickstart is intended for using Singularity on your personal workstation, where you have installed Singularity and have sudo. If you only have access to Singularity on a shared cluster resource, you will be able to go through all parts of this tutorial that do not require writing to an image. First, if you are on your local machine, let's install Singularity.

```bash
git clone {{ site.repo }}.git
cd singularity
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
```

Installing Singularity as a user, or without sudo, will not produce software that works properly. If you want Singularity on your shared cluster resource, you should ask an administrator to install it for you!

## Command Quick Start
This first section of commands can be done on a shared resource, or your personal computer. You don't need sudo to create, import, or shell into containers.

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

### Pull a container
Another easy way to obtain and use a container is to pull it directly. Here we can pull centos directly from Docker Hub, or pull an image from Singularity Hub.

```
singularity pull docker://centos:latest
Initializing Singularity image subsystem
Opening image file: centos-latest.img
Creating 336MiB image
Binding image to loop
Creating file system within image
Image is done: centos-latest.img
Docker image path: index.docker.io/library/centos:latest
Cache folder set to /home/vanessa/.singularity/docker
[1/1] |===================================| 100.0% 
Importing: base Singularity environment
Importing: /home/vanessa/.singularity/docker/sha256:d5e46245fe40c2d1ab72bfe328de28549b605b2587ab2fa8715f54e3e2de9c5d.tar.gz
Importing: /home/vanessa/.singularity/metadata/sha256:6b8bbe197a20c88d065c265cf6f6f8b4e3695f104d1f47f01a1298b3566f27fe.tar.gz
Done. Container is at: centos-latest.img
```

Did you notice anything interesting about the output to the terminal? If you noticed that the above output for "pull" is similar to the output of "create" and "import" combined, you nailed it on the head! In the context of docker, running the `pull` command is an easy shortcut to create and import docker layers to an image. Whereas Docker creates and imports layers into an image on pull, when we pull (or run, or shell) an image from Singularity Hub, the entire image is downloaded. This is one of the main differences between Docker and Singularity:

```
singularity run shub://vsoch/hello-world
Progress |===================================| 100.0% 
RaawwWWWWWRRRR!!
$ ls vsoch*
vsoch-hello-world-master.img
```

### Shell into container
Now let's go back to the `centos7.img` we created, and shell inside.

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

### Executing Commands
Singularity `exec` will send a custom command for the container to run, anything that you like! Unlike docker exec, the container doesn't have to be actively running. So, to list the root of the image (`/`), we could do the following:

```bash
singularity exec centos7.img ls /
anaconda-post.log  etc	 lib64	     mnt   root  singularity  tmp
bin		   home  lost+found  opt   run	 srv	      usr
dev		   lib	 media	     proc  sbin  sys	      var
```

### Working with Files

Files on the host can be reachable from within the container

```bash
echo "Hello World" > $HOME/hello-kitty.txt
singularity exec centos7.img cat $HOME/hello-kitty.txt
Hello World
```

By default, most configurations will mount `/tmp` and the home directories by default. On a research cluster, you probably want to access locations with big datasets, and then write results too. For this, you will want to bind a folder to the container. Here, we are binding my Desktop to `/opt` in the image, and listing the contents to show it worked. We use the command `-B` or `--bind` to do this.

```bash
$ singularity exec --bind /home/vanessa/Desktop:/opt centos7.img ls /opt
centos7.img	     researchapps-matlab-sherlock-master.img
hello-kitty.txt      singularity-recipe-demo.mp4
party_dinosaur.gif
````

## Commands needing root
The next set of actions, namely anything with `--writable` or bootstrap, do require you to use sudo, at least for most things. We can actually shell into a container, with `--writable`, and write to (some) locations for which we have permission to do so. Thus, this is possible to do, and will work depending on the permissions set in the container. For example, here let's shell in and try to write a root `/data` folder:

```bash
singularity shell --writable centos7.img
Singularity: Invoking an interactive shell within container...

Singularity centos7.img:~/Desktop> mkdir /data
mkdir: cannot create directory '/data': Permission denied
```

Oups. How about a folder in the present working directory?

```
Singularity centos7.img:~/Desktop> touch file.txt
```

This we are allowed to do, so it's not totally impossible to write some files in a container without sudo. However, for most things, you will need to use sudo with writable, discussed next. At this point, if you have been working on your shared resource, you will need to move to your personal laptop (and install Singularity if you haven't yet) before trying these out.


### Writing in the container
While we discourage making tweaks on the fly to containers (you should properly define all edits to the container in a boostrap specification file, shown later) you can add `--writable` to any command to write inside the container. Assuming we have our `centos7.img` on our local resource with sudo, let's try again to make that `/data` directory: 


```bash
sudo singularity shell --writable centos7.img
Singularity centos7.img:/root> mkdir /data
Singularity centos7.img:/root> touch /data/noodles.txt
exit
```

We made the data! And the noodles! But after we exit, is the file still there?

```bash
singularity exec centos7.img ls /data
noodles.txt
```

We (ideally) would have done this action with bootstrap, discussed next.

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
VARIABLE=MEATBALLVALUE
export VARIABLE

%labels
AUTHOR vsochat@stanford.edu

%post

apt-get update && apt-get install python3 git wget
mkdir /data
echo "The post section is where you can install, and configure your container."
```

The above bootstrap definition can then be run with singularity. Assuming that the definition was saved as `Singularity` and an image file `ubuntu.img` exists, the following will build the container.

```bash
sudo singularity bootstrap ubuntu.img Singularity
```

How might you go through this entire process without having singularity installed locally, or without leaving your cluster? You can build images using <a href="https://github.com/singularityhub/singularityhub.github.io/wiki" target="_blank">singularity hub.</a>

{% include links.html %}
