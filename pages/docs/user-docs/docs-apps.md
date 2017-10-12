---
title: Standard Integration Format (SCI-F) Apps
sidebar: user_docs
permalink: docs-scif-apps
folder: docs
toc: false
---

## Why do we need SCI-F?
SCI-F provides internal modularity of containers, and it makes it easy for the creator to give the container implied metadata about software. For example, installing a set of libraries, defining environment variables, or adding lables that belong to app `foo` makes a strong assertion that those dependencies belong to `foo`. When I run `foo`, I can be confident that the container is running in this context, meaning with `foo's` custom environment, and with `foo`'s libraries and executables on the path. This is drastically different from serving many executables in a single container, because there is no way to know which are associated with which of the container's intended functions.  This documentation will walk through some rationale, background, and examples of modular apps for Singularity containers. If you are interested in the background and rationale for the format, see it's <a href="http://containers-ftw.org/SCI-F/" target="_blank">home here</a>. If you are interested in a combined background and tutorial with asciinema, we've prepared that for you <a href="http://containers-ftw.org/apps/examples/tutorials/getting-started" target="_blank">here</a>. This page will primarily cover how SCI-F works with Singularity images.

{% include toc.html %}

To start, let's take a look at this series of steps to install dependencies for software foo and bar.

```
%post

# install dependencies 1
# install software A (foo)
# install software B (bar)
# install software C (foo)
# install software D (bar)
```

The creator may know that A and C were installed for `foo` and B and D for `bar`, but down the road, when someone discovers the container, if they can find the software at all, the intention of the container creator would be lost. As many are now, containers without any form of internal organization and predictibility are black boxes. We don't know if some software installed to `/opt`, or to `/usr/local/bin`, or to their custom favorite folder `/code`. We could assume that the creator added important software to the path and look in these locations, but that approach is still akin to fishing in a swamp. We might only hope that the container's main function, the Singularity runscript, is enough to make the container perform as intended. 

### Mixed up Modules
If your container truly runs one script, the traditional model of a runscript fits well. Even in the case of having two functions like `foo` and `bar` you probably have something like this.

```
%runscript

if some logic to choose foo:
   check arguments for foo
   run foo
else if some logic to choose bar:
   run bar
```

and maybe your environment looks like this:

```
%environment
BEST_GUY=foo
export BEST_GUY
```

but what if you run into this issue, with foo and bar?

```
%environment
BEST_GUY=foo
BEST_GUY=bar
export BEST_GUY
```

You obviously can't have them at separate times. You'd have to source some custom environment file (that you make on your own) and it gets hard easily with issues of using shell and sourcing. We don't know who the best guy is! You probably get the general idea. Without internal organization and modularity:


 - You have to do a lot of manual work to expose the different software to the user via a custom runscript (and be a generally decent programmer). 
 - All software must share the same metadata, environment, and labels. 


Under these conditions, containers are at best block boxes with unclear delineation between software provided, and only one context of running anything. The container creator shouldn't need to spend inordinate amounts of time writing custom runscripts to support multiple functions and inputs. Each of `foo` and `bar` should be easy to define, and have it's own runscript, environment, labels, tests, and help section.


### Container Transparency
SCI-F Apps make `foo` and `bar` transparent, and solve this problem of mixed up modules. Our simple issue of mixed up modules could be solved if we could do this:

```
Bootstrap:docker
From: ubuntu:16.04

%appenv foo
BEST_GUY=foo
export BEST_GUY

%appenv bar
BEST_GUY=bar
export BEST_GUY

%apprun foo
echo The best guy is $BEST_GUY

%apprun bar
echo The best guy is $BEST_GUY
```

Generate the container, and run it in the context of `foo` and then `bar`

```
$ singularity run --app bar foobar.img 
The best guy is bar
$ singularity run --app foo foobar.img 
The best guy is foo

```


Using SCI-F apps, a user can easily discover both `foo` and `bar` without knowing anything about the container:

```
singularity apps foobar.img
bar
foo
```

and inspect each one:

```
singularity inspect --app foo  foobar.img 
{
    "SINGULARITY_APP_NAME": "foo",
    "SINGULARITY_APP_SIZE": "1MB"
}
```

