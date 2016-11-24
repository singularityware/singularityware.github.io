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
Cache folder set to /home/vanessa/.singularity/docker
Extracting /home/vanessa/.singularity/docker/sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:182b64c1f020de1cb4b2783b3a13fbeb07ec4087bc911352d0f5ef40c8eec8cf.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:bfc1d5e3de1cf70353afb2b81fbbeab16bad961352b86f60901bc1da1396f2b4.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:d819f1ec59a06c001b37e66dd1639c591e606029ea7584fac704ff741cda249b.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:f5d83de9c6786bff4160679ed4bde332970367225ede609944bbe686edb1c25b.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:c1f8f4c880d49d70a8280860e3bc5ee559a95d4e1dc44f9128b638eb2240324c.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:9528c5352798ec3a134be13b66bc4dc71e7cdd029e268ae3cdfeb0719a4c8b8b.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:c145c1f339f57690f80bd64e86caa3b00e0635a6a383bc8be7726a3baf22a0d2.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:ebb77ce6e1c6769c1849194c1319dc6978e19575c76fd1fa942a623b6f2996a4.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:51900bc9e720db035e12f6c425dd9c06928a9d1eb565c86572b3aab93d24cfca.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:f8419ea7c1b5d667cf26c2c5ec0bfb3502872e5afc6aa85caf2b8c7650bdc8d9.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:3eed5ff20a90a40b0cb7909e79128740f1320d29bec2ae9e025a1d375555db15.tar.gz
Extracting /home/vanessa/.singularity/docker/sha256:6c953ac5d795ea26fd59dc5bdf4d335625c69f8bcfbdd8307d6009c2e61779c9.tar.gz
Adding Docker CMD as Singularity runscript...
/run_jupyter.sh
Bootstrap initialization
No bootstrap definition passed, updating container
Executing Prebootstrap module
Executing Postbootstrap module
Done.
```

Note that if you want (much) more detailed output for debugging to the console, you need to enable `--verbose` mode:

```bash
sudo singularity --verbose import tensorflow.img docker://tensorflow/tensorflow:latest
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

### How does the runscript work?
Docker has two commands in the `DOCKERFILE` that have something to do with execution, `CMD` and `ENTRYPOINT`. The differences are subtle, but the best description I've found is the following:

>> A `CMD` is to provide defaults for an executing container.

and

>> An `ENTRYPOINT` helps you to configure a container that you can run as an executable.

Given the definition, the `ENTRYPOINT` is most appropriate for the Singularity `%runscript`, and so using the default bootstrap (whether from a `docker://` endpoint or a `Singularity` spec file) will set the `ENTRYPOINT` variable as the runscript. You can change this behavior by specifying `IncludeCmd: yes` in the Spec file (see below). If you provide any sort of `%runscript` in your Spec file, this overrides anything provided in Docker. In summary, the order of operations is as follows:

1. If a `%runscript` is specified in the `Singularity` spec file, this takes prevalence over all
2. If no `%runscript` is specified, or if the `import` command is used as in the example above, the `ENTRYPOINT` is used as runscript.
3. If no `%runscript` is specified, but the user has a `Singularity` spec with `IncludeCmd`, then the Docker `CMD` is used.


### Use a Spec File
Do a barrel role! Use a spec file! Many times, you want to bootstrap an image, and then either change the `%runscript` or add additional software or commands in the `%post` section. To achieve this, you can create a specification file. Currently, these are distributed with the naming format `[myfile].def`, however (soon) we will use a standard name, `Singularity` so all specification files can be automatically found. Here is what the spec file would look like for tensorflow:


```bash
Bootstrap: docker
From: tensorflow/tensorflow:latest

%runscript
 
    exec /usr/bin/python "$@"

%post

    echo "Post install stuffs!"
```

In the example above, I am overriding any Dockerfile `ENTRYPOINT` because I have defined a `%runscript`. If I want the Dockerfile `ENTRYPOINT` to take preference, I would remove the `%runscript` section:

```bash
Bootstrap: docker
From: tensorflow/tensorflow:latest

%post

    echo "Post install stuffs!"
```

Note that the spec file above would be (almost) equivalent to the command:

```bash
sudo singularity import tensorflow.img docker://tensorflow/tensorflow:latest
```

minus the useless echo at the end. If I want the `CMD` to take preference, I would add `IncludeCmd`:

```bash
Bootstrap: docker
From: tensorflow/tensorflow:latest
IncludeCmd: yes

%post

    echo "Post install stuffs!"
```

The solutions above would be ideal for saving a custom specification of an image to build at some runtime. 

### Custom Authentication
For both import and bootstrap using a build spec file, by default we use the Docker Registry `index.docker.io`. Singularity first tries the call without a token, and then asks for one with pull permissions if the request is defined. However, it may be the case that you want to provide a custom token for a private registry. You have two options. You can either provide a `Username` and `Password` in the build specification file (if stored locally and there is no need to share), or (in the case of doing an import or needing to secure the credentials) you can export these variables to environmental variables. We provide instructions for each of these cases:


#### Authentication in the Spec File
You can simply specify your additional authentication parameters in the header with the labels `Username` and `Password`:

```bash
Username: vanessa
Password: [password]
```

Again, this can be in addition to specification of a custom registry with the `Registry` parameter.

#### Authentication in the Environment
You can export your registry, username, and password for Singularity as follows:

```bash
export SINGULARITY_DOCKER_REGISTRY='--registry myrepo'
export SINGULARITY_DOCKER_AUTH='--username vanessa --password [password]'
```

##### Testing Authentication
If you are having trouble, you can test your token by obtaining it on the command line and putting it into an environmental variable, `CREDENTIAL`:


```bash
CREDENTIAL=$(echo -n vanessa:[password] | base64)
TOKEN=$(http 'https://auth.docker.io/token?service=registry.docker.io&scope=repository:vanessa/code-samples:pull' Authorization:"Basic $CREDENTIAL" | jq -r '.token')
```

This should place the token in the environmental variable `TOKEN`. To test that your token is valid, you can do the following

```bash
http https://index.docker.io/v2/vanessa/code-samples/tags/list Authorization:"Bearer $TOKEN"
```

The above call should return the tags list as expected.


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
