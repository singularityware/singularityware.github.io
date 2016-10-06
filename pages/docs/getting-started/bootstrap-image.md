---
title: Getting Started with Bootstrap
sidebar: main_sidebar
permalink: bootstrap-image
folder: docs
---

## The definition file
Singularity container images can be bootstrapped with a definition file which describes how the container is to be built. The bootstrap definition can be very simple to create a working base image, or it can specify the entire build chain and every command needed to land at a fully functioning end product.

Below is an example bootstrap file to create a minimal Debian base image:

```bash
BootStrap: debian
OSVersion: trusty
MirrorURL: http://us.archive.ubuntu.com/ubuntu/


%runscript
    echo "This is what happens when you run the container..."


%post
    echo "Hello from inside the container"
    sed -i 's/$/ universe/' /etc/apt/sources.list
    apt-get -y install vim
```

Broadly, the header tells Singularity what to use as a base, `%runscript` is one or more lines that will be executed when you run the container (akin to Docker's CMD), and `%post` are one or more lines that will be executed only once after bootstrap (this is where you would install packages, make directories, etc.) The bootstrap file supports a mixture of shell and Singularity keywords and syntax. There are two flavors of bootstrapping:

1. Bootstrap another OS (start from scratch)
2. Bootstrap another container (currently supported is Docker)

Each of the above has slightly different arguments you will be interested in:

### Arguments for Both

- BootStrap: This is necessary to tell Singularity which distribution module should be used to parse the commands. Current supported bases are "redhat", "debian", "arch", "busybox", and "docker". Note that "redhat" applies to all Red Hat compatible distributions (e.g. CentOS), and "debian" applies to all Debian based derivatives (e.g. Ubuntu).
- %runscript: one or more lines that will be executed when you run the container (akin to Docker's CMD)
- %post: one or more lines that will be executed only once after bootstrap (install packages, make directories, etc.) 


### Arguments for Bootstrapping another OS
- MirrorURL: When bootstrapping, the packages necessary for the operating system build are downloaded on demand via the internet. In some cases (like CentOS vs. Scientific Linux) this is the only differentiating factor for what distribution gets installed.
- Build: This is a Debian flavor specific keyword and it is passed directly to debootstrap.


### Arguments for Docker

- IncludeCmd: This argument should be added and set to "no" or "yes" if you want to have the Docker CMD specified in the Dockerfile used as the container's runscript (a file called "/singularity" that is executed when you use the container like an executable. Note that if you define %runscript, this second definition will overwrite the CMD found from the Docker image.
- Registry: The default or public Docker registry is `registry-1.docker.io`, however many institutions host their own! You can specify a different registry via this argument, for example, Google Cloud would be `gcr.io`
- Token: If your registry is not Docker's public/default, does it require a token? For example, gcr.io (as of the update to these docs) does not require a token, and so "Token" would be set to "no" for the bootstrap to work properly.


<br>For <strong>examples</strong> we recommend that you look at the <a href="{{ site.repo}}/tree/master/examples" target="_blank">examples</a> folder for the most up-to-date examples.

### Bootstrapping
Once you have the bootstrap defined (or starting with a basic one), you can then use the `bootstrap` Singularity command to install the operating system into the container image. The process for doing this can be seen with:

```bash
$ sudo singularity bootstrap container.img debian.def 
W: Cannot check Release signature; keyring file not available /usr/share/keyrings/debian-archive-keyring.gpg
I: Retrieving Release 
I: Retrieving Packages 
I: Validating Packages 
I: Resolving dependencies of required packages...
I: Resolving dependencies of base packages...
I: Found additional required dependencies: acl adduser dmsetup insserv libaudit-common libaudit1 libbz2-1.0 libcap2 libcap2-bin libcryptsetup4 libdb5.3 libdebconfclient0 libdevmapper1.02.1 libgcrypt20 libgpg-error0 libkmod2 libncursesw5 libprocps3 libsemanage-common libsemanage1 libslang2 libsystemd0 libudev1 libustr-1.0-1 procps systemd systemd-sysv udev 
I: Found additional base dependencies: libdns-export100 libffi6 libgmp10 libgnutls-deb0-28 libgnutls-openssl27 libhogweed2 libicu52 libidn11 libirs-export91 libisc-export95 libisccfg-export90 libmnl0 libnetfilter-acct1 libnettle4 libnfnetlink0 libp11-kit0 libpsl0 libtasn1-6 
I: Checking component main on http://ftp.us.debian.org/debian...
I: Retrieving acl 2.2.52-2
I: Validating acl 2.2.52-2
I: Retrieving libacl1 2.2.52-2
I: Validating libacl1 2.2.52-2
I: Retrieving adduser 3.113+nmu3
I: Validating adduser 3.113+nmu3
I: Retrieving apt 1.0.9.8.3
I: Validating apt 1.0.9.8.3
I: Retrieving apt-utils 1.0.9.8.3
I: Validating apt-utils 1.0.9.8.3
I: Retrieving libapt-inst1.5 1.0.9.8.3
I: Validating libapt-inst1.5 1.0.9.8.3
I: Retrieving libapt-pkg4.12 1.0.9.8.3
I: Validating libapt-pkg4.12 1.0.9.8.3
I: Retrieving libattr1 1:2.4.47-2
I: Validating libattr1 1:2.4.47-2
I: Retrieving libaudit-common 1:2.4-1
I: Validating libaudit-common 1:2.4-1
I: Retrieving libaudit1 1:2.4-1+b1
I: Validating libaudit1 1:2.4-1+b1
I: Retrieving base-files 8+deb8u4
I: Validating base-files 8+deb8u4
I: Retrieving base-passwd 3.5.37
I: Validating base-passwd 3.5.37
I: Retrieving bash 4.3-11+b1
I: Validating bash 4.3-11+b1
snip....
Unpacking vim-runtime (2:7.4.488-7) ...
Selecting previously unselected package vim.
Preparing to unpack .../vim_2%3a7.4.488-7_amd64.deb ...
Unpacking vim (2:7.4.488-7) ...
Processing triggers for man-db (2.7.0.2-5) ...
Setting up libgpm2:amd64 (1.20.4-6.1+b2) ...
Setting up vim-runtime (2:7.4.488-7) ...
Processing /usr/share/vim/addons/doc
Setting up vim (2:7.4.488-7) ...
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/vim (vim) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/vimdiff (vimdiff) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/rvim (rvim) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/rview (rview) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/vi (vi) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/view (view) in auto mode
update-alternatives: using /usr/bin/vim.basic to provide /usr/bin/ex (ex) in auto mode
Processing triggers for libc-bin (2.19-18+deb8u4) ...
$ du -sh container.img 
312M    container.img
$ 
```

The image "container.img" has now been bootstrapped with the operating system as we specified in our definition file. For more detailed documentation, including instructions for bootstrapping a Docker image, see our <a href="/docs-bootstrap">bootstrap docs</a>.
