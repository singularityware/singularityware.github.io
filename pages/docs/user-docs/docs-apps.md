---
title: Standard Integration Format (SCI-F) Apps
sidebar: user_docs
permalink: docs-scif-apps
folder: docs
toc: false
---

Containers are great for reproducibility. But what happens when you have a large suite of software (possibly some with common dependencies) and you want to provide a (still reproducible) container to serve it? Your bootstrap build `%post` section probably looks like this:

```
%post

# install dependencies 1
# install software #1 (foo)
# install software #2 (bar)

# install software #3
...
# install software #4
```

and as a result, you have some software installed to `/opt`, some to `/usr/local/bin`, and everywhere in between. You also get only one shot at writing the runscript, and defining labels and environment variables. Your runscript probably looks like this.

```
%runscript

if some logic to choose software 1:
   run software 1
else if some logic to choose software 2:
   run software 2
```

This is problematic for several reasons. 

 1. You have to do a lot of manual work to expose the different software to the user via a custom runscript (and be a generally decent programmer). 
 2. All software must share the same metadata, environment, and labels. 

You could make entirely different containers, but now imagine the extreme that the only differences in the software applications are two python modules. Doesn't it make sense to cut the size of storage needed by half and put them in the same container? Isn't it better for reproducibility (in this case) to have them packaged together? These observations reveal something important - that while containers themselves are reproducible, they do not guarantee programmatic accessibility and consistency to make them understandable. This is where the Standard Container Integration Format (SCI-F) comes in. Let's try writing the build recipe again, this time with modularity in mind

```
Bootstrap: docker
From: ubuntu:latest

# Shared 
%labels
MAINTAINER vsochat@stanford.edu


# Here we have steps for application foo
%appinstall foo
    git clone ...
    mkdir bin && cd foo-master
    ./configure --prefix=../bin
    make
    make install

%appenv foo
SOFTWARE=foo
export SOFTWARE

%apphelp foo

Foo: will produce you bar.
Usage: foo [action] [options] ...
 --name/-n name your bar

%apprun foo
    exec echo "RUNNING FOO"


# Here we have steps for application bar
%appinstall bar
    apt-get install bar-doesnotexist

%appenv foo
SOFTWARE=bar
export SOFTWARE

%apprun bar
    /bin/bash start.sh

```

More detail will be provided later, but with this basic setup, I can do things like see the applications installed in a container:

```
singularity apps container.img
bar
foo
```

I can then run a specific application, and the corresponding environment is sourced, and importantly, not any of the others that aren't needed.

```
singularity run --app foo container.img
RUNNING FOO
```

I can also inspect and test applications. Importantly, this basic format makes containers not only reproducible, but the software inside them modular, predictable, and programmatically accessible. These are essential components for (ultimately) optimizing the way we develop, understand, and execute our scientific workflows.

In the following sections, we will go through the introduction and rationale for SCI-F, followed by usage. You can skip ahead to the applied sections if the background is not of interest to you.

{% include toc.html %}


# Introduction

For quite some time, our unit of understanding has been based on the operating system. It is the level of magnification at which we understand data, software, and products of those two things. Recently, however, two needs have arisen: internal modularity and reproducible practices.

To motivate the first need, let’s imagine a scenario where a researcher is developing a container to serve software to answer a specific scientific question. Let’s reduce the complexity of the container, and say that all dependencies aside from a main executable come with the base operating system of the container. Even under this use case, we face a significant issue: the community that wants modularity and programmatic accessibility (developers and maintainers of infrastructure) are usually not the producers of the scientific software. The scientist creating the software, without any help, is likely to produce a container that is akin to a black box. He or she will likely use the container with an understanding of its structure, and not tell others that, for example, the application expects its data input at some /data inside the container, or that for a slightly different command, a second executable is provided that must be called directly. We cannot have knowledge about where the software is installed, how to run it, or possibly integrate it with other resources. In the best case scenario, executing the container will execute some main driver of the software. The best case scenario breaks very quickly when there is more than one executable provided. This lack of internal modularity is the first compelling need for such a standard. It must be easy for the creator to define and organize multiple applications within a single container.

