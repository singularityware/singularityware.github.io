---
title: Singularity Inspect
sidebar: user_docs
permalink: docs-inspect
toc: false
folder: docs
---

How can you sniff an image? We have provided the inspect command for you to easily see the runscript, test script, environment, and metadata labels. 

{% include toc.html %}

## Usage

```bash
$ singularity inspect --help

USAGE: singularity [...] inspect [exec options...] <container path>

This command will show you the runscript for the image.

INSPECT OPTIONS:
    -l/--labels      Show the labels associated with the image (default)
    -d/--deffile     Show the bootstrap definition file which was used
                     to generate this image
    -r/--runscript   Show the runscript for this image
    -t/--test        Show the test script for this image
    -e/--environment Show the environment settings for this container
    -j/--json        Print structured json instead of sections

EXAMPLES:
    
    $ singularity inspect ubuntu.img
    #!/bin/sh

    exec /bin/bash "$@"

    $ singularity inspect --labels ubuntu.img
    {
        "SINGULARITY_DEFFILE_BOOTSTRAP": "docker",
        "SINGULARITY_DEFFILE": "Singularity",
        "SINGULARITY_DEFFILE_FROM": "ubuntu:latest",
        "SINGULARITY_BOOTSTRAP_VERSION": "2.2.99"
    }


For additional help, please visit our public documentation pages which are
found at:

    http://singularity.lbl.gov/

```

This inspect is essential for making containers understandable by other tools and applications.


## JSON Api Standard
For any inspect command, by adding `--json` you can be assured to get a <a href="http://jsonapi.org/" target="_blank">JSON API</a> standardized response, for example:

```
singularity inspect -l --json ubuntu.img
{
    "data": {
        "attributes": {
            "labels": {
                "SINGULARITY_DEFFILE_BOOTSTRAP": "docker",
                "SINGULARITY_DEFFILE": "Singularity",
                "SINGULARITY_BOOTSTRAP_VERSION": "2.2.99",
                "SINGULARITY_DEFFILE_FROM": "ubuntu:latest"
            }
        },
        "type": "container"
    }
}
```

## Inspect Flags
The default, if run without any arguments, will show you the container labels file

```
$ singularity inspect ubuntu.img
{
    "SINGULARITY_DEFFILE_BOOTSTRAP": "docker",
    "SINGULARITY_DEFFILE": "Singularity",
    "SINGULARITY_BOOTSTRAP_VERSION": "2.2.99",
    "SINGULARITY_DEFFILE_FROM": "ubuntu:latest"
}

```

and as outlined in the usage, you can specify to see any combination of `--labels`, `--environment`, `--runscript`, `--test`, and `--deffile`. The quick command to see everything, in json format, would be:

```
$ singularity inspect -l -r -d -t -e -j ubuntu.img
{
    "data": {
        "attributes": {
            "test": null,
            "environment": "# Custom environment shell code should follow\n\n",
            "labels": {
                "SINGULARITY_DEFFILE_BOOTSTRAP": "docker",
                "SINGULARITY_DEFFILE": "Singularity",
                "SINGULARITY_BOOTSTRAP_VERSION": "2.2.99",
                "SINGULARITY_DEFFILE_FROM": "ubuntu:latest"
            },
            "deffile": "Bootstrap:docker\nFrom:ubuntu:latest\n",
            "runscript": "#!/bin/sh\n\nexec /bin/bash \"$@\""
        },
        "type": "container"
    }
}
```

### Labels
The default, if run without any arguments, will show you the container labels file (located at `/.singularity.d/labels.json` in the container. These labels are the ones that you define in the `%labels` section of your bootstrap file, along with any Docker `LABEL` that came with an image that you imported, and other metadata about the bootstrap. For example, here we are inspecting labels for `ubuntu.img`

```
$ singularity inspect ubuntu.img
{
    "SINGULARITY_DEFFILE_BOOTSTRAP": "docker",
    "SINGULARITY_DEFFILE": "Singularity",
    "SINGULARITY_BOOTSTRAP_VERSION": "2.2.99",
    "SINGULARITY_DEFFILE_FROM": "ubuntu:latest"
}

```

This is the equivalent of both of:

```
$ singularity inspect -l ubuntu.img
$ singularity inspect --labels ubuntu.img
```



### Runscript
The commands `--runscript` or `-r` will show you the runscript, which also can be shown in `--json`:

```
$ singularity inspect -r -j ubuntu.img{
    "data": {
        "attributes": {
            "runscript": "#!/bin/sh\n\nexec /bin/bash \"$@\""
        },
        "type": "container"
    }
}
```

or in a human friendly, readable print to the screen:

```
$ singularity inspect -r ubuntu.img

##runscript
#!/bin/sh

exec /bin/bash "$@"
```


### Environment
The commands `--environment` and `-e` will show you the container's environment, again specified by the `%environment` section of a bootstrap file, and other `ENV` labels that might have come from a Docker import. You can again choose to see `--json`:

```
$ singularity inspect -e --json ubuntu.img
{
    "data": {
        "attributes": {
            "environment": "# Custom environment shell code should follow\n\n"
        },
        "type": "container"
    }
}

```
or human friendly:

```
$ singularity inspect -e ubuntu.img

##environment
# Custom environment shell code should follow
```

The container in the example above did not have any custom environment variables set.

### Test
The equivalent `--test` or `-t` commands will print any test defined for the container, which comes from the `%test` section of the bootstrap specification Singularity file. Again, we can ask for `--json` or human friendly (default):

```
$ singularity --inspect -t --json ubuntu.img
{
    "data": {
        "attributes": {
            "test": null
        },
        "type": "container"
    }
}

$ singularity inspect -t  ubuntu.img
{
    "status": 404,
    "detail": "This container does not have any tests defined",
    "title": "Tests Undefined"
}

```

### Deffile
Want to know where your container came from? You can see the entire Singularity definition file, if the container was created with a bootstrap, by using `--deffile` or `-d`:

```
$ singularity inspect -d  ubuntu.img

##deffile
Bootstrap:docker
From:ubuntu:latest
```
or with `--json` output.

```
$ singularity inspect -d --json ubuntu.img
{
    "data": {
        "attributes": {
            "deffile": "Bootstrap:docker\nFrom:ubuntu:latest\n"
        },
        "type": "container"
    }
}

```

The goal of these commands is to bring more transparency to containers, and to help better integrate them into common workflows by having them expose their guts to the world! If you have feedback for how we can improve or amend this, please <a href="https://github.com/singularityware/singularity/issues" target="_blank">let us know!</a>

