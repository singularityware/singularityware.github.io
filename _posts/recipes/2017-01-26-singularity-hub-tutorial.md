---
title:  "Getting Started with Singularity and Singularity Hub"
category: recipes
permalink: singularity-tutorial
---

So you want to put your scientific analysis in a nice package and run it on a cluster? You’ve probably heard of the container technology called Docker?

<img src="/assets/img/tutorial/horsecarrot.png"><br>

...too bad you can’t use it on your research cluster, because it introduces huge security issues. You’ve probably also heard of <a href="https://www.vagrantup.com/docs/virtualbox/" target="_blank">virtual machines</a>, but most clusters won’t let you run those either. What options does this leave us? Oh wait, duh, you are reading this website. You already know the answer to this question.


{% include toc.html %}


## Getting Started

### Install Singularity
The easiest thing to do is to install Singularity on your local workstation:

```bash
    sudo apt-get update
    sudo apt-get -y install build-essential curl git sudo man vim autoconf libtool
    git clone https://github.com/singularityware/singularity.git
    cd singularity
    ./autogen.sh
    ./configure --prefix=/usr/local
    make
    sudo make install
```

If you are using a Mac, or just need a virtual machine, then you will want to follow the instructions <a href="http://singularity.lbl.gov/install-mac" target="_blank">here</a>. Basically, you need to install vagrant, virtual box, and then do this:

```bash
vagrant init ubuntu/trusty64
vagrant up

vagrant ssh -c /bin/sh <<EOF
    sudo apt-get update
    sudo apt-get -y install build-essential curl git sudo man vim autoconf libtool
    git clone https://github.com/singularityware/singularity.git
    cd singularity
    ./autogen.sh
    ./configure --prefix=/usr/local
    make
    sudo make install
EOF

vagrant ssh
```

Once you are in your Virtual Machine, or have Singularity up and running? Well, it's time to go NUTS of course!


### A little about Singularity Hub
<a href="https://singularity-hub.org" target="_blank">Singularity Hub</a> is an online registry for images. This means that you can connect a Github repo containing a build specification file to this website, and the image is going to build for you automatically, and be available programatically! We can talk more about how that happens later. If you want some quick details, you should check out the <a href="https://www.singularity-hub.org/faq" target="_blank">Usage Docs</a> on Singularity Hub.


## Make and run containers

### Run an image
For this little preview, we are going to be first running an image, directly from Singularity Hub. This image is called <a href="https://singularity-hub.org/collections/24/" target="_blank">vsoch/singularity-images</a> and it's associated with <a href="https://www.github.com/vsoch/singularity-images" target="_blank">the equivalent Github repository.</a>

```bash
singularity run shub://vsoch/singularity-images
```

{% include asciicast-custom.html rows='41' cols='100' source='shub-pull.json' title='Pulling and running a Singularity Hub image' author='vsochat@stanford.edu' %}

In the above, we use the Singularity Hub "unique resource identifier," or `uri`, `shub://` which tells the software to run an image from Singularity Hub.


### Create an image
Running is great, but what if we want to mess around on the command line, using an image we've created ourselves? We can do that by creating an image:

```bash
sudo singularity create analysis.img
sudo singularity import analysis.img docker://ubuntu:latest
singularity shell analysis.img
```

{% include asciicast-custom.html rows='41' cols='100' source='singularity-interact.json' title='Create and shell into a Singularity image' author='vsochat@stanford.edu' %}

In the above, we use the docker "unique resource identifier," or `uri`, `docker://` which tells the software to import a docker image.

If we wanted to shell into the image and make it writable, meaning that we can write files and save changes, we would do this:

```bash
sudo singularity shell --writable analysis.img
```

Note that we need sudo, and also note that you wouldn't be able to do this on a research cluster, because you don't have sudo.


### Create a reproducible image
The problem with create an image, and then maybe writing stuff to it with `--writable` is that your work isn't properly saved anywhere. You COULD ship and share the entire image, but that still doesn't help to say what was done to it, and this is problematic. To help with this, we encourage you to create a build specification file, a file called `Singularity`. There are a few important sections you should know about. First, let's look at a very simple file:

```bash
Bootstrap: docker
From: ubuntu:latest

%runscript

    echo "I can put here whatever I want to happen when the user runs my container!"
    exec echo "Hello Monsoir Meatball" "$@"

%post
 
   echo "Here we are installing software and other dependencies for the container!"
   apt-get update
   apt-get install -y git 

```

The important things to note. The header section says that we want to `Bootstrap`  a docker image, specifically `From` ubuntu:latest. No, you don't actually need Docker installed to run this, because the layers are pulled from their API endpoint.

{% include asciicast-custom.html rows='41' cols='100' source='singularity-bootstrap.json' title='Bootstrapping an image' author='vsochat@stanford.edu' %}

Once you have your bootstrap file, and you know how to use Github, you are really good to go. You can add the file to repository, connect it to Singularity Hub, and it will build automatically and be available via the `shub://` endpoint. That's it!
