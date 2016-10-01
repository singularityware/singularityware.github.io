---
title:  "Building Singularity on Debian"
category: recipes
permalink: building-singularity-debian
---

This tutorial is generated courtsey of <a href="https://twitter.com/californiakarl" target="_blank">Karl Kornel</a> from Stanford Research Computing. The ascii art is amazing, if you don't care to build Singularity on Debian please scroll down to appreciate it in it's entirety. Thank you Karl!

For the purposes of this tutorial, we will assume that the name of your remote is "stanford" and your username is "vsoch."

{% include toc.html %}

## Quick Reference

This is for people who know what's going on, and just want help remembering the command sequence.

### Making a fresh repo.


    git init .
    git remote add lbl git@github.com:gmkurtzer/singularity.git
    git remote add stanford git@github.com:vsoch/singularity.git
    git fetch lbl

    for i in master 1.x 2.x gh-pages; do
    git checkout lbl/$i
    git checkout -b $i
    git branch -u stanford/$i
    done

    git push --all stanford
    git push --tags stanford

### Releasing an upstream version, with the change in source format, and adding the appropriate backport suffix to the version number.

    git clone https://github.com/vsoch/singularity.git
    git checkout 2.1.2
    git checkout -b stanford-2.1.2

    # Change debian/source/format to 3.0 (git)
    # Add git debian/control's Build-Depends list
    git commit -m 'Changing to git source format' debian/control debian/source/format

    dch -D xenial-backports -v 2.1.2-1~sbp16.04.1+1 'Releasing for Xenial'
    git commit -m 'Update changelog for release' debian/changelog

    git tag -s stanford/2.1.2-1_sbp16.04.1+1
    git push
    git push --tags


### To set up and build on a single system (same release only):

    aptitude install -y build-essential debhelper dh-autoreconf git
    dpkg-buildpackage -us -uc


### To set up and build on the build server:

    ssh $USER@$BUILDSERVER
    cd $SCRATCH/$USER
    test -d build-area || mkdir build-area

    git clone https://github.com/vsoch/singularity.git
    cd singularity

    git checkout stanford-2.1.2

    ls -d /var/cache/pbuilder/base*.cow

    pdebuild --pbuilder cowbuilder --buildresult ../build-area -- \
    --basepath /var/cache/pbuilder/base-xenial.cow

    rm ../singularity_*.dsc ../singularity_*.git \
    ../singularity_*.changes ../singularity_*.build
    cd ../build-area


## Overview

Singularity is unusual from a Debian perspective, in that the Debian packaging data are part of the upstream repository.

Normally, at least with Git repositories, the flow looks like this:

	    ==================
	    || Upstream     ||
	    || Repo         ||
	    ||              ||
	    ||  /--------\  ||
	    ||  | master |  ||
	    ||  | branch |  ||
	    ||  \----v---/  ||
	    =========v========
		     I
	    =========v===============================
	    ||  /----v-----\     /--------------\  ||
	    ||  | upstream |     | pristine-tar |  ||
	    ||  |  branch  +---->|    branch    |  ||
	    ||  \----v-----/     \-v------------/  ||
	    ||       I             I               ||
	    ||       I /--------\  I               ||
	    ||       I | debian |  I               ||
	    ||       I |  dir.  |  I               ||
	    ||       I \-v------/  I               ||
	    ||       I   I         I               ||
	    ||  /----v---v-\       I               ||
	    ||  |  master  |       I        Debian ||
	    ||  |  branch  |       I  Maintainer's ||
	    ||  \----v-----/       I          Repo ||
	    =========I=============I=================
		     I             I
		   /-v-------------v--\
		   |  Debian package  |
		   \------------------/


The Debian maintainer is responsible for pulling in code from upstream, adding the debian directory (which includes both metadata, build instructions, and patch files to change code), testing, and building the resulting Debian package(s).

With Singularity, there is no "Debian Maintainer's Repo", because the debian directory is in the upstream repository. On the one hand, this is nice because we only have to deal with a single repository! However, there are two challenges that are introduced by this:

1. You will always have to make a change of your own, because you need to set the name of the release that you are targeting when you build. The upstream repository is either going to have the release name (like "jessie" or "xenial") un-set, or will probably have it set to something that you do not want.
2. Most Debian build infrastructure is used to working from a `.tar` file containing the pristine (the "orig") source code. That doesn't exist here.