The next need is driven by a larger goal of encouraging reproducible practices. At first glance, containers are a leap in the right direction. Given that all dependencies are packaged nicely, a container is very reproducible. Given this level of representation, a container gives the user absolutely everything - a complete operating system with data, libraries, and software. But this also means that we are producing heavy containers to serve a small amount of software. In terms of reproducibility, we have lost modularity because best practices implement a module on the level of an operating system, and not on the level of the software installed. There are several problems with this practice:

- Containers are not consistent to allow for comparison. Two containers with the same software installed in different locations do not obviously do the same thing, despite this being a possibility.
- Containers are not transparent. If i discover a container and do not have any prior knowledge or metadata, a known function may be completely concealed.
- Container contents are not easily parseable, or programmatically understandable. I should be able to run a function over a container, and know exactly the functions available to me, ask for help for a function, or how and where to interact with inputs and outputs.
- Container internal infrastructure is not modular. We would be weary to export an entire container into another because of overlapping content.

The basis of these core problems can be reduced to the fact that we are being forced to operate on a level that no longer makes sense given the needs of the problem. We need to optimize definition and modular organization of applications and data, and this is a different set of goals than structuring one system per the Filesystem Hierarchy Standard. This goal is also not met moving up one level to one software package per container, because there is huge redundancy with regard to the duplicated filesystem. 

The above problems also hint that the generation of containers is not easy. When a scientist starts to write a recipe for his set of tools, he probably doesn't know where to put it, perhaps that a help file should exist, or that metadata about the software should be served by the container. If container generation software made it easy to organize and capture container content automatically, we would easily meet these goals of internal modularity and consistency, and generate containers that easily integrate with external hosts, data, and other containers.

Based on these problems, it is clear that we need direction and guidance on how organization multiple applications and data within a single container in a way that affords modularity, programmatic accessibility, transparency, and consistency. This document will review the rationale and use cases for the Standard Container Integration Format (SCI-F). We will first review the goals of the architecture, followed by it's primary use case: easy integration with tools that allow for organization and comparison. For interested readers, we finish with some background on its development, and future analysis and work that is afforded by it.


# Goals
The Standard Container Integration Format (SCI-F) establishes an overall goal to make containers *consistent*, *transparent*, *parseable*, and internally *modular*.  Under these goals, we assert that a framework that produces containers, to achieve this standard, must do the following:

- it must provide an encapsulated environment that includes packaged software and data modules, reproducible in that all dependencies are included
- building of multiple containers must be efficient by way of allowing for re-use of common software modules
- each software and data module must carry, minimally, a unique name and install location in the system

To achieve these goals, we introduce the idea of container apps that are installed easily, and conform to a predictable internal organization. Each of the specific goals in context of the assertions is discussed in more detail in the following sections:

## Consistency
Given the case of two containers with the same software installed, it should be the case that the software is always found in the same location. Further, it should be the case that the data (inputs and outputs) that is used and generated at runtime is also located in a consistent manner. To achieve this goal, SCI-F defines a new root folder,  /scif, chosen to be named to have minimal conflict with existing cluster resources. Under this folder are separate folders for each of software modules (/scif/apps), and data (/scif/data) where the container generation software should generate subfolders for each modular application installed. For example, a container with applications foo and bar would have them installed as follows:

```
        /scif
/apps
    /bar
    /foo
```

Thus, if two containers both have `foo` installed, we would know to find the installation under /scif/apps/foo. Data takes a similar approach. We define a new root folder, /scif/data, with a similar subfolder organization:

```
/scif
    /data
       /bar
       /foo
```
Thus, a container in a workflow that knows to execute the foo application would also know where to direct output, or find inputs. The details of the contents of these directories will be discussed further.


