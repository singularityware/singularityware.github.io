---
title: Singularity and Docker
sidebar: docs_sidebar
permalink: docker
folder: docs
---

Singularity is good friends with Docker. You can do all of the following:

- Import a Docker image into a Singularity image
- Use Docker to generate a development environment with Singularity and/or Docker
- Bootstrap a Docker image as the base for a Singularity image

# Import a Docker image into a Singularity Image

The core of a Docker image is basically a compressed set of files, a set of `.tar.gz` that (if you look in your <a href="http://stackoverflow.com/questions/19234831/where-are-docker-images-stored-on-the-host-machine" target="_blank">Docker image folder</a> on your host machine, you will see. We are going to use this local repository for this first set of methods.

## Use your local Docker cache

For the methods below, you will access Docker images via the `Docker` command line tool, meaning using the Docker engine, and either images pulled from Docker Hub or your local cache.

### docker2singularity.sh: running on your machine

It so happens that Docker has an "export" command to pipe this data out, and Singularity has an "import" command to take them in. Thus, you can do a simple import of a Docker image into a Singularity command by doing:

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

and so early on we created a <a href="https://github.com/singularityware/docker2singularity/blob/master/docker2singularity.sh" target="_blank">docker2singularity.sh</a>, a script that you can download and run as follows:

```bash
wget https://raw.githubusercontent.com/singularityware/docker2singularity/master/docker2singularity.sh
chmod u+x docker2singularity.sh
./docker2singularity.sh ubuntu:latest
```

To produce a Singularity image of "ubuntu:latest" in the present working directory.

### docker2singularity.sh: Dockerized

A clever colleague wrapped this entire process into a Docker container itself, which means that you can use a Docker container in a Docker container to export a Docker container into Singularity! Nuts. Full instructions <a href="https://github.com/singularityware/docker2singularity" target="_blank"> are provided, however here is the gist:

```bash
 docker run \        
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v D:\host\path\where\to\ouptut\singularity\image:/output \
 --privileged -t --rm \
 singularityware/docker2singularity \            
 ubuntu:14.04
```

## Use the Docker Remote API

The Docker engine communicates with the Docker Hub via the <a href="https://docs.docker.com/engine/reference/api/docker_remote_api/" target="_blank">Docker Remote API</a>, and guess what, we can too! This will hopefully eventually mean some kind of solution to import Docker containers without needing sudo, however this is still under development. For now, it means importing without needing the Docker engine.

### Bootstrap a Docker image to generate a Singularity one

A common use case is to want to start with a Docker image, possibly add custom commands, and have a Singularity image when you finish. You can read a bit about <a href="/docs-bootstrap" target="_blank">bootstrapping here</a> to get a sense of adding the custom commands and software. To specify "Docker" as the build source, you simply need this header:

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

In the case of omitting the tag (latest) it is assumed that you want the latest image. In the case of omitting the namespace (library) it is assumed that you want the common namespace, library.

### Import Docker to Singularity without specfile
A quicker implementation of the above (meaning without a specfile) is to specify the remote Docker image with the import command. For example, to import the Docker image "ubuntu:latest" into my Singularity image "/tmp/Debian.img" I would do:

```bash
sudo singularity import /tmp/Debian.img docker://ubuntu:latest
```

# Run a Singularity Shell from a Docker image

Finally, we can use the same Docker Remote API (it comes down to the same Python function) to achieve a "shell" experience, meaning shelling into Docker image imported into Singularity. We do this by storing the entire image in a temporary location, and then running the same function. You would do something like this:

```bash
sudo singularity shell docker://ubuntu:latest
```