To deal with point 1, we do two things: We make a new branch, and we add a commit on that branch which updates the changelog (the release name and version number come from the changelog).

To deal with point 2, we change how Debian deals with the source code: Instead of expecting a source tarball (with the 3.0 (`orig`) or 3.0 (`quilt`) source formats), we use an experimental format (3.0 (`git`)) which simply bundles up the entire Git repo as the source!

With the two changes we will make, the actual flow will look like this:


	    =================================
	    || Upstream                    ||
	    || Repo                        ||
	    ||                             ||
	    ||  /---------\  /----------\  ||
	    ||  | release |  | various  |  ||
	    ||  |  tags   |  | branches |  ||
	    ||  \----v----/  \----v-----/  ||
	    =========v============v==========
		     I            I
	    =========v============v====================
	    ||  /----v----\  /----v-----\        Our ||
	    ||  | release |  | various  |       Repo ||
	    ||  |  tags   |  | branches |            ||
	    ||  \----v----/  \----------/            ||
	    ||       I                               ||
	    ||       I    /-------------\            ||
	    ||       I    | debian dir. |            ||
	    ||       I    |   changes   |            ||
	    ||       I    \--v----------/            ||
	    ||       I       I                       ||
	    ||  /----v-------v-\   /--------------\  ||
	    ||  | stanford-XXX |   | stanford/XXX |  ||
	    ||  |   branches   +--->     tags     |  ||
	    ||  \--------------/   \-------v------/  ||
	    ||                             I         ||
	    ===============v===============v===========
		           I               I
		           I     /---------v--------\
		           \----->  Debian package  |
		                 \------------------/


The overall process goes like this:

- First, we make a clone of the upstream repository. That brings in upstream's branches (like `master`, `1.x`, and `2.x`).
- We pick a release tag (like `2.1.2`) and branch it (making the `stanford-2.1.2` branch).
- We change some of the stuff in the debian directory, and we tag our changes.
- We build our package. The final package includes a copy of the entire Git repository as the source, instead of a `.tar` file.

The following sections describe each of those four overall steps.

## Creating the Repository

Singuarity has their repository in Github, so cloning the repository is just a matter of forking it. However, if you want your repository to live somewhere other than Github, you can do this process:

First, create a blank repository, add the upstream Github as a source, and fetch:

      git init .
      git remote add lbl git@github.com:gmkurtzer/singularity.git
      git fetch lbl

Next, add a new remote representing your upstream repository:

      git remote add stanford git@github.com:vsoch/singularity.git

Check out the branches you care about, and link them to your upstream:

      for i in master 1.x 2.x gh-pages; do
      git checkout lbl/$i
      git checkout -b $i
      git branch -u stanford/$i
      done

Finally, push everything to your new upstream:

      git push --all stanford
      git push --tags stanford


## Updating Your Repository

From time to time, you should pull in upstream changes, so that your repository is in sync. Here's how to do that.

First, create a blank repository, and add both your remote and the upstream remote. Then, fetch from both:

      git init .
      git remote add lbl git@github.com:gmkurtzer/singularity.git
      git remote add stanford git@github.com:vsoch/singularity.git
      git fetch --all

Next, synchronize all changes from the branches we know about:

      for i in master 1.x 2.x gh-pages; do
      git checkout stanford/$i
      git checkout -b $i
      git branch -u stanford/$i
      git merge lbl/$i
      done

Then, run git branch -r and look to see if upstream has any new branches. If they do, then create matching branches on your end:

      for i in new1 new2; do
      git checkout lbl/$i
      git checkout -b $i
      git branch -u stanford/$i
      done

Finally, push everything up to your copy:

      git push --all stanford
      git push --tags stanford

If you are leaving upstream's branches untouched, then all of the merges should be fast-forward merges. If, however, you are making changes in upstream branches (like `master`, or `2.x`), you should expect either a non-fast-forward merge or a conflict. It's up to you to deal with them.

## Making a release

When upstream makes a release, we should do the same. Even if we aren't going to package it, making the release now means that packaging will go faster later!