## Transparency
Arguably, when we want to know about a container's intended use, we don't care so much for the underlying operating system. We would want to subtract out this base first, and then glimpse at what remains. Given the consistent organization above, and importantly, a distinction between container base operating system (for example, software in /bin, /sbin, or even sometimes /opt, we can easily determine the container's additional software with a simple list command:

```
singularity exec container.img ls /scif/apps -l

  bar
  foo
```

And in the case of the Singularity implementation, this information is available with a shorthand flag, apps. 


```
singularity apps containers.img
  
  bar
  foo
```

We can predictably find and investigate a particular software given that we know the name:

```
singularity shell --pwd /scif/apps/foo container.img
 
$ echo $PWD
$ /scif/apps/foo
```
Or ask a container to run a specific software:
```
singularity run --app foo container.img
RUNNING FOO
```
Another reason to advocate for an organization that is different from most base operating systems is because of mounting. A cluster onto which a container is mounted should be able to (in advance) know the paths that are allowed (/scif/apps) and (/scif/data) and not have these interfere with possibly software that already exists (and might be needed) on the cluster (e.g., /opt).

## Parsability
Parsability comes down to programmatic accessibility. This means that, for each software module installed, we need to be able to (easily) do the following:

provide an entrypoint (e.g., the current "runscript" for a Singularity container, or the Dockerfile `ENTRYPOINT` and `CMD` serve this purpose). We arguably need the different software modules within the container to each provide an entrypoint.
provide help. Given an entrypoint, or if a user wants to understand an installed application, it should be the case that a user can issue a command to view documentation provided for the software. For the developer, adding this functionality should be no harder than writing text in a section of a file.
provide metadata. A software module might have a version, a point of contact or link to further documentation, an author list, or other important metadata values that should be (also) programmatically accessible.

SCI-F will accomplish these goals by way of duplicating the current singularity metadata folder, which serves to provide metadata about a container, to serve each software module installed within the container.
 
## Modularity
A container with distinct, predictable locations for software modules and data is modular. The organization of these modules under a common root ensures that each carries a unique name. Further, this structure allows for easy movement of modules between containers. If a modular carries with it information about installation and dependencies, it could easily be installed in another container. 

### What is a module?
Implied in the above organization is a decision about the level of dimensionality that we want to operate, or defining what is considered a "module." For those familiar with container technology, it is commonly the case that an entire container is considered a module.  To fully discuss this discussion, we will review the extremes.

The smallest modules, one of our extremes, would be akin to breaking containers into the tiniest pieces imaginable. We could say bytes, but this would be like saying that an electron or proton is the ideal level to understand matter. While electrons and protons, and even one level up (atoms) might be an important feature of matter, arguably we can represent a lot more consistent information by moving up one additional level to a collection of atoms, an element. In filesystem science an atom matches to a file. The problem with this level of dimensionality is that individual files aren't usually the means by which we understand software. We usually go one level up, and call a suite of software a grouping of files, in our analogy, akin to an element.

On the other extreme, we could say that an entire host (possibly running multiple containers) or even an entire cluster, is a module. This doesn't need much explanation for why the representation is not suited for developing and deploying analyses - a scientist cannot package up and share his or her entire resource in any reasonable way. Such a feat would require extensive time and money, and not be possible for the individual scientist without some extreme circumstances. 

We thus define a module between those two extremes. We can realistically define a grouping of files that are required to use software, and we can add metadata to form a complete, and programmatically understandable software package or scientific analysis. SCI-F chooses this level of dimensionality for a module because such modules can easily be put together with an operating system to get a containers.

## Reproducible Practices
It is important to make the distinction between a container and a software module that we install under /scif/apps. While the container itself is portable, the application in the folder, in an of itself, is not guaranteed to be. For example, a user might define a software module only with an %apprun section, implying that the folder only contains a runscript to execute. The user may have chosen to install dependencies for this script globally in the container, in the %post section. Under these conditions, if another user expected to move the application to another image, without the dependencies from %post, the application would likely error. As another example, if a user defines an app to install with the package manager “yum,” this application would not move nicely into a debian base. However, appropriate checks and balances can be implemented into the process of moving applications:

- For applications that must be portable outside of their initial container, users would be encouraged to include all dependency installs within the %appinstall section.
- Moving an application from one container to another would check for OS compatibility. This can be done automatically by storing information about the base OS with each application as a label.


With these checks, we can have some confidence that the recipes for generating the apps are maximally portable.


# Integrations
The following sections discuss how such a format fits nicely to allow for integrations, including but not limited to applications and methods to generate reproducible containers, tools and workflow managers that use containers, and metrics for comparison.


## Container Bases
While containers largely provide modular, portable environments, it sometimes is the case that libraries on the host must match the container. Thus, SCI-F supports the idea of having container operating system bases, or base environments that are suited to these different needs onto which the equivalent software modules can be installed.

Under this framework, we can imagine a scenario or use case where a user is developing a container with several software modules for his or her cluster. If the container generation is managed by the cluster resource, under the hood would be provided starter bases that cater to the host needs of the user. This base image with a host operating system and possibly other libraries would be the first decision point of the container generation algorithm. The user might only need to view a list of software modules available given that base, and then select some subset for the image:

```
Operating System --> Library of Modules --> [choose subset] --> New Container
```

Given the same organizational rules across bases, the only filter would be with regard to which software is suited for each base, and ideally, given that software installation recipes are encouraged to be from a source base (or a package repository that is not specific to the host) most modules would work across hosts. In the case of a software module wanting to support multiple different hosts, the same rules would apply as they do now. Checks for the host architecture would come first to the installation procedure.

Likely, data containers, in that they are static (and thus not dependent on host architecture) would be consistent across operating system bases.

Under this framework, it would be possible to create an entire container by specifying an operating system, and then adding to it a set of data and software containers that are specific to the skeleton of choice. The container itself is completely reproducible because it (still) has included all dependencies. It also carries complete metadata about its additions. The landscape of organizing containers also becomes a lot easier because each module is understood as a feature.

Overall, this re-use of base containers, and sharing of software modules, creates a much more organized and less redundant environment. Operating on the level of software and data modules logically come together to form reproducible containers.


## Container Assessment
Given that a software or data module carries one or more signatures, the next logical question is about the kinds of metrics that we want and can to use to classify any given container or module. This idea has been referred to as container curation, and broadly encompasses the tasks of finding a container that serves some function, or representing containers by way of structural or functional features that can be easily compared. Akin to the discussion on levels of modularity, we will start this discussion by reviewing the different ways that we would generally use to assess containers including manual annotation, and functional assessment. We will lead into a discussion of doing this assessment based on file organization and content, a standard provided by SCI-F.


### Manual Annotation
The obvious approach to container curation is human labeled organization, meaning that a person looks at a software package, calls it "biopython" for "biology" in "python" and then moves on. A user later might search for any of these terms and find the container. This same kind of curation might be slightly improved upon if it is done automatically based on the scientists domain of work, or a journal published in. We could even improve upon that by making associations of words in text where the container is defined or cited, and collecting enough data to have some confidence of particular domains being associated. Manual annotation might work well for small, manageable projects, and automated annotation might work given a large enough source of data to learn from, but overall this metric is largely unreliable. We cannot have certainty that every single container has enough citations to make automated methods possible, or in the case of manual annotation, that there is enough manpower to maintain manual annotation.


### Functional Assessment
The second approach to assessing containers is functionally. We can view software as a black box that performs some task, and rank/sort the software based on comparison of that performance. If two different version of a python module act exactly the same, despite subtle differences in the files (imagine the silliest case where the spacing is slightly different) they are still deemed the same thing. If we define a functional metric likes "calculates metric A from data X" and then test software across languages to do this, we can organize based on the degree to which each individual package varies from some average. This metric maps nicely to scientific disciplines (for which the goal is to produce some knowledge about the world. However, this metric is not possible to assess if we don't have a basic understanding of the container content. We could perform this test and treat containers as black boxes, but then it would be hard to know if a difference was due to some small variance in a dependency, or perhaps something about the dataset.

To play devil's advocate, let's pretend that this functional assessment serves the goal of identifying the best container for some task. We then face the challenge of requiring different domains to be able to robustly identify the metrics most relevant for this assessment, and deriving methods for measuring these metrics across new software. If you are, or have worked with scientists, you will know that this kind of agreement is hard to come by. Thus, this again is a manual bottleneck that would be hard to overtake. 

This is not to say that functional assessment should not be done or is not important. It is paramount for scientists to understand the optimal way to achieve some specific goal. However, what we would want to be able to do is a functional assessment to meet a goal, and associate different choices of software and versions to the differences in outcomes that we see. This leads to the need for the final method for assessment, an assessment driven by container organization and content. If we have confidence in the container structure and content, we can know with complete confidence the subtle differences that we see for some functional metric can be linked back to the transparent software choices of the container. 



# Standard Container Integration Format
We now move into the standard itself, the Stanford Container Integration Format is entirely a set of rules about how a container software installs, organizes, and exposes software modules. We will start with a review of some basic background about Linux Filesystems.

## Traditional File Organization
File organization is likely to vary a bit based on the host OS, but arguably most Linux flavor operating systems can said to be similar to the [Filesystem Hierarchy Standard](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard) (FHS). For this discussion, we will disregard the inclusion of package managers, symbolic links, and custom structures, and focus on the core of FHS. We will discuss these locations in the context of how they do (or should) relate to a scientific container.

### Do Not Touch
Arguably, the following folders should not be touched by scientific software:

- /boot: boot loader, kernel files
- /bin: system-wide command binaries (essential for OS)
- /etc: host-wide configuration files
- /lib: again, system level libraries
- /root: root's home. Unless you are using Docker, putting things here leads to trouble.
- /sbin: system specific binaries
- /sys: system, devices, kernel features

While these locations likely have libraries and functions needed by the host to support software, it should not be the case that a scientist installs his or her software under any of these locations. It would not be easy or intuitive to find or untangle it from what is already provided by the host.

### Variable and Working Locations
The following locations are considered working directories in that they hold variables defined at runtime, or intermediate files that are expected to be purged at some point:

- /run: run time variables, should only be used for that, during running of programs.
- /tmp: temporary location for users and programs to dump things.
- /home: can be considered the user's working space. Singularity mounts by default, so nothing would be valued there. The same is true for.

For example, in the context of a container, it is common practice (at least in the case of Singularity) to mount the user's /home. Thus, if a scientist installed his or her software there, the user would not be able to see it unless this default was changed. For these reasons, it is not advisable to assume stability in putting software in these locations.

### Connections
Connections for containers are devices and mount points. A container will arguably always need to be able to support mount points that might be necessary from its host, so it would be important for a scientific container to not put valuables in these locations.

- /dev: essential devices
- /mnt: temporary mounts.
- /srv: is for "site specific data" served by the system. This might be a logical mount for cluster resources.
- /proc connections between processes and resources and hardware information


## SCI-F File Organization
The Standard Container Integration Format defines two root bases that can be known and consistently mounted across research clusters. These locations were chosen to be independent of any locations on traditional linux filesystems for the sole purpose of avoiding conflicts.


### Apps
The base of /apps is where software modules will live. To allow for this, in the context of Singularity, we provide the following user interface for the developer to install a software module to a container. In the example below, we create a build recipe (a file named Singularity) to start with a base Docker image, ubuntu, and install app "foo" into it from Github:

```
Bootstrap: docker
From: ubuntu:latest

%appinstall foo
    git clone ...
    mkdir bin && cd foo-master
    ./configure --prefix=../bin
    make
    make install

%applabels foo
MAINTAINER vsochat@stanford.edu

%appenv foo
FOO=BAR
export FOO


%apptest foo
/bin/bash bin/tests/run_tests.sh

%appfiles foo
README.md README.md 

%apphelp foo

Foo: will produce you bar.
Usage: foo [action] [options] ...
 --name/-n name your bar

%apprun foo

    /bin/bash bin/start.sh
```

In the example above, we defined an application (app) called "foo" and gave the container three sections for it, including a recipe for installation, a simple text print out to show to some user that wants help, and a runscript or entrypoint for the application, with all paths relative to the install folder. The Singularity software would do the following based on this set of instructions:

Finding the section %appinstall, %apphelp, or %apprun is indication of an application command.
The following string is parsed as the name of the application, and this folder is created, in lowercase, under /scif/apps if it doesn't exist.  A singularity metadata folder, .singularity.d, equivalent to the container’s main folder, is generated inside the application. An application thus is like a smaller image inside of it’s parent.

Based on the section name (help, run), the appropriate action is taken:
 - %appinstall corresponds to executing commands within the folder to install the 
application. These commands would previously belong in %post, but are now attributable 
to the application.
 - %apphelp is written as a file called runscript.help in the application's metadata folder, 
where the Singularity software knows where to find it. If no help section is provided, the 
software simply will alert the user and show the files provided for inspection.
 - %apprun is also written as a file called runscript.exec in the application's metadata 
folder, and again looked for when the user asks to run the software. If not found, the container should default to shelling into that location.
 - %applabels will write a labels.json in the application's metadata 
folder, allowing for application specific labels. 
 - %appenv will write an environment file in the application's base folder, allowing for definition of application specific environment variables. 
 - %apptest will run tests specific to the application, with present working directory assumed to be the software module’s folder

Finally, as a requirement of installing software at bootstrap (or with another means that might be developed) checks would be done to ensure that minimal requirements such as folders not being empty are met. Bootstrap will fail if these checks do not pass.

# Usage
A powerful feature of container software applications is allowing for programmatic accessibility to a specific application within a container. For each of the Singularity software’s main commands, run, exec, shell, inspect and test, the same commands can be easily run for an application. 

## Listing Applications
If I wanted to see all applications provided by a container, I could use singularity apps:

```
singularity apps container.img
bar
foo
```

## Application Run
To run a specific application, I can use run with the --app flag:

```
singularity run --app foo container.img
RUNNING FOO
```

This ability to run an application means that the application has its own runscript, defined in the build recipe with %apprun foo. In the case that an application doesn’t have a runscript, the default action is taken, shelling into the container:
```
Singularity run --app bar container.img
No Singularity runscript found, executing /bin/sh into bar
Singularity> 
```
Note that unlike a traditional shell command, we are shelling into the base location for the application, in this case at /scif/apps/bar as running the command makes the assumption the user wants to interact with this software.


## Application Shell, Exec, Test

For the commands shell and exec, in addition to the base container environment being sourced, if the user specifies a specific application, any variables specified for the application’s custom environment are also sourced.
```
     singularity shell --app foo container.img
     singularity exec --app foo container.img
```
An application with tests can be also be tested:
```
singularity test --app bar container.img

```
## Application Inspect
In the case that a user wants to inspect a particular application for a runscript, test, or labels, that is possible on the level of the application:
```
singularity inspect --app foo container.img
{
    "SINGULARITY_APP_SIZE": "1MB",
    "SINGULARITY_APP_NAME": "foo",
    "HELLOTHISIS": "foo"
}
```
The above shows the default output, the labels specific to the application foo.


## Data
The base of /scif/data is structured akin to apps - each installed application has a subfolder for inputs and outputs:

```
/scif/data
   /foo
      /input
      /output
```

and software developers would be advised to make input and output paths programmatically defined, and then users could easily (predictably) define and locate the data. For intermediate data, the same approach is suggested to use a temporary or working directory. As container functions and integrations are further developed, we expect this simple connection into a container for inputs and outputs specific to an application to be very useful. As for the organization and format of the data for any specific application, this is up to the application. Data can either be included with the container, mounted at runtime from the host filesystem, or connected to what can be considered a "data container."

Akin to software modules, overlap in data modules is not allowed. For example, let's say we have an application called foo.


users and developers would know that foo's data would be mounted or provided at /scif/data/foo. The directory is guaranteed to exist in the container, and this addresses the issue of some clusters not being able to generate directories in the container that don't exist at runtime.
importing of distinct data (between bars) under that folder would be allowed, eg /scif/data/foo/bar1 and /sci/data/foo/bar2.
 importing of distinct data (within a bar) would also be allowed, e.g., /scif/data/foo/bar1/this and /scif/data/foo/bar1/that.
importing of overlapping content would not be allowed with a force

An application's data would be traceable to the application by way of it's identifier. Thus, if I find /scif/data/foo I would expect to find the software that generated it under /scif/apps/foo.


# Submodules
This discussion would not be complete without a mention for external modules or dependencies that are required by the software. For example, pip is a package manager that installs to some python base. Two equivalent python installations with different submodules are, by definition, different. There are two possible choices to take, and we leave this choice up to the generator of the container.

In that a python module is likely a shared dependency, or different software modules under `apps` all use python, the user could choose to install shared dependencies to a system python. In the case of conflicting versions, the user would either provide the software in entirely different containers, or install (as would be required regardless of SCI-F) different python environments per each software module.
The user might also choose to install python from a package resource such as anaconda, miniconda, or similar. Given this task, the anaconda (or similar) installation would be considered equivalent to any other software installed to apps. As the developer would do now, the folder /scif/apps/anaconda3 would need to be installed first, and then following commands to use it directed to /scif/apps/anaconda3/bin/python. If the user wanted this python to be consistently on the path, across modules, it should be added to the %environment section.



# Metadata
A software or data module, in its sparsest state, is a folder of files with a name that the container points the user to. However, given easy development and definition of modules, SCI-F advocates for each application having a minimal amount of metadata. For standardization of labels, we will follow the org.label-schema specification, for which we aim to add a simple set of labels for scientific containers

- org.label-schema.schema-version: is in reference to the schema version.
- org.label-schema.version: in addition to a unique identifier provided by the folder name, a version number provided as a label or with running the software with --version
- org.label-schema.hash-md5sum: a content hash of it's guts (without a timestamp), which could easily be provided by Singularity at bootstrap time
- org.label-schema.build-date: the date when the container was generated, or the software module was added.

The metadata about dependencies and steps to create the software would be represented in the %appinstall, which is by default saved with each container. Metadata about different environment variables would go into %appenv, and labels that should be accessible statically go into %applabels. Help for the user is provided under %apphelp.


# Future Work
SCI-F is exciting because it makes basic container development and usage easier. The user can immediately inspect and see the software a container provides, and how to use it. The user can install additional software, copy from one container to another, or view metadata and help documentation. The developer is provided guidance for how and where to install and configure software, but complete freedom with regard to the software itself. The minimum requirements for any package are a name for it's folder, and then optionally a runscript and help document for the user.

## Mapping of container landscape
Given separation of the software from the host, we can more easily derive features that compare software modules. These features can be used with standard unsupervised clustering to better understand how groups of software are used together. We can further apply different labels like domains and understand what modules are shared (or not shared) between scientific domains. We can find opportunity by discovering gaps, that perhaps a software module isn't used for a particular domain (and it might be).
Special Hardware requirements
One can think of FPGA, GPU, etc. that should be available on the host. Any OpenCL or CUDA-based application will depend on the capabilities of the hardware GPU to be able to run successfully.

## Artificial Intelligence (AI) Generated Containers
Given some functional goal, and given a set of containers with measurable features to achieving it, we can (either by brute force or more elegantly) programmatically generate and test containers toward some metric. The landscape of containers can easily be pruned in that the best containers for specific use cases can be easily determined automatically.
