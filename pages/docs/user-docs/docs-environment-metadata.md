---
title: Environment and Metadata
sidebar: user_docs
permalink: docs-environment-metadata
folder: docs
toc: false
---

Singularity containers support environment variables and labels that you can add to your container during the build process. This page details general information about defining environments and labels. If you are looking for specific environment variables for build time, see [build environment](/build-environment).

{% include toc.html %}

## Environment

If you build a container from Singularity Hub or Docker Hub, the environment will be included with the container at build time. You can also define custom environment variables in your Recipe file like so:

```
Bootstrap: shub
From: vsoch/hello-world

%environment
    VARIABLE_NAME=VARIABLE_VALUE
    export VARIABLE_NAME
```

You may need to add environment variables to your container during the `%post` section.  For instance, maybe you will not know the appropriate value of a variable until you have installed some software.  

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

You will notice that the one label doesn't belong to the label schema, `MAINTAINER`. This was a user provided label during bootstrap. Finally, for Singularity versions >= 2.4, the image build size is added as a label, `org.label-schema.build-size`, and the label schema is used throughout. For versions earlier than 2.4, containers did not use the label schema, and looked like this:

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

Inside of the container, metadata is stored in the `/.singularity.d` directory. You probably shouldn't edit any of these files directly but it may be helpful to know where they are and what they do:

```
/.singularity.d/
├── actions
│   ├── exec
│   ├── run
│   ├── shell
│   ├── start
│   └── test
├── env
│   ├── 01-base.sh
│   ├── 90-environment.sh
│   ├── 95-apps.sh
│   └── 99-base.sh
├── labels.json
├── libs
├── runscript
├── Singularity
└── startscript
```

- **actions**: This directory contains helper scripts to allow the container to carry out the action commands.
- **env**:  All *.sh files in this directory are sourced in alpha-numeric order when the container is initiated. For legacy purposes there is a symbolic link called `/environment` that points to `/.singularity.d/env/90-environment.sh`.
- **labels.json**: The json file that stores a containers labels described above.
- **libs**: At runtime the user may request some host-system libraries to be mapped into the container (with the `--nv` option for example). If so, this is their destination.  
- **runscript**: The commands in this file will be executed when the container is invoked with the `run` command or called as an executable. For legacy purposes there is a symbolic link called `/singularity` that points to this file
- **Singularity**: This is the Recipe file that was used to generate the container. If more than 1 Recipe file was used to generate the container additional Singularity files will appear in numeric order in a sub-directory called `bootstrap_history`
- **startscript**: The commands in this file will be executed when the container is invoked with the `instance.start` command.  

{% include links.html %}
