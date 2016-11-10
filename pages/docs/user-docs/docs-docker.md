---
title: Singularity and Docker
sidebar: user_docs
permalink: docs-docker
folder: docs
---


# Import a Docker image into a Singularity Image

The core of a Docker image is basically a compressed set of files, a set of `.tar.gz` that (if you look in your <a href="http://stackoverflow.com/questions/19234831/where-are-docker-images-stored-on-the-host-machine" target="_blank">Docker image folder</a> on your host machine, you will see. We are going to use this local repository for this first set of methods.


## Quick Start: Use the Docker Remote API

### Import Docker to Singularity
The Docker engine communicates with the Docker Hub via the <a href="https://docs.docker.com/engine/reference/api/docker_remote_api/" target="_blank">Docker Remote API</a>, and guess what, we can too! The easiest thing to do is create an image, and then pipe a Docker image directly into it from the Docker Registry. This first method does not require having Docker installed on your machine. Let's say that I want to bootstrap tensorflow from Docker. First I should create the tensorflow image:

```bash
sudo singularity create --size 4000 tensorflow.img
sudo singularity import tensorflow.img docker://tensorflow/tensorflow:latest
tensorflow/tensorflow:latest
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:b4c3589c6b3abaeb9d70269ad62f6fc522a00670ec7064b1ca42fa74f4b6f588
Downloading layer: sha256:d63463802d368b6cb92c18e92ea3e5a5e3fd4a18c283ec19c0d56eef224748b5
Downloading layer: sha256:709fc41158c625a33847d53e95ffe051fa80adbb9607ce8554f493c024cef300
Downloading layer: sha256:528276ea4b2d54c35820437985d7ad944a2fcafb4bda4d98fa60976c657470e1
Downloading layer: sha256:46d4527e85d3385ae7ac24f4dd442268b82d5e5e2de6c22a1eecf02ec8b79d42
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:da76ab5d6dffb48a4a7358699b84f0b7390640cc2c71a5421bfd9d73821ecb56
Downloading layer: sha256:70d51ddf7c958a8df097423a32ec9ab9c02aff5c2e18758e51cf636a115a856c
Downloading layer: sha256:ff4090f99abc02fe3e4604da28b87a8b770492158e20954b87e40e1b599b20f5
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Downloading layer: sha256:c8144262002cd241e607d7d3ecda450ce4ae8edf7dac8dbf46897d498ac667d8
Downloading layer: sha256:cee0974db2b868f0408f7e3eaba93c11fce3a38f612674477653b04c10369da0
Downloading layer: sha256:390957b2f4f0cd72b8577795cd8076cdc21d45c7823bbb5c895a494ae6038267
Downloading layer: sha256:064f9af025390d8da3dfab763fac261dd67f8807343613239d66304cda8f5d16
Adding Docker CMD as Singularity runscript...
Bootstrap initialization
No bootstrap definition passed, updating container
Executing Prebootstrap module
Executing Postbootstrap module
Done.
```

Now I can shell into it, and import tensorflow:

```bash
$ singularity shell tensorflow.img 
Singularity: Invoking an interactive shell within container...

Singularity.tensorflow.img> ls
Singularity.tensorflow.img> python
Python 2.7.6 (default, Jun 22 2015, 17:58:13) 
[GCC 4.8.2] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import tensorflow
>>> 
```

### Use a Spec File
Do a barrel role! Use a spec file! Many times, you want to bootstrap an image, and then either change the `%runscript` or add additional software or commands in the `%post` section. To achieve this, you can create a specification file. Currently, these are distributed with the naming format `[myfile].def`, however (soon) we will use a standard name, `Singularity` so all specification files can be automatically found. Here is what the spec file would look like for tensorflow:

```bash
Bootstrap: docker
From: tensorflow/tensorflow:latest
IncludeCmd: yes

%runscript
 
    exec /usr/bin/python "$@"

%post

    echo "Post install stuffs!"
```

The solution above would be ideal for saving the specification of an image to build at some runtime. 


### Run a Singularity Shell from a Docker image

Finally, we can achieve a "shell" experience, meaning shelling into Docker image imported into Singularity. We do this by storing the entire image in a temporary location, and then running the same function. You would do something like this:

```bash
sudo singularity shell docker://ubuntu:latest
```


## Detailed Start: Bootstrapping a Docker image
A common use case is to want to start with a Docker image, possibly add custom commands, and have a Singularity image when you finish. You can read a bit about <a href="/bootstrap-image" target="_blank">bootstrapping here</a> to get a sense of adding the custom commands and software. To specify "Docker" as the build source, you simply need this header:

```bash
Bootstrap: docker
From: ubuntu:latest
IncludeCmd: yes
```

- Boostrap: docker specifies that you want to import from Docker. This is required for Docker bootstrapping!
- IncludeCmd: will add the Dockerfile CMD as the runscript (`/singularity`) if one is found. If you define a different one later in the spec file, your specification will overwrite this one.
- From: works the same way <a href="https://docs.docker.com/engine/reference/builder/" target="_blank">as it does</a> for Docker. You can specify, maximally, a library/imagename:tag. For example, all of the following are valid:
  - library/ubuntu:latest
  - library/ubuntu
  - ubuntu:latest
  - ubuntu


In the case of omitting the tag (latest) it is assumed that you want the latest image. In the case of omitting the namespace (library) it is assumed that you want the common namespace, library.  If you have a reason to use the Docker Engine, we also have a method to do this. The benefit of this method would be that you could use an image built locally (in your local cache) that isn't on Docker Hub.


### Using Docker Engine

Here we will access Docker images via the `Docker` command line tool, meaning using the Docker engine. As is the Docker standard, the image is first looked for in your local cache, and if not found, is pulled from Docker Hub.


#### docker2singularity.sh: Dockerized

We wrapped this entire process into a Docker container itself, which means that you can use a Docker container in a Docker container to export a Docker container into Singularity! Nuts. Full instructions <a href="https://github.com/singularityware/docker2singularity" target="_blank"> are provided, however here is the gist:

```bash
 docker run \        
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v D:\host\path\where\to\ouptut\singularity\image:/output \
 --privileged -t --rm \
 singularityware/docker2singularity \            
 ubuntu:14.04
```

##### How does docker2singularity.sh work?

How did this come to be? It so happens that Docker has an "export" command to pipe this data out, and Singularity has an "import" command to take them in. Thus, you can do a simple import of a Docker image into a Singularity command by doing:

```bash
# Here is the name of the Singularity image I will create
image=ubuntu.img

# Now I am creating it
sudo singularity create $image

# Now I am exporting a running Docker container into it via a pipe (|)
docker export $container_id | singularity import $image
```

Where `$container_id` is the id of a running container obtained with `docker ps`. However, there are subtle details like the environment and permissions that this method will miss. It's also the case that most Docker images don't run (and stay running) easily unless you do something like:

```bash
docker run -d $image tail -f /dev/null
```

Early on we created a <a href="https://github.com/singularityware/docker2singularity/blob/master/docker2singularity.sh" target="_blank">docker2singularity.sh</a>, a script that you can download and run as follows:

```bash
wget https://raw.githubusercontent.com/singularityware/docker2singularity/master/docker2singularity.sh
chmod u+x docker2singularity.sh
./docker2singularity.sh ubuntu:latest
```

To produce a Singularity image of "ubuntu:latest" in the present working directory.


## Troubleshooting
Why won't my image bootstrap work? If you can't find an answer on this site, please <a href="https://www.github.com/singularityware/singularity/issues" target="_blank">ping us an issue</a>.
If you've found an answer and you'd like to see it on the site for others to benefit from, then post to us <a href="https://www.github.com/singularityware/singularityware.github.io/issues" target="_blank">here</a>.

## Future
This entire process will hopefully change in two ways. First, we hope to collapse the image creation and bootstrapping, so you have the option to do them both in one full swing. Second, we hope to eventually figure out some kind of solution to import Docker containers without needing sudo.
