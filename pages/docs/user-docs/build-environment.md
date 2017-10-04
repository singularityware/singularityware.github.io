---
title: Build Customization
sidebar: user_docs
permalink: build-environment
folder: docs
---

It's commonly the case that you want to customize your build environment, such as specifying a custom cache directory for layers, or sending your Docker Credentials to the registry endpoint. Here we will discuss those things

{% include toc.html %}


## Cache Folders
To make download of layers for build and <a href="/docs-pull">pull</a> faster and less redundant, we use a caching strategy. By default, the Singularity software will create a set of folders in your `$HOME` directory for docker layers, Singularity Hub images, and Docker metadata, respectively:

```
$HOME/.singularity
$HOME/.singularity/docker
$HOME/.singularity/shub
$HOME/.singularity/metadata
```

Fear not, you have control to customize this behavior! If you don't want the cache to be created (and a temporary directory will be used), set `SINGULARITY_DISABLE_CACHE` to True/yes, or if you want to move it elsewhere, set `SINGULARITY_CACHEDIR` to the full path where you want to cache. Remember that when you run commands as sudo this will use root's home at `/root` and not your user's home. 

## Pull Folder
For details about customizing the output location of <a href="/docs-pull">pull</a>, see the<a href="/docs-pull">pull docs.</a> You have the similar ability to set it to be something different, or to customize the name of the pulled image.


## Environment Variables
All environmental variables are parsed by Singularity python helper functions, and specifically the file <a href="https://github.com/singularityware/singularity/blob/master/libexec/python/defaults.py" target="_blank">defaults.py</a> is a gateway between variables defined at runtime, and pre-defined defaults. By way of import from the file, variables set at runtime do not change if re-imported. This was done intentionally to prevent changes during the execution, and could be changed if needed. For all variables, the order of operations works as follows:
  
  1. First preference goes to environment variable set at runtime
  2. Second preference goes to default defined in this file
  3. Then, if neither is found, null is returned except in the case that `required=True`. A `required=True` variable not found will system exit with an error.
  4. Variables that should not be dispayed in debug logger are set with `silent=True`, and are only reported to be defined.


For boolean variables, the following are acceptable for True, with any kind of capitalization or not:

```
("yes", "true", "t", "1","y")
```

## Cache
The location and usage of the cache is also determined by environment variables. 

**SINGULARITY_DISABLE_CACHE**
If you want to disable the cache, this means is that the layers are written to a temporary directory. Thus, if you want to disable cache and write to a temporary folder, simply set `SINGULARITY_DISABLE_CACHE` to any true/yes value. By default, the cache is not disabled.

**SINGULARITY_CACHE**
Is the base folder for caching layers and singularity hub images. If not defined, it uses default of `$HOME/.singularity`. If defined, the defined location is used instead. If `SINGULARITY_DISABLE_CACHE` is set to True, this value is ignored in favor of a temporary directory. For specific subtypes of things to cache, subdirectories are created (by python), including `$SINGULARITY_CACHE/docker` for docker layers and `$SINGULARITY_CACHE/shub` for Singularity Hub images. If the cache is not created, the Python script creates it.

**SINGULARITY_PULLFOLDER**
While this isn't relevant for build, since build is close to pull, we will include it here. By default, images are pulled to the present working directory. The user can change this variable to change that.


### Defaults
The following variables have defaults that can be customized by you via environment variables at runtime. 


#### Docker

**DOCKER_API_BASE** 
Set as `index.docker.io`, which is the name of the registry. In the first version of Singularity we parsed the Registry argument from the build spec file, however now this is removed because it can be obtained directly from the image name (eg, `registry/namespace/repo:tag`). If you don't specify a registry name for your image, this default is used. If you have trouble with your registry being detected from the image URI, use this variable.

**DOCKER_API_VERSION**
Is the version of the Docker Registry API currently being used, by default now is `v2`.

**DOCKER_OS**
This is exposed via the exported environment variable `SINGULARITY_DOCKER_OS` and pertains to images that reveal a version 2 manifest with a [manifest list](https://docs.docker.com/registry/spec/manifest-v2-2/#manifest-list). In the case that the list is present, we must choose an operating system (this variable) and an architecture (below). The default is `linux`.

**DOCKER_ARCHITECTURE**
This is exposed via the exported environment variable `SINGULARITY_DOCKER_ARCHITECTURE` and the same applies as for the `DOCKER_OS` with regards to being used in context of a list of manifests. In the case that the list is present, we must choose an architecture (this variable) and an os (above). The default is `amd64`, and other common ones include `arm`, `arm64`, `ppc64le`, `386`, and `s390x`.

**NAMESPACE**
Is the default namespace, `library`.

**RUNSCRIPT_COMMAND** 
Is not obtained from the environment, but is a hard coded default (`"/bin/bash"`). This is the fallback command used in the case that the docker image does not have a `CMD` or `ENTRYPOINT`.

**TAG**
Is the default tag, `latest`.

**SINGULARITY_NOHTTPS**
This is relevant if you want to use a registry that doesn't have https, and it speaks for itself. If you export the variable `SINGULARITY_NOHTTPS` you can force the software to not use https when interacting with a Docker registry. This use case is typically for use of a local registry.


#### Singularity Hub

**SHUB_API_BASE**
The default base for the Singularity Hub API, which is `https://singularity-hub.org/api`. If you deploy your own registry, you don't need to change this, you can again specify the registry name in the `shub://` URI.



### General
**SINGULARITY_PYTHREADS**
The Python modules use threads (workers) to download layer files for Docker, and change permissions. By default, we will use 9 workers, unless the environment variable `SINGULARITY_PYTHREADS` is defined.


**SINGULARITY_COMMAND_ASIS**
By default, we want to make sure the container running process gets passed forward as the current process, so we want to prefix whatever the Docker command or entrypoint is with `exec`. We also want to make sure that following arguments get passed, so we append `"$@"`. Thus, some entrypoint or cmd might look like this:

```
     /usr/bin/python
```

and we would parse it into the runscript as:
```
     exec /usr/bin/python "$@"
```
However, it might be the case that the user does not want this. For this reason, we have the environmental variable `RUNSCRIPT_COMMAND_ASIS`. If defined as yes/y/1/True/true, etc., then the runscript will remain as `/usr/bin/python`.
