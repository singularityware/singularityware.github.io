---
title: Singularity Pull
sidebar: user_docs
permalink: docs-pull
folder: docs
toc: false
---

Singularity `pull` is the command that you would want to use to communicate with a container registry. The command does exactly as it says - there exists an image external to my host, and I want to pull it here. We currently support pull for both <a href="https://hub.docker.com/" target="_blank">Docker</a> and <a href="https://singularity-hub.org" target="_blank">Singularity Hub</a> images, and will review usage for both.

{% include toc.html %}

## Singularity Hub
Singularity differs from Docker in that we serve entire images, as opposed to layers. This means that pulling a Singularity Hub means downloading the entire (compressed) container file, and then having it extract on your local machine. The basic command is the following:

```
singularity pull shub://vsoch/hello-world
Progress |===================================| 100.0% 
Done. Container is at: ./vsoch-hello-world-master.img
```


### How do tags work?
On Singularity Hub, a `tag` coincide with a branch. So if you have a repo called `vsoch/hello-world`, by default the file called `Singularity` (your build recipe file) will be looked for in the base of the master branch. The command that we issued above would be equivalent to doing:

```
singularity pull shub://vsoch/hello-world:master
```

To enable other branches to build, they must be turned on in your collection (more details are available in the <a href="https://singularity-hub.org/faq" target="_blank">Singularity Hub docs</a>). If you then put another `Singularity` file in a branch called development, you would pull it as follows:

```
singularity pull shub://vsoch/hello-world:development
```

The term `latest` in Singularity Hub will pull, across all of your branches, the most recent image. If `development` is more recent than `master`, it would be pulled, for example.

### Image Names
As you can see, since we didn't specify anything special, the default naming convention is to use the username, reponame, and the branch (tag). You have three options for changing this:

```
PULL OPTIONS:
    -n/--name   Specify a custom container name (first priority)
    -C/--commit Name container based on GitHub commit (second priority)
    -H/--hash   Name container based on file hash (second priority)
```    

### Custom Name

```
singularity pull --name meatballs.img shub://vsoch/hello-world
Progress |===================================| 100.0% 
Done. Container is at: ./meatballs.img
```

### Name by commit
Each container build on Singularity Hub is associated with the GitHub commit of the repo that was used to build it. You can specify to name your container based on the commit with the `--commit` flag, if, for example, you want to match containers to their build files:

```
singularity pull --commit shub://vsoch/hello-world
Progress |===================================| 100.0% 
Done. Container is at: ./4187993b8b44cbfa51c7e38e6b527918fcdf0470.img
```

### Name by hash
If you prefer the hash of the file itself, you can do that too.

```
singularity pull --hash shub://vsoch/hello-world
Progress |===================================| 100.0% 
Done. Container is at: ./4db5b0723cfd378e332fa4806dd79e31.img
```

### Pull to different folder
For any of the above, if you want to specify a different folder for your image, you can define the variable `SINGULARITY_PULLFOLDER`. By default, we will first check if you have the `SINGULARITY_CACHEDIR` defined, and pull images there. If not, we look for `SINGULARITY_PULLFOLDER`. If neither of these are defined, the image is pulled to the present working directory, as we showed above. Here is an example of pulling to `/tmp`.

```
SINGULARITY_PULLFOLDER=/tmp
singularity pull shub://vsoch/hello-world
Progress |===================================| 100.0% 
Done. Container is at: /tmp/vsoch-hello-world-master.img
```

### Pull by commit
You can also pull different versions of your container by using their commit id (`version`). 

```
singularity pull shub://vsoch/hello-world@42e1f04ed80217895f8c960bdde6bef4d34fab59
Progress |===================================| 100.0%
Done. Container is at: ./vsoch-hello-world-master.img
```

In this example, the first build of this container will be pulled.


## Docker
Docker pull is similar (on the surface) to a Singularity Hub pull, and we would do the following:


```
singularity pull docker://ubuntu
Initializing Singularity image subsystem
Opening image file: ubuntu.img
Creating 223MiB image
Binding image to loop
Creating file system within image
Image is done: ubuntu.img
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /home/vanessa/.singularity/docker
Importing: base Singularity environment
Importing: /home/vanessa/.singularity/docker/sha256:b6f892c0043b37bd1834a4a1b7d68fe6421c6acbc7e7e63a4527e1d379f92c1b.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:55010f332b047687e081a9639fac04918552c144bc2da4edb3422ce8efcc1fb1.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:2955fb827c947b782af190a759805d229cfebc75978dba2d01b4a59e6a333845.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:3deef3fcbd3072b45771bd0d192d4e5ff2b7310b99ea92bce062e01097953505.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:cf9722e506aada1109f5c00a9ba542a81c9e109606c01c81f5991b1f93de7b66.tar.gz
Importing: /home/vanessa/.singularity/metadata/sha256:fe44851d529f465f9aa107b32351c8a0a722fc0619a2a7c22b058084fac068a4.tar.gz
Done. Container is at: ubuntu.img
```

If you specify the tag, the image would be named accordingly (eg, `ubuntu-latest.img`). Did you notice that the output looks similar to if we did the following?

```
singularity create ubuntu.img
singularity import ubuntu.img docker://ubuntu
```

this is because the same logic is happening on the back end. Thus, the pull command with a docker uri also supports arguments `--size` and `--name` Here is how I would pull an ubuntu image, but make it bigger, and name it something else.

```
singularity pull --size 2000 --name jellybelly.img docker://ubuntu
Initializing Singularity image subsystem
Opening image file: jellybelly.img
Creating 2000MiB image
Binding image to loop
Creating file system within image
Image is done: jellybelly.img
Docker image path: index.docker.io/library/ubuntu:latest
Cache folder set to /home/vanessa/.singularity/docker
Importing: base Singularity environment
Importing: /home/vanessa/.singularity/docker/sha256:b6f892c0043b37bd1834a4a1b7d68fe6421c6acbc7e7e63a4527e1d379f92c1b.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:55010f332b047687e081a9639fac04918552c144bc2da4edb3422ce8efcc1fb1.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:2955fb827c947b782af190a759805d229cfebc75978dba2d01b4a59e6a333845.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:3deef3fcbd3072b45771bd0d192d4e5ff2b7310b99ea92bce062e01097953505.tar.gz
Importing: /home/vanessa/.singularity/docker/sha256:cf9722e506aada1109f5c00a9ba542a81c9e109606c01c81f5991b1f93de7b66.tar.gz
Importing: /home/vanessa/.singularity/metadata/sha256:fe44851d529f465f9aa107b32351c8a0a722fc0619a2a7c22b058084fac068a4.tar.gz
Done. Container is at: jellybelly.img
```