### Container Modularity
What is going on, under the hood? Just a simple, clean organization that is tied to a set of sections in the build recipe relevant to each app. For example, I can specify custom install procedures (and they are relevant to each app's specific base defined under `/scif/apps`), labels, tests, and help sections. Before I tell you about the sections, I'll briefly show you what the organization looks like, for each app:

```
/scif/apps/

     foo/
        bin/
        lib/
        scif/
            runscript.help
            runscript
            env/
                01-base.sh 
                90-environment.sh

     bar/

     ....
```

If you are familiar with Singularity, the above will look very familiar. It mirrors the Singularity (main container) metadata folder, except instead of `.singularity.d` we have `scif`. The name and base `scif` is chosen intentionally to be something short, and likely to be unique. On the level of organization and metadata, these internal apps are like little containers! Are you worried that you need to remember all this
path nonsense? Don't worry, you don't. You can just use environment variables in your runscripts, etc. Here we are looking at the environment active for lolcat:


```
singularity exec --app lolcat scif.img env | grep lolcat

SINGULARITY_APPOUTPUT=/scif/data/lolcat/output
BEST_APP=lolcat
LD_LIBRARY_PATH=/scif/apps/lolcat/lib:/.singularity.d/libs
APPDATA_lolcat=/scif/data/lolcat
SINGULARITY_APPDATA=/scif/data/lolcat
PATH=/scif/apps/lolcat/bin:/scif/apps/lolcat:/usr/games:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SINGULARITY_APPINPUT=/scif/data/lolcat/input
APPROOT_lolcat=/scif/apps/lolcat
SINGULARITY_APPROOT=/scif/apps/lolcat
SINGULARITY_APPNAME=lolcat
SINGULARITY_APPMETA=/scif/apps/lolcat/scif
```

Notice a few things!

 - the specific environment (`%appenv lolcat`) is active because `BEST_APP` is lolcat
 - the lib folder in lolcat's base is added to the LD_LIBRARY_PATH
 - the bin folder is added to the path
 - locations for input, output, and general data are exposed. It's up to you how you use these, but you can predictably know that a well made app will look for inputs and outputs in it's specific folder.
 - environment variables are provided for the app's root, it's data, and it's name

If you need to interact with other app's during the execution of an app, the base and data folders are provided too (note I filtered this list to show the relevant):

```
singularity exec --app lolcat scif.img env | grep APP

APPDATA_cowsay=/scif/data/cowsay
APPROOT_cowsay=/scif/apps/cowsay

APPROOT_lolcat=/scif/apps/lolcat
APPDATA_lolcat=/scif/data/lolcat

APPDATA_fortune=/scif/data/fortune
APPROOT_fortune=/scif/apps/fortune
```

Also provided are more global paths for data and apps:

```
SINGULARITY_APPS=/scif/apps
SINGULARITY_DATA=/scif/data
```

Importantly, each app has its own modular location. When you do an `%appinstall foo`, the commands are all done in context of that base. The bin and lib are also automatically generated. So what would be a super simple app? Just add a script and name it:

```
%appfiles foo
runfoo.sh   bin/runfoo.sh
```

and then maybe for install I'd make it executable

```
%appinstall foo
chmod u+x bin/runfoo.sh
```

You don't even need files! You could just do this.

```
%appinstall foo
echo 'echo "Hello Foo."' >> bin/runfoo.sh
chmod u+x bin/runfoo.sh
```


Finding the section `%appinstall`, `%apphelp`, or `%apprun` is indication of an application command. The following string is parsed as the name of the application, and this folder is created, in lowercase, under `/scif/apps` if it doesn't exist.  A singularity metadata folder, .singularity.d, equivalent to the container’s main folder, is generated inside the application. An application thus is like a smaller image inside of it’s parent.

Specifically, SCI-F defines the following new sections for the build recipe, where each is optional for 0 or more apps:

**%appinstall** 
corresponds to executing commands within the folder to install the  application. These commands would previously belong in %post, but are now attributable 
to the application.

**%apphelp**
is written as a file called runscript.help in the application's metadata folder,  where the Singularity software knows where to find it. If no help section is provided, the 
software simply will alert the user and show the files provided for inspection.

**%apprun** 
is also written as a file called runscript.exec in the application's metadata 
folder, and again looked for when the user asks to run the software. If not found, the container should default to shelling into that location.

**%applabels**
 will write a labels.json in the application's metadata  folder, allowing for application specific labels. 

**%appenv**
will write an environment file in the application's base folder, allowing for definition of application specific environment variables. 

**%apptest**
will run tests specific to the application, with present working directory assumed to be the software module’s folder

**%appfiles**
will add files to the app's base at `/scif/apps/<app>`


Singularity containers are already reproducible in that they package dependencies. This basic format adds to that by making the software inside of them modular, predictable, and programmatically accessible. We can say confidently that some set of steps, labels, or variables in the runscript is associated with a particular action of the container. We can better reveal how dependencies relate to each step in a scientific workflow.  Making containers is not easy. When a scientist starts to write a recipe for his set of tools, he probably doesn't know where to put it, perhaps that a help file should exist, or that metadata about the software should be served by the container. If container generation software made it easy to organize and capture container content automatically, we would easily meet these goals of internal modularity and consistency, and generate containers that easily integrate with external hosts, data, and other containers. These are essential components for (ultimately) optimizing the way we develop, understand, and execute our scientific containers.


## Cowsay Container
Now let's go through the tutorial to build our <a href="https://github.com/singularityware/singularity/blob/development/examples/apps/Singularity.cowsay" target='_blank'>cowsay container.</a> 


**Important!** This tutorial is for Singularity 2.4, which is still under the development branch. You need to clone development and install it first before using the build command:

```
git clone -b development https://www.github.com/singularityware/singularity.git
cd singularity
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
```

When you've installed 2.4, download the recipe, and save it to your present working directory. By the way, credit for anything and everything lolcat and cowsay goes to <a href="https://www.github.com/GodLoveD" target="_blank">@GodLoveD</a>! Here is the recipe:

```
wget https://raw.githubusercontent.com/singularityware/singularity/development/examples/apps/Singularity.cowsay
sudo singularity build moo.img Singularity.cowsay
```
Note that when development is merged into master, you may need to change "development"  in the address above to master. 

What apps are installed?

```
singularity apps moo.img
cowsay
fortune
lolcat
```

Ask for help for a specific app!

```
singularity help --app fortune moo.img
fortune is the best app
```

Ask for help for all apps, without knowing in advance what they are:

```
for app in $(singularity apps moo.img)
   do
     singularity help --app $app moo.img
done
cowsay is the best app
fortune is the best app
lolcat is the best app
```

Run a particular app

```
singularity run --app fortune moo.img
	My dear People.
	My dear Bagginses and Boffins, and my dear Tooks and Brandybucks,
and Grubbs, and Chubbs, and Burrowses, and Hornblowers, and Bolgers,
Bracegirdles, Goodbodies, Brockhouses and Proudfoots.  Also my good
Sackville Bagginses that I welcome back at last to Bag End.  Today is my
one hundred and eleventh birthday: I am eleventy-one today!"
		-- J. R. R. Tolkien

```

Advanced running - pipe the output of fortune into lolcat, and make a fortune
that is beautifully colored!

```
singularity run --app fortune moo.img | singularity run --app lolcat moo.img
You will be surrounded by luxury.
```

This one might be easier to see - pipe the same fortune into the cowsay app:

```
singularity run --app fortune moo.img | singularity run --app cowsay moo.img
 ________________________________________
/ Executive ability is prominent in your \
\ make-up.                               /
 ----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

and the final shabang - do the same, but make it colored. Let's even get lazy and use
an evironment variable for the command:


```
CMD="singularity run --app"
$CMD fortune moo.img | $CMD cowsay moo.img | $CMD lolcat moo.img
 _________________________________________
/ Ships are safe in harbor, but they were \
\ never meant to stay there.              /
 -----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

```

Yes, you need to watch the asciinema to see the colors. Finally, inspect an app:

```
 singularity inspect --app fortune moo.img 
{
    "SINGULARITY_APP_NAME": "fortune",
    "SINGULARITY_APP_SIZE": "1MB"
}
```

If you haven't yet, <a href="https://asciinema.org/a/139153?speed=3" target="_blank">take a look at these examples</a> with the asciinema!
