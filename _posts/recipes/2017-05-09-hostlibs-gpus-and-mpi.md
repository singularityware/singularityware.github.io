---
title:  "Using Host libraries: GPU drivers and OpenMPI BTLs"
category: recipes
permalink: singularity-tutorial
---

Singularity does a fantastic job  of isolating you from the host so you don't
have to muck about with 'LD_LIBRARY_PATH', you just get exactly the library
versions you want. However in some situations you actually need to use library
versions that match exactly host libraries. Two common ones are NVIDIA gpu
drivers and user space libraries and OpenMPI transport drivers for high performance
networking.  

There are many ways to solve these problems. Some people build a container and
copy the version of the libs installed on the host into the container. This document
describes how to use a bind mount, symlinks and ldconfig so that when the host
libraries are updated the container does not need to be rebuilt.
{% include toc.html %}

**Note this tutorial is tested with Singularity commit 945c6ee343a1e6101e22396a90dfdb5944f442b6
(version 2.3 should work once released)
and OpenMPI version 2.1.0 (versions above 2.1 should work)**

## Environment

In our environment we run CentOS 7 hosts with:
  1. slurm located on '/opt/slurm-<version>' and the slurm user 'slurm'
  2. Mellanox network cards with drivers installed to '/opt/mellanox' (
    Specifically we run a RoCEv1 network for Lustre and MPI communications)
  3. NVIDIA GPUs with drivers installed to '/lib64'
  4. OpenMPI (by default) for MPI processes

## Creating your image

Since we are building an ubuntu image, it may be easier to create an ubuntu VM
to create the image. Alternatively you can follow the recipe
<a href="/building-ubuntu-rhel-host"> here </a>.

Use the following def file to create the image.

{% gist l1ll1/89b3f067d5b790ace6e6767be5ea2851 hostlibs.def %}

The mysterious wget line gets a list of all the libraries that the CentOS host
has in '/lib64' that *we* think its safe to use in the container. Specifically
this is things like nvidia drivers.

{% gist l1ll1/89b3f067d5b790ace6e6767be5ea2851 desired_hostlibs.txt %}

Also note:

1.  in 'hostlibs.def' we create a slurm user. Obviously if your 'SlurmUser'
is different you should change this name.
2.  We make directories for '/opt' and '/usr/local/openmpi'. We're going to
bindmount these from the host so we get all the bits of OpenMPI and Mellanox
and Slurm that we need.

## Executing your image
On our system we do
```export SINGULARITYENV_LD_LIBRARY_PATH=/usr/local/openmpi/2.1.0-gcc4/lib:/opt/munge-0.5.11/lib:/opt/slurm-16.05.4/lib:/opt/slurm-16.05.4/lib/slurm:/desired_hostlibs:/opt/mellanox/mxm/lib/
```
then
```
srun  singularity exec -B /usr/local/openmpi:/usr/local/openmpi -B /opt:/opt -B /lib64:/all_hostlibs hostlibs.img <path to binary>
```
