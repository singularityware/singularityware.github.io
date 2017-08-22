---
title: Environment and Metadata
sidebar: user_docs
permalink: docs-environment-metadata
folder: docs
toc: false
---

Singularity containers support environment variables and labels that can be added by user during the bootstrap process.

{% include toc.html %}

## Environment

If you are importing a Docker container, the environment will be imported as well. If you want to define custom environment variables in your bootstrap recipe file `Singularity` you can do that like this

```bash
Bootstrap:docker
From: ubuntu:latest

%environment
    VARIABLE_NAME=VARIABLE_VALUE
    export VARIABLE_NAME
```

Forget something, or need a variable defined at runtime? You can set any variable you want inside the container by prefixing it with "SINGULARITYENV_". It will be transposed automatically and the prefix will be stripped. For example, let's say we want to set the variable `HELLO` to have value `WORLD`. We can do that as follows:

```bash
$ SINGULARITYENV_HELLO=WORLD singularity exec -e centos7.img env
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

Notice the `-e`? That is the argument (or `--cleanenv`) that specifies that we want to remove the host environment from the container. If we remove the `-e`, we will still pass forward `HELLO=WORLD`, and the list shown above, but we will also pass forward all the other environment variables from the host. Here is a command to directly echo the variable we define:

```bash
$echo 'echo $HELLO' | SINGULARITYENV_HELLO=WORLD singularity exec centos7.img /bin/sh
WORLD
```

If you want to look at the environment inside a container, you can look inside the metadata env folder as follows:

```bash
singularity exec centos7.img ls /.singularity.d/env
01-base.sh  10-docker.sh  99-environment.sh
```

The variables in `01-base.sh` are a set of defaults set upon container creation, and the `10-docker.sh` come from a Docker import.

```bash
singularity exec centos7.img cat /.singularity.d/env/10-docker.sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

## Labels
Your container stores metadata about it's build, along with Docker labels, and your custom labels that you define in a bootstrap `%labels` section. For containers that are generated with Singularity version 2.4 and later, labels are represented using the <a href="http://label-schema.org/rc1/">rc1 Label Schema</a>. For example:

```
singularity inspect dino.img
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

You will notice that the one label doesn't belong to the label schema, `MAINTAINER`. This was a user provided label during bootstrap. For versions earlier than 2.4, containers did not use the label schema:


```bash
singularity exec centos7.img cat /.singularity.d/labels.json
{ "name": 
      "CentOS Base Image", 
       "build-date": "20170315", 
       "vendor": "CentOS", 
       "license": "GPLv2"
}
```

You can add custom labels to your container in a bootstrap file:

```bash
Bootstrap: docker
From: ubuntu: latest

%labels

AUTHOR Vanessasaur
```

{% include links.html %}
