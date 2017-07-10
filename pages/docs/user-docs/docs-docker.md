---
title: Singularity and Docker
sidebar: user_docs
permalink: docs-docker
folder: docs
---

{% include toc.html %}

Singularity is good friends with Docker. The reason is because the developers use and really like using Docker, and scientists have already put much resources into creating Docker images. Thus, one of our early goals was to support Docker. What can you do?

- You don't need Docker installed
- You can shell into a Singularity-ized Docker image
- You can run a Docker image instantly as a Singularity image
- You can import Docker images, including environment, guts, and labels, into your Singularity image (without sudo!)


# TLDR (Too Long Didn't Read)

You can shell, import, run, and exec.

```bash
singularity shell docker://ubuntu:latest
singularity run docker://ubuntu:latest
singularity exec docker://ubuntu:latest echo "Hello Dinosaur!"

singularity create ubuntu.img
singularity import ubuntu.img docker://ubuntu:latest

printf "Bootstrap:docker\nFrom:ubuntu:latest" > Singularity
singularity create ubuntu.img
sudo singularity bootstrap ubuntu.img Singularity
```

# Import a Docker image into a Singularity Image

The core of a Docker image is basically a compressed set of files, a set of `.tar.gz` that (if you look in your <a href="http://stackoverflow.com/questions/19234831/where-are-docker-images-stored-on-the-host-machine" target="_blank">Docker image folder</a> on your host machine, you will see. The Docker Registry, which you probably interact with via <a href="https://hub.docker.com" target="_blank">Docker Hub</a>, serves these layers. These are the layers that you see downloading when you interact with the docker daemon. We are going to use these same layers for Singularity!


## Quick Start: The Docker Registry
The Docker engine communicates with the Docker Hub via the <a href="https://docs.docker.com/engine/reference/api/docker_remote_api/" target="_blank">Docker Remote API</a>, and guess what, we can too! The easiest thing to do is create an image, and then pipe a Docker image directly into it from the Docker Registry. You don't need Docker installed on your machine, but you will need a working internet connection. Let's create an ubuntu operating system, from Docker:

```bash
singularity create ubuntu.img
Initializing Singularity image subsystem
Opening image file: ubuntu.img
Creating 768MiB image
Binding image to loop
Creating file system within image
Image is done: ubuntu.img
```

Note that the default size is 768MB, you can modify this by adding the `--size` or `-s` argument like:

```bash
singularity create --size 2000 ubuntu.img
```

If you aren't sure about the size? Try <a href="https://asciinema.org/a/103492?speed=3" target="_blank">building into a folder first</a>.

```bash
mkdir fatty
singularity import fatty docker://ubuntu:latest
du -sh fatty/
```

Next, let's import a Docker image into it! 

```bash
singularity import ubuntu.img docker://ubuntu
Cache folder set to /home/vanessa/.singularity/docker
Importing: base Singularity environment
Importing: /home/vanessa/.singularity/docker/sha256:6d9ef359eaaa311860550b478790123c4b22a2eaede8f8f46691b0b4433c08cf.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:9654c40e9079e3d5b271ec71f6d83f8ce80cfa6f09d9737fc6bfd4d2456fed3f.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:e8db7bf7c39fab6fec91b1b61e3914f21e60233c9823dd57c60bc360191aaf0d.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:f8b845f45a87dc7c095b15f3d9661e640ebc86f42cd8e8ab36674846472027f7.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:d54efb8db41d4ac23d29469940ec92da94c9a6c2d9e26ec060bebad1d1b0e48d.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:fe44851d529f465f9aa107b32351c8a0a722fc0619a2a7c22b058084fac068a4.tar.gz
singularity shell ubuntu.img 
Singularity: Invoking an interactive shell within container...

Singularity ubuntu.img>
```

## The Build Specification file, Singularity
Just like Docker has the Dockerfile, Singularity has a file called Singularity that (currently) applications like Singularity Hub know to sniff for. For reproducibility of your containers, our strong recommendation is that you build from these files. Any command that you issue to change a container with `--writable` is by default not recorded, and your container loses its reproducibility. So let's talk about how to make these files! First, let's look at the absolute minimum requirement:

```bash
Bootstrap: docker
From: tensorflow/tensorflow:latest
```

We would save this content to a file called `Singularity` and then issue the following commands to bootstrap the image from the file

```bash
singularity create --size 4000 tensorflow.img
sudo singularity bootstrap tensorflow.img Singularity
```

but just those two lines and doing bootstrap is silly, because we would achieve the same thing by doing:

```bash
singularity create --size 4000 tensorflow.img
singularity import tensorflow.img docker://tensorflow/tensorflow:latest
```

The power of bootstrap comes with the other stuff that you can do! This means running specific install commands, specifying your containers runscript (what it does when you execute it), adding files, labels, and customizing the environment. Here is a full Singularity file:


```bash
Bootstrap: docker
From: tensorflow/tensorflow:latest

%runscript
 
    exec /usr/bin/python "$@"

%post

    echo "Post install stuffs!"

%files

/home/vanessa/Desktop/analysis.py /tmp/analysis.py
relative_path.py /tmp/analysis2.py

%environment

TOPSECRET pancakes
HELLO WORLD

%labels

AUTHOR Vanessasaur
```

In the example above, I am overriding any Dockerfile `ENTRYPOINT` or `CMD` because I have defined a `%runscript`. If I want the Dockerfile `ENTRYPOINT` to take preference, I would remove the `%runscript` section. If I want to use `CMD` instead of `ENTRYPOINT`, I would again remove the runscript, and add IncludeCmd to the header:


```bash
Bootstrap: docker
From: tensorflow/tensorflow:latest
IncludeCmd: yes

%post

    echo "Post install stuffs!"
```

Did you know that you can commit this Singularity file to a Github repo and it will automatically build for you when you push to <a href="https://singularity-hub.org" target="_blank">Singularity Hub?</a>. This will ensure maximum reproducibility of your work.


## How does the runscript work?
Docker has two commands in the `Dockerfile` that have something to do with execution, `CMD` and `ENTRYPOINT`. The differences are subtle, but the best description I've found is the following:

>> A `CMD` is to provide defaults for an executing container.

and

>> An `ENTRYPOINT` helps you to configure a container that you can run as an executable.

Given the definition, the `ENTRYPOINT` is most appropriate for the Singularity `%runscript`, and so using the default bootstrap (whether from a `docker://` endpoint or a `Singularity` spec file) will set the `ENTRYPOINT` variable as the runscript. You can change this behavior by specifying `IncludeCmd: yes` in the Spec file (see below). If you provide any sort of `%runscript` in your Spec file, this overrides anything provided in Docker. In summary, the order of operations is as follows:

1. If a `%runscript` is specified in the `Singularity` spec file, this takes prevalence over all
2. If no `%runscript` is specified, or if the `import` command is used as in the example above, the `ENTRYPOINT` is used as runscript.
3. If no `%runscript` is specified, but the user has a `Singularity` spec with `IncludeCmd`, then the Docker `CMD` is used.
4. If no `%runscript` is specified, and there is no `CMD` or `ENTRYPOINT`, the image's default execution action is to run the bash shell.



## How do I specify my Docker image?

In the example above, you probably saw that we referened the docker image first with the uri `docker://` and that is important to tell Singularity that it will be pulling Docker layers. To ask for ubuntu, we asked for `docker://ubuntu`. This uri that we give to Singularity is going to be very important to choose the following Docker metadata items:

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


Have any more best practices? Please <a href="https://www.github.com/singularityware/singularityware.github.io/issues" target="_blank">let us know</a>!


## Troubleshooting
Why won't my image bootstrap work? If you can't find an answer on this site, please <a href="https://www.github.com/singularityware/singularity/issues" target="_blank">ping us an issue</a>.
If you've found an answer and you'd like to see it on the site for others to benefit from, then post to us <a href="https://www.github.com/singularityware/singularityware.github.io/issues" target="_blank">here</a>.

## Future
This entire process will hopefully change in two ways. First, we hope to collapse the image creation and bootstrapping, so you have the option to do them both in one full swing. Second, we hope to eventually figure out some kind of solution to import Docker containers without needing sudo.
