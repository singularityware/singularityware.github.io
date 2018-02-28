---
title: Singularity Container Instances
sidebar: user_docs
permalink: docs-instances
folder: docs
toc: false
---

Singularity 2.4 introduces the ability to run "container instances", allowing you to run services (*e.g. Nginx, MySQL, etc...*) using Singularity. A container instance, simply put, is a persistent and isolated version of the container image that runs in the background. 

{% include toc.html %}

## Why container instances?
Let's say I want to run a web server. With nginx, that is pretty simple, I install nginx and start the service:

```
apt-get update && apt-get install -y nginx
service nginx start
```

With older versions of Singularity, if you were to do something like this, from inside the container you would happily see the service start, and the web server running! But then if you were to log out of the container what would happen?

Orphan process within unreachable namespaces!

You would lose control of the process. It would still be running, but you couldn't easily kill or interface with it. This is a called an orphan process. Singularity versions less than 2.4 were not designed to handle running services properly.  

## Container Instances in Singularity
With Singularity 2.4 and the addition of container instances, the ability to cleanly, reliably, and safely run services in a container is here. First, let's put some commands that we want our instance to execute into a script. Let's call it a `startscript`. This fits into a definition file like so: 

```
%startscript

service nginx start
```

Now let's say we build a container with that startscript into an image called `nginx.img` and we want to run an nginx service. All we need to do is start the instance with the [`instance.start`](docs-instance-start) command, and the startscript will run inside the container automatically:

```
              [command]        [image]    [name of instance]
$ singularity instance.start   nginx.img  web
```

When we run that command, Singularity creates an isolated environment for the container instances' processes/services to live inside. We can confirm that this command started an instance by running the [`instance.list`](docs-instance-list) command like so:

```
$ singularity instance.list
INSTANCE NAME    PID      CONTAINER IMAGE
web              790      /home/mibauer/nginx.img
```

If we want to run multiple instances from the same image, it's as simple as running the command multiple times. The instance names are an identifier used to uniquely describe an instance, so they cannot be repeated.

```
$ singularity instance.start   nginx.img  web1
$ singularity instance.start   nginx.img  web2
$ singularity instance.start   nginx.img  web3
```

And again to confirm that the instances are running as we expected:

```
$ singularity instance.list
INSTANCE NAME    PID      CONTAINER IMAGE
web1             790      /home/mibauer/nginx.img
web2             791      /home/mibauer/nginx.img
web3             792      /home/mibauer/nginx.img
```

If the service you want to run in your instance requires a bind mount, then you must pass the `-B` option when calling `instance.start`. For example, if you wish to capture the output of the `web1` container instance which is placed at `/output/` inside the container you could do:

```
$ singularity instance.start -B output/dir/outside/:/output/ nginx.img  web1
```

If you want to poke around inside of your instance, you can do a normal `singularity shell` command, but give it the instance URI:

```
$ singularity shell instance://web1
Singularity: Invoking an interactive shell within container...

Singularity pdf_server.img:~/> 
```

Similarly, you can use the `singularity run/exec` commands on instances:

```
$ singularity run instance://web1
$ singularity exec instance://web1 ps -ef
```

When using `run` with an instance URI, the `runscript` will be executed inside of the instance. Similarly with `exec`, it will execute the given command in the instance.

When you are finished with your instance you can clean it up with the [`instance.stop`](docs-instance-stop) command like so:

```
$ singularity instance.stop web1
```

If you have multiple instances running and you want to stop all of them, you can do so with a wildcard or the -a flag:

```
$ singularity instance.stop \*
$ singularity instance.stop -a
```

Note that you must escape the wildcard with a backslash like this `\*` to pass it properly. 

## Nginx "Hello-world" in Singularity

Let's take a look at setting up a sample nginx web server using instances in Singularity. First we will just create a basic definition file:

```
Bootstrap: docker
From: nginx
Includecmd: no

%startscript
	nginx
```

All this does is download the official nginx Docker container, convert it to a Singularity image, and tell it to run nginx when you start the instance. Since we're running a web server, we're going to run the following commands as root.

```
# singularity build nginx.img Singularity
# singularity instance.start nginx.img web1
```

Just like that we've downloaded, built, and ran an nginx Singularity image. And to confirm that it's correctly running:

```
$ curl localhost
127.0.0.1 - - [06/Oct/2017:21:46:43 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.47.0" "-"
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

## Putting it all together

In this section, we will demonstrate an example of packaging a service into a container and running it. The service we will be packaging is an API server that converts a web page into a PDF, and can be found [here](https://github.com/alvarcarto/url-to-pdf-api). The final example can be found [here on GitHub](https://github.com/bauerm97/instance-example), and [here on SingularityHub](https://singularity-hub.org/collections/bauerm97/instance-example/). If you wish to just download the final image directly from Singularity Hub, simply run `singularity pull shub://bauerm97/instance-example`.

### Building the Image

