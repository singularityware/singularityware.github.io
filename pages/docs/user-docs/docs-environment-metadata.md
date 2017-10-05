---
title: Environment and Metadata
sidebar: user_docs
permalink: docs-environment-metadata
folder: docs
toc: false
---

Singularity containers support environment variables and labels that you can add to your container during the build process.

{% include toc.html %}

## Environment

If you build a container from Singularity Hub or Docker Hub, the environment will be imported into the container at build time. You can also define custom environment variables in your Recipe file like so:

```
Bootstrap: shub
From: singularityhub/ubuntu

%environment
    VARIABLE_NAME=VARIABLE_VALUE
    export VARIABLE_NAME
```

You may need to add environment variables to your container during the `$post` section.  For instance, maybe you will not know the appropriate value of a variable until you have installed some software.  

To add variables to the environment during `%post` you can use the `$SINGULARITY_ENVIRONMENT` variable with the following syntax:

```
%post
    echo 'export VARIABLE_NAME=VARIABLE_VALUE' >>$SINGULARITY_ENVIRONMENT
```

Text in the `%environment` section will be appended to the file `/.singularity.d/env/90-environment.sh` while text redirected to `$SINGULARITY_ENVIRONMENT` will end up in the file `/.singularity.d/env/91-environment.sh`.  

Because files in `/.singularity.d/env` are sourced in alpha-numerical order, this means that variables added using `$SINGULARITY_ENVIRONMENT` take precedence over those added via the `%environment` section.

Need to define a variable at runtime? You can set variables inside the container by prefixing them with "SINGULARITYENV_". They will be transposed automatically and the prefix will be stripped. For example, let's say we want to set the variable `HELLO` to have value `WORLD`. We can do that as follows:

```
$ SINGULARITYENV_HELLO=WORLD singularity exec --cleanenv centos7.img env
HELLO=WORLD
LD_LIBRARY_PATH=:/usr/local/lib:/usr/local/lib64
SINGULARITY_NAME=test.img
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PWD=/home/gmk/git/singularity
LANG=en_US.UTF-8
SHLVL=0
SINGULARITY_INIT=1
SINGULARITY_CONTAINER=test.img
```

Notice the `--cleanenv` in the example above? That argument specifies that we want to remove the host environment from the container. If we remove the `--cleanenv`, we will still pass forward `HELLO=WORLD`, and the list shown above, but we will also pass forward all the other environment variables from the host. 

Here is a command to directly echo the variable we define:

## Labels
Your container stores metadata about it's build, along with Docker labels, and custom labels that you define during build in a `%labels` section. For containers that are generated with Singularity version 2.4 and later, labels are represented using the <a href="http://label-schema.org/rc1/">rc1 Label Schema</a>. For example:

```
$ singularity inspect dino.img
{
    "org.label-schema.usage.singularity.deffile.bootstrap": "docker",
    "MAINTAINER": "Vanessasaurus",
    "org.label-schema.usage.singularity.deffile": "Singularity.help",
    "org.label-schema.usage": "/.singularity.d/runscript.help",
    "org.label-schema.schema-version": "1.0",
    "org.label-schema.usage.singularity.deffile.from": "ubuntu:latest",
    "org.label-schema.build-date": "2017-07-28T22:59:17-04:00",
    "org.label-schema.usage.singularity.runscript.help": "/.singularity.d/runscript.help",
    "org.label-schema.usage.singularity.version": "2.3.1-add/label-schema.g00f040f",
    "org.label-schema.build-size": "715MB"
}
```

You will notice that the one label doesn't belong to the label schema, `MAINTAINER`. This was a user provided label during bootstrap. Finally, for Singularity versions >= 2.4, the image build size is added as a label, `org.label-schema.build-size`, and the label schema is used througout. For versions earlier than 2.4, containers did not use the label schema, and looked like this:

```
singularity exec centos7.img cat /.singularity.d/labels.json
{ "name": 
      "CentOS Base Image", 
       "build-date": "20170315", 
       "vendor": "CentOS", 
       "license": "GPLv2"
}
```

You can add custom labels to your container in a bootstrap file:

```
Bootstrap: docker
From: ubuntu: latest

%labels

AUTHOR Vanessasaur
```
The `inspect` command is useful for viewing labels and other container meta-data.  

## Container Metadata

If you want to look at the environment inside a container, you can look inside the metadata env folder as follows:

```
singularity exec centos7.img ls /.singularity.d/env
01-base.sh  10-docker.sh  99-environment.sh
```

The variables in `01-base.sh` are a set of defaults set upon container creation, and the `10-docker.sh` come from a Docker import.

```
singularity exec centos7.img cat /.singularity.d/env/10-docker.sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```




{% include links.html %}
