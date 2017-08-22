---
title:  "Using Host libraries: GPU drivers and OpenMPI BTLs"
category: recipes
permalink: tutorial-gpu-drivers-open-mpi-mtls
---

**Note: _Much of the GPU portion of this tutorial is deprecated by the `--nv`
option that automatically binds host system driver libraries into your 
container at runtime.  See the [`exec`](/docs-exec#a-gpu-example) command for 
an example_**

Singularity does a fantastic job  of isolating you from the host so you don't
have to muck about with `LD_LIBRARY_PATH`, you just get exactly the library
versions you want. However, in some situations you need to use library
versions that match host exactly. Two common ones are NVIDIA gpu
driver user-space libraries, and OpenMPI transport drivers for high performance
networking. There are many ways to solve these problems. Some people build a container and
copy the version of the libs (installed on the host) into the container. 

{% include toc.html %}

## What We will learn today
This document describes how to use a bind mount, symlinks and ldconfig so that when the host
libraries are updated the container does not need to be rebuilt.

**Note** this tutorial is tested with Singularity <a href="https://github.com/singularityware/singularity/commit/945c6ee343a1e6101e22396a90dfdb5944f442b6" target="_blank">commit 945c6ee343a1e6101e22396a90dfdb5944f442b6</a>,
 which is part of the (current) development branch, and thus it should work with version 2.3 
when that is released. The version of OpenMPI used is 2.1.0 (versions above 2.1 should work).

## Environment

In our environment we run CentOS 7 hosts with:

  1. slurm located on `/opt/slurm-<version>` and the slurm user `slurm`
  2. Mellanox network cards with drivers installed to `/opt/mellanox` (
    Specifically we run a RoCEv1 network for Lustre and MPI communications)
  3. NVIDIA GPUs with drivers installed to `/lib64`
  4. OpenMPI (by default) for MPI processes

## Creating your image
Since we are building an ubuntu image, it may be easier to create an ubuntu VM
to create the image. Alternatively you can follow the recipe
<a href="/building-ubuntu-rhel-host" target="_blank"> here</a>.

Use the following def file to create the image.

{% include gist.html username='l1ll1' id='89b3f067d5b790ace6e6767be5ea2851' file='hostlibs.def' %}

The mysterious `wget` line gets a list of all the libraries that the CentOS host
has in `/lib64` that *we* think its safe to use in the container. Specifically
these are things like nvidia drivers.

{% include gist.html username='l1ll1' id='89b3f067d5b790ace6e6767be5ea2851' file='desired_hostlibs.txt' %}

Also note:

1.  in `hostlibs.def` we create a slurm user. Obviously if your `SlurmUser` is different you should change this name.
2.  We make directories for `/opt` and `/usr/local/openmpi`. We're going to bindmount these from the host so we get all the bits of OpenMPI and Mellanox and Slurm that we need.


## Executing your image
On our system we do:

```
SINGULARITYENV_LD_LIBRARY_PATH=/usr/local/openmpi/2.1.0-gcc4/lib:/opt/munge-0.5.11/lib:/opt/slurm-16.05.4/lib:/opt/slurm-16.05.4/lib/slurm:/desired_hostlibs:/opt/mellanox/mxm/lib/
export SINGULARITYENV_LD_LIBRARY_PATH
```

then

```
srun  singularity exec -B /usr/local/openmpi:/usr/local/openmpi -B /opt:/opt -B /lib64:/all_hostlibs hostlibs.img <path to binary>
```
