---
title: Singularity Checks
sidebar: user_docs
permalink: docs-user-checks
folder: docs
toc: false
---

New to Singularity 2.4 is the ability to, on demand, run container "checks," which can be anything from a filter for sensitive information, to an analysis of content on the filesystem. Checks are installed with Singularity and [managed by the administration](/docs-admin-checks), however as a user they are accessible to you for use during bootstrap or on demand:

```
# Perform all default checks, these are the same
$ singularity check ubuntu.img
$ singularity check --tag default ubuntu.img

# Perform checks with tag "clean"
$ singularity check --tag clean ubuntu.img
```

## Tags and Organization
Currently, checks are organized by tag and security level. If you know a specific tag that you want to use, for example "docker" deploys checks for containers with Docker imported layers, you can specify the tag:

```
USAGE

    -t/--tag       tag to filter checks. default is "default"                      
                      Available: default, security, docker, clean


EXAMPLE

singularity check --tag docker ubuntu.img
```

If you want to run checks associated with a different security level, you can specify with `--low`, `--med`, or `-high`:

```
USAGE: singularity [...] check [exec options...] <container path>

This command will run security checks for an image.
Note that some checks require sudo.

    -l/--low       Specify low threshold (all checks, default) 
    -m/--med       Perform medium and high checks
    -h/--high      Perform only checks at level high
```

Note that some checks will require sudo, and you will be alerted if this is the case and you didn't use it. Finally, if you want to run all default checks, just don't specify a tag or level.


## What checks are available?
Currently, you can view all installable checks [here](https://github.com/singularityware/singularity/blob/development/libexec/helpers/check.sh#L49), and we anticipate adding an ability to view tags that are available, along with your own custom checks. You should also ask your administration if new checks have been added not supported by Singularity. If you want to request adding a new check, please <a href="https://github.com/singularityware/singularity/issues" target="_blank">tell us!</a>.
