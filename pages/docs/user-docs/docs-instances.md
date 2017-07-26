---
title: Singularity Container Instances
sidebar: user_docs
permalink: docs-instances
folder: docs
toc: false
---

New to Singularity 2.4 is the ability to clone your image, meaning you create an instance of it that has its own namespace. Why would you want to do this? It means that your container can be instantiated and then serve a process that your computer has control of. 

## Why container instances?
Let's say I want to run a web server. With nginx, that is pretty simple, I install nginx and start the service:

```
apt-get update && apt-get install -y nginx
service nginx start
```

With older versions of Singularity, if you were to do something like this, from inside the container you would happily see the service start, and the web server running! But then if you were to log out of the container what would happen?

>> ghost process!!

You would lose control of the process. It would still be running, but you couldn't kill it. This is a called a ghost process, and it means that for running (enduring) services, Singularity was a no starter.


## Cloning containers
With version 2.4, you can do this in a more realistic way. First, let's put the commands of how to start our service into a script. Let's call it a `startscript`. And we can imagine this fitting into a bootstrap recipe file like this:

```
%startscript

service nginx start
```

and we will pretend that we are running with sudo, and we don't specify it above. Now let's say we have a container called `nginx.img` and we want to run it! What do we do?

```
            [action]  [image]    [name of instance]
singularity clone     nginx.img  service
```

When I do that, I still have my file `nginx.img` sitting on my Desktop, but now you can think about having actually an instance of it running, which I can now control! Heck, I could do that multiple times, if it made sense for my service:

```
singularity clone     nginx.img  instance1
singularity clone     nginx.img  instance2
singularity clone     nginx.img  instance3
```

Once you create this instance, you can't do additional things like binds. So if your service requires a special mount or any other kind of connection, do that at the time of the clone:

```
singularity clone   -B /etc/nginx  nginx.img  instance1
```

## Starting Services
Once you have generated instances, you can start them up! You do that with start, directed to the instance name:

```
singularity start nginx.img instance1
```

## Listing Services
You can then easily list services:

```
singularity list 
```

## Important Notes

- The instances are linked with your user. So if you clone and start with sudo, that is going to go under root, and you will be confused to call `singularity list` as your user and then not see your services.
- The only reason to specify the image is because it could be the case that you have two different images with services named equally.


This stuff is completely under development and likely to change! <a href="https://github.com/singularityware/singularity/issues" target="_blank"> Join the conversation!</a>.