To begin, we need to build the image. When looking at the GitHub page of the `url-to-pdf-api`, we can see that it is a Node 8 server that uses headless Chromium called [Puppeteer](https://github.com/GoogleChrome/puppeteer). Let's first choose a base from which to build our container, in this case I used the docker image `node:8` which comes pre-installed with Node 8:

```
Bootstrap: docker
From: node:8
Includecmd: no
```

Puppeteer also requires a few dependencies to be manually installed in addition to Node 8, so we can add those into the `post` section as well as the installation script for the `url-to-pdf-api`:

```
%post
     apt-get update
     apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
     libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 \
     libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 \
     libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 \
     libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates \
     fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget curl
     rm -r /var/lib/apt/lists/*
     cd /
     git clone https://github.com/alvarcarto/url-to-pdf-api.git pdf_server
     cd pdf_server
     npm install
     chmod -R 0755 .
```

And now we need to define what happens when we start an instance of the container. In this situation, we want to run the commands that starts up the url-to-pdf-api server:

```
%startscript
    cd /pdf_server
    # Use nohup and /dev/null to completely detach server process from terminal
    nohup npm start > /dev/null 2>&1 < /dev/null &
```

Also, the `url-to-pdf-api` server requires some environment variables be set, which we can do in the `environment` section:

```
%environment
    NODE_ENV=development
    PORT=8000
    ALLOW_HTTP=true
    URL=localhost
    export NODE_ENV PORT ALLOW_HTTP URL
```

Now we can build the definition file into an image! Simply run `build` and the image will be ready to go:

```
$ sudo singularity build url-to-pdf-api.img Singularity
```

### Running the Server

Now that we have an image, we are ready to start an instance and run the server:

```
$ singularity instance.start url-to-pdf-api.img pdf
```

We can confirm it's working by sending the server an http request using curl:

```
$ curl -o google.pdf localhost:8000/api/render?url=http://google.com
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 51664  100 51664    0     0  12443      0  0:00:04  0:00:04 --:--:-- 12446
```

If you shell into the instance, you can see the running processes:

```
$ singularity shell instance://pdf 
Singularity: Invoking an interactive shell within container...

Singularity pdf_server.img:~/bauerm97/instance-example> ps auxf
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
node        87  0.2  0.0  20364  3384 pts/0    S    16:16   0:00 /bin/bash --norc
node        88  0.0  0.0  17496  2144 pts/0    R+   16:16   0:00  \_ ps auxf
node         1  0.0  0.0  13968  1904 ?        Ss   16:10   0:00 singularity-instance: mibauer [pdf]
node         3  0.1  0.4 997452 40364 ?        Sl   16:10   0:00 npm                          
node        13  0.0  0.0   4340   724 ?        S    16:10   0:00  \_ sh -c nodemon --watch ./src -e j
node        14  0.0  0.4 1184492 37008 ?       Sl   16:10   0:00      \_ node /scif/apps/pdf_server/p
node        26  0.0  0.0   4340   804 ?        S    16:10   0:00          \_ sh -c node src/index.js
node        27  0.2  0.5 906108 43424 ?        Sl   16:10   0:00              \_ node src/index.js
Singularity pdf_server.img:~/bauerm97/instance-example> ls
LICENSE  README.md  Singularity  out  pdf_server.img
Singularity pdf_server.img:~/bauerm97/instance-example> exit
```

### Making it Pretty

Now that we have confirmation that the server is working, let's make it a little cleaner. It's difficult to remember the exact curl command and URL syntax each time you want to request a PDF, so let's automate that. To do that, we're going to be using Standard Container Integration Format (SCIF) apps, which are integrated directly into singularity. If you haven't already, check out the [Singularity app documentation](docs-scif-apps) to come up to speed. 

First off, we're going to move the installation of the `url-to-pdf-api` into an app, so that there is a designated spot to place output files. To do that, we want to add a section to our definition file to build the server:

```
%appinstall pdf_server
    git clone https://github.com/alvarcarto/url-to-pdf-api.git pdf_server
    cd pdf_server
    npm install
    chmod -R 0755 .
```

And update our `startscript` to point to the app location:

```
%startscript
    cd "${APPROOT_pdf_server}/pdf_server"
    # Use nohup and /dev/null to completely detach server process from terminal
    nohup npm start > /dev/null 2>&1 < /dev/null &
```

Now we want to define the pdf_client app, which we will run to send the requests to the server:

```
%apprun pdf_client
    if [ -z "${1:-}" ]; then
        echo "Usage: singularity run --app pdf <instance://name> <URL> [output file]"
        exit 1
    fi
    curl -o "${SINGULARITY_APPDATA}/output/${2:-output.pdf}" "${URL}:${PORT}/api/render?url=${1}"
```

As you can see, the `pdf_client` app checks to make sure that the user provides at least one argument. Now that we have an output directory in the container, we need to expose it to the host using a bind mount. Once we've rebuilt the container, make a new directory callout `out` for the generated PDF's to go. Now we simply start the instance like so:

```
$ singularity instance.start -B out/:/scif/data/pdf_client/output/ url-to-pdf-api.img pdf
```

And to request a pdf simply do:

```
$ singularity run --app pdf_client instance://pdf http://google.com google.pdf
```

And to confirm that it worked:

```
$ ls out/
google.pdf
```

When you are finished, use the `instance.stop` command to close all running instances.

```
$ singularity instance.stop \*
```

## Important Notes

- The instances are linked with your user. So if you start an instance with sudo, that is going to go under root, and you will need to call `sudo singularity instance.list` in order to see it.
