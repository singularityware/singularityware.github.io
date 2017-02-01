---
title: Basic Command Usage
sidebar: user_docs
permalink: docs-usage
folder: docs
---

## The Singularity command
Singularity uses a primary command wrapper called `singularity`. When you run `singularity` without any options or arguments it will dump the high level usage syntax.

The general usage form is:

```bash
$ singularity (opts1) [subcommand] (opts2) ...
```

If you type `singularity` without any arguments, you will see a high level help for all arguments:


```bash
USAGE: singularity [global options...] <command> [command options...] ...

GLOBAL OPTIONS:
    -d --debug    Print debugging information
    -h --help     Display usage summary
    -q --quiet    Only print errors
       --version  Show application version
    -v --verbose  Increase verbosity +1
    -x --sh-debug Print shell wrapper debugging information

GENERAL COMMANDS:
    help          Show additional help for a command

CONTAINER USAGE COMMANDS:
    exec          Execute a command within container
    run           Launch a runscript within container
    shell         Run a Bourne shell within container
    test          Execute any test code defined within container

CONTAINER USAGE OPTIONS:
    -H  --home    Specify $HOME to mount 

CONTAINER MANAGEMENT COMMANDS (requires root):
    bootstrap     Bootstrap a new Singularity image from scratch
    copy          Copy files from your host into the container
    create        Create a new container image
    expand        Grow the container image
    export        Export the contents of a container via a tar pipe
    import        Import/add container contents via a tar pipe
    mount         Mount a Singularity container image

CONTAINER REGISTRY COMMANDS:
    pull          pull a Singularity Hub container to $PWD


For any additional help or support visit the Singularity
website: http://singularity.lbl.gov/
```

### Options and argument processing
Because of the nature of how Singularity cascades commands and sub-commands, argument processing is done with a mandatory order. <strong>This means that where you place arguments is important!</strong> In the above usage example, `opts1` are the global Singularity run-time options. These options are always applicable no matter what subcommand you select (e.g. `--verbose` or `--debug`). But subcommand specific options must be passed after the relevant subcommand.

To further clarify this example, the `exec` Singularity subcommand will execute a program within the container and pass the arguments passed to the program. So to mitigate any argument clashes, Singularity must not interpret or interfere with any of the command arguments or options that are not relevant for that particular function.

### Singularity Help
Singularity comes with some internal documentation by using the `help` subcommand followed by the subcommand you want more information about. For example:

```bash
$ singularity help create
USAGE: singularity (options) create [command] (options)

Create a new Singularity formatted blank image.

OPTIONS:
    -s/--size   Specify a size for an operation (default 1GB)

EXAMPLES:

    $ sudo singularity create /tmp/Debian.img
    $ sudo singularity create -s 4096 /tmp/Debian.img
```