First, if you don't have the Git repository checked out, get it now:


      git clone https://github.com/vsoch/singularity.git


Next, either switch to the branch you want to build, or check out the tag for the release you want. In this case, we are getting `2.1.2` (which is a tag).


      git checkout 2.1.2


Then, create a new branch for that specific version, to which we'll add our changes:


      git checkout -b stanford-2.1.2


Now that we have our branch, there are two things we have to check:


1. Check debian/source/format, and change it to 3.0 (git).
2. Check debian/control, and add git to the "Build-Depends" list.


Once those changes are made, commit them.


      git commit -m 'Changing to git source format' debian/control debian/source/format


If you are working from your own Git repository, then you should also change the "Vcs-Git" and "Vcs-Browser" fields in debian/control. You should also add yourself to the "Uploaders" field. Then, once again, commit.

Next, you need to update the changelog. This is what sets the release, and also the version number!


      dch -D xenial-backports -v 2.1.2-1~sbp16.04.1+1 'Releasing for Xenial'
      git commit -m 'Update changelog for release' debian/changelog

(See the "Version Numbering" section for help on deciding what version number to use.)

Finally, make a new tag repesenting your version.

      git tag -s stanford/2.1.2-1_sbp16.04.1+1

(We changed the `~` in the version number to an `_` because Git doesn't allow the tilde character in tag names.)

When making the tag, an editor will launch, giving you a space to enter a tag description. Simply re-use the entry you made into debian/changelog (just copy-paste the entire changelog entry, including the header and the date line).

If you don't have a PGP key, then change `-s` to `-a`.

Finally, push everything, and you are ready to build!

      git push
      git push --tags

At this point, you can either go on to build the package, or you can stop, and the release will remain ready for when you do want to build.

## Version Numbering

Version numbering is interesting in Debian, because you need to keep track of at least two things:


- The upstream version number.
- The Debian revision number, which is essentially the version number for the debian directory contents.


But, you may also have to add other things:


- Debian derivatives (like Ubuntu) add their own suffix and number, like ubuntu1 or ubuntu2.
- If you are building something outside of the normal process, such as a backport (a newer version packaged for a production Debian release) or a test build, you need an additional suffix for that, normally a tilde character followed by something.


When constructing the package version number, there are two rules, and one very important exception to remember:

- Version numbers are evaluated in "parts", where each "part" is non-digit characters followed by digit characters. So, in the version number `2.1.2-1`, the parts are `2`, `.1`, `.2`, and `-1`.
- Within a part, first the non-numeric portion is compared (using an ASCII sort), and if equal, the numeric portion is compared (using a numeric sort).
- In Debian version numbers, the tilde character (`~`) sorts before everything else, including the empty string.

Because of that exception, if you have a test build (like `2.1.2-1~testFoo+1`) or a backport (`2.1.2-1~bpo8+1`), Debian will treat those versions as being *older* than a released version (like `2.1.2-1` or `2.1.2-1ubuntu1`).

More information is available in the <a href="https://www.debian.org/doc/debian-policy/" target="_blank">Debian Policy Manual</a>, sections <a href="https://www.debian.org/doc/debian-policy/ch-binary.html#s-versions" target="_blank">3.2</a> and <a href="https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-Version" target="_blank">5.6.12</a>.


Given all of the above, here are recommended version numbers to use:

- Backports (no code changes) for Debian should use the form `VERSION-1~sbp8+1`, where the `8` is the version number of the Debian release (Debian jessie is version 8).
- Backports (no code changes) for Ubuntu should use the form `VERSION-1~sbp16.04+1`. Similarly, `16.04` is the Ubuntu version.
- If we are making actual code changes, we should use a form like `VERSION-1stanford1`. We shoud then try to get those code changes applied upstream.

We use a different form for code changes because we want that to remain newer than anything that comes in through Debian/Ubuntu upstream (lest we lose our changes in an upgrade). Since backports don't have code changes, they are lower-priority.


## Building the package
Once you have a release tagged and pushed, it is time to build the package.
Before you start, you have to make a choice: You can either build the package on your own system, or you can use the Debian build service. Either way, the build products are the same.


### Building on your own system

The easiest way to build Singularity packages is on a system that you've already got. On the one hand, you don't have to maintain a separate infrastructure! However, you will only build for the release that you are running on that system. So, if you're running Debian wheezy, you'll only be able to build packages for Debian wheezy.

The other downside is that you'll have to install all of the build dependencies system-wide. However, that's not a big problem here, because Singularity's needs are very simple. There are four packages (plus all of their dependencies) that need to be installed:

- `build-essential` is a single package that installs (via dependencies) all of essential things that are required for building Debian packages.
- `debhelper` is a suite of scripts that help to automate the Debian package-building process. Almost all of the steps in making a package, such as generating the list of changes, are orchestrated by debhelper. (Singularity uses debhelper, which is why this is required.)
- `dh-autoreconf` is an optional debhelper component that ensures autoreconf is run before the software's configure script. This package also has the various autotools (`autoconf`, `automake`, etc.) as dependencies, so we can be sure they are also installed. (Singularity uses `dh-autoreconf`, which is why this is required.)
- Since we are getting everything from a Git repository, you'll need to install git.


You only have to do this the first time you build on this system.


      aptitude install -y build-essential debhelper dh-autoreconf git


Now it's time to build the package! Here's the command to use:


      dpkg-buildpackage -us -uc


That's it! That one command triggers an entire sequence of commands that will archive the source, build it, package the output, and create ancillary files. The command output is relatively good at explaining what's going on, so I won't reproduce or expand on that here.


### Using the Debian Build Server

If you plan on building for a release that is not your own, or you are unable to install all of the build dependencies, then you should use the Debian build server!

First, log in to the build server, and go to your scratch directory. Make a build-area directory, if you don't have one already:


      ssh $USER@buildserver
      cd $SCRATCH/$USER
      test -d build-area || mkdir build-area


Check out the repository, go into it, and then check out the branch or tag that you want to package:

      git clone https://github.com/vsoch/singularity.git
      cd singularity
      git checkout stanford-2.1.2


Look at the list of available releases to build against, and then pick one:


      ls -d /var/cache/pbuilder/base*.cow


Once the release you want is available, build your package!


      pdebuild --pbuilder cowbuilder --buildresult ../build-area -- \
      --basepath /var/cache/pbuilder/base-xenial.cow


The `pdebuild` process takes care of several different things:


- Instructing `cowbuilder` to spawn a new COW (copy-on-write) environment, based on the release you specify, and start a root session within the environment.
- Identifying any missing build dependencies, and installing them inside the build environent.
- Running dpkg-buildpackage, making sure that build products get put in the right place, and owned by you (not by `root`).


Once the build process is complete, the final products are placed into the build-area directory you created, but some intermediate products are left in the parent directory, which you should delete:


      rm ../singularity_*.dsc ../singularity_*.git \
      ../singularity_*.changes ../singularity_*.build


That's it! You now have stuff that you can install or upload.


### Build Products, and Uploading

Once package-building is complete, you should have three or four build products:

- The `.deb` file is your package! You can install this directly with `dpkg -i DEB_FILE_PATH`.
- The `.build` is a complete log of the steps taken to build your package, as well as the output (standard out and standard error) from those steps. If you are building locally, then this file might only be created if there was a problem. If you are using the build server, this file is always created.
- The `.git` file is your entire Git repository, packed up in a single file. This is known as a <a href="https://git-scm.com/blog/2010/03/10/bundles.html" target="_blank">Git Bundle</a>.
- The .changes file is filled with metadata that is used for uploading a package. It includes information about what package(s) you're uploading, as well as file sizes and checksums.
- The `.dsc` file is similar to your .changes file, except this file only contains information on the source. This file contains the information that someone else would need to get the source code you used, install the build dependencies, and then build the binary package themselves.
- The `.dsc` and `.changes` files are normally signed during the package-build process; this gets skipped normally by pdebuild, and gets disabled on `dpkg-buildpackage` by the `-us` `-uc` options. If you plan on uploading these files to a Debian repository, then you should sign them, either manually or using the debsign command.


      debsign singularity_*.changes


You'll be prompted twice, once to sign the `.dsc` file, then again to sign the `.changes` file.

Once signed, you can upload using dput:

      dput stanford singularity_*.changes

That's it! Once your servers upgrade, they should see the newer package version as an option.
