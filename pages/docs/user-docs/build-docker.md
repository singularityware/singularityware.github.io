---
title: Docker Builds
sidebar: user_docs
permalink: docs-docker
folder: docs
---

{% include toc.html %}

Singularity is good friends with Docker. The reason is because the developers use and really like using Docker, and scientists have already put much resources into creating Docker images. Thus, one of our early goals was to support Docker. What can you do?

- You don't need Docker installed
- You can shell into a Singularity-ized Docker image
- You can run a Docker image instantly as a Singularity image
- You can pull a Docker image (without sudo) 
- You can build images with bases from assembled Docker layers that include environment, guts, and labels


# TLDR (Too Long Didn't Read)

You can shell, pull, build, run, and exec.

```bash
singularity shell docker://ubuntu:latest
singularity pull docker://ubuntu:latest
singularity run docker://ubuntu:latest
singularity build ubuntu.img docker://ubuntu:latest
singularity exec docker://ubuntu:latest echo "Hello Dinosaur!"
```

# The Docker Build Base

The core of a Docker image is basically a compressed set of files, a set of `.tar.gz` that (if you look in your <a href="http://stackoverflow.com/questions/19234831/where-are-docker-images-stored-on-the-host-machine" target="_blank">Docker image folder</a> on your host machine, you will see. The Docker Registry, which you probably interact with via <a href="https://hub.docker.com" target="_blank">Docker Hub</a>, serves these layers. These are the layers that you see downloading when you interact with the docker daemon. We are going to use these same layers for Singularity!


## Quick Start: The Docker Registry
The Docker engine communicates with the Docker Hub via the <a href="https://docs.docker.com/engine/reference/api/docker_remote_api/" target="_blank">Docker Remote API</a>, and guess what, we can too! The easiest thing to do is create an image, and then pipe a Docker image directly into it from the Docker Registry. You don't need Docker installed on your machine, but you will need a working internet connection. Let's build an ubuntu operating system, from Docker:

```bash
singularity build ubuntu.simg docker://ubuntu
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /home/vanessa/.singularity/docker
Importing: base Singularity environment
Importing: /home/vanessa/.singularity/docker/sha256:9fb6c798fa41e509b58bccc5c29654c3ff4648b608f5daa67c1aab6a7d02c118.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:3b61febd4aefe982e0cb9c696d415137384d1a01052b50a85aae46439e15e49a.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:9d99b9777eb02b8943c0e72d7a7baec5c782f8fd976825c9d3fb48b3101aacc2.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:d010c8cf75d7eb5d2504d5ffa0d19696e8d745a457dd8d28ec6dd41d3763617e.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:7fac07fb303e0589b9c23e6f49d5dc1ff9d6f3c8c88cabe768b430bdb47f03a9.tar.gz
Importing: /home/vanessa/.singularity/metadata/sha256:22e289880847a9a2f32c62c237d2f7e3f4eae7259bf1d5c7ec7ffa19c1a483c8.tar.gz
Building Singularity image...
Cleaning up...
Singularity container built: ubuntu.simg
```
We didn't actually need to use build and provide an image path, if we just wanted the image as is, we could pull:

```
singularity pull docker://ubuntu
WARNING: pull for Docker Hub is not guaranteed to produce the
WARNING: same image on repeated pull. Use Singularity Registry
WARNING: (shub://) to pull exactly equivalent images.
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /home/vanessa/.singularity/docker
Importing: base Singularity environment
Importing: /home/vanessa/.singularity/docker/sha256:9fb6c798fa41e509b58bccc5c29654c3ff4648b608f5daa67c1aab6a7d02c118.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:3b61febd4aefe982e0cb9c696d415137384d1a01052b50a85aae46439e15e49a.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:9d99b9777eb02b8943c0e72d7a7baec5c782f8fd976825c9d3fb48b3101aacc2.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:d010c8cf75d7eb5d2504d5ffa0d19696e8d745a457dd8d28ec6dd41d3763617e.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:7fac07fb303e0589b9c23e6f49d5dc1ff9d6f3c8c88cabe768b430bdb47f03a9.tar.gz
Importing: /home/vanessa/.singularity/metadata/sha256:22e289880847a9a2f32c62c237d2f7e3f4eae7259bf1d5c7ec7ffa19c1a483c8.tar.gz
Building Singularity image...
Cleaning up...
Singularity container built: ./ubuntu.img
```

The warning message is pointing to the fact that a Docker image isn't actually a single image, it's a set of .tar.gz "layers" that are associated with the tag of the image. In the example above, we didn't provide a tag, and so it defaults to latest. This means that, if we run this command after another release of the image, it's likely not going to produce the same image. In contrast, pulling a specific image from a Singularity Registry returns one file that is identical to the one you pulled before. Docker is great to use as a base for a Singularity image that you are building, but keep this detail in mind if you expect a particular image base to be consistent over time.


## Build Recipe Details
If you haven't learned about build recipes yet, you should [do that first](/docs-recipes). The Docker build base will create a core operating system image based on assembling a set of Docker layers associated with an image hosted at a particular Docker Registry. By default it will use the primary Docker Library, but that can be overridden. When using the `docker` module, several other keywords may also be defined:

 - **From**: This keyword defines the string of the registry name used for this image in the format [name]:[version]. Several examples are: `ubuntu:latest`, `centos:6`, `alpine:latest`, or `debian` (if the version tag is omitted, `:latest` is automatically used).
 - **IncludeCmd**: This keyword tells Singularity to utilize the Docker defined `Cmd` as the `%runscript` (defined below), if the `Cmd` is defined.
 - **Registry**: If the registry you wish to download the image from is not from the main Docker Library, you can define it here.
 - **Token**: Sometimes the Docker API (depending on version?) requires an authorization token which is generated on the fly. Toggle this with a `yes` or `no` here.


## What gets used as the runscript?
The important detail with using Docker as a base bootstrap is with regard to answering this question! Docker has two commands in the `Dockerfile` that have something to do with execution, `CMD` and `ENTRYPOINT`. The differences are subtle, but the best description I've found is the following:

>> A `CMD` is to provide defaults for an executing container.

and

>> An `ENTRYPOINT` helps you to configure a container that you can run as an executable.

And Singularity of course has the `%runscript`. Who wins? We use an "order of operations" simple strategy to determine this, with first preference going to some `%runscript` you define, then the `ENTRYPOINT` that is defined in the Dockerfile, and then the `CMD`. Specifically:

1. If a `%runscript` is specified in the `Singularity` spec file, this takes prevalence over all
2. If no `%runscript` is specified, the `ENTRYPOINT` is used as runscript.
3. If no `%runscript` is specified, but the user has a `Singularity` spec with `IncludeCmd`, then the Docker `CMD` is used.
4. If no `%runscript` is specified, and there is no `CMD` or `ENTRYPOINT`, the image's default execution action is to run the bash shell.

Given an `ENTRYPOINT` exists, you would modify your file as follows to default to `CMD`:


```bash
Bootstrap: docker
From: tensorflow/tensorflow:latest
IncludeCmd: yes
```


## How do I specify my Docker image?

In the example above, you probably saw that we referenced the docker image first with the uri `docker://` and that is important to tell Singularity that it will be pulling Docker layers. To ask for ubuntu, we asked for `docker://ubuntu`. This uri that we give to Singularity is going to be very important to choose the following Docker metadata items:

- registry   (e.g., "index.docker.io")
- namespace  (e.g., "library")
- repository (e.g., "ubuntu")
- tag (e.g., "latest") OR version (e.g., "@sha256:1234...)

When we put those things together, it looks like this:

```bash
docker://<registry>/<namespace>/<repo_name>:<repo_tag>
```

By default, the minimum requirement is that you specify a repository name (eg, ubuntu) and it will default to the following:

```bash
docker://index.docker.io/library/ubuntu:latest
```

If you provide a version instead of a tag, that will be used instead:

```bash
docker://index.docker.io/library/ubuntu@sha256:1235...
```

You can have one or the other, both are considered a "digest" in Docker speak.

If you want to change any of those fields, then just specify what you want in the URI.


## Custom Authentication
For both import and bootstrap using a build spec file, by default we use the Docker Registry `index.docker.io`. Singularity first tries the call without a token, and then asks for one with pull permissions if the request is defined. However, it may be the case that you want to provide a custom token for a private registry. You have two options. You can either provide a `Username` and `Password` in the build specification file (if stored locally and there is no need to share), or (in the case of doing an import or needing to secure the credentials) you can export these variables to environmental variables. We provide instructions for each of these cases:


### Authentication in the Singularity Build File
You can simply specify your additional authentication parameters in the header with the labels `Username` and `Password`:

```bash
Username: vanessa
Password: [password]
```

Again, this can be in addition to specification of a custom registry with the `Registry` parameter.

### Authentication in the Environment
You can export your username, and password for Singularity as follows:

```bash
export SINGULARITY_DOCKER_USERNAME=vanessasaur
export SINGULARITY_DOCKER_PASSWORD=rawwwwwr
```

### Testing Authentication
If you are having trouble, you can test your token by obtaining it on the command line and putting it into an environmental variable, `CREDENTIAL`:


```bash
CREDENTIAL=$(echo -n vanessa:[password] | base64)
TOKEN=$(http 'https://auth.docker.io/token?service=registry.docker.io&scope=repository:vanessa/code-samples:pull' Authorization:"Basic $CREDENTIAL" | jq -r '.token')
```

This should place the token in the environmental variable `TOKEN`. To test that your token is valid, you can do the following

```bash
http https://index.docker.io/v2/vanessa/code-samples/tags/list Authorization:"Bearer $TOKEN"
```

The above call should return the tags list as expected. And of course you should change the repo name to be one that actually exists that you have credentials for.

## Best Practices
While most docker images can import and run without a hitch, there are some special cases for which things can go wrong. Here is a general list of suggested practices, and if you discover a new one in your building ventures please <a href="https://www.github.com/singularityware/singularityware.github.io/issues" target="_blank">let us know</a>.

### 1. Installation to Root
When using Docker, you typically run as root, meaning that root's home at `/root` is where things will install given a specification of home. This is fine when you stay in Docker, or if the content at `/root` doesn't need any kind of write access, but generally can lead to a lot of bugs because it is, after all, root's home. This leads us to best practice #1.

 >> Don't install anything to root's home, `/root`.

### 2. Library Configurations
The command [ldconfig](https://codeyarns.com/2014/01/14/how-to-add-library-directory-to-ldconfig-cache/) is used to update the shared library cache. If you have software that requires symbolic linking of libraries and you do the installation without updating the cache, then the Singularity image (in read only) will likely give you an error that the library is not found. If you look in the image, the library will exist but the symbolic link will not. This leads us to best practice #2:

 >> Update the library cache at the end of your Dockerfile with a call to ldconfig.

### 3. Don't install to $HOME or $TMP
We can assume that the most common Singularity use case has the $USER home being automatically mounted to `$HOME`, and `$TMP` also mounted. Thus, given the potential for some kind of conflict or missing files, for best practice #3 we suggest the following:

  >> Don't put container valuables in `$TMP` or `$HOME`


Have any more best practices? Please <a href="https://www.github.com/singularityware/singularityware.github.io/issues" target="_blank">let us know</a>!


## Troubleshooting
Why won't my image build work? If you can't find an answer on this site, please <a href="https://www.github.com/singularityware/singularity/issues" target="_blank">ping us an issue</a>. 
If you've found an answer and you'd like to see it on the site for others to benefit from, then post to us <a href="https://www.github.com/singularityware/singularityware.github.io/issues" target="_blank">here</a>.
