---
title:  "Building CentOS image (emphasis on Ubuntu host)"
category: recipes
permalink: building-centos-image
---

This recipe describes how to build a CentOS image using Singularity, with special emphasis for Ubuntu compatible host. 

{% include toc.html %}


**NOTE: this tutorial is intended for [Singularity release 2.2](http://singularity.lbl.gov/release-2-2), and reflects standards for that version.**

## The Problem
In theory, an Ubuntu host can create/bootstrap a CentOS image by installing the `yum` package, which is a front-end controller for [RPM](https://en.wikipedia.org/wiki/RPM_Package_Manager).  In order for this to work on Ubuntu, a software called [Berkeley DB](https://en.wikipedia.org/wiki/Berkeley_DB) must be identical in version to the version expected by `yum`. Unfortunately, these two verisons tend to be different, and this situation poses a difficult challenge for Singularity to deal with. A perfectly working `centos.def` file that can bootstrap a CentOS image from a RHEL-compatible host will not work when executed on Ubuntu, yielding the following error:


```bash
YumRepo Error: All mirror URLs are not using ftp, http[s] or file.
Eg. Invalid release/
removing mirrorlist with no valid mirrors: /var/cache/yum/x86_64/$releasever/base/mirrorlist.txt
Error: Cannot find a valid baseurl for repo: base
ERROR: Aborting with RETVAL=255   
```

The error above results during the bootstrap process, and happens because Ubuntu is trying to use its version of Berkeley DB to create the RPM database in the CentOS image.  Because of a version conflict, subsequent use of `yum` fails because it is unable parse the Berkeley DB.

This problem is not exclusive to Ubuntu.  Other flavors of Linux likely have the same problem.  In fact, building a CentOS image hosted by a newer CentOS host results in the same problem!

## Potential Solutions
There are a number of solutions:

1.  Obtain `db*_load` that match the Berkeley DB version for the version of CentOS being imaged, and add a conversion step during the Singularity bootstrap process.
2.  Perform a double bootstrap process: First build a base container containg CentOS (e.g. import from docker) and then 2) use this image to build the final desired CentOS image. You can run a container from within another container with Singularity as long as you are root when you do it.  
3.  Go to a CentOS machine and create a basic singularity image, and copy this image to the Ubuntu machine.  Since such an image already has working `/bin/sh`, `rpm`, `yum` commands, and an RPM database with the correct version of Berkeley DB, a subsequent `singularity bootstrap` on this image can successfully run `yum` to update and add additional software to this image.
4.  Leverage `singularity import centos.img docker://centos:6` to seed the CentOS image. 
5.  Import the container from Singularity Hub, when this feature becomes available.


### Create an image on CentOS (Option 3)

1. Identify a CentOS machine with the same major version of CentOS you want to build.  Don't use a CentOS-7 machine to build a CentOS-6 machine, because it won't work.  (Building a CentOS-7 image on a CentOS-6 host works, but the RPM DB would actually be using an older version of Berkeley DB)
2. Install Singularity on this host.  Locate the [centos.def](https://github.com/singularityware/singularity/blob/2.x/examples/centos.def) file from the `example/` directory.  Edit to your heart's desire (eg change OSVersion).
3. Create the image, bootstrap, and run:

```bash
sudo singularity create /tmp/centos.img
```

Bootstrap:

```bash
sudo singularity bootstrap /tmp/centos.img centos.def
```

Copy `/tmp/centos.img` to the host where you want to run the container (e.g. the Ubuntu host).
On the Ubuntu host, you can execute the CentOS container:

```bash
singularity shell centos.img
```

If further update is desired on this image, update the `centos.def` as desired, then run:

```bash
singularity bootstrap centos.img centos.def
```

At this stage, the bootstrap works because the container already has the minimum requirements to run `yum` from its own content.  There isn't a need to install `yum` on the Ubuntu host.

### Bootstrap a Docker Container (Option 4)

Instead of building your own seed CentOS image, the docker image imported using Option 4 can be used as well.  Subsequent `singularity bootstrap` on such .img file works.


### Pursuing Option 1 or 2
You will need to find the binary for various versions of `db_load`, and perhaps rename them to things like `db43_load`, `db47_load`, etc.  You will then need to update the `build-yum.sh` script that comes with the Singularity distribution, and add steps to convert the RPM DB files in `/var/lib/rpm` to the desired version of Berkeley DB utilized by the target OS release.

For further details of the above steps, 
refer to [this thread](https://groups.google.com/a/lbl.gov/forum/#!topic/singularity/gb-m2sjOLkM) on the mailing list, and look for postings by Tru Huynh.

## Miscellaneous troubleshooting notes
- The RPM command is NOT needed on the host to carry out the Singularity bootstrap process
- Initial bootstrap from an empty image needs `yum`, but after a basic image with `/bin/sh` and `yum` in place, the `yum` installation from inside the container is called.  
- The RPM containing `db*_load` are different in different OS. Here is a helpful list:

``` 
OS             rpm                               path to db*_load 
CentOS-6       db4-utils-4.7.25-20.el6_7.x86_64  /usr/bin/db_load
CentOS-6       compat-db43-4.3.29-15.el6.x86_64  /usr/bin/db42_load
CentOS-6       compat-db42-4.2.52-15.el6.x86_64  /usr/bin/db43_load
CentOS-7       libdb-utils-5.3.21-19.el7.x86_64  /usr/bin/db_load
```

- Unfortunately the `file` command provided by coreutils cannot give accurate version details of Berkeley DB used by the RPM database.  `file /var/lib/rpm/Packages` returns "version 9" in both CentOS 6 and 7.
- Unfortunately the `db_dump` command provided by `db4-utils` doesn't help either.  `db_dump -p /var/lib/rpm/Packages | head -1` always returns "VERSION=3", for RPM DB found natively in RHEL-6 and 7 hosts.  


### Be careful with yum release
If building CentOS image from an Ubuntu host, one can seemingly use `yum --releasever=6` to get `yum` to work and get a container to build.  This kind of works, but some packages may be installed twice while others may not be consistent, since `yum` is not able to properly query the RPM database created in the first stage of the bootstrap process.  This approach is *NOT* recommended for any long-lived container images.
