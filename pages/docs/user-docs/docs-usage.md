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

If you type `singularity` without any arguments, you will see a high level help for all arguments. The main options include:

**Container Actions**

- [build](/docs-build): Build a container on your user endpoint or build environment
- [exec](/docs-exec): Execute a command to your container
- [inspect](/docs-inspect): See labels, run and test scripts, and environment variables
- [pull](/docs-pull): pull an image from Docker or Singularity Hub
- [run](/docs-run): Run your image as an executable
- [shell](/docs-shell): Shell into your image

**Image Commands**

- [image.import](/docs-import): import layers or other file content to your image
- [image.export](/docs-export): export the contents of the image to tar or stream
- [image.create](/docs-create): create a new image, using the old ext3 filesystem
- [image.expand](/docs-create): increase the size of your image (old ext3)

**Instance Commands**

Instances were added in 2.4. This list is brief, and likely to expand with further development.

- [instances](/docs-instances): Start, stop, and list container instances


**Deprecated Commands**
The following commands are deprecated in 2.4 and will be removed in future releases.

- [bootstrap](/docs-bootstrap): Bootstrap a container recipe


For the full usage, see [the bottom of this page](#commands-usage)

### Options and argument processing
Because of the nature of how Singularity cascades commands and sub-commands, argument processing is done with a mandatory order. <strong>This means that where you place arguments is important!</strong> In the above usage example, `opts1` are the global Singularity run-time options. These options are always applicable no matter what subcommand you select (e.g. `--verbose` or `--debug`). But subcommand specific options must be passed after the relevant subcommand.

To further clarify this example, the `exec` Singularity subcommand will execute a program within the container and pass the arguments passed to the program. So to mitigate any argument clashes, Singularity must not interpret or interfere with any of the command arguments or options that are not relevant for that particular function.


### Singularity Help
Singularity comes with some internal documentation by using the `help` subcommand followed by the subcommand you want more information about. For example:

```bash
$ singularity help create
CREATE OPTIONS:
    -s/--size   Specify a size for an operation in MiB, i.e. 1024*1024B
                (default 768MiB)
    -F/--force  Overwrite an image file if it exists

EXAMPLES:

    $ singularity create /tmp/Debian.img
    $ singularity create -s 4096 /tmp/Debian.img

For additional help, please visit our public documentation pages which are
found at:

    http://singularity.lbl.gov/
```

## Commands Usage

```
USAGE: singularity [global options...] <command> [command options...] ...

GLOBAL OPTIONS:
    -d|--debug    Print debugging information
    -h|--help     Display usage summary
    -s|--silent   Only print errors
    -q|--quiet    Suppress all normal output
       --version  Show application version
    -v|--verbose  Increase verbosity +1
    -x|--sh-debug Print shell wrapper debugging information

GENERAL COMMANDS:
    help       Show additional help for a command or container                  
    selftest   Run some self tests for singularity install                      

CONTAINER USAGE COMMANDS:
    exec       Execute a command within container                               
    run        Launch a runscript within container                              
    shell      Run a Bourne shell within container                              
    test       Launch a testscript within container                             

CONTAINER MANAGEMENT COMMANDS:
    apps       List available apps within a container                           
    bootstrap  *Deprecated* use build instead                                   
    build      Build a new Singularity container                                
    check      Perform container lint checks                                    
    inspect    Display a container's metadata                                   
    mount      Mount a Singularity container image                              
    pull       Pull a Singularity/Docker container to $PWD                      

COMMAND GROUPS:
    image      Container image command group                                    
    instance   Persistent instance command group                                


CONTAINER USAGE OPTIONS:
    see singularity help <command>

For any additional help or support visit the Singularity
website: http://singularity.lbl.gov/
```

## Support

Have a question, or need further information? <a href="/support">Reach out to us.</a>
