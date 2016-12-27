---
title:  "Building CentOS image (especially on a Ubuntu host)"
category: recipes
permalink: building-centos-ubuntu-host
---

This recipe describes how to build an CentOS image using Singularity, with special emphasis for Ubuntu compatible host. 

**NOTE: this tutorial is intended for [Singularity release 2.2](http://singularity.lbl.gov/release-2-2), and reflects standards for that version.**


In theory, Ubuntu host can create/bootstrap a centos image by installing the `yum` package.  However, because the rpm tool can only operate on a very specific version of Berkeley DB, which tends to differ from the one on the Ubuntu host.  This result in a very messy situation for singularity to deal with.  A perfectly working centos.def file that can bootstrap a CentOS image from a RHEL-compatible host will not work when executed on Ubuntu, yielding error like:


```
YumRepo Error: All mirror URLs are not using ftp, http[s] or file.
Eg. Invalid release/
removing mirrorlist with no valid mirrors: /var/cache/yum/x86_64/$releasever/base/mirrorlist.txt
Error: Cannot find a valid baseurl for repo: base
ERROR: Aborting with RETVAL=255   
```

The erros is because during the bootstrae process, Ubuntu would have used its version of Berkeley DB to create the rpm database in the CentOS image.  Subsequent feature add on the image using `yum` fails because it is unable parse the Berkeley DB to read the releasever variable, since it is a different version.    

This problem is not exclusive to Ubuntu.  Other flavor of Linux likely have the same problem.  In fact, building CentOS image hosted by a newer centos host have the same problem.  

There are a number of solutions:

1.  Obtain db*_load that match the Berkeley DB version for the version of CentOS being imaged, and add a conversion step  during singularity bootstrap process.
2.  Perform a double bootstrap process: Build a base container containg CentOS (eg import from docker) and use this image to build the final desired centos image.  One can run container from within containers with Singularity as long as you are root when you do it.  
3.  Go to a CentOS machine and create a basic singularity image, and copy this image to the ubuntu machine.  Since such image already have a working `/bin/sh`, `rpm`, `yum` commands, RPM database with the correct version of Berkeley DB, subsequent `singularity bootstrap` on this image can successfully run `yum` to update and add additional software to this image.
4.  Leverage `singularity import centos.img docker://centos:6` to seed the CentOS image. 
5.  Import the container from Singularity Hub, when this feature becomes available.


## Step by step instructions for option 3

1. Identify a centos machine with the same major version of centos version you want to build.  Don't use a CentOS-7 machine to build a CentOS-6 machine, it won't work.  (Building a CentOS-7 image on a CentOS-6 host works--but the rpm DB would actually be using an older version of Berkeley DB)
3. Install singularity on this host.  Locate the [centos.def](https://github.com/singularityware/singularity/blob/2.x/examples/centos.def) file from the example/ directory.  Edit to your heart's desire (eg change OSVersion).
2. Run `sudo singularity create /tmp/centos.img`  
3. Run `sudo singularity bootstrap /tmp/centos.img centos.def`
4. Copy /tmp/centos.img to host wanting to run the container, eg the Ubuntu host.
5. On the ubuntu host, can execute the centos container as `singularity shell centos.img`
6. If further update is desired on this image, update the centos.def as desired, then run `singularity bootstrap centos.img centos.def`.  At this stage, this works because the container already has the minimum ingredients to run yum from its own content.   There isn't even a need to install `yum` on the Ubuntu host.

Instead of building your own seed CentOS image, the docker image imported using Option 4 can be used as well.  Subsequent `singularity bootstrap` on such .img file works.

## Pursuing Option 1 or 2

You will need to find the binary for various versions of db_load, and perhaps rename them to things like db43_load, db47_load, etc.  Then, you will need to update the build-yum.sh script that comes with the singularity distribution, and add steps to convert the rpm db files in /var/lib/rpm to the desired version of Berkeley DB utilized by the target OS release.

For further details of the above steps, 
refer to [this thread](https://groups.google.com/a/lbl.gov/forum/#!topic/singularity/gb-m2sjOLkM) on the mailing list, and look for postings by Tru Huynh.

### Miscellaneous troubleshooting notes


- The rpm command is NOT needed on the host to carry out the singularity bootstrap process
- Initial bootstrap from an empty image need yum, but after a basic image w/ /bin/sh and yum in place, yum from inside the container is called.  
- The rpm containing db*_load are different in different OS.   Here is a helping list:

``` 
OS             rpm                               path to db*_load 
CentOS-6       db4-utils-4.7.25-20.el6_7.x86_64  /usr/bin/db_load
CentOS-6       compat-db43-4.3.29-15.el6.x86_64  /usr/bin/db42_load
CentOS-6       compat-db42-4.2.52-15.el6.x86_64  /usr/bin/db43_load
CentOS-7       libdb-utils-5.3.21-19.el7.x86_64  /usr/bin/db_load
```
- Unfortunately the `file` command provided by coreutils cannot give accurate version details of BerkeleyDB used by the RPM database.  `file /var/lib/rpm/Packages` returns "version 9" in both CentOS 6 and 7.
- Unfortunately the `db_dump` command provided by db4-utils doesn't help either.  `db_dump -p /var/lib/rpm/Packages | head -1` always returns "VERSION=3", for RPM DB found natively in RHEL-6 and 7 hosts.  


## Caveat Emptor

If building CentOS image from an Ubuntu host, one can seemingly use `yum --releasever=6` to get yum to work and get a container build.  This kinda work, but some packages maybe installed twice while others may not be consistent, since `yum` is not able to properly query the rpm database created in the first stage of the bootstrap process.  This approach is *NOT* recommended for any long-lived container images.

